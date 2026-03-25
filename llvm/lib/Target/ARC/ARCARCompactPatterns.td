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

  // SWAPE: full byte reversal (bswap)
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
// RLC: rotate left through carry (b = (c << 1) | carry)
// RRC: rotate right through carry (b = (c >> 1) | (carry << 31))
// These require STATUS32 carry flag -- no simple DAG pattern.
// Left without patterns for now; used via inline asm or builtins.
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
// The auto-generated BTST has incorrect (outs GPR32:$rb) modeling.
// BTST should be a compare-like instruction with no output, only flag output.
// Cannot safely add ISel pattern until instruction is re-modeled.
// TODO: Fix BTST instruction definition to have (outs) and Defs=[STATUS32].
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
