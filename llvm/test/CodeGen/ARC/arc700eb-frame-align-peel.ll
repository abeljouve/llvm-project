; RUN: llc -march=arceb -mcpu=bcm55030 < %s | FileCheck %s

; The positive counterpart to the arc700eb-frame-misaligned-*.ll tests: this is
; what the SAME misaligned frame address must compile to when the IR tells the
; truth about it, and it must compile cleanly.
;
; The distinction is the whole point of the guard. Honest IR (`align 1`) makes
; TargetLoweringBase::allowsMemoryAccessForAlignment consult
; ARCTargetLowering::allowsMisalignedMemoryAccesses, which reports every
; misaligned multi-byte access as neither legal nor fast, so SelectionDAG
; legalization peels the access into byte loads long before an LD_rs9 can be
; selected. Nothing reaches the guard, and the emitted big-endian byte assembly
; reads the intended bytes on silicon.
;
; Lying IR (`align 4` on the same address) skips that hook entirely and reaches
; the guard, which rejects it. So the fix for a rejected access is to correct
; the alignment claim at the source -- a packed struct, __builtin_memcpy, or an
; explicit byte-assembly accessor -- and this test pins the good codegen that
; results.

declare void @escape(ptr)

; Honest under-aligned word read at a 3 (mod 4) frame address: peeled to four
; byte loads, assembled big-endian. No diagnostic.
define i32 @underaligned_word_peel() {
; CHECK-LABEL: underaligned_word_peel:
; CHECK: ldb
; CHECK: ldb
; CHECK: ldb
; CHECK: ldb
  %ctx = alloca [16 x i8], align 4
  call void @escape(ptr %ctx)
  %p = getelementptr inbounds i8, ptr %ctx, i32 3
  %v = load i32, ptr %p, align 1
  ret i32 %v
}

; Honest under-aligned half-word read at an odd frame address: peeled to two
; byte loads. No diagnostic.
define i16 @underaligned_half_peel() {
; CHECK-LABEL: underaligned_half_peel:
; CHECK: ldb
; CHECK: ldb
  %ctx = alloca [16 x i8], align 4
  call void @escape(ptr %ctx)
  %p = getelementptr inbounds i8, ptr %ctx, i32 1
  %v = load i16, ptr %p, align 1
  ret i16 %v
}

; Control: an ordinary, genuinely 4-aligned frame word access is unaffected --
; it keeps its single `ld` and is NOT peeled. The guard only ever looks at the
; effective offset, so a truthful aligned access never reaches it.
define i32 @aligned_word() {
; CHECK-LABEL: aligned_word:
; CHECK: ld_s %r{{[0-9]+}}, [%{{sp|fp|r[0-9]+}},
; CHECK-NOT: ldb
  %ctx = alloca [16 x i8], align 4
  call void @escape(ptr %ctx)
  %p = getelementptr inbounds i8, ptr %ctx, i32 4
  %v = load i32, ptr %p, align 4
  ret i32 %v
}
