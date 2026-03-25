//===- IntrinsicsARC.td - Defines ARC intrinsics -----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines all of the ARC-specific intrinsics.
//
//===----------------------------------------------------------------------===//

let TargetPrefix = "arc" in {  // All intrinsics start with "llvm.arc.".

  //===--------------------------------------------------------------------===//
  // Auxiliary register access (LR/SR instructions)
  //
  // LR reads an auxiliary register; SR writes an auxiliary register.
  // These are privileged operations on ARC700 for certain aux register ranges.
  //
  // Usage:
  //   %val = call i32 @llvm.arc.lr(i32 %aux_addr)
  //   call void @llvm.arc.sr(i32 %value, i32 %aux_addr)
  //===--------------------------------------------------------------------===//

  // LR: Load from auxiliary register.
  // IntrHasSideEffects because aux registers can have side effects on read
  // (e.g., reading TIMER0_COUNT advances state).
  def int_arc_lr : Intrinsic<[llvm_i32_ty], [llvm_i32_ty],
                             [IntrReadMem, IntrHasSideEffects]>;

  // SR: Store to auxiliary register.
  // IntrHasSideEffects because writing aux registers triggers hardware actions
  // (e.g., writing IC_CTRL invalidates instruction cache).
  def int_arc_sr : Intrinsic<[], [llvm_i32_ty, llvm_i32_ty],
                             [IntrWriteMem, IntrHasSideEffects]>;

} // end TargetPrefix = "arc"
