; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs -arc-disable-delay-filler < %s | FileCheck %s
; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs < %s | not grep -E "mpy|swape|\bffs\b|\bfls\b|rtie|\bex\b|adds|subs|bset|bclr|bmsk|bxor"

; -arc-disable-delay-filler: this file tests instruction *selection* and
; encodings, not scheduling. The delay slot filler is a late pass that sinks
; the last instruction of a block into the return's delay slot, which leaves
; `j_s.d` sitting between instructions this file asserts are adjacent with
; CHECK-NEXT. The selected instructions and their encodings are unchanged --
; only the return moves -- so the filler is turned off here to keep those
; adjacency assertions meaningful and independent of the filler's heuristics.
; Delay-slot behaviour has its own coverage in delay-slot-filler.mir and
; arc700eb-delay-slot-*.mir.

; CONST32 recipe (dossier 21 idea 4): materialize a 32-bit INTEGER constant
; that does not fit a signed 12-bit immediate via a cheap
; `mov_s seed ; asl seed, shift` chain (6 bytes total) instead of the
; 8-byte `mov ..., LIMM` baseline (4-byte host instruction + 4-byte LIMM
; word), whenever the constant is exactly `seed << shift` for an unsigned
; 8-bit seed and a shift in [1, 31]. See ARCConstantMaterialization.h/.cpp,
; the ISD::Constant case in ARCISelDAGToDAG.cpp, and
; ARCInstrInfo::expandPostRAPseudo (ARCInstrInfo.cpp) for the POST-register-
; allocation expansion that makes CONST32's isReMaterializable effective
; (see Section F below).
;
; The trailing `not grep` line is a whole-file forbidden-opcode sweep,
; mirroring arc700eb-bitops-imm.ll: none of the DSP/saturating/absent-
; silicon opcodes, and none of the bit-op mnemonics (bset/bclr/bmsk/bxor --
; deliberately EXCLUDED from CONST32 recipes pending a flag-behavior
; cross-check, see ARCConstantMaterialization.h), may appear anywhere in
; output compiled from this file.

; ============================================================================
; Section A: positive hits -- seed<<shift fits exactly, CONST32 fires.
; ============================================================================

; --- canonical example: 0x00010000 = 1 << 16 ---
; CHECK-LABEL: c_0x10000:
; CHECK: mov_s %r0, 1
; CHECK: asl %r0, %r0, 16
; CHECK-NOT: mov %r0,{{.*}}0x10000
define i32 @c_0x10000() {
  ret i32 65536
}

; --- max u8 seed: 0x00FF0000 = 0xFF << 16 ---
; CHECK-LABEL: c_0xff0000:
; CHECK: mov_s %r0, 255
; CHECK: asl %r0, %r0, 16
define i32 @c_0xff0000() {
  ret i32 16711680
}

; --- 0xFF000000 = 0xFF << 24 (seed at the top byte) ---
; CHECK-LABEL: c_0xff000000:
; CHECK: mov_s %r0, 255
; CHECK: asl %r0, %r0, 24
define i32 @c_0xff000000() {
  ret i32 4278190080
}

; --- high-bit-set / "negative-large": 0x80000000 = 1 << 31 ---
; CHECK-LABEL: c_0x80000000:
; CHECK: mov_s %r0, 1
; CHECK: asl %r0, %r0, 31
define i32 @c_0x80000000() {
  ret i32 2147483648
}

; --- another negative-large, non-power-of-two seed: 0xC0000000 = 3 << 30 ---
; CHECK-LABEL: c_0xc0000000:
; CHECK: mov_s %r0, 3
; CHECK: asl %r0, %r0, 30
define i32 @c_0xc0000000() {
  ret i32 3221225472
}

; ============================================================================
; Section B: negative hits -- no seed<<shift recipe fits (residue > u8, or
; the value is byte-neutral/worse than the 8-byte LIMM baseline) -- MUST
; keep the existing mov ..., LIMM lowering unchanged.
; ============================================================================

; --- 0xFFFF0000: residue after stripping 16 trailing zero bits is 0xFFFF,
;     too wide for a u8 seed -- stays MOV_rlimm (8 bytes, byte-verified via
;     the workshop disassembler during development; not re-verified here
;     since this test only checks assembly text, not raw bytes).
; CHECK-LABEL: c_0xffff0000:
; CHECK: mov %r0, -65536
; CHECK-NOT: mov_s
; CHECK-NOT: asl
define i32 @c_0xffff0000() {
  ret i32 4294901760
}

; --- 0xFFFFF400: same shape (residue 0x3FFFD after 10 trailing zero bits),
;     also stays MOV_rlimm.
; CHECK-LABEL: c_0xfffff400:
; CHECK: mov %r0, -3072
; CHECK-NOT: mov_s
; CHECK-NOT: asl
define i32 @c_0xfffff400() {
  ret i32 4294964224
}

; ============================================================================
; Section C: s12 fast path is completely untouched -- a constant in
; [-2048, 2047] (as tested by the existing isInt<12> check on the DAG's
; zero-extended immediate representation) stays a single 4-byte MOV_rs12,
; a 0-op seed, with no recipe search performed at all.
; ============================================================================

; CHECK-LABEL: c_s12_2000:
; CHECK: mov %r0, 2000
; CHECK-NOT: mov_s
; CHECK-NOT: asl
define i32 @c_s12_2000() {
  ret i32 2000
}

; --- s12 upper boundary ---
; CHECK-LABEL: c_s12_2047:
; CHECK: mov %r0, 2047
; CHECK-NOT: mov_s
; CHECK-NOT: asl
define i32 @c_s12_2047() {
  ret i32 2047
}

; --- negative s12 ---
; CHECK-LABEL: c_s12_neg5:
; CHECK: mov %r0, -5
; CHECK-NOT: mov_s
; CHECK-NOT: asl
define i32 @c_s12_neg5() {
  ret i32 -5
}

; --- trivial zero ---
; CHECK-LABEL: c_s12_zero:
; CHECK: mov_s %r0, 0
; CHECK-NOT: mov_s
; CHECK-NOT: asl
define i32 @c_s12_zero() {
  ret i32 0
}

; ============================================================================
; Section D: relocatable constants (global address / constant pool) are a
; completely different SDNode (ARCISD::GAWRAPPER, not ISD::Constant) and
; must never be routed through the CONST32 recipe search -- they keep
; materializing via MOV_rlimm(tconstpool)/(tglobaladdr) exactly as before.
; ============================================================================

@g = global i32 0

; CHECK-LABEL: c_global:
; CHECK: mov %r0, @g
; CHECK-NOT: mov_s
; CHECK-NOT: asl
define ptr @c_global() {
  ret ptr @g
}

; ============================================================================
; Section E: DenseMap sentinel regression (bug fixed in this re-run). An i32
; constant equal to -1 (0xFFFFFFFF) or -2 (0xFFFFFFFE) has a ZExt-ed 64-bit
; representation that does NOT fit isInt<12> (it reads as a huge unsigned
; value, not as -1/-2), so ISel calls synthesizeConst32(0xFFFFFFFF) /
; synthesizeConst32(0xFFFFFFFE) exactly like any other non-s12 constant.
; DenseMap<uint32_t, ...>'s default Empty/Tombstone sentinel keys are
; exactly those two bit patterns, so inserting either into the recipe
; memoization cache used to abort with "Empty/Tombstone value shouldn't be
; inserted into map!" -- this crashed compilation of any function
; materializing -1 or -2 as a bare i32 constant. Neither value has a valid
; seed<<shift decomposition (both are either odd or leave a residue far
; wider than 8 bits) anyway, so the fix (an early return before any cache
; access) is behavior-preserving: both must still compile, without
; crashing, to a single mov/LIMM -- never to a mov_s/asl chain.
; ============================================================================

; CHECK-LABEL: c_neg1:
; CHECK: mov %r0, -1
; CHECK-NOT: mov_s
; CHECK-NOT: asl
define i32 @c_neg1() {
  ret i32 -1
}

; CHECK-LABEL: c_neg2:
; CHECK: mov %r0, -2
; CHECK-NOT: mov_s
; CHECK-NOT: asl
define i32 @c_neg2() {
  ret i32 -2
}

; --- all-ones via an explicit hex literal, same bit pattern as c_neg1 but
;     spelled the way a "~0" idiom would appear after IR-level constant
;     folding -- exercises the same DenseMap-sentinel code path a second,
;     independent way.
; CHECK-LABEL: c_allones:
; CHECK: mov %r0, -1
; CHECK-NOT: mov_s
; CHECK-NOT: asl
define i32 @c_allones() {
  ret i32 4294967295
}

; ============================================================================
; Section F: genuine post-register-allocation rematerialization (bug fixed
; in this re-run). CONST32 is now expanded by
; ARCInstrInfo::expandPostRAPseudo -- which the target-independent
; ExpandPostRAPseudos pass runs strictly AFTER register allocation -- not
; by the pre-RA ARCExpandPseudos pass. This means CONST32 still exists, as
; a single immediate-only (no register operands) pseudo, when the greedy
; register allocator makes its rematerialize-vs-spill decision, so
; isReMaterializable/isAsCheapAsAMove/isMoveImm are now operationally
; effective instead of inert.
;
; This function materializes the same non-s12 constant (0x10000) both
; before and after a call to an opaque @clobber that clobbers all
; caller-saved registers. If CONST32 is genuinely rematerializable, the
; register allocator recomputes the mov_s/asl chain a second time after
; the call instead of spilling the first materialization to the stack and
; reloading it -- i.e. the exact `mov_s %r0, 1` / `asl %r0, %r0, 16` pair
; must appear TWICE, with no `st`/`ld` spill-slot traffic anywhere in the
; function body. (Verified independently, outside this lit test, via a
; hand-written high-register-pressure .mir dump run through
; `-run-pass=greedy -run-pass=virtregrewriter -run-pass=postrapseudos`
; forcing 9 live CONST32 values against the 8-register GPR_S class -- see
; the dossier 21 idea 4 session notes -- which showed the same
; recompute-at-every-use-site behavior with zero spill-slot instructions.)
; ============================================================================

declare void @use(i32)
declare void @clobber()

; CHECK-LABEL: remat_stress:
; CHECK: push_s %blink
; CHECK: mov_s %r0, 1
; CHECK-NEXT: asl %r0, %r0, 16
; CHECK-NEXT: bl @use
; CHECK-NEXT: bl @clobber
; CHECK-NEXT: mov_s %r0, 1
; CHECK-NEXT: asl %r0, %r0, 16
; CHECK-NEXT: bl @use
; CHECK-NEXT: pop_s %blink
; CHECK-NOT: {{^[ \t]*st}}
; CHECK-NOT: {{^[ \t]*ld}}
define void @remat_stress() {
entry:
  call void @use(i32 65536)
  call void @clobber()
  call void @use(i32 65536)
  ret void
}
