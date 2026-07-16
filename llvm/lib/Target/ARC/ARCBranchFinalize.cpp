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
#include "llvm/Support/MathExtras.h"
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
  bool tryFuseFlagRecycle(MachineInstr *MI) const;

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

// Shared guard for both the in-range bbit0/1 fusion (tryFuseBBIT) and the
// out-of-range BTST+Bcc fallback (replaceWithCmpBcc, dossier 24): recognize
// an immediately-preceding single-bit `and` feeding an immediate
// compare-against-zero branch (EQ/NE), and confirm the AND's destination is
// dead after the branch so both the `and` and the branch can be replaced.
// Factored out so the liveness/shape logic can't drift between the two call
// sites. On success, AndMI/Src/Bit describe the fusable `and` and MI's own
// CC (EQ/NE) operand is left untouched for the caller to read.
static bool matchBitTestBRcc(MachineInstr *MI, const TargetRegisterInfo *TRI,
                             MachineInstr *&AndMI, Register &Src,
                             unsigned &Bit) {
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

  Register AndDst;
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
  // is live at the branch and remains correct for the bbit/btst that replaces
  // it. (When the `and` is in place -- Src == B -- removing it leaves B
  // holding its incoming value, which is exactly what the bit test needs.)

  AndMI = Prev;
  return true;
}

// Flag-recycling branch fusion (dossier 21 idea 3). Unlike the SELECT_CC
// side (ARCISelLowering.cpp's LowerSELECT_CC, which emits ARCISD::LSRTEST /
// ARCISD::BMSKTEST target nodes at the SelectionDAG level), this is a
// POST-ISEL peephole for the SAME reason bbit0/bbit1 fusion above is one: a
// dedicated glue-consuming branch node/pseudo built straight out of ISel
// would be unanalyzable by analyzeBranch (only BRcc_rr_p/BRcc_ru6_p are
// recognized -- see isCondBranchOpcode in ARCInstrInfo.cpp) and would break
// MachineBlockPlacement / BranchFolding for every block ending in it. So
// LowerBR_CC keeps emitting the generic ARCISD::BRcc node unchanged, and we
// fuse it here, late, after all CFG-shape-dependent passes have already run
// on the still-analyzable BRcc_rr_p/BRcc_ru6_p pseudo.
//
// Both cases replace a dead-after-the-branch producer instruction (a
// LIMM-materializing `mov` for the range test, a LIMM-masking `and` for the
// zero test) plus the compare-and-branch pseudo with a 2-instruction
// `<flag-op>.f` + `Bcc` sequence -- the exact `mov(8B)+BRcc_rr/CMP+Bcc` or
// `and(8B)+cmp(4B)+Bcc` baseline this dossier targets. `Bcc` has s21 range
// ("always reachable" per the existing comment on the fallback `Bcc` above),
// so unlike tryFuseBBIT/replaceWithBRcc's bbit fusion this fold does not
// need to know whether MI's original target was in short-branch range --
// it is tried unconditionally, before the InRange decision.

// Match a preceding value-producing `lsr $dst, $src, K` (LSR_rru6 -- the
// GENERIC/ARCv2-shape shift multiclass in ARCInstrInfo.td, not the
// ARCompact-specific ARC_LSR_a_b_u6, which has no Pat at all and is never
// selected by ordinary `srl` codegen) feeding an immediate
// compare-against-zero branch (EQ/NE) whose shift amount K is LIMM-sized
// (unsigned range test: `x <u 2^K`). This is the shape ACTUALLY reached by
// ordinary IR: confirmed empirically that the generic SelectionDAG combiner
// canonicalizes `x <u 2^K` into `(x>>K)==0` (SETEQ/SETNE against a shifted
// value, RHS=0) well before LowerBR_CC's Custom hook runs -- the SAME
// canonicalization documented for LowerSELECT_CC's LSRTEST fold in
// ARCISelLowering.cpp, which is why LowerBR_CC's own emitted
// ARCISD::BRcc(LHS,RHS,cc) already carries LHS=(shifted x), RHS=0, cc=EQ/NE
// by the time it reaches ISel, and selects straight to BRcc_ru6_p (RHS=0
// always fits u6) rather than the LIMM-materializing BRcc_rr_p path
// matchRangeTestBRccLimm below was written for. `lsr $dst,$src,K` is
// otherwise a perfectly ordinary value-producing shift with no special
// provenance -- the liveness check below (dst dead after the branch) is
// what makes fusing it here always safe: `(x>>K)==0` is unconditionally
// equivalent regardless of why the shift was emitted.
static bool matchRangeTestBRccShift(MachineInstr *MI,
                                    const TargetRegisterInfo *TRI,
                                    MachineInstr *&LsrMI, Register &Src,
                                    unsigned &K) {
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
  if (!Prev || Prev->getOpcode() != ARC::LSR_rru6)
    return false;
  if (Prev->getOperand(0).getReg() != B)
    return false;
  const MachineOperand &Imm = Prev->getOperand(2);
  if (!Imm.isImm())
    return false;
  uint64_t KV = static_cast<uint64_t>(Imm.getImm());
  // LIMM gate: 2^K > 2047 <=> K >= 11. K is also bounded < 32 by the u6
  // immediate field's own producer (a shift amount that never legitimately
  // exceeds 31 for a 32-bit value), checked here defensively anyway.
  if (KV < 11 || KV >= 32)
    return false;

  // B (the shifted value actually tested) must be dead after the branch:
  // its only use is this compare, and we are erasing both the `lsr` (its
  // sole def) and the branch. LivePhysRegs is conservative -- if liveness
  // is unknown it keeps B live and we simply do not fuse. (Src -- the
  // PRE-shift value -- is untouched: we keep reading it directly, so its
  // own liveness is unaffected.)
  const MachineRegisterInfo &MRI = MBB->getParent()->getRegInfo();
  LivePhysRegs LiveOut(*TRI);
  LiveOut.addLiveOuts(*MBB);
  if (!LiveOut.available(MRI, B))
    return false;

  LsrMI = Prev;
  Src = Prev->getOperand(1).getReg();
  K = static_cast<unsigned>(KV);
  return true;
}

// Defensive fallback for the (unreached in practice -- see
// matchRangeTestBRccShift above, which is what ordinary IR actually
// selects) raw shape: a preceding MOV_rlimm materializing a LIMM-sized
// power-of-two constant into the register-form pseudo's RHS operand
// directly (`x <u 2^K` reaching BR_CC as SETULT/SETUGE with RHS=2^K,
// unmolested by the shift canonicalization -- mirrors why
// matchRangeTestBRccShift's SELECT_CC sibling, isRangeTestPow2 in
// ARCISelLowering.cpp, is likewise kept as a defensive fallback there).
static bool matchRangeTestBRccLimm(MachineInstr *MI,
                                   const TargetRegisterInfo *TRI,
                                   MachineInstr *&MovMI, Register &Src,
                                   unsigned &K) {
  // Only the register-form compare-and-branch, LO (ult) or HS (uge).
  if (MI->getOpcode() != ARC::BRcc_rr_p)
    return false;
  int64_t CC = MI->getOperand(3).getImm();
  if (CC != ARCCC::LO && CC != ARCCC::HS)
    return false;
  Register Ctmp = MI->getOperand(2).getReg();

  MachineBasicBlock *MBB = MI->getParent();
  MachineInstr *Prev = MI->getPrevNode();
  while (Prev && Prev->isDebugInstr())
    Prev = Prev->getPrevNode();
  if (!Prev || Prev->getOpcode() != ARC::MOV_rlimm)
    return false;
  if (Prev->getOperand(0).getReg() != Ctmp)
    return false;
  const MachineOperand &Imm = Prev->getOperand(1);
  if (!Imm.isImm())
    return false;
  uint32_t V = static_cast<uint32_t>(Imm.getImm());
  if (!isPowerOf2_32(V) || V <= 2047)
    return false;

  // Ctmp must be dead after the branch: its only use is this compare, and
  // we are erasing both the MOV (its sole def) and the branch. LivePhysRegs
  // is conservative -- if liveness is unknown it keeps Ctmp live and we
  // simply do not fuse. (Src -- the value actually tested -- is untouched:
  // we keep reading it directly, so its own liveness is unaffected.)
  const MachineRegisterInfo &MRI = MBB->getParent()->getRegInfo();
  LivePhysRegs LiveOut(*TRI);
  LiveOut.addLiveOuts(*MBB);
  if (!LiveOut.available(MRI, Ctmp))
    return false;

  MovMI = Prev;
  Src = MI->getOperand(1).getReg();
  K = Log2_32(V);
  return true;
}

// Match a preceding value-producing `bmsk $dst, $src, K` (ARC_BMSK_a_b_u6)
// feeding an immediate compare-against-zero branch (EQ/NE) -- low-mask zero
// test: `(x & (2^(K+1)-1)) == 0`. This is the shape ACTUALLY reached by
// ordinary IR: dossier 16's own value-producing BMSK Pat
// (ARCARCompactPatterns.td, `bmsk_mask_hi`) already rewrites any
// LIMM-sized-contiguous-low-mask `and` into a 4-byte `bmsk` REGARDLESS of
// whether the result feeds a compare, so by the time this pass runs the
// producer in front of the branch is never a LIMM-carrying `and` -- see
// matchMaskZeroBRccLimm below for the (unreached in practice, kept
// defensively) AND_rrlimm shape. ARC_BMSK_a_b_u6 is the multiclass's ONLY
// constant-immediate Pat target (verified: no other Pat in this backend
// matches (ARC_BMSK_a_b_u6 ...)), so K -- its own u6 bit-position operand --
// is already gate-passed by construction; no re-derivation or re-check of
// the LIMM threshold is needed here.
static bool matchMaskZeroBRccValue(MachineInstr *MI,
                                   const TargetRegisterInfo *TRI,
                                   MachineInstr *&BmskMI, Register &Src,
                                   unsigned &K) {
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
  if (!Prev || Prev->getOpcode() != ARC::ARC_BMSK_a_b_u6)
    return false;
  if (Prev->getOperand(0).getReg() != B)
    return false;
  const MachineOperand &Imm = Prev->getOperand(2);
  if (!Imm.isImm())
    return false;

  // B (the bmsk's dest, i.e. the compared `x & mask` value) must be dead
  // after the branch, same discipline as matchBitTestBRcc above.
  const MachineRegisterInfo &MRI = MBB->getParent()->getRegInfo();
  LivePhysRegs LiveOut(*TRI);
  LiveOut.addLiveOuts(*MBB);
  if (!LiveOut.available(MRI, B))
    return false;

  BmskMI = Prev;
  Src = Prev->getOperand(1).getReg();
  K = static_cast<unsigned>(Imm.getImm());
  return true;
}

// Defensive fallback for the (unreached in practice -- see
// matchMaskZeroBRccValue above) raw shape: a preceding AND_rrlimm feeding
// an immediate compare-against-zero branch (EQ/NE) whose mask is a
// LIMM-sized contiguous low-bit run, i.e. the `and` was NOT already
// rewritten into `bmsk` by dossier 16's Pat (e.g. a non-ARCompact-aware
// intermediate, or some future change to that Pat's selection). Restricted
// to AND_rrlimm only -- unlike matchSingleBitAnd's single-bit sibling,
// which also accepts AND_rru6/AND_rrs12 -- because any mask expressible in
// u6/s12 already fits a plain 4-byte `and`, so is never worth this fold;
// requiring AND_rrlimm naturally enforces that gate without a separate size
// check.
static bool matchMaskZeroBRccLimm(MachineInstr *MI,
                                  const TargetRegisterInfo *TRI,
                                  MachineInstr *&AndMI, Register &Src,
                                  unsigned &K) {
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
  if (!Prev || Prev->getOpcode() != ARC::AND_rrlimm)
    return false;
  if (Prev->getOperand(0).getReg() != B)
    return false;
  const MachineOperand &Imm = Prev->getOperand(2);
  if (!Imm.isImm())
    return false;
  uint32_t M = static_cast<uint32_t>(Imm.getImm());
  if (M <= 2047 || M == 0xFFFFu || M == 0xFFFFFFFFu || !isMask_32(M))
    return false;

  // B (the AND's dest, i.e. the compared `x & mask` value) must be dead
  // after the branch, same discipline as matchBitTestBRcc above.
  const MachineRegisterInfo &MRI = MBB->getParent()->getRegInfo();
  LivePhysRegs LiveOut(*TRI);
  LiveOut.addLiveOuts(*MBB);
  if (!LiveOut.available(MRI, B))
    return false;

  AndMI = Prev;
  Src = Prev->getOperand(1).getReg();
  K = Log2_32(M + 1) - 1;
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

  MachineInstr *AndMI;
  Register Src;
  unsigned Bit;
  if (!matchBitTestBRcc(MI, TRI, AndMI, Src, Bit))
    return false;

  int64_t CC = MI->getOperand(3).getImm();
  unsigned Opc = (CC == ARCCC::NE) ? ARC::ARC_BBIT1_b_u6_s9_d
                                   : ARC::ARC_BBIT0_b_u6_s9_d;
  BuildMI(*MI->getParent(), MI, MI->getDebugLoc(), TII->get(Opc))
      .addReg(Src)
      .addImm(Bit)
      .addMBB(MI->getOperand(0).getMBB());
  AndMI->eraseFromParent();
  MI->eraseFromParent();
  return true;
}

bool ARCBranchFinalize::tryFuseFlagRecycle(MachineInstr *MI) const {
  // Both null-destination flag forms (lsr.f/bmsk.f 0,...) are ARCompact-only
  // encodings, same restriction (and same SchedClass-resolution reason) as
  // tryFuseBBIT/replaceWithCmpBcc's BTST fusion above.
  if (!ST || !ST->isARCompact())
    return false;

  MachineInstr *ProducerMI;
  Register Src;
  unsigned K;

  // Range test: try the actually-reached shift shape first, then the
  // defensive LIMM shape.
  if (matchRangeTestBRccShift(MI, TRI, ProducerMI, Src, K)) {
    LLVM_DEBUG(dbgs() << "Replacing pseudo branch with lsr.f + Bcc "
                         "(flag-recycling range test, shift shape)\n");
    // Z polarity is unchanged from the source compare (MI's CC is already
    // EQ/NE, matching (x>>K)==0 directly), so it carries over as-is.
    int64_t CC = MI->getOperand(3).getImm();
    BuildMI(*MI->getParent(), MI, MI->getDebugLoc(),
            TII->get(ARC::ARC_LSR_z_b_u6_f))
        .addReg(Src)
        .addImm(K);
    BuildMI(*MI->getParent(), MI, MI->getDebugLoc(), TII->get(ARC::Bcc))
        .addMBB(MI->getOperand(0).getMBB())
        .addImm(CC);
    ProducerMI->eraseFromParent();
    MI->eraseFromParent();
    return true;
  }
  if (matchRangeTestBRccLimm(MI, TRI, ProducerMI, Src, K)) {
    LLVM_DEBUG(dbgs() << "Replacing pseudo branch with lsr.f + Bcc "
                         "(flag-recycling range test, LIMM shape)\n");
    int64_t CC = MI->getOperand(3).getImm();
    // (x>>K)==0 is the ult predicate directly (Z=1 -> EQ); uge is its
    // negation (Z=0 -> NE). Do NOT reuse getCCForBRcc/MI's own CC here --
    // LO/HS are meaningless against a Z-only glue produced by a shift, not
    // a subtract-based compare.
    int64_t FlagCC = (CC == ARCCC::LO) ? ARCCC::EQ : ARCCC::NE;
    BuildMI(*MI->getParent(), MI, MI->getDebugLoc(),
            TII->get(ARC::ARC_LSR_z_b_u6_f))
        .addReg(Src)
        .addImm(K);
    BuildMI(*MI->getParent(), MI, MI->getDebugLoc(), TII->get(ARC::Bcc))
        .addMBB(MI->getOperand(0).getMBB())
        .addImm(FlagCC);
    ProducerMI->eraseFromParent();
    MI->eraseFromParent();
    return true;
  }

  // Mask-zero test: try the actually-reached bmsk-value shape first, then
  // the defensive AND_rrlimm shape. Z polarity is unchanged from the source
  // compare in BOTH shapes, so MI's own CC (EQ/NE) always carries over
  // as-is -- mirrors the BTST fusion's CC reuse in replaceWithCmpBcc below.
  if (matchMaskZeroBRccValue(MI, TRI, ProducerMI, Src, K)) {
    LLVM_DEBUG(dbgs() << "Replacing pseudo branch with bmsk.f + Bcc "
                         "(flag-recycling zero test, value shape)\n");
    int64_t CC = MI->getOperand(3).getImm();
    BuildMI(*MI->getParent(), MI, MI->getDebugLoc(),
            TII->get(ARC::ARC_BMSK_z_b_u6_f))
        .addReg(Src)
        .addImm(K);
    BuildMI(*MI->getParent(), MI, MI->getDebugLoc(), TII->get(ARC::Bcc))
        .addMBB(MI->getOperand(0).getMBB())
        .addImm(CC);
    ProducerMI->eraseFromParent();
    MI->eraseFromParent();
    return true;
  }
  if (matchMaskZeroBRccLimm(MI, TRI, ProducerMI, Src, K)) {
    LLVM_DEBUG(dbgs() << "Replacing pseudo branch with bmsk.f + Bcc "
                         "(flag-recycling zero test, LIMM shape)\n");
    int64_t CC = MI->getOperand(3).getImm();
    BuildMI(*MI->getParent(), MI, MI->getDebugLoc(),
            TII->get(ARC::ARC_BMSK_z_b_u6_f))
        .addReg(Src)
        .addImm(K);
    BuildMI(*MI->getParent(), MI, MI->getDebugLoc(), TII->get(ARC::Bcc))
        .addMBB(MI->getOperand(0).getMBB())
        .addImm(CC);
    ProducerMI->eraseFromParent();
    MI->eraseFromParent();
    return true;
  }

  return false;
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

  // Out-of-bbit-range constant-bit-position test (dossier 24): `btst` + Bcc
  // (2 insns) replaces the generic `and` + `cmp` + Bcc (3 insns) fallback
  // when this branch is simply a bit test whose target didn't fit bbit's s9
  // range. Z-flag equivalence between BTST (AND-derived) and CMP-vs-0
  // (SUB-derived) is proven identical (see docs/notes/isa-characterization.md
  // 5.4 and dossier 24's zPolarity note); the branch keeps the SAME CC
  // (EQ/NE) it already had for CMP+Bcc. Restricted to ARCompact subtargets
  // -- BTST is an ARCompact-only encoding, same restriction as tryFuseBBIT
  // above (and for the identical SchedClass-resolution reason).
  if (ST && ST->isARCompact()) {
    MachineInstr *AndMI;
    Register Src;
    unsigned Bit;
    if (matchBitTestBRcc(MI, TRI, AndMI, Src, Bit)) {
      LLVM_DEBUG(dbgs() << "Replacing pseudo branch with BTST + Bcc "
                           "(out of bbit range)\n");
      int64_t CC = MI->getOperand(3).getImm();
      // Bit comes from matchSingleBitAnd's Log2_32 of a 32-bit power-of-2
      // immediate, so it is always in [0,31] -- always fits BTST's u6
      // immediate field.
      BuildMI(*MI->getParent(), MI, MI->getDebugLoc(),
              TII->get(ARC::ARC_BTST_b_u6))
          .addReg(Src)
          .addImm(Bit);
      BuildMI(*MI->getParent(), MI, MI->getDebugLoc(), TII->get(ARC::Bcc))
          .addMBB(MI->getOperand(0).getMBB())
          .addImm(CC);
      AndMI->eraseFromParent();
      MI->eraseFromParent();
      return;
    }
  }

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
      // The delay-slot filler runs AFTER this pass. In its default mode it
      // does not grow the code at all: it *moves* an instruction from before
      // a transfer into its slot and flips the transfer to a same-size .d
      // encoding, so a block's size is unchanged. The one residual effect is
      // that a filled transfer's own PC shifts up to 4 bytes earlier, which
      // can lengthen a forward displacement by up to 4 -- comfortably inside
      // the ~2x margin the range check below already keeps (it bounds to a
      // signed 9-bit *byte* displacement, ~+/-256, while the hardware encodes
      // half-words, ~+/-510).
      //
      // Reserve 4 bytes for any transfer that already carries a delay slot at
      // this point (hand-written MIR, and the -arc-nop-delay-filler A/B mode,
      // which does insert a NOP per slot). An out-of-range compact
      // compare-and-branch (BRcc) or bit-test-and-branch (bbit) is a hard
      // relocation error, not a silent miscompile, so the estimate must stay
      // a conservative upper bound on the final layout.
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
    // Flag-recycling fusion (dossier 21 idea 3) is tried unconditionally,
    // before the in-range decision below: its output is always `<flag-op>.f
    // + Bcc` regardless of MI's original target distance (Bcc has s21
    // range, always reachable), so there is no InRange dependency to
    // compute for it.
    if (tryFuseFlagRecycle(MI))
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
