//===-- ARCARCompactInstrExtArith.td - ARC ARCompact Extended Arithmetic Instructions -*- tablegen -*-===//
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

// 887 instruction variants

let Predicates = [IsARCompact] in {

// cmacrdw<.f> a,b,c 00101bbb00100110FBBBCCCCCCAAAAAA.
def ARC_CMACRDW_a_b_c : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "cmacrdw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28260000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100110;
  let Defs = [STATUS32];
}

// cmacrdw<.f> 0,b,c 00101bbb00100110FBBBCCCCCC111110.
def ARC_CMACRDW_z_b_c : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "cmacrdw\t$rb, $rc", []> {
  // Opcode: 0x2826003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// cmacrdw<.f><.cc> b,b,c 00101bbb11100110FBBBCCCCCC0QQQQQ.
def ARC_CMACRDW_b_c_cc : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "cmacrdw\t$rb_chk, $rc", []> {
  // Opcode: 0x28E60000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11100110;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// cmacrdw<.f> a,b,u6 00101bbb01100110FBBBuuuuuuAAAAAA.
def ARC_CMACRDW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "cmacrdw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28660000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01100110;
  let Defs = [STATUS32];
}

// cmacrdw<.f> 0,b,u6 00101bbb01100110FBBBuuuuuu111110.
def ARC_CMACRDW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "cmacrdw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2866003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01100110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// cmacrdw<.f><.cc> b,b,u6 00101bbb11100110FBBBuuuuuu1QQQQQ.
def ARC_CMACRDW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "cmacrdw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28E60020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11100110;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// cmacrdw<.f> b,b,s12 00101bbb10100110FBBBssssssSSSSSS.
def ARC_CMACRDW_b_s12 : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "cmacrdw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28A60000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10100110;
  let Defs = [STATUS32];
  
}

// cmacrdw<.f> a,limm,c 0010111000100110F111CCCCCCAAAAAA.
def ARC_CMACRDW_a_limm_c : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "cmacrdw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E267000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000100110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// cmacrdw<.f> a,b,limm 00101bbb00100110FBBB111110AAAAAA.
def ARC_CMACRDW_a_b_limm : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "cmacrdw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28260F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100110;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// cmacrdw<.f> 0,limm,c 0010111000100110F111CCCCCC111110.
def ARC_CMACRDW_z_limm_c : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "cmacrdw\t$limm, $rc", []> {
  // Opcode: 0x2E26703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000100110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// cmacrdw<.f> 0,b,limm 00101bbb00100110FBBB111110111110.
def ARC_CMACRDW_z_b_limm : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "cmacrdw\t$rb, $limm", []> {
  // Opcode: 0x28260FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00100110;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// cmacrdw<.f><.cc> 0,limm,c 0010111011100110F111CCCCCC0QQQQQ.
def ARC_CMACRDW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "cmacrdw\t$limm, $rc", []> {
  // Opcode: 0x2EE67000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011100110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// cmacrdw<.f><.cc> b,b,limm 00101bbb11100110FBBB1111100QQQQQ.
def ARC_CMACRDW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "cmacrdw\t$rb_chk, $limm", []> {
  // Opcode: 0x28E60F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11100110;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// cmacrdw<.f> a,limm,u6 0010111001100110F111uuuuuuAAAAAA.
def ARC_CMACRDW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "cmacrdw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E667000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001100110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// cmacrdw<.f> 0,limm,u6 0010111001100110F111uuuuuu111110.
def ARC_CMACRDW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "cmacrdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E66703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001100110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// cmacrdw<.f><.cc> 0,limm,u6 0010111011100110F111uuuuuu1QQQQQ.
def ARC_CMACRDW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "cmacrdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EE67020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011100110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// cmacrdw<.f> 0,limm,s12 0010111010100110F111ssssssSSSSSS.
def ARC_CMACRDW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "cmacrdw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EA67000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010100110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// cmacrdw<.f> a,limm,limm 0010111000100110F111111110AAAAAA.
def ARC_CMACRDW_a_limm : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "cmacrdw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E267F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000100110;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// cmacrdw<.f> 0,limm,limm 0010111000100110F111111110111110.
def ARC_CMACRDW_z_limm : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs ), (ins i32imm:$limm),
    "cmacrdw\t$limm", []> {
  // Opcode: 0x2E267FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000100110;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// cmacrdw<.f><.cc> 0,limm,limm 0010111011100110F1111111100QQQQQ.
def ARC_CMACRDW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b100110, "cmacrdw",
    (outs ), (ins i32imm:$limm),
    "cmacrdw\t$limm", []> {
  // Opcode: 0x2EE67F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011100110;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// crc<.f> a,b,c 00101bbb00101100FBBBCCCCCCAAAAAA.
def ARC_CRC_a_b_c : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "crc\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x282C0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101100;
  let Defs = [STATUS32];
}

// crc<.f> 0,b,c 00101bbb00101100FBBBCCCCCC111110.
def ARC_CRC_z_b_c : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "crc\t$rb, $rc", []> {
  // Opcode: 0x282C003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// crc<.f><.cc> b,b,c 00101bbb11101100FBBBCCCCCC0QQQQQ.
def ARC_CRC_b_c_cc : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "crc\t$rb_chk, $rc", []> {
  // Opcode: 0x28EC0000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11101100;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// crc<.f> a,b,u6 00101bbb01101100FBBBuuuuuuAAAAAA.
def ARC_CRC_a_b_u6 : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "crc\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x286C0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101100;
  let Defs = [STATUS32];
}

// crc<.f> 0,b,u6 00101bbb01101100FBBBuuuuuu111110.
def ARC_CRC_z_b_u6 : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "crc\t$rb, $uimm6_20", []> {
  // Opcode: 0x286C003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01101100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// crc<.f><.cc> b,b,u6 00101bbb11101100FBBBuuuuuu1QQQQQ.
def ARC_CRC_b_u6_cc : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "crc\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28EC0020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11101100;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// crc<.f> b,b,s12 00101bbb10101100FBBBssssssSSSSSS.
def ARC_CRC_b_s12 : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "crc\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28AC0000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10101100;
  let Defs = [STATUS32];
  
}

// crc<.f> a,limm,c 0010111000101100F111CCCCCCAAAAAA.
def ARC_CRC_a_limm_c : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "crc\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E2C7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// crc<.f> a,b,limm 00101bbb00101100FBBB111110AAAAAA.
def ARC_CRC_a_b_limm : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "crc\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x282C0F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101100;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// crc<.f> 0,limm,c 0010111000101100F111CCCCCC111110.
def ARC_CRC_z_limm_c : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "crc\t$limm, $rc", []> {
  // Opcode: 0x2E2C703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// crc<.f> 0,b,limm 00101bbb00101100FBBB111110111110.
def ARC_CRC_z_b_limm : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "crc\t$rb, $limm", []> {
  // Opcode: 0x282C0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00101100;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// crc<.f><.cc> 0,limm,c 0010111011101100F111CCCCCC0QQQQQ.
def ARC_CRC_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "crc\t$limm, $rc", []> {
  // Opcode: 0x2EEC7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011101100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// crc<.f><.cc> b,b,limm 00101bbb11101100FBBB1111100QQQQQ.
def ARC_CRC_b_limm_cc : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "crc\t$rb_chk, $limm", []> {
  // Opcode: 0x28EC0F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11101100;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// crc<.f> a,limm,u6 0010111001101100F111uuuuuuAAAAAA.
def ARC_CRC_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "crc\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E6C7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// crc<.f> 0,limm,u6 0010111001101100F111uuuuuu111110.
def ARC_CRC_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "crc\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E6C703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001101100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// crc<.f><.cc> 0,limm,u6 0010111011101100F111uuuuuu1QQQQQ.
def ARC_CRC_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "crc\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EEC7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011101100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// crc<.f> 0,limm,s12 0010111010101100F111ssssssSSSSSS.
def ARC_CRC_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "crc\t$limm, $simm12_20", []> {
  // Opcode: 0x2EAC7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010101100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// crc<.f> a,limm,limm 0010111000101100F111111110AAAAAA.
def ARC_CRC_a_limm : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "crc\t$ra_chk, $limm", []> {
  // Opcode: 0x2E2C7F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101100;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// crc<.f> 0,limm,limm 0010111000101100F111111110111110.
def ARC_CRC_z_limm : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs ), (ins i32imm:$limm),
    "crc\t$limm", []> {
  // Opcode: 0x2E2C7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000101100;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// crc<.f><.cc> 0,limm,limm 0010111011101100F1111111100QQQQQ.
def ARC_CRC_z_limm_cc : ARCompactInst32_3op<0b00101, 0b101100, "crc",
    (outs ), (ins i32imm:$limm),
    "crc\t$limm", []> {
  // Opcode: 0x2EEC7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011101100;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh11<.f> a,b,c 00110bbb00001100FBBBCCCCCCAAAAAA.
def ARC_DADDH11_a_b_c : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "daddh11\t$ra, $rb, $rc", []> {
  // Opcode: 0x300C0000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001100;
  let Defs = [STATUS32];
}

// daddh11<.f> 0,b,c 00110bbb00001100FBBBCCCCCC111110.
def ARC_DADDH11_z_b_c : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "daddh11\t$rb, $rc", []> {
  // Opcode: 0x300C003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh11<.f><.cc> b,b,c 00110bbb11001100FBBBCCCCCC0QQQQQ.
def ARC_DADDH11_b_c_cc : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "daddh11\t$rb, $rc", []> {
  // Opcode: 0x30CC0000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001100;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh11<.f> a,b,u6 00110bbb01001100FBBBuuuuuuAAAAAA.
def ARC_DADDH11_a_b_u6 : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "daddh11\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x304C0000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001100;
  let Defs = [STATUS32];
}

// daddh11<.f> 0,b,u6 00110bbb01001100FBBBuuuuuu111110.
def ARC_DADDH11_z_b_u6 : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "daddh11\t$rb, $uimm6_20", []> {
  // Opcode: 0x304C003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh11<.f><.cc> b,b,u6 00110bbb11001100FBBBuuuuuu1QQQQQ.
def ARC_DADDH11_b_u6_cc : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "daddh11\t$rb, $uimm6_20", []> {
  // Opcode: 0x30CC0020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001100;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh11<.f> b,b,s12 00110bbb10001100FBBBssssssSSSSSS.
def ARC_DADDH11_b_s12 : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "daddh11\t$rb, $simm12_20", []> {
  // Opcode: 0x308C0000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10001100;
  let Defs = [STATUS32];
  
}

// daddh11<.f> a,limm,c 0011011000001100F111CCCCCCAAAAAA.
def ARC_DADDH11_a_limm_c : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "daddh11\t$ra, $limm, $rc", []> {
  // Opcode: 0x360C7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh11<.f> a,b,limm 00110bbb00001100FBBB111110AAAAAA.
def ARC_DADDH11_a_b_limm : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "daddh11\t$ra, $rb, $limm", []> {
  // Opcode: 0x300C0F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001100;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// daddh11<.f> 0,limm,c 0011011000001100F111CCCCCC111110.
def ARC_DADDH11_z_limm_c : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "daddh11\t$limm, $rc", []> {
  // Opcode: 0x360C703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh11<.f> 0,b,limm 00110bbb00001100FBBB111110111110.
def ARC_DADDH11_z_b_limm : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "daddh11\t$rb, $limm", []> {
  // Opcode: 0x300C0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001100;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// daddh11<.f><.cc> 0,limm,c 0011011011001100F111CCCCCC0QQQQQ.
def ARC_DADDH11_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "daddh11\t$limm, $rc", []> {
  // Opcode: 0x36CC7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh11<.f><.cc> b,b,limm 00110bbb11001100FBBB1111100QQQQQ.
def ARC_DADDH11_b_limm_cc : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "daddh11\t$rb, $limm", []> {
  // Opcode: 0x30CC0F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001100;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh11<.f> a,limm,u6 0011011001001100F111uuuuuuAAAAAA.
def ARC_DADDH11_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh11\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x364C7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh11<.f> 0,limm,u6 0011011001001100F111uuuuuu111110.
def ARC_DADDH11_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh11\t$limm, $uimm6_20", []> {
  // Opcode: 0x364C703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh11<.f><.cc> 0,limm,u6 0011011011001100F111uuuuuu1QQQQQ.
def ARC_DADDH11_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh11\t$limm, $uimm6_20", []> {
  // Opcode: 0x36CC7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh11<.f> 0,limm,s12 0011011010001100F111ssssssSSSSSS.
def ARC_DADDH11_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "daddh11\t$limm, $simm12_20", []> {
  // Opcode: 0x368C7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010001100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh11<.f> a,limm,limm 0011011000001100F111111110AAAAAA.
def ARC_DADDH11_a_limm : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "daddh11\t$ra, $limm", []> {
  // Opcode: 0x360C7F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001100;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// daddh11<.f> 0,limm,limm 0011011000001100F111111110111110.
def ARC_DADDH11_z_limm : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs ), (ins i32imm:$limm),
    "daddh11\t$limm", []> {
  // Opcode: 0x360C7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001100;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// daddh11<.f><.cc> 0,limm,limm 0011011011001100F1111111100QQQQQ.
def ARC_DADDH11_z_limm_cc : ARCompactInst32_3op<0b00110, 0b001100, "daddh11",
    (outs ), (ins i32imm:$limm),
    "daddh11\t$limm", []> {
  // Opcode: 0x36CC7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001100;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh12<.f> a,b,c 00110bbb00001101FBBBCCCCCCAAAAAA.
def ARC_DADDH12_a_b_c : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "daddh12\t$ra, $rb, $rc", []> {
  // Opcode: 0x300D0000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001101;
  let Defs = [STATUS32];
}

// daddh12<.f> 0,b,c 00110bbb00001101FBBBCCCCCC111110.
def ARC_DADDH12_z_b_c : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "daddh12\t$rb, $rc", []> {
  // Opcode: 0x300D003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh12<.f><.cc> b,b,c 00110bbb11001101FBBBCCCCCC0QQQQQ.
def ARC_DADDH12_b_c_cc : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "daddh12\t$rb, $rc", []> {
  // Opcode: 0x30CD0000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001101;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh12<.f> a,b,u6 00110bbb01001101FBBBuuuuuuAAAAAA.
def ARC_DADDH12_a_b_u6 : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "daddh12\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x304D0000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001101;
  let Defs = [STATUS32];
}

// daddh12<.f> 0,b,u6 00110bbb01001101FBBBuuuuuu111110.
def ARC_DADDH12_z_b_u6 : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "daddh12\t$rb, $uimm6_20", []> {
  // Opcode: 0x304D003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh12<.f><.cc> b,b,u6 00110bbb11001101FBBBuuuuuu1QQQQQ.
def ARC_DADDH12_b_u6_cc : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "daddh12\t$rb, $uimm6_20", []> {
  // Opcode: 0x30CD0020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001101;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh12<.f> b,b,s12 00110bbb10001101FBBBssssssSSSSSS.
def ARC_DADDH12_b_s12 : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "daddh12\t$rb, $simm12_20", []> {
  // Opcode: 0x308D0000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10001101;
  let Defs = [STATUS32];
  
}

// daddh12<.f> a,limm,c 0011011000001101F111CCCCCCAAAAAA.
def ARC_DADDH12_a_limm_c : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "daddh12\t$ra, $limm, $rc", []> {
  // Opcode: 0x360D7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh12<.f> a,b,limm 00110bbb00001101FBBB111110AAAAAA.
def ARC_DADDH12_a_b_limm : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "daddh12\t$ra, $rb, $limm", []> {
  // Opcode: 0x300D0F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001101;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// daddh12<.f> 0,limm,c 0011011000001101F111CCCCCC111110.
def ARC_DADDH12_z_limm_c : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "daddh12\t$limm, $rc", []> {
  // Opcode: 0x360D703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh12<.f> 0,b,limm 00110bbb00001101FBBB111110111110.
def ARC_DADDH12_z_b_limm : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "daddh12\t$rb, $limm", []> {
  // Opcode: 0x300D0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001101;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// daddh12<.f><.cc> 0,limm,c 0011011011001101F111CCCCCC0QQQQQ.
def ARC_DADDH12_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "daddh12\t$limm, $rc", []> {
  // Opcode: 0x36CD7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh12<.f><.cc> b,b,limm 00110bbb11001101FBBB1111100QQQQQ.
def ARC_DADDH12_b_limm_cc : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "daddh12\t$rb, $limm", []> {
  // Opcode: 0x30CD0F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001101;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh12<.f> a,limm,u6 0011011001001101F111uuuuuuAAAAAA.
def ARC_DADDH12_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh12\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x364D7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh12<.f> 0,limm,u6 0011011001001101F111uuuuuu111110.
def ARC_DADDH12_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh12\t$limm, $uimm6_20", []> {
  // Opcode: 0x364D703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh12<.f><.cc> 0,limm,u6 0011011011001101F111uuuuuu1QQQQQ.
def ARC_DADDH12_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh12\t$limm, $uimm6_20", []> {
  // Opcode: 0x36CD7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh12<.f> 0,limm,s12 0011011010001101F111ssssssSSSSSS.
def ARC_DADDH12_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "daddh12\t$limm, $simm12_20", []> {
  // Opcode: 0x368D7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010001101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh12<.f> a,limm,limm 0011011000001101F111111110AAAAAA.
def ARC_DADDH12_a_limm : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "daddh12\t$ra, $limm", []> {
  // Opcode: 0x360D7F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001101;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// daddh12<.f> 0,limm,limm 0011011000001101F111111110111110.
def ARC_DADDH12_z_limm : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs ), (ins i32imm:$limm),
    "daddh12\t$limm", []> {
  // Opcode: 0x360D7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001101;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// daddh12<.f><.cc> 0,limm,limm 0011011011001101F1111111100QQQQQ.
def ARC_DADDH12_z_limm_cc : ARCompactInst32_3op<0b00110, 0b001101, "daddh12",
    (outs ), (ins i32imm:$limm),
    "daddh12\t$limm", []> {
  // Opcode: 0x36CD7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001101;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh21<.f> a,b,c 00110bbb00001110FBBBCCCCCCAAAAAA.
def ARC_DADDH21_a_b_c : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "daddh21\t$ra, $rb, $rc", []> {
  // Opcode: 0x300E0000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001110;
  let Defs = [STATUS32];
}

// daddh21<.f> 0,b,c 00110bbb00001110FBBBCCCCCC111110.
def ARC_DADDH21_z_b_c : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "daddh21\t$rb, $rc", []> {
  // Opcode: 0x300E003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh21<.f><.cc> b,b,c 00110bbb11001110FBBBCCCCCC0QQQQQ.
def ARC_DADDH21_b_c_cc : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "daddh21\t$rb, $rc", []> {
  // Opcode: 0x30CE0000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001110;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh21<.f> a,b,u6 00110bbb01001110FBBBuuuuuuAAAAAA.
def ARC_DADDH21_a_b_u6 : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "daddh21\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x304E0000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001110;
  let Defs = [STATUS32];
}

// daddh21<.f> 0,b,u6 00110bbb01001110FBBBuuuuuu111110.
def ARC_DADDH21_z_b_u6 : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "daddh21\t$rb, $uimm6_20", []> {
  // Opcode: 0x304E003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh21<.f><.cc> b,b,u6 00110bbb11001110FBBBuuuuuu1QQQQQ.
def ARC_DADDH21_b_u6_cc : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "daddh21\t$rb, $uimm6_20", []> {
  // Opcode: 0x30CE0020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001110;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh21<.f> b,b,s12 00110bbb10001110FBBBssssssSSSSSS.
def ARC_DADDH21_b_s12 : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "daddh21\t$rb, $simm12_20", []> {
  // Opcode: 0x308E0000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10001110;
  let Defs = [STATUS32];
  
}

// daddh21<.f> a,limm,c 0011011000001110F111CCCCCCAAAAAA.
def ARC_DADDH21_a_limm_c : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "daddh21\t$ra, $limm, $rc", []> {
  // Opcode: 0x360E7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh21<.f> a,b,limm 00110bbb00001110FBBB111110AAAAAA.
def ARC_DADDH21_a_b_limm : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "daddh21\t$ra, $rb, $limm", []> {
  // Opcode: 0x300E0F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001110;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// daddh21<.f> 0,limm,c 0011011000001110F111CCCCCC111110.
def ARC_DADDH21_z_limm_c : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "daddh21\t$limm, $rc", []> {
  // Opcode: 0x360E703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh21<.f> 0,b,limm 00110bbb00001110FBBB111110111110.
def ARC_DADDH21_z_b_limm : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "daddh21\t$rb, $limm", []> {
  // Opcode: 0x300E0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001110;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// daddh21<.f><.cc> 0,limm,c 0011011011001110F111CCCCCC0QQQQQ.
def ARC_DADDH21_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "daddh21\t$limm, $rc", []> {
  // Opcode: 0x36CE7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh21<.f><.cc> b,b,limm 00110bbb11001110FBBB1111100QQQQQ.
def ARC_DADDH21_b_limm_cc : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "daddh21\t$rb, $limm", []> {
  // Opcode: 0x30CE0F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001110;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh21<.f> a,limm,u6 0011011001001110F111uuuuuuAAAAAA.
def ARC_DADDH21_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh21\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x364E7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh21<.f> 0,limm,u6 0011011001001110F111uuuuuu111110.
def ARC_DADDH21_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh21\t$limm, $uimm6_20", []> {
  // Opcode: 0x364E703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh21<.f><.cc> 0,limm,u6 0011011011001110F111uuuuuu1QQQQQ.
def ARC_DADDH21_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh21\t$limm, $uimm6_20", []> {
  // Opcode: 0x36CE7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh21<.f> 0,limm,s12 0011011010001110F111ssssssSSSSSS.
def ARC_DADDH21_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "daddh21\t$limm, $simm12_20", []> {
  // Opcode: 0x368E7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010001110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh21<.f> a,limm,limm 0011011000001110F111111110AAAAAA.
def ARC_DADDH21_a_limm : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "daddh21\t$ra, $limm", []> {
  // Opcode: 0x360E7F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001110;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// daddh21<.f> 0,limm,limm 0011011000001110F111111110111110.
def ARC_DADDH21_z_limm : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs ), (ins i32imm:$limm),
    "daddh21\t$limm", []> {
  // Opcode: 0x360E7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001110;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// daddh21<.f><.cc> 0,limm,limm 0011011011001110F1111111100QQQQQ.
def ARC_DADDH21_z_limm_cc : ARCompactInst32_3op<0b00110, 0b001110, "daddh21",
    (outs ), (ins i32imm:$limm),
    "daddh21\t$limm", []> {
  // Opcode: 0x36CE7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001110;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh22<.f> a,b,c 00110bbb00001111FBBBCCCCCCAAAAAA.
def ARC_DADDH22_a_b_c : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "daddh22\t$ra, $rb, $rc", []> {
  // Opcode: 0x300F0000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001111;
  let Defs = [STATUS32];
}

// daddh22<.f> 0,b,c 00110bbb00001111FBBBCCCCCC111110.
def ARC_DADDH22_z_b_c : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "daddh22\t$rb, $rc", []> {
  // Opcode: 0x300F003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh22<.f><.cc> b,b,c 00110bbb11001111FBBBCCCCCC0QQQQQ.
def ARC_DADDH22_b_c_cc : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "daddh22\t$rb, $rc", []> {
  // Opcode: 0x30CF0000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh22<.f> a,b,u6 00110bbb01001111FBBBuuuuuuAAAAAA.
def ARC_DADDH22_a_b_u6 : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "daddh22\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x304F0000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001111;
  let Defs = [STATUS32];
}

// daddh22<.f> 0,b,u6 00110bbb01001111FBBBuuuuuu111110.
def ARC_DADDH22_z_b_u6 : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "daddh22\t$rb, $uimm6_20", []> {
  // Opcode: 0x304F003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh22<.f><.cc> b,b,u6 00110bbb11001111FBBBuuuuuu1QQQQQ.
def ARC_DADDH22_b_u6_cc : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "daddh22\t$rb, $uimm6_20", []> {
  // Opcode: 0x30CF0020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh22<.f> b,b,s12 00110bbb10001111FBBBssssssSSSSSS.
def ARC_DADDH22_b_s12 : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "daddh22\t$rb, $simm12_20", []> {
  // Opcode: 0x308F0000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10001111;
  let Defs = [STATUS32];
  
}

// daddh22<.f> a,limm,c 0011011000001111F111CCCCCCAAAAAA.
def ARC_DADDH22_a_limm_c : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "daddh22\t$ra, $limm, $rc", []> {
  // Opcode: 0x360F7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh22<.f> a,b,limm 00110bbb00001111FBBB111110AAAAAA.
def ARC_DADDH22_a_b_limm : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "daddh22\t$ra, $rb, $limm", []> {
  // Opcode: 0x300F0F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001111;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// daddh22<.f> 0,limm,c 0011011000001111F111CCCCCC111110.
def ARC_DADDH22_z_limm_c : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "daddh22\t$limm, $rc", []> {
  // Opcode: 0x360F703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh22<.f> 0,b,limm 00110bbb00001111FBBB111110111110.
def ARC_DADDH22_z_b_limm : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "daddh22\t$rb, $limm", []> {
  // Opcode: 0x300F0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001111;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// daddh22<.f><.cc> 0,limm,c 0011011011001111F111CCCCCC0QQQQQ.
def ARC_DADDH22_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "daddh22\t$limm, $rc", []> {
  // Opcode: 0x36CF7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh22<.f><.cc> b,b,limm 00110bbb11001111FBBB1111100QQQQQ.
def ARC_DADDH22_b_limm_cc : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "daddh22\t$rb, $limm", []> {
  // Opcode: 0x30CF0F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001111;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// daddh22<.f> a,limm,u6 0011011001001111F111uuuuuuAAAAAA.
def ARC_DADDH22_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh22\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x364F7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh22<.f> 0,limm,u6 0011011001001111F111uuuuuu111110.
def ARC_DADDH22_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh22\t$limm, $uimm6_20", []> {
  // Opcode: 0x364F703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// daddh22<.f><.cc> 0,limm,u6 0011011011001111F111uuuuuu1QQQQQ.
def ARC_DADDH22_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "daddh22\t$limm, $uimm6_20", []> {
  // Opcode: 0x36CF7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// daddh22<.f> 0,limm,s12 0011011010001111F111ssssssSSSSSS.
def ARC_DADDH22_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "daddh22\t$limm, $simm12_20", []> {
  // Opcode: 0x368F7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010001111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// daddh22<.f> a,limm,limm 0011011000001111F111111110AAAAAA.
def ARC_DADDH22_a_limm : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "daddh22\t$ra, $limm", []> {
  // Opcode: 0x360F7F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001111;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// daddh22<.f> 0,limm,limm 0011011000001111F111111110111110.
def ARC_DADDH22_z_limm : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs ), (ins i32imm:$limm),
    "daddh22\t$limm", []> {
  // Opcode: 0x360F7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001111;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// daddh22<.f><.cc> 0,limm,limm 0011011011001111F1111111100QQQQQ.
def ARC_DADDH22_z_limm_cc : ARCompactInst32_3op<0b00110, 0b001111, "daddh22",
    (outs ), (ins i32imm:$limm),
    "daddh22\t$limm", []> {
  // Opcode: 0x36CF7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001111;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dexcl1<.f> a,b,c 00110bbb00011000FBBBCCCCCCAAAAAA.
def ARC_DEXCL1_a_b_c : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "dexcl1\t$ra, $rb, $rc", []> {
  // Opcode: 0x30180000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00011000;
  let Defs = [STATUS32];
}

// dexcl1<.f> 0,b,c 00110bbb00011000FBBBCCCCCC111110.
def ARC_DEXCL1_z_b_c : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "dexcl1\t$rb, $rc", []> {
  // Opcode: 0x3018003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00011000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dexcl1<.f><.cc> b,b,c 00110bbb11011000FBBBCCCCCC0QQQQQ.
def ARC_DEXCL1_b_c_cc : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "dexcl1\t$rb, $rc", []> {
  // Opcode: 0x30D80000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11011000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dexcl1<.f> a,b,u6 00110bbb01011000FBBBuuuuuuAAAAAA.
def ARC_DEXCL1_a_b_u6 : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dexcl1\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30580000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01011000;
  let Defs = [STATUS32];
}

// dexcl1<.f> 0,b,u6 00110bbb01011000FBBBuuuuuu111110.
def ARC_DEXCL1_z_b_u6 : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dexcl1\t$rb, $uimm6_20", []> {
  // Opcode: 0x3058003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01011000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dexcl1<.f><.cc> b,b,u6 00110bbb11011000FBBBuuuuuu1QQQQQ.
def ARC_DEXCL1_b_u6_cc : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "dexcl1\t$rb, $uimm6_20", []> {
  // Opcode: 0x30D80020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11011000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dexcl1<.f> b,b,s12 00110bbb10011000FBBBssssssSSSSSS.
def ARC_DEXCL1_b_s12 : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "dexcl1\t$rb, $simm12_20", []> {
  // Opcode: 0x30980000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10011000;
  let Defs = [STATUS32];
  
}

// dexcl1<.f> a,limm,c 0011011000011000F111CCCCCCAAAAAA.
def ARC_DEXCL1_a_limm_c : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "dexcl1\t$ra, $limm, $rc", []> {
  // Opcode: 0x36187000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000011000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dexcl1<.f> a,b,limm 00110bbb00011000FBBB111110AAAAAA.
def ARC_DEXCL1_a_b_limm : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "dexcl1\t$ra, $rb, $limm", []> {
  // Opcode: 0x30180F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00011000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// dexcl1<.f> 0,limm,c 0011011000011000F111CCCCCC111110.
def ARC_DEXCL1_z_limm_c : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dexcl1\t$limm, $rc", []> {
  // Opcode: 0x3618703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000011000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dexcl1<.f> 0,b,limm 00110bbb00011000FBBB111110111110.
def ARC_DEXCL1_z_b_limm : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "dexcl1\t$rb, $limm", []> {
  // Opcode: 0x30180FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00011000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// dexcl1<.f><.cc> 0,limm,c 0011011011011000F111CCCCCC0QQQQQ.
def ARC_DEXCL1_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dexcl1\t$limm, $rc", []> {
  // Opcode: 0x36D87000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011011000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dexcl1<.f><.cc> b,b,limm 00110bbb11011000FBBB1111100QQQQQ.
def ARC_DEXCL1_b_limm_cc : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "dexcl1\t$rb, $limm", []> {
  // Opcode: 0x30D80F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11011000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dexcl1<.f> a,limm,u6 0011011001011000F111uuuuuuAAAAAA.
def ARC_DEXCL1_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dexcl1\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36587000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001011000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dexcl1<.f> 0,limm,u6 0011011001011000F111uuuuuu111110.
def ARC_DEXCL1_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dexcl1\t$limm, $uimm6_20", []> {
  // Opcode: 0x3658703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001011000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dexcl1<.f><.cc> 0,limm,u6 0011011011011000F111uuuuuu1QQQQQ.
def ARC_DEXCL1_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dexcl1\t$limm, $uimm6_20", []> {
  // Opcode: 0x36D87020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011011000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dexcl1<.f> 0,limm,s12 0011011010011000F111ssssssSSSSSS.
def ARC_DEXCL1_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "dexcl1\t$limm, $simm12_20", []> {
  // Opcode: 0x36987000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010011000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dexcl1<.f> a,limm,limm 0011011000011000F111111110AAAAAA.
def ARC_DEXCL1_a_limm : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "dexcl1\t$ra, $limm", []> {
  // Opcode: 0x36187F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000011000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// dexcl1<.f> 0,limm,limm 0011011000011000F111111110111110.
def ARC_DEXCL1_z_limm : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs ), (ins i32imm:$limm),
    "dexcl1\t$limm", []> {
  // Opcode: 0x36187FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000011000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// dexcl1<.f><.cc> 0,limm,limm 0011011011011000F1111111100QQQQQ.
def ARC_DEXCL1_z_limm_cc : ARCompactInst32_3op<0b00110, 0b011000, "dexcl1",
    (outs ), (ins i32imm:$limm),
    "dexcl1\t$limm", []> {
  // Opcode: 0x36D87F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011011000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dexcl2<.f> a,b,c 00110bbb00011001FBBBCCCCCCAAAAAA.
def ARC_DEXCL2_a_b_c : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "dexcl2\t$ra, $rb, $rc", []> {
  // Opcode: 0x30190000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00011001;
  let Defs = [STATUS32];
}

// dexcl2<.f> 0,b,c 00110bbb00011001FBBBCCCCCC111110.
def ARC_DEXCL2_z_b_c : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "dexcl2\t$rb, $rc", []> {
  // Opcode: 0x3019003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00011001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dexcl2<.f><.cc> b,b,c 00110bbb11011001FBBBCCCCCC0QQQQQ.
def ARC_DEXCL2_b_c_cc : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "dexcl2\t$rb, $rc", []> {
  // Opcode: 0x30D90000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11011001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dexcl2<.f> a,b,u6 00110bbb01011001FBBBuuuuuuAAAAAA.
def ARC_DEXCL2_a_b_u6 : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dexcl2\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30590000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01011001;
  let Defs = [STATUS32];
}

// dexcl2<.f> 0,b,u6 00110bbb01011001FBBBuuuuuu111110.
def ARC_DEXCL2_z_b_u6 : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dexcl2\t$rb, $uimm6_20", []> {
  // Opcode: 0x3059003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01011001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dexcl2<.f><.cc> b,b,u6 00110bbb11011001FBBBuuuuuu1QQQQQ.
def ARC_DEXCL2_b_u6_cc : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "dexcl2\t$rb, $uimm6_20", []> {
  // Opcode: 0x30D90020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11011001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dexcl2<.f> b,b,s12 00110bbb10011001FBBBssssssSSSSSS.
def ARC_DEXCL2_b_s12 : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "dexcl2\t$rb, $simm12_20", []> {
  // Opcode: 0x30990000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10011001;
  let Defs = [STATUS32];
  
}

// dexcl2<.f> a,limm,c 0011011000011001F111CCCCCCAAAAAA.
def ARC_DEXCL2_a_limm_c : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "dexcl2\t$ra, $limm, $rc", []> {
  // Opcode: 0x36197000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000011001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dexcl2<.f> a,b,limm 00110bbb00011001FBBB111110AAAAAA.
def ARC_DEXCL2_a_b_limm : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "dexcl2\t$ra, $rb, $limm", []> {
  // Opcode: 0x30190F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00011001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// dexcl2<.f> 0,limm,c 0011011000011001F111CCCCCC111110.
def ARC_DEXCL2_z_limm_c : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dexcl2\t$limm, $rc", []> {
  // Opcode: 0x3619703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000011001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dexcl2<.f> 0,b,limm 00110bbb00011001FBBB111110111110.
def ARC_DEXCL2_z_b_limm : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "dexcl2\t$rb, $limm", []> {
  // Opcode: 0x30190FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00011001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// dexcl2<.f><.cc> 0,limm,c 0011011011011001F111CCCCCC0QQQQQ.
def ARC_DEXCL2_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dexcl2\t$limm, $rc", []> {
  // Opcode: 0x36D97000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011011001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dexcl2<.f><.cc> b,b,limm 00110bbb11011001FBBB1111100QQQQQ.
def ARC_DEXCL2_b_limm_cc : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "dexcl2\t$rb, $limm", []> {
  // Opcode: 0x30D90F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11011001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dexcl2<.f> a,limm,u6 0011011001011001F111uuuuuuAAAAAA.
def ARC_DEXCL2_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dexcl2\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36597000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001011001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dexcl2<.f> 0,limm,u6 0011011001011001F111uuuuuu111110.
def ARC_DEXCL2_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dexcl2\t$limm, $uimm6_20", []> {
  // Opcode: 0x3659703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001011001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dexcl2<.f><.cc> 0,limm,u6 0011011011011001F111uuuuuu1QQQQQ.
def ARC_DEXCL2_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dexcl2\t$limm, $uimm6_20", []> {
  // Opcode: 0x36D97020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011011001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dexcl2<.f> 0,limm,s12 0011011010011001F111ssssssSSSSSS.
def ARC_DEXCL2_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "dexcl2\t$limm, $simm12_20", []> {
  // Opcode: 0x36997000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010011001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dexcl2<.f> a,limm,limm 0011011000011001F111111110AAAAAA.
def ARC_DEXCL2_a_limm : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "dexcl2\t$ra, $limm", []> {
  // Opcode: 0x36197F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000011001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// dexcl2<.f> 0,limm,limm 0011011000011001F111111110111110.
def ARC_DEXCL2_z_limm : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs ), (ins i32imm:$limm),
    "dexcl2\t$limm", []> {
  // Opcode: 0x36197FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000011001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// dexcl2<.f><.cc> 0,limm,limm 0011011011011001F1111111100QQQQQ.
def ARC_DEXCL2_z_limm_cc : ARCompactInst32_3op<0b00110, 0b011001, "dexcl2",
    (outs ), (ins i32imm:$limm),
    "dexcl2\t$limm", []> {
  // Opcode: 0x36D97F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011011001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh11<.f> a,b,c 00110bbb00001000FBBBCCCCCCAAAAAA.
def ARC_DMULH11_a_b_c : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "dmulh11\t$ra, $rb, $rc", []> {
  // Opcode: 0x30080000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001000;
  let Defs = [STATUS32];
}

// dmulh11<.f> 0,b,c 00110bbb00001000FBBBCCCCCC111110.
def ARC_DMULH11_z_b_c : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "dmulh11\t$rb, $rc", []> {
  // Opcode: 0x3008003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh11<.f><.cc> b,b,c 00110bbb11001000FBBBCCCCCC0QQQQQ.
def ARC_DMULH11_b_c_cc : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "dmulh11\t$rb, $rc", []> {
  // Opcode: 0x30C80000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh11<.f> a,b,u6 00110bbb01001000FBBBuuuuuuAAAAAA.
def ARC_DMULH11_a_b_u6 : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dmulh11\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30480000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001000;
  let Defs = [STATUS32];
}

// dmulh11<.f> 0,b,u6 00110bbb01001000FBBBuuuuuu111110.
def ARC_DMULH11_z_b_u6 : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dmulh11\t$rb, $uimm6_20", []> {
  // Opcode: 0x3048003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh11<.f><.cc> b,b,u6 00110bbb11001000FBBBuuuuuu1QQQQQ.
def ARC_DMULH11_b_u6_cc : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "dmulh11\t$rb, $uimm6_20", []> {
  // Opcode: 0x30C80020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh11<.f> b,b,s12 00110bbb10001000FBBBssssssSSSSSS.
def ARC_DMULH11_b_s12 : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "dmulh11\t$rb, $simm12_20", []> {
  // Opcode: 0x30880000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10001000;
  let Defs = [STATUS32];
  
}

// dmulh11<.f> a,limm,c 0011011000001000F111CCCCCCAAAAAA.
def ARC_DMULH11_a_limm_c : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "dmulh11\t$ra, $limm, $rc", []> {
  // Opcode: 0x36087000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh11<.f> a,b,limm 00110bbb00001000FBBB111110AAAAAA.
def ARC_DMULH11_a_b_limm : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "dmulh11\t$ra, $rb, $limm", []> {
  // Opcode: 0x30080F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh11<.f> 0,limm,c 0011011000001000F111CCCCCC111110.
def ARC_DMULH11_z_limm_c : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dmulh11\t$limm, $rc", []> {
  // Opcode: 0x3608703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh11<.f> 0,b,limm 00110bbb00001000FBBB111110111110.
def ARC_DMULH11_z_b_limm : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "dmulh11\t$rb, $limm", []> {
  // Opcode: 0x30080FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// dmulh11<.f><.cc> 0,limm,c 0011011011001000F111CCCCCC0QQQQQ.
def ARC_DMULH11_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dmulh11\t$limm, $rc", []> {
  // Opcode: 0x36C87000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh11<.f><.cc> b,b,limm 00110bbb11001000FBBB1111100QQQQQ.
def ARC_DMULH11_b_limm_cc : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "dmulh11\t$rb, $limm", []> {
  // Opcode: 0x30C80F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh11<.f> a,limm,u6 0011011001001000F111uuuuuuAAAAAA.
def ARC_DMULH11_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh11\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36487000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh11<.f> 0,limm,u6 0011011001001000F111uuuuuu111110.
def ARC_DMULH11_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh11\t$limm, $uimm6_20", []> {
  // Opcode: 0x3648703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh11<.f><.cc> 0,limm,u6 0011011011001000F111uuuuuu1QQQQQ.
def ARC_DMULH11_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh11\t$limm, $uimm6_20", []> {
  // Opcode: 0x36C87020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh11<.f> 0,limm,s12 0011011010001000F111ssssssSSSSSS.
def ARC_DMULH11_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "dmulh11\t$limm, $simm12_20", []> {
  // Opcode: 0x36887000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010001000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh11<.f> a,limm,limm 0011011000001000F111111110AAAAAA.
def ARC_DMULH11_a_limm : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "dmulh11\t$ra, $limm", []> {
  // Opcode: 0x36087F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// dmulh11<.f> 0,limm,limm 0011011000001000F111111110111110.
def ARC_DMULH11_z_limm : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs ), (ins i32imm:$limm),
    "dmulh11\t$limm", []> {
  // Opcode: 0x36087FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// dmulh11<.f><.cc> 0,limm,limm 0011011011001000F1111111100QQQQQ.
def ARC_DMULH11_z_limm_cc : ARCompactInst32_3op<0b00110, 0b001000, "dmulh11",
    (outs ), (ins i32imm:$limm),
    "dmulh11\t$limm", []> {
  // Opcode: 0x36C87F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh12<.f> a,b,c 00110bbb00001001FBBBCCCCCCAAAAAA.
def ARC_DMULH12_a_b_c : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "dmulh12\t$ra, $rb, $rc", []> {
  // Opcode: 0x30090000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001001;
  let Defs = [STATUS32];
}

// dmulh12<.f> 0,b,c 00110bbb00001001FBBBCCCCCC111110.
def ARC_DMULH12_z_b_c : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "dmulh12\t$rb, $rc", []> {
  // Opcode: 0x3009003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh12<.f><.cc> b,b,c 00110bbb11001001FBBBCCCCCC0QQQQQ.
def ARC_DMULH12_b_c_cc : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "dmulh12\t$rb, $rc", []> {
  // Opcode: 0x30C90000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh12<.f> a,b,u6 00110bbb01001001FBBBuuuuuuAAAAAA.
def ARC_DMULH12_a_b_u6 : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dmulh12\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30490000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001001;
  let Defs = [STATUS32];
}

// dmulh12<.f> 0,b,u6 00110bbb01001001FBBBuuuuuu111110.
def ARC_DMULH12_z_b_u6 : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dmulh12\t$rb, $uimm6_20", []> {
  // Opcode: 0x3049003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh12<.f><.cc> b,b,u6 00110bbb11001001FBBBuuuuuu1QQQQQ.
def ARC_DMULH12_b_u6_cc : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "dmulh12\t$rb, $uimm6_20", []> {
  // Opcode: 0x30C90020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh12<.f> b,b,s12 00110bbb10001001FBBBssssssSSSSSS.
def ARC_DMULH12_b_s12 : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "dmulh12\t$rb, $simm12_20", []> {
  // Opcode: 0x30890000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10001001;
  let Defs = [STATUS32];
  
}

// dmulh12<.f> a,limm,c 0011011000001001F111CCCCCCAAAAAA.
def ARC_DMULH12_a_limm_c : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "dmulh12\t$ra, $limm, $rc", []> {
  // Opcode: 0x36097000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh12<.f> a,b,limm 00110bbb00001001FBBB111110AAAAAA.
def ARC_DMULH12_a_b_limm : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "dmulh12\t$ra, $rb, $limm", []> {
  // Opcode: 0x30090F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh12<.f> 0,limm,c 0011011000001001F111CCCCCC111110.
def ARC_DMULH12_z_limm_c : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dmulh12\t$limm, $rc", []> {
  // Opcode: 0x3609703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh12<.f> 0,b,limm 00110bbb00001001FBBB111110111110.
def ARC_DMULH12_z_b_limm : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "dmulh12\t$rb, $limm", []> {
  // Opcode: 0x30090FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// dmulh12<.f><.cc> 0,limm,c 0011011011001001F111CCCCCC0QQQQQ.
def ARC_DMULH12_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dmulh12\t$limm, $rc", []> {
  // Opcode: 0x36C97000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh12<.f><.cc> b,b,limm 00110bbb11001001FBBB1111100QQQQQ.
def ARC_DMULH12_b_limm_cc : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "dmulh12\t$rb, $limm", []> {
  // Opcode: 0x30C90F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh12<.f> a,limm,u6 0011011001001001F111uuuuuuAAAAAA.
def ARC_DMULH12_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh12\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36497000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh12<.f> 0,limm,u6 0011011001001001F111uuuuuu111110.
def ARC_DMULH12_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh12\t$limm, $uimm6_20", []> {
  // Opcode: 0x3649703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh12<.f><.cc> 0,limm,u6 0011011011001001F111uuuuuu1QQQQQ.
def ARC_DMULH12_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh12\t$limm, $uimm6_20", []> {
  // Opcode: 0x36C97020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh12<.f> 0,limm,s12 0011011010001001F111ssssssSSSSSS.
def ARC_DMULH12_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "dmulh12\t$limm, $simm12_20", []> {
  // Opcode: 0x36897000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010001001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh12<.f> a,limm,limm 0011011000001001F111111110AAAAAA.
def ARC_DMULH12_a_limm : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "dmulh12\t$ra, $limm", []> {
  // Opcode: 0x36097F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// dmulh12<.f> 0,limm,limm 0011011000001001F111111110111110.
def ARC_DMULH12_z_limm : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs ), (ins i32imm:$limm),
    "dmulh12\t$limm", []> {
  // Opcode: 0x36097FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// dmulh12<.f><.cc> 0,limm,limm 0011011011001001F1111111100QQQQQ.
def ARC_DMULH12_z_limm_cc : ARCompactInst32_3op<0b00110, 0b001001, "dmulh12",
    (outs ), (ins i32imm:$limm),
    "dmulh12\t$limm", []> {
  // Opcode: 0x36C97F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh21<.f> a,b,c 00110bbb00001010FBBBCCCCCCAAAAAA.
def ARC_DMULH21_a_b_c : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "dmulh21\t$ra, $rb, $rc", []> {
  // Opcode: 0x300A0000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001010;
  let Defs = [STATUS32];
}

// dmulh21<.f> 0,b,c 00110bbb00001010FBBBCCCCCC111110.
def ARC_DMULH21_z_b_c : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "dmulh21\t$rb, $rc", []> {
  // Opcode: 0x300A003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh21<.f><.cc> b,b,c 00110bbb11001010FBBBCCCCCC0QQQQQ.
def ARC_DMULH21_b_c_cc : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "dmulh21\t$rb, $rc", []> {
  // Opcode: 0x30CA0000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh21<.f> a,b,u6 00110bbb01001010FBBBuuuuuuAAAAAA.
def ARC_DMULH21_a_b_u6 : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dmulh21\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x304A0000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001010;
  let Defs = [STATUS32];
}

// dmulh21<.f> 0,b,u6 00110bbb01001010FBBBuuuuuu111110.
def ARC_DMULH21_z_b_u6 : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dmulh21\t$rb, $uimm6_20", []> {
  // Opcode: 0x304A003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh21<.f><.cc> b,b,u6 00110bbb11001010FBBBuuuuuu1QQQQQ.
def ARC_DMULH21_b_u6_cc : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "dmulh21\t$rb, $uimm6_20", []> {
  // Opcode: 0x30CA0020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh21<.f> b,b,s12 00110bbb10001010FBBBssssssSSSSSS.
def ARC_DMULH21_b_s12 : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "dmulh21\t$rb, $simm12_20", []> {
  // Opcode: 0x308A0000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10001010;
  let Defs = [STATUS32];
  
}

// dmulh21<.f> a,limm,c 0011011000001010F111CCCCCCAAAAAA.
def ARC_DMULH21_a_limm_c : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "dmulh21\t$ra, $limm, $rc", []> {
  // Opcode: 0x360A7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh21<.f> a,b,limm 00110bbb00001010FBBB111110AAAAAA.
def ARC_DMULH21_a_b_limm : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "dmulh21\t$ra, $rb, $limm", []> {
  // Opcode: 0x300A0F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh21<.f> 0,limm,c 0011011000001010F111CCCCCC111110.
def ARC_DMULH21_z_limm_c : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dmulh21\t$limm, $rc", []> {
  // Opcode: 0x360A703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh21<.f> 0,b,limm 00110bbb00001010FBBB111110111110.
def ARC_DMULH21_z_b_limm : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "dmulh21\t$rb, $limm", []> {
  // Opcode: 0x300A0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001010;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// dmulh21<.f><.cc> 0,limm,c 0011011011001010F111CCCCCC0QQQQQ.
def ARC_DMULH21_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dmulh21\t$limm, $rc", []> {
  // Opcode: 0x36CA7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh21<.f><.cc> b,b,limm 00110bbb11001010FBBB1111100QQQQQ.
def ARC_DMULH21_b_limm_cc : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "dmulh21\t$rb, $limm", []> {
  // Opcode: 0x30CA0F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh21<.f> a,limm,u6 0011011001001010F111uuuuuuAAAAAA.
def ARC_DMULH21_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh21\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x364A7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh21<.f> 0,limm,u6 0011011001001010F111uuuuuu111110.
def ARC_DMULH21_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh21\t$limm, $uimm6_20", []> {
  // Opcode: 0x364A703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh21<.f><.cc> 0,limm,u6 0011011011001010F111uuuuuu1QQQQQ.
def ARC_DMULH21_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh21\t$limm, $uimm6_20", []> {
  // Opcode: 0x36CA7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh21<.f> 0,limm,s12 0011011010001010F111ssssssSSSSSS.
def ARC_DMULH21_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "dmulh21\t$limm, $simm12_20", []> {
  // Opcode: 0x368A7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010001010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh21<.f> a,limm,limm 0011011000001010F111111110AAAAAA.
def ARC_DMULH21_a_limm : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "dmulh21\t$ra, $limm", []> {
  // Opcode: 0x360A7F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001010;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// dmulh21<.f> 0,limm,limm 0011011000001010F111111110111110.
def ARC_DMULH21_z_limm : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs ), (ins i32imm:$limm),
    "dmulh21\t$limm", []> {
  // Opcode: 0x360A7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001010;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// dmulh21<.f><.cc> 0,limm,limm 0011011011001010F1111111100QQQQQ.
def ARC_DMULH21_z_limm_cc : ARCompactInst32_3op<0b00110, 0b001010, "dmulh21",
    (outs ), (ins i32imm:$limm),
    "dmulh21\t$limm", []> {
  // Opcode: 0x36CA7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001010;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh22<.f> a,b,c 00110bbb00001011FBBBCCCCCCAAAAAA.
def ARC_DMULH22_a_b_c : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "dmulh22\t$ra, $rb, $rc", []> {
  // Opcode: 0x300B0000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001011;
  let Defs = [STATUS32];
}

// dmulh22<.f> 0,b,c 00110bbb00001011FBBBCCCCCC111110.
def ARC_DMULH22_z_b_c : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "dmulh22\t$rb, $rc", []> {
  // Opcode: 0x300B003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh22<.f><.cc> b,b,c 00110bbb11001011FBBBCCCCCC0QQQQQ.
def ARC_DMULH22_b_c_cc : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "dmulh22\t$rb, $rc", []> {
  // Opcode: 0x30CB0000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001011;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh22<.f> a,b,u6 00110bbb01001011FBBBuuuuuuAAAAAA.
def ARC_DMULH22_a_b_u6 : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dmulh22\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x304B0000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001011;
  let Defs = [STATUS32];
}

// dmulh22<.f> 0,b,u6 00110bbb01001011FBBBuuuuuu111110.
def ARC_DMULH22_z_b_u6 : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dmulh22\t$rb, $uimm6_20", []> {
  // Opcode: 0x304B003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01001011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh22<.f><.cc> b,b,u6 00110bbb11001011FBBBuuuuuu1QQQQQ.
def ARC_DMULH22_b_u6_cc : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "dmulh22\t$rb, $uimm6_20", []> {
  // Opcode: 0x30CB0020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001011;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh22<.f> b,b,s12 00110bbb10001011FBBBssssssSSSSSS.
def ARC_DMULH22_b_s12 : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "dmulh22\t$rb, $simm12_20", []> {
  // Opcode: 0x308B0000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10001011;
  let Defs = [STATUS32];
  
}

// dmulh22<.f> a,limm,c 0011011000001011F111CCCCCCAAAAAA.
def ARC_DMULH22_a_limm_c : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "dmulh22\t$ra, $limm, $rc", []> {
  // Opcode: 0x360B7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh22<.f> a,b,limm 00110bbb00001011FBBB111110AAAAAA.
def ARC_DMULH22_a_b_limm : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "dmulh22\t$ra, $rb, $limm", []> {
  // Opcode: 0x300B0F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001011;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh22<.f> 0,limm,c 0011011000001011F111CCCCCC111110.
def ARC_DMULH22_z_limm_c : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dmulh22\t$limm, $rc", []> {
  // Opcode: 0x360B703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh22<.f> 0,b,limm 00110bbb00001011FBBB111110111110.
def ARC_DMULH22_z_b_limm : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "dmulh22\t$rb, $limm", []> {
  // Opcode: 0x300B0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00001011;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// dmulh22<.f><.cc> 0,limm,c 0011011011001011F111CCCCCC0QQQQQ.
def ARC_DMULH22_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dmulh22\t$limm, $rc", []> {
  // Opcode: 0x36CB7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh22<.f><.cc> b,b,limm 00110bbb11001011FBBB1111100QQQQQ.
def ARC_DMULH22_b_limm_cc : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "dmulh22\t$rb, $limm", []> {
  // Opcode: 0x30CB0F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11001011;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dmulh22<.f> a,limm,u6 0011011001001011F111uuuuuuAAAAAA.
def ARC_DMULH22_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh22\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x364B7000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh22<.f> 0,limm,u6 0011011001001011F111uuuuuu111110.
def ARC_DMULH22_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh22\t$limm, $uimm6_20", []> {
  // Opcode: 0x364B703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001001011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dmulh22<.f><.cc> 0,limm,u6 0011011011001011F111uuuuuu1QQQQQ.
def ARC_DMULH22_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dmulh22\t$limm, $uimm6_20", []> {
  // Opcode: 0x36CB7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dmulh22<.f> 0,limm,s12 0011011010001011F111ssssssSSSSSS.
def ARC_DMULH22_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "dmulh22\t$limm, $simm12_20", []> {
  // Opcode: 0x368B7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010001011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dmulh22<.f> a,limm,limm 0011011000001011F111111110AAAAAA.
def ARC_DMULH22_a_limm : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "dmulh22\t$ra, $limm", []> {
  // Opcode: 0x360B7F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001011;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// dmulh22<.f> 0,limm,limm 0011011000001011F111111110111110.
def ARC_DMULH22_z_limm : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs ), (ins i32imm:$limm),
    "dmulh22\t$limm", []> {
  // Opcode: 0x360B7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000001011;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// dmulh22<.f><.cc> 0,limm,limm 0011011011001011F1111111100QQQQQ.
def ARC_DMULH22_z_limm_cc : ARCompactInst32_3op<0b00110, 0b001011, "dmulh22",
    (outs ), (ins i32imm:$limm),
    "dmulh22\t$limm", []> {
  // Opcode: 0x36CB7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011001011;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh11<.f> a,b,c 00110bbb00010100FBBBCCCCCCAAAAAA.
def ARC_DRSUBH11_a_b_c : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "drsubh11\t$ra, $rb, $rc", []> {
  // Opcode: 0x30140000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010100;
  let Defs = [STATUS32];
}

// drsubh11<.f> 0,b,c 00110bbb00010100FBBBCCCCCC111110.
def ARC_DRSUBH11_z_b_c : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "drsubh11\t$rb, $rc", []> {
  // Opcode: 0x3014003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh11<.f><.cc> b,b,c 00110bbb11010100FBBBCCCCCC0QQQQQ.
def ARC_DRSUBH11_b_c_cc : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "drsubh11\t$rb, $rc", []> {
  // Opcode: 0x30D40000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010100;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh11<.f> a,b,u6 00110bbb01010100FBBBuuuuuuAAAAAA.
def ARC_DRSUBH11_a_b_u6 : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "drsubh11\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30540000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010100;
  let Defs = [STATUS32];
}

// drsubh11<.f> 0,b,u6 00110bbb01010100FBBBuuuuuu111110.
def ARC_DRSUBH11_z_b_u6 : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "drsubh11\t$rb, $uimm6_20", []> {
  // Opcode: 0x3054003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh11<.f><.cc> b,b,u6 00110bbb11010100FBBBuuuuuu1QQQQQ.
def ARC_DRSUBH11_b_u6_cc : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "drsubh11\t$rb, $uimm6_20", []> {
  // Opcode: 0x30D40020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010100;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh11<.f> b,b,s12 00110bbb10010100FBBBssssssSSSSSS.
def ARC_DRSUBH11_b_s12 : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "drsubh11\t$rb, $simm12_20", []> {
  // Opcode: 0x30940000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10010100;
  let Defs = [STATUS32];
  
}

// drsubh11<.f> a,limm,c 0011011000010100F111CCCCCCAAAAAA.
def ARC_DRSUBH11_a_limm_c : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "drsubh11\t$ra, $limm, $rc", []> {
  // Opcode: 0x36147000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh11<.f> a,b,limm 00110bbb00010100FBBB111110AAAAAA.
def ARC_DRSUBH11_a_b_limm : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "drsubh11\t$ra, $rb, $limm", []> {
  // Opcode: 0x30140F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010100;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh11<.f> 0,limm,c 0011011000010100F111CCCCCC111110.
def ARC_DRSUBH11_z_limm_c : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "drsubh11\t$limm, $rc", []> {
  // Opcode: 0x3614703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh11<.f> 0,b,limm 00110bbb00010100FBBB111110111110.
def ARC_DRSUBH11_z_b_limm : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "drsubh11\t$rb, $limm", []> {
  // Opcode: 0x30140FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010100;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// drsubh11<.f><.cc> 0,limm,c 0011011011010100F111CCCCCC0QQQQQ.
def ARC_DRSUBH11_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "drsubh11\t$limm, $rc", []> {
  // Opcode: 0x36D47000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh11<.f><.cc> b,b,limm 00110bbb11010100FBBB1111100QQQQQ.
def ARC_DRSUBH11_b_limm_cc : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "drsubh11\t$rb, $limm", []> {
  // Opcode: 0x30D40F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010100;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh11<.f> a,limm,u6 0011011001010100F111uuuuuuAAAAAA.
def ARC_DRSUBH11_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh11\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36547000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh11<.f> 0,limm,u6 0011011001010100F111uuuuuu111110.
def ARC_DRSUBH11_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh11\t$limm, $uimm6_20", []> {
  // Opcode: 0x3654703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh11<.f><.cc> 0,limm,u6 0011011011010100F111uuuuuu1QQQQQ.
def ARC_DRSUBH11_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh11\t$limm, $uimm6_20", []> {
  // Opcode: 0x36D47020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh11<.f> 0,limm,s12 0011011010010100F111ssssssSSSSSS.
def ARC_DRSUBH11_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "drsubh11\t$limm, $simm12_20", []> {
  // Opcode: 0x36947000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010010100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh11<.f> a,limm,limm 0011011000010100F111111110AAAAAA.
def ARC_DRSUBH11_a_limm : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "drsubh11\t$ra, $limm", []> {
  // Opcode: 0x36147F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010100;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// drsubh11<.f> 0,limm,limm 0011011000010100F111111110111110.
def ARC_DRSUBH11_z_limm : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs ), (ins i32imm:$limm),
    "drsubh11\t$limm", []> {
  // Opcode: 0x36147FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010100;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// drsubh11<.f><.cc> 0,limm,limm 0011011011010100F1111111100QQQQQ.
def ARC_DRSUBH11_z_limm_cc : ARCompactInst32_3op<0b00110, 0b010100, "drsubh11",
    (outs ), (ins i32imm:$limm),
    "drsubh11\t$limm", []> {
  // Opcode: 0x36D47F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010100;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh12<.f> a,b,c 00110bbb00010101FBBBCCCCCCAAAAAA.
def ARC_DRSUBH12_a_b_c : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "drsubh12\t$ra, $rb, $rc", []> {
  // Opcode: 0x30150000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010101;
  let Defs = [STATUS32];
}

// drsubh12<.f> 0,b,c 00110bbb00010101FBBBCCCCCC111110.
def ARC_DRSUBH12_z_b_c : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "drsubh12\t$rb, $rc", []> {
  // Opcode: 0x3015003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh12<.f><.cc> b,b,c 00110bbb11010101FBBBCCCCCC0QQQQQ.
def ARC_DRSUBH12_b_c_cc : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "drsubh12\t$rb, $rc", []> {
  // Opcode: 0x30D50000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010101;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh12<.f> a,b,u6 00110bbb01010101FBBBuuuuuuAAAAAA.
def ARC_DRSUBH12_a_b_u6 : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "drsubh12\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30550000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010101;
  let Defs = [STATUS32];
}

// drsubh12<.f> 0,b,u6 00110bbb01010101FBBBuuuuuu111110.
def ARC_DRSUBH12_z_b_u6 : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "drsubh12\t$rb, $uimm6_20", []> {
  // Opcode: 0x3055003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh12<.f><.cc> b,b,u6 00110bbb11010101FBBBuuuuuu1QQQQQ.
def ARC_DRSUBH12_b_u6_cc : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "drsubh12\t$rb, $uimm6_20", []> {
  // Opcode: 0x30D50020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010101;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh12<.f> b,b,s12 00110bbb10010101FBBBssssssSSSSSS.
def ARC_DRSUBH12_b_s12 : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "drsubh12\t$rb, $simm12_20", []> {
  // Opcode: 0x30950000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10010101;
  let Defs = [STATUS32];
  
}

// drsubh12<.f> a,limm,c 0011011000010101F111CCCCCCAAAAAA.
def ARC_DRSUBH12_a_limm_c : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "drsubh12\t$ra, $limm, $rc", []> {
  // Opcode: 0x36157000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh12<.f> a,b,limm 00110bbb00010101FBBB111110AAAAAA.
def ARC_DRSUBH12_a_b_limm : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "drsubh12\t$ra, $rb, $limm", []> {
  // Opcode: 0x30150F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010101;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh12<.f> 0,limm,c 0011011000010101F111CCCCCC111110.
def ARC_DRSUBH12_z_limm_c : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "drsubh12\t$limm, $rc", []> {
  // Opcode: 0x3615703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh12<.f> 0,b,limm 00110bbb00010101FBBB111110111110.
def ARC_DRSUBH12_z_b_limm : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "drsubh12\t$rb, $limm", []> {
  // Opcode: 0x30150FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010101;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// drsubh12<.f><.cc> 0,limm,c 0011011011010101F111CCCCCC0QQQQQ.
def ARC_DRSUBH12_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "drsubh12\t$limm, $rc", []> {
  // Opcode: 0x36D57000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh12<.f><.cc> b,b,limm 00110bbb11010101FBBB1111100QQQQQ.
def ARC_DRSUBH12_b_limm_cc : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "drsubh12\t$rb, $limm", []> {
  // Opcode: 0x30D50F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010101;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh12<.f> a,limm,u6 0011011001010101F111uuuuuuAAAAAA.
def ARC_DRSUBH12_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh12\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36557000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh12<.f> 0,limm,u6 0011011001010101F111uuuuuu111110.
def ARC_DRSUBH12_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh12\t$limm, $uimm6_20", []> {
  // Opcode: 0x3655703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh12<.f><.cc> 0,limm,u6 0011011011010101F111uuuuuu1QQQQQ.
def ARC_DRSUBH12_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh12\t$limm, $uimm6_20", []> {
  // Opcode: 0x36D57020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh12<.f> 0,limm,s12 0011011010010101F111ssssssSSSSSS.
def ARC_DRSUBH12_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "drsubh12\t$limm, $simm12_20", []> {
  // Opcode: 0x36957000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010010101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh12<.f> a,limm,limm 0011011000010101F111111110AAAAAA.
def ARC_DRSUBH12_a_limm : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "drsubh12\t$ra, $limm", []> {
  // Opcode: 0x36157F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010101;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// drsubh12<.f> 0,limm,limm 0011011000010101F111111110111110.
def ARC_DRSUBH12_z_limm : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs ), (ins i32imm:$limm),
    "drsubh12\t$limm", []> {
  // Opcode: 0x36157FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010101;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// drsubh12<.f><.cc> 0,limm,limm 0011011011010101F1111111100QQQQQ.
def ARC_DRSUBH12_z_limm_cc : ARCompactInst32_3op<0b00110, 0b010101, "drsubh12",
    (outs ), (ins i32imm:$limm),
    "drsubh12\t$limm", []> {
  // Opcode: 0x36D57F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010101;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh21<.f> a,b,c 00110bbb00010110FBBBCCCCCCAAAAAA.
def ARC_DRSUBH21_a_b_c : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "drsubh21\t$ra, $rb, $rc", []> {
  // Opcode: 0x30160000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010110;
  let Defs = [STATUS32];
}

// drsubh21<.f> 0,b,c 00110bbb00010110FBBBCCCCCC111110.
def ARC_DRSUBH21_z_b_c : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "drsubh21\t$rb, $rc", []> {
  // Opcode: 0x3016003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh21<.f><.cc> b,b,c 00110bbb11010110FBBBCCCCCC0QQQQQ.
def ARC_DRSUBH21_b_c_cc : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "drsubh21\t$rb, $rc", []> {
  // Opcode: 0x30D60000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010110;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh21<.f> a,b,u6 00110bbb01010110FBBBuuuuuuAAAAAA.
def ARC_DRSUBH21_a_b_u6 : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "drsubh21\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30560000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010110;
  let Defs = [STATUS32];
}

// drsubh21<.f> 0,b,u6 00110bbb01010110FBBBuuuuuu111110.
def ARC_DRSUBH21_z_b_u6 : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "drsubh21\t$rb, $uimm6_20", []> {
  // Opcode: 0x3056003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh21<.f><.cc> b,b,u6 00110bbb11010110FBBBuuuuuu1QQQQQ.
def ARC_DRSUBH21_b_u6_cc : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "drsubh21\t$rb, $uimm6_20", []> {
  // Opcode: 0x30D60020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010110;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh21<.f> b,b,s12 00110bbb10010110FBBBssssssSSSSSS.
def ARC_DRSUBH21_b_s12 : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "drsubh21\t$rb, $simm12_20", []> {
  // Opcode: 0x30960000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10010110;
  let Defs = [STATUS32];
  
}

// drsubh21<.f> a,limm,c 0011011000010110F111CCCCCCAAAAAA.
def ARC_DRSUBH21_a_limm_c : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "drsubh21\t$ra, $limm, $rc", []> {
  // Opcode: 0x36167000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh21<.f> a,b,limm 00110bbb00010110FBBB111110AAAAAA.
def ARC_DRSUBH21_a_b_limm : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "drsubh21\t$ra, $rb, $limm", []> {
  // Opcode: 0x30160F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010110;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh21<.f> 0,limm,c 0011011000010110F111CCCCCC111110.
def ARC_DRSUBH21_z_limm_c : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "drsubh21\t$limm, $rc", []> {
  // Opcode: 0x3616703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh21<.f> 0,b,limm 00110bbb00010110FBBB111110111110.
def ARC_DRSUBH21_z_b_limm : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "drsubh21\t$rb, $limm", []> {
  // Opcode: 0x30160FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010110;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// drsubh21<.f><.cc> 0,limm,c 0011011011010110F111CCCCCC0QQQQQ.
def ARC_DRSUBH21_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "drsubh21\t$limm, $rc", []> {
  // Opcode: 0x36D67000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh21<.f><.cc> b,b,limm 00110bbb11010110FBBB1111100QQQQQ.
def ARC_DRSUBH21_b_limm_cc : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "drsubh21\t$rb, $limm", []> {
  // Opcode: 0x30D60F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010110;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh21<.f> a,limm,u6 0011011001010110F111uuuuuuAAAAAA.
def ARC_DRSUBH21_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh21\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36567000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh21<.f> 0,limm,u6 0011011001010110F111uuuuuu111110.
def ARC_DRSUBH21_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh21\t$limm, $uimm6_20", []> {
  // Opcode: 0x3656703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh21<.f><.cc> 0,limm,u6 0011011011010110F111uuuuuu1QQQQQ.
def ARC_DRSUBH21_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh21\t$limm, $uimm6_20", []> {
  // Opcode: 0x36D67020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh21<.f> 0,limm,s12 0011011010010110F111ssssssSSSSSS.
def ARC_DRSUBH21_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "drsubh21\t$limm, $simm12_20", []> {
  // Opcode: 0x36967000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010010110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh21<.f> a,limm,limm 0011011000010110F111111110AAAAAA.
def ARC_DRSUBH21_a_limm : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "drsubh21\t$ra, $limm", []> {
  // Opcode: 0x36167F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010110;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// drsubh21<.f> 0,limm,limm 0011011000010110F111111110111110.
def ARC_DRSUBH21_z_limm : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs ), (ins i32imm:$limm),
    "drsubh21\t$limm", []> {
  // Opcode: 0x36167FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010110;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// drsubh21<.f><.cc> 0,limm,limm 0011011011010110F1111111100QQQQQ.
def ARC_DRSUBH21_z_limm_cc : ARCompactInst32_3op<0b00110, 0b010110, "drsubh21",
    (outs ), (ins i32imm:$limm),
    "drsubh21\t$limm", []> {
  // Opcode: 0x36D67F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010110;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh22<.f> a,b,c 00110bbb00010111FBBBCCCCCCAAAAAA.
def ARC_DRSUBH22_a_b_c : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "drsubh22\t$ra, $rb, $rc", []> {
  // Opcode: 0x30170000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010111;
  let Defs = [STATUS32];
}

// drsubh22<.f> 0,b,c 00110bbb00010111FBBBCCCCCC111110.
def ARC_DRSUBH22_z_b_c : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "drsubh22\t$rb, $rc", []> {
  // Opcode: 0x3017003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh22<.f><.cc> b,b,c 00110bbb11010111FBBBCCCCCC0QQQQQ.
def ARC_DRSUBH22_b_c_cc : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "drsubh22\t$rb, $rc", []> {
  // Opcode: 0x30D70000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh22<.f> a,b,u6 00110bbb01010111FBBBuuuuuuAAAAAA.
def ARC_DRSUBH22_a_b_u6 : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "drsubh22\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30570000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010111;
  let Defs = [STATUS32];
}

// drsubh22<.f> 0,b,u6 00110bbb01010111FBBBuuuuuu111110.
def ARC_DRSUBH22_z_b_u6 : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "drsubh22\t$rb, $uimm6_20", []> {
  // Opcode: 0x3057003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh22<.f><.cc> b,b,u6 00110bbb11010111FBBBuuuuuu1QQQQQ.
def ARC_DRSUBH22_b_u6_cc : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "drsubh22\t$rb, $uimm6_20", []> {
  // Opcode: 0x30D70020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh22<.f> b,b,s12 00110bbb10010111FBBBssssssSSSSSS.
def ARC_DRSUBH22_b_s12 : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "drsubh22\t$rb, $simm12_20", []> {
  // Opcode: 0x30970000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10010111;
  let Defs = [STATUS32];
  
}

// drsubh22<.f> a,limm,c 0011011000010111F111CCCCCCAAAAAA.
def ARC_DRSUBH22_a_limm_c : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "drsubh22\t$ra, $limm, $rc", []> {
  // Opcode: 0x36177000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh22<.f> a,b,limm 00110bbb00010111FBBB111110AAAAAA.
def ARC_DRSUBH22_a_b_limm : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "drsubh22\t$ra, $rb, $limm", []> {
  // Opcode: 0x30170F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010111;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh22<.f> 0,limm,c 0011011000010111F111CCCCCC111110.
def ARC_DRSUBH22_z_limm_c : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "drsubh22\t$limm, $rc", []> {
  // Opcode: 0x3617703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh22<.f> 0,b,limm 00110bbb00010111FBBB111110111110.
def ARC_DRSUBH22_z_b_limm : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "drsubh22\t$rb, $limm", []> {
  // Opcode: 0x30170FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010111;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// drsubh22<.f><.cc> 0,limm,c 0011011011010111F111CCCCCC0QQQQQ.
def ARC_DRSUBH22_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "drsubh22\t$limm, $rc", []> {
  // Opcode: 0x36D77000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh22<.f><.cc> b,b,limm 00110bbb11010111FBBB1111100QQQQQ.
def ARC_DRSUBH22_b_limm_cc : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "drsubh22\t$rb, $limm", []> {
  // Opcode: 0x30D70F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010111;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// drsubh22<.f> a,limm,u6 0011011001010111F111uuuuuuAAAAAA.
def ARC_DRSUBH22_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh22\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36577000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh22<.f> 0,limm,u6 0011011001010111F111uuuuuu111110.
def ARC_DRSUBH22_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh22\t$limm, $uimm6_20", []> {
  // Opcode: 0x3657703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// drsubh22<.f><.cc> 0,limm,u6 0011011011010111F111uuuuuu1QQQQQ.
def ARC_DRSUBH22_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "drsubh22\t$limm, $uimm6_20", []> {
  // Opcode: 0x36D77020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// drsubh22<.f> 0,limm,s12 0011011010010111F111ssssssSSSSSS.
def ARC_DRSUBH22_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "drsubh22\t$limm, $simm12_20", []> {
  // Opcode: 0x36977000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010010111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// drsubh22<.f> a,limm,limm 0011011000010111F111111110AAAAAA.
def ARC_DRSUBH22_a_limm : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "drsubh22\t$ra, $limm", []> {
  // Opcode: 0x36177F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010111;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// drsubh22<.f> 0,limm,limm 0011011000010111F111111110111110.
def ARC_DRSUBH22_z_limm : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs ), (ins i32imm:$limm),
    "drsubh22\t$limm", []> {
  // Opcode: 0x36177FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010111;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// drsubh22<.f><.cc> 0,limm,limm 0011011011010111F1111111100QQQQQ.
def ARC_DRSUBH22_z_limm_cc : ARCompactInst32_3op<0b00110, 0b010111, "drsubh22",
    (outs ), (ins i32imm:$limm),
    "drsubh22\t$limm", []> {
  // Opcode: 0x36D77F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010111;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh11<.f> a,b,c 00110bbb00010000FBBBCCCCCCAAAAAA.
def ARC_DSUBH11_a_b_c : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "dsubh11\t$ra, $rb, $rc", []> {
  // Opcode: 0x30100000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010000;
  let Defs = [STATUS32];
}

// dsubh11<.f> 0,b,c 00110bbb00010000FBBBCCCCCC111110.
def ARC_DSUBH11_z_b_c : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "dsubh11\t$rb, $rc", []> {
  // Opcode: 0x3010003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh11<.f><.cc> b,b,c 00110bbb11010000FBBBCCCCCC0QQQQQ.
def ARC_DSUBH11_b_c_cc : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "dsubh11\t$rb, $rc", []> {
  // Opcode: 0x30D00000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh11<.f> a,b,u6 00110bbb01010000FBBBuuuuuuAAAAAA.
def ARC_DSUBH11_a_b_u6 : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dsubh11\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30500000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010000;
  let Defs = [STATUS32];
}

// dsubh11<.f> 0,b,u6 00110bbb01010000FBBBuuuuuu111110.
def ARC_DSUBH11_z_b_u6 : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dsubh11\t$rb, $uimm6_20", []> {
  // Opcode: 0x3050003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh11<.f><.cc> b,b,u6 00110bbb11010000FBBBuuuuuu1QQQQQ.
def ARC_DSUBH11_b_u6_cc : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "dsubh11\t$rb, $uimm6_20", []> {
  // Opcode: 0x30D00020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh11<.f> b,b,s12 00110bbb10010000FBBBssssssSSSSSS.
def ARC_DSUBH11_b_s12 : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "dsubh11\t$rb, $simm12_20", []> {
  // Opcode: 0x30900000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10010000;
  let Defs = [STATUS32];
  
}

// dsubh11<.f> a,limm,c 0011011000010000F111CCCCCCAAAAAA.
def ARC_DSUBH11_a_limm_c : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "dsubh11\t$ra, $limm, $rc", []> {
  // Opcode: 0x36107000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh11<.f> a,b,limm 00110bbb00010000FBBB111110AAAAAA.
def ARC_DSUBH11_a_b_limm : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "dsubh11\t$ra, $rb, $limm", []> {
  // Opcode: 0x30100F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh11<.f> 0,limm,c 0011011000010000F111CCCCCC111110.
def ARC_DSUBH11_z_limm_c : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dsubh11\t$limm, $rc", []> {
  // Opcode: 0x3610703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh11<.f> 0,b,limm 00110bbb00010000FBBB111110111110.
def ARC_DSUBH11_z_b_limm : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "dsubh11\t$rb, $limm", []> {
  // Opcode: 0x30100FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// dsubh11<.f><.cc> 0,limm,c 0011011011010000F111CCCCCC0QQQQQ.
def ARC_DSUBH11_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dsubh11\t$limm, $rc", []> {
  // Opcode: 0x36D07000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh11<.f><.cc> b,b,limm 00110bbb11010000FBBB1111100QQQQQ.
def ARC_DSUBH11_b_limm_cc : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "dsubh11\t$rb, $limm", []> {
  // Opcode: 0x30D00F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh11<.f> a,limm,u6 0011011001010000F111uuuuuuAAAAAA.
def ARC_DSUBH11_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh11\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36507000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh11<.f> 0,limm,u6 0011011001010000F111uuuuuu111110.
def ARC_DSUBH11_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh11\t$limm, $uimm6_20", []> {
  // Opcode: 0x3650703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh11<.f><.cc> 0,limm,u6 0011011011010000F111uuuuuu1QQQQQ.
def ARC_DSUBH11_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh11\t$limm, $uimm6_20", []> {
  // Opcode: 0x36D07020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh11<.f> 0,limm,s12 0011011010010000F111ssssssSSSSSS.
def ARC_DSUBH11_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "dsubh11\t$limm, $simm12_20", []> {
  // Opcode: 0x36907000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010010000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh11<.f> a,limm,limm 0011011000010000F111111110AAAAAA.
def ARC_DSUBH11_a_limm : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "dsubh11\t$ra, $limm", []> {
  // Opcode: 0x36107F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// dsubh11<.f> 0,limm,limm 0011011000010000F111111110111110.
def ARC_DSUBH11_z_limm : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs ), (ins i32imm:$limm),
    "dsubh11\t$limm", []> {
  // Opcode: 0x36107FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// dsubh11<.f><.cc> 0,limm,limm 0011011011010000F1111111100QQQQQ.
def ARC_DSUBH11_z_limm_cc : ARCompactInst32_3op<0b00110, 0b010000, "dsubh11",
    (outs ), (ins i32imm:$limm),
    "dsubh11\t$limm", []> {
  // Opcode: 0x36D07F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh12<.f> a,b,c 00110bbb00010001FBBBCCCCCCAAAAAA.
def ARC_DSUBH12_a_b_c : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "dsubh12\t$ra, $rb, $rc", []> {
  // Opcode: 0x30110000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010001;
  let Defs = [STATUS32];
}

// dsubh12<.f> 0,b,c 00110bbb00010001FBBBCCCCCC111110.
def ARC_DSUBH12_z_b_c : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "dsubh12\t$rb, $rc", []> {
  // Opcode: 0x3011003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh12<.f><.cc> b,b,c 00110bbb11010001FBBBCCCCCC0QQQQQ.
def ARC_DSUBH12_b_c_cc : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "dsubh12\t$rb, $rc", []> {
  // Opcode: 0x30D10000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh12<.f> a,b,u6 00110bbb01010001FBBBuuuuuuAAAAAA.
def ARC_DSUBH12_a_b_u6 : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dsubh12\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30510000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010001;
  let Defs = [STATUS32];
}

// dsubh12<.f> 0,b,u6 00110bbb01010001FBBBuuuuuu111110.
def ARC_DSUBH12_z_b_u6 : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dsubh12\t$rb, $uimm6_20", []> {
  // Opcode: 0x3051003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh12<.f><.cc> b,b,u6 00110bbb11010001FBBBuuuuuu1QQQQQ.
def ARC_DSUBH12_b_u6_cc : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "dsubh12\t$rb, $uimm6_20", []> {
  // Opcode: 0x30D10020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh12<.f> b,b,s12 00110bbb10010001FBBBssssssSSSSSS.
def ARC_DSUBH12_b_s12 : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "dsubh12\t$rb, $simm12_20", []> {
  // Opcode: 0x30910000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10010001;
  let Defs = [STATUS32];
  
}

// dsubh12<.f> a,limm,c 0011011000010001F111CCCCCCAAAAAA.
def ARC_DSUBH12_a_limm_c : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "dsubh12\t$ra, $limm, $rc", []> {
  // Opcode: 0x36117000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh12<.f> a,b,limm 00110bbb00010001FBBB111110AAAAAA.
def ARC_DSUBH12_a_b_limm : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "dsubh12\t$ra, $rb, $limm", []> {
  // Opcode: 0x30110F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh12<.f> 0,limm,c 0011011000010001F111CCCCCC111110.
def ARC_DSUBH12_z_limm_c : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dsubh12\t$limm, $rc", []> {
  // Opcode: 0x3611703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh12<.f> 0,b,limm 00110bbb00010001FBBB111110111110.
def ARC_DSUBH12_z_b_limm : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "dsubh12\t$rb, $limm", []> {
  // Opcode: 0x30110FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// dsubh12<.f><.cc> 0,limm,c 0011011011010001F111CCCCCC0QQQQQ.
def ARC_DSUBH12_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dsubh12\t$limm, $rc", []> {
  // Opcode: 0x36D17000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh12<.f><.cc> b,b,limm 00110bbb11010001FBBB1111100QQQQQ.
def ARC_DSUBH12_b_limm_cc : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "dsubh12\t$rb, $limm", []> {
  // Opcode: 0x30D10F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh12<.f> a,limm,u6 0011011001010001F111uuuuuuAAAAAA.
def ARC_DSUBH12_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh12\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36517000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh12<.f> 0,limm,u6 0011011001010001F111uuuuuu111110.
def ARC_DSUBH12_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh12\t$limm, $uimm6_20", []> {
  // Opcode: 0x3651703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh12<.f><.cc> 0,limm,u6 0011011011010001F111uuuuuu1QQQQQ.
def ARC_DSUBH12_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh12\t$limm, $uimm6_20", []> {
  // Opcode: 0x36D17020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh12<.f> 0,limm,s12 0011011010010001F111ssssssSSSSSS.
def ARC_DSUBH12_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "dsubh12\t$limm, $simm12_20", []> {
  // Opcode: 0x36917000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010010001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh12<.f> a,limm,limm 0011011000010001F111111110AAAAAA.
def ARC_DSUBH12_a_limm : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "dsubh12\t$ra, $limm", []> {
  // Opcode: 0x36117F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// dsubh12<.f> 0,limm,limm 0011011000010001F111111110111110.
def ARC_DSUBH12_z_limm : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs ), (ins i32imm:$limm),
    "dsubh12\t$limm", []> {
  // Opcode: 0x36117FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// dsubh12<.f><.cc> 0,limm,limm 0011011011010001F1111111100QQQQQ.
def ARC_DSUBH12_z_limm_cc : ARCompactInst32_3op<0b00110, 0b010001, "dsubh12",
    (outs ), (ins i32imm:$limm),
    "dsubh12\t$limm", []> {
  // Opcode: 0x36D17F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh21<.f> a,b,c 00110bbb00010010FBBBCCCCCCAAAAAA.
def ARC_DSUBH21_a_b_c : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "dsubh21\t$ra, $rb, $rc", []> {
  // Opcode: 0x30120000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010010;
  let Defs = [STATUS32];
}

// dsubh21<.f> 0,b,c 00110bbb00010010FBBBCCCCCC111110.
def ARC_DSUBH21_z_b_c : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "dsubh21\t$rb, $rc", []> {
  // Opcode: 0x3012003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh21<.f><.cc> b,b,c 00110bbb11010010FBBBCCCCCC0QQQQQ.
def ARC_DSUBH21_b_c_cc : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "dsubh21\t$rb, $rc", []> {
  // Opcode: 0x30D20000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh21<.f> a,b,u6 00110bbb01010010FBBBuuuuuuAAAAAA.
def ARC_DSUBH21_a_b_u6 : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dsubh21\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30520000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010010;
  let Defs = [STATUS32];
}

// dsubh21<.f> 0,b,u6 00110bbb01010010FBBBuuuuuu111110.
def ARC_DSUBH21_z_b_u6 : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dsubh21\t$rb, $uimm6_20", []> {
  // Opcode: 0x3052003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh21<.f><.cc> b,b,u6 00110bbb11010010FBBBuuuuuu1QQQQQ.
def ARC_DSUBH21_b_u6_cc : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "dsubh21\t$rb, $uimm6_20", []> {
  // Opcode: 0x30D20020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh21<.f> b,b,s12 00110bbb10010010FBBBssssssSSSSSS.
def ARC_DSUBH21_b_s12 : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "dsubh21\t$rb, $simm12_20", []> {
  // Opcode: 0x30920000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10010010;
  let Defs = [STATUS32];
  
}

// dsubh21<.f> a,limm,c 0011011000010010F111CCCCCCAAAAAA.
def ARC_DSUBH21_a_limm_c : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "dsubh21\t$ra, $limm, $rc", []> {
  // Opcode: 0x36127000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh21<.f> a,b,limm 00110bbb00010010FBBB111110AAAAAA.
def ARC_DSUBH21_a_b_limm : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "dsubh21\t$ra, $rb, $limm", []> {
  // Opcode: 0x30120F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh21<.f> 0,limm,c 0011011000010010F111CCCCCC111110.
def ARC_DSUBH21_z_limm_c : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dsubh21\t$limm, $rc", []> {
  // Opcode: 0x3612703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh21<.f> 0,b,limm 00110bbb00010010FBBB111110111110.
def ARC_DSUBH21_z_b_limm : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "dsubh21\t$rb, $limm", []> {
  // Opcode: 0x30120FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010010;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// dsubh21<.f><.cc> 0,limm,c 0011011011010010F111CCCCCC0QQQQQ.
def ARC_DSUBH21_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dsubh21\t$limm, $rc", []> {
  // Opcode: 0x36D27000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh21<.f><.cc> b,b,limm 00110bbb11010010FBBB1111100QQQQQ.
def ARC_DSUBH21_b_limm_cc : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "dsubh21\t$rb, $limm", []> {
  // Opcode: 0x30D20F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh21<.f> a,limm,u6 0011011001010010F111uuuuuuAAAAAA.
def ARC_DSUBH21_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh21\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36527000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh21<.f> 0,limm,u6 0011011001010010F111uuuuuu111110.
def ARC_DSUBH21_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh21\t$limm, $uimm6_20", []> {
  // Opcode: 0x3652703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh21<.f><.cc> 0,limm,u6 0011011011010010F111uuuuuu1QQQQQ.
def ARC_DSUBH21_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh21\t$limm, $uimm6_20", []> {
  // Opcode: 0x36D27020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh21<.f> 0,limm,s12 0011011010010010F111ssssssSSSSSS.
def ARC_DSUBH21_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "dsubh21\t$limm, $simm12_20", []> {
  // Opcode: 0x36927000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010010010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh21<.f> a,limm,limm 0011011000010010F111111110AAAAAA.
def ARC_DSUBH21_a_limm : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "dsubh21\t$ra, $limm", []> {
  // Opcode: 0x36127F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010010;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// dsubh21<.f> 0,limm,limm 0011011000010010F111111110111110.
def ARC_DSUBH21_z_limm : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs ), (ins i32imm:$limm),
    "dsubh21\t$limm", []> {
  // Opcode: 0x36127FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010010;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// dsubh21<.f><.cc> 0,limm,limm 0011011011010010F1111111100QQQQQ.
def ARC_DSUBH21_z_limm_cc : ARCompactInst32_3op<0b00110, 0b010010, "dsubh21",
    (outs ), (ins i32imm:$limm),
    "dsubh21\t$limm", []> {
  // Opcode: 0x36D27F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010010;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh22<.f> a,b,c 00110bbb00010011FBBBCCCCCCAAAAAA.
def ARC_DSUBH22_a_b_c : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "dsubh22\t$ra, $rb, $rc", []> {
  // Opcode: 0x30130000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010011;
  let Defs = [STATUS32];
}

// dsubh22<.f> 0,b,c 00110bbb00010011FBBBCCCCCC111110.
def ARC_DSUBH22_z_b_c : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "dsubh22\t$rb, $rc", []> {
  // Opcode: 0x3013003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh22<.f><.cc> b,b,c 00110bbb11010011FBBBCCCCCC0QQQQQ.
def ARC_DSUBH22_b_c_cc : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "dsubh22\t$rb, $rc", []> {
  // Opcode: 0x30D30000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010011;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh22<.f> a,b,u6 00110bbb01010011FBBBuuuuuuAAAAAA.
def ARC_DSUBH22_a_b_u6 : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dsubh22\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30530000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010011;
  let Defs = [STATUS32];
}

// dsubh22<.f> 0,b,u6 00110bbb01010011FBBBuuuuuu111110.
def ARC_DSUBH22_z_b_u6 : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "dsubh22\t$rb, $uimm6_20", []> {
  // Opcode: 0x3053003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01010011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh22<.f><.cc> b,b,u6 00110bbb11010011FBBBuuuuuu1QQQQQ.
def ARC_DSUBH22_b_u6_cc : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "dsubh22\t$rb, $uimm6_20", []> {
  // Opcode: 0x30D30020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010011;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh22<.f> b,b,s12 00110bbb10010011FBBBssssssSSSSSS.
def ARC_DSUBH22_b_s12 : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "dsubh22\t$rb, $simm12_20", []> {
  // Opcode: 0x30930000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10010011;
  let Defs = [STATUS32];
  
}

// dsubh22<.f> a,limm,c 0011011000010011F111CCCCCCAAAAAA.
def ARC_DSUBH22_a_limm_c : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "dsubh22\t$ra, $limm, $rc", []> {
  // Opcode: 0x36137000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh22<.f> a,b,limm 00110bbb00010011FBBB111110AAAAAA.
def ARC_DSUBH22_a_b_limm : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "dsubh22\t$ra, $rb, $limm", []> {
  // Opcode: 0x30130F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010011;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh22<.f> 0,limm,c 0011011000010011F111CCCCCC111110.
def ARC_DSUBH22_z_limm_c : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dsubh22\t$limm, $rc", []> {
  // Opcode: 0x3613703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh22<.f> 0,b,limm 00110bbb00010011FBBB111110111110.
def ARC_DSUBH22_z_b_limm : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "dsubh22\t$rb, $limm", []> {
  // Opcode: 0x30130FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00010011;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// dsubh22<.f><.cc> 0,limm,c 0011011011010011F111CCCCCC0QQQQQ.
def ARC_DSUBH22_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "dsubh22\t$limm, $rc", []> {
  // Opcode: 0x36D37000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh22<.f><.cc> b,b,limm 00110bbb11010011FBBB1111100QQQQQ.
def ARC_DSUBH22_b_limm_cc : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "dsubh22\t$rb, $limm", []> {
  // Opcode: 0x30D30F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11010011;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// dsubh22<.f> a,limm,u6 0011011001010011F111uuuuuuAAAAAA.
def ARC_DSUBH22_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh22\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36537000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh22<.f> 0,limm,u6 0011011001010011F111uuuuuu111110.
def ARC_DSUBH22_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh22\t$limm, $uimm6_20", []> {
  // Opcode: 0x3653703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001010011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// dsubh22<.f><.cc> 0,limm,u6 0011011011010011F111uuuuuu1QQQQQ.
def ARC_DSUBH22_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "dsubh22\t$limm, $uimm6_20", []> {
  // Opcode: 0x36D37020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// dsubh22<.f> 0,limm,s12 0011011010010011F111ssssssSSSSSS.
def ARC_DSUBH22_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "dsubh22\t$limm, $simm12_20", []> {
  // Opcode: 0x36937000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010010011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// dsubh22<.f> a,limm,limm 0011011000010011F111111110AAAAAA.
def ARC_DSUBH22_a_limm : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "dsubh22\t$ra, $limm", []> {
  // Opcode: 0x36137F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010011;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// dsubh22<.f> 0,limm,limm 0011011000010011F111111110111110.
def ARC_DSUBH22_z_limm : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs ), (ins i32imm:$limm),
    "dsubh22\t$limm", []> {
  // Opcode: 0x36137FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000010011;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// dsubh22<.f><.cc> 0,limm,limm 0011011011010011F1111111100QQQQQ.
def ARC_DSUBH22_z_limm_cc : ARCompactInst32_3op<0b00110, 0b010011, "dsubh22",
    (outs ), (ins i32imm:$limm),
    "dsubh22\t$limm", []> {
  // Opcode: 0x36D37F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011010011;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// fadd<.f> a,b,c 00110bbb00000001FBBBCCCCCCAAAAAA.
def ARC_FADD_a_b_c : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "fadd\t$ra, $rb, $rc", []> {
  // Opcode: 0x30010000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000001;
  let Defs = [STATUS32];
}

// fadd<.f> 0,b,c 00110bbb00000001FBBBCCCCCC111110.
def ARC_FADD_z_b_c : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "fadd\t$rb, $rc", []> {
  // Opcode: 0x3001003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fadd<.f><.cc> b,b,c 00110bbb11000001FBBBCCCCCC0QQQQQ.
def ARC_FADD_b_c_cc : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "fadd\t$rb, $rc", []> {
  // Opcode: 0x30C10000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11000001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// fadd<.f> a,b,u6 00110bbb01000001FBBBuuuuuuAAAAAA.
def ARC_FADD_a_b_u6 : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "fadd\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30410000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01000001;
  let Defs = [STATUS32];
}

// fadd<.f> 0,b,u6 00110bbb01000001FBBBuuuuuu111110.
def ARC_FADD_z_b_u6 : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "fadd\t$rb, $uimm6_20", []> {
  // Opcode: 0x3041003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01000001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fadd<.f><.cc> b,b,u6 00110bbb11000001FBBBuuuuuu1QQQQQ.
def ARC_FADD_b_u6_cc : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "fadd\t$rb, $uimm6_20", []> {
  // Opcode: 0x30C10020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11000001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// fadd<.f> b,b,s12 00110bbb10000001FBBBssssssSSSSSS.
def ARC_FADD_b_s12 : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "fadd\t$rb, $simm12_20", []> {
  // Opcode: 0x30810000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10000001;
  let Defs = [STATUS32];
  
}

// fadd<.f> a,limm,c 0011011000000001F111CCCCCCAAAAAA.
def ARC_FADD_a_limm_c : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "fadd\t$ra, $limm, $rc", []> {
  // Opcode: 0x36017000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// fadd<.f> a,b,limm 00110bbb00000001FBBB111110AAAAAA.
def ARC_FADD_a_b_limm : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "fadd\t$ra, $rb, $limm", []> {
  // Opcode: 0x30010F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// fadd<.f> 0,limm,c 0011011000000001F111CCCCCC111110.
def ARC_FADD_z_limm_c : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "fadd\t$limm, $rc", []> {
  // Opcode: 0x3601703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fadd<.f> 0,b,limm 00110bbb00000001FBBB111110111110.
def ARC_FADD_z_b_limm : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "fadd\t$rb, $limm", []> {
  // Opcode: 0x30010FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// fadd<.f><.cc> 0,limm,c 0011011011000001F111CCCCCC0QQQQQ.
def ARC_FADD_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "fadd\t$limm, $rc", []> {
  // Opcode: 0x36C17000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011000001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// fadd<.f><.cc> b,b,limm 00110bbb11000001FBBB1111100QQQQQ.
def ARC_FADD_b_limm_cc : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "fadd\t$rb, $limm", []> {
  // Opcode: 0x30C10F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11000001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// fadd<.f> a,limm,u6 0011011001000001F111uuuuuuAAAAAA.
def ARC_FADD_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "fadd\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36417000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001000001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// fadd<.f> 0,limm,u6 0011011001000001F111uuuuuu111110.
def ARC_FADD_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "fadd\t$limm, $uimm6_20", []> {
  // Opcode: 0x3641703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001000001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fadd<.f><.cc> 0,limm,u6 0011011011000001F111uuuuuu1QQQQQ.
def ARC_FADD_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "fadd\t$limm, $uimm6_20", []> {
  // Opcode: 0x36C17020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011000001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// fadd<.f> 0,limm,s12 0011011010000001F111ssssssSSSSSS.
def ARC_FADD_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "fadd\t$limm, $simm12_20", []> {
  // Opcode: 0x36817000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010000001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// fadd<.f> a,limm,limm 0011011000000001F111111110AAAAAA.
def ARC_FADD_a_limm : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "fadd\t$ra, $limm", []> {
  // Opcode: 0x36017F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// fadd<.f> 0,limm,limm 0011011000000001F111111110111110.
def ARC_FADD_z_limm : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs ), (ins i32imm:$limm),
    "fadd\t$limm", []> {
  // Opcode: 0x36017FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// fadd<.f><.cc> 0,limm,limm 0011011011000001F1111111100QQQQQ.
def ARC_FADD_z_limm_cc : ARCompactInst32_3op<0b00110, 0b000001, "fadd",
    (outs ), (ins i32imm:$limm),
    "fadd\t$limm", []> {
  // Opcode: 0x36C17F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011000001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// fmul<.f> a,b,c 00110bbb00000000FBBBCCCCCCAAAAAA.
def ARC_FMUL_a_b_c : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "fmul\t$ra, $rb, $rc", []> {
  // Opcode: 0x30000000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000000;
  let Defs = [STATUS32];
}

// fmul<.f> 0,b,c 00110bbb00000000FBBBCCCCCC111110.
def ARC_FMUL_z_b_c : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "fmul\t$rb, $rc", []> {
  // Opcode: 0x3000003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fmul<.f><.cc> b,b,c 00110bbb11000000FBBBCCCCCC0QQQQQ.
def ARC_FMUL_b_c_cc : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "fmul\t$rb, $rc", []> {
  // Opcode: 0x30C00000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11000000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// fmul<.f> a,b,u6 00110bbb01000000FBBBuuuuuuAAAAAA.
def ARC_FMUL_a_b_u6 : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "fmul\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30400000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01000000;
  let Defs = [STATUS32];
}

// fmul<.f> 0,b,u6 00110bbb01000000FBBBuuuuuu111110.
def ARC_FMUL_z_b_u6 : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "fmul\t$rb, $uimm6_20", []> {
  // Opcode: 0x3040003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01000000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fmul<.f><.cc> b,b,u6 00110bbb11000000FBBBuuuuuu1QQQQQ.
def ARC_FMUL_b_u6_cc : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "fmul\t$rb, $uimm6_20", []> {
  // Opcode: 0x30C00020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11000000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// fmul<.f> b,b,s12 00110bbb10000000FBBBssssssSSSSSS.
def ARC_FMUL_b_s12 : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "fmul\t$rb, $simm12_20", []> {
  // Opcode: 0x30800000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10000000;
  let Defs = [STATUS32];
  
}

// fmul<.f> a,limm,c 0011011000000000F111CCCCCCAAAAAA.
def ARC_FMUL_a_limm_c : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "fmul\t$ra, $limm, $rc", []> {
  // Opcode: 0x36007000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// fmul<.f> a,b,limm 00110bbb00000000FBBB111110AAAAAA.
def ARC_FMUL_a_b_limm : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "fmul\t$ra, $rb, $limm", []> {
  // Opcode: 0x30000F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// fmul<.f> 0,limm,c 0011011000000000F111CCCCCC111110.
def ARC_FMUL_z_limm_c : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "fmul\t$limm, $rc", []> {
  // Opcode: 0x3600703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fmul<.f> 0,b,limm 00110bbb00000000FBBB111110111110.
def ARC_FMUL_z_b_limm : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "fmul\t$rb, $limm", []> {
  // Opcode: 0x30000FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// fmul<.f><.cc> 0,limm,c 0011011011000000F111CCCCCC0QQQQQ.
def ARC_FMUL_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "fmul\t$limm, $rc", []> {
  // Opcode: 0x36C07000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011000000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// fmul<.f><.cc> b,b,limm 00110bbb11000000FBBB1111100QQQQQ.
def ARC_FMUL_b_limm_cc : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "fmul\t$rb, $limm", []> {
  // Opcode: 0x30C00F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11000000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// fmul<.f> a,limm,u6 0011011001000000F111uuuuuuAAAAAA.
def ARC_FMUL_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "fmul\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36407000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001000000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// fmul<.f> 0,limm,u6 0011011001000000F111uuuuuu111110.
def ARC_FMUL_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "fmul\t$limm, $uimm6_20", []> {
  // Opcode: 0x3640703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001000000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fmul<.f><.cc> 0,limm,u6 0011011011000000F111uuuuuu1QQQQQ.
def ARC_FMUL_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "fmul\t$limm, $uimm6_20", []> {
  // Opcode: 0x36C07020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011000000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// fmul<.f> 0,limm,s12 0011011010000000F111ssssssSSSSSS.
def ARC_FMUL_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "fmul\t$limm, $simm12_20", []> {
  // Opcode: 0x36807000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010000000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// fmul<.f> a,limm,limm 0011011000000000F111111110AAAAAA.
def ARC_FMUL_a_limm : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "fmul\t$ra, $limm", []> {
  // Opcode: 0x36007F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// fmul<.f> 0,limm,limm 0011011000000000F111111110111110.
def ARC_FMUL_z_limm : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs ), (ins i32imm:$limm),
    "fmul\t$limm", []> {
  // Opcode: 0x36007FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// fmul<.f><.cc> 0,limm,limm 0011011011000000F1111111100QQQQQ.
def ARC_FMUL_z_limm_cc : ARCompactInst32_3op<0b00110, 0b000000, "fmul",
    (outs ), (ins i32imm:$limm),
    "fmul\t$limm", []> {
  // Opcode: 0x36C07F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011000000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// fsub<.f> a,b,c 00110bbb00000010FBBBCCCCCCAAAAAA.
def ARC_FSUB_a_b_c : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs GPR32:$ra), (ins GPR32:$rb, GPR32:$rc),
    "fsub\t$ra, $rb, $rc", []> {
  // Opcode: 0x30020000, Mask: 0xF8FF0000
  // Operands: RA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000010;
  let Defs = [STATUS32];
}

// fsub<.f> 0,b,c 00110bbb00000010FBBBCCCCCC111110.
def ARC_FSUB_z_b_c : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "fsub\t$rb, $rc", []> {
  // Opcode: 0x3002003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fsub<.f><.cc> b,b,c 00110bbb11000010FBBBCCCCCC0QQQQQ.
def ARC_FSUB_b_c_cc : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "fsub\t$rb, $rc", []> {
  // Opcode: 0x30C20000, Mask: 0xF8FF0020
  // Operands: RB, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11000010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// fsub<.f> a,b,u6 00110bbb01000010FBBBuuuuuuAAAAAA.
def ARC_FSUB_a_b_u6 : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs GPR32:$ra), (ins GPR32:$rb, u6imm:$uimm6_20),
    "fsub\t$ra, $rb, $uimm6_20", []> {
  // Opcode: 0x30420000, Mask: 0xF8FF0000
  // Operands: RA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01000010;
  let Defs = [STATUS32];
}

// fsub<.f> 0,b,u6 00110bbb01000010FBBBuuuuuu111110.
def ARC_FSUB_z_b_u6 : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "fsub\t$rb, $uimm6_20", []> {
  // Opcode: 0x3042003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01000010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fsub<.f><.cc> b,b,u6 00110bbb11000010FBBBuuuuuu1QQQQQ.
def ARC_FSUB_b_u6_cc : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "fsub\t$rb, $uimm6_20", []> {
  // Opcode: 0x30C20020, Mask: 0xF8FF0020
  // Operands: RB, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11000010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// fsub<.f> b,b,s12 00110bbb10000010FBBBssssssSSSSSS.
def ARC_FSUB_b_s12 : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs GPR32:$rb), (ins s12imm:$simm12_20),
    "fsub\t$rb, $simm12_20", []> {
  // Opcode: 0x30820000, Mask: 0xF8FF0000
  // Operands: RB, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10000010;
  let Defs = [STATUS32];
  
}

// fsub<.f> a,limm,c 0011011000000010F111CCCCCCAAAAAA.
def ARC_FSUB_a_limm_c : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs GPR32:$ra), (ins i32imm:$limm, GPR32:$rc),
    "fsub\t$ra, $limm, $rc", []> {
  // Opcode: 0x36027000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// fsub<.f> a,b,limm 00110bbb00000010FBBB111110AAAAAA.
def ARC_FSUB_a_b_limm : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs GPR32:$ra), (ins GPR32:$rb, i32imm:$limm),
    "fsub\t$ra, $rb, $limm", []> {
  // Opcode: 0x30020F80, Mask: 0xF8FF0FC0
  // Operands: RA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// fsub<.f> 0,limm,c 0011011000000010F111CCCCCC111110.
def ARC_FSUB_z_limm_c : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "fsub\t$limm, $rc", []> {
  // Opcode: 0x3602703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fsub<.f> 0,b,limm 00110bbb00000010FBBB111110111110.
def ARC_FSUB_z_b_limm : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "fsub\t$rb, $limm", []> {
  // Opcode: 0x30020FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00000010;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// fsub<.f><.cc> 0,limm,c 0011011011000010F111CCCCCC0QQQQQ.
def ARC_FSUB_z_limm_c_cc : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "fsub\t$limm, $rc", []> {
  // Opcode: 0x36C27000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011000010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// fsub<.f><.cc> b,b,limm 00110bbb11000010FBBB1111100QQQQQ.
def ARC_FSUB_b_limm_cc : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "fsub\t$rb, $limm", []> {
  // Opcode: 0x30C20F80, Mask: 0xF8FF0FE0
  // Operands: RB, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11000010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// fsub<.f> a,limm,u6 0011011001000010F111uuuuuuAAAAAA.
def ARC_FSUB_a_limm_u6 : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs GPR32:$ra), (ins i32imm:$limm, u6imm:$uimm6_20),
    "fsub\t$ra, $limm, $uimm6_20", []> {
  // Opcode: 0x36427000, Mask: 0xFFFF7000
  // Operands: RA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001000010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// fsub<.f> 0,limm,u6 0011011001000010F111uuuuuu111110.
def ARC_FSUB_z_limm_u6 : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "fsub\t$limm, $uimm6_20", []> {
  // Opcode: 0x3642703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011001000010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// fsub<.f><.cc> 0,limm,u6 0011011011000010F111uuuuuu1QQQQQ.
def ARC_FSUB_z_limm_u6_cc : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "fsub\t$limm, $uimm6_20", []> {
  // Opcode: 0x36C27020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011000010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// fsub<.f> 0,limm,s12 0011011010000010F111ssssssSSSSSS.
def ARC_FSUB_z_limm_s12 : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "fsub\t$limm, $simm12_20", []> {
  // Opcode: 0x36827000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0011011010000010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// fsub<.f> a,limm,limm 0011011000000010F111111110AAAAAA.
def ARC_FSUB_a_limm : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs GPR32:$ra), (ins i32imm:$limm),
    "fsub\t$ra, $limm", []> {
  // Opcode: 0x36027F80, Mask: 0xFFFF7FC0
  // Operands: RA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000010;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// fsub<.f> 0,limm,limm 0011011000000010F111111110111110.
def ARC_FSUB_z_limm : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs ), (ins i32imm:$limm),
    "fsub\t$limm", []> {
  // Opcode: 0x36027FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0011011000000010;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// fsub<.f><.cc> 0,limm,limm 0011011011000010F1111111100QQQQQ.
def ARC_FSUB_z_limm_cc : ARCompactInst32_3op<0b00110, 0b000010, "fsub",
    (outs ), (ins i32imm:$limm),
    "fsub\t$limm", []> {
  // Opcode: 0x36C27F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0011011011000010;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macdw<.f> a,b,c 00101bbb00010000FBBBCCCCCCAAAAAA.
def ARC_MACDW_a_b_c : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "macdw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28100000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010000;
  let Defs = [STATUS32];
}

// macdw<.f> 0,b,c 00101bbb00010000FBBBCCCCCC111110.
def ARC_MACDW_z_b_c : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "macdw\t$rb, $rc", []> {
  // Opcode: 0x2810003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macdw<.f><.cc> b,b,c 00101bbb11010000FBBBCCCCCC0QQQQQ.
def ARC_MACDW_b_c_cc : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "macdw\t$rb_chk, $rc", []> {
  // Opcode: 0x28D00000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macdw<.f> a,b,u6 00101bbb01010000FBBBuuuuuuAAAAAA.
def ARC_MACDW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "macdw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28500000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01010000;
  let Defs = [STATUS32];
}

// macdw<.f> 0,b,u6 00101bbb01010000FBBBuuuuuu111110.
def ARC_MACDW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "macdw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2850003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01010000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macdw<.f><.cc> b,b,u6 00101bbb11010000FBBBuuuuuu1QQQQQ.
def ARC_MACDW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "macdw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28D00020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macdw<.f> b,b,s12 00101bbb10010000FBBBssssssSSSSSS.
def ARC_MACDW_b_s12 : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "macdw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28900000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10010000;
  let Defs = [STATUS32];
  
}

// macdw<.f> a,limm,c 0010111000010000F111CCCCCCAAAAAA.
def ARC_MACDW_a_limm_c : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "macdw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E107000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macdw<.f> a,b,limm 00101bbb00010000FBBB111110AAAAAA.
def ARC_MACDW_a_b_limm : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "macdw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28100F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// macdw<.f> 0,limm,c 0010111000010000F111CCCCCC111110.
def ARC_MACDW_z_limm_c : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "macdw\t$limm, $rc", []> {
  // Opcode: 0x2E10703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macdw<.f> 0,b,limm 00101bbb00010000FBBB111110111110.
def ARC_MACDW_z_b_limm : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "macdw\t$rb, $limm", []> {
  // Opcode: 0x28100FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// macdw<.f><.cc> 0,limm,c 0010111011010000F111CCCCCC0QQQQQ.
def ARC_MACDW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "macdw\t$limm, $rc", []> {
  // Opcode: 0x2ED07000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macdw<.f><.cc> b,b,limm 00101bbb11010000FBBB1111100QQQQQ.
def ARC_MACDW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "macdw\t$rb_chk, $limm", []> {
  // Opcode: 0x28D00F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macdw<.f> a,limm,u6 0010111001010000F111uuuuuuAAAAAA.
def ARC_MACDW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macdw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E507000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001010000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macdw<.f> 0,limm,u6 0010111001010000F111uuuuuu111110.
def ARC_MACDW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E50703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001010000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macdw<.f><.cc> 0,limm,u6 0010111011010000F111uuuuuu1QQQQQ.
def ARC_MACDW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2ED07020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macdw<.f> 0,limm,s12 0010111010010000F111ssssssSSSSSS.
def ARC_MACDW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "macdw\t$limm, $simm12_20", []> {
  // Opcode: 0x2E907000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010010000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macdw<.f> a,limm,limm 0010111000010000F111111110AAAAAA.
def ARC_MACDW_a_limm : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "macdw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E107F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// macdw<.f> 0,limm,limm 0010111000010000F111111110111110.
def ARC_MACDW_z_limm : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs ), (ins i32imm:$limm),
    "macdw\t$limm", []> {
  // Opcode: 0x2E107FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// macdw<.f><.cc> 0,limm,limm 0010111011010000F1111111100QQQQQ.
def ARC_MACDW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b010000, "macdw",
    (outs ), (ins i32imm:$limm),
    "macdw\t$limm", []> {
  // Opcode: 0x2ED07F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macflw<.f> a,b,c 00101bbb00110100FBBBCCCCCCAAAAAA.
def ARC_MACFLW_a_b_c : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "macflw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28340000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110100;
  let Defs = [STATUS32];
}

// macflw<.f> 0,b,c 00101bbb00110100FBBBCCCCCC111110.
def ARC_MACFLW_z_b_c : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "macflw\t$rb, $rc", []> {
  // Opcode: 0x2834003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macflw<.f><.cc> b,b,c 00101bbb11110100FBBBCCCCCC0QQQQQ.
def ARC_MACFLW_b_c_cc : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "macflw\t$rb_chk, $rc", []> {
  // Opcode: 0x28F40000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110100;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macflw<.f> a,b,u6 00101bbb01110100FBBBuuuuuuAAAAAA.
def ARC_MACFLW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "macflw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28740000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110100;
  let Defs = [STATUS32];
}

// macflw<.f> 0,b,u6 00101bbb01110100FBBBuuuuuu111110.
def ARC_MACFLW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "macflw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2874003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macflw<.f><.cc> b,b,u6 00101bbb11110100FBBBuuuuuu1QQQQQ.
def ARC_MACFLW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "macflw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28F40020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110100;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macflw<.f> b,b,s12 00101bbb10110100FBBBssssssSSSSSS.
def ARC_MACFLW_b_s12 : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "macflw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28B40000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10110100;
  let Defs = [STATUS32];
  
}

// macflw<.f> a,limm,c 0010111000110100F111CCCCCCAAAAAA.
def ARC_MACFLW_a_limm_c : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "macflw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E347000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macflw<.f> a,b,limm 00101bbb00110100FBBB111110AAAAAA.
def ARC_MACFLW_a_b_limm : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "macflw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28340F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110100;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// macflw<.f> 0,limm,c 0010111000110100F111CCCCCC111110.
def ARC_MACFLW_z_limm_c : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "macflw\t$limm, $rc", []> {
  // Opcode: 0x2E34703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macflw<.f> 0,b,limm 00101bbb00110100FBBB111110111110.
def ARC_MACFLW_z_b_limm : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "macflw\t$rb, $limm", []> {
  // Opcode: 0x28340FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110100;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// macflw<.f><.cc> 0,limm,c 0010111011110100F111CCCCCC0QQQQQ.
def ARC_MACFLW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "macflw\t$limm, $rc", []> {
  // Opcode: 0x2EF47000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macflw<.f><.cc> b,b,limm 00101bbb11110100FBBB1111100QQQQQ.
def ARC_MACFLW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "macflw\t$rb_chk, $limm", []> {
  // Opcode: 0x28F40F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110100;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macflw<.f> a,limm,u6 0010111001110100F111uuuuuuAAAAAA.
def ARC_MACFLW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macflw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E747000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macflw<.f> 0,limm,u6 0010111001110100F111uuuuuu111110.
def ARC_MACFLW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macflw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E74703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macflw<.f><.cc> 0,limm,u6 0010111011110100F111uuuuuu1QQQQQ.
def ARC_MACFLW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macflw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EF47020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macflw<.f> 0,limm,s12 0010111010110100F111ssssssSSSSSS.
def ARC_MACFLW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "macflw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EB47000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010110100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macflw<.f> a,limm,limm 0010111000110100F111111110AAAAAA.
def ARC_MACFLW_a_limm : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "macflw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E347F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110100;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// macflw<.f> 0,limm,limm 0010111000110100F111111110111110.
def ARC_MACFLW_z_limm : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs ), (ins i32imm:$limm),
    "macflw\t$limm", []> {
  // Opcode: 0x2E347FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110100;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// macflw<.f><.cc> 0,limm,limm 0010111011110100F1111111100QQQQQ.
def ARC_MACFLW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b110100, "macflw",
    (outs ), (ins i32imm:$limm),
    "macflw\t$limm", []> {
  // Opcode: 0x2EF47F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110100;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// machflw<.f> a,b,c 00101bbb00110111FBBBCCCCCCAAAAAA.
def ARC_MACHFLW_a_b_c : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "machflw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28370000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110111;
  let Defs = [STATUS32];
}

// machflw<.f> 0,b,c 00101bbb00110111FBBBCCCCCC111110.
def ARC_MACHFLW_z_b_c : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "machflw\t$rb, $rc", []> {
  // Opcode: 0x2837003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machflw<.f><.cc> b,b,c 00101bbb11110111FBBBCCCCCC0QQQQQ.
def ARC_MACHFLW_b_c_cc : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "machflw\t$rb_chk, $rc", []> {
  // Opcode: 0x28F70000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// machflw<.f> a,b,u6 00101bbb01110111FBBBuuuuuuAAAAAA.
def ARC_MACHFLW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "machflw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28770000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110111;
  let Defs = [STATUS32];
}

// machflw<.f> 0,b,u6 00101bbb01110111FBBBuuuuuu111110.
def ARC_MACHFLW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "machflw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2877003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machflw<.f><.cc> b,b,u6 00101bbb11110111FBBBuuuuuu1QQQQQ.
def ARC_MACHFLW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "machflw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28F70020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// machflw<.f> b,b,s12 00101bbb10110111FBBBssssssSSSSSS.
def ARC_MACHFLW_b_s12 : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "machflw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28B70000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10110111;
  let Defs = [STATUS32];
  
}

// machflw<.f> a,limm,c 0010111000110111F111CCCCCCAAAAAA.
def ARC_MACHFLW_a_limm_c : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "machflw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E377000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// machflw<.f> a,b,limm 00101bbb00110111FBBB111110AAAAAA.
def ARC_MACHFLW_a_b_limm : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "machflw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28370F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110111;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// machflw<.f> 0,limm,c 0010111000110111F111CCCCCC111110.
def ARC_MACHFLW_z_limm_c : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "machflw\t$limm, $rc", []> {
  // Opcode: 0x2E37703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machflw<.f> 0,b,limm 00101bbb00110111FBBB111110111110.
def ARC_MACHFLW_z_b_limm : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "machflw\t$rb, $limm", []> {
  // Opcode: 0x28370FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110111;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// machflw<.f><.cc> 0,limm,c 0010111011110111F111CCCCCC0QQQQQ.
def ARC_MACHFLW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "machflw\t$limm, $rc", []> {
  // Opcode: 0x2EF77000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// machflw<.f><.cc> b,b,limm 00101bbb11110111FBBB1111100QQQQQ.
def ARC_MACHFLW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "machflw\t$rb_chk, $limm", []> {
  // Opcode: 0x28F70F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110111;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// machflw<.f> a,limm,u6 0010111001110111F111uuuuuuAAAAAA.
def ARC_MACHFLW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "machflw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E777000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// machflw<.f> 0,limm,u6 0010111001110111F111uuuuuu111110.
def ARC_MACHFLW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "machflw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E77703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machflw<.f><.cc> 0,limm,u6 0010111011110111F111uuuuuu1QQQQQ.
def ARC_MACHFLW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "machflw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EF77020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110111;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// machflw<.f> 0,limm,s12 0010111010110111F111ssssssSSSSSS.
def ARC_MACHFLW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "machflw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EB77000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010110111;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// machflw<.f> a,limm,limm 0010111000110111F111111110AAAAAA.
def ARC_MACHFLW_a_limm : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "machflw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E377F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110111;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// machflw<.f> 0,limm,limm 0010111000110111F111111110111110.
def ARC_MACHFLW_z_limm : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs ), (ins i32imm:$limm),
    "machflw\t$limm", []> {
  // Opcode: 0x2E377FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110111;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// machflw<.f><.cc> 0,limm,limm 0010111011110111F1111111100QQQQQ.
def ARC_MACHFLW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b110111, "machflw",
    (outs ), (ins i32imm:$limm),
    "machflw\t$limm", []> {
  // Opcode: 0x2EF77F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110111;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// machlw<.f> a,b,c 00101bbb00110110FBBBCCCCCCAAAAAA.
def ARC_MACHLW_a_b_c : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "machlw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28360000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110110;
  let Defs = [STATUS32];
}

// machlw<.f> 0,b,c 00101bbb00110110FBBBCCCCCC111110.
def ARC_MACHLW_z_b_c : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "machlw\t$rb, $rc", []> {
  // Opcode: 0x2836003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machlw<.f><.cc> b,b,c 00101bbb11110110FBBBCCCCCC0QQQQQ.
def ARC_MACHLW_b_c_cc : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "machlw\t$rb_chk, $rc", []> {
  // Opcode: 0x28F60000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110110;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// machlw<.f> a,b,u6 00101bbb01110110FBBBuuuuuuAAAAAA.
def ARC_MACHLW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "machlw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28760000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110110;
  let Defs = [STATUS32];
}

// machlw<.f> 0,b,u6 00101bbb01110110FBBBuuuuuu111110.
def ARC_MACHLW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "machlw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2876003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machlw<.f><.cc> b,b,u6 00101bbb11110110FBBBuuuuuu1QQQQQ.
def ARC_MACHLW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "machlw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28F60020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110110;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// machlw<.f> b,b,s12 00101bbb10110110FBBBssssssSSSSSS.
def ARC_MACHLW_b_s12 : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "machlw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28B60000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10110110;
  let Defs = [STATUS32];
  
}

// machlw<.f> a,limm,c 0010111000110110F111CCCCCCAAAAAA.
def ARC_MACHLW_a_limm_c : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "machlw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E367000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// machlw<.f> a,b,limm 00101bbb00110110FBBB111110AAAAAA.
def ARC_MACHLW_a_b_limm : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "machlw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28360F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110110;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// machlw<.f> 0,limm,c 0010111000110110F111CCCCCC111110.
def ARC_MACHLW_z_limm_c : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "machlw\t$limm, $rc", []> {
  // Opcode: 0x2E36703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machlw<.f> 0,b,limm 00101bbb00110110FBBB111110111110.
def ARC_MACHLW_z_b_limm : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "machlw\t$rb, $limm", []> {
  // Opcode: 0x28360FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110110;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// machlw<.f><.cc> 0,limm,c 0010111011110110F111CCCCCC0QQQQQ.
def ARC_MACHLW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "machlw\t$limm, $rc", []> {
  // Opcode: 0x2EF67000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// machlw<.f><.cc> b,b,limm 00101bbb11110110FBBB1111100QQQQQ.
def ARC_MACHLW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "machlw\t$rb_chk, $limm", []> {
  // Opcode: 0x28F60F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110110;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// machlw<.f> a,limm,u6 0010111001110110F111uuuuuuAAAAAA.
def ARC_MACHLW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "machlw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E767000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// machlw<.f> 0,limm,u6 0010111001110110F111uuuuuu111110.
def ARC_MACHLW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "machlw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E76703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machlw<.f><.cc> 0,limm,u6 0010111011110110F111uuuuuu1QQQQQ.
def ARC_MACHLW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "machlw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EF67020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// machlw<.f> 0,limm,s12 0010111010110110F111ssssssSSSSSS.
def ARC_MACHLW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "machlw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EB67000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010110110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// machlw<.f> a,limm,limm 0010111000110110F111111110AAAAAA.
def ARC_MACHLW_a_limm : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "machlw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E367F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110110;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// machlw<.f> 0,limm,limm 0010111000110110F111111110111110.
def ARC_MACHLW_z_limm : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs ), (ins i32imm:$limm),
    "machlw\t$limm", []> {
  // Opcode: 0x2E367FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110110;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// machlw<.f><.cc> 0,limm,limm 0010111011110110F1111111100QQQQQ.
def ARC_MACHLW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b110110, "machlw",
    (outs ), (ins i32imm:$limm),
    "machlw\t$limm", []> {
  // Opcode: 0x2EF67F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110110;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// machulw<.f> a,b,c 00101bbb00110101FBBBCCCCCCAAAAAA.
def ARC_MACHULW_a_b_c : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "machulw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28350000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110101;
  let Defs = [STATUS32];
}

// machulw<.f> 0,b,c 00101bbb00110101FBBBCCCCCC111110.
def ARC_MACHULW_z_b_c : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "machulw\t$rb, $rc", []> {
  // Opcode: 0x2835003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machulw<.f><.cc> b,b,c 00101bbb11110101FBBBCCCCCC0QQQQQ.
def ARC_MACHULW_b_c_cc : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "machulw\t$rb_chk, $rc", []> {
  // Opcode: 0x28F50000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110101;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// machulw<.f> a,b,u6 00101bbb01110101FBBBuuuuuuAAAAAA.
def ARC_MACHULW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "machulw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28750000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110101;
  let Defs = [STATUS32];
}

// machulw<.f> 0,b,u6 00101bbb01110101FBBBuuuuuu111110.
def ARC_MACHULW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "machulw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2875003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machulw<.f><.cc> b,b,u6 00101bbb11110101FBBBuuuuuu1QQQQQ.
def ARC_MACHULW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "machulw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28F50020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110101;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// machulw<.f> b,b,s12 00101bbb10110101FBBBssssssSSSSSS.
def ARC_MACHULW_b_s12 : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "machulw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28B50000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10110101;
  let Defs = [STATUS32];
  
}

// machulw<.f> a,limm,c 0010111000110101F111CCCCCCAAAAAA.
def ARC_MACHULW_a_limm_c : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "machulw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E357000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// machulw<.f> a,b,limm 00101bbb00110101FBBB111110AAAAAA.
def ARC_MACHULW_a_b_limm : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "machulw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28350F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110101;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// machulw<.f> 0,limm,c 0010111000110101F111CCCCCC111110.
def ARC_MACHULW_z_limm_c : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "machulw\t$limm, $rc", []> {
  // Opcode: 0x2E35703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machulw<.f> 0,b,limm 00101bbb00110101FBBB111110111110.
def ARC_MACHULW_z_b_limm : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "machulw\t$rb, $limm", []> {
  // Opcode: 0x28350FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110101;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// machulw<.f><.cc> 0,limm,c 0010111011110101F111CCCCCC0QQQQQ.
def ARC_MACHULW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "machulw\t$limm, $rc", []> {
  // Opcode: 0x2EF57000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// machulw<.f><.cc> b,b,limm 00101bbb11110101FBBB1111100QQQQQ.
def ARC_MACHULW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "machulw\t$rb_chk, $limm", []> {
  // Opcode: 0x28F50F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110101;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// machulw<.f> a,limm,u6 0010111001110101F111uuuuuuAAAAAA.
def ARC_MACHULW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "machulw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E757000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// machulw<.f> 0,limm,u6 0010111001110101F111uuuuuu111110.
def ARC_MACHULW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "machulw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E75703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// machulw<.f><.cc> 0,limm,u6 0010111011110101F111uuuuuu1QQQQQ.
def ARC_MACHULW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "machulw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EF57020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// machulw<.f> 0,limm,s12 0010111010110101F111ssssssSSSSSS.
def ARC_MACHULW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "machulw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EB57000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010110101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// machulw<.f> a,limm,limm 0010111000110101F111111110AAAAAA.
def ARC_MACHULW_a_limm : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "machulw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E357F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110101;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// machulw<.f> 0,limm,limm 0010111000110101F111111110111110.
def ARC_MACHULW_z_limm : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs ), (ins i32imm:$limm),
    "machulw\t$limm", []> {
  // Opcode: 0x2E357FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110101;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// machulw<.f><.cc> 0,limm,limm 0010111011110101F1111111100QQQQQ.
def ARC_MACHULW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b110101, "machulw",
    (outs ), (ins i32imm:$limm),
    "machulw\t$limm", []> {
  // Opcode: 0x2EF57F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110101;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// maclw<.f> a,b,c 00101bbb00110011FBBBCCCCCCAAAAAA.
def ARC_MACLW_a_b_c : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "maclw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28330000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110011;
  let Defs = [STATUS32];
}

// maclw<.f> 0,b,c 00101bbb00110011FBBBCCCCCC111110.
def ARC_MACLW_z_b_c : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "maclw\t$rb, $rc", []> {
  // Opcode: 0x2833003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// maclw<.f><.cc> b,b,c 00101bbb11110011FBBBCCCCCC0QQQQQ.
def ARC_MACLW_b_c_cc : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "maclw\t$rb_chk, $rc", []> {
  // Opcode: 0x28F30000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110011;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// maclw<.f> a,b,u6 00101bbb01110011FBBBuuuuuuAAAAAA.
def ARC_MACLW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "maclw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28730000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110011;
  let Defs = [STATUS32];
}

// maclw<.f> 0,b,u6 00101bbb01110011FBBBuuuuuu111110.
def ARC_MACLW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "maclw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2873003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// maclw<.f><.cc> b,b,u6 00101bbb11110011FBBBuuuuuu1QQQQQ.
def ARC_MACLW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "maclw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28F30020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110011;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// maclw<.f> b,b,s12 00101bbb10110011FBBBssssssSSSSSS.
def ARC_MACLW_b_s12 : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "maclw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28B30000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10110011;
  let Defs = [STATUS32];
  
}

// maclw<.f> a,limm,c 0010111000110011F111CCCCCCAAAAAA.
def ARC_MACLW_a_limm_c : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "maclw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E337000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// maclw<.f> a,b,limm 00101bbb00110011FBBB111110AAAAAA.
def ARC_MACLW_a_b_limm : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "maclw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28330F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110011;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// maclw<.f> 0,limm,c 0010111000110011F111CCCCCC111110.
def ARC_MACLW_z_limm_c : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "maclw\t$limm, $rc", []> {
  // Opcode: 0x2E33703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// maclw<.f> 0,b,limm 00101bbb00110011FBBB111110111110.
def ARC_MACLW_z_b_limm : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "maclw\t$rb, $limm", []> {
  // Opcode: 0x28330FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110011;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// maclw<.f><.cc> 0,limm,c 0010111011110011F111CCCCCC0QQQQQ.
def ARC_MACLW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "maclw\t$limm, $rc", []> {
  // Opcode: 0x2EF37000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// maclw<.f><.cc> b,b,limm 00101bbb11110011FBBB1111100QQQQQ.
def ARC_MACLW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "maclw\t$rb_chk, $limm", []> {
  // Opcode: 0x28F30F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110011;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// maclw<.f> a,limm,u6 0010111001110011F111uuuuuuAAAAAA.
def ARC_MACLW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "maclw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E737000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// maclw<.f> 0,limm,u6 0010111001110011F111uuuuuu111110.
def ARC_MACLW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "maclw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E73703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// maclw<.f><.cc> 0,limm,u6 0010111011110011F111uuuuuu1QQQQQ.
def ARC_MACLW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "maclw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EF37020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// maclw<.f> 0,limm,s12 0010111010110011F111ssssssSSSSSS.
def ARC_MACLW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "maclw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EB37000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010110011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// maclw<.f> a,limm,limm 0010111000110011F111111110AAAAAA.
def ARC_MACLW_a_limm : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "maclw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E337F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110011;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// maclw<.f> 0,limm,limm 0010111000110011F111111110111110.
def ARC_MACLW_z_limm : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs ), (ins i32imm:$limm),
    "maclw\t$limm", []> {
  // Opcode: 0x2E337FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110011;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// maclw<.f><.cc> 0,limm,limm 0010111011110011F1111111100QQQQQ.
def ARC_MACLW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b110011, "maclw",
    (outs ), (ins i32imm:$limm),
    "maclw\t$limm", []> {
  // Opcode: 0x2EF37F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110011;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macrdw<.f> a,b,c 00101bbb00010010FBBBCCCCCCAAAAAA.
def ARC_MACRDW_a_b_c : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "macrdw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28120000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010010;
  let Defs = [STATUS32];
}

// macrdw<.f> 0,b,c 00101bbb00010010FBBBCCCCCC111110.
def ARC_MACRDW_z_b_c : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "macrdw\t$rb, $rc", []> {
  // Opcode: 0x2812003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macrdw<.f><.cc> b,b,c 00101bbb11010010FBBBCCCCCC0QQQQQ.
def ARC_MACRDW_b_c_cc : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "macrdw\t$rb_chk, $rc", []> {
  // Opcode: 0x28D20000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macrdw<.f> a,b,u6 00101bbb01010010FBBBuuuuuuAAAAAA.
def ARC_MACRDW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "macrdw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28520000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01010010;
  let Defs = [STATUS32];
}

// macrdw<.f> 0,b,u6 00101bbb01010010FBBBuuuuuu111110.
def ARC_MACRDW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "macrdw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2852003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01010010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macrdw<.f><.cc> b,b,u6 00101bbb11010010FBBBuuuuuu1QQQQQ.
def ARC_MACRDW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "macrdw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28D20020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macrdw<.f> b,b,s12 00101bbb10010010FBBBssssssSSSSSS.
def ARC_MACRDW_b_s12 : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "macrdw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28920000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10010010;
  let Defs = [STATUS32];
  
}

// macrdw<.f> a,limm,c 0010111000010010F111CCCCCCAAAAAA.
def ARC_MACRDW_a_limm_c : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "macrdw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E127000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macrdw<.f> a,b,limm 00101bbb00010010FBBB111110AAAAAA.
def ARC_MACRDW_a_b_limm : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "macrdw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28120F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// macrdw<.f> 0,limm,c 0010111000010010F111CCCCCC111110.
def ARC_MACRDW_z_limm_c : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "macrdw\t$limm, $rc", []> {
  // Opcode: 0x2E12703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macrdw<.f> 0,b,limm 00101bbb00010010FBBB111110111110.
def ARC_MACRDW_z_b_limm : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "macrdw\t$rb, $limm", []> {
  // Opcode: 0x28120FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010010;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// macrdw<.f><.cc> 0,limm,c 0010111011010010F111CCCCCC0QQQQQ.
def ARC_MACRDW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "macrdw\t$limm, $rc", []> {
  // Opcode: 0x2ED27000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macrdw<.f><.cc> b,b,limm 00101bbb11010010FBBB1111100QQQQQ.
def ARC_MACRDW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "macrdw\t$rb_chk, $limm", []> {
  // Opcode: 0x28D20F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macrdw<.f> a,limm,u6 0010111001010010F111uuuuuuAAAAAA.
def ARC_MACRDW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macrdw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E527000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001010010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macrdw<.f> 0,limm,u6 0010111001010010F111uuuuuu111110.
def ARC_MACRDW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macrdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E52703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001010010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macrdw<.f><.cc> 0,limm,u6 0010111011010010F111uuuuuu1QQQQQ.
def ARC_MACRDW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macrdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2ED27020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macrdw<.f> 0,limm,s12 0010111010010010F111ssssssSSSSSS.
def ARC_MACRDW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "macrdw\t$limm, $simm12_20", []> {
  // Opcode: 0x2E927000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010010010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macrdw<.f> a,limm,limm 0010111000010010F111111110AAAAAA.
def ARC_MACRDW_a_limm : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "macrdw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E127F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010010;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// macrdw<.f> 0,limm,limm 0010111000010010F111111110111110.
def ARC_MACRDW_z_limm : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs ), (ins i32imm:$limm),
    "macrdw\t$limm", []> {
  // Opcode: 0x2E127FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010010;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// macrdw<.f><.cc> 0,limm,limm 0010111011010010F1111111100QQQQQ.
def ARC_MACRDW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b010010, "macrdw",
    (outs ), (ins i32imm:$limm),
    "macrdw\t$limm", []> {
  // Opcode: 0x2ED27F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010010;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macudw<.f> a,b,c 00101bbb00010001FBBBCCCCCCAAAAAA.
def ARC_MACUDW_a_b_c : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "macudw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28110000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010001;
  let Defs = [STATUS32];
}

// macudw<.f> 0,b,c 00101bbb00010001FBBBCCCCCC111110.
def ARC_MACUDW_z_b_c : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "macudw\t$rb, $rc", []> {
  // Opcode: 0x2811003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macudw<.f><.cc> b,b,c 00101bbb11010001FBBBCCCCCC0QQQQQ.
def ARC_MACUDW_b_c_cc : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "macudw\t$rb_chk, $rc", []> {
  // Opcode: 0x28D10000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macudw<.f> a,b,u6 00101bbb01010001FBBBuuuuuuAAAAAA.
def ARC_MACUDW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "macudw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28510000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01010001;
  let Defs = [STATUS32];
}

// macudw<.f> 0,b,u6 00101bbb01010001FBBBuuuuuu111110.
def ARC_MACUDW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "macudw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2851003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01010001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macudw<.f><.cc> b,b,u6 00101bbb11010001FBBBuuuuuu1QQQQQ.
def ARC_MACUDW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "macudw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28D10020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macudw<.f> b,b,s12 00101bbb10010001FBBBssssssSSSSSS.
def ARC_MACUDW_b_s12 : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "macudw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28910000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10010001;
  let Defs = [STATUS32];
  
}

// macudw<.f> a,limm,c 0010111000010001F111CCCCCCAAAAAA.
def ARC_MACUDW_a_limm_c : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "macudw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E117000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macudw<.f> a,b,limm 00101bbb00010001FBBB111110AAAAAA.
def ARC_MACUDW_a_b_limm : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "macudw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28110F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// macudw<.f> 0,limm,c 0010111000010001F111CCCCCC111110.
def ARC_MACUDW_z_limm_c : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "macudw\t$limm, $rc", []> {
  // Opcode: 0x2E11703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macudw<.f> 0,b,limm 00101bbb00010001FBBB111110111110.
def ARC_MACUDW_z_b_limm : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "macudw\t$rb, $limm", []> {
  // Opcode: 0x28110FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// macudw<.f><.cc> 0,limm,c 0010111011010001F111CCCCCC0QQQQQ.
def ARC_MACUDW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "macudw\t$limm, $rc", []> {
  // Opcode: 0x2ED17000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macudw<.f><.cc> b,b,limm 00101bbb11010001FBBB1111100QQQQQ.
def ARC_MACUDW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "macudw\t$rb_chk, $limm", []> {
  // Opcode: 0x28D10F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// macudw<.f> a,limm,u6 0010111001010001F111uuuuuuAAAAAA.
def ARC_MACUDW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macudw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E517000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001010001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macudw<.f> 0,limm,u6 0010111001010001F111uuuuuu111110.
def ARC_MACUDW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macudw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E51703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001010001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// macudw<.f><.cc> 0,limm,u6 0010111011010001F111uuuuuu1QQQQQ.
def ARC_MACUDW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "macudw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2ED17020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// macudw<.f> 0,limm,s12 0010111010010001F111ssssssSSSSSS.
def ARC_MACUDW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "macudw\t$limm, $simm12_20", []> {
  // Opcode: 0x2E917000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010010001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// macudw<.f> a,limm,limm 0010111000010001F111111110AAAAAA.
def ARC_MACUDW_a_limm : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "macudw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E117F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// macudw<.f> 0,limm,limm 0010111000010001F111111110111110.
def ARC_MACUDW_z_limm : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs ), (ins i32imm:$limm),
    "macudw\t$limm", []> {
  // Opcode: 0x2E117FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// macudw<.f><.cc> 0,limm,limm 0010111011010001F1111111100QQQQQ.
def ARC_MACUDW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b010001, "macudw",
    (outs ), (ins i32imm:$limm),
    "macudw\t$limm", []> {
  // Opcode: 0x2ED17F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpy<.f> a,b,c 00100bbb00011010FBBBCCCCCCAAAAAA.
def ARC_MPY_a_b_c : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "mpy\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x201A0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011010;
  let Defs = [STATUS32];
}

// mpy<.f> 0,b,c 00100bbb00011010FBBBCCCCCC111110.
def ARC_MPY_z_b_c : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "mpy\t$rb, $rc", []> {
  // Opcode: 0x201A003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpy<.f><.cc> b,b,c 00100bbb11011010FBBBCCCCCC0QQQQQ.
def ARC_MPY_b_c_cc : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "mpy\t$rb_chk, $rc", []> {
  // Opcode: 0x20DA0000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpy<.f> a,b,u6 00100bbb01011010FBBBuuuuuuAAAAAA.
def ARC_MPY_a_b_u6 : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mpy\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x205A0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011010;
  let Defs = [STATUS32];
}

// mpy<.f> 0,b,u6 00100bbb01011010FBBBuuuuuu111110.
def ARC_MPY_z_b_u6 : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mpy\t$rb, $uimm6_20", []> {
  // Opcode: 0x205A003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpy<.f><.cc> b,b,u6 00100bbb11011010FBBBuuuuuu1QQQQQ.
def ARC_MPY_b_u6_cc : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "mpy\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x20DA0020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpy<.f> b,b,s12 00100bbb10011010FBBBssssssSSSSSS.
def ARC_MPY_b_s12 : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "mpy\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x209A0000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10011010;
  let Defs = [STATUS32];
  
}

// mpy<.f> a,limm,c 0010011000011010F111CCCCCCAAAAAA.
def ARC_MPY_a_limm_c : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "mpy\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x261A7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpy<.f> a,b,limm 00100bbb00011010FBBB111110AAAAAA.
def ARC_MPY_a_b_limm : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "mpy\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x201A0F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// mpy<.f> 0,limm,c 0010011000011010F111CCCCCC111110.
def ARC_MPY_z_limm_c : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mpy\t$limm, $rc", []> {
  // Opcode: 0x261A703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpy<.f> 0,b,limm 00100bbb00011010FBBB111110111110.
def ARC_MPY_z_b_limm : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "mpy\t$rb, $limm", []> {
  // Opcode: 0x201A0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011010;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// mpy<.f><.cc> b,b,limm 00100bbb11011010FBBB1111100QQQQQ.
def ARC_MPY_b_limm_cc : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "mpy\t$rb_chk, $limm", []> {
  // Opcode: 0x20DA0F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpy<.f><.cc> 0,limm,c 0010011011011010F111CCCCCC0QQQQQ.
def ARC_MPY_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mpy\t$limm, $rc", []> {
  // Opcode: 0x26DA7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpy<.f> a,limm,u6 0010011001011010F111uuuuuuAAAAAA.
def ARC_MPY_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpy\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x265A7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpy<.f> 0,limm,u6 0010011001011010F111uuuuuu111110.
def ARC_MPY_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpy\t$limm, $uimm6_20", []> {
  // Opcode: 0x265A703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpy<.f><.cc> 0,limm,u6 0010011011011010F111uuuuuu1QQQQQ.
def ARC_MPY_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpy\t$limm, $uimm6_20", []> {
  // Opcode: 0x26DA7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpy<.f> 0,limm,s12 0010011010011010F111ssssssSSSSSS.
def ARC_MPY_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "mpy\t$limm, $simm12_20", []> {
  // Opcode: 0x269A7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010011010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpy<.f> a,limm,limm 0010011000011010F111111110AAAAAA.
def ARC_MPY_a_limm : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "mpy\t$ra_chk, $limm", []> {
  // Opcode: 0x261A7F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011010;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// mpy<.f> 0,limm,limm 0010011000011010F111111110111110.
def ARC_MPY_z_limm : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs ), (ins i32imm:$limm),
    "mpy\t$limm", []> {
  // Opcode: 0x261A7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011010;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// mpy<.f><.cc> 0,limm,limm 0010011011011010F1111111100QQQQQ.
def ARC_MPY_z_limm_cc : ARCompactInst32_3op<0b00100, 0b011010, "mpy",
    (outs ), (ins i32imm:$limm),
    "mpy\t$limm", []> {
  // Opcode: 0x26DA7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011010;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpyh<.f> a,b,c 00100bbb00011011FBBBCCCCCCAAAAAA.
def ARC_MPYH_a_b_c : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "mpyh\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x201B0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011011;
  let Defs = [STATUS32];
}

// mpyh<.f> 0,b,c 00100bbb00011011FBBBCCCCCC111110.
def ARC_MPYH_z_b_c : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "mpyh\t$rb, $rc", []> {
  // Opcode: 0x201B003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyh<.f><.cc> b,b,c 00100bbb11011011FBBBCCCCCC0QQQQQ.
def ARC_MPYH_b_c_cc : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "mpyh\t$rb_chk, $rc", []> {
  // Opcode: 0x20DB0000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011011;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyh<.f> a,b,u6 00100bbb01011011FBBBuuuuuuAAAAAA.
def ARC_MPYH_a_b_u6 : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mpyh\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x205B0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011011;
  let Defs = [STATUS32];
}

// mpyh<.f> 0,b,u6 00100bbb01011011FBBBuuuuuu111110.
def ARC_MPYH_z_b_u6 : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mpyh\t$rb, $uimm6_20", []> {
  // Opcode: 0x205B003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011011;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyh<.f><.cc> b,b,u6 00100bbb11011011FBBBuuuuuu1QQQQQ.
def ARC_MPYH_b_u6_cc : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "mpyh\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x20DB0020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011011;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyh<.f> b,b,s12 00100bbb10011011FBBBssssssSSSSSS.
def ARC_MPYH_b_s12 : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "mpyh\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x209B0000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10011011;
  let Defs = [STATUS32];
  
}

// mpyh<.f> a,limm,c 0010011000011011F111CCCCCCAAAAAA.
def ARC_MPYH_a_limm_c : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "mpyh\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x261B7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpyh<.f> a,b,limm 00100bbb00011011FBBB111110AAAAAA.
def ARC_MPYH_a_b_limm : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "mpyh\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x201B0F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011011;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// mpyh<.f> 0,limm,c 0010011000011011F111CCCCCC111110.
def ARC_MPYH_z_limm_c : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mpyh\t$limm, $rc", []> {
  // Opcode: 0x261B703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyh<.f> 0,b,limm 00100bbb00011011FBBB111110111110.
def ARC_MPYH_z_b_limm : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "mpyh\t$rb, $limm", []> {
  // Opcode: 0x201B0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011011;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// mpyh<.f><.cc> b,b,limm 00100bbb11011011FBBB1111100QQQQQ.
def ARC_MPYH_b_limm_cc : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "mpyh\t$rb_chk, $limm", []> {
  // Opcode: 0x20DB0F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011011;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyh<.f><.cc> 0,limm,c 0010011011011011F111CCCCCC0QQQQQ.
def ARC_MPYH_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mpyh\t$limm, $rc", []> {
  // Opcode: 0x26DB7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpyh<.f> a,limm,u6 0010011001011011F111uuuuuuAAAAAA.
def ARC_MPYH_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpyh\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x265B7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpyh<.f> 0,limm,u6 0010011001011011F111uuuuuu111110.
def ARC_MPYH_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpyh\t$limm, $uimm6_20", []> {
  // Opcode: 0x265B703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011011;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyh<.f><.cc> 0,limm,u6 0010011011011011F111uuuuuu1QQQQQ.
def ARC_MPYH_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpyh\t$limm, $uimm6_20", []> {
  // Opcode: 0x26DB7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011011;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpyh<.f> 0,limm,s12 0010011010011011F111ssssssSSSSSS.
def ARC_MPYH_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "mpyh\t$limm, $simm12_20", []> {
  // Opcode: 0x269B7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010011011;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpyh<.f> a,limm,limm 0010011000011011F111111110AAAAAA.
def ARC_MPYH_a_limm : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "mpyh\t$ra_chk, $limm", []> {
  // Opcode: 0x261B7F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011011;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// mpyh<.f> 0,limm,limm 0010011000011011F111111110111110.
def ARC_MPYH_z_limm : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs ), (ins i32imm:$limm),
    "mpyh\t$limm", []> {
  // Opcode: 0x261B7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011011;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// mpyh<.f><.cc> 0,limm,limm 0010011011011011F1111111100QQQQQ.
def ARC_MPYH_z_limm_cc : ARCompactInst32_3op<0b00100, 0b011011, "mpyh",
    (outs ), (ins i32imm:$limm),
    "mpyh\t$limm", []> {
  // Opcode: 0x26DB7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011011;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpyhu<.f> a,b,c 00100bbb00011100FBBBCCCCCCAAAAAA.
def ARC_MPYHU_a_b_c : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "mpyhu\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x201C0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011100;
  let Defs = [STATUS32];
}

// mpyhu<.f> 0,b,c 00100bbb00011100FBBBCCCCCC111110.
def ARC_MPYHU_z_b_c : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "mpyhu\t$rb, $rc", []> {
  // Opcode: 0x201C003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyhu<.f><.cc> b,b,c 00100bbb11011100FBBBCCCCCC0QQQQQ.
def ARC_MPYHU_b_c_cc : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "mpyhu\t$rb_chk, $rc", []> {
  // Opcode: 0x20DC0000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011100;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyhu<.f> a,b,u6 00100bbb01011100FBBBuuuuuuAAAAAA.
def ARC_MPYHU_a_b_u6 : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mpyhu\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x205C0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011100;
  let Defs = [STATUS32];
}

// mpyhu<.f> 0,b,u6 00100bbb01011100FBBBuuuuuu111110.
def ARC_MPYHU_z_b_u6 : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mpyhu\t$rb, $uimm6_20", []> {
  // Opcode: 0x205C003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyhu<.f><.cc> b,b,u6 00100bbb11011100FBBBuuuuuu1QQQQQ.
def ARC_MPYHU_b_u6_cc : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "mpyhu\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x20DC0020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011100;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyhu<.f> b,b,s12 00100bbb10011100FBBBssssssSSSSSS.
def ARC_MPYHU_b_s12 : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "mpyhu\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x209C0000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10011100;
  let Defs = [STATUS32];
  
}

// mpyhu<.f> a,limm,c 0010011000011100F111CCCCCCAAAAAA.
def ARC_MPYHU_a_limm_c : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "mpyhu\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x261C7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpyhu<.f> a,b,limm 00100bbb00011100FBBB111110AAAAAA.
def ARC_MPYHU_a_b_limm : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "mpyhu\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x201C0F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011100;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// mpyhu<.f> 0,limm,c 0010011000011100F111CCCCCC111110.
def ARC_MPYHU_z_limm_c : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mpyhu\t$limm, $rc", []> {
  // Opcode: 0x261C703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyhu<.f> 0,b,limm 00100bbb00011100FBBB111110111110.
def ARC_MPYHU_z_b_limm : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "mpyhu\t$rb, $limm", []> {
  // Opcode: 0x201C0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011100;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// mpyhu<.f><.cc> b,b,limm 00100bbb11011100FBBB1111100QQQQQ.
def ARC_MPYHU_b_limm_cc : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "mpyhu\t$rb_chk, $limm", []> {
  // Opcode: 0x20DC0F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011100;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyhu<.f><.cc> 0,limm,c 0010011011011100F111CCCCCC0QQQQQ.
def ARC_MPYHU_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mpyhu\t$limm, $rc", []> {
  // Opcode: 0x26DC7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpyhu<.f> a,limm,u6 0010011001011100F111uuuuuuAAAAAA.
def ARC_MPYHU_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpyhu\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x265C7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpyhu<.f> 0,limm,u6 0010011001011100F111uuuuuu111110.
def ARC_MPYHU_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpyhu\t$limm, $uimm6_20", []> {
  // Opcode: 0x265C703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyhu<.f><.cc> 0,limm,u6 0010011011011100F111uuuuuu1QQQQQ.
def ARC_MPYHU_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpyhu\t$limm, $uimm6_20", []> {
  // Opcode: 0x26DC7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpyhu<.f> 0,limm,s12 0010011010011100F111ssssssSSSSSS.
def ARC_MPYHU_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "mpyhu\t$limm, $simm12_20", []> {
  // Opcode: 0x269C7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010011100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpyhu<.f> a,limm,limm 0010011000011100F111111110AAAAAA.
def ARC_MPYHU_a_limm : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "mpyhu\t$ra_chk, $limm", []> {
  // Opcode: 0x261C7F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011100;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// mpyhu<.f> 0,limm,limm 0010011000011100F111111110111110.
def ARC_MPYHU_z_limm : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs ), (ins i32imm:$limm),
    "mpyhu\t$limm", []> {
  // Opcode: 0x261C7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011100;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// mpyhu<.f><.cc> 0,limm,limm 0010011011011100F1111111100QQQQQ.
def ARC_MPYHU_z_limm_cc : ARCompactInst32_3op<0b00100, 0b011100, "mpyhu",
    (outs ), (ins i32imm:$limm),
    "mpyhu\t$limm", []> {
  // Opcode: 0x26DC7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011100;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpyqb<.f><.cc> b,b,c 00110bbb11100101FBBBCCCCCC0QQQQQ.
def ARC_MPYQB_b_c_cc : ARCompactInst32_3op<0b00110, 0b100101, "mpyqb",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "mpyqb\t$rb_chk, $rc", []> {
  // Opcode: 0x30E50000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100101;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyqb<.f> a,b,u6 00110bbb01100101FBBBuuuuuuAAAAAA.
def ARC_MPYQB_a_b_u6 : ARCompactInst32_3op<0b00110, 0b100101, "mpyqb",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mpyqb\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x30650000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b01100101;
  let Defs = [STATUS32];
}

// mpyqb<.f><.cc> b,b,u6 00110bbb11100101FBBBuuuuuu1QQQQQ.
def ARC_MPYQB_b_u6_cc : ARCompactInst32_3op<0b00110, 0b100101, "mpyqb",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "mpyqb\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x30E50020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100101;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyqb<.f> b,b,s12 00110bbb10100101FBBBssssssSSSSSS.
def ARC_MPYQB_b_s12 : ARCompactInst32_3op<0b00110, 0b100101, "mpyqb",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "mpyqb\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x30A50000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b10100101;
  let Defs = [STATUS32];
  
}

// mpyqb<.f> a,limm,c 0011011000100101F111CCCCCCAAAAAA.
def ARC_MPYQB_a_limm_c : ARCompactInst32_3op<0b00110, 0b100101, "mpyqb",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "mpyqb\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x36257000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0011011000100101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpyqb<.f> a,b,limm 00110bbb00100101FBBB111110AAAAAA.
def ARC_MPYQB_a_b_limm : ARCompactInst32_3op<0b00110, 0b100101, "mpyqb",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "mpyqb\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x30250F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b00100101;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// mpyqb<.f><.cc> b,b,limm 00110bbb11100101FBBB1111100QQQQQ.
def ARC_MPYQB_b_limm_cc : ARCompactInst32_3op<0b00110, 0b100101, "mpyqb",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "mpyqb\t$rb_chk, $limm", []> {
  // Opcode: 0x30E50F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00110;
  let Inst{23-16} = 0b11100101;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyu<.f> a,b,c 00100bbb00011101FBBBCCCCCCAAAAAA.
def ARC_MPYU_a_b_c : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "mpyu\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x201D0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011101;
  let Defs = [STATUS32];
}

// mpyu<.f> 0,b,c 00100bbb00011101FBBBCCCCCC111110.
def ARC_MPYU_z_b_c : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "mpyu\t$rb, $rc", []> {
  // Opcode: 0x201D003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyu<.f><.cc> b,b,c 00100bbb11011101FBBBCCCCCC0QQQQQ.
def ARC_MPYU_b_c_cc : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "mpyu\t$rb_chk, $rc", []> {
  // Opcode: 0x20DD0000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011101;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyu<.f> a,b,u6 00100bbb01011101FBBBuuuuuuAAAAAA.
def ARC_MPYU_a_b_u6 : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mpyu\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x205D0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011101;
  let Defs = [STATUS32];
}

// mpyu<.f> 0,b,u6 00100bbb01011101FBBBuuuuuu111110.
def ARC_MPYU_z_b_u6 : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mpyu\t$rb, $uimm6_20", []> {
  // Opcode: 0x205D003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01011101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyu<.f><.cc> b,b,u6 00100bbb11011101FBBBuuuuuu1QQQQQ.
def ARC_MPYU_b_u6_cc : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "mpyu\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x20DD0020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011101;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyu<.f> b,b,s12 00100bbb10011101FBBBssssssSSSSSS.
def ARC_MPYU_b_s12 : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "mpyu\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x209D0000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b10011101;
  let Defs = [STATUS32];
  
}

// mpyu<.f> a,limm,c 0010011000011101F111CCCCCCAAAAAA.
def ARC_MPYU_a_limm_c : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "mpyu\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x261D7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpyu<.f> a,b,limm 00100bbb00011101FBBB111110AAAAAA.
def ARC_MPYU_a_b_limm : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "mpyu\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x201D0F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011101;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// mpyu<.f> 0,limm,c 0010011000011101F111CCCCCC111110.
def ARC_MPYU_z_limm_c : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mpyu\t$limm, $rc", []> {
  // Opcode: 0x261D703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyu<.f> 0,b,limm 00100bbb00011101FBBB111110111110.
def ARC_MPYU_z_b_limm : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "mpyu\t$rb, $limm", []> {
  // Opcode: 0x201D0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00011101;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// mpyu<.f><.cc> b,b,limm 00100bbb11011101FBBB1111100QQQQQ.
def ARC_MPYU_b_limm_cc : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "mpyu\t$rb_chk, $limm", []> {
  // Opcode: 0x20DD0F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b11011101;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mpyu<.f><.cc> 0,limm,c 0010011011011101F111CCCCCC0QQQQQ.
def ARC_MPYU_z_limm_c_cc : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mpyu\t$limm, $rc", []> {
  // Opcode: 0x26DD7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpyu<.f> a,limm,u6 0010011001011101F111uuuuuuAAAAAA.
def ARC_MPYU_a_limm_u6 : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpyu\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x265D7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpyu<.f> 0,limm,u6 0010011001011101F111uuuuuu111110.
def ARC_MPYU_z_limm_u6 : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpyu\t$limm, $uimm6_20", []> {
  // Opcode: 0x265D703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011001011101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mpyu<.f><.cc> 0,limm,u6 0010011011011101F111uuuuuu1QQQQQ.
def ARC_MPYU_z_limm_u6_cc : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mpyu\t$limm, $uimm6_20", []> {
  // Opcode: 0x26DD7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mpyu<.f> 0,limm,s12 0010011010011101F111ssssssSSSSSS.
def ARC_MPYU_z_limm_s12 : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "mpyu\t$limm, $simm12_20", []> {
  // Opcode: 0x269D7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010011010011101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mpyu<.f> a,limm,limm 0010011000011101F111111110AAAAAA.
def ARC_MPYU_a_limm : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "mpyu\t$ra_chk, $limm", []> {
  // Opcode: 0x261D7F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011101;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// mpyu<.f> 0,limm,limm 0010011000011101F111111110111110.
def ARC_MPYU_z_limm : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs ), (ins i32imm:$limm),
    "mpyu\t$limm", []> {
  // Opcode: 0x261D7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010011000011101;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// mpyu<.f><.cc> 0,limm,limm 0010011011011101F1111111100QQQQQ.
def ARC_MPYU_z_limm_cc : ARCompactInst32_3op<0b00100, 0b011101, "mpyu",
    (outs ), (ins i32imm:$limm),
    "mpyu\t$limm", []> {
  // Opcode: 0x26DD7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010011011011101;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// msubdw<.f> a,b,c 00101bbb00010100FBBBCCCCCCAAAAAA.
def ARC_MSUBDW_a_b_c : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "msubdw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28140000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010100;
  let Defs = [STATUS32];
}

// msubdw<.f> 0,b,c 00101bbb00010100FBBBCCCCCC111110.
def ARC_MSUBDW_z_b_c : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "msubdw\t$rb, $rc", []> {
  // Opcode: 0x2814003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// msubdw<.f><.cc> b,b,c 00101bbb11010100FBBBCCCCCC0QQQQQ.
def ARC_MSUBDW_b_c_cc : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "msubdw\t$rb_chk, $rc", []> {
  // Opcode: 0x28D40000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010100;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// msubdw<.f> a,b,u6 00101bbb01010100FBBBuuuuuuAAAAAA.
def ARC_MSUBDW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "msubdw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28540000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01010100;
  let Defs = [STATUS32];
}

// msubdw<.f> 0,b,u6 00101bbb01010100FBBBuuuuuu111110.
def ARC_MSUBDW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "msubdw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2854003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01010100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// msubdw<.f><.cc> b,b,u6 00101bbb11010100FBBBuuuuuu1QQQQQ.
def ARC_MSUBDW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "msubdw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28D40020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010100;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// msubdw<.f> b,b,s12 00101bbb10010100FBBBssssssSSSSSS.
def ARC_MSUBDW_b_s12 : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "msubdw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28940000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10010100;
  let Defs = [STATUS32];
  
}

// msubdw<.f> a,limm,c 0010111000010100F111CCCCCCAAAAAA.
def ARC_MSUBDW_a_limm_c : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "msubdw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E147000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// msubdw<.f> a,b,limm 00101bbb00010100FBBB111110AAAAAA.
def ARC_MSUBDW_a_b_limm : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "msubdw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28140F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010100;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// msubdw<.f> 0,limm,c 0010111000010100F111CCCCCC111110.
def ARC_MSUBDW_z_limm_c : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "msubdw\t$limm, $rc", []> {
  // Opcode: 0x2E14703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// msubdw<.f> 0,b,limm 00101bbb00010100FBBB111110111110.
def ARC_MSUBDW_z_b_limm : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "msubdw\t$rb, $limm", []> {
  // Opcode: 0x28140FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00010100;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// msubdw<.f><.cc> 0,limm,c 0010111011010100F111CCCCCC0QQQQQ.
def ARC_MSUBDW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "msubdw\t$limm, $rc", []> {
  // Opcode: 0x2ED47000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// msubdw<.f><.cc> b,b,limm 00101bbb11010100FBBB1111100QQQQQ.
def ARC_MSUBDW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "msubdw\t$rb_chk, $limm", []> {
  // Opcode: 0x28D40F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11010100;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// msubdw<.f> a,limm,u6 0010111001010100F111uuuuuuAAAAAA.
def ARC_MSUBDW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "msubdw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E547000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001010100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// msubdw<.f> 0,limm,u6 0010111001010100F111uuuuuu111110.
def ARC_MSUBDW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "msubdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E54703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001010100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// msubdw<.f><.cc> 0,limm,u6 0010111011010100F111uuuuuu1QQQQQ.
def ARC_MSUBDW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "msubdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2ED47020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// msubdw<.f> 0,limm,s12 0010111010010100F111ssssssSSSSSS.
def ARC_MSUBDW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "msubdw\t$limm, $simm12_20", []> {
  // Opcode: 0x2E947000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010010100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// msubdw<.f> a,limm,limm 0010111000010100F111111110AAAAAA.
def ARC_MSUBDW_a_limm : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "msubdw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E147F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010100;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// msubdw<.f> 0,limm,limm 0010111000010100F111111110111110.
def ARC_MSUBDW_z_limm : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs ), (ins i32imm:$limm),
    "msubdw\t$limm", []> {
  // Opcode: 0x2E147FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000010100;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// msubdw<.f><.cc> 0,limm,limm 0010111011010100F1111111100QQQQQ.
def ARC_MSUBDW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b010100, "msubdw",
    (outs ), (ins i32imm:$limm),
    "msubdw\t$limm", []> {
  // Opcode: 0x2ED47F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011010100;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// muldw<.f> a,b,c 00101bbb00001100FBBBCCCCCCAAAAAA.
def ARC_MULDW_a_b_c : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "muldw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x280C0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001100;
  let Defs = [STATUS32];
}

// muldw<.f> 0,b,c 00101bbb00001100FBBBCCCCCC111110.
def ARC_MULDW_z_b_c : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "muldw\t$rb, $rc", []> {
  // Opcode: 0x280C003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// muldw<.f><.cc> b,b,c 00101bbb11001100FBBBCCCCCC0QQQQQ.
def ARC_MULDW_b_c_cc : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "muldw\t$rb_chk, $rc", []> {
  // Opcode: 0x28CC0000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001100;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// muldw<.f> a,b,u6 00101bbb01001100FBBBuuuuuuAAAAAA.
def ARC_MULDW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "muldw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x284C0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001100;
  let Defs = [STATUS32];
}

// muldw<.f> 0,b,u6 00101bbb01001100FBBBuuuuuu111110.
def ARC_MULDW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "muldw\t$rb, $uimm6_20", []> {
  // Opcode: 0x284C003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001100;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// muldw<.f><.cc> b,b,u6 00101bbb11001100FBBBuuuuuu1QQQQQ.
def ARC_MULDW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "muldw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28CC0020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001100;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// muldw<.f> b,b,s12 00101bbb10001100FBBBssssssSSSSSS.
def ARC_MULDW_b_s12 : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "muldw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x288C0000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10001100;
  let Defs = [STATUS32];
  
}

// muldw<.f> a,limm,c 0010111000001100F111CCCCCCAAAAAA.
def ARC_MULDW_a_limm_c : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "muldw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E0C7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// muldw<.f> a,b,limm 00101bbb00001100FBBB111110AAAAAA.
def ARC_MULDW_a_b_limm : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "muldw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x280C0F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001100;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// muldw<.f> 0,limm,c 0010111000001100F111CCCCCC111110.
def ARC_MULDW_z_limm_c : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "muldw\t$limm, $rc", []> {
  // Opcode: 0x2E0C703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// muldw<.f> 0,b,limm 00101bbb00001100FBBB111110111110.
def ARC_MULDW_z_b_limm : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "muldw\t$rb, $limm", []> {
  // Opcode: 0x280C0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001100;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// muldw<.f><.cc> 0,limm,c 0010111011001100F111CCCCCC0QQQQQ.
def ARC_MULDW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "muldw\t$limm, $rc", []> {
  // Opcode: 0x2ECC7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// muldw<.f><.cc> b,b,limm 00101bbb11001100FBBB1111100QQQQQ.
def ARC_MULDW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "muldw\t$rb_chk, $limm", []> {
  // Opcode: 0x28CC0F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001100;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// muldw<.f> a,limm,u6 0010111001001100F111uuuuuuAAAAAA.
def ARC_MULDW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "muldw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E4C7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// muldw<.f> 0,limm,u6 0010111001001100F111uuuuuu111110.
def ARC_MULDW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "muldw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E4C703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001100;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// muldw<.f><.cc> 0,limm,u6 0010111011001100F111uuuuuu1QQQQQ.
def ARC_MULDW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "muldw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2ECC7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001100;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// muldw<.f> 0,limm,s12 0010111010001100F111ssssssSSSSSS.
def ARC_MULDW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "muldw\t$limm, $simm12_20", []> {
  // Opcode: 0x2E8C7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010001100;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// muldw<.f> a,limm,limm 0010111000001100F111111110AAAAAA.
def ARC_MULDW_a_limm : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "muldw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E0C7F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001100;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// muldw<.f> 0,limm,limm 0010111000001100F111111110111110.
def ARC_MULDW_z_limm : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs ), (ins i32imm:$limm),
    "muldw\t$limm", []> {
  // Opcode: 0x2E0C7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001100;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// muldw<.f><.cc> 0,limm,limm 0010111011001100F1111111100QQQQQ.
def ARC_MULDW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b001100, "muldw",
    (outs ), (ins i32imm:$limm),
    "muldw\t$limm", []> {
  // Opcode: 0x2ECC7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001100;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulflw<.f> a,b,c 00101bbb00110010FBBBCCCCCCAAAAAA.
def ARC_MULFLW_a_b_c : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "mulflw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28320000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110010;
  let Defs = [STATUS32];
}

// mulflw<.f> 0,b,c 00101bbb00110010FBBBCCCCCC111110.
def ARC_MULFLW_z_b_c : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "mulflw\t$rb, $rc", []> {
  // Opcode: 0x2832003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulflw<.f><.cc> b,b,c 00101bbb11110010FBBBCCCCCC0QQQQQ.
def ARC_MULFLW_b_c_cc : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "mulflw\t$rb_chk, $rc", []> {
  // Opcode: 0x28F20000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110010;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulflw<.f> a,b,u6 00101bbb01110010FBBBuuuuuuAAAAAA.
def ARC_MULFLW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mulflw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28720000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110010;
  let Defs = [STATUS32];
}

// mulflw<.f> 0,b,u6 00101bbb01110010FBBBuuuuuu111110.
def ARC_MULFLW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mulflw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2872003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110010;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulflw<.f><.cc> b,b,u6 00101bbb11110010FBBBuuuuuu1QQQQQ.
def ARC_MULFLW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "mulflw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28F20020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110010;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulflw<.f> b,b,s12 00101bbb10110010FBBBssssssSSSSSS.
def ARC_MULFLW_b_s12 : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "mulflw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28B20000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10110010;
  let Defs = [STATUS32];
  
}

// mulflw<.f> a,limm,c 0010111000110010F111CCCCCCAAAAAA.
def ARC_MULFLW_a_limm_c : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "mulflw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E327000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulflw<.f> a,b,limm 00101bbb00110010FBBB111110AAAAAA.
def ARC_MULFLW_a_b_limm : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "mulflw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28320F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110010;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// mulflw<.f> 0,limm,c 0010111000110010F111CCCCCC111110.
def ARC_MULFLW_z_limm_c : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mulflw\t$limm, $rc", []> {
  // Opcode: 0x2E32703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulflw<.f> 0,b,limm 00101bbb00110010FBBB111110111110.
def ARC_MULFLW_z_b_limm : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "mulflw\t$rb, $limm", []> {
  // Opcode: 0x28320FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110010;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// mulflw<.f><.cc> 0,limm,c 0010111011110010F111CCCCCC0QQQQQ.
def ARC_MULFLW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mulflw\t$limm, $rc", []> {
  // Opcode: 0x2EF27000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulflw<.f><.cc> b,b,limm 00101bbb11110010FBBB1111100QQQQQ.
def ARC_MULFLW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "mulflw\t$rb_chk, $limm", []> {
  // Opcode: 0x28F20F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110010;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulflw<.f> a,limm,u6 0010111001110010F111uuuuuuAAAAAA.
def ARC_MULFLW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulflw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E727000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulflw<.f> 0,limm,u6 0010111001110010F111uuuuuu111110.
def ARC_MULFLW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulflw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E72703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110010;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulflw<.f><.cc> 0,limm,u6 0010111011110010F111uuuuuu1QQQQQ.
def ARC_MULFLW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulflw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EF27020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110010;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulflw<.f> 0,limm,s12 0010111010110010F111ssssssSSSSSS.
def ARC_MULFLW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "mulflw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EB27000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010110010;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulflw<.f> a,limm,limm 0010111000110010F111111110AAAAAA.
def ARC_MULFLW_a_limm : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "mulflw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E327F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110010;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// mulflw<.f> 0,limm,limm 0010111000110010F111111110111110.
def ARC_MULFLW_z_limm : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs ), (ins i32imm:$limm),
    "mulflw\t$limm", []> {
  // Opcode: 0x2E327FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110010;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// mulflw<.f><.cc> 0,limm,limm 0010111011110010F1111111100QQQQQ.
def ARC_MULFLW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b110010, "mulflw",
    (outs ), (ins i32imm:$limm),
    "mulflw\t$limm", []> {
  // Opcode: 0x2EF27F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110010;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulhflw<.f> a,b,c 00101bbb00111001FBBBCCCCCCAAAAAA.
def ARC_MULHFLW_a_b_c : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "mulhflw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28390000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00111001;
  let Defs = [STATUS32];
}

// mulhflw<.f> 0,b,c 00101bbb00111001FBBBCCCCCC111110.
def ARC_MULHFLW_z_b_c : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "mulhflw\t$rb, $rc", []> {
  // Opcode: 0x2839003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00111001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulhflw<.f><.cc> b,b,c 00101bbb11111001FBBBCCCCCC0QQQQQ.
def ARC_MULHFLW_b_c_cc : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "mulhflw\t$rb_chk, $rc", []> {
  // Opcode: 0x28F90000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11111001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulhflw<.f> a,b,u6 00101bbb01111001FBBBuuuuuuAAAAAA.
def ARC_MULHFLW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mulhflw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28790000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01111001;
  let Defs = [STATUS32];
}

// mulhflw<.f> 0,b,u6 00101bbb01111001FBBBuuuuuu111110.
def ARC_MULHFLW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mulhflw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2879003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01111001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulhflw<.f><.cc> b,b,u6 00101bbb11111001FBBBuuuuuu1QQQQQ.
def ARC_MULHFLW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "mulhflw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28F90020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11111001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulhflw<.f> b,b,s12 00101bbb10111001FBBBssssssSSSSSS.
def ARC_MULHFLW_b_s12 : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "mulhflw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28B90000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10111001;
  let Defs = [STATUS32];
  
}

// mulhflw<.f> a,limm,c 0010111000111001F111CCCCCCAAAAAA.
def ARC_MULHFLW_a_limm_c : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "mulhflw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E397000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000111001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulhflw<.f> a,b,limm 00101bbb00111001FBBB111110AAAAAA.
def ARC_MULHFLW_a_b_limm : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "mulhflw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28390F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00111001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// mulhflw<.f> 0,limm,c 0010111000111001F111CCCCCC111110.
def ARC_MULHFLW_z_limm_c : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mulhflw\t$limm, $rc", []> {
  // Opcode: 0x2E39703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000111001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulhflw<.f> 0,b,limm 00101bbb00111001FBBB111110111110.
def ARC_MULHFLW_z_b_limm : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "mulhflw\t$rb, $limm", []> {
  // Opcode: 0x28390FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00111001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// mulhflw<.f><.cc> 0,limm,c 0010111011111001F111CCCCCC0QQQQQ.
def ARC_MULHFLW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mulhflw\t$limm, $rc", []> {
  // Opcode: 0x2EF97000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011111001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulhflw<.f><.cc> b,b,limm 00101bbb11111001FBBB1111100QQQQQ.
def ARC_MULHFLW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "mulhflw\t$rb_chk, $limm", []> {
  // Opcode: 0x28F90F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11111001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulhflw<.f> a,limm,u6 0010111001111001F111uuuuuuAAAAAA.
def ARC_MULHFLW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulhflw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E797000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001111001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulhflw<.f> 0,limm,u6 0010111001111001F111uuuuuu111110.
def ARC_MULHFLW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulhflw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E79703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001111001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulhflw<.f><.cc> 0,limm,u6 0010111011111001F111uuuuuu1QQQQQ.
def ARC_MULHFLW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulhflw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EF97020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011111001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulhflw<.f> 0,limm,s12 0010111010111001F111ssssssSSSSSS.
def ARC_MULHFLW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "mulhflw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EB97000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010111001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulhflw<.f> a,limm,limm 0010111000111001F111111110AAAAAA.
def ARC_MULHFLW_a_limm : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "mulhflw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E397F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000111001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// mulhflw<.f> 0,limm,limm 0010111000111001F111111110111110.
def ARC_MULHFLW_z_limm : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs ), (ins i32imm:$limm),
    "mulhflw\t$limm", []> {
  // Opcode: 0x2E397FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000111001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// mulhflw<.f><.cc> 0,limm,limm 0010111011111001F1111111100QQQQQ.
def ARC_MULHFLW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b111001, "mulhflw",
    (outs ), (ins i32imm:$limm),
    "mulhflw\t$limm", []> {
  // Opcode: 0x2EF97F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011111001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulhlw<.f> a,b,c 00101bbb00111000FBBBCCCCCCAAAAAA.
def ARC_MULHLW_a_b_c : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "mulhlw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28380000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00111000;
  let Defs = [STATUS32];
}

// mulhlw<.f> 0,b,c 00101bbb00111000FBBBCCCCCC111110.
def ARC_MULHLW_z_b_c : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "mulhlw\t$rb, $rc", []> {
  // Opcode: 0x2838003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00111000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulhlw<.f><.cc> b,b,c 00101bbb11111000FBBBCCCCCC0QQQQQ.
def ARC_MULHLW_b_c_cc : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "mulhlw\t$rb_chk, $rc", []> {
  // Opcode: 0x28F80000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11111000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulhlw<.f> a,b,u6 00101bbb01111000FBBBuuuuuuAAAAAA.
def ARC_MULHLW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mulhlw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28780000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01111000;
  let Defs = [STATUS32];
}

// mulhlw<.f> 0,b,u6 00101bbb01111000FBBBuuuuuu111110.
def ARC_MULHLW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mulhlw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2878003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01111000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulhlw<.f><.cc> b,b,u6 00101bbb11111000FBBBuuuuuu1QQQQQ.
def ARC_MULHLW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "mulhlw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28F80020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11111000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulhlw<.f> b,b,s12 00101bbb10111000FBBBssssssSSSSSS.
def ARC_MULHLW_b_s12 : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "mulhlw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28B80000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10111000;
  let Defs = [STATUS32];
  
}

// mulhlw<.f> a,limm,c 0010111000111000F111CCCCCCAAAAAA.
def ARC_MULHLW_a_limm_c : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "mulhlw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E387000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000111000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulhlw<.f> a,b,limm 00101bbb00111000FBBB111110AAAAAA.
def ARC_MULHLW_a_b_limm : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "mulhlw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28380F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00111000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// mulhlw<.f> 0,limm,c 0010111000111000F111CCCCCC111110.
def ARC_MULHLW_z_limm_c : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mulhlw\t$limm, $rc", []> {
  // Opcode: 0x2E38703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000111000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulhlw<.f> 0,b,limm 00101bbb00111000FBBB111110111110.
def ARC_MULHLW_z_b_limm : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "mulhlw\t$rb, $limm", []> {
  // Opcode: 0x28380FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00111000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// mulhlw<.f><.cc> 0,limm,c 0010111011111000F111CCCCCC0QQQQQ.
def ARC_MULHLW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mulhlw\t$limm, $rc", []> {
  // Opcode: 0x2EF87000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011111000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulhlw<.f><.cc> b,b,limm 00101bbb11111000FBBB1111100QQQQQ.
def ARC_MULHLW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "mulhlw\t$rb_chk, $limm", []> {
  // Opcode: 0x28F80F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11111000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulhlw<.f> a,limm,u6 0010111001111000F111uuuuuuAAAAAA.
def ARC_MULHLW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulhlw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E787000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001111000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulhlw<.f> 0,limm,u6 0010111001111000F111uuuuuu111110.
def ARC_MULHLW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulhlw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E78703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001111000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulhlw<.f><.cc> 0,limm,u6 0010111011111000F111uuuuuu1QQQQQ.
def ARC_MULHLW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulhlw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EF87020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011111000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulhlw<.f> 0,limm,s12 0010111010111000F111ssssssSSSSSS.
def ARC_MULHLW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "mulhlw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EB87000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010111000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulhlw<.f> a,limm,limm 0010111000111000F111111110AAAAAA.
def ARC_MULHLW_a_limm : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "mulhlw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E387F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000111000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// mulhlw<.f> 0,limm,limm 0010111000111000F111111110111110.
def ARC_MULHLW_z_limm : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs ), (ins i32imm:$limm),
    "mulhlw\t$limm", []> {
  // Opcode: 0x2E387FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000111000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// mulhlw<.f><.cc> 0,limm,limm 0010111011111000F1111111100QQQQQ.
def ARC_MULHLW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b111000, "mulhlw",
    (outs ), (ins i32imm:$limm),
    "mulhlw\t$limm", []> {
  // Opcode: 0x2EF87F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011111000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mullw<.f> a,b,c 00101bbb00110001FBBBCCCCCCAAAAAA.
def ARC_MULLW_a_b_c : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "mullw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28310000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110001;
  let Defs = [STATUS32];
}

// mullw<.f> 0,b,c 00101bbb00110001FBBBCCCCCC111110.
def ARC_MULLW_z_b_c : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "mullw\t$rb, $rc", []> {
  // Opcode: 0x2831003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mullw<.f><.cc> b,b,c 00101bbb11110001FBBBCCCCCC0QQQQQ.
def ARC_MULLW_b_c_cc : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "mullw\t$rb_chk, $rc", []> {
  // Opcode: 0x28F10000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110001;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mullw<.f> a,b,u6 00101bbb01110001FBBBuuuuuuAAAAAA.
def ARC_MULLW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mullw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28710000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110001;
  let Defs = [STATUS32];
}

// mullw<.f> 0,b,u6 00101bbb01110001FBBBuuuuuu111110.
def ARC_MULLW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mullw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2871003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110001;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mullw<.f><.cc> b,b,u6 00101bbb11110001FBBBuuuuuu1QQQQQ.
def ARC_MULLW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "mullw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28F10020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110001;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mullw<.f> b,b,s12 00101bbb10110001FBBBssssssSSSSSS.
def ARC_MULLW_b_s12 : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "mullw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28B10000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10110001;
  let Defs = [STATUS32];
  
}

// mullw<.f> a,limm,c 0010111000110001F111CCCCCCAAAAAA.
def ARC_MULLW_a_limm_c : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "mullw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E317000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mullw<.f> a,b,limm 00101bbb00110001FBBB111110AAAAAA.
def ARC_MULLW_a_b_limm : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "mullw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28310F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110001;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// mullw<.f> 0,limm,c 0010111000110001F111CCCCCC111110.
def ARC_MULLW_z_limm_c : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mullw\t$limm, $rc", []> {
  // Opcode: 0x2E31703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mullw<.f> 0,b,limm 00101bbb00110001FBBB111110111110.
def ARC_MULLW_z_b_limm : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "mullw\t$rb, $limm", []> {
  // Opcode: 0x28310FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110001;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// mullw<.f><.cc> 0,limm,c 0010111011110001F111CCCCCC0QQQQQ.
def ARC_MULLW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mullw\t$limm, $rc", []> {
  // Opcode: 0x2EF17000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mullw<.f><.cc> b,b,limm 00101bbb11110001FBBB1111100QQQQQ.
def ARC_MULLW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "mullw\t$rb_chk, $limm", []> {
  // Opcode: 0x28F10F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110001;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mullw<.f> a,limm,u6 0010111001110001F111uuuuuuAAAAAA.
def ARC_MULLW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mullw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E717000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mullw<.f> 0,limm,u6 0010111001110001F111uuuuuu111110.
def ARC_MULLW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mullw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E71703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110001;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mullw<.f><.cc> 0,limm,u6 0010111011110001F111uuuuuu1QQQQQ.
def ARC_MULLW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mullw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EF17020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110001;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mullw<.f> 0,limm,s12 0010111010110001F111ssssssSSSSSS.
def ARC_MULLW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "mullw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EB17000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010110001;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mullw<.f> a,limm,limm 0010111000110001F111111110AAAAAA.
def ARC_MULLW_a_limm : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "mullw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E317F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110001;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// mullw<.f> 0,limm,limm 0010111000110001F111111110111110.
def ARC_MULLW_z_limm : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs ), (ins i32imm:$limm),
    "mullw\t$limm", []> {
  // Opcode: 0x2E317FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110001;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// mullw<.f><.cc> 0,limm,limm 0010111011110001F1111111100QQQQQ.
def ARC_MULLW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b110001, "mullw",
    (outs ), (ins i32imm:$limm),
    "mullw\t$limm", []> {
  // Opcode: 0x2EF17F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110001;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulrdw<.f> a,b,c 00101bbb00001110FBBBCCCCCCAAAAAA.
def ARC_MULRDW_a_b_c : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "mulrdw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x280E0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001110;
  let Defs = [STATUS32];
}

// mulrdw<.f> 0,b,c 00101bbb00001110FBBBCCCCCC111110.
def ARC_MULRDW_z_b_c : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "mulrdw\t$rb, $rc", []> {
  // Opcode: 0x280E003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulrdw<.f><.cc> b,b,c 00101bbb11001110FBBBCCCCCC0QQQQQ.
def ARC_MULRDW_b_c_cc : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "mulrdw\t$rb_chk, $rc", []> {
  // Opcode: 0x28CE0000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001110;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulrdw<.f> a,b,u6 00101bbb01001110FBBBuuuuuuAAAAAA.
def ARC_MULRDW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mulrdw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x284E0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001110;
  let Defs = [STATUS32];
}

// mulrdw<.f> 0,b,u6 00101bbb01001110FBBBuuuuuu111110.
def ARC_MULRDW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mulrdw\t$rb, $uimm6_20", []> {
  // Opcode: 0x284E003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001110;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulrdw<.f><.cc> b,b,u6 00101bbb11001110FBBBuuuuuu1QQQQQ.
def ARC_MULRDW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "mulrdw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28CE0020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001110;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulrdw<.f> b,b,s12 00101bbb10001110FBBBssssssSSSSSS.
def ARC_MULRDW_b_s12 : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "mulrdw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x288E0000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10001110;
  let Defs = [STATUS32];
  
}

// mulrdw<.f> a,limm,c 0010111000001110F111CCCCCCAAAAAA.
def ARC_MULRDW_a_limm_c : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "mulrdw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E0E7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulrdw<.f> a,b,limm 00101bbb00001110FBBB111110AAAAAA.
def ARC_MULRDW_a_b_limm : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "mulrdw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x280E0F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001110;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// mulrdw<.f> 0,limm,c 0010111000001110F111CCCCCC111110.
def ARC_MULRDW_z_limm_c : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mulrdw\t$limm, $rc", []> {
  // Opcode: 0x2E0E703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulrdw<.f> 0,b,limm 00101bbb00001110FBBB111110111110.
def ARC_MULRDW_z_b_limm : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "mulrdw\t$rb, $limm", []> {
  // Opcode: 0x280E0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001110;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// mulrdw<.f><.cc> 0,limm,c 0010111011001110F111CCCCCC0QQQQQ.
def ARC_MULRDW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mulrdw\t$limm, $rc", []> {
  // Opcode: 0x2ECE7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulrdw<.f><.cc> b,b,limm 00101bbb11001110FBBB1111100QQQQQ.
def ARC_MULRDW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "mulrdw\t$rb_chk, $limm", []> {
  // Opcode: 0x28CE0F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001110;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mulrdw<.f> a,limm,u6 0010111001001110F111uuuuuuAAAAAA.
def ARC_MULRDW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulrdw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E4E7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulrdw<.f> 0,limm,u6 0010111001001110F111uuuuuu111110.
def ARC_MULRDW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulrdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E4E703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mulrdw<.f><.cc> 0,limm,u6 0010111011001110F111uuuuuu1QQQQQ.
def ARC_MULRDW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mulrdw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2ECE7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001110;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mulrdw<.f> 0,limm,s12 0010111010001110F111ssssssSSSSSS.
def ARC_MULRDW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "mulrdw\t$limm, $simm12_20", []> {
  // Opcode: 0x2E8E7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010001110;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mulrdw<.f> a,limm,limm 0010111000001110F111111110AAAAAA.
def ARC_MULRDW_a_limm : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "mulrdw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E0E7F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001110;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// mulrdw<.f> 0,limm,limm 0010111000001110F111111110111110.
def ARC_MULRDW_z_limm : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs ), (ins i32imm:$limm),
    "mulrdw\t$limm", []> {
  // Opcode: 0x2E0E7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001110;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// mulrdw<.f><.cc> 0,limm,limm 0010111011001110F1111111100QQQQQ.
def ARC_MULRDW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b001110, "mulrdw",
    (outs ), (ins i32imm:$limm),
    "mulrdw\t$limm", []> {
  // Opcode: 0x2ECE7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001110;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// muludw<.f> a,b,c 00101bbb00001101FBBBCCCCCCAAAAAA.
def ARC_MULUDW_a_b_c : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "muludw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x280D0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001101;
  let Defs = [STATUS32];
}

// muludw<.f> 0,b,c 00101bbb00001101FBBBCCCCCC111110.
def ARC_MULUDW_z_b_c : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "muludw\t$rb, $rc", []> {
  // Opcode: 0x280D003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// muludw<.f><.cc> b,b,c 00101bbb11001101FBBBCCCCCC0QQQQQ.
def ARC_MULUDW_b_c_cc : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "muludw\t$rb_chk, $rc", []> {
  // Opcode: 0x28CD0000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001101;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// muludw<.f> a,b,u6 00101bbb01001101FBBBuuuuuuAAAAAA.
def ARC_MULUDW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "muludw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x284D0000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001101;
  let Defs = [STATUS32];
}

// muludw<.f> 0,b,u6 00101bbb01001101FBBBuuuuuu111110.
def ARC_MULUDW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "muludw\t$rb, $uimm6_20", []> {
  // Opcode: 0x284D003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01001101;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// muludw<.f><.cc> b,b,u6 00101bbb11001101FBBBuuuuuu1QQQQQ.
def ARC_MULUDW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "muludw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28CD0020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001101;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// muludw<.f> b,b,s12 00101bbb10001101FBBBssssssSSSSSS.
def ARC_MULUDW_b_s12 : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "muludw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x288D0000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10001101;
  let Defs = [STATUS32];
  
}

// muludw<.f> a,limm,c 0010111000001101F111CCCCCCAAAAAA.
def ARC_MULUDW_a_limm_c : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "muludw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E0D7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// muludw<.f> a,b,limm 00101bbb00001101FBBB111110AAAAAA.
def ARC_MULUDW_a_b_limm : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "muludw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x280D0F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001101;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// muludw<.f> 0,limm,c 0010111000001101F111CCCCCC111110.
def ARC_MULUDW_z_limm_c : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "muludw\t$limm, $rc", []> {
  // Opcode: 0x2E0D703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// muludw<.f> 0,b,limm 00101bbb00001101FBBB111110111110.
def ARC_MULUDW_z_b_limm : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "muludw\t$rb, $limm", []> {
  // Opcode: 0x280D0FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00001101;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// muludw<.f><.cc> 0,limm,c 0010111011001101F111CCCCCC0QQQQQ.
def ARC_MULUDW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "muludw\t$limm, $rc", []> {
  // Opcode: 0x2ECD7000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// muludw<.f><.cc> b,b,limm 00101bbb11001101FBBB1111100QQQQQ.
def ARC_MULUDW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "muludw\t$rb_chk, $limm", []> {
  // Opcode: 0x28CD0F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11001101;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// muludw<.f> a,limm,u6 0010111001001101F111uuuuuuAAAAAA.
def ARC_MULUDW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "muludw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E4D7000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// muludw<.f> 0,limm,u6 0010111001001101F111uuuuuu111110.
def ARC_MULUDW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "muludw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E4D703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001001101;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// muludw<.f><.cc> 0,limm,u6 0010111011001101F111uuuuuu1QQQQQ.
def ARC_MULUDW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "muludw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2ECD7020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001101;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// muludw<.f> 0,limm,s12 0010111010001101F111ssssssSSSSSS.
def ARC_MULUDW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "muludw\t$limm, $simm12_20", []> {
  // Opcode: 0x2E8D7000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010001101;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// muludw<.f> a,limm,limm 0010111000001101F111111110AAAAAA.
def ARC_MULUDW_a_limm : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "muludw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E0D7F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001101;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// muludw<.f> 0,limm,limm 0010111000001101F111111110111110.
def ARC_MULUDW_z_limm : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs ), (ins i32imm:$limm),
    "muludw\t$limm", []> {
  // Opcode: 0x2E0D7FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000001101;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// muludw<.f><.cc> 0,limm,limm 0010111011001101F1111111100QQQQQ.
def ARC_MULUDW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b001101, "muludw",
    (outs ), (ins i32imm:$limm),
    "muludw\t$limm", []> {
  // Opcode: 0x2ECD7F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011001101;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mululw<.f> a,b,c 00101bbb00110000FBBBCCCCCCAAAAAA.
def ARC_MULULW_a_b_c : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "mululw\t$ra_chk, $rb, $rc", []> {
  // Opcode: 0x28300000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110000;
  let Defs = [STATUS32];
}

// mululw<.f> 0,b,c 00101bbb00110000FBBBCCCCCC111110.
def ARC_MULULW_z_b_c : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "mululw\t$rb, $rc", []> {
  // Opcode: 0x2830003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, RC
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mululw<.f><.cc> b,b,c 00101bbb11110000FBBBCCCCCC0QQQQQ.
def ARC_MULULW_b_c_cc : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs GPR32:$rb_chk), (ins GPR32:$rc),
    "mululw\t$rb_chk, $rc", []> {
  // Opcode: 0x28F00000, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, RC
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110000;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mululw<.f> a,b,u6 00101bbb01110000FBBBuuuuuuAAAAAA.
def ARC_MULULW_a_b_u6 : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mululw\t$ra_chk, $rb, $uimm6_20", []> {
  // Opcode: 0x28700000, Mask: 0xF8FF0000
  // Operands: RA_CHK, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110000;
  let Defs = [STATUS32];
}

// mululw<.f> 0,b,u6 00101bbb01110000FBBBuuuuuu111110.
def ARC_MULULW_z_b_u6 : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs ), (ins GPR32:$rb, u6imm:$uimm6_20),
    "mululw\t$rb, $uimm6_20", []> {
  // Opcode: 0x2870003E, Mask: 0xF8FF003F
  // Operands: ZA, RB, UIMM6_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b01110000;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mululw<.f><.cc> b,b,u6 00101bbb11110000FBBBuuuuuu1QQQQQ.
def ARC_MULULW_b_u6_cc : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs GPR32:$rb_chk), (ins u6imm:$uimm6_20),
    "mululw\t$rb_chk, $uimm6_20", []> {
  // Opcode: 0x28F00020, Mask: 0xF8FF0020
  // Operands: RB_CHK, RBdup, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110000;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mululw<.f> b,b,s12 00101bbb10110000FBBBssssssSSSSSS.
def ARC_MULULW_b_s12 : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs GPR32:$rb_chk), (ins s12imm:$simm12_20),
    "mululw\t$rb_chk, $simm12_20", []> {
  // Opcode: 0x28B00000, Mask: 0xF8FF0000
  // Operands: RB_CHK, RBdup, SIMM12_20
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b10110000;
  let Defs = [STATUS32];
  
}

// mululw<.f> a,limm,c 0010111000110000F111CCCCCCAAAAAA.
def ARC_MULULW_a_limm_c : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "mululw\t$ra_chk, $limm, $rc", []> {
  // Opcode: 0x2E307000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mululw<.f> a,b,limm 00101bbb00110000FBBB111110AAAAAA.
def ARC_MULULW_a_b_limm : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "mululw\t$ra_chk, $rb, $limm", []> {
  // Opcode: 0x28300F80, Mask: 0xF8FF0FC0
  // Operands: RA_CHK, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110000;
  let Inst{11-6} = 0b111110;
  let Defs = [STATUS32];
}

// mululw<.f> 0,limm,c 0010111000110000F111CCCCCC111110.
def ARC_MULULW_z_limm_c : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mululw\t$limm, $rc", []> {
  // Opcode: 0x2E30703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, RC
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mululw<.f> 0,b,limm 00101bbb00110000FBBB111110111110.
def ARC_MULULW_z_b_limm : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "mululw\t$rb, $limm", []> {
  // Opcode: 0x28300FBE, Mask: 0xF8FF0FFF
  // Operands: ZA, RB, LIMM
  // Flags: C_F
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b00110000;
  let Inst{11-0} = 0b111110111110;
  let Defs = [STATUS32];
}

// mululw<.f><.cc> 0,limm,c 0010111011110000F111CCCCCC0QQQQQ.
def ARC_MULULW_z_limm_c_cc : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "mululw\t$limm, $rc", []> {
  // Opcode: 0x2EF07000, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, RC
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 0;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mululw<.f><.cc> b,b,limm 00101bbb11110000FBBB1111100QQQQQ.
def ARC_MULULW_b_limm_cc : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs GPR32:$rb_chk), (ins i32imm:$limm),
    "mululw\t$rb_chk, $limm", []> {
  // Opcode: 0x28F00F80, Mask: 0xF8FF0FE0
  // Operands: RB_CHK, RBdup, LIMM
  // Flags: C_F, C_CC
  let Inst{31-27} = 0b00101;
  let Inst{23-16} = 0b11110000;
  let Inst{11-5} = 0b1111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
  
}

// mululw<.f> a,limm,u6 0010111001110000F111uuuuuuAAAAAA.
def ARC_MULULW_a_limm_u6 : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mululw\t$ra_chk, $limm, $uimm6_20", []> {
  // Opcode: 0x2E707000, Mask: 0xFFFF7000
  // Operands: RA_CHK, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mululw<.f> 0,limm,u6 0010111001110000F111uuuuuu111110.
def ARC_MULULW_z_limm_u6 : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mululw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2E70703E, Mask: 0xFFFF703F
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111001110000;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  let Defs = [STATUS32];
}

// mululw<.f><.cc> 0,limm,u6 0010111011110000F111uuuuuu1QQQQQ.
def ARC_MULULW_z_limm_u6_cc : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "mululw\t$limm, $uimm6_20", []> {
  // Opcode: 0x2EF07020, Mask: 0xFFFF7020
  // Operands: ZA, LIMM, UIMM6_20
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110000;
  let Inst{14-12} = 0b111;
  let Inst{5} = 1;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

// mululw<.f> 0,limm,s12 0010111010110000F111ssssssSSSSSS.
def ARC_MULULW_z_limm_s12 : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs ), (ins i32imm:$limm, s12imm:$simm12_20),
    "mululw\t$limm, $simm12_20", []> {
  // Opcode: 0x2EB07000, Mask: 0xFFFF7000
  // Operands: ZA, LIMM, SIMM12_20
  // Flags: C_F
  let Inst{31-16} = 0b0010111010110000;
  let Inst{14-12} = 0b111;
  let Defs = [STATUS32];
}

// mululw<.f> a,limm,limm 0010111000110000F111111110AAAAAA.
def ARC_MULULW_a_limm : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "mululw\t$ra_chk, $limm", []> {
  // Opcode: 0x2E307F80, Mask: 0xFFFF7FC0
  // Operands: RA_CHK, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110000;
  let Inst{14-6} = 0b111111110;
  let Defs = [STATUS32];
}

// mululw<.f> 0,limm,limm 0010111000110000F111111110111110.
def ARC_MULULW_z_limm : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs ), (ins i32imm:$limm),
    "mululw\t$limm", []> {
  // Opcode: 0x2E307FBE, Mask: 0xFFFF7FFF
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F
  let Inst{31-16} = 0b0010111000110000;
  let Inst{14-0} = 0b111111110111110;
  let Defs = [STATUS32];
}

// mululw<.f><.cc> 0,limm,limm 0010111011110000F1111111100QQQQQ.
def ARC_MULULW_z_limm_cc : ARCompactInst32_3op<0b00101, 0b110000, "mululw",
    (outs ), (ins i32imm:$limm),
    "mululw\t$limm", []> {
  // Opcode: 0x2EF07F80, Mask: 0xFFFF7FE0
  // Operands: ZA, LIMM, LIMMdup
  // Flags: C_F, C_CC
  let Inst{31-16} = 0b0010111011110000;
  let Inst{14-5} = 0b1111111100;
  let isPredicable = 1;
  let Defs = [STATUS32];
}

} // end let Predicates = [IsARCompact]
