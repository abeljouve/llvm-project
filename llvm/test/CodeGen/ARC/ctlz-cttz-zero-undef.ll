; RUN: llc -mtriple=arceb-unknown-elf -mcpu=generic  < %s | FileCheck %s --check-prefix=GENERIC
; RUN: llc -mtriple=arceb-unknown-elf -mcpu=bcm55030 < %s | FileCheck %s --check-prefix=SILICON
; RUN: llc -march=arceb -mcpu=arc700eb               < %s | FileCheck %s --check-prefix=SILICON
;
; The bit-scan opcodes fls/ffs are ARCv2-only; they trap as illegal on the
; ARC700 profiles, so they MUST NEVER appear for those subtargets:
; RUN: llc -mtriple=arceb-unknown-elf -mcpu=bcm55030 < %s | not grep -wE 'fls|ffs'
; RUN: llc -march=arceb -mcpu=arc700eb               < %s | not grep -wE 'fls|ffs'

; CTLZ_ZERO_UNDEF / CTTZ_ZERO_UNDEF must keep their action in lockstep with the
; predicate on the only selection patterns able to cover them. On the bit-scan
; subtarget (generic) TargetLowering marks these Legal, but the CTLZ/CTTZ
; pseudos in ARCInstrInfo.td only match the zero-DEFINED generic nodes. Without
; a Pat mapping the zero-UNDEF nodes onto those pseudos, isel hits a hard
; "LLVM ERROR: Cannot select: i32 = ctlz_zero_undef". The DAG combiner rewrites
; even a zero-DEFINED ctlz/cttz into the zero-undef node once it is Legal, so on
; the bit-scan subtarget every ctlz/cttz took this crash before the fix.
;
; The zero-UNDEF nodes are covered by the same pseudos because fls/ffs give a
; fully defined answer for a zero input -- a valid (over-)implementation of the
; "don't-care on zero" contract.
;
; The ARC700 profiles (bcm55030 / arc700eb) lack bit-scan and Custom-lower these
; through the norm-based sequence instead -- exercised here to prove the new
; patterns are gated behind HasBitScan and do not perturb the silicon target.

declare i32 @llvm.ctlz.i32(i32, i1)
declare i32 @llvm.cttz.i32(i32, i1)

define i32 @ctlz_zu(i32 %x) {
; GENERIC-LABEL: ctlz_zu:
; GENERIC: fls.f %r0, %r0
;
; SILICON-LABEL: ctlz_zu:
; SILICON: norm %r0, %r0
  %a = call i32 @llvm.ctlz.i32(i32 %x, i1 true)
  ret i32 %a
}

define i32 @cttz_zu(i32 %x) {
; GENERIC-LABEL: cttz_zu:
; GENERIC: ffs.f %r0, %r0
;
; SILICON-LABEL: cttz_zu:
; SILICON: norm
  %a = call i32 @llvm.cttz.i32(i32 %x, i1 true)
  ret i32 %a
}
