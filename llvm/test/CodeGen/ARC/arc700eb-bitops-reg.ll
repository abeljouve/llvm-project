; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact < %s | FileCheck %s
; RUN: llc -march=arceb -mcpu=arc700eb -mattr=-arcompact < %s | FileCheck %s --check-prefix=NOCOMPACT
; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact < %s | not grep -E "mpy|swape|\bffs\b|\bfls\b|rtie|\bex\b|adds|subs"

; Register (runtime) bit-position variants of BSET/BXOR/BCLR/BMSK
; (ARCARCompactPatterns.td lines ~80-111). Before this dossier there was
; ZERO coverage anywhere in llvm/test/CodeGen/ARC for these four Pats --
; only the constant-bit-position family (arc700eb-bitops-imm.ll) was
; exercised. These match `(op x, (shl 1, r))` shapes directly (no ImmLeaf
; involved, no LIMM-avoidance tradeoff -- they always win over the
; materialize-mask-then-op sequence a generic lowering would emit).
;
; (Function names avoid the mnemonics so CHECK-NOT can't match a .size
; label, matching the convention in arc700eb-bitops-imm.ll.)

; --- BSET: a = b | (1 << n) ---
define i32 @bsetreg(i32 %a, i32 %n) {
; CHECK-LABEL: bsetreg:
; CHECK: bset %r0, %r0, %r1
; CHECK-NOT: asl
  %s = shl i32 1, %n
  %r = or i32 %a, %s
  ret i32 %r
}

; --- BXOR: a = b ^ (1 << n) ---
define i32 @bxorreg(i32 %a, i32 %n) {
; CHECK-LABEL: bxorreg:
; CHECK: bxor %r0, %r0, %r1
; CHECK-NOT: asl
  %s = shl i32 1, %n
  %r = xor i32 %a, %s
  ret i32 %r
}

; --- BCLR: a = b & ~(1 << n) ---
define i32 @bclrreg(i32 %a, i32 %n) {
; CHECK-LABEL: bclrreg:
; CHECK: bclr %r0, %r0, %r1
; CHECK-NOT: asl
  %s = shl i32 1, %n
  %ns = xor i32 %s, -1
  %r = and i32 %a, %ns
  ret i32 %r
}

; --- BMSK: a = b & ((1 << (n + 1)) - 1) ---
define i32 @bmskreg(i32 %a, i32 %n) {
; CHECK-LABEL: bmskreg:
; CHECK: bmsk %r0, %r0, %r1
; CHECK-NOT: asl
  %np1 = add i32 %n, 1
  %s = shl i32 1, %np1
  %m = add i32 %s, -1
  %r = and i32 %a, %m
  ret i32 %r
}

; ============================================================================
; Negative cases: the specialized register Pats must NOT over-match a shape
; that merely resembles theirs. Each of these must fall back to the generic
; shift + or/xor/and sequence, never a dedicated bit-op mnemonic.
; ============================================================================

; --- shl by a non-1 base (2, not 1) must NOT become bset ---
define i32 @bsetreg_wrongbase(i32 %a, i32 %n) {
; CHECK-LABEL: bsetreg_wrongbase:
; CHECK: asl
; CHECK: or %r0, %r0, %r1
; CHECK-NOT: bset %r
  %s = shl i32 2, %n
  %r = or i32 %a, %s
  ret i32 %r
}

; --- shl by a non-1 base must NOT become bxor ---
define i32 @bxorreg_wrongbase(i32 %a, i32 %n) {
; CHECK-LABEL: bxorreg_wrongbase:
; CHECK: asl
; CHECK: xor %r0, %r0, %r1
; CHECK-NOT: bxor %r
  %s = shl i32 3, %n
  %r = xor i32 %a, %s
  ret i32 %r
}

; --- shl by a non-1 base, and-not shape must NOT become bclr. This
; degenerate shape (AND with the complement of an arbitrary register value,
; not specifically a single shifted bit) legitimately selects BIC (a = b &
; ~c, the plain and-not instruction from earlier in this file) instead --
; BIC is a correct, unrelated pattern match, not bclr; the CHECK-NOT below
; only asserts bclr itself never fires here. ---
define i32 @bclrreg_wrongbase(i32 %a, i32 %n) {
; CHECK-LABEL: bclrreg_wrongbase:
; CHECK: asl
; CHECK-NOT: bclr %r
  %s = shl i32 3, %n
  %ns = xor i32 %s, -1
  %r = and i32 %a, %ns
  ret i32 %r
}

; --- wrong shift amount (n+2, not n+1) must NOT become bmsk ---
define i32 @bmskreg_wrongshift(i32 %a, i32 %n) {
; CHECK-LABEL: bmskreg_wrongshift:
; CHECK: asl
; CHECK: and %r0, %r0, %r1
; CHECK-NOT: bmsk %r
  %np2 = add i32 %n, 2
  %s = shl i32 1, %np2
  %m = add i32 %s, -1
  %r = and i32 %a, %m
  ret i32 %r
}

; ============================================================================
; Feature-negative sweep: with ARCompact disabled, none of the register-
; variant bit ops may be selected -- the generic shift+op sequence must be
; used for every positive case above.
; ============================================================================

; NOCOMPACT-NOT: bset %r
; NOCOMPACT-NOT: bxor %r
; NOCOMPACT-NOT: bclr %r
; NOCOMPACT-NOT: bmsk %r
