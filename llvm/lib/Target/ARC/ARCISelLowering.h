//===- ARCISelLowering.h - ARC DAG Lowering Interface -----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces that ARC uses to lower LLVM code into a
// selection DAG.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_ARC_ARCISELLOWERING_H
#define LLVM_LIB_TARGET_ARC_ARCISELLOWERING_H

#include "ARC.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/TargetLowering.h"

namespace llvm {

// Forward delcarations
class ARCSubtarget;
class ARCTargetMachine;

//===--------------------------------------------------------------------===//
// TargetLowering Implementation
//===--------------------------------------------------------------------===//
class ARCTargetLowering : public TargetLowering {
public:
  explicit ARCTargetLowering(const TargetMachine &TM,
                             const ARCSubtarget &Subtarget);

  /// Provide custom lowering hooks for some operations.
  SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override;

  /// Return true if the addressing mode represented by AM is legal for this
  /// target, for a load/store of the specified type.
  bool isLegalAddressingMode(const DataLayout &DL, const AddrMode &AM, Type *Ty,
                             unsigned AS,
                             Instruction *I = nullptr) const override;

  /// Return true if the target allows unaligned memory accesses of the
  /// specified type in the given address space, and set *Fast accordingly.
  /// ARC700/BCM55030 misaligned word/half-word accesses do not trap and are
  /// NOT hardware-fixed-up: the low address bits are silently cleared
  /// (word: addr & ~3, half-word: addr & ~1), corrupting the access. Always
  /// return false. See docs/notes/isa-characterization.md.
  bool allowsMisalignedMemoryAccesses(
      EVT VT, unsigned AddrSpace = 0, Align Alignment = Align(1),
      MachineMemOperand::Flags Flags = MachineMemOperand::MONone,
      unsigned *Fast = nullptr) const override;

  /// Return true if folding Imm directly as the immediate of an `add` is
  /// legal -- i.e. it fits ADD_rrs12/ADD_rru6's -2048..2047 window (the
  /// same silicon fact ARCTargetTransformInfo.h's materializeCost32 uses).
  /// The TargetLoweringBase default is `return true` unconditionally for
  /// EVERY int64_t, which made ConstantHoistingPass::findBaseConstants
  /// (the linear scan gated on `TTI->isLegalAddImmediate(Diff)`,
  /// ConstantHoisting.cpp) merge ANY same-type constants in a function
  /// into one rebase group regardless of how far apart their values are --
  /// the group is never split, so an outlier gets rebased through a
  /// same-cost-tier-chosen base via an ADD that itself needs a LIMM,
  /// replacing one folded ALU-immediate instruction with three. See
  /// ARCTargetTransformInfo.h's getIntImmCodeSizeCost comment for the
  /// measured -Oz firmware regression this caused before both were added.
  bool isLegalAddImmediate(int64_t Imm) const override {
    return isInt<12>(Imm);
  }

  /// Same s12 window as isLegalAddImmediate, for CMP_rs12/CMP_ru6.
  bool isLegalICmpImmediate(int64_t Imm) const override {
    return isInt<12>(Imm);
  }

private:
  const ARCSubtarget &Subtarget;

  void ReplaceNodeResults(SDNode *N, SmallVectorImpl<SDValue> &Results,
                          SelectionDAG &DAG) const override;

  // Lower Operand helpers
  SDValue LowerCallArguments(SDValue Chain, CallingConv::ID CallConv,
                             bool isVarArg,
                             const SmallVectorImpl<ISD::InputArg> &Ins,
                             SDLoc dl, SelectionDAG &DAG,
                             SmallVectorImpl<SDValue> &InVals) const;
  // Lower Operand specifics
  SDValue LowerJumpTable(SDValue Op, SelectionDAG &DAG) const;
  SDValue LowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const;
  SDValue LowerSELECT_CC(SDValue Op, SelectionDAG &DAG) const;
  SDValue LowerBR_CC(SDValue Op, SelectionDAG &DAG) const;
  SDValue LowerSIGN_EXTEND_INREG(SDValue Op, SelectionDAG &DAG) const;
  SDValue LowerGlobalAddress(SDValue Op, SelectionDAG &DAG) const;
  SDValue LowerConstantPool(SDValue Op, SelectionDAG &DAG) const;
  SDValue LowerBSWAP(SDValue Op, SelectionDAG &DAG) const;
  // Unsigned add/sub-with-overflow -- see docs/llvm-arc700-optimizations/
  // 19-flag-consuming-arithmetic-idioms.md. Build the 2-result ARCISD::
  // UADDO/USUBO target node; the legalizer pulls .getValue(1) out for the
  // overflow result (LegalizeDAG.cpp's multi-result Custom-lowering path).
  SDValue LowerUADDO(SDValue Op, SelectionDAG &DAG) const;
  SDValue LowerUSUBO(SDValue Op, SelectionDAG &DAG) const;
  SDValue PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const override;

  // Bounded scaled-add/shift/sub/neg synthesizer for `mul x, C` on cores
  // without a hardware multiplier (ARC700 / !Subtarget.hasMPY()). Runs as a
  // target DAG combine on ISD::MUL (registered via setTargetDAGCombine in
  // the constructor), strictly BEFORE DAGCombiner::visitMUL's own generic
  // 2-term power-of-two decomposition would ever see the node (see
  // decomposeMulByConstant below, which is unconditionally disabled so it
  // never competes with this). Emits only plain ISD::ADD/SUB/SHL nodes built
  // from a bounded depth/node-budgeted search (see
  // docs/llvm-arc700-optimizations/02-constant-multiplication.md); ISel then
  // selects the existing ADD1-3/SUB1-3 scaled-add patterns in
  // ARCARCompactPatterns.td and the plain add/sub/asl patterns for the rest.
  // Returns SDValue() (no combine) when no synthesized sequence is cheaper
  // than a __mulsi3 call under the current opt-size profile, or when the
  // subtarget has a hardware multiplier.
  SDValue performMULCombine(SDNode *N, DAGCombinerInfo &DCI) const;

  // Overflow-to-branch/select rewrite -- docs/llvm-arc700-optimizations/
  // 19-flag-consuming-arithmetic-idioms.md. Recognizes ISD::BRCOND /
  // ISD::SELECT whose sole condition is the overflow result (#1) of a raw
  // (not-yet-Custom-lowered) generic ISD::UADDO/USUBO node and rewrites it to
  // the equivalent native unsigned compare-and-branch / compare-and-select
  // (ISD::BR_CC / ISD::SELECT_CC, both already Custom-lowered here) instead of
  // letting LowerUADDO/LowerUSUBO materialize a 0/1 boolean that is then
  // redundantly re-compared. UADDO overflow == (A+B <u A); USUBO borrow ==
  // (A <u B) -- both plain ISD::SETULT, so the silicon-validated
  // ISDCCtoARCCC / BRcc / CMOV paths carry the polarity and NO new carry-flag
  // condition is hand-coded here. The node's arithmetic result #0 (the
  // wrapped sum / the difference) MAY be live: it is re-materialized with a
  // plain ADD/SUB and shared, so unlike a flag-glued producer/consumer there
  // is no STATUS32 adjacency constraint and a live result exports freely.
  //
  // These run as target DAG combines on ISD::BRCOND / ISD::SELECT (registered
  // via setTargetDAGCombine in the constructor), firing at
  // Level::BeforeLegalizeTypes -- before ISD::BRCOND's generic Expand, before
  // ISD::SELECT's generic Expand, and before LowerUADDO/LowerUSUBO's own
  // Custom-lowering (all later, in LegalizeDAG) -- so when either hook fires
  // the raw generic ISD::UADDO/USUBO node is still intact and the
  // materialize-then-recompare sequence is never constructed for the matched
  // (single-overflow-use) case.
  //
  // Returns SDValue() (declines, no-op) whenever the overflow bit is not the
  // sole condition (Cond.hasOneUse() == false -- e.g. also stored/returned),
  // is not width-i32, or the guarded node is not UADDO/USUBO's overflow
  // result -- in every such case the ORIGINAL node proceeds untouched through
  // the existing value-materializing path (LowerUADDO/LowerUSUBO ->
  // UADDO_PSEUDO/USUBO_PSEUDO), correct for a genuinely-used overflow value.
  SDValue performOverflowBrcondCombine(SDNode *N, DAGCombinerInfo &DCI) const;
  SDValue performOverflowSelectCombine(SDNode *N, DAGCombinerInfo &DCI) const;

  // Subsumed by performMULCombine above (see its comment) -- always returns
  // false so DAGCombiner::visitMUL's own decomposition never fires and every
  // non-trivial constant multiply on a !hasMPY() target reaches the target
  // combine uniformly. See docs/bugs/ if this predicate is ever revived.
  bool decomposeMulByConstant(LLVMContext &Context, EVT VT,
                              SDValue C) const override;

  // KnownBits-driven immediate re-selection for AND/OR/XOR (idea 2 of
  // docs/llvm-arc700-optimizations/21-immediate-cost-and-rematerialization.md).
  // Given that only DemandedBits of Op's result are ever consumed, look for
  // a replacement immediate that agrees with the original constant on every
  // demanded bit but is cheaper to materialize (fits u6/s12, or a
  // BSET/BCLR/BMSK single-bit/mask shape) than the original, which may
  // require an 8-byte LIMM form. Calls TLO.CombineTo and returns true when a
  // strictly cheaper equivalent constant was found; also returns true
  // (without a CombineTo) when the constant is already cheapest but has
  // bits outside DemandedBits, to suppress TargetLowering::
  // ShrinkDemandedConstant's own clear-only fallback -- which would
  // otherwise strip those bits back to a non-free value and oscillate with
  // this hook forever. See the implementation for the full argument.
  bool targetShrinkDemandedConstant(SDValue Op, const APInt &DemandedBits,
                                    const APInt &DemandedElts,
                                    TargetLoweringOpt &TLO) const override;

  SDValue LowerFormalArguments(SDValue Chain, CallingConv::ID CallConv,
                               bool isVarArg,
                               const SmallVectorImpl<ISD::InputArg> &Ins,
                               const SDLoc &dl, SelectionDAG &DAG,
                               SmallVectorImpl<SDValue> &InVals) const override;

  SDValue LowerCall(TargetLowering::CallLoweringInfo &CLI,
                    SmallVectorImpl<SDValue> &InVals) const override;

  SDValue LowerReturn(SDValue Chain, CallingConv::ID CallConv, bool isVarArg,
                      const SmallVectorImpl<ISD::OutputArg> &Outs,
                      const SmallVectorImpl<SDValue> &OutVals, const SDLoc &dl,
                      SelectionDAG &DAG) const override;

  bool CanLowerReturn(CallingConv::ID CallConv, MachineFunction &MF,
                      bool isVarArg,
                      const SmallVectorImpl<ISD::OutputArg> &ArgsFlags,
                      LLVMContext &Context, const Type *RetTy) const override;

  bool mayBeEmittedAsTailCall(const CallInst *CI) const override;

  //===--------------------------------------------------------------------===//
  // Inline assembly constraint handling.
  //===--------------------------------------------------------------------===//
  ConstraintType getConstraintType(StringRef Constraint) const override;

  std::pair<unsigned, const TargetRegisterClass *>
  getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                               StringRef Constraint, MVT VT) const override;
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_ARC_ARCISELLOWERING_H
