; RUN: opt -mtriple=arceb-unknown-elf -mcpu=bcm55030 -passes=loop-unroll -S < %s \
; RUN:   | llc -O2 -mtriple=arceb-unknown-elf -mcpu=bcm55030 -verify-machineinstrs \
; RUN:   | FileCheck %s --implicit-check-not=%{{sp}}
;
; NB: the implicit-check-not pattern must be spelled %{{sp}}, not {{%sp}}. lit
; textually substitutes the token %s (the test path) before FileCheck ever sees
; the line, so {{%sp}} degrades into a regex matching the test path -- an
; assertion that can never fire. Writing the % outside the regex braces leaves
; no %s substring to substitute, and FileCheck still reads it as literal %sp.

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
;
; One of the four is the 16-bit compact LD_S (byte-verified: encoding 0x8243 =
; ld r2,[r2,0xC], the 4th array element), emitted because 16-bit compaction now
; runs at every optimization level -- hence the "_s" alternation. Do not
; re-narrow the pattern to plain "ld".
;
; The trailing CHECK-NOT/backedge pair pins all four loads inside ONE inner-loop
; body: without it the 4th match could drift into the epilogue loop and the test
; would still pass on a factor-3 unroll.
define i32 @sum(ptr nocapture readonly %a, i32 %n) {
; CHECK-LABEL: sum:
; CHECK:       This Inner Loop Header
; CHECK-COUNT-4: ld{{(\.as|_s)?}} %r{{[0-9]+}}, [
; CHECK-NOT:   This Inner Loop Header
; CHECK:       brne.d %r{{[0-9]+}}, %r{{[0-9]+}}, @.LBB{{[0-9_]+}}
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
