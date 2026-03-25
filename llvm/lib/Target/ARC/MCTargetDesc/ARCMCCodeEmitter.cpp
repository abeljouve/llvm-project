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

  // getBranchTargetEncoding - Return binary encoding for a branch target
  // operand (ARCompact branch/conditional branch instructions).
  unsigned getBranchTargetEncoding(const MCInst &MI, unsigned OpNo,
                                   SmallVectorImpl<MCFixup> &Fixups,
                                   const MCSubtargetInfo &STI) const;

  // getCallTargetEncoding - Return binary encoding for a call target
  // operand (ARCompact BL/BL_S instructions).
  unsigned getCallTargetEncoding(const MCInst &MI, unsigned OpNo,
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

  // TODO: Add fixup support for relocations.
  // For now, return 0 for expression operands. Fixup support will be
  // added when ARCFixupKinds and ARCAsmBackend are implemented.
  return 0;
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

unsigned ARCMCCodeEmitter::getBranchTargetEncoding(
    const MCInst &MI, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);
  if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());

  // Expression operand -- will need a fixup for relocation.
  // TODO: Add proper ARCompact branch fixup kinds.
  return 0;
}

unsigned ARCMCCodeEmitter::getCallTargetEncoding(
    const MCInst &MI, unsigned OpNo, SmallVectorImpl<MCFixup> &Fixups,
    const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);
  if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());

  // Expression operand -- will need a fixup for relocation.
  // TODO: Add proper ARCompact call fixup kinds.
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
