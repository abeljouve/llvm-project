; RUN: not llc -march=arceb -mcpu=bcm55030 < %s 2>&1 | FileCheck %s
; RUN: not llc -march=arceb -mcpu=arc700eb < %s 2>&1 | FileCheck %s

; A frame-relative word load whose effective address is provably 3 (mod 4)
; must be rejected, not emitted.
;
; This is the minimal reproducer for the misaligned frame access that showed up
; during LTO codegen of a C corpus. LTO was only the messenger: it inlined a
; callee, substituting an opaque pointer parameter with the caller's alloca, so
; an already-bad access acquired a FrameIndex base and started routing through
; eliminateFrameIndex -- the one place in the toolchain that noticed. No LTO is
; needed to reproduce, as this test shows.
;
; The IR below is exactly what clang emits for a C word-typed dereference of an
; address that is provably misaligned, e.g. `*(u32 *)(p + 3)`. That cast is
; undefined behaviour, and clang is entitled to believe it: it faithfully
; propagates `align 4` onto the load. The claim is false, and no backend hook
; can catch it on the way in --
; TargetLoweringBase::allowsMemoryAccessForAlignment short-circuits to "fast"
; whenever the claimed alignment >= the type's ABI alignment, so
; ARCTargetLowering::allowsMisalignedMemoryAccesses is never consulted. That
; hook only ever defends against IR that under-states its alignment honestly
; (see arc700eb-frame-align-peel.ll for that path working correctly).
;
; This matters beyond a build failure. This hardware does not fault on a
; misaligned access and does not fix it up: it silently clears the low address
; bits, so the emitted `ld %rN, [%fp, -313]` would quietly read the four bytes
; at -316 instead. A wrong value, with no error signal, at runtime. Refusing to
; emit it is the only way that ever gets noticed.

declare void @escape(ptr)

; CHECK: LLVM ERROR: ARC: misaligned frame access in function 'misaligned_frame_ld'
; CHECK-SAME: requires 4-byte alignment
define i32 @misaligned_frame_ld() {
  %ctx = alloca [16 x i8], align 4
  ; Force the object to stay addressable in memory rather than be promoted.
  call void @escape(ptr %ctx)
  %p = getelementptr inbounds i8, ptr %ctx, i32 3
  %v = load i32, ptr %p, align 4
  ret i32 %v
}
