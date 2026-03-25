; RUN: llc -mtriple=arc -mcpu=arc700 < %s | FileCheck %s
;
; Test that HWLOOP_SETUP pseudo-instructions are expanded into the correct
; ARC700 instruction sequence: mov LP_COUNT(r60), <count> / nop / lp <end>.
; The NOP is required as a hazard barrier between writing LP_COUNT and the
; LP instruction.

; CHECK-LABEL: simple_loop:
; CHECK:       mov %r60,
; CHECK-NEXT:  nop
; CHECK-NEXT:  lp @[[LPEND:.LBB[0-9]+_[0-9]+]]
; CHECK:       [[LPEND]]:
define void @simple_loop(ptr %p, i32 %n) {
entry:
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %loop, label %exit

loop:
  %i = phi i32 [ %n, %entry ], [ %i.next, %loop ]
  %ptr = getelementptr i32, ptr %p, i32 %i
  store i32 0, ptr %ptr
  %i.next = sub i32 %i, 1
  %done = icmp eq i32 %i.next, 0
  br i1 %done, label %exit, label %loop

exit:
  ret void
}

; A second variant to check the expansion also works with a different
; register for the trip count.
; CHECK-LABEL: memset_loop:
; CHECK:       mov %r60,
; CHECK-NEXT:  nop
; CHECK-NEXT:  lp @[[LPEND2:.LBB[0-9]+_[0-9]+]]
; CHECK:       [[LPEND2]]:
define void @memset_loop(ptr %p, i32 %val, i32 %n) {
entry:
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %loop, label %exit

loop:
  %i = phi i32 [ %n, %entry ], [ %i.next, %loop ]
  %idx = sub i32 %i, 1
  %ptr = getelementptr i32, ptr %p, i32 %idx
  store i32 %val, ptr %ptr
  %i.next = sub i32 %i, 1
  %done = icmp eq i32 %i.next, 0
  br i1 %done, label %exit, label %loop

exit:
  ret void
}
