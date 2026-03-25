//===-- ARCARCompactInstrFormats.td - ARC ARCompact Instruction Formats -*- tablegen -*-===//
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

//===----------------------------------------------------------------------===//
// ARCompact instruction format base classes
//===----------------------------------------------------------------------===//

// Predicate for ARCompact mode
def IsARCompact : Predicate<"Subtarget->isARCompact()">,
                  AssemblerPredicate<(all_of FeatureARCompact),
                                     "ARCompact ISA">;

//===----------------------------------------------------------------------===//
// 32-bit ARCompact instruction formats
//===----------------------------------------------------------------------===//

// Base class for all 32-bit ARCompact instructions
class ARCompactInst32<dag outs, dag ins, string asmstr, list<dag> pattern>
    : Instruction {
  let Namespace = "ARC";
  let Size = 4;
  let DecoderNamespace = "ARCompact32";

  field bits<32> Inst;
  field bits<32> SoftFail = 0;

  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = asmstr;
  let Pattern = pattern;
  let Predicates = [IsARCompact];
  let isPseudo = 0;
  // Disassembler enabled -- conflicts resolved via isCodeGenOnly on specific
  // instructions (DSP/float overlaps, true duplicates).
}

// 3-operand ALU: major[31:27], subop[21:16], F[15], a[5:0], b[26:24,14:12], c[11:6]
// Register B field is SPLIT: Inst{26-24} = rb{2-0} (low 3), Inst{14-12} = rb{5-3} (high 3).
// Matches binutils insert_rb(): insn | ((value & 0x07)<<24) | (((value>>3)&0x07)<<12).
// Register A field: Inst{5-0} = ra{5-0}.
// Register C field: Inst{11-6} = rc{5-0}.
class ARCompactInst32_3op<bits<5> major, bits<6> subop, string mnemonic,
                          dag outs, dag ins, string asmstr, list<dag> pattern>
    : ARCompactInst32<outs, ins, asmstr, pattern> {
  let Inst{31-27} = major;
  let Inst{21-16} = subop;
  // ALU instructions have no side effects and do not access memory.
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// 2-operand (single-operand) ALU: major[31:27], subop1=0x2F[21:16], subop2[5:0]
// Register B field is SPLIT: Inst{26-24} = rb{2-0} (low 3), Inst{14-12} = rb{5-3} (high 3).
// Matches binutils insert_rb(): insn | ((value & 0x07)<<24) | (((value>>3)&0x07)<<12).
class ARCompactInst32_2op<bits<5> major, bits<6> subop2, string mnemonic,
                          dag outs, dag ins, string asmstr, list<dag> pattern>
    : ARCompactInst32<outs, ins, asmstr, pattern> {
  let Inst{31-27} = major;
  let Inst{21-16} = 0b101111; // 0x2F
  let Inst{5-0} = subop2;
  // ALU instructions have no side effects and do not access memory.
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// Branch format: major[31:27]
class ARCompactInstBranch<bits<5> major, string mnemonic,
                          dag outs, dag ins, string asmstr, list<dag> pattern>
    : ARCompactInst32<outs, ins, asmstr, pattern> {
  let Inst{31-27} = major;
  let isBranch = 1;
  let isTerminator = 1;
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// Jump format
class ARCompactInstJump<bits<5> major, string mnemonic,
                        dag outs, dag ins, string asmstr, list<dag> pattern>
    : ARCompactInst32<outs, ins, asmstr, pattern> {
  let Inst{31-27} = major;
  let isBranch = 1;
  let isTerminator = 1;
  let isIndirectBranch = 1;
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// Load format: major[31:27]
class ARCompactInstLoad<bits<5> major, string mnemonic,
                        dag outs, dag ins, string asmstr, list<dag> pattern>
    : ARCompactInst32<outs, ins, asmstr, pattern> {
  let Inst{31-27} = major;
  let hasSideEffects = 0;
  let mayLoad = 1;
  let mayStore = 0;
}

// Store format: major[31:27]
class ARCompactInstStore<bits<5> major, string mnemonic,
                         dag outs, dag ins, string asmstr, list<dag> pattern>
    : ARCompactInst32<outs, ins, asmstr, pattern> {
  let Inst{31-27} = major;
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 1;
}

// Special/control format
class ARCompactInstSpecial<string mnemonic,
                           dag outs, dag ins, string asmstr, list<dag> pattern>
    : ARCompactInst32<outs, ins, asmstr, pattern>;

//===----------------------------------------------------------------------===//
// 16-bit ARCompact instruction formats
//===----------------------------------------------------------------------===//

// Base class for all 16-bit ARCompact (compact) instructions
class ARCompactInst16<dag outs, dag ins, string asmstr, list<dag> pattern>
    : Instruction {
  let Namespace = "ARC";
  let Size = 2;
  let DecoderNamespace = "ARCompact16";

  field bits<16> Inst;
  field bits<16> SoftFail = 0;

  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = asmstr;
  let Pattern = pattern;
  let Predicates = [IsARCompact];
  let isPseudo = 0;
  // Disassembler enabled -- conflicts resolved via isCodeGenOnly on specific
  // instructions (DSP/float overlaps, true duplicates).
}

// 16-bit ALU
class ARCompactInst16_ALU<bits<5> major, string mnemonic,
                          dag outs, dag ins, string asmstr, list<dag> pattern>
    : ARCompactInst16<outs, ins, asmstr, pattern> {
  let Inst{15-11} = major;
  // ALU instructions have no side effects and do not access memory.
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// 16-bit Branch
class ARCompactInst16_Branch<bits<5> major, string mnemonic,
                             dag outs, dag ins, string asmstr, list<dag> pattern>
    : ARCompactInst16<outs, ins, asmstr, pattern> {
  let Inst{15-11} = major;
  let isBranch = 1;
  let isTerminator = 1;
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// 16-bit Load/Store
class ARCompactInst16_LS<bits<5> major, string mnemonic,
                         dag outs, dag ins, string asmstr, list<dag> pattern>
    : ARCompactInst16<outs, ins, asmstr, pattern> {
  let Inst{15-11} = major;
  // mayLoad/mayStore set per-instruction in the individual defs.
  let hasSideEffects = 0;
}

//===----------------------------------------------------------------------===//
// Operand definitions for ARCompact
//===----------------------------------------------------------------------===//

// Immediate operands
def u3imm : Operand<i32>;
def u5imm : Operand<i32>;
def u6imm : Operand<i32>;
def u7imm : Operand<i32>;
def u8imm : Operand<i32>;
def u10imm : Operand<i32>;
def u12imm : Operand<i32>;
def s3imm : Operand<i32>;
def s6imm : Operand<i32>;
def s9imm : Operand<i32>;
def s12imm : Operand<i32>;

// Aligned immediates
def u5imm_a32 : Operand<i32>;
def u6imm_a16 : Operand<i32>;
def u7imm_a16 : Operand<i32>;
def u7imm_a32 : Operand<i32>;
def u10imm_a32 : Operand<i32>;
def s11imm_a32 : Operand<i32>;

// Branch/call targets
def brtarget_s7 : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetEncoding";
  let DecoderMethod = "decodeBranchTarget7";
}
def brtarget_s8 : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetEncoding";
  let DecoderMethod = "decodeBranchTarget8";
}
def brtarget_s9 : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetEncoding";
  let DecoderMethod = "decodeBranchTarget9";
}
def brtarget_s10 : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetEncoding";
  let DecoderMethod = "decodeBranchTarget10";
}
def brtarget_s13 : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetEncoding";
  let DecoderMethod = "decodeBranchTarget13";
}
def brtarget_s21 : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetEncoding";
  let DecoderMethod = "decodeBranchTarget21";
}
def brtarget_s25 : Operand<OtherVT> {
  let EncoderMethod = "getBranchTargetEncoding";
  let DecoderMethod = "decodeBranchTarget25";
}
def calltarget_s13 : Operand<i32> {
  let EncoderMethod = "getCallTargetEncoding";
  let DecoderMethod = "decodeCallTarget13";
}
def calltarget_s21 : Operand<i32> {
  let EncoderMethod = "getCallTargetEncoding";
  let DecoderMethod = "decodeCallTarget21";
}
def calltarget_s25 : Operand<i32> {
  let EncoderMethod = "getCallTargetEncoding";
  let DecoderMethod = "decodeCallTarget25";
}

// Fixed register operands for 16-bit instructions
// PCL (PC aligned) is used in PC-relative loads
def PCL : Operand<i32> {
  let PrintMethod = "printPCLOperand";
}

// SP/GP as operands in 16-bit instructions (they're real registers but used as
// fixed implicit operands in the compact encoding)
// GP and SP are already defined as registers in ARCRegisterInfo.td.
// For 16-bit instructions that reference them as fixed operands, we use GPR32.
