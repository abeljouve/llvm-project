; RUN: llc -mtriple=arceb -mcpu=arc700eb -show-mc-encoding < %s | FileCheck %s

; Encodings of the llvm.arc.lr / llvm.arc.sr immediate forms. The u6 form
; covers aux 0..63, the s12 form 64..2047. s12 holds S[5:0] in bits [11:6]
; and S[11:6] in bits [5:0]; the B register is split, B[2:0] in bits [26:24]
; and B[5:3] in bits [14:12].

declare i32 @llvm.arc.lr(i32)
declare void @llvm.arc.sr(i32, i32)

; CHECK-LABEL: aux_s12:
; CHECK: sr %r1, [72] ; encoding: [0x21,0xab,0x02,0x01]
; CHECK: sr %r1, [3] ; encoding: [0x21,0x6b,0x00,0xc0]
; CHECK: lr %r1, [71] ; encoding: [0x21,0xaa,0x01,0xc1]
define i32 @aux_s12(i32 %a, i32 %v) {
  call void @llvm.arc.sr(i32 %v, i32 72)
  call void @llvm.arc.sr(i32 %v, i32 3)
  %x = call i32 @llvm.arc.lr(i32 71)
  %y = add i32 %x, %a
  ret i32 %y
}
