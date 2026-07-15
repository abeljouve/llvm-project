; RUN: llc -mtriple=arceb-unknown-elf -mattr=+arcompact,+norm < %s | FileCheck %s

; On an ARC700 core without the 32x32 multiplier (MPY off), `mul x, C` must
; strength-reduce to a bounded chain of add/sub/asl/add1-3/sub1-3 instead of
; a `bl __mulsi3` libcall whenever a cheap-enough sequence exists. This is
; performMULCombine's bounded scaled-add synthesizer (a target DAG combine
; on ISD::MUL), which SUBSUMES the old decomposeMulByConstant hook -- see
; docs/llvm-arc700-optimizations/02-constant-multiplication.md. It covers
; every constant the old 2-term "2^N +/- 2^M after stripping trailing
; zeros" predicate used to accept (C=12,6,20,40,... below), generally with
; an EQUAL-OR-BETTER instruction count (e.g. mul12 drops from 3 raw
; instructions to 2, since the old generic decomposition built two
; independent SHL nodes that could never match the ADD1/2/3 fused pattern),
; and ALSO covers three-set-bit constants like 11/13/97 that the old hook
; could never express (mul11 was a `bl __mulsi3` before this change).
; Regression: a per-iter `bl __mulsi3` on a u8 induction variable in a hot
; uncached-read loop.

; CHECK-LABEL: mul12_wide:
; CHECK-NOT: __mulsi3
; CHECK: add1 %r0, %r0, %r0
; CHECK: asl %r0, %r0, 2
define i32 @mul12_wide(i32 %x) {
  %m = mul i32 %x, 12
  ret i32 %m
}

; The narrow (zext i8) multiplicand must decompose identically -- this is the
; exact shape that survived LSR and hit the libcall before the original fix.
; CHECK-LABEL: mul12_narrow:
; CHECK-NOT: __mulsi3
; CHECK: add1 %r0, %r0, %r0
; CHECK: asl %r0, %r0, 2
define i32 @mul12_narrow(i8 zeroext %i) {
  %z = zext i8 %i to i32
  %m = mul i32 %z, 12
  ret i32 %m
}

; CHECK-LABEL: mul6:
; CHECK-NOT: __mulsi3
; CHECK: add1 %r0, %r0, %r0
; CHECK: asl %r0, %r0, 1
define i32 @mul6(i32 %x) {
  %m = mul i32 %x, 6
  ret i32 %m
}

; CHECK-LABEL: mul40:
; CHECK-NOT: __mulsi3
; CHECK: add2 %r0, %r0, %r0
; CHECK: asl %r0, %r0, 3
define i32 @mul40(i32 %x) {
  %m = mul i32 %x, 40
  ret i32 %m
}

; 2^N - 1 shape (7 = 2^3 - 1) stays a 2-instruction sequence, now via the
; SUB3 self-peel branch (t = -x; t - (t<<3) = -x*(1-8) = 7x) instead of the
; old asl+sub pair -- same instruction count, different (still correct)
; encoding.
; CHECK-LABEL: mul7:
; CHECK-NOT: __mulsi3
; CHECK: rsub %r0, %r0, 0
; CHECK: sub3 %r0, %r0, %r0
define i32 @mul7(i32 %x) {
  %m = mul i32 %x, 7
  ret i32 %m
}

; A constant with 3 set bits (11 = 0b1011) is NOT a <=2-term shift-add shape
; the old decomposeMulByConstant predicate could express, but the bounded
; search finds 11x = ADD1(ADD3(x,x),x) = (9x)+2x -- two scaled-add
; instructions, no libcall. This is the dossier's flagship "x*11" example.
; CHECK-LABEL: mul11:
; CHECK-NOT: __mulsi3
; CHECK: add3 %r1, %r0, %r0
; CHECK: add1 %r0, %r1, %r0
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
