; RUN: llc -mtriple=arc -mcpu=generic < %s | FileCheck %s
;
; The bare CHECK prefix describes -mcpu=generic. A bare -mtriple=arc with no
; -mcpu selects a featureless pseudo-subtarget matching no shipping
; configuration (no MPY/SEXT/BitScan, so not `generic`; no ARCompact, so
; ARCSizeReduction never runs, so not arc700 either). Its output for this test
; is byte-identical to generic, so pinning the real CPU loses no coverage.
;
; The ARC700 prefixes cover the shipping ARC700 profiles, where argument setup
; fuses into the 16-bit ARCompact MOV_S for r0-r3 (MOV_S has no encoding for
; r4-r7, which stay 32-bit) and the call gets a filled delay slot.
;
; i64 argument and return halves are assigned by endianness, so the register
; that holds each half flips between the LE and BE profiles. That is real
; ABI-visible behaviour and is pinned per-endianness rather than wildcarded
; away, hence the split ARC700LE / ARC700BE sub-prefixes.
; RUN: llc -mtriple=arc   -mcpu=arc700   < %s | FileCheck %s --check-prefixes=ARC700,ARC700LE
; RUN: llc -mtriple=arceb -mcpu=arc700eb < %s | FileCheck %s --check-prefixes=ARC700,ARC700BE
; RUN: llc -mtriple=arceb -mcpu=bcm55030 < %s | FileCheck %s --check-prefixes=ARC700,ARC700BE


declare i32 @goo1(i32) nounwind

; CHECK-LABEL: call1
; CHECK: bl @goo1
;
; ARC700-LABEL: call1:
; ARC700: bl @goo1
define i32 @call1(i32 %a) nounwind {
entry:
  %x = call i32 @goo1(i32 %a)
  ret i32 %x
}

declare i32 @goo2(i32, i32, i32, i32, i32, i32, i32, i32) nounwind

; CHECK-LABEL: call2
; CHECK-DAG: mov %r0, 0
; CHECK-DAG: mov %r1, 1
; CHECK-DAG: mov %r2, 2
; CHECK-DAG: mov %r3, 3
; CHECK-DAG: mov %r4, 4
; CHECK-DAG: mov %r5, 5
; CHECK-DAG: mov %r6, 6
; CHECK-DAG: mov %r7, 7
; CHECK: bl @goo2
;
; MOV_S covers r0-r3 only; r4-r7 have no compact encoding and stay 32-bit --
; that asymmetry is the discriminator here, since generic emits the 32-bit mov
; for all eight. The bl is part of the unordered group rather than anchored
; after it: on ARC700 the call takes a filled delay slot, so bl.d is emitted
; *before* the final argument mov that executes in that slot.
; ARC700-LABEL: call2:
; ARC700-DAG:  mov_s %r0, 0
; ARC700-DAG:  mov_s %r1, 1
; ARC700-DAG:  mov_s %r2, 2
; ARC700-DAG:  mov_s %r3, 3
; ARC700-DAG:  mov %r4, 4
; ARC700-DAG:  mov %r5, 5
; ARC700-DAG:  mov %r6, 6
; ARC700-DAG:  mov %r7, 7
; ARC700-DAG:  bl{{(\.d)?}} @goo2
define i32 @call2() nounwind {
entry:
  %x = call i32 @goo2(i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7)
  ret i32 %x
}

declare i32 @goo3(i64, i32, i64) nounwind
; call goo3(0xEEEEEEEE77777777, 0x55555555, 0xAAAAAAAA33333333)
; 0xEEEEEEEE == -286331154
; 0x77777777 == 2004318071
; 0x55555555 == 1431655765
; 0xAAAAAAAA == -1431655766
; 0x33333333 == 858993459
; CHECK-LABEL: call3
; CHECK-DAG: mov %r0, 2004318071
; CHECK-DAG: mov %r1, -286331154
; CHECK-DAG: mov %r2, 1431655765
; CHECK-DAG: mov %r3, 858993459
; CHECK-DAG: mov %r4, -1431655766
; CHECK: bl @goo3
;
; The i64 halves swap registers with endianness: LE puts the low word in the
; even register, BE puts the high word there.
; ARC700-LABEL: call3:
; ARC700LE-DAG: mov %r0, 2004318071
; ARC700LE-DAG: mov %r1, -286331154
; ARC700LE-DAG: mov %r3, 858993459
; ARC700LE-DAG: mov %r4, -1431655766
; ARC700BE-DAG: mov %r0, -286331154
; ARC700BE-DAG: mov %r1, 2004318071
; ARC700BE-DAG: mov %r3, -1431655766
; ARC700BE-DAG: mov %r4, 858993459
; ARC700-DAG:   mov %r2, 1431655765
; ARC700:       bl @goo3
define i32 @call3() nounwind {
entry:
  %x = call i32 @goo3(i64 17216961133457930103,
                      i32 1431655765,
                      i64 12297829380468716339)
  ret i32 %x
}

declare i64 @goo4()

; 64-bit values are returned in r0r1
; CHECK-LABEL: call4
; CHECK: bl @goo4
; CHECK: lsr %r0, %r1, 16
;
; Bits 48..63 of the returned i64 live in the high-order half register, which
; is r1 on LE and r0 on BE.
; ARC700-LABEL: call4:
; ARC700:       bl @goo4
; ARC700LE:     lsr %r0, %r1, 16
; ARC700BE:     lsr %r0, %r0, 16
define i32 @call4() nounwind {
  %x = call i64 @goo4()
  %v1 = lshr i64 %x, 48
  %v = trunc i64 %v1 to i32
  ret i32 %v
}

; 0x0000ffff00ff00ff=281470698455295
; returned as r0=0x00ff00ff=16711935, r1=0x0000ffff=65535
; CHECK-LABEL: ret1
; CHECK-DAG: mov %r1, 65535
; CHECK-DAG: mov %r0, 16711935
;
; ARC700-LABEL: ret1:
; ARC700LE-DAG: mov %r0, 16711935
; ARC700LE-DAG: mov %r1, 65535
; ARC700BE-DAG: mov %r0, 65535
; ARC700BE-DAG: mov %r1, 16711935
define i64 @ret1() nounwind {
  ret i64 281470698455295
}

@funcptr = external global ptr, align 4
; Indirect calls use JL
; CHECK-LABEL: call_indirect
; CHECK-DAG: ld %r[[REG:[0-9]+]], [@funcptr]
; CHECK-DAG: mov %r0, 12
; CHECK:     jl [%r[[REG]]]
;
; ARC700-LABEL: call_indirect:
; ARC700-NOT:   mov %r0, 12
; ARC700-DAG:   ld %r[[AREG:[0-9]+]], [@funcptr]
; ARC700-DAG:   mov_s %r0, 12
; ARC700:       jl [%r[[AREG]]]
define i32 @call_indirect(i32 %x) nounwind {
  %f = load ptr, ptr @funcptr, align 4
  %call = call i32 %f(i32 12)
  %add = add nsw i32 %call, %x
  ret i32 %add
}

