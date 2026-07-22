//===- ARC.h - Top-level interface for ARC representation -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in the LLVM
// ARC back-end.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_ARC_ARC_H
#define LLVM_LIB_TARGET_ARC_ARC_H

#include "MCTargetDesc/ARCMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class ARCTargetMachine;
class FunctionPass;
class PassRegistry;

FunctionPass *createARCISelDag(ARCTargetMachine &TM, CodeGenOptLevel OptLevel);
FunctionPass *createARCExpandPseudosPass();
FunctionPass *createARCOptAddrMode();
FunctionPass *createARCBranchFinalizePass();
FunctionPass *createARCDelaySlotFillerPass();
FunctionPass *createARCSizeReductionPass();
FunctionPass *createARCLowOverheadLoopsPass();
void initializeARCAsmPrinterPass(PassRegistry &);
void initializeARCDAGToDAGISelLegacyPass(PassRegistry &);
void initializeARCDelaySlotFillerPass(PassRegistry &);
void initializeARCSizeReductionPass(PassRegistry &);
void initializeARCLowOverheadLoopsPass(PassRegistry &);
void initializeARCOptAddrModePass(PassRegistry &);
void initializeARCBranchFinalizePass(PassRegistry &);

/// Whether zero-overhead hardware-loop (LP) formation is enabled. Reflects the
/// hidden -arc-hardware-loops command-line flag, which defaults to OFF: the
/// runtime interrupt entry code on the intended target does not save/restore
/// LP_COUNT / LP_START / LP_END, so emitting LP by default would silently
/// corrupt a foreground loop interrupted by an LP-using handler. See
/// ARCTargetMachine.cpp and docs/notes/isa-characterization.md 4.4.
bool ARCEnableHardwareLoops();

} // end namespace llvm

#endif // LLVM_LIB_TARGET_ARC_ARC_H
