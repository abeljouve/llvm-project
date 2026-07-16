//===-- ARCARCompactInstr16.td - ARC ARCompact 16-bit Compact Instructions -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Auto-generated from GNU binutils arc-tbl.h by gen_tablegen.py
// DO NOT EDIT -- regenerate with:
//   python3 tools/gen_tablegen.py
//
// Manual overrides: the generator mis-translated a handful of descriptors
// -- the "High Register" h-field scatter (ADD_S/MOV_S/CMP_S b,h forms), the
// compare-as-definition operand shape (CMP_S), and the register-count shift
// v1 variants -- each hand-patched below with a comment explaining the bug
// and citing the encoding evidence that pinned it down. Regenerating from
// gen_tablegen.py would silently drop these fixes unless the generator
// itself is corrected first.
//
//===----------------------------------------------------------------------===//

// 99 instruction variants

let Predicates = [IsARCompact] in {

// abs_s b,c 01111bbbccc10001.
def ARC_ABS_S_b_c : ARCompactInst16_ALU<0b01111, "abs_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "abs_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007811, Mask: 0x0000F81F
  // Operands: RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b10001;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// add1_s b,b,c 01111bbbccc10100.
def ARC_ADD1_S_b_c : ARCompactInst16_ALU<0b01111, "add1_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "add1_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007814, Mask: 0x0000F81F
  // Operands: RB_S, RB_Sdup, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b10100;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// add2_s b,b,c 01111bbbccc10101.
def ARC_ADD2_S_b_c : ARCompactInst16_ALU<0b01111, "add2_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "add2_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007815, Mask: 0x0000F81F
  // Operands: RB_S, RB_Sdup, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b10101;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// add3_s b,b,c 01111bbbccc10110.
def ARC_ADD3_S_b_c : ARCompactInst16_ALU<0b01111, "add3_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "add3_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007816, Mask: 0x0000F81F
  // Operands: RB_S, RB_Sdup, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b10110;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// add_s a,b,c 01100bbbccc11aaa.
def ARC_ADD_S_ra_s_b_c : ARCompactInst16_ALU<0b01100, "add_s",
    (outs GPR_S:$ra_s), (ins GPR_S:$rb_s, GPR_S:$rc_s),
    "add_s\t$ra_s, $rb_s, $rc_s", []> {
  // Opcode: 0x00006018, Mask: 0x0000F818
  // Operands: RA_S, RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01100;
  let Inst{4-3} = 0b11;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<3> ra_s;
  let Inst{2-0} = ra_s;
}

// add_s b,b,h 01110bbbhhh00HHH.
//
// Manual fix: the generator scattered the 6-bit high-register field
// backwards (bits[7:5]=h{5:3}, bits[2:0]=h{2:0}). docs/isa/15-encoding-16bit.md
// Table 70's "Mov/Cmp/Add with High Register" layout is the opposite:
// bits[7:5] = h[2:0] (low half), bits[2:0] = h[5:3] (high half). Confirmed
// against the authoritative disassembler: the correct split of `mov_s
// r12,r13` encodes 0x74A9 -> `mov r12, r13`; the buggy split of the same
// operands encodes 0x742D -> `mov r12, r41` (wrong register). Same format
// (0x0E) and same h-field shape is shared by MOV_S_b_h/MOV_S_h_b/CMP_S_b_h
// below -- identical fix applied to all four.
def ARC_ADD_S_b_h : ARCompactInst16_ALU<0b01110, "add_s",
    (outs GPR_S:$rb_s), (ins GPR32:$r6h),
    "add_s\t$rb_s, $r6h", []> {
  // Opcode: 0x00007000, Mask: 0x0000F818
  // Operands: RB_S, RB_Sdup, R6H
  // Flags: none
  let Inst{15-11} = 0b01110;
  let Inst{4-3} = 0b00;

  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<6> r6h;
  let Inst{7-5} = r6h{2-0};
  let Inst{2-0} = r6h{5-3};
}

// add_s c,b,u3 01101bbbccc00uuu.
def ARC_ADD_S_c_b_u3 : ARCompactInst16_ALU<0b01101, "add_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s, u3imm:$uimm3_13_s),
    "add_s\t$rc_s, $rb_s, $uimm3_13_s", []> {
  // Opcode: 0x00006800, Mask: 0x0000F818
  // Operands: RC_S, RB_S, UIMM3_13_S
  // Flags: none
  let Inst{15-11} = 0b01101;
  let Inst{4-3} = 0b00;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<3> uimm3_13_s;
  let Inst{2-0} = uimm3_13_s;
}

// add_s b,sp,u7 11000bbb100uuuuu.
def ARC_ADD_S_b_sp_u7 : ARCompactInst16_ALU<0b11000, "add_s",
    (outs GPR_S:$rb_s), (ins GPR32:$sp_s, u7imm_a32:$uimm7_a32_11_s),
    "add_s\t$rb_s, $sp_s, $uimm7_a32_11_s", []> {
  // Opcode: 0x0000C080, Mask: 0x0000F8E0
  // Operands: RB_S, SP_S, UIMM7_A32_11_S
  // Flags: none
  let Inst{15-11} = 0b11000;
  let Inst{7-5} = 0b100;
  // Operand(s) sp_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// add_s b,b,u7 11100bbb0uuuuuuu.
def ARC_ADD_S_b_u7 : ARCompactInst16_ALU<0b11100, "add_s",
    (outs GPR_S:$rb_s), (ins u7imm:$uimm7_9_s),
    "add_s\t$rb_s, $uimm7_9_s", []> {
  // Opcode: 0x0000E000, Mask: 0x0000F880
  // Operands: RB_S, RB_Sdup, UIMM7_9_S
  // Flags: none
  let Inst{15-11} = 0b11100;
  let Inst{7} = 0;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<7> uimm7_9_s;
  let Inst{6-0} = uimm7_9_s;
}

// add_s SP,SP,u7 11000000101uuuuu.
def ARC_ADD_S_sp_sp_u7 : ARCompactInst16_ALU<0b11000, "add_s",
    (outs ), (ins GPR32:$sp_s, GPR32:$sp_sdup, u7imm_a32:$uimm7_a32_11_s),
    "add_s\t$sp_s, $sp_sdup, $uimm7_a32_11_s", []> {
  // Opcode: 0x0000C0A0, Mask: 0x0000FFE0
  // Operands: SP_S, SP_Sdup, UIMM7_A32_11_S
  // Flags: none
  let Inst{15-5} = 0b11000000101;
  // Operand(s) sp_s, sp_sdup need custom disassembler.
  let isCodeGenOnly = 1;
}

// add_s R0,GP,s11 1100111sssssssss.
def ARC_ADD_S_r0_gp_s11 : ARCompactInst16_ALU<0b11001, "add_s",
    (outs ), (ins GPR32:$gp_s, s11imm_a32:$simm11_a32_7_s),
    "add_s\t%r0, $gp_s, $simm11_a32_7_s", []> {
  // Opcode: 0x0000CE00, Mask: 0x0000FE00
  // Operands: R0_S, GP_S, SIMM11_A32_7_S
  // Flags: none
  let Inst{15-9} = 0b1100111;
  // Operand(s) gp_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// add_s b,b,limm 01110bbb11000111.
def ARC_ADD_S_b_limm : ARCompactInst16_ALU<0b01110, "add_s",
    (outs GPR_S:$rb_s), (ins i32imm:$limm_s),
    "add_s\t$rb_s, $limm_s", []> {
  // Opcode: 0x000070C7, Mask: 0x0000F8FF
  // Operands: RB_S, RB_Sdup, LIMM_S
  // Flags: none
  let Inst{15-11} = 0b01110;
  let Inst{7-0} = 0b11000111;
  
  // Operand(s) limm_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// and_s b,b,c 01111bbbccc00100.
def ARC_AND_S_b_c : ARCompactInst16_ALU<0b01111, "and_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "and_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007804, Mask: 0x0000F81F
  // Operands: RB_S, RB_Sdup, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b00100;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// asl_s b,c 01111bbbccc11011.
def ARC_ASL_S_b_c : ARCompactInst16_ALU<0b01111, "asl_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "asl_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x0000781B, Mask: 0x0000F81F
  // Operands: RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b11011;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// asl_s b,b,c 01111bbbccc11000.
//
// Manual fix: the generator's dedup heuristic wrongly treated this as a
// "duplicate encoding variant" of ARC_ASL_S_b_c (sub-opcode 0x1B) and left
// rb_s/rc_s unbound, so the MC encoder emitted the fixed opcode word 0x7818
// regardless of operands (silently encoding r0,r0). They are NOT duplicates:
// per docs/isa/15-encoding-16bit.md Table 71, sub-opcode 0x18 is
// "B <- B ASL C" (the real variable-register-count shift this reduction
// needs), while 0x1B is the unrelated "B <- C+C" shift-by-one idiom that
// ARC_ASL_S_b_c correctly encodes. Added the same rb_s/rc_s bit binding
// already used by the neighboring correctly-encoded defs and dropped the
// bogus isCodeGenOnly. Byte-verified: 0x7DD8 (b=r13, c=r14) decodes via the
// authoritative disassembler as `asl r13, r13, r14`.
def ARC_ASL_S_b_c_v1 : ARCompactInst16_ALU<0b01111, "asl_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "asl_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007818, Mask: 0x0000F81F
  // Operands: RB_S, RB_Sdup, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b11000;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// asl_s c,b,u3 01101bbbccc10uuu.
def ARC_ASL_S_c_b_u3 : ARCompactInst16_ALU<0b01101, "asl_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s, u3imm:$uimm3_13_s),
    "asl_s\t$rc_s, $rb_s, $uimm3_13_s", []> {
  // Opcode: 0x00006810, Mask: 0x0000F818
  // Operands: RC_S, RB_S, UIMM3_13_S
  // Flags: none
  let Inst{15-11} = 0b01101;
  let Inst{4-3} = 0b10;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<3> uimm3_13_s;
  let Inst{2-0} = uimm3_13_s;
}

// asl_s b,b,u5 10111bbb000uuuuu.
def ARC_ASL_S_b_u5 : ARCompactInst16_ALU<0b10111, "asl_s",
    (outs GPR_S:$rb_s), (ins u5imm:$uimm5_11_s),
    "asl_s\t$rb_s, $uimm5_11_s", []> {
  // Opcode: 0x0000B800, Mask: 0x0000F8E0
  // Operands: RB_S, RB_Sdup, UIMM5_11_S
  // Flags: none
  let Inst{15-11} = 0b10111;
  let Inst{7-5} = 0b000;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<5> uimm5_11_s;
  let Inst{4-0} = uimm5_11_s;
}

// asr_s b,c 01111bbbccc11100.
def ARC_ASR_S_b_c : ARCompactInst16_ALU<0b01111, "asr_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "asr_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x0000781C, Mask: 0x0000F81F
  // Operands: RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b11100;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// asr_s b,b,c 01111bbbccc11010.
//
// Manual fix: same missing-bit-binding bug as ARC_ASL_S_b_c_v1 above. Per
// Table 71, sub-opcode 0x1A is "B <- B ASR C" (the real variable shift);
// 0x1C ("B <- C ASR 1", shift-by-one) is the unrelated instruction
// ARC_ASR_S_b_c already encodes correctly. Added the rb_s/rc_s binding and
// dropped the bogus isCodeGenOnly.
def ARC_ASR_S_b_c_v1 : ARCompactInst16_ALU<0b01111, "asr_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "asr_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x0000781A, Mask: 0x0000F81F
  // Operands: RB_S, RB_Sdup, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b11010;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// asr_s c,b,u3 01101bbbccc11uuu.
def ARC_ASR_S_c_b_u3 : ARCompactInst16_ALU<0b01101, "asr_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s, u3imm:$uimm3_13_s),
    "asr_s\t$rc_s, $rb_s, $uimm3_13_s", []> {
  // Opcode: 0x00006818, Mask: 0x0000F818
  // Operands: RC_S, RB_S, UIMM3_13_S
  // Flags: none
  let Inst{15-11} = 0b01101;
  let Inst{4-3} = 0b11;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<3> uimm3_13_s;
  let Inst{2-0} = uimm3_13_s;
}

// asr_s b,b,u5 10111bbb010uuuuu.
def ARC_ASR_S_b_u5 : ARCompactInst16_ALU<0b10111, "asr_s",
    (outs GPR_S:$rb_s), (ins u5imm:$uimm5_11_s),
    "asr_s\t$rb_s, $uimm5_11_s", []> {
  // Opcode: 0x0000B840, Mask: 0x0000F8E0
  // Operands: RB_S, RB_Sdup, UIMM5_11_S
  // Flags: none
  let Inst{15-11} = 0b10111;
  let Inst{7-5} = 0b010;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<5> uimm5_11_s;
  let Inst{4-0} = uimm5_11_s;
}

// bclr_s b,b,u5 10111bbb101uuuuu.
def ARC_BCLR_S_b_u5 : ARCompactInst16_ALU<0b10111, "bclr_s",
    (outs GPR_S:$rb_s), (ins u5imm:$uimm5_11_s),
    "bclr_s\t$rb_s, $uimm5_11_s", []> {
  // Opcode: 0x0000B8A0, Mask: 0x0000F8E0
  // Operands: RB_S, RB_Sdup, UIMM5_11_S
  // Flags: none
  let Inst{15-11} = 0b10111;
  let Inst{7-5} = 0b101;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<5> uimm5_11_s;
  let Inst{4-0} = uimm5_11_s;
}

// beq_sCC_EQ s10 1111001sssssssss.
def ARC_BEQ_S_s10_eq : ARCompactInst16_Branch<0b11110, "beq_s",
    (outs ), (ins brtarget_s10:$simm10_a16_7_s),
    "beq_s\t$simm10_a16_7_s", []> {
  // Opcode: 0x0000F200, Mask: 0x0000FE00
  // Operands: SIMM10_A16_7_S
  // Flags: C_CC_EQ
  let Inst{15-9} = 0b1111001;
  let isPredicable = 1;
  bits<9> simm10_a16_7_s;
  let Inst{8-0} = simm10_a16_7_s;
}

// bge_sCC_GE s7 1111011001ssssss.
def ARC_BGE_S_s7_ge : ARCompactInst16_Branch<0b11110, "bge_s",
    (outs ), (ins brtarget_s7:$simm7_a16_10_s),
    "bge_s\t$simm7_a16_10_s", []> {
  // Opcode: 0x0000F640, Mask: 0x0000FFC0
  // Operands: SIMM7_A16_10_S
  // Flags: C_CC_GE
  let Inst{15-6} = 0b1111011001;
  let isPredicable = 1;
  bits<6> simm7_a16_10_s;
  let Inst{5-0} = simm7_a16_10_s;
}

// bgt_sCC_GT s7 1111011000ssssss.
def ARC_BGT_S_s7_gt : ARCompactInst16_Branch<0b11110, "bgt_s",
    (outs ), (ins brtarget_s7:$simm7_a16_10_s),
    "bgt_s\t$simm7_a16_10_s", []> {
  // Opcode: 0x0000F600, Mask: 0x0000FFC0
  // Operands: SIMM7_A16_10_S
  // Flags: C_CC_GT
  let Inst{15-6} = 0b1111011000;
  let isPredicable = 1;
  bits<6> simm7_a16_10_s;
  let Inst{5-0} = simm7_a16_10_s;
}

// bhi_sCC_HI s7 1111011100ssssss.
def ARC_BHI_S_s7_hi : ARCompactInst16_Branch<0b11110, "bhi_s",
    (outs ), (ins brtarget_s7:$simm7_a16_10_s),
    "bhi_s\t$simm7_a16_10_s", []> {
  // Opcode: 0x0000F700, Mask: 0x0000FFC0
  // Operands: SIMM7_A16_10_S
  // Flags: C_CC_HI
  let Inst{15-6} = 0b1111011100;
  let isPredicable = 1;
  bits<6> simm7_a16_10_s;
  let Inst{5-0} = simm7_a16_10_s;
}

// bhs_sCC_HS s7 1111011101ssssss.
def ARC_BHS_S_s7_hs : ARCompactInst16_Branch<0b11110, "bhs_s",
    (outs ), (ins brtarget_s7:$simm7_a16_10_s),
    "bhs_s\t$simm7_a16_10_s", []> {
  // Opcode: 0x0000F740, Mask: 0x0000FFC0
  // Operands: SIMM7_A16_10_S
  // Flags: C_CC_HS
  let Inst{15-6} = 0b1111011101;
  let isPredicable = 1;
  bits<6> simm7_a16_10_s;
  let Inst{5-0} = simm7_a16_10_s;
}

// bic_s b,b,c 01111bbbccc00110.
def ARC_BIC_S_b_c : ARCompactInst16_ALU<0b01111, "bic_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "bic_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007806, Mask: 0x0000F81F
  // Operands: RB_S, RB_Sdup, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b00110;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// ble_sCC_LE s7 1111011011ssssss.
def ARC_BLE_S_s7_le : ARCompactInst16_Branch<0b11110, "ble_s",
    (outs ), (ins brtarget_s7:$simm7_a16_10_s),
    "ble_s\t$simm7_a16_10_s", []> {
  // Opcode: 0x0000F6C0, Mask: 0x0000FFC0
  // Operands: SIMM7_A16_10_S
  // Flags: C_CC_LE
  let Inst{15-6} = 0b1111011011;
  let isPredicable = 1;
  bits<6> simm7_a16_10_s;
  let Inst{5-0} = simm7_a16_10_s;
}

// blo_sCC_LO s7 1111011110ssssss.
def ARC_BLO_S_s7_lo : ARCompactInst16_Branch<0b11110, "blo_s",
    (outs ), (ins brtarget_s7:$simm7_a16_10_s),
    "blo_s\t$simm7_a16_10_s", []> {
  // Opcode: 0x0000F780, Mask: 0x0000FFC0
  // Operands: SIMM7_A16_10_S
  // Flags: C_CC_LO
  let Inst{15-6} = 0b1111011110;
  let isPredicable = 1;
  bits<6> simm7_a16_10_s;
  let Inst{5-0} = simm7_a16_10_s;
}

// bls_sCC_LS s7 1111011111ssssss.
def ARC_BLS_S_s7_ls : ARCompactInst16_Branch<0b11110, "bls_s",
    (outs ), (ins brtarget_s7:$simm7_a16_10_s),
    "bls_s\t$simm7_a16_10_s", []> {
  // Opcode: 0x0000F7C0, Mask: 0x0000FFC0
  // Operands: SIMM7_A16_10_S
  // Flags: C_CC_LS
  let Inst{15-6} = 0b1111011111;
  let isPredicable = 1;
  bits<6> simm7_a16_10_s;
  let Inst{5-0} = simm7_a16_10_s;
}

// blt_sCC_LT s7 1111011010ssssss.
def ARC_BLT_S_s7_lt : ARCompactInst16_Branch<0b11110, "blt_s",
    (outs ), (ins brtarget_s7:$simm7_a16_10_s),
    "blt_s\t$simm7_a16_10_s", []> {
  // Opcode: 0x0000F680, Mask: 0x0000FFC0
  // Operands: SIMM7_A16_10_S
  // Flags: C_CC_LT
  let Inst{15-6} = 0b1111011010;
  let isPredicable = 1;
  bits<6> simm7_a16_10_s;
  let Inst{5-0} = simm7_a16_10_s;
}

// bl_s s13 11111sssssssssss.
def ARC_BL_S_s13 : ARCompactInst16_Branch<0b11111, "bl_s",
    (outs ), (ins calltarget_s13:$simm13_a32_5_s),
    "bl_s\t$simm13_a32_5_s", []> {
  // Opcode: 0x0000F800, Mask: 0x0000F800
  // Operands: SIMM13_A32_5_S
  // Flags: none
  let Inst{15-11} = 0b11111;
  bits<11> simm13_a32_5_s;
  let Inst{10-0} = simm13_a32_5_s;
}

// bmsk_s b,b,u5 10111bbb110uuuuu.
def ARC_BMSK_S_b_u5 : ARCompactInst16_ALU<0b10111, "bmsk_s",
    (outs GPR_S:$rb_s), (ins u5imm:$uimm5_11_s),
    "bmsk_s\t$rb_s, $uimm5_11_s", []> {
  // Opcode: 0x0000B8C0, Mask: 0x0000F8E0
  // Operands: RB_S, RB_Sdup, UIMM5_11_S
  // Flags: none
  let Inst{15-11} = 0b10111;
  let Inst{7-5} = 0b110;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<5> uimm5_11_s;
  let Inst{4-0} = uimm5_11_s;
}

// bne_sCC_NE s10 1111010sssssssss.
def ARC_BNE_S_s10_ne : ARCompactInst16_Branch<0b11110, "bne_s",
    (outs ), (ins brtarget_s10:$simm10_a16_7_s),
    "bne_s\t$simm10_a16_7_s", []> {
  // Opcode: 0x0000F400, Mask: 0x0000FE00
  // Operands: SIMM10_A16_7_S
  // Flags: C_CC_NE
  let Inst{15-9} = 0b1111010;
  let isPredicable = 1;
  bits<9> simm10_a16_7_s;
  let Inst{8-0} = simm10_a16_7_s;
}

// breq_sCC_EQ b,0,s8 11101bbb0sssssss.
def ARC_BREQ_S_b_z_s8_eq : ARCompactInst16_Branch<0b11101, "breq_s",
    (outs ), (ins GPR_S:$rb_s, brtarget_s8:$simm8_a16_9_s),
    "breq_s\t$rb_s, $simm8_a16_9_s", []> {
  // Opcode: 0x0000E800, Mask: 0x0000F880
  // Operands: RB_S, ZB_S, SIMM8_A16_9_S
  // Flags: C_CC_EQ
  let Inst{15-11} = 0b11101;
  let Inst{7} = 0;
  let isPredicable = 1;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<7> simm8_a16_9_s;
  let Inst{6-0} = simm8_a16_9_s;
}

// brk_s  0111111111111111.
def ARC_BRK_S_0 : ARCompactInst16_ALU<0b01111, "brk_s",
    (outs ), (ins),
    "brk_s", []> {
  // Opcode: 0x00007FFF, Mask: 0x0000FFFF
  // Operands: 0
  // Flags: none
  let Inst{15-0} = 0b0111111111111111;
}

// brne_sCC_NE b,0,s8 11101bbb1sssssss.
def ARC_BRNE_S_b_z_s8_ne : ARCompactInst16_Branch<0b11101, "brne_s",
    (outs ), (ins GPR_S:$rb_s, brtarget_s8:$simm8_a16_9_s),
    "brne_s\t$rb_s, $simm8_a16_9_s", []> {
  // Opcode: 0x0000E880, Mask: 0x0000F880
  // Operands: RB_S, ZB_S, SIMM8_A16_9_S
  // Flags: C_CC_NE
  let Inst{15-11} = 0b11101;
  let Inst{7} = 1;
  let isPredicable = 1;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<7> simm8_a16_9_s;
  let Inst{6-0} = simm8_a16_9_s;
}

// bset_s b,b,u5 10111bbb100uuuuu.
def ARC_BSET_S_b_u5 : ARCompactInst16_ALU<0b10111, "bset_s",
    (outs GPR_S:$rb_s), (ins u5imm:$uimm5_11_s),
    "bset_s\t$rb_s, $uimm5_11_s", []> {
  // Opcode: 0x0000B880, Mask: 0x0000F8E0
  // Operands: RB_S, RB_Sdup, UIMM5_11_S
  // Flags: none
  let Inst{15-11} = 0b10111;
  let Inst{7-5} = 0b100;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<5> uimm5_11_s;
  let Inst{4-0} = uimm5_11_s;
}

// btst_s b,u5 10111bbb111uuuuu.
//
// Same compare-like fix as the 32-bit BTST family (dossier 24): $rb_s is a
// source, not a destination, and the instruction only writes STATUS32.
// Moved into (ins); byte-identical encoding (bits<3> rb_s binds by name).
def ARC_BTST_S_b_u5 : ARCompactInst16_ALU<0b10111, "btst_s",
    (outs), (ins GPR_S:$rb_s, u5imm:$uimm5_11_s),
    "btst_s\t$rb_s, $uimm5_11_s", []> {
  // Opcode: 0x0000B8E0, Mask: 0x0000F8E0
  // Operands: RB_S, UIMM5_11_S
  // Flags: none
  let Inst{15-11} = 0b10111;
  let Inst{7-5} = 0b111;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<5> uimm5_11_s;
  let Inst{4-0} = uimm5_11_s;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// b_s s10 1111000sssssssss.
def ARC_B_S_s10 : ARCompactInst16_Branch<0b11110, "b_s",
    (outs ), (ins brtarget_s10:$simm10_a16_7_s),
    "b_s\t$simm10_a16_7_s", []> {
  // Opcode: 0x0000F000, Mask: 0x0000FE00
  // Operands: SIMM10_A16_7_S
  // Flags: none
  let Inst{15-9} = 0b1111000;
  bits<9> simm10_a16_7_s;
  let Inst{8-0} = simm10_a16_7_s;
}

// cmp_s b,h 01110bbbhhh10HHH.
//
// Two manual fixes:
// 1. h-field scatter (see ARC_ADD_S_b_h above for the byte-verified evidence):
//    bits[7:5]=h[2:0], bits[2:0]=h[5:3].
// 2. Operand-as-def bug: `cmp` never writes a register -- it only reads
//    both operands and sets STATUS32. The generator modeled $rb_s as an
//    output (def), which is the same class of bug already fixed on
//    BTST_S_b_u5 above and on the wide 32-bit CMP (ARCInstrInfo.td's
//    `ArcSpecialDOPInst`, `(outs), (ins GPR32:$B, GPR32:$C)` under
//    `isCompare = 1, Defs = [STATUS32]`). Moved $rb_s into (ins) and added
//    the matching isCompare/Defs. Byte-identical encoding -- bits<3> rb_s
//    still binds by name to Inst{10-8}, only the MachineInstr operand
//    shape (def->use) and the flag metadata changed.
def ARC_CMP_S_b_h : ARCompactInst16_ALU<0b01110, "cmp_s",
    (outs), (ins GPR_S:$rb_s, GPR32:$r6h),
    "cmp_s\t$rb_s, $r6h", []> {
  // Opcode: 0x00007010, Mask: 0x0000F818
  // Operands: RB_S, R6H
  // Flags: none
  let Inst{15-11} = 0b01110;
  let Inst{4-3} = 0b10;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<6> r6h;
  let Inst{7-5} = r6h{2-0};
  let Inst{2-0} = r6h{5-3};
  let isCompare = 1;
  let Defs = [STATUS32];
}

// cmp_s b,u7 11100bbb1uuuuuuu.
//
// Manual fix: same operand-as-def bug as ARC_CMP_S_b_h above -- $rb_s is a
// source, never a destination. Moved into (ins); byte-identical encoding
// (bits<3> rb_s binds by name).
def ARC_CMP_S_b_u7 : ARCompactInst16_ALU<0b11100, "cmp_s",
    (outs), (ins GPR_S:$rb_s, u7imm:$uimm7_9_s),
    "cmp_s\t$rb_s, $uimm7_9_s", []> {
  // Opcode: 0x0000E080, Mask: 0x0000F880
  // Operands: RB_S, UIMM7_9_S
  // Flags: none
  let Inst{15-11} = 0b11100;
  let Inst{7} = 1;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<7> uimm7_9_s;
  let Inst{6-0} = uimm7_9_s;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// cmp_s b,limm 01110bbb11010111.
//
// Manual fix: same operand-as-def bug as ARC_CMP_S_b_h above -- $rb_s is a
// source, never a destination. Moved into (ins); byte-identical encoding.
def ARC_CMP_S_b_limm : ARCompactInst16_ALU<0b01110, "cmp_s",
    (outs), (ins GPR_S:$rb_s, i32imm:$limm_s),
    "cmp_s\t$rb_s, $limm_s", []> {
  // Opcode: 0x000070D7, Mask: 0x0000F8FF
  // Operands: RB_S, LIMM_S
  // Flags: none
  let Inst{15-11} = 0b01110;
  let Inst{7-0} = 0b11010111;
  // Operand(s) limm_s need custom disassembler.
  let isCodeGenOnly = 1;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// extb_s b,c 01111bbbccc01111.
def ARC_EXTB_S_b_c : ARCompactInst16_ALU<0b01111, "extb_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "extb_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x0000780F, Mask: 0x0000F81F
  // Operands: RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b01111;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// extw_s b,c 01111bbbccc10000.
def ARC_EXTW_S_b_c : ARCompactInst16_ALU<0b01111, "extw_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "extw_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007810, Mask: 0x0000F81F
  // Operands: RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b10000;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// jeq_sCC_EQ BLINK 0111110011100000.
def ARC_JEQ_S_blink_eq : ARCompactInst16_ALU<0b01111, "jeq_s",
    (outs ), (ins GPR32:$blink_s),
    "jeq_s\t[$blink_s]", []> {
  // Opcode: 0x00007CE0, Mask: 0x0000FFFF
  // Operands: BRAKET, BLINK_S, BRAKETdup
  // Flags: C_CC_EQ
  let Inst{15-0} = 0b0111110011100000;
  let isPredicable = 1;
  // Operand(s) blink_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// jl_s b 01111bbb01000000.
def ARC_JL_S_b : ARCompactInst16_ALU<0b01111, "jl_s",
    (outs ), (ins GPR_S:$rb_s),
    "jl_s\t[$rb_s]", []> {
  // Opcode: 0x00007840, Mask: 0x0000F8FF
  // Operands: BRAKET, RB_S, BRAKETdup
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{7-0} = 0b01000000;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
}

// jl_s.D b 01111bbb01100000.
def ARC_JL_S_b_d : ARCompactInst16_ALU<0b01111, "jl_s",
    (outs ), (ins GPR_S:$rb_s),
    "jl_s\t[$rb_s]", []> {
  // Opcode: 0x00007860, Mask: 0x0000F8FF
  // Operands: BRAKET, RB_S, BRAKETdup
  // Flags: C_DHARD
  let Inst{15-11} = 0b01111;
  let Inst{7-0} = 0b01100000;
  let hasDelaySlot = 1;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
}

// jne_sCC_NE BLINK 0111110111100000.
def ARC_JNE_S_blink_ne : ARCompactInst16_ALU<0b01111, "jne_s",
    (outs ), (ins GPR32:$blink_s),
    "jne_s\t[$blink_s]", []> {
  // Opcode: 0x00007DE0, Mask: 0x0000FFFF
  // Operands: BRAKET, BLINK_S, BRAKETdup
  // Flags: C_CC_NE
  let Inst{15-0} = 0b0111110111100000;
  let isPredicable = 1;
  // Operand(s) blink_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// j_s b 01111bbb00000000.
def ARC_J_S_b : ARCompactInst16_ALU<0b01111, "j_s",
    (outs ), (ins GPR_S:$rb_s),
    "j_s\t[$rb_s]", []> {
  // Opcode: 0x00007800, Mask: 0x0000F8FF
  // Operands: BRAKET, RB_S, BRAKETdup
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{7-0} = 0b00000000;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
}

// j_s.D b 01111bbb00100000.
def ARC_J_S_b_d : ARCompactInst16_ALU<0b01111, "j_s",
    (outs ), (ins GPR_S:$rb_s),
    "j_s\t[$rb_s]", []> {
  // Opcode: 0x00007820, Mask: 0x0000F8FF
  // Operands: BRAKET, RB_S, BRAKETdup
  // Flags: C_DHARD
  let Inst{15-11} = 0b01111;
  let Inst{7-0} = 0b00100000;
  let hasDelaySlot = 1;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
}

// j_s BLINK 0111111011100000.
def ARC_J_S_blink : ARCompactInst16_ALU<0b01111, "j_s",
    (outs ), (ins GPR32:$blink_s),
    "j_s\t[$blink_s]", []> {
  // Opcode: 0x00007EE0, Mask: 0x0000FFFF
  // Operands: BRAKET, BLINK_S, BRAKETdup
  // Flags: none
  let Inst{15-0} = 0b0111111011100000;
  // Operand(s) blink_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// j_s.D BLINK 0111111111100000.
def ARC_J_S_blink_d : ARCompactInst16_ALU<0b01111, "j_s",
    (outs ), (ins GPR32:$blink_s),
    "j_s\t[$blink_s]", []> {
  // Opcode: 0x00007FE0, Mask: 0x0000FFFF
  // Operands: BRAKET, BLINK_S, BRAKETdup
  // Flags: C_DHARD
  let Inst{15-0} = 0b0111111111100000;
  let hasDelaySlot = 1;
  // Operand(s) blink_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// ldb_s a,b,c 01100bbbccc01aaa.
def ARC_LDB_S_ra_s_b_c : ARCompactInst16_LS<0b01100, "ldb_s",
    (outs GPR_S:$ra_s), (ins GPR_S:$rb_s, GPR_S:$rc_s),
    "ldb_s\t$ra_s, [$rb_s, $rc_s]", []> {
  // Opcode: 0x00006008, Mask: 0x0000F818
  // Operands: RA_S, BRAKET, RB_S, RC_S, BRAKETdup
  // Flags: C_ZZ_B
  let Inst{15-11} = 0b01100;
  let Inst{4-3} = 0b01;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<3> ra_s;
  let Inst{2-0} = ra_s;
}

// ldb_s c,b,u5 10001bbbcccuuuuu.
def ARC_LDB_S_c_b_u5 : ARCompactInst16_LS<0b10001, "ldb_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s, u5imm:$uimm5_11_s),
    "ldb_s\t$rc_s, [$rb_s, $uimm5_11_s]", []> {
  // Opcode: 0x00008800, Mask: 0x0000F800
  // Operands: RC_S, BRAKET, RB_S, UIMM5_11_S, BRAKETdup
  // Flags: C_ZZ_B
  let Inst{15-11} = 0b10001;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<5> uimm5_11_s;
  let Inst{4-0} = uimm5_11_s;
}

// ldb_s b,SP,u7 11000bbb001uuuuu.
def ARC_LDB_S_b_sp_u7 : ARCompactInst16_LS<0b11000, "ldb_s",
    (outs GPR_S:$rb_s), (ins GPR32:$sp_s, u7imm_a32:$uimm7_a32_11_s),
    "ldb_s\t$rb_s, [$sp_s, $uimm7_a32_11_s]", []> {
  // Opcode: 0x0000C020, Mask: 0x0000F8E0
  // Operands: RB_S, BRAKET, SP_S, UIMM7_A32_11_S, BRAKETdup
  // Flags: C_ZZ_B
  let Inst{15-11} = 0b11000;
  let Inst{7-5} = 0b001;
  // Operand(s) sp_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// ldb_s R0,GP,s9 1100101sssssssss.
def ARC_LDB_S_r0_gp_s9 : ARCompactInst16_LS<0b11001, "ldb_s",
    (outs ), (ins GPR32:$gp_s, s9imm:$simm9_7_s),
    "ldb_s\t%r0, [$gp_s, $simm9_7_s]", []> {
  // Opcode: 0x0000CA00, Mask: 0x0000FE00
  // Operands: R0_S, BRAKET, GP_S, SIMM9_7_S, BRAKETdup
  // Flags: C_ZZ_B
  let Inst{15-9} = 0b1100101;
  // Operand(s) gp_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// ldw_sZZ_H a,b,c 01100bbbccc10aaa.
def ARC_LDW_S_ra_s_b_c : ARCompactInst16_LS<0b01100, "ldw_s",
    (outs GPR_S:$ra_s), (ins GPR_S:$rb_s, GPR_S:$rc_s),
    "ldw_s\t$ra_s, [$rb_s, $rc_s]", []> {
  // Opcode: 0x00006010, Mask: 0x0000F818
  // Operands: RA_S, BRAKET, RB_S, RC_S, BRAKETdup
  // Flags: C_ZZ_H
  let Inst{15-11} = 0b01100;
  let Inst{4-3} = 0b10;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<3> ra_s;
  let Inst{2-0} = ra_s;
}

// ldw_sZZ_H c,b,u6 10010bbbcccuuuuu.
def ARC_LDW_S_c_b_u6 : ARCompactInst16_LS<0b10010, "ldw_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s, u6imm_a16:$uimm6_a16_11_s),
    "ldw_s\t$rc_s, [$rb_s, $uimm6_a16_11_s]", []> {
  // Opcode: 0x00009000, Mask: 0x0000F800
  // Operands: RC_S, BRAKET, RB_S, UIMM6_A16_11_S, BRAKETdup
  // Flags: C_ZZ_H
  let Inst{15-11} = 0b10010;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<5> uimm6_a16_11_s;
  let Inst{4-0} = uimm6_a16_11_s;
}

// ldw_sZZ_H.X c,b,u6 10011bbbcccuuuuu.
def ARC_LDW_S_c_b_u6_v1 : ARCompactInst16_LS<0b10011, "ldw_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s, u6imm_a16:$uimm6_a16_11_s),
    "ldw_s\t$rc_s, [$rb_s, $uimm6_a16_11_s]", []> {
  // Opcode: 0x00009800, Mask: 0x0000F800
  // Operands: RC_S, BRAKET, RB_S, UIMM6_A16_11_S, BRAKETdup
  // Flags: C_XHARD, C_ZZ_H
  let Inst{15-11} = 0b10011;
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// ldw_s R0,GP,s10 1100110sssssssss.
def ARC_LDW_S_r0_gp_s10 : ARCompactInst16_LS<0b11001, "ldw_s",
    (outs ), (ins GPR32:$gp_s, brtarget_s10:$simm10_a16_7_sbis),
    "ldw_s\t%r0, [$gp_s, $simm10_a16_7_sbis]", []> {
  // Opcode: 0x0000CC00, Mask: 0x0000FE00
  // Operands: R0_S, BRAKET, GP_S, SIMM10_A16_7_Sbis, BRAKETdup
  // Flags: C_ZZ_H
  let Inst{15-9} = 0b1100110;
  // Operand(s) gp_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// ld_s a,b,c 01100bbbccc00aaa.
def ARC_LD_S_ra_s_b_c : ARCompactInst16_LS<0b01100, "ld_s",
    (outs GPR_S:$ra_s), (ins GPR_S:$rb_s, GPR_S:$rc_s),
    "ld_s\t$ra_s, [$rb_s, $rc_s]", []> {
  // Opcode: 0x00006000, Mask: 0x0000F818
  // Operands: RA_S, BRAKET, RB_S, RC_S, BRAKETdup
  // Flags: none
  let Inst{15-11} = 0b01100;
  let Inst{4-3} = 0b00;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<3> ra_s;
  let Inst{2-0} = ra_s;
}

// ld_s b,SP,u7 11000bbb000uuuuu.
def ARC_LD_S_b_sp_u7 : ARCompactInst16_LS<0b11000, "ld_s",
    (outs GPR_S:$rb_s), (ins GPR32:$sp_s, u7imm_a32:$uimm7_a32_11_s),
    "ld_s\t$rb_s, [$sp_s, $uimm7_a32_11_s]", []> {
  // Opcode: 0x0000C000, Mask: 0x0000F8E0
  // Operands: RB_S, BRAKET, SP_S, UIMM7_A32_11_S, BRAKETdup
  // Flags: none
  let Inst{15-11} = 0b11000;
  let Inst{7-5} = 0b000;
  // Operand(s) sp_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// ld_s c,b,u7 10000bbbcccuuuuu.
def ARC_LD_S_c_b_u7 : ARCompactInst16_LS<0b10000, "ld_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s, u7imm_a32:$uimm7_a32_11_s),
    "ld_s\t$rc_s, [$rb_s, $uimm7_a32_11_s]", []> {
  // Opcode: 0x00008000, Mask: 0x0000F800
  // Operands: RC_S, BRAKET, RB_S, UIMM7_A32_11_S, BRAKETdup
  // Flags: none
  let Inst{15-11} = 0b10000;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<5> uimm7_a32_11_s;
  let Inst{4-0} = uimm7_a32_11_s;
}

// ld_s b,PCL,u10 11010bbbuuuuuuuu.
def ARC_LD_S_b_pcl_u10 : ARCompactInst16_LS<0b11010, "ld_s",
    (outs GPR_S:$rb_s), (ins GPR32:$pcl_s, u10imm_a32:$uimm10_a32_8_s),
    "ld_s\t$rb_s, [$pcl_s, $uimm10_a32_8_s]", []> {
  // Opcode: 0x0000D000, Mask: 0x0000F800
  // Operands: RB_S, BRAKET, PCL_S, UIMM10_A32_8_S, BRAKETdup
  // Flags: none
  let Inst{15-11} = 0b11010;
  // Operand(s) pcl_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// ld_s R0,GP,s11 1100100sssssssss.
def ARC_LD_S_r0_gp_s11 : ARCompactInst16_LS<0b11001, "ld_s",
    (outs ), (ins GPR32:$gp_s, s11imm_a32:$simm11_a32_7_s),
    "ld_s\t%r0, [$gp_s, $simm11_a32_7_s]", []> {
  // Opcode: 0x0000C800, Mask: 0x0000FE00
  // Operands: R0_S, BRAKET, GP_S, SIMM11_A32_7_S, BRAKETdup
  // Flags: none
  let Inst{15-9} = 0b1100100;
  // Operand(s) gp_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr_s b,c 01111bbbccc11101.
def ARC_LSR_S_b_c : ARCompactInst16_ALU<0b01111, "lsr_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "lsr_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x0000781D, Mask: 0x0000F81F
  // Operands: RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b11101;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// lsr_s b,b,c 01111bbbccc11001.
//
// Manual fix: same missing-bit-binding bug as ARC_ASL_S_b_c_v1 above. Per
// Table 71, sub-opcode 0x19 is "B <- B LSR C" (the real variable shift);
// 0x1D ("B <- C LSR 1", shift-by-one) is the unrelated instruction
// ARC_LSR_S_b_c already encodes correctly. Added the rb_s/rc_s binding and
// dropped the bogus isCodeGenOnly.
def ARC_LSR_S_b_c_v1 : ARCompactInst16_ALU<0b01111, "lsr_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "lsr_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007819, Mask: 0x0000F81F
  // Operands: RB_S, RB_Sdup, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b11001;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// lsr_s b,b,u5 10111bbb001uuuuu.
def ARC_LSR_S_b_u5 : ARCompactInst16_ALU<0b10111, "lsr_s",
    (outs GPR_S:$rb_s), (ins u5imm:$uimm5_11_s),
    "lsr_s\t$rb_s, $uimm5_11_s", []> {
  // Opcode: 0x0000B820, Mask: 0x0000F8E0
  // Operands: RB_S, RB_Sdup, UIMM5_11_S
  // Flags: none
  let Inst{15-11} = 0b10111;
  let Inst{7-5} = 0b001;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<5> uimm5_11_s;
  let Inst{4-0} = uimm5_11_s;
}

// mov_s b,h 01110bbbhhh01HHH.
//
// Manual fix: h-field scatter (see ARC_ADD_S_b_h above for the byte-verified
// evidence): bits[7:5]=h[2:0], bits[2:0]=h[5:3].
def ARC_MOV_S_b_h : ARCompactInst16_ALU<0b01110, "mov_s",
    (outs GPR_S:$rb_s), (ins GPR32:$r6h),
    "mov_s\t$rb_s, $r6h", []> {
  // Opcode: 0x00007008, Mask: 0x0000F818
  // Operands: RB_S, R6H
  // Flags: none
  let Inst{15-11} = 0b01110;
  let Inst{4-3} = 0b01;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<6> r6h;
  let Inst{7-5} = r6h{2-0};
  let Inst{2-0} = r6h{5-3};
}

// mov_s h,b 01110bbbhhh11HHH.
//
// Manual fix: same h-field scatter bug as ARC_MOV_S_b_h above.
def ARC_MOV_S_h_b : ARCompactInst16_ALU<0b01110, "mov_s",
    (outs GPR_S:$rb_s), (ins GPR32:$r6h),
    "mov_s\t$r6h, $rb_s", []> {
  // Opcode: 0x00007018, Mask: 0x0000F818
  // Operands: R6H, RB_S
  // Flags: none
  let Inst{15-11} = 0b01110;
  let Inst{4-3} = 0b11;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<6> r6h;
  let Inst{7-5} = r6h{2-0};
  let Inst{2-0} = r6h{5-3};
}

// mov_s 0,b 01110bbb1101111H.
def ARC_MOV_S_z_b : ARCompactInst16_ALU<0b01110, "mov_s",
    (outs ), (ins GPR_S:$rb_s),
    "mov_s\t$rb_s", []> {
  // Opcode: 0x000070DE, Mask: 0x0000F8FE
  // Operands: ZA_S, RB_S
  // Flags: none
  let Inst{15-11} = 0b01110;
  let Inst{7-1} = 0b1101111;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
}

// mov_s b,u8 11011bbbuuuuuuuu.
def ARC_MOV_S_b_u8 : ARCompactInst16_ALU<0b11011, "mov_s",
    (outs GPR_S:$rb_s), (ins u8imm:$uimm8_8_s),
    "mov_s\t$rb_s, $uimm8_8_s", []> {
  // Opcode: 0x0000D800, Mask: 0x0000F800
  // Operands: RB_S, UIMM8_8_S
  // Flags: none
  let Inst{15-11} = 0b11011;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<8> uimm8_8_s;
  let Inst{7-0} = uimm8_8_s;
}

// mov_s b,limm 01110bbb11001111.
def ARC_MOV_S_b_limm : ARCompactInst16_ALU<0b01110, "mov_s",
    (outs GPR_S:$rb_s), (ins i32imm:$limm_s),
    "mov_s\t$rb_s, $limm_s", []> {
  // Opcode: 0x000070CF, Mask: 0x0000F8FF
  // Operands: RB_S, LIMM_S
  // Flags: none
  let Inst{15-11} = 0b01110;
  let Inst{7-0} = 0b11001111;
  // Operand(s) limm_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// neg_s b,c 01111bbbccc10011.
def ARC_NEG_S_b_c : ARCompactInst16_ALU<0b01111, "neg_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "neg_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007813, Mask: 0x0000F81F
  // Operands: RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b10011;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// nop_s  0111100011100000.
def ARC_NOP_S_0 : ARCompactInst16_ALU<0b01111, "nop_s",
    (outs ), (ins),
    "nop_s", []> {
  // Opcode: 0x000078E0, Mask: 0x0000FFFF
  // Operands: 0
  // Flags: none
  let Inst{15-0} = 0b0111100011100000;
}

// not_s b,c 01111bbbccc10010.
def ARC_NOT_S_b_c : ARCompactInst16_ALU<0b01111, "not_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "not_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007812, Mask: 0x0000F81F
  // Operands: RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b10010;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// or_s b,b,c 01111bbbccc00101.
def ARC_OR_S_b_c : ARCompactInst16_ALU<0b01111, "or_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "or_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007805, Mask: 0x0000F81F
  // Operands: RB_S, RB_Sdup, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b00101;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// pop_sAA_AB b 11000bbb11000001.
def ARC_POP_S_b : ARCompactInst16_ALU<0b11000, "pop_s",
    (outs GPR_S:$rb_s), (ins ),
    "pop_s\t$rb_s", []> {
  // Opcode: 0x0000C0C1, Mask: 0x0000F8FF
  // Operands: RB_S
  // Flags: C_AA_AB
  let Inst{15-11} = 0b11000;
  let Inst{7-0} = 0b11000001;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
}

// pop_sAA_AB BLINK 11000RRR11010001.
def ARC_POP_S_blink : ARCompactInst16_ALU<0b11000, "pop_s",
    (outs ), (ins GPR32:$blink_s),
    "pop_s\t$blink_s", []> {
  // Opcode: 0x0000C0D1, Mask: 0x0000F8FF
  // Operands: BLINK_S
  // Flags: C_AA_AB
  let Inst{15-11} = 0b11000;
  let Inst{7-0} = 0b11010001;
  // Operand(s) blink_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// push_sAA_AW b 11000bbb11100001.
def ARC_PUSH_S_b : ARCompactInst16_ALU<0b11000, "push_s",
    (outs GPR_S:$rb_s), (ins ),
    "push_s\t$rb_s", []> {
  // Opcode: 0x0000C0E1, Mask: 0x0000F8FF
  // Operands: RB_S
  // Flags: C_AA_AW
  let Inst{15-11} = 0b11000;
  let Inst{7-0} = 0b11100001;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
}

// push_sAA_AW blink 11000RRR11110001.
def ARC_PUSH_S_blink : ARCompactInst16_ALU<0b11000, "push_s",
    (outs ), (ins GPR32:$blink_s),
    "push_s\t$blink_s", []> {
  // Opcode: 0x0000C0F1, Mask: 0x0000F8FF
  // Operands: BLINK_S
  // Flags: C_AA_AW
  let Inst{15-11} = 0b11000;
  let Inst{7-0} = 0b11110001;
  // Operand(s) blink_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// sexb_s b,c 01111bbbccc01101.
def ARC_SEXB_S_b_c : ARCompactInst16_ALU<0b01111, "sexb_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "sexb_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x0000780D, Mask: 0x0000F81F
  // Operands: RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b01101;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// sexw_s b,c 01111bbbccc01110.
def ARC_SEXW_S_b_c : ARCompactInst16_ALU<0b01111, "sexw_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "sexw_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x0000780E, Mask: 0x0000F81F
  // Operands: RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b01110;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// stb_s c,b,u5 10101bbbcccuuuuu.
def ARC_STB_S_c_b_u5 : ARCompactInst16_LS<0b10101, "stb_s",
    (outs ), (ins GPR_S:$rc_s, GPR_S:$rb_s, u5imm:$uimm5_11_s),
    "stb_s\t$rc_s, [$rb_s, $uimm5_11_s]", []> {
  // Opcode: 0x0000A800, Mask: 0x0000F800
  // Operands: RC_S, BRAKET, RB_S, UIMM5_11_S, BRAKETdup
  // Flags: C_ZZ_B
  let Inst{15-11} = 0b10101;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<5> uimm5_11_s;
  let Inst{4-0} = uimm5_11_s;
}

// stb_sZZ_B b,SP,u7 11000bbb011uuuuu.
def ARC_STB_S_b_sp_u7 : ARCompactInst16_LS<0b11000, "stb_s",
    (outs ), (ins GPR_S:$rb_s, GPR32:$sp_s, u7imm_a32:$uimm7_a32_11_s),
    "stb_s\t$rb_s, [$sp_s, $uimm7_a32_11_s]", []> {
  // Opcode: 0x0000C060, Mask: 0x0000F8E0
  // Operands: RB_S, BRAKET, SP_S, UIMM7_A32_11_S, BRAKETdup
  // Flags: C_ZZ_B
  let Inst{15-11} = 0b11000;
  let Inst{7-5} = 0b011;
  // Operand(s) sp_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// stw_sZZ_H c,b,u6 10110bbbcccuuuuu.
def ARC_STW_S_c_b_u6 : ARCompactInst16_LS<0b10110, "stw_s",
    (outs ), (ins GPR_S:$rc_s, GPR_S:$rb_s, u6imm_a16:$uimm6_a16_11_s),
    "stw_s\t$rc_s, [$rb_s, $uimm6_a16_11_s]", []> {
  // Opcode: 0x0000B000, Mask: 0x0000F800
  // Operands: RC_S, BRAKET, RB_S, UIMM6_A16_11_S, BRAKETdup
  // Flags: C_ZZ_H
  let Inst{15-11} = 0b10110;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<5> uimm6_a16_11_s;
  let Inst{4-0} = uimm6_a16_11_s;
}

// st_s b,SP,u7 11000bbb010uuuuu.
def ARC_ST_S_b_sp_u7 : ARCompactInst16_LS<0b11000, "st_s",
    (outs ), (ins GPR_S:$rb_s, GPR32:$sp_s, u7imm_a32:$uimm7_a32_11_s),
    "st_s\t$rb_s, [$sp_s, $uimm7_a32_11_s]", []> {
  // Opcode: 0x0000C040, Mask: 0x0000F8E0
  // Operands: RB_S, BRAKET, SP_S, UIMM7_A32_11_S, BRAKETdup
  // Flags: none
  let Inst{15-11} = 0b11000;
  let Inst{7-5} = 0b010;
  // Operand(s) sp_s need custom disassembler.
  let isCodeGenOnly = 1;
}

// st_s c,b,u7 10100bbbcccuuuuu.
def ARC_ST_S_c_b_u7 : ARCompactInst16_LS<0b10100, "st_s",
    (outs ), (ins GPR_S:$rc_s, GPR_S:$rb_s, u7imm_a32:$uimm7_a32_11_s),
    "st_s\t$rc_s, [$rb_s, $uimm7_a32_11_s]", []> {
  // Opcode: 0x0000A000, Mask: 0x0000F800
  // Operands: RC_S, BRAKET, RB_S, UIMM7_A32_11_S, BRAKETdup
  // Flags: none
  let Inst{15-11} = 0b10100;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<5> uimm7_a32_11_s;
  let Inst{4-0} = uimm7_a32_11_s;
}

// sub_s b,b,c 01111bbbccc00010.
def ARC_SUB_S_b_c : ARCompactInst16_ALU<0b01111, "sub_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "sub_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007802, Mask: 0x0000F81F
  // Operands: RB_S, RB_Sdup, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b00010;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// sub_s c,b,u3 01101bbbccc01uuu.
def ARC_SUB_S_c_b_u3 : ARCompactInst16_ALU<0b01101, "sub_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s, u3imm:$uimm3_13_s),
    "sub_s\t$rc_s, $rb_s, $uimm3_13_s", []> {
  // Opcode: 0x00006808, Mask: 0x0000F818
  // Operands: RC_S, RB_S, UIMM3_13_S
  // Flags: none
  let Inst{15-11} = 0b01101;
  let Inst{4-3} = 0b01;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
  bits<3> uimm3_13_s;
  let Inst{2-0} = uimm3_13_s;
}

// sub_s b,b,u5 10111bbb011uuuuu.
def ARC_SUB_S_b_u5 : ARCompactInst16_ALU<0b10111, "sub_s",
    (outs GPR_S:$rb_s), (ins u5imm:$uimm5_11_s),
    "sub_s\t$rb_s, $uimm5_11_s", []> {
  // Opcode: 0x0000B860, Mask: 0x0000F8E0
  // Operands: RB_S, RB_Sdup, UIMM5_11_S
  // Flags: none
  let Inst{15-11} = 0b10111;
  let Inst{7-5} = 0b011;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<5> uimm5_11_s;
  let Inst{4-0} = uimm5_11_s;
}

// sub_s SP,SP,u7 11000001101uuuuu.
def ARC_SUB_S_sp_sp_u7 : ARCompactInst16_ALU<0b11000, "sub_s",
    (outs ), (ins GPR32:$sp_s, GPR32:$sp_sdup, u7imm_a32:$uimm7_a32_11_s),
    "sub_s\t$sp_s, $sp_sdup, $uimm7_a32_11_s", []> {
  // Opcode: 0x0000C1A0, Mask: 0x0000FFE0
  // Operands: SP_S, SP_Sdup, UIMM7_A32_11_S
  // Flags: none
  let Inst{15-5} = 0b11000001101;
  // Operand(s) sp_s, sp_sdup need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub_s.ne b,b,b 01111bbb11000000.
def ARC_SUB_S_b_ne : ARCompactInst16_ALU<0b01111, "sub_s",
    (outs GPR_S:$rb_s), (ins ),
    "sub_s\t$rb_s", []> {
  // Opcode: 0x000078C0, Mask: 0x0000F8FF
  // Operands: RB_S, RB_Sdup, RB_Sdup
  // Flags: C_NE, C_CC_NE
  let Inst{15-11} = 0b01111;
  let Inst{7-0} = 0b11000000;
  let isPredicable = 1;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
}

// trap_s u6 01111uuuuuu11110.
def ARC_TRAP_S_u6 : ARCompactInst16_ALU<0b01111, "trap_s",
    (outs ), (ins u6imm:$uimm6_5_s),
    "trap_s\t$uimm6_5_s", []> {
  // Opcode: 0x0000781E, Mask: 0x0000F81F
  // Operands: UIMM6_5_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b11110;
  bits<6> uimm6_5_s;
  let Inst{10-5} = uimm6_5_s;
}

// tst_s b,c 01111bbbccc01011.
def ARC_TST_S_b_c : ARCompactInst16_ALU<0b01111, "tst_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "tst_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x0000780B, Mask: 0x0000F81F
  // Operands: RB_S, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b01011;
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

// unimp_s  0111100111100000.
def ARC_UNIMP_S_0 : ARCompactInst16_ALU<0b01111, "unimp_s",
    (outs ), (ins),
    "unimp_s", []> {
  // Opcode: 0x000079E0, Mask: 0x0000FFFF
  // Operands: 0
  // Flags: none
  let Inst{15-0} = 0b0111100111100000;
}

// xor_s b,b,c 01111bbbccc00111.
def ARC_XOR_S_b_c : ARCompactInst16_ALU<0b01111, "xor_s",
    (outs GPR_S:$rb_s), (ins GPR_S:$rc_s),
    "xor_s\t$rb_s, $rc_s", []> {
  // Opcode: 0x00007807, Mask: 0x0000F81F
  // Operands: RB_S, RB_Sdup, RC_S
  // Flags: none
  let Inst{15-11} = 0b01111;
  let Inst{4-0} = 0b00111;
  
  bits<3> rb_s;
  let Inst{10-8} = rb_s;
  bits<3> rc_s;
  let Inst{7-5} = rc_s;
}

} // end let Predicates = [IsARCompact]
