; Integration test: the whole zero-overhead-loop pipeline, from the generic
; HardwareLoops IR pass through ARCLowOverheadLoops.
;
; With -arc-hardware-loops a clean counted loop becomes an `lp.ne` hardware loop
; (guard + setup folded) with the LP_COUNT write to r60. With the flag off (the
; default) the tree is inert: an ordinary decrement-and-branch loop, no `lp`.

; RUN: llc -mtriple=arceb -mcpu=arc700eb -arc-hardware-loops \
; RUN:     -verify-machineinstrs < %s | FileCheck %s --check-prefix=HWLOOP
; RUN: llc -mtriple=arceb -mcpu=arc700eb \
; RUN:     -verify-machineinstrs < %s | FileCheck %s --check-prefix=OFF

; A guarded (trip >= 1 on the taken edge) do-while counted loop. The stored
; value IV is separate from the hardware counter the pass introduces.
define void @count_store(ptr %p, i32 %n) {
entry:
  %pos = icmp sgt i32 %n, 0
  br i1 %pos, label %loop, label %exit

loop:
  %i = phi i32 [ %n, %entry ], [ %i.next, %loop ]
  %pi = phi ptr [ %p, %entry ], [ %pi.next, %loop ]
  store volatile i32 %i, ptr %pi
  %pi.next = getelementptr inbounds i32, ptr %pi, i32 1
  %i.next = add i32 %i, -1
  %done = icmp eq i32 %i.next, 0
  br i1 %done, label %exit, label %loop

exit:
  ret void
}

; HWLOOP-LABEL: count_store:
; The LP_COUNT write and the conditional loop-setup/zero-trip-guard instruction.
; The ARC InstPrinter spells the conditional setup `lpne` (no dot).
; HWLOOP: mov {{.*}}%r60
; HWLOOP: lpne
; A hardware loop has no in-loop decrement-and-branch back-edge.
; HWLOOP-NOT: brne

; OFF-LABEL: count_store:
; Flag off: ordinary loop, never an `lp`.
; OFF-NOT: lpne
; OFF-NOT: mov {{.*}}%r60
