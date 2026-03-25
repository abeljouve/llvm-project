//===- ARCExpandHWLoops.cpp - Expand hardware loop pseudos ------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass expands HWLOOP_SETUP and HWLOOP_SETUP_IMM pseudo-instructions
// into the real ARC700 instruction sequence:
//
//   mov   LP_COUNT, <count>     ; LP_COUNT is r60
//   nop                         ; hazard: 1 cycle between LP_COUNT write and LP
//   lp    <loop_end_label>      ; set up zero-overhead loop
//
// HWLOOP_END markers emit no code (size 0); they only provide the label
// that LP targets.
//
// This pass runs in the pre-emit phase (after register allocation).
//
//===----------------------------------------------------------------------===//

#include "ARC.h"
#include "ARCInstrInfo.h"
#include "ARCSubtarget.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

using namespace llvm;

#define DEBUG_TYPE "arc-expand-hwloops"

STATISTIC(NumExpanded, "Number of hardware loop pseudos expanded");

namespace {

class ARCExpandHWLoops : public MachineFunctionPass {
public:
  static char ID;
  ARCExpandHWLoops() : MachineFunctionPass(ID) {
    initializeARCExpandHWLoopsPass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override {
    return "ARC Expand Hardware Loop Pseudos";
  }

private:
  const ARCInstrInfo *TII = nullptr;

  bool expandHWLoopSetup(MachineBasicBlock::iterator MI);
  bool expandHWLoopSetupImm(MachineBasicBlock::iterator MI);
};

char ARCExpandHWLoops::ID = 0;

} // end anonymous namespace

INITIALIZE_PASS(ARCExpandHWLoops, "arc-expand-hwloops",
                "ARC Expand Hardware Loop Pseudos", false, false)

bool ARCExpandHWLoops::expandHWLoopSetup(MachineBasicBlock::iterator MI) {
  // HWLOOP_SETUP $count(reg), $loopend(MBB)
  //   -> mov R60, $count
  //      nop
  //      lp  $loopend
  MachineBasicBlock &MBB = *MI->getParent();
  DebugLoc DL = MI->getDebugLoc();

  Register CountReg = MI->getOperand(0).getReg();
  MachineBasicBlock *LoopEnd = MI->getOperand(1).getMBB();

  // mov LP_COUNT, $count
  BuildMI(MBB, MI, DL, TII->get(ARC::MOV_rr), ARC::R60)
      .addReg(CountReg);

  // nop (hazard: must have 1 instruction between LP_COUNT write and LP)
  BuildMI(MBB, MI, DL, TII->get(ARC::ARC_NOP_0));

  // lp $loopend
  BuildMI(MBB, MI, DL, TII->get(ARC::ARC_LP_s13))
      .addMBB(LoopEnd);

  MI->eraseFromParent();
  ++NumExpanded;
  return true;
}

bool ARCExpandHWLoops::expandHWLoopSetupImm(MachineBasicBlock::iterator MI) {
  // HWLOOP_SETUP_IMM $count(imm), $loopend(MBB)
  //   -> mov R60, $count
  //      nop
  //      lp  $loopend
  MachineBasicBlock &MBB = *MI->getParent();
  DebugLoc DL = MI->getDebugLoc();

  int64_t CountImm = MI->getOperand(0).getImm();
  MachineBasicBlock *LoopEnd = MI->getOperand(1).getMBB();

  // Choose the appropriate MOV variant based on immediate size.
  if (isInt<12>(CountImm)) {
    // mov LP_COUNT, $count  (signed 12-bit immediate)
    BuildMI(MBB, MI, DL, TII->get(ARC::MOV_rs12), ARC::R60)
        .addImm(CountImm);
  } else {
    // mov LP_COUNT, $count  (long immediate / 32-bit)
    BuildMI(MBB, MI, DL, TII->get(ARC::MOV_rlimm), ARC::R60)
        .addImm(CountImm);
  }

  // nop (hazard: must have 1 instruction between LP_COUNT write and LP)
  BuildMI(MBB, MI, DL, TII->get(ARC::ARC_NOP_0));

  // lp $loopend
  BuildMI(MBB, MI, DL, TII->get(ARC::ARC_LP_s13))
      .addMBB(LoopEnd);

  MI->eraseFromParent();
  ++NumExpanded;
  return true;
}

bool ARCExpandHWLoops::runOnMachineFunction(MachineFunction &MF) {
  const ARCSubtarget &STI = MF.getSubtarget<ARCSubtarget>();
  if (!STI.isARCompact())
    return false;

  TII = STI.getInstrInfo();
  bool Changed = false;

  for (auto &MBB : MF) {
    MachineBasicBlock::iterator MBBI = MBB.begin(), E = MBB.end();
    while (MBBI != E) {
      MachineBasicBlock::iterator Next = std::next(MBBI);
      switch (MBBI->getOpcode()) {
      case ARC::HWLOOP_SETUP:
        Changed |= expandHWLoopSetup(MBBI);
        break;
      case ARC::HWLOOP_SETUP_IMM:
        Changed |= expandHWLoopSetupImm(MBBI);
        break;
      default:
        break;
      }
      MBBI = Next;
    }
  }

  return Changed;
}

FunctionPass *llvm::createARCExpandHWLoopsPass() {
  return new ARCExpandHWLoops();
}
