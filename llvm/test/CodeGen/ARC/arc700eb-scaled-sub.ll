; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact < %s | FileCheck %s

; Scaled-subtract: a - (b << {1,2,3}) must select the single SUB1/SUB2/SUB3
; instruction (previously fell back to a separate `asl` + `sub` pair).

define i32 @sub1(i32 %a, i32 %b) {
; CHECK-LABEL: sub1:
; CHECK: sub1 %r0, %r0, %r1
; CHECK-NOT: asl
  %s = shl i32 %b, 1
  %r = sub i32 %a, %s
  ret i32 %r
}

define i32 @sub2(i32 %a, i32 %b) {
; CHECK-LABEL: sub2:
; CHECK: sub2 %r0, %r0, %r1
; CHECK-NOT: asl
  %s = shl i32 %b, 2
  %r = sub i32 %a, %s
  ret i32 %r
}

define i32 @sub3(i32 %a, i32 %b) {
; CHECK-LABEL: sub3:
; CHECK: sub3 %r0, %r0, %r1
; CHECK-NOT: asl
  %s = shl i32 %b, 3
  %r = sub i32 %a, %s
  ret i32 %r
}
