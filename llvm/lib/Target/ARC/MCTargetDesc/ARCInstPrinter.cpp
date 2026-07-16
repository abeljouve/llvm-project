//===- ARCInstPrinter.cpp - ARC MCInst to assembly syntax -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This class prints an ARC MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#include "ARCInstPrinter.h"
#include "MCTargetDesc/ARCInfo.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "asm-printer"

#include "ARCGenAsmWriter.inc"

template <class T>
static const char *BadConditionCode(T cc) {
  LLVM_DEBUG(dbgs() << "Unknown condition code passed: " << cc << "\n");
  return "{unknown-cc}";
}

static const char *ARCBRCondCodeToString(ARCCC::BRCondCode BRCC) {
  switch (BRCC) {
  case ARCCC::BREQ:
    return "eq";
  case ARCCC::BRNE:
    return "ne";
  case ARCCC::BRLT:
    return "lt";
  case ARCCC::BRGE:
    return "ge";
  case ARCCC::BRLO:
    return "lo";
  case ARCCC::BRHS:
    return "hs";
  }
  return BadConditionCode(BRCC);
}

static const char *ARCCondCodeToString(ARCCC::CondCode CC) {
  switch (CC) {
  case ARCCC::EQ:
    return "eq";
  case ARCCC::NE:
    return "ne";
  case ARCCC::P:
    return "p";
  case ARCCC::N:
    return "n";
  case ARCCC::HS:
    return "hs";
  case ARCCC::LO:
    return "lo";
  case ARCCC::GT:
    return "gt";
  case ARCCC::GE:
    return "ge";
  case ARCCC::VS:
    return "vs";
  case ARCCC::VC:
    return "vc";
  case ARCCC::LT:
    return "lt";
  case ARCCC::LE:
    return "le";
  case ARCCC::HI:
    return "hi";
  case ARCCC::LS:
    return "ls";
  case ARCCC::PNZ:
    return "pnz";
  case ARCCC::AL:
    return "al";
  case ARCCC::NZ:
    return "nz";
  case ARCCC::Z:
    return "z";
  }
  return BadConditionCode(CC);
}

void ARCInstPrinter::printRegName(raw_ostream &OS, MCRegister Reg) {
  OS << StringRef(getRegisterName(Reg)).lower();
}

void ARCInstPrinter::printInst(const MCInst *MI, uint64_t Address,
                               StringRef Annot, const MCSubtargetInfo &STI,
                               raw_ostream &O) {
  printInstruction(MI, Address, O);
  printAnnotation(O, Annot);
}

static void printExpr(const MCExpr *Expr, const MCAsmInfo *MAI,
                      raw_ostream &OS) {
  int Offset = 0;
  const MCSymbolRefExpr *SRE;

  if (const auto *CE = dyn_cast<MCConstantExpr>(Expr)) {
    OS << "0x";
    OS.write_hex(CE->getValue());
    return;
  }

  if (const auto *BE = dyn_cast<MCBinaryExpr>(Expr)) {
    SRE = dyn_cast<MCSymbolRefExpr>(BE->getLHS());
    const auto *CE = dyn_cast<MCConstantExpr>(BE->getRHS());
    assert(SRE && CE && "Binary expression must be sym+const.");
    Offset = CE->getValue();
  } else {
    SRE = dyn_cast<MCSymbolRefExpr>(Expr);
    assert(SRE && "Unexpected MCExpr type.");
  }
  assert(SRE->getSpecifier() == 0);

  // Symbols are prefixed with '@'
  OS << '@';
  SRE->getSymbol().print(OS, MAI);

  if (Offset) {
    if (Offset > 0)
      OS << '+';
    OS << Offset;
  }
}

void ARCInstPrinter::printOperand(const MCInst *MI, unsigned OpNum,
                                  raw_ostream &O) {
  const MCOperand &Op = MI->getOperand(OpNum);
  if (Op.isReg()) {
    printRegName(O, Op.getReg());
    return;
  }

  if (Op.isImm()) {
    O << Op.getImm();
    return;
  }

  assert(Op.isExpr() && "unknown operand kind in printOperand");
  printExpr(Op.getExpr(), &MAI, O);
}

void ARCInstPrinter::printMemOperandRI(const MCInst *MI, unsigned OpNum,
                                       raw_ostream &O) {
  // The disassembler can produce MCInsts whose operand count doesn't match
  // what the AsmWriter table expects (incomplete decoder methods, custom
  // pseudos that share a print method, etc.). Guard the operand access so
  // `llvm-objdump` prints `<invalid>` and continues instead of asserting
  // out of bounds in SmallVector::operator[].
  if (OpNum + 1 >= MI->getNumOperands()) {
    O << "<invalid memop>";
    return;
  }
  const MCOperand &base = MI->getOperand(OpNum);
  const MCOperand &offset = MI->getOperand(OpNum + 1);
  if (!base.isReg() || !offset.isImm()) {
    O << "<invalid memop>";
    return;
  }
  printRegName(O, base.getReg());
  O << "," << offset.getImm();
}

// MEMrr (ARCInstrFormats.td) is a compound reg+reg operand -- (GPR32:$B,
// GPR32:$C) -- used only by the scaled reg+reg word load `ld.as` (LD_AS_rr).
// It must NOT share printMemOperandRI: that method asserts/guards on the
// second sub-operand being an immediate offset, which is never true here
// (both sub-operands are registers), so routing MEMrr through it silently
// printed "<invalid memop>" for every `ld.as` -- never caught before
// because nothing exercised the scaled load through the AsmPrinter path
// end-to-end.
void ARCInstPrinter::printMemOperandRR(const MCInst *MI, unsigned OpNum,
                                       raw_ostream &O) {
  if (OpNum + 1 >= MI->getNumOperands()) {
    O << "<invalid memop>";
    return;
  }
  const MCOperand &base = MI->getOperand(OpNum);
  const MCOperand &index = MI->getOperand(OpNum + 1);
  if (!base.isReg() || !index.isReg()) {
    O << "<invalid memop>";
    return;
  }
  printRegName(O, base.getReg());
  O << ",";
  printRegName(O, index.getReg());
}

void ARCInstPrinter::printPredicateOperand(const MCInst *MI, unsigned OpNum,
                                           raw_ostream &O) {

  const MCOperand &Op = MI->getOperand(OpNum);
  assert(Op.isImm() && "Predicate operand is immediate.");
  O << ARCCondCodeToString((ARCCC::CondCode)Op.getImm());
}

void ARCInstPrinter::printBRCCPredicateOperand(const MCInst *MI, unsigned OpNum,
                                               raw_ostream &O) {
  const MCOperand &Op = MI->getOperand(OpNum);
  assert(Op.isImm() && "Predicate operand is immediate.");
  O << ARCBRCondCodeToString((ARCCC::BRCondCode)Op.getImm());
}

void ARCInstPrinter::printCCOperand(const MCInst *MI, int OpNum,
                                    raw_ostream &O) {
  O << ARCCondCodeToString((ARCCC::CondCode)MI->getOperand(OpNum).getImm());
}

void ARCInstPrinter::printU6ShiftedBy(unsigned ShiftBy, const MCInst *MI,
                                      int OpNum, raw_ostream &O) {
  const MCOperand &MO = MI->getOperand(OpNum);
  if (MO.isImm()) {
    unsigned Value = MO.getImm();
    unsigned Value2 = Value >> ShiftBy;
    if (Value2 > 0x3F || (Value2 << ShiftBy != Value)) {
      errs() << "!!! Instruction has out-of-range U6 immediate operand:\n"
             << "    Opcode is " << MI->getOpcode() << "; operand value is "
             << Value;
      if (ShiftBy)
        errs() << " scaled by " << (1 << ShiftBy) << "\n";
      assert(false && "instruction has wrong format");
    }
  }
  printOperand(MI, OpNum, O);
}

void ARCInstPrinter::printU6(const MCInst *MI, int OpNum, raw_ostream &O) {
  printU6ShiftedBy(0, MI, OpNum, O);
}
