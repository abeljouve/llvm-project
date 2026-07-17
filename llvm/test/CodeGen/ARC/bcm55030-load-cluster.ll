; RUN: llc -O2 -mtriple=arceb-unknown-elf -mcpu=bcm55030 -verify-machineinstrs < %s | FileCheck %s

; Load-use latency hiding: the pre-RA machine scheduler carries a load-cluster
; mutation (ARCTargetMachine::createMachineScheduler) that groups neighbouring
; loads off the same base so each load's 10-cycle shadow can be filled by the
; other independent loads. The D-cache is disabled in the shipping config, so
; every load pays the full latency and this grouping is the dominant lever.
;
; The candidate set and the ordering guarantee live in
; ARCInstrInfo::getMemOperandsWithOffsetWidth / shouldClusterMemOps.

; Four independent word loads off one base, feeding a reduction. They must be
; emitted back-to-back (clustered) ahead of the dependent adds, not interleaved
; ld/add/ld/add.
define i32 @gather(ptr %in) {
; CHECK-LABEL: gather:
; CHECK:       ld  %r{{[0-9]+}}, [%r0,0]
; CHECK-NEXT:  ld  %r{{[0-9]+}}, [%r0,4]
; CHECK-NEXT:  ld  %r{{[0-9]+}}, [%r0,8]
; CHECK-NEXT:  ld  %r{{[0-9]+}}, [%r0,12]
; CHECK-NEXT:  add
entry:
  %p0 = getelementptr inbounds i32, ptr %in, i32 0
  %v0 = load i32, ptr %p0, align 4
  %p1 = getelementptr inbounds i32, ptr %in, i32 1
  %v1 = load i32, ptr %p1, align 4
  %p2 = getelementptr inbounds i32, ptr %in, i32 2
  %v2 = load i32, ptr %p2, align 4
  %p3 = getelementptr inbounds i32, ptr %in, i32 3
  %v3 = load i32, ptr %p3, align 4
  %a = add i32 %v0, %v1
  %b = add i32 %a, %v2
  %c = add i32 %b, %v3
  ret i32 %c
}

; HAZARD: a volatile/MMIO access must never be reordered or clustered -- its
; order is a real hardware contract on this chip's peripherals. The refusal
; lives in getMemOperandsWithOffsetWidth (hasOrderedMemoryRef returns the
; candidate to the caller as "not a memop"), the same discipline
; ARCOptAddrMode applies. These interleaved volatile loads and stores must stay
; in exact program order: ld,st,ld,st,ld,st,ld,st -- NEVER four loads hoisted
; together the way @gather above is clustered.
define void @mmio(ptr %in, ptr %out) {
; CHECK-LABEL: mmio:
; CHECK:       ld  %r{{[0-9]+}}, [%r0,0]
; CHECK-NEXT:  st  %r{{[0-9]+}}, [%r1,0]
; CHECK-NEXT:  ld  %r{{[0-9]+}}, [%r0,4]
; CHECK-NEXT:  st  %r{{[0-9]+}}, [%r1,0]
; CHECK-NEXT:  ld  %r{{[0-9]+}}, [%r0,8]
; CHECK-NEXT:  st  %r{{[0-9]+}}, [%r1,0]
; CHECK-NEXT:  ld  %r{{[0-9]+}}, [%r0,12]
; CHECK-NEXT:  st  %r{{[0-9]+}}, [%r1,0]
entry:
  %p0 = getelementptr inbounds i32, ptr %in, i32 0
  %v0 = load volatile i32, ptr %p0, align 4
  store volatile i32 %v0, ptr %out, align 4
  %p1 = getelementptr inbounds i32, ptr %in, i32 1
  %v1 = load volatile i32, ptr %p1, align 4
  store volatile i32 %v1, ptr %out, align 4
  %p2 = getelementptr inbounds i32, ptr %in, i32 2
  %v2 = load volatile i32, ptr %p2, align 4
  store volatile i32 %v2, ptr %out, align 4
  %p3 = getelementptr inbounds i32, ptr %in, i32 3
  %v3 = load volatile i32, ptr %p3, align 4
  store volatile i32 %v3, ptr %out, align 4
  ret void
}
