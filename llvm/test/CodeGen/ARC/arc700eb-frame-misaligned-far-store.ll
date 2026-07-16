; RUN: not llc -march=arceb -mcpu=bcm55030 < %s 2>&1 | FileCheck %s

; Closed hole #2 in the old per-opcode asserts: a FAR misaligned HALF-WORD
; STORE.
;
; This is a different hole from the far-load one (arc700eb-frame-misaligned-
; far-load.ll), reached through a different path. Stores do not take the
; LD_rlimm early-out; they take the scratch-register path, which materialises
; the address into a scavenged register with an ADD and then sets `Offset = 0`
; before the switch runs. The old asserts therefore saw 0 and passed trivially
; for EVERY far access, load or store -- the check was structurally incapable
; of failing there, whatever the real offset was. Note that the resulting
; `add rX, fp, 2053` + `sth [rX, 0]` computes the identical misaligned address:
; splitting the addressing mode launders the offset past the check without
; changing the access the hardware performs. That is also why refusing the fold
; in SelectAddrModeS9 would not be a fix.
;
; Evaluating alignment at the top, against the incoming Offset, closes both.
; As in the far-load test, the far path needs a small folded imm (+1) on top of
; a large frame-layout offset -- a large constant GEP would opt out of
; FrameIndex addressing entirely (see that test for the mechanism).
;
; Half-word coverage is here too: STH_rs9/LDH_rs9/LDH_X_rs9 need 2-byte
; alignment (the hardware clears addr & ~1 for a half-word access), and the odd
; offset below is misaligned for a half-word as well as for a word.

declare void @escape(ptr)

; CHECK: LLVM ERROR: ARC: misaligned frame access in function 'misaligned_far_frame_sth'
; CHECK-SAME: STH_rs9 requires 2-byte alignment
; CHECK-SAME: effective frame offset is 2053
define void @misaligned_far_frame_sth(i16 %v) {
  %ctx = alloca [16 x i8], align 4
  %pad = alloca [2048 x i8], align 4
  ; Keep both objects addressable in memory, and place %ctx beyond S9 reach.
  call void @escape(ptr %ctx)
  call void @escape(ptr %pad)
  %p = getelementptr inbounds i8, ptr %ctx, i32 1
  store i16 %v, ptr %p, align 2
  ret void
}
