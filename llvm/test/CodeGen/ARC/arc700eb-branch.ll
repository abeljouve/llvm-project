; RUN: llc -march=arceb -mcpu=arc700eb < %s | FileCheck %s

; Branch and comparison tests for ARC700 big-endian

define i32 @test_branch_eq(i32 %a, i32 %b) {
; CHECK-LABEL: test_branch_eq:
; CHECK: br{{eq|ne}} %r0, %r1
entry:
  %cmp = icmp eq i32 %a, %b
  br i1 %cmp, label %iftrue, label %iffalse

iftrue:
  ret i32 1

iffalse:
  ret i32 0
}

define i32 @test_branch_ne(i32 %a, i32 %b) {
; CHECK-LABEL: test_branch_ne:
; CHECK: br{{eq|ne}} %r0, %r1
entry:
  %cmp = icmp ne i32 %a, %b
  br i1 %cmp, label %iftrue, label %iffalse

iftrue:
  ret i32 1

iffalse:
  ret i32 0
}

define i32 @test_branch_lt(i32 %a, i32 %b) {
; CHECK-LABEL: test_branch_lt:
; CHECK: br{{lt|ge}} %r0, %r1
entry:
  %cmp = icmp slt i32 %a, %b
  br i1 %cmp, label %iftrue, label %iffalse

iftrue:
  ret i32 1

iffalse:
  ret i32 0
}

define i32 @test_cmp(i32 %a, i32 %b) {
; CHECK-LABEL: test_cmp:
; CHECK: cmp_s %r0, %r1
  %cmp = icmp sgt i32 %a, %b
  br i1 %cmp, label %iftrue, label %iffalse

iftrue:
  ret i32 %a

iffalse:
  ret i32 %b
}
