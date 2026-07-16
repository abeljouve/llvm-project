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
// on ARCompact. Without it, CTLZ/CTTZ are Expand-lowered to an inline
// shift-OR + popcount sequence (no libcall).
def FeatureBitScan
    : SubtargetFeature<"bitscan", "HasBitScan", "true",
                       "Enable fls/ffs bit-scan instructions">;

// Full-32-bit byte-reversal instruction (swape). ARCv2-only; ABSENT on
// ARC700/ARCompact cores (no encoding on ARC700; traps as an illegal
// instruction on ARCv2 word-mode per the silicon oracle). Stays OFF for
// every currently-defined Proc (generic/arc700/arc700eb/bcm55030) so the
// bswap DAG combine can never select ARC_SWAPE_* on this profile.
def FeatureSwape
    : SubtargetFeature<"swape", "HasSwape", "true",
                       "Enable swape full-32-bit byte-reversal (ABSENT on BCM55030 ARC700)">;

// Interrupt-return instruction (rtie). ABSENT/traps on the BCM55030 ARC700
// integration -- silicon characterization confirmed RTIE enters Instruction
// Error vector 2 (docs/notes/isa-characterization.md). The required
// interrupt-return mechanism on this profile is `j.f [ILINK1/2]`, not RTIE.
// Stays OFF for every currently-defined Proc so the assembler rejects `rtie`
// by default and codegen must never emit/reference it.
def FeatureRTIE
    : SubtargetFeature<"rtie", "HasRTIE", "true",
                       "Enable rtie (interrupt return; ABSENT/traps on BCM55030 ARC700)">;

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

//===----------------------------------------------------------------------===//
// Scheduling models
//===----------------------------------------------------------------------===//
//
// Must come after the instruction definitions: the model attaches itself with
// InstRW blocks keyed by opcode name.

include "ARCScheduleBCM55030.td"

//===----------------------------------------------------------------------===//
// Processors
//===----------------------------------------------------------------------===//

class Proc<string Name, list<SubtargetFeature> Features>
 : Processor<Name, NoItineraries, Features>;

def : Proc<"generic", [FeatureMPY, FeatureSEXT, FeatureBitScan]>;
def : Proc<"arc700", [FeatureARCompact, FeatureNORM]>;
def : Proc<"arc700eb", [FeatureARCompact, FeatureNORM, FeatureBigEndian]>;

// BCM55030's ARC700 core. Feature list is deliberately IDENTICAL to
// arc700eb's today (ARCompact + NORM + big-endian, nothing else) — this CPU
// name exists so future -mcpu=bcm55030 usage documents silicon intent, but
// it must NOT gain FeatureMPY/FeatureSEXT/FeatureBitScan/FeatureSwape: none
// of those are present on this silicon (see docs/notes/isa-characterization.md).
//
// This is the ONLY processor with a scheduling model. BCM55030Model is a
// per-clock characterization of one specific part, measured on that silicon;
// the other CPUs above are generic profiles that were never measured, and
// extending a calibrated model to them would be fabrication with a
// calibrated-looking veneer. They keep NoItineraries, and ARCSubtarget's
// enableMachineScheduler() gates on a model being present, so their codegen is
// bit-for-bit unaffected by this file.
def : ProcessorModel<"bcm55030", BCM55030Model,
                     [FeatureARCompact, FeatureNORM, FeatureBigEndian]>;

def ARC : Target {
  let InstructionSet = ARCInstrInfo;
}
