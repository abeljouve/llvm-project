//===-- ARCARCompactInstrBranch.td - ARC ARCompact Branch/Jump Instructions -*- tablegen -*-===//
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
//===----------------------------------------------------------------------===//

// 78 instruction variants

let Predicates = [IsARCompact] in {

// b<.d> s25 00000ssssssssss1SSSSSSSSSSNRtttt.
def ARC_B_s25_d : ARCompactInstBranch<0b00000, "b",
    (outs ), (ins brtarget_s25:$simm25_a16_5),
    "b\t$simm25_a16_5", []> {
  // Opcode: 0x00010000, Mask: 0xF8010000
  // Operands: SIMM25_A16_5
  // Flags: C_D
  let Inst{31-27} = 0b00000;
  let Inst{16} = 1;
  let hasDelaySlot = 1;
}

// b<.d><cc> s21 00000ssssssssss0SSSSSSSSSSNQQQQQ.
def ARC_B_s21_cc_d : ARCompactInstBranch<0b00000, "b",
    (outs ), (ins brtarget_s21:$simm21_a16_5),
    "b\t$simm21_a16_5", []> {
  // Opcode: 0x00000000, Mask: 0xF8010000
  // Operands: SIMM21_A16_5
  // Flags: C_CC, C_D
  let Inst{31-27} = 0b00000;
  let Inst{16} = 0;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// bbit0<.d> b,c,s9 00001bbbsssssss1SBBBCCCCCCN01110.
def ARC_BBIT0_b_c_s9_d : ARCompactInstSpecial<"bbit0",
    (outs ), (ins GPR32:$rb, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "bbit0\t$rb, $rc, $simm9_a16_8", []> {
  // Opcode: 0x0801000E, Mask: 0xF801001F
  // Operands: RB, RC, SIMM9_A16_8
  // Flags: C_D
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b01110;
}

// bbit0<.d> b,u6,s9 00001bbbsssssss1SBBBuuuuuuN11110.
def ARC_BBIT0_b_u6_s9_d : ARCompactInstSpecial<"bbit0",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "bbit0\t$rb, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x0801001E, Mask: 0xF801001F
  // Operands: RB, UIMM6_8, SIMM9_A16_8
  // Flags: C_D
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b11110;
}

// bbit0 b,limm,s9 00001bbbsssssss1SBBB111110001110.
def ARC_BBIT0_b_limm_s9 : ARCompactInstSpecial<"bbit0",
    (outs ), (ins GPR32:$rb, i32imm:$limm, brtarget_s9:$simm9_a16_8),
    "bbit0\t$rb, $limm, $simm9_a16_8", []> {
  // Opcode: 0x08010F8E, Mask: 0xF8010FFF
  // Operands: RB, LIMM, SIMM9_A16_8
  // Flags: none
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{11-0} = 0b111110001110;
}

// bbit0 limm,c,s9 00001110sssssss1S111CCCCCC001110.
def ARC_BBIT0_limm_c_s9 : ARCompactInstSpecial<"bbit0",
    (outs ), (ins i32imm:$limm, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "bbit0\t$limm, $rc, $simm9_a16_8", []> {
  // Opcode: 0x0E01700E, Mask: 0xFF01703F
  // Operands: LIMM, RC, SIMM9_A16_8
  // Flags: none
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001110;
}

// bbit0 limm,u6,s9 00001110sssssss1S111uuuuuu011110.
def ARC_BBIT0_limm_u6_s9 : ARCompactInstSpecial<"bbit0",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "bbit0\t$limm, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x0E01701E, Mask: 0xFF01703F
  // Operands: LIMM, UIMM6_8, SIMM9_A16_8
  // Flags: none
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b011110;
}

// bbit0 limm,limm,s9 00001110sssssss1S111111110001110.
def ARC_BBIT0_limm_s9 : ARCompactInstSpecial<"bbit0",
    (outs ), (ins i32imm:$limm, brtarget_s9:$simm9_a16_8),
    "bbit0\t$limm, $simm9_a16_8", []> {
  // Opcode: 0x0E017F8E, Mask: 0xFF017FFF
  // Operands: LIMM, LIMMdup, SIMM9_A16_8
  // Flags: none
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-0} = 0b111111110001110;
}

// bbit1<.d> b,c,s9 00001bbbsssssss1SBBBCCCCCCN01111.
def ARC_BBIT1_b_c_s9_d : ARCompactInstSpecial<"bbit1",
    (outs ), (ins GPR32:$rb, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "bbit1\t$rb, $rc, $simm9_a16_8", []> {
  // Opcode: 0x0801000F, Mask: 0xF801001F
  // Operands: RB, RC, SIMM9_A16_8
  // Flags: C_D
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b01111;
}

// bbit1<.d> b,u6,s9 00001bbbsssssss1SBBBuuuuuuN11111.
def ARC_BBIT1_b_u6_s9_d : ARCompactInstSpecial<"bbit1",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "bbit1\t$rb, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x0801001F, Mask: 0xF801001F
  // Operands: RB, UIMM6_8, SIMM9_A16_8
  // Flags: C_D
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b11111;
}

// bbit1 b,limm,s9 00001bbbsssssss1SBBB111110001111.
def ARC_BBIT1_b_limm_s9 : ARCompactInstSpecial<"bbit1",
    (outs ), (ins GPR32:$rb, i32imm:$limm, brtarget_s9:$simm9_a16_8),
    "bbit1\t$rb, $limm, $simm9_a16_8", []> {
  // Opcode: 0x08010F8F, Mask: 0xF8010FFF
  // Operands: RB, LIMM, SIMM9_A16_8
  // Flags: none
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{11-0} = 0b111110001111;
}

// bbit1 limm,c,s9 00001110sssssss1S111CCCCCC001111.
def ARC_BBIT1_limm_c_s9 : ARCompactInstSpecial<"bbit1",
    (outs ), (ins i32imm:$limm, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "bbit1\t$limm, $rc, $simm9_a16_8", []> {
  // Opcode: 0x0E01700F, Mask: 0xFF01703F
  // Operands: LIMM, RC, SIMM9_A16_8
  // Flags: none
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001111;
}

// bbit1 limm,u6,s9 00001110sssssss1S111uuuuuu011111.
def ARC_BBIT1_limm_u6_s9 : ARCompactInstSpecial<"bbit1",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "bbit1\t$limm, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x0E01701F, Mask: 0xFF01703F
  // Operands: LIMM, UIMM6_8, SIMM9_A16_8
  // Flags: none
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b011111;
}

// bbit1 limm,limm,s9 00001110sssssss1S111111110001111.
def ARC_BBIT1_limm_s9 : ARCompactInstSpecial<"bbit1",
    (outs ), (ins i32imm:$limm, brtarget_s9:$simm9_a16_8),
    "bbit1\t$limm, $simm9_a16_8", []> {
  // Opcode: 0x0E017F8F, Mask: 0xFF017FFF
  // Operands: LIMM, LIMMdup, SIMM9_A16_8
  // Flags: none
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-0} = 0b111111110001111;
}

// bl<.d> s25 00001sssssssss10SSSSSSSSSSNRtttt.
def ARC_BL_s25_d : ARCompactInstBranch<0b00001, "bl",
    (outs ), (ins calltarget_s25:$simm25_a32_5),
    "bl\t$simm25_a32_5", []> {
  // Opcode: 0x08020000, Mask: 0xF8030000
  // Operands: SIMM25_A32_5
  // Flags: C_D
  let Inst{31-27} = 0b00001;
  let Inst{17-16} = 0b10;
  let hasDelaySlot = 1;
}

// bl<.cc><.d> s21 00001sssssssss00SSSSSSSSSSNQQQQQ.
def ARC_BL_s21_cc_d : ARCompactInstBranch<0b00001, "bl",
    (outs ), (ins calltarget_s21:$simm21_a32_5),
    "bl\t$simm21_a32_5", []> {
  // Opcode: 0x08000000, Mask: 0xF8030000
  // Operands: SIMM21_A32_5
  // Flags: C_CC, C_D
  let Inst{31-27} = 0b00001;
  let Inst{17-16} = 0b00;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// breq<.d>CC_EQ b,c,s9 00001bbbsssssss1SBBBCCCCCCN00000.
def ARC_BREQ_b_c_s9_eq_d : ARCompactInstBranch<0b00001, "breq",
    (outs ), (ins GPR32:$rb, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "breq\t$rb, $rc, $simm9_a16_8", []> {
  // Opcode: 0x08010000, Mask: 0xF801001F
  // Operands: RB, RC, SIMM9_A16_8
  // Flags: C_D, C_CC_EQ
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b00000;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// breq<.d>CC_EQ b,u6,s9 00001bbbsssssss1SBBBuuuuuuN10000.
def ARC_BREQ_b_u6_s9_eq_d : ARCompactInstBranch<0b00001, "breq",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "breq\t$rb, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x08010010, Mask: 0xF801001F
  // Operands: RB, UIMM6_8, SIMM9_A16_8
  // Flags: C_D, C_CC_EQ
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b10000;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// breqCC_EQ b,limm,s9 00001bbbsssssss1SBBB111110000000.
def ARC_BREQ_b_limm_s9_eq : ARCompactInstBranch<0b00001, "breq",
    (outs ), (ins GPR32:$rb, i32imm:$limm, brtarget_s9:$simm9_a16_8),
    "breq\t$rb, $limm, $simm9_a16_8", []> {
  // Opcode: 0x08010F80, Mask: 0xF8010FFF
  // Operands: RB, LIMM, SIMM9_A16_8
  // Flags: C_CC_EQ
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{11-0} = 0b111110000000;
  let isPredicable = 1;
}

// breqCC_EQ limm,c,s9 00001110sssssss1S111CCCCCC000000.
def ARC_BREQ_limm_c_s9_eq : ARCompactInstBranch<0b00001, "breq",
    (outs ), (ins i32imm:$limm, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "breq\t$limm, $rc, $simm9_a16_8", []> {
  // Opcode: 0x0E017000, Mask: 0xFF01703F
  // Operands: LIMM, RC, SIMM9_A16_8
  // Flags: C_CC_EQ
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000000;
  let isPredicable = 1;
}

// breqCC_EQ limm,u6,s9 00001110sssssss1S111uuuuuu010000.
def ARC_BREQ_limm_u6_s9_eq : ARCompactInstBranch<0b00001, "breq",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "breq\t$limm, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x0E017010, Mask: 0xFF01703F
  // Operands: LIMM, UIMM6_8, SIMM9_A16_8
  // Flags: C_CC_EQ
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b010000;
  let isPredicable = 1;
}

// brge<.d>CC_GE b,c,s9 00001bbbsssssss1SBBBCCCCCCN00011.
def ARC_BRGE_b_c_s9_ge_d : ARCompactInstBranch<0b00001, "brge",
    (outs ), (ins GPR32:$rb, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "brge\t$rb, $rc, $simm9_a16_8", []> {
  // Opcode: 0x08010003, Mask: 0xF801001F
  // Operands: RB, RC, SIMM9_A16_8
  // Flags: C_D, C_CC_GE
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b00011;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// brge<.d>CC_GE b,u6,s9 00001bbbsssssss1SBBBuuuuuuN10011.
def ARC_BRGE_b_u6_s9_ge_d : ARCompactInstBranch<0b00001, "brge",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "brge\t$rb, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x08010013, Mask: 0xF801001F
  // Operands: RB, UIMM6_8, SIMM9_A16_8
  // Flags: C_D, C_CC_GE
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b10011;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// brgeCC_GE b,limm,s9 00001bbbsssssss1SBBB111110000011.
def ARC_BRGE_b_limm_s9_ge : ARCompactInstBranch<0b00001, "brge",
    (outs ), (ins GPR32:$rb, i32imm:$limm, brtarget_s9:$simm9_a16_8),
    "brge\t$rb, $limm, $simm9_a16_8", []> {
  // Opcode: 0x08010F83, Mask: 0xF8010FFF
  // Operands: RB, LIMM, SIMM9_A16_8
  // Flags: C_CC_GE
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{11-0} = 0b111110000011;
  let isPredicable = 1;
}

// brgeCC_GE limm,c,s9 00001110sssssss1S111CCCCCC000011.
def ARC_BRGE_limm_c_s9_ge : ARCompactInstBranch<0b00001, "brge",
    (outs ), (ins i32imm:$limm, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "brge\t$limm, $rc, $simm9_a16_8", []> {
  // Opcode: 0x0E017003, Mask: 0xFF01703F
  // Operands: LIMM, RC, SIMM9_A16_8
  // Flags: C_CC_GE
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000011;
  let isPredicable = 1;
}

// brgeCC_GE limm,u6,s9 00001110sssssss1S111uuuuuu010011.
def ARC_BRGE_limm_u6_s9_ge : ARCompactInstBranch<0b00001, "brge",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "brge\t$limm, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x0E017013, Mask: 0xFF01703F
  // Operands: LIMM, UIMM6_8, SIMM9_A16_8
  // Flags: C_CC_GE
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b010011;
  let isPredicable = 1;
}

// brhs<.d>CC_HS b,c,s9 00001bbbsssssss1SBBBCCCCCCN00101.
def ARC_BRHS_b_c_s9_hs_d : ARCompactInstBranch<0b00001, "brhs",
    (outs ), (ins GPR32:$rb, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "brhs\t$rb, $rc, $simm9_a16_8", []> {
  // Opcode: 0x08010005, Mask: 0xF801001F
  // Operands: RB, RC, SIMM9_A16_8
  // Flags: C_D, C_CC_HS
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b00101;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// brhs<.d>CC_HS b,u6,s9 00001bbbsssssss1SBBBuuuuuuN10101.
def ARC_BRHS_b_u6_s9_hs_d : ARCompactInstBranch<0b00001, "brhs",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "brhs\t$rb, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x08010015, Mask: 0xF801001F
  // Operands: RB, UIMM6_8, SIMM9_A16_8
  // Flags: C_D, C_CC_HS
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b10101;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// brhsCC_HS b,limm,s9 00001bbbsssssss1SBBB111110000101.
def ARC_BRHS_b_limm_s9_hs : ARCompactInstBranch<0b00001, "brhs",
    (outs ), (ins GPR32:$rb, i32imm:$limm, brtarget_s9:$simm9_a16_8),
    "brhs\t$rb, $limm, $simm9_a16_8", []> {
  // Opcode: 0x08010F85, Mask: 0xF8010FFF
  // Operands: RB, LIMM, SIMM9_A16_8
  // Flags: C_CC_HS
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{11-0} = 0b111110000101;
  let isPredicable = 1;
}

// brhsCC_HS limm,c,s9 00001110sssssss1S111CCCCCC000101.
def ARC_BRHS_limm_c_s9_hs : ARCompactInstBranch<0b00001, "brhs",
    (outs ), (ins i32imm:$limm, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "brhs\t$limm, $rc, $simm9_a16_8", []> {
  // Opcode: 0x0E017005, Mask: 0xFF01703F
  // Operands: LIMM, RC, SIMM9_A16_8
  // Flags: C_CC_HS
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000101;
  let isPredicable = 1;
}

// brhsCC_HS limm,u6,s9 00001110sssssss1S111uuuuuu010101.
def ARC_BRHS_limm_u6_s9_hs : ARCompactInstBranch<0b00001, "brhs",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "brhs\t$limm, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x0E017015, Mask: 0xFF01703F
  // Operands: LIMM, UIMM6_8, SIMM9_A16_8
  // Flags: C_CC_HS
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b010101;
  let isPredicable = 1;
}

// brlo<.d>CC_LO b,c,s9 00001bbbsssssss1SBBBCCCCCCN00100.
def ARC_BRLO_b_c_s9_lo_d : ARCompactInstBranch<0b00001, "brlo",
    (outs ), (ins GPR32:$rb, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "brlo\t$rb, $rc, $simm9_a16_8", []> {
  // Opcode: 0x08010004, Mask: 0xF801001F
  // Operands: RB, RC, SIMM9_A16_8
  // Flags: C_D, C_CC_LO
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b00100;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// brlo<.d>CC_LO b,u6,s9 00001bbbsssssss1SBBBuuuuuuN10100.
def ARC_BRLO_b_u6_s9_lo_d : ARCompactInstBranch<0b00001, "brlo",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "brlo\t$rb, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x08010014, Mask: 0xF801001F
  // Operands: RB, UIMM6_8, SIMM9_A16_8
  // Flags: C_D, C_CC_LO
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b10100;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// brloCC_LO b,limm,s9 00001bbbsssssss1SBBB111110000100.
def ARC_BRLO_b_limm_s9_lo : ARCompactInstBranch<0b00001, "brlo",
    (outs ), (ins GPR32:$rb, i32imm:$limm, brtarget_s9:$simm9_a16_8),
    "brlo\t$rb, $limm, $simm9_a16_8", []> {
  // Opcode: 0x08010F84, Mask: 0xF8010FFF
  // Operands: RB, LIMM, SIMM9_A16_8
  // Flags: C_CC_LO
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{11-0} = 0b111110000100;
  let isPredicable = 1;
}

// brloCC_LO limm,c,s9 00001110sssssss1S111CCCCCC000100.
def ARC_BRLO_limm_c_s9_lo : ARCompactInstBranch<0b00001, "brlo",
    (outs ), (ins i32imm:$limm, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "brlo\t$limm, $rc, $simm9_a16_8", []> {
  // Opcode: 0x0E017004, Mask: 0xFF01703F
  // Operands: LIMM, RC, SIMM9_A16_8
  // Flags: C_CC_LO
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000100;
  let isPredicable = 1;
}

// brloCC_LO limm,u6,s9 00001110sssssss1S111uuuuuu010100.
def ARC_BRLO_limm_u6_s9_lo : ARCompactInstBranch<0b00001, "brlo",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "brlo\t$limm, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x0E017014, Mask: 0xFF01703F
  // Operands: LIMM, UIMM6_8, SIMM9_A16_8
  // Flags: C_CC_LO
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b010100;
  let isPredicable = 1;
}

// brlt<.d>CC_LT b,c,s9 00001bbbsssssss1SBBBCCCCCCN00010.
def ARC_BRLT_b_c_s9_lt_d : ARCompactInstBranch<0b00001, "brlt",
    (outs ), (ins GPR32:$rb, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "brlt\t$rb, $rc, $simm9_a16_8", []> {
  // Opcode: 0x08010002, Mask: 0xF801001F
  // Operands: RB, RC, SIMM9_A16_8
  // Flags: C_D, C_CC_LT
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b00010;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// brlt<.d>CC_LT b,u6,s9 00001bbbsssssss1SBBBuuuuuuN10010.
def ARC_BRLT_b_u6_s9_lt_d : ARCompactInstBranch<0b00001, "brlt",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "brlt\t$rb, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x08010012, Mask: 0xF801001F
  // Operands: RB, UIMM6_8, SIMM9_A16_8
  // Flags: C_D, C_CC_LT
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b10010;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// brltCC_LT b,limm,s9 00001bbbsssssss1SBBB111110000010.
def ARC_BRLT_b_limm_s9_lt : ARCompactInstBranch<0b00001, "brlt",
    (outs ), (ins GPR32:$rb, i32imm:$limm, brtarget_s9:$simm9_a16_8),
    "brlt\t$rb, $limm, $simm9_a16_8", []> {
  // Opcode: 0x08010F82, Mask: 0xF8010FFF
  // Operands: RB, LIMM, SIMM9_A16_8
  // Flags: C_CC_LT
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{11-0} = 0b111110000010;
  let isPredicable = 1;
}

// brltCC_LT limm,c,s9 00001110sssssss1S111CCCCCC000010.
def ARC_BRLT_limm_c_s9_lt : ARCompactInstBranch<0b00001, "brlt",
    (outs ), (ins i32imm:$limm, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "brlt\t$limm, $rc, $simm9_a16_8", []> {
  // Opcode: 0x0E017002, Mask: 0xFF01703F
  // Operands: LIMM, RC, SIMM9_A16_8
  // Flags: C_CC_LT
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000010;
  let isPredicable = 1;
}

// brltCC_LT limm,u6,s9 00001110sssssss1S111uuuuuu010010.
def ARC_BRLT_limm_u6_s9_lt : ARCompactInstBranch<0b00001, "brlt",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "brlt\t$limm, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x0E017012, Mask: 0xFF01703F
  // Operands: LIMM, UIMM6_8, SIMM9_A16_8
  // Flags: C_CC_LT
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b010010;
  let isPredicable = 1;
}

// brne<.d>CC_NE b,c,s9 00001bbbsssssss1SBBBCCCCCCN00001.
def ARC_BRNE_b_c_s9_ne_d : ARCompactInstBranch<0b00001, "brne",
    (outs ), (ins GPR32:$rb, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "brne\t$rb, $rc, $simm9_a16_8", []> {
  // Opcode: 0x08010001, Mask: 0xF801001F
  // Operands: RB, RC, SIMM9_A16_8
  // Flags: C_D, C_CC_NE
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b00001;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// brne<.d>CC_NE b,u6,s9 00001bbbsssssss1SBBBUUUUUUN10001.
def ARC_BRNE_b_u6_s9_ne_d : ARCompactInstBranch<0b00001, "brne",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "brne\t$rb, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x08010011, Mask: 0xF801001F
  // Operands: RB, UIMM6_8, SIMM9_A16_8
  // Flags: C_D, C_CC_NE
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{4-0} = 0b10001;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// brneCC_NE b,limm,s9 00001bbbsssssss1SBBB111110000001.
def ARC_BRNE_b_limm_s9_ne : ARCompactInstBranch<0b00001, "brne",
    (outs ), (ins GPR32:$rb, i32imm:$limm, brtarget_s9:$simm9_a16_8),
    "brne\t$rb, $limm, $simm9_a16_8", []> {
  // Opcode: 0x08010F81, Mask: 0xF8010FFF
  // Operands: RB, LIMM, SIMM9_A16_8
  // Flags: C_CC_NE
  let Inst{31-27} = 0b00001;
  let Inst{16} = 1;
  let Inst{11-0} = 0b111110000001;
  let isPredicable = 1;
}

// brneCC_NE limm,c,s9 00001110sssssss1S111CCCCCC000001.
def ARC_BRNE_limm_c_s9_ne : ARCompactInstBranch<0b00001, "brne",
    (outs ), (ins i32imm:$limm, GPR32:$rc, brtarget_s9:$simm9_a16_8),
    "brne\t$limm, $rc, $simm9_a16_8", []> {
  // Opcode: 0x0E017001, Mask: 0xFF01703F
  // Operands: LIMM, RC, SIMM9_A16_8
  // Flags: C_CC_NE
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000001;
  let isPredicable = 1;
}

// brneCC_NE limm,u6,s9 00001110sssssss1S111uuuuuu010001.
def ARC_BRNE_limm_u6_s9_ne : ARCompactInstBranch<0b00001, "brne",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_8, brtarget_s9:$simm9_a16_8),
    "brne\t$limm, $uimm6_8, $simm9_a16_8", []> {
  // Opcode: 0x0E017011, Mask: 0xFF01703F
  // Operands: LIMM, UIMM6_8, SIMM9_A16_8
  // Flags: C_CC_NE
  let Inst{31-24} = 0b00001110;
  let Inst{16} = 1;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b010001;
  let isPredicable = 1;
}

// j c 00100RRR001000000RRRCCCCCCRRRRRR.
def ARC_J_c : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$rc),
    "j\t[$rc]", []> {
  // Opcode: 0x20200000, Mask: 0xF8FF8000
  // Operands: BRAKET, RC, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001000000;
}

// j BLINK 00100RRR001000000RRR011111RRRRRR.
def ARC_J_blink : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$blink),
    "j\t[$blink]", []> {
  // Opcode: 0x202007C0, Mask: 0xF8FF8FC0
  // Operands: BRAKET, BLINK, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001000000;
  let Inst{11-6} = 0b011111;
}

// j.F ILINK1 00100RRR001000001RRR011101RRRRRR.
def ARC_J_ilink1 : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$ilink1),
    "j\t[$ilink1]", []> {
  // Opcode: 0x20208740, Mask: 0xF8FF8FC0
  // Operands: BRAKET, ILINK1, BRAKETdup
  // Flags: C_FHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001000001;
  let Inst{11-6} = 0b011101;
  let Defs = [STATUS32];
}

// j.F ILINK2 00100RRR001000001RRR011110RRRRRR.
def ARC_J_ilink2 : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$ilink2),
    "j\t[$ilink2]", []> {
  // Opcode: 0x20208780, Mask: 0xF8FF8FC0
  // Operands: BRAKET, ILINK2, BRAKETdup
  // Flags: C_FHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001000001;
  let Inst{11-6} = 0b011110;
  let Defs = [STATUS32];
}

// jcc c 00100RRR111000000RRRCCCCCC0QQQQQ.
def ARC_J_c_cc : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$rc),
    "j\t[$rc]", []> {
  // Opcode: 0x20E00000, Mask: 0xF8FF8020
  // Operands: BRAKET, RC, BRAKETdup
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000000;
  let Inst{5} = 0;
  let isPredicable = 1;
}

// jcc BLINK 00100RRR111000000RRR0111110QQQQQ.
def ARC_J_blink_cc : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$blink),
    "j\t[$blink]", []> {
  // Opcode: 0x20E007C0, Mask: 0xF8FF8FE0
  // Operands: BRAKET, BLINK, BRAKETdup
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000000;
  let Inst{11-5} = 0b0111110;
  let isPredicable = 1;
}

// j.Fcc ILINK1 00100RRR111000001RRR0111010QQQQQ.
def ARC_J_ilink1_cc : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$ilink1),
    "j\t[$ilink1]", []> {
  // Opcode: 0x20E08740, Mask: 0xF8FF8FE0
  // Operands: BRAKET, ILINK1, BRAKETdup
  // Flags: C_FHARD, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000001;
  let Inst{11-5} = 0b0111010;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// j.Fcc ILINK2 00100RRR111000001RRR0111100QQQQQ.
def ARC_J_ilink2_cc : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$ilink2),
    "j\t[$ilink2]", []> {
  // Opcode: 0x20E08780, Mask: 0xF8FF8FE0
  // Operands: BRAKET, ILINK2, BRAKETdup
  // Flags: C_FHARD, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000001;
  let Inst{11-5} = 0b0111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// j.D c 00100RRR001000010RRRCCCCCCRRRRRR.
def ARC_J_c_d : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$rc),
    "j\t[$rc]", []> {
  // Opcode: 0x20210000, Mask: 0xF8FF8000
  // Operands: BRAKET, RC, BRAKETdup
  // Flags: C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001000010;
  let hasDelaySlot = 1;
}

// j.D BLINK 00100RRR001000010RRR011111RRRRRR.
def ARC_J_blink_d : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$blink),
    "j\t[$blink]", []> {
  // Opcode: 0x202107C0, Mask: 0xF8FF8FC0
  // Operands: BRAKET, BLINK, BRAKETdup
  // Flags: C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001000010;
  let Inst{11-6} = 0b011111;
  let hasDelaySlot = 1;
}

// j.Dcc c 00100RRR111000010RRRCCCCCC0QQQQQ.
def ARC_J_c_cc_d : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$rc),
    "j\t[$rc]", []> {
  // Opcode: 0x20E10000, Mask: 0xF8FF8020
  // Operands: BRAKET, RC, BRAKETdup
  // Flags: C_CC, C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000010;
  let Inst{5} = 0;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// j.Dcc BLINK 00100RRR111000010RRR0111110QQQQQ.
def ARC_J_blink_cc_d : ARCompactInstJump<0b00100, "j",
    (outs ), (ins GPR32:$blink),
    "j\t[$blink]", []> {
  // Opcode: 0x20E107C0, Mask: 0xF8FF8FE0
  // Operands: BRAKET, BLINK, BRAKETdup
  // Flags: C_CC, C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000010;
  let Inst{11-5} = 0b0111110;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// j s12 00100RRR101000000RRRssssssSSSSSS.
def ARC_J_s12 : ARCompactInstJump<0b00100, "j",
    (outs ), (ins s12imm:$simm12_20),
    "j\t$simm12_20", []> {
  // Opcode: 0x20A00000, Mask: 0xF8FF8000
  // Operands: SIMM12_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b101000000;
}

// j.D s12 00100RRR101000010RRRssssssSSSSSS.
def ARC_J_s12_d : ARCompactInstJump<0b00100, "j",
    (outs ), (ins s12imm:$simm12_20),
    "j\t$simm12_20", []> {
  // Opcode: 0x20A10000, Mask: 0xF8FF8000
  // Operands: SIMM12_20
  // Flags: C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b101000010;
  let hasDelaySlot = 1;
}

// j u6 00100RRR011000000RRRuuuuuuRRRRRR.
def ARC_J_u6 : ARCompactInstJump<0b00100, "j",
    (outs ), (ins u6imm:$uimm6_20),
    "j\t$uimm6_20", []> {
  // Opcode: 0x20600000, Mask: 0xF8FF8000
  // Operands: UIMM6_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b011000000;
}

// jcc u6 00100RRR111000000RRRuuuuuu1QQQQQ.
def ARC_J_u6_cc : ARCompactInstJump<0b00100, "j",
    (outs ), (ins u6imm:$uimm6_20),
    "j\t$uimm6_20", []> {
  // Opcode: 0x20E00020, Mask: 0xF8FF8020
  // Operands: UIMM6_20
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000000;
  let Inst{5} = 1;
  let isPredicable = 1;
}

// j.D u6 00100RRR011000010RRRuuuuuuRRRRRR.
def ARC_J_u6_d : ARCompactInstJump<0b00100, "j",
    (outs ), (ins u6imm:$uimm6_20),
    "j\t$uimm6_20", []> {
  // Opcode: 0x20610000, Mask: 0xF8FF8000
  // Operands: UIMM6_20
  // Flags: C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b011000010;
  let hasDelaySlot = 1;
}

// j.Dcc u6 00100RRR111000010RRRuuuuuu1QQQQQ.
def ARC_J_u6_cc_d : ARCompactInstJump<0b00100, "j",
    (outs ), (ins u6imm:$uimm6_20),
    "j\t$uimm6_20", []> {
  // Opcode: 0x20E10020, Mask: 0xF8FF8020
  // Operands: UIMM6_20
  // Flags: C_CC, C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000010;
  let Inst{5} = 1;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// j limm 00100RRR001000000RRR111110RRRRRR.
def ARC_J_limm : ARCompactInstJump<0b00100, "j",
    (outs ), (ins i32imm:$limm),
    "j\t$limm", []> {
  // Opcode: 0x20200F80, Mask: 0xF8FF8FC0
  // Operands: LIMM
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001000000;
  let Inst{11-6} = 0b111110;
}

// jcc limm 00100RRR111000000RRR1111100QQQQQ.
def ARC_J_limm_cc : ARCompactInstJump<0b00100, "j",
    (outs ), (ins i32imm:$limm),
    "j\t$limm", []> {
  // Opcode: 0x20E00F80, Mask: 0xF8FF8FE0
  // Operands: LIMM
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
}

// jl c 00100RRR001000100RRRCCCCCCRRRRRR.
def ARC_JL_c : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins GPR32:$rc),
    "jl\t[$rc]", []> {
  // Opcode: 0x20220000, Mask: 0xF8FF8000
  // Operands: BRAKET, RC, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001000100;
}

// jlcc c 00100RRR111000100RRRCCCCCC0QQQQQ.
def ARC_JL_c_cc : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins GPR32:$rc),
    "jl\t[$rc]", []> {
  // Opcode: 0x20E20000, Mask: 0xF8FF8020
  // Operands: BRAKET, RC, BRAKETdup
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000100;
  let Inst{5} = 0;
  let isPredicable = 1;
}

// jl.D c 00100RRR001000110RRRCCCCCCRRRRRR.
def ARC_JL_c_d : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins GPR32:$rc),
    "jl\t[$rc]", []> {
  // Opcode: 0x20230000, Mask: 0xF8FF8000
  // Operands: BRAKET, RC, BRAKETdup
  // Flags: C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001000110;
  let hasDelaySlot = 1;
}

// jl.Dcc c 00100RRR111000110RRRCCCCCC0QQQQQ.
def ARC_JL_c_cc_d : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins GPR32:$rc),
    "jl\t[$rc]", []> {
  // Opcode: 0x20E30000, Mask: 0xF8FF8020
  // Operands: BRAKET, RC, BRAKETdup
  // Flags: C_CC, C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000110;
  let Inst{5} = 0;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// jl s12 00100RRR101000100RRRssssssSSSSSS.
def ARC_JL_s12 : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins s12imm:$simm12_20),
    "jl\t$simm12_20", []> {
  // Opcode: 0x20A20000, Mask: 0xF8FF8000
  // Operands: SIMM12_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b101000100;
}

// jl.D s12 00100RRR101000110RRRssssssSSSSSS.
def ARC_JL_s12_d : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins s12imm:$simm12_20),
    "jl\t$simm12_20", []> {
  // Opcode: 0x20A30000, Mask: 0xF8FF8000
  // Operands: SIMM12_20
  // Flags: C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b101000110;
  let hasDelaySlot = 1;
}

// jl u6 00100RRR011000100RRRuuuuuuRRRRRR.
def ARC_JL_u6 : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins u6imm:$uimm6_20),
    "jl\t$uimm6_20", []> {
  // Opcode: 0x20620000, Mask: 0xF8FF8000
  // Operands: UIMM6_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b011000100;
}

// jlcc u6 00100RRR111000100RRRuuuuuu1QQQQQ.
def ARC_JL_u6_cc : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins u6imm:$uimm6_20),
    "jl\t$uimm6_20", []> {
  // Opcode: 0x20E20020, Mask: 0xF8FF8020
  // Operands: UIMM6_20
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000100;
  let Inst{5} = 1;
  let isPredicable = 1;
}

// jl.D u6 00100RRR011000110RRRuuuuuuRRRRRR.
def ARC_JL_u6_d : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins u6imm:$uimm6_20),
    "jl\t$uimm6_20", []> {
  // Opcode: 0x20630000, Mask: 0xF8FF8000
  // Operands: UIMM6_20
  // Flags: C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b011000110;
  let hasDelaySlot = 1;
}

// jl.Dcc u6 00100RRR111000110RRRuuuuuu1QQQQQ.
def ARC_JL_u6_cc_d : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins u6imm:$uimm6_20),
    "jl\t$uimm6_20", []> {
  // Opcode: 0x20E30020, Mask: 0xF8FF8020
  // Operands: UIMM6_20
  // Flags: C_CC, C_DHARD
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000110;
  let Inst{5} = 1;
  let hasDelaySlot = 1;
  let isPredicable = 1;
}

// jl limm 00100RRR001000100RRR111110RRRRRR.
def ARC_JL_limm : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins i32imm:$limm),
    "jl\t$limm", []> {
  // Opcode: 0x20220F80, Mask: 0xF8FF8FC0
  // Operands: LIMM
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001000100;
  let Inst{11-6} = 0b111110;
}

// jlcc limm 00100RRR111000100RRR1111100QQQQQ.
def ARC_JL_limm_cc : ARCompactInstJump<0b00100, "jl",
    (outs ), (ins i32imm:$limm),
    "jl\t$limm", []> {
  // Opcode: 0x20E20F80, Mask: 0xF8FF8FE0
  // Operands: LIMM
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111000100;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
}

} // end let Predicates = [IsARCompact]
