; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact < %s | FileCheck %s

; Constant-bit-position bit ops. bset/bxor/bclr/bmsk with a compile-time bit
; must select ONLY where it strictly saves an 8-byte LIMM (high bit / wide
; mask). Low bits stay on the already-optimal u6/s12 or/and forms.
; (Function names avoid the mnemonics so CHECK-NOT can't match a .size label.)

; --- set a high bit (bit 20) -> 1 instruction, no LIMM ---
define i32 @setbit_hi(i32 %a) {
; CHECK-LABEL: setbit_hi:
; CHECK: bset %r0, %r0, 20
; CHECK-NOT: limm
  %r = or i32 %a, 1048576
  ret i32 %r
}

; --- set low bit (bit 5) must STAY the u6 `or` form (byte-stable) ---
define i32 @setbit_lo(i32 %a) {
; CHECK-LABEL: setbit_lo:
; CHECK: or %r0, %r0, 32
; CHECK-NOT: bset %r
  %r = or i32 %a, 32
  ret i32 %r
}

; --- toggle a high bit (bit 24) ---
define i32 @togglebit_hi(i32 %a) {
; CHECK-LABEL: togglebit_hi:
; CHECK: bxor %r0, %r0, 24
; CHECK-NOT: limm
  %r = xor i32 %a, 16777216
  ret i32 %r
}

; --- clear a high bit (bit 20) -> and ~(1<<20) = -1048577 ---
define i32 @clearbit_hi(i32 %a) {
; CHECK-LABEL: clearbit_hi:
; CHECK: bclr %r0, %r0, 20
; CHECK-NOT: limm
  %r = and i32 %a, -1048577
  ret i32 %r
}

; --- low 12-bit mask 0xFFF (4095 > 2047) -> bit position 11 ---
define i32 @lowmask12(i32 %a) {
; CHECK-LABEL: lowmask12:
; CHECK: bmsk %r0, %r0, 11
; CHECK-NOT: limm
  %r = and i32 %a, 4095
  ret i32 %r
}

; --- must NOT steal the 16-bit width (extw / dedicated form handles 0xFFFF) ---
define i32 @width16(i32 %a) {
; CHECK-LABEL: width16:
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 65535
  ret i32 %r
}

; --- a 10-bit mask 0x3FF (1023 < 2048) already fits s12 AND: stays `and` ---
define i32 @lowmask10(i32 %a) {
; CHECK-LABEL: lowmask10:
; CHECK: and %r0, %r0, 1023
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 1023
  ret i32 %r
}
