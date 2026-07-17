//===- ARCLowOverheadLoops.cpp - ARC zero-overhead loop finalize ----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// The commit-or-fall-back half of ARC zero-overhead (LP) loop formation.
//
// The generic HardwareLoops IR pass (enabled by ARCTTIImpl::
// isHardwareLoopProfitable behind -arc-hardware-loops) has already proven the
// loop counted with SCEV and lowered it to an ordinary countdown loop marked
// with two pseudos:
//
//   preheader P:  CReg = HWLOOP_START CountReg          ; start.loop.iterations
//   body     BB:  ... ; CReg = HWLOOP_DEC CReg, 1       ; loop.decrement.reg
//                 brne CReg, 0, BB                       ; ordinary back-branch
//   exit     E:   ...
//
// This pass runs LAST in addPreEmitPass -- after ARCBranchFinalize,
// ARCSizeReduction and ARCDelaySlotFiller -- because that is the only point at
// which instruction sizes (and therefore the >=4-fetch-word LP_COUNT setup
// window) are final. For a loop it can fully verify, it commits to `lp`:
//
//   preheader P:  ...
//                 cmp   CountReg, 0            ; Z = (count == 0)
//                 mov   lp_count, CountReg     ; LP_COUNT write (r60)
//                 nop   x padWords             ; >=4-word separation padding
//                 lp.ne @E                     ; arm if count!=0, else skip to E
//   body     BB:  ...                          ; runs, hardware loops to itself
//   exit     E:   ...
//
// The conditional `lp.ne` form is BOTH the loop setup AND the zero-trip guard:
// when the count is zero the core branches past the loop to E instead of arming
// it (§4.4: a zero count otherwise runs the body once). Using it avoids
// creating any new basic block for a separate guard.
//
// If ANY silicon precondition cannot be proven -- the body is not a single
// self-looping block, the required preheader/body/exit block adjacency does not
// hold, the counter is live past the loop, or the `lp` displacement would not
// fit the u7 (<=126-byte) skip reach -- the pass leaves the loop ALONE by
// expanding the two pseudos back into the ordinary `mov` / `sub`. Because that
// fallback is a correct countdown loop, an unconvertible loop is never a
// miscompile, only a missed optimization. That is the whole reason ARC uses the
// ARM-style explicit-counter (CounterInReg) representation rather than an opaque
// hardware counter: it keeps a correct ordinary loop to fall back to.
//
//===----------------------------------------------------------------------===//

#include "ARC.h"
#include "ARCInstrInfo.h"
#include "ARCSubtarget.h"
#include "MCTargetDesc/ARCInfo.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/LivePhysRegs.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/InitializePasses.h"
#include "llvm/Support/Alignment.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"

using namespace llvm;

#define DEBUG_TYPE "arc-lowoverhead-loops"

namespace llvm {
void initializeARCLowOverheadLoopsPass(PassRegistry &);
} // namespace llvm

// The conditional `lp<cc>` skip displacement is a 6-bit field scaled by 2
// (Inst{11-6}, pre-scaled as field = disp >> 1; see ARC_LP_u7_cc in
// ARCARCompactInstrSpecial.td). Its forward reach is therefore 0..126 bytes.
static constexpr unsigned LPccMaxField = 63;
static constexpr unsigned LPccMaxDisp = LPccMaxField * 2; // 126 bytes

namespace {

class ARCLowOverheadLoops : public MachineFunctionPass {
public:
  static char ID;

  ARCLowOverheadLoops() : MachineFunctionPass(ID) {
    initializeARCLowOverheadLoopsPass(*PassRegistry::getPassRegistry());
  }

  StringRef getPassName() const override {
    return "ARC Zero-Overhead Loop Finalize";
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

private:
  const ARCInstrInfo *TII = nullptr;
  const TargetRegisterInfo *TRI = nullptr;
  const ARCSubtarget *ST = nullptr;

  // Try to commit the loop whose decrement pseudo is Dec to `lp`. Returns true
  // and rewrites the loop on success; returns false (mutating nothing) if any
  // precondition fails, leaving Dec for revertPseudo() to expand.
  bool tryConvertLoop(MachineInstr *Dec);

  // Expand a leftover formation pseudo back into ordinary code (mov / sub) so
  // that nothing pseudo reaches the AsmPrinter.
  void revertPseudo(MachineInstr *MI) const;

  // Byte offsets of each block's first instruction in the final layout,
  // honoring block alignment. Instruction sizes are final at this pass, so
  // these are exact.
  DenseMap<const MachineBasicBlock *, uint64_t>
  computeBlockOffsets(MachineFunction &MF) const;
};

} // end anonymous namespace

char ARCLowOverheadLoops::ID = 0;

INITIALIZE_PASS(ARCLowOverheadLoops, DEBUG_TYPE,
                "ARC Zero-Overhead Loop Finalize", false, false)

FunctionPass *llvm::createARCLowOverheadLoopsPass() {
  return new ARCLowOverheadLoops();
}

DenseMap<const MachineBasicBlock *, uint64_t>
ARCLowOverheadLoops::computeBlockOffsets(MachineFunction &MF) const {
  DenseMap<const MachineBasicBlock *, uint64_t> Offsets;
  uint64_t PC = 0;
  for (auto &MBB : MF) {
    PC = alignTo(PC, MBB.getAlignment());
    Offsets[&MBB] = PC;
    for (auto &MI : MBB)
      PC += TII->getInstSizeInBytes(MI);
  }
  return Offsets;
}

// Sum the byte sizes of a block's instructions.
static uint64_t blockSize(const MachineBasicBlock &MBB,
                          const ARCInstrInfo *TII) {
  uint64_t Sz = 0;
  for (auto &MI : MBB)
    Sz += TII->getInstSizeInBytes(MI);
  return Sz;
}

void ARCLowOverheadLoops::revertPseudo(MachineInstr *MI) const {
  MachineBasicBlock &MBB = *MI->getParent();
  DebugLoc DL = MI->getDebugLoc();
  Register Dst = MI->getOperand(0).getReg();
  Register Src = MI->getOperand(1).getReg();

  if (MI->getOpcode() == ARC::HWLOOP_START) {
    // Identity: CReg = start.loop.iterations(CountReg). An ordinary `mov`
    // (elided when the counter register coalesced onto its source).
    if (Dst != Src)
      BuildMI(MBB, MI, DL, TII->get(ARC::MOV_rr), Dst).addReg(Src);
  } else {
    assert(MI->getOpcode() == ARC::HWLOOP_DEC && "unexpected pseudo");
    // CReg = CReg - dec. dec is always 1 (HardwareLoopInfo.LoopDecrement).
    int64_t Dec = MI->getOperand(2).getImm();
    BuildMI(MBB, MI, DL, TII->get(ARC::SUB_rru6), Dst)
        .addReg(Src)
        .addImm(Dec);
  }
  MI->eraseFromParent();
}

bool ARCLowOverheadLoops::tryConvertLoop(MachineInstr *Dec) {
  MachineBasicBlock *BB = Dec->getParent();
  MachineFunction &MF = *BB->getParent();
  MachineRegisterInfo &MRI = MF.getRegInfo();

  Register CReg = Dec->getOperand(0).getReg();
  // The decrement must be self-tied (CReg = CReg - 1): the counter is a single
  // coalesced physical register around the loop. Anything else (a stray copy,
  // a spill) is rejected -- we fall back to the ordinary loop.
  if (!Dec->getOperand(1).isReg() || Dec->getOperand(1).getReg() != CReg)
    return false;

  // BB must be a single-block self loop: header == latch == BB, with exactly
  // two predecessors (the preheader and itself) and two successors (itself and
  // the exit).
  if (!BB->isSuccessor(BB) || BB->pred_size() != 2 || BB->succ_size() != 2)
    return false;

  // Identify the preheader P (the non-self predecessor) and the exit E (the
  // non-self successor).
  MachineBasicBlock *P = nullptr;
  for (MachineBasicBlock *Pred : BB->predecessors())
    if (Pred != BB)
      P = Pred;
  MachineBasicBlock *E = nullptr;
  for (MachineBasicBlock *Succ : BB->successors())
    if (Succ != BB)
      E = Succ;
  if (!P || !E)
    return false;

  // Block-layout adjacency is what makes the `lp` displacement and the two
  // fall-throughs correct: P immediately precedes BB (so `lp` at P's tail is
  // immediately followed by the body => LP_START = first body word), and E
  // immediately follows BB (so the body falls through to E => LP_END = E).
  if (P->getNextNode() != BB || BB->getNextNode() != E)
    return false;

  // P must be a clean preheader: its single successor is BB.
  if (P->succ_size() != 1 || *P->succ_begin() != BB)
    return false;

  // The back-branch must be the exact self-loop shape ARCBranchFinalize emits
  // for an in-range countdown: brne CReg, 0, BB.
  MachineInstr *Br = nullptr;
  for (MachineInstr &T : BB->terminators()) {
    if (Br)
      return false; // more than one terminator -> not the clean shape
    Br = &T;
  }
  if (!Br || Br->getOpcode() != ARC::BRcc_ru6)
    return false;
  if (!Br->getOperand(0).isMBB() || Br->getOperand(0).getMBB() != BB ||
      !Br->getOperand(1).isReg() || Br->getOperand(1).getReg() != CReg ||
      !Br->getOperand(2).isImm() || Br->getOperand(2).getImm() != 0 ||
      !Br->getOperand(3).isImm() || Br->getOperand(3).getImm() != ARCCC::BRNE)
    return false;

  // Find the setup pseudo in P and confirm the counter chain: its def is CReg
  // (the loop-carried counter) and its use is the loop-invariant trip count.
  MachineInstr *Start = nullptr;
  for (MachineInstr &MI : *P) {
    if (MI.getOpcode() == ARC::HWLOOP_START) {
      if (Start)
        return false; // two setups feeding one body -> bail
      Start = &MI;
    }
  }
  if (!Start || Start->getOperand(0).getReg() != CReg)
    return false;
  Register CountReg = Start->getOperand(1).getReg();

  // The counter must be dead after the loop: `lp` hands the count to LP_COUNT
  // hardware and we are about to delete every instruction that reads/writes
  // CReg. CReg is (correctly) live across the self back-edge, so its liveness
  // must be tested at the EXIT block E -- NOT via addLiveOuts(*BB), which folds
  // in the self-edge successor's live-ins and therefore always reports the
  // counter live for any self-loop. Every path leaving the loop passes through
  // E, so "not live-in to E" is exactly "unused after the loop". If it is used
  // after the loop the transform is unsound.
  LivePhysRegs ExitLiveIn(*TRI);
  ExitLiveIn.addLiveIns(*E);
  if (!ExitLiveIn.available(MRI, CReg))
    return false;

  // We append `cmp CountReg, 0` at P's tail, which writes STATUS32. Refuse if
  // STATUS32 is live into the body (some body instruction consumes incoming
  // flags) -- clobbering it would be a miscompile. This is virtually never the
  // case for a counted loop, but the check keeps the transform sound.
  LivePhysRegs PLiveOut(*TRI);
  PLiveOut.addLiveOuts(*P);
  if (!PLiveOut.available(MRI, ARC::STATUS32))
    return false;

  // No body instruction other than the decrement and the back-branch may touch
  // CReg (it is the pure control counter; the addressing IV, if any, is a
  // different register the generic pass leaves alone).
  for (MachineInstr &MI : *BB) {
    if (&MI == Dec || &MI == Br || MI.isDebugInstr())
      continue;
    for (const MachineOperand &MO : MI.operands())
      if (MO.isReg() && MO.getReg() == CReg)
        return false;
  }

  // Measure the body with FINAL sizes. Only 32-bit body instructions count as a
  // guaranteed fetch word toward the >=4-word rule; 16-bit compact instructions
  // contribute zero (conservative), so we may over-pad but never under-pad.
  unsigned BodyWords = 0;
  uint64_t BodyBytes = 0;
  for (MachineInstr &MI : *BB) {
    if (&MI == Dec || &MI == Br || MI.isDebugInstr())
      continue;
    unsigned Sz = TII->getInstSizeInBytes(MI);
    BodyBytes += Sz;
    if (Sz == 4)
      ++BodyWords;
  }
  // A fully empty body would put LP_START at LP_END (zero-length loop, undefined
  // on this engine); reject it. The generic pass does not produce one, but be
  // defensive.
  if (BodyBytes == 0)
    return false;

  // Window fetched after the LP_COUNT write = padWords + 1 (the `lp` word) +
  // BodyWords must be >= 4 => padWords >= 3 - BodyWords.
  unsigned PadWords = (BodyWords >= 3) ? 0 : (3 - BodyWords);

  // Exact `lp` displacement in the post-conversion layout, computed BEFORE any
  // mutation so a range failure reverts cleanly (no undo needed). Only P and BB
  // change size; every preceding block keeps its current offset.
  auto Offsets = computeBlockOffsets(MF);
  uint64_t PStart = Offsets[P];
  uint64_t CurPSize = blockSize(*P, TII);
  uint64_t CurBBSize = blockSize(*BB, TII);

  // Bytes P loses (HWLOOP_START) and any redundant unconditional branch to BB
  // it can shed (fall-through to the layout-next BB replaces it).
  uint64_t PRemoved = TII->getInstSizeInBytes(*Start);
  MachineInstr *PBranch = nullptr;
  for (MachineInstr &T : P->terminators()) {
    // P has a single successor BB; its only terminator (if any) is an
    // unconditional branch to BB.
    PBranch = &T;
  }
  if (PBranch)
    PRemoved += TII->getInstSizeInBytes(*PBranch);

  // Bytes added to P: cmp (4) + mov lp_count (4) + PadWords * nop (4) + lp (4).
  uint64_t PAdded = 4 /*cmp*/ + 4 /*mov*/ + PadWords * 4 /*nops*/ + 4 /*lp*/;
  uint64_t NewPSize = CurPSize - PRemoved + PAdded;
  uint64_t LpPC = PStart + (NewPSize - 4); // `lp` is P's last instruction

  uint64_t NewBBSize =
      CurBBSize - TII->getInstSizeInBytes(*Dec) - TII->getInstSizeInBytes(*Br);
  uint64_t BBStart = alignTo(PStart + NewPSize, BB->getAlignment());
  uint64_t EAddr = alignTo(BBStart + NewBBSize, E->getAlignment());

  uint64_t LpPCL = LpPC & ~UINT64_C(3);
  if (EAddr <= LpPCL)
    return false; // must be a forward, non-empty displacement
  uint64_t Disp = EAddr - LpPCL;
  if ((Disp & 1) != 0 || Disp > LPccMaxDisp)
    return false; // odd, or beyond the u7 skip reach
  unsigned Field = static_cast<unsigned>(Disp >> 1);
  if (Field > LPccMaxField)
    return false;

  LLVM_DEBUG(dbgs() << "ARCLowOverheadLoops: converting self-loop bb."
                    << BB->getNumber() << " padWords=" << PadWords
                    << " bodyWords=" << BodyWords << " disp=" << Disp << "\n");

  // ---- Commit. All precondition checks passed; mutate now. ----
  DebugLoc DL = Start->getDebugLoc();

  // 1) Body: drop the decrement and the back-branch; drop the self-edge so BB
  //    falls through to E. The BB->BB and (hardware) P->E edges are intentionally
  //    left unmodeled, exactly as ARC's LP engine is unmodeled elsewhere.
  Dec->eraseFromParent();
  Br->eraseFromParent();
  BB->removeSuccessor(BB);

  // 2) Preheader: shed the redundant branch to BB and the setup pseudo, then
  //    append cmp / mov lp_count / padding / lp.ne at the tail (CountReg is
  //    defined earlier in P and is still live here).
  if (PBranch)
    PBranch->eraseFromParent();
  Start->eraseFromParent();

  BuildMI(P, DL, TII->get(ARC::CMP_ru6)).addReg(CountReg).addImm(0);
  BuildMI(P, DL, TII->get(ARC::MOV_rr), ARC::R60).addReg(CountReg);
  for (unsigned I = 0; I != PadWords; ++I)
    BuildMI(P, DL, TII->get(ARC::ARC_NOP_0));
  // lp.ne @E : arm the loop when count != 0, else branch past to E. The field
  // is the pre-scaled forward displacement (disp >> 1); §4.4's zero-trip guard
  // and the loop setup in one instruction.
  BuildMI(P, DL, TII->get(ARC::ARC_LP_u7_cc)).addImm(Field).addImm(ARCCC::NE);

  // No E->setLabelMustBeEmitted() is needed: unlike the ARC_LP_s13 form, the
  // conditional u7 form carries the loop-end/skip target as an IMMEDIATE field
  // (computed above), not a symbol, so nothing references the exit block's
  // label.

  return true;
}

bool ARCLowOverheadLoops::runOnMachineFunction(MachineFunction &MF) {
  // Double gate: the pass is only added to the pipeline when the flag is set,
  // but never emit LP unless the flag is on and the subtarget has the engine.
  if (!ARCEnableHardwareLoops())
    return false;

  ST = &MF.getSubtarget<ARCSubtarget>();
  TII = ST->getInstrInfo();
  TRI = ST->getRegisterInfo();

  // Collect the decrement pseudos up front; conversion mutates the function.
  SmallVector<MachineInstr *, 4> Decs;
  for (auto &MBB : MF)
    for (auto &MI : MBB)
      if (MI.getOpcode() == ARC::HWLOOP_DEC)
        Decs.push_back(&MI);

  if (Decs.empty())
    return false;

  bool Changed = false;
  // On a non-ARCompact subtarget the LP engine is not wired; never convert,
  // just fall the pseudos back to ordinary code below.
  if (ST->isARCompact()) {
    for (MachineInstr *Dec : Decs)
      Changed |= tryConvertLoop(Dec);
  }

  // Expand every formation pseudo that survived (unconverted loops, and the
  // matching HWLOOP_START of converted ones -- which was already erased inside
  // tryConvertLoop, so only the fallbacks remain). Nothing pseudo may reach the
  // AsmPrinter.
  SmallVector<MachineInstr *, 8> Leftover;
  for (auto &MBB : MF)
    for (auto &MI : MBB)
      if (MI.getOpcode() == ARC::HWLOOP_START ||
          MI.getOpcode() == ARC::HWLOOP_DEC)
        Leftover.push_back(&MI);
  for (MachineInstr *MI : Leftover) {
    revertPseudo(MI);
    Changed = true;
  }

  // Conversion deleted the counter defs/uses and the self-edge, which leaves
  // stale block live-in lists (e.g. the counter register still listed live-in
  // to the body). Recompute them so -verify-machineinstrs stays clean. This is
  // a no-op when nothing changed.
  if (Changed) {
    SmallVector<MachineBasicBlock *, 16> Blocks;
    for (auto &MBB : MF)
      Blocks.push_back(&MBB);
    fullyRecomputeLiveIns(Blocks);
  }

  return Changed;
}
