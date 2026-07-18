; RUN: llc -march=arceb -mcpu=bcm55030 < %s | FileCheck %s

; ABS is a single ARCompact instruction (abs) and must be kept Legal so the
; existing td patterns select it instead of the generic expansion.
;
; BSWAP has no single-instruction ARCompact form on the BCM55030 ARC700
; profile: `swape` is an ARCv2-only full-32-bit byte-reversal encoding that
; is ABSENT here (silicon characterization: no ARC700 encoding; traps as an
; illegal instruction on ARCv2 word-mode). FeatureSwape stays OFF for every
; current Proc (see ARC.td), so BSWAP is Custom-lowered to a mask/shift/or
; byte-swap sequence, with the final 16-bit half-swap done by the real
; `swap` instruction (SWAP_BUILD=1 on silicon), never `swape`.

declare i32 @llvm.bswap.i32(i32)
declare i32 @llvm.abs.i32(i32, i1)

define i32 @bswap32(i32 %a) {
; CHECK-LABEL: bswap32:
; CHECK: lsr [[T0:%r[0-9]+]], %r0, 8
; CHECK: and [[T1:%r[0-9]+]], [[T0]], 16711935
; CHECK: and [[T2:%r[0-9]+]], %r0, 16711935
; CHECK: asl [[T3:%r[0-9]+]], [[T2]], 8
; CHECK: or_s %r0, [[T1]]
; CHECK: swap %r0, %r0
; CHECK-NOT: swape
  %r = call i32 @llvm.bswap.i32(i32 %a)
  ret i32 %r
}

define i32 @abs32(i32 %a) {
; CHECK-LABEL: abs32:
; CHECK: abs %r0, %r0
; CHECK-NOT: max
  %r = call i32 @llvm.abs.i32(i32 %a, i1 false)
  ret i32 %r
}

; Hand-written abs idiom: (x < 0) ? -x : x
define i32 @abs_idiom(i32 %a) {
; CHECK-LABEL: abs_idiom:
; CHECK: abs %r0, %r0
  %neg = sub i32 0, %a
  %c = icmp slt i32 %a, 0
  %r = select i1 %c, i32 %neg, i32 %a
  ret i32 %r
}
