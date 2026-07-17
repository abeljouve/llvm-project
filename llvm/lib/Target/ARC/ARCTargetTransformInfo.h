//===- ARCTargetTransformInfo.h - ARC specific TTI --------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
// \file
// This file contains a TargetTransformInfoImplBase conforming object specific
// to the ARC target machine. It uses the target's detailed information to
// provide more precise answers to certain TTI queries, while letting the
// target independent and default TTI implementations handle the rest.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_ARC_ARCTARGETTRANSFORMINFO_H
#define LLVM_LIB_TARGET_ARC_ARCTARGETTRANSFORMINFO_H

#include "ARC.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/CodeGen/BasicTTIImpl.h"

namespace llvm {

class ARCSubtarget;
class ARCTargetLowering;
class ARCTargetMachine;

class ARCTTIImpl final : public BasicTTIImplBase<ARCTTIImpl> {
  using BaseT = BasicTTIImplBase<ARCTTIImpl>;
  using TTI = TargetTransformInfo;
  friend BaseT;

  const ARCSubtarget *ST;
  const ARCTargetLowering *TLI;

  const ARCSubtarget *getST() const { return ST; }
  const ARCTargetLowering *getTLI() const { return TLI; }

public:
  explicit ARCTTIImpl(const ARCTargetMachine *TM, const Function &F)
      : BaseT(TM, F.getDataLayout()), ST(TM->getSubtargetImpl()),
        TLI(ST->getTargetLowering()) {}

  // Provide value semantics. MSVC requires that we spell all of these out.
  ARCTTIImpl(const ARCTTIImpl &Arg)
      : BaseT(static_cast<const BaseT &>(Arg)), ST(Arg.ST), TLI(Arg.TLI) {}
  ARCTTIImpl(ARCTTIImpl &&Arg)
      : BaseT(std::move(static_cast<BaseT &>(Arg))), ST(std::move(Arg.ST)),
        TLI(std::move(Arg.TLI)) {}

  // -----------------------------------------------------------------------
  // Immediate materialization cost model.
  //
  // Silicon fact (docs/notes/isa-characterization.md, committed-backend fact
  // in docs/llvm-arc700-optimizations/21-immediate-cost-and-rematerialization.md):
  // ISD::Constant selects MOV_rs12 (one 4-byte host word) when the value
  // fits a signed 12-bit immediate (-2048..2047, see
  // ARCISelDAGToDAG.cpp's ISD::Constant Select() case), else MOV_rlimm
  // (host word + an appended 32-bit LIMM word -- pure code-size and 4 KiB
  // direct-mapped I-cache cost, per the same dossier). This is a cost
  // model only: it emits no instructions and enables no new ISel pattern.

  // Cost of materializing one 32-bit half of an immediate in isolation
  // (no fold context): s12-fitting -> a single MOV_rs12 word (TCC_Basic);
  // everything else -> MOV_rlimm, host word + LIMM word (2 * TCC_Basic).
  // isSignedIntN(12) is pure APInt math (never a host signed shift), and
  // is trivially true for any APInt narrower than 12 bits.
  static InstructionCost materializeCost32(const APInt &Imm) {
    return Imm.isSignedIntN(12) ? TTI::TCC_Basic : 2 * TTI::TCC_Basic;
  }

  // Cost of encoding an already-hoisted candidate's REBASE OFFSET as the
  // immediate of the `Instruction::Add` that ConstantHoistingPass::
  // emitBaseConstants always synthesizes for a nonzero rebase --
  // `BinaryOperator::Create(Instruction::Add, Base, Adj->Offset, ...)` in
  // ConstantHoisting.cpp -- regardless of the ORIGINAL use's opcode.
  // ConstantHoistingPass::maximizeConstantsInRange subtracts this as a
  // per-pairing penalty (`Cost -= getIntImmCodeSizeCost(Diff)`) when
  // scoring which candidate should become the shared base: the bigger the
  // penalty, the less attractive grouping two constants under one base is.
  //
  // The BasicTTIImplBase default unconditionally returns 0 ("every rebase
  // is free"), which made ConstantHoisting group numerically nearby but
  // otherwise-unrelated constants under one base even when the rebase ADD
  // itself needs a LIMM -- turning an originally-folded single
  // ALU-immediate site (e.g. `and r1,r1,0x1FE00`, one host word + LIMM)
  // into base-materialize + LIMM-ADD-rebase + register-operand ALU op
  // (three instruction words instead of one). Measured on the -Oz
  // firmware build: without this override .text grew 293294 -> 295670 bytes
  // (+2376) versus the pre-cost-model baseline -- a regression, not the
  // expected win. Same isSignedIntN(12) fold window as materializeCost32
  // (ADD_rrs12 / ADD_rru6 cover the full u6+s12 range), applied to the
  // Diff instead of the raw candidate value.
  InstructionCost getIntImmCodeSizeCost(unsigned Opcode, unsigned Idx,
                                        const APInt &Imm,
                                        Type *Ty) const override {
    unsigned BitSize = Ty->getPrimitiveSizeInBits();
    if (BitSize == 0 || BitSize > 64)
      return 0;
    if (BitSize <= 32)
      return Imm.isSignedIntN(12) ? 0 : TTI::TCC_Basic;
    APInt Lo = Imm.trunc(32);
    APInt Hi = Imm.lshr(32).trunc(32);
    return (Lo.isSignedIntN(12) ? 0 : TTI::TCC_Basic) +
           (Hi.isSignedIntN(12) ? 0 : TTI::TCC_Basic);
  }

  InstructionCost getIntImmCost(const APInt &Imm, Type *Ty,
                                TTI::TargetCostKind CostKind) const override {
    unsigned BitSize = Ty->getPrimitiveSizeInBits();
    // Defensive guards (mirrors LanaiTTIImpl::getIntImmCost): not reachable
    // for real IR on this 32-bit scalar target, but avoid UB on a 0-bit
    // type and keep the cost model silent beyond the 64-bit scalars we
    // reason about.
    if (BitSize == 0 || BitSize > 64)
      return TTI::TCC_Free;

    if (BitSize <= 32)
      return materializeCost32(Imm);

    // i33..i64 (e.g. an un-legalized i64 IR constant reaching
    // ConstantHoisting before SelectionDAG type-legalization splits it).
    // This is a direct restatement of what ARCISelDAGToDAG.cpp's *same*
    // ISD::Constant case will do independently to each 32-bit half once
    // legalization splits the i64 into two ConstantSDNodes -- not a
    // synthesis heuristic, just the arithmetic legalization already does.
    APInt Lo = Imm.trunc(32);
    APInt Hi = Imm.lshr(32).trunc(32);
    return materializeCost32(Lo) + materializeCost32(Hi);
  }

  // Mirrors ARCARCompactPatterns.td's constant-bit-position BSET/BCLR/
  // BXOR/BMSK patterns exactly (`bit_pos_hi`, `bclr_mask_hi`,
  // `bmsk_mask_hi` ImmLeafs, `Predicates = [IsARCompact], AddedComplexity
  // = 4`): a single-bit OR/XOR, single-bit-clear AND, or contiguous
  // low-bit-mask AND outside the s12 window still folds into ONE 4-byte
  // host instruction (u6 bit-index operand, no LIMM) instead of the
  // 8-byte `op B,B,limm` fallback. Without this, a value like `1<<21`
  // used by `x |= (1<<21)` was reported as a genuine 2-word
  // materialization cost by the s12-only check below, so
  // ConstantHoisting collected it as a hoisting candidate and rebased it
  // against a numerically-nearby but semantically-unrelated constant --
  // see the getIntImmCodeSizeCost comment above for the measured -Oz
  // firmware regression this contributed to (one folded BSET/BMSK turned into
  // base-materialize + LIMM-rebase-add + the original op on a register).
  static bool foldsViaBitOp(unsigned Opcode, const APInt &Imm) {
    if (Imm.getBitWidth() == 0 || Imm.getBitWidth() > 32)
      return false;
    uint32_t V = static_cast<uint32_t>(Imm.getZExtValue());
    switch (Opcode) {
    case Instruction::Or:
    case Instruction::Xor:
      // BSET_a_b_u6 / BXOR_a_b_u6: single set bit, u6 bit-index operand.
      return isPowerOf2_32(V) && V > 2047;
    case Instruction::And:
      // BCLR_a_b_u6: single CLEAR bit (~Imm is a single set bit).
      if (isPowerOf2_32(~V) && !isInt<12>(static_cast<int32_t>(V)))
        return true;
      // BMSK_a_b_u6: contiguous low-bit mask, excluding the extb/extw
      // widths (0xFF/0xFFFF have their own dedicated forms) and the
      // all-ones no-op.
      return V > 2047 && V != 0xFFFFu && V != 0xFFFFFFFFu && isMask_32(V);
    default:
      return false;
    }
  }

  InstructionCost
  getIntImmCostInst(unsigned Opcode, unsigned Idx, const APInt &Imm,
                    Type *Ty, TTI::TargetCostKind CostKind,
                    Instruction *Inst = nullptr) const override {
    // Below, TCC_Free is returned exactly where an ACTUAL DAG ISel Pat in
    // ARCInstrInfo.td folds the immediate into the host instruction (no
    // LIMM) -- never on the strength of an asm-only ARCAsmParser.cpp form,
    // and never for an ISA feature this subtarget doesn't have. Everything
    // else falls through to the real materialization cost, so
    // ConstantHoisting neither skips a genuinely expensive constant nor
    // wastes a hoist on one that was already free at its use.
    switch (Opcode) {
    case Instruction::GetElementPtr:
      // Never let ConstantHoisting touch a GEP index: CodeGenPrepare's
      // addressing-mode-aware index splitting is strictly better than
      // ConstantHoisting's whole-constant view (mirrors
      // RISCVTargetTransformInfo.cpp's identical GetElementPtr case).
      return TTI::TCC_Free;

    case Instruction::Add:
    case Instruction::Sub:
      // ADD_rrs12/SUB_rrs12 (ARCInstrInfo.td immS12NotU6 Pats) plus the u6
      // MultiPat forms together cover the full -2048..2047 window on
      // either operand. Sub also folds when the constant is the minuend
      // (C - x) via RSUB_rru6/RSUB_rrs12, so no Idx restriction is needed
      // for either opcode.
      if (Imm.isSignedIntN(12))
        return TTI::TCC_Free;
      break;

    case Instruction::And:
    case Instruction::Or:
    case Instruction::Xor:
      // Same u6/s12 MultiPat + immS12NotU6 shape as Add/Sub, either
      // operand (InstCombine canonicalizes the constant to the RHS before
      // ConstantHoisting runs, but the underlying Pat doesn't care which
      // side). Plus the BSET/BCLR/BXOR/BMSK constant-bit-position forms
      // (foldsViaBitOp) for the s12-window-missing single-bit/mask cases.
      if (Imm.isSignedIntN(12) || foldsViaBitOp(Opcode, Imm))
        return TTI::TCC_Free;
      break;

    case Instruction::ICmp:
      // CMP_ru6 (MultiPat) / CMP_rs12 (immS12NotU6 Pat): same -2048..2047
      // window.
      if (Imm.isSignedIntN(12))
        return TTI::TCC_Free;
      break;

    case Instruction::Shl:
    case Instruction::LShr:
    case Instruction::AShr:
      // Only the shift-amount operand (Idx == 1) folds, via the u6
      // MultiPat forms (ASL_rru6/LSR_rru6/ASR_rru6). Any well-defined i32
      // shift amount is 0..31, unconditionally inside the u6 (0..63)
      // window, so no isSignedIntN check is needed here -- just the
      // operand-index guard. Idx == 0 (the shifted value) never folds and
      // falls through to the base cost below.
      if (Idx == 1)
        return TTI::TCC_Free;
      break;

    case Instruction::Mul:
      // MPY_rru6/MPY_rrs12 exist only under `let Predicates = [HasMPY]`.
      // arc700/arc700eb have HasMPY=false (ARCSubtarget.h), so this case
      // is dead in practice on this subtarget: ISD::MUL is legalized to a
      // __mulsi3 libcall and the constant becomes an ordinary call
      // argument, never folded. The ST->hasMPY() guard is kept (not
      // simplified away) so the cost model stays honest if this backend
      // is ever reused for a HasMPY subtarget -- removing it would
      // silently claim a fold this subtarget's ISel cannot perform.
      if (ST->hasMPY() && Imm.isSignedIntN(12))
        return TTI::TCC_Free;
      break;

    default:
      break;
    }

    return getIntImmCost(Imm, Ty, CostKind);
  }

  // -----------------------------------------------------------------------
  // Zero-overhead hardware-loop (LP) profitability.
  //
  // Enables the generic llvm/lib/CodeGen/HardwareLoops.cpp IR pass for a
  // counted loop the pass has proven with SCEV. Gated behind the off-by-default
  // -arc-hardware-loops flag; see ARCTargetTransformInfo.cpp for the full
  // profitability bar and ARCEnableHardwareLoops() / ARCTargetMachine.cpp for
  // why it must stay off by default (interrupt trampolines do not preserve
  // LP_COUNT / LP_START / LP_END).
  bool isHardwareLoopProfitable(Loop *L, ScalarEvolution &SE,
                                AssumptionCache &AC, TargetLibraryInfo *LibInfo,
                                HardwareLoopInfo &HWLoopInfo) const override;

  // True if I is expected to lower to a bl (an ordinary call, an integer
  // multiply/divide libcall, a soft-float op, or a 64-bit-int libcall on
  // arc700). Such loops are rejected: LP_COUNT liveness across a call is
  // uncharacterized on this silicon and the interrupt-safety story (§4.4) is
  // not yet discharged for callees.
  bool maybeLoweredToCall(Instruction &I) const;

  InstructionCost
  getIntImmCostIntrin(Intrinsic::ID IID, unsigned Idx, const APInt &Imm,
                      Type *Ty, TTI::TargetCostKind CostKind) const override {
    // No ARC target intrinsic has an immediate operand whose encoding cost
    // differs from a generic call argument (the inherited
    // TargetTransformInfoImplBase default already returns TCC_Free here).
    // This override exists only to document that decision in one place --
    // it is the spot a future intrinsic-immediate rule would go.
    return TTI::TCC_Free;
  }
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_ARC_ARCTARGETTRANSFORMINFO_H
