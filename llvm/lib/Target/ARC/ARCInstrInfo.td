//===- ARCInstrInfo.td - Target Description for ARC --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the ARC instructions in TableGen format.
//
//===----------------------------------------------------------------------===//

include "ARCInstrFormats.td"

//===----------------------------------------------------------------------===//
// Operand Pattern Stuff.
//===----------------------------------------------------------------------===//

// Operand for printing out a condition code.
let PrintMethod = "printCCOperand" in
  def CCOp : PredicateOperand<i32, (ops), (ops)>;

// The "u6" operand of a RRU6-type instruction
let PrintMethod = "printU6" in {
  def u6 : Operand<i32>, ImmLeaf<i32, [{
    return isUInt<6>(Imm);
  }]>;
  def wide_u6 : Operand<i64>, ImmLeaf<i64, [{
    return isUInt<6>(Imm);
  }]>;
}

// ---------------------------------------------------------------------------
// Selection DAG Nodes.
// ---------------------------------------------------------------------------

// Selection DAG types.
def SDT_ARCcmptst : SDTypeProfile<0, 2, [SDTCisSameAs<0, 1>]>;
def SDT_ARCcmov : SDTypeProfile<1, 3, [SDTCisSameAs<0, 1>]>;
def SDT_ARCmov : SDTypeProfile<1, 1, [SDTCisSameAs<0, 1>]>;
def SDT_ARCbrcc : SDTypeProfile<0, 4, []>;
def SDT_ARCBranchLink : SDTypeProfile<0, 1, [SDTCisPtrTy<0>]>;
def SDT_ARCCallSeqStart : SDCallSeqStart<[ SDTCisVT<0, i32>,
                                           SDTCisVT<1, i32> ]>;
def SDT_ARCCallSeqEnd   : SDCallSeqEnd<[ SDTCisVT<0, i32>,
                                         SDTCisVT<1, i32> ]>;

// Global Address.
def ARCGAWrapper : SDNode<"ARCISD::GAWRAPPER", SDT_ARCmov, []>;

// NORM extension: count of redundant leading sign bits. Used by the
// CTLZ/CTTZ custom lowering (clz(x)=norm(x>>1), ctz(x)=31-norm((x&-x)>>1)).
def ARCnorm : SDNode<"ARCISD::NORM", SDT_ARCmov, []>;

// Comparison
def ARCcmp : SDNode<"ARCISD::CMP", SDT_ARCcmptst, [SDNPOutGlue]>;

// Bit test: B AND (1<<C), flags-only (compare-like, dossier 24). Emitted by
// ARCTargetLowering::LowerSELECT_CC in place of ARCcmp when the compared
// value is `(and X, mask)` against 0 under SETEQ/SETNE -- see
// ARCARCompactPatterns.td for the Pats that fold this into btst. RHS carries
// the full mask sub-DAG (constant power-of-2, or `(shl 1, reg)`) so the Pat
// can pattern-match it directly, mirroring BSET/BCLR/BXOR/BMSK.
def ARCbtst : SDNode<"ARCISD::BTST", SDT_ARCcmptst, [SDNPOutGlue]>;

// Flag-recycling compares (dossier 21 idea 3). Both are flags-only,
// glue-producing, and emitted by ARCTargetLowering::LowerSELECT_CC in place
// of ARCcmp -- same shape/discipline as ARCbtst above, and coordinated with
// it (see ARCARCompactPatterns.td): the LIMM-sized shapes these two nodes
// recognize are structurally disjoint from ARCbtst's single-set-bit shape,
// so there is no double-match risk.
//
// ARClsrtest B, K : select when `x <u 2^K` (K = log2 of the compared
// power-of-2, RHS didn't fit an immediate compare form). Lowers to the
// null-destination `lsr.f 0, B, K`, which sets Z = ((B >> K) == 0), i.e.
// exactly the ult predicate. NEVER used for a signed predicate -- see the
// LowerSELECT_CC comment at the call site.
def ARClsrtest : SDNode<"ARCISD::LSRTEST", SDT_ARCcmptst, [SDNPOutGlue]>;

// ARCbmsktest B, K : select when `(x & ((1<<(K+1))-1)) == 0`, i.e. the low
// (K+1) bits of B are all zero (RHS is a contiguous low-bit mask too wide
// for an immediate `and`+`cmp`). Lowers to the null-destination
// `bmsk.f 0, B, K`, which sets Z = ((B & mask) == 0). Valid for both EQ and
// NE against zero (the branch/select consumer picks the CC).
def ARCbmsktest : SDNode<"ARCISD::BMSKTEST", SDT_ARCcmptst, [SDNPOutGlue]>;

// Conditional mov
def ARCcmov : SDNode<"ARCISD::CMOV", SDT_ARCcmov, [SDNPInGlue]>;

// Unsigned add/sub-with-overflow. 2-result target nodes -- unlike
// UADDSAT/USUBSAT/UMIN/UMAX (which reuse upstream's generic PatFrags
// directly, see the UADDSAT_PSEUDO/etc. defs below), ISD::UADDO/USUBO have
// no generic PatFrag anywhere upstream (every target Custom-lowers them in
// C++), so LowerUADDO/LowerUSUBO in ARCISelLowering.cpp build these target
// nodes explicitly and a Pat below matches them into the pseudo. See
// docs/llvm-arc700-optimizations/19-flag-consuming-arithmetic-idioms.md.
def SDT_ARCUAddSubO : SDTypeProfile<2, 2, [SDTCisVT<0, i32>, SDTCisVT<1, i32>,
                                            SDTCisSameAs<0, 2>,
                                            SDTCisSameAs<0, 3>]>;
def ARCuaddo : SDNode<"ARCISD::UADDO", SDT_ARCUAddSubO, []>;
def ARCusubo : SDNode<"ARCISD::USUBO", SDT_ARCUAddSubO, []>;

// Signed add/sub-with-overflow. Same shape as ARCuaddo/ARCusubo above (the
// SDTypeProfile carries no signedness, only 2-in/2-out i32 shape) -- reuse
// SDT_ARCUAddSubO verbatim rather than duplicating it. LowerSADDO/LowerSSUBO
// in ARCISelLowering.cpp build these target nodes explicitly; a Pat below
// matches them into SADDO_PSEUDO/SSUBO_PSEUDO. See docs/llvm-arc700-
// optimizations/19-flag-consuming-arithmetic-idioms.md.
def ARCsaddo : SDNode<"ARCISD::SADDO", SDT_ARCUAddSubO, []>;
def ARCssubo : SDNode<"ARCISD::SSUBO", SDT_ARCUAddSubO, []>;

// Carry-chain fusions: i64 `shl x, 1` and one bit-reverse step (dossier 24,
// docs/llvm-arc700-optimizations/24-carry-chain-and-bit-serial-idioms.md).
// 2-result target nodes, same shape as SDT_ARCUAddSubO above -- everything
// is folded into ONE opaque MI (SHL64_1_PSEUDO / BITREV_STEP_PSEUDO below)
// until ARCExpandPseudos.cpp splits it into an asl.f/lsr.f producer + rlc
// consumer, so no SelectionDAG glue is needed (glue would have to survive
// DAGCombine/legalize/schedule across a 2-node span, which this backend has
// no working STATUS32 precedent for -- see ARCARCompactPatterns.td's RLC
// comment). Constructed ONLY by ARCISelLowering.cpp's
// performShl64By1Combine / performBitRevStepCombine, which pin the shift
// amount to a literal 1 -- never synthesize this from a multi-bit/variable
// shift (isa-characterization.md 5.1: multi-bit barrel .f is not
// flag-identical to the single-bit form).
def SDT_ARCShl64C1 : SDTypeProfile<2, 2, [SDTCisVT<0, i32>, SDTCisVT<1, i32>,
                                           SDTCisSameAs<0, 2>,
                                           SDTCisSameAs<1, 3>]>;
// (Lo, Hi) = ARCshl64c1(InLo, InHi): Lo = InLo<<1, Hi = (InHi<<1)|carry.
def ARCshl64c1 : SDNode<"ARCISD::SHL64_1", SDT_ARCShl64C1, []>;
// (XOut, YOut) = ARCbitrevstep(XIn, YIn): XOut = XIn>>1 (carry = old LSB of
// XIn), YOut = (YIn<<1)|carry. Same profile shape as SDT_ARCShl64C1 (2
// i32 outs, 2 i32 ins); kept as a distinct SDNode name/opcode since it is a
// semantically different fusion (shift-right producer, not shift-left).
def ARCbitrevstep : SDNode<"ARCISD::BITREV_STEP", SDT_ARCShl64C1, []>;

// Fused 64-bit relational compare (dossier 23 Phase 1,
// docs/llvm-arc700-optimizations/23-conditional-compare-chaining.md).
//
// The compare these nodes perform is always UNSIGNED -- $cc is only ever LO or
// HS. A SIGNED i64 compare reaches them too, as the unsigned compare of high
// words its builder has already bit-31-biased into offset binary (see
// biasHiWord in ARCISelLowering.cpp); the bias is in the OPERANDS, so nothing
// here needs to know about it.
//
// Built ONLY by ARCTargetLowering::LowerSETCCCARRY (value form) and
// performSetccCarryBrCombine (branch form), both of which match the exact
// `SETCCCARRY(AHi, BHi, USUBO(ALo,BLo).1, cc)` shape that
// LegalizeIntegerTypes.cpp's IntegerExpandSetCCOperands emits for an i64
// `<`/`>=` once ISD::SETCCCARRY is Legal-or-Custom on i32. Each is folded
// into ONE opaque pseudo (SETCCCARRY_PSEUDO / BRCARRY_p below) that survives
// until ARCExpandPseudos / ARCBranchFinalize, so nothing can be scheduled
// between the `cmp` carry producer and the `sbc.f` carry consumer -- same
// atomic-pseudo discipline as SHL64_1_PSEUDO/UADDO_PSEUDO above, and the
// reason these carry no SelectionDAG glue.
//
// CARRY POLARITY (the sole silent-miscompile risk in this whole area, and a
// point THREE dossiers state INVERTED -- read this, not them): this ARC700
// sets C = BORROW after SUB/CMP/SBC, x86-style, NOT ARM-style.
//
//     a <u b   =>  C = 1  =>  LO/CS (0x05)
//     a >=u b  =>  C = 0  =>  HS/CC (0x06)
//
// Sources, all three cross-checked: the ARCompact ISA Programmer's Reference
// Ch.8 condition-code table ("CS, C, LO | Carry set, lower than (unsigned) |
// C | 0x05"; "CC, NC, HS | Carry clear, higher or same (unsigned) | /C |
// 0x06"), mirrored in docs/isa/06-condition-codes.md Table 85;
// docs/notes/isa-characterization.md section 5.4; and the emulator's ALU
// model (`AluOp::Sub | AluOp::Cmp => // ARC convention: C = borrow (C=1 when
// A < B unsigned)`). It also matches what this backend already SHIPS and what
// silicon already runs -- ARCExpandPseudos.cpp's expandUSUBO selects a borrow
// (`a <u b`) with ARCCC::LO. $cc is LO/HS only -- signed arrives pre-biased,
// see the header note above and biasHiWord in ARCISelLowering.cpp.
//
// SETCCCARRY: (Dst) = ARCsetcccarry(ALo, BLo, AHi, BHi, cc) -- the i32 0/1
// boolean of the 64-bit compare (AHi:ALo) <u/>=u (BHi:BLo).
def SDT_ARCsetcccarry : SDTypeProfile<1, 5, []>;
def ARCsetcccarry : SDNode<"ARCISD::SETCCCARRY", SDT_ARCsetcccarry, []>;

// BRCCCARRY: same compare, consumed directly by a conditional branch, so the
// 0/1 boolean is never materialized. Constraint-free profile, mirroring
// SDT_ARCbrcc below.
def SDT_ARCbrcccarry : SDTypeProfile<0, 6, []>;
def ARCbrcccarry : SDNode<"ARCISD::BRCCCARRY", SDT_ARCbrcccarry, [SDNPHasChain]>;

// Conditional Branch
def ARCbrcc : SDNode<"ARCISD::BRcc", SDT_ARCbrcc, [SDNPHasChain]>;

// Bit-test branches (ARCompact bbit0/bbit1)
// Operands: target, reg, bitpos
def SDT_ARCbbit : SDTypeProfile<0, 3, [SDTCisVT<0, OtherVT>,
                                        SDTCisVT<1, i32>,
                                        SDTCisVT<2, i32>]>;
def ARCbbit0 : SDNode<"ARCISD::BBIT0", SDT_ARCbbit, [SDNPHasChain]>;
def ARCbbit1 : SDNode<"ARCISD::BBIT1", SDT_ARCbbit, [SDNPHasChain]>;

// Direct Call
def ARCBranchLink     : SDNode<"ARCISD::BL",SDT_ARCBranchLink,
                            [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                             SDNPVariadic]>;

// Indirect Call
def ARCJumpLink       : SDNode<"ARCISD::JL",SDT_ARCBranchLink,
                                 [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                                  SDNPVariadic]>;
// Call return
def ret      : SDNode<"ARCISD::RET", SDTNone,
                      [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

// Tail call: jump to the callee (direct) with our frame torn down, so the
// callee returns straight to our caller. One pointer operand = the callee
// address; variadic arg-reg uses + reg-mask attach like a normal call.
def SDT_ARCTcRet : SDTypeProfile<0, 1, [SDTCisPtrTy<0>]>;
def ARCtcreturn : SDNode<"ARCISD::TC_RETURN", SDT_ARCTcRet,
                         [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

// Call sequencing nodes.
// These are target-independent nodes, but have target-specific formats.
def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_ARCCallSeqStart,
                           [SDNPHasChain, SDNPOutGlue]>;
def callseq_end   : SDNode<"ISD::CALLSEQ_END",   SDT_ARCCallSeqEnd,
                           [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

//===----------------------------------------------------------------------===//
// Instruction predicates
//===----------------------------------------------------------------------===//

def HasNorm    :     Predicate<"Subtarget->hasNorm()">;
def HasMPY     :     Predicate<"Subtarget->hasMPY()">;
def HasSEXT    :     Predicate<"Subtarget->hasSEXT()">;
def HasBitScan :     Predicate<"Subtarget->hasBitScan()">;
def HasSwape   :     Predicate<"Subtarget->hasSwape()">;

//===----------------------------------------------------------------------===//
// Instruction Pattern Stuff
//===----------------------------------------------------------------------===//

def imm32 : ImmLeaf<i32, [{
  return (Imm & 0xFFFFFFFF) == Imm;
}]>;

// Addressing modes
def FrameADDR_ri : ComplexPattern<i32, 2, "SelectFrameADDR_ri",
                                  [add, frameindex], []>;
def AddrModeS9 : ComplexPattern<i32, 2, "SelectAddrModeS9", []>;
// base + (index<<2), both registers, for the scaled word load `ld.as`.
// WantsRoot: the matcher needs the root LoadSDNode itself (not just the
// address) to reject volatile/atomic loads -- ld.as has no `.di`/ordering
// variant, so a volatile/MMIO access must never be told this mode applies.
let WantsRoot = 1 in
def AddrModeAS : ComplexPattern<i32, 2, "SelectAddrModeAS", []>;
def AddrModeImm : ComplexPattern<i32, 2, "SelectAddrModeImm", []>;
def AddrModeFar : ComplexPattern<i32, 2, "SelectAddrModeFar", []>;

//===----------------------------------------------------------------------===//
// Instruction Class Templates
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Pseudo Instructions
//===----------------------------------------------------------------------===//

let Defs = [SP], Uses = [SP] in {
def ADJCALLSTACKDOWN : PseudoInstARC<(outs), (ins i32imm:$amt, i32imm:$amt2),
                               "# ADJCALLSTACKDOWN $amt, $amt2",
                               [(callseq_start timm:$amt, timm:$amt2)]>;
def ADJCALLSTACKUP : PseudoInstARC<(outs), (ins i32imm:$amt1, i32imm:$amt2),
                            "# ADJCALLSTACKUP $amt1",
                            [(callseq_end timm:$amt1, timm:$amt2)]>;
}

def GETFI : PseudoInstARC<(outs GPR32:$dst), (ins MEMii:$addr),
                             "pldfi $dst, $addr",
                             [(set GPR32:$dst, FrameADDR_ri:$addr)]>;


def ST_FAR : PseudoInstARC<(outs), (ins GPR32:$dst, MEMrlimm:$addr),
                             "ST_FAR $dst, $addr",
                             [(store GPR32:$dst, AddrModeFar:$addr)]>;

def STH_FAR : PseudoInstARC<(outs), (ins GPR32:$dst, MEMrlimm:$addr),
                             "STH_FAR $dst, $addr",
                             [(truncstorei16 GPR32:$dst, AddrModeFar:$addr)]>;

def STB_FAR : PseudoInstARC<(outs), (ins GPR32:$dst, MEMrlimm:$addr),
                             "STB_FAR $dst, $addr",
                             [(truncstorei8 GPR32:$dst, AddrModeFar:$addr)]>;

// CTLZ/CTTZ pseudos expand to FLS/FFS (ARCv2-only bit-scan instructions) in
// ARCExpandPseudos. Gate behind HasBitScan so ARCompact lowers these via
// libcalls through TargetLowering::LibCall.
let Defs = [STATUS32], Predicates = [HasBitScan] in {
  def CTLZ : PseudoInstARC<(outs GPR32:$A),
                           (ins GPR32:$B),
                           "error.fls $A, $B",
                           [(set GPR32:$A, (ctlz i32:$B))]>;

  def CTTZ : PseudoInstARC<(outs GPR32:$A),
                           (ins GPR32:$B),
                           "error.ffs $A, $B",
                           [(set GPR32:$A, (cttz i32:$B))]>;
}

// The CTLZ/CTTZ pseudos above compute a fully zero-DEFINED result (fls/ffs give
// a defined answer for a zero input), so they are a valid selection target for
// the zero-UNDEF nodes too. TargetLowering marks CTLZ_ZERO_UNDEF /
// CTTZ_ZERO_UNDEF Legal on the bit-scan subtarget, but the pseudos above only
// match the zero-DEFINED generic nodes -- without these two patterns a
// zero-undef node reaches ISel as "Cannot select". Gated behind HasBitScan
// (Predicates only; Pat has no Defs field) so ARCompact keeps its Custom path.
let Predicates = [HasBitScan] in {
  def : Pat<(ctlz_zero_undef i32:$B), (CTLZ i32:$B)>;
  def : Pat<(cttz_zero_undef i32:$B), (CTTZ i32:$B)>;
}

// Unsigned AND signed carry/overflow-consuming arithmetic idioms
// (UADDSAT/USUBSAT/UADDO/USUBO, SADDSAT/SSUBSAT/SADDO/SSUBO, AVGFLOORU).
// Each pseudo bundles a `.f`-form ADD/SUB producer with its conditional-mov
// (or, for AVGFLOORU, RRC) consumer as ONE atomic pre-RA pseudo (mirroring
// the CTLZ/CTTZ mechanism above) so nothing can be scheduled between the
// STATUS32 producer and consumer; ARCExpandPseudos.cpp expands each into its
// real instruction sequence. No `Predicates` gate: ADD/SUB/MOV/mov.cc/rrc are
// baseline ARCompact, always present (unlike CTLZ/CTTZ's HasBitScan gate).
// See docs/llvm-arc700-optimizations/19-flag-consuming-arithmetic-idioms.md
// and docs/notes/isa-characterization.md for the silicon carry/overflow-flag
// facts.
//
// UNSIGNED family: the carry polarity is standard ARCompact (NOT ARM-style):
// after SUB, C=1 means BORROW (a<b unsigned) and C=0 means no borrow (a>=b);
// after ADD, C=1 is the unsigned carry-out. The full per-idiom .c/.cc
// selection and its silicon derivation live in the polarity comment above
// expandUADDSAT() in ARCExpandPseudos.cpp, which the expansions rely on.
// (UMIN/UMAX are left to generic Expand -- a Legal pseudo for them regressed
// .text; see ARCISelLowering.cpp.)
//
// SIGNED family (SADDSAT/SSUBSAT/SADDO/SSUBO): keyed off STATUS32.V, set by
// `.f`-form ADD/SUB on SIGNED overflow -- unambiguous for both producers,
// unlike carry. Consumed via the VS (0x7) condition code, never LO/HS.
// SADDSAT/SSUBSAT additionally need a data-dependent clamp limit
// (INT_MAX/INT_MIN, keyed off the sign of the first operand); that limit is
// built with plain (non-`.f`) ASR/MOV/LSR/XOR entirely BEFORE the atomic
// producer/consumer pair, so the flag-adjacency discipline below only ever
// has to hold across the final two real instructions of each expansion. See
// the polarity/limit-construction comment above expandSADDSAT() in
// ARCExpandPseudos.cpp.
//
// AVGFLOORU is UNSIGNED-only (RRC injects the raw carry bit, not a sign) and
// needs no clamp -- see the RRC comment in ARCARCompactPatterns.td and
// expandAVGFLOORU() in ARCExpandPseudos.cpp.
let Defs = [STATUS32] in {
  def UADDSAT_PSEUDO : PseudoInstARC<(outs GPR32:$Dst),
                           (ins GPR32:$A, GPR32:$B),
                           "# UADDSAT_PSEUDO $Dst, $A, $B",
                           [(set GPR32:$Dst, (uaddsat i32:$A, i32:$B))]>;

  def USUBSAT_PSEUDO : PseudoInstARC<(outs GPR32:$Dst),
                           (ins GPR32:$A, GPR32:$B),
                           "# USUBSAT_PSEUDO $Dst, $A, $B",
                           [(set GPR32:$Dst, (usubsat i32:$A, i32:$B))]>;

  def UADDO_PSEUDO : PseudoInstARC<(outs GPR32:$Sum, GPR32:$Ovf),
                           (ins GPR32:$A, GPR32:$B),
                           "# UADDO_PSEUDO $Sum, $Ovf, $A, $B",
                           [(set GPR32:$Sum, GPR32:$Ovf,
                                 (ARCuaddo i32:$A, i32:$B))]>;

  def USUBO_PSEUDO : PseudoInstARC<(outs GPR32:$Diff, GPR32:$Ovf),
                           (ins GPR32:$A, GPR32:$B),
                           "# USUBO_PSEUDO $Diff, $Ovf, $A, $B",
                           [(set GPR32:$Diff, GPR32:$Ovf,
                                 (ARCusubo i32:$A, i32:$B))]>;

  def SADDSAT_PSEUDO : PseudoInstARC<(outs GPR32:$Dst),
                           (ins GPR32:$A, GPR32:$B),
                           "# SADDSAT_PSEUDO $Dst, $A, $B",
                           [(set GPR32:$Dst, (saddsat i32:$A, i32:$B))]>;

  def SSUBSAT_PSEUDO : PseudoInstARC<(outs GPR32:$Dst),
                           (ins GPR32:$A, GPR32:$B),
                           "# SSUBSAT_PSEUDO $Dst, $A, $B",
                           [(set GPR32:$Dst, (ssubsat i32:$A, i32:$B))]>;

  def SADDO_PSEUDO : PseudoInstARC<(outs GPR32:$Sum, GPR32:$Ovf),
                           (ins GPR32:$A, GPR32:$B),
                           "# SADDO_PSEUDO $Sum, $Ovf, $A, $B",
                           [(set GPR32:$Sum, GPR32:$Ovf,
                                 (ARCsaddo i32:$A, i32:$B))]>;

  def SSUBO_PSEUDO : PseudoInstARC<(outs GPR32:$Diff, GPR32:$Ovf),
                           (ins GPR32:$A, GPR32:$B),
                           "# SSUBO_PSEUDO $Diff, $Ovf, $A, $B",
                           [(set GPR32:$Diff, GPR32:$Ovf,
                                 (ARCssubo i32:$A, i32:$B))]>;

  def AVGFLOORU_PSEUDO : PseudoInstARC<(outs GPR32:$Dst),
                           (ins GPR32:$A, GPR32:$B),
                           "# AVGFLOORU_PSEUDO $Dst, $A, $B",
                           [(set GPR32:$Dst, (avgflooru i32:$A, i32:$B))]>;

  // Fused i64 unsigned compare, value form (dossier 23 Phase 1). Same atomic
  // pre-RA pseudo mechanism as UADDO_PSEUDO above: ARCExpandPseudos
  // (addPreRegAlloc, i.e. after the pre-RA scheduler) splits this into
  //     cmp   ALo, BLo        ; C = borrow(lo)
  //     sbc.f 0, AHi, BHi     ; C = borrow of the full 64-bit subtract
  //     mov   Zero, 0
  //     mov.$cc Dst, 1        ; $cc = LO (a <u b) or HS (a >=u b)
  // so the pre-RA scheduler can only move the whole pseudo and can never
  // insert a flag writer between the `cmp` producer and the `sbc.f` consumer.
  // (The `mov Zero,0` between the sbc.f and the mov.$cc is non-`.f` and does
  // not touch STATUS32 -- exactly the shape expandUSUBO already ships.)
  // $cc is LO/HS only -- the compare is always unsigned, signed having been
  // bit-31-biased into offset binary by ARCISelLowering.cpp's biasHiWord
  // before it ever gets here.
  def SETCCCARRY_PSEUDO : PseudoInstARC<(outs GPR32:$Dst),
                           (ins GPR32:$ALo, GPR32:$BLo, GPR32:$AHi,
                                GPR32:$BHi, ccond:$cc),
                           "# SETCCCARRY_PSEUDO $Dst, $ALo, $BLo, $AHi, $BHi, $cc",
                           [(set GPR32:$Dst,
                                 (ARCsetcccarry i32:$ALo, i32:$BLo, i32:$AHi,
                                                i32:$BHi, imm32:$cc))]>;
}

// Carry-chain fusions for i64<<1 and the bit-reverse step (dossier 24,
// docs/llvm-arc700-optimizations/24-carry-chain-and-bit-serial-idioms.md).
// Exact same atomic-pseudo mechanism as UADDO_PSEUDO/USUBO_PSEUDO above:
// bundle a `.f`-form ASL/LSR carry producer with its RLC consumer as ONE
// pre-RA pseudo so the pre-RA scheduler (which runs before
// ARCExpandPseudos, see ARCTargetMachine.cpp's addPreRegAlloc) can only
// move the whole pseudo, never insert something between the two real
// instructions it expands to. ARCExpandPseudos.cpp's expandSHL64_1 /
// expandBitRevStep emit the two real instructions back-to-back with
// nothing else built between them, so they land MBB-adjacent at creation
// time and stay that way (no later pass reorders within a basic block).
// PINNED to a literal 1-bit shift: these pseudos are constructed ONLY by
// ARCISelLowering.cpp's performShl64By1Combine / performBitRevStepCombine,
// which match an exact SHL-by-1 (and, for the bit-reverse step, AND-by-1 /
// SRL-by-1) shape -- never a multi-bit or variable shift
// (isa-characterization.md 5.1).
let Defs = [STATUS32] in {
  def SHL64_1_PSEUDO : PseudoInstARC<(outs GPR32:$Lo, GPR32:$Hi),
                           (ins GPR32:$InLo, GPR32:$InHi),
                           "# SHL64_1_PSEUDO $Lo, $Hi, $InLo, $InHi",
                           [(set GPR32:$Lo, GPR32:$Hi,
                                 (ARCshl64c1 i32:$InLo, i32:$InHi))]>;

  def BITREV_STEP_PSEUDO : PseudoInstARC<(outs GPR32:$XOut, GPR32:$YOut),
                           (ins GPR32:$XIn, GPR32:$YIn),
                           "# BITREV_STEP_PSEUDO $XOut, $YOut, $XIn, $YIn",
                           [(set GPR32:$XOut, GPR32:$YOut,
                                 (ARCbitrevstep i32:$XIn, i32:$YIn))]>;
}

//===----------------------------------------------------------------------===//
// Instruction Generation multiclasses.
// Generate many variants of a single instruction with a single defining
// multiclass.  These classes do not contain Selection DAG patterns.
//===----------------------------------------------------------------------===//

// Generic 3 operand binary instructions (i.e., add r0, r1, r2).
multiclass ArcBinaryInst<bits<5> major, bits<6> mincode,
                       string opasm, bit Commutable> {
  // 3 register variant.
  def _rrr : F32_DOP_RR<major, mincode, 0, (outs GPR32:$A),
                        (ins GPR32:$B, GPR32:$C),
                        !strconcat(opasm, "\t$A, $B, $C"),
                        []>
  { let isCommutable = Commutable; }
  def _f_rrr : F32_DOP_RR<major, mincode, 1, (outs GPR32:$A),
                          (ins GPR32:$B, GPR32:$C),
                          !strconcat(opasm, ".f\t$A, $B, $C"),
                          []>
  { let Defs = [STATUS32]; }

  // 2 register with unsigned 6-bit immediate variant.
  def _rru6 : F32_DOP_RU6<major, mincode, 0, (outs GPR32:$A),
                          (ins GPR32:$B, immU6:$U6),
                          !strconcat(opasm, "\t$A, $B, $U6"),
                          []>;
  def _f_rru6 : F32_DOP_RU6<major, mincode, 1, (outs GPR32:$A),
                            (ins GPR32:$B, immU6:$U6),
                            !strconcat(opasm, ".f\t$A, $B, $U6"),
                            []>
  { let Defs = [STATUS32]; }

  def _cc_rru6 : F32_DOP_CC_RRU6<major, mincode, 0, (outs GPR32:$A),
                                 (ins immU6:$U6, ccond:$cc, GPR32:$B),
                                 !strconcat(opasm, ".$cc\t$A, $B, $U6"),
                                 []> {
                                   let Uses = [STATUS32];
                                   let Constraints = "$A = $B";
                                 }

  def _cc_f_rru6 : F32_DOP_CC_RRU6<major, mincode, 1, (outs GPR32:$A),
                                   (ins immU6:$U6, ccond:$cc, GPR32:$B),
                                   !strconcat(opasm, ".$cc.f\t$A, $B, $U6"),
                                   []> {
                                     let Defs = [STATUS32];
                                     let Uses = [STATUS32];
                                     let Constraints = "$A = $B";
                                   }

  // 2 register with 32-bit immediate variant.
  def _rrlimm : F32_DOP_RLIMM<major, mincode, 0,
                              (outs GPR32:$A),
                              (ins GPR32:$B, i32imm:$LImm),
                              !strconcat(opasm, "\t$A, $B, $LImm"),
                              []>;
  def _f_rrlimm : F32_DOP_RLIMM<major, mincode, 1,
                                (outs GPR32:$A),
                                (ins GPR32:$B, i32imm:$LImm),
                                !strconcat(opasm, ".f\t$A, $B, $LImm"),
                                []>
  { let Defs = [STATUS32]; }

  // 2 matched-register with signed 12-bit immediate variant (add r0, r0, -1).
  def _rrs12 : F32_DOP_RS12<major, mincode, 0,
                            (outs GPR32:$B),
                            (ins GPR32:$in, immS<12>:$S12),
                            !strconcat(opasm, "\t$B, $in, $S12"),
                            []>
  { let Constraints = "$B = $in"; }
  def _f_rrs12 : F32_DOP_RS12<major, mincode, 1,
                              (outs GPR32:$B),
                              (ins GPR32:$in, immS<12>:$S12),
                              !strconcat(opasm, ".f\t$B, $in, $S12"),
                              []>
  { let Constraints = "$B = $in"; let Defs = [STATUS32]; }
}

// Special multivariant GEN4 DOP format instruction that take 2 registers.
// This is the class that is used for various comparison instructions.
multiclass ArcSpecialDOPInst<bits<6> subop, string opasm, bit F> {
  def _rr : F32_DOP_RR<0b00100, subop, F, (outs), (ins GPR32:$B, GPR32:$C),
               !strconcat(opasm, "\t$B, $C"),
               []>
  { let A = 0; }

  def _ru6 : F32_DOP_RU6<0b00100, subop, F, (outs), (ins GPR32:$B, i32imm:$U6),
               !strconcat(opasm, "\t$B, $U6"),
               []>
  { let A = 0; }

  def _rlimm : F32_DOP_RLIMM<0b00100, subop, F, (outs),
               (ins GPR32:$B, i32imm:$LImm),
               !strconcat(opasm, "\t$B, $LImm"),
               []>
  { let A = 0; }

  // Signed 12-bit immediate compare form (cmp B, s12). No dest, B read-only,
  // so no $B=$in constraint (F32_DOP_RS12 has no A field).
  def _rs12 : F32_DOP_RS12<0b00100, subop, F, (outs),
               (ins GPR32:$B, immS<12>:$S12),
               !strconcat(opasm, "\t$B, $S12"),
               []>;
}

// Generic 2-operand unary instructions.
multiclass ArcUnaryInst<bits<5> major, bits<6> subop,
                        string opasm> {
  def _rr : F32_SOP_RR<major, subop, 0, (outs GPR32:$B), (ins GPR32:$C),
                       !strconcat(opasm, "\t$B, $C"), []>;

  def _f_rr : F32_SOP_RR<major, subop, 1, (outs GPR32:$B), (ins GPR32:$C),
                       !strconcat(opasm, ".f\t$B, $C"), []>
  { let Defs = [STATUS32]; }
}


multiclass ArcBinaryGEN4Inst<bits<6> mincode, string opasm, bit Commutable = 0> :
  ArcBinaryInst<0b00100, mincode, opasm, Commutable>;
multiclass ArcBinaryEXT5Inst<bits<6> mincode, string opasm> :
  ArcBinaryInst<0b00101, mincode, opasm, 0>;

multiclass ArcUnaryGEN4Inst<bits<6> mincode, string opasm> :
  ArcUnaryInst<0b00100, mincode, opasm>;
multiclass ArcUnaryEXT5Inst<bits<6> mincode, string opasm> :
  ArcUnaryInst<0b00101, mincode, opasm>;

// Pattern generation for different instruction variants.
multiclass MultiPat<SDPatternOperator InFrag,
               Instruction RRR, Instruction RRU6, Instruction RRLImm> {
  def _rrr : Pat<(InFrag i32:$B, i32:$C), (RRR i32:$B, i32:$C)>;
  def _rru6 : Pat<(InFrag i32:$B, immU6:$U6), (RRU6 i32:$B, immU6:$U6)>;
  def _rrlimm : Pat<(InFrag i32:$B, imm32:$LImm), (RRLImm i32:$B, imm32:$LImm)>;
}

// NOTE: This could be specialized later with a custom `PrintMethod` for
//       displaying the aux register name. E.g. `[%count0]` instead of [33].
def AuxReg : Operand<i32>;

def LR_rs12 : F32_SOP_RS12<0b00100, 0b101010, 0,
                           (outs GPR32:$B), (ins AuxReg:$S12),
                           "lr\t$B, [$S12]", []>;
def LR_ru6 : F32_SOP_RU6<0b00100, 0b101010, 0,
                         (outs GPR32:$B), (ins AuxReg:$U6),
                         "lr\t$B, [$U6]", []>;

def: Pat<(i32 readcyclecounter), (LR_rs12 0x21) >;  // read timer

// ---------------------------------------------------------------------------
// Instruction definitions and patterns for 3 operand binary instructions.
// ---------------------------------------------------------------------------

// Definitions for 3 operand binary instructions.
defm ADD : ArcBinaryGEN4Inst<0b000000, "add",1>;
defm SUB : ArcBinaryGEN4Inst<0b000010, "sub">;
defm SUB1 : ArcBinaryGEN4Inst<0b010111, "sub1">;
defm SUB2 : ArcBinaryGEN4Inst<0b011000, "sub2">;
defm SUB3 : ArcBinaryGEN4Inst<0b011001, "sub3">;
defm RSUB : ArcBinaryGEN4Inst<0b001110, "rsub">;
defm OR  : ArcBinaryGEN4Inst<0b000101, "or",1>;
defm AND : ArcBinaryGEN4Inst<0b000100, "and",1>;
defm XOR : ArcBinaryGEN4Inst<0b000111, "xor",1>;
defm MAX : ArcBinaryGEN4Inst<0b001000, "max",1>;
defm MIN : ArcBinaryGEN4Inst<0b001001, "min",1>;
defm ASL : ArcBinaryEXT5Inst<0b000000, "asl">;
defm LSR : ArcBinaryEXT5Inst<0b000001, "lsr">;
defm ASR : ArcBinaryEXT5Inst<0b000010, "asr">;
defm ROR : ArcBinaryEXT5Inst<0b000011, "ror">;
let Predicates = [HasMPY] in {
defm MPY  : ArcBinaryGEN4Inst<0b011010, "mpy",1>;
defm MPYM : ArcBinaryGEN4Inst<0b011011, "mpym",1>;
defm MPYMU : ArcBinaryGEN4Inst<0b011100, "mpymu",1>;
}
defm SETEQ : ArcBinaryGEN4Inst<0b111000, "seteq",1>;
let Uses=[STATUS32], isAsCheapAsAMove=0, isReMaterializable=0 in {
  defm ADC : ArcBinaryGEN4Inst<0b000001, "adc",1>;
  defm SBC : ArcBinaryGEN4Inst<0b000011, "sbc">;

  // `sbc.f 0,B,C` -- subtract-with-borrow into the ARCompact NULL destination.
  // Computes (B - C - C_flag), DISCARDS the difference, and writes STATUS32.
  // The high half of a fused 64-bit unsigned compare: with C already holding
  // the low half's borrow (from a preceding `cmp ALo,BLo`), this leaves
  // C = borrow of the full 64-bit subtract, i.e. C = (A <u B). Emitted only
  // by ARCExpandPseudos::expandSETCCCARRY and ARCBranchFinalize's BRCARRY_p
  // expansion (dossier 23 Phase 1).
  //
  // *** A = 62, NOT 0. *** r62 is the ARCompact null-destination encoding:
  // "When a destination register is set to r62, there is no destination for
  // the result so results are discarded. Any flag updates will still occur
  // according to the set flags directive (.F or implicit)" -- ISA Programmer's
  // Reference, mirrored in docs/isa/16-operand-formats.md. The `0` in the
  // ISA's `SUB<.f> 0,B,C` assembler syntax IS that r62, not a literal zero.
  //
  // Do NOT copy ArcSpecialDOPInst's `let A = 0;` here. That works for CMP only
  // because CMP's sub-opcode (0x0C) is inherently non-writing, so its A field
  // is a don't-care. SBC *does* write its destination, so `A = 0` names r0 --
  // the return-value / first-argument register -- and silently clobbers it.
  // Byte-verified with the workshop's authoritative big-endian ARC
  // disassembler (llvm-objdump misdecodes big-endian ARC and must not be used
  // for this):
  //     0x200380BE  (A=62)  ->  sbc.f 0x0, r0, r2     <- correct, null dest
  //     0x20038080  (A=0)   ->  sbc.f r0, r0, r2      <- clobbers r0
  // Uses=[STATUS32] (inherited from the enclosing `let`) is load-bearing: SBC
  // READS the carry-in. Defs=[STATUS32] comes from F=1 below.
  let Defs = [STATUS32] in
  def SBC_f_null_rrr : F32_DOP_RR<0b00100, 0b000011, 1, (outs),
                                  (ins GPR32:$B, GPR32:$C),
                                  "sbc.f\t0, $B, $C", []>
  { let A = 62; }
}

// Patterns for 3 operand binary instructions.
defm : MultiPat<add, ADD_rrr, ADD_rru6, ADD_rrlimm>;
defm : MultiPat<sub, SUB_rrr, SUB_rru6, SUB_rrlimm>;
defm : MultiPat<or, OR_rrr, OR_rru6, OR_rrlimm>;
defm : MultiPat<and, AND_rrr, AND_rru6, AND_rrlimm>;
defm : MultiPat<xor, XOR_rrr, XOR_rru6, XOR_rrlimm>;
defm : MultiPat<smax, MAX_rrr, MAX_rru6, MAX_rrlimm>;
defm : MultiPat<smin, MIN_rrr, MIN_rru6, MIN_rrlimm>;
defm : MultiPat<shl, ASL_rrr, ASL_rru6, ASL_rrlimm>;
defm : MultiPat<srl, LSR_rrr, LSR_rru6, LSR_rrlimm>;
defm : MultiPat<sra, ASR_rrr, ASR_rru6, ASR_rrlimm>;
defm : MultiPat<rotr, ROR_rrr, ROR_rru6, ROR_rrlimm>;
let Predicates = [HasMPY] in {
defm : MultiPat<mul, MPY_rrr, MPY_rru6, MPY_rrlimm>;
defm : MultiPat<mulhs, MPYM_rrr, MPYM_rru6, MPYM_rrlimm>;
defm : MultiPat<mulhu, MPYMU_rrr, MPYMU_rru6, MPYMU_rrlimm>;
}

defm : MultiPat<addc, ADD_f_rrr, ADD_f_rru6, ADD_f_rrlimm>;
defm : MultiPat<adde, ADC_f_rrr, ADC_f_rru6, ADC_f_rrlimm>;
defm : MultiPat<subc, SUB_f_rrr, SUB_f_rru6, SUB_f_rrlimm>;
defm : MultiPat<sube, SBC_f_rrr, SBC_f_rru6, SBC_f_rrlimm>;

// Signed 12-bit immediate ALU forms (ARCompact `op B,B,s12`, dest==src1).
// Cover -2048..-1 and 64..2047 in a single 4-byte insn. Without them a
// negative/medium constant materializes via an 8-byte `op B,B,limm` or a
// `mov rN,C; op` pair. immU6 (0..63) keeps priority via the existing _rru6
// MultiPat entry; immS12NotU6 excludes that range so the two never overlap.
// AddedComplexity prefers the 4-byte s12 form over the 8-byte limm form.
def immS12NotU6 : PatLeaf<(imm), [{
  int64_t V = N->getSExtValue();
  return isInt<12>(V) && !isUInt<6>(V);
}]>;
let AddedComplexity = 2 in {
def : Pat<(add  i32:$B, immS12NotU6:$S12), (ADD_rrs12 i32:$B, immS12NotU6:$S12)>;
def : Pat<(sub  i32:$B, immS12NotU6:$S12), (SUB_rrs12 i32:$B, immS12NotU6:$S12)>;
def : Pat<(or   i32:$B, immS12NotU6:$S12), (OR_rrs12  i32:$B, immS12NotU6:$S12)>;
def : Pat<(and  i32:$B, immS12NotU6:$S12), (AND_rrs12 i32:$B, immS12NotU6:$S12)>;
def : Pat<(xor  i32:$B, immS12NotU6:$S12), (XOR_rrs12 i32:$B, immS12NotU6:$S12)>;
def : Pat<(smax i32:$B, immS12NotU6:$S12), (MAX_rrs12 i32:$B, immS12NotU6:$S12)>;
def : Pat<(smin i32:$B, immS12NotU6:$S12), (MIN_rrs12 i32:$B, immS12NotU6:$S12)>;
// C - x (reverse subtract): rsub B,B,imm computes imm - B. u6 covers 0..63,
// s12 covers the rest of -2048..2047; without these `C - x` is mov+sub.
def : Pat<(sub immU6:$U6,        i32:$B), (RSUB_rru6  i32:$B, immU6:$U6)>;
def : Pat<(sub immS12NotU6:$S12, i32:$B), (RSUB_rrs12 i32:$B, immS12NotU6:$S12)>;
}

// ---------------------------------------------------------------------------
// Unary Instruction definitions.
// ---------------------------------------------------------------------------
// General unary instruction definitions.
// SEXB/SEXH are ARCv2 base ISA. ARCompact (ARC600/ARC700) does not include
// them — the Synopsys binutils rejects both mnemonics for -mcpu=arc700.
let Predicates = [HasSEXT] in {
defm SEXB : ArcUnaryGEN4Inst<0b000101, "sexb">;
defm SEXH : ArcUnaryGEN4Inst<0b000110, "sexh">;
}

// Extension unary instruction definitions.
// FFS/FLS are ARCv2 only — ARCompact lowers CTLZ/CTTZ via libcalls.
let Predicates = [HasBitScan] in {
defm FFS : ArcUnaryEXT5Inst<0b010010, "ffs">;
defm FLS : ArcUnaryEXT5Inst<0b010011, "fls">;
}

let Predicates=[HasNorm] in {
  defm NORM  : ArcUnaryEXT5Inst<0b000001,"norm">;
  defm NORMH : ArcUnaryEXT5Inst<0b001000,"normh">;
  def : Pat<(ARCnorm i32:$C), (NORM_rr i32:$C)>;
}

// General Unary Instruction fragments.
let Predicates = [HasSEXT] in {
def : Pat<(sext_inreg i32:$a, i8), (SEXB_rr i32:$a)>;
def : Pat<(sext_inreg i32:$a, i16), (SEXH_rr i32:$a)>;
}

// Comparison instruction definition
let isCompare = 1, Defs = [STATUS32] in {
defm CMP : ArcSpecialDOPInst<0b001100, "cmp", 1>;
}

def cmp : PatFrag<(ops node:$op1, node:$op2), (ARCcmp $op1, $op2)>;
defm : MultiPat<cmp, CMP_rr, CMP_ru6, CMP_rlimm>;
// Signed 12-bit immediate compare (cmp x, negC / medium C) in 4 bytes vs limm.
let AddedComplexity = 2 in
def : Pat<(cmp i32:$B, immS12NotU6:$S12), (CMP_rs12 i32:$B, immS12NotU6:$S12)>;

// ---------------------------------------------------------------------------
// MOV instruction and variants (conditional mov).
// ---------------------------------------------------------------------------
let isReMaterializable = 1, isAsCheapAsAMove = 1, isMoveImm = 1 in {
def MOV_rs12 : F32_DOP_RS12<0b00100, 0b001010, 0,
                 (outs GPR32:$B), (ins immS<12>:$S12),
                 "mov\t$B, $S12",
                 [(set GPR32:$B, immS<12>:$S12)]>;
}

// CONST32: materialize a 32-bit INTEGER constant that does not fit MOV_rs12
// via a cheap seed+shift chain instead of the 8-byte MOV_rlimm (4-byte host
// + 4-byte LIMM word). Selected only when ARCConstantMaterialization.h's
// synthesizeConst32() finds a recipe strictly cheaper than 8 bytes -- see
// ARCISelDAGToDAG.cpp's ISD::Constant case. Expanded POST-register-
// allocation, by ARCInstrInfo::expandPostRAPseudo (ARCInstrInfo.cpp) --
// deliberately NOT by the pre-RA ARCExpandPseudos pass -- so the pseudo is
// still alive, as a single register-free-input instruction, when the
// register allocator decides whether to rematerialize or spill it.
// (Expanding earlier turns it into ordinary instructions before that
// decision is ever made, silently defeating isReMaterializable.)
//
// dst is constrained to the compact GPR_S class (R0-R3, R12-R15), NOT the
// full GPR32 -- this is what makes the post-RA expansion self-contained:
// by the time expandPostRAPseudo runs, $dst already names a concrete
// physical register that is guaranteed to be a legal `mov_s` destination,
// so the seed instruction can target $dst directly with no scratch
// register. (The register-pressure cost of constraining the whole live
// range to 8 registers is the accepted tradeoff for genuine
// rematerializability -- see dossier 21 idea 4's open risks.)
//
// No `Defs = [STATUS32]`: every recipe step is a non-`.f` form, so this
// pseudo is flag-dead by construction -- it must never clobber STATUS32
// the surrounding code may depend on. isReMaterializable/isAsCheapAsAMove/
// isMoveImm mirror MOV_rs12/MOV_rlimm above; because CONST32's only input
// is the immediate (no register operands at all), the register allocator
// can freely re-derive a spilled CONST32 value via the recipe instead of
// a load-use reload.
let isReMaterializable = 1, isAsCheapAsAMove = 1, isMoveImm = 1,
    hasSideEffects = 0 in
def CONST32 : PseudoInstARC<(outs GPR_S:$dst), (ins i32imm:$imm),
                             "# CONST32 $dst, $imm", []>;

def MOV_rr : F32_DOP_RR<0b00100, 0b001010, 0,
                (outs GPR32:$B), (ins GPR32:$C),
                "mov\t$B, $C", []>
{ let A = 0; }

def MOV_rlimm : F32_DOP_RLIMM<0b00100, 0b001010, 0,
                      (outs GPR32:$B), (ins i32imm:$LImm),
                      "mov\t$B, $LImm", []>
{ let A = 0; }

def MOV_ru6 : F32_DOP_RU6<0b00100, 0b001010, 0,
                          (outs GPR32:$B), (ins immU6:$U6),
                          "mov\t$B, $U6", []>
{ let A = 0; }

def MOV_f_ru6 : F32_DOP_RU6<0b00100, 0b001010, 1,
                          (outs GPR32:$B), (ins u6:$U6),
                          "mov.f\t$B, $U6", []> {
  let A = 0;
  let isAsCheapAsAMove=1;
  let Defs = [STATUS32];
}

def cmov : PatFrag<(ops node:$op1, node:$op2, node:$cc),
                   (ARCcmov $op1, $op2, $cc)>;
let Uses = [STATUS32], isAsCheapAsAMove = 1, isPredicable=1,
	  isReMaterializable = 0, Constraints = "$B = $B2" in {
  def MOV_cc : F32_DOP_CC_RR<0b00100, 0b001010, 0,
                 (outs GPR32:$B), (ins GPR32:$C, GPR32:$B2, CCOp:$cc),
                 "mov.$cc\t$B, $C",
                 [(set GPR32:$B, (cmov i32:$C, i32:$B2, imm32:$cc))]>;

  def MOV_cc_ru6 : F32_DOP_CC_RU6<0b00100, 0b001010, 0,
                 (outs GPR32:$B), (ins u6:$U6, CCOp:$cc, GPR32:$B2),
                 "mov.$cc\t$B, $U6",
                 [(set GPR32:$B, (cmov u6:$U6, i32:$B2, imm32:$cc))]>;

  def MOV_cc_f_ru6 : F32_DOP_CC_RU6<0b00100, 0b001010, 1,
                    (outs GPR32:$B), (ins u6:$U6, CCOp:$cc, GPR32:$B2),
                    "mov.$cc.f\t$B, $U6", []> {
    let Defs = [STATUS32];
  }
}

def : Pat<(ARCGAWrapper tglobaladdr:$addr),
           (MOV_rlimm tglobaladdr:$addr)>;

def : Pat<(ARCGAWrapper tjumptable:$addr),
           (MOV_rlimm tjumptable:$addr)>;

def : Pat<(ARCGAWrapper tconstpool:$addr),
           (MOV_rlimm tconstpool:$addr)>;


// ---------------------------------------------------------------------------
// Control flow instructions (branch, return, calls, etc).
// ---------------------------------------------------------------------------

// Branch instructions
let isBranch = 1, isTerminator = 1 in {

  // Unconditional branch.
  let isBarrier = 1 in
  def BR : F32_BR0_UCOND_FAR<(outs), (ins btargetS25:$S25),
                             "b\t$S25", [(br bb:$S25)]>
  { let N = 0; }

  let Uses=[STATUS32] in
  // Conditional branch.
  def Bcc : F32_BR0_COND<(outs), (ins btargetS21:$S21, ccond:$cc),
                         "b$cc\t$S21", []>
  { let N = 0; }

  // Compare and branch (limited range).
  def BRcc_rr  : F32_BR1_BCC<(outs),
                             (ins btargetS9:$S9, GPR32:$B, GPR32:$C, brccond:$cc),
                             "br$cc\t$B, $C, $S9", 0, []>
  { let N = 0; }
  def BRcc_ru6 : F32_BR1_BCC<(outs),
                             (ins btargetS9:$S9, GPR32:$B, immU6:$C, brccond:$cc),
                             "br$cc\t$B, $C, $S9", 1, []>
  { let N = 0; }

  // Pseudo compare and branch.
  // After register allocation, this can expand into either a limited range
  // Compare and branch (BRcc), or into CMP + Bcc.
  // At worst, this expands into 2 4-byte instructions.
  def BRcc_rr_p : PseudoInstARC<(outs),
                                (ins btarget:$T, GPR32:$B, GPR32:$C, ccond:$cc),
                                "pbr$cc\t$B, $C, $T",
                                [(ARCbrcc bb:$T, i32:$B, i32:$C, imm32:$cc)]>
                                { let Size = 8; }

  def BRcc_ru6_p : PseudoInstARC<(outs),
                                 (ins btarget:$T, GPR32:$B, i32imm:$C, ccond:$cc),
                                 "pbr$cc\t$B, $C, $T",
                                 [(ARCbrcc bb:$T, i32:$B, immU6:$C, imm32:$cc)]>
                                 { let Size = 8; }

  // Fused i64 unsigned compare-and-branch (dossier 23 Phase 1). Mirrors
  // BRcc_rr_p above: an opaque pseudo terminator that survives register
  // allocation, scheduling and block layout, and is expanded by
  // ARCBranchFinalize (addPreEmitPass, before ARCDelaySlotFiller) into
  //     cmp   ALo, BLo        ; C = borrow(lo)
  //     sbc.f 0, AHi, BHi     ; C = borrow of the full 64-bit subtract
  //     b$cc  T               ; $cc = LO (a <u b) or HS (a >=u b)
  // Being one MI until then is what guarantees the STATUS32 adjacency of the
  // triple through RA/scheduling; after expansion nothing reorders within a
  // basic block, and ARCDelaySlotFiller cannot break it either -- see the
  // expansion site in ARCBranchFinalize.cpp for that argument in full.
  //
  // Size = 12 is the exact expansion size (3 x 4 bytes) and is what the
  // ARCBranchFinalize PC walk and the s9-range check for sibling BRcc pseudos
  // account for. ARCSizeReduction may later shrink the `cmp` to a 2-byte
  // `cmp_s` (ISA: CMP_S sets flags implicitly), making the real sequence 10
  // bytes -- an over-estimate here is conservative for branch range and never
  // wrong. `b$cc` itself is Bcc's s21 (+/-1 MB) range, which this backend
  // already treats as always-reachable: it is the existing out-of-range
  // fallback replaceWithCmpBcc() degrades every long BRcc into.
  //
  // ANALYZABLE: listed in ARCInstrInfo.cpp's isCondBranchOpcode, with Cond
  // carrying this pseudo's 5-operand {ALo, BLo, AHi, BHi, cc} condition
  // alongside BRcc's 3-operand {B, C, cc}. Cond is target-opaque
  // (TargetInstrInfo.h asks only for "a list of operands that evaluate the
  // condition" and fixes no arity), so both shapes coexist; getNumCondOperands
  // maps opcode -> arity and the cc is always Cond.back().
  //
  // Being analyzable is SAFE here for the same reason the pseudo exists at all:
  // until ARCBranchFinalize it is ONE self-contained MI, condition and all, and
  // branch-folder / tailduplication / block-placement every one run strictly
  // BEFORE that pass. There is no separate flag producer in the block yet, so
  // no caller can split a `cmp`/`sbc.f` from its `Bcc`; the triple is only ever
  // materialized later, atomically. reverseBranchCondition is exact too -- LO
  // and HS test the same carry bit, so inverting the cc needs no operand swap.
  //
  // It is also what makes Size = 12 the truth rather than an aspiration: while
  // this pseudo was unanalyzable, BranchFolding could not elide the fallthrough
  // branch after it, so every fused i64 compare-and-branch really emitted FOUR
  // instructions -- `cmp`/`sbc.f`/`b$cc`/`b .Lnext`, 16 bytes, with those last
  // 4 dead. Contrast the flag-recycling fusions in ARCBranchFinalize.cpp, which
  // consume a SEPARATE producer's flags and so must stay unanalyzable and late.
  let Defs = [STATUS32] in
  def BRCARRY_p : PseudoInstARC<(outs),
                                (ins btarget:$T, GPR32:$ALo, GPR32:$BLo,
                                     GPR32:$AHi, GPR32:$BHi, ccond:$cc),
                                "# BRCARRY_p $ALo, $BLo, $AHi, $BHi, $T, $cc",
                                [(ARCbrcccarry bb:$T, i32:$ALo, i32:$BLo,
                                               i32:$AHi, i32:$BHi,
                                               imm32:$cc)]>
                                { let Size = 12; }
} // let isBranch, isTerminator

// Unconditional Jump.
let isBranch = 1, isTerminator = 1, isBarrier = 1 in {
  // Indirect.
  let isIndirectBranch = 1 in
  def J :  F32_DOP_RR<0b00100, 0b100000, 0,
                      (outs), (ins GPR32:$C),
                      "j\t[$C]", [(brind i32:$C)]>
  { let A = 0; let B = 0; }

  // Direct.
  def J_LImm : F32_DOP_RLIMM<0b00100, 0b100000, 0,
                             (outs), (ins i32imm:$LImm),
                             "j\t$LImm", []>
  { let A = 0; let B = 0; }
}

// Call instructions.
let isCall = 1, isBarrier = 1, Defs = [BLINK], Uses = [SP] in {
  // Direct unconditional call.
  def BL : F32_BR1_BL_UCOND_FAR<(outs), (ins calltargetS25:$S25),
                      "bl\t$S25", [(ARCBranchLink tglobaladdr:$S25)]>
  { let N = 0; }

  // Indirect unconditional call.
  let isIndirectBranch = 1 in
  def JL : F32_DOP_RR<0b00100, 0b100010, 0, (outs), (ins GPR32:$C),
                     "jl\t[$C]", [(ARCJumpLink i32:$C)]>
  { let A = 0; let B = 0; }

  // Direct unconditional call.
  def JL_LImm : F32_DOP_RLIMM<0b00100, 0b100010, 0, (outs), (ins i32imm:$LImm),
                              "jl\t$LImm", []>
  { let A = 0; let B = 0; }
} // let isCall, isBarrier, Defs, Uses

// Pattern to generate BL instruction.
def : Pat<(ARCBranchLink texternalsym:$dst), (BL texternalsym:$dst)>;

// Direct tail call = a far unconditional branch to the callee (major 0x00,
// s25h pcrel, same range that reaches any BL target). It does NOT set BLINK, so
// the callee returns straight to our caller. isReturn+isTerminator so PEI tears
// down the frame before it; isCall so the variadic arg-reg uses + the call
// reg-mask attach (like BL). Encoded directly via getBranchTargetS25HEncoding
// (fixup_arc_s25h_pcrel) -- no pseudo expansion, so analyzeBranch never sees a
// branch with a non-MBB target.
let isCall = 1, isReturn = 1, isTerminator = 1, isBarrier = 1,
    isCodeGenOnly = 1, Uses = [SP] in
def TCB : F32_BR0_UCOND_FAR<(outs), (ins tcalltargetS25:$S25), "b\t$S25",
                            [(ARCtcreturn tglobaladdr:$S25)]>
{ let N = 0; }

def : Pat<(ARCtcreturn texternalsym:$dst), (TCB texternalsym:$dst)>;

// Return from call.
let isReturn = 1, isTerminator = 1, isBarrier = 1  in
// This is a specialized 2-byte instruction that doesn't generalize
// to any larger 2-byte class, so go ahead and define it here.
//
// Uses = [BLINK]: the return reads the link register. It has no explicit
// operands, so without this its dependence on BLINK is entirely unmodelled
// and any pass that reorders code is free to clobber the return address --
// e.g. sinking an epilogue `ld blink, [sp]` past it.
let Uses = [BLINK] in
def J_S_BLINK : InstARC<2, (outs), (ins), "j_s\t[%blink]", [(ret)]> {
  let Inst{15-0} = 0b0111111011100000;
}

// ---------------------------------------------------------------------------
// Delayed (.d) twins of the code-generated transfers.
//
// ARC700 gives every branch / call / jump one architectural delay slot. The
// mode is selected by the N bit, which for the branch formats is Inst{5}
// (see `bit N; let Inst{5} = N;` in F32_BR / F32_BR1_BCC in
// ARCInstrFormats.td) and for the jump formats is a distinct sub-opcode:
//   N=0 (ND, the default the defs above select): the following instruction is
//        nullified when the transfer is taken, and executes when it is not.
//   N=1 (D): the following instruction always executes, on both paths.
//
// D-mode's "executes on both paths" is exactly what makes filling safe: the
// filler only ever moves an instruction that already executed unconditionally
// *before* the transfer, so its execution count is unchanged on either path.
//
// These forms are created exclusively by ARCDelaySlotFiller, and only once it
// has a real instruction to put in the slot -- hence no pattern and
// isCodeGenOnly. Selecting a .d form up front would commit to a slot blind,
// before the passes that produce the fill candidate have even run.
//
// Every encoding below is byte-verified with the reference ARC disassembler
// (llvm-objdump misdecodes big-endian ARC and must not be used):
//   b        0x00010000 / b.d        0x00010020
//   b.eq     0x00000001 / b.eq.d     0x00000021
//   breq     0x08010000 / breq.d     0x08010020
//   breq u6  0x08010010 / breq.d u6  0x08010030
//   bl       0x08020000 / bl.d       0x08020020
//   j [r0]   0x20200000 / j.d [r0]   0x20210000   (sub-opcode 0x20 -> 0x21)
//   jl [r0]  0x20220000 / jl.d [r0]  0x20230000   (sub-opcode 0x22 -> 0x23)
//   j_s [blink]  0x7EE0 / j_s.d [blink]  0x7FE0   (2 bytes; size-neutral)
// ---------------------------------------------------------------------------
let isCodeGenOnly = 1, hasDelaySlot = 1 in {

let isBranch = 1, isTerminator = 1 in {
  let isBarrier = 1 in
  def BR_D : F32_BR0_UCOND_FAR<(outs), (ins btargetS25:$S25), "b.d\t$S25", []>
  { let N = 1; }

  let Uses = [STATUS32] in
  def Bcc_D : F32_BR0_COND<(outs), (ins btargetS21:$S21, ccond:$cc),
                           "b$cc.d\t$S21", []>
  { let N = 1; }

  def BRcc_rr_D : F32_BR1_BCC<(outs),
                              (ins btargetS9:$S9, GPR32:$B, GPR32:$C,
                                   brccond:$cc),
                              "br$cc.d\t$B, $C, $S9", 0, []>
  { let N = 1; }
  def BRcc_ru6_D : F32_BR1_BCC<(outs),
                               (ins btargetS9:$S9, GPR32:$B, immU6:$C,
                                    brccond:$cc),
                               "br$cc.d\t$B, $C, $S9", 1, []>
  { let N = 1; }
} // let isBranch, isTerminator

let isBranch = 1, isTerminator = 1, isBarrier = 1, isIndirectBranch = 1 in
def J_D : F32_DOP_RR<0b00100, 0b100001, 0, (outs), (ins GPR32:$C),
                     "j.d\t[$C]", []>
{ let A = 0; let B = 0; }

let isCall = 1, isBarrier = 1, Defs = [BLINK], Uses = [SP] in {
  def BL_D : F32_BR1_BL_UCOND_FAR<(outs), (ins calltargetS25:$S25),
                                  "bl.d\t$S25", []>
  { let N = 1; }

  let isIndirectBranch = 1 in
  def JL_D : F32_DOP_RR<0b00100, 0b100011, 0, (outs), (ins GPR32:$C),
                        "jl.d\t[$C]", []>
  { let A = 0; let B = 0; }
} // let isCall

let isCall = 1, isReturn = 1, isTerminator = 1, isBarrier = 1, Uses = [SP] in
def TCB_D : F32_BR0_UCOND_FAR<(outs), (ins tcalltargetS25:$S25), "b.d\t$S25",
                              []>
{ let N = 1; }

let isReturn = 1, isTerminator = 1, isBarrier = 1, Uses = [BLINK] in
def J_S_BLINK_D : InstARC<2, (outs), (ins), "j_s.d\t[%blink]", []> {
  let Inst{15-0} = 0b0111111111100000;
}

} // let isCodeGenOnly = 1, hasDelaySlot = 1

//----------------------------------------------------------------------------
// Compact stack-based operations.
//----------------------------------------------------------------------------

// 2-byte push/pop blink instructions commonly used for prolog/epilog
// generation.  These 2 instructions are actually specialized 2-byte
// format instructions that aren't generalized to a larger 2-byte
// class, so we might as well have them here.
let Uses = [BLINK], Defs = [SP] in
def PUSH_S_BLINK : F16_SP_OPS_buconst<0b111, "push_s">;

let Defs = [BLINK, SP] in
def POP_S_BLINK : F16_SP_OPS_buconst<0b110, "pop_s">;

def PUSH_S_r : F16_SP_OPS_uconst<0b110,
  (outs), (ins GPR32Reduced:$b3), "push_s">;
def POP_S_r : F16_SP_OPS_uconst<0b111,
  (outs GPR32Reduced:$b3), (ins), "pop_s">;

def SP_SUB_SP_S : F16_SP_OPS_bconst<0b001, "sub_s">;
def SP_ADD_SP_S : F16_SP_OPS_bconst<0b000, "add_s">;
def SP_ADD_S : F16_SP_OPS_u7_aligned<0b100,
                (outs GPR32Reduced:$b3), (ins immU<7>:$u7),
                "add_s\t$b3, %sp, $u7">;

// Manual fix (dossier 05 step 5): F16_SP_LD/F16_SP_ST (like every compact
// 16-bit load/store descriptor in ARCARCompactInstr16.td) never declared
// mayLoad/mayStore, so they silently inherited InstARC's mayLoad=0/
// mayStore=0 default. This was invisible until ARCSizeReduction attached a
// MachineMemOperand to the reduced instruction for MMO preservation: the
// MachineVerifier's per-MMO check (`Op->isLoad() && !MI->mayLoad()` /
// `Op->isStore() && !MI->mayStore()`) then aborts codegen. Reproduced on
// this already-committed (dossier 04) SP-relative path via a trivial
// alloca+load/store at -Os/-Oz through `llc -verify-machineinstrs` --
// proves the bug predates this session and was never exercised end-to-end
// before now. Pure metadata fix, no bit-encoding change.
let mayLoad = 1 in {
def SP_LD_S : F16_SP_LD<0b000, "ld_s">;
def SP_LDB_S : F16_SP_LD<0b001, "ldb_s">;
}
let mayStore = 1 in {
def SP_ST_S : F16_SP_ST<0b010, "st_s">;
def SP_STB_S : F16_SP_ST<0b011, "stb_s">;
}

def LEAVE_S : F16_SP_OPS<0b110,
  (outs), (ins immU<7>:$u7), "leave_s\t$u7"> {

  bits<7> u7;

  let fieldB = u7{6-4};
  let fieldU{4-1} = u7{3-0};
  let fieldU{0} = 0b0;
}

def ENTER_S : F16_SP_OPS<0b111,
  (outs), (ins immU<6>:$u6), "enter_s\t$u6"> {

  bits<6> u6;

  let fieldB{2} = 0;
  let fieldB{1-0} = u6{5-4};
  let fieldU{4-1} = u6{3-0};
  let fieldU{0} = 0b0;
}

//----------------------------------------------------------------------------
// Compact Move/Load instructions.
//----------------------------------------------------------------------------
class COMPACT_MOV_S :
  F16_COMPACT<0b0, (outs GPR32:$g), (ins GPR32:$h),
          "mov_s\t$g, $h"> {
  let DecoderMethod = "DecodeMoveHRegInstruction";
}

def COMPACT_MOV_S_limm : InstARC<6, (outs GPR32:$g), (ins i32imm:$LImm),
                                    "mov_s\t$g, $LImm", []> {
  bits<32> LImm;
  let Inst{47-16} = LImm;

  bits<5> g;
  let Inst{15-11} = 0b01000;
  bits<5> LImmReg = 0b11110;
  let Inst{7-5} = LImmReg{2-0};
  let Inst{10-8} = g{2-0};
  let Inst{4-3} = g{4-3};
  let Inst{2} = 0b0;
  let Inst{1-0} = LImmReg{4-3};
  let Inst{9} = 0;

  let DecoderMethod = "DecodeMoveHRegInstruction";
}

def COMPACT_MOV_S_hreg : COMPACT_MOV_S;

def COMPACT_LD_S :
  F16_COMPACT<0b1, (outs GPR32:$r), (ins GPR32:$h, immU<5>:$u5),
          "ld_s\t$r, [$h, $u5]"> {
  bits<5> u5;
  bits<2> r;

  let Inst{10} = u5{4};
  let Inst{9-8} = r;
  let Inst{4-3} = u5{3-2};
  let u5{1-0} = 0b00;
}

//----------------------------------------------------------------------------
// Compact Load/Add/Sub.
//----------------------------------------------------------------------------
def LD_S_AS_rrr : F16_LD_SUB<0b0, "ld_s.as\t$a, [$b, $c]">;
def SUB_S_rrr : F16_LD_SUB<0b1, "sub_s\t$a, $b, $c">;
def ADD_S_rru6 : F16_ADD;

//----------------------------------------------------------------------------
// Compact Load/Store.
//----------------------------------------------------------------------------
def LD_S_s11 : F16_LD_ST_s11<0b0, "ld_s\t%r1, [%gp, $s11]">;
def ST_S_s11 : F16_LD_ST_s11<0b1, "st_s\t%r0, [%gp, $s11]">;
def LDI_S_u7 : F16_LDI_u7;

//----------------------------------------------------------------------------
// Indexed Jump or Execute.
//----------------------------------------------------------------------------
def JLI_S : F16_JLI_EI<0, "jli_s">;
def EI_S : F16_JLI_EI<1, "ei_s">;

//----------------------------------------------------------------------------
// Load/Add Register-Register.
//----------------------------------------------------------------------------
def LD_S_rrr : F16_LD_ADD_RR<0b00, "ld_s\t$a, [$b, $c]">;
def LDB_S_rrr : F16_LD_ADD_RR<0b01, "ldb_s\t$a, [$b, $c]">;
def LDH_S_rrr : F16_LD_ADD_RR<0b10, "ldh_s\t$a, [$b, $c]">;
def ADD_S_rrr : F16_LD_ADD_RR<0b11, "add_s\t$a, $b, $c">;

//----------------------------------------------------------------------------
// Load/Add GP-Relative.
//----------------------------------------------------------------------------
def GP_LD_S : F16_GP_LD_ADD<0b00, (ins immS<11>:$s),
  "ld_s\t%r0, [%gp, $s]"> {

  bits<11> s;
  let Inst{8-0} = s{10-2};
  let s{1-0} = 0b00;
}

def GP_LDB_S : F16_GP_LD_ADD<0b01, (ins immS<9>:$s),
  "ldb_s\t%r0, [%gp, $s]"> {

  bits<9> s;
  let Inst{8-0} = s{8-0};
}

def GP_LDH_S : F16_GP_LD_ADD<0b10, (ins immS<10>:$s),
  "ldh_s\t%r0, [%gp, $s]"> {

  bits<10> s;
  let Inst{8-0} = s{9-1};
  let s{0} = 0b0;
}

def GP_ADD_S : F16_GP_LD_ADD<0b11, (ins immS<11>:$s),
  "add_s\t%r0, %gp, $s"> {

  bits<11> s;
  let Inst{8-0} = s{10-2};
  let s{1-0} = 0b00;
}

//----------------------------------------------------------------------------
// Load PCL-Relative.
//----------------------------------------------------------------------------
def PCL_LD : InstARC<2, (outs GPR32:$b), (ins immU<10>:$u10),
 "ld_s\t$b, [%pcl, $u10]", []> {

  bits<3> b;
  bits<10> u10;

  let Inst{15-11} = 0b11010;
  let Inst{10-8} = b;
  let Inst{7-0} = u10{9-2};
  let u10{1-0} = 0b00;
}

let isBranch = 1 in {
  //----------------------------------------------------------------------------
  // Branch on Compare Register with Zero.
  //----------------------------------------------------------------------------
  def BREQ_S : F16_BCC_REG<0b0, "breq_s">;
  def BRNE_S : F16_BCC_REG<0b1, "brne_s">;

  //----------------------------------------------------------------------------
  // Branch Conditionally.
  //----------------------------------------------------------------------------
  let isBarrier = 1 in
  def B_S : F16_BCC_s10<0b00, "b_s">;

  def BEQ_S : F16_BCC_s10<0b01, "beq_s">;
  def BNE_S : F16_BCC_s10<0b10, "bne_s">;
  def BGT_S : F16_BCC_s7<0b000, "bgt_s">;
  def BGE_S : F16_BCC_s7<0b001, "bge_s">;
  def BLT_S : F16_BCC_s7<0b010, "blt_s">;
  def BLE_S : F16_BCC_s7<0b011, "ble_s">;
  def BHI_S : F16_BCC_s7<0b100, "bhi_s">;
  def BHS_S : F16_BCC_s7<0b101, "bhs_s">;
  def BLO_S : F16_BCC_s7<0b110, "blo_s">;
  def BLS_S : F16_BCC_s7<0b111, "bls_s">;
} // let isBranch

def BL_S :
  InstARC<2, (outs), (ins btargetS13:$s13), "bl_s\t$s13", []> {

  let Inst{15-11} = 0b11111;

  bits<13> s13;
  let Inst{10-0} = s13{12-2};
  let s13{1-0} = 0b00;

  let isCall = 1;
  let isBarrier = 1;
}

//----------------------------------------------------------------------------
// Add/Sub/Shift Register-Immediate.
//----------------------------------------------------------------------------
def ADD_S_ru3 : F16_ADD_IMM<0b00,"add_s">;
def SUB_S_ru3 : F16_ADD_IMM<0b01,"sub_s">;
def ASL_S_ru3 : F16_ADD_IMM<0b10,"asl_s">;
def ASR_S_ru3 : F16_ADD_IMM<0b11,"asr_s">;

//----------------------------------------------------------------------------
// Shift/Subtract/Bit Immediate.
//----------------------------------------------------------------------------
def ASL_S_ru5 : F16_SH_SUB_BIT_DST<0b000,"asl_s">;
def LSR_S_ru5 : F16_SH_SUB_BIT_DST<0b001,"lsr_s">;
def ASR_S_ru5 : F16_SH_SUB_BIT_DST<0b010,"asr_s">;
def SUB_S_ru5 : F16_SH_SUB_BIT_DST<0b011,"sub_s">;
def BSET_S_ru5 : F16_SH_SUB_BIT_DST<0b100,"bset_s">;
def BCLR_S_ru5 : F16_SH_SUB_BIT_DST<0b101,"bclr_s">;
def BMSK_S_ru5 : F16_SH_SUB_BIT_DST<0b110,"bmsk_s">;
// BTST is compare-like: the F16_SH_SUB_BIT base class already has (outs),
// (ins GPR32:$b, immU<5>:$u5) (unlike its _DST siblings above) -- verified
// correct. It was only missing Defs=[STATUS32] (dossier 24); btst_s always
// writes flags (implicit F=1, no toggle bit in the encoding).
let isCompare = 1, Defs = [STATUS32] in
def BTST_S_ru5 : F16_SH_SUB_BIT<0b111, "btst_s\t$b, $u5">;

//----------------------------------------------------------------------------
// Dual Register Operations.
//----------------------------------------------------------------------------
def ADD_S_rlimm :
  F16_OP_HREG_LIMM<0b000, (outs GPR32:$b_s3), (ins i32imm:$LImm),
          !strconcat("add_s", "\t$b_s3, $b_s3, $LImm")>;

def ADD_S_rr :
  F16_OP_HREG<0b000, (outs GPR32:$b_s3), (ins GPR32:$h),
          !strconcat("add_s", "\t$b_s3, $b_s3, $h")>;

def ADD_S_rs3 :
  F16_OP_HREG<0b001, (outs GPR32:$h), (ins immC<3>:$b_s3),
          !strconcat("add_s", "\t$h, $h, $b_s3")>;

def ADD_S_limms3 :
  F16_OP_HREG_LIMM<0b001, (outs), (ins immC<3>:$b_s3, i32imm:$LImm),
          !strconcat("add_s", "\t0, $LImm, $b_s3")>;

def MOV_S_NE_rlimm :
  F16_OP_HREG_LIMM<0b111, (outs GPR32:$b_s3), (ins i32imm:$LImm),
          !strconcat("mov_s.ne", "\t$b_s3, $LImm")>;

def MOV_S_NE_rr :
  F16_OP_HREG<0b111,(outs GPR32:$b_s3), (ins GPR32:$h),
          !strconcat("mov_s.ne", "\t$b_s3, $h")>;

def MOV_S_rs3 :
  F16_OP_HREG<0b011, (outs GPR32:$h), (ins immC<3>:$b_s3),
          !strconcat("mov_s", "\t$h, $b_s3")>;

def MOV_S_s3 :
  F16_OP_HREG30<0b011, (outs), (ins immC<3>:$b_s3),
          !strconcat("mov_s", "\t0, $b_s3")>;

def CMP_S_rlimm :
  F16_OP_HREG_LIMM<0b100, (outs GPR32:$b_s3), (ins i32imm:$LImm),
          !strconcat("cmp_s", "\t$b_s3, $LImm")>;

def CMP_S_rr :
  F16_OP_HREG<0b100, (outs GPR32:$b_s3), (ins GPR32:$h),
          !strconcat("cmp_s", "\t$b_s3, $h")>;

def CMP_S_rs3 :
  F16_OP_HREG<0b101, (outs GPR32:$h), (ins immC<3>:$b_s3),
          !strconcat("cmp_s", "\t$h, $b_s3")>;

def CMP_S_limms3 :
  F16_OP_HREG_LIMM<0b101, (outs), (ins immC<3>:$b_s3, i32imm:$LImm),
          !strconcat("cmp_s", "\t$LImm, $b_s3")>;

//----------------------------------------------------------------------------
// Compact MOV/ADD/CMP Immediate instructions.
//----------------------------------------------------------------------------
def MOV_S_u8 :
  F16_OP_IMM<0b11011, (outs GPR32:$b), (ins immU<8>:$u8),
          !strconcat("mov_s", "\t$b, $u8")> {
  bits<8> u8;
  let Inst{7-0} = u8;
}

def ADD_S_u7 :
  F16_OP_U7<0b0, !strconcat("add_s", "\t$b, $b, $u7")>;

def CMP_S_u7 :
  F16_OP_U7<0b1, !strconcat("cmp_s", "\t$b, $u7")>;

//----------------------------------------------------------------------------
// Compact Load/Store instructions with offset -- QUARANTINED (dossier 05
// step 5). LD_S_OFF/LDB_S_OFF/LDH_S_OFF/LDH_S_X_OFF/ST_S_OFF/STB_S_OFF/
// STH_S_OFF used to live here, built from F16_LD_ST_OFF/_WORD_OFF/_HALF_OFF/
// _BYTE_OFF in ARCInstrFormats.td. They claimed the identical 16-bit
// encoding space (opcodes 0x10-0x16) as ARCARCompactInstr16.td's
// ARC_LD_S_c_b_u7 / ARC_LDB_S_c_b_u5 / ARC_LDW_S_c_b_u6 / ARC_ST_S_c_b_u7 /
// ARC_STB_S_c_b_u5 / ARC_STW_S_c_b_u6 family but used unconstrained
// `GPR32:$b/$c` operand types over raw 3-bit fields (bits<3> b; bits<3> c;)
// instead of the true GPR_S register class -- a silent-aliasing risk if
// ever reached (e.g. R4's low-3-bit-truncated encoding collides with R12's
// compact-field encoding), since only C++-side isGPR_S() gating (not the
// MachineVerifier) would have caught a misuse. Confirmed dead at removal
// time: no Pattern, no ReduceTable reference, no test coverage, and not
// reachable from the hand-written AsmParser dispatch table (see
// toolchain/llvm/CLAUDE.md) -- the only references were TableGen-generated
// disassembler/encoder tables. The live, GPR_S-correct family in
// ARCARCompactInstr16.td is the one wired into ARCSizeReduction's
// ReduceTable below.
//----------------------------------------------------------------------------
// General compact instructions.
//----------------------------------------------------------------------------
def GEN_SUB_S : F16_GEN_DOP<0x02, "sub_s">;
def GEN_AND_S : F16_GEN_DOP<0x04, "and_s">;
def GEN_OR_S : F16_GEN_DOP<0x05, "or_s">;
def GEN_BIC_S : F16_GEN_DOP<0x06, "bic_s">;
def GEN_XOR_S : F16_GEN_DOP<0x07, "xor_s">;
def GEN_MPYW_S : F16_GEN_DOP<0x09, "mpyw_s">;
def GEN_MPYUW_S : F16_GEN_DOP<0x0a, "mpyuw_s">;
def GEN_TST_S : F16_GEN_DOP_NODST<0x0b, "tst_s">;
def GEN_MPY_S : F16_GEN_DOP<0x0c, "mpy_s">;
def GEN_SEXB_S : F16_GEN_DOP_SINGLESRC<0x0d, "sexb_s">;
def GEN_SEXH_S : F16_GEN_DOP_SINGLESRC<0x0e, "sexh_s">;
def GEN_EXTB_S : F16_GEN_DOP_SINGLESRC<0x0f, "extb_s">;
def GEN_EXTH_S : F16_GEN_DOP_SINGLESRC<0x10, "exth_s">;
def GEN_ABS_S : F16_GEN_DOP_SINGLESRC<0x11, "abs_s">;
def GEN_NOT_S : F16_GEN_DOP_SINGLESRC<0x12, "not_s">;
def GEN_NEG_S : F16_GEN_DOP_SINGLESRC<0x13, "neg_s">;
def GEN_ADD1_S : F16_GEN_DOP<0x14, "add1_s">;
def GEN_ADD2_S : F16_GEN_DOP<0x15, "add2_s">;
def GEN_ADD3_S : F16_GEN_DOP<0x16, "add3_s">;
def GEN_ASL_S : F16_GEN_DOP<0x18, "asl_s">;
def GEN_LSR_S : F16_GEN_DOP<0x19, "lsr_s">;
def GEN_ASR_S : F16_GEN_DOP<0x1a, "asr_s">;
def GEN_AS1L_S : F16_GEN_DOP_SINGLESRC<0x1b, "asl_s">;
def GEN_AS1R_S : F16_GEN_DOP_SINGLESRC<0x1c, "asr_s">;
def GEN_LS1R_S : F16_GEN_DOP_SINGLESRC<0x1d, "lsr_s">;
def GEN_TRAP_S : F16_GEN_DOP_BASE<0x1e, (outs), (ins immU6:$u6),
  "trap_s\t$u6"> {

  bits<6> u6;
  let b = u6{5-3};
  let c = u6{2-0};
}

def GEN_BRK_S : F16_GEN_DOP_BASE<0x1f, (outs), (ins),
  "brk_s"> {

  let b = 0b111;
  let c = 0b111;
}

let isBarrier = 1 in {
  let isBranch = 1 in {
    def GEN_J_S : F16_GEN_SOP<0x0, "j_s\t[$b]">;
    def GEN_J_S_D : F16_GEN_SOP<0x1, "j_s.d\t[$b]">;
  } // let isBranch

  let isCall = 1 in {
    def GEN_JL_S : F16_GEN_SOP<0x2, "jl_s\t[$b]">;
    def GEN_JL_S_D : F16_GEN_SOP<0x3, "jl_s.d\t[$b]">;
  } // let isCall
} // let isBarrier

def GEN_SUB_S_NE : F16_GEN_SOP<0x6, "sub_s.ne\t$b, $b, $b">;

def GEN_NOP_S : F16_GEN_ZOP<0x0, "nop_s">;
def GEN_UNIMP_S : F16_GEN_ZOP<0x1, "unimp_s">;
def GEN_SWI_S : F16_GEN_ZOP<0x2, "swi_s">;

let isReturn = 1, isTerminator = 1 in {
  def GEN_JEQ_S : F16_GEN_ZOP<0x4, "jeq_s\t[%blink]">;
  def GEN_JNE_S : F16_GEN_ZOP<0x5, "jne_s\t[%blink]">;
  let isBarrier = 1 in {
    //def GEN_J_S_BLINK : F16_GEN_ZOP<0x6, "j_s\t[%blink]">;
    def GEN_J_S_D_BLINK : F16_GEN_ZOP<0x7, "j_s.d\t[%blink]">;
  } // let isBarrier
} // let isReturn, isTerminator

//----------------------------------------------------------------------------
// Load/Store instructions.
//----------------------------------------------------------------------------

// Filter  class for load/store mappings
class ArcLdStRel;

// Load instruction variants:
// Control bits: x, aa, di, zz
// x - sign extend.
// aa - incrementing mode. (N/A for LIMM).
// di - uncached.
// zz - data size.
multiclass ArcLdInst<DataSizeMode zz, ExtMode x, CacheMode di, string asmop> {
  let mayLoad = 1, ZZ = zz, X = x, DI = di in {
    def _rs9: F32_LD_ADDR<x.Value, NoAM.Value, di.Value, zz.Value,
			   (outs GPR32:$A), (ins MEMrs9:$addr),
			   !strconcat(asmop, "\t$A, [$addr]"), []>, ArcLdStRel;

    def _limm: F32_LD_LIMM<x.Value, di.Value, zz.Value,
			   (outs GPR32:$A), (ins MEMii:$addr),
			   !strconcat(asmop, "\t$A, [$addr]"), []>, ArcLdStRel;

    def _rlimm: F32_LD_RLIMM<x.Value, NoAM.Value, di.Value, zz.Value,
			     (outs GPR32:$A), (ins MEMrlimm:$addr),
			     !strconcat(asmop, "\t$A, [$addr]"), []>, ArcLdStRel;

    foreach aa = [PreIncAM, PostIncAM] in {
      def aa.InstSuffix#_rs9: F32_LD_RS9<x.Value, aa.Value, di.Value, zz.Value,
					  (outs GPR32:$A, GPR32:$addrout),
					  (ins GPR32:$B, immS<9>:$S9),
					  asmop#aa.AsmSuffix#"\t$A, [$B,$S9]", []>, ArcLdStRel
			       { let Constraints = "$addrout = $B"; let AA = aa; }
    }
  }
}

foreach di = [NoCC, UncachedCC] in {
  defm LD#di.InstSuffix : ArcLdInst<WordSM, NoEM, di, "ld"#di.AsmSuffix>;
  foreach zz = [ByteSM, HalfSM] in {
    foreach x = [NoEM, SignedEM] in {
      defm LD#zz.InstSuffix#x.InstSuffix#di.InstSuffix : ArcLdInst<zz, x, di, "ld"#zz.AsmSuffix#x.AsmSuffix#di.AsmSuffix>;
    }
  }
}

// Scaled reg+reg word load: `ld.as rA,[rB,rC]` = load(rB + rC*4) in one insn
// (GEN4 ALU-form load, major 0x04, AA=0b11 scaled). Encoding mirrors the
// AsmParser's byte-verified reg+reg base 0x20300000 with AA=11 (0x20F00000):
// B[2:0] at [26:24], B[5:3] at [14:12], C at [11:6], A at [5:0].
let mayLoad = 1, isCodeGenOnly = 1 in
def LD_AS_rr : InstARC<4, (outs GPR32:$A), (ins MEMrr:$addr),
                       "ld.as\t$A, [$addr]", []> {
  bits<6>  A;
  bits<12> addr;               // [11:6]=B, [5:0]=C (from getMEMrrOpValue)
  let Inst{31-27} = 0b00100;   // major 0x04 (GEN4 ALU-form load)
  let Inst{26-24} = addr{8-6};   // B[2:0]
  let Inst{23-22} = 0b11;      // AA = scaled (.as)
  let Inst{21-16} = 0b110000;  // load sub-opcode
  let Inst{15}    = 0;
  let Inst{14-12} = addr{11-9};  // B[5:3]
  let Inst{11-6}  = addr{5-0};   // C
  let Inst{5-0}   = A{5-0};
}

// Load instruction patterns.
// 32-bit loads. Try the scaled reg+reg form first (AddedComplexity) so an
// indexed word access folds the scale into the load instead of a separate add2.
let AddedComplexity = 10 in
def : Pat<(load AddrModeAS:$addr), (LD_AS_rr AddrModeAS:$addr)>;
def : Pat<(load AddrModeS9:$addr), (LD_rs9 AddrModeS9:$addr)>;
def : Pat<(load AddrModeImm:$addr), (LD_limm AddrModeImm:$addr)>;
// 32-bit far load MUST use the rlimm (LIMM-offset) form, not rs9: an
// out-of-s9 offset (e.g. partitions[p].flash_addr @ 0x8EC) stuffed into the
// 9-bit rs9 field is silently truncated by getMEMrs9OpValue (0x8EC -> 0xEC).
// The 16-/8-bit far loads already use LDH_rlimm/LDB_rlimm correctly below.
def : Pat<(load AddrModeFar:$addr), (LD_rlimm AddrModeFar:$addr)>;

// 16-bit loads
def : Pat<(zextloadi16 AddrModeS9:$addr), (LDH_rs9 AddrModeS9:$addr)>;
def : Pat<(extloadi16 AddrModeS9:$addr), (LDH_rs9 AddrModeS9:$addr)>;
def : Pat<(zextloadi16 AddrModeImm:$addr), (LDH_limm AddrModeImm:$addr)>;
def : Pat<(extloadi16 AddrModeImm:$addr), (LDH_limm AddrModeImm:$addr)>;
def : Pat<(zextloadi16 AddrModeFar:$addr), (LDH_rlimm AddrModeFar:$addr)>;
def : Pat<(extloadi16 AddrModeFar:$addr), (LDH_rlimm AddrModeFar:$addr)>;
def : Pat<(sextloadi16 AddrModeImm:$addr),(LDH_X_limm AddrModeImm:$addr)>;
def : Pat<(sextloadi16 AddrModeFar:$addr),(LDH_X_rlimm AddrModeFar:$addr)>;
def : Pat<(sextloadi16 AddrModeS9:$addr),(LDH_X_rs9 AddrModeS9:$addr)>;

// 8-bit loads.
def : Pat<(zextloadi8 AddrModeS9:$addr), (LDB_rs9 AddrModeS9:$addr)>;
def : Pat<(extloadi8 AddrModeS9:$addr), (LDB_rs9 AddrModeS9:$addr)>;
def : Pat<(zextloadi8 AddrModeImm:$addr), (LDB_limm AddrModeImm:$addr)>;
def : Pat<(extloadi8 AddrModeImm:$addr), (LDB_limm AddrModeImm:$addr)>;
def : Pat<(zextloadi8 AddrModeFar:$addr), (LDB_rlimm AddrModeFar:$addr)>;
def : Pat<(extloadi8 AddrModeFar:$addr), (LDB_rlimm AddrModeFar:$addr)>;
def : Pat<(zextloadi1 AddrModeS9:$addr), (LDB_rs9 AddrModeS9:$addr)>;
def : Pat<(extloadi1 AddrModeS9:$addr), (LDB_rs9 AddrModeS9:$addr)>;
def : Pat<(zextloadi1 AddrModeImm:$addr), (LDB_limm AddrModeImm:$addr)>;
def : Pat<(extloadi1 AddrModeImm:$addr), (LDB_limm AddrModeImm:$addr)>;
def : Pat<(zextloadi1 AddrModeFar:$addr), (LDB_rlimm AddrModeFar:$addr)>;
def : Pat<(extloadi1 AddrModeFar:$addr), (LDB_rlimm AddrModeFar:$addr)>;
def : Pat<(sextloadi8 AddrModeImm:$addr),(LDB_X_limm AddrModeImm:$addr)>;
def : Pat<(sextloadi8 AddrModeFar:$addr),(LDB_X_rlimm AddrModeFar:$addr)>;
def : Pat<(sextloadi8 AddrModeS9:$addr),(LDB_X_rs9 AddrModeS9:$addr)>;


// Store instruction variants:
// Control bits: aa, di, zz
// aa - incrementing mode. (N/A for LIMM).
// di - uncached.
// zz - data size.
multiclass ArcStInst<DataSizeMode zz, CacheMode di, string asmop> {
  let mayStore = 1, ZZ = zz, DI = di in {
    def _rs9: F32_ST_ADDR<NoAM.Value, di.Value, zz.Value,
			   (outs), (ins GPR32:$C, MEMrs9:$addr),
			   !strconcat(asmop, "\t$C, [$addr]"), []>, ArcLdStRel;

    def _limm: F32_ST_LIMM<di.Value, zz.Value,
			   (outs), (ins GPR32:$C, MEMii:$addr),
			   !strconcat(asmop, "\t$C, [$addr]"), []>, ArcLdStRel;


    foreach aa = [PreIncAM, PostIncAM] in {
      def aa.InstSuffix#_rs9: F32_ST_RS9<aa.Value, di.Value, zz.Value,
					  (outs GPR32:$addrout),
					  (ins GPR32:$C, GPR32:$B, immS<9>:$S9),
					  asmop#aa.AsmSuffix#"\t$C, [$B,$S9]", []>, ArcLdStRel
			       { let Constraints = "$addrout = $B"; let AA = aa; }
    }
  }
}

foreach di = [NoCC, UncachedCC] in {
  foreach zz = [ByteSM, HalfSM, WordSM] in {
      defm ST#zz.InstSuffix#di.InstSuffix : ArcStInst<zz, di, "st"#zz.AsmSuffix#di.AsmSuffix>;
  }
}

// Store instruction patterns.
// 32-bit stores
def : Pat<(store i32:$C, AddrModeS9:$addr),
          (ST_rs9 i32:$C, AddrModeS9:$addr)>;
def : Pat<(store i32:$C, AddrModeImm:$addr),
          (ST_limm i32:$C, AddrModeImm:$addr)>;

// 16-bit stores
def : Pat<(truncstorei16 i32:$C, AddrModeS9:$addr),
          (STH_rs9 i32:$C, AddrModeS9:$addr)>;
def : Pat<(truncstorei16 i32:$C, AddrModeImm:$addr),
          (STH_limm i32:$C, AddrModeImm:$addr)>;

// 8-bit stores
def : Pat<(truncstorei8 i32:$C, AddrModeS9:$addr),
          (STB_rs9 i32:$C, AddrModeS9:$addr)>;
def : Pat<(truncstorei8 i32:$C, AddrModeImm:$addr),
          (STB_limm i32:$C, AddrModeImm:$addr)>;

//===----------------------------------------------------------------------===//
// ARCompact Zero-Overhead Loop pseudo instructions.
//
// The HWLOOP_SETUP / HWLOOP_SETUP_IMM / HWLOOP_END pseudos that used to live
// here have been removed along with the formation and expansion passes that
// produced and consumed them (see ARCPassConfig::addPreRegAlloc for why).
//
// They are deliberately NOT kept as scaffolding for a future rewrite: they
// encoded a wrong model of the hazard and would mislead it.
//
//   * HWLOOP_SETUP_IMM declared `Size = 12` (MOV+NOP+LP) but its own
//     expansion selected the 8-byte MOV_rlimm whenever the trip count did
//     not fit in s12, making the real sequence 16 bytes. ARCBranchFinalize
//     sizes branches across the pseudo using that number, one pass before
//     the expansion made it false.
//   * The expansion documented its NOP as "must have 1 instruction between
//     LP_COUNT write and LP". The actual ISA rule is at least 4 instruction
//     *words* fetched after the LP_COUNT write and through the final word of
//     the first iteration -- a property of the whole window, not a fixed
//     one-instruction gap, and one that is only checkable once instruction
//     sizes are final (i.e. after 16-bit size reduction and delay-slot
//     filling, both of which run later).
//
// A replacement pseudo has to carry the ordinary CFG and back-edge so a late
// pass can commit to LP or fall back, so it will not be this shape anyway.
//
// That replacement now exists. The generic llvm/lib/CodeGen/HardwareLoops.cpp
// IR pass -- driven by ARCTTIImpl::isHardwareLoopProfitable and gated behind
// the off-by-default -arc-hardware-loops flag -- proves the trip count with
// SCEV and rewrites a counted loop into
//   preheader:  %c = llvm.start.loop.iterations.i32(%count)
//   header:     %p = phi [%c, preheader], [%d, latch]
//   latch:      %d = llvm.loop.decrement.reg.i32(%p, 1); br (%d != 0), header
// i.e. a completely ordinary countdown loop with an explicit counter register
// and a real conditional back-branch. The two intrinsics select to the two
// pseudos below; everything else (the phi, the compare, the branch) is
// ordinary ARC codegen. ARCLowOverheadLoops (last pass in addPreEmitPass,
// where instruction sizes are finally fixed) then either commits the loop to
// `lp` -- deleting the counter/compare/back-branch and emitting
// `mov lp_count,%count` + word-separation padding + `lp @end` in the
// preheader, with a zero-trip guard -- or, if any silicon precondition fails
// (>=4 fetch WORDS after the LP_COUNT write, LP's +/-4 KiB s13 reach, or the
// required preheader/body/exit block adjacency), leaves the loop alone by
// expanding these two pseudos back into the ordinary `mov` / `sub`. Because
// the fallback is a correct ordinary loop, an unconvertible loop is never a
// miscompile, only a missed optimization.
//
// Keeping the pseudos opaque (hasSideEffects, isNotDuplicable) is what stops
// scheduling / size-reduction / the delay-slot filler from perturbing the
// setup window before ARCLowOverheadLoops can measure the >=4-word separation
// with final sizes -- the same discipline ARC_LP_s13 already relies on in
// hasUnmodeledARCompactSideEffects. Size = 4 matches their ordinary-loop
// expansion (one `mov` / one `sub`) so branch range estimates stay honest
// while they exist.
// Selected manually from llvm.start.loop.iterations / llvm.loop.decrement.reg
// in ARCISelDAGToDAG.cpp (Select's INTRINSIC_W_CHAIN case), rather than via a
// TableGen intrinsic pattern: the two-operand loop.decrement.reg has no
// in-tree direct-pattern precedent (ARM custom-selects it), so hand selection
// keeps the chain wiring explicit and certain. Empty patterns here.
let hasSideEffects = 1, isNotDuplicable = 1 in {
def HWLOOP_START : PseudoInstARC<(outs GPR32:$dst), (ins GPR32:$count),
    "# hwloop start $dst, $count", []> {
  // 4 bytes: the ordinary-loop fall-back expands this to one `mov`. (Size must
  // be set in the def body to override InstARC's Size = sz parameter, exactly
  // as BRcc_rr_p sets Size = 8.)
  let Size = 4;
}

def HWLOOP_DEC : PseudoInstARC<(outs GPR32:$dst), (ins GPR32:$src, i32imm:$dec),
    "# hwloop dec $dst, $src, $dec", []> {
  // 4 bytes: the ordinary-loop fall-back expands this to one `sub`.
  let Size = 4;
}
}
//===----------------------------------------------------------------------===//

def getPostIncOpcode : InstrMapping {
  let FilterClass = "ArcLdStRel";
  let RowFields = [ "BaseOpcode", "ZZ", "DI", "X"];
  let ColFields = [ "AA" ];
  let KeyCol = [ "NoAM" ];
  let ValueCols = [["PostIncAM"]];
}
