//===- ARCAsmBackend.cpp - ARC Assembler Backend --------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the ARCAsmBackend class for ARC/ARCompact targets.
// Supports both little-endian and big-endian byte ordering.
//
//===----------------------------------------------------------------------===//

#include "ARCFixupKinds.h"
#include "MCTargetDesc/ARCMCTargetDesc.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {

class ARCAsmBackend : public MCAsmBackend {
  uint8_t OSABI;
  bool IsARCompact;

public:
  ARCAsmBackend(llvm::endianness Endian, uint8_t OSABI, bool IsARCompact)
      : MCAsmBackend(Endian), OSABI(OSABI), IsARCompact(IsARCompact) {}

  // Absolute `fixup_arc_32` references always need the linker. For
  // PC-relative branch fixups, applyFixup now handles the ARCompact split
  // bit-field encoding directly, so they can be resolved locally when the
  // target is in the same section — no relocation record needed.
  std::optional<bool> evaluateFixup(const MCFragment &, MCFixup &Fixup,
                                    MCValue &, uint64_t &) override {
    switch (static_cast<unsigned>(Fixup.getKind())) {
    case ARC::fixup_arc_32:
    case ARC::fixup_arc_32_pcrel:
      return false; // Not resolved; emit as relocation.
    default:
      return {};
    }
  }

  void applyFixup(const MCFragment &, const MCFixup &, const MCValue &Target,
                  uint8_t *Data, uint64_t Value, bool IsResolved) override;

  std::unique_ptr<MCObjectTargetWriter>
  createObjectTargetWriter() const override;

  MCFixupKindInfo getFixupKindInfo(MCFixupKind Kind) const override;

  bool writeNopData(raw_ostream &OS, uint64_t Count,
                    const MCSubtargetInfo *STI) const override;
};

} // end anonymous namespace

MCFixupKindInfo ARCAsmBackend::getFixupKindInfo(MCFixupKind Kind) const {
  // clang-format off
  const static MCFixupKindInfo Infos[ARC::NumTargetFixupKinds] = {
    // This table must be in the same order as enum in ARCFixupKinds.h.
    //
    // name                    offset bits flags
    {"fixup_arc_32",             0,    32,  0},
    {"fixup_arc_s21h_pcrel",     0,    21,  0},
    {"fixup_arc_s21w_pcrel",     0,    21,  0},
    {"fixup_arc_s25h_pcrel",     0,    25,  0},
    {"fixup_arc_s25w_pcrel",     0,    25,  0},
    {"fixup_arc_32_pcrel",       0,    32,  0},
    {"fixup_arc_s9h_pcrel",      0,    9,   0},
    {"fixup_arc_s13_lp_pcrel",   0,    13,  0},
  };
  // clang-format on
  static_assert((std::size(Infos)) == ARC::NumTargetFixupKinds,
                "Not all fixup kinds added to Infos array");

  if (Kind < FirstTargetFixupKind)
    return MCAsmBackend::getFixupKindInfo(Kind);

  assert(unsigned(Kind - FirstTargetFixupKind) < ARC::NumTargetFixupKinds &&
         "Invalid kind!");
  return Infos[Kind - FirstTargetFixupKind];
}

// Scatter a PC-relative byte displacement into an ARCompact branch/call
// instruction's split bit fields and return the 32-bit instruction-word
// patch to OR in. Mirrors the layouts decoded in
// arc700-emulator/src/decoder/decode32.rs.
//
//   fixup_arc_s21h_pcrel  (Bcc   — 21-bit half-word signed)
//     raw = (disp >> 1) & 0xFFFFF   // 20 usable bits (S[20:1])
//     bits [26:17] = raw[9:0]       (S[10:1])
//     bits [15:6]  = raw[19:10]     (S[20:11])
//
//   fixup_arc_s21w_pcrel  (BLcc  — 21-bit word-aligned signed)
//     raw = (disp >> 2) & 0x7FFFF   // 19 usable bits (S[20:2])
//     bits [26:18] = raw[8:0]       (S[10:2])
//     bits [15:6]  = raw[18:9]      (S[20:11])
//
//   fixup_arc_s25h_pcrel  (B far — 25-bit half-word signed)
//     raw = (disp >> 1) & 0xFFFFFF  // 24 usable bits (S[24:1])
//     bits [26:17] = raw[9:0]       (S[10:1])
//     bits [15:6]  = raw[19:10]     (S[20:11])
//     bits [3:0]   = raw[23:20]     (S[24:21])
//
//   fixup_arc_s25w_pcrel  (BL far — 25-bit word-aligned signed)
//     raw = (disp >> 2) & 0x7FFFFF  // 23 usable bits (S[24:2])
//     bits [26:18] = raw[8:0]       (S[10:2])
//     bits [15:6]  = raw[18:9]      (S[20:11])
//     bits [3:0]   = raw[22:19]     (S[24:21])
//
//   fixup_arc_s9h_pcrel   (BRcc/BBIT — 9-bit half-word signed)
//     raw = (disp >> 1) & 0xFF      // 8 usable bits (S[8:1])
//     bits [23:17] = raw[6:0]       (S[7:1])
//     bit [15]     = raw[7]         (S[8])
//
//   fixup_arc_s13_lp_pcrel (LP — 13-bit half-word signed loop end)
//     raw = (disp >> 1) & 0xFFF     // 12 usable bits (S[12:1])
//     bits [11:6]  = raw[5:0]       (S[6:1])
//     bits [5:0]   = raw[11:6]      (S[12:7])
//     This is the standard REG_S12IMM split (docs/isa 16-operand-formats):
//     the LOW half of the field sits in the HIGH bit positions. Verified
//     against the reference ARCompact decoder by a single-bit sweep of
//     insn[11:0] (12/12) plus a displacement round-trip including both
//     +/-4 KiB boundaries (19/19).
static uint32_t scatterBranchFixup(unsigned Kind, uint64_t Value) {
  int64_t SDisp = static_cast<int64_t>(Value);
  switch (Kind) {
  case ARC::fixup_arc_s21h_pcrel: {
    uint32_t Raw = (static_cast<uint32_t>(SDisp >> 1)) & 0xFFFFF;
    uint32_t Lo  = Raw & 0x3FF;
    uint32_t Hi  = (Raw >> 10) & 0x3FF;
    return (Lo << 17) | (Hi << 6);
  }
  case ARC::fixup_arc_s21w_pcrel: {
    uint32_t Raw = (static_cast<uint32_t>(SDisp >> 2)) & 0x7FFFF;
    uint32_t Lo  = Raw & 0x1FF;
    uint32_t Hi  = (Raw >> 9) & 0x3FF;
    return (Lo << 18) | (Hi << 6);
  }
  case ARC::fixup_arc_s25h_pcrel: {
    uint32_t Raw = (static_cast<uint32_t>(SDisp >> 1)) & 0xFFFFFF;
    uint32_t Lo  = Raw & 0x3FF;
    uint32_t Md  = (Raw >> 10) & 0x3FF;
    uint32_t T   = (Raw >> 20) & 0xF;
    return (Lo << 17) | (Md << 6) | T;
  }
  case ARC::fixup_arc_s25w_pcrel: {
    uint32_t Raw = (static_cast<uint32_t>(SDisp >> 2)) & 0x7FFFFF;
    uint32_t Lo  = Raw & 0x1FF;
    uint32_t Md  = (Raw >> 9) & 0x3FF;
    uint32_t T   = (Raw >> 19) & 0xF;
    return (Lo << 18) | (Md << 6) | T;
  }
  case ARC::fixup_arc_s9h_pcrel: {
    // S9 = signed byte offset (bit 0 always 0 for 2-byte alignment).
    uint32_t S9 = static_cast<uint32_t>(SDisp) & 0x1FF;
    uint32_t Lo7 = (S9 >> 1) & 0x7F;   // S9[7:1] → Inst[23:17]
    uint32_t Hi1 = (S9 >> 8) & 0x1;    // S9[8]   → Inst[15]
    return (Lo7 << 17) | (Hi1 << 15);
  }
  case ARC::fixup_arc_s13_lp_pcrel: {
    uint32_t Raw = (static_cast<uint32_t>(SDisp >> 1)) & 0xFFF;
    uint32_t Lo = Raw & 0x3F;          // field[5:0]  → Inst[11:6]
    uint32_t Hi = (Raw >> 6) & 0x3F;   // field[11:6] → Inst[5:0]
    return (Lo << 6) | Hi;
  }
  default:
    llvm_unreachable("not a branch fixup");
  }
}

void ARCAsmBackend::applyFixup(const MCFragment &F, const MCFixup &Fixup,
                               const MCValue &Target, uint8_t *Data,
                               uint64_t Value, bool IsResolved) {
  maybeAddReloc(F, Fixup, Target, Value, IsResolved);
  unsigned Kind = Fixup.getKind();

  // ARCompact branch/call fixups use scattered bit fields. Compute the
  // 32-bit instruction-word patch and OR it into the existing encoding in
  // the target endianness.
  switch (Kind) {
  case ARC::fixup_arc_s21h_pcrel:
  case ARC::fixup_arc_s21w_pcrel:
  case ARC::fixup_arc_s25h_pcrel:
  case ARC::fixup_arc_s25w_pcrel:
  case ARC::fixup_arc_s9h_pcrel:
  case ARC::fixup_arc_s13_lp_pcrel: {
    // ARC PC-relative branches compute target = (PC & ~3) + offset. LLVM
    // passes Value = target - fixup_addr where fixup_addr is the exact
    // byte offset of the instruction. Compensate for the alignment-down
    // by adding (fixup_addr & 3) so the encoded displacement matches.
    // LP shares this base: an `lp` at a 2-mod-4 address with field=6
    // targets (PC & ~3) + 12, not PC + 12 — verified against the
    // reference ARCompact decoder.
    uint64_t FixupOff = Asm->getFragmentOffset(F) + Fixup.getOffset();
    int64_t Adjusted = static_cast<int64_t>(Value) +
                       static_cast<int64_t>(FixupOff & 3);
    // LP encodes a signed 12-bit half-word field, so it reaches only
    // +/-4 KiB. Out of range must be a hard error: silently truncating
    // the displacement would relocate the loop end and leave the loop
    // executing the wrong instructions with no runtime signal.
    if (Kind == ARC::fixup_arc_s13_lp_pcrel) {
      if (Adjusted & 1)
        Asm->getContext().reportError(
            Fixup.getLoc(), "lp loop-end target must be 2-byte aligned");
      else if (!isInt<13>(Adjusted))
        Asm->getContext().reportError(
            Fixup.getLoc(), "lp loop-end target out of range (+/-4 KiB)");
    }
    if (!Adjusted)
      return;
    uint32_t Patch =
        scatterBranchFixup(Kind, static_cast<uint64_t>(Adjusted));
    // ARC branch/call instructions are always 32-bit words. Read the
    // existing word in the target endianness, merge, write back.
    uint32_t Insn;
    if (Endian == llvm::endianness::big)
      Insn = (uint32_t(Data[0]) << 24) | (uint32_t(Data[1]) << 16) |
             (uint32_t(Data[2]) << 8)  | uint32_t(Data[3]);
    else
      Insn = uint32_t(Data[0]) | (uint32_t(Data[1]) << 8) |
             (uint32_t(Data[2]) << 16) | (uint32_t(Data[3]) << 24);
    Insn |= Patch;
    if (Endian == llvm::endianness::big) {
      Data[0] = uint8_t(Insn >> 24);
      Data[1] = uint8_t(Insn >> 16);
      Data[2] = uint8_t(Insn >> 8);
      Data[3] = uint8_t(Insn);
    } else {
      Data[0] = uint8_t(Insn);
      Data[1] = uint8_t(Insn >> 8);
      Data[2] = uint8_t(Insn >> 16);
      Data[3] = uint8_t(Insn >> 24);
    }
    return;
  }
  default:
    break;
  }

  // Absolute fixups fall through to the generic linear bit-packer below.
  MCFixupKindInfo Info = getFixupKindInfo(Fixup.getKind());
  if (!Value)
    return; // This value doesn't change the encoding.

  // Shift the value into position.
  Value <<= Info.TargetOffset;

  unsigned NumBytes = alignTo(Info.TargetSize + Info.TargetOffset, 8) / 8;
  assert(Fixup.getOffset() + NumBytes <= F.getSize() &&
         "Invalid fixup offset!");

  // For each byte of the fragment that the fixup touches, mask in the
  // bits from the fixup value. Handle endianness.
  if (Endian == llvm::endianness::big) {
    for (unsigned i = 0; i != NumBytes; ++i) {
      unsigned Idx = NumBytes - 1 - i;
      Data[Idx] |= uint8_t((Value >> (i * 8)) & 0xff);
    }
  } else {
    for (unsigned i = 0; i != NumBytes; ++i) {
      Data[i] |= uint8_t((Value >> (i * 8)) & 0xff);
    }
  }
}

bool ARCAsmBackend::writeNopData(raw_ostream &OS, uint64_t Count,
                                 const MCSubtargetInfo *STI) const {
  if ((Count % 2) != 0)
    return false;

  // ARC NOP encodings:
  // 32-bit NOP: 0x264A7000 (mov 0,0)
  // 16-bit NOP_S: 0x78E0
  for (uint64_t i = 0; i + 4 <= Count; i += 4) {
    if (Endian == llvm::endianness::big)
      OS.write("\x26\x4A\x70\x00", 4);
    else
      OS.write("\x00\x70\x4A\x26", 4);
  }

  // If there are 2 remaining bytes, emit a 16-bit NOP_S.
  if (Count % 4 == 2) {
    if (Endian == llvm::endianness::big)
      OS.write("\x78\xE0", 2);
    else
      OS.write("\xE0\x78", 2);
  }

  return true;
}

std::unique_ptr<MCObjectTargetWriter>
ARCAsmBackend::createObjectTargetWriter() const {
  return createARCELFObjectWriter(OSABI, IsARCompact);
}

MCAsmBackend *llvm::createARCAsmBackend(const Target &T,
                                        const MCSubtargetInfo &STI,
                                        const MCRegisterInfo &MRI,
                                        const MCTargetOptions &Options) {
  const Triple &TT = STI.getTargetTriple();
  llvm::endianness End = TT.isLittleEndian() ? llvm::endianness::little
                                              : llvm::endianness::big;
  uint8_t OSABI = MCELFObjectTargetWriter::getOSABI(TT.getOS());
  // Derive ARCompact-ness from the parsed subtarget feature, not a CPU-name
  // prefix: a CPU like "bcm55030" enables FeatureARCompact (see ARC.td) but
  // does not start with "arc700", and a name-prefix check would silently
  // mis-tag it as ARCv2 (wrong branch-encoding scatter + wrong ELF e_machine).
  bool IsARCompact = STI.getFeatureBits()[ARC::FeatureARCompact];
  return new ARCAsmBackend(End, OSABI, IsARCompact);
}
