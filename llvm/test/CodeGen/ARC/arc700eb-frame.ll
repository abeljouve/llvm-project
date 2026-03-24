; RUN: llc -march=arceb -mcpu=arc700eb < %s | FileCheck %s

; Frame lowering and calling convention tests for ARC700 big-endian

define i32 @test_frame_simple(i32 %a) {
; CHECK-LABEL: test_frame_simple:
; CHECK: push_s %blink
; CHECK: bl @callee
; CHECK: pop_s %blink
; CHECK: j_s [%blink]
  %r = call i32 @callee(i32 %a)
  ret i32 %r
}

declare i32 @callee(i32)

define i32 @test_callee_saved(i32 %n) {
; CHECK-LABEL: test_callee_saved:
; CHECK: push_s %blink
; CHECK: st %r13
; CHECK: ld %r13
; CHECK: pop_s %blink
entry:
  %r = call i32 @callee(i32 %n)
  %r2 = call i32 @callee(i32 %r)
  %sum = add i32 %r, %r2
  ret i32 %sum
}

define i32 @test_many_args(i32 %a, i32 %b, i32 %c, i32 %d,
                           i32 %e, i32 %f, i32 %g, i32 %h) {
; CHECK-LABEL: test_many_args:
; First 8 args in r0-r7
; CHECK: add %r0, %r0, %r1
  %s1 = add i32 %a, %b
  %s2 = add i32 %c, %d
  %s3 = add i32 %e, %f
  %s4 = add i32 %g, %h
  %s5 = add i32 %s1, %s2
  %s6 = add i32 %s3, %s4
  %s7 = add i32 %s5, %s6
  ret i32 %s7
}
