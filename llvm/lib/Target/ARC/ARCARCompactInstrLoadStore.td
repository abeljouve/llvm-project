//===-- ARCARCompactInstrLoadStore.td - ARC ARCompact Load/Store Instructions -*- tablegen -*-===//
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

// 35 instruction variants

let Predicates = [IsARCompact] in {

// ld<.di><.aa><.x><zz> a,b 00010bbb000000000BBBDaaZZXAAAAAA.
def ARC_LD_a_b : ARCompactInstLoad<0b00010, "ld",
    (outs GPR32:$ra_chk), (ins GPR32:$rb),
    "ld\t$ra_chk, [$rb]", []> {
  // Opcode: 0x10000000, Mask: 0xF8FF8000
  // Operands: RA_CHK, BRAKET, RB, BRAKETdup
  // Flags: C_ZZ23, C_DI20, C_AA21, C_X25
  let Inst{31-27} = 0b00010;
  let Inst{23-15} = 0b000000000;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
  bits<8> ra_chk;
  let Inst{10-9} = ra_chk{7-6};
  let Inst{5-0} = ra_chk{5-0};
}

// ld<.di><.aa><.x><zz> a,b,c 00100bbbaa110ZZXDBBBCCCCCCAAAAAA.
def ARC_LD_a_b_c : ARCompactInstLoad<0b00100, "ld",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, GPR32:$rc),
    "ld\t$ra_chk, [$rb, $rc]", []> {
  // Opcode: 0x20300000, Mask: 0xF8380000
  // Operands: RA_CHK, BRAKET, RB, RC, BRAKETdup
  // Flags: C_ZZ13, C_DI16, C_AA8, C_X15
  let Inst{31-27} = 0b00100;
  let Inst{21-19} = 0b110;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
  bits<8> ra_chk;
  let Inst{23-22} = ra_chk{7-6};
  let Inst{5-0} = ra_chk{5-0};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// ld<.di><.aa><.x><zz> 0,b 00010bbb000000000BBBDaaZZX111110.
def ARC_LD_z_b : ARCompactInstLoad<0b00010, "ld",
    (outs ), (ins GPR32:$rb),
    "ld\t[$rb]", []> {
  // Opcode: 0x1000003E, Mask: 0xF8FF803F
  // Operands: ZA, BRAKET, RB, BRAKETdup
  // Flags: C_ZZ23, C_DI20, C_AA21, C_X25
  let Inst{31-27} = 0b00010;
  let Inst{23-15} = 0b000000000;
  let Inst{5-0} = 0b111110;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
}

// ld<.di><.aa><.x><zz> 0,b,c 00100bbbaa110ZZXDBBBCCCCCC111110.
def ARC_LD_z_b_c : ARCompactInstLoad<0b00100, "ld",
    (outs ), (ins GPR32:$rb, GPR32:$rc),
    "ld\t[$rb, $rc]", []> {
  // Opcode: 0x2030003E, Mask: 0xF838003F
  // Operands: ZA, BRAKET, RB, RC, BRAKETdup
  // Flags: C_ZZ13, C_DI16, C_AA8, C_X15
  let Inst{31-27} = 0b00100;
  let Inst{21-19} = 0b110;
  let Inst{5-0} = 0b111110;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// ld<.di><.aa><.x><zz> a,b,s9 00010bbbssssssssSBBBDaaZZXAAAAAA.
def ARC_LD_a_b_s9 : ARCompactInstLoad<0b00010, "ld",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, s9imm:$simm9_8),
    "ld\t$ra_chk, [$rb, $simm9_8]", []> {
  // Opcode: 0x10000000, Mask: 0xF8000000
  // Operands: RA_CHK, BRAKET, RB, SIMM9_8, BRAKETdup
  // Flags: C_ZZ23, C_DI20, C_AA21, C_X25
  let Inst{31-27} = 0b00010;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
  bits<9> simm9_8;
  let Inst{23-16} = simm9_8{8-1};
  let Inst{15} = simm9_8{0};
  bits<8> ra_chk;
  let Inst{10-9} = ra_chk{7-6};
  let Inst{5-0} = ra_chk{5-0};
}

// ld<.di><.aa><.x><zz> 0,b,s9 00010bbbssssssssSBBBDaaZZX111110.
def ARC_LD_z_b_s9 : ARCompactInstLoad<0b00010, "ld",
    (outs ), (ins GPR32:$rb, s9imm:$simm9_8),
    "ld\t[$rb, $simm9_8]", []> {
  // Opcode: 0x1000003E, Mask: 0xF800003F
  // Operands: ZA, BRAKET, RB, SIMM9_8, BRAKETdup
  // Flags: C_ZZ23, C_DI20, C_AA21, C_X25
  let Inst{31-27} = 0b00010;
  let Inst{5-0} = 0b111110;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
  bits<9> simm9_8;
  let Inst{23-16} = simm9_8{8-1};
  let Inst{15} = simm9_8{0};
}

// ld<.di><.x><zz> a,limm 00010110000000000111DRRZZXAAAAAA.
def ARC_LD_a_limm : ARCompactInstLoad<0b00010, "ld",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "ld\t$ra_chk, [$limm]", []> {
  // Opcode: 0x16007000, Mask: 0xFFFFF000
  // Operands: RA_CHK, BRAKET, LIMM, BRAKETdup
  // Flags: C_ZZ23, C_DI20, C_X25
  let Inst{31-12} = 0b00010110000000000111;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ld<.di><.aa><.x><zz> a,b,limm 00100bbbaa110ZZXDBBB111110AAAAAA.
def ARC_LD_a_b_limm : ARCompactInstLoad<0b00100, "ld",
    (outs GPR32:$ra_chk), (ins GPR32:$rb, i32imm:$limm),
    "ld\t$ra_chk, [$rb, $limm]", []> {
  // Opcode: 0x20300F80, Mask: 0xF8380FC0
  // Operands: RA_CHK, BRAKET, RB, LIMM, BRAKETdup
  // Flags: C_ZZ13, C_DI16, C_AA8, C_X15
  let Inst{31-27} = 0b00100;
  let Inst{21-19} = 0b110;
  let Inst{11-6} = 0b111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ld<.di><.aa><.x><zz> a,limm,c 00100110aa110ZZXD111CCCCCCAAAAAA.
def ARC_LD_a_limm_c : ARCompactInstLoad<0b00100, "ld",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "ld\t$ra_chk, [$limm, $rc]", []> {
  // Opcode: 0x26307000, Mask: 0xFF387000
  // Operands: RA_CHK, BRAKET, LIMM, RC, BRAKETdup
  // Flags: C_ZZ13, C_DI16, C_AA8, C_X15
  let Inst{31-24} = 0b00100110;
  let Inst{21-19} = 0b110;
  let Inst{14-12} = 0b111;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ld<.di><.x><zz> a,limm,c 00100110RR110ZZXD111CCCCCCAAAAAA.
def ARC_LD_a_limm_c_v1 : ARCompactInstLoad<0b00100, "ld",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, GPR32:$rc),
    "ld\t$ra_chk, [$limm, $rc]", []> {
  // Opcode: 0x26307000, Mask: 0xFF387000
  // Operands: RA_CHK, BRAKET, LIMM, RC, BRAKETdup
  // Flags: C_ZZ13, C_DI16, C_X15
  let Inst{31-24} = 0b00100110;
  let Inst{21-19} = 0b110;
  let Inst{14-12} = 0b111;
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// ld<.di><.x><zz> 0,limm 00010110000000000111DRRZZX111110.
def ARC_LD_z_limm : ARCompactInstLoad<0b00010, "ld",
    (outs ), (ins i32imm:$limm),
    "ld\t[$limm]", []> {
  // Opcode: 0x1600703E, Mask: 0xFFFFF03F
  // Operands: ZA, BRAKET, LIMM, BRAKETdup
  // Flags: C_ZZ23, C_DI20, C_X25
  let Inst{31-12} = 0b00010110000000000111;
  let Inst{5-0} = 0b111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ld<.di><.aa><.x><zz> 0,b,limm 00100bbbaa110ZZXDBBB111110111110.
def ARC_LD_z_b_limm : ARCompactInstLoad<0b00100, "ld",
    (outs ), (ins GPR32:$rb, i32imm:$limm),
    "ld\t[$rb, $limm]", []> {
  // Opcode: 0x20300FBE, Mask: 0xF8380FFF
  // Operands: ZA, BRAKET, RB, LIMM, BRAKETdup
  // Flags: C_ZZ13, C_DI16, C_AA8, C_X15
  let Inst{31-27} = 0b00100;
  let Inst{21-19} = 0b110;
  let Inst{11-0} = 0b111110111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ld<.di><.aa><.x><zz> 0,limm,c 00100110aa110ZZXD111CCCCCC111110.
def ARC_LD_z_limm_c : ARCompactInstLoad<0b00100, "ld",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "ld\t[$limm, $rc]", []> {
  // Opcode: 0x2630703E, Mask: 0xFF38703F
  // Operands: ZA, BRAKET, LIMM, RC, BRAKETdup
  // Flags: C_ZZ13, C_DI16, C_AA8, C_X15
  let Inst{31-24} = 0b00100110;
  let Inst{21-19} = 0b110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ld<.di><.x><zz> 0,limm,c 00100110RR110ZZXD111CCCCCC111110.
def ARC_LD_z_limm_c_v1 : ARCompactInstLoad<0b00100, "ld",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "ld\t[$limm, $rc]", []> {
  // Opcode: 0x2630703E, Mask: 0xFF38703F
  // Operands: ZA, BRAKET, LIMM, RC, BRAKETdup
  // Flags: C_ZZ13, C_DI16, C_X15
  let Inst{31-24} = 0b00100110;
  let Inst{21-19} = 0b110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// ld<.di><.aa><.x><zz> a,limm,s9 00010110ssssssssS111DaaZZXAAAAAA.
def ARC_LD_a_limm_s9 : ARCompactInstLoad<0b00010, "ld",
    (outs GPR32:$ra_chk), (ins i32imm:$limm, s9imm:$simm9_8),
    "ld\t$ra_chk, [$limm, $simm9_8]", []> {
  // Opcode: 0x16007000, Mask: 0xFF007000
  // Operands: RA_CHK, BRAKET, LIMM, SIMM9_8, BRAKETdup
  // Flags: C_ZZ23, C_DI20, C_AA21, C_X25
  let Inst{31-24} = 0b00010110;
  let Inst{14-12} = 0b111;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ld<.di><.aa><.x><zz> 0,limm,s9 00010110ssssssssS111DaaZZX111110.
def ARC_LD_z_limm_s9 : ARCompactInstLoad<0b00010, "ld",
    (outs ), (ins i32imm:$limm, s9imm:$simm9_8),
    "ld\t[$limm, $simm9_8]", []> {
  // Opcode: 0x1600703E, Mask: 0xFF00703F
  // Operands: ZA, BRAKET, LIMM, SIMM9_8, BRAKETdup
  // Flags: C_ZZ23, C_DI20, C_AA21, C_X25
  let Inst{31-24} = 0b00010110;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// ld<.di><.aa><.x><zz> a,limm,limm 00100110aa110ZZXD111111110AAAAAA.
def ARC_LD_a_limm_v1 : ARCompactInstLoad<0b00100, "ld",
    (outs GPR32:$ra_chk), (ins i32imm:$limm),
    "ld\t$ra_chk, [$limm]", []> {
  // Opcode: 0x26307F80, Mask: 0xFF387FC0
  // Operands: RA_CHK, BRAKET, LIMM, LIMMdup, BRAKETdup
  // Flags: C_ZZ13, C_DI16, C_AA8, C_X15
  let Inst{31-24} = 0b00100110;
  let Inst{21-19} = 0b110;
  let Inst{14-6} = 0b111111110;
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// ld<.di><.aa><.x><zz> 0,limm,limm 00100110aa110ZZXD111111110111110.
def ARC_LD_z_limm_v1 : ARCompactInstLoad<0b00100, "ld",
    (outs ), (ins i32imm:$limm),
    "ld\t[$limm]", []> {
  // Opcode: 0x26307FBE, Mask: 0xFF387FFF
  // Operands: ZA, BRAKET, LIMM, LIMMdup, BRAKETdup
  // Flags: C_ZZ13, C_DI16, C_AA8, C_X15
  let Inst{31-24} = 0b00100110;
  let Inst{21-19} = 0b110;
  let Inst{14-0} = 0b111111110111110;
  // Duplicate encoding variant.
  let isCodeGenOnly = 1;
}

// llock<.di> b,c 00100bbb00101111DBBBCCCCCC010000.
def ARC_LLOCK_b_c : ARCompactInst32_2op<0b00100, 0b010000, "llock",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "llock\t$rb, [$rc]", []> {
  // Opcode: 0x202F0010, Mask: 0xF8FF003F
  // Operands: RB, BRAKET, RC, BRAKETdup
  // Flags: C_DI16
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b010000;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// llock<.di> 0,c 0010011000101111D111CCCCCC010000.
def ARC_LLOCK_z_c : ARCompactInst32_2op<0b00100, 0b010000, "llock",
    (outs ), (ins GPR32:$rc),
    "llock\t[$rc]", []> {
  // Opcode: 0x262F7010, Mask: 0xFFFF703F
  // Operands: ZA, BRAKET, RC, BRAKETdup
  // Flags: C_DI16
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b010000;
  bits<6> rc;
  let Inst{11-6} = rc;
}

// llock<.di> b,u6 00100bbb01101111DBBBuuuuuu010000.
def ARC_LLOCK_b_u6 : ARCompactInst32_2op<0b00100, 0b010000, "llock",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "llock\t$rb, [$uimm6_20]", []> {
  // Opcode: 0x206F0010, Mask: 0xF8FF003F
  // Operands: RB, BRAKET, UIMM6_20, BRAKETdup
  // Flags: C_DI16
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b010000;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// llock<.di> 0,u6 0010011001101111D111uuuuuu010000.
def ARC_LLOCK_z_u6 : ARCompactInst32_2op<0b00100, 0b010000, "llock",
    (outs ), (ins u6imm:$uimm6_20),
    "llock\t[$uimm6_20]", []> {
  // Opcode: 0x266F7010, Mask: 0xFFFF703F
  // Operands: ZA, BRAKET, UIMM6_20, BRAKETdup
  // Flags: C_DI16
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b010000;
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// llock<.di> b,limm 00100bbb00101111DBBB111110010000.
def ARC_LLOCK_b_limm : ARCompactInst32_2op<0b00100, 0b010000, "llock",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "llock\t$rb, [$limm]", []> {
  // Opcode: 0x202F0F90, Mask: 0xF8FF0FFF
  // Operands: RB, BRAKET, LIMM, BRAKETdup
  // Flags: C_DI16
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110010000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// llock<.di> 0,limm 0010011000101111D111111110010000.
def ARC_LLOCK_z_limm : ARCompactInst32_2op<0b00100, 0b010000, "llock",
    (outs ), (ins i32imm:$limm),
    "llock\t[$limm]", []> {
  // Opcode: 0x262F7F90, Mask: 0xFFFF7FFF
  // Operands: ZA, BRAKET, LIMM, BRAKETdup
  // Flags: C_DI16
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110010000;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// scond<.di> b,c 00100bbb00101111DBBBCCCCCC010001.
def ARC_SCOND_b_c : ARCompactInst32_2op<0b00100, 0b010001, "scond",
    (outs GPR32:$rb), (ins GPR32:$rc),
    "scond\t$rb, [$rc]", []> {
  // Opcode: 0x202F0011, Mask: 0xF8FF003F
  // Operands: RB, BRAKET, RC, BRAKETdup
  // Flags: C_DI16
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{5-0} = 0b010001;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// scond<.di> b,u6 00100bbb01101111DBBBuuuuuu010001.
def ARC_SCOND_b_u6 : ARCompactInst32_2op<0b00100, 0b010001, "scond",
    (outs GPR32:$rb), (ins u6imm:$uimm6_20),
    "scond\t$rb, [$uimm6_20]", []> {
  // Opcode: 0x206F0011, Mask: 0xF8FF003F
  // Operands: RB, BRAKET, UIMM6_20, BRAKETdup
  // Flags: C_DI16
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b01101111;
  let Inst{5-0} = 0b010001;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
  bits<6> uimm6_20;
  let Inst{11-6} = uimm6_20;
}

// scond<.di> b,limm 00100bbb00101111DBBB111110010001.
def ARC_SCOND_b_limm : ARCompactInst32_2op<0b00100, 0b010001, "scond",
    (outs GPR32:$rb), (ins i32imm:$limm),
    "scond\t$rb, [$limm]", []> {
  // Opcode: 0x202F0F91, Mask: 0xF8FF0FFF
  // Operands: RB, BRAKET, LIMM, BRAKETdup
  // Flags: C_DI16
  let Inst{31-27} = 0b00100;
  let Inst{23-16} = 0b00101111;
  let Inst{11-0} = 0b111110010001;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// scond<.di> limm,c 0010011000101111D111CCCCCC010001.
def ARC_SCOND_limm_c : ARCompactInst32_2op<0b00100, 0b010001, "scond",
    (outs ), (ins i32imm:$limm, GPR32:$rc),
    "scond\t$limm, [$rc]", []> {
  // Opcode: 0x262F7011, Mask: 0xFFFF703F
  // Operands: LIMM, BRAKET, RC, BRAKETdup
  // Flags: C_DI16
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b010001;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// scond<.di> limm,u6 0010011001101111D111uuuuuu010001.
def ARC_SCOND_limm_u6 : ARCompactInst32_2op<0b00100, 0b010001, "scond",
    (outs ), (ins i32imm:$limm, u6imm:$uimm6_20),
    "scond\t$limm, [$uimm6_20]", []> {
  // Opcode: 0x266F7011, Mask: 0xFFFF703F
  // Operands: LIMM, BRAKET, UIMM6_20, BRAKETdup
  // Flags: C_DI16
  let Inst{31-16} = 0b0010011001101111;
  let Inst{14-12} = 0b111;
  let Inst{5-0} = 0b010001;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// scond<.di> limm,limm 0010011000101111D111111110010001.
def ARC_SCOND_limm : ARCompactInst32_2op<0b00100, 0b010001, "scond",
    (outs ), (ins i32imm:$limm),
    "scond\t$limm", []> {
  // Opcode: 0x262F7F91, Mask: 0xFFFF7FFF
  // Operands: LIMM, BRAKET, LIMMdup, BRAKETdup
  // Flags: C_DI16
  let Inst{31-16} = 0b0010011000101111;
  let Inst{14-0} = 0b111111110010001;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

// st<.di><.aa><zz> c,b 00011bbb000000000BBBCCCCCCDaaZZR.
def ARC_ST_c_b : ARCompactInstStore<0b00011, "st",
    (outs ), (ins GPR32:$rc, GPR32:$rb),
    "st\t$rc, [$rb]", []> {
  // Opcode: 0x18000000, Mask: 0xF8FF8000
  // Operands: RC, BRAKET, RB, BRAKETdup
  // Flags: C_ZZ29, C_DI26, C_AA27
  let Inst{31-27} = 0b00011;
  let Inst{23-15} = 0b000000000;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// st<.di><.aa><zz> c,b,s9 00011bbbssssssssSBBBCCCCCCDaaZZR.
def ARC_ST_c_b_s9 : ARCompactInstStore<0b00011, "st",
    (outs ), (ins GPR32:$rc, GPR32:$rb, s9imm:$simm9_8),
    "st\t$rc, [$rb, $simm9_8]", []> {
  // Opcode: 0x18000000, Mask: 0xF8000000
  // Operands: RC, BRAKET, RB, SIMM9_8, BRAKETdup
  // Flags: C_ZZ29, C_DI26, C_AA27
  let Inst{31-27} = 0b00011;
  bits<6> rb;
  let Inst{26-24} = rb{5-3};
  let Inst{14-12} = rb{2-0};
  bits<9> simm9_8;
  let Inst{23-16} = simm9_8{8-1};
  let Inst{15} = simm9_8{0};
  bits<6> rc;
  let Inst{11-6} = rc;
}

// st<.di><zz> c,limm 00011110000000000111CCCCCCDRRZZR.
def ARC_ST_c_limm : ARCompactInstStore<0b00011, "st",
    (outs ), (ins GPR32:$rc, i32imm:$limm),
    "st\t$rc, [$limm]", []> {
  // Opcode: 0x1E007000, Mask: 0xFFFFF000
  // Operands: RC, BRAKET, LIMM, BRAKETdup
  // Flags: C_ZZ29, C_DI26
  let Inst{31-12} = 0b00011110000000000111;
  // Decoding conflict with overlapping encoding.
  let isCodeGenOnly = 1;
}

// st<.di><.aa><zz> limm,b,s9 00011bbbssssssssSBBB111110DaaZZR.
def ARC_ST_limm_b_s9 : ARCompactInstStore<0b00011, "st",
    (outs ), (ins i32imm:$limm, GPR32:$rb, s9imm:$simm9_8),
    "st\t$limm, [$rb, $simm9_8]", []> {
  // Opcode: 0x18000F80, Mask: 0xF8000FC0
  // Operands: LIMM, BRAKET, RB, SIMM9_8, BRAKETdup
  // Flags: C_ZZ29, C_DI26, C_AA27
  let Inst{31-27} = 0b00011;
  let Inst{11-6} = 0b111110;
  // Decoding conflict with overlapping encoding.
  let isCodeGenOnly = 1;
}

// st<.di><.aa><zz> limm,limm,s9 00011110ssssssssS111111110DaaZZR.
def ARC_ST_limm_s9 : ARCompactInstStore<0b00011, "st",
    (outs ), (ins i32imm:$limm, s9imm:$simm9_8),
    "st\t$limm, [$simm9_8]", []> {
  // Opcode: 0x1E007F80, Mask: 0xFF007FC0
  // Operands: LIMM, BRAKET, LIMMdup, SIMM9_8, BRAKETdup
  // Flags: C_ZZ29, C_DI26, C_AA27
  let Inst{31-24} = 0b00011110;
  let Inst{14-6} = 0b111111110;
  // Operand(s) limm need custom disassembler.
  let isCodeGenOnly = 1;
}

} // end let Predicates = [IsARCompact]
