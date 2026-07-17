; RUN: opt -mtriple=arceb-unknown-elf -mcpu=bcm55030 -passes=loop-unroll -S < %s \
; RUN:   | llc -O2 -mtriple=arceb-unknown-elf -mcpu=bcm55030 -verify-machineinstrs \
; RUN:   | FileCheck %s --implicit-check-not={{%sp}}

; End-to-end load-use latency hiding (dossier 20): getUnrollingPreferences
; unrolls the reduction to factor 4, and the load-cluster scheduler mutation
; groups the four independent loads so the recurrence no longer serializes on
; each load's 10-cycle shadow.
;
; The register-pressure bound is load-bearing: on this core the D-cache is
; disabled, so a spill is an uncached 10-clock load and would defeat the whole
; optimization. UP.MaxCount = 8 keeps the peak live-temp count (~ factor + 3)
; far under the empirical spill cliff (22 simultaneously-live temps against 26
; allocatable GPRs). At factor 4 the loop must touch NO stack at all -- the
; whole-output --implicit-check-not=%sp asserts exactly that: no spill slot, no
; frame, no reload.

; Four loads in the unrolled main-loop body prove the factor-4 unroll survived
; to machine code; the epilogue carries the scalar remainder's single load.
define i32 @sum(ptr nocapture readonly %a, i32 %n) {
; CHECK-LABEL: sum:
; CHECK:       This Inner Loop Header
; CHECK-COUNT-4: ld{{(\.as)?}}  %r{{[0-9]+}}, [
; CHECK:       add
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
