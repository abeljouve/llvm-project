//===- ARCBranchFinalize.cpp - ARC conditional branches ---------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass takes existing conditional branches and expands them into longer
// range conditional branches. It also fuses a single-bit `and` feeding an
// in-range compare-against-zero branch into a `bbit0`/`bbit1` bit-test branch.
//===----------------------------------------------------------------------===//

#include "ARCInstrInfo.h"
#include "ARCTargetMachine.h"
#include "MCTargetDesc/ARCInfo.h"
#include "llvm/CodeGen/LivePhysRegs.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/InitializePasses.h"
#include "llvm/Support/Debug.h"
#include <vector>

#define DEBUG_TYPE "arc-branch-finalize"

using namespace llvm;

namespace llvm {

void initializeARCBranchFinalizePass(PassRegistry &Registry);
FunctionPass *createARCBranchFinalizePass();

} // end namespace llvm

namespace {

class ARCBranchFinalize : public MachineFunctionPass {
public:
  static char ID;

  ARCBranchFinalize() : MachineFunctionPass(ID) {
    initializeARCBranchFinalizePass(*PassRegistry::getPassRegistry());
  }

  StringRef getPassName() const override {
    return "ARC Branch Finalization Pass";
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
  void replaceWithBRcc(MachineInstr *MI) const;
  void replaceWithCmpBcc(MachineInstr *MI) const;
  bool tryFuseBBIT(MachineInstr *MI) const;

private:
  const ARCInstrInfo *TII{nullptr};
  const TargetRegisterInfo *TRI{nullptr};
  const ARCSubtarget *ST{nullptr};
};

char ARCBranchFinalize::ID = 0;

} // end anonymous namespace

INITIALIZE_PASS_BEGIN(ARCBranchFinalize, "arc-branch-finalize",
                      "ARC finalize branches", false, false)
INITIALIZE_PASS_DEPENDENCY(MachineDominatorTreeWrapperPass)
INITIALIZE_PASS_END(ARCBranchFinalize, "arc-branch-finalize",
                    "ARC finalize branches", false, false)

// BRcc has 6 supported condition codes, which differ from the 16
// condition codes supported in the predicated instructions:
// EQ -- 000
// NE -- 001
// LT -- 010
// GE -- 011
// LO -- 100
// HS -- 101
static unsigned getCCForBRcc(unsigned CC) {
  switch (CC) {
  case ARCCC::EQ:
    return 0;
  case ARCCC::NE:
    return 1;
  case ARCCC::LT:
    return 2;
  case ARCCC::GE:
    return 3;
  case ARCCC::LO:
    return 4;
  case ARCCC::HS:
    return 5;
  default:
    return -1U;
  }
}

static bool isBRccPseudo(MachineInstr *MI) {
  return !(MI->getOpcode() != ARC::BRcc_rr_p &&
           MI->getOpcode() != ARC::BRcc_ru6_p);
}

static unsigned getBRccForPseudo(MachineInstr *MI) {
  assert(isBRccPseudo(MI) && "Can't get BRcc for wrong instruction.");
  if (MI->getOpcode() == ARC::BRcc_rr_p)
    return ARC::BRcc_rr;
  return ARC::BRcc_ru6;
}

static unsigned getCmpForPseudo(MachineInstr *MI) {
  assert(isBRccPseudo(MI) && "Can't get BRcc for wrong instruction.");
  if (MI->getOpcode() == ARC::BRcc_rr_p)
    return ARC::CMP_rr;
  return ARC::CMP_ru6;
}

// If MI is `and Dst, Src, <power-of-2 immediate>` (any of the immediate ALU
// forms), report Src and the tested bit position. All three immediate AND
// forms share the operand layout (0 = dest, 1 = source reg, 2 = immediate).
static bool matchSingleBitAnd(const MachineInstr &MI, Register &Dst,
                              Register &Src, unsigned &Bit) {
  unsigned Op = MI.getOpcode();
  if (Op != ARC::AND_rru6 && Op != ARC::AND_rrs12 && Op != ARC::AND_rrlimm)
    return false;
  const MachineOperand &Imm = MI.getOperand(2);
  if (!Imm.isImm())
    return false;
  uint32_t Mask = static_cast<uint32_t>(Imm.getImm());
  if (!isPowerOf2_32(Mask))
    return false;
  Dst = MI.getOperand(0).getReg();
  Src = MI.getOperand(1).getReg();
  Bit = Log2_32(Mask);
  return true;
}

// Try to fuse an immediately-preceding single-bit `and` feeding this
// compare-against-zero branch into a `bbit0`/`bbit1`. Called only for a branch
// already selected as the in-range BRcc form, so the s9 `bbit` (same range) is
// guaranteed reachable -- no out-of-range fallback is needed. Returns true and
// rewrites the branch (erasing MI and the `and`) on success.
bool ARCBranchFinalize::tryFuseBBIT(MachineInstr *MI) const {
  // The ARC_BBIT0/ARC_BBIT1 opcodes are ARCompact-only encodings (tablegen
  // records them with a required-feature-bits set of just IsARCompact -- see
  // the CEFBS_IsARCompact entries in the generated ARCGenInstrInfo.inc). On a
  // subtarget that doesn't enable FeatureARCompact (e.g. the default
  // "generic" CPU, which has no Proc-level ARCompact/NORM features), building
  // one of these MachineInstrs directly via BuildMI still assembles fine at
  // the MI level, but the generic scheduling-class-resolution machinery
  // treats the opcode's SchedClass as unresolved off that subtarget and
  // falls into ARCGenSubtargetInfo::resolveSchedClass, which is an
  // unconditional `report_fatal_error("Expected a variant SchedClass")` stub
  // under our NoItineraries model -- crashing ARCAsmPrinter::emitInstruction.
  // Confirmed empirically: `-target arceb-unknown-elf -O2` with no CPU/
  // features crashes; adding only `+arcompact` (not `+norm`) fixes it.
  // Restrict the fusion to ARCompact subtargets so it only ever produces
  // bbit0/bbit1 where they're guaranteed to print/encode safely. Any
  // `+arcompact` target still gets the optimization; only feature-less
  // subtargets (e.g. the default "generic" CPU) skip it, so this is
  // strictly additive and changes no existing ARCompact codegen output.
  if (!ST || !ST->isARCompact())
    return false;
  // Only the immediate compare-and-branch, comparing against 0 with EQ / NE.
  if (MI->getOpcode() != ARC::BRcc_ru6_p)
    return false;
  if (!MI->getOperand(2).isImm() || MI->getOperand(2).getImm() != 0)
    return false;
  int64_t CC = MI->getOperand(3).getImm();
  if (CC != ARCCC::EQ && CC != ARCCC::NE)
    return false;
  Register B = MI->getOperand(1).getReg();

  MachineBasicBlock *MBB = MI->getParent();
  MachineInstr *Prev = MI->getPrevNode();
  while (Prev && Prev->isDebugInstr())
    Prev = Prev->getPrevNode();
  if (!Prev)
    return false;

  Register AndDst, Src;
  unsigned Bit;
  if (!matchSingleBitAnd(*Prev, AndDst, Src, Bit) || AndDst != B)
    return false;

  // B must not be needed after the branch: its only use is this compare, so
  // removing the `and` (its sole def) and the branch is safe iff B is dead on
  // every out-edge. LivePhysRegs is conservative -- if liveness is unknown it
  // keeps B live and we simply do not fuse.
  const MachineRegisterInfo &MRI = MBB->getParent()->getRegInfo();
  LivePhysRegs LiveOut(*TRI);
  LiveOut.addLiveOuts(*MBB);
  if (!LiveOut.available(MRI, B))
    return false;
  // Src is read by the `and` immediately before MI (nothing in between), so it
  // is live at the branch and remains correct for the bbit that replaces it.
  // (When the `and` is in place -- Src == B -- removing it leaves B holding its
  // incoming value, which is exactly what the bit test needs.)

  unsigned Opc = (CC == ARCCC::NE) ? ARC::ARC_BBIT1_b_u6_s9_d
                                   : ARC::ARC_BBIT0_b_u6_s9_d;
  BuildMI(*MBB, MI, MI->getDebugLoc(), TII->get(Opc))
      .addReg(Src)
      .addImm(Bit)
      .addMBB(MI->getOperand(0).getMBB());
  Prev->eraseFromParent();
  MI->eraseFromParent();
  return true;
}

void ARCBranchFinalize::replaceWithBRcc(MachineInstr *MI) const {
  // The target is within s9 range, so a bit-test-and-branch (also s9) is
  // guaranteed reachable: prefer it when the compare is a single-bit test.
  if (tryFuseBBIT(MI))
    return;
  LLVM_DEBUG(dbgs() << "Replacing pseudo branch with BRcc\n");
  unsigned CC = getCCForBRcc(MI->getOperand(3).getImm());
  if (CC != -1U) {
    BuildMI(*MI->getParent(), MI, MI->getDebugLoc(),
            TII->get(getBRccForPseudo(MI)))
        .addMBB(MI->getOperand(0).getMBB())
        .addReg(MI->getOperand(1).getReg())
        .add(MI->getOperand(2))
        .addImm(getCCForBRcc(MI->getOperand(3).getImm()));
    MI->eraseFromParent();
  } else {
    replaceWithCmpBcc(MI);
  }
}

void ARCBranchFinalize::replaceWithCmpBcc(MachineInstr *MI) const {
  LLVM_DEBUG(dbgs() << "Branch: " << *MI << "\n");
  LLVM_DEBUG(dbgs() << "Replacing pseudo branch with Cmp + Bcc\n");
  BuildMI(*MI->getParent(), MI, MI->getDebugLoc(),
          TII->get(getCmpForPseudo(MI)))
      .addReg(MI->getOperand(1).getReg())
      .add(MI->getOperand(2));
  BuildMI(*MI->getParent(), MI, MI->getDebugLoc(), TII->get(ARC::Bcc))
      .addMBB(MI->getOperand(0).getMBB())
      .addImm(MI->getOperand(3).getImm());
  MI->eraseFromParent();
}

bool ARCBranchFinalize::runOnMachineFunction(MachineFunction &MF) {
  LLVM_DEBUG(dbgs() << "Running ARC Branch Finalize on " << MF.getName()
                    << "\n");
  std::vector<MachineInstr *> Branches;
  bool Changed = false;
  unsigned MaxSize = 0;
  ST = &MF.getSubtarget<ARCSubtarget>();
  TII = ST->getInstrInfo();
  TRI = ST->getRegisterInfo();
  std::map<MachineBasicBlock *, unsigned> BlockToPCMap;
  std::vector<std::pair<MachineInstr *, unsigned>> BranchToPCList;
  unsigned PC = 0;

  for (auto &MBB : MF) {
    BlockToPCMap.insert(std::make_pair(&MBB, PC));
    for (auto &MI : MBB) {
      unsigned Size = TII->getInstSizeInBytes(MI);
      if (Size > 8 || Size == 0) {
        LLVM_DEBUG(dbgs() << "Unknown (or size 0) size for: " << MI << "\n");
      } else {
        MaxSize += Size;
      }
      // The delay-slot filler runs AFTER this pass and inserts a 4-byte NOP
      // into every unfilled delay slot, growing the code past this estimate.
      // Count that worst case so the per-branch range check below never
      // underestimates the real displacement -- an out-of-range compact
      // compare-and-branch (BRcc) or bit-test-and-branch (bbit) is a hard
      // relocation error, not a silent miscompile, so the estimate must be a
      // conservative upper bound on the final layout.
      unsigned PCSize = Size;
      if (MI.getDesc().hasDelaySlot())
        PCSize += 4;
      if (MI.isBranch()) {
        Branches.push_back(&MI);
        BranchToPCList.emplace_back(&MI, PC);
      }
      PC += PCSize;
    }
  }
  for (auto P : BranchToPCList) {
    MachineInstr *MI = P.first;
    if (!isBRccPseudo(MI))
      continue;
    // Decide per branch, not on the whole-function size: the compact
    // compare-and-branch (BRcc) encodes a signed 9-bit half-word displacement.
    // The old code used MaxSize (the entire function), so any function larger
    // than the s9 range degraded *every* BRcc into CMP + Bcc -- even a tight
    // in-range loop a handful of bytes away. That turned a 1-instruction
    // `brlt r,0,loop` into a 2-instruction `cmp r,0 / blt loop` sequence.
    //
    // PCs here estimate the final layout (delay-slot NOPs already counted,
    // above; the BRcc pseudo shrinks from 8 to 4 bytes so intervening pseudos
    // only make the real displacement smaller). We bound the estimate to a
    // signed 9-bit *byte* range (~+/-256), which stays safely inside the s9
    // half-word hardware range (~+/-512), so the fixup can never overflow at
    // assembly time. Out-of-range branches fall back to CMP + Bcc (Bcc has
    // s21 range, always reachable).
    unsigned BranchPC = P.second;
    MachineBasicBlock *TargetMBB = MI->getOperand(0).getMBB();
    auto It = BlockToPCMap.find(TargetMBB);
    bool InRange = It != BlockToPCMap.end() &&
                   isInt<9>((int64_t)It->second - (int64_t)BranchPC);
    InRange ? replaceWithBRcc(MI) : replaceWithCmpBcc(MI);
  }

  LLVM_DEBUG(dbgs() << "Estimated function size for " << MF.getName() << ": "
                    << MaxSize << "\n");
  (void)MaxSize; // only read under LLVM_DEBUG (compiled out in release)

  return Changed;
}

FunctionPass *llvm::createARCBranchFinalizePass() {
  return new ARCBranchFinalize();
}
