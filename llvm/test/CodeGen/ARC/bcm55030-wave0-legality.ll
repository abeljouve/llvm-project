; RUN: llc -march=arceb -mcpu=bcm55030 < %s | FileCheck %s

; Wave 0 backend-correctness regression test for the -mcpu=bcm55030 profile.
; Covers three negative-legality facts established by silicon
; characterization (docs/notes/isa-characterization.md) that the codegen
; must never violate:
;
;   1. llvm.bswap.i32 must never select `swape` (ARCv2-only full-32-bit
;      byte-reversal; ABSENT on this ARC700 integration -- no encoding on
;      ARC700, traps as illegal on ARCv2 word-mode). It must lower to a
;      mask/shift/or sequence, with the halfword swap done by the real
;      `swap` instruction (SWAP_BUILD=1 on silicon).
;   2. llvm.abs.i32 selects the native `abs` instruction (non-saturating,
;      ABS(INT_MIN)=INT_MIN per silicon characterization).
;   3. A misaligned (align 1) i32 load/store must never be legalized to a
;      single misaligned word `ld`/`st` -- silicon silently clears the low
;      address bits instead of trapping or byte-fixing up (`effective
;      address = address & ~3`), which is silent corruption. It must peel
;      into byte-wise `ldb`/`stb` accesses instead.

declare i32 @llvm.bswap.i32(i32)
declare i32 @llvm.abs.i32(i32, i1)

define i32 @bswap32(i32 %a) {
; CHECK-LABEL: bswap32:
; CHECK-NOT: swape
; CHECK: lsr
; CHECK: and
; CHECK: and
; CHECK: asl
; CHECK: or
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

define i32 @load_i32_align1(ptr %p) {
; CHECK-LABEL: load_i32_align1:
; CHECK-NOT: ld{{[[:space:]]}}
; CHECK: ldb
; CHECK: ldb
; CHECK: ldb
; CHECK: ldb
; CHECK-NOT: ld{{[[:space:]]}}
; CHECK: j_s
  %v = load i32, ptr %p, align 1
  ret i32 %v
}

define void @store_i32_align1(ptr %p, i32 %v) {
; CHECK-LABEL: store_i32_align1:
; CHECK-NOT: st{{[[:space:]]}}
; CHECK: stb
; CHECK: stb
; CHECK: stb
; CHECK: stb
; CHECK-NOT: st{{[[:space:]]}}
; CHECK: j_s
  store i32 %v, ptr %p, align 1
  ret void
}
