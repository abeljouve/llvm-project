//===- ARCMCTargetDesc.cpp - ARC Target Descriptions ------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides ARC specific target descriptions.
//
//===----------------------------------------------------------------------===//

#include "ARCMCTargetDesc.h"
#include "ARCInstPrinter.h"
#include "ARCMCAsmInfo.h"
#include "ARCMCCodeEmitter.h"
#include "ARCTargetStreamer.h"
#include "TargetInfo/ARCTargetInfo.h"
#include "llvm/MC/MCDwarf.h"
#include "llvm/MC/MCInstrAnalysis.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"

using namespace llvm;

#define GET_INSTRINFO_MC_DESC
#define ENABLE_INSTR_PREDICATE_VERIFIER
#include "ARCGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "ARCGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "ARCGenRegisterInfo.inc"

static MCInstrInfo *createARCMCInstrInfo() {
  auto *X = new MCInstrInfo();
  InitARCMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createARCMCRegisterInfo(const Triple &TT) {
  auto *X = new MCRegisterInfo();
  InitARCMCRegisterInfo(X, ARC::BLINK);
  return X;
}

static MCSubtargetInfo *createARCMCSubtargetInfo(const Triple &TT,
                                                 StringRef CPU, StringRef FS) {
  return createARCMCSubtargetInfoImpl(TT, CPU, /*TuneCPU=*/CPU, FS);
}

static MCAsmInfo *createARCMCAsmInfo(const MCRegisterInfo &MRI,
                                     const Triple &TT,
                                     const MCTargetOptions &Options) {
  MCAsmInfo *MAI = new ARCMCAsmInfo(TT);

  // Initial state of the frame pointer is SP.
  MCCFIInstruction Inst = MCCFIInstruction::cfiDefCfa(nullptr, ARC::SP, 0);
  MAI->addInitialFrameState(Inst);

  return MAI;
}

// The generic analysis answers isCall / isReturn / isBranch / isTerminator /
// isBarrier straight out of the MCInstrDesc flags, which the ARC instruction
// definitions already set (BL/JL are isCall, J [blink] and RTIE are isReturn,
// Bcc/BRcc are isBranch). ARC needs no target-specific overrides beyond that:
// the two members that would want one -- evaluateBranch and findPltEntries --
// are used by objdump-style tools, not by the scheduling consumers, and the
// base class's conservative "unknown" answers are correct for them.
//
// Registering this is what lets llvm-mca run on ARC. MCA's InstrBuilder holds
// an MCInstrAnalysis and, unlike its other uses of it, dereferences it without
// a null check when classifying calls and returns. No target ships without one,
// so that path is never exercised elsewhere; ARC used to escape it only because
// MCA bailed out earlier for want of a scheduling model. Now that a model
// exists, MCA gets that far and the missing registration would be a null
// dereference. SystemZ registers the generic analysis the same way.
static MCInstrAnalysis *createARCMCInstrAnalysis(const MCInstrInfo *Info) {
  return new MCInstrAnalysis(Info);
}

static MCInstPrinter *createARCMCInstPrinter(const Triple &T,
                                             unsigned SyntaxVariant,
                                             const MCAsmInfo &MAI,
                                             const MCInstrInfo &MII,
                                             const MCRegisterInfo &MRI) {
  return new ARCInstPrinter(MAI, MII, MRI);
}

ARCTargetStreamer::ARCTargetStreamer(MCStreamer &S) : MCTargetStreamer(S) {}
ARCTargetStreamer::~ARCTargetStreamer() = default;

static MCTargetStreamer *createTargetAsmStreamer(MCStreamer &S,
                                                 formatted_raw_ostream &OS,
                                                 MCInstPrinter *InstPrint) {
  return new ARCTargetStreamer(S);
}

static void registerARCMCTargetDesc(Target &T) {
  RegisterMCAsmInfoFn MAI(T, createARCMCAsmInfo);
  TargetRegistry::RegisterMCInstrInfo(T, createARCMCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(T, createARCMCRegisterInfo);
  TargetRegistry::RegisterMCSubtargetInfo(T, createARCMCSubtargetInfo);
  TargetRegistry::RegisterMCInstrAnalysis(T, createARCMCInstrAnalysis);
  TargetRegistry::RegisterMCInstPrinter(T, createARCMCInstPrinter);
  TargetRegistry::RegisterMCCodeEmitter(T, createARCMCCodeEmitter);
  TargetRegistry::RegisterMCAsmBackend(T, createARCAsmBackend);
  TargetRegistry::RegisterAsmTargetStreamer(T, createTargetAsmStreamer);
}

// Force static initialization.
extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeARCTargetMC() {
  registerARCMCTargetDesc(getTheARCTarget());
  registerARCMCTargetDesc(getTheARCebTarget());
}
