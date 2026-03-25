//===- ARCDelaySlotFiller.cpp - ARC700 delay slot filler ---------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass fills delay slots for ARCompact (ARC700) branch instructions.
// ARC700 branches (B, BL, J, JL and variants) have a single delay slot
// when the .d suffix is used. This pass attempts to move a useful instruction
// into the delay slot, or inserts a NOP if no safe candidate is found.
//
// This pass only runs for ARCompact subtargets; ARCv2 does not have delay
// slots.
//
//===----------------------------------------------------------------------===//

#include "ARC.h"
#include "ARCSubtarget.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineInstrBundle.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/InitializePasses.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define DEBUG_TYPE "arc-delay-slot-filler"

STATISTIC(FilledSlots, "Number of delay slots filled");
STATISTIC(NopSlots, "Number of delay slots filled with NOPs");

static cl::opt<bool>
    DisableDelaySlotFiller("arc-disable-delay-filler", cl::init(false),
                           cl::desc("Disable ARC delay slot filler."),
                           cl::Hidden);

static cl::opt<bool>
    NopOnlyDelaySlotFiller("arc-nop-delay-filler", cl::init(false),
                           cl::desc("Fill ARC delay slots with NOPs only."),
                           cl::Hidden);

namespace llvm {
void initializeARCDelaySlotFillerPass(PassRegistry &Registry);
} // end namespace llvm

namespace {

class ARCDelaySlotFiller : public MachineFunctionPass {
public:
  static char ID;

  ARCDelaySlotFiller() : MachineFunctionPass(ID) {
    initializeARCDelaySlotFillerPass(*PassRegistry::getPassRegistry());
  }

  StringRef getPassName() const override {
    return "ARC Delay Slot Filler";
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  MachineFunctionProperties getRequiredProperties() const override {
    return MachineFunctionProperties().setNoVRegs();
  }

private:
  const TargetInstrInfo *TII = nullptr;
  const TargetRegisterInfo *TRI = nullptr;
  MachineBasicBlock::instr_iterator LastFiller;

  bool runOnMachineBasicBlock(MachineBasicBlock &MBB);

  bool findDelayInstr(MachineBasicBlock &MBB,
                      MachineBasicBlock::instr_iterator Slot,
                      MachineBasicBlock::instr_iterator &Filler);

  bool delayHasHazard(MachineBasicBlock::instr_iterator MI,
                      bool &SawLoad, bool &SawStore,
                      SmallSet<unsigned, 32> &RegDefs,
                      SmallSet<unsigned, 32> &RegUses);

  void insertDefsUses(MachineBasicBlock::instr_iterator MI,
                      SmallSet<unsigned, 32> &RegDefs,
                      SmallSet<unsigned, 32> &RegUses);

  bool isRegInSet(SmallSet<unsigned, 32> &RegSet, unsigned Reg);
};

char ARCDelaySlotFiller::ID = 0;

} // end anonymous namespace

INITIALIZE_PASS(ARCDelaySlotFiller, "arc-delay-slot-filler",
                "ARC Delay Slot Filler", false, false)

bool ARCDelaySlotFiller::runOnMachineFunction(MachineFunction &MF) {
  const ARCSubtarget &Subtarget = MF.getSubtarget<ARCSubtarget>();

  // Only ARCompact (ARC700) has delay slots.
  if (!Subtarget.isARCompact())
    return false;

  if (DisableDelaySlotFiller)
    return false;

  TII = Subtarget.getInstrInfo();
  TRI = Subtarget.getRegisterInfo();

  LLVM_DEBUG(dbgs() << "Running ARC Delay Slot Filler on " << MF.getName()
                    << "\n");

  bool Changed = false;
  for (MachineBasicBlock &MBB : MF)
    Changed |= runOnMachineBasicBlock(MBB);
  return Changed;
}

bool ARCDelaySlotFiller::runOnMachineBasicBlock(MachineBasicBlock &MBB) {
  bool Changed = false;
  LastFiller = MBB.instr_end();

  for (MachineBasicBlock::instr_iterator I = MBB.instr_begin();
       I != MBB.instr_end(); ++I) {
    if (!I->getDesc().hasDelaySlot())
      continue;

    MachineBasicBlock::instr_iterator InstrWithSlot = I;
    MachineBasicBlock::instr_iterator J = I;

    if (!NopOnlyDelaySlotFiller && findDelayInstr(MBB, I, J)) {
      MBB.splice(std::next(I), &MBB, J);
      ++FilledSlots;
    } else {
      // Insert a NOP into the delay slot.
      // Use the 32-bit NOP (ARC_NOP_0) for ARCompact.
      BuildMI(MBB, std::next(I), DebugLoc(), TII->get(ARC::ARC_NOP_0));
      ++NopSlots;
    }

    Changed = true;
    // Record the filler instruction that filled the delay slot.
    // The instruction after it will be visited in the next iteration.
    LastFiller = ++I;

    // Bundle the delay slot filler with the branch so that the machine
    // verifier does not expect the filler to be a terminator.
    MIBundleBuilder(MBB, InstrWithSlot, std::next(LastFiller));
  }
  return Changed;
}

bool ARCDelaySlotFiller::findDelayInstr(
    MachineBasicBlock &MBB,
    MachineBasicBlock::instr_iterator Slot,
    MachineBasicBlock::instr_iterator &Filler) {
  SmallSet<unsigned, 32> RegDefs;
  SmallSet<unsigned, 32> RegUses;

  insertDefsUses(Slot, RegDefs, RegUses);

  bool SawLoad = false;
  bool SawStore = false;

  for (MachineBasicBlock::reverse_instr_iterator I = ++Slot.getReverse();
       I != MBB.instr_rend(); ++I) {
    // Skip debug instructions.
    if (I->isDebugInstr())
      continue;

    // Convert to forward iterator.
    MachineBasicBlock::instr_iterator FI = I.getReverse();

    // Cannot move past labels, inline asm, instructions with unmodeled
    // side effects, pseudos, or the last filler we placed.
    if (I->hasUnmodeledSideEffects() || I->isInlineAsm() || I->isLabel() ||
        FI == LastFiller || I->isPseudo())
      break;

    // Cannot put branches, calls or returns in the delay slot.
    if (I->isCall() || I->isReturn() || I->isBranch())
      break;

    if (delayHasHazard(FI, SawLoad, SawStore, RegDefs, RegUses)) {
      insertDefsUses(FI, RegDefs, RegUses);
      continue;
    }

    Filler = FI;
    return true;
  }
  return false;
}

bool ARCDelaySlotFiller::delayHasHazard(
    MachineBasicBlock::instr_iterator MI,
    bool &SawLoad, bool &SawStore,
    SmallSet<unsigned, 32> &RegDefs,
    SmallSet<unsigned, 32> &RegUses) {
  if (MI->isImplicitDef() || MI->isKill())
    return true;

  // Loads or stores cannot be moved past a store to the delay slot
  // and stores cannot be moved past a load.
  if (MI->mayLoad()) {
    if (SawStore)
      return true;
    SawLoad = true;
  }

  if (MI->mayStore()) {
    if (SawStore)
      return true;
    SawStore = true;
    if (SawLoad)
      return true;
  }

  for (const MachineOperand &MO : MI->operands()) {
    unsigned Reg;

    if (!MO.isReg() || !(Reg = MO.getReg()))
      continue;

    if (MO.isDef()) {
      // Check whether Reg is defined or used before delay slot.
      if (isRegInSet(RegDefs, Reg) || isRegInSet(RegUses, Reg))
        return true;
    }
    if (MO.isUse()) {
      // Check whether Reg is defined before delay slot.
      if (isRegInSet(RegDefs, Reg))
        return true;
    }
  }
  return false;
}

void ARCDelaySlotFiller::insertDefsUses(
    MachineBasicBlock::instr_iterator MI,
    SmallSet<unsigned, 32> &RegDefs,
    SmallSet<unsigned, 32> &RegUses) {
  const MCInstrDesc &MCID = MI->getDesc();
  unsigned E = MI->isCall() || MI->isReturn() ? MCID.getNumOperands()
                                              : MI->getNumOperands();
  for (unsigned I = 0; I != E; ++I) {
    const MachineOperand &MO = MI->getOperand(I);
    unsigned Reg;

    if (!MO.isReg() || !(Reg = MO.getReg()))
      continue;

    if (MO.isDef())
      RegDefs.insert(Reg);
    else if (MO.isUse())
      RegUses.insert(Reg);
  }

  // Call & return instructions define SP implicitly.
  if (MI->isCall() || MI->isReturn())
    RegDefs.insert(ARC::SP);
}

bool ARCDelaySlotFiller::isRegInSet(SmallSet<unsigned, 32> &RegSet,
                                     unsigned Reg) {
  for (MCRegAliasIterator AI(Reg, TRI, true); AI.isValid(); ++AI)
    if (RegSet.count(*AI))
      return true;
  return false;
}

FunctionPass *llvm::createARCDelaySlotFillerPass() {
  return new ARCDelaySlotFiller();
}
