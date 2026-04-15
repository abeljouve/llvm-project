//===- ARCFixupKinds.h - ARC Specific Fixup Entries -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_ARC_MCTARGETDESC_ARCFIXUPKINDS_H
#define LLVM_LIB_TARGET_ARC_MCTARGETDESC_ARCFIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

namespace llvm {
namespace ARC {

enum Fixups {
  // 32-bit absolute fixup.
  fixup_arc_32 = FirstTargetFixupKind,

  // 21-bit signed half-word PC-relative branch (BL, B with condition).
  fixup_arc_s21h_pcrel,

  // 21-bit signed word PC-relative branch.
  fixup_arc_s21w_pcrel,

  // 25-bit signed half-word PC-relative branch (unconditional B).
  fixup_arc_s25h_pcrel,

  // 25-bit signed word PC-relative branch (unconditional BL).
  fixup_arc_s25w_pcrel,

  // 32-bit PC-relative fixup.
  fixup_arc_32_pcrel,

  // 9-bit signed half-word PC-relative compare-and-branch (BRcc/BBIT0/
  // BBIT1). Target is half-word aligned; encoding splits the displacement
  // across bits [23:17] + bit [15] of the 32-bit instruction word.
  fixup_arc_s9h_pcrel,

  // Marker.
  fixup_arc_invalid,
  NumTargetFixupKinds = fixup_arc_invalid - FirstTargetFixupKind
};

} // end namespace ARC
} // end namespace llvm

#endif // LLVM_LIB_TARGET_ARC_MCTARGETDESC_ARCFIXUPKINDS_H
