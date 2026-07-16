//===- ARCAsmPrinter.cpp - ARC LLVM assembly writer -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GNU format ARC assembly language.
//
//===----------------------------------------------------------------------===//

#include "ARC.h"
#include "ARCInstrInfo.h"
#include "ARCMCInstLower.h"
#include "ARCSubtarget.h"
#include "ARCTargetMachine.h"
#include "MCTargetDesc/ARCInstPrinter.h"
#include "TargetInfo/ARCTargetInfo.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "asm-printer"

namespace {

class ARCAsmPrinter : public AsmPrinter {
  ARCMCInstLower MCInstLowering;

public:
  static char ID;

  explicit ARCAsmPrinter(TargetMachine &TM,
                         std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer), ID),
        MCInstLowering(&OutContext, *this) {}

  StringRef getPassName() const override { return "ARC Assembly Printer"; }
  void emitInstruction(const MachineInstr *MI) override;

private:
  /// Lower and emit exactly one instruction. Bundle walking is the caller's
  /// job -- see emitInstruction.
  void emitSingleInstruction(const MachineInstr *MI);

public:

  bool runOnMachineFunction(MachineFunction &MF) override;

  bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                       const char *ExtraCode, raw_ostream &OS) override;
  bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                             const char *ExtraCode, raw_ostream &OS) override;
};

} // end anonymous namespace

// A filled delay slot is a *flag-only* bundle: ARCDelaySlotFiller builds it
// with MIBundleBuilder, which only sets the BundledSucc / BundledPred flags on
// the transfer and its slot instruction -- it inserts no TargetOpcode::BUNDLE
// header. So there is nothing here for isBundle() to match, and the delayed
// transfer is itself the bundle head: it must be emitted like any other
// instruction, and its members emitted after it.
//
// This walk is not optional. AsmPrinter iterates a block with a
// MachineBasicBlock::iterator, which is a bundle_iterator and therefore yields
// only bundle heads. Without the walk the slot instruction is never lowered,
// never reaches the streamer, and silently vanishes from .text -- whereupon the
// delayed transfer executes whatever word happens to follow it as its delay
// slot. That is a silent wrong-code bug, not a crash: -verify-machineinstrs
// stays quiet and the only symptom is a short .text.
void ARCAsmPrinter::emitInstruction(const MachineInstr *MI) {
  const MachineBasicBlock *MBB = MI->getParent();
  MachineBasicBlock::const_instr_iterator I = MI->getIterator();
  MachineBasicBlock::const_instr_iterator E = MBB->instr_end();

  do {
    // A TargetOpcode::BUNDLE marker encodes nothing and must not be lowered.
    // ARCDelaySlotFiller never creates one, but tolerating both bundle shapes
    // keeps this correct if some later pass starts using finalizeBundle().
    // Meta instructions (DBG_VALUE, lifetime markers, ...) likewise emit no
    // code; the generic AsmPrinter filters them before calling us, but a
    // bundle member reaches the streamer only through this loop.
    if (!I->isBundle() && !I->isMetaInstruction())
      emitSingleInstruction(&*I);
    ++I;
  } while (I != E && I->isInsideBundle());
}

void ARCAsmPrinter::emitSingleInstruction(const MachineInstr *MI) {
  ARC_MC::verifyInstructionPredicates(MI->getOpcode(),
                                      getSubtargetInfo().getFeatureBits());

  SmallString<128> Str;
  raw_svector_ostream O(Str);

  switch (MI->getOpcode()) {
  case ARC::DBG_VALUE:
    llvm_unreachable("Should be handled target independently");
    break;
  case ARC::HWLOOP_END:
    // End-of-loop marker: no code emitted. The label at this position
    // is the LP_END target for the zero-overhead loop.
    return;
  case ARC::HWLOOP_SETUP:
  case ARC::HWLOOP_SETUP_IMM:
    // These pseudos should have been expanded before reaching the
    // AsmPrinter. If they reach here, emit as comments for debugging.
    OutStreamer->AddComment("HWLOOP_SETUP (not expanded)");
    return;
  }

  MCInst TmpInst;
  MCInstLowering.Lower(MI, TmpInst);
  EmitToStreamer(*OutStreamer, TmpInst);
}

bool ARCAsmPrinter::runOnMachineFunction(MachineFunction &MF) {
  // Functions are 4-byte aligned.
  MF.ensureAlignment(Align(4));
  return AsmPrinter::runOnMachineFunction(MF);
}

bool ARCAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                                    const char *ExtraCode, raw_ostream &OS) {
  // Defer to the generic handler for any modifier letter — we don't
  // implement any custom ARC-specific ones yet.
  if (ExtraCode && ExtraCode[0])
    return AsmPrinter::PrintAsmOperand(MI, OpNo, ExtraCode, OS);

  const MachineOperand &MO = MI->getOperand(OpNo);
  switch (MO.getType()) {
  case MachineOperand::MO_Register:
    OS << ARCInstPrinter::getRegisterName(MO.getReg());
    return false;
  case MachineOperand::MO_Immediate:
    OS << MO.getImm();
    return false;
  default:
    break;
  }
  return AsmPrinter::PrintAsmOperand(MI, OpNo, ExtraCode, OS);
}

bool ARCAsmPrinter::PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                                          const char *ExtraCode,
                                          raw_ostream &OS) {
  if (ExtraCode && ExtraCode[0])
    return true;
  const MachineOperand &Base = MI->getOperand(OpNo);
  if (!Base.isReg())
    return true;
  OS << ARCInstPrinter::getRegisterName(Base.getReg());
  return false;
}

char ARCAsmPrinter::ID = 0;

INITIALIZE_PASS(ARCAsmPrinter, "arc-asm-printer", "ARC Assmebly Printer", false,
                false)

// Force static initialization.
extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeARCAsmPrinter() {
  RegisterAsmPrinter<ARCAsmPrinter> X(getTheARCTarget());
  RegisterAsmPrinter<ARCAsmPrinter> Y(getTheARCebTarget());
}
