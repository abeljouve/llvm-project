; RUN: llc -march=arceb -mcpu=arc700eb < %s | FileCheck %s

; Basic ALU operations on ARC700 big-endian

define i32 @test_add(i32 %a, i32 %b) {
; CHECK-LABEL: test_add:
; CHECK: add %r0, %r0, %r1
  %c = add i32 %a, %b
  ret i32 %c
}

define i32 @test_sub(i32 %a, i32 %b) {
; CHECK-LABEL: test_sub:
; CHECK: sub %r0, %r0, %r1
  %c = sub i32 %a, %b
  ret i32 %c
}

define i32 @test_and(i32 %a, i32 %b) {
; CHECK-LABEL: test_and:
; CHECK: and %r0, %r0, %r1
  %c = and i32 %a, %b
  ret i32 %c
}

define i32 @test_or(i32 %a, i32 %b) {
; CHECK-LABEL: test_or:
; CHECK: or %r0, %r0, %r1
  %c = or i32 %a, %b
  ret i32 %c
}

define i32 @test_xor(i32 %a, i32 %b) {
; CHECK-LABEL: test_xor:
; CHECK: xor %r0, %r0, %r1
  %c = xor i32 %a, %b
  ret i32 %c
}

define i32 @test_shl(i32 %a, i32 %b) {
; CHECK-LABEL: test_shl:
; CHECK: asl %r0, %r0, %r1
  %c = shl i32 %a, %b
  ret i32 %c
}

define i32 @test_lshr(i32 %a, i32 %b) {
; CHECK-LABEL: test_lshr:
; CHECK: lsr %r0, %r0, %r1
  %c = lshr i32 %a, %b
  ret i32 %c
}

define i32 @test_ashr(i32 %a, i32 %b) {
; CHECK-LABEL: test_ashr:
; CHECK: asr %r0, %r0, %r1
  %c = ashr i32 %a, %b
  ret i32 %c
}

define i32 @test_add_imm(i32 %a) {
; CHECK-LABEL: test_add_imm:
; CHECK: add %r0, %r0, 42
  %c = add i32 %a, 42
  ret i32 %c
}

define i32 @test_load(ptr %p) {
; CHECK-LABEL: test_load:
; CHECK: ld %r0, [%r0,0]
  %v = load i32, ptr %p
  ret i32 %v
}

define void @test_store(ptr %p, i32 %v) {
; CHECK-LABEL: test_store:
; CHECK: st %r1, [%r0,0]
  store i32 %v, ptr %p
  ret void
}

define void @test_call(i32 %x) {
; CHECK-LABEL: test_call:
; CHECK: bl @external_func
  call void @external_func(i32 %x)
  ret void
}

declare void @external_func(i32)

define i32 @test_ret(i32 %x) {
; CHECK-LABEL: test_ret:
; CHECK: j_s [%blink]
  ret i32 %x
}
