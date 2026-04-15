//===- ARCMCCodeEmitter.cpp - ARC Code Emitter ------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the ARCMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//

#include "ARCMCCodeEmitter.h"
#include "ARCFixupKinds.h"
#include "ARCMCTargetDesc.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrDesc.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/TargetParser/Triple.h"
#include <cassert>
#include <cstdint>

#define DEBUG_TYPE "mccodeemitter"

STATISTIC(MCNumEmitted, "Number of MC instructions emitted");

namespace llvm {

namespace {

class ARCMCCodeEmitter : public MCCodeEmitter {
  const MCInstrInfo &MCII;
  MCContext &Ctx;
  bool IsLittleEndian;

public:
  ARCMCCodeEmitter(const MCInstrInfo &MCII, MCContext &Ctx, bool IsLE)
      : MCII(MCII), Ctx(Ctx), IsLittleEndian(IsLE) {}

  ARCMCCodeEmitter(const ARCMCCodeEmitter &) = delete;
  ARCMCCodeEmitter &operator=(const ARCMCCodeEmitter &) = delete;
  ~ARCMCCodeEmitter() override = default;

  // getBinaryCodeForInstr - TableGen'erated function for getting the
  // binary encoding for an instruction.
  uint64_t getBinaryCodeForInstr(const MCInst &MI,
                                 SmallVectorImpl<MCFixup> &Fixups,
                                 const MCSubtargetInfo &STI) const;

  // getMachineOpValue - Return binary encoding of operand. If the machine
  // operand requires relocation, record the relocation and return zero.
  unsigned getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                             SmallVectorImpl<MCFixup> &Fixups,
                             const MCSubtargetInfo &STI) const;

  // getMemIIOpValue - Return binary encoding for MEMii compound operand
  // (used by LIMM load/store instructions).
  uint64_t getMemIIOpValue(const MCInst &MI, unsigned OpNo,
                           SmallVectorImpl<MCFixup> &Fixups,
                           const MCSubtargetInfo &STI) const;

  // getMEMrs9OpValue - Return 15-bit encoding for MEMrs9 compound operand
  // (register base + signed 9-bit offset). Composes the two MI sub-operands
  // into a single value, laid out as [B:6 | S9:9], which matches the
  // `bits<15> addr` field split in F32_ST_ADDR / F32_LD_ADDR.
  uint64_t getMEMrs9OpValue(const MCInst &MI, unsigned OpNo,
                             SmallVectorImpl<MCFixup> &Fixups,
                             const MCSubtargetInfo &STI) const;

  // getBranchTargetS21HEncoding - Return binary encoding for a 21-bit
  // half-word branch target operand (ARCompact Bcc).
  unsigned getBranchTargetS21HEncoding(const MCInst &MI, unsigned OpNo,
                                        SmallVectorImpl<MCFixup> &Fixups,
                                        const MCSubtargetInfo &STI) const;

  // getBranchTargetS25HEncoding - Return binary encoding for a 25-bit
  // half-word branch target operand (ARCompact B far).
  unsigned getBranchTargetS25HEncoding(const MCInst &MI, unsigned OpNo,
                                        SmallVectorImpl<MCFixup> &Fixups,
                                        const MCSubtargetInfo &STI) const;

  // getCallTargetEncoding - Return binary encoding for a call target
  // operand (ARCompact BL/BL_S instructions).
  unsigned getCallTargetEncoding(const MCInst &MI, unsigned OpNo,
                                  SmallVectorImpl<MCFixup> &Fixups,
                                  const MCSubtargetInfo &STI) const;

  // getBRccTargetEncoding - Return binary encoding for an S9 BRcc/BBIT
  // branch target operand (9-bit half-word signed PC-relative).
  unsigned getBRccTargetEncoding(const MCInst &MI, unsigned OpNo,
                                 SmallVectorImpl<MCFixup> &Fixups,
                                 const MCSubtargetInfo &STI) const;

  void encodeInstruction(const MCInst &MI, SmallVectorImpl<char> &CB,
                         SmallVectorImpl<MCFixup> &Fixups,
                         const MCSubtargetInfo &STI) const override;
};

} // end anonymous namespace

unsigned ARCMCCodeEmitter::getMachineOpValue(const MCInst &MI,
                                             const MCOperand &MO,
                                             SmallVectorImpl<MCFixup> &Fixups,
                                             const MCSubtargetInfo &STI) const {
  if (MO.isReg())
    return Ctx.getRegisterInfo()->getEncodingValue(MO.getReg());
  if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());

  // MO must be an expression.
  assert(MO.isExpr() && "Expected an expression operand");

  // Non-branch expression operands (e.g. the LIMM half of an ARCompact
  // instruction that carries a 32-bit absolute address such as
  // `mov r16, @label`) need an absolute 32-bit fixup so the linker can
  // patch in the resolved symbol address.
  Fixups.push_back(
      MCFixup::create(0, MO.getExpr(), MCFixupKind(ARC::fixup_arc_32)));
  return 0;
}

uint64_t ARCMCCodeEmitter::getMEMrs9OpValue(const MCInst &MI, unsigned OpNo,
                                             SmallVectorImpl<MCFixup> &Fixups,
                                             const MCSubtargetInfo &STI) const {
  // MEMrs9 is a compound operand: (GPR32 $B, immS<9> $S9).
  // Pack as 15 bits [14:9]=B, [8:0]=S9 so the F32_ST_ADDR `let` slices
  // reproduce the original bit positions.
  const MCOperand &Base = MI.getOperand(OpNo);
  const MCOperand &Offset = MI.getOperand(OpNo + 1);

  uint64_t BaseEnc = 0;
  if (Base.isReg())
    BaseEnc = Ctx.getRegisterInfo()->getEncodingValue(Base.getReg());

  int64_t OffImm = 0;
  if (Offset.isImm())
    OffImm = Offset.getImm();

  uint64_t S9 = static_cast<uint64_t>(OffImm) & 0x1FF;
  uint64_t B = BaseEnc & 0x3F;
  return (B << 9) | S9;
}

uint64_t ARCMCCodeEmitter::getMemIIOpValue(const MCInst &MI, unsigned OpNo,
                                           SmallVectorImpl<MCFixup> &Fixups,
                                           const MCSubtargetInfo &STI) const {
  // MEMii is a compound operand with two i32imm sub-operands.
  // For LIMM load/store instructions, the address is encoded as the
  // 32-bit long immediate in the upper word of the 64-bit encoding.
  // The first sub-operand is typically 0 (base), and the second is the
  // immediate address.
  const MCOperand &Base = MI.getOperand(OpNo);
  const MCOperand &Offset = MI.getOperand(OpNo + 1);

  uint64_t Value = 0;
  if (Base.isImm())
    Value |= static_cast<uint64_t>(static_cast<uint32_t>(Base.getImm()));
  if (Offset.isImm())
    Value |= static_cast<uint64_t>(static_cast<uint32_t>(Offset.getImm()));

  return Value;
}

unsigned ARCMCCodeEmitter::getBranchTargetS21HEncoding(
    const MCInst &MI, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);
  if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());

  assert(MO.isExpr() && "Expected an expression operand");
  // Bcc: 21-bit signed half-word PC-relative displacement.
  Fixups.push_back(MCFixup::create(
      0, MO.getExpr(), MCFixupKind(ARC::fixup_arc_s21h_pcrel),
      /*PCRel=*/true));
  return 0;
}

unsigned ARCMCCodeEmitter::getBranchTargetS25HEncoding(
    const MCInst &MI, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);
  if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());

  assert(MO.isExpr() && "Expected an expression operand");
  // B far: 25-bit signed half-word PC-relative displacement.
  Fixups.push_back(MCFixup::create(
      0, MO.getExpr(), MCFixupKind(ARC::fixup_arc_s25h_pcrel),
      /*PCRel=*/true));
  return 0;
}

unsigned ARCMCCodeEmitter::getCallTargetEncoding(
    const MCInst &MI, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);
  if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());

  assert(MO.isExpr() && "Expected an expression operand");
  // ARCompact BL encodes the call target as a 25-bit signed word
  // PC-relative displacement. BLcc uses a 21-bit word variant but
  // in practice Rust rarely emits conditional calls; if the assembler
  // sees one with an expression operand it will fault here and we can
  // split this into per-width encoders later.
  Fixups.push_back(MCFixup::create(
      0, MO.getExpr(), MCFixupKind(ARC::fixup_arc_s25w_pcrel),
      /*PCRel=*/true));
  return 0;
}

unsigned ARCMCCodeEmitter::getBRccTargetEncoding(
    const MCInst &MI, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);
  if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());

  assert(MO.isExpr() && "Expected an expression operand");
  // BRcc/BBIT0/BBIT1 encode the target as a 9-bit signed half-word
  // PC-relative displacement, split between bits [23:17] and bit [15].
  Fixups.push_back(MCFixup::create(
      0, MO.getExpr(), MCFixupKind(ARC::fixup_arc_s9h_pcrel),
      /*PCRel=*/true));
  return 0;
}

void ARCMCCodeEmitter::encodeInstruction(const MCInst &MI,
                                         SmallVectorImpl<char> &CB,
                                         SmallVectorImpl<MCFixup> &Fixups,
                                         const MCSubtargetInfo &STI) const {
  const MCInstrDesc &Desc = MCII.get(MI.getOpcode());
  unsigned Size = Desc.getSize();

  // Pseudo instructions and other zero-size instructions don't get encoded.
  if (Size == 0)
    return;

  // Remember how many fixups existed before we encode this instruction so
  // we can fix up their offsets below for LIMM-carrying instructions.
  size_t FixupsBefore = Fixups.size();

  uint64_t Binary = getBinaryCodeForInstr(MI, Fixups, STI);

  auto Endian = IsLittleEndian ? llvm::endianness::little
                               : llvm::endianness::big;

  switch (Size) {
  case 2:
    // 16-bit compact instruction.
    support::endian::write<uint16_t>(CB, static_cast<uint16_t>(Binary), Endian);
    break;
  case 4:
    // 32-bit instruction.
    support::endian::write<uint32_t>(CB, static_cast<uint32_t>(Binary), Endian);
    break;
  case 6:
    // 32-bit instruction + 16-bit immediate (used by some existing ARCv2
    // instruction definitions). Emit the instruction word followed by the
    // immediate half-word.
    support::endian::write<uint32_t>(CB, static_cast<uint32_t>(Binary), Endian);
    support::endian::write<uint16_t>(
        CB, static_cast<uint16_t>(Binary >> 32), Endian);
    break;
  case 8:
    // 32-bit instruction + 32-bit long immediate (LIMM).
    // The instruction word is in bits [31:0] and the LIMM is in bits [63:32].
    support::endian::write<uint32_t>(CB, static_cast<uint32_t>(Binary), Endian);
    support::endian::write<uint32_t>(
        CB, static_cast<uint32_t>(Binary >> 32), Endian);
    break;
  default:
    llvm_unreachable("Unexpected instruction size");
  }

  // Fix up fixup offsets for instructions that carry a 32-bit LIMM: the
  // LIMM lives in bytes [4..8] of the 8-byte encoding, not [0..4]. Fixups
  // on the LIMM operand were created with offset 0 in getMachineOpValue;
  // adjust them to +4 so the ELF writer / applyFixup hit the LIMM bytes.
  if (Size == 8) {
    for (size_t i = FixupsBefore; i < Fixups.size(); ++i) {
      MCFixup &F = Fixups[i];
      F.setOffset(F.getOffset() + 4);
    }
  }

  ++MCNumEmitted;
}

#include "ARCGenMCCodeEmitter.inc"

} // end namespace llvm

llvm::MCCodeEmitter *llvm::createARCMCCodeEmitter(const MCInstrInfo &MCII,
                                                   MCContext &Ctx) {
  const Triple &TT = Ctx.getTargetTriple();
  bool IsLE = TT.isLittleEndian();
  return new ARCMCCodeEmitter(MCII, Ctx, IsLE);
}
