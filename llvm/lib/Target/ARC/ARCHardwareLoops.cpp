//===- ARCHardwareLoops.cpp - ARC Zero-Overhead Loop Pass -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass identifies counted loops that can be converted to use the ARC700
// zero-overhead loop mechanism (LP instruction + LP_COUNT register).
//
// The LP instruction sets up LP_START and LP_END auxiliary registers. The
// hardware automatically decrements LP_COUNT and branches back to LP_START
// when the end of the loop body is reached, with zero branch overhead.
//
// This pass runs after register allocation and before the pre-emit passes.
// It operates at the MachineInstr level and only activates for the ARCompact
// subtarget.
//
// Constraints:
//  - Only innermost loops (no nesting of hardware loops on ARC700)
//  - Loop must have a single exit
//  - No function calls inside the loop body
//  - No nested hardware loops
//  - LP_COUNT (r60) must not be written by LD/POP/EX/MPY inside the loop
//  - At least 4 instruction words between LP_COUNT write and loop end
//
//===----------------------------------------------------------------------===//

#include "ARC.h"
#include "ARCInstrInfo.h"
#include "ARCSubtarget.h"
#include "MCTargetDesc/ARCInfo.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineLoopInfo.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetRegisterInfo.h"
#include "llvm/IR/DebugLoc.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "arc-hwloops"

static cl::opt<bool>
    DisableHWLoops("disable-arc-hwloops", cl::Hidden, cl::init(false),
                   cl::desc("Disable ARC zero-overhead loop generation"));

static cl::opt<unsigned>
    MinLoopBodySize("arc-hwloop-min-size", cl::Hidden, cl::init(2),
                    cl::desc("Minimum loop body size (instructions) for "
                             "hardware loop conversion"));

STATISTIC(NumHWLoops, "Number of loops converted to hardware loops");

namespace {

class ARCHardwareLoops : public MachineFunctionPass {
  const ARCInstrInfo *TII;
  const ARCSubtarget *STI;
  MachineLoopInfo *MLI;
  MachineRegisterInfo *MRI;

public:
  static char ID;

  ARCHardwareLoops() : MachineFunctionPass(ID) {
    initializeARCHardwareLoopsPass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override {
    return "ARC Zero-Overhead Loops";
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<MachineLoopInfoWrapperPass>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }

private:
  /// Attempt to convert a machine loop to a hardware loop.
  /// Returns true if the conversion was successful.
  bool convertToHardwareLoop(MachineLoop *L);

  /// Check if the loop body contains instructions that prevent
  /// hardware loop conversion (calls, nested HW loops, etc.).
  bool containsInvalidInstruction(MachineLoop *L) const;

  /// Try to find the induction variable pattern in the loop latch.
  /// Looks for: phi -> add/sub -> cmp -> brcc patterns.
  /// Returns true if found, sets TripCount info.
  bool findTripCount(MachineLoop *L, MachineBasicBlock *Latch,
                     Register &CountReg, int64_t &CountImm,
                     bool &IsImm, SmallVectorImpl<MachineInstr *> &ToRemove);

  /// Get the loop body size in instruction words (for minimum size check
  /// and LP_COUNT write hazard).
  unsigned getLoopBodySize(MachineLoop *L) const;
};

char ARCHardwareLoops::ID = 0;

} // end anonymous namespace

INITIALIZE_PASS_BEGIN(ARCHardwareLoops, "arc-hwloops",
                      "ARC Zero-Overhead Loops", false, false)
INITIALIZE_PASS_DEPENDENCY(MachineLoopInfoWrapperPass)
INITIALIZE_PASS_END(ARCHardwareLoops, "arc-hwloops",
                    "ARC Zero-Overhead Loops", false, false)

bool ARCHardwareLoops::runOnMachineFunction(MachineFunction &MF) {
  if (DisableHWLoops)
    return false;

  STI = &MF.getSubtarget<ARCSubtarget>();

  // Only enable for ARCompact targets (ARC700).
  if (!STI->isARCompact()) {
    LLVM_DEBUG(dbgs() << "HWLoop: not ARCompact, skipping\n");
    return false;
  }

  LLVM_DEBUG(dbgs() << "********* ARC Zero-Overhead Loops *********\n");

  TII = STI->getInstrInfo();
  MRI = &MF.getRegInfo();
  MLI = &getAnalysis<MachineLoopInfoWrapperPass>().getLI();

  bool Changed = false;
  for (MachineLoop *L : *MLI) {
    if (!L->isOutermost())
      continue;
    // Process innermost loops. Walk down to find them.
    SmallVector<MachineLoop *, 4> Worklist;
    Worklist.push_back(L);
    while (!Worklist.empty()) {
      MachineLoop *CurL = Worklist.pop_back_val();
      if (CurL->isInnermost()) {
        Changed |= convertToHardwareLoop(CurL);
      } else {
        for (MachineLoop *Sub : *CurL)
          Worklist.push_back(Sub);
      }
    }
  }
  return Changed;
}

bool ARCHardwareLoops::containsInvalidInstruction(MachineLoop *L) const {
  for (MachineBasicBlock *MBB : L->blocks()) {
    for (MachineInstr &MI : *MBB) {
      // No function calls allowed.
      if (MI.isCall()) {
        LLVM_DEBUG(dbgs() << "HWLoop: call found, rejecting\n");
        return true;
      }
      // No inline asm (conservative).
      if (MI.isInlineAsm()) {
        LLVM_DEBUG(dbgs() << "HWLoop: inline asm found, rejecting\n");
        return true;
      }
      // If there is already a hardware loop setup, reject (no nesting).
      unsigned Opc = MI.getOpcode();
      if (Opc == ARC::HWLOOP_SETUP || Opc == ARC::HWLOOP_SETUP_IMM ||
          Opc == ARC::HWLOOP_END || Opc == ARC::ARC_LP_s13) {
        LLVM_DEBUG(dbgs() << "HWLoop: nested HW loop found, rejecting\n");
        return true;
      }
    }
  }
  return false;
}

unsigned ARCHardwareLoops::getLoopBodySize(MachineLoop *L) const {
  unsigned Size = 0;
  for (MachineBasicBlock *MBB : L->blocks()) {
    for (MachineInstr &MI : *MBB) {
      if (MI.isPseudo() || MI.isDebugInstr())
        continue;
      // Approximate: each real instruction is at least 1 word.
      // 16-bit instructions are 1 half-word but we count conservatively.
      Size++;
    }
  }
  return Size;
}

bool ARCHardwareLoops::findTripCount(
    MachineLoop *L, MachineBasicBlock *Latch, Register &CountReg,
    int64_t &CountImm, bool &IsImm,
    SmallVectorImpl<MachineInstr *> &ToRemove) {

  // Analyze the branch at the end of the latch block.
  MachineBasicBlock *TBB = nullptr, *FBB = nullptr;
  SmallVector<MachineOperand, 4> Cond;
  if (TII->analyzeBranch(*Latch, TBB, FBB, Cond, false))
    return false;

  // We need a conditional branch that loops back to the header.
  if (Cond.empty())
    return false;

  MachineBasicBlock *Header = L->getHeader();

  // Determine which target is the loop-back edge.
  bool LoopsOnTrue = (TBB == Header);
  if (!LoopsOnTrue && FBB != Header)
    return false;

  // Cond format for ARC BRcc: [src1, src2, cc]
  //   analyzeBranch pushes operands 1,2,3 from BRcc_rr_p/BRcc_ru6_p:
  //     BRcc_rr_p:  (ins btarget:$T, GPR32:$B, GPR32:$C, ccond:$cc)
  //     BRcc_ru6_p: (ins btarget:$T, GPR32:$B, i32imm:$C, ccond:$cc)
  //   So Cond[0] = B (reg), Cond[1] = C (reg or imm), Cond[2] = cc (imm)
  if (Cond.size() != 3)
    return false;

  if (!Cond[2].isImm())
    return false;
  unsigned CC = Cond[2].getImm();

  MachineOperand &Src1 = Cond[0];
  MachineOperand &Src2 = Cond[1];

  // We need the comparison to be against an immediate 0 (for simple
  // decrement-to-zero), and the condition to be NE (loop while not zero).
  // When the branch loops back on true:
  //   BRcc NE, %iv.next, 0 -> header (loop while iv.next != 0)
  // When the branch loops back on false (falls through to header):
  //   BRcc EQ, %iv.next, 0 -> exit
  // For now, only handle NE+0 pattern (decrement to zero).
  // BRcc_rr_p/BRcc_ru6_p use the main ARCCC::CondCode values, not BRCondCode.
  if (LoopsOnTrue && CC != ARCCC::NE)
    return false;
  if (!LoopsOnTrue && CC != ARCCC::EQ)
    return false;

  // Check that one operand is immediate 0.
  bool Src2IsZero = Src2.isImm() && Src2.getImm() == 0;
  if (!Src2IsZero)
    return false;

  // Src1 must be a register (the induction variable after decrement).
  if (!Src1.isReg())
    return false;

  Register IVNext = Src1.getReg();

  // Find the instruction that defines IVNext -- should be an ADD/SUB by -1/+1.
  if (!IVNext.isVirtual())
    return false;

  MachineInstr *IVDef = MRI->getVRegDef(IVNext);
  if (!IVDef)
    return false;

  // Check for SUB_rru6 %iv, 1 or ADD_rrs12 %iv, -1
  int64_t Bump = 0;
  Register IVReg;
  unsigned DefOpc = IVDef->getOpcode();

  auto getImmValue = [this](Register Reg, int64_t &Val) -> bool {
    if (!Reg.isVirtual())
      return false;
    MachineInstr *Def = MRI->getVRegDef(Reg);
    if (!Def)
      return false;
    if ((Def->getOpcode() == ARC::MOV_rs12 ||
         Def->getOpcode() == ARC::MOV_rlimm) &&
        Def->getOperand(1).isImm()) {
      Val = Def->getOperand(1).getImm();
      return true;
    }
    return false;
  };

  if (DefOpc == ARC::SUB_rru6 || DefOpc == ARC::SUB_rrlimm) {
    // SUB dst, src, imm  =>  dst = src - imm
    IVReg = IVDef->getOperand(1).getReg();
    if (IVDef->getOperand(2).isImm()) {
      Bump = -IVDef->getOperand(2).getImm();
    } else {
      return false;
    }
  } else if (DefOpc == ARC::ADD_rru6 || DefOpc == ARC::ADD_rrlimm ||
             DefOpc == ARC::ADD_rrs12) {
    IVReg = IVDef->getOperand(1).getReg();
    if (IVDef->getOperand(2).isImm()) {
      Bump = IVDef->getOperand(2).getImm();
    } else {
      return false;
    }
  } else if (DefOpc == ARC::ADD_rrr) {
    // ADD_rrr dst, src1, src2 -- check if src2 is a known immediate -1.
    IVReg = IVDef->getOperand(1).getReg();
    Register Src2Reg = IVDef->getOperand(2).getReg();
    int64_t ImmVal;
    if (getImmValue(Src2Reg, ImmVal)) {
      Bump = ImmVal;
    } else if (getImmValue(IVReg, ImmVal)) {
      // Maybe src1 is the constant and src2 is the IV.
      IVReg = Src2Reg;
      Bump = ImmVal;
    } else {
      return false;
    }
  } else {
    return false;
  }

  // We need a decrement by 1 (bump == -1).
  if (Bump != -1)
    return false;

  // IVReg should be a PHI in the header that feeds back IVNext.
  if (!IVReg.isVirtual())
    return false;

  MachineInstr *Phi = MRI->getVRegDef(IVReg);
  if (!Phi || !Phi->isPHI())
    return false;

  if (Phi->getParent() != Header)
    return false;

  // Find the initial value from the preheader.
  MachineBasicBlock *Preheader = nullptr;
  Register InitReg;
  bool InitIsImm = false;
  int64_t InitImm = 0;

  for (unsigned i = 1, e = Phi->getNumOperands(); i < e; i += 2) {
    MachineBasicBlock *PredMBB = Phi->getOperand(i + 1).getMBB();
    if (L->contains(PredMBB))
      continue;
    // This is the preheader/entry edge.
    Preheader = PredMBB;
    MachineOperand &InitOp = Phi->getOperand(i);
    if (InitOp.isReg()) {
      InitReg = InitOp.getReg();
      // Check if the init register is a known immediate.
      if (InitReg.isVirtual()) {
        MachineInstr *InitDef = MRI->getVRegDef(InitReg);
        if (InitDef &&
            (InitDef->getOpcode() == ARC::MOV_rs12 ||
             InitDef->getOpcode() == ARC::MOV_rlimm)) {
          if (InitDef->getOperand(1).isImm()) {
            InitIsImm = true;
            InitImm = InitDef->getOperand(1).getImm();
          }
        }
      }
    }
    break;
  }

  if (!Preheader)
    return false;

  // The trip count equals the initial value of the IV (for count-down-to-zero).
  if (InitIsImm) {
    if (InitImm <= 0)
      return false; // Zero or negative trip count.
    IsImm = true;
    CountImm = InitImm;
  } else {
    if (!InitReg.isValid())
      return false;
    IsImm = false;
    CountReg = InitReg;
  }

  // Mark instructions for removal: the PHI, the decrement, and the branch.
  // The branch is removed by removeBranch; the others we collect.
  // Note: we don't remove the PHI and decrement yet because other uses
  // might exist. We will let DCE handle them. If the IV is used only for
  // the loop control, it will be dead.
  // However, we do need to remove the branch.

  // Find the branch instruction(s) in the latch to remove.
  MachineBasicBlock::iterator LatchEnd = Latch->end();
  for (auto I = Latch->getFirstTerminator(); I != LatchEnd; ) {
    MachineInstr &Term = *I++;
    ToRemove.push_back(&Term);
  }

  LLVM_DEBUG({
    dbgs() << "HWLoop: found trip count pattern, ";
    if (IsImm)
      dbgs() << "imm=" << CountImm;
    else
      dbgs() << "reg=" << printReg(CountReg);
    dbgs() << "\n";
  });
  return true;
}

bool ARCHardwareLoops::convertToHardwareLoop(MachineLoop *L) {
  assert(L->isInnermost() && "Should only process innermost loops");

  MachineBasicBlock *Header = L->getHeader();
  if (!Header)
    return false;

  // Need a single latch block.
  MachineBasicBlock *Latch = L->getLoopLatch();
  if (!Latch)
    return false;

  // Need a single exit block.
  MachineBasicBlock *ExitBlock = L->getExitBlock();
  if (!ExitBlock)
    return false;

  // Check for invalid instructions.
  if (containsInvalidInstruction(L))
    return false;

  // Check minimum loop body size (need at least a few instructions for
  // the LP_COUNT write hazard: 4 instruction words between write and end).
  unsigned BodySize = getLoopBodySize(L);
  if (BodySize < MinLoopBodySize)
    return false;

  // Find the trip count pattern.
  Register CountReg;
  int64_t CountImm = 0;
  bool IsImm = false;
  SmallVector<MachineInstr *, 4> ToRemove;

  if (!findTripCount(L, Latch, CountReg, CountImm, IsImm, ToRemove))
    return false;

  // Find or create a preheader.
  MachineBasicBlock *Preheader = MLI->findLoopPreheader(L);
  if (!Preheader) {
    LLVM_DEBUG(dbgs() << "HWLoop: no preheader, skipping\n");
    return false;
  }

  LLVM_DEBUG(dbgs() << "HWLoop: converting loop in "
             << Header->getParent()->getName() << "\n");

  // Determine the loop end label target.
  // LP_END should point to the first instruction after the loop body.
  // That is the exit block.
  MachineBasicBlock *LoopEnd = ExitBlock;

  // Insert the HWLOOP_SETUP pseudo in the preheader, before the terminator.
  MachineBasicBlock::iterator InsertPos = Preheader->getFirstTerminator();
  DebugLoc DL;
  if (InsertPos != Preheader->end())
    DL = InsertPos->getDebugLoc();

  if (IsImm) {
    BuildMI(*Preheader, InsertPos, DL, TII->get(ARC::HWLOOP_SETUP_IMM))
        .addImm(CountImm)
        .addMBB(LoopEnd);
  } else {
    BuildMI(*Preheader, InsertPos, DL, TII->get(ARC::HWLOOP_SETUP))
        .addReg(CountReg)
        .addMBB(LoopEnd);
  }

  // Insert HWLOOP_END marker at the beginning of the exit block.
  BuildMI(*LoopEnd, LoopEnd->begin(), DL, TII->get(ARC::HWLOOP_END));

  // Remove the old branch instructions from the latch.
  for (MachineInstr *MI : ToRemove)
    MI->eraseFromParent();

  // The hardware loop mechanism handles the back-edge: at LP_END, if
  // LP_COUNT > 0, the hardware jumps to LP_START. The latch block now
  // falls through to the exit block (LP_END address).
  //
  // Update the CFG: remove the loop-back edge from latch to header.
  // The hardware provides this edge implicitly.
  Latch->removeSuccessor(Header);

  // If the latch does not fall through to the exit block, add an
  // explicit unconditional branch to maintain valid CFG.
  if (!Latch->isLayoutSuccessor(LoopEnd)) {
    BuildMI(*Latch, Latch->end(), DL, TII->get(ARC::BR)).addMBB(LoopEnd);
  }

  ++NumHWLoops;
  return true;
}

FunctionPass *llvm::createARCHardwareLoopsPass() {
  return new ARCHardwareLoops();
}
