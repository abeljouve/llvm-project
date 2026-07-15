//===-- ARCARCompactInstrALU.td - ARC ARCompact ALU Instructions -*- tablegen -*-===//
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

// 968 instruction variants

let Predicates = [IsARCompact] in {

// abs<.f> b,c 00100bbb00101111FBBBCCCCCC001001.
def ARC_ABS_b_c : ARCompactInst32_2op<0b00100, 0b001001, "abs",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "abs\t$rb, $rc", []> {
  // Opcode: 0x202F0009, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b001001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// abs<.f> 0,c 0010011000101111F111CCCCCC001001.
def ARC_ABS_z_c : ARCompactInst32_2op<0b00100, 0b001001, "abs",
    (outs ), (ins GPR32:$rc),
    "abs\t$rc", []> {
  // Opcode: 0x262F7009, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001001;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// abs<.f> b,u6 00100bbb01101111FBBBuuuuuu001001.
def ARC_ABS_b_u6 : ARCompactInst32_2op<0b00100, 0b001001, "abs",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "abs\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F0009, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b001001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// abs<.f> 0,u6 0010011001101111F111uuuuuu001001.
def ARC_ABS_z_u6 : ARCompactInst32_2op<0b00100, 0b001001, "abs",
    (outs ), (ins u6imm:$uimm6_20),
    "abs\t$uimm6_20", []> {
  // Opcode: 0x266F7009, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001001;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// abs<.f> b,limm 00100bbb00101111FBBB111110001001.
def ARC_ABS_b_limm : ARCompactInst32_2op<0b00100, 0b001001, "abs",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "abs\t$rb, $limm", []> {
  // Opcode: 0x202F0F89, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110001001;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// abs<.f> 0,limm 0010011000101111F111111110001001.
def ARC_ABS_z_limm : ARCompactInst32_2op<0b00100, 0b001001, "abs",
    (outs ), (ins i32imm:$limm),
    "abs\t$limm", []> {
  // Opcode: 0x262F7F89, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110001001;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// abss<.f> b,c 00101bbb00101111FBBBCCCCCC000101.
def ARC_ABSS_b_c : ARCompactInst32_2op<0b00101, 0b000101, "abss",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "abss\t$rb, $rc", []> {
  // Opcode: 0x282F0005, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000101;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// abss<.f> 0,c 0010111000101111F111CCCCCC000101.
def ARC_ABSS_z_c : ARCompactInst32_2op<0b00101, 0b000101, "abss",
    (outs ), (ins GPR32:$rc),
    "abss\t$rc", []> {
  // Opcode: 0x2E2F7005, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000101;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// abss<.f> b,u6 00101bbb01101111FBBBuuuuuu000101.
def ARC_ABSS_b_u6 : ARCompactInst32_2op<0b00101, 0b000101, "abss",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "abss\t$rb, $uimm6_20", []> {
  // Opcode: 0x286F0005, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000101;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// abss<.f> 0,u6 0010111001101111F111uuuuuu000101.
def ARC_ABSS_z_u6 : ARCompactInst32_2op<0b00101, 0b000101, "abss",
    (outs ), (ins u6imm:$uimm6_20),
    "abss\t$uimm6_20", []> {
  // Opcode: 0x2E6F7005, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000101;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// abss<.f> b,limm 00101bbb00101111FBBB111110000101.
def ARC_ABSS_b_limm : ARCompactInst32_2op<0b00101, 0b000101, "abss",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "abss\t$rb, $limm", []> {
  // Opcode: 0x282F0F85, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000101;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// abss<.f> 0,limm 0010111000101111F111111110000101.
def ARC_ABSS_z_limm : ARCompactInst32_2op<0b00101, 0b000101, "abss",
    (outs ), (ins i32imm:$limm),
    "abss\t$limm", []> {
  // Opcode: 0x2E2F7F85, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-0} = 0b111111110000101;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// abssw<.f> b,c 00101bbb00101111FBBBCCCCCC000100.
def ARC_ABSSW_b_c : ARCompactInst32_2op<0b00101, 0b000100, "abssw",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "abssw\t$rb, $rc", []> {
  // Opcode: 0x282F0004, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000100;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// abssw<.f> 0,c 0010111000101111F111CCCCCC000100.
def ARC_ABSSW_z_c : ARCompactInst32_2op<0b00101, 0b000100, "abssw",
    (outs ), (ins GPR32:$rc),
    "abssw\t$rc", []> {
  // Opcode: 0x2E2F7004, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000100;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// abssw<.f> b,u6 00101bbb01101111FBBBuuuuuu000100.
def ARC_ABSSW_b_u6 : ARCompactInst32_2op<0b00101, 0b000100, "abssw",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "abssw\t$rb, $uimm6_20", []> {
  // Opcode: 0x286F0004, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000100;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// abssw<.f> 0,u6 0010111001101111F111uuuuuu000100.
def ARC_ABSSW_z_u6 : ARCompactInst32_2op<0b00101, 0b000100, "abssw",
    (outs ), (ins u6imm:$uimm6_20),
    "abssw\t$uimm6_20", []> {
  // Opcode: 0x2E6F7004, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000100;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// abssw<.f> b,limm 00101bbb00101111FBBB111110000100.
def ARC_ABSSW_b_limm : ARCompactInst32_2op<0b00101, 0b000100, "abssw",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "abssw\t$rb, $limm", []> {
  // Opcode: 0x282F0F84, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000100;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// abssw<.f> 0,limm 0010111000101111F111111110000100.
def ARC_ABSSW_z_limm : ARCompactInst32_2op<0b00101, 0b000100, "abssw",
    (outs ), (ins i32imm:$limm),
    "abssw\t$limm", []> {
  // Opcode: 0x2E2F7F84, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-0} = 0b111111110000100;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// acm<.f> a,b,c 00110bbb00101000FBBBCCCCCCAAAAAA.
def ARC_ACM_a_b_c : ARCompactInst32_3op<0b00110, 0b101000, "acm",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "acm\t$ra, $rb, $rc", []> {
  // Opcode: 0x30280000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00101000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// acm<.f><.cc> b,b,c 00110bbb11101000FBBBCCCCCC0QQQQQ.
def ARC_ACM_b_c_cc : ARCompactInst32_3op<0b00110, 0b101000, "acm",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "acm\t$rb, $rc", []> {
  // Opcode: 0x30E80000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11101000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// acm<.f> a,b,u6 00110bbb01101000FBBBuuuuuuAAAAAA.
def ARC_ACM_a_b_u6 : ARCompactInst32_3op<0b00110, 0b101000, "acm",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "acm\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30680000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01101000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// acm<.f><.cc> b,b,u6 00110bbb11101000FBBBuuuuuu1QQQQQ.
def ARC_ACM_b_u6_cc : ARCompactInst32_3op<0b00110, 0b101000, "acm",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "acm\t$rb, $uimm6_20", []> {
  // Opcode: 0x30E80020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11101000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// acm<.f> b,b,s12 00110bbb10101000FBBBssssssSSSSSS.
def ARC_ACM_b_s12 : ARCompactInst32_3op<0b00110, 0b101000, "acm",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "acm\t$rb, $simm12_20", []> {
  // Opcode: 0x30A80000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10101000;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// acm<.f> a,limm,c 0011011000101000F111CCCCCCAAAAAA.
def ARC_ACM_a_limm_c : ARCompactInst32_3op<0b00110, 0b101000, "acm",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "acm\t$ra, $limm, $rc", []> {
  // Opcode: 0x36287000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000101000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// acm<.f> a,b,limm 00110bbb00101000FBBB111110AAAAAA.
def ARC_ACM_a_b_limm : ARCompactInst32_3op<0b00110, 0b101000, "acm",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "acm\t$ra, $rb, $limm", []> {
  // Opcode: 0x30280F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00101000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// acm<.f><.cc> b,b,limm 00110bbb11101000FBBB1111100QQQQQ.
def ARC_ACM_b_limm_cc : ARCompactInst32_3op<0b00110, 0b101000, "acm",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "acm\t$rb, $limm", []> {
  // Opcode: 0x30E80F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11101000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f> a,b,c 00100bbb00000001FBBBCCCCCCAAAAAA.
def ARC_ADC_a_b_c : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "adc\t$ra, $rb, $rc", []> {
  // Opcode: 0x20010000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// adc<.f> 0,b,c 00100bbb00000001FBBBCCCCCC111110.
def ARC_ADC_z_b_c : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "adc\t$rb, $rc", []> {
  // Opcode: 0x2001003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// adc<.f><.cc> b,b,c 00100bbb11000001FBBBCCCCCC0QQQQQ.
def ARC_ADC_b_c_cc : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "adc\t$rb, $rc", []> {
  // Opcode: 0x20C10000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// adc<.f> a,b,u6 00100bbb01000001FBBBuuuuuuAAAAAA.
def ARC_ADC_a_b_u6 : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "adc\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20410000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// adc<.f> 0,b,u6 00100bbb01000001FBBBuuuuuu111110.
def ARC_ADC_z_b_u6 : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "adc\t$rb, $uimm6_20", []> {
  // Opcode: 0x2041003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// adc<.f><.cc> b,b,u6 00100bbb11000001FBBBuuuuuu1QQQQQ.
def ARC_ADC_b_u6_cc : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "adc\t$rb, $uimm6_20", []> {
  // Opcode: 0x20C10020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// adc<.f> b,b,s12 00100bbb10000001FBBBssssssSSSSSS.
def ARC_ADC_b_s12 : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "adc\t$rb, $simm12_20", []> {
  // Opcode: 0x20810000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10000001;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// adc<.f> a,limm,c 0010011000000001F111CCCCCCAAAAAA.
def ARC_ADC_a_limm_c : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "adc\t$ra, $limm, $rc", []> {
  // Opcode: 0x26017000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f> a,b,limm 00100bbb00000001FBBB111110AAAAAA.
def ARC_ADC_a_b_limm : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "adc\t$ra, $rb, $limm", []> {
  // Opcode: 0x20010F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f> 0,limm,c 0010011000000001F111CCCCCC111110.
def ARC_ADC_z_limm_c : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "adc\t$limm, $rc", []> {
  // Opcode: 0x2601703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f> 0,b,limm 00100bbb00000001FBBB111110111110.
def ARC_ADC_z_b_limm : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "adc\t$rb, $limm", []> {
  // Opcode: 0x20010FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f><.cc> b,b,limm 00100bbb11000001FBBB1111100QQQQQ.
def ARC_ADC_b_limm_cc : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "adc\t$rb, $limm", []> {
  // Opcode: 0x20C10F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f><.cc> 0,limm,c 0010011011000001F111CCCCCC0QQQQQ.
def ARC_ADC_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "adc\t$limm, $rc", []> {
  // Opcode: 0x26C17000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f> a,limm,u6 0010011001000001F111uuuuuuAAAAAA.
def ARC_ADC_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "adc\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26417000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f> 0,limm,u6 0010011001000001F111uuuuuu111110.
def ARC_ADC_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "adc\t$limm, $uimm6_20", []> {
  // Opcode: 0x2641703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f><.cc> 0,limm,u6 0010011011000001F111uuuuuu1QQQQQ.
def ARC_ADC_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "adc\t$limm, $uimm6_20", []> {
  // Opcode: 0x26C17020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f> 0,limm,s12 0010011010000001F111ssssssSSSSSS.
def ARC_ADC_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "adc\t$limm, $simm12_20", []> {
  // Opcode: 0x26817000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010000001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f> a,limm,limm 0010011000000001F111111110AAAAAA.
def ARC_ADC_a_limm : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "adc\t$ra, $limm", []> {
  // Opcode: 0x26017F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f> 0,limm,limm 0010011000000001F111111110111110.
def ARC_ADC_z_limm : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs ), (ins i32imm:$limm),
    "adc\t$limm", []> {
  // Opcode: 0x26017FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adc<.f><.cc> 0,limm,limm 0010011011000001F1111111100QQQQQ.
def ARC_ADC_z_limm_cc : ARCompactInst32_3op<0b00100, 0b000001, "adc",
    (outs ), (ins i32imm:$limm),
    "adc\t$limm", []> {
  // Opcode: 0x26C17F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f> a,b,c 00101bbb00100110FBBBCCCCCCAAAAAA.
def ARC_ADCS_a_b_c : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "adcs\t$ra, $rb, $rc", []> {
  // Opcode: 0x28260000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// adcs<.f> 0,b,c 00101bbb00100110FBBBCCCCCC111110.
def ARC_ADCS_z_b_c : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "adcs\t$rb, $rc", []> {
  // Opcode: 0x2826003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// adcs<.f><.cc> b,b,c 00101bbb11100110FBBBCCCCCC0QQQQQ.
def ARC_ADCS_b_c_cc : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "adcs\t$rb, $rc", []> {
  // Opcode: 0x28E60000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11100110;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// adcs<.f> a,b,u6 00101bbb01100110FBBBuuuuuuAAAAAA.
def ARC_ADCS_a_b_u6 : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "adcs\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x28660000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01100110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// adcs<.f> 0,b,u6 00101bbb01100110FBBBuuuuuu111110.
def ARC_ADCS_z_b_u6 : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "adcs\t$rb, $uimm6_20", []> {
  // Opcode: 0x2866003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01100110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// adcs<.f><.cc> b,b,u6 00101bbb11100110FBBBuuuuuu1QQQQQ.
def ARC_ADCS_b_u6_cc : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "adcs\t$rb, $uimm6_20", []> {
  // Opcode: 0x28E60020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11100110;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// adcs<.f> b,b,s12 00101bbb10100110FBBBssssssSSSSSS.
def ARC_ADCS_b_s12 : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "adcs\t$rb, $simm12_20", []> {
  // Opcode: 0x28A60000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10100110;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// adcs<.f> a,limm,c 0010111000100110F111CCCCCCAAAAAA.
def ARC_ADCS_a_limm_c : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "adcs\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E267000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000100110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f> a,b,limm 00101bbb00100110FBBB111110AAAAAA.
def ARC_ADCS_a_b_limm : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "adcs\t$ra, $rb, $limm", []> {
  // Opcode: 0x28260F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100110;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f> 0,limm,c 0010111001100110F111CCCCCC111110.
def ARC_ADCS_z_limm_c : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "adcs\t$limm, $rc", []> {
  // Opcode: 0x2E66703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111001100110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f> 0,b,limm 00101bbb00100110FBBB111110111110.
def ARC_ADCS_z_b_limm : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "adcs\t$rb, $limm", []> {
  // Opcode: 0x28260FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100110;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f><.cc> b,b,limm 00101bbb11100110FBBB1111100QQQQQ.
def ARC_ADCS_b_limm_cc : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "adcs\t$rb, $limm", []> {
  // Opcode: 0x28E60F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11100110;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f><.cc> 0,limm,c 0010111011100110F111CCCCCC0QQQQQ.
def ARC_ADCS_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "adcs\t$limm, $rc", []> {
  // Opcode: 0x2EE67000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011100110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f> a,limm,u6 0010111001100110F111uuuuuuAAAAAA.
def ARC_ADCS_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "adcs\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E667000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001100110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f> 0,limm,u6 0010111001100110F111uuuuuu111110.
def ARC_ADCS_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "adcs\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E66703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001100110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Decoding conflict with overlapping encoding.
  let isCodeGenOnly = 1;
}

// adcs<.f><.cc> 0,limm,u6 0010111011100110F111uuuuuu1QQQQQ.
def ARC_ADCS_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "adcs\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EE67020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011100110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f> 0,limm,s12 0010111010100110F111ssssssSSSSSS.
def ARC_ADCS_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "adcs\t$limm, $simm12_20", []> {
  // Opcode: 0x2EA67000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010100110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f> a,limm,limm 0010111000100110F111111110AAAAAA.
def ARC_ADCS_a_limm : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "adcs\t$ra, $limm", []> {
  // Opcode: 0x2E267F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000100110;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f> 0,limm,limm 0010111000100110F111111110111110.
def ARC_ADCS_z_limm : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs ), (ins i32imm:$limm),
    "adcs\t$limm", []> {
  // Opcode: 0x2E267FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000100110;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adcs<.f><.cc> 0,limm,limm 0010111011100110F1111111100QQQQQ.
def ARC_ADCS_z_limm_cc : ARCompactInst32_3op<0b00101, 0b100110, "adcs",
    (outs ), (ins i32imm:$limm),
    "adcs\t$limm", []> {
  // Opcode: 0x2EE67F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011100110;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f> a,b,c 00100bbb00000000FBBBCCCCCCAAAAAA.
def ARC_ADD_a_b_c : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "add\t$ra, $rb, $rc", []> {
  // Opcode: 0x20000000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// add<.f> 0,b,c 00100bbb00000000FBBBCCCCCC111110.
def ARC_ADD_z_b_c : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "add\t$rb, $rc", []> {
  // Opcode: 0x2000003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// add<.f><.cc> b,b,c 00100bbb11000000FBBBCCCCCC0QQQQQ.
def ARC_ADD_b_c_cc : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "add\t$rb, $rc", []> {
  // Opcode: 0x20C00000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// add<.f> a,b,u6 00100bbb01000000FBBBuuuuuuAAAAAA.
def ARC_ADD_a_b_u6 : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "add\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20400000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// add<.f> 0,b,u6 00100bbb01000000FBBBuuuuuu111110.
def ARC_ADD_z_b_u6 : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "add\t$rb, $uimm6_20", []> {
  // Opcode: 0x2040003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// add<.f><.cc> b,b,u6 00100bbb11000000FBBBuuuuuu1QQQQQ.
def ARC_ADD_b_u6_cc : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "add\t$rb, $uimm6_20", []> {
  // Opcode: 0x20C00020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// add<.f> b,b,s12 00100bbb10000000FBBBssssssSSSSSS.
def ARC_ADD_b_s12 : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "add\t$rb, $simm12_20", []> {
  // Opcode: 0x20800000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10000000;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// add<.f> a,limm,c 0010011000000000F111CCCCCCAAAAAA.
def ARC_ADD_a_limm_c : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "add\t$ra, $limm, $rc", []> {
  // Opcode: 0x26007000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f> a,b,limm 00100bbb00000000FBBB111110AAAAAA.
def ARC_ADD_a_b_limm : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "add\t$ra, $rb, $limm", []> {
  // Opcode: 0x20000F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f> 0,limm,c 0010011000000000F111CCCCCC111110.
def ARC_ADD_z_limm_c : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "add\t$limm, $rc", []> {
  // Opcode: 0x2600703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f> 0,b,limm 00100bbb00000000FBBB111110111110.
def ARC_ADD_z_b_limm : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "add\t$rb, $limm", []> {
  // Opcode: 0x20000FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f><.cc> b,b,limm 00100bbb11000000FBBB1111100QQQQQ.
def ARC_ADD_b_limm_cc : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "add\t$rb, $limm", []> {
  // Opcode: 0x20C00F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f><.cc> 0,limm,c 0010011011000000F111CCCCCC0QQQQQ.
def ARC_ADD_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "add\t$limm, $rc", []> {
  // Opcode: 0x26C07000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f> a,limm,u6 0010011001000000F111uuuuuuAAAAAA.
def ARC_ADD_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26407000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f> 0,limm,u6 0010011001000000F111uuuuuu111110.
def ARC_ADD_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add\t$limm, $uimm6_20", []> {
  // Opcode: 0x2640703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f><.cc> 0,limm,u6 0010011011000000F111uuuuuu1QQQQQ.
def ARC_ADD_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add\t$limm, $uimm6_20", []> {
  // Opcode: 0x26C07020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f> 0,limm,s12 0010011010000000F111ssssssSSSSSS.
def ARC_ADD_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "add\t$limm, $simm12_20", []> {
  // Opcode: 0x26807000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010000000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f> a,limm,limm 0010011000000000F111111110AAAAAA.
def ARC_ADD_a_limm : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "add\t$ra, $limm", []> {
  // Opcode: 0x26007F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f> 0,limm,limm 0010011000000000F111111110111110.
def ARC_ADD_z_limm : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs ), (ins i32imm:$limm),
    "add\t$limm", []> {
  // Opcode: 0x26007FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add<.f><.cc> 0,limm,limm 0010011011000000F1111111100QQQQQ.
def ARC_ADD_z_limm_cc : ARCompactInst32_3op<0b00100, 0b000000, "add",
    (outs ), (ins i32imm:$limm),
    "add\t$limm", []> {
  // Opcode: 0x26C07F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f> a,b,c 00100bbb00010100FBBBCCCCCCAAAAAA.
def ARC_ADD1_a_b_c : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "add1\t$ra, $rb, $rc", []> {
  // Opcode: 0x20140000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010100;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// add1<.f> 0,b,c 00100bbb00010100FBBBCCCCCC111110.
def ARC_ADD1_z_b_c : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "add1\t$rb, $rc", []> {
  // Opcode: 0x2014003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// add1<.f><.cc> b,b,c 00100bbb11010100FBBBCCCCCC0QQQQQ.
def ARC_ADD1_b_c_cc : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "add1\t$rb, $rc", []> {
  // Opcode: 0x20D40000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010100;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// add1<.f> a,b,u6 00100bbb01010100FBBBuuuuuuAAAAAA.
def ARC_ADD1_a_b_u6 : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "add1\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20540000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010100;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// add1<.f> 0,b,u6 00100bbb01010100FBBBuuuuuu111110.
def ARC_ADD1_z_b_u6 : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "add1\t$rb, $uimm6_20", []> {
  // Opcode: 0x2054003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// add1<.f><.cc> b,b,u6 00100bbb11010100FBBBuuuuuu1QQQQQ.
def ARC_ADD1_b_u6_cc : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "add1\t$rb, $uimm6_20", []> {
  // Opcode: 0x20D40020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010100;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// add1<.f> b,b,s12 00100bbb10010100FBBBssssssSSSSSS.
def ARC_ADD1_b_s12 : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "add1\t$rb, $simm12_20", []> {
  // Opcode: 0x20940000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10010100;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// add1<.f> a,limm,c 0010011000010100F111CCCCCCAAAAAA.
def ARC_ADD1_a_limm_c : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "add1\t$ra, $limm, $rc", []> {
  // Opcode: 0x26147000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f> a,b,limm 00100bbb00010100FBBB111110AAAAAA.
def ARC_ADD1_a_b_limm : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "add1\t$ra, $rb, $limm", []> {
  // Opcode: 0x20140F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010100;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f> 0,limm,c 0010011000010100F111CCCCCC111110.
def ARC_ADD1_z_limm_c : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "add1\t$limm, $rc", []> {
  // Opcode: 0x2614703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f> 0,b,limm 00100bbb00010100FBBB111110111110.
def ARC_ADD1_z_b_limm : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "add1\t$rb, $limm", []> {
  // Opcode: 0x20140FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010100;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f><.cc> b,b,limm 00100bbb11010100FBBB1111100QQQQQ.
def ARC_ADD1_b_limm_cc : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "add1\t$rb, $limm", []> {
  // Opcode: 0x20D40F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010100;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f><.cc> 0,limm,c 0010011011010100F111CCCCCC0QQQQQ.
def ARC_ADD1_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "add1\t$limm, $rc", []> {
  // Opcode: 0x26D47000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f> a,limm,u6 0010011001010100F111uuuuuuAAAAAA.
def ARC_ADD1_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add1\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26547000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f> 0,limm,u6 0010011001010100F111uuuuuu111110.
def ARC_ADD1_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add1\t$limm, $uimm6_20", []> {
  // Opcode: 0x2654703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f><.cc> 0,limm,u6 0010011011010100F111uuuuuu1QQQQQ.
def ARC_ADD1_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add1\t$limm, $uimm6_20", []> {
  // Opcode: 0x26D47020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f> 0,limm,s12 0010011010010100F111ssssssSSSSSS.
def ARC_ADD1_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "add1\t$limm, $simm12_20", []> {
  // Opcode: 0x26947000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010010100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f> a,limm,limm 0010011000010100F111111110AAAAAA.
def ARC_ADD1_a_limm : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "add1\t$ra, $limm", []> {
  // Opcode: 0x26147F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010100;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f> 0,limm,limm 0010011000010100F111111110111110.
def ARC_ADD1_z_limm : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs ), (ins i32imm:$limm),
    "add1\t$limm", []> {
  // Opcode: 0x26147FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010100;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add1<.f><.cc> 0,limm,limm 0010011011010100F1111111100QQQQQ.
def ARC_ADD1_z_limm_cc : ARCompactInst32_3op<0b00100, 0b010100, "add1",
    (outs ), (ins i32imm:$limm),
    "add1\t$limm", []> {
  // Opcode: 0x26D47F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010100;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f> a,b,c 00100bbb00010101FBBBCCCCCCAAAAAA.
def ARC_ADD2_a_b_c : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "add2\t$ra, $rb, $rc", []> {
  // Opcode: 0x20150000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010101;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// add2<.f> 0,b,c 00100bbb00010101FBBBCCCCCC111110.
def ARC_ADD2_z_b_c : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "add2\t$rb, $rc", []> {
  // Opcode: 0x2015003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// add2<.f><.cc> b,b,c 00100bbb11010101FBBBCCCCCC0QQQQQ.
def ARC_ADD2_b_c_cc : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "add2\t$rb, $rc", []> {
  // Opcode: 0x20D50000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010101;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// add2<.f> a,b,u6 00100bbb01010101FBBBuuuuuuAAAAAA.
def ARC_ADD2_a_b_u6 : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "add2\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20550000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010101;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// add2<.f> 0,b,u6 00100bbb01010101FBBBuuuuuu111110.
def ARC_ADD2_z_b_u6 : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "add2\t$rb, $uimm6_20", []> {
  // Opcode: 0x2055003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// add2<.f><.cc> b,b,u6 00100bbb11010101FBBBuuuuuu1QQQQQ.
def ARC_ADD2_b_u6_cc : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "add2\t$rb, $uimm6_20", []> {
  // Opcode: 0x20D50020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010101;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// add2<.f> b,b,s12 00100bbb10010101FBBBssssssSSSSSS.
def ARC_ADD2_b_s12 : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "add2\t$rb, $simm12_20", []> {
  // Opcode: 0x20950000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10010101;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// add2<.f> a,limm,c 0010011000010101F111CCCCCCAAAAAA.
def ARC_ADD2_a_limm_c : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "add2\t$ra, $limm, $rc", []> {
  // Opcode: 0x26157000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f> a,b,limm 00100bbb00010101FBBB111110AAAAAA.
def ARC_ADD2_a_b_limm : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "add2\t$ra, $rb, $limm", []> {
  // Opcode: 0x20150F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010101;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f> 0,limm,c 0010011000010101F111CCCCCC111110.
def ARC_ADD2_z_limm_c : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "add2\t$limm, $rc", []> {
  // Opcode: 0x2615703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f> 0,b,limm 00100bbb00010101FBBB111110111110.
def ARC_ADD2_z_b_limm : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "add2\t$rb, $limm", []> {
  // Opcode: 0x20150FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010101;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f><.cc> b,b,limm 00100bbb11010101FBBB1111100QQQQQ.
def ARC_ADD2_b_limm_cc : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "add2\t$rb, $limm", []> {
  // Opcode: 0x20D50F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010101;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f><.cc> 0,limm,c 0010011011010101F111CCCCCC0QQQQQ.
def ARC_ADD2_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "add2\t$limm, $rc", []> {
  // Opcode: 0x26D57000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f> a,limm,u6 0010011001010101F111uuuuuuAAAAAA.
def ARC_ADD2_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add2\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26557000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f> 0,limm,u6 0010011001010101F111uuuuuu111110.
def ARC_ADD2_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add2\t$limm, $uimm6_20", []> {
  // Opcode: 0x2655703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f><.cc> 0,limm,u6 0010011011010101F111uuuuuu1QQQQQ.
def ARC_ADD2_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add2\t$limm, $uimm6_20", []> {
  // Opcode: 0x26D57020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f> 0,limm,s12 0010011010010101F111ssssssSSSSSS.
def ARC_ADD2_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "add2\t$limm, $simm12_20", []> {
  // Opcode: 0x26957000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010010101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f> a,limm,limm 0010011000010101F111111110AAAAAA.
def ARC_ADD2_a_limm : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "add2\t$ra, $limm", []> {
  // Opcode: 0x26157F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010101;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f> 0,limm,limm 0010011000010101F111111110111110.
def ARC_ADD2_z_limm : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs ), (ins i32imm:$limm),
    "add2\t$limm", []> {
  // Opcode: 0x26157FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010101;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add2<.f><.cc> 0,limm,limm 0010011011010101F1111111100QQQQQ.
def ARC_ADD2_z_limm_cc : ARCompactInst32_3op<0b00100, 0b010101, "add2",
    (outs ), (ins i32imm:$limm),
    "add2\t$limm", []> {
  // Opcode: 0x26D57F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010101;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f> a,b,c 00100bbb00010110FBBBCCCCCCAAAAAA.
def ARC_ADD3_a_b_c : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "add3\t$ra, $rb, $rc", []> {
  // Opcode: 0x20160000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// add3<.f> 0,b,c 00100bbb00010110FBBBCCCCCC111110.
def ARC_ADD3_z_b_c : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "add3\t$rb, $rc", []> {
  // Opcode: 0x2016003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// add3<.f><.cc> b,b,c 00100bbb11010110FBBBCCCCCC0QQQQQ.
def ARC_ADD3_b_c_cc : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "add3\t$rb, $rc", []> {
  // Opcode: 0x20D60000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010110;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// add3<.f> a,b,u6 00100bbb01010110FBBBuuuuuuAAAAAA.
def ARC_ADD3_a_b_u6 : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "add3\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20560000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// add3<.f> 0,b,u6 00100bbb01010110FBBBuuuuuu111110.
def ARC_ADD3_z_b_u6 : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "add3\t$rb, $uimm6_20", []> {
  // Opcode: 0x2056003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// add3<.f><.cc> b,b,u6 00100bbb11010110FBBBuuuuuu1QQQQQ.
def ARC_ADD3_b_u6_cc : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "add3\t$rb, $uimm6_20", []> {
  // Opcode: 0x20D60020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010110;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// add3<.f> b,b,s12 00100bbb10010110FBBBssssssSSSSSS.
def ARC_ADD3_b_s12 : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "add3\t$rb, $simm12_20", []> {
  // Opcode: 0x20960000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10010110;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// add3<.f> a,limm,c 0010011000010110F111CCCCCCAAAAAA.
def ARC_ADD3_a_limm_c : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "add3\t$ra, $limm, $rc", []> {
  // Opcode: 0x26167000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f> a,b,limm 00100bbb00010110FBBB111110AAAAAA.
def ARC_ADD3_a_b_limm : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "add3\t$ra, $rb, $limm", []> {
  // Opcode: 0x20160F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010110;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f> 0,limm,c 0010011000010110F111CCCCCC111110.
def ARC_ADD3_z_limm_c : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "add3\t$limm, $rc", []> {
  // Opcode: 0x2616703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f> 0,b,limm 00100bbb00010110FBBB111110111110.
def ARC_ADD3_z_b_limm : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "add3\t$rb, $limm", []> {
  // Opcode: 0x20160FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010110;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f><.cc> b,b,limm 00100bbb11010110FBBB1111100QQQQQ.
def ARC_ADD3_b_limm_cc : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "add3\t$rb, $limm", []> {
  // Opcode: 0x20D60F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010110;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f><.cc> 0,limm,c 0010011011010110F111CCCCCC0QQQQQ.
def ARC_ADD3_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "add3\t$limm, $rc", []> {
  // Opcode: 0x26D67000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f> a,limm,u6 0010011001010110F111uuuuuuAAAAAA.
def ARC_ADD3_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add3\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26567000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f> 0,limm,u6 0010011001010110F111uuuuuu111110.
def ARC_ADD3_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add3\t$limm, $uimm6_20", []> {
  // Opcode: 0x2656703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f><.cc> 0,limm,u6 0010011011010110F111uuuuuu1QQQQQ.
def ARC_ADD3_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "add3\t$limm, $uimm6_20", []> {
  // Opcode: 0x26D67020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f> 0,limm,s12 0010011010010110F111ssssssSSSSSS.
def ARC_ADD3_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "add3\t$limm, $simm12_20", []> {
  // Opcode: 0x26967000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010010110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f> a,limm,limm 0010011000010110F111111110AAAAAA.
def ARC_ADD3_a_limm : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "add3\t$ra, $limm", []> {
  // Opcode: 0x26167F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010110;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f> 0,limm,limm 0010011000010110F111111110111110.
def ARC_ADD3_z_limm : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs ), (ins i32imm:$limm),
    "add3\t$limm", []> {
  // Opcode: 0x26167FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010110;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// add3<.f><.cc> 0,limm,limm 0010011011010110F1111111100QQQQQ.
def ARC_ADD3_z_limm_cc : ARCompactInst32_3op<0b00100, 0b010110, "add3",
    (outs ), (ins i32imm:$limm),
    "add3\t$limm", []> {
  // Opcode: 0x26D67F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010110;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addqbs<.f> a,b,c 00110bbb00100100FBBBCCCCCCAAAAAA.
def ARC_ADDQBS_a_b_c : ARCompactInst32_3op<0b00110, 0b100100, "addqbs",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "addqbs\t$ra, $rb, $rc", []> {
  // Opcode: 0x30240000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100100;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// addqbs<.f><.cc> b,b,c 00110bbb11100100FBBBCCCCCC0QQQQQ.
def ARC_ADDQBS_b_c_cc : ARCompactInst32_3op<0b00110, 0b100100, "addqbs",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "addqbs\t$rb, $rc", []> {
  // Opcode: 0x30E40000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100100;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// addqbs<.f> a,b,u6 00110bbb01100100FBBBuuuuuuAAAAAA.
def ARC_ADDQBS_a_b_u6 : ARCompactInst32_3op<0b00110, 0b100100, "addqbs",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "addqbs\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30640000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01100100;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// addqbs<.f><.cc> b,b,u6 00110bbb11100100FBBBuuuuuu1QQQQQ.
def ARC_ADDQBS_b_u6_cc : ARCompactInst32_3op<0b00110, 0b100100, "addqbs",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "addqbs\t$rb, $uimm6_20", []> {
  // Opcode: 0x30E40020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100100;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// addqbs<.f> b,b,s12 00110bbb10100100FBBBssssssSSSSSS.
def ARC_ADDQBS_b_s12 : ARCompactInst32_3op<0b00110, 0b100100, "addqbs",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "addqbs\t$rb, $simm12_20", []> {
  // Opcode: 0x30A40000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10100100;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// addqbs<.f> a,limm,c 0011011000100100F111CCCCCCAAAAAA.
def ARC_ADDQBS_a_limm_c : ARCompactInst32_3op<0b00110, 0b100100, "addqbs",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "addqbs\t$ra, $limm, $rc", []> {
  // Opcode: 0x36247000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000100100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addqbs<.f> a,b,limm 00110bbb00100100FBBB111110AAAAAA.
def ARC_ADDQBS_a_b_limm : ARCompactInst32_3op<0b00110, 0b100100, "addqbs",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "addqbs\t$ra, $rb, $limm", []> {
  // Opcode: 0x30240F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100100;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addqbs<.f><.cc> b,b,limm 00110bbb11100100FBBB1111100QQQQQ.
def ARC_ADDQBS_b_limm_cc : ARCompactInst32_3op<0b00110, 0b100100, "addqbs",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "addqbs\t$rb, $limm", []> {
  // Opcode: 0x30E40F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100100;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f> a,b,c 00101bbb00000110FBBBCCCCCCAAAAAA.
def ARC_ADDS_a_b_c : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "adds\t$ra, $rb, $rc", []> {
  // Opcode: 0x28060000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// adds<.f> 0,b,c 00101bbb00000110FBBBCCCCCC111110.
def ARC_ADDS_z_b_c : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "adds\t$rb, $rc", []> {
  // Opcode: 0x2806003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// adds<.f><.cc> b,b,c 00101bbb11000110FBBBCCCCCC0QQQQQ.
def ARC_ADDS_b_c_cc : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "adds\t$rb, $rc", []> {
  // Opcode: 0x28C60000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000110;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// adds<.f> a,b,u6 00101bbb01000110FBBBuuuuuuAAAAAA.
def ARC_ADDS_a_b_u6 : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "adds\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x28460000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// adds<.f> 0,b,u6 00101bbb01000110FBBBuuuuuu111110.
def ARC_ADDS_z_b_u6 : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "adds\t$rb, $uimm6_20", []> {
  // Opcode: 0x2846003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// adds<.f><.cc> b,b,u6 00101bbb11000110FBBBuuuuuu1QQQQQ.
def ARC_ADDS_b_u6_cc : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "adds\t$rb, $uimm6_20", []> {
  // Opcode: 0x28C60020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000110;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// adds<.f> b,b,s12 00101bbb10000110FBBBssssssSSSSSS.
def ARC_ADDS_b_s12 : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "adds\t$rb, $simm12_20", []> {
  // Opcode: 0x28860000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10000110;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// adds<.f> a,limm,c 0010111000000110F111CCCCCCAAAAAA.
def ARC_ADDS_a_limm_c : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "adds\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E067000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f> a,b,limm 00101bbb00000110FBBB111110AAAAAA.
def ARC_ADDS_a_b_limm : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "adds\t$ra, $rb, $limm", []> {
  // Opcode: 0x28060F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000110;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f> 0,limm,c 0010111000000110F111CCCCCC111110.
def ARC_ADDS_z_limm_c : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "adds\t$limm, $rc", []> {
  // Opcode: 0x2E06703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f> 0,b,limm 00101bbb00000110FBBB111110111110.
def ARC_ADDS_z_b_limm : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "adds\t$rb, $limm", []> {
  // Opcode: 0x28060FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000110;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f><.cc> b,b,limm 00101bbb11000110FBBB1111100QQQQQ.
def ARC_ADDS_b_limm_cc : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "adds\t$rb, $limm", []> {
  // Opcode: 0x28C60F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000110;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f><.cc> 0,limm,c 0010111011000110F111CCCCCC0QQQQQ.
def ARC_ADDS_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "adds\t$limm, $rc", []> {
  // Opcode: 0x2EC67000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f> a,limm,u6 0010111001000110F111uuuuuuAAAAAA.
def ARC_ADDS_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "adds\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E467000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f> 0,limm,u6 0010111001000110F111uuuuuu111110.
def ARC_ADDS_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "adds\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E46703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f><.cc> 0,limm,u6 0010111011000110F111uuuuuu1QQQQQ.
def ARC_ADDS_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "adds\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EC67020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f> 0,limm,s12 0010111010000110F111ssssssSSSSSS.
def ARC_ADDS_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "adds\t$limm, $simm12_20", []> {
  // Opcode: 0x2E867000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010000110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f> a,limm,limm 0010111000000110F111111110AAAAAA.
def ARC_ADDS_a_limm : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "adds\t$ra, $limm", []> {
  // Opcode: 0x2E067F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000110;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f> 0,limm,limm 0010111000000110F111111110111110.
def ARC_ADDS_z_limm : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs ), (ins i32imm:$limm),
    "adds\t$limm", []> {
  // Opcode: 0x2E067FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000110;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// adds<.f><.cc> 0,limm,limm 0010111011000110F1111111100QQQQQ.
def ARC_ADDS_z_limm_cc : ARCompactInst32_3op<0b00101, 0b000110, "adds",
    (outs ), (ins i32imm:$limm),
    "adds\t$limm", []> {
  // Opcode: 0x2EC67F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000110;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f> a,b,c 00101bbb00101000FBBBCCCCCCAAAAAA.
def ARC_ADDSDW_a_b_c : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "addsdw\t$ra, $rb, $rc", []> {
  // Opcode: 0x28280000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// addsdw<.f> 0,b,c 00101bbb00101000FBBBCCCCCC111110.
def ARC_ADDSDW_z_b_c : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "addsdw\t$rb, $rc", []> {
  // Opcode: 0x2828003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// addsdw<.f><.cc> b,b,c 00101bbb11101000FBBBCCCCCC0QQQQQ.
def ARC_ADDSDW_b_c_cc : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "addsdw\t$rb, $rc", []> {
  // Opcode: 0x28E80000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11101000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// addsdw<.f> a,b,u6 00101bbb01101000FBBBuuuuuuAAAAAA.
def ARC_ADDSDW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "addsdw\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x28680000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// addsdw<.f> 0,b,u6 00101bbb01101000FBBBuuuuuu111110.
def ARC_ADDSDW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "addsdw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2868003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// addsdw<.f><.cc> b,b,u6 00101bbb11101000FBBBuuuuuu1QQQQQ.
def ARC_ADDSDW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "addsdw\t$rb, $uimm6_20", []> {
  // Opcode: 0x28E80020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11101000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// addsdw<.f> b,b,s12 00101bbb10101000FBBBssssssSSSSSS.
def ARC_ADDSDW_b_s12 : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "addsdw\t$rb, $simm12_20", []> {
  // Opcode: 0x28A80000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10101000;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// addsdw<.f> a,limm,c 0010111000101000F111CCCCCCAAAAAA.
def ARC_ADDSDW_a_limm_c : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "addsdw\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E287000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f> a,b,limm 00101bbb00101000FBBB111110AAAAAA.
def ARC_ADDSDW_a_b_limm : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "addsdw\t$ra, $rb, $limm", []> {
  // Opcode: 0x28280F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f> 0,limm,c 0010111000101000F111CCCCCC111110.
def ARC_ADDSDW_z_limm_c : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "addsdw\t$limm, $rc", []> {
  // Opcode: 0x2E28703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f> 0,b,limm 00101bbb00101000FBBB111110111110.
def ARC_ADDSDW_z_b_limm : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "addsdw\t$rb, $limm", []> {
  // Opcode: 0x28280FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f><.cc> b,b,limm 00101bbb11101000FBBB1111100QQQQQ.
def ARC_ADDSDW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "addsdw\t$rb, $limm", []> {
  // Opcode: 0x28E80F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11101000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f><.cc> 0,limm,c 0010111011101000F111CCCCCC0QQQQQ.
def ARC_ADDSDW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "addsdw\t$limm, $rc", []> {
  // Opcode: 0x2EE87000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011101000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f> a,limm,u6 0010111001101000F111uuuuuuAAAAAA.
def ARC_ADDSDW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "addsdw\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E687000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f> 0,limm,u6 0010111001101000F111uuuuuu111110.
def ARC_ADDSDW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "addsdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E68703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f><.cc> 0,limm,u6 0010111011101000F111uuuuuu1QQQQQ.
def ARC_ADDSDW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "addsdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EE87020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011101000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f> 0,limm,s12 0010111010101000F111ssssssSSSSSS.
def ARC_ADDSDW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "addsdw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EA87000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010101000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f> a,limm,limm 0010111000101000F111111110AAAAAA.
def ARC_ADDSDW_a_limm : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "addsdw\t$ra, $limm", []> {
  // Opcode: 0x2E287F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f> 0,limm,limm 0010111000101000F111111110111110.
def ARC_ADDSDW_z_limm : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs ), (ins i32imm:$limm),
    "addsdw\t$limm", []> {
  // Opcode: 0x2E287FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// addsdw<.f><.cc> 0,limm,limm 0010111011101000F1111111100QQQQQ.
def ARC_ADDSDW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b101000, "addsdw",
    (outs ), (ins i32imm:$limm),
    "addsdw\t$limm", []> {
  // Opcode: 0x2EE87F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011101000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f> a,b,c 00100bbb00000100FBBBCCCCCCAAAAAA.
def ARC_AND_a_b_c : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "and\t$ra, $rb, $rc", []> {
  // Opcode: 0x20040000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000100;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// and<.f> 0,b,c 00100bbb00000100FBBBCCCCCC111110.
def ARC_AND_z_b_c : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "and\t$rb, $rc", []> {
  // Opcode: 0x2004003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// and<.f><.cc> b,b,c 00100bbb11000100FBBBCCCCCC0QQQQQ.
def ARC_AND_b_c_cc : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "and\t$rb, $rc", []> {
  // Opcode: 0x20C40000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000100;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// and<.f> a,b,u6 00100bbb01000100FBBBuuuuuuAAAAAA.
def ARC_AND_a_b_u6 : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "and\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20440000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000100;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// and<.f> 0,b,u6 00100bbb01000100FBBBuuuuuu111110.
def ARC_AND_z_b_u6 : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "and\t$rb, $uimm6_20", []> {
  // Opcode: 0x2044003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// and<.f><.cc> b,b,u6 00100bbb11000100FBBBuuuuuu1QQQQQ.
def ARC_AND_b_u6_cc : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "and\t$rb, $uimm6_20", []> {
  // Opcode: 0x20C40020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000100;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// and<.f> b,b,s12 00100bbb10000100FBBBssssssSSSSSS.
def ARC_AND_b_s12 : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "and\t$rb, $simm12_20", []> {
  // Opcode: 0x20840000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10000100;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// and<.f> a,limm,c 0010011000000100F111CCCCCCAAAAAA.
def ARC_AND_a_limm_c : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "and\t$ra, $limm, $rc", []> {
  // Opcode: 0x26047000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f> a,b,limm 00100bbb00000100FBBB111110AAAAAA.
def ARC_AND_a_b_limm : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "and\t$ra, $rb, $limm", []> {
  // Opcode: 0x20040F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000100;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f> 0,limm,c 0010011000000100F111CCCCCC111110.
def ARC_AND_z_limm_c : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "and\t$limm, $rc", []> {
  // Opcode: 0x2604703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f> 0,b,limm 00100bbb00000100FBBB111110111110.
def ARC_AND_z_b_limm : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "and\t$rb, $limm", []> {
  // Opcode: 0x20040FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000100;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f><.cc> b,b,limm 00100bbb11000100FBBB1111100QQQQQ.
def ARC_AND_b_limm_cc : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "and\t$rb, $limm", []> {
  // Opcode: 0x20C40F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000100;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f><.cc> 0,limm,c 0010011011000100F111CCCCCC0QQQQQ.
def ARC_AND_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "and\t$limm, $rc", []> {
  // Opcode: 0x26C47000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f> a,limm,u6 0010011001000100F111uuuuuuAAAAAA.
def ARC_AND_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "and\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26447000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f> 0,limm,u6 0010011001000100F111uuuuuu111110.
def ARC_AND_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "and\t$limm, $uimm6_20", []> {
  // Opcode: 0x2644703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f><.cc> 0,limm,u6 0010011011000100F111uuuuuu1QQQQQ.
def ARC_AND_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "and\t$limm, $uimm6_20", []> {
  // Opcode: 0x26C47020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f> 0,limm,s12 0010011010000100F111ssssssSSSSSS.
def ARC_AND_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "and\t$limm, $simm12_20", []> {
  // Opcode: 0x26847000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010000100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f> a,limm,limm 0010011000000100F111111110AAAAAA.
def ARC_AND_a_limm : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "and\t$ra, $limm", []> {
  // Opcode: 0x26047F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000100;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f> 0,limm,limm 0010011000000100F111111110111110.
def ARC_AND_z_limm : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs ), (ins i32imm:$limm),
    "and\t$limm", []> {
  // Opcode: 0x26047FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000100;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// and<.f><.cc> 0,limm,limm 0010011011000100F1111111100QQQQQ.
def ARC_AND_z_limm_cc : ARCompactInst32_3op<0b00100, 0b000100, "and",
    (outs ), (ins i32imm:$limm),
    "and\t$limm", []> {
  // Opcode: 0x26C47F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000100;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f> b,c 00100bbb00101111FBBBCCCCCC000000.
def ARC_ASL_b_c : ARCompactInst32_2op<0b00100, 0b000000, "asl",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "asl\t$rb, $rc", []> {
  // Opcode: 0x202F0000, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asl<.f> 0,c 0010011000101111F111CCCCCC000000.
def ARC_ASL_z_c : ARCompactInst32_2op<0b00100, 0b000000, "asl",
    (outs ), (ins GPR32:$rc),
    "asl\t$rc", []> {
  // Opcode: 0x262F7000, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000000;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asl<.f> a,b,c 00101bbb00000000FBBBCCCCCCAAAAAA.
def ARC_ASL_a_b_c : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "asl\t$ra, $rb, $rc", []> {
  // Opcode: 0x28000000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// asl<.f> 0,b,c 00101bbb00000000FBBBCCCCCC111110.
def ARC_ASL_z_b_c : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "asl\t$rb, $rc", []> {
  // Opcode: 0x2800003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asl<.f><.cc> b,b,c 00101bbb11000000FBBBCCCCCC0QQQQQ.
def ARC_ASL_b_c_cc : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "asl\t$rb, $rc", []> {
  // Opcode: 0x28C00000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asl<.f> b,u6 00100bbb01101111FBBBuuuuuu000000.
def ARC_ASL_b_u6 : ARCompactInst32_2op<0b00100, 0b000000, "asl",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "asl\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F0000, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asl<.f> 0,u6 0010011001101111F111uuuuuu000000.
def ARC_ASL_z_u6 : ARCompactInst32_2op<0b00100, 0b000000, "asl",
    (outs ), (ins u6imm:$uimm6_20),
    "asl\t$uimm6_20", []> {
  // Opcode: 0x266F7000, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000000;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asl<.f> a,b,u6 00101bbb01000000FBBBuuuuuuAAAAAA.
def ARC_ASL_a_b_u6 : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "asl\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x28400000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// asl<.f> 0,b,u6 00101bbb01000000FBBBuuuuuu111110.
def ARC_ASL_z_b_u6 : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "asl\t$rb, $uimm6_20", []> {
  // Opcode: 0x2840003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asl<.f><.cc> b,b,u6 00101bbb11000000FBBBuuuuuu1QQQQQ.
def ARC_ASL_b_u6_cc : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "asl\t$rb, $uimm6_20", []> {
  // Opcode: 0x28C00020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asl<.f> b,b,s12 00101bbb10000000FBBBssssssSSSSSS.
def ARC_ASL_b_s12 : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "asl\t$rb, $simm12_20", []> {
  // Opcode: 0x28800000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10000000;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// asl<.f> b,limm 00100bbb00101111FBBB111110000000.
def ARC_ASL_b_limm : ARCompactInst32_2op<0b00100, 0b000000, "asl",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "asl\t$rb, $limm", []> {
  // Opcode: 0x202F0F80, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000000;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f> 0,limm 0010011000101111F111111110000000.
def ARC_ASL_z_limm : ARCompactInst32_2op<0b00100, 0b000000, "asl",
    (outs ), (ins i32imm:$limm),
    "asl\t$limm", []> {
  // Opcode: 0x262F7F80, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110000000;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f> a,limm,c 0010111000000000F111CCCCCCAAAAAA.
def ARC_ASL_a_limm_c : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "asl\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E007000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f> a,b,limm 00101bbb00000000FBBB111110AAAAAA.
def ARC_ASL_a_b_limm : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "asl\t$ra, $rb, $limm", []> {
  // Opcode: 0x28000F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f> 0,limm,c 0010111000000000F111CCCCCC111110.
def ARC_ASL_z_limm_c : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "asl\t$limm, $rc", []> {
  // Opcode: 0x2E00703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f> 0,b,limm 00101bbb00000000FBBB111110111110.
def ARC_ASL_z_b_limm : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "asl\t$rb, $limm", []> {
  // Opcode: 0x28000FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f><.cc> b,b,limm 00101bbb11000000FBBB1111100QQQQQ.
def ARC_ASL_b_limm_cc : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "asl\t$rb, $limm", []> {
  // Opcode: 0x28C00F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f><.cc> 0,limm,c 0010111011000000F111CCCCCC0QQQQQ.
def ARC_ASL_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "asl\t$limm, $rc", []> {
  // Opcode: 0x2EC07000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f> a,limm,u6 0010111001000000F111uuuuuuAAAAAA.
def ARC_ASL_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asl\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E407000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f> 0,limm,u6 0010111001000000F111uuuuuu111110.
def ARC_ASL_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asl\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E40703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f><.cc> 0,limm,u6 0010111011000000F111uuuuuu1QQQQQ.
def ARC_ASL_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asl\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EC07020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f> 0,limm,s12 0010111010000000F111ssssssSSSSSS.
def ARC_ASL_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "asl\t$limm, $simm12_20", []> {
  // Opcode: 0x2E807000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010000000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f> a,limm,limm 0010111000000000F111111110AAAAAA.
def ARC_ASL_a_limm : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "asl\t$ra, $limm", []> {
  // Opcode: 0x2E007F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asl<.f> 0,limm,limm 0010111000000000F111111110111110.
def ARC_ASL_z_limm_v1 : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs ), (ins i32imm:$limm),
    "asl\t$limm", []> {
  // Opcode: 0x2E007FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// asl<.f><.cc> 0,limm,limm 0010111011000000F1111111100QQQQQ.
def ARC_ASL_z_limm_cc : ARCompactInst32_3op<0b00101, 0b000000, "asl",
    (outs ), (ins i32imm:$limm),
    "asl\t$limm", []> {
  // Opcode: 0x2EC07F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f> a,b,c 00101bbb00001010FBBBCCCCCCAAAAAA.
def ARC_ASLS_a_b_c : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "asls\t$ra, $rb, $rc", []> {
  // Opcode: 0x280A0000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// asls<.f> 0,b,c 00101bbb00001010FBBBCCCCCC111110.
def ARC_ASLS_z_b_c : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "asls\t$rb, $rc", []> {
  // Opcode: 0x280A003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asls<.f><.cc> b,b,c 00101bbb11001010FBBBCCCCCC0QQQQQ.
def ARC_ASLS_b_c_cc : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "asls\t$rb, $rc", []> {
  // Opcode: 0x28CA0000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asls<.f> a,b,u6 00101bbb01001010FBBBuuuuuuAAAAAA.
def ARC_ASLS_a_b_u6 : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "asls\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x284A0000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// asls<.f> 0,b,u6 00101bbb01001010FBBBuuuuuu111110.
def ARC_ASLS_z_b_u6 : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "asls\t$rb, $uimm6_20", []> {
  // Opcode: 0x284A003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asls<.f><.cc> b,b,u6 00101bbb11001010FBBBuuuuuu1QQQQQ.
def ARC_ASLS_b_u6_cc : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "asls\t$rb, $uimm6_20", []> {
  // Opcode: 0x28CA0020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asls<.f> b,b,s12 00101bbb10001010FBBBssssssSSSSSS.
def ARC_ASLS_b_s12 : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "asls\t$rb, $simm12_20", []> {
  // Opcode: 0x288A0000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10001010;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// asls<.f> a,limm,c 0010111000001010F111CCCCCCAAAAAA.
def ARC_ASLS_a_limm_c : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "asls\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E0A7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f> a,b,limm 00101bbb00001010FBBB111110AAAAAA.
def ARC_ASLS_a_b_limm : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "asls\t$ra, $rb, $limm", []> {
  // Opcode: 0x280A0F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f> 0,limm,c 0010111000001010F111CCCCCC111110.
def ARC_ASLS_z_limm_c : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "asls\t$limm, $rc", []> {
  // Opcode: 0x2E0A703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f> 0,b,limm 00101bbb00001010FBBB111110111110.
def ARC_ASLS_z_b_limm : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "asls\t$rb, $limm", []> {
  // Opcode: 0x280A0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001010;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f><.cc> b,b,limm 00101bbb11001010FBBB1111100QQQQQ.
def ARC_ASLS_b_limm_cc : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "asls\t$rb, $limm", []> {
  // Opcode: 0x28CA0F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f><.cc> 0,limm,c 0010111011001010F111CCCCCC0QQQQQ.
def ARC_ASLS_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "asls\t$limm, $rc", []> {
  // Opcode: 0x2ECA7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f> a,limm,u6 0010111001001010F111uuuuuuAAAAAA.
def ARC_ASLS_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asls\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E4A7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f> 0,limm,u6 0010111001001010F111uuuuuu111110.
def ARC_ASLS_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asls\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E4A703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f><.cc> 0,limm,u6 0010111011001010F111uuuuuu1QQQQQ.
def ARC_ASLS_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asls\t$limm, $uimm6_20", []> {
  // Opcode: 0x2ECA7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f> 0,limm,s12 0010111010001010F111ssssssSSSSSS.
def ARC_ASLS_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "asls\t$limm, $simm12_20", []> {
  // Opcode: 0x2E8A7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010001010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f> a,limm,limm 0010111000001010F111111110AAAAAA.
def ARC_ASLS_a_limm : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "asls\t$ra, $limm", []> {
  // Opcode: 0x2E0A7F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001010;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f> 0,limm,limm 0010111000001010F111111110111110.
def ARC_ASLS_z_limm : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs ), (ins i32imm:$limm),
    "asls\t$limm", []> {
  // Opcode: 0x2E0A7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001010;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asls<.f><.cc> 0,limm,limm 0010111011001010F1111111100QQQQQ.
def ARC_ASLS_z_limm_cc : ARCompactInst32_3op<0b00101, 0b001010, "asls",
    (outs ), (ins i32imm:$limm),
    "asls\t$limm", []> {
  // Opcode: 0x2ECA7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001010;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f> b,c 00100bbb00101111FBBBCCCCCC000001.
def ARC_ASR_b_c : ARCompactInst32_2op<0b00100, 0b000001, "asr",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "asr\t$rb, $rc", []> {
  // Opcode: 0x202F0001, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asr<.f> 0,c 0010011000101111F111CCCCCC000001.
def ARC_ASR_z_c : ARCompactInst32_2op<0b00100, 0b000001, "asr",
    (outs ), (ins GPR32:$rc),
    "asr\t$rc", []> {
  // Opcode: 0x262F7001, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000001;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asr<.f> a,b,c 00101bbb00000010FBBBCCCCCCAAAAAA.
def ARC_ASR_a_b_c : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "asr\t$ra, $rb, $rc", []> {
  // Opcode: 0x28020000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// asr<.f> 0,b,c 00101bbb00000010FBBBCCCCCC111110.
def ARC_ASR_z_b_c : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "asr\t$rb, $rc", []> {
  // Opcode: 0x2802003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asr<.f><.cc> b,b,c 00101bbb11000010FBBBCCCCCC0QQQQQ.
def ARC_ASR_b_c_cc : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "asr\t$rb, $rc", []> {
  // Opcode: 0x28C20000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asr<.f> b,u6 00100bbb01101111FBBBuuuuuu000001.
def ARC_ASR_b_u6 : ARCompactInst32_2op<0b00100, 0b000001, "asr",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "asr\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F0001, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asr<.f> 0,u6 0010011001101111F111uuuuuu000001.
def ARC_ASR_z_u6 : ARCompactInst32_2op<0b00100, 0b000001, "asr",
    (outs ), (ins u6imm:$uimm6_20),
    "asr\t$uimm6_20", []> {
  // Opcode: 0x266F7001, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000001;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asr<.f> a,b,u6 00101bbb01000010FBBBuuuuuuAAAAAA.
def ARC_ASR_a_b_u6 : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "asr\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x28420000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// asr<.f> 0,b,u6 00101bbb01000010FBBBuuuuuu111110.
def ARC_ASR_z_b_u6 : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "asr\t$rb, $uimm6_20", []> {
  // Opcode: 0x2842003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asr<.f><.cc> b,b,u6 00101bbb11000010FBBBuuuuuu1QQQQQ.
def ARC_ASR_b_u6_cc : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "asr\t$rb, $uimm6_20", []> {
  // Opcode: 0x28C20020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asr<.f> b,b,s12 00101bbb10000010FBBBssssssSSSSSS.
def ARC_ASR_b_s12 : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "asr\t$rb, $simm12_20", []> {
  // Opcode: 0x28820000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10000010;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// asr<.f> b,limm 00100bbb00101111FBBB111110000001.
def ARC_ASR_b_limm : ARCompactInst32_2op<0b00100, 0b000001, "asr",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "asr\t$rb, $limm", []> {
  // Opcode: 0x202F0F81, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000001;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f> 0,limm 0010011000101111F111111110000001.
def ARC_ASR_z_limm : ARCompactInst32_2op<0b00100, 0b000001, "asr",
    (outs ), (ins i32imm:$limm),
    "asr\t$limm", []> {
  // Opcode: 0x262F7F81, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110000001;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f> a,limm,c 0010111000000010F111CCCCCCAAAAAA.
def ARC_ASR_a_limm_c : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "asr\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E027000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f> a,b,limm 00101bbb00000010FBBB111110AAAAAA.
def ARC_ASR_a_b_limm : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "asr\t$ra, $rb, $limm", []> {
  // Opcode: 0x28020F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f> 0,limm,c 0010111000000010F111CCCCCC111110.
def ARC_ASR_z_limm_c : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "asr\t$limm, $rc", []> {
  // Opcode: 0x2E02703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f> 0,b,limm 00101bbb00000010FBBB111110111110.
def ARC_ASR_z_b_limm : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "asr\t$rb, $limm", []> {
  // Opcode: 0x28020FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000010;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f><.cc> b,b,limm 00101bbb11000010FBBB1111100QQQQQ.
def ARC_ASR_b_limm_cc : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "asr\t$rb, $limm", []> {
  // Opcode: 0x28C20F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f><.cc> 0,limm,c 0010111011000010F111CCCCCC0QQQQQ.
def ARC_ASR_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "asr\t$limm, $rc", []> {
  // Opcode: 0x2EC27000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f> a,limm,u6 0010111001000010F111uuuuuuAAAAAA.
def ARC_ASR_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asr\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E427000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f> 0,limm,u6 0010111001000010F111uuuuuu111110.
def ARC_ASR_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asr\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E42703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f><.cc> 0,limm,u6 0010111011000010F111uuuuuu1QQQQQ.
def ARC_ASR_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asr\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EC27020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f> 0,limm,s12 0010111010000010F111ssssssSSSSSS.
def ARC_ASR_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "asr\t$limm, $simm12_20", []> {
  // Opcode: 0x2E827000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010000010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f> a,limm,limm 0010111000000010F111111110AAAAAA.
def ARC_ASR_a_limm : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "asr\t$ra, $limm", []> {
  // Opcode: 0x2E027F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000010;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asr<.f> 0,limm,limm 0010111000000010F111111110111110.
def ARC_ASR_z_limm_v1 : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs ), (ins i32imm:$limm),
    "asr\t$limm", []> {
  // Opcode: 0x2E027FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000010;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// asr<.f><.cc> 0,limm,limm 0010111011000010F1111111100QQQQQ.
def ARC_ASR_z_limm_cc : ARCompactInst32_3op<0b00101, 0b000010, "asr",
    (outs ), (ins i32imm:$limm),
    "asr\t$limm", []> {
  // Opcode: 0x2EC27F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000010;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f> a,b,c 00101bbb00001011FBBBCCCCCCAAAAAA.
def ARC_ASRS_a_b_c : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "asrs\t$ra, $rb, $rc", []> {
  // Opcode: 0x280B0000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// asrs<.f> 0,b,c 00101bbb00001011FBBBCCCCCC111110.
def ARC_ASRS_z_b_c : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "asrs\t$rb, $rc", []> {
  // Opcode: 0x280B003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asrs<.f><.cc> b,b,c 00101bbb11001011FBBBCCCCCC0QQQQQ.
def ARC_ASRS_b_c_cc : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "asrs\t$rb, $rc", []> {
  // Opcode: 0x28CB0000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001011;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// asrs<.f> a,b,u6 00101bbb01001011FBBBuuuuuuAAAAAA.
def ARC_ASRS_a_b_u6 : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "asrs\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x284B0000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// asrs<.f> 0,b,u6 00101bbb01001011FBBBuuuuuu111110.
def ARC_ASRS_z_b_u6 : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "asrs\t$rb, $uimm6_20", []> {
  // Opcode: 0x284B003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asrs<.f><.cc> b,b,u6 00101bbb11001011FBBBuuuuuu1QQQQQ.
def ARC_ASRS_b_u6_cc : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "asrs\t$rb, $uimm6_20", []> {
  // Opcode: 0x28CB0020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001011;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// asrs<.f> b,b,s12 00101bbb10001011FBBBssssssSSSSSS.
def ARC_ASRS_b_s12 : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "asrs\t$rb, $simm12_20", []> {
  // Opcode: 0x288B0000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10001011;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// asrs<.f> a,limm,c 0010111000001011F111CCCCCCAAAAAA.
def ARC_ASRS_a_limm_c : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "asrs\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E0B7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f> a,b,limm 00101bbb00001011FBBB111110AAAAAA.
def ARC_ASRS_a_b_limm : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "asrs\t$ra, $rb, $limm", []> {
  // Opcode: 0x280B0F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001011;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f> 0,limm,c 0010111000001011F111CCCCCC111110.
def ARC_ASRS_z_limm_c : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "asrs\t$limm, $rc", []> {
  // Opcode: 0x2E0B703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f> 0,b,limm 00101bbb00001011FBBB111110111110.
def ARC_ASRS_z_b_limm : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "asrs\t$rb, $limm", []> {
  // Opcode: 0x280B0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001011;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f><.cc> b,b,limm 00101bbb11001011FBBB1111100QQQQQ.
def ARC_ASRS_b_limm_cc : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "asrs\t$rb, $limm", []> {
  // Opcode: 0x28CB0F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001011;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f><.cc> 0,limm,c 0010111011001011F111CCCCCC0QQQQQ.
def ARC_ASRS_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "asrs\t$limm, $rc", []> {
  // Opcode: 0x2ECB7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f> a,limm,u6 0010111001001011F111uuuuuuAAAAAA.
def ARC_ASRS_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asrs\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E4B7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f> 0,limm,u6 0010111001001011F111uuuuuu111110.
def ARC_ASRS_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asrs\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E4B703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f><.cc> 0,limm,u6 0010111011001011F111uuuuuu1QQQQQ.
def ARC_ASRS_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "asrs\t$limm, $uimm6_20", []> {
  // Opcode: 0x2ECB7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f> 0,limm,s12 0010111010001011F111ssssssSSSSSS.
def ARC_ASRS_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "asrs\t$limm, $simm12_20", []> {
  // Opcode: 0x2E8B7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010001011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f> a,limm,limm 0010111000001011F111111110AAAAAA.
def ARC_ASRS_a_limm : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "asrs\t$ra, $limm", []> {
  // Opcode: 0x2E0B7F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001011;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f> 0,limm,limm 0010111000001011F111111110111110.
def ARC_ASRS_z_limm : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs ), (ins i32imm:$limm),
    "asrs\t$limm", []> {
  // Opcode: 0x2E0B7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001011;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// asrs<.f><.cc> 0,limm,limm 0010111011001011F1111111100QQQQQ.
def ARC_ASRS_z_limm_cc : ARCompactInst32_3op<0b00101, 0b001011, "asrs",
    (outs ), (ins i32imm:$limm),
    "asrs\t$limm", []> {
  // Opcode: 0x2ECB7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001011;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// avgqb<.f> a,b,c 00110bbb00100011FBBBCCCCCCAAAAAA.
def ARC_AVGQB_a_b_c : ARCompactInst32_3op<0b00110, 0b100011, "avgqb",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "avgqb\t$ra, $rb, $rc", []> {
  // Opcode: 0x30230000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// avgqb<.f><.cc> b,b,c 00110bbb11100011FBBBCCCCCC0QQQQQ.
def ARC_AVGQB_b_c_cc : ARCompactInst32_3op<0b00110, 0b100011, "avgqb",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "avgqb\t$rb, $rc", []> {
  // Opcode: 0x30E30000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100011;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// avgqb<.f> a,b,u6 00110bbb01100011FBBBuuuuuuAAAAAA.
def ARC_AVGQB_a_b_u6 : ARCompactInst32_3op<0b00110, 0b100011, "avgqb",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "avgqb\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30630000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01100011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// avgqb<.f><.cc> b,b,u6 00110bbb11100011FBBBuuuuuu1QQQQQ.
def ARC_AVGQB_b_u6_cc : ARCompactInst32_3op<0b00110, 0b100011, "avgqb",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "avgqb\t$rb, $uimm6_20", []> {
  // Opcode: 0x30E30020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100011;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// avgqb<.f> b,b,s12 00110bbb10100011FBBBssssssSSSSSS.
def ARC_AVGQB_b_s12 : ARCompactInst32_3op<0b00110, 0b100011, "avgqb",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "avgqb\t$rb, $simm12_20", []> {
  // Opcode: 0x30A30000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10100011;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// avgqb<.f> a,limm,c 0011011000100011F111CCCCCCAAAAAA.
def ARC_AVGQB_a_limm_c : ARCompactInst32_3op<0b00110, 0b100011, "avgqb",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "avgqb\t$ra, $limm, $rc", []> {
  // Opcode: 0x36237000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000100011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// avgqb<.f> a,b,limm 00110bbb00100011FBBB111110AAAAAA.
def ARC_AVGQB_a_b_limm : ARCompactInst32_3op<0b00110, 0b100011, "avgqb",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "avgqb\t$ra, $rb, $limm", []> {
  // Opcode: 0x30230F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100011;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// avgqb<.f><.cc> b,b,limm 00110bbb11100011FBBB1111100QQQQQ.
def ARC_AVGQB_b_limm_cc : ARCompactInst32_3op<0b00110, 0b100011, "avgqb",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "avgqb\t$rb, $limm", []> {
  // Opcode: 0x30E30F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100011;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f> a,b,c 00100bbb00010000FBBBCCCCCCAAAAAA.
def ARC_BCLR_a_b_c : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "bclr\t$ra, $rb, $rc", []> {
  // Opcode: 0x20100000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// bclr<.f> 0,b,c 00100bbb00010000FBBBCCCCCC111110.
def ARC_BCLR_z_b_c : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "bclr\t$rb, $rc", []> {
  // Opcode: 0x2010003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// bclr<.f><.cc> b,b,c 00100bbb11010000FBBBCCCCCC0QQQQQ.
def ARC_BCLR_b_c_cc : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "bclr\t$rb, $rc", []> {
  // Opcode: 0x20D00000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// bclr<.f> a,b,u6 00100bbb01010000FBBBuuuuuuAAAAAA.
def ARC_BCLR_a_b_u6 : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "bclr\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20500000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// bclr<.f> 0,b,u6 00100bbb01010000FBBBuuuuuu111110.
def ARC_BCLR_z_b_u6 : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "bclr\t$rb, $uimm6_20", []> {
  // Opcode: 0x2050003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// bclr<.f><.cc> b,b,u6 00100bbb11010000FBBBuuuuuu1QQQQQ.
def ARC_BCLR_b_u6_cc : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "bclr\t$rb, $uimm6_20", []> {
  // Opcode: 0x20D00020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// bclr<.f> b,b,s12 00100bbb10010000FBBBssssssSSSSSS.
def ARC_BCLR_b_s12 : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "bclr\t$rb, $simm12_20", []> {
  // Opcode: 0x20900000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10010000;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// bclr<.f> a,limm,c 0010011000010000F111CCCCCCAAAAAA.
def ARC_BCLR_a_limm_c : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "bclr\t$ra, $limm, $rc", []> {
  // Opcode: 0x26107000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f> a,b,limm 00100bbb00010000FBBB111110AAAAAA.
def ARC_BCLR_a_b_limm : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "bclr\t$ra, $rb, $limm", []> {
  // Opcode: 0x20100F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f> 0,limm,c 0010011000010000F111CCCCCC111110.
def ARC_BCLR_z_limm_c : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "bclr\t$limm, $rc", []> {
  // Opcode: 0x2610703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f> 0,b,limm 00100bbb00010000FBBB111110111110.
def ARC_BCLR_z_b_limm : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "bclr\t$rb, $limm", []> {
  // Opcode: 0x20100FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f><.cc> b,b,limm 00100bbb11010000FBBB1111100QQQQQ.
def ARC_BCLR_b_limm_cc : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "bclr\t$rb, $limm", []> {
  // Opcode: 0x20D00F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f><.cc> 0,limm,c 0010011011010000F111CCCCCC0QQQQQ.
def ARC_BCLR_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "bclr\t$limm, $rc", []> {
  // Opcode: 0x26D07000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f> a,limm,u6 0010011001010000F111uuuuuuAAAAAA.
def ARC_BCLR_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bclr\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26507000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f> 0,limm,u6 0010011001010000F111uuuuuu111110.
def ARC_BCLR_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bclr\t$limm, $uimm6_20", []> {
  // Opcode: 0x2650703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f><.cc> 0,limm,u6 0010011011010000F111uuuuuu1QQQQQ.
def ARC_BCLR_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bclr\t$limm, $uimm6_20", []> {
  // Opcode: 0x26D07020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f> 0,limm,s12 0010011010010000F111ssssssSSSSSS.
def ARC_BCLR_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "bclr\t$limm, $simm12_20", []> {
  // Opcode: 0x26907000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010010000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f> a,limm,limm 0010011000010000F111111110AAAAAA.
def ARC_BCLR_a_limm : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "bclr\t$ra, $limm", []> {
  // Opcode: 0x26107F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f> 0,limm,limm 0010011000010000F111111110111110.
def ARC_BCLR_z_limm : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs ), (ins i32imm:$limm),
    "bclr\t$limm", []> {
  // Opcode: 0x26107FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bclr<.f><.cc> 0,limm,limm 0010011011010000F1111111100QQQQQ.
def ARC_BCLR_z_limm_cc : ARCompactInst32_3op<0b00100, 0b010000, "bclr",
    (outs ), (ins i32imm:$limm),
    "bclr\t$limm", []> {
  // Opcode: 0x26D07F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f> a,b,c 00100bbb00000110FBBBCCCCCCAAAAAA.
def ARC_BIC_a_b_c : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "bic\t$ra, $rb, $rc", []> {
  // Opcode: 0x20060000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// bic<.f> 0,b,c 00100bbb00000110FBBBCCCCCC111110.
def ARC_BIC_z_b_c : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "bic\t$rb, $rc", []> {
  // Opcode: 0x2006003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// bic<.f><.cc> b,b,c 00100bbb11000110FBBBCCCCCC0QQQQQ.
def ARC_BIC_b_c_cc : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "bic\t$rb, $rc", []> {
  // Opcode: 0x20C60000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000110;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// bic<.f> a,b,u6 00100bbb01000110FBBBuuuuuuAAAAAA.
def ARC_BIC_a_b_u6 : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "bic\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20460000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// bic<.f> 0,b,u6 00100bbb01000110FBBBuuuuuu111110.
def ARC_BIC_z_b_u6 : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "bic\t$rb, $uimm6_20", []> {
  // Opcode: 0x2046003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// bic<.f><.cc> b,b,u6 00100bbb11000110FBBBuuuuuu1QQQQQ.
def ARC_BIC_b_u6_cc : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "bic\t$rb, $uimm6_20", []> {
  // Opcode: 0x20C60020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000110;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// bic<.f> b,b,s12 00100bbb10000110FBBBssssssSSSSSS.
def ARC_BIC_b_s12 : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "bic\t$rb, $simm12_20", []> {
  // Opcode: 0x20860000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10000110;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// bic<.f> a,limm,c 0010011000000110F111CCCCCCAAAAAA.
def ARC_BIC_a_limm_c : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "bic\t$ra, $limm, $rc", []> {
  // Opcode: 0x26067000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f> a,b,limm 00100bbb00000110FBBB111110AAAAAA.
def ARC_BIC_a_b_limm : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "bic\t$ra, $rb, $limm", []> {
  // Opcode: 0x20060F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000110;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f> 0,limm,c 0010011000000110F111CCCCCC111110.
def ARC_BIC_z_limm_c : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "bic\t$limm, $rc", []> {
  // Opcode: 0x2606703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f> 0,b,limm 00100bbb00000110FBBB111110111110.
def ARC_BIC_z_b_limm : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "bic\t$rb, $limm", []> {
  // Opcode: 0x20060FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000110;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f><.cc> b,b,limm 00100bbb11000110FBBB1111100QQQQQ.
def ARC_BIC_b_limm_cc : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "bic\t$rb, $limm", []> {
  // Opcode: 0x20C60F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000110;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f><.cc> 0,limm,c 0010011011000110F111CCCCCC0QQQQQ.
def ARC_BIC_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "bic\t$limm, $rc", []> {
  // Opcode: 0x26C67000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f> a,limm,u6 0010011001000110F111uuuuuuAAAAAA.
def ARC_BIC_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bic\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26467000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f> 0,limm,u6 0010011001000110F111uuuuuu111110.
def ARC_BIC_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bic\t$limm, $uimm6_20", []> {
  // Opcode: 0x2646703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f><.cc> 0,limm,u6 0010011011000110F111uuuuuu1QQQQQ.
def ARC_BIC_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bic\t$limm, $uimm6_20", []> {
  // Opcode: 0x26C67020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f> 0,limm,s12 0010011010000110F111ssssssSSSSSS.
def ARC_BIC_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "bic\t$limm, $simm12_20", []> {
  // Opcode: 0x26867000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010000110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f> a,limm,limm 0010011000000110F111111110AAAAAA.
def ARC_BIC_a_limm : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "bic\t$ra, $limm", []> {
  // Opcode: 0x26067F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000110;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f> 0,limm,limm 0010011000000110F111111110111110.
def ARC_BIC_z_limm : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs ), (ins i32imm:$limm),
    "bic\t$limm", []> {
  // Opcode: 0x26067FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000110;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bic<.f><.cc> 0,limm,limm 0010011011000110F1111111100QQQQQ.
def ARC_BIC_z_limm_cc : ARCompactInst32_3op<0b00100, 0b000110, "bic",
    (outs ), (ins i32imm:$limm),
    "bic\t$limm", []> {
  // Opcode: 0x26C67F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000110;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f> a,b,c 00100bbb00010011FBBBCCCCCCAAAAAA.
def ARC_BMSK_a_b_c : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "bmsk\t$ra, $rb, $rc", []> {
  // Opcode: 0x20130000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// bmsk<.f> 0,b,c 00100bbb00010011FBBBCCCCCC111110.
def ARC_BMSK_z_b_c : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "bmsk\t$rb, $rc", []> {
  // Opcode: 0x2013003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// bmsk<.f><.cc> b,b,c 00100bbb11010011FBBBCCCCCC0QQQQQ.
def ARC_BMSK_b_c_cc : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "bmsk\t$rb, $rc", []> {
  // Opcode: 0x20D30000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010011;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// bmsk<.f> a,b,u6 00100bbb01010011FBBBuuuuuuAAAAAA.
def ARC_BMSK_a_b_u6 : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "bmsk\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20530000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// bmsk<.f> 0,b,u6 00100bbb01010011FBBBuuuuuu111110.
def ARC_BMSK_z_b_u6 : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "bmsk\t$rb, $uimm6_20", []> {
  // Opcode: 0x2053003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// bmsk<.f><.cc> b,b,u6 00100bbb11010011FBBBuuuuuu1QQQQQ.
def ARC_BMSK_b_u6_cc : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "bmsk\t$rb, $uimm6_20", []> {
  // Opcode: 0x20D30020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010011;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// bmsk<.f> b,b,s12 00100bbb10010011FBBBssssssSSSSSS.
def ARC_BMSK_b_s12 : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "bmsk\t$rb, $simm12_20", []> {
  // Opcode: 0x20930000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10010011;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// bmsk<.f> a,limm,c 0010011000010011F111CCCCCCAAAAAA.
def ARC_BMSK_a_limm_c : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "bmsk\t$ra, $limm, $rc", []> {
  // Opcode: 0x26137000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f> a,b,limm 00100bbb00010011FBBB111110AAAAAA.
def ARC_BMSK_a_b_limm : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "bmsk\t$ra, $rb, $limm", []> {
  // Opcode: 0x20130F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010011;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f> 0,limm,c 0010011000010011F111CCCCCC111110.
def ARC_BMSK_z_limm_c : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "bmsk\t$limm, $rc", []> {
  // Opcode: 0x2613703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f> 0,b,limm 00100bbb00010011FBBB111110111110.
def ARC_BMSK_z_b_limm : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "bmsk\t$rb, $limm", []> {
  // Opcode: 0x20130FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010011;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f><.cc> b,b,limm 00100bbb11010011FBBB1111100QQQQQ.
def ARC_BMSK_b_limm_cc : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "bmsk\t$rb, $limm", []> {
  // Opcode: 0x20D30F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010011;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f><.cc> 0,limm,c 0010011011010011F111CCCCCC0QQQQQ.
def ARC_BMSK_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "bmsk\t$limm, $rc", []> {
  // Opcode: 0x26D37000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f> a,limm,u6 0010011001010011F111uuuuuuAAAAAA.
def ARC_BMSK_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bmsk\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26537000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f> 0,limm,u6 0010011001010011F111uuuuuu111110.
def ARC_BMSK_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bmsk\t$limm, $uimm6_20", []> {
  // Opcode: 0x2653703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f><.cc> 0,limm,u6 0010011011010011F111uuuuuu1QQQQQ.
def ARC_BMSK_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bmsk\t$limm, $uimm6_20", []> {
  // Opcode: 0x26D37020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f> 0,limm,s12 0010011010010011F111ssssssSSSSSS.
def ARC_BMSK_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "bmsk\t$limm, $simm12_20", []> {
  // Opcode: 0x26937000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010010011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f> a,limm,limm 0010011000010011F111111110AAAAAA.
def ARC_BMSK_a_limm : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "bmsk\t$ra, $limm", []> {
  // Opcode: 0x26137F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010011;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f> 0,limm,limm 0010011000010011F111111110111110.
def ARC_BMSK_z_limm : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs ), (ins i32imm:$limm),
    "bmsk\t$limm", []> {
  // Opcode: 0x26137FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010011;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bmsk<.f><.cc> 0,limm,limm 0010011011010011F1111111100QQQQQ.
def ARC_BMSK_z_limm_cc : ARCompactInst32_3op<0b00100, 0b010011, "bmsk",
    (outs ), (ins i32imm:$limm),
    "bmsk\t$limm", []> {
  // Opcode: 0x26D37F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010011;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f> a,b,c 00100bbb00001111FBBBCCCCCCAAAAAA.
def ARC_BSET_a_b_c : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "bset\t$ra, $rb, $rc", []> {
  // Opcode: 0x200F0000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// bset<.f> 0,b,c 00100bbb00001111FBBBCCCCCC111110.
def ARC_BSET_z_b_c : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "bset\t$rb, $rc", []> {
  // Opcode: 0x200F003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// bset<.f><.cc> b,b,c 00100bbb11001111FBBBCCCCCC0QQQQQ.
def ARC_BSET_b_c_cc : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "bset\t$rb, $rc", []> {
  // Opcode: 0x20CF0000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// bset<.f> a,b,u6 00100bbb01001111FBBBuuuuuuAAAAAA.
def ARC_BSET_a_b_u6 : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "bset\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x204F0000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01001111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// bset<.f> 0,b,u6 00100bbb01001111FBBBuuuuuu111110.
def ARC_BSET_z_b_u6 : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "bset\t$rb, $uimm6_20", []> {
  // Opcode: 0x204F003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01001111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// bset<.f><.cc> b,b,u6 00100bbb11001111FBBBuuuuuu1QQQQQ.
def ARC_BSET_b_u6_cc : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "bset\t$rb, $uimm6_20", []> {
  // Opcode: 0x20CF0020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// bset<.f> b,b,s12 00100bbb10001111FBBBssssssSSSSSS.
def ARC_BSET_b_s12 : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "bset\t$rb, $simm12_20", []> {
  // Opcode: 0x208F0000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10001111;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// bset<.f> a,limm,c 0010011000001111F111CCCCCCAAAAAA.
def ARC_BSET_a_limm_c : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "bset\t$ra, $limm, $rc", []> {
  // Opcode: 0x260F7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f> a,b,limm 00100bbb00001111FBBB111110AAAAAA.
def ARC_BSET_a_b_limm : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "bset\t$ra, $rb, $limm", []> {
  // Opcode: 0x200F0F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001111;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f> 0,limm,c 0010011000001111F111CCCCCC111110.
def ARC_BSET_z_limm_c : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "bset\t$limm, $rc", []> {
  // Opcode: 0x260F703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f> 0,b,limm 00100bbb00001111FBBB111110111110.
def ARC_BSET_z_b_limm : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "bset\t$rb, $limm", []> {
  // Opcode: 0x200F0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001111;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f><.cc> b,b,limm 00100bbb11001111FBBB1111100QQQQQ.
def ARC_BSET_b_limm_cc : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "bset\t$rb, $limm", []> {
  // Opcode: 0x20CF0F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001111;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f><.cc> 0,limm,c 0010011011001111F111CCCCCC0QQQQQ.
def ARC_BSET_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "bset\t$limm, $rc", []> {
  // Opcode: 0x26CF7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f> a,limm,u6 0010011001001111F111uuuuuuAAAAAA.
def ARC_BSET_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bset\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x264F7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001001111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f> 0,limm,u6 0010011001001111F111uuuuuu111110.
def ARC_BSET_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bset\t$limm, $uimm6_20", []> {
  // Opcode: 0x264F703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001001111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f><.cc> 0,limm,u6 0010011011001111F111uuuuuu1QQQQQ.
def ARC_BSET_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bset\t$limm, $uimm6_20", []> {
  // Opcode: 0x26CF7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f> 0,limm,s12 0010011010001111F111ssssssSSSSSS.
def ARC_BSET_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "bset\t$limm, $simm12_20", []> {
  // Opcode: 0x268F7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010001111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f> a,limm,limm 0010011000001111F111111110AAAAAA.
def ARC_BSET_a_limm : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "bset\t$ra, $limm", []> {
  // Opcode: 0x260F7F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001111;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f> 0,limm,limm 0010011000001111F111111110111110.
def ARC_BSET_z_limm : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs ), (ins i32imm:$limm),
    "bset\t$limm", []> {
  // Opcode: 0x260F7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001111;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bset<.f><.cc> 0,limm,limm 0010011011001111F1111111100QQQQQ.
def ARC_BSET_z_limm_cc : ARCompactInst32_3op<0b00100, 0b001111, "bset",
    (outs ), (ins i32imm:$limm),
    "bset\t$limm", []> {
  // Opcode: 0x26CF7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001111;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// btst b,c 00100bbb000100011BBBCCCCCC000000.
//
// BTST is compare-like: B AND (1<<C) is computed but only STATUS32 is
// written (implicit F=1, per docs/isa/07-alu-32bit.md#BTST -- "The
// destination is always ignored and the instruction result is always
// discarded"). The auto-generator modeled $rb as a GPR32 def (bogus --
// binutils' operand table doesn't distinguish def/use), which made the
// instruction unselectable/unverifiable. Moved $rb into (ins); this is
// byte-identical at the encoding level (`bits<6> rb` binds by name
// regardless of outs/ins list membership) and only changes
// SelectionDAG/MachineInstr def/use bookkeeping. See dossier 24.
def ARC_BTST_b_c : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs), (ins GPR32:$rb, GPR32:$rc),
    "btst\t$rb, $rc", []> {
  // Opcode: 0x20118000, Mask: 0xF8FF803F
  // Operands: RB, RC
  // Flags: none (no optional .f toggle bit -- always writes flags, see above)
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b000100011;
  let Inst{5-0} = 0b000000;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst<.cc> b,c 00100bbb110100011BBBCCCCCC0QQQQQ.
def ARC_BTST_b_c_cc : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs), (ins GPR32:$rb, GPR32:$rc),
    "btst\t$rb, $rc", []> {
  // Opcode: 0x20D18000, Mask: 0xF8FF8020
  // Operands: RB, RC
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110100011;
  let Inst{5} = 0;
  let isPredicable = 1;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst b,u6 00100bbb010100011BBBuuuuuu000000.
def ARC_BTST_b_u6 : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs), (ins GPR32:$rb, u6imm:$uimm6_20),
    "btst\t$rb, $uimm6_20", []> {
  // Opcode: 0x20518000, Mask: 0xF8FF803F
  // Operands: RB, UIMM6_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b010100011;
  let Inst{5-0} = 0b000000;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst<.cc> b,u6 00100bbb110100011BBBuuuuuu1QQQQQ.
def ARC_BTST_b_u6_cc : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs), (ins GPR32:$rb, u6imm:$uimm6_20),
    "btst\t$rb, $uimm6_20", []> {
  // Opcode: 0x20D18020, Mask: 0xF8FF8020
  // Operands: RB, UIMM6_20
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110100011;
  let Inst{5} = 1;
  let isPredicable = 1;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst b,s12 00100bbb100100011BBBssssssSSSSSS.
def ARC_BTST_b_s12 : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs), (ins GPR32:$rb, s12imm:$simm12_20),
    "btst\t$rb, $simm12_20", []> {
  // Opcode: 0x20918000, Mask: 0xF8FF8000
  // Operands: RB, SIMM12_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b100100011;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst limm,c 00100110000100011111CCCCCC000000.
def ARC_BTST_limm_c : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "btst\t$limm, $rc", []> {
  // Opcode: 0x2611F000, Mask: 0xFFFFF03F
  // Operands: LIMM, RC
  // Flags: none
  let Inst{31-12} = 0b00100110000100011111;
  let Inst{5-0} = 0b000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst b,limm 00100bbb000100011BBB111110000000.
def ARC_BTST_b_limm : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs), (ins GPR32:$rb, i32imm:$limm),
    "btst\t$rb, $limm", []> {
  // Opcode: 0x20118F80, Mask: 0xF8FF8FFF
  // Operands: RB, LIMM
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b000100011;
  let Inst{11-0} = 0b111110000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst<.cc> b,limm 00100bbb110100011BBB1111100QQQQQ.
def ARC_BTST_b_limm_cc : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs), (ins GPR32:$rb, i32imm:$limm),
    "btst\t$rb, $limm", []> {
  // Opcode: 0x20D18F80, Mask: 0xF8FF8FE0
  // Operands: RB, LIMM
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110100011;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst<.cc> limm,c 00100110110100011111CCCCCC0QQQQQ.
def ARC_BTST_limm_c_cc : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "btst\t$limm, $rc", []> {
  // Opcode: 0x26D1F000, Mask: 0xFFFFF020
  // Operands: LIMM, RC
  // Flags: C_CC
  let Inst{31-12} = 0b00100110110100011111;
  let Inst{5} = 0;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst limm,u6 00100110010100011111uuuuuu000000.
def ARC_BTST_limm_u6 : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "btst\t$limm, $uimm6_20", []> {
  // Opcode: 0x2651F000, Mask: 0xFFFFF03F
  // Operands: LIMM, UIMM6_20
  // Flags: none
  let Inst{31-12} = 0b00100110010100011111;
  let Inst{5-0} = 0b000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst<.cc> limm,u6 00100110110100011111uuuuuu1QQQQQ.
def ARC_BTST_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "btst\t$limm, $uimm6_20", []> {
  // Opcode: 0x26D1F020, Mask: 0xFFFFF020
  // Operands: LIMM, UIMM6_20
  // Flags: C_CC
  let Inst{31-12} = 0b00100110110100011111;
  let Inst{5} = 1;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst limm,s12 00100110100100011111ssssssSSSSSS.
def ARC_BTST_limm_s12 : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "btst\t$limm, $simm12_20", []> {
  // Opcode: 0x2691F000, Mask: 0xFFFFF000
  // Operands: LIMM, SIMM12_20
  // Flags: none
  let Inst{31-12} = 0b00100110100100011111;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst limm,limm 00100110000100011111111110000000.
def ARC_BTST_limm : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs ), (ins i32imm:$limm),
    "btst\t$limm", []> {
  // Opcode: 0x2611FF80, Mask: 0xFFFFFFFF
  // Operands: LIMM, LIMMdup
  // Flags: none
  let Inst{31-0} = 0b00100110000100011111111110000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// btst<.cc> limm,limm 001001101101000111111111100QQQQQ.
def ARC_BTST_limm_cc : ARCompactInst32_3op<0b00100, 0b010001, "btst",
    (outs ), (ins i32imm:$limm),
    "btst\t$limm", []> {
  // Opcode: 0x26D1FF80, Mask: 0xFFFFFFE0
  // Operands: LIMM, LIMMdup
  // Flags: C_CC
  let Inst{31-5} = 0b001001101101000111111111100;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
  let isCompare = 1;
  let Defs = [STATUS32];
}

// bxor<.f> a,b,c 00100bbb00010010FBBBCCCCCCAAAAAA.
def ARC_BXOR_a_b_c : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "bxor\t$ra, $rb, $rc", []> {
  // Opcode: 0x20120000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// bxor<.f> 0,b,c 00100bbb00010010FBBBCCCCCC111110.
def ARC_BXOR_z_b_c : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "bxor\t$rb, $rc", []> {
  // Opcode: 0x2012003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// bxor<.f><.cc> b,b,c 00100bbb11010010FBBBCCCCCC0QQQQQ.
def ARC_BXOR_b_c_cc : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "bxor\t$rb, $rc", []> {
  // Opcode: 0x20D20000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// bxor<.f> a,b,u6 00100bbb01010010FBBBuuuuuuAAAAAA.
def ARC_BXOR_a_b_u6 : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "bxor\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20520000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// bxor<.f> 0,b,u6 00100bbb01010010FBBBuuuuuu111110.
def ARC_BXOR_z_b_u6 : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "bxor\t$rb, $uimm6_20", []> {
  // Opcode: 0x2052003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// bxor<.f><.cc> b,b,u6 00100bbb11010010FBBBuuuuuu1QQQQQ.
def ARC_BXOR_b_u6_cc : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "bxor\t$rb, $uimm6_20", []> {
  // Opcode: 0x20D20020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// bxor<.f> b,b,s12 00100bbb10010010FBBBssssssSSSSSS.
def ARC_BXOR_b_s12 : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "bxor\t$rb, $simm12_20", []> {
  // Opcode: 0x20920000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10010010;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// bxor<.f> a,limm,c 0010011000010010F111CCCCCCAAAAAA.
def ARC_BXOR_a_limm_c : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "bxor\t$ra, $limm, $rc", []> {
  // Opcode: 0x26127000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f> a,b,limm 00100bbb00010010FBBB111110AAAAAA.
def ARC_BXOR_a_b_limm : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "bxor\t$ra, $rb, $limm", []> {
  // Opcode: 0x20120F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f> 0,limm,c 0010011000010010F111CCCCCC111110.
def ARC_BXOR_z_limm_c : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "bxor\t$limm, $rc", []> {
  // Opcode: 0x2612703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f> 0,b,limm 00100bbb00010010FBBB111110111110.
def ARC_BXOR_z_b_limm : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "bxor\t$rb, $limm", []> {
  // Opcode: 0x20120FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010010;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f><.cc> b,b,limm 00100bbb11010010FBBB1111100QQQQQ.
def ARC_BXOR_b_limm_cc : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "bxor\t$rb, $limm", []> {
  // Opcode: 0x20D20F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f><.cc> 0,limm,c 0010011011010010F111CCCCCC0QQQQQ.
def ARC_BXOR_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "bxor\t$limm, $rc", []> {
  // Opcode: 0x26D27000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f> a,limm,u6 0010011001010010F111uuuuuuAAAAAA.
def ARC_BXOR_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bxor\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26527000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f> 0,limm,u6 0010011001010010F111uuuuuu111110.
def ARC_BXOR_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bxor\t$limm, $uimm6_20", []> {
  // Opcode: 0x2652703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f><.cc> 0,limm,u6 0010011011010010F111uuuuuu1QQQQQ.
def ARC_BXOR_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "bxor\t$limm, $uimm6_20", []> {
  // Opcode: 0x26D27020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f> 0,limm,s12 0010011010010010F111ssssssSSSSSS.
def ARC_BXOR_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "bxor\t$limm, $simm12_20", []> {
  // Opcode: 0x26927000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010010010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f> a,limm,limm 0010011000010010F111111110AAAAAA.
def ARC_BXOR_a_limm : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "bxor\t$ra, $limm", []> {
  // Opcode: 0x26127F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010010;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f> 0,limm,limm 0010011000010010F111111110111110.
def ARC_BXOR_z_limm : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs ), (ins i32imm:$limm),
    "bxor\t$limm", []> {
  // Opcode: 0x26127FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010010;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// bxor<.f><.cc> 0,limm,limm 0010011011010010F1111111100QQQQQ.
def ARC_BXOR_z_limm_cc : ARCompactInst32_3op<0b00100, 0b010010, "bxor",
    (outs ), (ins i32imm:$limm),
    "bxor\t$limm", []> {
  // Opcode: 0x26D27F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010010;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// clamp<.f> a,b,c 00110bbb00101010FBBBCCCCCCAAAAAA.
def ARC_CLAMP_a_b_c : ARCompactInst32_3op<0b00110, 0b101010, "clamp",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "clamp\t$ra, $rb, $rc", []> {
  // Opcode: 0x302A0000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00101010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// clamp<.f><.cc> b,b,c 00110bbb11101010FBBBCCCCCC0QQQQQ.
def ARC_CLAMP_b_c_cc : ARCompactInst32_3op<0b00110, 0b101010, "clamp",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "clamp\t$rb, $rc", []> {
  // Opcode: 0x30EA0000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11101010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// clamp<.f> a,b,u6 00110bbb01101010FBBBuuuuuuAAAAAA.
def ARC_CLAMP_a_b_u6 : ARCompactInst32_3op<0b00110, 0b101010, "clamp",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "clamp\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x306A0000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01101010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// clamp<.f><.cc> b,b,u6 00110bbb11101010FBBBuuuuuu1QQQQQ.
def ARC_CLAMP_b_u6_cc : ARCompactInst32_3op<0b00110, 0b101010, "clamp",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "clamp\t$rb, $uimm6_20", []> {
  // Opcode: 0x30EA0020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11101010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// clamp<.f> b,b,s12 00110bbb10101010FBBBssssssSSSSSS.
def ARC_CLAMP_b_s12 : ARCompactInst32_3op<0b00110, 0b101010, "clamp",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "clamp\t$rb, $simm12_20", []> {
  // Opcode: 0x30AA0000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10101010;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// clamp<.f> a,limm,c 0011011000101010F111CCCCCCAAAAAA.
def ARC_CLAMP_a_limm_c : ARCompactInst32_3op<0b00110, 0b101010, "clamp",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "clamp\t$ra, $limm, $rc", []> {
  // Opcode: 0x362A7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000101010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// clamp<.f> a,b,limm 00110bbb00101010FBBB111110AAAAAA.
def ARC_CLAMP_a_b_limm : ARCompactInst32_3op<0b00110, 0b101010, "clamp",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "clamp\t$ra, $rb, $limm", []> {
  // Opcode: 0x302A0F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00101010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// clamp<.f><.cc> b,b,limm 00110bbb11101010FBBB1111100QQQQQ.
def ARC_CLAMP_b_limm_cc : ARCompactInst32_3op<0b00110, 0b101010, "clamp",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "clamp\t$rb, $limm", []> {
  // Opcode: 0x30EA0F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11101010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// cmp b,c 00100bbb000011001BBBCCCCCC000000.
def ARC_CMP_b_c : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "cmp\t$rb, $rc", []> {
  // Opcode: 0x200C8000, Mask: 0xF8FF803F
  // Operands: RB, RC
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b000011001;
  let Inst{5-0} = 0b000000;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// cmp<.cc> b,c 00100bbb110011001BBBCCCCCC0QQQQQ.
def ARC_CMP_b_c_cc : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "cmp\t$rb, $rc", []> {
  // Opcode: 0x20CC8000, Mask: 0xF8FF8020
  // Operands: RB, RC
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110011001;
  let Inst{5} = 0;
  let isPredicable = 1;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// cmp b,u6 00100bbb010011001BBBuuuuuu000000.
def ARC_CMP_b_u6 : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "cmp\t$rb, $uimm6_20", []> {
  // Opcode: 0x204C8000, Mask: 0xF8FF803F
  // Operands: RB, UIMM6_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b010011001;
  let Inst{5-0} = 0b000000;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// cmp<.cc> b,u6 00100bbb110011001BBBuuuuuu1QQQQQ.
def ARC_CMP_b_u6_cc : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "cmp\t$rb, $uimm6_20", []> {
  // Opcode: 0x20CC8020, Mask: 0xF8FF8020
  // Operands: RB, UIMM6_20
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110011001;
  let Inst{5} = 1;
  let isPredicable = 1;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// cmp b,s12 00100bbb100011001BBBssssssSSSSSS.
def ARC_CMP_b_s12 : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "cmp\t$rb, $simm12_20", []> {
  // Opcode: 0x208C8000, Mask: 0xF8FF8000
  // Operands: RB, SIMM12_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b100011001;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// cmp limm,c 00100110000011001111CCCCCC000000.
def ARC_CMP_limm_c : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "cmp\t$limm, $rc", []> {
  // Opcode: 0x260CF000, Mask: 0xFFFFF03F
  // Operands: LIMM, RC
  // Flags: none
  let Inst{31-12} = 0b00100110000011001111;
  let Inst{5-0} = 0b000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// cmp b,limm 00100bbb000011001BBB111110000000.
def ARC_CMP_b_limm : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "cmp\t$rb, $limm", []> {
  // Opcode: 0x200C8F80, Mask: 0xF8FF8FFF
  // Operands: RB, LIMM
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b000011001;
  let Inst{11-0} = 0b111110000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// cmp<.cc> b,limm 00100bbb110011001BBB1111100QQQQQ.
def ARC_CMP_b_limm_cc : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "cmp\t$rb, $limm", []> {
  // Opcode: 0x20CC8F80, Mask: 0xF8FF8FE0
  // Operands: RB, LIMM
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110011001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// cmp<.cc> limm,c 00100110110011001111CCCCCC0QQQQQ.
def ARC_CMP_limm_c_cc : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "cmp\t$limm, $rc", []> {
  // Opcode: 0x26CCF000, Mask: 0xFFFFF020
  // Operands: LIMM, RC
  // Flags: C_CC
  let Inst{31-12} = 0b00100110110011001111;
  let Inst{5} = 0;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// cmp limm,u6 00100110010011001111uuuuuu000000.
def ARC_CMP_limm_u6 : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "cmp\t$limm, $uimm6_20", []> {
  // Opcode: 0x264CF000, Mask: 0xFFFFF03F
  // Operands: LIMM, UIMM6_20
  // Flags: none
  let Inst{31-12} = 0b00100110010011001111;
  let Inst{5-0} = 0b000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// cmp<.cc> limm,u6 00100110110011001111uuuuuu1QQQQQ.
def ARC_CMP_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "cmp\t$limm, $uimm6_20", []> {
  // Opcode: 0x26CCF020, Mask: 0xFFFFF020
  // Operands: LIMM, UIMM6_20
  // Flags: C_CC
  let Inst{31-12} = 0b00100110110011001111;
  let Inst{5} = 1;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// cmp limm,s12 00100110100011001111ssssssSSSSSS.
def ARC_CMP_limm_s12 : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "cmp\t$limm, $simm12_20", []> {
  // Opcode: 0x268CF000, Mask: 0xFFFFF000
  // Operands: LIMM, SIMM12_20
  // Flags: none
  let Inst{31-12} = 0b00100110100011001111;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// cmp limm,limm 00100110000011001111111110000000.
def ARC_CMP_limm : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs ), (ins i32imm:$limm),
    "cmp\t$limm", []> {
  // Opcode: 0x260CFF80, Mask: 0xFFFFFFFF
  // Operands: LIMM, LIMMdup
  // Flags: none
  let Inst{31-0} = 0b00100110000011001111111110000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// cmp<.cc> limm,limm 001001101100110011111111100QQQQQ.
def ARC_CMP_limm_cc : ARCompactInst32_3op<0b00100, 0b001100, "cmp",
    (outs ), (ins i32imm:$limm),
    "cmp\t$limm", []> {
  // Opcode: 0x26CCFF80, Mask: 0xFFFFFFE0
  // Operands: LIMM, LIMMdup
  // Flags: C_CC
  let Inst{31-5} = 0b001001101100110011111111100;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f> a,b,c 00101bbb00001000FBBBCCCCCCAAAAAA.
def ARC_DIVAW_a_b_c : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "divaw\t$ra, $rb, $rc", []> {
  // Opcode: 0x28080000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// divaw<.f> 0,b,c 00101bbb00001000FBBBCCCCCC111110.
def ARC_DIVAW_z_b_c : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "divaw\t$rb, $rc", []> {
  // Opcode: 0x2808003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// divaw<.f><.cc> b,b,c 00101bbb11001000FBBBCCCCCC0QQQQQ.
def ARC_DIVAW_b_c_cc : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "divaw\t$rb, $rc", []> {
  // Opcode: 0x28C80000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// divaw<.f> a,b,u6 00101bbb01001000FBBBuuuuuuAAAAAA.
def ARC_DIVAW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "divaw\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x28480000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// divaw<.f> 0,b,u6 00101bbb01001000FBBBuuuuuu111110.
def ARC_DIVAW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "divaw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2848003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// divaw<.f><.cc> b,b,u6 00101bbb11001000FBBBuuuuuu1QQQQQ.
def ARC_DIVAW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "divaw\t$rb, $uimm6_20", []> {
  // Opcode: 0x28C80020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// divaw<.f> b,b,s12 00101bbb10001000FBBBssssssSSSSSS.
def ARC_DIVAW_b_s12 : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "divaw\t$rb, $simm12_20", []> {
  // Opcode: 0x28880000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10001000;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// divaw<.f> a,limm,c 0010111000001000F111CCCCCCAAAAAA.
def ARC_DIVAW_a_limm_c : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "divaw\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E087000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f> a,b,limm 00101bbb00001000FBBB111110AAAAAA.
def ARC_DIVAW_a_b_limm : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "divaw\t$ra, $rb, $limm", []> {
  // Opcode: 0x28080F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f> 0,limm,c 0010111000001000F111CCCCCC111110.
def ARC_DIVAW_z_limm_c : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "divaw\t$limm, $rc", []> {
  // Opcode: 0x2E08703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f> 0,b,limm 00101bbb00001000FBBB111110111110.
def ARC_DIVAW_z_b_limm : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "divaw\t$rb, $limm", []> {
  // Opcode: 0x28080FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f><.cc> b,b,limm 00101bbb11001000FBBB1111100QQQQQ.
def ARC_DIVAW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "divaw\t$rb, $limm", []> {
  // Opcode: 0x28C80F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f><.cc> 0,limm,c 0010111011001000F111CCCCCC0QQQQQ.
def ARC_DIVAW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "divaw\t$limm, $rc", []> {
  // Opcode: 0x2EC87000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f> a,limm,u6 0010111001001000F111uuuuuuAAAAAA.
def ARC_DIVAW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "divaw\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E487000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f> 0,limm,u6 0010111001001000F111uuuuuu111110.
def ARC_DIVAW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "divaw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E48703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f><.cc> 0,limm,u6 0010111011001000F111uuuuuu1QQQQQ.
def ARC_DIVAW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "divaw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EC87020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f> 0,limm,s12 0010111010001000F111ssssssSSSSSS.
def ARC_DIVAW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "divaw\t$limm, $simm12_20", []> {
  // Opcode: 0x2E887000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010001000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f> a,limm,limm 0010111000001000F111111110AAAAAA.
def ARC_DIVAW_a_limm : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "divaw\t$ra, $limm", []> {
  // Opcode: 0x2E087F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f> 0,limm,limm 0010111000001000F111111110111110.
def ARC_DIVAW_z_limm : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs ), (ins i32imm:$limm),
    "divaw\t$limm", []> {
  // Opcode: 0x2E087FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// divaw<.f><.cc> 0,limm,limm 0010111011001000F1111111100QQQQQ.
def ARC_DIVAW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b001000, "divaw",
    (outs ), (ins i32imm:$limm),
    "divaw\t$limm", []> {
  // Opcode: 0x2EC87F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// extb<.f> b,c 00100bbb00101111FBBBCCCCCC000111.
def ARC_EXTB_b_c : ARCompactInst32_2op<0b00100, 0b000111, "extb",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "extb\t$rb, $rc", []> {
  // Opcode: 0x202F0007, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// extb<.f> 0,c 0010011000101111F111CCCCCC000111.
def ARC_EXTB_z_c : ARCompactInst32_2op<0b00100, 0b000111, "extb",
    (outs ), (ins GPR32:$rc),
    "extb\t$rc", []> {
  // Opcode: 0x262F7007, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000111;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// extb<.f> b,u6 00100bbb01101111FBBBuuuuuu000111.
def ARC_EXTB_b_u6 : ARCompactInst32_2op<0b00100, 0b000111, "extb",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "extb\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F0007, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// extb<.f> 0,u6 0010011001101111F111uuuuuu000111.
def ARC_EXTB_z_u6 : ARCompactInst32_2op<0b00100, 0b000111, "extb",
    (outs ), (ins u6imm:$uimm6_20),
    "extb\t$uimm6_20", []> {
  // Opcode: 0x266F7007, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000111;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// extb<.f> b,limm 00100bbb00101111FBBB111110000111.
def ARC_EXTB_b_limm : ARCompactInst32_2op<0b00100, 0b000111, "extb",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "extb\t$rb, $limm", []> {
  // Opcode: 0x202F0F87, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// extb<.f> 0,limm 0010011000101111F111111110000111.
def ARC_EXTB_z_limm : ARCompactInst32_2op<0b00100, 0b000111, "extb",
    (outs ), (ins i32imm:$limm),
    "extb\t$limm", []> {
  // Opcode: 0x262F7F87, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110000111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// extw<.f> b,c 00100bbb00101111FBBBCCCCCC001000.
def ARC_EXTW_b_c : ARCompactInst32_2op<0b00100, 0b001000, "extw",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "extw\t$rb, $rc", []> {
  // Opcode: 0x202F0008, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b001000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// extw<.f> 0,c 0010011000101111F111CCCCCC001000.
def ARC_EXTW_z_c : ARCompactInst32_2op<0b00100, 0b001000, "extw",
    (outs ), (ins GPR32:$rc),
    "extw\t$rc", []> {
  // Opcode: 0x262F7008, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001000;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// extw<.f> b,u6 00100bbb01101111FBBBuuuuuu001000.
def ARC_EXTW_b_u6 : ARCompactInst32_2op<0b00100, 0b001000, "extw",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "extw\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F0008, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b001000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// extw<.f> 0,u6 0010011001101111F111uuuuuu001000.
def ARC_EXTW_z_u6 : ARCompactInst32_2op<0b00100, 0b001000, "extw",
    (outs ), (ins u6imm:$uimm6_20),
    "extw\t$uimm6_20", []> {
  // Opcode: 0x266F7008, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001000;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// extw<.f> b,limm 00100bbb00101111FBBB111110001000.
def ARC_EXTW_b_limm : ARCompactInst32_2op<0b00100, 0b001000, "extw",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "extw\t$rb, $limm", []> {
  // Opcode: 0x202F0F88, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110001000;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// extw<.f> 0,limm 0010011000101111F111111110001000.
def ARC_EXTW_z_limm : ARCompactInst32_2op<0b00100, 0b001000, "extw",
    (outs ), (ins i32imm:$limm),
    "extw\t$limm", []> {
  // Opcode: 0x262F7F88, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110001000;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// fxtr<.f> a,b,c 00110bbb00100110FBBBCCCCCCAAAAAA.
def ARC_FXTR_a_b_c : ARCompactInst32_3op<0b00110, 0b100110, "fxtr",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "fxtr\t$ra, $rb, $rc", []> {
  // Opcode: 0x30260000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// fxtr<.f><.cc> b,b,c 00110bbb11100110FBBBCCCCCC0QQQQQ.
def ARC_FXTR_b_c_cc : ARCompactInst32_3op<0b00110, 0b100110, "fxtr",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "fxtr\t$rb, $rc", []> {
  // Opcode: 0x30E60000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100110;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// fxtr<.f> a,b,u6 00110bbb01100110FBBBuuuuuuAAAAAA.
def ARC_FXTR_a_b_u6 : ARCompactInst32_3op<0b00110, 0b100110, "fxtr",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "fxtr\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30660000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01100110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// fxtr<.f><.cc> b,b,u6 00110bbb11100110FBBBuuuuuu1QQQQQ.
def ARC_FXTR_b_u6_cc : ARCompactInst32_3op<0b00110, 0b100110, "fxtr",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "fxtr\t$rb, $uimm6_20", []> {
  // Opcode: 0x30E60020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100110;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// fxtr<.f> b,b,s12 00110bbb10100110FBBBssssssSSSSSS.
def ARC_FXTR_b_s12 : ARCompactInst32_3op<0b00110, 0b100110, "fxtr",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "fxtr\t$rb, $simm12_20", []> {
  // Opcode: 0x30A60000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10100110;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// fxtr<.f> a,limm,c 0011011000100110F111CCCCCCAAAAAA.
def ARC_FXTR_a_limm_c : ARCompactInst32_3op<0b00110, 0b100110, "fxtr",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "fxtr\t$ra, $limm, $rc", []> {
  // Opcode: 0x36267000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000100110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// fxtr<.f> a,b,limm 00110bbb00100110FBBB111110AAAAAA.
def ARC_FXTR_a_b_limm : ARCompactInst32_3op<0b00110, 0b100110, "fxtr",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "fxtr\t$ra, $rb, $limm", []> {
  // Opcode: 0x30260F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100110;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// fxtr<.f><.cc> b,b,limm 00110bbb11100110FBBB1111100QQQQQ.
def ARC_FXTR_b_limm_cc : ARCompactInst32_3op<0b00110, 0b100110, "fxtr",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "fxtr\t$rb, $limm", []> {
  // Opcode: 0x30E60F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100110;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// iaddr<.f> a,b,c 00110bbb00100111FBBBCCCCCCAAAAAA.
def ARC_IADDR_a_b_c : ARCompactInst32_3op<0b00110, 0b100111, "iaddr",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "iaddr\t$ra, $rb, $rc", []> {
  // Opcode: 0x30270000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// iaddr<.f><.cc> b,b,c 00110bbb11100111FBBBCCCCCC0QQQQQ.
def ARC_IADDR_b_c_cc : ARCompactInst32_3op<0b00110, 0b100111, "iaddr",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "iaddr\t$rb, $rc", []> {
  // Opcode: 0x30E70000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// iaddr<.f> a,b,u6 00110bbb01100111FBBBuuuuuuAAAAAA.
def ARC_IADDR_a_b_u6 : ARCompactInst32_3op<0b00110, 0b100111, "iaddr",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "iaddr\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30670000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01100111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// iaddr<.f><.cc> b,b,u6 00110bbb11100111FBBBuuuuuu1QQQQQ.
def ARC_IADDR_b_u6_cc : ARCompactInst32_3op<0b00110, 0b100111, "iaddr",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "iaddr\t$rb, $uimm6_20", []> {
  // Opcode: 0x30E70020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// iaddr<.f> b,b,s12 00110bbb10100111FBBBssssssSSSSSS.
def ARC_IADDR_b_s12 : ARCompactInst32_3op<0b00110, 0b100111, "iaddr",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "iaddr\t$rb, $simm12_20", []> {
  // Opcode: 0x30A70000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10100111;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// iaddr<.f> a,limm,c 0011011000100111F111CCCCCCAAAAAA.
def ARC_IADDR_a_limm_c : ARCompactInst32_3op<0b00110, 0b100111, "iaddr",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "iaddr\t$ra, $limm, $rc", []> {
  // Opcode: 0x36277000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000100111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// iaddr<.f> a,b,limm 00110bbb00100111FBBB111110AAAAAA.
def ARC_IADDR_a_b_limm : ARCompactInst32_3op<0b00110, 0b100111, "iaddr",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "iaddr\t$ra, $rb, $limm", []> {
  // Opcode: 0x30270F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100111;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// iaddr<.f><.cc> b,b,limm 00110bbb11100111FBBB1111100QQQQQ.
def ARC_IADDR_b_limm_cc : ARCompactInst32_3op<0b00110, 0b100111, "iaddr",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "iaddr\t$rb, $limm", []> {
  // Opcode: 0x30E70F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100111;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f> b,c 00100bbb00101111FBBBCCCCCC000010.
def ARC_LSR_b_c : ARCompactInst32_2op<0b00100, 0b000010, "lsr",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "lsr\t$rb, $rc", []> {
  // Opcode: 0x202F0002, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// lsr<.f> 0,c 0010011000101111F111CCCCCC000010.
def ARC_LSR_z_c : ARCompactInst32_2op<0b00100, 0b000010, "lsr",
    (outs ), (ins GPR32:$rc),
    "lsr\t$rc", []> {
  // Opcode: 0x262F7002, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000010;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// lsr<.f> a,b,c 00101bbb00000001FBBBCCCCCCAAAAAA.
def ARC_LSR_a_b_c : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "lsr\t$ra, $rb, $rc", []> {
  // Opcode: 0x28010000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// lsr<.f> 0,b,c 00101bbb00000001FBBBCCCCCC111110.
def ARC_LSR_z_b_c : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "lsr\t$rb, $rc", []> {
  // Opcode: 0x2801003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// lsr<.f><.cc> b,b,c 00101bbb11000001FBBBCCCCCC0QQQQQ.
def ARC_LSR_b_c_cc : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "lsr\t$rb, $rc", []> {
  // Opcode: 0x28C10000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// lsr<.f> b,u6 00100bbb01101111FBBBuuuuuu000010.
def ARC_LSR_b_u6 : ARCompactInst32_2op<0b00100, 0b000010, "lsr",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "lsr\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F0002, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// lsr<.f> 0,u6 0010011001101111F111uuuuuu000010.
def ARC_LSR_z_u6 : ARCompactInst32_2op<0b00100, 0b000010, "lsr",
    (outs ), (ins u6imm:$uimm6_20),
    "lsr\t$uimm6_20", []> {
  // Opcode: 0x266F7002, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000010;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// lsr<.f> a,b,u6 00101bbb01000001FBBBuuuuuuAAAAAA.
def ARC_LSR_a_b_u6 : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "lsr\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x28410000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// lsr<.f> 0,b,u6 00101bbb01000001FBBBuuuuuu111110.
def ARC_LSR_z_b_u6 : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "lsr\t$rb, $uimm6_20", []> {
  // Opcode: 0x2841003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// lsr<.f><.cc> b,b,u6 00101bbb11000001FBBBuuuuuu1QQQQQ.
def ARC_LSR_b_u6_cc : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "lsr\t$rb, $uimm6_20", []> {
  // Opcode: 0x28C10020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// lsr<.f> b,b,s12 00101bbb10000001FBBBssssssSSSSSS.
def ARC_LSR_b_s12 : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "lsr\t$rb, $simm12_20", []> {
  // Opcode: 0x28810000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10000001;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// lsr<.f> b,limm 00100bbb00101111FBBB111110000010.
def ARC_LSR_b_limm : ARCompactInst32_2op<0b00100, 0b000010, "lsr",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "lsr\t$rb, $limm", []> {
  // Opcode: 0x202F0F82, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000010;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f> 0,limm 0010011000101111F111111110000010.
def ARC_LSR_z_limm : ARCompactInst32_2op<0b00100, 0b000010, "lsr",
    (outs ), (ins i32imm:$limm),
    "lsr\t$limm", []> {
  // Opcode: 0x262F7F82, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110000010;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f> a,limm,c 0010111000000001F111CCCCCCAAAAAA.
def ARC_LSR_a_limm_c : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "lsr\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E017000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f> a,b,limm 00101bbb00000001FBBB111110AAAAAA.
def ARC_LSR_a_b_limm : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "lsr\t$ra, $rb, $limm", []> {
  // Opcode: 0x28010F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f> 0,limm,c 0010111000000001F111CCCCCC111110.
def ARC_LSR_z_limm_c : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "lsr\t$limm, $rc", []> {
  // Opcode: 0x2E01703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f> 0,b,limm 00101bbb00000001FBBB111110111110.
def ARC_LSR_z_b_limm : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "lsr\t$rb, $limm", []> {
  // Opcode: 0x28010FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f><.cc> b,b,limm 00101bbb11000001FBBB1111100QQQQQ.
def ARC_LSR_b_limm_cc : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "lsr\t$rb, $limm", []> {
  // Opcode: 0x28C10F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f><.cc> 0,limm,c 0010111011000001F111CCCCCC0QQQQQ.
def ARC_LSR_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "lsr\t$limm, $rc", []> {
  // Opcode: 0x2EC17000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f> a,limm,u6 0010111001000001F111uuuuuuAAAAAA.
def ARC_LSR_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "lsr\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E417000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f> 0,limm,u6 0010111001000001F111uuuuuu111110.
def ARC_LSR_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "lsr\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E41703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f><.cc> 0,limm,u6 0010111011000001F111uuuuuu1QQQQQ.
def ARC_LSR_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "lsr\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EC17020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f> 0,limm,s12 0010111010000001F111ssssssSSSSSS.
def ARC_LSR_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "lsr\t$limm, $simm12_20", []> {
  // Opcode: 0x2E817000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010000001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f> a,limm,limm 0010111000000001F111111110AAAAAA.
def ARC_LSR_a_limm : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "lsr\t$ra, $limm", []> {
  // Opcode: 0x2E017F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// lsr<.f> 0,limm,limm 0010111000000001F111111110111110.
def ARC_LSR_z_limm_v1 : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs ), (ins i32imm:$limm),
    "lsr\t$limm", []> {
  // Opcode: 0x2E017FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// lsr<.f><.cc> 0,limm,limm 0010111011000001F1111111100QQQQQ.
def ARC_LSR_z_limm_cc : ARCompactInst32_3op<0b00101, 0b000001, "lsr",
    (outs ), (ins i32imm:$limm),
    "lsr\t$limm", []> {
  // Opcode: 0x2EC17F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f> a,b,c 00100bbb00001000FBBBCCCCCCAAAAAA.
def ARC_MAX_a_b_c : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "max\t$ra, $rb, $rc", []> {
  // Opcode: 0x20080000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// max<.f> 0,b,c 00100bbb00001000FBBBCCCCCC111110.
def ARC_MAX_z_b_c : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "max\t$rb, $rc", []> {
  // Opcode: 0x2008003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// max<.f><.cc> b,b,c 00100bbb11001000FBBBCCCCCC0QQQQQ.
def ARC_MAX_b_c_cc : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "max\t$rb, $rc", []> {
  // Opcode: 0x20C80000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// max<.f> a,b,u6 00100bbb01001000FBBBuuuuuuAAAAAA.
def ARC_MAX_a_b_u6 : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "max\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20480000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01001000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// max<.f> 0,b,u6 00100bbb01001000FBBBuuuuuu111110.
def ARC_MAX_z_b_u6 : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "max\t$rb, $uimm6_20", []> {
  // Opcode: 0x2048003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01001000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// max<.f><.cc> b,b,u6 00100bbb11001000FBBBuuuuuu1QQQQQ.
def ARC_MAX_b_u6_cc : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "max\t$rb, $uimm6_20", []> {
  // Opcode: 0x20C80020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// max<.f> b,b,s12 00100bbb10001000FBBBssssssSSSSSS.
def ARC_MAX_b_s12 : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "max\t$rb, $simm12_20", []> {
  // Opcode: 0x20880000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10001000;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// max<.f> a,limm,c 0010011000001000F111CCCCCCAAAAAA.
def ARC_MAX_a_limm_c : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "max\t$ra, $limm, $rc", []> {
  // Opcode: 0x26087000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f> a,b,limm 00100bbb00001000FBBB111110AAAAAA.
def ARC_MAX_a_b_limm : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "max\t$ra, $rb, $limm", []> {
  // Opcode: 0x20080F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f> 0,limm,c 0010011000001000F111CCCCCC111110.
def ARC_MAX_z_limm_c : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "max\t$limm, $rc", []> {
  // Opcode: 0x2608703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f> 0,b,limm 00100bbb00001000FBBB111110111110.
def ARC_MAX_z_b_limm : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "max\t$rb, $limm", []> {
  // Opcode: 0x20080FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f><.cc> b,b,limm 00100bbb11001000FBBB1111100QQQQQ.
def ARC_MAX_b_limm_cc : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "max\t$rb, $limm", []> {
  // Opcode: 0x20C80F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f><.cc> 0,limm,c 0010011011001000F111CCCCCC0QQQQQ.
def ARC_MAX_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "max\t$limm, $rc", []> {
  // Opcode: 0x26C87000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f> a,limm,u6 0010011001001000F111uuuuuuAAAAAA.
def ARC_MAX_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "max\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26487000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001001000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f> 0,limm,u6 0010011001001000F111uuuuuu111110.
def ARC_MAX_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "max\t$limm, $uimm6_20", []> {
  // Opcode: 0x2648703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001001000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f><.cc> 0,limm,u6 0010011011001000F111uuuuuu1QQQQQ.
def ARC_MAX_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "max\t$limm, $uimm6_20", []> {
  // Opcode: 0x26C87020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f> 0,limm,s12 0010011010001000F111ssssssSSSSSS.
def ARC_MAX_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "max\t$limm, $simm12_20", []> {
  // Opcode: 0x26887000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010001000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f> a,limm,limm 0010011000001000F111111110AAAAAA.
def ARC_MAX_a_limm : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "max\t$ra, $limm", []> {
  // Opcode: 0x26087F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f> 0,limm,limm 0010011000001000F111111110111110.
def ARC_MAX_z_limm : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs ), (ins i32imm:$limm),
    "max\t$limm", []> {
  // Opcode: 0x26087FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// max<.f><.cc> 0,limm,limm 0010011011001000F1111111100QQQQQ.
def ARC_MAX_z_limm_cc : ARCompactInst32_3op<0b00100, 0b001000, "max",
    (outs ), (ins i32imm:$limm),
    "max\t$limm", []> {
  // Opcode: 0x26C87F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f> a,b,c 00100bbb00001001FBBBCCCCCCAAAAAA.
def ARC_MIN_a_b_c : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "min\t$ra, $rb, $rc", []> {
  // Opcode: 0x20090000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// min<.f> 0,b,c 00100bbb00001001FBBBCCCCCC111110.
def ARC_MIN_z_b_c : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "min\t$rb, $rc", []> {
  // Opcode: 0x2009003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// min<.f><.cc> b,b,c 00100bbb11001001FBBBCCCCCC0QQQQQ.
def ARC_MIN_b_c_cc : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "min\t$rb, $rc", []> {
  // Opcode: 0x20C90000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// min<.f> a,b,u6 00100bbb01001001FBBBuuuuuuAAAAAA.
def ARC_MIN_a_b_u6 : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "min\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20490000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01001001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// min<.f> 0,b,u6 00100bbb01001001FBBBuuuuuu111110.
def ARC_MIN_z_b_u6 : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "min\t$rb, $uimm6_20", []> {
  // Opcode: 0x2049003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01001001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// min<.f><.cc> b,b,u6 00100bbb11001001FBBBuuuuuu1QQQQQ.
def ARC_MIN_b_u6_cc : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "min\t$rb, $uimm6_20", []> {
  // Opcode: 0x20C90020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// min<.f> b,b,s12 00100bbb10001001FBBBssssssSSSSSS.
def ARC_MIN_b_s12 : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "min\t$rb, $simm12_20", []> {
  // Opcode: 0x20890000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10001001;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// min<.f> a,limm,c 0010011000001001F111CCCCCCAAAAAA.
def ARC_MIN_a_limm_c : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "min\t$ra, $limm, $rc", []> {
  // Opcode: 0x26097000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f> a,b,limm 00100bbb00001001FBBB111110AAAAAA.
def ARC_MIN_a_b_limm : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "min\t$ra, $rb, $limm", []> {
  // Opcode: 0x20090F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f> 0,limm,c 0010011000001001F111CCCCCC111110.
def ARC_MIN_z_limm_c : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "min\t$limm, $rc", []> {
  // Opcode: 0x2609703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f> 0,b,limm 00100bbb00001001FBBB111110111110.
def ARC_MIN_z_b_limm : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "min\t$rb, $limm", []> {
  // Opcode: 0x20090FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f><.cc> b,b,limm 00100bbb11001001FBBB1111100QQQQQ.
def ARC_MIN_b_limm_cc : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "min\t$rb, $limm", []> {
  // Opcode: 0x20C90F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f><.cc> 0,limm,c 0010011011001001F111CCCCCC0QQQQQ.
def ARC_MIN_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "min\t$limm, $rc", []> {
  // Opcode: 0x26C97000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f> a,limm,u6 0010011001001001F111uuuuuuAAAAAA.
def ARC_MIN_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "min\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26497000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001001001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f> 0,limm,u6 0010011001001001F111uuuuuu111110.
def ARC_MIN_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "min\t$limm, $uimm6_20", []> {
  // Opcode: 0x2649703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001001001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f><.cc> 0,limm,u6 0010011011001001F111uuuuuu1QQQQQ.
def ARC_MIN_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "min\t$limm, $uimm6_20", []> {
  // Opcode: 0x26C97020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f> 0,limm,s12 0010011010001001F111ssssssSSSSSS.
def ARC_MIN_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "min\t$limm, $simm12_20", []> {
  // Opcode: 0x26897000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010001001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f> a,limm,limm 0010011000001001F111111110AAAAAA.
def ARC_MIN_a_limm : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "min\t$ra, $limm", []> {
  // Opcode: 0x26097F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f> 0,limm,limm 0010011000001001F111111110111110.
def ARC_MIN_z_limm : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs ), (ins i32imm:$limm),
    "min\t$limm", []> {
  // Opcode: 0x26097FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// min<.f><.cc> 0,limm,limm 0010011011001001F1111111100QQQQQ.
def ARC_MIN_z_limm_cc : ARCompactInst32_3op<0b00100, 0b001001, "min",
    (outs ), (ins i32imm:$limm),
    "min\t$limm", []> {
  // Opcode: 0x26C97F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// mov<.f> b,c 00100bbb00001010FBBBCCCCCCRRRRRR.
def ARC_MOV_b_c : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "mov\t$rb, $rc", []> {
  // Opcode: 0x200A0000, Mask: 0xF8FF0000
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// mov<.f> 0,c 0010011000001010F111CCCCCCRRRRRR.
def ARC_MOV_z_c : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs ), (ins GPR32:$rc),
    "mov\t$rc", []> {
  // Opcode: 0x260A7000, Mask: 0xFFFF7000
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// mov<.f><.cc> b,c 00100bbb11001010FBBBCCCCCC0QQQQQ.
def ARC_MOV_b_c_cc : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "mov\t$rb, $rc", []> {
  // Opcode: 0x20CA0000, Mask: 0xF8FF0020
  // Operands: RB, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// mov<.f><.cc> 0,c 0010011011001010F111CCCCCC0QQQQQ.
def ARC_MOV_z_c_cc : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs ), (ins GPR32:$rc),
    "mov\t$rc", []> {
  // Opcode: 0x26CA7000, Mask: 0xFFFF7020
  // Operands: ZA, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// mov<.f> b,u6 00100bbb01001010FBBBuuuuuuRRRRRR.
def ARC_MOV_b_u6 : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "mov\t$rb, $uimm6_20", []> {
  // Opcode: 0x204A0000, Mask: 0xF8FF0000
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01001010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// mov<.f> 0,u6 0010011001001010F111uuuuuuRRRRRR.
def ARC_MOV_z_u6 : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs ), (ins u6imm:$uimm6_20),
    "mov\t$uimm6_20", []> {
  // Opcode: 0x264A7000, Mask: 0xFFFF7000
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001001010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// mov<.f><.cc> b,u6 00100bbb11001010FBBBuuuuuu1QQQQQ.
def ARC_MOV_b_u6_cc : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "mov\t$rb, $uimm6_20", []> {
  // Opcode: 0x20CA0020, Mask: 0xF8FF0020
  // Operands: RB, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// mov<.f><.cc> 0,u6 0010011011001010F111uuuuuu1QQQQQ.
def ARC_MOV_z_u6_cc : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs ), (ins u6imm:$uimm6_20),
    "mov\t$uimm6_20", []> {
  // Opcode: 0x26CA7020, Mask: 0xFFFF7020
  // Operands: ZA, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// mov<.f> b,s12 00100bbb10001010FBBBssssssSSSSSS.
def ARC_MOV_b_s12 : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "mov\t$rb, $simm12_20", []> {
  // Opcode: 0x208A0000, Mask: 0xF8FF0000
  // Operands: RB, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10001010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// mov<.f> 0,s12 0010011010001010F111ssssssSSSSSS.
def ARC_MOV_z_s12 : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs ), (ins s12imm:$simm12_20),
    "mov\t$simm12_20", []> {
  // Opcode: 0x268A7000, Mask: 0xFFFF7000
  // Operands: ZA, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010001010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// mov<.f> b,limm 00100bbb00001010FBBB111110RRRRRR.
def ARC_MOV_b_limm : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "mov\t$rb, $limm", []> {
  // Opcode: 0x200A0F80, Mask: 0xF8FF0FC0
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// mov<.f> 0,limm 0010011000001010F111111110RRRRRR.
def ARC_MOV_z_limm : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs ), (ins i32imm:$limm),
    "mov\t$limm", []> {
  // Opcode: 0x260A7F80, Mask: 0xFFFF7FC0
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001010;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// mov<.f><.cc> b,limm 00100bbb11001010FBBB1111100QQQQQ.
def ARC_MOV_b_limm_cc : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "mov\t$rb, $limm", []> {
  // Opcode: 0x20CA0F80, Mask: 0xF8FF0FE0
  // Operands: RB, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// mov<.f><.cc> 0,limm 0010011011001010F1111111100QQQQQ.
def ARC_MOV_z_limm_cc : ARCompactInst32_3op<0b00100, 0b001010, "mov",
    (outs ), (ins i32imm:$limm),
    "mov\t$limm", []> {
  // Opcode: 0x26CA7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001010;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// neg<.f> a,b 00100bbb01001110FBBB000000AAAAAA.
def ARC_NEG_a_b : ARCompactInst32_3op<0b00100, 0b001110, "neg",
    (outs GPR32:$ra), (ins GPR32:$rb),
    "neg\t$ra, $rb", []> {
  // Opcode: 0x204E0000, Mask: 0xF8FF0FC0
  // Operands: RA, RB
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01001110;
  let Inst{11-6} = 0b000000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> ra;
  let Inst{5-0} = ra;
}

// neg<.f> 0,b 00100bbb01001110FBBB000000111110.
def ARC_NEG_z_b : ARCompactInst32_3op<0b00100, 0b001110, "neg",
    (outs ), (ins GPR32:$rb),
    "neg\t$rb", []> {
  // Opcode: 0x204E0000, Mask: 0xF8FF0FFF
  // Operands: ZA, RB
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01001110;
  let Inst{11-0} = 0b000000000000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
}

// neg<.f><.cc> b,b 00100bbb11001110FBBB0000001QQQQQ.
def ARC_NEG_b_cc : ARCompactInst32_3op<0b00100, 0b001110, "neg",
    (outs GPR32:$rb), (ins ),
    "neg\t$rb", []> {
  // Opcode: 0x20CE0020, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001110;
  let Inst{11-5} = 0b0000001;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
}

// neg<.f> a,limm 0010011001001110F111000000AAAAAA.
def ARC_NEG_a_limm : ARCompactInst32_3op<0b00100, 0b001110, "neg",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "neg\t$ra, $limm", []> {
  // Opcode: 0x264E7000, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011001001110;
  let Inst{14-6} = 0b111000000;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// neg<.f><.cc> 0,limm 0010011011001110F1110000001QQQQQ.
def ARC_NEG_z_limm_cc : ARCompactInst32_3op<0b00100, 0b001110, "neg",
    (outs ), (ins i32imm:$limm),
    "neg\t$limm", []> {
  // Opcode: 0x26CE7020, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001110;
  let Inst{14-5} = 0b1110000001;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// negs<.f> b,c 00101bbb00101111FBBBCCCCCC000111.
def ARC_NEGS_b_c : ARCompactInst32_2op<0b00101, 0b000111, "negs",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "negs\t$rb, $rc", []> {
  // Opcode: 0x282F0007, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// negs<.f> 0,c 0010111000101111F111CCCCCC000111.
def ARC_NEGS_z_c : ARCompactInst32_2op<0b00101, 0b000111, "negs",
    (outs ), (ins GPR32:$rc),
    "negs\t$rc", []> {
  // Opcode: 0x2E2F7007, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000111;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// negs<.f> b,u6 00101bbb01101111FBBBuuuuuu000111.
def ARC_NEGS_b_u6 : ARCompactInst32_2op<0b00101, 0b000111, "negs",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "negs\t$rb, $uimm6_20", []> {
  // Opcode: 0x286F0007, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// negs<.f> 0,u6 0010111001101111F111uuuuuu000111.
def ARC_NEGS_z_u6 : ARCompactInst32_2op<0b00101, 0b000111, "negs",
    (outs ), (ins u6imm:$uimm6_20),
    "negs\t$uimm6_20", []> {
  // Opcode: 0x2E6F7007, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000111;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// negs<.f> b,limm 00101bbb00101111FBBB111110000111.
def ARC_NEGS_b_limm : ARCompactInst32_2op<0b00101, 0b000111, "negs",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "negs\t$rb, $limm", []> {
  // Opcode: 0x282F0F87, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// negs<.f> 0,limm 0010111000101111F111111110000111.
def ARC_NEGS_z_limm : ARCompactInst32_2op<0b00101, 0b000111, "negs",
    (outs ), (ins i32imm:$limm),
    "negs\t$limm", []> {
  // Opcode: 0x2E2F7F87, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-0} = 0b111111110000111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// negsw<.f> b,c 00101bbb00101111FBBBCCCCCC000110.
def ARC_NEGSW_b_c : ARCompactInst32_2op<0b00101, 0b000110, "negsw",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "negsw\t$rb, $rc", []> {
  // Opcode: 0x282F0006, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// negsw<.f> 0,c 0010111000101111F111CCCCCC000110.
def ARC_NEGSW_z_c : ARCompactInst32_2op<0b00101, 0b000110, "negsw",
    (outs ), (ins GPR32:$rc),
    "negsw\t$rc", []> {
  // Opcode: 0x2E2F7006, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000110;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// negsw<.f> b,u6 00101bbb01101111FBBBuuuuuu000110.
def ARC_NEGSW_b_u6 : ARCompactInst32_2op<0b00101, 0b000110, "negsw",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "negsw\t$rb, $uimm6_20", []> {
  // Opcode: 0x286F0006, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// negsw<.f> 0,u6 0010111001101111F111uuuuuu000110.
def ARC_NEGSW_z_u6 : ARCompactInst32_2op<0b00101, 0b000110, "negsw",
    (outs ), (ins u6imm:$uimm6_20),
    "negsw\t$uimm6_20", []> {
  // Opcode: 0x2E6F7006, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000110;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// negsw<.f> b,limm 00101bbb00101111FBBB111110000110.
def ARC_NEGSW_b_limm : ARCompactInst32_2op<0b00101, 0b000110, "negsw",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "negsw\t$rb, $limm", []> {
  // Opcode: 0x282F0F86, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// negsw<.f> 0,limm 0010111000101111F111111110000110.
def ARC_NEGSW_z_limm : ARCompactInst32_2op<0b00101, 0b000110, "negsw",
    (outs ), (ins i32imm:$limm),
    "negsw\t$limm", []> {
  // Opcode: 0x2E2F7F86, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-0} = 0b111111110000110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// norm<.f> b,c 00101bbb00101111FBBBCCCCCC000001.
def ARC_NORM_b_c : ARCompactInst32_2op<0b00101, 0b000001, "norm",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "norm\t$rb, $rc", []> {
  // Opcode: 0x282F0001, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// norm<.f> 0,c 0010111000101111F111CCCCCC000001.
def ARC_NORM_z_c : ARCompactInst32_2op<0b00101, 0b000001, "norm",
    (outs ), (ins GPR32:$rc),
    "norm\t$rc", []> {
  // Opcode: 0x2E2F7001, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000001;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// norm<.f> b,u6 00101bbb01101111FBBBuuuuuu000001.
def ARC_NORM_b_u6 : ARCompactInst32_2op<0b00101, 0b000001, "norm",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "norm\t$rb, $uimm6_20", []> {
  // Opcode: 0x286F0001, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// norm<.f> 0,u6 0010111001101111F111uuuuuu000001.
def ARC_NORM_z_u6 : ARCompactInst32_2op<0b00101, 0b000001, "norm",
    (outs ), (ins u6imm:$uimm6_20),
    "norm\t$uimm6_20", []> {
  // Opcode: 0x2E6F7001, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000001;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// norm<.f> b,limm 00101bbb00101111FBBB111110000001.
def ARC_NORM_b_limm : ARCompactInst32_2op<0b00101, 0b000001, "norm",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "norm\t$rb, $limm", []> {
  // Opcode: 0x282F0F81, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000001;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// norm<.f> 0,limm 0010111000101111F111111110000001.
def ARC_NORM_z_limm : ARCompactInst32_2op<0b00101, 0b000001, "norm",
    (outs ), (ins i32imm:$limm),
    "norm\t$limm", []> {
  // Opcode: 0x2E2F7F81, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-0} = 0b111111110000001;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// normw<.f> b,c 00101bbb00101111FBBBCCCCCC001000.
def ARC_NORMW_b_c : ARCompactInst32_2op<0b00101, 0b001000, "normw",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "normw\t$rb, $rc", []> {
  // Opcode: 0x282F0008, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b001000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// normw<.f> 0,c 0010111000101111F111CCCCCC001000.
def ARC_NORMW_z_c : ARCompactInst32_2op<0b00101, 0b001000, "normw",
    (outs ), (ins GPR32:$rc),
    "normw\t$rc", []> {
  // Opcode: 0x2E2F7008, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001000;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// normw<.f> b,u6 00101bbb01101111FBBBuuuuuu001000.
def ARC_NORMW_b_u6 : ARCompactInst32_2op<0b00101, 0b001000, "normw",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "normw\t$rb, $uimm6_20", []> {
  // Opcode: 0x286F0008, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b001000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// normw<.f> 0,u6 0010111001101111F111uuuuuu001000.
def ARC_NORMW_z_u6 : ARCompactInst32_2op<0b00101, 0b001000, "normw",
    (outs ), (ins u6imm:$uimm6_20),
    "normw\t$uimm6_20", []> {
  // Opcode: 0x2E6F7008, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001000;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// normw<.f> b,limm 00101bbb00101111FBBB111110001000.
def ARC_NORMW_b_limm : ARCompactInst32_2op<0b00101, 0b001000, "normw",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "normw\t$rb, $limm", []> {
  // Opcode: 0x282F0F88, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110001000;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// normw<.f> 0,limm 0010111000101111F111111110001000.
def ARC_NORMW_z_limm : ARCompactInst32_2op<0b00101, 0b001000, "normw",
    (outs ), (ins i32imm:$limm),
    "normw\t$limm", []> {
  // Opcode: 0x2E2F7F88, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-0} = 0b111111110001000;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// not<.f> b,c 00100bbb00101111FBBBCCCCCC001010.
def ARC_NOT_b_c : ARCompactInst32_2op<0b00100, 0b001010, "not",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "not\t$rb, $rc", []> {
  // Opcode: 0x202F000A, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b001010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// not<.f> 0,c 0010011000101111F111CCCCCC001010.
def ARC_NOT_z_c : ARCompactInst32_2op<0b00100, 0b001010, "not",
    (outs ), (ins GPR32:$rc),
    "not\t$rc", []> {
  // Opcode: 0x262F700A, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001010;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// not<.f> b,u6 00100bbb01101111FBBBuuuuuu001010.
def ARC_NOT_b_u6 : ARCompactInst32_2op<0b00100, 0b001010, "not",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "not\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F000A, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b001010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// not<.f> 0,u6 0010011001101111F111uuuuuu001010.
def ARC_NOT_z_u6 : ARCompactInst32_2op<0b00100, 0b001010, "not",
    (outs ), (ins u6imm:$uimm6_20),
    "not\t$uimm6_20", []> {
  // Opcode: 0x266F700A, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001010;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// not<.f> b,limm 00100bbb00101111FBBB111110001010.
def ARC_NOT_b_limm : ARCompactInst32_2op<0b00100, 0b001010, "not",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "not\t$rb, $limm", []> {
  // Opcode: 0x202F0F8A, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110001010;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// not<.f> 0,limm 0010011000101111F111111110001010.
def ARC_NOT_z_limm : ARCompactInst32_2op<0b00100, 0b001010, "not",
    (outs ), (ins i32imm:$limm),
    "not\t$limm", []> {
  // Opcode: 0x262F7F8A, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110001010;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f> a,b,c 00100bbb00000101FBBBCCCCCCAAAAAA.
def ARC_OR_a_b_c : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "or\t$ra, $rb, $rc", []> {
  // Opcode: 0x20050000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000101;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// or<.f> 0,b,c 00100bbb00000101FBBBCCCCCC111110.
def ARC_OR_z_b_c : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "or\t$rb, $rc", []> {
  // Opcode: 0x2005003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// or<.f><.cc> b,b,c 00100bbb11000101FBBBCCCCCC0QQQQQ.
def ARC_OR_b_c_cc : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "or\t$rb, $rc", []> {
  // Opcode: 0x20C50000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000101;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// or<.f> a,b,u6 00100bbb01000101FBBBuuuuuuAAAAAA.
def ARC_OR_a_b_u6 : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "or\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20450000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000101;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// or<.f> 0,b,u6 00100bbb01000101FBBBuuuuuu111110.
def ARC_OR_z_b_u6 : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "or\t$rb, $uimm6_20", []> {
  // Opcode: 0x2045003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// or<.f><.cc> b,b,u6 00100bbb11000101FBBBuuuuuu1QQQQQ.
def ARC_OR_b_u6_cc : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "or\t$rb, $uimm6_20", []> {
  // Opcode: 0x20C50020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000101;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// or<.f> b,b,s12 00100bbb10000101FBBBssssssSSSSSS.
def ARC_OR_b_s12 : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "or\t$rb, $simm12_20", []> {
  // Opcode: 0x20850000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10000101;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// or<.f> a,limm,c 0010011000000101F111CCCCCCAAAAAA.
def ARC_OR_a_limm_c : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "or\t$ra, $limm, $rc", []> {
  // Opcode: 0x26057000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f> a,b,limm 00100bbb00000101FBBB111110AAAAAA.
def ARC_OR_a_b_limm : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "or\t$ra, $rb, $limm", []> {
  // Opcode: 0x20050F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000101;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f> 0,limm,c 0010011000000101F111CCCCCC111110.
def ARC_OR_z_limm_c : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "or\t$limm, $rc", []> {
  // Opcode: 0x2605703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f> 0,b,limm 00100bbb00000101FBBB111110111110.
def ARC_OR_z_b_limm : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "or\t$rb, $limm", []> {
  // Opcode: 0x20050FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000101;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f><.cc> b,b,limm 00100bbb11000101FBBB1111100QQQQQ.
def ARC_OR_b_limm_cc : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "or\t$rb, $limm", []> {
  // Opcode: 0x20C50F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000101;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f><.cc> 0,limm,c 0010011011000101F111CCCCCC0QQQQQ.
def ARC_OR_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "or\t$limm, $rc", []> {
  // Opcode: 0x26C57000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f> a,limm,u6 0010011001000101F111uuuuuuAAAAAA.
def ARC_OR_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "or\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26457000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f> 0,limm,u6 0010011001000101F111uuuuuu111110.
def ARC_OR_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "or\t$limm, $uimm6_20", []> {
  // Opcode: 0x2645703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f><.cc> 0,limm,u6 0010011011000101F111uuuuuu1QQQQQ.
def ARC_OR_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "or\t$limm, $uimm6_20", []> {
  // Opcode: 0x26C57020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f> 0,limm,s12 0010011010000101F111ssssssSSSSSS.
def ARC_OR_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "or\t$limm, $simm12_20", []> {
  // Opcode: 0x26857000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010000101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f> a,limm,limm 0010011000000101F111111110AAAAAA.
def ARC_OR_a_limm : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "or\t$ra, $limm", []> {
  // Opcode: 0x26057F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000101;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f> 0,limm,limm 0010011000000101F111111110111110.
def ARC_OR_z_limm : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs ), (ins i32imm:$limm),
    "or\t$limm", []> {
  // Opcode: 0x26057FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000101;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// or<.f><.cc> 0,limm,limm 0010011011000101F1111111100QQQQQ.
def ARC_OR_z_limm_cc : ARCompactInst32_3op<0b00100, 0b000101, "or",
    (outs ), (ins i32imm:$limm),
    "or\t$limm", []> {
  // Opcode: 0x26C57F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000101;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// pkqb<.f> a,b,c 00110bbb00100000FBBBCCCCCCAAAAAA.
def ARC_PKQB_a_b_c : ARCompactInst32_3op<0b00110, 0b100000, "pkqb",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "pkqb\t$ra, $rb, $rc", []> {
  // Opcode: 0x30200000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// pkqb<.f><.cc> b,b,c 00110bbb11100000FBBBCCCCCC0QQQQQ.
def ARC_PKQB_b_c_cc : ARCompactInst32_3op<0b00110, 0b100000, "pkqb",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "pkqb\t$rb, $rc", []> {
  // Opcode: 0x30E00000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// pkqb<.f> a,b,u6 00110bbb01100000FBBBuuuuuuAAAAAA.
def ARC_PKQB_a_b_u6 : ARCompactInst32_3op<0b00110, 0b100000, "pkqb",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "pkqb\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30600000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01100000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// pkqb<.f><.cc> b,b,u6 00110bbb11100000FBBBuuuuuu1QQQQQ.
def ARC_PKQB_b_u6_cc : ARCompactInst32_3op<0b00110, 0b100000, "pkqb",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "pkqb\t$rb, $uimm6_20", []> {
  // Opcode: 0x30E00020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// pkqb<.f> b,b,s12 00110bbb10100000FBBBssssssSSSSSS.
def ARC_PKQB_b_s12 : ARCompactInst32_3op<0b00110, 0b100000, "pkqb",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "pkqb\t$rb, $simm12_20", []> {
  // Opcode: 0x30A00000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10100000;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// pkqb<.f> a,limm,c 0011011000100000F111CCCCCCAAAAAA.
def ARC_PKQB_a_limm_c : ARCompactInst32_3op<0b00110, 0b100000, "pkqb",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "pkqb\t$ra, $limm, $rc", []> {
  // Opcode: 0x36207000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000100000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// pkqb<.f> a,b,limm 00110bbb00100000FBBB111110AAAAAA.
def ARC_PKQB_a_b_limm : ARCompactInst32_3op<0b00110, 0b100000, "pkqb",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "pkqb\t$ra, $rb, $limm", []> {
  // Opcode: 0x30200F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// pkqb<.f><.cc> b,b,limm 00110bbb11100000FBBB1111100QQQQQ.
def ARC_PKQB_b_limm_cc : ARCompactInst32_3op<0b00110, 0b100000, "pkqb",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "pkqb\t$rb, $limm", []> {
  // Opcode: 0x30E00F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rcmp b,c 00100bbb000011011BBBCCCCCC000000.
def ARC_RCMP_b_c : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "rcmp\t$rb, $rc", []> {
  // Opcode: 0x200D8000, Mask: 0xF8FF803F
  // Operands: RB, RC
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b000011011;
  let Inst{5-0} = 0b000000;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rcmp<.cc> b,c 00100bbb110011011BBBCCCCCC0QQQQQ.
def ARC_RCMP_b_c_cc : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "rcmp\t$rb, $rc", []> {
  // Opcode: 0x20CD8000, Mask: 0xF8FF8020
  // Operands: RB, RC
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110011011;
  let Inst{5} = 0;
  let isPredicable = 1;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rcmp b,u6 00100bbb010011011BBBuuuuuu000000.
def ARC_RCMP_b_u6 : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "rcmp\t$rb, $uimm6_20", []> {
  // Opcode: 0x204D8000, Mask: 0xF8FF803F
  // Operands: RB, UIMM6_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b010011011;
  let Inst{5-0} = 0b000000;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rcmp<.cc> b,u6 00100bbb110011011BBBuuuuuu1QQQQQ.
def ARC_RCMP_b_u6_cc : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "rcmp\t$rb, $uimm6_20", []> {
  // Opcode: 0x20CD8020, Mask: 0xF8FF8020
  // Operands: RB, UIMM6_20
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110011011;
  let Inst{5} = 1;
  let isPredicable = 1;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rcmp b,s12 00100bbb100011011BBBssssssSSSSSS.
def ARC_RCMP_b_s12 : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "rcmp\t$rb, $simm12_20", []> {
  // Opcode: 0x208D8000, Mask: 0xF8FF8000
  // Operands: RB, SIMM12_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b100011011;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// rcmp limm,c 00100110000011011111CCCCCC000000.
def ARC_RCMP_limm_c : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "rcmp\t$limm, $rc", []> {
  // Opcode: 0x260DF000, Mask: 0xFFFFF03F
  // Operands: LIMM, RC
  // Flags: none
  let Inst{31-12} = 0b00100110000011011111;
  let Inst{5-0} = 0b000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rcmp b,limm 00100bbb000011011BBB111110000000.
def ARC_RCMP_b_limm : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "rcmp\t$rb, $limm", []> {
  // Opcode: 0x200D8F80, Mask: 0xF8FF8FFF
  // Operands: RB, LIMM
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b000011011;
  let Inst{11-0} = 0b111110000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rcmp<.cc> limm,c 00100110110011011111CCCCCC0QQQQQ.
def ARC_RCMP_limm_c_cc : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "rcmp\t$limm, $rc", []> {
  // Opcode: 0x26CDF000, Mask: 0xFFFFF020
  // Operands: LIMM, RC
  // Flags: C_CC
  let Inst{31-12} = 0b00100110110011011111;
  let Inst{5} = 0;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rcmp<.cc> b,limm 00100bbb110011011BBB1111100QQQQQ.
def ARC_RCMP_b_limm_cc : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "rcmp\t$rb, $limm", []> {
  // Opcode: 0x20CD8F80, Mask: 0xF8FF8FE0
  // Operands: RB, LIMM
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110011011;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rcmp limm,u6 00100110010011011111uuuuuu000000.
def ARC_RCMP_limm_u6 : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "rcmp\t$limm, $uimm6_20", []> {
  // Opcode: 0x264DF000, Mask: 0xFFFFF03F
  // Operands: LIMM, UIMM6_20
  // Flags: none
  let Inst{31-12} = 0b00100110010011011111;
  let Inst{5-0} = 0b000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rcmp<.cc> limm,u6 00100110110011011111uuuuuu1QQQQQ.
def ARC_RCMP_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "rcmp\t$limm, $uimm6_20", []> {
  // Opcode: 0x26CDF020, Mask: 0xFFFFF020
  // Operands: LIMM, UIMM6_20
  // Flags: C_CC
  let Inst{31-12} = 0b00100110110011011111;
  let Inst{5} = 1;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rcmp limm,s12 00100110100011011111ssssssSSSSSS.
def ARC_RCMP_limm_s12 : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "rcmp\t$limm, $simm12_20", []> {
  // Opcode: 0x268DF000, Mask: 0xFFFFF000
  // Operands: LIMM, SIMM12_20
  // Flags: none
  let Inst{31-12} = 0b00100110100011011111;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rcmp limm,limm 00100110000011011111111110000000.
def ARC_RCMP_limm : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs ), (ins i32imm:$limm),
    "rcmp\t$limm", []> {
  // Opcode: 0x260DFF80, Mask: 0xFFFFFFFF
  // Operands: LIMM, LIMMdup
  // Flags: none
  let Inst{31-0} = 0b00100110000011011111111110000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rcmp<.cc> limm,limm 001001101100110111111111100QQQQQ.
def ARC_RCMP_limm_cc : ARCompactInst32_3op<0b00100, 0b001101, "rcmp",
    (outs ), (ins i32imm:$limm),
    "rcmp\t$limm", []> {
  // Opcode: 0x26CDFF80, Mask: 0xFFFFFFE0
  // Operands: LIMM, LIMMdup
  // Flags: C_CC
  let Inst{31-5} = 0b001001101100110111111111100;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rlc<.f> b,c 00100bbb00101111FBBBCCCCCC001011.
def ARC_RLC_b_c : ARCompactInst32_2op<0b00100, 0b001011, "rlc",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "rlc\t$rb, $rc", []> {
  // Opcode: 0x202F000B, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b001011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rlc<.f> 0,c 0010011000101111F111CCCCCC001011.
def ARC_RLC_z_c : ARCompactInst32_2op<0b00100, 0b001011, "rlc",
    (outs ), (ins GPR32:$rc),
    "rlc\t$rc", []> {
  // Opcode: 0x262F700B, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001011;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rlc<.f> b,u6 00100bbb01101111FBBBuuuuuu001011.
def ARC_RLC_b_u6 : ARCompactInst32_2op<0b00100, 0b001011, "rlc",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "rlc\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F000B, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b001011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rlc<.f> 0,u6 0010011001101111F111uuuuuu001011.
def ARC_RLC_z_u6 : ARCompactInst32_2op<0b00100, 0b001011, "rlc",
    (outs ), (ins u6imm:$uimm6_20),
    "rlc\t$uimm6_20", []> {
  // Opcode: 0x266F700B, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001011;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rlc<.f> b,limm 00100bbb00101111FBBB111110001011.
def ARC_RLC_b_limm : ARCompactInst32_2op<0b00100, 0b001011, "rlc",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "rlc\t$rb, $limm", []> {
  // Opcode: 0x202F0F8B, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110001011;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rlc<.f> 0,limm 0010011000101111F111111110001011.
def ARC_RLC_z_limm : ARCompactInst32_2op<0b00100, 0b001011, "rlc",
    (outs ), (ins i32imm:$limm),
    "rlc\t$limm", []> {
  // Opcode: 0x262F7F8B, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110001011;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rnd16<.f> b,c 00101bbb00101111FBBBCCCCCC000011.
def ARC_RND16_b_c : ARCompactInst32_2op<0b00101, 0b000011, "rnd16",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "rnd16\t$rb, $rc", []> {
  // Opcode: 0x282F0003, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rnd16<.f> 0,c 0010111000101111F111CCCCCC000011.
def ARC_RND16_z_c : ARCompactInst32_2op<0b00101, 0b000011, "rnd16",
    (outs ), (ins GPR32:$rc),
    "rnd16\t$rc", []> {
  // Opcode: 0x2E2F7003, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000011;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rnd16<.f> b,u6 00101bbb01101111FBBBuuuuuu000011.
def ARC_RND16_b_u6 : ARCompactInst32_2op<0b00101, 0b000011, "rnd16",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "rnd16\t$rb, $uimm6_20", []> {
  // Opcode: 0x286F0003, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rnd16<.f> 0,u6 0010111001101111F111uuuuuu000011.
def ARC_RND16_z_u6 : ARCompactInst32_2op<0b00101, 0b000011, "rnd16",
    (outs ), (ins u6imm:$uimm6_20),
    "rnd16\t$uimm6_20", []> {
  // Opcode: 0x2E6F7003, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000011;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rnd16<.f> b,limm 00101bbb00101111FBBB111110000011.
def ARC_RND16_b_limm : ARCompactInst32_2op<0b00101, 0b000011, "rnd16",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "rnd16\t$rb, $limm", []> {
  // Opcode: 0x282F0F83, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000011;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rnd16<.f> 0,limm 0010111000101111F111111110000011.
def ARC_RND16_z_limm : ARCompactInst32_2op<0b00101, 0b000011, "rnd16",
    (outs ), (ins i32imm:$limm),
    "rnd16\t$limm", []> {
  // Opcode: 0x2E2F7F83, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-0} = 0b111111110000011;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f> b,c 00100bbb00101111FBBBCCCCCC000011.
def ARC_ROR_b_c : ARCompactInst32_2op<0b00100, 0b000011, "ror",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "ror\t$rb, $rc", []> {
  // Opcode: 0x202F0003, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// ror<.f> 0,c 0010011000101111F111CCCCCC000011.
def ARC_ROR_z_c : ARCompactInst32_2op<0b00100, 0b000011, "ror",
    (outs ), (ins GPR32:$rc),
    "ror\t$rc", []> {
  // Opcode: 0x262F7003, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000011;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// ror<.f> a,b,c 00101bbb00000011FBBBCCCCCCAAAAAA.
def ARC_ROR_a_b_c : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "ror\t$ra, $rb, $rc", []> {
  // Opcode: 0x28030000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// ror<.f> 0,b,c 00101bbb00000011FBBBCCCCCC111110.
def ARC_ROR_z_b_c : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "ror\t$rb, $rc", []> {
  // Opcode: 0x2803003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// ror<.f><.cc> b,b,c 00101bbb11000011FBBBCCCCCC0QQQQQ.
def ARC_ROR_b_c_cc : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "ror\t$rb, $rc", []> {
  // Opcode: 0x28C30000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000011;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// ror<.f> b,u6 00100bbb01101111FBBBuuuuuu000011.
def ARC_ROR_b_u6 : ARCompactInst32_2op<0b00100, 0b000011, "ror",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "ror\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F0003, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// ror<.f> 0,u6 0010011001101111F111uuuuuu000011.
def ARC_ROR_z_u6 : ARCompactInst32_2op<0b00100, 0b000011, "ror",
    (outs ), (ins u6imm:$uimm6_20),
    "ror\t$uimm6_20", []> {
  // Opcode: 0x266F7003, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000011;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// ror<.f> a,b,u6 00101bbb01000011FBBBuuuuuuAAAAAA.
def ARC_ROR_a_b_u6 : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "ror\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x28430000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// ror<.f> 0,b,u6 00101bbb01000011FBBBuuuuuu111110.
def ARC_ROR_z_b_u6 : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "ror\t$rb, $uimm6_20", []> {
  // Opcode: 0x2843003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// ror<.f><.cc> b,b,u6 00101bbb11000011FBBBuuuuuu1QQQQQ.
def ARC_ROR_b_u6_cc : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "ror\t$rb, $uimm6_20", []> {
  // Opcode: 0x28C30020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000011;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// ror<.f> b,b,s12 00101bbb10000011FBBBssssssSSSSSS.
def ARC_ROR_b_s12 : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "ror\t$rb, $simm12_20", []> {
  // Opcode: 0x28830000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10000011;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// ror<.f> b,limm 00100bbb00101111FBBB111110000011.
def ARC_ROR_b_limm : ARCompactInst32_2op<0b00100, 0b000011, "ror",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "ror\t$rb, $limm", []> {
  // Opcode: 0x202F0F83, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000011;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f> 0,limm 0010011000101111F111111110000011.
def ARC_ROR_z_limm : ARCompactInst32_2op<0b00100, 0b000011, "ror",
    (outs ), (ins i32imm:$limm),
    "ror\t$limm", []> {
  // Opcode: 0x262F7F83, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110000011;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f> a,limm,c 0010111000000011F111CCCCCCAAAAAA.
def ARC_ROR_a_limm_c : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "ror\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E037000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f> a,b,limm 00101bbb00000011FBBB111110AAAAAA.
def ARC_ROR_a_b_limm : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "ror\t$ra, $rb, $limm", []> {
  // Opcode: 0x28030F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000011;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f> 0,limm,c 0010111000000011F111CCCCCC111110.
def ARC_ROR_z_limm_c : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "ror\t$limm, $rc", []> {
  // Opcode: 0x2E03703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f> 0,b,limm 00101bbb00000011FBBB111110111110.
def ARC_ROR_z_b_limm : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "ror\t$rb, $limm", []> {
  // Opcode: 0x28030FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000011;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f><.cc> b,b,limm 00101bbb11000011FBBB1111100QQQQQ.
def ARC_ROR_b_limm_cc : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "ror\t$rb, $limm", []> {
  // Opcode: 0x28C30F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000011;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f><.cc> 0,limm,c 0010111011000011F111CCCCCC0QQQQQ.
def ARC_ROR_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "ror\t$limm, $rc", []> {
  // Opcode: 0x2EC37000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f> a,limm,u6 0010111001000011F111uuuuuuAAAAAA.
def ARC_ROR_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "ror\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E437000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f> 0,limm,u6 0010111001000011F111uuuuuu111110.
def ARC_ROR_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "ror\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E43703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f><.cc> 0,limm,u6 0010111011000011F111uuuuuu1QQQQQ.
def ARC_ROR_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "ror\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EC37020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f> 0,limm,s12 0010111010000011F111ssssssSSSSSS.
def ARC_ROR_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "ror\t$limm, $simm12_20", []> {
  // Opcode: 0x2E837000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010000011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f> a,limm,limm 0010111000000011F111111110AAAAAA.
def ARC_ROR_a_limm : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "ror\t$ra, $limm", []> {
  // Opcode: 0x2E037F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000011;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ror<.f> 0,limm,limm 0010111000000011F111111110111110.
def ARC_ROR_z_limm_v1 : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs ), (ins i32imm:$limm),
    "ror\t$limm", []> {
  // Opcode: 0x2E037FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000011;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// ror<.f><.cc> 0,limm,limm 0010111011000011F1111111100QQQQQ.
def ARC_ROR_z_limm_cc : ARCompactInst32_3op<0b00101, 0b000011, "ror",
    (outs ), (ins i32imm:$limm),
    "ror\t$limm", []> {
  // Opcode: 0x2EC37F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000011;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rrc<.f> b,c 00100bbb00101111FBBBCCCCCC000100.
def ARC_RRC_b_c : ARCompactInst32_2op<0b00100, 0b000100, "rrc",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "rrc\t$rb, $rc", []> {
  // Opcode: 0x202F0004, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000100;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rrc<.f> 0,c 0010011000101111F111CCCCCC000100.
def ARC_RRC_z_c : ARCompactInst32_2op<0b00100, 0b000100, "rrc",
    (outs ), (ins GPR32:$rc),
    "rrc\t$rc", []> {
  // Opcode: 0x262F7004, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000100;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rrc<.f> b,u6 00100bbb01101111FBBBuuuuuu000100.
def ARC_RRC_b_u6 : ARCompactInst32_2op<0b00100, 0b000100, "rrc",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "rrc\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F0004, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000100;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rrc<.f> 0,u6 0010011001101111F111uuuuuu000100.
def ARC_RRC_z_u6 : ARCompactInst32_2op<0b00100, 0b000100, "rrc",
    (outs ), (ins u6imm:$uimm6_20),
    "rrc\t$uimm6_20", []> {
  // Opcode: 0x266F7004, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000100;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rrc<.f> b,limm 00100bbb00101111FBBB111110000100.
def ARC_RRC_b_limm : ARCompactInst32_2op<0b00100, 0b000100, "rrc",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "rrc\t$rb, $limm", []> {
  // Opcode: 0x202F0F84, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000100;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rrc<.f> 0,limm 0010011000101111F111111110000100.
def ARC_RRC_z_limm : ARCompactInst32_2op<0b00100, 0b000100, "rrc",
    (outs ), (ins i32imm:$limm),
    "rrc\t$limm", []> {
  // Opcode: 0x262F7F84, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110000100;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f> a,b,c 00100bbb00001110FBBBCCCCCCAAAAAA.
def ARC_RSUB_a_b_c : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "rsub\t$ra, $rb, $rc", []> {
  // Opcode: 0x200E0000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// rsub<.f> 0,b,c 00100bbb00001110FBBBCCCCCC111110.
def ARC_RSUB_z_b_c : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "rsub\t$rb, $rc", []> {
  // Opcode: 0x200E003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rsub<.f><.cc> b,b,c 00100bbb11001110FBBBCCCCCC0QQQQQ.
def ARC_RSUB_b_c_cc : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "rsub\t$rb, $rc", []> {
  // Opcode: 0x20CE0000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001110;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// rsub<.f> a,b,u6 00100bbb01001110FBBBuuuuuuAAAAAA.
def ARC_RSUB_a_b_u6 : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "rsub\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x204E0000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01001110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// rsub<.f> 0,b,u6 00100bbb01001110FBBBuuuuuu111110.
def ARC_RSUB_z_b_u6 : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "rsub\t$rb, $uimm6_20", []> {
  // Opcode: 0x204E003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01001110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rsub<.f><.cc> b,b,u6 00100bbb11001110FBBBuuuuuu1QQQQQ.
def ARC_RSUB_b_u6_cc : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "rsub\t$rb, $uimm6_20", []> {
  // Opcode: 0x20CE0020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001110;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// rsub<.f> b,b,s12 00100bbb10001110FBBBssssssSSSSSS.
def ARC_RSUB_b_s12 : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "rsub\t$rb, $simm12_20", []> {
  // Opcode: 0x208E0000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10001110;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// rsub<.f> a,limm,c 0010011000001110F111CCCCCCAAAAAA.
def ARC_RSUB_a_limm_c : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "rsub\t$ra, $limm, $rc", []> {
  // Opcode: 0x260E7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f> a,b,limm 00100bbb00001110FBBB111110AAAAAA.
def ARC_RSUB_a_b_limm : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "rsub\t$ra, $rb, $limm", []> {
  // Opcode: 0x200E0F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001110;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f> 0,limm,c 0010011000001110F111CCCCCC111110.
def ARC_RSUB_z_limm_c : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "rsub\t$limm, $rc", []> {
  // Opcode: 0x260E703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f> 0,b,limm 00100bbb00001110FBBB111110111110.
def ARC_RSUB_z_b_limm : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "rsub\t$rb, $limm", []> {
  // Opcode: 0x200E0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00001110;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f><.cc> b,b,limm 00100bbb11001110FBBB1111100QQQQQ.
def ARC_RSUB_b_limm_cc : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "rsub\t$rb, $limm", []> {
  // Opcode: 0x20CE0F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11001110;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f><.cc> 0,limm,c 0010011011001110F111CCCCCC0QQQQQ.
def ARC_RSUB_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "rsub\t$limm, $rc", []> {
  // Opcode: 0x26CE7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f> a,limm,u6 0010011001001110F111uuuuuuAAAAAA.
def ARC_RSUB_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "rsub\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x264E7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001001110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f> 0,limm,u6 0010011001001110F111uuuuuu111110.
def ARC_RSUB_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "rsub\t$limm, $uimm6_20", []> {
  // Opcode: 0x264E703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001001110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f><.cc> 0,limm,u6 0010011011001110F111uuuuuu1QQQQQ.
def ARC_RSUB_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "rsub\t$limm, $uimm6_20", []> {
  // Opcode: 0x26CE7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f> 0,limm,s12 0010011010001110F111ssssssSSSSSS.
def ARC_RSUB_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "rsub\t$limm, $simm12_20", []> {
  // Opcode: 0x268E7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010001110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f> a,limm,limm 0010011000001110F111111110AAAAAA.
def ARC_RSUB_a_limm : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "rsub\t$ra, $limm", []> {
  // Opcode: 0x260E7F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001110;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f> 0,limm,limm 0010011000001110F111111110111110.
def ARC_RSUB_z_limm : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs ), (ins i32imm:$limm),
    "rsub\t$limm", []> {
  // Opcode: 0x260E7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000001110;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// rsub<.f><.cc> 0,limm,limm 0010011011001110F1111111100QQQQQ.
def ARC_RSUB_z_limm_cc : ARCompactInst32_3op<0b00100, 0b001110, "rsub",
    (outs ), (ins i32imm:$limm),
    "rsub\t$limm", []> {
  // Opcode: 0x26CE7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011001110;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sat16<.f> b,c 00101bbb00101111FBBBCCCCCC000010.
def ARC_SAT16_b_c : ARCompactInst32_2op<0b00101, 0b000010, "sat16",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "sat16\t$rb, $rc", []> {
  // Opcode: 0x282F0002, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sat16<.f> 0,c 0010111000101111F111CCCCCC000010.
def ARC_SAT16_z_c : ARCompactInst32_2op<0b00101, 0b000010, "sat16",
    (outs ), (ins GPR32:$rc),
    "sat16\t$rc", []> {
  // Opcode: 0x2E2F7002, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000010;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sat16<.f> b,u6 00101bbb01101111FBBBuuuuuu000010.
def ARC_SAT16_b_u6 : ARCompactInst32_2op<0b00101, 0b000010, "sat16",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "sat16\t$rb, $uimm6_20", []> {
  // Opcode: 0x286F0002, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sat16<.f> 0,u6 0010111001101111F111uuuuuu000010.
def ARC_SAT16_z_u6 : ARCompactInst32_2op<0b00101, 0b000010, "sat16",
    (outs ), (ins u6imm:$uimm6_20),
    "sat16\t$uimm6_20", []> {
  // Opcode: 0x2E6F7002, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000010;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sat16<.f> b,limm 00101bbb00101111FBBB111110000010.
def ARC_SAT16_b_limm : ARCompactInst32_2op<0b00101, 0b000010, "sat16",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "sat16\t$rb, $limm", []> {
  // Opcode: 0x282F0F82, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000010;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sat16<.f> 0,limm 0010111000101111F111111110000010.
def ARC_SAT16_z_limm : ARCompactInst32_2op<0b00101, 0b000010, "sat16",
    (outs ), (ins i32imm:$limm),
    "sat16\t$limm", []> {
  // Opcode: 0x2E2F7F82, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-0} = 0b111111110000010;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f> a,b,c 00100bbb00000011FBBBCCCCCCAAAAAA.
def ARC_SBC_a_b_c : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "sbc\t$ra, $rb, $rc", []> {
  // Opcode: 0x20030000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sbc<.f> 0,b,c 00100bbb00000011FBBBCCCCCC111110.
def ARC_SBC_z_b_c : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "sbc\t$rb, $rc", []> {
  // Opcode: 0x2003003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sbc<.f><.cc> b,b,c 00100bbb11000011FBBBCCCCCC0QQQQQ.
def ARC_SBC_b_c_cc : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "sbc\t$rb, $rc", []> {
  // Opcode: 0x20C30000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000011;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sbc<.f> a,b,u6 00100bbb01000011FBBBuuuuuuAAAAAA.
def ARC_SBC_a_b_u6 : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sbc\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20430000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000011;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sbc<.f> 0,b,u6 00100bbb01000011FBBBuuuuuu111110.
def ARC_SBC_z_b_u6 : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sbc\t$rb, $uimm6_20", []> {
  // Opcode: 0x2043003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sbc<.f><.cc> b,b,u6 00100bbb11000011FBBBuuuuuu1QQQQQ.
def ARC_SBC_b_u6_cc : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "sbc\t$rb, $uimm6_20", []> {
  // Opcode: 0x20C30020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000011;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sbc<.f> b,b,s12 00100bbb10000011FBBBssssssSSSSSS.
def ARC_SBC_b_s12 : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "sbc\t$rb, $simm12_20", []> {
  // Opcode: 0x20830000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10000011;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// sbc<.f> a,limm,c 0010011000000011F111CCCCCCAAAAAA.
def ARC_SBC_a_limm_c : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "sbc\t$ra, $limm, $rc", []> {
  // Opcode: 0x26037000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f> a,b,limm 00100bbb00000011FBBB111110AAAAAA.
def ARC_SBC_a_b_limm : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "sbc\t$ra, $rb, $limm", []> {
  // Opcode: 0x20030F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000011;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f> 0,limm,c 0010011000000011F111CCCCCC111110.
def ARC_SBC_z_limm_c : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sbc\t$limm, $rc", []> {
  // Opcode: 0x2603703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f> 0,b,limm 00100bbb00000011FBBB111110111110.
def ARC_SBC_z_b_limm : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "sbc\t$rb, $limm", []> {
  // Opcode: 0x20030FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000011;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f><.cc> b,b,limm 00100bbb11000011FBBB1111100QQQQQ.
def ARC_SBC_b_limm_cc : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "sbc\t$rb, $limm", []> {
  // Opcode: 0x20C30F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000011;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f><.cc> 0,limm,c 0010011011000011F111CCCCCC0QQQQQ.
def ARC_SBC_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sbc\t$limm, $rc", []> {
  // Opcode: 0x26C37000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f> a,limm,u6 0010011001000011F111uuuuuuAAAAAA.
def ARC_SBC_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sbc\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26437000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f> 0,limm,u6 0010011001000011F111uuuuuu111110.
def ARC_SBC_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sbc\t$limm, $uimm6_20", []> {
  // Opcode: 0x2643703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f><.cc> 0,limm,u6 0010011011000011F111uuuuuu1QQQQQ.
def ARC_SBC_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sbc\t$limm, $uimm6_20", []> {
  // Opcode: 0x26C37020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f> 0,limm,s12 0010011010000011F111ssssssSSSSSS.
def ARC_SBC_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "sbc\t$limm, $simm12_20", []> {
  // Opcode: 0x26837000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010000011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f> a,limm,limm 0010011000000011F111111110AAAAAA.
def ARC_SBC_a_limm : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "sbc\t$ra, $limm", []> {
  // Opcode: 0x26037F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000011;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f> 0,limm,limm 0010011000000011F111111110111110.
def ARC_SBC_z_limm : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs ), (ins i32imm:$limm),
    "sbc\t$limm", []> {
  // Opcode: 0x26037FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000011;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbc<.f><.cc> 0,limm,limm 0010011011000011F1111111100QQQQQ.
def ARC_SBC_z_limm_cc : ARCompactInst32_3op<0b00100, 0b000011, "sbc",
    (outs ), (ins i32imm:$limm),
    "sbc\t$limm", []> {
  // Opcode: 0x26C37F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000011;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f> a,b,c 00101bbb00100111FBBBCCCCCCAAAAAA.
def ARC_SBCS_a_b_c : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "sbcs\t$ra, $rb, $rc", []> {
  // Opcode: 0x28270000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sbcs<.f> 0,b,c 00101bbb00100111FBBBCCCCCC111110.
def ARC_SBCS_z_b_c : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "sbcs\t$rb, $rc", []> {
  // Opcode: 0x2827003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sbcs<.f><.cc> b,b,c 00101bbb11100111FBBBCCCCCC0QQQQQ.
def ARC_SBCS_b_c_cc : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "sbcs\t$rb, $rc", []> {
  // Opcode: 0x28E70000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11100111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sbcs<.f> a,b,u6 00101bbb01100111FBBBuuuuuuAAAAAA.
def ARC_SBCS_a_b_u6 : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sbcs\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x28670000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01100111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sbcs<.f> 0,b,u6 00101bbb01100111FBBBuuuuuu111110.
def ARC_SBCS_z_b_u6 : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sbcs\t$rb, $uimm6_20", []> {
  // Opcode: 0x2867003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01100111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sbcs<.f><.cc> b,b,u6 00101bbb11100111FBBBuuuuuu1QQQQQ.
def ARC_SBCS_b_u6_cc : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "sbcs\t$rb, $uimm6_20", []> {
  // Opcode: 0x28E70020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11100111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sbcs<.f> b,b,s12 00101bbb10100111FBBBssssssSSSSSS.
def ARC_SBCS_b_s12 : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "sbcs\t$rb, $simm12_20", []> {
  // Opcode: 0x28A70000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10100111;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// sbcs<.f> a,limm,c 0010111000100111F111CCCCCCAAAAAA.
def ARC_SBCS_a_limm_c : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "sbcs\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E277000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000100111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f> a,b,limm 00101bbb00100111FBBB111110AAAAAA.
def ARC_SBCS_a_b_limm : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "sbcs\t$ra, $rb, $limm", []> {
  // Opcode: 0x28270F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100111;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f> 0,limm,c 0010111001100111F111CCCCCC111110.
def ARC_SBCS_z_limm_c : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sbcs\t$limm, $rc", []> {
  // Opcode: 0x2E67703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111001100111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f> 0,b,limm 00101bbb00100111FBBB111110111110.
def ARC_SBCS_z_b_limm : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "sbcs\t$rb, $limm", []> {
  // Opcode: 0x28270FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100111;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f><.cc> b,b,limm 00101bbb11100111FBBB1111100QQQQQ.
def ARC_SBCS_b_limm_cc : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "sbcs\t$rb, $limm", []> {
  // Opcode: 0x28E70F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11100111;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f><.cc> 0,limm,c 0010111011100111F111CCCCCC0QQQQQ.
def ARC_SBCS_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sbcs\t$limm, $rc", []> {
  // Opcode: 0x2EE77000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011100111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f> a,limm,u6 0010111001100111F111uuuuuuAAAAAA.
def ARC_SBCS_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sbcs\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E677000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001100111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f> 0,limm,u6 0010111001100111F111uuuuuu111110.
def ARC_SBCS_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sbcs\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E67703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001100111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Decoding conflict with overlapping encoding.
  let isCodeGenOnly = 1;
}

// sbcs<.f><.cc> 0,limm,u6 0010111011100111F111uuuuuu1QQQQQ.
def ARC_SBCS_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sbcs\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EE77020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011100111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f> 0,limm,s12 0010111010100111F111ssssssSSSSSS.
def ARC_SBCS_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "sbcs\t$limm, $simm12_20", []> {
  // Opcode: 0x2EA77000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010100111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f> a,limm,limm 0010111000100111F111111110AAAAAA.
def ARC_SBCS_a_limm : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "sbcs\t$ra, $limm", []> {
  // Opcode: 0x2E277F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000100111;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f> 0,limm,limm 0010111000100111F111111110111110.
def ARC_SBCS_z_limm : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs ), (ins i32imm:$limm),
    "sbcs\t$limm", []> {
  // Opcode: 0x2E277FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000100111;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sbcs<.f><.cc> 0,limm,limm 0010111011100111F1111111100QQQQQ.
def ARC_SBCS_z_limm_cc : ARCompactInst32_3op<0b00101, 0b100111, "sbcs",
    (outs ), (ins i32imm:$limm),
    "sbcs\t$limm", []> {
  // Opcode: 0x2EE77F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011100111;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sexb<.f> b,c 00100bbb00101111FBBBCCCCCC000101.
def ARC_SEXB_b_c : ARCompactInst32_2op<0b00100, 0b000101, "sexb",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "sexb\t$rb, $rc", []> {
  // Opcode: 0x202F0005, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000101;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sexb<.f> 0,c 0010011000101111F111CCCCCC000101.
def ARC_SEXB_z_c : ARCompactInst32_2op<0b00100, 0b000101, "sexb",
    (outs ), (ins GPR32:$rc),
    "sexb\t$rc", []> {
  // Opcode: 0x262F7005, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000101;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sexb<.f> b,u6 00100bbb01101111FBBBuuuuuu000101.
def ARC_SEXB_b_u6 : ARCompactInst32_2op<0b00100, 0b000101, "sexb",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "sexb\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F0005, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000101;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sexb<.f> 0,u6 0010011001101111F111uuuuuu000101.
def ARC_SEXB_z_u6 : ARCompactInst32_2op<0b00100, 0b000101, "sexb",
    (outs ), (ins u6imm:$uimm6_20),
    "sexb\t$uimm6_20", []> {
  // Opcode: 0x266F7005, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000101;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sexb<.f> b,limm 00100bbb00101111FBBB111110000101.
def ARC_SEXB_b_limm : ARCompactInst32_2op<0b00100, 0b000101, "sexb",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "sexb\t$rb, $limm", []> {
  // Opcode: 0x202F0F85, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000101;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sexb<.f> 0,limm 0010011000101111F111111110000101.
def ARC_SEXB_z_limm : ARCompactInst32_2op<0b00100, 0b000101, "sexb",
    (outs ), (ins i32imm:$limm),
    "sexb\t$limm", []> {
  // Opcode: 0x262F7F85, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110000101;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sexw<.f> b,c 00100bbb00101111FBBBCCCCCC000110.
def ARC_SEXW_b_c : ARCompactInst32_2op<0b00100, 0b000110, "sexw",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "sexw\t$rb, $rc", []> {
  // Opcode: 0x202F0006, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sexw<.f> 0,c 0010011000101111F111CCCCCC000110.
def ARC_SEXW_z_c : ARCompactInst32_2op<0b00100, 0b000110, "sexw",
    (outs ), (ins GPR32:$rc),
    "sexw\t$rc", []> {
  // Opcode: 0x262F7006, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000110;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sexw<.f> b,u6 00100bbb01101111FBBBuuuuuu000110.
def ARC_SEXW_b_u6 : ARCompactInst32_2op<0b00100, 0b000110, "sexw",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "sexw\t$rb, $uimm6_20", []> {
  // Opcode: 0x206F0006, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sexw<.f> 0,u6 0010011001101111F111uuuuuu000110.
def ARC_SEXW_z_u6 : ARCompactInst32_2op<0b00100, 0b000110, "sexw",
    (outs ), (ins u6imm:$uimm6_20),
    "sexw\t$uimm6_20", []> {
  // Opcode: 0x266F7006, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000110;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sexw<.f> b,limm 00100bbb00101111FBBB111110000110.
def ARC_SEXW_b_limm : ARCompactInst32_2op<0b00100, 0b000110, "sexw",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "sexw\t$rb, $limm", []> {
  // Opcode: 0x202F0F86, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sexw<.f> 0,limm 0010011000101111F111111110000110.
def ARC_SEXW_z_limm : ARCompactInst32_2op<0b00100, 0b000110, "sexw",
    (outs ), (ins i32imm:$limm),
    "sexw\t$limm", []> {
  // Opcode: 0x262F7F86, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110000110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sfxtr<.f> a,b,c 00110bbb00101001FBBBCCCCCCAAAAAA.
def ARC_SFXTR_a_b_c : ARCompactInst32_3op<0b00110, 0b101001, "sfxtr",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "sfxtr\t$ra, $rb, $rc", []> {
  // Opcode: 0x30290000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00101001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sfxtr<.f><.cc> b,b,c 00110bbb11101001FBBBCCCCCC0QQQQQ.
def ARC_SFXTR_b_c_cc : ARCompactInst32_3op<0b00110, 0b101001, "sfxtr",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "sfxtr\t$rb, $rc", []> {
  // Opcode: 0x30E90000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11101001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sfxtr<.f> a,b,u6 00110bbb01101001FBBBuuuuuuAAAAAA.
def ARC_SFXTR_a_b_u6 : ARCompactInst32_3op<0b00110, 0b101001, "sfxtr",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sfxtr\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30690000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01101001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sfxtr<.f><.cc> b,b,u6 00110bbb11101001FBBBuuuuuu1QQQQQ.
def ARC_SFXTR_b_u6_cc : ARCompactInst32_3op<0b00110, 0b101001, "sfxtr",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "sfxtr\t$rb, $uimm6_20", []> {
  // Opcode: 0x30E90020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11101001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sfxtr<.f> b,b,s12 00110bbb10101001FBBBssssssSSSSSS.
def ARC_SFXTR_b_s12 : ARCompactInst32_3op<0b00110, 0b101001, "sfxtr",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "sfxtr\t$rb, $simm12_20", []> {
  // Opcode: 0x30A90000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10101001;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// sfxtr<.f> a,limm,c 0011011000101001F111CCCCCCAAAAAA.
def ARC_SFXTR_a_limm_c : ARCompactInst32_3op<0b00110, 0b101001, "sfxtr",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "sfxtr\t$ra, $limm, $rc", []> {
  // Opcode: 0x36297000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000101001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sfxtr<.f> a,b,limm 00110bbb00101001FBBB111110AAAAAA.
def ARC_SFXTR_a_b_limm : ARCompactInst32_3op<0b00110, 0b101001, "sfxtr",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "sfxtr\t$ra, $rb, $limm", []> {
  // Opcode: 0x30290F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00101001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sfxtr<.f><.cc> b,b,limm 00110bbb11101001FBBB1111100QQQQQ.
def ARC_SFXTR_b_limm_cc : ARCompactInst32_3op<0b00110, 0b101001, "sfxtr",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "sfxtr\t$rb, $limm", []> {
  // Opcode: 0x30E90F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11101001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f> a,b,c 00100bbb00000010FBBBCCCCCCAAAAAA.
def ARC_SUB_a_b_c : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "sub\t$ra, $rb, $rc", []> {
  // Opcode: 0x20020000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sub<.f> 0,b,c 00100bbb00000010FBBBCCCCCC111110.
def ARC_SUB_z_b_c : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "sub\t$rb, $rc", []> {
  // Opcode: 0x2002003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sub<.f><.cc> b,b,c 00100bbb11000010FBBBCCCCCC0QQQQQ.
def ARC_SUB_b_c_cc : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "sub\t$rb, $rc", []> {
  // Opcode: 0x20C20000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sub<.f> a,b,u6 00100bbb01000010FBBBuuuuuuAAAAAA.
def ARC_SUB_a_b_u6 : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sub\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20420000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sub<.f> 0,b,u6 00100bbb01000010FBBBuuuuuu111110.
def ARC_SUB_z_b_u6 : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sub\t$rb, $uimm6_20", []> {
  // Opcode: 0x2042003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sub<.f><.cc> b,b,u6 00100bbb11000010FBBBuuuuuu1QQQQQ.
def ARC_SUB_b_u6_cc : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "sub\t$rb, $uimm6_20", []> {
  // Opcode: 0x20C20020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sub<.f> b,b,s12 00100bbb10000010FBBBssssssSSSSSS.
def ARC_SUB_b_s12 : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "sub\t$rb, $simm12_20", []> {
  // Opcode: 0x20820000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10000010;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// sub<.f> a,limm,c 0010011000000010F111CCCCCCAAAAAA.
def ARC_SUB_a_limm_c : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "sub\t$ra, $limm, $rc", []> {
  // Opcode: 0x26027000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f> a,b,limm 00100bbb00000010FBBB111110AAAAAA.
def ARC_SUB_a_b_limm : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "sub\t$ra, $rb, $limm", []> {
  // Opcode: 0x20020F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f> 0,limm,c 0010011000000010F111CCCCCC111110.
def ARC_SUB_z_limm_c : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sub\t$limm, $rc", []> {
  // Opcode: 0x2602703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f> 0,b,limm 00100bbb00000010FBBB111110111110.
def ARC_SUB_z_b_limm : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "sub\t$rb, $limm", []> {
  // Opcode: 0x20020FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000010;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f><.cc> b,b,limm 00100bbb11000010FBBB1111100QQQQQ.
def ARC_SUB_b_limm_cc : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "sub\t$rb, $limm", []> {
  // Opcode: 0x20C20F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f><.cc> 0,limm,c 0010011011000010F111CCCCCC0QQQQQ.
def ARC_SUB_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sub\t$limm, $rc", []> {
  // Opcode: 0x26C27000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f> a,limm,u6 0010011001000010F111uuuuuuAAAAAA.
def ARC_SUB_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26427000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f> 0,limm,u6 0010011001000010F111uuuuuu111110.
def ARC_SUB_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub\t$limm, $uimm6_20", []> {
  // Opcode: 0x2642703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f><.cc> 0,limm,u6 0010011011000010F111uuuuuu1QQQQQ.
def ARC_SUB_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub\t$limm, $uimm6_20", []> {
  // Opcode: 0x26C27020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f> 0,limm,s12 0010011010000010F111ssssssSSSSSS.
def ARC_SUB_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "sub\t$limm, $simm12_20", []> {
  // Opcode: 0x26827000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010000010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f> a,limm,limm 0010011000000010F111111110AAAAAA.
def ARC_SUB_a_limm : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "sub\t$ra, $limm", []> {
  // Opcode: 0x26027F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000010;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f> 0,limm,limm 0010011000000010F111111110111110.
def ARC_SUB_z_limm : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs ), (ins i32imm:$limm),
    "sub\t$limm", []> {
  // Opcode: 0x26027FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000010;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub<.f><.cc> 0,limm,limm 0010011011000010F1111111100QQQQQ.
def ARC_SUB_z_limm_cc : ARCompactInst32_3op<0b00100, 0b000010, "sub",
    (outs ), (ins i32imm:$limm),
    "sub\t$limm", []> {
  // Opcode: 0x26C27F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000010;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f> a,b,c 00100bbb00010111FBBBCCCCCCAAAAAA.
def ARC_SUB1_a_b_c : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "sub1\t$ra, $rb, $rc", []> {
  // Opcode: 0x20170000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sub1<.f> 0,b,c 00100bbb00010111FBBBCCCCCC111110.
def ARC_SUB1_z_b_c : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "sub1\t$rb, $rc", []> {
  // Opcode: 0x2017003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sub1<.f><.cc> b,b,c 00100bbb11010111FBBBCCCCCC0QQQQQ.
def ARC_SUB1_b_c_cc : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "sub1\t$rb, $rc", []> {
  // Opcode: 0x20D70000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sub1<.f> a,b,u6 00100bbb01010111FBBBuuuuuuAAAAAA.
def ARC_SUB1_a_b_u6 : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sub1\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20570000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sub1<.f> 0,b,u6 00100bbb01010111FBBBuuuuuu111110.
def ARC_SUB1_z_b_u6 : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sub1\t$rb, $uimm6_20", []> {
  // Opcode: 0x2057003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01010111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sub1<.f><.cc> b,b,u6 00100bbb11010111FBBBuuuuuu1QQQQQ.
def ARC_SUB1_b_u6_cc : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "sub1\t$rb, $uimm6_20", []> {
  // Opcode: 0x20D70020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sub1<.f> b,b,s12 00100bbb10010111FBBBssssssSSSSSS.
def ARC_SUB1_b_s12 : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "sub1\t$rb, $simm12_20", []> {
  // Opcode: 0x20970000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10010111;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// sub1<.f> a,limm,c 0010011000010111F111CCCCCCAAAAAA.
def ARC_SUB1_a_limm_c : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "sub1\t$ra, $limm, $rc", []> {
  // Opcode: 0x26177000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f> a,b,limm 00100bbb00010111FBBB111110AAAAAA.
def ARC_SUB1_a_b_limm : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "sub1\t$ra, $rb, $limm", []> {
  // Opcode: 0x20170F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010111;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f> 0,limm,c 0010011000010111F111CCCCCC111110.
def ARC_SUB1_z_limm_c : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sub1\t$limm, $rc", []> {
  // Opcode: 0x2617703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f> 0,b,limm 00100bbb00010111FBBB111110111110.
def ARC_SUB1_z_b_limm : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "sub1\t$rb, $limm", []> {
  // Opcode: 0x20170FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00010111;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f><.cc> b,b,limm 00100bbb11010111FBBB1111100QQQQQ.
def ARC_SUB1_b_limm_cc : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "sub1\t$rb, $limm", []> {
  // Opcode: 0x20D70F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11010111;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f><.cc> 0,limm,c 0010011011010111F111CCCCCC0QQQQQ.
def ARC_SUB1_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sub1\t$limm, $rc", []> {
  // Opcode: 0x26D77000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f> a,limm,u6 0010011001010111F111uuuuuuAAAAAA.
def ARC_SUB1_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub1\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26577000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f> 0,limm,u6 0010011001010111F111uuuuuu111110.
def ARC_SUB1_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub1\t$limm, $uimm6_20", []> {
  // Opcode: 0x2657703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001010111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f><.cc> 0,limm,u6 0010011011010111F111uuuuuu1QQQQQ.
def ARC_SUB1_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub1\t$limm, $uimm6_20", []> {
  // Opcode: 0x26D77020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f> 0,limm,s12 0010011010010111F111ssssssSSSSSS.
def ARC_SUB1_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "sub1\t$limm, $simm12_20", []> {
  // Opcode: 0x26977000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010010111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f> a,limm,limm 0010011000010111F111111110AAAAAA.
def ARC_SUB1_a_limm : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "sub1\t$ra, $limm", []> {
  // Opcode: 0x26177F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010111;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f> 0,limm,limm 0010011000010111F111111110111110.
def ARC_SUB1_z_limm : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs ), (ins i32imm:$limm),
    "sub1\t$limm", []> {
  // Opcode: 0x26177FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000010111;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub1<.f><.cc> 0,limm,limm 0010011011010111F1111111100QQQQQ.
def ARC_SUB1_z_limm_cc : ARCompactInst32_3op<0b00100, 0b010111, "sub1",
    (outs ), (ins i32imm:$limm),
    "sub1\t$limm", []> {
  // Opcode: 0x26D77F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011010111;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f> a,b,c 00100bbb00011000FBBBCCCCCCAAAAAA.
def ARC_SUB2_a_b_c : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "sub2\t$ra, $rb, $rc", []> {
  // Opcode: 0x20180000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sub2<.f> 0,b,c 00100bbb00011000FBBBCCCCCC111110.
def ARC_SUB2_z_b_c : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "sub2\t$rb, $rc", []> {
  // Opcode: 0x2018003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sub2<.f><.cc> b,b,c 00100bbb11011000FBBBCCCCCC0QQQQQ.
def ARC_SUB2_b_c_cc : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "sub2\t$rb, $rc", []> {
  // Opcode: 0x20D80000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sub2<.f> a,b,u6 00100bbb01011000FBBBuuuuuuAAAAAA.
def ARC_SUB2_a_b_u6 : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sub2\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20580000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sub2<.f> 0,b,u6 00100bbb01011000FBBBuuuuuu111110.
def ARC_SUB2_z_b_u6 : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sub2\t$rb, $uimm6_20", []> {
  // Opcode: 0x2058003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sub2<.f><.cc> b,b,u6 00100bbb11011000FBBBuuuuuu1QQQQQ.
def ARC_SUB2_b_u6_cc : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "sub2\t$rb, $uimm6_20", []> {
  // Opcode: 0x20D80020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sub2<.f> b,b,s12 00100bbb10011000FBBBssssssSSSSSS.
def ARC_SUB2_b_s12 : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "sub2\t$rb, $simm12_20", []> {
  // Opcode: 0x20980000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10011000;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// sub2<.f> a,limm,c 0010011000011000F111CCCCCCAAAAAA.
def ARC_SUB2_a_limm_c : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "sub2\t$ra, $limm, $rc", []> {
  // Opcode: 0x26187000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f> a,b,limm 00100bbb00011000FBBB111110AAAAAA.
def ARC_SUB2_a_b_limm : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "sub2\t$ra, $rb, $limm", []> {
  // Opcode: 0x20180F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f> 0,limm,c 0010011000011000F111CCCCCC111110.
def ARC_SUB2_z_limm_c : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sub2\t$limm, $rc", []> {
  // Opcode: 0x2618703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f> 0,b,limm 00100bbb00011000FBBB111110111110.
def ARC_SUB2_z_b_limm : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "sub2\t$rb, $limm", []> {
  // Opcode: 0x20180FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f><.cc> b,b,limm 00100bbb11011000FBBB1111100QQQQQ.
def ARC_SUB2_b_limm_cc : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "sub2\t$rb, $limm", []> {
  // Opcode: 0x20D80F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f><.cc> 0,limm,c 0010011011011000F111CCCCCC0QQQQQ.
def ARC_SUB2_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sub2\t$limm, $rc", []> {
  // Opcode: 0x26D87000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f> a,limm,u6 0010011001011000F111uuuuuuAAAAAA.
def ARC_SUB2_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub2\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26587000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f> 0,limm,u6 0010011001011000F111uuuuuu111110.
def ARC_SUB2_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub2\t$limm, $uimm6_20", []> {
  // Opcode: 0x2658703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f><.cc> 0,limm,u6 0010011011011000F111uuuuuu1QQQQQ.
def ARC_SUB2_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub2\t$limm, $uimm6_20", []> {
  // Opcode: 0x26D87020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f> 0,limm,s12 0010011010011000F111ssssssSSSSSS.
def ARC_SUB2_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "sub2\t$limm, $simm12_20", []> {
  // Opcode: 0x26987000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010011000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f> a,limm,limm 0010011000011000F111111110AAAAAA.
def ARC_SUB2_a_limm : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "sub2\t$ra, $limm", []> {
  // Opcode: 0x26187F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f> 0,limm,limm 0010011000011000F111111110111110.
def ARC_SUB2_z_limm : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs ), (ins i32imm:$limm),
    "sub2\t$limm", []> {
  // Opcode: 0x26187FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub2<.f><.cc> 0,limm,limm 0010011011011000F1111111100QQQQQ.
def ARC_SUB2_z_limm_cc : ARCompactInst32_3op<0b00100, 0b011000, "sub2",
    (outs ), (ins i32imm:$limm),
    "sub2\t$limm", []> {
  // Opcode: 0x26D87F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f> a,b,c 00100bbb00011001FBBBCCCCCCAAAAAA.
def ARC_SUB3_a_b_c : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "sub3\t$ra, $rb, $rc", []> {
  // Opcode: 0x20190000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sub3<.f> 0,b,c 00100bbb00011001FBBBCCCCCC111110.
def ARC_SUB3_z_b_c : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "sub3\t$rb, $rc", []> {
  // Opcode: 0x2019003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sub3<.f><.cc> b,b,c 00100bbb11011001FBBBCCCCCC0QQQQQ.
def ARC_SUB3_b_c_cc : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "sub3\t$rb, $rc", []> {
  // Opcode: 0x20D90000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// sub3<.f> a,b,u6 00100bbb01011001FBBBuuuuuuAAAAAA.
def ARC_SUB3_a_b_u6 : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sub3\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20590000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// sub3<.f> 0,b,u6 00100bbb01011001FBBBuuuuuu111110.
def ARC_SUB3_z_b_u6 : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "sub3\t$rb, $uimm6_20", []> {
  // Opcode: 0x2059003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sub3<.f><.cc> b,b,u6 00100bbb11011001FBBBuuuuuu1QQQQQ.
def ARC_SUB3_b_u6_cc : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "sub3\t$rb, $uimm6_20", []> {
  // Opcode: 0x20D90020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// sub3<.f> b,b,s12 00100bbb10011001FBBBssssssSSSSSS.
def ARC_SUB3_b_s12 : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "sub3\t$rb, $simm12_20", []> {
  // Opcode: 0x20990000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10011001;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// sub3<.f> a,limm,c 0010011000011001F111CCCCCCAAAAAA.
def ARC_SUB3_a_limm_c : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "sub3\t$ra, $limm, $rc", []> {
  // Opcode: 0x26197000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f> a,b,limm 00100bbb00011001FBBB111110AAAAAA.
def ARC_SUB3_a_b_limm : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "sub3\t$ra, $rb, $limm", []> {
  // Opcode: 0x20190F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f> 0,limm,c 0010011000011001F111CCCCCC111110.
def ARC_SUB3_z_limm_c : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sub3\t$limm, $rc", []> {
  // Opcode: 0x2619703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f> 0,b,limm 00100bbb00011001FBBB111110111110.
def ARC_SUB3_z_b_limm : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "sub3\t$rb, $limm", []> {
  // Opcode: 0x20190FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f><.cc> b,b,limm 00100bbb11011001FBBB1111100QQQQQ.
def ARC_SUB3_b_limm_cc : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "sub3\t$rb, $limm", []> {
  // Opcode: 0x20D90F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f><.cc> 0,limm,c 0010011011011001F111CCCCCC0QQQQQ.
def ARC_SUB3_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "sub3\t$limm, $rc", []> {
  // Opcode: 0x26D97000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f> a,limm,u6 0010011001011001F111uuuuuuAAAAAA.
def ARC_SUB3_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub3\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26597000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f> 0,limm,u6 0010011001011001F111uuuuuu111110.
def ARC_SUB3_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub3\t$limm, $uimm6_20", []> {
  // Opcode: 0x2659703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f><.cc> 0,limm,u6 0010011011011001F111uuuuuu1QQQQQ.
def ARC_SUB3_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "sub3\t$limm, $uimm6_20", []> {
  // Opcode: 0x26D97020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f> 0,limm,s12 0010011010011001F111ssssssSSSSSS.
def ARC_SUB3_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "sub3\t$limm, $simm12_20", []> {
  // Opcode: 0x26997000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010011001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f> a,limm,limm 0010011000011001F111111110AAAAAA.
def ARC_SUB3_a_limm : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "sub3\t$ra, $limm", []> {
  // Opcode: 0x26197F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f> 0,limm,limm 0010011000011001F111111110111110.
def ARC_SUB3_z_limm : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs ), (ins i32imm:$limm),
    "sub3\t$limm", []> {
  // Opcode: 0x26197FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// sub3<.f><.cc> 0,limm,limm 0010011011011001F1111111100QQQQQ.
def ARC_SUB3_z_limm_cc : ARCompactInst32_3op<0b00100, 0b011001, "sub3",
    (outs ), (ins i32imm:$limm),
    "sub3\t$limm", []> {
  // Opcode: 0x26D97F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f> a,b,c 00101bbb00000111FBBBCCCCCCAAAAAA.
def ARC_SUBS_a_b_c : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "subs\t$ra, $rb, $rc", []> {
  // Opcode: 0x28070000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// subs<.f> 0,b,c 00101bbb00000111FBBBCCCCCC111110.
def ARC_SUBS_z_b_c : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "subs\t$rb, $rc", []> {
  // Opcode: 0x2807003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// subs<.f><.cc> b,b,c 00101bbb11000111FBBBCCCCCC0QQQQQ.
def ARC_SUBS_b_c_cc : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "subs\t$rb, $rc", []> {
  // Opcode: 0x28C70000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// subs<.f> a,b,u6 00101bbb01000111FBBBuuuuuuAAAAAA.
def ARC_SUBS_a_b_u6 : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "subs\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x28470000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// subs<.f> 0,b,u6 00101bbb01000111FBBBuuuuuu111110.
def ARC_SUBS_z_b_u6 : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "subs\t$rb, $uimm6_20", []> {
  // Opcode: 0x2847003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01000111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// subs<.f><.cc> b,b,u6 00101bbb11000111FBBBuuuuuu1QQQQQ.
def ARC_SUBS_b_u6_cc : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "subs\t$rb, $uimm6_20", []> {
  // Opcode: 0x28C70020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// subs<.f> b,b,s12 00101bbb10000111FBBBssssssSSSSSS.
def ARC_SUBS_b_s12 : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "subs\t$rb, $simm12_20", []> {
  // Opcode: 0x28870000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10000111;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// subs<.f> a,limm,c 0010111000000111F111CCCCCCAAAAAA.
def ARC_SUBS_a_limm_c : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "subs\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E077000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f> a,b,limm 00101bbb00000111FBBB111110AAAAAA.
def ARC_SUBS_a_b_limm : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "subs\t$ra, $rb, $limm", []> {
  // Opcode: 0x28070F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000111;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f> 0,limm,c 0010111000000111F111CCCCCC111110.
def ARC_SUBS_z_limm_c : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "subs\t$limm, $rc", []> {
  // Opcode: 0x2E07703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f> 0,b,limm 00101bbb00000111FBBB111110111110.
def ARC_SUBS_z_b_limm : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "subs\t$rb, $limm", []> {
  // Opcode: 0x28070FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00000111;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f> a,limm,c 0010111000000111F111CCCCCCAAAAAA.
def ARC_SUBS_a_limm_c_v1 : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "subs\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E077000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// subs<.f><.cc> b,b,limm 00101bbb11000111FBBB1111100QQQQQ.
def ARC_SUBS_b_limm_cc : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "subs\t$rb, $limm", []> {
  // Opcode: 0x28C70F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11000111;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f><.cc> 0,limm,c 0010111011000111F111CCCCCC0QQQQQ.
def ARC_SUBS_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "subs\t$limm, $rc", []> {
  // Opcode: 0x2EC77000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f> a,limm,u6 0010111001000111F111uuuuuuAAAAAA.
def ARC_SUBS_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "subs\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E477000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f> 0,limm,u6 0010111001000111F111uuuuuu111110.
def ARC_SUBS_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "subs\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E47703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001000111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f><.cc> 0,limm,u6 0010111011000111F111uuuuuu1QQQQQ.
def ARC_SUBS_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "subs\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EC77020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f> 0,limm,s12 0010111010000111F111ssssssSSSSSS.
def ARC_SUBS_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "subs\t$limm, $simm12_20", []> {
  // Opcode: 0x2E877000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010000111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f> a,limm,limm 0010111000000111F111111110AAAAAA.
def ARC_SUBS_a_limm : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "subs\t$ra, $limm", []> {
  // Opcode: 0x2E077F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000111;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f> 0,limm,limm 0010111000000111F111111110111110.
def ARC_SUBS_z_limm : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs ), (ins i32imm:$limm),
    "subs\t$limm", []> {
  // Opcode: 0x2E077FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000000111;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subs<.f><.cc> 0,limm,limm 0010111011000111F1111111100QQQQQ.
def ARC_SUBS_z_limm_cc : ARCompactInst32_3op<0b00101, 0b000111, "subs",
    (outs ), (ins i32imm:$limm),
    "subs\t$limm", []> {
  // Opcode: 0x2EC77F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011000111;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f> a,b,c 00101bbb00101001FBBBCCCCCCAAAAAA.
def ARC_SUBSDW_a_b_c : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "subsdw\t$ra, $rb, $rc", []> {
  // Opcode: 0x28290000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// subsdw<.f> 0,b,c 00101bbb00101001FBBBCCCCCC111110.
def ARC_SUBSDW_z_b_c : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "subsdw\t$rb, $rc", []> {
  // Opcode: 0x2829003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// subsdw<.f><.cc> b,b,c 00101bbb11101001FBBBCCCCCC0QQQQQ.
def ARC_SUBSDW_b_c_cc : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "subsdw\t$rb, $rc", []> {
  // Opcode: 0x28E90000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11101001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// subsdw<.f> a,b,u6 00101bbb01101001FBBBuuuuuuAAAAAA.
def ARC_SUBSDW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "subsdw\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x28690000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// subsdw<.f> 0,b,u6 00101bbb01101001FBBBuuuuuu111110.
def ARC_SUBSDW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "subsdw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2869003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// subsdw<.f><.cc> b,b,u6 00101bbb11101001FBBBuuuuuu1QQQQQ.
def ARC_SUBSDW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "subsdw\t$rb, $uimm6_20", []> {
  // Opcode: 0x28E90020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11101001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// subsdw<.f> b,b,s12 00101bbb10101001FBBBssssssSSSSSS.
def ARC_SUBSDW_b_s12 : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "subsdw\t$rb, $simm12_20", []> {
  // Opcode: 0x28A90000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10101001;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// subsdw<.f> a,limm,c 0010111000101001F111CCCCCCAAAAAA.
def ARC_SUBSDW_a_limm_c : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "subsdw\t$ra, $limm, $rc", []> {
  // Opcode: 0x2E297000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f> a,b,limm 00101bbb00101001FBBB111110AAAAAA.
def ARC_SUBSDW_a_b_limm : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "subsdw\t$ra, $rb, $limm", []> {
  // Opcode: 0x28290F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f> 0,limm,c 0010111000101001F111CCCCCC111110.
def ARC_SUBSDW_z_limm_c : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "subsdw\t$limm, $rc", []> {
  // Opcode: 0x2E29703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f> 0,b,limm 00101bbb00101001FBBB111110111110.
def ARC_SUBSDW_z_b_limm : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "subsdw\t$rb, $limm", []> {
  // Opcode: 0x28290FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f><.cc> b,b,limm 00101bbb11101001FBBB1111100QQQQQ.
def ARC_SUBSDW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "subsdw\t$rb, $limm", []> {
  // Opcode: 0x28E90F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11101001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f><.cc> 0,limm,c 0010111011101001F111CCCCCC0QQQQQ.
def ARC_SUBSDW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "subsdw\t$limm, $rc", []> {
  // Opcode: 0x2EE97000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011101001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f> a,limm,u6 0010111001101001F111uuuuuuAAAAAA.
def ARC_SUBSDW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "subsdw\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x2E697000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f> 0,limm,u6 0010111001101001F111uuuuuu111110.
def ARC_SUBSDW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "subsdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E69703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f><.cc> 0,limm,u6 0010111011101001F111uuuuuu1QQQQQ.
def ARC_SUBSDW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "subsdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EE97020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011101001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f> 0,limm,s12 0010111010101001F111ssssssSSSSSS.
def ARC_SUBSDW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "subsdw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EA97000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010101001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f> a,limm,limm 0010111000101001F111111110AAAAAA.
def ARC_SUBSDW_a_limm : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "subsdw\t$ra, $limm", []> {
  // Opcode: 0x2E297F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f> 0,limm,limm 0010111000101001F111111110111110.
def ARC_SUBSDW_z_limm : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs ), (ins i32imm:$limm),
    "subsdw\t$limm", []> {
  // Opcode: 0x2E297FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// subsdw<.f><.cc> 0,limm,limm 0010111011101001F1111111100QQQQQ.
def ARC_SUBSDW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b101001, "subsdw",
    (outs ), (ins i32imm:$limm),
    "subsdw\t$limm", []> {
  // Opcode: 0x2EE97F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011101001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// swap<.f> b,c 00101bbb00101111FBBBCCCCCC000000.
def ARC_SWAP_b_c : ARCompactInst32_2op<0b00101, 0b000000, "swap",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "swap\t$rb, $rc", []> {
  // Opcode: 0x282F0000, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b000000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// swap<.f> 0,c 0010111000101111F111CCCCCC000000.
def ARC_SWAP_z_c : ARCompactInst32_2op<0b00101, 0b000000, "swap",
    (outs ), (ins GPR32:$rc),
    "swap\t$rc", []> {
  // Opcode: 0x2E2F7000, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000000;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// swap<.f> b,u6 00101bbb01101111FBBBuuuuuu000000.
def ARC_SWAP_b_u6 : ARCompactInst32_2op<0b00101, 0b000000, "swap",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "swap\t$rb, $uimm6_20", []> {
  // Opcode: 0x286F0000, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b000000;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// swap<.f> 0,u6 0010111001101111F111uuuuuu000000.
def ARC_SWAP_z_u6 : ARCompactInst32_2op<0b00101, 0b000000, "swap",
    (outs ), (ins u6imm:$uimm6_20),
    "swap\t$uimm6_20", []> {
  // Opcode: 0x2E6F7000, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b000000;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// swap<.f> b,limm 00101bbb00101111FBBB111110000000.
def ARC_SWAP_b_limm : ARCompactInst32_2op<0b00101, 0b000000, "swap",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "swap\t$rb, $limm", []> {
  // Opcode: 0x282F0F80, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110000000;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// swap<.f> 0,limm 0010111000101111F111111110000000.
def ARC_SWAP_z_limm : ARCompactInst32_2op<0b00101, 0b000000, "swap",
    (outs ), (ins i32imm:$limm),
    "swap\t$limm", []> {
  // Opcode: 0x2E2F7F80, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-0} = 0b111111110000000;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// swape<.f> b,c 00101bbb00101111FBBBCCCCCC001001.
def ARC_SWAPE_b_c : ARCompactInst32_2op<0b00101, 0b001001, "swape",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "swape\t$rb, $rc", []> {
  // Opcode: 0x282F0009, Mask: 0xF8FF003F
  // Operands: RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b001001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// swape<.f> 0,c 0010111000101111F111CCCCCC001001.
def ARC_SWAPE_z_c : ARCompactInst32_2op<0b00101, 0b001001, "swape",
    (outs ), (ins GPR32:$rc),
    "swape\t$rc", []> {
  // Opcode: 0x2E2F7009, Mask: 0xFFFF703F
  // Operands: ZA, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001001;
  let Defs = [STATUS32];
  bits<6> rc;
  let Inst{11-6} = rc;
}

// swape<.f> b,u6 00101bbb01101111FBBBuuuuuu001001.
def ARC_SWAPE_b_u6 : ARCompactInst32_2op<0b00101, 0b001001, "swape",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "swape\t$rb, $uimm6_20", []> {
  // Opcode: 0x286F0009, Mask: 0xF8FF003F
  // Operands: RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b001001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// swape<.f> 0,u6 0010111001101111F111uuuuuu001001.
def ARC_SWAPE_z_u6 : ARCompactInst32_2op<0b00101, 0b001001, "swape",
    (outs ), (ins u6imm:$uimm6_20),
    "swape\t$uimm6_20", []> {
  // Opcode: 0x2E6F7009, Mask: 0xFFFF703F
  // Operands: ZA, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b001001;
  let Defs = [STATUS32];
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// swape<.f> b,limm 00101bbb00101111FBBB111110001001.
def ARC_SWAPE_b_limm : ARCompactInst32_2op<0b00101, 0b001001, "swape",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "swape\t$rb, $limm", []> {
  // Opcode: 0x282F0F89, Mask: 0xF8FF0FFF
  // Operands: RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110001001;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// swape<.f> 0,limm 0010111000101111F111111110001001.
def ARC_SWAPE_z_limm : ARCompactInst32_2op<0b00101, 0b001001, "swape",
    (outs ), (ins i32imm:$limm),
    "swape\t$limm", []> {
  // Opcode: 0x2E2F7F89, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101111;
  let Inst{14-0} = 0b111111110001001;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// tst b,c 00100bbb000010111BBBCCCCCC000000.
def ARC_TST_b_c : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "tst\t$rb, $rc", []> {
  // Opcode: 0x200B8000, Mask: 0xF8FF803F
  // Operands: RB, RC
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b000010111;
  let Inst{5-0} = 0b000000;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// tst<.cc> b,c 00100bbb110010111BBBCCCCCC0QQQQQ.
def ARC_TST_b_c_cc : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "tst\t$rb, $rc", []> {
  // Opcode: 0x20CB8000, Mask: 0xF8FF8020
  // Operands: RB, RC
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110010111;
  let Inst{5} = 0;
  let isPredicable = 1;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// tst b,u6 00100bbb010010111BBBuuuuuu000000.
def ARC_TST_b_u6 : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "tst\t$rb, $uimm6_20", []> {
  // Opcode: 0x204B8000, Mask: 0xF8FF803F
  // Operands: RB, UIMM6_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b010010111;
  let Inst{5-0} = 0b000000;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// tst<.cc> b,u6 00100bbb110010111BBBuuuuuu1QQQQQ.
def ARC_TST_b_u6_cc : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "tst\t$rb, $uimm6_20", []> {
  // Opcode: 0x20CB8020, Mask: 0xF8FF8020
  // Operands: RB, UIMM6_20
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110010111;
  let Inst{5} = 1;
  let isPredicable = 1;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// tst b,s12 00100bbb100010111BBBssssssSSSSSS.
def ARC_TST_b_s12 : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "tst\t$rb, $simm12_20", []> {
  // Opcode: 0x208B8000, Mask: 0xF8FF8000
  // Operands: RB, SIMM12_20
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b100010111;
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// tst limm,c 00100110000010111111CCCCCC000000.
def ARC_TST_limm_c : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "tst\t$limm, $rc", []> {
  // Opcode: 0x260BF000, Mask: 0xFFFFF03F
  // Operands: LIMM, RC
  // Flags: none
  let Inst{31-12} = 0b00100110000010111111;
  let Inst{5-0} = 0b000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// tst b,limm 00100bbb000010111BBB111110000000.
def ARC_TST_b_limm : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "tst\t$rb, $limm", []> {
  // Opcode: 0x200B8F80, Mask: 0xF8FF8FFF
  // Operands: RB, LIMM
  // Flags: none
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b000010111;
  let Inst{11-0} = 0b111110000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// tst<.cc> b,limm 00100bbb110010111BBB1111100QQQQQ.
def ARC_TST_b_limm_cc : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "tst\t$rb, $limm", []> {
  // Opcode: 0x20CB8F80, Mask: 0xF8FF8FE0
  // Operands: RB, LIMM
  // Flags: C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-15} = 0b110010111;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// tst<.cc> limm,c 00100110110010111111CCCCCC0QQQQQ.
def ARC_TST_limm_c_cc : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "tst\t$limm, $rc", []> {
  // Opcode: 0x26CBF000, Mask: 0xFFFFF020
  // Operands: LIMM, RC
  // Flags: C_CC
  let Inst{31-12} = 0b00100110110010111111;
  let Inst{5} = 0;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// tst limm,u6 00100110010010111111uuuuuu000000.
def ARC_TST_limm_u6 : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "tst\t$limm, $uimm6_20", []> {
  // Opcode: 0x264BF000, Mask: 0xFFFFF03F
  // Operands: LIMM, UIMM6_20
  // Flags: none
  let Inst{31-12} = 0b00100110010010111111;
  let Inst{5-0} = 0b000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// tst<.cc> limm,u6 00100110110010111111uuuuuu1QQQQQ.
def ARC_TST_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "tst\t$limm, $uimm6_20", []> {
  // Opcode: 0x26CBF020, Mask: 0xFFFFF020
  // Operands: LIMM, UIMM6_20
  // Flags: C_CC
  let Inst{31-12} = 0b00100110110010111111;
  let Inst{5} = 1;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// tst limm,s12 00100110100010111111ssssssSSSSSS.
def ARC_TST_limm_s12 : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "tst\t$limm, $simm12_20", []> {
  // Opcode: 0x268BF000, Mask: 0xFFFFF000
  // Operands: LIMM, SIMM12_20
  // Flags: none
  let Inst{31-12} = 0b00100110100010111111;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// tst limm,limm 00100110000010111111111110000000.
def ARC_TST_limm : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs ), (ins i32imm:$limm),
    "tst\t$limm", []> {
  // Opcode: 0x260BFF80, Mask: 0xFFFFFFFF
  // Operands: LIMM, LIMMdup
  // Flags: none
  let Inst{31-0} = 0b00100110000010111111111110000000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// tst<.cc> limm,limm 001001101100101111111111100QQQQQ.
def ARC_TST_limm_cc : ARCompactInst32_3op<0b00100, 0b001011, "tst",
    (outs ), (ins i32imm:$limm),
    "tst\t$limm", []> {
  // Opcode: 0x26CBFF80, Mask: 0xFFFFFFE0
  // Operands: LIMM, LIMMdup
  // Flags: C_CC
  let Inst{31-5} = 0b001001101100101111111111100;
  let isPredicable = 1;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// upkqb<.f> a,b,c 00110bbb00100001FBBBCCCCCCAAAAAA.
def ARC_UPKQB_a_b_c : ARCompactInst32_3op<0b00110, 0b100001, "upkqb",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "upkqb\t$ra, $rb, $rc", []> {
  // Opcode: 0x30210000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// upkqb<.f><.cc> b,b,c 00110bbb11100001FBBBCCCCCC0QQQQQ.
def ARC_UPKQB_b_c_cc : ARCompactInst32_3op<0b00110, 0b100001, "upkqb",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "upkqb\t$rb, $rc", []> {
  // Opcode: 0x30E10000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// upkqb<.f> a,b,u6 00110bbb01100001FBBBuuuuuuAAAAAA.
def ARC_UPKQB_a_b_u6 : ARCompactInst32_3op<0b00110, 0b100001, "upkqb",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "upkqb\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30610000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01100001;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// upkqb<.f><.cc> b,b,u6 00110bbb11100001FBBBuuuuuu1QQQQQ.
def ARC_UPKQB_b_u6_cc : ARCompactInst32_3op<0b00110, 0b100001, "upkqb",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "upkqb\t$rb, $uimm6_20", []> {
  // Opcode: 0x30E10020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// upkqb<.f> b,b,s12 00110bbb10100001FBBBssssssSSSSSS.
def ARC_UPKQB_b_s12 : ARCompactInst32_3op<0b00110, 0b100001, "upkqb",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "upkqb\t$rb, $simm12_20", []> {
  // Opcode: 0x30A10000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10100001;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// upkqb<.f> a,limm,c 0011011000100001F111CCCCCCAAAAAA.
def ARC_UPKQB_a_limm_c : ARCompactInst32_3op<0b00110, 0b100001, "upkqb",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "upkqb\t$ra, $limm, $rc", []> {
  // Opcode: 0x36217000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000100001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// upkqb<.f> a,b,limm 00110bbb00100001FBBB111110AAAAAA.
def ARC_UPKQB_a_b_limm : ARCompactInst32_3op<0b00110, 0b100001, "upkqb",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "upkqb\t$ra, $rb, $limm", []> {
  // Opcode: 0x30210F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// upkqb<.f><.cc> b,b,limm 00110bbb11100001FBBB1111100QQQQQ.
def ARC_UPKQB_b_limm_cc : ARCompactInst32_3op<0b00110, 0b100001, "upkqb",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "upkqb\t$rb, $limm", []> {
  // Opcode: 0x30E10F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f> a,b,c 00100bbb00000111FBBBCCCCCCAAAAAA.
def ARC_XOR_a_b_c : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "xor\t$ra, $rb, $rc", []> {
  // Opcode: 0x20070000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// xor<.f> 0,b,c 00100bbb00000111FBBBCCCCCC111110.
def ARC_XOR_z_b_c : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "xor\t$rb, $rc", []> {
  // Opcode: 0x2007003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// xor<.f><.cc> b,b,c 00100bbb11000111FBBBCCCCCC0QQQQQ.
def ARC_XOR_b_c_cc : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "xor\t$rb, $rc", []> {
  // Opcode: 0x20C70000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// xor<.f> a,b,u6 00100bbb01000111FBBBuuuuuuAAAAAA.
def ARC_XOR_a_b_u6 : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "xor\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x20470000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000111;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// xor<.f> 0,b,u6 00100bbb01000111FBBBuuuuuu111110.
def ARC_XOR_z_b_u6 : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "xor\t$rb, $uimm6_20", []> {
  // Opcode: 0x2047003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01000111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// xor<.f><.cc> b,b,u6 00100bbb11000111FBBBuuuuuu1QQQQQ.
def ARC_XOR_b_u6_cc : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "xor\t$rb, $uimm6_20", []> {
  // Opcode: 0x20C70020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// xor<.f> b,b,s12 00100bbb10000111FBBBssssssSSSSSS.
def ARC_XOR_b_s12 : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "xor\t$rb, $simm12_20", []> {
  // Opcode: 0x20870000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10000111;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// xor<.f> a,limm,c 0010011000000111F111CCCCCCAAAAAA.
def ARC_XOR_a_limm_c : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "xor\t$ra, $limm, $rc", []> {
  // Opcode: 0x26077000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f> a,b,limm 00100bbb00000111FBBB111110AAAAAA.
def ARC_XOR_a_b_limm : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "xor\t$ra, $rb, $limm", []> {
  // Opcode: 0x20070F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000111;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f> 0,limm,c 0010011000000111F111CCCCCC111110.
def ARC_XOR_z_limm_c : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "xor\t$limm, $rc", []> {
  // Opcode: 0x2607703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f> 0,b,limm 00100bbb00000111FBBB111110111110.
def ARC_XOR_z_b_limm : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "xor\t$rb, $limm", []> {
  // Opcode: 0x20070FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00000111;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f><.cc> 0,limm,c 0010011011000111F111CCCCCC0QQQQQ.
def ARC_XOR_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "xor\t$limm, $rc", []> {
  // Opcode: 0x26C77000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f><.cc> b,b,limm 00100bbb11000111FBBB1111100QQQQQ.
def ARC_XOR_b_limm_cc : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "xor\t$rb, $limm", []> {
  // Opcode: 0x20C70F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11000111;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f> a,limm,u6 0010011001000111F111uuuuuuAAAAAA.
def ARC_XOR_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "xor\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x26477000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f> 0,limm,u6 0010011001000111F111uuuuuu111110.
def ARC_XOR_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "xor\t$limm, $uimm6_20", []> {
  // Opcode: 0x2647703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001000111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f><.cc> 0,limm,u6 0010011011000111F111uuuuuu1QQQQQ.
def ARC_XOR_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "xor\t$limm, $uimm6_20", []> {
  // Opcode: 0x26C77020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f> 0,limm,s12 0010011010000111F111ssssssSSSSSS.
def ARC_XOR_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "xor\t$limm, $simm12_20", []> {
  // Opcode: 0x26877000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010000111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f> a,limm,limm 0010011000000111F111111110AAAAAA.
def ARC_XOR_a_limm : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "xor\t$ra, $limm", []> {
  // Opcode: 0x26077F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000111;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f> 0,limm,limm 0010011000000111F111111110111110.
def ARC_XOR_z_limm : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs ), (ins i32imm:$limm),
    "xor\t$limm", []> {
  // Opcode: 0x26077FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000000111;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xor<.f><.cc> 0,limm,limm 0010011011000111F1111111100QQQQQ.
def ARC_XOR_z_limm_cc : ARCompactInst32_3op<0b00100, 0b000111, "xor",
    (outs ), (ins i32imm:$limm),
    "xor\t$limm", []> {
  // Opcode: 0x26C77F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011000111;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xpkqb<.f> a,b,c 00110bbb00100010FBBBCCCCCCAAAAAA.
def ARC_XPKQB_a_b_c : ARCompactInst32_3op<0b00110, 0b100010, "xpkqb",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "xpkqb\t$ra, $rb, $rc", []> {
  // Opcode: 0x30220000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// xpkqb<.f><.cc> b,b,c 00110bbb11100010FBBBCCCCCC0QQQQQ.
def ARC_XPKQB_b_c_cc : ARCompactInst32_3op<0b00110, 0b100010, "xpkqb",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "xpkqb\t$rb, $rc", []> {
  // Opcode: 0x30E20000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// xpkqb<.f> a,b,u6 00110bbb01100010FBBBuuuuuuAAAAAA.
def ARC_XPKQB_a_b_u6 : ARCompactInst32_3op<0b00110, 0b100010, "xpkqb",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "xpkqb\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30620000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01100010;
  let Defs = [STATUS32];
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
  bits<6> ra;
  let Inst{5-0} = ra;
}

// xpkqb<.f><.cc> b,b,u6 00110bbb11100010FBBBuuuuuu1QQQQQ.
def ARC_XPKQB_b_u6_cc : ARCompactInst32_3op<0b00110, 0b100010, "xpkqb",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "xpkqb\t$rb, $uimm6_20", []> {
  // Opcode: 0x30E20020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// xpkqb<.f> b,b,s12 00110bbb10100010FBBBssssssSSSSSS.
def ARC_XPKQB_b_s12 : ARCompactInst32_3op<0b00110, 0b100010, "xpkqb",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "xpkqb\t$rb, $simm12_20", []> {
  // Opcode: 0x30A20000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10100010;
  let Defs = [STATUS32];
  
  bits<6> rb;
  let Inst{26-24} = rb{2-0};
  let Inst{14-12} = rb{5-3};
  bits<12> simm12_20;
  let Inst{11-6} = simm12_20{11-6};
  let Inst{5-0} = simm12_20{5-0};
}

// xpkqb<.f> a,limm,c 0011011000100010F111CCCCCCAAAAAA.
def ARC_XPKQB_a_limm_c : ARCompactInst32_3op<0b00110, 0b100010, "xpkqb",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "xpkqb\t$ra, $limm, $rc", []> {
  // Opcode: 0x36227000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000100010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xpkqb<.f> a,b,limm 00110bbb00100010FBBB111110AAAAAA.
def ARC_XPKQB_a_b_limm : ARCompactInst32_3op<0b00110, 0b100010, "xpkqb",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "xpkqb\t$ra, $rb, $limm", []> {
  // Opcode: 0x30220F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// xpkqb<.f><.cc> b,b,limm 00110bbb11100010FBBB1111100QQQQQ.
def ARC_XPKQB_b_limm_cc : ARCompactInst32_3op<0b00110, 0b100010, "xpkqb",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "xpkqb\t$rb, $limm", []> {
  // Opcode: 0x30E20F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

} // end let Predicates = [IsARCompact]
