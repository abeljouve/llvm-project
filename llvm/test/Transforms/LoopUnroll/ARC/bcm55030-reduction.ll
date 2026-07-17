; RUN: opt -mtriple=arceb-unknown-elf -mcpu=bcm55030 -passes=loop-unroll -S < %s | FileCheck %s

; Load-use latency hiding: ARCTTIImpl::getUnrollingPreferences turns on
; partial/runtime unrolling with a default factor of 4 (both UP.Count and
; UP.DefaultUnrollRuntimeCount) and a hard register-pressure ceiling of
; UP.MaxCount = 8. A dependent load-use costs 10 clocks and the D-cache is off
; in the shipping config, so a scalar reduction is bound by its own recurrence;
; unrolling gives the scheduler independent loads to overlap in each load's
; shadow. The factor is bounded by register pressure, not the cost threshold:
; on this core a spill is an uncached 10-clock load, so the loop must NOT spill
; at the chosen factor.

; A reduction with an unknown (runtime) trip count takes the runtime-unroll
; path, which reads UP.DefaultUnrollRuntimeCount. It must unroll to exactly 4
; -- four loads in the main loop body -- with a scalar remainder loop, and NO
; more (the next factor, 8, is the ceiling, not the default).
define i32 @sum(ptr nocapture readonly %a, i32 %n) {
; CHECK-LABEL: @sum(
; CHECK:       loop:
; CHECK:         load i32
; CHECK-NEXT:    add
; CHECK:         load i32
; CHECK:         load i32
; CHECK:         load i32
; The fifth load in the whole function is the remainder loop's single load, not
; a fifth unrolled copy: exactly four in the main body.
; CHECK:       loop.epil:
; CHECK:         load i32
; CHECK-NOT:     load i32
entry:
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %loop, label %exit
loop:
  %i = phi i32 [ %inc, %loop ], [ 0, %entry ]
  %s = phi i32 [ %add, %loop ], [ 0, %entry ]
  %p = getelementptr inbounds i32, ptr %a, i32 %i
  %v = load i32, ptr %p, align 4
  %add = add nsw i32 %v, %s
  %inc = add nuw nsw i32 %i, 1
  %ec = icmp eq i32 %inc, %n
  br i1 %ec, label %exit, label %loop
exit:
  %r = phi i32 [ 0, %entry ], [ %add, %loop ]
  ret i32 %r
}

; Size builds must not grow: unrolling only ever adds instructions, so at
; -Os/-Oz (optsize) getUnrollingPreferences leaves the size-mode thresholds at
; zero and returns before enabling any unrolling. The loop stays rolled: one
; load, no remainder loop.
define i32 @sum_optsize(ptr nocapture readonly %a, i32 %n) optsize {
; CHECK-LABEL: @sum_optsize(
; CHECK:       load i32
; CHECK-NOT:   load i32
entry:
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %loop, label %exit
loop:
  %i = phi i32 [ %inc, %loop ], [ 0, %entry ]
  %s = phi i32 [ %add, %loop ], [ 0, %entry ]
  %p = getelementptr inbounds i32, ptr %a, i32 %i
  %v = load i32, ptr %p, align 4
  %add = add nsw i32 %v, %s
  %inc = add nuw nsw i32 %i, 1
  %ec = icmp eq i32 %inc, %n
  br i1 %ec, label %exit, label %loop
exit:
  %r = phi i32 [ 0, %entry ], [ %add, %loop ]
  ret i32 %r
}
