; RUN: llc -march=arceb -mcpu=arc700eb < %s | FileCheck %s \
; RUN:   --implicit-check-not="sub %sp, %sp," --implicit-check-not="add %sp, %sp,"
; RUN: llc -march=arceb -mcpu=arc700eb -arc-save-restore-funclet=false < %s \
; RUN:   | FileCheck %s --check-prefix=INLINE

; Callee-save/restore millicode funclet path (__st_r13_to_rN / __ld_r13_to_rN).
;
; The helpers are supplied by the runtime this target links, not by LLVM. The
; contract these tests pin (see the comment above store_funclet_name[] in
; ARCFrameLowering.cpp):
;   - at the BL, SP points exactly at r13's slot;
;   - the helper stores rK at [sp, 4*(K-13)] and MUST NOT modify SP -- the
;     caller allocates and releases the slot range;
;   - the helper returns via `j [blink]` and clobbers blink only.
;
; The SP arithmetic is the load-bearing half of that contract, so every
; SP-moving instruction below is pinned with its exact byte amount and the
; sequences are checked with CHECK-NEXT so nothing can slip in between.
;
; The two --implicit-check-not patterns on the first RUN line assert, over the
; WHOLE output, that no SP adjustment uses the 4-byte add/sub rru6 form: funclet
; amounts are always 4*N with N in [3,13] -- 12..52 bytes, 4-byte aligned and
; <= 124 -- so the 2-byte compact form always fits, and a bare
; `sub %sp, %sp, <imm>` / `add %sp, %sp, <imm>` anywhere means some path stopped
; consulting generateStackAdjustment. (`sub %sp, %fp, 28` and `add %fp, %sp, 28`
; in fp_dynamic_alloca are different instructions -- FP is the source/destination
; there -- and correctly do not match.)

;-------------------------------------------------------------------------
; Trigger boundary. `Last` is the MAX callee-saved register, and the gate is
; `Last > r14`: there is no contiguity requirement and no size threshold.
;-------------------------------------------------------------------------

; Highest callee-saved reg is r14 -> NO funclet, registers spilled inline.
define void @boundary_max_r14() {
; CHECK-LABEL: boundary_max_r14:
; CHECK-NOT: __st_r13_to_
; CHECK: sub_s %sp, %sp, 8
; CHECK: st_s %r13, [%sp, 0]
; CHECK: st_s %r14, [%sp, 4]
; CHECK: ld_s %r14, [%sp, 4]
; CHECK: ld_s %r13, [%sp, 0]
; CHECK: add_s %sp, %sp, 8
; CHECK-NOT: __ld_r13_to_
  call void asm sideeffect "", "~{r13},~{r14}"()
  ret void
}

; One register higher -- r15 -- and the funclet fires. N = 3 slots (r13..r15).
; Frame: 4 (blink) + 12 (r13..r15) = 16 bytes.
define void @boundary_max_r15() {
; CHECK-LABEL: boundary_max_r15:
; CHECK: push_s %blink
; CHECK-NEXT: sub_s %sp, %sp, 12
; CHECK-NEXT: bl @__st_r13_to_r15
; CHECK: bl @__ld_r13_to_r15
; CHECK-NEXT: add_s %sp, %sp, 12
; CHECK-NEXT: pop_s %blink
; CHECK-NEXT: j_s [%blink]
;
; With the funclet disabled the same function spills inline -- this is what the
; default-on path is buying, and it is why the default stays on.
; INLINE-LABEL: boundary_max_r15:
; INLINE-NOT: __st_r13_to_
; INLINE: sub_s %sp, %sp, 12
; INLINE: st_s %r13, [%sp, 0]
; INLINE: st_s %r14, [%sp, 4]
; INLINE: st_s %r15, [%sp, 8]
  call void asm sideeffect "", "~{r13},~{r14},~{r15}"()
  ret void
}

;-------------------------------------------------------------------------
; A leaf function on the funclet path must still describe its BLINK slot.
;
; This is the regression test for the CFI/allocation gate disagreement: the
; slot-allocation gate asked `hasCalls() || funclet`, the CFI gate asked only
; `hasCalls()`. A leaf reaches the funclet path (it makes no calls of its own,
; but the `bl` to the helper clobbers blink), so it pushed blink and emitted no
; .cfi_offset for it -- describing the return-address register as unchanged
; when it had in fact been clobbered.
;
; No .text impact: the epilogue already popped blink symmetrically. Only the
; unwind description was missing.
;-------------------------------------------------------------------------

define void @leaf_funclet_describes_blink() {
; CHECK-LABEL: leaf_funclet_describes_blink:
; CHECK: push_s %blink
; CHECK-NEXT: sub_s %sp, %sp, 12
; CHECK-NEXT: bl @__st_r13_to_r15
; CHECK-NEXT: .cfi_def_cfa_offset 16
; blink is DWARF register 31, saved at CFA-4 (pushed first, no FP here).
; CHECK-NEXT: .cfi_offset 31, -4
; CHECK-NEXT: .cfi_offset 13, -16
; CHECK-NEXT: .cfi_offset 14, -12
; CHECK-NEXT: .cfi_offset 15, -8
  call void asm sideeffect "", "~{r13},~{r14},~{r15}"()
  ret void
}

; Same shape, but with a real call. This one always described blink correctly
; (hasCalls() was true), and is the control proving the leaf case above now
; agrees with it.
define void @nonleaf_funclet_describes_blink() {
; CHECK-LABEL: nonleaf_funclet_describes_blink:
; CHECK: .cfi_def_cfa_offset 16
; CHECK-NEXT: .cfi_offset 31, -4
; CHECK-NEXT: .cfi_offset 13, -16
  call void asm sideeffect "", "~{r13},~{r14},~{r15}"()
  call void @ext()
  ret void
}

;-------------------------------------------------------------------------
; Sparse callee-saved set: clobber ONLY a high register. The funclet still
; forms, and slots are allocated for the whole r13..Last range even though the
; function never touches r13..r19. Only the registers actually in CSI get a
; .cfi_offset -- the others hold values the function never had.
;-------------------------------------------------------------------------

define void @sparse_only_r20() {
; CHECK-LABEL: sparse_only_r20:
; N = r20 - r12 = 8 slots = 32 bytes; frame = 4 + 32 = 36.
; CHECK: push_s %blink
; CHECK-NEXT: sub_s %sp, %sp, 32
; CHECK-NEXT: bl @__st_r13_to_r20
; CHECK-NEXT: .cfi_def_cfa_offset 36
; CHECK-NEXT: .cfi_offset 31, -4
; CHECK-NEXT: .cfi_offset 20, -8
; CHECK: bl @__ld_r13_to_r20
; CHECK-NEXT: add_s %sp, %sp, 32
; CHECK-NEXT: pop_s %blink
  call void asm sideeffect "", "~{r20}"()
  ret void
}

;-------------------------------------------------------------------------
; Top of the helper ladder: r25 -> N = 13 slots = 52 bytes, the largest amount
; the funclet path can ever request. 52 is 4-byte aligned and <= 124, so even
; the maximum still selects the 2-byte compact SP form.
;-------------------------------------------------------------------------

define void @ladder_top_r25() {
; CHECK-LABEL: ladder_top_r25:
; CHECK: push_s %blink
; CHECK-NEXT: sub_s %sp, %sp, 52
; CHECK-NEXT: bl @__st_r13_to_r25
; CHECK-NEXT: .cfi_def_cfa_offset 56
; CHECK-NEXT: .cfi_offset 31, -4
; CHECK-NEXT: .cfi_offset 25, -8
; CHECK: bl @__ld_r13_to_r25
; CHECK-NEXT: add_s %sp, %sp, 52
; CHECK-NEXT: pop_s %blink
; CHECK-NEXT: j_s [%blink]
  call void asm sideeffect "", "~{r25}"()
  ret void
}

;-------------------------------------------------------------------------
; SP balance with a frame pointer and a dynamic alloca.
;
; Prologue moves SP down by 4 (fp) + 4 (blink) + 16 (r13..r16) + 4 (residual
; scavenger slot) = 28 = the frame size, then pins FP to the CFA.
; The epilogue reverses all 28 exactly, in the mirrored order, releasing the
; helper's 16-byte range itself -- the helper never touches SP.
;-------------------------------------------------------------------------

define void @fp_dynamic_alloca(i32 %n) {
; CHECK-LABEL: fp_dynamic_alloca:
; CHECK: st.aw %fp, [%sp,-4]
; CHECK-NEXT: push_s %blink
; CHECK-NEXT: sub_s %sp, %sp, 16
; CHECK-NEXT: bl @__st_r13_to_r16
; CHECK-NEXT: sub_s %sp, %sp, 4
; CHECK-NEXT: add %fp, %sp, 28
; CHECK-NEXT: .cfi_def_cfa_offset 28
; fp is DWARF register 27 at CFA-4; blink is 31, pushed after fp, at CFA-8.
; CHECK-NEXT: .cfi_offset 27, -4
; CHECK-NEXT: .cfi_offset 31, -8
; CHECK-NEXT: .cfi_offset 13, -24
; CHECK-NEXT: .cfi_offset 14, -20
; CHECK-NEXT: .cfi_offset 15, -16
; CHECK-NEXT: .cfi_offset 16, -12
; Teardown: recover SP from FP past the alloca, then unwind the frame exactly.
; CHECK: sub %sp, %fp, 28
; CHECK-NEXT: add_s %sp, %sp, 4
; CHECK-NEXT: bl @__ld_r13_to_r16
; CHECK-NEXT: add_s %sp, %sp, 16
; CHECK-NEXT: pop_s %blink
; CHECK-NEXT: ld.ab %fp, [%sp,4]
; CHECK-NEXT: j_s [%blink]
  %p = alloca i8, i32 %n
  call void asm sideeffect "", "~{r13},~{r14},~{r15},~{r16}"()
  call void @sink(ptr %p)
  ret void
}

;-------------------------------------------------------------------------
; Tail call out of a funclet frame: the frame must be FULLY torn down -- the
; restore helper called, its slot range released, blink popped -- before the
; tail branch. Otherwise the callee would run on a frame that still owns this
; function's save area and return past it.
;-------------------------------------------------------------------------

define i32 @tail_call_from_funclet_frame(i32 %x) {
; CHECK-LABEL: tail_call_from_funclet_frame:
; CHECK: push_s %blink
; CHECK-NEXT: sub_s %sp, %sp, 12
; CHECK-NEXT: bl @__st_r13_to_r15
; CHECK-NEXT: .cfi_def_cfa_offset 16
; CHECK-NEXT: .cfi_offset 31, -4
; Full teardown, then the tail branch -- 12 + 4 = 16 = the whole frame.
; CHECK: bl @__ld_r13_to_r15
; CHECK-NEXT: add_s %sp, %sp, 12
; CHECK-NEXT: pop_s %blink
; CHECK-NEXT: b @tgt
  call void asm sideeffect "", "~{r13},~{r14},~{r15}"()
  %r = tail call i32 @tgt(i32 %x)
  ret i32 %r
}

;-------------------------------------------------------------------------
; Multiple returns: emitEpilogue runs once per return block, so EACH epilogue
; must independently restore SP to the CFA. Both blocks below release the same
; 12-byte helper range and pop blink.
;-------------------------------------------------------------------------

define i32 @multiple_returns(i32 %c) {
; CHECK-LABEL: multiple_returns:
; CHECK: push_s %blink
; CHECK-NEXT: sub_s %sp, %sp, 12
; CHECK-NEXT: bl @__st_r13_to_r15
; CHECK-NEXT: .cfi_def_cfa_offset 16
; CHECK-NEXT: .cfi_offset 31, -4
; First epilogue: tail-branch exit.
; CHECK: bl @__ld_r13_to_r15
; CHECK-NEXT: add_s %sp, %sp, 12
; CHECK-NEXT: pop_s %blink
; CHECK-NEXT: b @tgt
; Second epilogue: ordinary return. The return-value move is emitted ahead of the
; restore helper call (16-bit compaction leaves the call without a delay slot);
; the teardown that follows must not touch SP or blink.
; CHECK: mov_s %r0, 7
; CHECK-NEXT: bl @__ld_r13_to_r15
; CHECK-NEXT: add_s %sp, %sp, 12
; CHECK-NEXT: pop_s %blink
; CHECK-NEXT: j_s [%blink]
  call void asm sideeffect "", "~{r13},~{r14},~{r15}"()
  %t = icmp sgt i32 %c, 0
  br i1 %t, label %a, label %b
a:
  %r = tail call i32 @tgt(i32 %c)
  ret i32 %r
b:
  ret i32 7
}

declare void @ext()
declare void @sink(ptr)
declare i32 @tgt(i32)
