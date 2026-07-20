; RUN: llc -mtriple=arc -mcpu=generic < %s | FileCheck %s
;
; The bare CHECK prefix describes -mcpu=generic, which enables FeatureBitScan
; and therefore really does select fls.f/ffs.f -- keeping that coverage live
; matters, since those are the patterns whose absence used to crash isel with
; "Cannot select: ctlz_zero_undef" (see ctlz-cttz-zero-undef.ll).
;
; The ARC700 prefix covers the shipping ARC700 profiles, which have
; FeatureBitScan OFF but FeatureNORM ON, so CTLZ/CTTZ lower to a short
; lsr + norm sequence rather than to fls/ffs.
; RUN: llc -mtriple=arc   -mcpu=arc700   < %s | FileCheck %s --check-prefix=ARC700
; RUN: llc -mtriple=arceb -mcpu=arc700eb < %s | FileCheck %s --check-prefix=ARC700
; RUN: llc -mtriple=arceb -mcpu=bcm55030 < %s | FileCheck %s --check-prefix=ARC700

target triple = "arc"

declare i32 @llvm.ctlz.i32(i32, i1)
declare i32 @llvm.cttz.i32(i32, i1)
declare i64 @llvm.readcyclecounter()

; CHECK-LABEL: test_ctlz_i32:
; CHECK:       fls.f   %r0, %r0
; CHECK-NEXT:  mov.eq  %r0, 32
; CHECK-NEXT:  rsub.ne %r0, %r0, 31
; The -NOT pattern must be "fls.f", not a bare "fls"/"ffs": bare "ffs" matches
; the substring inside ".cfi_def_cfa_offset" and self-fails.
; ARC700-LABEL: test_ctlz_i32:
; ARC700-NOT:     fls{{[a-z_.]*}} %r
; ARC700:         breq %r0, 0, @[[Z:.LBB[0-9_]+]]
; ARC700:         lsr %r0, %r0, 1
; ARC700:         norm %r0, %r0
; ARC700:       [[Z]]:
; ARC700:         mov{{(_s)?}} %r0, 32
define i32 @test_ctlz_i32(i32 %x) {
  %a = call i32 @llvm.ctlz.i32(i32 %x, i1 false)
  ret i32 %a
}

; CHECK-LABEL: test_cttz_i32:
; CHECK:       ffs.f   %r0, %r0
; CHECK-NEXT:  mov.eq  %r0, 32
; x & -x isolates the lowest set bit, then norm counts it.
; ARC700-LABEL: test_cttz_i32:
; ARC700-NOT:     ffs{{[a-z_.]*}} %r
; ARC700:         rsub %r1, %r0, 0
; ARC700:         and_s %r0, %r1
; ARC700:         lsr %r0, %r0, 1
; ARC700:         norm %r0, %r0
; ARC700:         rsub %r0, %r0, 31
define i32 @test_cttz_i32(i32 %x) {
  %a = call i32 @llvm.cttz.i32(i32 %x, i1 false)
  ret i32 %a
}

; CHECK-LABEL: test_readcyclecounter:
; CHECK:       lr %r0, [33]
; CHECK-NEXT:  mov %r1, 0
; Which of r0/r1 holds the low i64 half flips with endianness (LE: lr into r0,
; BE: lr into r1), so the ARC700 prefix pins the AUX index and the zeroed other
; half rather than a fixed register assignment.
; ARC700-LABEL: test_readcyclecounter:
; ARC700:         lr %r{{[01]}}, [33]
; ARC700-NEXT:    mov{{(_s)?}} %r{{[01]}}, 0
define i64 @test_readcyclecounter() nounwind {
  %a = call i64 @llvm.readcyclecounter()
  ret i64 %a
}
