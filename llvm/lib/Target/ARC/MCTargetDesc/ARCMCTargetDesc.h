//===- ARCMCTargetDesc.h - ARC Target Descriptions --------------*- C++ -*-===//
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

#ifndef LLVM_LIB_TARGET_ARC_MCTARGETDESC_ARCMCTARGETDESC_H
#define LLVM_LIB_TARGET_ARC_MCTARGETDESC_ARCMCTARGETDESC_H

#include "llvm/Support/DataTypes.h"
#include <memory>

namespace llvm {

class MCAsmBackend;
class MCObjectTargetWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class MCTargetOptions;
class Target;

MCAsmBackend *createARCAsmBackend(const Target &T, const MCSubtargetInfo &STI,
                                  const MCRegisterInfo &MRI,
                                  const MCTargetOptions &Options);

std::unique_ptr<MCObjectTargetWriter>
createARCELFObjectWriter(uint8_t OSABI, bool IsBigEndian);

} // end namespace llvm

// Defines symbolic names for ARC registers.  This defines a mapping from
// register name to register number.
#define GET_REGINFO_ENUM
#include "ARCGenRegisterInfo.inc"

// Defines symbolic names for the ARC instructions.
#define GET_INSTRINFO_ENUM
#define GET_INSTRINFO_MC_HELPER_DECLS
#include "ARCGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "ARCGenSubtargetInfo.inc"

#endif // LLVM_LIB_TARGET_ARC_MCTARGETDESC_ARCMCTARGETDESC_H
