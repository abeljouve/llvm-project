; RUN: llc -mtriple=arc -mcpu=generic < %s | FileCheck %s
;
; The bare CHECK prefix describes -mcpu=generic. A bare -mtriple=arc with no
; -mcpu selects a featureless pseudo-subtarget matching no shipping
; configuration (no MPY/SEXT/BitScan, so not `generic`; no ARCompact, so
; ARCSizeReduction never runs, so not arc700 either). Its output for this test
; is byte-identical to generic, so naming the real CPU loses no coverage.
;
; The RUN lines below extend the SAME prefix to the three shipping ARC700
; profiles, deliberately without splitting. The property under test is that no
; ARC subtarget has native atomics, so every atomic becomes an __atomic_*
; libcall -- that is true of all four configurations for the same reason, and
; it is exactly the property that must hold on real silicon. The ARC700 output
; does differ in the surrounding spill code (compact ST_S/LD_S/MOV_S), but no
; assertion here observes that, so a second prefix would assert nothing extra.
; RUN: llc -mtriple=arc   -mcpu=arc700   < %s | FileCheck %s
; RUN: llc -mtriple=arceb -mcpu=arc700eb < %s | FileCheck %s
; RUN: llc -mtriple=arceb -mcpu=bcm55030 < %s | FileCheck %s

; Native atomics are unsupported, so all are oversize.
define void @test(ptr %a) nounwind {
; CHECK-LABEL: test:
; CHECK: bl @__atomic_load_1
; CHECK: bl @__atomic_store_1
  %1 = load atomic i8, ptr %a seq_cst, align 16
  store atomic i8 %1, ptr %a seq_cst, align 16
  ret void
}
