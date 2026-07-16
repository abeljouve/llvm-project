//===- ARCISelLowering.cpp - ARC DAG Lowering Impl --------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the ARCTargetLowering class.
//
//===----------------------------------------------------------------------===//

#include "ARCISelLowering.h"
#include "ARC.h"
#include "ARCMachineFunctionInfo.h"
#include "ARCSelectionDAGInfo.h"
#include "ARCSubtarget.h"
#include "ARCTargetMachine.h"
#include "ARCTargetTransformInfo.h"
#include "MCTargetDesc/ARCInfo.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"
#include <algorithm>
#include <optional>

#define DEBUG_TYPE "arc-lower"

using namespace llvm;

static SDValue lowerCallResult(SDValue Chain, SDValue InGlue,
                               const SmallVectorImpl<CCValAssign> &RVLocs,
                               SDLoc dl, SelectionDAG &DAG,
                               SmallVectorImpl<SDValue> &InVals);

static ARCCC::CondCode ISDCCtoARCCC(ISD::CondCode isdCC) {
  switch (isdCC) {
  case ISD::SETUEQ:
    return ARCCC::EQ;
  case ISD::SETUGT:
    return ARCCC::HI;
  case ISD::SETUGE:
    return ARCCC::HS;
  case ISD::SETULT:
    return ARCCC::LO;
  case ISD::SETULE:
    return ARCCC::LS;
  case ISD::SETUNE:
    return ARCCC::NE;
  case ISD::SETEQ:
    return ARCCC::EQ;
  case ISD::SETGT:
    return ARCCC::GT;
  case ISD::SETGE:
    return ARCCC::GE;
  case ISD::SETLT:
    return ARCCC::LT;
  case ISD::SETLE:
    return ARCCC::LE;
  case ISD::SETNE:
    return ARCCC::NE;
  default:
    llvm_unreachable("Unhandled ISDCC code.");
  }
}

void ARCTargetLowering::ReplaceNodeResults(SDNode *N,
                                           SmallVectorImpl<SDValue> &Results,
                                           SelectionDAG &DAG) const {
  LLVM_DEBUG(dbgs() << "[ARC-ISEL] ReplaceNodeResults ");
  LLVM_DEBUG(N->dump(&DAG));
  LLVM_DEBUG(dbgs() << "; use_count=" << N->use_size() << "\n");

  switch (N->getOpcode()) {
  case ISD::READCYCLECOUNTER:
    if (N->getValueType(0) == MVT::i64) {
      // We read the TIMER0 and zero-extend it to 64-bits as the intrinsic
      // requires.
      SDValue V =
          DAG.getNode(ISD::READCYCLECOUNTER, SDLoc(N),
                      DAG.getVTList(MVT::i32, MVT::Other), N->getOperand(0));
      SDValue Op = DAG.getNode(ISD::ZERO_EXTEND, SDLoc(N), MVT::i64, V);
      Results.push_back(Op);
      Results.push_back(V.getValue(1));
    }
    break;
  default:
    break;
  }
}

ARCTargetLowering::ARCTargetLowering(const TargetMachine &TM,
                                     const ARCSubtarget &Subtarget)
    : TargetLowering(TM, Subtarget), Subtarget(Subtarget) {
  // Set up the register classes.
  addRegisterClass(MVT::i32, &ARC::GPR32RegClass);

  // Compute derived properties from the register classes
  computeRegisterProperties(Subtarget.getRegisterInfo());

  setStackPointerRegisterToSaveRestore(ARC::SP);

  setSchedulingPreference(Sched::Source);

  // Bounded scaled-add synthesis for `mul x, C` on cores without a hardware
  // multiplier -- see performMULCombine / synthesizeConstMul below and
  // docs/llvm-arc700-optimizations/02-constant-multiplication.md. Registered
  // unconditionally; the per-node handler itself gates on
  // !Subtarget.hasMPY() so this is a no-op when MUL is Legal.
  setTargetDAGCombine(ISD::MUL);

  // Constant-divisor unsigned div/rem synthesis (dossier 18) -- see
  // performUDivRemCombine / performURemDigitFoldCombine below. Registered
  // unconditionally, same shape as the MUL combine above; the per-node
  // handlers gate on !Subtarget.hasMPY() and their respective divisor
  // whitelists. Deliberately DAGCombines, not setOperationAction(Custom) --
  // see the .cpp section header comment for why marking UDIV/UREM Custom
  // would corrupt TargetLowering::expandREM's legality checks for
  // non-whitelisted divisors.
  setTargetDAGCombine(ISD::UDIV);
  setTargetDAGCombine(ISD::UREM);

  // Constant-divisor SIGNED div/rem synthesis (dossier 18, SIGNED phase) --
  // see performSDivRemCombine below. Same architecture/rationale as the
  // UDIV/UREM registration above: a pure DAGCombine, never setOperationAction
  // (Custom), so it cannot corrupt TargetLowering's legality checks for
  // sibling, non-whitelisted SDIV/SREM nodes.
  setTargetDAGCombine(ISD::SDIV);
  setTargetDAGCombine(ISD::SREM);

  // Overflow-to-branch/select fusion -- docs/llvm-arc700-optimizations/
  // 19-flag-consuming-arithmetic-idioms.md and performOverflowBrcondCombine/
  // performOverflowSelectCombine below. Fires at Level::BeforeLegalizeTypes,
  // strictly before BRCOND/SELECT's generic Expand and before
  // LowerUADDO/LowerUSUBO's own Custom-lowering ever run, so it can
  // intercept the raw generic ISD::UADDO/USUBO overflow result before the
  // value-materializing fallback path is even constructed.
  setTargetDAGCombine(ISD::BRCOND);
  setTargetDAGCombine(ISD::SELECT);

  // Carry-chain fusions (i64<<1, bit-reverse step) -- docs/llvm-arc700-
  // optimizations/24-carry-chain-and-bit-serial-idioms.md. Both shapes
  // surface as an ISD::OR after (for i64<<1) type legalization splits the
  // 64-bit shift, or (for the bit-reverse step) ordinary i32 front-end
  // codegen; performShl64By1Combine / performBitRevStepCombine below try
  // each exact shape in turn and decline cleanly on any mismatch.
  setTargetDAGCombine(ISD::OR);

  // Use i32 for setcc operations results (slt, sgt, ...).
  setBooleanContents(ZeroOrOneBooleanContent);
  setBooleanVectorContents(ZeroOrOneBooleanContent);

  for (unsigned Opc = 0; Opc < ISD::BUILTIN_OP_END; ++Opc)
    setOperationAction(Opc, MVT::i32, Expand);

  // Operations to get us off of the ground.
  // Basic.
  setOperationAction(ISD::ADD, MVT::i32, Legal);
  setOperationAction(ISD::SUB, MVT::i32, Legal);
  setOperationAction(ISD::AND, MVT::i32, Legal);
  setOperationAction(ISD::SMAX, MVT::i32, Legal);
  setOperationAction(ISD::SMIN, MVT::i32, Legal);

  setOperationAction(ISD::ADDC, MVT::i32, Legal);
  setOperationAction(ISD::ADDE, MVT::i32, Legal);
  setOperationAction(ISD::SUBC, MVT::i32, Legal);
  setOperationAction(ISD::SUBE, MVT::i32, Legal);

  // Need barrel shifter.
  setOperationAction(ISD::SHL, MVT::i32, Legal);
  setOperationAction(ISD::SRA, MVT::i32, Legal);
  setOperationAction(ISD::SRL, MVT::i32, Legal);
  setOperationAction(ISD::ROTR, MVT::i32, Legal);

  // SWAPE (the ARCompact full-32-bit byte-reversal instruction) has NO
  // encoding on ARC700 / BCM55030 -- it is an ARCv2-only opcode that this
  // silicon does not implement (confirmed by silicon characterization, see
  // docs/notes/isa-characterization.md). BSWAP must therefore never select
  // ARC_SWAPE_b_c on this profile. We Custom-lower ISD::BSWAP to a
  // mask/shift/or halfword-lane swap followed by ISD::ROTR by 16, which
  // reaches ISel already in Legal form and selects the existing `swap`
  // (halfword-exchange) instruction -- itself a real, present ARC700
  // instruction, unrelated to and unaffected by the absent SWAPE. The
  // bswap->SWAPE Pat in ARCARCompactPatterns.td is gated behind the
  // off-by-default HasSwape predicate so it can never fire here; it exists
  // only for a hypothetical future ARCv2-word CPU that genuinely has swape.
  //
  // ABS executes on this silicon (wrapping, non-saturating: ABS(INT_MIN) ==
  // INT_MIN) and keeps its single-instruction Legal lowering + Pat below.
  setOperationAction(ISD::BSWAP, MVT::i32, Custom);
  setOperationAction(ISD::ABS, MVT::i32, Legal);

  setOperationAction(ISD::Constant, MVT::i32, Legal);
  setOperationAction(ISD::UNDEF, MVT::i32, Legal);

  // 32x32 multiply is an optional extension. On ARC700 cores without
  // MULTIPLY_BUILD (reads 0 on such cores), mul/mulhs/mulhu must lower to
  // compiler-rt libcalls — __mulsi3, __mulhisi3 (MULHS i16→i32), and the
  // 64-bit helpers via LibCallLoweringInfo. Using LibCall here keeps the
  // legalizer away from mpy/mpym/mpymu which the backend can no longer
  // select once the TableGen patterns are gated behind HasMPY.
  if (Subtarget.hasMPY()) {
    setOperationAction(ISD::MUL, MVT::i32, Legal);
    setOperationAction(ISD::MULHS, MVT::i32, Legal);
    setOperationAction(ISD::MULHU, MVT::i32, Legal);
  } else {
    setOperationAction(ISD::MUL, MVT::i32, LibCall);
    setOperationAction(ISD::MULHS, MVT::i32, LibCall);
    setOperationAction(ISD::MULHU, MVT::i32, LibCall);
    // Also lower 64-bit multiply and SMUL_LOHI/UMUL_LOHI via libcalls.
    setOperationAction(ISD::SMUL_LOHI, MVT::i32, LibCall);
    setOperationAction(ISD::UMUL_LOHI, MVT::i32, LibCall);
  }
  // UDIV/UREM/SDIV/SREM are deliberately left at their default Expand action
  // for EVERY subtarget (never set to Custom/Legal/LibCall here) -- dossier
  // 18's constant-divisor synthesis (performUDivRemCombine /
  // performURemDigitFoldCombine for unsigned, performSDivRemCombine for
  // signed -- all registered as DAGCombines above) fires ahead of
  // legalization and needs no operation-action change; see those functions'
  // section header comment in this file for why marking UDIV/SDIV Custom
  // would be actively harmful (it corrupts TargetLowering::expandREM's
  // legality check for sibling, non-whitelisted UREM/SREM nodes). A
  // hardware-multiplier subtarget (hasMPY()) additionally gets a good
  // generic BuildSDIV/BuildUDIV reciprocal for free via the Expand path once
  // MULHS/MULHU is Legal (branch above) -- all three DAGCombines explicitly
  // decline whenever Subtarget.hasMPY(), so they never compete with it.
  setOperationAction(ISD::LOAD, MVT::i32, Legal);
  setOperationAction(ISD::STORE, MVT::i32, Legal);

  setOperationAction(ISD::SELECT_CC, MVT::i32, Custom);
  setOperationAction(ISD::BR_CC, MVT::i32, Custom);
  setOperationAction(ISD::BRCOND, MVT::Other, Expand);
  setOperationAction(ISD::BR_JT, MVT::Other, Expand);
  setOperationAction(ISD::JumpTable, MVT::i32, Custom);

  // Have pseudo instruction for frame addresses.
  setOperationAction(ISD::FRAMEADDR, MVT::i32, Legal);
  // Custom lower global addresses.
  setOperationAction(ISD::GlobalAddress, MVT::i32, Custom);
  // Custom lower constant pool entries — needed by the CTTZ de Bruijn
  // lookup-table expansion and by soft-float constants.
  setOperationAction(ISD::ConstantPool, MVT::i32, Custom);

  // Expand var-args ops.
  setOperationAction(ISD::VASTART, MVT::Other, Custom);
  setOperationAction(ISD::VAEND, MVT::Other, Expand);
  setOperationAction(ISD::VAARG, MVT::Other, Expand);
  setOperationAction(ISD::VACOPY, MVT::Other, Expand);

  // Other expansions
  setOperationAction(ISD::STACKSAVE, MVT::Other, Expand);
  setOperationAction(ISD::STACKRESTORE, MVT::Other, Expand);

  // Sign extend inreg
  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i1, Custom);

  // ARC700/ARCompact lacks sexb/sexh. Expand to shl+ashr pair so the
  // legalizer materialises the sign extension via plain shifts.
  if (!Subtarget.hasSEXT()) {
    setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i8, Expand);
    setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i16, Expand);
  }

  // CTLZ/CTTZ are Legal when the target has fls/ffs (ARCv2). ARCompact
  // (ARC600/ARC700) lacks bit-scan instructions, so we expand every
  // count-bits opcode to shift/or + popcount, and CTPOP itself to the
  // generic bit-twiddle sequence. This avoids a compiler-rt dependency
  // (no __clzsi2/__ctzsi2/__popcountsi2 libcall in the sysroot) and
  // matches what compiler_builtins would emit anyway.
  //
  // ConvertNodeToLibcall has no case for plain ISD::CTLZ, so a LibCall
  // action on that opcode is a trap — the node survives legalization
  // and reaches ISel as "Cannot select". Hence Expand for all four
  // and for CTPOP (whose default action is Legal).
  if (Subtarget.hasBitScan()) {
    setOperationAction(ISD::CTLZ, MVT::i32, Legal);
    setOperationAction(ISD::CTLZ_ZERO_UNDEF, MVT::i32, Legal);
    setOperationAction(ISD::CTTZ, MVT::i32, Legal);
    setOperationAction(ISD::CTTZ_ZERO_UNDEF, MVT::i32, Legal);
  } else {
    setOperationAction(ISD::CTLZ, MVT::i32, Expand);
    // CTLZ_ZERO_UNDEF escapes the default Expand path on some DAG shapes
    // (late-combiner insertions from overflow-check / non-zero
    // leading_zeros expansions in debug / opt-level=s Rust codegen).
    // Custom-lower to plain CTLZ which then Expand-legalizes to the
    // shift-OR + popcount bit-twiddle sequence.
    setOperationAction(ISD::CTLZ_ZERO_UNDEF, MVT::i32, Custom);
    setOperationAction(ISD::CTTZ, MVT::i32, Expand);
    setOperationAction(ISD::CTTZ_ZERO_UNDEF, MVT::i32, Custom);
    setOperationAction(ISD::CTPOP, MVT::i32, Expand);
  }

  // Carry/overflow-consuming arithmetic idioms -- docs/llvm-arc700-
  // optimizations/19-flag-consuming-arithmetic-idioms.md (cmp3 is separate/
  // later; everything else in that dossier is wired below).
  //
  // UADDSAT/USUBSAT are ordinary 1-result nodes with generic PatFrags already
  // defined upstream (TargetSelectionDAG.td) -- mirror the CTLZ/CTTZ precedent
  // just above: Legal + a pseudo whose embedded Pat is the bare generic node,
  // expanded pre-RA in ARCExpandPseudos into a `.f`-form ADD/SUB producer +
  // conditional-MOV consumer.
  setOperationAction(ISD::UADDSAT, MVT::i32, Legal);
  setOperationAction(ISD::USUBSAT, MVT::i32, Legal);
  // SADDSAT/SSUBSAT are the signed counterparts: same Legal + bare-pattern-
  // pseudo mechanism (upstream `saddsat`/`ssubsat` PatFrags), but the
  // consumer tests STATUS32.V (signed overflow, condition VS) instead of C,
  // and the clamp value is data-dependent (INT_MAX/INT_MIN keyed off the
  // sign of the first operand) rather than a fixed constant -- see
  // expandSADDSAT/expandSSUBSAT in ARCExpandPseudos.cpp.
  setOperationAction(ISD::SADDSAT, MVT::i32, Legal);
  setOperationAction(ISD::SSUBSAT, MVT::i32, Legal);
  // AVGFLOORU: exact unsigned floor((a+b)/2) over the true 33-bit sum,
  // correct across a 32-bit wrap. Same Legal + bare-pattern-pseudo shape
  // (upstream `avgflooru` PatFrag); the pseudo expands to add.f + rrc,
  // reusing the RRC infrastructure the carry-chain fusions below already
  // established. Formed by DAGCombiner::foldAddToAvg from the
  // `(a&b)+((a^b)>>1)` branchless-average idiom, NOT from a naive
  // `(a+b)>>1` (which is not equivalent -- see ARCARCompactPatterns.td).
  //
  // UNLIKE SADDSAT/SSUBSAT/SADDO/SSUBO above (which expand using only
  // baseline F32_DOP-format instructions with no ARCompact predicate),
  // expandAVGFLOORU's consumer is ARC_RRC_b_c -- an ARCompact-only encoding
  // (ARCompactInst32 base class hard-codes Predicates=[IsARCompact], see
  // ARCARCompactInstrFormats.td). `Predicates` only gates the TableGen
  // ISel matcher; it does NOT stop ARCExpandPseudos.cpp's manual BuildMI
  // from constructing the opcode directly, so an unconditional Legal here
  // would hard-crash a non-ARCompact subtarget at scheduling-info
  // resolution the same way an unguarded SHL64_1_PSEUDO/BITREV_STEP_PSEUDO
  // would (see the isARCompact() guard comment on
  // performShl64By1Combine/performBitRevStepCombine below). Gate on
  // Subtarget.isARCompact() so a non-ARCompact target keeps the default
  // Expand action (TargetLoweringBase's generic TLI.expandAVG lowering,
  // baseline ops only).
  if (Subtarget.isARCompact())
    setOperationAction(ISD::AVGFLOORU, MVT::i32, Legal);
  // UMIN/UMAX are left to the generic Expand (CMP + SELECT_CC -> ARCISD::CMOV).
  // A dedicated Legal CMP+MOV_cc pseudo was measured to REGRESS real firmware
  // .text: marking them Legal makes DAGCombiner canonicalize more
  // select/compare shapes into umin/umax, and the tied-operand conditional-MOV
  // pseudo blocks folds the generic SELECT_CC path still gets -- a net size
  // loss with no correctness benefit here (both forms are CMP + conditional
  // MOV). Keep them Expand.
  //
  // UADDO/USUBO are 2-result nodes with no generic PatFrag upstream. Custom:
  // when the overflow result feeds a branch/select it is rewritten to a native
  // unsigned compare-branch/select by performOverflowBrcondCombine /
  // performOverflowSelectCombine (below); otherwise it Custom-lowers to a
  // 2-result ARCISD::UADDO/USUBO node (LowerUADDO/LowerUSUBO) that a Pat
  // matches into the value-materializing pseudo.
  setOperationAction(ISD::UADDO, MVT::i32, Custom);
  setOperationAction(ISD::USUBO, MVT::i32, Custom);
  // SADDO/SSUBO: same 2-result-node Custom-lowering shape as UADDO/USUBO
  // (LowerSADDO/LowerSSUBO build ARCISD::SADDO/SSUBO), but deliberately NOT
  // fed into performOverflowBrcondCombine/performOverflowSelectCombine -- see
  // the comment above performOverflowBrcondCombine's declaration in
  // ARCISelLowering.h for why the unsigned fusion does not generalize to
  // signed overflow. A branch/select on SADDO/SSUBO's overflow bit always
  // takes the value-materializing path (mov.vs boolean) below.
  setOperationAction(ISD::SADDO, MVT::i32, Custom);
  setOperationAction(ISD::SSUBO, MVT::i32, Custom);

  setOperationAction(ISD::READCYCLECOUNTER, MVT::i32, Legal);
  setOperationAction(ISD::READCYCLECOUNTER, MVT::i64,
                     isTypeLegal(MVT::i64) ? Legal : Custom);

  setMaxAtomicSizeInBitsSupported(0);

  // Inline fixed-size memcpy/memset/memmove as ld/st runs instead of calling
  // the compiler-rt helpers. ARC700 has 32-bit word load/store only, so each
  // store covers up to 4 bytes; 16 stores inlines an aligned 64-byte copy. The
  // base defaults (8 / 4) collapse every copy >32B (>16B at -Oz) to a `bl`.
  MaxStoresPerMemcpy = 16;
  MaxStoresPerMemcpyOptSize = 8;
  MaxStoresPerMemset = 16;
  MaxStoresPerMemsetOptSize = 8;
  MaxStoresPerMemmove = 16;
  MaxStoresPerMemmoveOptSize = 8;
}

//===----------------------------------------------------------------------===//
//  Misc Lower Operation implementation
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Inline assembly constraint handling
//===----------------------------------------------------------------------===//

TargetLowering::ConstraintType
ARCTargetLowering::getConstraintType(StringRef Constraint) const {
  if (Constraint.size() == 1) {
    switch (Constraint[0]) {
    case 'r':
      return C_RegisterClass;
    default:
      break;
    }
  }
  return TargetLowering::getConstraintType(Constraint);
}

std::pair<unsigned, const TargetRegisterClass *>
ARCTargetLowering::getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                                                 StringRef Constraint,
                                                 MVT VT) const {
  if (Constraint.size() == 1 && Constraint[0] == 'r')
    return std::make_pair(0U, &ARC::GPR32RegClass);

  return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
}

// Recognize a mask operand of `(and X, mask)` that BTST can test directly:
// either a compile-time power-of-2 (bit position = log2(mask), fits the u6
// immediate form since bit positions are always 0-31) or `(shl 1, reg)` (bit
// position held in a register, the ARC_BTST_b_c form). Mirrors the shapes
// already matched by the BSET/BCLR/BXOR/BMSK Pats in
// ARCARCompactPatterns.td -- see pow2_mask there.
static bool isRecognizedBitTestMask(SDValue Mask) {
  if (ConstantSDNode *C = dyn_cast<ConstantSDNode>(Mask)) {
    uint64_t Imm = C->getZExtValue();
    return Imm > 0 && isPowerOf2_64(Imm) && isUInt<32>(Imm);
  }
  if (Mask.getOpcode() == ISD::SHL) {
    ConstantSDNode *One = dyn_cast<ConstantSDNode>(Mask.getOperand(0));
    return One && One->getZExtValue() == 1;
  }
  return false;
}

// Flag-recycling compare recognition (dossier 21 idea 3). Both helpers gate
// on the SAME LIMM-sized threshold that ARCARCompactPatterns.td's
// bit_pos_hi/bmsk_mask_hi ImmLeafs use (constant > 2047, i.e. it does not
// fit the 12-bit signed compare/mov forms and would otherwise cost an
// 8-byte LIMM). Duplicated here rather than shared across the .cpp/.td
// boundary -- no existing precedent for that in this backend;
// isRecognizedBitTestMask above duplicates ISA shape logic the same way.
// Keep the two boundaries in sync if either threshold ever changes.

// `x <u 2^K` (K in [11,31]): true only when the compared power-of-2 needs a
// LIMM. All arithmetic is on uint32_t (never a host signed shift).
static bool isRangeTestPow2(SDValue RHS, unsigned &K) {
  ConstantSDNode *RHSC = dyn_cast<ConstantSDNode>(RHS);
  if (!RHSC || !isUInt<32>(RHSC->getZExtValue()))
    return false;
  uint32_t V = static_cast<uint32_t>(RHSC->getZExtValue());
  if (!isPowerOf2_32(V) || V <= 2047)
    return false;
  K = Log2_32(V);
  return true;
}

// `(x & (2^(K+1)-1)) == 0`: true only when the low-bit mask needs a LIMM.
// Mirrors bmsk_mask_hi's guard exactly (excludes the extb/extw widths and
// the all-ones no-op -- see ARCARCompactPatterns.td) so the two dossiers
// (16 and 21-idea-3) never disagree about which masks are LIMM-sized.
static bool isMaskZeroTest(SDValue Mask, unsigned &K) {
  ConstantSDNode *MaskC = dyn_cast<ConstantSDNode>(Mask);
  if (!MaskC || !isUInt<32>(MaskC->getZExtValue()))
    return false;
  uint32_t M = static_cast<uint32_t>(MaskC->getZExtValue());
  if (M <= 2047 || M == 0xFFFFu || M == 0xFFFFFFFFu || !isMask_32(M))
    return false;
  K = Log2_32(M + 1) - 1;
  return true;
}

// Shift-amount operand of an already-canonicalized `(x >> K) == 0` shape
// (see the range-test comment at the LowerSELECT_CC call site below for why
// this shape, not the raw `x <u 2^K` SETULT/SETUGE one, is what is actually
// reached in practice): true only when K is a valid in-range shift amount
// (< 32, so the shift itself is defined) AND 2^K needs a LIMM (K >= 11,
// i.e. 2^11 = 2048 is the first power of two that doesn't fit a 12-bit
// signed compare/mov immediate). Comparing K directly against 11 avoids
// ever materializing 1u32<<K on the host.
static bool isRangeTestShift(SDValue ShAmt, unsigned &K) {
  ConstantSDNode *C = dyn_cast<ConstantSDNode>(ShAmt);
  if (!C)
    return false;
  uint64_t KV = C->getZExtValue();
  if (KV >= 32)
    return false;
  K = static_cast<unsigned>(KV);
  return K >= 11;
}

// `X & (1<<N)` is canonicalized by the generic (target-independent)
// SelectionDAG combiner into `(X >> N) & 1` well before LowerSELECT_CC runs
// -- confirmed empirically: even hand-written IR with the literal
// `and(x, shl(1,n))` shape reaches this lowering as `and(srl(x,n), 1)`.
// Left alone, that means the `(shl 1, GPR32:$n)` register-form BTST Pat
// above is unreachable from ordinary C, and the constant-N case pays for an
// extra `lsr` that a direct `btst X, N` doesn't need. Peel through the SRL
// here so the value tested and the bit position both refer back to the
// pre-shift X:
//   - N constant (< 32): rewrite to (X, 1<<N) -- compile-time pow2 mask on
//     the ORIGINAL value, selects the single-instruction u6 form.
//   - N variable: rewrite to (X, (shl 1, N)) -- hits the existing
//     register-form Pat, selecting `btst X, N` with no shift at all.
// Doesn't require the SRL to be single-use: if `(X>>N)` is also needed for
// something else it is still emitted for that other use: we simply stop
// depending on it for the compare, which is a strict win either way.
// N>=32 is not specially handled: `lshr i32 %x, %n` is poison for
// %n>=32 per LLVM IR semantics (the existing `(shl 1, GPR32:$n)` Pat above
// already relies on the identical poison-for-out-of-range-shift contract),
// so the compiler is free to pick any behavior there; ARC's hardware BTST
// register form masks C to 5 bits internally (`a & (1u32 << (b & 31))`,
// confirmed against the emulator ALU model), same masking LSR itself uses
// for in-range shifts.
static void getBitTestOperands(SDValue LHS, SDValue &TestVal, SDValue &Mask,
                                SelectionDAG &DAG, const SDLoc &dl) {
  TestVal = LHS.getOperand(0);
  Mask = LHS.getOperand(1);
  if (TestVal.getOpcode() != ISD::SRL)
    return;
  ConstantSDNode *MaskC = dyn_cast<ConstantSDNode>(Mask);
  if (!MaskC || MaskC->getZExtValue() != 1)
    return;
  SDValue N = TestVal.getOperand(1);
  SDValue X = TestVal.getOperand(0);
  if (ConstantSDNode *NC = dyn_cast<ConstantSDNode>(N)) {
    if (NC->getZExtValue() < 32) {
      TestVal = X;
      Mask = DAG.getConstant(1u << NC->getZExtValue(), dl, MVT::i32);
    }
    return;
  }
  if (N.getValueType() != MVT::i32)
    return;
  TestVal = X;
  Mask = DAG.getNode(ISD::SHL, dl, MVT::i32, DAG.getConstant(1, dl, MVT::i32),
                     N);
}

SDValue ARCTargetLowering::LowerSELECT_CC(SDValue Op, SelectionDAG &DAG) const {
  SDValue LHS = Op.getOperand(0);
  SDValue RHS = Op.getOperand(1);
  ISD::CondCode CC = cast<CondCodeSDNode>(Op.getOperand(4))->get();
  SDValue TVal = Op.getOperand(2);
  SDValue FVal = Op.getOperand(3);
  SDLoc dl(Op);
  ARCCC::CondCode ArcCC = ISDCCtoARCCC(CC);
  assert(LHS.getValueType() == MVT::i32 && "Only know how to SELECT_CC i32");

  // Bit-test fold (dossier 24): `(x & mask) ==/!= 0 ? T : F` selects to a
  // single `btst` instead of `mov`-mask + `and` + `cmp`. Restricted to
  // SETEQ/SETNE against a zero RHS -- BTST's N/C/V beyond Z are unproven
  // equivalent to a SUB-based CMP-vs-0 (see isa-characterization.md 5.4 and
  // dossier 24), so this must never generalize to other condition codes.
  // Only ARCompact subtargets encode BTST at all; emitting ARCISD::BTST
  // without a matching Predicates=[IsARCompact] Pat is a hard "cannot
  // select" ISel crash, not a soft fallback -- gate on isARCompact()
  // explicitly rather than relying on the Pat predicate alone.
  if (Subtarget.isARCompact() && (CC == ISD::SETEQ || CC == ISD::SETNE) &&
      LHS.getOpcode() == ISD::AND && LHS.hasOneUse()) {
    if (ConstantSDNode *RHSC = dyn_cast<ConstantSDNode>(RHS)) {
      if (RHSC->isZero()) {
        SDValue TestVal, Mask;
        getBitTestOperands(LHS, TestVal, Mask, DAG, dl);
        if (isRecognizedBitTestMask(Mask)) {
          SDValue Btst =
              DAG.getNode(ARCISD::BTST, dl, MVT::Glue, TestVal, Mask);
          return DAG.getNode(ARCISD::CMOV, dl, TVal.getValueType(), TVal,
                             FVal, DAG.getConstant(ArcCC, dl, MVT::i32),
                             Btst);
        }
      }
    }
  }

  // Unsigned range test (dossier 21 idea 3), raw shape: `x <u 2^K ? T : F`
  // directly as SETULT/SETUGE against a power-of-two RHS. In PRACTICE the
  // generic (target-independent) SelectionDAG combiner canonicalizes this
  // into `(x>>K) == 0 ? T : F` (SETEQ/SETNE against a shifted value) well
  // before this lowering runs -- confirmed empirically, even at -O0 --
  // exactly the same kind of canonicalization documented for the BTST fold
  // above, so the block below (inside the SETEQ/SETNE section) is the one
  // that actually fires for ordinary IR. This raw-shape block is kept as a
  // defensive fallback in case some other path (e.g. extra uses blocking
  // the combine, mirroring how the BTST fold's raw-AND shape stays
  // reachable via @bit_test_reg_pos in arc700eb-btst.ll) reaches Custom
  // lowering without going through that combine. Predicate-exact for
  // SETULT/SETUGE ONLY -- (x>>K)==0 is equivalent to `x <u 2^K` for the
  // UNSIGNED predicate alone; a signed compare against the same power-of-two
  // constant falls through to the materialized-operand CMP path below,
  // untouched.
  if (Subtarget.isARCompact() && (CC == ISD::SETULT || CC == ISD::SETUGE)) {
    unsigned K;
    if (isRangeTestPow2(RHS, K)) {
      SDValue Test = DAG.getNode(ARCISD::LSRTEST, dl, MVT::Glue, LHS,
                                 DAG.getConstant(K, dl, MVT::i32));
      // (x>>K)==0 is the ult predicate directly (Z=1 -> EQ); SETUGE is its
      // negation (Z=0 -> NE). Do NOT reuse ISDCCtoARCCC/ArcCC here -- LO/HS
      // are meaningless against a Z-only glue produced by a shift, not a
      // subtract-based compare.
      ARCCC::CondCode FlagCC = (CC == ISD::SETULT) ? ARCCC::EQ : ARCCC::NE;
      return DAG.getNode(ARCISD::CMOV, dl, TVal.getValueType(), TVal, FVal,
                         DAG.getConstant(FlagCC, dl, MVT::i32), Test);
    }
  }

  // Low-mask zero test AND canonicalized range test (dossier 21 idea 3):
  // both `(x & (2^(K+1)-1)) == 0 ? T : F` and the ALREADY-CANONICALIZED
  // `(x>>K) == 0 ? T : F` (see the raw-shape comment above -- this is the
  // shape ordinary `icmp ult`/`icmp uge` IR actually reaches here as)
  // select to a single null-destination flag op (`bmsk.f` / `lsr.f`)
  // instead of an 8-byte LIMM mask/compare. EQ/NE only, same restriction as
  // the BTST fold above (and for the same reason: only Z is proven
  // equivalent to the SUB-based CMP-vs-0 this replaces). The flag polarity
  // is unchanged from the source predicate in EITHER sub-case, so ArcCC
  // (already an EQ/NE-mapped code) is reused as-is -- mirrors the BTST
  // fold's CC reuse.
  if (Subtarget.isARCompact() && (CC == ISD::SETEQ || CC == ISD::SETNE) &&
      LHS.hasOneUse()) {
    if (ConstantSDNode *RHSC = dyn_cast<ConstantSDNode>(RHS)) {
      if (RHSC->isZero()) {
        if (LHS.getOpcode() == ISD::AND) {
          unsigned K;
          if (isMaskZeroTest(LHS.getOperand(1), K)) {
            SDValue Test = DAG.getNode(ARCISD::BMSKTEST, dl, MVT::Glue,
                                       LHS.getOperand(0),
                                       DAG.getConstant(K, dl, MVT::i32));
            return DAG.getNode(ARCISD::CMOV, dl, TVal.getValueType(), TVal,
                               FVal, DAG.getConstant(ArcCC, dl, MVT::i32),
                               Test);
          }
        } else if (LHS.getOpcode() == ISD::SRL) {
          unsigned K;
          if (isRangeTestShift(LHS.getOperand(1), K)) {
            SDValue Test = DAG.getNode(ARCISD::LSRTEST, dl, MVT::Glue,
                                       LHS.getOperand(0),
                                       DAG.getConstant(K, dl, MVT::i32));
            return DAG.getNode(ARCISD::CMOV, dl, TVal.getValueType(), TVal,
                               FVal, DAG.getConstant(ArcCC, dl, MVT::i32),
                               Test);
          }
        }
      }
    }
  }

  SDValue Cmp = DAG.getNode(ARCISD::CMP, dl, MVT::Glue, LHS, RHS);
  return DAG.getNode(ARCISD::CMOV, dl, TVal.getValueType(), TVal, FVal,
                     DAG.getConstant(ArcCC, dl, MVT::i32), Cmp);
}

SDValue ARCTargetLowering::LowerSIGN_EXTEND_INREG(SDValue Op,
                                                  SelectionDAG &DAG) const {
  SDValue Op0 = Op.getOperand(0);
  SDLoc dl(Op);
  assert(Op.getValueType() == MVT::i32 &&
         "Unhandled target sign_extend_inreg.");
  // These are legal
  unsigned Width = cast<VTSDNode>(Op.getOperand(1))->getVT().getSizeInBits();
  if (Width == 16 || Width == 8)
    return Op;
  if (Width >= 32) {
    return {};
  }
  SDValue LS = DAG.getNode(ISD::SHL, dl, MVT::i32, Op0,
                           DAG.getConstant(32 - Width, dl, MVT::i32));
  SDValue SR = DAG.getNode(ISD::SRA, dl, MVT::i32, LS,
                           DAG.getConstant(32 - Width, dl, MVT::i32));
  return SR;
}

SDValue ARCTargetLowering::LowerBSWAP(SDValue Op, SelectionDAG &DAG) const {
  SDLoc dl(Op);
  EVT VT = Op.getValueType();
  assert(VT == MVT::i32 && "Only know how to BSWAP i32");
  SDValue X = Op.getOperand(0);
  SDValue Mask = DAG.getConstant(0x00FF00FFU, dl, VT);
  EVT ShVT = getShiftAmountTy(VT, DAG.getDataLayout());
  // t = ((x & 0x00FF00FF) << 8) | ((x >> 8) & 0x00FF00FF)
  // This swaps byte 0<->1 and byte 2<->3 within each halfword lane.
  SDValue Lo = DAG.getNode(ISD::SHL, dl, VT,
                           DAG.getNode(ISD::AND, dl, VT, X, Mask),
                           DAG.getConstant(8, dl, ShVT));
  SDValue Hi = DAG.getNode(ISD::AND, dl, VT,
                           DAG.getNode(ISD::SRL, dl, VT, X,
                                       DAG.getConstant(8, dl, ShVT)),
                           Mask);
  SDValue T = DAG.getNode(ISD::OR, dl, VT, Lo, Hi);
  // bswap(x) = SWAP(t) -- exchange the two halfword lanes. ISD::ROTR by 16
  // is Legal (set above) and the existing
  // Pat<(rotr GPR32:$c, (i32 16)), (ARC_SWAP_b_c GPR32:$c)> in
  // ARCARCompactPatterns.td selects it directly to the real ARC700 `swap`
  // instruction. Do NOT use ROTL here: it is not marked Legal (falls
  // through the blanket Expand set at the top of this constructor) and
  // would re-enter legalization instead of hitting the SWAP Pat.
  return DAG.getNode(ISD::ROTR, dl, VT, T, DAG.getConstant(16, dl, ShVT));
}

SDValue ARCTargetLowering::LowerUADDO(SDValue Op, SelectionDAG &DAG) const {
  SDLoc dl(Op);
  assert(Op.getValueType() == MVT::i32 && "Only know how to lower i32 UADDO");
  SDValue A = Op.getOperand(0);
  SDValue B = Op.getOperand(1);
  // 2-result target node; the legalizer (LegalizeDAG.cpp's multi-result
  // Custom-lowering path) pulls Res.getValue(1) out for the overflow
  // result on its own, so returning the SDValue (result #0) is sufficient.
  return DAG.getNode(ARCISD::UADDO, dl, DAG.getVTList(MVT::i32, MVT::i32), A,
                     B);
}

SDValue ARCTargetLowering::LowerUSUBO(SDValue Op, SelectionDAG &DAG) const {
  SDLoc dl(Op);
  assert(Op.getValueType() == MVT::i32 && "Only know how to lower i32 USUBO");
  SDValue A = Op.getOperand(0);
  SDValue B = Op.getOperand(1);
  return DAG.getNode(ARCISD::USUBO, dl, DAG.getVTList(MVT::i32, MVT::i32), A,
                     B);
}

SDValue ARCTargetLowering::LowerSADDO(SDValue Op, SelectionDAG &DAG) const {
  SDLoc dl(Op);
  assert(Op.getValueType() == MVT::i32 && "Only know how to lower i32 SADDO");
  SDValue A = Op.getOperand(0);
  SDValue B = Op.getOperand(1);
  // 2-result target node; the legalizer pulls Res.getValue(1) out for the
  // overflow result on its own, same as LowerUADDO above.
  return DAG.getNode(ARCISD::SADDO, dl, DAG.getVTList(MVT::i32, MVT::i32), A,
                     B);
}

SDValue ARCTargetLowering::LowerSSUBO(SDValue Op, SelectionDAG &DAG) const {
  SDLoc dl(Op);
  assert(Op.getValueType() == MVT::i32 && "Only know how to lower i32 SSUBO");
  SDValue A = Op.getOperand(0);
  SDValue B = Op.getOperand(1);
  return DAG.getNode(ARCISD::SSUBO, dl, DAG.getVTList(MVT::i32, MVT::i32), A,
                     B);
}

SDValue ARCTargetLowering::LowerBR_CC(SDValue Op, SelectionDAG &DAG) const {
  SDValue Chain = Op.getOperand(0);
  ISD::CondCode CC = cast<CondCodeSDNode>(Op.getOperand(1))->get();
  SDValue LHS = Op.getOperand(2);
  SDValue RHS = Op.getOperand(3);
  SDValue Dest = Op.getOperand(4);
  SDLoc dl(Op);

  ARCCC::CondCode arcCC = ISDCCtoARCCC(CC);
  assert(LHS.getValueType() == MVT::i32 && "Only know how to BR_CC i32");
  return DAG.getNode(ARCISD::BRcc, dl, MVT::Other, Chain, Dest, LHS, RHS,
                     DAG.getConstant(arcCC, dl, MVT::i32));
}

SDValue ARCTargetLowering::LowerJumpTable(SDValue Op, SelectionDAG &DAG) const {
  auto *N = cast<JumpTableSDNode>(Op);
  SDValue GA = DAG.getTargetJumpTable(N->getIndex(), MVT::i32);
  return DAG.getNode(ARCISD::GAWRAPPER, SDLoc(N), MVT::i32, GA);
}

#include "ARCGenCallingConv.inc"

//===----------------------------------------------------------------------===//
//                  Call Calling Convention Implementation
//===----------------------------------------------------------------------===//

/// ARC call implementation
SDValue ARCTargetLowering::LowerCall(TargetLowering::CallLoweringInfo &CLI,
                                     SmallVectorImpl<SDValue> &InVals) const {
  SelectionDAG &DAG = CLI.DAG;
  SDLoc &dl = CLI.DL;
  SmallVectorImpl<ISD::OutputArg> &Outs = CLI.Outs;
  SmallVectorImpl<SDValue> &OutVals = CLI.OutVals;
  SmallVectorImpl<ISD::InputArg> &Ins = CLI.Ins;
  SDValue Chain = CLI.Chain;
  SDValue Callee = CLI.Callee;
  CallingConv::ID CallConv = CLI.CallConv;
  bool IsVarArg = CLI.IsVarArg;
  bool &IsTailCall = CLI.IsTailCall;
  bool WantTail = IsTailCall; // frontend hint (call in tail position)
  IsTailCall = false;

  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), ArgLocs,
                 *DAG.getContext());

  CCInfo.AnalyzeCallOperands(Outs, CC_ARC);

  // Tail-call eligibility (conservative): direct call (GA/extsym) under the
  // C/Fast conv, no varargs, and every argument in a register (no outgoing
  // stack args). The frontend already gates WantTail on tail position + a
  // compatible return, so we trust it for the return contract. Indirect tail
  // calls and stack-arg tail calls are left as normal calls.
  bool CalleeIsDirect =
      isa<GlobalAddressSDNode>(Callee) || isa<ExternalSymbolSDNode>(Callee);
  if (WantTail && !IsVarArg && CalleeIsDirect &&
      (CallConv == CallingConv::C || CallConv == CallingConv::Fast)) {
    IsTailCall = true;
    for (const CCValAssign &VA : ArgLocs)
      if (!VA.isRegLoc()) {
        IsTailCall = false;
        break;
      }
  }

  SmallVector<CCValAssign, 16> RVLocs;
  // Analyze return values to determine the number of bytes of stack required.
  CCState RetCCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), RVLocs,
                    *DAG.getContext());
  RetCCInfo.AllocateStack(CCInfo.getStackSize(), Align(4));
  RetCCInfo.AnalyzeCallResult(Ins, RetCC_ARC);

  // Get a count of how many bytes are to be pushed on the stack.
  unsigned NumBytes = RetCCInfo.getStackSize();

  // A tail call has no outgoing stack args (eligibility required all-reg args)
  // and reuses the caller's frame, so no call-frame sequence is emitted.
  if (!IsTailCall)
    Chain = DAG.getCALLSEQ_START(Chain, NumBytes, 0, dl);

  SmallVector<std::pair<unsigned, SDValue>, 4> RegsToPass;
  SmallVector<SDValue, 12> MemOpChains;

  SDValue StackPtr;
  // Walk the register/memloc assignments, inserting copies/loads.
  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    CCValAssign &VA = ArgLocs[i];
    SDValue Arg = OutVals[i];

    // Promote the value if needed.
    switch (VA.getLocInfo()) {
    default:
      llvm_unreachable("Unknown loc info!");
    case CCValAssign::Full:
      break;
    case CCValAssign::SExt:
      Arg = DAG.getNode(ISD::SIGN_EXTEND, dl, VA.getLocVT(), Arg);
      break;
    case CCValAssign::ZExt:
      Arg = DAG.getNode(ISD::ZERO_EXTEND, dl, VA.getLocVT(), Arg);
      break;
    case CCValAssign::AExt:
      Arg = DAG.getNode(ISD::ANY_EXTEND, dl, VA.getLocVT(), Arg);
      break;
    }

    // Arguments that can be passed on register must be kept at
    // RegsToPass vector
    if (VA.isRegLoc()) {
      RegsToPass.push_back(std::make_pair(VA.getLocReg(), Arg));
    } else {
      assert(VA.isMemLoc() && "Must be register or memory argument.");
      if (!StackPtr.getNode())
        StackPtr = DAG.getCopyFromReg(Chain, dl, ARC::SP,
                                      getPointerTy(DAG.getDataLayout()));
      // Calculate the stack position.
      SDValue SOffset = DAG.getIntPtrConstant(VA.getLocMemOffset(), dl);
      SDValue PtrOff = DAG.getNode(
          ISD::ADD, dl, getPointerTy(DAG.getDataLayout()), StackPtr, SOffset);

      SDValue Store =
          DAG.getStore(Chain, dl, Arg, PtrOff, MachinePointerInfo());
      MemOpChains.push_back(Store);
      IsTailCall = false;
    }
  }

  // Transform all store nodes into one single node because
  // all store nodes are independent of each other.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, MemOpChains);

  // Build a sequence of copy-to-reg nodes chained together with token
  // chain and flag operands which copy the outgoing args into registers.
  // The Glue in necessary since all emitted instructions must be
  // stuck together.
  SDValue Glue;
  for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i) {
    Chain = DAG.getCopyToReg(Chain, dl, RegsToPass[i].first,
                             RegsToPass[i].second, Glue);
    Glue = Chain.getValue(1);
  }

  // If the callee is a GlobalAddress node (quite common, every direct call is)
  // turn it into a TargetGlobalAddress node so that legalize doesn't hack it.
  // Likewise ExternalSymbol -> TargetExternalSymbol.
  bool IsDirect = true;
  if (auto *G = dyn_cast<GlobalAddressSDNode>(Callee))
    Callee = DAG.getTargetGlobalAddress(G->getGlobal(), dl, MVT::i32);
  else if (auto *E = dyn_cast<ExternalSymbolSDNode>(Callee))
    Callee = DAG.getTargetExternalSymbol(E->getSymbol(), MVT::i32);
  else
    IsDirect = false;
  // Branch + Link = #chain, #target_address, #opt_in_flags...
  //             = Chain, Callee, Reg#1, Reg#2, ...
  //
  // Returns a chain & a glue for retval copy to use.
  SDVTList NodeTys = DAG.getVTList(MVT::Other, MVT::Glue);
  SmallVector<SDValue, 8> Ops;
  Ops.push_back(Chain);
  Ops.push_back(Callee);

  for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i)
    Ops.push_back(DAG.getRegister(RegsToPass[i].first,
                                  RegsToPass[i].second.getValueType()));

  // Add a register mask operand representing the call-preserved registers.
  const TargetRegisterInfo *TRI = Subtarget.getRegisterInfo();
  const uint32_t *Mask =
      TRI->getCallPreservedMask(DAG.getMachineFunction(), CallConv);
  assert(Mask && "Missing call preserved mask for calling convention");
  Ops.push_back(DAG.getRegisterMask(Mask));

  if (Glue.getNode())
    Ops.push_back(Glue);

  // Tail call: emit the terminator return-jump. PEI inserts the epilogue before
  // it (frame teardown); TCRETURN_di then expands to `mov r12,@callee; j[r12]`.
  // No CALLSEQ_END / result copy -- the callee returns straight to our caller.
  if (IsTailCall)
    return DAG.getNode(ARCISD::TC_RETURN, dl, MVT::Other, Ops);

  Chain = DAG.getNode(IsDirect ? ARCISD::BL : ARCISD::JL, dl, NodeTys, Ops);
  Glue = Chain.getValue(1);

  // Create the CALLSEQ_END node.
  Chain = DAG.getCALLSEQ_END(Chain, NumBytes, 0, Glue, dl);
  Glue = Chain.getValue(1);

  // Handle result values, copying them out of physregs into vregs that we
  // return.
  if (IsTailCall)
    return Chain;
  return lowerCallResult(Chain, Glue, RVLocs, dl, DAG, InVals);
}

/// Lower the result values of a call into the appropriate copies out of
/// physical registers / memory locations.
static SDValue lowerCallResult(SDValue Chain, SDValue Glue,
                               const SmallVectorImpl<CCValAssign> &RVLocs,
                               SDLoc dl, SelectionDAG &DAG,
                               SmallVectorImpl<SDValue> &InVals) {
  SmallVector<std::pair<int, unsigned>, 4> ResultMemLocs;
  // Copy results out of physical registers.
  for (unsigned i = 0, e = RVLocs.size(); i != e; ++i) {
    const CCValAssign &VA = RVLocs[i];
    if (VA.isRegLoc()) {
      SDValue RetValue;
      RetValue =
          DAG.getCopyFromReg(Chain, dl, VA.getLocReg(), VA.getValVT(), Glue);
      Chain = RetValue.getValue(1);
      Glue = RetValue.getValue(2);
      InVals.push_back(RetValue);
    } else {
      assert(VA.isMemLoc() && "Must be memory location.");
      ResultMemLocs.push_back(
          std::make_pair(VA.getLocMemOffset(), InVals.size()));

      // Reserve space for this result.
      InVals.push_back(SDValue());
    }
  }

  // Copy results out of memory.
  SmallVector<SDValue, 4> MemOpChains;
  for (unsigned i = 0, e = ResultMemLocs.size(); i != e; ++i) {
    int Offset = ResultMemLocs[i].first;
    unsigned Index = ResultMemLocs[i].second;
    SDValue StackPtr = DAG.getRegister(ARC::SP, MVT::i32);
    SDValue SpLoc = DAG.getNode(ISD::ADD, dl, MVT::i32, StackPtr,
                                DAG.getConstant(Offset, dl, MVT::i32));
    SDValue Load =
        DAG.getLoad(MVT::i32, dl, Chain, SpLoc, MachinePointerInfo());
    InVals[Index] = Load;
    MemOpChains.push_back(Load.getValue(1));
  }

  // Transform all loads nodes into one single node because
  // all load nodes are independent of each other.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, MemOpChains);

  return Chain;
}

//===----------------------------------------------------------------------===//
//             Formal Arguments Calling Convention Implementation
//===----------------------------------------------------------------------===//

namespace {

struct ArgDataPair {
  SDValue SDV;
  ISD::ArgFlagsTy Flags;
};

} // end anonymous namespace

/// ARC formal arguments implementation
SDValue ARCTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &dl,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {
  switch (CallConv) {
  default:
    llvm_unreachable("Unsupported calling convention");
  case CallingConv::C:
  case CallingConv::Fast:
    return LowerCallArguments(Chain, CallConv, IsVarArg, Ins, dl, DAG, InVals);
  }
}

/// Transform physical registers into virtual registers, and generate load
/// operations for argument places on the stack.
SDValue ARCTargetLowering::LowerCallArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, SDLoc dl, SelectionDAG &DAG,
    SmallVectorImpl<SDValue> &InVals) const {
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  MachineRegisterInfo &RegInfo = MF.getRegInfo();
  auto *AFI = MF.getInfo<ARCFunctionInfo>();

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), ArgLocs,
                 *DAG.getContext());

  CCInfo.AnalyzeFormalArguments(Ins, CC_ARC);

  unsigned StackSlotSize = 4;

  if (!IsVarArg)
    AFI->setReturnStackOffset(CCInfo.getStackSize());

  // All getCopyFromReg ops must precede any getMemcpys to prevent the
  // scheduler clobbering a register before it has been copied.
  // The stages are:
  // 1. CopyFromReg (and load) arg & vararg registers.
  // 2. Chain CopyFromReg nodes into a TokenFactor.
  // 3. Memcpy 'byVal' args & push final InVals.
  // 4. Chain mem ops nodes into a TokenFactor.
  SmallVector<SDValue, 4> CFRegNode;
  SmallVector<ArgDataPair, 4> ArgData;
  SmallVector<SDValue, 4> MemOps;

  // 1a. CopyFromReg (and load) arg registers.
  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    CCValAssign &VA = ArgLocs[i];
    SDValue ArgIn;

    if (VA.isRegLoc()) {
      // Arguments passed in registers
      EVT RegVT = VA.getLocVT();
      switch (RegVT.getSimpleVT().SimpleTy) {
      default: {
        LLVM_DEBUG(errs() << "LowerFormalArguments Unhandled argument type: "
                          << (unsigned)RegVT.getSimpleVT().SimpleTy << "\n");
        llvm_unreachable("Unhandled LowerFormalArguments type.");
      }
      case MVT::i32:
        unsigned VReg = RegInfo.createVirtualRegister(&ARC::GPR32RegClass);
        RegInfo.addLiveIn(VA.getLocReg(), VReg);
        ArgIn = DAG.getCopyFromReg(Chain, dl, VReg, RegVT);
        CFRegNode.push_back(ArgIn.getValue(ArgIn->getNumValues() - 1));
      }
    } else {
      // Only arguments passed on the stack should make it here.
      assert(VA.isMemLoc());
      // Load the argument to a virtual register
      unsigned ObjSize = VA.getLocVT().getStoreSize();
      assert((ObjSize <= StackSlotSize) && "Unhandled argument");

      // Create the frame index object for this incoming parameter...
      int FI = MFI.CreateFixedObject(ObjSize, VA.getLocMemOffset(), true);

      // Create the SelectionDAG nodes corresponding to a load
      // from this parameter
      SDValue FIN = DAG.getFrameIndex(FI, MVT::i32);
      ArgIn = DAG.getLoad(VA.getLocVT(), dl, Chain, FIN,
                          MachinePointerInfo::getFixedStack(MF, FI));
    }
    const ArgDataPair ADP = {ArgIn, Ins[i].Flags};
    ArgData.push_back(ADP);
  }

  // 1b. CopyFromReg vararg registers.
  if (IsVarArg) {
    // Argument registers
    static const MCPhysReg ArgRegs[] = {ARC::R0, ARC::R1, ARC::R2, ARC::R3,
                                        ARC::R4, ARC::R5, ARC::R6, ARC::R7};
    auto *AFI = MF.getInfo<ARCFunctionInfo>();
    unsigned FirstVAReg = CCInfo.getFirstUnallocated(ArgRegs);
    if (FirstVAReg < std::size(ArgRegs)) {
      int Offset = 0;
      // Save remaining registers, storing higher register numbers at a higher
      // address
      // There are (std::size(ArgRegs) - FirstVAReg) registers which
      // need to be saved.
      int VarFI = MFI.CreateFixedObject((std::size(ArgRegs) - FirstVAReg) * 4,
                                        CCInfo.getStackSize(), true);
      AFI->setVarArgsFrameIndex(VarFI);
      SDValue FIN = DAG.getFrameIndex(VarFI, MVT::i32);
      for (unsigned i = FirstVAReg; i < std::size(ArgRegs); i++) {
        // Move argument from phys reg -> virt reg
        unsigned VReg = RegInfo.createVirtualRegister(&ARC::GPR32RegClass);
        RegInfo.addLiveIn(ArgRegs[i], VReg);
        SDValue Val = DAG.getCopyFromReg(Chain, dl, VReg, MVT::i32);
        CFRegNode.push_back(Val.getValue(Val->getNumValues() - 1));
        SDValue VAObj = DAG.getNode(ISD::ADD, dl, MVT::i32, FIN,
                                    DAG.getConstant(Offset, dl, MVT::i32));
        // Move argument from virt reg -> stack
        SDValue Store =
            DAG.getStore(Val.getValue(1), dl, Val, VAObj, MachinePointerInfo());
        MemOps.push_back(Store);
        Offset += 4;
      }
    } else {
      llvm_unreachable("Too many var args parameters.");
    }
  }

  // 2. Chain CopyFromReg nodes into a TokenFactor.
  if (!CFRegNode.empty())
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, CFRegNode);

  // 3. Memcpy 'byVal' args & push final InVals.
  // Aggregates passed "byVal" need to be copied by the callee.
  // The callee will use a pointer to this copy, rather than the original
  // pointer.
  for (const auto &ArgDI : ArgData) {
    if (ArgDI.Flags.isByVal() && ArgDI.Flags.getByValSize()) {
      unsigned Size = ArgDI.Flags.getByValSize();
      Align Alignment =
          std::max(Align(StackSlotSize), ArgDI.Flags.getNonZeroByValAlign());
      // Create a new object on the stack and copy the pointee into it.
      int FI = MFI.CreateStackObject(Size, Alignment, false);
      SDValue FIN = DAG.getFrameIndex(FI, MVT::i32);
      InVals.push_back(FIN);
      MemOps.push_back(DAG.getMemcpy(
          Chain, dl, FIN, ArgDI.SDV, DAG.getConstant(Size, dl, MVT::i32),
          Alignment, false, false, /*CI=*/nullptr, false, MachinePointerInfo(),
          MachinePointerInfo()));
    } else {
      InVals.push_back(ArgDI.SDV);
    }
  }

  // 4. Chain mem ops nodes into a TokenFactor.
  if (!MemOps.empty()) {
    MemOps.push_back(Chain);
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, MemOps);
  }

  return Chain;
}

//===----------------------------------------------------------------------===//
//               Return Value Calling Convention Implementation
//===----------------------------------------------------------------------===//

bool ARCTargetLowering::CanLowerReturn(
    CallingConv::ID CallConv, MachineFunction &MF, bool IsVarArg,
    const SmallVectorImpl<ISD::OutputArg> &Outs, LLVMContext &Context,
    const Type *RetTy) const {
  SmallVector<CCValAssign, 16> RVLocs;
  CCState CCInfo(CallConv, IsVarArg, MF, RVLocs, Context);
  if (!CCInfo.CheckReturn(Outs, RetCC_ARC))
    return false;
  if (CCInfo.getStackSize() != 0 && IsVarArg)
    return false;
  return true;
}

SDValue
ARCTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                               bool IsVarArg,
                               const SmallVectorImpl<ISD::OutputArg> &Outs,
                               const SmallVectorImpl<SDValue> &OutVals,
                               const SDLoc &dl, SelectionDAG &DAG) const {
  auto *AFI = DAG.getMachineFunction().getInfo<ARCFunctionInfo>();
  MachineFrameInfo &MFI = DAG.getMachineFunction().getFrameInfo();

  // CCValAssign - represent the assignment of
  // the return value to a location
  SmallVector<CCValAssign, 16> RVLocs;

  // CCState - Info about the registers and stack slot.
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), RVLocs,
                 *DAG.getContext());

  // Analyze return values.
  if (!IsVarArg)
    CCInfo.AllocateStack(AFI->getReturnStackOffset(), Align(4));

  CCInfo.AnalyzeReturn(Outs, RetCC_ARC);

  SDValue Glue;
  SmallVector<SDValue, 4> RetOps(1, Chain);
  SmallVector<SDValue, 4> MemOpChains;
  // Handle return values that must be copied to memory.
  for (unsigned i = 0, e = RVLocs.size(); i != e; ++i) {
    CCValAssign &VA = RVLocs[i];
    if (VA.isRegLoc())
      continue;
    assert(VA.isMemLoc());
    if (IsVarArg) {
      report_fatal_error("Can't return value from vararg function in memory");
    }

    int Offset = VA.getLocMemOffset();
    unsigned ObjSize = VA.getLocVT().getStoreSize();
    // Create the frame index object for the memory location.
    int FI = MFI.CreateFixedObject(ObjSize, Offset, false);

    // Create a SelectionDAG node corresponding to a store
    // to this memory location.
    SDValue FIN = DAG.getFrameIndex(FI, MVT::i32);
    MemOpChains.push_back(DAG.getStore(
        Chain, dl, OutVals[i], FIN,
        MachinePointerInfo::getFixedStack(DAG.getMachineFunction(), FI)));
  }

  // Transform all store nodes into one single node because
  // all stores are independent of each other.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, MemOpChains);

  // Now handle return values copied to registers.
  for (unsigned i = 0, e = RVLocs.size(); i != e; ++i) {
    CCValAssign &VA = RVLocs[i];
    if (!VA.isRegLoc())
      continue;
    // Copy the result values into the output registers.
    Chain = DAG.getCopyToReg(Chain, dl, VA.getLocReg(), OutVals[i], Glue);

    // guarantee that all emitted copies are
    // stuck together, avoiding something bad
    Glue = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
  }

  RetOps[0] = Chain; // Update chain.

  // Add the glue if we have it.
  if (Glue.getNode())
    RetOps.push_back(Glue);

  // What to do with the RetOps?
  return DAG.getNode(ARCISD::RET, dl, MVT::Other, RetOps);
}

//===----------------------------------------------------------------------===//
// Target Optimization Hooks
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Bounded constant-multiply synthesizer (no HW multiplier)
//
//  See docs/llvm-arc700-optimizations/02-constant-multiplication.md and
//  docs/notes/isa-characterization.md section 4.1 for the primitive set.
//
//  Synthesizes `mul x, C` (ARC700 / !Subtarget.hasMPY()) into a bounded
//  chain of the seven silicon-characterized 1-instruction ARCompact
//  primitives -- ADD, SUB, NEG, immediate ASL, and ADD1/2/3 & SUB1/2/3
//  scaled-adds -- instead of a `bl __mulsi3` libcall. Every primitive is
//  LINEAR in its x-derived operand(s) over Z/2^32Z and the seed `x` is the
//  only free variable ever injected, so any recipe built purely from these
//  primitives computes exactly `K*x mod 2^32` for a fixed K determined by
//  the op sequence -- checking `interpret(recipe, 1) == C` is therefore
//  mathematically sufficient to prove correctness for every x (see the
//  NDEBUG-gated asserts in synthesizeConstMul).
//===----------------------------------------------------------------------===//

namespace {

// One step of a synthesized recipe. Operand references are indices into the
// SAME SynthRecipe::Steps vector: 0 means "the seed x", N>0 means
// "the result of Steps[N-1]". This is an ABSTRACT recipe -- never an
// SDValue/SDNode pointer -- so it is safe to memoize across unrelated
// SelectionDAGs (different functions / a persistent cache).
enum class StepOp : uint8_t { Shl, Add, Sub, AddSh, SubSh, Neg };

struct Step {
  StepOp Op;
  uint8_t Imm = 0;  // shift amount, for Shl/AddSh/SubSh only.
  int32_t Lhs = 0;  // operand ref (0 = seed x).
  int32_t Rhs = 0;  // operand ref (0 = seed x); unused by Shl/Neg.
};

// A self-contained recipe: Steps.back() (or the seed x, if Steps is empty)
// is the result. Cost == Steps.size() == instruction count, since every
// Step above is exactly one 4-byte ARCompact instruction and none of them
// ever carries a runtime-materialized immediate (shift amounts are
// compile-time-fixed opcode operands, not DAG leaves), so no LIMM is ever
// needed by a synthesized sequence.
struct SynthRecipe {
  bool Found = false;
  SmallVector<Step, 8> Steps;

  // ref to this recipe's own result, for use as an operand of the NEXT step
  // a caller appends.
  int32_t root() const { return static_cast<int32_t>(Steps.size()); }

  static SynthRecipe seed() {
    SynthRecipe R;
    R.Found = true; // Steps empty -> root() == 0 == the seed x itself.
    return R;
  }

  // Append `Op(Operand.root() [, Imm])`, i.e. a unary/Shl/Neg step.
  static SynthRecipe unary(StepOp Op, uint8_t Imm, const SynthRecipe &Operand) {
    SynthRecipe R;
    if (!Operand.Found)
      return R;
    R.Steps = Operand.Steps;
    R.Steps.push_back(Step{Op, Imm, Operand.root(), 0});
    R.Found = true;
    return R;
  }

  // Append `Op(Operand.root(), Operand.root() [, Imm])` -- self-peel: BOTH
  // operands reference the SAME earlier step, giving free CSE by
  // construction (e.g. ADD1(t,t) for a *3 self-peel), never a duplicated
  // subexpression.
  static SynthRecipe binarySelf(StepOp Op, uint8_t Imm,
                                const SynthRecipe &Operand) {
    SynthRecipe R;
    if (!Operand.Found)
      return R;
    R.Steps = Operand.Steps;
    int32_t Root = Operand.root();
    R.Steps.push_back(Step{Op, Imm, Root, Root});
    R.Found = true;
    return R;
  }

  // Append `Op(Operand.root(), x [, Imm])` -- the "adjacent bump" shape,
  // combining a recursed sub-recipe with the free seed.
  static SynthRecipe withSeedRhs(StepOp Op, uint8_t Imm,
                                 const SynthRecipe &Operand) {
    SynthRecipe R;
    if (!Operand.Found)
      return R;
    R.Steps = Operand.Steps;
    R.Steps.push_back(Step{Op, Imm, Operand.root(), 0});
    R.Found = true;
    return R;
  }
};

// Three independent, all-enforced compile-time bounds (per the dossier's
// "hard node/depth budget for deterministic compile time" requirement):
//   MaxDepth    -- recursion-depth ceiling; also an upper bound on the final
//                  instruction count of any accepted recipe, since every
//                  recursive branch below adds exactly one Step per level.
//   MaxExplored -- total recursive-call ceiling for one top-level query,
//                  independent of MaxDepth (defense-in-depth: bounds compile
//                  time even if a future edit widens the branch set without
//                  updating MaxDepth).
//   CacheCap    -- steady-state memory ceiling on the persistent cache below
//                  (a pure perf tradeoff: queries beyond the cap still
//                  compute correctly, just uncached).
constexpr unsigned MaxDepth = 4;
constexpr unsigned MaxExplored = 4096;
constexpr size_t CacheCap = 16384;

// Reduce an arbitrary intermediate back to the canonical signed-32-bit
// representative. Well-defined two's-complement truncation -- matches every
// other place in this codebase that assumes wraparound i32 arithmetic.
// Deliberately int64_t throughout the search (never raw int32_t negation) so
// negating INT32_MIN is always well-defined (int64_t has headroom), sidestepping
// the APInt::abs()-on-INT_MIN footgun the old decomposeMulByConstant had to
// special-case.
static int64_t canon32(int64_t V) {
  return static_cast<int64_t>(static_cast<int32_t>(static_cast<uint32_t>(V)));
}

struct SearchCtx {
  // Per-top-level-query memo, keyed by (canon32'd C, remaining depth). Safe
  // to key on the exact remaining depth (rather than trying to reuse across
  // different depths): a search at depth d can never find a result cheaper
  // than one found at depth d' < d, so this has no cross-depth correctness
  // subtlety -- it is a plain memoized recursion, not an attempt at a
  // depth-independent global optimum.
  DenseMap<std::pair<int64_t, unsigned>, SynthRecipe> Memo;
  unsigned Explored = 0;
};

static SynthRecipe searchC(int64_t C, unsigned Depth, SearchCtx &Ctx);

// The uncached body of searchC: fast paths first (never consuming search
// budget beyond their own 1-2 steps), then the five recursive branches from
// docs/llvm-arc700-optimizations/02-constant-multiplication.md, trying ALL
// of them and keeping the minimum-cost result (branch-and-bound would only
// prune a sub-call whose cost already exceeds the current best; we skip
// that refinement since MaxDepth/MaxExplored already bound the work).
static SynthRecipe searchCUncached(int64_t Cc, unsigned Depth, SearchCtx &Ctx) {
  // --- Fast paths: 0, 1, -1, +-2^k (including INT_MIN), never touch the
  //     general branches below. Reachability note: because these are always
  //     checked (at every recursive entry, not just the top level) BEFORE
  //     the general branches run, a caller can never recurse into branch
  //     4/5's "C-+1"/"C-+2^k" adjacent-bump shapes starting from a C that
  //     itself was 0/+-1/+-2^k -- so Cc==0 is unreachable in practice here
  //     (defensively handled by declining rather than asserting, so a
  //     reachability mistake can only cost a missed optimization, never a
  //     miscompile).
  if (Cc == 0)
    return SynthRecipe();
  if (Cc == 1)
    return SynthRecipe::seed(); // cost 0, already-live register.
  if (Cc == -1) {
    if (Depth < 1)
      return SynthRecipe();
    return SynthRecipe::unary(StepOp::Neg, 0, SynthRecipe::seed()); // cost 1.
  }
  SynthRecipe FastBest;
  {
    uint32_t U = static_cast<uint32_t>(Cc);
    if (isPowerOf2_32(U)) {
      unsigned Sh = Log2_32(U);
      if (Sh >= 1 && Sh <= 31 && Depth >= 1)
        FastBest = SynthRecipe::unary(StepOp::Shl, Sh, SynthRecipe::seed());
    }
  }
  {
    uint32_t UNeg = static_cast<uint32_t>(-Cc);
    if (isPowerOf2_32(UNeg)) {
      unsigned Sh = Log2_32(UNeg);
      if (Sh >= 1 && Sh <= 31 && Depth >= 2) {
        SynthRecipe Shl =
            SynthRecipe::unary(StepOp::Shl, Sh, SynthRecipe::seed());
        SynthRecipe NegShl = SynthRecipe::unary(StepOp::Neg, 0, Shl);
        if (!FastBest.Found ||
            NegShl.Steps.size() < FastBest.Steps.size())
          FastBest = NegShl;
      }
    }
  }
  if (FastBest.Found)
    return FastBest; // power-of-two shapes never consume the general budget.

  if (Depth == 0)
    return SynthRecipe(); // no budget left for the general branches below.

  SynthRecipe Best;
  auto consider = [&](SynthRecipe &&Cand) {
    if (Cand.Found && (!Best.Found || Cand.Steps.size() < Best.Steps.size()))
      Best = std::move(Cand);
  };

  // Branch 1: strip an ARBITRARY run of trailing zero bits in one Shl.
  // Generalizes the old decomposeMulByConstant's TZeros-stripping idea to
  // recurse instead of requiring the residue to immediately be 2^N+-1.
  {
    uint32_t Bits = static_cast<uint32_t>(Cc);
    unsigned Tz = countr_zero(Bits);
    if (Tz >= 1 && Tz <= 31) {
      int64_t Residue = Cc >> Tz; // exact: Cc is divisible by 2^Tz.
      consider(SynthRecipe::unary(
          StepOp::Shl, Tz, searchC(Residue, Depth - 1, Ctx)));
    }
  }

  // Branch 2: self-scaled ADD-peel. ADDk(t,t) = t*(1+2^k) for k in {1,2,3}
  // (divisors 3, 5, 9) -- this is exactly how x*3/5/9 arise (A=1, the
  // trivial seed base case) and how x*11/13's inner ADD1/ADD2 arise.
  for (unsigned K : {1u, 2u, 3u}) {
    int64_t Divisor = (int64_t{1} << K) + 1;
    if (Cc % Divisor == 0) {
      int64_t A = Cc / Divisor;
      consider(SynthRecipe::binarySelf(
          StepOp::AddSh, static_cast<uint8_t>(K), searchC(A, Depth - 1, Ctx)));
    }
  }

  // Branch 3: self-scaled SUB-peel. SUBk(t,t) = t*(1-2^k) = -t*(2^k-1) for
  // k in {2,3} (divisors 3, 7); k=1 would give divisor 1 (degenerate,
  // already covered by the NEG fast path) so it is skipped.
  for (unsigned K : {2u, 3u}) {
    int64_t Divisor = (int64_t{1} << K) - 1;
    if (Cc % Divisor == 0) {
      int64_t A = -(Cc / Divisor);
      consider(SynthRecipe::binarySelf(
          StepOp::SubSh, static_cast<uint8_t>(K), searchC(A, Depth - 1, Ctx)));
    }
  }

  // Branch 4: adjacent +-1 bump -- generalizes the 2^N+-1 shape to allow an
  // arbitrary PRECEDING chain instead of requiring a bare Shl in front.
  consider(SynthRecipe::withSeedRhs(StepOp::Add, 0,
                                    searchC(Cc - 1, Depth - 1, Ctx)));
  consider(SynthRecipe::withSeedRhs(StepOp::Sub, 0,
                                    searchC(Cc + 1, Depth - 1, Ctx)));

  // Branch 5: adjacent scaled +-2^k bump, k in {1,2,3}. This is the branch
  // that finds x*11 = ADD3(ADD1(x,x),x) [11-8=3 -> branch2 k=1 cost1 -> wrap
  // ADD3 cost2] and x*13 = ADD3(ADD2(x,x),x) [13-8=5 -> branch2 k=2 cost1 ->
  // wrap ADD3 cost2].
  for (unsigned K : {1u, 2u, 3u}) {
    int64_t Bump = int64_t{1} << K;
    consider(SynthRecipe::withSeedRhs(
        StepOp::AddSh, static_cast<uint8_t>(K),
        searchC(Cc - Bump, Depth - 1, Ctx)));
    consider(SynthRecipe::withSeedRhs(
        StepOp::SubSh, static_cast<uint8_t>(K),
        searchC(Cc + Bump, Depth - 1, Ctx)));
  }

  return Best;
}

static SynthRecipe searchC(int64_t C, unsigned Depth, SearchCtx &Ctx) {
  int64_t Cc = canon32(C);
  if (++Ctx.Explored > MaxExplored)
    return SynthRecipe(); // compile-time guardrail: stop exploring.

  auto Key = std::make_pair(Cc, Depth);
  if (auto It = Ctx.Memo.find(Key); It != Ctx.Memo.end())
    return It->second;

  SynthRecipe R = searchCUncached(Cc, Depth, Ctx);
  Ctx.Memo.try_emplace(Key, R);
  return R;
}

// Host-side interpreter over the SAME 7-primitive enum, used only for the
// NDEBUG-gated correctness assertions in synthesizeConstMul. uint32_t
// arithmetic gives the mod-2^32 wraparound for free.
static uint32_t interpretRecipe(const SynthRecipe &R, uint32_t X) {
  SmallVector<uint32_t, 8> Vals;
  auto Val = [&](int32_t Ref) -> uint32_t {
    return Ref == 0 ? X : Vals[Ref - 1];
  };
  for (const Step &S : R.Steps) {
    uint32_t V;
    switch (S.Op) {
    case StepOp::Shl:
      V = Val(S.Lhs) << S.Imm;
      break;
    case StepOp::Add:
      V = Val(S.Lhs) + Val(S.Rhs);
      break;
    case StepOp::Sub:
      V = Val(S.Lhs) - Val(S.Rhs);
      break;
    case StepOp::AddSh:
      V = Val(S.Lhs) + (Val(S.Rhs) << S.Imm);
      break;
    case StepOp::SubSh:
      V = Val(S.Lhs) - (Val(S.Rhs) << S.Imm);
      break;
    case StepOp::Neg:
      V = 0u - Val(S.Lhs);
      break;
    }
    Vals.push_back(V);
  }
  return R.Steps.empty() ? X : Vals.back();
}

// Top-level entry: search(C, MaxDepth), memoized persistently by canon32'd C
// alone. Safe to key on C alone (ignoring context) because every top-level
// query always searches with the SAME fixed MaxDepth budget -- there is no
// "partial budget" top-level query this cache could serve incorrectly.
// thread_local sidesteps any data race if this toolchain's codegen pipeline
// ever parallelizes per-function combines (e.g. ThinLTO codegen
// partitioning); costs nothing extra if it never does.
static std::optional<SynthRecipe> synthesizeConstMul(int64_t C) {
  int64_t Cc = canon32(C);

  static thread_local DenseMap<int64_t, std::optional<SynthRecipe>> Cache;
  if (auto It = Cache.find(Cc); It != Cache.end())
    return It->second;

  SearchCtx Ctx;
  SynthRecipe R = searchC(Cc, MaxDepth, Ctx);

  std::optional<SynthRecipe> Result;
  if (R.Found) {
#ifndef NDEBUG
    // Linearity proof (see file header comment): DAG(x) = K*x mod 2^32 for
    // every primitive here, so DAG(1) == C is mathematically sufficient.
    // Also exercised at a handful of concrete x as defense-in-depth against
    // a bug in the interpreter/lemma itself (e.g. a stray non-linear
    // primitive slipping in) -- redundant with the proof, not a substitute
    // for it.
    assert(interpretRecipe(R, 1) == static_cast<uint32_t>(Cc) &&
           "ARC constant-mul synthesizer: recipe fails linearity check at "
           "x=1 -- DAG(1) must equal C for the search to be sound");
    for (uint32_t X :
        {0u, 1u, 0xFFFFFFFFu, 0x80000000u, 0xDEADBEEFu, 0x12345678u}) {
      uint32_t Want = static_cast<uint32_t>(
          static_cast<uint64_t>(static_cast<uint32_t>(Cc)) *
          static_cast<uint64_t>(X));
      assert(interpretRecipe(R, X) == Want &&
             "ARC constant-mul synthesizer: recipe failed randomized-x "
             "check -- a non-linear primitive must have slipped in");
    }
#endif
    Result = R;
  }

  if (Cache.size() < CacheCap)
    Cache.try_emplace(Cc, Result);
  return Result;
}

// Materialize a SynthRecipe as ordinary ISD::ADD/SUB/SHL DAG nodes (there is
// no such thing as an "ADD1 SDNode" -- ADD1/2/3/SUB1/2/3 are ISel Pats in
// ARCARCompactPatterns.td matching the shape `(add $b,(shl $c,N))` /
// `(sub $b,(shl $c,N))`, which fire automatically once the DAG has this
// shape; no new TableGen pattern is needed). SUB/SubSh are not commutative,
// so the true minuend is always placed as the Lhs operand -- this falls out
// naturally from which side each branch above tracked as "sub" vs
// "x"/"SHL(x,k)". No nsw/nuw flags are propagated (default SDNodeFlags()):
// intermediate synthesized steps are not provably no-wrap even when the
// overall `mul` had such a flag.
static SDValue emitRecipe(const SynthRecipe &R, SDValue X, const SDLoc &dl,
                          SelectionDAG &DAG) {
  EVT VT = X.getValueType();
  SmallVector<SDValue, 8> Vals;
  auto Val = [&](int32_t Ref) -> SDValue {
    return Ref == 0 ? X : Vals[Ref - 1];
  };
  for (const Step &S : R.Steps) {
    SDValue V;
    switch (S.Op) {
    case StepOp::Shl:
      V = DAG.getNode(ISD::SHL, dl, VT, Val(S.Lhs),
                      DAG.getConstant(S.Imm, dl, VT));
      break;
    case StepOp::Add:
      V = DAG.getNode(ISD::ADD, dl, VT, Val(S.Lhs), Val(S.Rhs));
      break;
    case StepOp::Sub:
      V = DAG.getNode(ISD::SUB, dl, VT, Val(S.Lhs), Val(S.Rhs));
      break;
    case StepOp::AddSh: {
      SDValue Sh = DAG.getNode(ISD::SHL, dl, VT, Val(S.Rhs),
                               DAG.getConstant(S.Imm, dl, VT));
      V = DAG.getNode(ISD::ADD, dl, VT, Val(S.Lhs), Sh);
      break;
    }
    case StepOp::SubSh: {
      SDValue Sh = DAG.getNode(ISD::SHL, dl, VT, Val(S.Rhs),
                               DAG.getConstant(S.Imm, dl, VT));
      V = DAG.getNode(ISD::SUB, dl, VT, Val(S.Lhs), Sh);
      break;
    }
    case StepOp::Neg:
      V = DAG.getNode(ISD::SUB, dl, VT, DAG.getConstant(0, dl, VT),
                      Val(S.Lhs));
      break;
    }
    Vals.push_back(V);
  }
  return R.Steps.empty() ? X : Vals.back();
}

} // end anonymous namespace

//===----------------------------------------------------------------------===//
//  Constant-divisor unsigned div/rem synthesis (dossier 18, first cut)
//
//  UNSIGNED-only, whitelist-gated synthesis of `udiv x, C` / `urem x, C` for
//  cores without a hardware multiplier (ARC700 / !Subtarget.hasMPY()) and a
//  compile-time-constant divisor. Two independent mechanisms, chosen per
//  divisor:
//
//   (a) Shift-add reciprocal + back-multiply remainder recovery, for
//       C in {3, 5, 10} -- performUDivRemCombine below, a target DAGCombine
//       on BOTH ISD::UDIV and ISD::UREM (reached for either opcode with that
//       divisor). Produces the quotient directly and recovers the remainder
//       via a single back-multiply, reusing synthesizeConstMul / emitRecipe
//       from the constant-multiply synthesizer above (see mulByConst below)
//       -- NEVER a MUL node.
//   (b) Digit-fold modulo, for C in the 2^k-1 family {7, 15, 255} (NOT 3 --
//       see the note on emitURemDigitFold's dispatch below) --
//       performURemDigitFoldCombine, a target DAGCombine on ISD::UREM.
//
//  BOTH mechanisms are target DAGCombines, mirroring performMULCombine's
//  architecture exactly -- registered via setTargetDAGCombine in the
//  constructor, intercepting strictly BEFORE legalization would otherwise
//  route the node to the __udivsi3/__umodsi3 libcall. This is a deliberate
//  choice, not a style preference: UDIV/UREM are NEVER marked Custom via
//  setOperationAction here (they stay at their default Expand action for
//  every subtarget). Marking UDIV Custom -- even a Custom hook that
//  DECLINES for the non-whitelisted/common case -- would make
//  TargetLowering::isOperationLegalOrCustom(ISD::UDIV, ...) return true,
//  which TargetLowering::expandREM (LegalizeDAG.cpp's generic UREM
//  expansion) consults to decide HOW to expand a UREM node it cannot custom-
//  lower: with UDIV "legal-or-custom", expandREM synthesizes
//  `urem = n - udiv(n,d)*d` (a UDIV + a generic MUL, i.e. TWO libcalls --
//  __udivsi3 then __mulsi3 -- plus a SUB) instead of its other branch, a
//  single direct __umodsi3 call. This was caught empirically during
//  dossier-18 IMPLEMENT: an earlier Custom-LowerOperation-based version of
//  path (a) silently turned every NON-whitelisted UREM (e.g. `%7` at -Oz)
//  from one libcall into two, and incidentally tripped a latent
//  MachineVerifier bug in the two-call callee-saved-register spill sequence
//  that the single-call path never exercised. A pure DAGCombine has no such
//  side effect on sibling-opcode legality queries, so it is the only
//  correct vehicle here.
//
//  Every divisor here (3, 5, 7, 10, 15, 255) and every synthesized op
//  sequence was exhaustively verified over all 2^32 u32 inputs against the
//  native unsigned-division reference (0 mismatches) in the dossier-18
//  PROVE phase before this code was written. SDIV/SREM, the modular-inverse
//  exact-division test, IV strength-reduction, and any divisor outside this
//  set are explicitly OUT OF SCOPE for this cut -- see
//  llvm/test/CodeGen/ARC/arc700eb-udivmod.ll for the acceptance coverage.
//
//  Cost gate mirrors performMULCombine's exactly: at -Oz/-Os (MinSize /
//  OptSize) both mechanisms decline unconditionally and the node falls
//  through to the existing Expand -> __udivsi3/__umodsi3 libcall path (the
//  synthesized sequences, 13-19 instructions, are never smaller than the
//  2-3 instruction call site for this divisor set) -- so a size-tuned
//  (-Oz) firmware build is expected to show ~0 byte delta from this
//  dossier. At -O0/-O1/-O2/-O3
//  the whitelist always fires once matched (these are fixed hand-written
//  sequences, not a re-checked bounded search).
//===----------------------------------------------------------------------===//

namespace {

// Reuses the bounded scaled-add synthesizer above for every q*C / r*K
// back-multiply this file needs -- NEVER a MUL node. K must be one of the
// constants the reciprocal recipes below actually use (3, 5, 10, 11, 13);
// all five are proven (by the dossier-02 worked examples / the search
// itself) to resolve within MaxDepth==4, so a failure here can only mean a
// whitelist/search-budget mismatch introduced by a later edit, never a
// runtime-data-dependent condition -- report_fatal_error rather than
// silently miscompiling.
static SDValue mulByConst(SDValue X, int64_t K, const SDLoc &dl,
                          SelectionDAG &DAG) {
  std::optional<SynthRecipe> R = synthesizeConstMul(K);
  if (!R)
    report_fatal_error(
        "ARC dossier-18: whitelist constant multiplier failed to resolve "
        "within the dossier-02 bounded search (MaxDepth) -- indicates a "
        "whitelist/search-budget mismatch, not a runtime-data-dependent "
        "failure");
  return emitRecipe(*R, X, dl, DAG);
}

static SDValue lsrImm(SDValue V, uint64_t Amt, const SDLoc &dl,
                      SelectionDAG &DAG, EVT VT) {
  return DAG.getNode(ISD::SRL, dl, VT, V, DAG.getConstant(Amt, dl, VT));
}

static SDValue addV(SDValue A, SDValue B, const SDLoc &dl, SelectionDAG &DAG,
                    EVT VT) {
  return DAG.getNode(ISD::ADD, dl, VT, A, B);
}

static SDValue subV(SDValue A, SDValue B, const SDLoc &dl, SelectionDAG &DAG,
                    EVT VT) {
  return DAG.getNode(ISD::SUB, dl, VT, A, B);
}

static SDValue andImm(SDValue V, uint64_t Mask, const SDLoc &dl,
                      SelectionDAG &DAG, EVT VT) {
  return DAG.getNode(ISD::AND, dl, VT, V, DAG.getConstant(Mask, dl, VT));
}

// Mandatory conditional reduce after a digit-fold: keep T if T<C, subtract C
// if T>=C. CARRY POLARITY (docs/notes/isa-characterization.md section 5.4):
// on this ARC700 SUB/CMP set, C(arry)=BORROW; a>=b (unsigned) => C=0 =>
// .hs/.cc. This reduce is therefore selected with SETUGE (-> ARCCC::HS via
// ISDCCtoARCCC, reached through LowerSELECT_CC), i.e. a carry-CLEAR-
// predicated sub -- NEVER SETULT/.lo/.cs. Routed through the already
// silicon-validated LowerSELECT_CC (ARCISD::CMP + ARCISD::CMOV) path rather
// than any new hand-coded carry-flag logic.
static SDValue reduceMod(SDValue T, uint64_t C, const SDLoc &dl,
                         SelectionDAG &DAG, EVT VT) {
  SDValue CVal = DAG.getConstant(C, dl, VT);
  SDValue Sub = subV(T, CVal, dl, DAG, VT);
  return DAG.getNode(ISD::SELECT_CC, dl, VT, T, CVal, Sub, T,
                     DAG.getCondCode(ISD::SETUGE));
}

// The whitelist itself, as a small static table -- the single source of
// truth both performUDivRemCombine and performURemDigitFoldCombine consult.
// EVERY entry below was exhaustively verified (0 mismatches over all 2^32
// u32 inputs) against the native reference in the dossier-18 PROVE phase
// before this code was written; Proven is always true here BY CONSTRUCTION
// (there is no code path that can add an entry without that proof) -- kept
// as an explicit field anyway so the invariant is documented at the
// definition site, not just asserted by omission. Do not add an entry
// without a matching exhaustive proof landing first (the dossier's hard
// gate).
enum class DivRemKind : uint8_t {
  ReciprocalDivMod, // path (a): shift-add reciprocal + back-multiply.
  DigitFold,        // path (b): 2^k-1 digit-fold modulo (UREM only).
};

struct DivisorEntry {
  uint32_t Divisor;
  DivRemKind Kind;
  bool Proven;
};

static constexpr DivisorEntry ProvenUDivRemWhitelist[] = {
    {3, DivRemKind::ReciprocalDivMod, true},
    {5, DivRemKind::ReciprocalDivMod, true},
    {10, DivRemKind::ReciprocalDivMod, true},
    // Divisor 3 is deliberately NOT also listed as DigitFold: 2^2-1==3
    // qualifies structurally, but the ReciprocalDivMod entry above is
    // strictly cheaper for a bare %3 and also yields the paired quotient --
    // see the emitURemDigitFold family's dispatch comment below for the
    // full rationale. This table is the single place that decision is
    // encoded: %3 has exactly one entry, and it is ReciprocalDivMod.
    {7, DivRemKind::DigitFold, true},
    {15, DivRemKind::DigitFold, true},
    {255, DivRemKind::DigitFold, true},
};

// Linear scan -- the table has 6 entries, so this is cheaper than any
// container machinery and keeps the whitelist trivially auditable in one
// place. Returns nullptr for a divisor with no entry (not whitelisted at
// all) or found but Kind != WantKind (whitelisted for the OTHER mechanism,
// e.g. divisor 7 queried with ReciprocalDivMod).
static const DivisorEntry *lookupDivisor(uint64_t D, DivRemKind WantKind) {
  for (const DivisorEntry &E : ProvenUDivRemWhitelist)
    if (E.Divisor == D && E.Kind == WantKind && E.Proven)
      return &E;
  return nullptr;
}

// --- Path (a): shift-add reciprocal + back-multiply, C in {3, 5, 10} -----
// Every sequence below is EXHAUSTIVELY VERIFIED (0 mismatches over all
// 2^32 u32 inputs, native C harness) in the dossier-18 PROVE phase.

// floor(n/3), remainder via back-multiply. 9-op doubling-fold reciprocal +
// an exact closed-form fix (11*r >> 5) -- no branches, no extra reduce
// needed for the whole 32-bit range.
static void emitDivRem3(SDValue N, const SDLoc &dl, SelectionDAG &DAG, EVT VT,
                        SDValue &Q, SDValue &Rem) {
  SDValue q0 = lsrImm(N, 2, dl, DAG, VT);
  SDValue t1 = lsrImm(N, 4, dl, DAG, VT);
  SDValue q1 = addV(q0, t1, dl, DAG, VT);
  SDValue t2 = lsrImm(q1, 4, dl, DAG, VT);
  SDValue q2 = addV(q1, t2, dl, DAG, VT);
  SDValue t3 = lsrImm(q2, 8, dl, DAG, VT);
  SDValue q3 = addV(q2, t3, dl, DAG, VT);
  SDValue t4 = lsrImm(q3, 16, dl, DAG, VT);
  SDValue qraw = addV(q3, t4, dl, DAG, VT);

  SDValue t = mulByConst(qraw, 3, dl, DAG);
  SDValue r = subV(N, t, dl, DAG, VT);
  SDValue fix = lsrImm(mulByConst(r, 11, dl, DAG), 5, dl, DAG, VT);
  Q = addV(qraw, fix, dl, DAG, VT);
  Rem = subV(N, mulByConst(Q, 3, dl, DAG), dl, DAG, VT);
}

// floor(m/5), quotient only -- shared by emitDivRem5 (m=n) and emitDivRem10
// (m=n>>1, via the exact floor(n/10)==floor(floor(n/2)/5) identity: n>>1 is
// an exact truncating unsigned halving, so there is no rounding hazard).
static SDValue computeQuot5(SDValue M, const SDLoc &dl, SelectionDAG &DAG,
                            EVT VT) {
  SDValue s0 = lsrImm(M, 4, dl, DAG, VT);
  SDValue q0 = mulByConst(s0, 3, dl, DAG); // 3*(M>>4), ADD1 self-peel.
  SDValue t1 = lsrImm(q0, 4, dl, DAG, VT);
  SDValue q1 = addV(q0, t1, dl, DAG, VT);
  SDValue t2 = lsrImm(q1, 8, dl, DAG, VT);
  SDValue q2 = addV(q1, t2, dl, DAG, VT);
  SDValue t3 = lsrImm(q2, 16, dl, DAG, VT);
  SDValue qraw = addV(q2, t3, dl, DAG, VT);

  SDValue t = mulByConst(qraw, 5, dl, DAG);
  SDValue r = subV(M, t, dl, DAG, VT);
  SDValue fix = lsrImm(mulByConst(r, 13, dl, DAG), 6, dl, DAG, VT);
  return addV(qraw, fix, dl, DAG, VT);
}

static void emitDivRem5(SDValue N, const SDLoc &dl, SelectionDAG &DAG, EVT VT,
                        SDValue &Q, SDValue &Rem) {
  Q = computeQuot5(N, dl, DAG, VT);
  Rem = subV(N, mulByConst(Q, 5, dl, DAG), dl, DAG, VT);
}

// floor(n/10) = floor(floor(n/2)/5) exactly -- reuses computeQuot5 on n>>1
// verbatim, then a single back-multiply by 10 (dossier-02's own
// "10x = asl(add2 x,x),1" shape, reached automatically through mulByConst).
static void emitDivRem10(SDValue N, const SDLoc &dl, SelectionDAG &DAG,
                         EVT VT, SDValue &Q, SDValue &Rem) {
  SDValue M = lsrImm(N, 1, dl, DAG, VT);
  Q = computeQuot5(M, dl, DAG, VT);
  Rem = subV(N, mulByConst(Q, 10, dl, DAG), dl, DAG, VT);
}

// --- Path (b): digit-fold modulo, C in the 2^k-1 family {7, 15, 255} -----
// (NOT 3: 2^2-1==3 also qualifies structurally, but path (a)'s emitDivRem3
// remainder is strictly cheaper -- 17 ops, 0 conditional instructions, vs
// this family's 19 ops / 4 conditional instructions for a bare %3 -- AND it
// also produces the paired quotient for free. %3 is therefore routed
// exclusively through performUDivRemCombine/emitDivRem3; performURemDigitFoldCombine
// below deliberately excludes divisor 3 so this costlier shape is never
// reachable / never dead-code-shipped for it. This is a deliberate
// dispatch-priority decision made during dossier-18 IMPLEMENT, recorded
// here per the STUDY phase's open-risk note.)
//
// Every cascade is EXHAUSTIVELY VERIFIED (0 mismatches over all 2^32 u32
// inputs) in the dossier-18 PROVE phase, including the exact reduce count
// (single vs double) each one needs.

static SDValue emitURemDigitFold7(SDValue X, const SDLoc &dl,
                                  SelectionDAG &DAG, EVT VT) {
  SDValue v1 = addV(lsrImm(X, 15, dl, DAG, VT), andImm(X, 0x7FFF, dl, DAG, VT),
                    dl, DAG, VT);
  SDValue v2 = addV(lsrImm(v1, 9, dl, DAG, VT),
                    andImm(v1, 0x1FF, dl, DAG, VT), dl, DAG, VT);
  SDValue v3 = addV(lsrImm(v2, 6, dl, DAG, VT), andImm(v2, 0x3F, dl, DAG, VT),
                    dl, DAG, VT);
  SDValue v4 = addV(lsrImm(v3, 3, dl, DAG, VT), andImm(v3, 0x7, dl, DAG, VT),
                    dl, DAG, VT);
  SDValue v5 = addV(lsrImm(v4, 3, dl, DAG, VT), andImm(v4, 0x7, dl, DAG, VT),
                    dl, DAG, VT);
  // max(v5) == 8 (verified exhaustively) -- a single reduce suffices.
  return reduceMod(v5, 7, dl, DAG, VT);
}

static SDValue emitURemDigitFold15(SDValue X, const SDLoc &dl,
                                   SelectionDAG &DAG, EVT VT) {
  SDValue v1 = addV(lsrImm(X, 16, dl, DAG, VT),
                    andImm(X, 0xFFFF, dl, DAG, VT), dl, DAG, VT);
  SDValue v2 = addV(lsrImm(v1, 8, dl, DAG, VT), andImm(v1, 0xFF, dl, DAG, VT),
                    dl, DAG, VT);
  SDValue v3 = addV(lsrImm(v2, 4, dl, DAG, VT), andImm(v2, 0xF, dl, DAG, VT),
                    dl, DAG, VT);
  SDValue v4 = addV(lsrImm(v3, 4, dl, DAG, VT), andImm(v3, 0xF, dl, DAG, VT),
                    dl, DAG, VT);
  // max(v4) == 17 (verified exhaustively) -- a single reduce suffices.
  return reduceMod(v4, 15, dl, DAG, VT);
}

static SDValue emitURemDigitFold255(SDValue X, const SDLoc &dl,
                                    SelectionDAG &DAG, EVT VT) {
  SDValue c0 = andImm(X, 0xFF, dl, DAG, VT);
  SDValue c1 = andImm(lsrImm(X, 8, dl, DAG, VT), 0xFF, dl, DAG, VT);
  SDValue c2 = andImm(lsrImm(X, 16, dl, DAG, VT), 0xFF, dl, DAG, VT);
  SDValue c3 = lsrImm(X, 24, dl, DAG, VT);
  SDValue u1 = addV(c0, c1, dl, DAG, VT);
  SDValue u2 = addV(u1, c2, dl, DAG, VT);
  SDValue t = addV(u2, c3, dl, DAG, VT); // t <= 4*255 == 1020.
  SDValue d0 = andImm(t, 0xFF, dl, DAG, VT);
  SDValue d1 = lsrImm(t, 8, dl, DAG, VT);
  SDValue t2 = addV(d0, d1, dl, DAG, VT); // t2 <= 258.
  // Deliberately NOT the naive 2-fold iterative shape used for 7/15
  // (a uniform k=16,8 fold on this identity FAILS -- max residue 765,
  // needing up to 3 reduces): this dossier's own verified 4-way-sum shape
  // is used instead. max(t2) == 258 -- a single reduce suffices.
  return reduceMod(t2, 255, dl, DAG, VT);
}

} // end anonymous namespace

// Target DAGCombine for path (a) -- see the section header comment above.
// Fires on BOTH ISD::UDIV and ISD::UREM at combine time (both registered via
// setTargetDAGCombine in the constructor), strictly before legalization
// would otherwise route the node to a libcall; the opcode is re-checked
// below to pick the quotient or the remainder from the SAME synthesized
// pipeline. A paired udiv+urem by the same constant divisor on the same
// dividend in the same function reconstructs structurally-identical
// intermediate nodes, which ordinary SelectionDAG CSE (hash-consing) merges
// automatically -- no manual 2-result ISD::UDIVREM node is needed for this
// first cut.
SDValue ARCTargetLowering::performUDivRemCombine(SDNode *N,
                                                 DAGCombinerInfo &DCI) const {
  assert((N->getOpcode() == ISD::UDIV || N->getOpcode() == ISD::UREM) &&
        "performUDivRemCombine: expected ISD::UDIV or ISD::UREM");
  if (Subtarget.hasMPY())
    return SDValue();

  EVT VT = N->getValueType(0);
  if (VT != MVT::i32)
    return SDValue();

  SDValue N0 = N->getOperand(0);
  SDValue Divisor = N->getOperand(1);
  auto *DivC = dyn_cast<ConstantSDNode>(Divisor);
  if (!DivC || DivC->isOpaque())
    return SDValue(); // Non-constant / opaque divisor: fall through to the
                      // existing Expand -> libcall path, unchanged.

  uint64_t D = DivC->getZExtValue();
  // ProvenUDivRemWhitelist lookup (dossier-18 PROVE phase) -- the ONLY
  // divisors this path may ever synthesize for. Do not extend the table
  // without a matching exhaustive-2^32 proof landing first (the dossier's
  // hard gate).
  if (!lookupDivisor(D, DivRemKind::ReciprocalDivMod))
    return SDValue(); // Not whitelisted for the reciprocal path.

  // Cost gate: mirror performMULCombine's -Oz/-Os policy exactly (see the
  // section header comment). At -Oz/-Os the __udivsi3/__umodsi3 libcall
  // (2-3 instructions) is strictly smaller than every synthesized sequence
  // here (16-18 instructions), so decline unconditionally and keep it.
  const MachineFunction &MF = DCI.DAG.getMachineFunction();
  if (MF.getFunction().hasMinSize() || MF.getFunction().hasOptSize())
    return SDValue();

  SDLoc dl(N);
  SelectionDAG &DAG = DCI.DAG;
  SDValue Q, R;
  switch (D) {
  case 3:
    emitDivRem3(N0, dl, DAG, VT, Q, R);
    break;
  case 5:
    emitDivRem5(N0, dl, DAG, VT, Q, R);
    break;
  case 10:
    emitDivRem10(N0, dl, DAG, VT, Q, R);
    break;
  default:
    llvm_unreachable(
        "performUDivRemCombine: divisor whitelist check above is stale");
  }
  return N->getOpcode() == ISD::UDIV ? Q : R;
}

// Target DAGCombine for path (b) -- see the section header comment above.
// Fires on ISD::UREM at combine time, strictly before legalization would
// otherwise route a non-whitelisted (before this dossier, EVERY) constant
// UREM to the __umodsi3 libcall -- mirrors performMULCombine's interception
// of ISD::MUL ahead of its LibCall action.
SDValue ARCTargetLowering::performURemDigitFoldCombine(
    SDNode *N, DAGCombinerInfo &DCI) const {
  if (Subtarget.hasMPY())
    return SDValue();

  EVT VT = N->getValueType(0);
  if (VT != MVT::i32)
    return SDValue();

  SDValue X = N->getOperand(0);
  SDValue Divisor = N->getOperand(1);
  auto *DivC = dyn_cast<ConstantSDNode>(Divisor);
  if (!DivC || DivC->isOpaque())
    return SDValue();

  uint64_t D = DivC->getZExtValue();
  // ProvenUDivRemWhitelist lookup, DigitFold kind: {7, 15, 255}. Divisor 3
  // is DELIBERATELY absent from the table under this Kind even though
  // 2^2-1==3 -- see the dispatch note on emitURemDigitFold's family above
  // and on the table's definition; it is routed exclusively through
  // performUDivRemCombine/emitDivRem3 instead. Do not extend the table
  // without a matching exhaustive-2^32 proof landing first.
  if (!lookupDivisor(D, DivRemKind::DigitFold))
    return SDValue();

  const MachineFunction &MF = DCI.DAG.getMachineFunction();
  if (MF.getFunction().hasMinSize() || MF.getFunction().hasOptSize())
    return SDValue(); // -Oz/-Os: keep the __umodsi3 libcall.

  SDLoc dl(N);
  SelectionDAG &DAG = DCI.DAG;
  switch (D) {
  case 7:
    return emitURemDigitFold7(X, dl, DAG, VT);
  case 15:
    return emitURemDigitFold15(X, dl, DAG, VT);
  case 255:
    return emitURemDigitFold255(X, dl, DAG, VT);
  default:
    llvm_unreachable(
        "performURemDigitFoldCombine: divisor whitelist check above is stale");
  }
}

//===----------------------------------------------------------------------===//
//  Constant-divisor SIGNED div/rem synthesis (dossier 18, SIGNED phase)
//
//  sdiv/srem by a compile-time-constant divisor of magnitude in {3, 5, 10}
//  (either sign), for cores without a hardware multiplier
//  (!Subtarget.hasMPY()). Reuses the unsigned reciprocal builders
//  (emitDivRem3/5/10) applied to |a| and |C| verbatim -- see the .h file's
//  performSDivRemCombine doc comment for the full derivation. sdiv/srem here
//  are C-style truncating (round-toward-zero) semantics, matching what
//  __divsi3/__modsi3 (the libcall this replaces) already implement.
//
//  Every shipped divisor (+-3, +-5, +-10) and its full signed wrapper
//  (ABS + reciprocal + sign-adjust) was exhaustively verified over all 2^32
//  int32 inputs against native C round-toward-zero `/`/`%` (0 mismatches),
//  including an explicit INT_MIN spot-check for each, in the dossier-18
//  SIGNED PROVE phase before this code was written -- see
//  llvm/test/CodeGen/ARC/arc700eb-sdivmod.ll for the acceptance coverage.
//  Any magnitude outside {3, 5, 10}, or a divisor with no unsigned
//  ReciprocalDivMod whitelist entry, is explicitly OUT OF SCOPE for this cut.
//
//  Cost gate mirrors performUDivRemCombine's exactly: at -Oz/-Os
//  (MinSize/OptSize) both SDIV and SREM decline unconditionally and fall
//  through to the existing Expand -> __divsi3/__modsi3 libcall path.
//===----------------------------------------------------------------------===//

SDValue ARCTargetLowering::performSDivRemCombine(SDNode *N,
                                                 DAGCombinerInfo &DCI) const {
  assert((N->getOpcode() == ISD::SDIV || N->getOpcode() == ISD::SREM) &&
        "performSDivRemCombine: expected ISD::SDIV or ISD::SREM");
  if (Subtarget.hasMPY())
    return SDValue();

  EVT VT = N->getValueType(0);
  if (VT != MVT::i32)
    return SDValue();

  SDValue N0 = N->getOperand(0);
  SDValue Divisor = N->getOperand(1);
  auto *DivC = dyn_cast<ConstantSDNode>(Divisor);
  if (!DivC || DivC->isOpaque())
    return SDValue(); // Non-constant / opaque divisor: fall through to the
                      // existing Expand -> libcall path, unchanged.

  int64_t D = DivC->getSExtValue();
  if (D == 0)
    return SDValue(); // Constant-fold-away-able / UB divide-by-zero: leave
                      // it exactly as-is for the existing lowering to handle.

  bool Cneg = D < 0;
  uint64_t Dm = Cneg ? static_cast<uint64_t>(-D) : static_cast<uint64_t>(D);
  // Reuses the SAME whitelist table performUDivRemCombine consults --
  // magnitude-keyed, so {3, 5, 10} in either sign resolve to the same
  // ReciprocalDivMod entry. Do not extend without a matching exhaustive-2^32
  // SIGNED proof landing first (the dossier's hard gate).
  if (!lookupDivisor(Dm, DivRemKind::ReciprocalDivMod))
    return SDValue(); // Not whitelisted for the reciprocal path.

  // Cost gate: mirror performUDivRemCombine's -Oz/-Os policy exactly (see
  // the section header comment above).
  const MachineFunction &MF = DCI.DAG.getMachineFunction();
  if (MF.getFunction().hasMinSize() || MF.getFunction().hasOptSize())
    return SDValue();

  SDLoc dl(N);
  SelectionDAG &DAG = DCI.DAG;

  // ua = ABS(a); ABS is Legal on this target (ABS(INT_MIN) == INT_MIN, whose
  // bit pattern IS the correct unsigned magnitude 0x80000000). The unsigned
  // reciprocal builders below are already proven correct over the FULL u32
  // range, of which ua's range is a strict subset -- no new unsigned proof
  // obligation here, only the signed wrapper below needed the dedicated
  // exhaustive proof (see section header comment).
  SDValue UA = DAG.getNode(ISD::ABS, dl, VT, N0);
  SDValue UQ, UR;
  switch (Dm) {
  case 3:
    emitDivRem3(UA, dl, DAG, VT, UQ, UR);
    break;
  case 5:
    emitDivRem5(UA, dl, DAG, VT, UQ, UR);
    break;
  case 10:
    emitDivRem10(UA, dl, DAG, VT, UQ, UR);
    break;
  default:
    llvm_unreachable(
        "performSDivRemCombine: divisor whitelist check above is stale");
  }

  SDValue Zero = DAG.getConstant(0, dl, VT);
  if (N->getOpcode() == ISD::SDIV) {
    // q = (a<0) XOR (C<0) ? -uq : uq. C's sign is a compile-time constant,
    // so this collapses to a single SELECT_CC keyed on sign(a) alone: for
    // C>0 negate iff a<0 (SETLT); for C<0 negate iff a>=0 (SETGE). Negation
    // is a SUB from 0 (RSUB), never a multiply.
    SDValue NegUQ = subV(Zero, UQ, dl, DAG, VT);
    ISD::CondCode CC = Cneg ? ISD::SETGE : ISD::SETLT;
    return DAG.getNode(ISD::SELECT_CC, dl, VT, N0, Zero, NegUQ, UQ,
                       DAG.getCondCode(CC));
  }

  // ISD::SREM: C-style truncated remainder always follows the DIVIDEND's
  // sign only (independent of the divisor's sign) -- r = sign(a) * ur,
  // equivalent to `a - q*C` (verified together with the quotient in the
  // exhaustive proof above) but needs no back-multiply at all.
  SDValue NegUR = subV(Zero, UR, dl, DAG, VT);
  return DAG.getNode(ISD::SELECT_CC, dl, VT, N0, Zero, NegUR, UR,
                     DAG.getCondCode(ISD::SETLT));
}

SDValue ARCTargetLowering::PerformDAGCombine(SDNode *N,
                                             DAGCombinerInfo &DCI) const {
  switch (N->getOpcode()) {
  case ISD::MUL:
    return performMULCombine(N, DCI);
  case ISD::UDIV:
    return performUDivRemCombine(N, DCI);
  case ISD::UREM:
    // Path (a) (whitelist {3, 5, 10}) is tried first; if it declines (a
    // divisor outside that whitelist), path (b)'s digit-fold family
    // ({7, 15, 255}) gets a chance. Mirrors the existing OR-node double-try
    // pattern just below (performShl64By1Combine / performBitRevStepCombine)
    // -- each mechanism matches an exact, disjoint divisor set and declines
    // cleanly on any mismatch, so trying both in sequence cannot misfire.
    if (SDValue R = performUDivRemCombine(N, DCI))
      return R;
    return performURemDigitFoldCombine(N, DCI);
  case ISD::SDIV:
  case ISD::SREM:
    return performSDivRemCombine(N, DCI);
  case ISD::BRCOND:
    return performOverflowBrcondCombine(N, DCI);
  case ISD::SELECT:
    return performOverflowSelectCombine(N, DCI);
  case ISD::OR:
    if (SDValue R = performShl64By1Combine(N, DCI))
      return R;
    return performBitRevStepCombine(N, DCI);
  default:
    return {};
  }
}

//===----------------------------------------------------------------------===//
//  Overflow-to-branch/select fusion -- dossier 19
//
//  Rewrite `br i1 (uaddo/usubo A,B).1, bb` / `select i1 (uaddo/usubo A,B).1,
//  T, F` into an equivalent unsigned compare-and-branch / compare-and-select
//  instead of materializing the overflow bit into a 0/1 GPR and re-testing
//  it. See docs/llvm-arc700-optimizations/19-flag-consuming-arithmetic-
//  idioms.md and docs/notes/isa-characterization.md section 5.4.
//
//  The two overflow predicates reduce to a plain unsigned comparison of
//  values this target already compares natively (ISD::SETULT -> the existing
//  ISDCCtoARCCC / BRcc / CMOV paths, which are silicon-validated -- so this
//  introduces NO new hand-coded carry-polarity, the sole class of silent
//  miscompile this whole area risks):
//
//    * UADDO: unsigned (A+B) overflows (carries out) iff the truncated 32-bit
//      sum is strictly less than either addend. So overflow == (Sum <u A),
//      where Sum = A + B. The Sum node produced here also REPLACES the
//      original node's result #0 (the sum) when it is live, so the addend is
//      added exactly once and shared between the wrapped-around value and the
//      overflow test -- the whole point of an add-with-overflow.
//    * USUBO: unsigned (A-B) borrows iff A <u B. The comparison is on the raw
//      operands, independent of the difference; the difference (result #0)
//      is materialized with a plain SUB and shared only when it is live.
//
//  Because the rewrite lands on ISD::BR_CC / ISD::SELECT_CC (both already
//  Custom-lowered for this target) rather than a flag-glued producer/consumer
//  pair, there is NO STATUS32 adjacency constraint: the compare operands are
//  ordinary register values read by BRcc/CMP, so a live sum/difference can be
//  freely scheduled and cross-block-exported with no glue conflict. Overflow
//  nodes whose overflow result is used as a genuine value (stored, returned,
//  or arithmetically combined) are NOT matched here and fall through to the
//  existing Custom value-materializing path (LowerUADDO/LowerUSUBO ->
//  UADDO_PSEUDO/USUBO_PSEUDO), which stays correct for that case.
//===----------------------------------------------------------------------===//

namespace {

// Recognize a fusable overflow test feeding a BRCOND/SELECT condition and
// report the underlying overflow SDValue plus whether the branch/select
// should fire on the OPPOSITE polarity (Invert -- i.e. on "no overflow").
// Two shapes are matched:
//
//   (1) Cond IS DIRECTLY the overflow result: Cond == (uaddo/usubo A,B).1.
//       This is the shape SelectionDAGBuilder constructs for `br i1 %ovf,
//       %trueBB, %falseBB` when %trueBB is NOT the block laid out immediately
//       after the branch (no fallthrough-inversion needed), and always for
//       `select i1 %ovf, T, F` (SELECT's condition is used as-is, with no
//       block-order-dependent inversion trick). Invert = false.
//
//   (2) Cond is `setcc(overflow, C, cc)` with C in {0,1} and cc in
//       {SETEQ,SETNE} testing the overflow bit against a boolean constant.
//       This is what shape (1) becomes whenever the "true" successor is the
//       physically-next block: SelectionDAGBuilder inverts the condition for
//       fallthrough via `xor(overflow, 1)`, and DAGCombiner's own generic
//       `(brcond (xor x, 1)) -> (brcond (setcc x, 1, ne))` canonicalization
//       rewrites that xor into this setcc BEFORE our target hook sees the
//       node -- so the common `if (a+b < a) goto slow;` fallthrough shape
//       arrives in this wrapped form. Both `(ovf != 1)` and `(ovf == 0)`
//       mean "branch when NOT overflow" -> Invert = true; both `(ovf == 1)`
//       and `(ovf != 0)` mean "branch when overflow" -> Invert = false.
//
// The overflow result must be single-use along the peeled chain: the SETCC
// (if present) must be Cond's only definition reaching N, and the overflow
// bit must be the SETCC's (or N's, in shape (1)) only use -- otherwise a
// second consumer of the same overflow bit would still need the materialized
// boolean, defeating the rewrite. Declining is always safe: the original
// node proceeds through the existing value-materializing path. (The
// arithmetic result #0 -- the sum/difference -- MAY be freely used elsewhere;
// only the overflow bit's single-use matters, since the rewrite re-shares
// result #0 via an explicit ADD/SUB.)
static bool matchOverflowCond(SDValue Cond, SDValue &Overflow, bool &Invert) {
  auto isOverflowResult = [](SDValue V) {
    return (V.getOpcode() == ISD::UADDO || V.getOpcode() == ISD::USUBO) &&
           V.getResNo() == 1;
  };

  if (isOverflowResult(Cond)) {
    Overflow = Cond;
    Invert = false;
    return true;
  }

  if (Cond.getOpcode() != ISD::SETCC || !Cond.hasOneUse())
    return false;
  SDValue LHS = Cond.getOperand(0);
  SDValue RHS = Cond.getOperand(1);
  if (!isOverflowResult(LHS) || !LHS.hasOneUse())
    return false;
  auto *C = dyn_cast<ConstantSDNode>(RHS);
  if (!C)
    return false;
  ISD::CondCode CC = cast<CondCodeSDNode>(Cond.getOperand(2))->get();

  if (CC == ISD::SETNE && C->isOne())
    Invert = true; // (ovf != 1) == !ovf
  else if (CC == ISD::SETEQ && C->isZero())
    Invert = true; // (ovf == 0) == !ovf
  else if (CC == ISD::SETEQ && C->isOne())
    Invert = false; // (ovf == 1) == ovf
  else if (CC == ISD::SETNE && C->isZero())
    Invert = false; // (ovf != 0) == ovf
  else
    return false; // Some other constant/cc combination -- not a plain
                  // boolean test; decline rather than guess.

  Overflow = LHS;
  return true;
}

// Build the unsigned compare (LHS, RHS) whose SETULT is exactly the overflow
// predicate of the matched UADDO/USUBO node, and -- when the node's
// arithmetic result #0 (the wrapped sum / the difference) is still live --
// re-materialize it with a plain ADD/SUB and redirect its users there, so the
// single add/sub is shared between the value and the overflow test. Returns
// the SETULT condition code; the caller applies Invert.
static ISD::CondCode buildOverflowCompare(SDValue Overflow, SelectionDAG &DAG,
                                          const SDLoc &dl, SDValue &CmpLHS,
                                          SDValue &CmpRHS) {
  SDValue A = Overflow.getOperand(0);
  SDValue B = Overflow.getOperand(1);
  SDValue ResultVal(Overflow.getNode(), 0); // result #0: sum or difference
  if (Overflow.getOpcode() == ISD::UADDO) {
    // Sum is needed by the compare regardless of whether result #0 is live.
    SDValue Sum = DAG.getNode(ISD::ADD, dl, MVT::i32, A, B);
    if (!ResultVal.use_empty())
      DAG.ReplaceAllUsesOfValueWith(ResultVal, Sum);
    CmpLHS = Sum; // overflow == (Sum <u A)
    CmpRHS = A;
  } else {
    // USUBO: borrow == (A <u B); the difference is only re-shared if live.
    if (!ResultVal.use_empty()) {
      SDValue Diff = DAG.getNode(ISD::SUB, dl, MVT::i32, A, B);
      DAG.ReplaceAllUsesOfValueWith(ResultVal, Diff);
    }
    CmpLHS = A;
    CmpRHS = B;
  }
  return ISD::SETULT;
}

} // end anonymous namespace

SDValue ARCTargetLowering::performOverflowBrcondCombine(
    SDNode *N, DAGCombinerInfo &DCI) const {
  // ISD::BRCOND: (chain, cond, dest), all three explicit here (chain is
  // operand(0) because SDNPHasChain places it first).
  SDValue Chain = N->getOperand(0);
  SDValue Cond = N->getOperand(1);
  SDValue Dest = N->getOperand(2);

  SDValue Overflow;
  bool Invert;
  if (!matchOverflowCond(Cond, Overflow, Invert))
    return SDValue();
  // Cond (whether the raw overflow bit or the peeled setcc) must be this
  // BRCOND's only use of it -- if the same Cond also feeds another
  // branch/select, the boolean stays materialized for that other consumer, so
  // there is nothing to gain and we must not rewrite a value others depend on.
  if (!Cond.hasOneUse())
    return SDValue();

  SDValue A = Overflow.getOperand(0);
  // Explicit VT guard (mirrors performMULCombine's style above) rather than
  // relying on "i32 is currently ARC's only legal scalar type" -- protects
  // against a future subtarget/vector extension routing through this combine.
  if (A.getValueType() != MVT::i32)
    return SDValue();

  SelectionDAG &DAG = DCI.DAG;
  SDLoc dl(N);

  // Reduce the overflow predicate to a native unsigned comparison and re-share
  // the arithmetic result #0 (sum/difference) when it is live. Emit ISD::BR_CC
  // -- Custom-lowered to ARCISD::BRcc (a combined compare-and-branch reading
  // ordinary register operands, no STATUS32 glue) -- so a live sum can be
  // scheduled/exported without any adjacency conflict.
  SDValue CmpLHS, CmpRHS;
  ISD::CondCode CC = buildOverflowCompare(Overflow, DAG, dl, CmpLHS, CmpRHS);
  if (Invert) // branch on "no overflow"
    CC = ISD::getSetCCInverse(CC, MVT::i32); // integer type -> SETULT -> SETUGE
  return DAG.getNode(ISD::BR_CC, dl, MVT::Other, Chain,
                     DAG.getCondCode(CC), CmpLHS, CmpRHS, Dest);
}

SDValue ARCTargetLowering::performOverflowSelectCombine(
    SDNode *N, DAGCombinerInfo &DCI) const {
  // ISD::SELECT: (cond, T, F).
  SDValue Cond = N->getOperand(0);
  SDValue TVal = N->getOperand(1);
  SDValue FVal = N->getOperand(2);

  SDValue Overflow;
  bool Invert;
  if (!matchOverflowCond(Cond, Overflow, Invert))
    return SDValue();
  if (!Cond.hasOneUse())
    return SDValue();

  SDValue A = Overflow.getOperand(0);
  if (A.getValueType() != MVT::i32)
    return SDValue();
  // ARC has one register class (i32); guard the select's own result type
  // explicitly too, mirroring the BRCOND combine's defensiveness.
  if (N->getValueType(0) != MVT::i32)
    return SDValue();

  SelectionDAG &DAG = DCI.DAG;
  SDLoc dl(N);

  // Same reduction as the branch case, landing on ISD::SELECT_CC (Custom ->
  // ARCISD::CMP + CMOV). SETULT selects TVal on overflow; Invert swaps the
  // picked values rather than the compare so the SETULT stays canonical.
  SDValue CmpLHS, CmpRHS;
  ISD::CondCode CC = buildOverflowCompare(Overflow, DAG, dl, CmpLHS, CmpRHS);
  SDValue T = Invert ? FVal : TVal;
  SDValue F = Invert ? TVal : FVal;
  return DAG.getNode(ISD::SELECT_CC, dl, N->getValueType(0), CmpLHS, CmpRHS, T,
                     F, DAG.getCondCode(CC));
}

//===----------------------------------------------------------------------===//
//  Carry-chain fusions (i64<<1, bit-reverse step) -- dossier 24
//
//  docs/llvm-arc700-optimizations/24-carry-chain-and-bit-serial-idioms.md.
//  See the declarations in ARCISelLowering.h for the full rationale; this
//  block only carries the shape-matching detail.
//===----------------------------------------------------------------------===//

namespace {

// If V is exactly `(Opc V2, Amt)` with Amt an exact-match constant, return
// V2; otherwise SDValue(). Used for the SHL-by-1 / SRL-by-31 / SRL-by-1
// shapes below -- every match is an EXACT constant comparison, never a
// range or KnownBits guess, so a mismatch always declines rather than
// misfires.
static SDValue matchShiftByImm(SDValue V, unsigned Opc, uint64_t Amt) {
  if (V.getOpcode() != Opc)
    return SDValue();
  auto *C = dyn_cast<ConstantSDNode>(V.getOperand(1));
  if (!C || C->getZExtValue() != Amt)
    return SDValue();
  return V.getOperand(0);
}

// If V is exactly `(and V2, Mask)`, return V2; otherwise SDValue().
static SDValue matchAndImm(SDValue V, uint64_t Mask) {
  if (V.getOpcode() != ISD::AND)
    return SDValue();
  auto *C = dyn_cast<ConstantSDNode>(V.getOperand(1));
  if (!C || C->getZExtValue() != Mask)
    return SDValue();
  return V.getOperand(0);
}

// Find the (at most one, by SelectionDAG CSE) sibling node
// `(Opc Val, Amt)` among Val's uses and return it, or nullptr. Used to
// locate the "other half" of a carry-chain pair -- e.g. given InLo (the
// SRL(InLo,31) operand from a matched Hi node), find the `(shl InLo, 1)`
// node that is the corresponding Lo result.
static SDNode *findSiblingUse(SDValue Val, unsigned Opc, uint64_t Amt,
                              unsigned OperandNo) {
  for (const SDUse &U : Val.getNode()->uses()) {
    if (U != Val)
      continue; // a different result number of the same multi-result node
    SDNode *User = const_cast<SDNode *>(U.getUser());
    if (User->getOpcode() != Opc || U.getOperandNo() != OperandNo)
      continue;
    auto *C = dyn_cast<ConstantSDNode>(User->getOperand(1 - OperandNo));
    if (C && C->getZExtValue() == Amt)
      return User;
  }
  return nullptr;
}

} // end anonymous namespace

// i64 `shl x, 1` -> asl.f (lo) + rlc (hi), 2 instructions instead of the 4
// generic ExpandShiftByConstant emits. DAGTypeLegalizer::ExpandIntRes_Shift
// takes the ExpandShiftByConstant branch UNCONDITIONALLY for a
// compile-time-constant shift amount, before ever consulting
// TLI.getOperationAction(ISD::SHL_PARTS, ...) -- so a Custom SHL_PARTS hook
// would never fire for this idiom; this DAGCombine on the resulting
// OR(SHL(InHi,1), SRL(InLo,31)) Hi-half shape is the only interception
// point. A variable (non-constant) shift amount never reaches this shape at
// all (ExpandIntRes_Shift takes a different, compare-and-select path for
// that case), so there is nothing for this combine to accidentally
// mis-match on a runtime shift count.
SDValue ARCTargetLowering::performShl64By1Combine(SDNode *N,
                                                   DAGCombinerInfo &DCI) const {
  // ARC_ASL_b_c_f / ARC_RLC_b_c are ARCompact-only encodings (no
  // Predicates=[IsARCompact] gate exists at the raw instruction-def level in
  // ARCARCompactInstrALU.td -- only Pats are normally gated that way -- so
  // an unconditional BuildMI from this MI-level pseudo-expansion would
  // otherwise emit them even for a non-ARCompact subtarget and hard-crash
  // at scheduling-info resolution ("Feature_IsARCompact predicate(s) are
  // not met"), confirmed empirically with `llc -march=arc -mcpu=generic`.
  // RLC/RRC/ASL/LSR are baseline-present on every ARCompact profile this
  // fork targets (isa-characterization.md), so no finer-grained predicate
  // is needed -- just gate on ARCompact-ness itself, mirroring the existing
  // `Subtarget.isARCompact()` guard in LowerSELECT_CC's BTST fold above.
  if (!Subtarget.isARCompact())
    return SDValue();
  if (N->getValueType(0) != MVT::i32)
    return SDValue();
  SDValue Op0 = N->getOperand(0);
  SDValue Op1 = N->getOperand(1);

  SDValue InHi, InLo;
  if ((InHi = matchShiftByImm(Op0, ISD::SHL, 1)))
    InLo = matchShiftByImm(Op1, ISD::SRL, 31);
  else if ((InHi = matchShiftByImm(Op1, ISD::SHL, 1)))
    InLo = matchShiftByImm(Op0, ISD::SRL, 31);
  if (!InHi || !InLo)
    return SDValue();
  if (InHi.getValueType() != MVT::i32 || InLo.getValueType() != MVT::i32)
    return SDValue();

  // Sibling Lo node: `(shl InLo, 1)`. CSE guarantees at most one such SDNode
  // value exists, so this is a structural lookup, not a heuristic scan.
  SDNode *LoNode = findSiblingUse(InLo, ISD::SHL, 1, /*OperandNo=*/0);
  if (!LoNode)
    return SDValue();

  SelectionDAG &DAG = DCI.DAG;
  SDLoc dl(N);
  SDValue Fused = DAG.getNode(ARCISD::SHL64_1, dl,
                              DAG.getVTList(MVT::i32, MVT::i32), InLo, InHi);
  DAG.ReplaceAllUsesOfValueWith(SDValue(LoNode, 0), Fused.getValue(0));
  return Fused.getValue(1); // replaces N (the Hi/OR node)
}

// One bit-reverse step (`y = (y<<1)|(x&1); x >>= 1;`, unrolled) -> lsr.f
// (x) + rlc (y), 2 instructions instead of the ~4 a naive lsr+and+or+asl
// sequence needs. UNLIKE the i64<<1 shape above (mechanically fixed by the
// type legalizer for every target), this exact AND/OR canonical form is not
// guaranteed stable across DAGCombiner passes or compiler versions for
// ordinary front-end-emitted code; declining is always safe here and falls
// through to the generic lowering.
SDValue
ARCTargetLowering::performBitRevStepCombine(SDNode *N,
                                            DAGCombinerInfo &DCI) const {
  // Same ARCompact-only guard as performShl64By1Combine above -- see its
  // comment. ARC_LSR_b_c_f / ARC_RLC_b_c must never be emitted for a
  // non-ARCompact subtarget.
  if (!Subtarget.isARCompact())
    return SDValue();
  if (N->getValueType(0) != MVT::i32)
    return SDValue();
  SDValue Op0 = N->getOperand(0);
  SDValue Op1 = N->getOperand(1);

  SDValue YIn, XIn;
  if ((YIn = matchShiftByImm(Op0, ISD::SHL, 1)))
    XIn = matchAndImm(Op1, 1);
  else if ((YIn = matchShiftByImm(Op1, ISD::SHL, 1)))
    XIn = matchAndImm(Op0, 1);
  if (!YIn || !XIn)
    return SDValue();
  if (YIn.getValueType() != MVT::i32 || XIn.getValueType() != MVT::i32)
    return SDValue();

  // Sibling node: `(srl XIn, 1)`. Same CSE-uniqueness argument as above.
  SDNode *XOutNode = findSiblingUse(XIn, ISD::SRL, 1, /*OperandNo=*/0);
  if (!XOutNode)
    return SDValue();

  SelectionDAG &DAG = DCI.DAG;
  SDLoc dl(N);
  SDValue Fused = DAG.getNode(ARCISD::BITREV_STEP, dl,
                              DAG.getVTList(MVT::i32, MVT::i32), XIn, YIn);
  DAG.ReplaceAllUsesOfValueWith(SDValue(XOutNode, 0), Fused.getValue(0));
  return Fused.getValue(1); // replaces N (the YOut/OR node)
}

// Rewrite `mul x, C` into a bounded chain of add/sub/shl/neg DAG nodes (see
// the synthesizer above) when that is cheaper than the __mulsi3 libcall
// ARC700 would otherwise emit (no hardware multiplier). This DAGCombine
// fires at Level::BeforeLegalizeTypes -- strictly before SelectionDAGLegalize
// would ever turn the LibCall-marked MUL into a call node -- because
// DAGCombiner::combine() only calls TLI.PerformDAGCombine() after the
// generic visit(N) (here, DAGCombiner::visitMUL) has run to completion and
// found nothing to do; with decomposeMulByConstant unconditionally disabled
// (see its definition), visitMUL's own 2-term shape rewrite never fires on
// this target, so every non-trivial constant MUL reaches this hook.
SDValue ARCTargetLowering::performMULCombine(SDNode *N,
                                             DAGCombinerInfo &DCI) const {
  // Never touch MUL when a hardware multiplier is present -- MUL is Legal
  // there and must reach ISel as-is, never rewritten into a scaled-add
  // chain. (Guarding here, independently of the setTargetDAGCombine
  // registration above, is the belt to that call site's suspenders.)
  if (Subtarget.hasMPY())
    return {};

  // Explicit VT guard (mirrors the old decomposeMulByConstant) rather than
  // relying on "i32 is currently ARC's only legal scalar type" -- protects
  // against a future subtarget variant or vector extension silently routing
  // through this combine incorrectly.
  EVT VT = N->getValueType(0);
  if (VT != MVT::i32)
    return {};

  SDValue N0 = N->getOperand(0);
  SDValue N1 = N->getOperand(1);

  SDValue X;
  ConstantSDNode *CN = dyn_cast<ConstantSDNode>(N1);
  if (CN) {
    X = N0;
  } else if ((CN = dyn_cast<ConstantSDNode>(N0))) {
    X = N1;
  } else {
    return {}; // No constant operand -- variable*variable stays a libcall.
  }
  if (CN->isOpaque())
    return {}; // Opaque constants must not be inspected/rewritten.

  int64_t C = CN->getSExtValue();

  std::optional<SynthRecipe> Recipe = synthesizeConstMul(C);
  if (!Recipe)
    return {}; // Nothing found within budget -- fall through to __mulsi3.

  unsigned SynthInstrs = Recipe->Steps.size();

  // Cost threshold: compare against the ACTUAL call-site cost, not an
  // abstract instruction count, and never assume anything about whether
  // __mulsi3's body is "already linked elsewhere" (whole-program information
  // unavailable here, and ignoring it is always conservative-safe -- a
  // synth that is no larger than the local call site can never make THIS
  // call site's bytes larger than the call it replaces).
  //   CallSiteInstrs = 1 (`bl __mulsi3`) +
  //                    1 (MOV_rs12, C fits s12) or 2 (MOV_rlimm, else).
  // Reuses the exact same s12 fold window ARCTTIImpl::materializeCost32 /
  // isLegalAddImmediate already use, so this DAGCombine-time cost model can
  // never drift from the ConstantHoisting-time one.
  unsigned CallSiteInstrs = 1 + (isInt<12>(C) ? 1 : 2);

  const MachineFunction &MF = DCI.DAG.getMachineFunction();
  bool Accept;
  if (MF.getFunction().hasMinSize() || MF.getFunction().hasOptSize()) {
    // -Oz/-Os: bytes are the objective. Ties are resolved in favor of synth
    // -- it strictly dominates the call on every axis bytes don't capture
    // (no blink clobber / possible caller-side spill, no caller-saved
    // register clobber, no call/return latency).
    Accept = SynthInstrs <= CallSiteInstrs;
  } else {
    // -O0/-O1/-O2/-O3: speed-tuned. Accept anything the bounded search
    // found (SynthInstrs <= MaxDepth is trivially true here, since every
    // branch above only ever appends within its remaining depth budget).
    // isa-characterization.md section 8 measures one ALU instruction per
    // clock on this in-order core, so even a full MaxDepth-deep dependent
    // chain (~MaxDepth cycles) is far cheaper than a call's
    // mov+bl+callee-prologue+shift-add-loop+ret.
    Accept = SynthInstrs <= MaxDepth;
  }
  if (!Accept)
    return {};

  SDLoc dl(N);
  return emitRecipe(*Recipe, X, dl, DCI.DAG);
}

// Subsumed by performMULCombine above. Always declining here means
// DAGCombiner::visitMUL's own 2-term (2^N+-1 / 2^N+-2^M) decomposition never
// fires for this target, so every non-trivial constant MUL falls through
// uniformly to performMULCombine's bounded search instead of being stolen
// piecemeal by the generic combine with no way for the target hook to
// improve an already-replaced node. Verified (grep) that DAGCombiner.cpp's
// visitMUL is the ONLY caller of this hook in-tree, so disabling it has no
// other observable effect. Every constant the OLD predicate used to accept
// (2^N+-1 / 2^N+-2^M, after stripping trailing zeros) is proven to reach an
// equal-or-better instruction count under the new search --  see
// docs/llvm-arc700-optimizations/02-constant-multiplication.md's
// acceptance criteria and the FileCheck coverage in
// llvm/test/CodeGen/ARC/arc700eb-scaled-sub.ll.
bool ARCTargetLowering::decomposeMulByConstant(LLVMContext &Context, EVT VT,
                                               SDValue C) const {
  (void)Context;
  (void)VT;
  (void)C;
  return false;
}

//===----------------------------------------------------------------------===//
//  targetShrinkDemandedConstant -- AND/OR/XOR immediate narrowing (idea 2)
//===----------------------------------------------------------------------===//

// Maps an ISD AND/OR/XOR opcode to the corresponding llvm::Instruction
// opcode that ARCTTIImpl::foldsViaBitOp (the single source of truth for
// "does this immediate fold into a 4-byte host instruction with no LIMM")
// expects. Kept local to this translation unit: nothing else needs it.
static unsigned toIRBinOp(unsigned ISDOpc) {
  switch (ISDOpc) {
  case ISD::AND:
    return Instruction::And;
  case ISD::OR:
    return Instruction::Or;
  case ISD::XOR:
    return Instruction::Xor;
  default:
    llvm_unreachable("toIRBinOp: not an AND/OR/XOR opcode");
  }
}

// True when materializing this AND/OR/XOR immediate costs a single 4-byte
// host instruction (fits s12, or matches one of the BSET/BCLR/BMSK
// constant-bit-position shapes) -- i.e. it is already in the cheapest tier
// and there is nothing left for targetShrinkDemandedConstant to win by
// replacing it. Deliberately reuses ARCTTIImpl::foldsViaBitOp (the exact
// predicate ARCTTIImpl::getIntImmCostInst's Instruction::And/Or/Xor case
// already uses) instead of re-deriving the u6/s12/bit-op shapes a second
// time, so the DAGCombine-time notion of "cheap" can never drift from the
// ConstantHoisting-time notion of "cheap".
static bool isFreeALUImm(unsigned ISDOpc, const APInt &V) {
  return V.isSignedIntN(12) || ARCTTIImpl::foldsViaBitOp(toIRBinOp(ISDOpc), V);
}

// See docs/llvm-arc700-optimizations/21-immediate-cost-and-rematerialization.md
// idea 2. SimplifyDemandedBits calls this hook for AND/OR/XOR nodes with a
// constant RHS; we may substitute a different constant Cp for C as long as
// Cp agrees with C on every DEMANDED bit -- i.e. the single non-negotiable
// invariant enforced below is:
//
//     ((Cp xor C) & DemandedBits) == 0
//
// Only bits OUTSIDE DemandedBits may differ between C and Cp. This is
// checked explicitly (the `agrees` lambda) on every candidate before it is
// used, even where the construction also makes it provable algebraically,
// so a bug in candidate *derivation* can only ever cost a missed
// optimization, never a miscompile.
bool ARCTargetLowering::targetShrinkDemandedConstant(
    SDValue Op, const APInt &DemandedBits, const APInt &DemandedElts,
    TargetLoweringOpt &TLO) const {
  (void)DemandedElts; // ARC has no vector register class; always all-ones.

  // Delay past type/op legalization, mirroring ARM/RISCV.
  if (!TLO.LegalOps)
    return false;

  if (Op.getValueType() != MVT::i32)
    return false;

  unsigned Opcode = Op.getOpcode();
  if (Opcode != ISD::AND && Opcode != ISD::OR && Opcode != ISD::XOR)
    return false;

  auto *CN = dyn_cast<ConstantSDNode>(Op.getOperand(1));
  if (!CN || CN->isOpaque())
    return false;
  const APInt &C = CN->getAPIntValue();

  // Redundant with the Step-1 free-tier precheck below for an all-ones XOR
  // mask (it already fits s12), kept explicit so the invariant survives if
  // the free-cost tiers are ever changed independently of this guard.
  if (Opcode == ISD::XOR && C.isAllOnes())
    return false;

  // If C is already in the cheapest tier there is nothing strictly cheaper
  // to find. How we report that matters for termination:
  //
  // TargetLowering::ShrinkDemandedConstant calls this hook FIRST and, if it
  // returns false, immediately falls through to ITS OWN generic clear-only
  // clamp: `if (!C.isSubsetOf(DemandedBits)) NewC = DemandedBits & C;`. That
  // clamp is unconditional and mechanical -- it does not know a bit outside
  // DemandedBits was set DELIBERATELY (by Tier A/B below, on an earlier
  // visit of this same node) to reach a free encoding. If we returned false
  // here whenever C is merely free -- regardless of whether C still has
  // 1-bits outside the CURRENT DemandedBits -- the generic clamp would
  // immediately strip those bits back to (C & DemandedBits) on the very
  // next revisit, which is not guaranteed to still be free; this hook would
  // then widen it right back on the revisit after that, forever. Reproduced
  // concretely while developing this hook: and(zext_i16, 0xFFFF0) with
  // DemandedBits=0xFFFF narrowed Tier A to C=0xFFFFFFF0 (-16, free), but the
  // very next visit's generic clamp reduced it straight back to C=0xFFF0
  // (not free), which this hook then widened back to -16 again -- llc hung.
  //
  // The fix: a free C with no 1-bits outside DemandedBits is one the
  // generic clamp would leave untouched anyway (its own `!C.isSubsetOf(...)`
  // guard is false), so deferring to it is provably a no-op -- safe to
  // return false. A free C that DOES have 1-bits outside DemandedBits can
  // only have gotten that way from this hook's own Tier A/B widening on a
  // prior visit (a freshly-legalized constant is never pre-widened), so we
  // must return true (a no-op "handled" report -- TLO.New is left unset,
  // so no CombineTo happens) to suppress the generic clamp and stop the
  // oscillation. Either branch is a correct "nothing cheaper" answer; the
  // choice between them only controls whether the generic clamp is allowed
  // to run afterward.
  if (isFreeALUImm(Opcode, C))
    return !C.isSubsetOf(DemandedBits);

  auto agrees = [&](const APInt &Cand) -> bool {
    return ((Cand ^ C) & DemandedBits).isZero();
  };

  auto tryUse = [&](const APInt &Cand) -> bool {
    if (!agrees(Cand))
      return false;
    if (!isFreeALUImm(Opcode, Cand))
      return false;
    SDLoc DL(Op);
    SDValue NewC = TLO.DAG.getConstant(Cand, DL, Op.getValueType());
    SDNodeFlags Flags = Op->getFlags();
    if (Opcode == ISD::OR)
      // Cand may set bits beyond C at undemanded positions (that is the
      // only way Tier A can differ from C here, since C was already proven
      // not free above), so the rewritten OR can no longer be assumed
      // bit-disjoint from its other operand even though it is still
      // correct on every demanded bit. Drop a stale `or disjoint` flag
      // rather than let it survive onto a node it no longer describes.
      Flags.setDisjoint(false);
    SDValue NewOp = TLO.DAG.getNode(Opcode, DL, Op.getValueType(),
                                    Op.getOperand(0), NewC, Flags);
    return TLO.CombineTo(Op, NewOp);
  };

  // Tier A (AND/OR/XOR): force every undemanded bit to 1. This is the
  // extremal point that can SET bits the clear-only generic fallback
  // (TargetLowering::ShrinkDemandedConstant's own ShrunkMask = C &
  // DemandedBits, which runs unconditionally when this hook returns false)
  // structurally cannot reach. Covers the s12 sign-extension win common to
  // all three opcodes (the dossier's y & 0x00FFFFF0 example: ExpandedMask =
  // 0x00FFFFF0 | 0xFF000000 = 0xFFFFFFF0 = -16, isSignedIntN(12)) and
  // AND's BCLR shape specifically (a single DEMANDED 0-bit with every other
  // bit -- demanded-1 or undemanded-forced-1 -- ending up 1, i.e. exactly
  // ~(1<<k)). It does NOT reach OR/XOR's BSET/BXOR single-SET-bit shape --
  // that needs the opposite polarity (undemanded bits forced to 0), which
  // is exactly what TargetLowering::ShrinkDemandedConstant's own
  // clear-only clamp (ShrunkMask = C & DemandedBits) already reproduces for
  // free whenever C's demanded bits are already a lone bit -- so no
  // separate tier for it is needed here.
  APInt ExpandedMask = C | ~DemandedBits;
  if (tryUse(ExpandedMask))
    return true;

  // Tier B (AND only): BMSK contiguous-low-mask shape (2^M - 1). Not
  // reachable via ExpandedMask (which forces high undemanded bits to 1, the
  // opposite of what BMSK's high region needs) nor via pure clearing (which
  // forces LOW undemanded bits to 0, the opposite of what BMSK's low region
  // needs) -- it needs its own targeted construction. This is a heuristic
  // guess (sized to the highest demanded set bit of the clear-only
  // baseline), not an algebraic guarantee like ExpandedMask; `agrees()`
  // below is what keeps a wrong guess from ever reaching CombineTo.
  if (Opcode == ISD::AND) {
    APInt ShrunkMask = C & DemandedBits;
    unsigned M = ShrunkMask.getActiveBits();
    if (M > 0 && M < 32) {
      APInt BmskCand = APInt::getLowBitsSet(32, M);
      if (tryUse(BmskCand))
        return true;
    }
  }

  // No cheaper equivalent constant found on the checked candidates. Let the
  // generic clear-only ShrinkDemandedConstant fallback run instead -- it
  // may still narrow C for later combines even when no cost tier changes.
  return false;
}

//===----------------------------------------------------------------------===//
//  Addressing mode description hooks
//===----------------------------------------------------------------------===//

/// Return true if the addressing mode represented by AM is legal for this
/// target, for a load/store of the specified type.
bool ARCTargetLowering::isLegalAddressingMode(const DataLayout &DL,
                                              const AddrMode &AM, Type *Ty,
                                              unsigned AS,
                                              Instruction *I) const {
  // Unscaled reg (+imm folded elsewhere) is always fine -- the plain S9 /
  // LIMM addressing forms are type- and kind-agnostic at this hook.
  if (AM.Scale == 0)
    return true;

  if (AM.Scale != 4)
    return false;

  // Scale==4 models `base + (index << 2)`, which is ONLY selectable as the
  // scaled reg+reg word load `ld.as rA,[rB,rC]` (ARCInstrInfo.td LD_AS_rr,
  // matched off a plain, non-extending `load` DAG node). There is no scaled
  // STORE form and no scaled byte/half form in this ISA -- advertising the
  // mode for those would let LSR/CodeGenPrepare fold an address expression
  // that ISel can never actually select, forcing a real explicit shift+add
  // to reappear later (or worse, silently mis-costing the transform). Every
  // extra condition below exists to keep this hook truthful about what
  // LD_AS_rr can select.
  if (AM.BaseGV || AM.BaseOffs != 0 || !AM.HasBaseReg)
    return false;

  // One generic address space only; ARC has no scaled-addressing story for
  // any other AS (e.g. MMIO/uncached spaces always go through explicit
  // `.di` base+offset forms, never `.as`).
  if (AS != 0)
    return false;

  // Ty must be exactly a 32-bit, naturally-aligned scalar: the scaled load
  // is a full-width, non-extending word access. This hook's signature has
  // no separate Align parameter in this LLVM version, so alignment is
  // approximated from Ty's own ABI alignment -- sufficient here because the
  // only real caller path is a genuine i32/ptr load/store value type, not
  // an arbitrarily-aligned bitcast.
  if (!Ty || !Ty->isSized() || Ty->isVectorTy() || Ty->isAggregateType())
    return false;
  if (DL.getTypeSizeInBits(Ty) != 32)
    return false;
  if (DL.getABITypeAlign(Ty) < Align(4))
    return false;

  // When the originating IR Instruction is known, use it to rule out the
  // cases the DAG pattern structurally cannot select: a STORE (no scaled
  // store form exists) and a volatile/non-unordered-atomic LOAD (the scaled
  // form has no `.di`/ordering-preserving variant, so telling the optimizer
  // it's "free" here would be as unsafe as fusing/reordering it -- see the
  // volatile/atomic rejection in ARCOptAddrMode.cpp for the machine-pass
  // side of the same rule).
  if (I) {
    const auto *LI = dyn_cast<LoadInst>(I);
    if (!LI)
      return false; // StoreInst or anything else: no scaled form exists.
    if (!LI->isUnordered())
      return false; // volatile or atomic-with-ordering: never advertise.
  }
  // I == nullptr: some TTI/cost-model callers omit it. We cannot tell load
  // from store or check volatility here, so stay exactly as strict as the
  // I!=nullptr path on every check we CAN make (Ty/AS/alignment above) and
  // do not relax further -- this intentionally may under-advertise legality
  // for some pure-load cost queries, never over-advertise it for a store.

  return true;
}

bool ARCTargetLowering::allowsMisalignedMemoryAccesses(
    EVT VT, unsigned AddrSpace, Align Alignment,
    MachineMemOperand::Flags Flags, unsigned *Fast) const {
  // ARC700/BCM55030 has no hardware unaligned-access fixup and no
  // STATUS32.AD "unaligned enable" behavior (that assumption was disproved
  // by silicon characterization -- see docs/notes/isa-characterization.md
  // and the deleted comment this replaces in ARCRegisterInfo.cpp).
  // Misaligned word/half-word loads/stores silently clear the low address
  // bits (word: addr & ~3, half-word: addr & ~1) instead of trapping or
  // being fixed up, so an under-aligned multi-byte access reads/writes the
  // wrong location without any error signal. Unconditionally report every
  // misaligned scalar access as neither legal nor fast, for every width and
  // address space, so callers (SelectionDAGBuilder / DAG Legalize / the
  // memcpy-inlining combine) never emit a naturally-misaligned LD/ST and
  // instead peel to byte/half-word operations.
  //
  // This is a pinning override, not a behavior change: TargetLoweringBase's
  // default implementation already returns false unconditionally, and
  // allowsMemoryAccessForAlignment() only calls into this hook once it has
  // already proven Alignment < the type's ABI alignment -- so the aligned
  // fast path (Alignment >= ABI align) never reaches this function and is
  // unaffected. Made explicit so behavior cannot silently change if a
  // future legalization/vectorization feature relies on a friendlier
  // generic default.
  (void)VT;
  (void)AddrSpace;
  (void)Alignment;
  (void)Flags;
  if (Fast)
    *Fast = 0;
  return false;
}

// Allow the generic code to mark calls as tail-call candidates; LowerCall
// applies the conservative eligibility (direct, C/Fast, no stack args).
bool ARCTargetLowering::mayBeEmittedAsTailCall(const CallInst *CI) const {
  return CI->isTailCall();
}

SDValue ARCTargetLowering::LowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const {
  const ARCRegisterInfo &ARI = *Subtarget.getRegisterInfo();
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  MFI.setFrameAddressIsTaken(true);

  EVT VT = Op.getValueType();
  SDLoc dl(Op);
  assert(Op.getConstantOperandVal(0) == 0 &&
         "Only support lowering frame addr of current frame.");
  Register FrameReg = ARI.getFrameRegister(MF);
  return DAG.getCopyFromReg(DAG.getEntryNode(), dl, FrameReg, VT);
}

SDValue ARCTargetLowering::LowerGlobalAddress(SDValue Op,
                                              SelectionDAG &DAG) const {
  const GlobalAddressSDNode *GN = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = GN->getGlobal();
  SDLoc dl(GN);
  int64_t Offset = GN->getOffset();
  SDValue GA = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, Offset);
  return DAG.getNode(ARCISD::GAWRAPPER, dl, MVT::i32, GA);
}

SDValue ARCTargetLowering::LowerConstantPool(SDValue Op,
                                              SelectionDAG &DAG) const {
  ConstantPoolSDNode *CP = cast<ConstantPoolSDNode>(Op);
  SDLoc dl(Op);
  SDValue Res;
  if (CP->isMachineConstantPoolEntry())
    Res = DAG.getTargetConstantPool(CP->getMachineCPVal(), MVT::i32,
                                    CP->getAlign(), CP->getOffset());
  else
    Res = DAG.getTargetConstantPool(CP->getConstVal(), MVT::i32, CP->getAlign(),
                                    CP->getOffset());
  return DAG.getNode(ARCISD::GAWRAPPER, dl, MVT::i32, Res);
}

static SDValue LowerVASTART(SDValue Op, SelectionDAG &DAG) {
  MachineFunction &MF = DAG.getMachineFunction();
  auto *FuncInfo = MF.getInfo<ARCFunctionInfo>();

  // vastart just stores the address of the VarArgsFrameIndex slot into the
  // memory location argument.
  SDLoc dl(Op);
  EVT PtrVT = DAG.getTargetLoweringInfo().getPointerTy(DAG.getDataLayout());
  SDValue FR = DAG.getFrameIndex(FuncInfo->getVarArgsFrameIndex(), PtrVT);
  const Value *SV = cast<SrcValueSDNode>(Op.getOperand(2))->getValue();
  return DAG.getStore(Op.getOperand(0), dl, FR, Op.getOperand(1),
                      MachinePointerInfo(SV));
}

SDValue ARCTargetLowering::LowerOperation(SDValue Op, SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  case ISD::GlobalAddress:
    return LowerGlobalAddress(Op, DAG);
  case ISD::ConstantPool:
    return LowerConstantPool(Op, DAG);
  case ISD::FRAMEADDR:
    return LowerFRAMEADDR(Op, DAG);
  case ISD::SELECT_CC:
    return LowerSELECT_CC(Op, DAG);
  case ISD::BR_CC:
    return LowerBR_CC(Op, DAG);
  case ISD::SIGN_EXTEND_INREG:
    return LowerSIGN_EXTEND_INREG(Op, DAG);
  case ISD::JumpTable:
    return LowerJumpTable(Op, DAG);
  case ISD::BSWAP:
    return LowerBSWAP(Op, DAG);
  case ISD::UADDO:
    return LowerUADDO(Op, DAG);
  case ISD::USUBO:
    return LowerUSUBO(Op, DAG);
  case ISD::SADDO:
    return LowerSADDO(Op, DAG);
  case ISD::SSUBO:
    return LowerSSUBO(Op, DAG);
  case ISD::VASTART:
    return LowerVASTART(Op, DAG);
  case ISD::READCYCLECOUNTER:
    // As of LLVM 3.8, the lowering code insists that we customize it even
    // though we've declared the i32 version as legal. This is because it only
    // thinks i64 is the truly supported version. We've already converted the
    // i64 version to a widened i32.
    assert(Op.getSimpleValueType() == MVT::i32);
    return Op;
  case ISD::CTLZ_ZERO_UNDEF: {
    SDLoc dl(Op);
    EVT VT = Op.getValueType();
    SDValue X = Op.getOperand(0);
    if (Subtarget.hasNorm()) {
      // clz(x) = norm((unsigned)x >> 1) for x != 0 (NORM counts redundant
      // sign bits; shifting in a 0 MSB makes norm equal the leading-zero
      // count). Two instructions: lsr + norm.
      EVT ShVT = getShiftAmountTy(VT, DAG.getDataLayout());
      SDValue Sh =
          DAG.getNode(ISD::SRL, dl, VT, X, DAG.getConstant(1, dl, ShVT));
      return DAG.getNode(ARCISD::NORM, dl, VT, Sh);
    }
    // Hand-lower to the shift-OR + popcount bit-twiddle sequence from
    // Hacker's Delight. We cannot delegate to TargetLowering::expandCTLZ
    // or to plain ISD::CTLZ because both paths eventually construct a
    // CTLZ_ZERO_UNDEF node (expandCTLZ's LegalOrCustom check matches
    // our Custom action), which our Custom handler would re-lower and
    // spin into an infinite recursion.
    unsigned NumBits = VT.getScalarSizeInBits();
    EVT ShVT = getShiftAmountTy(VT, DAG.getDataLayout());
    for (unsigned i = 0; (1U << i) < NumBits; ++i) {
      SDValue Sh = DAG.getConstant(1ULL << i, dl, ShVT);
      X = DAG.getNode(ISD::OR, dl, VT, X,
                      DAG.getNode(ISD::SRL, dl, VT, X, Sh));
    }
    X = DAG.getNOT(dl, X, VT);
    return DAG.getNode(ISD::CTPOP, dl, VT, X);
  }
  case ISD::CTTZ_ZERO_UNDEF: {
    SDLoc dl(Op);
    EVT VT = Op.getValueType();
    SDValue X = Op.getOperand(0);
    SDValue Neg = DAG.getNegative(X, dl, VT);
    SDValue IsolateLow = DAG.getNode(ISD::AND, dl, VT, X, Neg);
    if (Subtarget.hasNorm()) {
      // ctz(x) = 31 - norm((x & -x) >> 1) for x != 0.
      EVT ShVT = getShiftAmountTy(VT, DAG.getDataLayout());
      SDValue Sh = DAG.getNode(ISD::SRL, dl, VT, IsolateLow,
                               DAG.getConstant(1, dl, ShVT));
      SDValue N = DAG.getNode(ARCISD::NORM, dl, VT, Sh);
      return DAG.getNode(ISD::SUB, dl, VT, DAG.getConstant(31, dl, VT), N);
    }
    // ctz(x) = popcount((x & -x) - 1)
    SDValue Mask = DAG.getNode(ISD::SUB, dl, VT, IsolateLow,
                               DAG.getConstant(1, dl, VT));
    return DAG.getNode(ISD::CTPOP, dl, VT, Mask);
  }
  default:
    llvm_unreachable("unimplemented operand");
  }
}
