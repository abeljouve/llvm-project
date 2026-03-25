//===- ARC.td - Describe the ARC Target Machine ------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// ARC Subtarget features
//===----------------------------------------------------------------------===//

def FeatureNORM
    : SubtargetFeature<"norm", "Xnorm", "true",
                       "Enable support for norm instruction.">;

def FeatureARCompact
    : SubtargetFeature<"arcompact", "IsARCompact", "true",
                       "ARCompact ISA (ARC600/ARC700)">;

def FeatureBigEndian
    : SubtargetFeature<"bigendian", "IsBigEndian", "true",
                       "Big-endian byte order">;

//===----------------------------------------------------------------------===//
// Registers, calling conventions, instruction descriptions
//===----------------------------------------------------------------------===//

include "ARCRegisterInfo.td"
include "ARCInstrInfo.td"
include "ARCCallingConv.td"

//===----------------------------------------------------------------------===//
// ARCompact (ARC600/ARC700) instruction definitions
//===----------------------------------------------------------------------===//

include "ARCARCompactInstrFormats.td"
include "ARCARCompactInstrALU.td"
include "ARCARCompactInstrBranch.td"
include "ARCARCompactInstrLoadStore.td"
include "ARCARCompactInstrSpecial.td"
include "ARCARCompactInstrExtArith.td"
include "ARCARCompactInstr16.td"
include "ARCARCompactPatterns.td"

defm : RemapAllTargetPseudoPointerOperands<GPR32>;

def ARCInstrInfo : InstrInfo;

class Proc<string Name, list<SubtargetFeature> Features>
 : Processor<Name, NoItineraries, Features>;

def : Proc<"generic", []>;
def : Proc<"arc700", [FeatureARCompact, FeatureNORM]>;
def : Proc<"arc700eb", [FeatureARCompact, FeatureNORM, FeatureBigEndian]>;

def ARC : Target {
  let InstructionSet = ARCInstrInfo;
}
