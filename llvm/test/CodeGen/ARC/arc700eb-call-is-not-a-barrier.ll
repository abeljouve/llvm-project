; RUN: llc -mtriple=arceb-unknown-unknown-elf -mcpu=arc700eb -O0 \
; RUN:     -verify-machineinstrs -filetype=null %s
; RUN: llc -mtriple=arceb-unknown-unknown-elf -mcpu=arc700eb -O2 \
; RUN:     -verify-machineinstrs -filetype=null %s
; RUN: llc -mtriple=arceb-unknown-unknown-elf -mcpu=arc700eb -O2 < %s \
; RUN:     | FileCheck %s

; A call is not a barrier: control returns from it and falls through. Marking
; the BL family isBarrier contradicts analyzeBranch, which reports "falls
; through" for a block whose last instruction is not a terminator. The two
; disagree the moment a call ends its block, which is what a noreturn callee
; produces once PEI deletes the ADJCALLSTACK pseudos that sat after it:
;
;   *** Bad machine code: MBB exits via unconditional fall-through but ends
;       with a barrier instruction! ***
;
; The block has no successors there; that is the empty successor list's job,
; not a barrier flag on the call. -verify-machineinstrs above is the real
; assertion -- at BOTH optimization levels, because the bad MIR was produced
; at every level and only the -O0 allocator ever crashed on it.

target datalayout = "E-m:e-p:32:32-i1:8:32-i8:8:32-i16:16:32-i32:32:32-f32:32:32-i64:32-f64:32-a:0:32-n32"
target triple = "arceb-unknown-unknown-elf"

declare void @llvm.trap()
declare void @noreturn_callee() noreturn

; The `br i1 poison` also covers the second half of this: the register
; allocator erases the IMPLICIT_DEF behind an undefined value and marks its
; uses `undef` instead, so ARCBranchFinalize must carry that flag onto the
; BRcc it builds or the branch reads a register nothing defines
; ("Using an undefined physical register").
define void @trap_ends_the_block() {
; CHECK-LABEL: trap_ends_the_block:
entry:
  br i1 poison, label %t, label %u
t:
  call void @llvm.trap()
  ret void
u:
  unreachable
}

define void @noreturn_call_ends_the_block(i32 %x) {
; CHECK-LABEL: noreturn_call_ends_the_block:
entry:
  %c = icmp eq i32 %x, 0
  br i1 %c, label %bail, label %done
bail:
  call void @noreturn_callee()
  unreachable
done:
  ret void
}
