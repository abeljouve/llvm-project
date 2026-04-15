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

// Hardware 32x32 multiply extension. ARC700 cores can ship WITHOUT this
// (MULTIPLY_BUILD BCR 0x7B = 0), so mul/mulhs/mulhu must lower to libcalls
// via compiler-rt (__mulsi3, __umulsi3hi, __mulsi3hi).
def FeatureMPY
    : SubtargetFeature<"mpy", "HasMPY", "true",
                       "Enable 32x32 multiply instructions (mpy, mpym, mpymu)">;

// Sign-extend byte/halfword instructions (sexb, sexh). Part of ARCv2 base
// ISA, NOT available on ARCompact (ARC600/ARC700) — the Synopsys binutils
// rejects both mnemonics for -mcpu=arc700/arc600. On ARCompact cores
// sext_inreg is expanded into a shift-shift pair.
def FeatureSEXT
    : SubtargetFeature<"sext", "HasSEXT", "true",
                       "Enable sexb/sexh sign-extend instructions">;

// Bit-scan instructions (fls, ffs). Part of ARCv2 base ISA, NOT available
// on ARCompact. Without it, CTLZ/CTTZ lower via libcalls (__clzsi2/__ctzsi2
// from compiler-rt).
def FeatureBitScan
    : SubtargetFeature<"bitscan", "HasBitScan", "true",
                       "Enable fls/ffs bit-scan instructions">;

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

def : Proc<"generic", [FeatureMPY, FeatureSEXT, FeatureBitScan]>;
def : Proc<"arc700", [FeatureARCompact, FeatureNORM]>;
def : Proc<"arc700eb", [FeatureARCompact, FeatureNORM, FeatureBigEndian]>;

def ARC : Target {
  let InstructionSet = ARCInstrInfo;
}
