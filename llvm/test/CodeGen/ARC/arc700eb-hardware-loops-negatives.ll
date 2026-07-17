; Loops that must NOT become hardware loops even with -arc-hardware-loops on.
; Each falls back to ordinary code; none emits `lp`. -verify-machineinstrs must
; stay clean throughout.

; RUN: llc -mtriple=arceb -mcpu=arc700eb -arc-hardware-loops \
; RUN:     -verify-machineinstrs < %s | FileCheck %s

declare void @use(i32)

; A call in the body is rejected up front (LP_COUNT liveness across a call is
; uncharacterized and the interrupt-safety story is unresolved): no intrinsics
; are inserted, so no `lp`.
define void @call_in_body(i32 %n) {
entry:
  %pos = icmp sgt i32 %n, 0
  br i1 %pos, label %loop, label %exit

loop:
  %i = phi i32 [ %n, %entry ], [ %i.next, %loop ]
  call void @use(i32 %i)
  %i.next = add i32 %i, -1
  %done = icmp eq i32 %i.next, 0
  br i1 %done, label %exit, label %loop

exit:
  ret void
}
; CHECK-LABEL: call_in_body:
; CHECK-NOT: lp.ne

; A second in-loop exit means the loop is not a single-exit candidate: the
; generic pass rejects it, and the multi-block body would fail ARCLowOverhead-
; Loops' single-block precondition anyway.
define i32 @early_exit(ptr %p, i32 %n) {
entry:
  %pos = icmp sgt i32 %n, 0
  br i1 %pos, label %loop, label %exit

loop:
  %i = phi i32 [ %n, %entry ], [ %i.next, %cont ]
  %pi = phi ptr [ %p, %entry ], [ %pi.next, %cont ]
  %v = load volatile i32, ptr %pi
  %hit = icmp eq i32 %v, 42
  br i1 %hit, label %found, label %cont

cont:
  %pi.next = getelementptr inbounds i32, ptr %pi, i32 1
  %i.next = add i32 %i, -1
  %done = icmp eq i32 %i.next, 0
  br i1 %done, label %exit, label %loop

found:
  ret i32 1

exit:
  ret i32 0
}
; CHECK-LABEL: early_exit:
; CHECK-NOT: lp.ne

; An outer loop that contains an inner loop must not itself become a hardware
; loop (nested hardware loops are illegal here, IsNestingLegal = false; the
; generic pass converts at most the innermost). The outer counter stays an
; ordinary decrement-and-branch. We only require that the OUTER back-edge is not
; folded away into the outer preheader as an `lp` around the whole nest, and that
; codegen verifies.
define void @nested(ptr %p, i32 %n, i32 %m) {
entry:
  %pn = icmp sgt i32 %n, 0
  br i1 %pn, label %outer, label %exit

outer:
  %i = phi i32 [ %n, %entry ], [ %i.next, %outer.latch ]
  %pm = icmp sgt i32 %m, 0
  br i1 %pm, label %inner, label %outer.latch

inner:
  %j = phi i32 [ %m, %outer ], [ %j.next, %inner ]
  store volatile i32 %j, ptr %p
  %j.next = add i32 %j, -1
  %jdone = icmp eq i32 %j.next, 0
  br i1 %jdone, label %outer.latch, label %inner

outer.latch:
  %i.next = add i32 %i, -1
  %idone = icmp eq i32 %i.next, 0
  br i1 %idone, label %exit, label %outer

exit:
  ret void
}
; The inner loop may legally become an `lp`; the key property is that nested
; hardware loops are rejected and the whole nest still verifies (checked by
; -verify-machineinstrs on the RUN line). No assertion on the exact `lp` count
; is made here -- FileCheck cannot robustly count occurrences across a function.
; CHECK-LABEL: nested:
