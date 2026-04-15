//===- ARC.cpp ------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// ARCompact (ARC600 / ARC700) and ARCv2 (ARC HS / EM) are 32-bit RISC
// architectures from Synopsys. They share the same ELF machine IDs
// (EM_ARC_COMPACT = 93, EM_ARC_COMPACT2 = 195) and the same relocation
// type numbering, so this backend covers both variants in either
// endianness.
//
// The branch and call relocations use a scattered bit-field encoding: the
// displacement is split across non-contiguous positions within the 32-bit
// instruction word. For example, the 25-bit word-aligned BL displacement
// occupies bits [26:18] (low nine bits), [15:6] (middle ten bits) and
// [3:0] (top four bits). The split mirrors the ARCompact encoding and
// matches the fixup logic in llvm/lib/Target/ARC/MCTargetDesc/
// ARCAsmBackend.cpp.
//
// ARC also has a "PCL" oddity: branch targets are computed relative to
// `PC & ~3`, i.e. the address of the current instruction rounded down to
// a 4-byte boundary. LLVM's generic relocation pipeline hands us
// `val = S + A - P` with an exact fixup address `P`, so we add `P & 3`
// back onto the value before packing it into the instruction.
//
//===----------------------------------------------------------------------===//

#include "InputSection.h"
#include "Symbols.h"
#include "Target.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/Support/Endian.h"

using namespace llvm;
using namespace llvm::object;
using namespace llvm::support::endian;
using namespace llvm::ELF;
using namespace lld;
using namespace lld::elf;

namespace {
class ARC final : public TargetInfo {
public:
  ARC(Ctx &);
  RelExpr getRelExpr(RelType type, const Symbol &s,
                     const uint8_t *loc) const override;
  void relocate(uint8_t *loc, const Relocation &rel,
                uint64_t val) const override;
};
} // namespace

ARC::ARC(Ctx &ctx) : TargetInfo(ctx) {
  // `flag 1` halts the core. Use as unreachable-area filler so a runaway
  // fetch into unused space stops immediately instead of decoding random
  // bytes as valid instructions.
  //
  // Encoding (big-endian arceb): 20 69 00 40
  // Encoding (little-endian arc): 40 00 69 20
  if (ctx.arg.isLE)
    trapInstr = {0x40, 0x00, 0x69, 0x20};
  else
    trapInstr = {0x20, 0x69, 0x00, 0x40};
}

RelExpr ARC::getRelExpr(RelType type, const Symbol &s,
                        const uint8_t *loc) const {
  switch (type) {
  case R_ARC_NONE:
    return R_NONE;
  case R_ARC_8:
  case R_ARC_16:
  case R_ARC_24:
  case R_ARC_32:
  case R_ARC_32_ME:
  case R_ARC_N8:
  case R_ARC_N16:
  case R_ARC_N24:
  case R_ARC_N32:
    return R_ABS;
  case R_ARC_S13_PCREL:
  case R_ARC_S21H_PCREL:
  case R_ARC_S21W_PCREL:
  case R_ARC_S25H_PCREL:
  case R_ARC_S25W_PCREL:
  case R_ARC_32_PCREL:
    return R_PC;
  default:
    Err(ctx) << getErrorLoc(ctx, loc) << "unknown relocation (" << type.v
             << ") against symbol " << &s;
    return R_NONE;
  }
}

// Read/write a 32-bit ARC instruction word in the target endianness.
static uint32_t readInsn(bool isLE, const uint8_t *loc) {
  return isLE ? read32le(loc) : read32be(loc);
}
static void writeInsn(bool isLE, uint8_t *loc, uint32_t val) {
  if (isLE)
    write32le(loc, val);
  else
    write32be(loc, val);
}

// Scatter a byte displacement into an ARCompact branch/call bit layout.
// The instruction bit field positions below match ARCInstrFormats.td and
// the decoder in arc700-emulator/src/decoder/decode32.rs.
namespace {
struct Scatter {
  uint32_t patch;
  uint32_t mask;
};
} // namespace

// R_ARC_S21H_PCREL — Bcc, 21-bit half-word signed (bit 0 implicit zero).
//   bits [26:17] = disp[10:1]  (10 bits, Lo)
//   bits [15:6]  = disp[20:11] (10 bits, Hi)
static Scatter scatterS21H(int64_t disp) {
  uint32_t raw = static_cast<uint32_t>(disp >> 1) & 0xFFFFF;
  uint32_t lo = raw & 0x3FF;
  uint32_t hi = (raw >> 10) & 0x3FF;
  return {(lo << 17) | (hi << 6),
          /*mask=*/(0x3FFu << 17) | (0x3FFu << 6)};
}

// R_ARC_S21W_PCREL — BLcc, 21-bit word-aligned signed.
//   bits [26:18] = disp[10:2]  (9 bits, Lo)
//   bits [15:6]  = disp[20:11] (10 bits, Hi)
static Scatter scatterS21W(int64_t disp) {
  uint32_t raw = static_cast<uint32_t>(disp >> 2) & 0x7FFFF;
  uint32_t lo = raw & 0x1FF;
  uint32_t hi = (raw >> 9) & 0x3FF;
  return {(lo << 18) | (hi << 6),
          /*mask=*/(0x1FFu << 18) | (0x3FFu << 6)};
}

// R_ARC_S25H_PCREL — B far, 25-bit half-word signed.
//   bits [26:17] = disp[10:1]  (10 bits, Lo)
//   bits [15:6]  = disp[20:11] (10 bits, Md)
//   bits [3:0]   = disp[24:21] (4 bits, T)
static Scatter scatterS25H(int64_t disp) {
  uint32_t raw = static_cast<uint32_t>(disp >> 1) & 0xFFFFFF;
  uint32_t lo = raw & 0x3FF;
  uint32_t md = (raw >> 10) & 0x3FF;
  uint32_t t = (raw >> 20) & 0xF;
  return {(lo << 17) | (md << 6) | t,
          /*mask=*/(0x3FFu << 17) | (0x3FFu << 6) | 0xFu};
}

// R_ARC_S25W_PCREL — BL far, 25-bit word-aligned signed.
//   bits [26:18] = disp[10:2]  (9 bits, Lo)
//   bits [15:6]  = disp[20:11] (10 bits, Md)
//   bits [3:0]   = disp[24:21] (4 bits, T)
static Scatter scatterS25W(int64_t disp) {
  uint32_t raw = static_cast<uint32_t>(disp >> 2) & 0x7FFFFF;
  uint32_t lo = raw & 0x1FF;
  uint32_t md = (raw >> 9) & 0x3FF;
  uint32_t t = (raw >> 19) & 0xF;
  return {(lo << 18) | (md << 6) | t,
          /*mask=*/(0x1FFu << 18) | (0x3FFu << 6) | 0xFu};
}

// R_ARC_S13_PCREL — BL_S 13-bit word-aligned compact branch.
//   bits [10:0] = disp[12:2]
static Scatter scatterS13W(int64_t disp) {
  uint32_t raw = static_cast<uint32_t>(disp >> 2) & 0x7FF;
  return {raw, 0x7FFu};
}

void ARC::relocate(uint8_t *loc, const Relocation &rel, uint64_t val) const {
  const bool isLE = ctx.arg.isLE;

  // ARC branches compute `target = (PC & ~3) + offset`. Compensate for
  // the alignment-down by adding the low two bits of the fixup offset
  // back into the resolved displacement. Sections are 4-byte aligned
  // (enforced by link.ld), so `rel.offset & 3` is identical to
  // `fixup_output_vma & 3`.
  auto pcAdjust = [&](int64_t v) -> int64_t {
    return v + static_cast<int64_t>(rel.offset & 3);
  };

  switch (rel.type) {
  case R_ARC_NONE:
    break;

  case R_ARC_8:
    checkIntUInt(ctx, loc, val, 8, rel);
    *loc = val;
    break;

  case R_ARC_16:
    checkIntUInt(ctx, loc, val, 16, rel);
    if (isLE)
      write16le(loc, val);
    else
      write16be(loc, val);
    break;

  case R_ARC_24:
    // Three-byte absolute: top byte first in big-endian.
    checkIntUInt(ctx, loc, val, 24, rel);
    if (isLE) {
      loc[0] = val;
      loc[1] = val >> 8;
      loc[2] = val >> 16;
    } else {
      loc[0] = val >> 16;
      loc[1] = val >> 8;
      loc[2] = val;
    }
    break;

  case R_ARC_32:
  case R_ARC_32_PCREL:
    checkIntUInt(ctx, loc, val, 32, rel);
    writeInsn(isLE, loc, static_cast<uint32_t>(val));
    break;

  case R_ARC_32_ME: {
    // Middle-endian 32-bit LIMM absolute. The LIMM word lives in the
    // second half of an 8-byte ARCompact instruction and the Synopsys
    // assembler stores it as two 16-bit halves, upper half first, each
    // half in the target's native endianness.
    //
    // On big-endian arceb this is identical to a plain 32-bit big-endian
    // write. On little-endian arc the halves are swapped relative to a
    // naive 32-bit write: low-16 LE followed by high-16 LE becomes
    // high-16 LE followed by low-16 LE.
    checkIntUInt(ctx, loc, val, 32, rel);
    uint32_t v32 = static_cast<uint32_t>(val);
    if (isLE) {
      write16le(loc, static_cast<uint16_t>(v32 >> 16));
      write16le(loc + 2, static_cast<uint16_t>(v32));
    } else {
      write32be(loc, v32);
    }
    break;
  }

  case R_ARC_N32:
    // Negated 32-bit absolute.
    writeInsn(isLE, loc, static_cast<uint32_t>(-static_cast<int64_t>(val)));
    break;

  case R_ARC_S21H_PCREL: {
    int64_t v = pcAdjust(static_cast<int64_t>(val));
    checkInt(ctx, loc, v, 21, rel);
    checkAlignment(ctx, loc, v, 2, rel);
    Scatter s = scatterS21H(v);
    uint32_t insn = readInsn(isLE, loc);
    writeInsn(isLE, loc, (insn & ~s.mask) | s.patch);
    break;
  }

  case R_ARC_S21W_PCREL: {
    int64_t v = pcAdjust(static_cast<int64_t>(val));
    checkInt(ctx, loc, v, 21, rel);
    checkAlignment(ctx, loc, v, 4, rel);
    Scatter s = scatterS21W(v);
    uint32_t insn = readInsn(isLE, loc);
    writeInsn(isLE, loc, (insn & ~s.mask) | s.patch);
    break;
  }

  case R_ARC_S25H_PCREL: {
    int64_t v = pcAdjust(static_cast<int64_t>(val));
    checkInt(ctx, loc, v, 25, rel);
    checkAlignment(ctx, loc, v, 2, rel);
    Scatter s = scatterS25H(v);
    uint32_t insn = readInsn(isLE, loc);
    writeInsn(isLE, loc, (insn & ~s.mask) | s.patch);
    break;
  }

  case R_ARC_S25W_PCREL: {
    int64_t v = pcAdjust(static_cast<int64_t>(val));
    checkInt(ctx, loc, v, 25, rel);
    checkAlignment(ctx, loc, v, 4, rel);
    Scatter s = scatterS25W(v);
    uint32_t insn = readInsn(isLE, loc);
    writeInsn(isLE, loc, (insn & ~s.mask) | s.patch);
    break;
  }

  case R_ARC_S13_PCREL: {
    int64_t v = pcAdjust(static_cast<int64_t>(val));
    checkInt(ctx, loc, v, 13, rel);
    checkAlignment(ctx, loc, v, 4, rel);
    Scatter s = scatterS13W(v);
    uint32_t insn = readInsn(isLE, loc);
    writeInsn(isLE, loc, (insn & ~s.mask) | s.patch);
    break;
  }

  default:
    Err(ctx) << getErrorLoc(ctx, loc) << "unrecognized relocation " << rel.type;
  }
}

void elf::setARCTargetInfo(Ctx &ctx) { ctx.target.reset(new ARC(ctx)); }
