//===-- ARCARCompactInstrSpecial.td - ARC ARCompact Special Instructions -*- tablegen -*-===//
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

// 59 instruction variants

let Predicates = [IsARCompact] in {

// brk  00100101011011110000000000111111.
def ARC_BRK_0 : ARCompactInst32_2op<0b00100, 0b111111, "brk",
    (outs ), (ins),
    "brk", []> {
  // Opcode: 0x256F003F, Mask: 0xFFFFFFFF
  // Operands: 0
  // Flags: none
  let Inst{31-0} = 0b00100101011011110000000000111111;
}

// ex<.di> b,c 00100bbb00101111DBBBCCCCCC001100.
def ARC_EX_b_c : ARCompactInst32_2op<0b00100, 0b001100, "ex",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "ex\t$rb, [$rc]", []> {
  // Opcode: 0x202F000C, Mask: 0xF8FF003F
  // Operands: RB, BRAKET, RC, BRAKETdup
  // Flags: C_DI16
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b001100;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// ex<.di> b,u6 00100bbb01101111DBBBuuuuuu001100.
def ARC_EX_b_u6 : ARCompactInst32_2op<0b00100, 0b001100, "ex",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "ex\t$rb, [$uimm6_20]", []> {
  // Opcode: 0x206F000C, Mask: 0xF8FF003F
  // Operands: RB, BRAKET, UIMM6_20, BRAKETdup
  // Flags: C_DI16
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b001100;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// ex<.di> b,limm 00100bbb00101111DBBB111110001100.
def ARC_EX_b_limm : ARCompactInst32_2op<0b00100, 0b001100, "ex",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "ex\t$rb, [$limm]", []> {
  // Opcode: 0x202F0F8C, Mask: 0xF8FF0FFF
  // Operands: RB, BRAKET, LIMM, BRAKETdup
  // Flags: C_DI16
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110001100;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ex<.di> limm,c 0010011000101111D111CCCCCC001100.
def ARC_EX_limm_c : ARCompactInst32_2op<0b00100, 0b001100, "ex",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "ex\t$limm, [$rc]", []> {
  // Opcode: 0x262F700C, Mask: 0xFFFF703F
  // Operands: LIMM, BRAKET, RC, BRAKETdup
  // Flags: C_DI16
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001100;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ex<.di> limm,u6 0010011001101111D111uuuuuu001100.
def ARC_EX_limm_u6 : ARCompactInst32_2op<0b00100, 0b001100, "ex",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "ex\t$limm, [$uimm6_20]", []> {
  // Opcode: 0x266F700C, Mask: 0xFFFF703F
  // Operands: LIMM, BRAKET, UIMM6_20, BRAKETdup
  // Flags: C_DI16
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001100;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ex<.di> limm,limm 0010011000101111D111111110001100.
def ARC_EX_limm : ARCompactInst32_2op<0b00100, 0b001100, "ex",
    (outs ), (ins i32imm:$limm),
    "ex\t$limm", []> {
  // Opcode: 0x262F7F8C, Mask: 0xFFFF7FFF
  // Operands: LIMM, BRAKET, LIMMdup, BRAKETdup
  // Flags: C_DI16
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110001100;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// flag c 00100RRR001010010RRRCCCCCCRRRRRR.
def ARC_FLAG_c : ARCompactInst32_3op<0b00100, 0b101001, "flag",
    (outs ), (ins GPR32:$rc),
    "flag\t$rc", []> {
  // Opcode: 0x20290000, Mask: 0xF8FF8000
  // Operands: RC
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001010010;
  bits<6> rc;
  let Inst{11-6} = rc;
}

// flag<.cc> c 00100RRR111010010RRRCCCCCC0QQQQQ.
def ARC_FLAG_c_cc : ARCompactInst32_3op<0b00100, 0b101001, "flag",
    (outs ), (ins GPR32:$rc),
    "flag\t$rc", []> {
  // Opcode: 0x20E90000, Mask: 0xF8FF8020
  // Operands: RC
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111010010;
  let Inst{5} = 0;
  let isPredicable = 1;
  bits<6> rc;
  let Inst{11-6} = rc;
}

// flag u6 00100RRR011010010RRRuuuuuuRRRRRR.
def ARC_FLAG_u6 : ARCompactInst32_3op<0b00100, 0b101001, "flag",
    (outs ), (ins u6imm:$uimm6_20),
    "flag\t$uimm6_20", []> {
  // Opcode: 0x20690000, Mask: 0xF8FF8000
  // Operands: UIMM6_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b011010010;
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// flag<.cc> u6 00100RRR111010010RRRuuuuuu1QQQQQ.
def ARC_FLAG_u6_cc : ARCompactInst32_3op<0b00100, 0b101001, "flag",
    (outs ), (ins u6imm:$uimm6_20),
    "flag\t$uimm6_20", []> {
  // Opcode: 0x20E90020, Mask: 0xF8FF8020
  // Operands: UIMM6_20
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111010010;
  let Inst{5} = 1;
  let isPredicable = 1;
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// flag s12 00100RRR101010010RRRssssssSSSSSS.
def ARC_FLAG_s12 : ARCompactInst32_3op<0b00100, 0b101001, "flag",
    (outs ), (ins s12imm:$simm12_20),
    "flag\t$simm12_20", []> {
  // Opcode: 0x20A90000, Mask: 0xF8FF8000
  // Operands: SIMM12_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b101010010;
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// flag limm 00100RRR001010010RRR111110RRRRRR.
def ARC_FLAG_limm : ARCompactInst32_3op<0b00100, 0b101001, "flag",
    (outs ), (ins i32imm:$limm),
    "flag\t$limm", []> {
  // Opcode: 0x20290F80, Mask: 0xF8FF8FC0
  // Operands: LIMM
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001010010;
  let Inst{11-6} = 0b111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// flag<.cc> limm 00100RRR111010010RRR1111100QQQQQ.
def ARC_FLAG_limm_cc : ARCompactInst32_3op<0b00100, 0b101001, "flag",
    (outs ), (ins i32imm:$limm),
    "flag\t$limm", []> {
  // Opcode: 0x20E90F80, Mask: 0xF8FF8FE0
  // Operands: LIMM
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111010010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// prefetch<.aa> b,c 00100bbbaa1100000BBBCCCCCC111110.
def ARC_PREFETCH_b_c : ARCompactInst32_3op<0b00100, 0b110000, "prefetch",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "prefetch\t[$rb, $rc]", []> {
  // Opcode: 0x2030003E, Mask: 0xF83F803F
  // Operands: BRAKET, RB, RC, BRAKETdup
  // Flags: C_AA8
  let Inst{31-27} = 0b00100;
  let Inst{21-15} = 0b1100000;
  let Inst{5-0} = 0b111110;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// prefetch b 00010bbb000000000BBB0RR000111110.
def ARC_PREFETCH_b : ARCompactInst32_3op<0b00010, 0b000000, "prefetch",
    (outs GPR32:$rb), (ins ),
    "prefetch\t[$rb]", []> {
  // Opcode: 0x1000003E, Mask: 0xF8FF89FF
  // Operands: BRAKET, RB, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00010;
  let Inst{23-15} = 0b000000000;
  let Inst{11} = 0;
  let Inst{8-0} = 0b000111110;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
}

// prefetch<.aa> b,s9 00010bbbssssssssSBBB0aa000111110.
def ARC_PREFETCH_b_s9 : ARCompactInstSpecial<"prefetch",
    (outs GPR32:$rb), (ins s9imm:$simm9_8),
    "prefetch\t[$rb, $simm9_8]", []> {
  // Opcode: 0x1000003E, Mask: 0xF80009FF
  // Operands: BRAKET, RB, SIMM9_8, BRAKETdup
  // Flags: C_AA21
  let Inst{31-27} = 0b00010;
  let Inst{11} = 0;
  let Inst{8-0} = 0b000111110;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<9> simm9_8;
  let Inst{23-16} = simm9_8{8-1};
  let Inst{15} = simm9_8{0};
}

// prefetch<.aa> b,limm 00100bbbaa1100000BBB111110111110.
def ARC_PREFETCH_b_limm : ARCompactInst32_3op<0b00100, 0b110000, "prefetch",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "prefetch\t[$rb, $limm]", []> {
  // Opcode: 0x20300FBE, Mask: 0xF83F8FFF
  // Operands: BRAKET, RB, LIMM, BRAKETdup
  // Flags: C_AA8
  let Inst{31-27} = 0b00100;
  let Inst{21-15} = 0b1100000;
  let Inst{11-0} = 0b111110111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// prefetch<.aa> limm,c 00100110aa1100000111CCCCCC111110.
def ARC_PREFETCH_limm_c : ARCompactInst32_3op<0b00100, 0b110000, "prefetch",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "prefetch\t[$limm, $rc]", []> {
  // Opcode: 0x2630703E, Mask: 0xFF3FF03F
  // Operands: BRAKET, LIMM, RC, BRAKETdup
  // Flags: C_AA8
  let Inst{31-24} = 0b00100110;
  let Inst{21-12} = 0b1100000111;
  let Inst{5-0} = 0b111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// prefetch limm,c 00100110RR1100000111CCCCCC111110.
def ARC_PREFETCH_limm_c_v1 : ARCompactInst32_3op<0b00100, 0b110000, "prefetch",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "prefetch\t[$limm, $rc]", []> {
  // Opcode: 0x2630703E, Mask: 0xFF3FF03F
  // Operands: BRAKET, LIMM, RC, BRAKETdup
  // Flags: none
  let Inst{31-24} = 0b00100110;
  let Inst{21-12} = 0b1100000111;
  let Inst{5-0} = 0b111110;
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// prefetch limm 000101100000000001110RR000111110.
def ARC_PREFETCH_limm : ARCompactInst32_3op<0b00010, 0b000000, "prefetch",
    (outs ), (ins i32imm:$limm),
    "prefetch\t[$limm]", []> {
  // Opcode: 0x1600703E, Mask: 0xFFFFF9FF
  // Operands: BRAKET, LIMM, BRAKETdup
  // Flags: none
  let Inst{31-11} = 0b000101100000000001110;
  let Inst{8-0} = 0b000111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// prefetch<.aa> limm,s9 00010110ssssssssS1110aa000111110.
def ARC_PREFETCH_limm_s9 : ARCompactInstSpecial<"prefetch",
    (outs ), (ins i32imm:$limm, s9imm:$simm9_8),
    "prefetch\t[$limm, $simm9_8]", []> {
  // Opcode: 0x1600703E, Mask: 0xFF0079FF
  // Operands: BRAKET, LIMM, SIMM9_8, BRAKETdup
  // Flags: C_AA21
  let Inst{31-24} = 0b00010110;
  let Inst{14-11} = 0b1110;
  let Inst{8-0} = 0b000111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// prefetch limm,s9 00010110ssssssssS1110RR000111110.
def ARC_PREFETCH_limm_s9_v1 : ARCompactInstSpecial<"prefetch",
    (outs ), (ins i32imm:$limm, s9imm:$simm9_8),
    "prefetch\t[$limm, $simm9_8]", []> {
  // Opcode: 0x1600703E, Mask: 0xFF0079FF
  // Operands: BRAKET, LIMM, SIMM9_8, BRAKETdup
  // Flags: none
  let Inst{31-24} = 0b00010110;
  let Inst{14-11} = 0b1110;
  let Inst{8-0} = 0b000111110;
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// prefetch<.aa> limm,limm 00100110aa1100000111111110111110.
def ARC_PREFETCH_limm_v1 : ARCompactInst32_3op<0b00100, 0b110000, "prefetch",
    (outs ), (ins i32imm:$limm),
    "prefetch\t[$limm]", []> {
  // Opcode: 0x26307FBE, Mask: 0xFF3FFFFF
  // Operands: BRAKET, LIMM, LIMMdup, BRAKETdup
  // Flags: C_AA8
  let Inst{31-24} = 0b00100110;
  let Inst{21-0} = 0b1100000111111110111110;
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// lp s13 00100RRR101010000RRRssssssSSSSSS.
def ARC_LP_s13 : ARCompactInst32_3op<0b00100, 0b101000, "lp",
    (outs ), (ins brtarget_s13:$simm13_a16_20),
    "lp\t$simm13_a16_20", []> {
  // Opcode: 0x20A80000, Mask: 0xF8FF8000
  // Operands: SIMM13_A16_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b101010000;
  bits<12> simm13_a16_20;
  let Inst{11-6} = simm13_a16_20{11-6};
  let Inst{5-0} = simm13_a16_20{5-0};
}

// lp<cc> u7 00100RRR111010000RRRuuuuuu1QQQQQ.
def ARC_LP_u7_cc : ARCompactInst32_3op<0b00100, 0b101000, "lp",
    (outs ), (ins u7imm_a16:$uimm7_a16_20),
    "lp\t$uimm7_a16_20", []> {
  // Opcode: 0x20E80020, Mask: 0xF8FF8020
  // Operands: UIMM7_A16_20
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b111010000;
  let Inst{5} = 1;
  let isPredicable = 1;
  bits<6> uimm7_a16_20;
  let Inst{11-6} = uimm7_a16_20;
}

// lr b,c 00100bbb001010100BBBCCCCCCRRRRRR.
def ARC_LR_b_c : ARCompactInst32_3op<0b00100, 0b101010, "lr",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "lr\t$rb_chk, [$rc]", []> {
  // Opcode: 0x202A0000, Mask: 0xF8FF8000
  // Operands: RB_CHK, BRAKET, RC, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001010100;
  bits<6> rb_chk;
  let Inst{26-24} = rb_chk{5-3};
  let Inst{14-12} = rb_chk{2-0};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// lr 0,c 00100110001010100111CCCCCCRRRRRR.
def ARC_LR_z_c : ARCompactInst32_3op<0b00100, 0b101010, "lr",
    (outs ), (ins GPR32:$rc),
    "lr\t[$rc]", []> {
  // Opcode: 0x262A7000, Mask: 0xFFFFF000
  // Operands: ZA, BRAKET, RC, BRAKETdup
  // Flags: none
  let Inst{31-12} = 0b00100110001010100111;
  bits<6> rc;
  let Inst{11-6} = rc;
}

// lr b,u6 00100bbb011010100BBBuuuuuu000000.
def ARC_LR_b_u6 : ARCompactInst32_3op<0b00100, 0b101010, "lr",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "lr\t$rb_chk, [$uimm6_20]", []> {
  // Opcode: 0x206A0000, Mask: 0xF8FF803F
  // Operands: RB_CHK, BRAKET, UIMM6_20, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b011010100;
  let Inst{5-0} = 0b000000;
  bits<6> rb_chk;
  let Inst{26-24} = rb_chk{5-3};
  let Inst{14-12} = rb_chk{2-0};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// lr 0,u6 00100110011010100111uuuuuu000000.
def ARC_LR_z_u6 : ARCompactInst32_3op<0b00100, 0b101010, "lr",
    (outs ), (ins u6imm:$uimm6_20),
    "lr\t[$uimm6_20]", []> {
  // Opcode: 0x266A7000, Mask: 0xFFFFF03F
  // Operands: ZA, BRAKET, UIMM6_20, BRAKETdup
  // Flags: none
  let Inst{31-12} = 0b00100110011010100111;
  let Inst{5-0} = 0b000000;
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// lr b,s12 00100bbb101010100BBBssssssSSSSSS.
def ARC_LR_b_s12 : ARCompactInst32_3op<0b00100, 0b101010, "lr",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "lr\t$rb_chk, [$simm12_20]", []> {
  // Opcode: 0x20AA0000, Mask: 0xF8FF8000
  // Operands: RB_CHK, BRAKET, SIMM12_20, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b101010100;
  bits<6> rb_chk;
  let Inst{26-24} = rb_chk{5-3};
  let Inst{14-12} = rb_chk{2-0};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// lr 0,s12 00100110101010100111ssssssSSSSSS.
def ARC_LR_z_s12 : ARCompactInst32_3op<0b00100, 0b101010, "lr",
    (outs ), (ins s12imm:$simm12_20),
    "lr\t[$simm12_20]", []> {
  // Opcode: 0x26AA7000, Mask: 0xFFFFF000
  // Operands: ZA, BRAKET, SIMM12_20, BRAKETdup
  // Flags: none
  let Inst{31-12} = 0b00100110101010100111;
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// lr b,limm 00100bbb001010100BBB111110RRRRRR.
def ARC_LR_b_limm : ARCompactInst32_3op<0b00100, 0b101010, "lr",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "lr\t$rb_chk, [$limm]", []> {
  // Opcode: 0x202A0F80, Mask: 0xF8FF8FC0
  // Operands: RB_CHK, BRAKET, LIMM, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001010100;
  let Inst{11-6} = 0b111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lr 0,limm 00100110001010100111111110RRRRRR.
def ARC_LR_z_limm : ARCompactInst32_3op<0b00100, 0b101010, "lr",
    (outs ), (ins i32imm:$limm),
    "lr\t[$limm]", []> {
  // Opcode: 0x262A7F80, Mask: 0xFFFFFFC0
  // Operands: ZA, BRAKET, LIMM, BRAKETdup
  // Flags: none
  let Inst{31-6} = 0b00100110001010100111111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// nop  00100110010010100111000000000000.
def ARC_NOP_0 : ARCompactInst32_3op<0b00100, 0b001010, "nop",
    (outs ), (ins),
    "nop", []> {
  // Opcode: 0x264A7000, Mask: 0xFFFFFFFF
  // Operands: 0
  // Flags: none
  let Inst{31-0} = 0b00100110010010100111000000000000;
}

// rtie  00100100011011110000000000111111.
def ARC_RTIE_0 : ARCompactInst32_2op<0b00100, 0b111111, "rtie",
    (outs ), (ins),
    "rtie", []> {
  // Opcode: 0x246F003F, Mask: 0xFFFFFFFF
  // Operands: 0
  // Flags: none
  let Inst{31-0} = 0b00100100011011110000000000111111;
}

// rtsc b,0 00110bbb01101111RBBB000000011010.
def ARC_RTSC_b_z : ARCompactInst32_2op<0b00110, 0b011010, "rtsc",
    (outs ), (ins GPR32:$rb),
    "rtsc\t$rb", []> {
  // Opcode: 0x306F001A, Mask: 0xF8FF0FFF
  // Operands: RB, ZB
  // Flags: none
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01101111;
  let Inst{11-0} = 0b000000011010;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
}

// rtsc 0,0 0011011001101111R111000000011010.
def ARC_RTSC_z_z : ARCompactInst32_2op<0b00110, 0b011010, "rtsc",
    (outs ), (ins ),
    "rtsc", []> {
  // Opcode: 0x366F701A, Mask: 0xFFFF7FFF
  // Operands: ZA, ZB
  // Flags: none
  let Inst{31-16} = 0b0011011001101111;
  let Inst{14-0} = 0b111000000011010;
}

// rtsc b,c 00110bbb00101111RBBBCCCCCC011010.
def ARC_RTSC_b_c : ARCompactInst32_2op<0b00110, 0b011010, "rtsc",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "rtsc\t$rb, $rc", []> {
  // Opcode: 0x302F001A, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: none
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b011010;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rtsc 0,c 0011011000101111R111CCCCCC011010.
def ARC_RTSC_z_c : ARCompactInst32_2op<0b00110, 0b011010, "rtsc",
    (outs ), (ins GPR32:$rc),
    "rtsc\t$rc", []> {
  // Opcode: 0x362F701A, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: none
  let Inst{31-16} = 0b0011011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b011010;
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rtsc b,u6 00110bbb01101111RBBBuuuuuu011010.
def ARC_RTSC_b_u6 : ARCompactInst32_2op<0b00110, 0b011010, "rtsc",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "rtsc\t$rb, $uimm6_20", []> {
  // Opcode: 0x306F001A, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: none
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b011010;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rtsc 0,u6 0011011001101111R111uuuuuu011010.
def ARC_RTSC_z_u6 : ARCompactInst32_2op<0b00110, 0b011010, "rtsc",
    (outs ), (ins u6imm:$uimm6_20),
    "rtsc\t$uimm6_20", []> {
  // Opcode: 0x366F701A, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: none
  let Inst{31-16} = 0b0011011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b011010;
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rtsc b,limm 00110bbb00101111RBBB111110011010.
def ARC_RTSC_b_limm : ARCompactInst32_2op<0b00110, 0b011010, "rtsc",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "rtsc\t$rb, $limm", []> {
  // Opcode: 0x302F0F9A, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: none
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110011010;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rtsc 0,limm 0011011000101111R111111110011010.
def ARC_RTSC_z_limm : ARCompactInst32_2op<0b00110, 0b011010, "rtsc",
    (outs ), (ins i32imm:$limm),
    "rtsc\t$limm", []> {
  // Opcode: 0x362F7F9A, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: none
  let Inst{31-16} = 0b0011011000101111;
  let Inst{14-0} = 0b111111110011010;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rtsc (no-operand variant removed — duplicate of ARC_RTSC_z_z)

// sleep c 00100001001011110000CCCCCC111111.
def ARC_SLEEP_c : ARCompactInst32_2op<0b00100, 0b111111, "sleep",
    (outs ), (ins GPR32:$rc),
    "sleep\t$rc", []> {
  // Opcode: 0x212F003F, Mask: 0xFFFFF03F
  // Operands: RC
  // Flags: none
  let Inst{31-12} = 0b00100001001011110000;
  let Inst{5-0} = 0b111111;
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sleep u6 00100001011011110000uuuuuu111111.
def ARC_SLEEP_u6 : ARCompactInst32_2op<0b00100, 0b111111, "sleep",
    (outs ), (ins u6imm:$uimm6_20),
    "sleep\t$uimm6_20", []> {
  // Opcode: 0x216F003F, Mask: 0xFFFFF03F
  // Operands: UIMM6_20
  // Flags: none
  let Inst{31-12} = 0b00100001011011110000;
  let Inst{5-0} = 0b111111;
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sleep limm 00100001001011110000111110111111.
def ARC_SLEEP_limm : ARCompactInst32_2op<0b00100, 0b111111, "sleep",
    (outs ), (ins i32imm:$limm),
    "sleep\t$limm", []> {
  // Opcode: 0x212F0FBF, Mask: 0xFFFFFFFF
  // Operands: LIMM
  // Flags: none
  let Inst{31-0} = 0b00100001001011110000111110111111;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sleep 00100001011011110000uuuuuu111111.
def ARC_SLEEP_0 : ARCompactInst32_2op<0b00100, 0b111111, "sleep",
    (outs ), (ins),
    "sleep", []> {
  // Opcode: 0x216F003F, Mask: 0xFFFFFFFF
  // Operands: 0
  // Flags: none
  let Inst{31-0} = 0b00100001011011110000000000111111;
}

// sr b,c 00100bbb001010110BBBCCCCCCRRRRRR.
def ARC_SR_b_c : ARCompactInst32_3op<0b00100, 0b101011, "sr",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "sr\t$rb_chk, [$rc]", []> {
  // Opcode: 0x202B0000, Mask: 0xF8FF8000
  // Operands: RB_CHK, BRAKET, RC, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001010110;
  bits<6> rb_chk;
  let Inst{26-24} = rb_chk{5-3};
  let Inst{14-12} = rb_chk{2-0};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sr b,u6 00100bbb011010110BBBuuuuuu000000.
def ARC_SR_b_u6 : ARCompactInst32_3op<0b00100, 0b101011, "sr",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "sr\t$rb_chk, [$uimm6_20]", []> {
  // Opcode: 0x206B0000, Mask: 0xF8FF803F
  // Operands: RB_CHK, BRAKET, UIMM6_20, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b011010110;
  let Inst{5-0} = 0b000000;
  bits<6> rb_chk;
  let Inst{26-24} = rb_chk{5-3};
  let Inst{14-12} = rb_chk{2-0};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sr b,s12 00100bbb101010110BBBssssssSSSSSS.
def ARC_SR_b_s12 : ARCompactInst32_3op<0b00100, 0b101011, "sr",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "sr\t$rb_chk, [$simm12_20]", []> {
  // Opcode: 0x20AB0000, Mask: 0xF8FF8000
  // Operands: RB_CHK, BRAKET, SIMM12_20, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b101010110;
  bits<6> rb_chk;
  let Inst{26-24} = rb_chk{5-3};
  let Inst{14-12} = rb_chk{2-0};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// sr limm,c 00100110001010110111CCCCCCRRRRRR.
def ARC_SR_limm_c : ARCompactInst32_3op<0b00100, 0b101011, "sr",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sr\t$limm, [$rc]", []> {
  // Opcode: 0x262B7000, Mask: 0xFFFFF000
  // Operands: LIMM, BRAKET, RC, BRAKETdup
  // Flags: none
  let Inst{31-12} = 0b00100110001010110111;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sr b,limm 00100bbb001010110BBB111110RRRRRR.
def ARC_SR_b_limm : ARCompactInst32_3op<0b00100, 0b101011, "sr",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "sr\t$rb_chk, [$limm]", []> {
  // Opcode: 0x202B0F80, Mask: 0xF8FF8FC0
  // Operands: RB_CHK, BRAKET, LIMM, BRAKETdup
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b001010110;
  let Inst{11-6} = 0b111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sr limm,u6 00100110011010110111uuuuuu000000.
def ARC_SR_limm_u6 : ARCompactInst32_3op<0b00100, 0b101011, "sr",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sr\t$limm, [$uimm6_20]", []> {
  // Opcode: 0x266B7000, Mask: 0xFFFFF03F
  // Operands: LIMM, BRAKET, UIMM6_20, BRAKETdup
  // Flags: none
  let Inst{31-12} = 0b00100110011010110111;
  let Inst{5-0} = 0b000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sr limm,s12 00100110101010110111ssssssSSSSSS.
def ARC_SR_limm_s12 : ARCompactInst32_3op<0b00100, 0b101011, "sr",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "sr\t$limm, [$simm12_20]", []> {
  // Opcode: 0x26AB7000, Mask: 0xFFFFF000
  // Operands: LIMM, BRAKET, SIMM12_20, BRAKETdup
  // Flags: none
  let Inst{31-12} = 0b00100110101010110111;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sr limm,limm 00100110001010110111111110RRRRRR.
def ARC_SR_limm : ARCompactInst32_3op<0b00100, 0b101011, "sr",
    (outs ), (ins i32imm:$limm),
    "sr\t$limm", []> {
  // Opcode: 0x262B7F80, Mask: 0xFFFFFFC0
  // Operands: LIMM, BRAKET, LIMMdup, BRAKETdup
  // Flags: none
  let Inst{31-6} = 0b00100110001010110111111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sync  00100011011011110000000000111111.
def ARC_SYNC_0 : ARCompactInst32_2op<0b00100, 0b111111, "sync",
    (outs ), (ins),
    "sync", []> {
  // Opcode: 0x236F003F, Mask: 0xFFFFFFFF
  // Operands: 0
  // Flags: none
  let Inst{31-0} = 0b00100011011011110000000000111111;
}

// trap0  00100010011011110000000000111111.
def ARC_TRAP0_0 : ARCompactInst32_2op<0b00100, 0b111111, "trap0",
    (outs ), (ins),
    "trap0", []> {
  // Opcode: 0x226F003F, Mask: 0xFFFFFFFF
  // Operands: 0
  // Flags: none
  let Inst{31-0} = 0b00100010011011110000000000111111;
}

} // end let Predicates = [IsARCompact]
