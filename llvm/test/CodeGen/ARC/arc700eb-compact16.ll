; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -march=arceb -mcpu=arc700eb -mattr=-arcompact -verify-machineinstrs < %s | FileCheck %s --check-prefix=NOCOMPACT
; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs < %s | not grep -E "mpy|swape|\bffs\b|\bfls\b|rtie|\bex\b|adds|subs"

; ARCSizeReduction (dossier 05): reg-reg mov_s, cmp_s (reg-reg and reg-imm),
; the register-count shifts asl_s/asr_s/lsr_s, and the fused sexb_s/sexw_s
; two-instruction idiom. All five were previously blocked by structural
; TableGen descriptor bugs in ARCARCompactInstr16.td:
;   - the "High Register" h-field scatter (shared by ADD_S/MOV_S/CMP_S b,h)
;     put the low/high halves of the 6-bit source register in the wrong
;     Inst{} bit positions, silently copying/comparing the wrong register;
;   - the compact CMP_S descriptors modeled the compared register as a
;     definition instead of a use;
;   - the variable-register-count shift encodings (_v1 sub-opcodes
;     0x18/0x19/0x1A) never bound their operands to any Inst{} bits at all,
;     so the MC encoder always emitted a fixed r0,r0,r0 encoding regardless
;     of the selected registers.
; All three classes are byte-verified against the authoritative BE-ARC
; disassembler (projects/bcm55030-retools/target/release/disasm) at the
; GPR_S boundary registers (r0, r3, r12, r15) as part of the implementation
; session; this file is the checked-in mnemonic-level regression coverage.
;
; The trailing `not grep` RUN line is the standard whole-file forbidden-opcode
; sweep (see arc700eb-bitops-imm.ll): none of the DSP/hardware-multiply/
; saturating opcodes may appear in output compiled from this file. The second
; RUN line (-mattr=-arcompact) is the feature-negative check: none of the
; five reductions below may fire without the ARCompact feature.

; ============================================================================
; Section A: reg-reg mov_s (MOV_rr -> ARC_MOV_S_b_h). Forcing a genuine
; register-to-register copy (not a redundant one coalescing would delete)
; via a 4-argument calling-convention rotation -- the register allocator has
; to insert real MOV_rr copies to satisfy the callee's argument registers.
; ============================================================================

declare i32 @g4(i32, i32, i32, i32)

; CHECK-LABEL: swap4:
; CHECK: mov_s
; CHECK: mov_s
; CHECK: mov_s
; CHECK: mov_s
; NOCOMPACT-LABEL: swap4:
; NOCOMPACT-NOT: mov_s
define i32 @swap4(i32 %a, i32 %b, i32 %c, i32 %d) minsize optsize {
entry:
  %r = call i32 @g4(i32 %d, i32 %c, i32 %b, i32 %a)
  ret i32 %r
}

; ============================================================================
; Section B: cmp_s reg-reg (CMP_rr -> ARC_CMP_S_b_h) and cmp_s reg-imm
; (CMP_ru6 -> ARC_CMP_S_b_u7), via icmp+select (lowers to cmp + conditional
; mov, which is exactly the "live-flags-through-CMP_S" shape: the compact
; compare's implicit STATUS32 def must round-trip correctly into the
; following flag-consuming mov.cc).
; ============================================================================

; CHECK-LABEL: cmp_reg_sel:
; CHECK: cmp_s %r0, %r1
; CHECK: mov.lt
; NOCOMPACT-LABEL: cmp_reg_sel:
; NOCOMPACT-NOT: cmp_s
define i32 @cmp_reg_sel(i32 %a, i32 %b, i32 %c, i32 %d) minsize optsize {
  %cc = icmp slt i32 %a, %b
  %r = select i1 %cc, i32 %c, i32 %d
  ret i32 %r
}

; --- immediate boundary: 0 ---
; CHECK-LABEL: cmp_imm_zero:
; CHECK: cmp_s %r0, 0
; CHECK: mov.eq
define i32 @cmp_imm_zero(i32 %a, i32 %b, i32 %c) minsize optsize {
  %cc = icmp eq i32 %a, 0
  %r = select i1 %cc, i32 %b, i32 %c
  ret i32 %r
}

; --- immediate boundary: 63 (top of the immU6 range CMP_ru6 selects on;
; always fits the compact form's u7 field) ---
; CHECK-LABEL: cmp_imm_hi:
; CHECK: cmp_s %r0, 63
define i32 @cmp_imm_hi(i32 %a) minsize optsize {
  %c = icmp ult i32 %a, 63
  %r = select i1 %c, i32 %a, i32 0
  ret i32 %r
}

; ============================================================================
; Section C: register-count shifts (ASL_rrr/ASR_rrr/LSR_rrr ->
; ARC_{ASL,ASR,LSR}_S_b_c_v1). Shift-by-register, NOT shift-by-constant --
; the constant-shift forms use a different (already-correct) encoding and
; would not exercise the previously-broken _v1 descriptors.
; ============================================================================

; CHECK-LABEL: shl_reg:
; CHECK: asl_s %r0, %r1
; NOCOMPACT-LABEL: shl_reg:
; NOCOMPACT-NOT: asl_s
define i32 @shl_reg(i32 %a, i32 %n) minsize optsize {
  %r = shl i32 %a, %n
  ret i32 %r
}

; CHECK-LABEL: ashr_reg:
; CHECK: asr_s %r0, %r1
define i32 @ashr_reg(i32 %a, i32 %n) minsize optsize {
  %r = ashr i32 %a, %n
  ret i32 %r
}

; CHECK-LABEL: lshr_reg:
; CHECK: lsr_s %r0, %r1
define i32 @lshr_reg(i32 %a, i32 %n) minsize optsize {
  %r = lshr i32 %a, %n
  ret i32 %r
}

; ============================================================================
; Section D: sexb_s / sexw_s fusion (ASL_rru6 + ASR_rru6, shift 24 / 16 ->
; ARC_SEXB_S_b_c / ARC_SEXW_S_b_c). ARC700 has no single-instruction wide
; SEXB/SEXH (ARCv2-only, gated off via !HasSEXT), so sext_inreg legalizes to
; the two-instruction shift-left/arithmetic-shift-right pair this fusion
; recognizes.
; ============================================================================

; CHECK-LABEL: sb:
; CHECK: sexb_s %r0, %r0
; CHECK-NOT: asl
; CHECK-NOT: asr
; NOCOMPACT-LABEL: sb:
; NOCOMPACT: asl %r0, %r0, 24
; NOCOMPACT: asr %r0, %r0, 24
define i32 @sb(i8 %x) minsize optsize {
  %s = sext i8 %x to i32
  ret i32 %s
}

; CHECK-LABEL: sw:
; CHECK: sexw_s %r0, %r0
; CHECK-NOT: asl
; CHECK-NOT: asr
; NOCOMPACT-LABEL: sw:
; NOCOMPACT: asl %r0, %r0, 16
; NOCOMPACT: asr %r0, %r0, 16
define i32 @sw(i16 %x) minsize optsize {
  %s = sext i16 %x to i32
  ret i32 %s
}
