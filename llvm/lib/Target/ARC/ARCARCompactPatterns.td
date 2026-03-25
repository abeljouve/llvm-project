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
def pow2_mask : ImmLeaf<i32, [{
  return Imm > 0 && isPowerOf2_32(Imm);
}]>;

// SDNodeXForm to extract log2 of a power-of-2 immediate.
def log2_pow2 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(Log2_32(N->getZExtValue()),
                                   SDLoc(N), MVT::i32);
}]>;

// PatFrag to match (and X, power-of-2) == 0 as a setcc.
// We use custom PatFrags to combine the and+setcc into a single match.

// Match: (brcond (seteq (and $src, (1 << N)), 0), bb) where N is a register
// This variant uses bbit0 with register bit position (RC operand).
// Not common in practice -- the constant variant below is more useful.

let Predicates = [IsARCompact] in {
  // --- bbit0: branch if bit is 0 ---
  // Lowered from LowerBR_CC: (ARCISD::BBIT0 dest, reg, bitpos)
  def : Pat<(ARCbbit0 bb:$target, GPR32:$rb, immU6:$bit),
            (ARC_BBIT0_b_u6_s9_d GPR32:$rb, immU6:$bit,
              brtarget_s9:$target)>;

  def : Pat<(ARCbbit0 bb:$target, GPR32:$rb, GPR32:$rc),
            (ARC_BBIT0_b_c_s9_d GPR32:$rb, GPR32:$rc,
              brtarget_s9:$target)>;

  // --- bbit1: branch if bit is 1 ---
  // Lowered from LowerBR_CC: (ARCISD::BBIT1 dest, reg, bitpos)
  def : Pat<(ARCbbit1 bb:$target, GPR32:$rb, immU6:$bit),
            (ARC_BBIT1_b_u6_s9_d GPR32:$rb, immU6:$bit,
              brtarget_s9:$target)>;

  def : Pat<(ARCbbit1 bb:$target, GPR32:$rb, GPR32:$rc),
            (ARC_BBIT1_b_c_s9_d GPR32:$rb, GPR32:$rc,
              brtarget_s9:$target)>;
}

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
