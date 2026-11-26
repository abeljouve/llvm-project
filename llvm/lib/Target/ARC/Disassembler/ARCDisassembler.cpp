//===- ARCDisassembler.cpp - Disassembler for ARC ---------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file is part of the ARC Disassembler.
///
//===----------------------------------------------------------------------===//

#include "ARC.h"
#include "ARCRegisterInfo.h"
#include "MCTargetDesc/ARCMCTargetDesc.h"
#include "TargetInfo/ARCTargetInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDecoder.h"
#include "llvm/MC/MCDecoderOps.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/TargetParser/Triple.h"

using namespace llvm;
using namespace llvm::MCD;

#define DEBUG_TYPE "arc-disassembler"

using DecodeStatus = MCDisassembler::DecodeStatus;

namespace {

/// A disassembler class for ARC.
class ARCDisassembler : public MCDisassembler {
public:
  std::unique_ptr<MCInstrInfo const> const MCII;
  // Byte order of the instruction stream, from the target triple (`arc` is
  // little-endian, `arceb` big-endian).
  const bool IsBigEndian;

  ARCDisassembler(const MCSubtargetInfo &STI, MCContext &Ctx,
                  MCInstrInfo const *MCII)
      : MCDisassembler(STI, Ctx), MCII(MCII),
        IsBigEndian(!STI.getTargetTriple().isLittleEndian()) {}

  DecodeStatus getInstruction(MCInst &Instr, uint64_t &Size,
                              ArrayRef<uint8_t> Bytes, uint64_t Address,
                              raw_ostream &CStream) const override;
};

} // end anonymous namespace

// Instruction stream layout.
//
// ARCompact code is a stream of 16-bit parcels. A 32-bit instruction is two
// parcels, the one holding bits [31:16] first; a long immediate (LIMM) that
// follows an instruction is two more parcels, its bits [31:16] first. Each
// parcel is stored in the target's byte order. So on a big-endian target
// every 32-bit quantity is a plain big-endian word, while on a little-endian
// target it is "middle-endian": two little-endian half-words, high half
// first.
//
// The decoder tables see the logical value: the instruction in the low bits
// and the LIMM above it (Inst{47-16} for a 16-bit instruction, Inst{63-32}
// for a 32-bit one).

static uint32_t readParcel16(ArrayRef<uint8_t> Bytes, unsigned Off,
                             bool IsBigEndian) {
  if (IsBigEndian)
    return (uint32_t(Bytes[Off]) << 8) | uint32_t(Bytes[Off + 1]);
  return uint32_t(Bytes[Off]) | (uint32_t(Bytes[Off + 1]) << 8);
}

static uint32_t readWord32(ArrayRef<uint8_t> Bytes, unsigned Off,
                           bool IsBigEndian) {
  return (readParcel16(Bytes, Off, IsBigEndian) << 16) |
         readParcel16(Bytes, Off + 2, IsBigEndian);
}

static bool readInstruction32(ArrayRef<uint8_t> Bytes, uint64_t Address,
                              uint64_t &Size, uint32_t &Insn,
                              bool IsBigEndian) {
  Size = 4;
  Insn = readWord32(Bytes, 0, IsBigEndian);
  return true;
}

static bool readInstruction64(ArrayRef<uint8_t> Bytes, uint64_t Address,
                              uint64_t &Size, uint64_t &Insn,
                              bool IsBigEndian) {
  Size = 8;
  Insn = uint64_t(readWord32(Bytes, 0, IsBigEndian)) |
         (uint64_t(readWord32(Bytes, 4, IsBigEndian)) << 32);
  return true;
}

static bool readInstruction48(ArrayRef<uint8_t> Bytes, uint64_t Address,
                              uint64_t &Size, uint64_t &Insn,
                              bool IsBigEndian) {
  Size = 6;
  Insn = uint64_t(readParcel16(Bytes, 0, IsBigEndian)) |
         (uint64_t(readWord32(Bytes, 2, IsBigEndian)) << 16);
  return true;
}

static bool readInstruction16(ArrayRef<uint8_t> Bytes, uint64_t Address,
                              uint64_t &Size, uint32_t &Insn,
                              bool IsBigEndian) {
  Size = 2;
  Insn = readParcel16(Bytes, 0, IsBigEndian);
  return true;
}

template <unsigned B>
static DecodeStatus
DecodeSignedOperand(MCInst &Inst, unsigned InsnS, uint64_t Address = 0,
                    const MCDisassembler *Decoder = nullptr);

template <unsigned B>
static DecodeStatus
DecodeFromCyclicRange(MCInst &Inst, unsigned InsnS, uint64_t Address = 0,
                      const MCDisassembler *Decoder = nullptr);

template <unsigned B>
static DecodeStatus DecodeBranchTargetS(MCInst &Inst, unsigned InsnS,
                                        uint64_t Address,
                                        const MCDisassembler *Decoder);

static void DecodeSymbolicOperandOff(MCInst &Inst, uint64_t Address,
                                     uint64_t Offset,
                                     const MCDisassembler *Decoder);

static DecodeStatus DecodeMEMrs9(MCInst &, unsigned, uint64_t,
                                 const MCDisassembler *);

static DecodeStatus DecodeLdLImmInstruction(MCInst &, uint64_t, uint64_t,
                                            const MCDisassembler *);

static DecodeStatus DecodeStLImmInstruction(MCInst &, uint64_t, uint64_t,
                                            const MCDisassembler *);

static DecodeStatus DecodeLdRLImmInstruction(MCInst &, uint64_t, uint64_t,
                                             const MCDisassembler *);

static DecodeStatus DecodeSOPwithRS12(MCInst &, uint64_t, uint64_t,
                                      const MCDisassembler *);

static DecodeStatus DecodeSOPwithRU6(MCInst &, uint64_t, uint64_t,
                                     const MCDisassembler *);

static DecodeStatus DecodeCCRU6Instruction(MCInst &, uint64_t, uint64_t,
                                           const MCDisassembler *);

static DecodeStatus DecodeMoveHRegInstruction(MCInst &Inst, uint64_t, uint64_t,
                                              const MCDisassembler *);

static const uint16_t GPR32DecoderTable[] = {
    ARC::R0,  ARC::R1,    ARC::R2,  ARC::R3,   ARC::R4,  ARC::R5,  ARC::R6,
    ARC::R7,  ARC::R8,    ARC::R9,  ARC::R10,  ARC::R11, ARC::R12, ARC::R13,
    ARC::R14, ARC::R15,   ARC::R16, ARC::R17,  ARC::R18, ARC::R19, ARC::R20,
    ARC::R21, ARC::R22,   ARC::R23, ARC::R24,  ARC::R25, ARC::GP,  ARC::FP,
    ARC::SP,  ARC::ILINK, ARC::R30, ARC::BLINK};

static DecodeStatus DecodeGPR32RegisterClass(MCInst &Inst, unsigned RegNo,
                                             uint64_t Address,
                                             const MCDisassembler *Decoder) {
  if (RegNo >= 32) {
    LLVM_DEBUG(dbgs() << "Not a GPR32 register.");
    return MCDisassembler::Fail;
  }

  unsigned Reg = GPR32DecoderTable[RegNo];
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeGBR32ShortRegister(MCInst &Inst, unsigned RegNo,
                                             uint64_t Address,
                                             const MCDisassembler *Decoder) {
  // Enumerates registers from ranges [r0-r3],[r12-r15].
  if (RegNo > 3)
    RegNo += 8; // 4 for r12, etc...

  return DecodeGPR32RegisterClass(Inst, RegNo, Address, Decoder);
}

//===----------------------------------------------------------------------===//
// ARCompact-specific decoder functions
//===----------------------------------------------------------------------===//

// Branch target decoders for ARCompact branch instructions.
// These decode sign-extended PC-relative offsets of various widths.
static DecodeStatus decodeBranchTarget9(MCInst &Inst, unsigned InsnS,
                                        uint64_t Address,
                                        const MCDisassembler *Decoder) {
  return DecodeBranchTargetS<9>(Inst, InsnS, Address, Decoder);
}

static DecodeStatus decodeBranchTarget13(MCInst &Inst, unsigned InsnS,
                                         uint64_t Address,
                                         const MCDisassembler *Decoder) {
  // LP loop-end target -- the sole user of brtarget_s13.
  //
  // This cannot go through DecodeBranchTargetS<13>: the operand is a SIGNED
  // 12-bit field (the REG_S12IMM split), not a 13-bit one, and it holds the
  // displacement scaled by 2. Sign-extending from 13 would take bit 12 as the
  // sign -- a bit the 12-bit field never sets -- so every negative loop-end
  // displacement would decode as a large positive one, and every target would
  // land at half its true distance for want of the <<1.
  //
  // The base is also (PC & ~3) rather than PC, which matters whenever an `lp`
  // sits at a 2-mod-4 address (ARCompact mixes 16- and 32-bit encodings, so
  // it can).
  int32_t Offset = SignExtend32<12>(InsnS) * 2;
  DecodeSymbolicOperandOff(Inst, Address & ~UINT64_C(3), Offset, Decoder);
  return MCDisassembler::Success;
}

static DecodeStatus decodeBranchTarget21(MCInst &Inst, unsigned InsnS,
                                         uint64_t Address,
                                         const MCDisassembler *Decoder) {
  return DecodeBranchTargetS<21>(Inst, InsnS, Address, Decoder);
}

static DecodeStatus decodeBranchTarget25(MCInst &Inst, unsigned InsnS,
                                         uint64_t Address,
                                         const MCDisassembler *Decoder) {
  return DecodeBranchTargetS<25>(Inst, InsnS, Address, Decoder);
}

// Branch target decoders for 16-bit compact branch instructions.
static DecodeStatus decodeBranchTarget7(MCInst &Inst, unsigned InsnS,
                                        uint64_t Address,
                                        const MCDisassembler *Decoder) {
  return DecodeBranchTargetS<7>(Inst, InsnS, Address, Decoder);
}

static DecodeStatus decodeBranchTarget8(MCInst &Inst, unsigned InsnS,
                                        uint64_t Address,
                                        const MCDisassembler *Decoder) {
  return DecodeBranchTargetS<8>(Inst, InsnS, Address, Decoder);
}

static DecodeStatus decodeBranchTarget10(MCInst &Inst, unsigned InsnS,
                                         uint64_t Address,
                                         const MCDisassembler *Decoder) {
  return DecodeBranchTargetS<10>(Inst, InsnS, Address, Decoder);
}

// Call target decoders for ARCompact BL/BL_S instructions.
static DecodeStatus decodeCallTarget13(MCInst &Inst, unsigned InsnS,
                                       uint64_t Address,
                                       const MCDisassembler *Decoder) {
  return DecodeBranchTargetS<13>(Inst, InsnS, Address, Decoder);
}

static DecodeStatus decodeCallTarget21(MCInst &Inst, unsigned InsnS,
                                       uint64_t Address,
                                       const MCDisassembler *Decoder) {
  return DecodeBranchTargetS<21>(Inst, InsnS, Address, Decoder);
}

static DecodeStatus decodeCallTarget25(MCInst &Inst, unsigned InsnS,
                                       uint64_t Address,
                                       const MCDisassembler *Decoder) {
  return DecodeBranchTargetS<25>(Inst, InsnS, Address, Decoder);
}

// GPR_S register class decoder for ARCompact 16-bit instructions.
// The compact register set maps 3-bit encoding to r0-r3, r12-r15.
static const uint16_t GPR_SDecoderTable[] = {
    ARC::R0, ARC::R1, ARC::R2,  ARC::R3,
    ARC::R12, ARC::R13, ARC::R14, ARC::R15,
};

static DecodeStatus DecodeGPR_SRegisterClass(MCInst &Inst, unsigned RegNo,
                                             uint64_t /*Address*/,
                                             const MCDisassembler * /*Decoder*/) {
  if (RegNo >= std::size(GPR_SDecoderTable))
    return MCDisassembler::Fail;

  unsigned Reg = GPR_SDecoderTable[RegNo];
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

#include "ARCGenDisassemblerTables.inc"

static unsigned decodeCField(unsigned Insn) {
  return fieldFromInstruction(Insn, 6, 6);
}

static unsigned decodeBField(unsigned Insn) {
  return (fieldFromInstruction(Insn, 12, 3) << 3) |
         fieldFromInstruction(Insn, 24, 3);
}

static unsigned decodeAField(unsigned Insn) {
  return fieldFromInstruction(Insn, 0, 6);
}

// The hand-written decoders below must fail when a register field does not
// name a GPR32 register (encodings 32-63: extension core registers, LP_COUNT,
// the LIMM marker, PCL). Carrying on after a failed register decode leaves
// the MCInst one operand short of what its AsmWriter entry indexes, and the
// printer then reads past the end of the operand list.
static DecodeStatus DecodeMEMrs9(MCInst &Inst, unsigned Insn, uint64_t Address,
                                 const MCDisassembler *Dec) {
  // We have the 9-bit immediate in the low bits, 6-bit register in high bits.
  unsigned S9 = Insn & 0x1ff;
  unsigned R = (Insn & (0x7fff & ~0x1ff)) >> 9;
  if (DecodeGPR32RegisterClass(Inst, R, Address, Dec) !=
      MCDisassembler::Success)
    return MCDisassembler::Fail;
  Inst.addOperand(MCOperand::createImm(SignExtend32<9>(S9)));
  return MCDisassembler::Success;
}

static bool DecodeSymbolicOperand(MCInst &Inst, uint64_t Address,
                                  uint64_t Value,
                                  const MCDisassembler *Decoder) {
  static const uint64_t AtLeast = 2;
  return (nullptr != Decoder && Decoder->tryAddingSymbolicOperand(
                                    Inst, Value, Address, true, 0, AtLeast, 0));
}

static void DecodeSymbolicOperandOff(MCInst &Inst, uint64_t Address,
                                     uint64_t Offset,
                                     const MCDisassembler *Decoder) {
  uint64_t NextAddress = Address + Offset;

  if (!DecodeSymbolicOperand(Inst, Address, NextAddress, Decoder))
    Inst.addOperand(MCOperand::createImm(Offset));
}

template <unsigned B>
static DecodeStatus DecodeBranchTargetS(MCInst &Inst, unsigned InsnS,
                                        uint64_t Address,
                                        const MCDisassembler *Decoder) {

  static_assert(B > 0, "field is empty");
  DecodeSymbolicOperandOff(Inst, Address, SignExtend32<B>(InsnS), Decoder);
  return MCDisassembler::Success;
}

template <unsigned B>
static DecodeStatus DecodeSignedOperand(MCInst &Inst, unsigned InsnS,
                                        uint64_t /*Address*/,
                                        const MCDisassembler * /*Decoder*/) {

  static_assert(B > 0, "field is empty");
  Inst.addOperand(MCOperand::createImm(
      SignExtend32<B>(maskTrailingOnes<decltype(InsnS)>(B) & InsnS)));
  return MCDisassembler::Success;
}

template <unsigned B>
static DecodeStatus DecodeFromCyclicRange(MCInst &Inst, unsigned InsnS,
                                          uint64_t /*Address*/,
                                          const MCDisassembler * /*Decoder*/) {

  static_assert(B > 0, "field is empty");
  const unsigned max = (1u << B) - 1;
  Inst.addOperand(
      MCOperand::createImm(InsnS < max ? static_cast<int>(InsnS) : -1));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeStLImmInstruction(MCInst &Inst, uint64_t Insn,
                                            uint64_t Address,
                                            const MCDisassembler *Decoder) {
  unsigned SrcC, DstB, LImm;
  DstB = decodeBField(Insn);
  if (DstB != 62) {
    LLVM_DEBUG(dbgs() << "Decoding StLImm found non-limm register.");
    return MCDisassembler::Fail;
  }
  SrcC = decodeCField(Insn);
  if (DecodeGPR32RegisterClass(Inst, SrcC, Address, Decoder) !=
      MCDisassembler::Success)
    return MCDisassembler::Fail;
  LImm = (Insn >> 32);
  Inst.addOperand(MCOperand::createImm(LImm));
  Inst.addOperand(MCOperand::createImm(0));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeLdLImmInstruction(MCInst &Inst, uint64_t Insn,
                                            uint64_t Address,
                                            const MCDisassembler *Decoder) {
  unsigned DstA, SrcB, LImm;
  LLVM_DEBUG(dbgs() << "Decoding LdLImm:\n");
  SrcB = decodeBField(Insn);
  if (SrcB != 62) {
    LLVM_DEBUG(dbgs() << "Decoding LdLImm found non-limm register.");
    return MCDisassembler::Fail;
  }
  DstA = decodeAField(Insn);
  if (DecodeGPR32RegisterClass(Inst, DstA, Address, Decoder) !=
      MCDisassembler::Success)
    return MCDisassembler::Fail;
  LImm = (Insn >> 32);
  Inst.addOperand(MCOperand::createImm(LImm));
  Inst.addOperand(MCOperand::createImm(0));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeLdRLImmInstruction(MCInst &Inst, uint64_t Insn,
                                             uint64_t Address,
                                             const MCDisassembler *Decoder) {
  unsigned DstA, SrcB;
  LLVM_DEBUG(dbgs() << "Decoding LdRLimm\n");
  DstA = decodeAField(Insn);
  if (DecodeGPR32RegisterClass(Inst, DstA, Address, Decoder) !=
      MCDisassembler::Success)
    return MCDisassembler::Fail;
  SrcB = decodeBField(Insn);
  if (DecodeGPR32RegisterClass(Inst, SrcB, Address, Decoder) !=
      MCDisassembler::Success)
    return MCDisassembler::Fail;
  if (decodeCField(Insn) != 62) {
    LLVM_DEBUG(dbgs() << "Decoding LdRLimm found non-limm register.");
    return MCDisassembler::Fail;
  }
  Inst.addOperand(MCOperand::createImm((uint32_t)(Insn >> 32)));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeMoveHRegInstruction(MCInst &Inst, uint64_t Insn,
                                              uint64_t Address,
                                              const MCDisassembler *Decoder) {
  LLVM_DEBUG(dbgs() << "Decoding MOV_S h-register\n");
  using Field = decltype(Insn);
  Field H = fieldFromInstruction(Insn, 5, 3) |
            (fieldFromInstruction(Insn, 0, 2) << 3);
  Field G = fieldFromInstruction(Insn, 8, 3) |
            (fieldFromInstruction(Insn, 3, 2) << 3);

  auto DecodeRegisterOrImm = [&Inst, Address, Decoder](Field RegNum,
                                                       Field Value) {
    if (30 == RegNum) {
      Inst.addOperand(MCOperand::createImm(Value));
      return MCDisassembler::Success;
    }

    return DecodeGPR32RegisterClass(Inst, RegNum, Address, Decoder);
  };

  if (MCDisassembler::Success != DecodeRegisterOrImm(G, 0))
    return MCDisassembler::Fail;

  return DecodeRegisterOrImm(H, Insn >> 16u);
}

static DecodeStatus DecodeCCRU6Instruction(MCInst &Inst, uint64_t Insn,
                                           uint64_t Address,
                                           const MCDisassembler *Decoder) {
  unsigned DstB;
  LLVM_DEBUG(dbgs() << "Decoding CCRU6 instruction:\n");
  DstB = decodeBField(Insn);
  if (DecodeGPR32RegisterClass(Inst, DstB, Address, Decoder) !=
      MCDisassembler::Success)
    return MCDisassembler::Fail;
  using Field = decltype(Insn);
  Field U6Field = fieldFromInstruction(Insn, 6, 6);
  Inst.addOperand(MCOperand::createImm(U6Field));
  Field CCField = fieldFromInstruction(Insn, 0, 4);
  Inst.addOperand(MCOperand::createImm(CCField));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeSOPwithRU6(MCInst &Inst, uint64_t Insn,
                                     uint64_t Address,
                                     const MCDisassembler *Decoder) {
  unsigned DstB = decodeBField(Insn);
  if (DecodeGPR32RegisterClass(Inst, DstB, Address, Decoder) !=
      MCDisassembler::Success)
    return MCDisassembler::Fail;
  using Field = decltype(Insn);
  Field U6 = fieldFromInstruction(Insn, 6, 6);
  Inst.addOperand(MCOperand::createImm(U6));
  return MCDisassembler::Success;
}

static DecodeStatus DecodeSOPwithRS12(MCInst &Inst, uint64_t Insn,
                                      uint64_t Address,
                                      const MCDisassembler *Decoder) {
  unsigned DstB = decodeBField(Insn);
  if (DecodeGPR32RegisterClass(Inst, DstB, Address, Decoder) !=
      MCDisassembler::Success)
    return MCDisassembler::Fail;
  // S[5:0] in bits [11:6], S[11:6] in bits [5:0], two's complement (not
  // sign and magnitude: 0xfff is -1).
  unsigned S12 = (fieldFromInstruction(Insn, 0, 6) << 6) |
                 fieldFromInstruction(Insn, 6, 6);
  Inst.addOperand(MCOperand::createImm(SignExtend32<12>(S12)));
  return MCDisassembler::Success;
}

DecodeStatus ARCDisassembler::getInstruction(MCInst &Instr, uint64_t &Size,
                                             ArrayRef<uint8_t> Bytes,
                                             uint64_t Address,
                                             raw_ostream &cStream) const {
  MCDisassembler::DecodeStatus Result;
  if (Bytes.size() < 2) {
    Size = 0;
    return Fail;
  }
  // The major opcode sits in bits [15:11] of the first parcel, i.e. in its
  // most significant byte: the first byte on a big-endian target, the second
  // on a little-endian one.
  uint8_t DecodeByte = (Bytes[IsBigEndian ? 0 : 1] & 0xF7) >> 3;
  // 0x00 -> 0x07 are 32-bit instructions.
  // 0x08 -> 0x1F are 16-bit instructions.
  if (DecodeByte < 0x08) {
    // 32-bit instruction.
    if (Bytes.size() < 4) {
      // Did we decode garbage?
      Size = 0;
      return Fail;
    }
    if (Bytes.size() >= 8) {
      // Attempt to decode 64-bit instruction.
      uint64_t Insn64;
      if (!readInstruction64(Bytes, Address, Size, Insn64, IsBigEndian))
        return Fail;
      // Default (ARCv2) table first, then the ARCompact LIMM forms -- see
      // the 32-bit tables below for the order.
      Result =
          decodeInstruction(DecoderTable64, Instr, Insn64, Address, this, STI);
      if (Success == Result) {
        LLVM_DEBUG(dbgs() << "Successfully decoded 64-bit instruction.");
        return Result;
      }
      Result = decodeInstruction(DecoderTableARCompact3264, Instr, Insn64,
                                 Address, this, STI);
      if (Success == Result) {
        LLVM_DEBUG(dbgs() << "Decoded ARCompact 64-bit instruction.");
        return Result;
      }
      LLVM_DEBUG(dbgs() << "Not a 64-bit instruction, falling back to 32-bit.");
    }
    uint32_t Insn32;
    if (!readInstruction32(Bytes, Address, Size, Insn32, IsBigEndian)) {
      return Fail;
    }
    // Default (ARCv2) table first, then the ARCompact one (separate
    // DecoderNamespace, enabled by FeatureARCompact). For the encodings both
    // tables know -- the base ALU, load/store and branch forms, which
    // ARCompact and ARCv2 share -- the default table's defs carry the
    // complete operand set (condition, .f, .di, scaled offsets,
    // PC-relative targets), while many generated ARCompact defs drop part of
    // it. The ARCompact table then supplies what the default one lacks
    // (flag, the bit operations, ...).
    //
    // Not for majors 0 and 1 (Bcc/B, BLcc/BL, BRcc, BBIT): the ARCompact
    // branch defs decode the split displacement fields without assembling
    // and scaling them, so their targets are wrong. An undecoded word is
    // better than a wrong branch target.
    Result = decodeInstruction(DecoderTable32, Instr, Insn32, Address, this,
                               STI);
    if (Success == Result)
      return Result;
    if ((Insn32 >> 27) <= 1)
      return Result;
    Result = decodeInstruction(DecoderTableARCompact3232, Instr, Insn32,
                               Address, this, STI);
    if (Success == Result)
      LLVM_DEBUG(dbgs() << "Decoded ARCompact 32-bit instruction.");
    return Result;
  } else {
    if (Bytes.size() >= 6) {
      // Attempt to treat as instr. with limm data.
      uint64_t Insn48;
      if (!readInstruction48(Bytes, Address, Size, Insn48, IsBigEndian))
        return Fail;
      Result =
          decodeInstruction(DecoderTable48, Instr, Insn48, Address, this, STI);
      if (Success == Result) {
        LLVM_DEBUG(
            dbgs() << "Successfully decoded 16-bit instruction with limm.");
        return Result;
      }
      LLVM_DEBUG(
          dbgs() << "Not a 16-bit instruction with limm, try without it.");
    }

    uint32_t Insn16;
    if (!readInstruction16(Bytes, Address, Size, Insn16, IsBigEndian))
      return Fail;

    // Calling the auto-generated decoder function.
    return decodeInstruction(DecoderTable16, Instr, Insn16, Address, this, STI);
  }
}

static MCDisassembler *createARCDisassembler(const Target &T,
                                             const MCSubtargetInfo &STI,
                                             MCContext &Ctx) {
  return new ARCDisassembler(STI, Ctx, T.createMCInstrInfo());
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeARCDisassembler() {
  // Register the disassembler.
  TargetRegistry::RegisterMCDisassembler(getTheARCTarget(),
                                         createARCDisassembler);
  TargetRegistry::RegisterMCDisassembler(getTheARCebTarget(),
                                         createARCDisassembler);
}
