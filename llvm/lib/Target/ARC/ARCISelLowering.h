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
  SDValue PerformDAGCombine(SDNode *N, DAGCombinerInfo &DCI) const override;

  // Decompose `mul x, C` for 2^N±1 constants into shl+add/sub instead of a
  // __mulsi3 libcall (ARC700 has no hardware multiplier).
  bool decomposeMulByConstant(LLVMContext &Context, EVT VT,
                              SDValue C) const override;

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
