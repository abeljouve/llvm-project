; RUN: llc -mtriple=arc -mcpu=arc700 -debug-only=arc-hwloops < %s 2>&1 | FileCheck %s --check-prefix=CHECK-DEBUG
; RUN: llc -mtriple=arc -debug-only=arc-hwloops < %s 2>&1 | FileCheck %s --check-prefix=CHECK-SKIP
; REQUIRES: asserts

; Test that the ARC hardware loop pass runs and converts counted loops
; for the ARCompact (arc700) subtarget.

; CHECK-DEBUG: ********* ARC Zero-Overhead Loops *********
; CHECK-DEBUG: HWLoop: found trip count pattern
; CHECK-DEBUG: HWLoop: converting loop in simple_loop

; Test that the pass skips non-ARCompact targets.
; CHECK-SKIP: HWLoop: not ARCompact, skipping

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
