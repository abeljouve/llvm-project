//===-- ARCARCompactPatterns.td - ISel patterns for ARCompact -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// ISel patterns for ARCompact (ARC700) instructions that have no equivalent
// in the ARCv2 backend. These patterns reference instruction definitions
// from the auto-generated ARCARCompact*.td files.
//
// Instructions already covered by ARCv2 patterns in ARCInstrInfo.td:
//   ADD, SUB, AND, OR, XOR, ASL, LSR, ASR, ROR, MPY, MPYM, MPYMU,
//   SEXB, SEXH, FFS, FLS, NORM, NORMH, CMP, MOV, LD, ST, BR, J, BL,
//   SUB1, SUB2, SUB3, RSUB, ADC, SBC
//
// This file adds patterns for ARC700-specific instructions that are NOT
// present in the ARCv2 ISA or not pattern-matched there.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Pattern fragments (from stephenmcgruer fork)
//===----------------------------------------------------------------------===//

class ARCBinOpFrag<dag res> : PatFrag<(ops node:$LHS, node:$RHS), res>;
class ARCUnOpFrag<dag res>  : PatFrag<(ops node:$Src), res>;

//===----------------------------------------------------------------------===//
// ADD1: a = b + (c << 1)
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(add GPR32:$b, (shl GPR32:$c, (i32 1))),
            (ARC_ADD1_a_b_c GPR32:$b, GPR32:$c)>;

  def : Pat<(add GPR32:$b, (shl GPR32:$c, (i32 2))),
            (ARC_ADD2_a_b_c GPR32:$b, GPR32:$c)>;

  def : Pat<(add GPR32:$b, (shl GPR32:$c, (i32 3))),
            (ARC_ADD3_a_b_c GPR32:$b, GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// SUB1/SUB2/SUB3: a = b - (c << {1,2,3})
//
// Mirror of ADD1/2/3 above. The generated ARC_SUB{1,2,3}_a_b_c encodings exist
// but had NO ISel pattern (an in-file comment wrongly claimed they were already
// covered), so scaled-subtract index / pointer-difference-by-element-size math
// fell back to a separate `asl` + `sub` pair. `sub` is not commutative so there
// is no operand-order ambiguity.
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(sub GPR32:$b, (shl GPR32:$c, (i32 1))),
            (ARC_SUB1_a_b_c GPR32:$b, GPR32:$c)>;

  def : Pat<(sub GPR32:$b, (shl GPR32:$c, (i32 2))),
            (ARC_SUB2_a_b_c GPR32:$b, GPR32:$c)>;

  def : Pat<(sub GPR32:$b, (shl GPR32:$c, (i32 3))),
            (ARC_SUB3_a_b_c GPR32:$b, GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// BIC: a = b & ~c  (bit clear / AND-NOT)
// Not in ARCv2 ISA.
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(and GPR32:$b, (not GPR32:$c)),
            (ARC_BIC_a_b_c GPR32:$b, GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// BCLR: a = b & ~(1 << c)  (bit clear at position)
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(and GPR32:$b, (not (shl 1, GPR32:$c))),
            (ARC_BCLR_a_b_c GPR32:$b, GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// BSET: a = b | (1 << c)  (bit set at position)
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(or GPR32:$b, (shl 1, GPR32:$c)),
            (ARC_BSET_a_b_c GPR32:$b, GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// BXOR: a = b ^ (1 << c)  (bit toggle at position)
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(xor GPR32:$b, (shl 1, GPR32:$c)),
            (ARC_BXOR_a_b_c GPR32:$b, GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// BMSK: a = b & ((1 << (c + 1)) - 1)  (bitmask from LSB to position c)
// Equivalent to: a = b & ((2 << c) - 1)
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(and GPR32:$b, (add (shl 1, (add GPR32:$c, 1)), -1)),
            (ARC_BMSK_a_b_c GPR32:$b, GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// Constant-bit-position bit ops: bset/bxor/bclr/bmsk with a compile-time bit.
//
// The register-index patterns above match `(op x, (shl 1, r))`; when the bit
// position is a *constant*, `(shl 1, n)` folds to a literal before those match,
// so the whole family was dead for constants. AND/OR/XOR already have u6 (<64)
// and s12 (<2048) immediate forms, so those are already 1 instruction -- the
// only loss is a HIGH bit / WIDE mask that needs an 8-byte LIMM. These leafs
// fire ONLY in that strictly-beneficial range (so existing codegen is
// byte-stable) and stay clear of the extb/extw widths (0xFF / 0xFFFF).
//===----------------------------------------------------------------------===//

// or/xor with a single set bit >= 1<<11 (u6 covers <64, s12 covers <2048).
def bit_pos_hi : ImmLeaf<i32, [{
  return isPowerOf2_32((uint32_t)Imm) && (uint32_t)Imm > 2047;
}]>;
def log2_bit_pos_hi : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(Log2_32((uint32_t)N->getZExtValue()),
                                   SDLoc(N), MVT::i32);
}]>;

// and with ~(1<<n) where the (negative) mask does not fit s12 -> n >= 11.
def bclr_mask_hi : ImmLeaf<i32, [{
  return isPowerOf2_32(~(uint32_t)Imm) && !isInt<12>((int32_t)Imm);
}]>;
def log2_bclr_mask_hi : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(Log2_32(~(uint32_t)N->getZExtValue()),
                                   SDLoc(N), MVT::i32);
}]>;

// and with a low-bit mask (2^k - 1) that does not fit s12 and is not the
// 8/16-bit width already handled by extb/extw, nor the all-ones no-op.
def bmsk_mask_hi : ImmLeaf<i32, [{
  uint32_t M = (uint32_t)Imm;
  return M > 2047 && M != 0xFFFFu && M != 0xFFFFFFFFu && isMask_32(M);
}]>;
def log2_bmsk_mask_hi : SDNodeXForm<imm, [{
  // Bit position for bmsk = (number of low set bits) - 1 = log2(mask+1) - 1.
  return CurDAG->getTargetConstant(Log2_32((uint32_t)N->getZExtValue() + 1) - 1,
                                   SDLoc(N), MVT::i32);
}]>;

// AddedComplexity so the 4-byte bit op wins over the 8-byte `op B,B,limm`
// fallback that also matches (or/and/xor with an out-of-range immediate).
let Predicates = [IsARCompact], AddedComplexity = 4 in {
  def : Pat<(or  GPR32:$b, bit_pos_hi:$m),
            (ARC_BSET_a_b_u6 GPR32:$b, (log2_bit_pos_hi bit_pos_hi:$m))>;
  def : Pat<(xor GPR32:$b, bit_pos_hi:$m),
            (ARC_BXOR_a_b_u6 GPR32:$b, (log2_bit_pos_hi bit_pos_hi:$m))>;
  def : Pat<(and GPR32:$b, bclr_mask_hi:$m),
            (ARC_BCLR_a_b_u6 GPR32:$b, (log2_bclr_mask_hi bclr_mask_hi:$m))>;
  def : Pat<(and GPR32:$b, bmsk_mask_hi:$m),
            (ARC_BMSK_a_b_u6 GPR32:$b, (log2_bmsk_mask_hi bmsk_mask_hi:$m))>;
}

//===----------------------------------------------------------------------===//
// NOT: b = ~c  (bitwise complement)
// ARCv2 does NOT have a NOT instruction with pattern.
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(not GPR32:$c),
            (ARC_NOT_b_c GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// SWAP: byte-swap within halfwords
//   SWAP reverses the two 16-bit halves of a 32-bit word:
//   result = (src >> 16) | (src << 16)
//   This is NOT bswap (full byte reversal). SWAPE is the full byte swap.
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  // SWAP: result = (src << 16) | (src >> 16)  -- halfword swap
  def : Pat<(or (shl GPR32:$c, (i32 16)), (srl GPR32:$c, (i32 16))),
            (ARC_SWAP_b_c GPR32:$c)>;
  def : Pat<(rotl GPR32:$c, (i32 16)),
            (ARC_SWAP_b_c GPR32:$c)>;
  def : Pat<(rotr GPR32:$c, (i32 16)),
            (ARC_SWAP_b_c GPR32:$c)>;

}

// SWAPE: full byte reversal (bswap). SWAPE has NO encoding on ARC700 /
// BCM55030 -- confirmed absent by silicon characterization (see
// docs/notes/isa-characterization.md). Gate this Pat behind the
// off-by-default HasSwape predicate so it is dead on this profile; only a
// hypothetical future ARCv2-word CPU that genuinely implements swape would
// enable HasSwape and let this fire. ISD::BSWAP is Custom-lowered
// (ARCTargetLowering::LowerBSWAP) to a mask/shift/or + SWAP(halfword)
// sequence instead -- see ARCISelLowering.cpp. The ARC_SWAPE_* instruction
// *encodings* in ARCARCompactInstrALU.td stay defined (available as an
// assembler mnemonic); only their ISel selection is forbidden here.
let Predicates = [IsARCompact, HasSwape] in {
  def : Pat<(bswap GPR32:$c),
            (ARC_SWAPE_b_c GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// NEG: b = 0 - c  (two's complement negate)
// ARCv2 does not pattern-match NEG (only rsub with 0).
// NEG in ARCompact is encoded as RSUB a,b,0 (subop 0x0E).
// The auto-generated ARC_NEG_a_b uses 3op format with implicit 0.
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(ineg GPR32:$b),
            (ARC_NEG_a_b GPR32:$b)>;
}

//===----------------------------------------------------------------------===//
// EXTB: b = zext8(c)  (zero extend byte)
// EXTW: b = zext16(c) (zero extend halfword)
// These are modeled as AND with mask by LLVM.
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(and GPR32:$c, 255),
            (ARC_EXTB_b_c GPR32:$c)>;
  def : Pat<(and GPR32:$c, 65535),
            (ARC_EXTW_b_c GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// ABS: b = |c|  (absolute value)
// Not in ARCv2 ISA.
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(abs GPR32:$c),
            (ARC_ABS_b_c GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// SEXB: b = sext8(c)  (sign-extend byte)
// SEXW: b = sext16(c) (sign-extend halfword, named sexw in ARCompact binutils)
//
// The ARCv2 backend already defines SEXB_rr and SEXH_rr with identical
// sext_inreg patterns (ARCInstrInfo.td lines 355-356).  Those instructions
// use a different encoding (major opcode 0x04, GEN4 sub-opcode) and are
// gated by no ARCompact predicate, so they can fire on any ARC target.
//
// We add ARCompact-specific patterns pointing at the auto-generated
// ARC_SEXB_b_c / ARC_SEXW_b_c variants so that when IsARCompact is active
// the code-generator can also use these encodings.  TableGen will prefer
// the more-specific predicate match.
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(sext_inreg GPR32:$c, i8),
            (ARC_SEXB_b_c GPR32:$c)>;
  def : Pat<(sext_inreg GPR32:$c, i16),
            (ARC_SEXW_b_c GPR32:$c)>;
}

//===----------------------------------------------------------------------===//
// RCMP: reverse compare (rcmp b, c  ≡  cmp c, b)
//
// RCMP computes (C - B) and updates flags — it is the mirror of CMP.
// In LLVM's ISel, comparisons are lowered via ARCISD::CMP with operands
// already in the required order, so there is no DAG node whose natural
// encoding maps to RCMP rather than CMP.  RCMP is therefore not useful as
// an ISel target; it remains available as an assembler mnemonic only.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// RLC: rotate left through carry (b = (c << 1) | carry)
// RRC: rotate right through carry (b = (c >> 1) | (carry << 31))
//
// Fixed (dossier 24): these were previously left without any ISel pattern
// because RLC/RRC's carry operand is not a plain DAG value -- it is the
// STATUS32.C bit ejected by an ADJACENT `.f`-form producer, and nothing may
// be scheduled between the two (isa-characterization.md 5.1: multi-bit
// barrel `.f` is NOT flag-identical to the single-bit SOP form, so this is
// PINNED to a literal 1-bit shift). Rather than a SelectionDAG glue node
// (no working STATUS32-glue precedent exists in this backend -- ADDC/ADDE/
// SUBC/SUBE are marked Legal in ARCISelLowering.cpp but have no Pat
// anywhere and are dead), RLC is selected only via two atomic MI pseudos
// that bundle a `.f` producer with its RLC consumer as ONE pre-RA
// instruction (mirroring the UADDSAT_PSEUDO/UADDO_PSEUDO mechanism in
// ARCInstrInfo.td):
//   - SHL64_1_PSEUDO: i64 `shl x, 1` -> asl.f (lo) + rlc (hi).
//   - BITREV_STEP_PSEUDO: one bit-reverse step -> lsr.f (x) + rlc (y).
// Both pseudos are recognized from ordinary i32/i64 DAG shapes by a
// DAGCombine on ISD::OR (performShl64By1Combine / performBitRevStepCombine
// in ARCISelLowering.cpp) and expanded post-scheduling in
// ARCExpandPseudos.cpp (expandSHL64_1 / expandBitRevStep), so no other
// STATUS32-writing instruction can land between the producer and the RLC
// consumer. ARC_RLC_b_c / ARC_RRC_b_c carry a corrected Uses=[STATUS32]
// (not Defs -- F=0 on both, they don't write the flag, only read it) so
// LiveIntervals models the real dependency. RRC's first real consumer is
// AVGFLOORU_PSEUDO / expandAVGFLOORU in ARCExpandPseudos.cpp (dossier 19,
// docs/llvm-arc700-optimizations/19-flag-consuming-arithmetic-idioms.md):
// add.f produces the raw carry-out (bit 32 of the true 33-bit sum) and rrc
// folds it into the vacated MSB while shifting right by one, giving the
// exact unsigned floor((a+b)/2) even when the 32-bit sum wraps. Neither RLC
// nor RRC has a direct ISel Pat of its own -- they are ONLY ever constructed
// inside the three expand functions above/below (expandSHL64_1,
// expandBitRevStep, expandAVGFLOORU), so there is no path by which a
// shift/rotate outside the pinned 1-bit carry-chain shapes could ever reach
// an RLC/RRC opcode.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// NORM: count leading redundant sign bits (for normalization)
// Already in ARCv2 as NORM/NORMH with HasNorm predicate.
// The ARCompact NORM is different encoding but same operation.
// No additional pattern needed -- ARCv2 patterns cover this.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// MPYH: signed multiply, return high 32 bits (mulhs)
// MPYHU: unsigned multiply, return high 32 bits (mulhu)
// Already pattern-matched in ARCv2 via MultiPat<mulhs/mulhu>.
// The ARCompact versions share the same encoding space.
// No additional patterns needed.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// EX: atomic exchange (swap memory and register)
// This is a hardware atomic -- needs custom lowering or intrinsic.
// No simple DAG pattern; leave for custom ISelLowering.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// BTST: bit test (sets Z flag if bit at position is 0)
//
// Fixed (dossier 24): the auto-generated BTST defs had a bogus
// (outs GPR32:$rb) and no Defs=[STATUS32] -- corrected in
// ARCARCompactInstrALU.td / ARCARCompactInstr16.td / ARCInstrInfo.td to
// (outs)/Defs=[STATUS32]/isCompare=1. The register-position and
// immediate-position selection Pats are below, after the pow2_mask /
// log2_pow2 defs they reuse (~line 370). ARCTargetLowering::LowerSELECT_CC
// emits the ARCbtst target node (in place of ARCcmp) when it recognizes
// `(x & mask) ==/!= 0` under SETEQ/SETNE -- see ARCISelLowering.cpp.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// DIVAW: division assist step
// SAT16: saturate to signed 16-bit
// RND16: round to 16-bit
// ABSS: absolute value with saturation
// ABSSW: absolute value saturated word
// NEGS: negate with saturation
// NEGSW: negate saturated word
// ADDS: add with saturation
// SUBS: subtract with saturation
//
// These are DSP-style instructions with saturation semantics.
// They require custom ISD nodes or intrinsics to be properly matched.
// No standard LLVM SDNode corresponds to saturating arithmetic on ARC.
// TODO: Add target-specific intrinsics for these operations.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// 16-bit compact instruction patterns
// These are size-optimization alternatives to their 32-bit counterparts.
// They use restricted register classes (r0-r3 for some, r0-r15 for others).
// TODO: Add patterns with appropriate register constraints for 16-bit forms.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// BBIT0/BBIT1: Branch on Bit Test
//
// bbit0 b, u5, target  -- branch if bit u5 of b is 0
// bbit1 b, u5, target  -- branch if bit u5 of b is 1
//
// The hardware instruction takes a u6 immediate for the bit position,
// but only bits 0-31 are meaningful for a 32-bit register, so we
// constrain to u5 (0-31) for ISel.
//
// DAG patterns matched:
//   brcond (seteq (and X, (1 << N)), 0), bb  ->  bbit0 X, N, bb
//   brcond (setne (and X, (1 << N)), 0), bb  ->  bbit1 X, N, bb
//   brcond (seteq (and X, POWER_OF_2), 0), bb -> bbit0 X, log2(P), bb
//   brcond (setne (and X, POWER_OF_2), 0), bb -> bbit1 X, log2(P), bb
//===----------------------------------------------------------------------===//

// ImmLeaf for bit position 0-31 (fits in u6 operand field).
def immU5 : ImmLeaf<i32, [{
  return Imm >= 0 && Imm <= 31;
}]>;

// ImmLeaf matching a power of 2 in [1, 1<<31].
//
// Bug fixed (dossier 24): `Imm` is ImmLeaf's sign-extended int64_t view of
// the immediate, so bit 31 (0x80000000) sign-extends to a NEGATIVE int64_t
// and `Imm > 0` incorrectly rejected it -- e.g. `(x & 0x80000000) == 0`
// would then fall through the ARCbtst Pat unmatched, leaving an unselectable
// ARCISD::BTST node (an ISel crash, not a soft fallback: LowerSELECT_CC
// already committed to emitting BTST once isRecognizedBitTestMask accepts
// the mask). Cast to uint32_t first, matching the established idiom already
// used by bit_pos_hi/bclr_mask_hi/bmsk_mask_hi above in this same file. This
// predicate was unreferenced before this dossier (bbit0/bbit1 fusion is an
// MI-level peephole, not a Pat -- see the comment below), so the bug was
// latent; the BTST Pats using it (below) are the first real consumer.
def pow2_mask : ImmLeaf<i32, [{
  return isPowerOf2_32((uint32_t)Imm);
}]>;

// SDNodeXForm to extract log2 of a power-of-2 immediate.
def log2_pow2 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(Log2_32(N->getZExtValue()),
                                   SDLoc(N), MVT::i32);
}]>;

//===----------------------------------------------------------------------===//
// BTST selection from the ARCbtst target node (dossier 24).
//
// LowerSELECT_CC (ARCISelLowering.cpp) emits ARCbtst B, mask -- where mask
// is either a compile-time power-of-2 or `(shl 1, reg)` -- only for
// SETEQ/SETNE-against-zero selects, so the CC-restriction is already
// enforced before these Pats ever see the node; they only need to pick the
// right BTST encoding for the mask shape:
//   - constant power-of-2 mask -> bit position is known at compile time,
//     always 0-31, always fits the u6 immediate form (ARC_BTST_b_u6).
//   - `(shl 1, reg)` mask -> bit position lives in a register
//     (ARC_BTST_b_c), mirroring the existing BSET/BCLR/BXOR/BMSK register
//     Pats above.
// No s12/limm Pat is needed: bit positions are always in [0,31], which
// always fits u6.
//
// De-confliction with bbit0/bbit1 (ARCBranchFinalize.cpp, dossier 07):
// branches never lower through ARCcmp/ARCbtst at all -- LowerBR_CC builds
// ARCISD::BRcc directly from the raw `(and X, mask)` LHS, which selects
// independently as AND_rrr/rru6/rrlimm and is fused into bbit0/bbit1 (or,
// out of s9 range, BTST + Bcc -- see replaceWithCmpBcc below) by the
// MI-level peephole. This Pat only fires on the SELECT_CC (non-branch)
// side, so btst and bbit can never double-match the same node.
//===----------------------------------------------------------------------===//

let Predicates = [IsARCompact] in {
  def : Pat<(ARCbtst GPR32:$b, pow2_mask:$m),
            (ARC_BTST_b_u6 GPR32:$b, (log2_pow2 pow2_mask:$m))>;
  def : Pat<(ARCbtst GPR32:$b, (shl 1, GPR32:$n)),
            (ARC_BTST_b_c GPR32:$b, GPR32:$n)>;
}

//===----------------------------------------------------------------------===//
// Flag-recycling compares (dossier 21 idea 3): LSRTEST / BMSKTEST selection.
//
// ARCTargetLowering::LowerSELECT_CC emits ARCISD::LSRTEST / ARCISD::BMSKTEST
// (in place of ARCcmp) for `x <u 2^K` and `(x & (2^(K+1)-1)) == 0`
// respectively, ONLY when the compared constant is LIMM-sized (see
// isRangeTestPow2 / isMaskZeroTest in ARCISelLowering.cpp -- both mirror the
// bit_pos_hi / bmsk_mask_hi thresholds below). K is already the final
// shift-amount / bit-position value by the time the node is built (unlike
// bit_pos_hi/bmsk_mask_hi above, which take the raw mask and compute log2
// via an SDNodeXForm at Pat-match time) -- so these Pats need only a
// range-check-and-passthrough for the immediate operand, not a further
// transform.
//
// Coordination:
//   - vs. BTST (dossier 24, above): BTST matches a single set bit
//     (isPowerOf2_64, any magnitude, no LIMM gate); BMSKTEST matches a
//     CONTIGUOUS multi-bit run-from-LSB (isMask_32) that is LIMM-gated. The
//     only overlap point (mask=1, both a single bit and a 1-bit run) is
//     excluded by BMSKTEST's own >2047 gate, so BTST always claims it
//     uncontested -- no AddedComplexity/ordering needed.
//   - vs. dossier-16's value-producing BMSK Pat (ARC_BMSK_a_b_u6 above,
//     same bmsk_mask_hi ImmLeaf): that Pat matches `(and X,mask)` in a
//     VALUE-CONSUMING context (`(set GPR32:$dst, (and ...))`); BMSKTEST
//     matches the same shape but only inside LowerSELECT_CC's
//     SETCC-vs-0 recognition (a COMPARE-consuming context, decided in C++
//     before generic Pat matching ever sees that AND use). Non-competing:
//     if the AND also feeds a real value use elsewhere, dossier-16's Pat
//     still selects that use normally.
//   - vs. BR_CC: branches never reach LSRTEST/BMSKTEST at all --
//     LowerBR_CC keeps emitting the generic ARCISD::BRcc node unchanged.
//     The branch-side flag-recycling fold is a POST-ISEL peephole in
//     ARCBranchFinalize.cpp instead (mirrors why bbit0/bbit1 fusion above
//     is a peephole and not a Pat: a dedicated glue-consuming branch node
//     built straight out of ISel would be unanalyzable by analyzeBranch and
//     break MachineBlockPlacement/BranchFolding. The blocker is the glue --
//     flags read from a SEPARATE producer that analyzeBranch cannot hand back
//     in Cond -- not the opcode list. Self-contained compare pseudos are
//     analyzable: see isCondBranchOpcode in ARCInstrInfo.cpp.
//===----------------------------------------------------------------------===//

// K is already range-checked and computed (Log2_32 of the pow2 RHS, or the
// bmsk bit-position) by the C++ side before the node is built -- this
// ImmLeaf only re-confirms the u6 range and the Xform is a pure passthrough
// (no further math), unlike log2_bit_pos_hi/log2_bmsk_mask_hi above.
def u6_passthrough : ImmLeaf<i32, [{
  return isUInt<6>((uint32_t)Imm);
}]>;
def u6_identity : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(N->getZExtValue(), SDLoc(N), MVT::i32);
}]>;

let Predicates = [IsARCompact] in {
  def : Pat<(ARClsrtest GPR32:$b, u6_passthrough:$k),
            (ARC_LSR_z_b_u6_f GPR32:$b, (u6_identity u6_passthrough:$k))>;
  def : Pat<(ARCbmsktest GPR32:$b, u6_passthrough:$k),
            (ARC_BMSK_z_b_u6_f GPR32:$b, (u6_identity u6_passthrough:$k))>;
}

// Bit-test-and-branch (bbit0/bbit1) is NOT selected via an ISel pattern. A
// dedicated node/pseudo would be unanalyzable by analyzeBranch and break
// MachineBlockPlacement (a conditional branch to a fall-through block would
// lose its label). Instead ARCBranchFinalize fuses an adjacent single-bit
// `and` feeding an in-range compare-and-branch against zero into a real
// `bbit0`/`bbit1` as a late peephole (see ARCBranchFinalize.cpp). Because it
// only fires on a branch already chosen to be the in-range BRcc form, the
// resulting bbit is guaranteed to be within s9 range -- no fallback needed.

//===----------------------------------------------------------------------===//
// LR/SR: Auxiliary Register Access Intrinsics
//
// LR (Load Register): reads an auxiliary register into a core register.
//   Usage: %val = call i32 @llvm.arc.lr(i32 %aux_addr)
//   Maps to: lr $dst, [$aux_addr]
//
// SR (Store Register): writes a core register to an auxiliary register.
//   Usage: call void @llvm.arc.sr(i32 %value, i32 %aux_addr)
//   Maps to: sr $value, [$aux_addr]
//
// The auto-generated SR instructions have $rb_chk in (outs) which is a
// modeling artifact from binutils' operand encoding. For ISel, we define
// pseudo-instructions with correct operand semantics, then expand them
// in ARCInstrInfo::expandPostRAPseudo or via custom inserter.
//
// Known auxiliary registers (ARC700):
//   0x02  LP_START          0x03  LP_END
//   0x10  STATUS32          0x28  AUX_CONTROL
//   0x40  IC_CTRL           0x84  TIMER0_COUNT
//   0x88  TIMER0_CONTROL    0x8C  TIMER0_LIMIT
//   0x94  INT_VECTOR_BASE   0x400 TIMER1_COUNT
//   0x404 TIMER1_CONTROL    0x408 TIMER1_LIMIT
//   0x800 IRQ config
//===----------------------------------------------------------------------===//

// Pseudo-instruction for SR with correct ISel operand modeling.
// The real SR instruction (ARC_SR_b_c / ARC_SR_b_u6 / ARC_SR_b_s12) has
// the source value modeled as an output due to binutils encoding conventions.
// This pseudo has both value and address as inputs, which is correct for ISel.
let Predicates = [IsARCompact] in {
  let hasSideEffects = 1,
      mayStore = 1 in {
    def ARC_SR_PSEUDO : PseudoInstARC<(outs),
        (ins GPR32:$val, GPR32:$aux_addr),
        "# sr $val, [$aux_addr]",
        [(int_arc_sr GPR32:$val, GPR32:$aux_addr)]> {
      let Size = 4;
    }

    def ARC_SR_IMM_PSEUDO : PseudoInstARC<(outs),
        (ins GPR32:$val, i32imm:$aux_addr),
        "# sr $val, [$aux_addr]",
        [(int_arc_sr GPR32:$val, imm32:$aux_addr)]> {
      let Size = 8; // May need limm for large aux addresses
    }
  }

  // LR patterns -- the auto-generated LR instructions have correct operand
  // modeling (output register, input address), so we can add patterns directly.
  let hasSideEffects = 1, mayLoad = 1 in {
    def ARC_LR_PSEUDO : PseudoInstARC<(outs GPR32:$dst),
        (ins GPR32:$aux_addr),
        "# lr $dst, [$aux_addr]",
        [(set GPR32:$dst, (int_arc_lr GPR32:$aux_addr))]> {
      let Size = 4;
    }

    def ARC_LR_IMM_PSEUDO : PseudoInstARC<(outs GPR32:$dst),
        (ins i32imm:$aux_addr),
        "# lr $dst, [$aux_addr]",
        [(set GPR32:$dst, (int_arc_lr imm32:$aux_addr))]> {
      let Size = 8; // May need limm for large aux addresses
    }
  }
}
