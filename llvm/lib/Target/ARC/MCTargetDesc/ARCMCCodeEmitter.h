//===- ARCMCCodeEmitter.h - ARC Code Emitter --------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the ARCMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_ARC_MCTARGETDESC_ARCMCCODEEMITTER_H
#define LLVM_LIB_TARGET_ARC_MCTARGETDESC_ARCMCCODEEMITTER_H

#include "llvm/MC/MCCodeEmitter.h"

namespace llvm {

class MCContext;
class MCInstrInfo;

MCCodeEmitter *createARCMCCodeEmitter(const MCInstrInfo &MCII,
                                      MCContext &Ctx);

} // end namespace llvm

#endif // LLVM_LIB_TARGET_ARC_MCTARGETDESC_ARCMCCODEEMITTER_H
