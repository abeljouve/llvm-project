; RUN: llc -mtriple=arceb-unknown-elf -mattr=+arcompact,+norm < %s | FileCheck %s

; On an ARC700 core without the 32x32 multiplier (MPY off), `mul x, C` for a
; constant C of the form 2^N +/- 2^M must strength-reduce to shift + add/sub
; instead of a `bl __mulsi3` libcall. The decomposeMulByConstant hook must
; mirror the generic DAGCombiner::visitMUL decomposition, which strips the
; trailing-zero 2^M factor before testing 2^N +/- 1 -- so C=12,6,20,40,... are
; covered, not just the single-term 2^N +/- 1 shapes. Regression: a per-iter
; `bl __mulsi3` on a u8 induction variable in a hot uncached-read loop.

; CHECK-LABEL: mul12_wide:
; CHECK-NOT: __mulsi3
; CHECK: asl %r1, %r0, 3
; CHECK: add2 %r0, %r1, %r0
define i32 @mul12_wide(i32 %x) {
  %m = mul i32 %x, 12
  ret i32 %m
}

; The narrow (zext i8) multiplicand must decompose identically -- this is the
; exact shape that survived LSR and hit the libcall before the fix.
; CHECK-LABEL: mul12_narrow:
; CHECK-NOT: __mulsi3
; CHECK: asl %r1, %r0, 3
; CHECK: add2 %r0, %r1, %r0
define i32 @mul12_narrow(i8 zeroext %i) {
  %z = zext i8 %i to i32
  %m = mul i32 %z, 12
  ret i32 %m
}

; CHECK-LABEL: mul6:
; CHECK-NOT: __mulsi3
; CHECK: asl %r1, %r0, 2
; CHECK: add1 %r0, %r1, %r0
define i32 @mul6(i32 %x) {
  %m = mul i32 %x, 6
  ret i32 %m
}

; CHECK-LABEL: mul40:
; CHECK-NOT: __mulsi3
; CHECK: asl %r1, %r0, 5
; CHECK: add3 %r0, %r1, %r0
define i32 @mul40(i32 %x) {
  %m = mul i32 %x, 40
  ret i32 %m
}

; 2^N - 1 shape stays shift + sub (was already handled).
; CHECK-LABEL: mul7:
; CHECK-NOT: __mulsi3
; CHECK: asl %r1, %r0, 3
; CHECK: sub %r0, %r1, %r0
define i32 @mul7(i32 %x) {
  %m = mul i32 %x, 7
  ret i32 %m
}

; A constant with 3 set bits (11 = 0b1011) is not a <=2-op shift-add and
; correctly keeps the libcall -- the fix must not over-fire.
; CHECK-LABEL: mul11:
; CHECK: __mulsi3
define i32 @mul11(i32 %x) {
  %m = mul i32 %x, 11
  ret i32 %m
}

; A genuine variable multiply must still lower to the libcall.
; CHECK-LABEL: mul_var:
; CHECK: __mulsi3
define i32 @mul_var(i32 %a, i32 %b) {
  %m = mul i32 %a, %b
  ret i32 %m
}
