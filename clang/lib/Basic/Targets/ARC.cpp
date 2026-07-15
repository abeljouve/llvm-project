//===--- ARC.cpp - Implement ARC target feature support -------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements ARC TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#include "ARC.h"
#include "clang/Basic/Builtins.h"
#include "clang/Basic/MacroBuilder.h"
#include "llvm/ADT/StringRef.h"

using namespace clang;
using namespace clang::targets;

namespace {
struct ARCCPUInfo {
  llvm::StringLiteral Name;
  ARCTargetInfo::CPUKind Kind;
};

// 1:1 with the `Proc<>` table in llvm/lib/Target/ARC/ARC.td. Deliberately
// EXCLUDES "generic": ARC.td's generic Proc enables FeatureMPY,
// FeatureSEXT and FeatureBitScan, none of which exist on the BCM55030
// ARC700 integration (they trap on real silicon -- see
// docs/notes/isa-characterization.md and
// docs/llvm-arc700-optimizations/00-target-profile-and-legality.md).
// Whitelisting "generic" here would let a user opt into three trapping
// instruction classes through a name that reads as an innocuous default.
// Any future name added to this table MUST be cross-checked against BOTH
// ARC.td's Proc<> list and the isa-characterization presence/absence
// matrix before being exposed here -- this is a security-relevant
// allowlist, not routine CPU-list housekeeping.
constexpr ARCCPUInfo CPUInfo[] = {
    {{"arc700"}, ARCTargetInfo::CK_ARC700},
    {{"arc700eb"}, ARCTargetInfo::CK_ARC700EB},
    {{"bcm55030"}, ARCTargetInfo::CK_BCM55030},
};
} // namespace

ARCTargetInfo::CPUKind ARCTargetInfo::getCPUKind(StringRef Name) const {
  for (const ARCCPUInfo &Info : CPUInfo)
    if (Info.Name == Name)
      return Info.Kind;
  return CK_NONE;
}

void ARCTargetInfo::fillValidCPUList(
    SmallVectorImpl<StringRef> &Values) const {
  for (const ARCCPUInfo &Info : CPUInfo)
    Values.push_back(Info.Name);
}

void ARCTargetInfo::getTargetDefines(const LangOptions &Opts,
                                     MacroBuilder &Builder) const {
  Builder.defineMacro("__arc__");
  Builder.defineMacro("__ARC__");
  if (IsARCompact)
    Builder.defineMacro("__ARCompact__");

  // Endianness: keyed off the TRIPLE, not the selected CPU, so this stays
  // correct even when no -mcpu is given (arceb-unknown-elf with no CPU
  // selected is a common bare-metal build configuration). clang's
  // InitPreprocessor.cpp already
  // defines __BYTE_ORDER__ / __ORDER_BIG_ENDIAN__ / __ORDER_LITTLE_ENDIAN__
  // generically from TargetInfo::isBigEndian() for every target; this is a
  // convenience alias for ARC-toolchain-flavored source, not filling a gap
  // in the standard macros.
  if (getTriple().getArch() == llvm::Triple::arceb)
    Builder.defineMacro("__ARC_BIG_ENDIAN__");

  // Optional CPU-tune macro, only emitted when a concrete CPU was selected
  // via -mcpu/-target-cpu. CK_NONE must never define anything here -- no
  // macro should claim a CPU identity that wasn't actually requested.
  switch (CPU) {
  case CK_ARC700:
  case CK_ARC700EB:
    Builder.defineMacro("__arc700__");
    break;
  case CK_BCM55030:
    Builder.defineMacro("__arc700__");
    Builder.defineMacro("__arc_bcm55030__");
    break;
  case CK_NONE:
    break;
  }
}
