; RUN: not llc -march=arceb -mcpu=bcm55030 < %s 2>&1 | FileCheck %s

; Closed hole #1 in the old per-opcode asserts: a FAR misaligned word LOAD.
;
; replaceFrameIndex takes an early-out for LD_rs9 when the resolved offset does
; not fit the S9 field (Offset >= 256 || Offset < -256), rewriting it to
; LD_rlimm and returning immediately -- before the switch that carried the
; alignment asserts. A far misaligned word load was therefore emitted with the
; alignment check structurally unable to run. LD_rlimm has the same alignment
; requirement as LD_rs9: widening the offset field changes nothing about what
; the hardware does with the low address bits.
;
; Getting here requires care, because the far path is NOT reached by simply
; writing a large constant GEP. ARCDAGToDAGISel::SelectAddrModeS9 bails out
; (`if (!isInt<9>(RHSC)) return false;`) when the constant offset itself
; overflows S9, so such an address is materialised into a register with a
; separate ADD and the access never carries a FrameIndex into
; eliminateFrameIndex at all. The far path is reached instead when a SMALL
; folded imm is added to a LARGE frame-layout offset: %ctx below is pushed past
; S9 reach by %pad, and is read at a folded +3, so the offset only resolves to
; 2055 (misaligned, and far) once the frame layout is applied. That resolution
; happens in eliminateFrameIndex -- which is exactly why the guard has to live
; there and be evaluated against the incoming Offset.

declare void @escape(ptr)

; CHECK: LLVM ERROR: ARC: misaligned frame access in function 'misaligned_far_frame_ld'
; CHECK-SAME: LD_rs9 requires 4-byte alignment
; CHECK-SAME: effective frame offset is 2055
define i32 @misaligned_far_frame_ld() {
  %ctx = alloca [16 x i8], align 4
  %pad = alloca [2048 x i8], align 4
  ; Keep both objects addressable in memory, and place %ctx beyond S9 reach.
  call void @escape(ptr %ctx)
  call void @escape(ptr %pad)
  %p = getelementptr inbounds i8, ptr %ctx, i32 3
  %v = load i32, ptr %p, align 4
  ret i32 %v
}
