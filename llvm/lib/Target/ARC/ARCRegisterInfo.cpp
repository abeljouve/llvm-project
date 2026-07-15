//===- ARCRegisterInfo.cpp - ARC Register Information -----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the ARC implementation of the MRegisterInfo class.
//
//===----------------------------------------------------------------------===//

#include "ARCRegisterInfo.h"
#include "ARC.h"
#include "ARCInstrInfo.h"
#include "ARCMachineFunctionInfo.h"
#include "ARCSubtarget.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/Debug.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetOptions.h"

using namespace llvm;

#define DEBUG_TYPE "arc-reg-info"

#define GET_REGINFO_TARGET_DESC
#include "ARCGenRegisterInfo.inc"

static void replaceFrameIndex(MachineBasicBlock::iterator II,
                              const ARCInstrInfo &TII, unsigned Reg,
                              unsigned FrameReg, int Offset, int StackSize,
                              int ObjSize, RegScavenger *RS, int SPAdj) {
  assert(RS && "Need register scavenger.");
  MachineInstr &MI = *II;
  MachineBasicBlock &MBB = *MI.getParent();
  DebugLoc DL = MI.getDebugLoc();
  unsigned BaseReg = FrameReg;
  unsigned KillState = 0;
  if (MI.getOpcode() == ARC::LD_rs9 && (Offset >= 256 || Offset < -256)) {
    // Loads can always be reached with LD_rlimm.
    BuildMI(MBB, II, DL, TII.get(ARC::LD_rlimm), Reg)
        .addReg(BaseReg)
        .addImm(Offset)
        .addMemOperand(*MI.memoperands_begin());
    MBB.erase(II);
    return;
  }

  if (MI.getOpcode() != ARC::GETFI && (Offset >= 256 || Offset < -256)) {
    // We need to use a scratch register to reach the far-away frame indexes.
    // For stores, Reg holds the value being stored and must not be reused as
    // the scratch base — otherwise the ADD that computes the address overwrites
    // the value before the ST reads it.
    bool IsStore = MI.getOpcode() == ARC::ST_rs9 ||
                   MI.getOpcode() == ARC::STH_rs9 ||
                   MI.getOpcode() == ARC::STB_rs9;
    if (IsStore)
      RS->setRegUsed(Reg);
    BaseReg = RS->FindUnusedReg(&ARC::GPR32RegClass);
    if (!BaseReg) {
      // We can be sure that the scavenged-register slot is within the range
      // of the load offset.
      const TargetRegisterInfo *TRI =
          MBB.getParent()->getSubtarget().getRegisterInfo();
      BaseReg =
          RS->scavengeRegisterBackwards(ARC::GPR32RegClass, II, false, SPAdj);
      assert(BaseReg && "Register scavenging failed.");
      LLVM_DEBUG(dbgs() << "Scavenged register " << printReg(BaseReg, TRI)
                        << " for FrameReg=" << printReg(FrameReg, TRI)
                        << "+Offset=" << Offset << "\n");
      (void)TRI;
      RS->setRegUsed(BaseReg);
    }
    unsigned AddOpc = isUInt<6>(Offset) ? ARC::ADD_rru6 : ARC::ADD_rrlimm;
    BuildMI(MBB, II, DL, TII.get(AddOpc))
        .addReg(BaseReg, RegState::Define)
        .addReg(FrameReg)
        .addImm(Offset);
    Offset = 0;
    KillState = RegState::Kill;
  }
  switch (MI.getOpcode()) {
  // The S9 field of LD_rs9 / ST_rs9 is a signed byte offset; the ARC700
  // encoding itself imposes no alignment. On real BCM55030 silicon,
  // misaligned word/half-word accesses do NOT trap and are NOT hardware
  // fixed up: STATUS32.AD does not provide an unaligned-access-enable path
  // on this core, and a misaligned effective address is silently rounded
  // down (word: addr & ~3, half-word: addr & ~1), corrupting the accessed
  // data. See docs/notes/isa-characterization.md. A prior comment here
  // claiming "STATUS32.AD" performs a runtime fixup was an unverified
  // assumption, disproved by silicon characterization -- do not
  // reintroduce it.
  //
  // ARCTargetLowering::allowsMisalignedMemoryAccesses (ARCISelLowering.cpp)
  // now unconditionally reports misaligned multi-byte accesses as illegal,
  // so SelectionDAG legalization always peels an insufficiently-aligned IR
  // load/store into byte/half-word ops before an LD_rs9/ST_rs9/LDH_rs9/
  // STH_rs9 can ever be selected. A frame-relative multi-byte access
  // reaching here with a non-naturally-aligned effective offset is
  // therefore a backend bug, not valid user code -- reinstate the
  // assertion to catch it.
  case ARC::LD_rs9:
    assert((Offset % 4 == 0) && "LD needs 4 byte alignment.");
    [[fallthrough]];
  case ARC::LDH_rs9:
  case ARC::LDH_X_rs9:
    assert((Offset % 2 == 0) && "LDH needs 2 byte alignment.");
    [[fallthrough]];
  case ARC::LDB_rs9:
  case ARC::LDB_X_rs9:
    LLVM_DEBUG(dbgs() << "Building LDFI\n");
    BuildMI(MBB, II, DL, TII.get(MI.getOpcode()), Reg)
        .addReg(BaseReg, KillState)
        .addImm(Offset)
        .addMemOperand(*MI.memoperands_begin());
    break;
  case ARC::ST_rs9:
    assert((Offset % 4 == 0) && "ST needs 4 byte alignment.");
    [[fallthrough]];
  case ARC::STH_rs9:
    assert((Offset % 2 == 0) && "STH needs 2 byte alignment.");
    [[fallthrough]];
  case ARC::STB_rs9:
    LLVM_DEBUG(dbgs() << "Building STFI\n");
    BuildMI(MBB, II, DL, TII.get(MI.getOpcode()))
        .addReg(Reg, getKillRegState(MI.getOperand(0).isKill()))
        .addReg(BaseReg, KillState)
        .addImm(Offset)
        .addMemOperand(*MI.memoperands_begin());
    break;
  case ARC::GETFI:
    LLVM_DEBUG(dbgs() << "Building GETFI\n");
    BuildMI(MBB, II, DL,
            TII.get(isUInt<6>(Offset) ? ARC::ADD_rru6 : ARC::ADD_rrlimm))
        .addReg(Reg, RegState::Define)
        .addReg(FrameReg)
        .addImm(Offset);
    break;
  default:
    llvm_unreachable("Unhandled opcode.");
  }

  // Erase old instruction.
  MBB.erase(II);
}

ARCRegisterInfo::ARCRegisterInfo(const ARCSubtarget &ST)
    : ARCGenRegisterInfo(ARC::BLINK), ST(ST) {}

bool ARCRegisterInfo::needsFrameMoves(const MachineFunction &MF) {
  return MF.needsFrameMoves();
}

const MCPhysReg *
ARCRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  // NOTE: deliberately NOT `return CSR_ARC_SaveList;`. CSR_ARC_SaveList
  // (tablegen-generated from CSR_ARC in ARCCallingConv.td) is
  // { R13..R25, GP, FP }. That combined list is correct as the *source* for
  // CSR_ARC_RegMask / getCallPreservedMask() below (a call really does
  // preserve FP and GP per the ABI), but it is the WRONG list to hand to the
  // generic CSI/funclet spill machinery that consumes getCalleeSavedRegs():
  // ARCFrameLowering's determineLastCalleeSave/assignCalleeSavedSpillSlots/
  // spillCalleeSavedRegisters/restoreCalleeSavedRegisters hard-code the
  // invariant that every CalleeSavedInfo entry lies in R13..R25 (the
  // __st_r13_to_rN / __ld_r13_to_rN funclet range) -- see the
  // `assert(Reg.getReg() >= ARC::R13 && Reg.getReg() <= ARC::R25)` in
  // determineLastCalleeSave. FP already has its own dedicated,
  // hasFP(MF)-gated save/restore in ARCFrameLowering::emitPrologue/
  // emitEpilogue via ST_AW_rs9/LD_AB_rs9, entirely independent of CSI; GP has
  // no save/restore code anywhere in this backend. Ordinarily neither FP nor
  // GP is ever "modified" from codegen's point of view (both are Reserved in
  // getReservedRegs(), so the register allocator never assigns them to a
  // vreg), so TargetFrameLowering::determineCalleeSaves() never sets their
  // bit and they never reach CSI -- the FP/GP tail of CSR_ARC_SaveList is
  // normally inert dead weight. But an inline-asm explicit-register operand
  // (`register int x asm("fp"); asm("..." : "=r"(x));`) is lowered to a
  // genuine MachineOperand def of the physical register, which DOES set the
  // "modified" bit for FP/GP and lets them leak into CSI -- tripping the
  // R13..R25 assert. Returning a separate, narrower list here (R13..R25
  // only, matching the funclet range and excluding GP/FP/BLINK -- BLINK is
  // handled entirely outside the CSI mechanism via PUSH_S_BLINK/
  // POP_S_BLINK, gated on MFI.hasCalls(), not on CSR membership) makes it
  // structurally impossible for FP or GP to ever enter CSI, independent of
  // whatever inline asm does to their "modified" bit. This is behavior-
  // neutral for ordinary code: for every function that never explicitly
  // binds "fp"/"gp" as an asm operand, FP/GP were never going to be in CSI
  // either way, so removing them from the *candidate* list changes nothing.
  static const MCPhysReg CSR_ARC_SpillList[] = {
      ARC::R13, ARC::R14, ARC::R15, ARC::R16, ARC::R17, ARC::R18, ARC::R19,
      ARC::R20, ARC::R21, ARC::R22, ARC::R23, ARC::R24, ARC::R25, 0};
  return CSR_ARC_SpillList;
}

BitVector ARCRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());

  Reserved.set(ARC::ILINK);
  Reserved.set(ARC::SP);
  Reserved.set(ARC::GP);
  Reserved.set(ARC::R25);
  Reserved.set(ARC::BLINK);
  Reserved.set(ARC::FP);

  return Reserved;
}

bool ARCRegisterInfo::isInlineAsmReadOnlyReg(const MachineFunction &MF,
                                             MCRegister PhysReg) const {
  // A C/Rust `register T x asm("regname")` local variable bound to one of
  // ARC's hardware-dedicated registers, then used as ANY inline-asm operand
  // (including a plain "r" input -- the explicit-register binding on the
  // *variable* overrides the "r" constraint text, forcing a `{regname}`
  // operand at the LLVM IR level), makes SelectionDAGBuilder materialize a
  // CopyToReg into that literal physical register before the asm executes
  // (see SelectionDAGBuilder::visitInlineAsm's isOutput and isInput
  // C_Register/C_RegisterClass paths, both of which query
  // TargetRegisterInfo::isInlineAsmReadOnlyReg before doing so). Verified
  // empirically (clang -O0, arceb-unknown-elf) that binding "sp", "fp", or
  // "gp" this way emits `ld <garbage>,[frame slot]` followed by
  // `mov %sp,<garbage>` / `mov %fp,<garbage>` / `mov %gp,<garbage>` --
  // i.e. an arbitrary-value write straight into the live hardware register
  // mid-function, BEFORE any use-site logic runs. That is unconditionally
  // unsafe here:
  //  - SP: this is an interrupt-driven target; if an
  //    interrupt fires between the corrupting write and wherever the
  //    epilogue happens to reconstruct SP from FP, the interrupt entry
  //    sequence (which itself pushes context via SP) writes through a bogus
  //    address.
  //  - FP: every frame-relative load/store and the epilogue's
  //    `sub %sp,%fp,StackSize` depend on FP holding the value this
  //    function's own prologue set it to; overwriting it mid-body breaks
  //    every subsequent local/spill access and the stack-pointer restore
  //    on the way out.
  //  - GP: Reserved (see getReservedRegs below) with no generic
  //    save/restore path in this backend at all; nothing here defends
  //    against an arbitrary clobber the way FP's dedicated prologue/epilogue
  //    code at least partially does for FP itself.
  // None of SP/FP/GP have any backend mechanism that tolerates an
  // arbitrary external write appearing mid-function (unlike an ordinary
  // GPR32 member, which is exactly what local register-asm variables are
  // for on this target). Rejecting the write here routes into Clang's
  // existing, already-verified "write to reserved register '<name>'"
  // diagnostic (SelectionDAGBuilder::emitInlineAsmError) -- a clean,
  // compile-time error instead of a silent runtime corruption.
  //
  // BLINK and ILINK are deliberately NOT included here: BLINK in particular
  // is a plausible target for legitimate hand-written return-address /
  // backtrace manipulation in low-level firmware code, which this file's
  // scope has no visibility into (out-of-tree, not part of this LLVM fork).
  // Revisit if that turns out to need the same protection.
  return PhysReg == ARC::SP || PhysReg == ARC::FP || PhysReg == ARC::GP;
}

bool ARCRegisterInfo::requiresRegisterScavenging(
    const MachineFunction &MF) const {
  return true;
}

bool ARCRegisterInfo::useFPForScavengingIndex(const MachineFunction &MF) const {
  return true;
}

bool ARCRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                          int SPAdj, unsigned FIOperandNum,
                                          RegScavenger *RS) const {
  assert(SPAdj == 0 && "Unexpected");
  MachineInstr &MI = *II;
  MachineOperand &FrameOp = MI.getOperand(FIOperandNum);
  int FrameIndex = FrameOp.getIndex();

  MachineFunction &MF = *MI.getParent()->getParent();
  const ARCInstrInfo &TII = *MF.getSubtarget<ARCSubtarget>().getInstrInfo();
  const ARCFrameLowering *TFI = getFrameLowering(MF);
  int Offset = MF.getFrameInfo().getObjectOffset(FrameIndex);
  int ObjSize = MF.getFrameInfo().getObjectSize(FrameIndex);
  int StackSize = MF.getFrameInfo().getStackSize();
  int LocalFrameSize = MF.getFrameInfo().getLocalFrameSize();

  LLVM_DEBUG(dbgs() << "\nFunction         : " << MF.getName() << "\n");
  LLVM_DEBUG(dbgs() << "<--------->\n");
  LLVM_DEBUG(dbgs() << MI << "\n");
  LLVM_DEBUG(dbgs() << "FrameIndex         : " << FrameIndex << "\n");
  LLVM_DEBUG(dbgs() << "ObjSize            : " << ObjSize << "\n");
  LLVM_DEBUG(dbgs() << "FrameOffset        : " << Offset << "\n");
  LLVM_DEBUG(dbgs() << "StackSize          : " << StackSize << "\n");
  LLVM_DEBUG(dbgs() << "LocalFrameSize     : " << LocalFrameSize << "\n");
  (void)LocalFrameSize;

  // Special handling of DBG_VALUE instructions.
  if (MI.isDebugValue()) {
    Register FrameReg = getFrameRegister(MF);
    MI.getOperand(FIOperandNum).ChangeToRegister(FrameReg, false /*isDef*/);
    MI.getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
    return false;
  }

  // fold constant into offset.
  Offset += MI.getOperand(FIOperandNum + 1).getImm();

  // TODO: assert based on the load type:
  // ldb needs no alignment,
  // ldh needs 2 byte alignment
  // ld needs 4 byte alignment
  LLVM_DEBUG(dbgs() << "Offset             : " << Offset << "\n"
                    << "<--------->\n");

  Register Reg = MI.getOperand(0).getReg();
  assert(ARC::GPR32RegClass.contains(Reg) && "Unexpected register operand");

  if (!TFI->hasFP(MF)) {
    Offset = StackSize + Offset;
    if (FrameIndex >= 0)
      assert((Offset >= 0 && Offset < StackSize) && "SP Offset not in bounds.");
  } else {
    if (FrameIndex >= 0) {
      assert((Offset < 0 && -Offset <= StackSize) &&
             "FP Offset not in bounds.");
    }
  }
  replaceFrameIndex(II, TII, Reg, getFrameRegister(MF), Offset, StackSize,
                    ObjSize, RS, SPAdj);
  return true;                  
}

Register ARCRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  const ARCFrameLowering *TFI = getFrameLowering(MF);
  return TFI->hasFP(MF) ? ARC::FP : ARC::SP;
}

const uint32_t *
ARCRegisterInfo::getCallPreservedMask(const MachineFunction &MF,
                                      CallingConv::ID CC) const {
  return CSR_ARC_RegMask;
}
