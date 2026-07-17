; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs -arc-disable-delay-filler < %s | FileCheck %s

; -arc-disable-delay-filler: this file tests instruction *selection* and
; encodings, not scheduling. The filler sinks the last instruction of a block
; into a transfer's delay slot, which would leave a `j_s.d` sitting between
; instructions asserted adjacent with CHECK-NEXT. The selected instructions and
; their encodings are unchanged -- only the transfer moves -- so it is turned
; off here to keep those adjacency assertions meaningful. The filler's own
; interaction with this sequence (it must never sink a flag writer into the
; branch's slot) is covered by its STATUS32 hazard guard and
; arc700eb-delay-slot-hazards.mir.

; 64-bit relational compares via ISD::SETCCCARRY (dossier 23 Phase 1).
;
; An i64 `<`/`>=` used to expand to the type legalizer's getSelect fallback --
; 9 instructions, 36 bytes, branchless but boolean-materializing. Marking
; SETCCCARRY Custom on i32 routes it to `cmp` + `sbc.f 0, ...` instead: the low
; half's borrow is left in STATUS32.C by a plain `cmp` and consumed directly by
; a subtract-with-borrow of the high halves, whose carry-out is the verdict for
; the whole 64-bit compare.
;
; CARRY POLARITY (the single silent-miscompile risk here -- and a point dossier
; 23's own prose states INVERTED, as do dossiers 18/19/24). On this ARC700
; SUB/CMP/SBC set C = BORROW, x86-style, NOT ARM-style:
;
;     a <u b   =>  C = 1  =>  "lo" / CS  (0x05)
;     a >=u b  =>  C = 0  =>  "hs" / CC  (0x06)
;
; Sources, cross-checked: ARCompact ISA Programmer's Reference Ch.8
; condition-code table ("CS, C, LO | Carry set, lower than (unsigned) | C |
; 0x05"), mirrored at docs/isa/06-condition-codes.md Table 85;
; docs/notes/isa-characterization.md section 5.4; and the emulator's ALU model
; (`AluOp::Sub | AluOp::Cmp => // ARC convention: C = borrow`). The `cmp` +
; `sbc.f` sequence was executed against that model's exact formulas over
; 200,784 vectors -- the full boundary set below plus 200k random/near-boundary
; pairs -- with 0 mismatches against the C-language `a < b`.
;
; A single .lo <-> .hs inversion silently reverses every unsigned i64 compare;
; the polarity CHECKs in this file are the tripwire.
;
; Encodings byte-verified with the workshop's authoritative big-endian ARC
; disassembler (llvm-objdump misdecodes big-endian ARC and must not be used):
;   0x210C80C0 -> cmp.f %r1, %r3
;   0x200380BE -> sbc.f 0x0, %r0, %r2      (A=62, the r62 NULL destination)
;   0x20038080 -> sbc.f %r0, %r0, %r2      (A=0 -- would CLOBBER %r0; the trap)
;   0x000E0005 -> b.cs (== "lo", 0x05)
;   0x000E0006 -> b.cc (== "hs", 0x06)
;   0x205207C0 -> bxor r0, r0, 0x1F        (the signed bias; F=Inst{15}=0, so
;                                           it cannot disturb the borrow)
;
; Big-endian i64 argument split: high half in the LOW-numbered register. So for
; f(i64 %a, i64 %b): %a = r0:r1 (hi:lo), %b = r2:r3 (hi:lo). The low compare is
; therefore `cmp %r1, %r3` and the high subtract `sbc.f 0, %r0, %r2`.

; ---------------------------------------------------------------------------
; Value form: materialize the 0/1 boolean. cmp + sbc.f + mov + mov.cc.
; ---------------------------------------------------------------------------

; a <u b: the verdict is the borrow itself -> "lo" (C=1).
; CHECK-LABEL: t_i64_ult_setcc:
; CHECK:      cmp %r1, %r3
; CHECK-NEXT: sbc.f 0, %r0, %r2
; CHECK-NOT:  mov.hs
; CHECK:      mov.lo
; CHECK-NOT:  mov.hs
define i32 @t_i64_ult_setcc(i64 %a, i64 %b) {
  %c = icmp ult i64 %a, %b
  %r = zext i1 %c to i32
  ret i32 %r
}

; a >=u b: no borrow -> "hs" (C=0). Exact polarity mirror of t_i64_ult_setcc.
; CHECK-LABEL: t_i64_uge_setcc:
; CHECK:      cmp %r1, %r3
; CHECK-NEXT: sbc.f 0, %r0, %r2
; CHECK-NOT:  mov.lo
; CHECK:      mov.hs
; CHECK-NOT:  mov.lo
define i32 @t_i64_uge_setcc(i64 %a, i64 %b) {
  %c = icmp uge i64 %a, %b
  %r = zext i1 %c to i32
  ret i32 %r
}

; a >u b: SETCCCARRY only knows LT/GE, so IntegerExpandSetCCOperands rewrites
; UGT to ULT by SWAPPING the operands. The compare must come out reversed --
; `cmp %r3, %r1` / `sbc.f 0, %r2, %r0` -- with the SAME "lo". Emitting the
; unswapped operands here would compute `b > a`.
; CHECK-LABEL: t_i64_ugt_setcc:
; CHECK:      cmp %r3, %r1
; CHECK-NEXT: sbc.f 0, %r2, %r0
; CHECK:      mov.lo
define i32 @t_i64_ugt_setcc(i64 %a, i64 %b) {
  %c = icmp ugt i64 %a, %b
  %r = zext i1 %c to i32
  ret i32 %r
}

; a <=u b: ULE -> UGE with operands swapped. Same swap, "hs" polarity.
; CHECK-LABEL: t_i64_ule_setcc:
; CHECK:      cmp %r3, %r1
; CHECK-NEXT: sbc.f 0, %r2, %r0
; CHECK:      mov.hs
define i32 @t_i64_ule_setcc(i64 %a, i64 %b) {
  %c = icmp ule i64 %a, %b
  %r = zext i1 %c to i32
  ret i32 %r
}

; ---------------------------------------------------------------------------
; Branch form: the 0/1 boolean is never materialized (the -67% case).
; BRCOND(SETCCCARRY) folds to cmp + sbc.f + Bcc = 3 instructions / 12 bytes.
;
; Those 12 bytes are REAL, and only became so once BRCARRY_p was admitted to
; isCondBranchOpcode in ARCInstrInfo.cpp. While the pseudo was unanalyzable,
; analyzeBranch reported every block ending in one as UNANALYZABLE, so
; BranchFolding could not elide the unconditional branch to the fallthrough and
; the sequence really emitted FOUR instructions / 16 bytes:
;
;     cmp %r1, %r3 / sbc.f 0, %r0, %r2 / bhs @.LBB0_2 / b @.LBB0_1
;                                                       ^^^^^^^^^^^
;                        .LBB0_1 is the next label -- 4 dead bytes, 32/32 sites.
;
; The `CHECK-NOT: b @` below is the tripwire for that regression, and it is the
; assertion this file was missing when the defect shipped: the CHECK-NEXT triple
; above matched happily while a dead branch sat right after it. Each CHECK-NOT
; is bounded by the next CHECK-LABEL, so it covers the rest of the function.
; ("b @" cannot alias the Bcc itself: `bhs @.LBB` has no "b @" substring.)
; ---------------------------------------------------------------------------

; The branch's polarity depends on which successor is laid out as the
; fallthrough (SelectionDAGBuilder folds that inversion into the compare's own
; condition code), so accept either "blo" or "bhs" -- but there must be exactly
; one Bcc, and NO materialized boolean: no mov/mov.cc pair and no `brne`/`bbit`
; re-test of one. That absence is the whole point of the fold.
; CHECK-LABEL: t_i64_ult_br:
; CHECK:      cmp %r1, %r3
; CHECK-NEXT: sbc.f 0, %r0, %r2
; CHECK-NEXT: b{{lo|hs}} {{.*}}LBB
; CHECK-NOT:  bbit
; CHECK-NOT:  b @
define i32 @t_i64_ult_br(i64 %a, i64 %b) {
  %c = icmp ult i64 %a, %b
  br i1 %c, label %t, label %f
t:
  ret i32 1
f:
  ret i32 0
}

; CHECK-LABEL: t_i64_uge_br:
; CHECK:      cmp %r1, %r3
; CHECK-NEXT: sbc.f 0, %r0, %r2
; CHECK-NEXT: b{{lo|hs}} {{.*}}LBB
; CHECK-NOT:  bbit
; CHECK-NOT:  b @
define i32 @t_i64_uge_br(i64 %a, i64 %b) {
  %c = icmp uge i64 %a, %b
  br i1 %c, label %t, label %f
t:
  ret i32 1
f:
  ret i32 0
}

; ---------------------------------------------------------------------------
; SIGNED -- the same carry sequence, over bit-31-biased high words.
;
; A signed fast path that read STATUS32.V after `sbc.f` (mov.lt / mov.ge) would
; require V to equal the true 64-bit signed overflow. That is UNCHARACTERIZED on
; this silicon (isa-characterization.md section 10.2 puts per-encoding
; conditional flag behaviour outside the proven surface, and SBC appears nowhere
; in that document; section 5.4 proves C = borrow for SUB/CMP only).
;
; So signed does not read V at all. Flipping bit 31 of BOTH high words maps the
; signed order onto the unsigned order (offset binary):
;
;     x <s y   <=>   (x ^ 0x80000000) <u (y ^ 0x80000000)
;
; leaving the low words alone (already unsigned in both readings). The compare
; is then the PROVEN unsigned one, reading only the carry:
;
;     bxor %rH, %rH, 31   ; non-.f -- must not disturb the borrow
;     bxor %rH', %rH', 31
;     cmp  <lo>, <lo>
;     sbc.f 0, <hi'>, <hi'>
;     Bcc / mov.cc        ; SAME "lo"/"hs" polarity -- the bias moves the
;                         ; operands, never the condition code
;
; 5 insns / 20 bytes (branch) or 6 / 24 (value), against 9 / 36 for the
; getSelect fallback this replaces.
;
; The two `bxor` MUST be flag-free (F=0 in ARC_BXOR_a_b_u6, byte-verified:
; 0x205207C0 -> `bxor r0, r0, 0x1F`, bit 15 clear) and must precede the `cmp` --
; they do, by data dependence, since they feed the compare's operands.
;
; mov.lt / mov.ge / b.lt / b.ge MUST NOT appear here: any of them means someone
; has started reading V without the measurement that licenses it. See the
; "THE PROBE THAT WOULD SETTLE V" note in ARCISelLowering.cpp's LowerSETCCCARRY
; -- one silicon run over the boundary set settles it and buys back 8 bytes.
; ---------------------------------------------------------------------------

; Big-endian split: %a = r0:r1 (hi:lo), %b = r2:r3 (hi:lo), so the HIGH words
; biased are r0 and r2 -- never r1/r3.
;
; CHECK-DAG, not CHECK-NEXT, for the two `bxor`: they are independent of each
; other, so the scheduler is free to emit them in either order (it currently
; picks %r2 first here and %r0 first in t_i64_sgt_setcc below -- both correct).
; What must hold is asserted: both HIGH words are biased, and the DAG group is
; terminated by the `cmp`, so both necessarily precede it.
; CHECK-LABEL: t_i64_slt_setcc:
; CHECK-DAG:  bxor %r0, %r0, 31
; CHECK-DAG:  bxor %r2, %r2, 31
; CHECK:      cmp %r1, %r3
; CHECK-NEXT: sbc.f 0, %r0, %r2
; CHECK:      mov.lo
; CHECK-NOT:  mov.lt
; CHECK-NOT:  mov.ge
define i32 @t_i64_slt_setcc(i64 %a, i64 %b) {
  %c = icmp slt i64 %a, %b
  %r = zext i1 %c to i32
  ret i32 %r
}

; Exact polarity mirror of t_i64_slt_setcc: >= is carry-CLEAR.
; CHECK-LABEL: t_i64_sge_setcc:
; CHECK-DAG:  bxor %r0, %r0, 31
; CHECK-DAG:  bxor %r2, %r2, 31
; CHECK:      cmp %r1, %r3
; CHECK-NEXT: sbc.f 0, %r0, %r2
; CHECK:      mov.hs
; CHECK-NOT:  mov.lt
; CHECK-NOT:  mov.ge
define i32 @t_i64_sge_setcc(i64 %a, i64 %b) {
  %c = icmp sge i64 %a, %b
  %r = zext i1 %c to i32
  ret i32 %r
}

; a >s b: SETCCCARRY only knows LT/GE, so IntegerExpandSetCCOperands rewrites
; SGT to SLT by SWAPPING the operands -- the signed mirror of t_i64_ugt_setcc.
; The bias must follow the operands onto the swapped high words.
; CHECK-LABEL: t_i64_sgt_setcc:
; CHECK:      bxor
; CHECK:      cmp %r3, %r1
; CHECK-NEXT: sbc.f 0, %r2, %r0
; CHECK:      mov.lo
; CHECK-NOT:  mov.lt
define i32 @t_i64_sgt_setcc(i64 %a, i64 %b) {
  %c = icmp sgt i64 %a, %b
  %r = zext i1 %c to i32
  ret i32 %r
}

; The signed BRANCH form: no boolean is materialized here either. This is the
; case that would silently regress if performSetccCarryBrCombine's condition-code
; gate ever fell out of step with LowerSETCCCARRY's -- the compare would be
; materialized as a 0/1 and re-tested by a `brne`.
; CHECK-LABEL: t_i64_slt_br:
; CHECK-DAG:  bxor %r0, %r0, 31
; CHECK-DAG:  bxor %r2, %r2, 31
; CHECK:      cmp %r1, %r3
; CHECK-NEXT: sbc.f 0, %r0, %r2
; CHECK-NEXT: b{{lo|hs}} {{.*}}LBB
; CHECK-NOT:  bbit
; CHECK-NOT:  brne
define i32 @t_i64_slt_br(i64 %a, i64 %b) {
  %c = icmp slt i64 %a, %b
  br i1 %c, label %t, label %f
t:
  ret i32 1
f:
  ret i32 0
}

; A SIGNED constant RHS: the bias on the constant high word costs NOTHING. It
; is XOR of two constants, so it folds inside getNode (0x12345678 ^ 0x80000000
; = 0x92345678 = -1842063752, materialized directly as the compare's operand)
; and only the VARIABLE side keeps a real `bxor` -- exactly one, never two.
; If a second `bxor` ever appears here, the fold has been lost.
; CHECK-LABEL: t_i64_slt_const:
; CHECK:      bxor
; CHECK-NOT:  bxor
; CHECK:      mov {{.*}}, -1842063752
; CHECK:      sbc.f 0,
define i32 @t_i64_slt_const(i64 %a) {
  %c = icmp slt i64 %a, 1311768467463790320 ; 0x123456789ABCDEF0
  %r = zext i1 %c to i32
  ret i32 %r
}

; ---------------------------------------------------------------------------
; Boundary vectors, as constant right-hand sides.
;
; These pin the SHAPE at each interesting 64-bit boundary. The value-level
; boundary classes the sequence has to get right -- hi-equal/lo-differ,
; hi-differ/lo-equal, hi-differ/lo-differ, and the 0 / 1 / UINT64_MAX /
; 0x8000000000000000 extremes -- are RUNTIME input classes that no FileCheck
; assertion can distinguish (they all compile to the same three instructions).
; They are proven by the 200,784-vector differential against the emulator's ALU
; model described in the header, which covers every one of those classes
; explicitly with 0 mismatches. What the tests below pin is the complementary
; half: which shapes reach the fused path at all. Several fold before
; SETCCCARRY is ever built, because the legalizer short-circuits a compare
; whose high half is a known constant -- correct and expected, and each one is
; asserted here so a future change cannot silently route them onto the carry
; sequence.
; ---------------------------------------------------------------------------

; a <u 0 is universally false -- must fold to a constant 0, never a compare.
; CHECK-LABEL: t_i64_ult_zero:
; CHECK-NOT:  cmp
; CHECK-NOT:  sbc.f
; CHECK:      mov %r0, 0
define i32 @t_i64_ult_zero(i64 %a) {
  %c = icmp ult i64 %a, 0
  %r = zext i1 %c to i32
  ret i32 %r
}

; a <u 1 is a == 0: an OR of the halves against zero, no SETCCCARRY needed
; (IntegerExpandSetCCOperands rewrites ULT-1 to EQ-0 before reaching it).
; CHECK-LABEL: t_i64_ult_one:
; CHECK-NOT:  sbc.f
define i32 @t_i64_ult_one(i64 %a) {
  %c = icmp ult i64 %a, 1
  %r = zext i1 %c to i32
  ret i32 %r
}

; a <u UINT64_MAX is a != UINT64_MAX -- the legalizer's equality-to-all-ones
; special case (AND of the halves), not a SETCCCARRY.
; CHECK-LABEL: t_i64_ult_umax:
; CHECK-NOT:  sbc.f
define i32 @t_i64_ult_umax(i64 %a) {
  %c = icmp ult i64 %a, 18446744073709551615
  %r = zext i1 %c to i32
  ret i32 %r
}

; a <u 0x8000000000000000 is a sign-bit test on the HIGH half only: the
; legalizer looks at the top word alone and never builds a SETCCCARRY.
; CHECK-LABEL: t_i64_ult_signbit:
; CHECK-NOT:  sbc.f
define i32 @t_i64_ult_signbit(i64 %a) {
  %c = icmp ult i64 %a, 9223372036854775808
  %r = zext i1 %c to i32
  ret i32 %r
}

; Genuinely two-word constant: both halves non-zero and neither equal nor
; all-ones, so none of the legalizer's short-circuits apply and this is the
; real fused path with a materialized constant operand. (Baseline for
; comparison: this compiled to the full 9-instruction getSelect sequence.)
; CHECK-LABEL: t_i64_ult_bothwords:
; CHECK:      sbc.f 0,
; CHECK:      mov.lo
define i32 @t_i64_ult_bothwords(i64 %a) {
  %c = icmp ult i64 %a, 1311768467463790320 ; 0x123456789ABCDEF0
  %r = zext i1 %c to i32
  ret i32 %r
}

; ---------------------------------------------------------------------------
; i128: exercises the OTHER carry shape.
;
; ExpandIntOp_SETCCCARRY (the i128-and-wider path) builds its SETCCCARRY with
; an ISD::USUBO_CARRY carry rather than an ISD::USUBO, so matchLowBorrow
; declines and LowerSETCCCARRY takes its general identity fallback
; (`C ? (L <= R) : (L < R)`), which assumes nothing about the carry's producer.
; This is purely a "stays correct and does not crash" test: before SETCCCARRY
; was Custom this path could not be reached at all, and returning SDValue()
; from the Custom hook would NOT decline gracefully -- LegalizeDAG falls a
; Custom hook through to Expand, and ISD::SETCCCARRY has no expansion, so an
; unhandled shape here is a hard failure rather than a fallback.
; (An `sbc.f` may legitimately appear here from the 128-bit subtract's own
; ADDC/ADDE chain -- that is unrelated to this compare, so it is not asserted
; either way.)
; CHECK-LABEL: t_i128_ult_setcc:
define i32 @t_i128_ult_setcc(i128 %a, i128 %b) {
  %c = icmp ult i128 %a, %b
  %r = zext i1 %c to i32
  ret i32 %r
}

; CHECK-LABEL: t_i128_slt_setcc:
define i32 @t_i128_slt_setcc(i128 %a, i128 %b) {
  %c = icmp slt i128 %a, %b
  %r = zext i1 %c to i32
  ret i32 %r
}

; ---------------------------------------------------------------------------
; Equality is untouched: SETEQ/SETNE return from IntegerExpandSetCCOperands
; before its SETCCCARRY construction (they lower to XOR/OR-against-zero), so
; flipping the gate must not disturb them.
; ---------------------------------------------------------------------------

; CHECK-LABEL: t_i64_eq:
; CHECK-NOT:  sbc.f
define i32 @t_i64_eq(i64 %a, i64 %b) {
  %c = icmp eq i64 %a, %b
  %r = zext i1 %c to i32
  ret i32 %r
}

; CHECK-LABEL: t_i64_ne:
; CHECK-NOT:  sbc.f
define i32 @t_i64_ne(i64 %a, i64 %b) {
  %c = icmp ne i64 %a, %b
  %r = zext i1 %c to i32
  ret i32 %r
}

; ---------------------------------------------------------------------------
; The i64 subtract itself must keep selecting sub.f + sbc.f into a REAL
; destination. This is the tripwire for the A-field trap: the new null-dest
; def hardcodes A=62 (r62, "discard the result"), and an accidental A=0 there
; would make `sbc.f` write %r0. If this test ever prints `sbc.f 0, ...` for an
; ordinary subtract, the two defs have been confused.
; CHECK-LABEL: t_i64_sub:
; CHECK:      sub.f %r1, %r1, %r3
; CHECK-NEXT: sbc.f %r0, %r0, %r2
define i64 @t_i64_sub(i64 %a, i64 %b) {
  %r = sub i64 %a, %b
  ret i64 %r
}
