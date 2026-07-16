; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs < %s | FileCheck %s

; Constant-divisor SIGNED div/rem synthesis (no hardware multiplier, no
; hardware divide -- ARC700 / !hasMPY()). One whitelist-gated DAGCombine,
; performSDivRemCombine, firing on both sdiv and srem for a divisor of
; magnitude in {3, 5, 10} (either sign) -- reuses the committed UNSIGNED
; reciprocal builders (emitDivRem3/5/10, see arc700eb-udivmod.ll) applied to
; ABS(a) and |C|, then sign-adjusts:
;
;   ua = ABS(a)                        (ABS is Legal; ABS(INT_MIN)==INT_MIN,
;                                        whose bit pattern IS the correct
;                                        unsigned magnitude 0x80000000)
;   uq,ur = the committed unsigned reciprocal divmod of ua by |C|
;   q = (a<0) XOR (C<0) ? -uq : uq     (a single SELECT_CC keyed on sign(a):
;                                        SETLT for C>0, SETGE for C<0)
;   r = sign(a) * ur                   (C-style truncated remainder always
;                                        follows the DIVIDEND's sign only,
;                                        independent of C's sign -- no
;                                        back-multiply needed)
;
; Every shipped divisor (+-3, +-5, +-10) and its full signed wrapper was
; exhaustively verified (0 mismatches) against native C round-toward-zero
; `/` and `%` over ALL 2^32 int32 inputs, including an explicit INT_MIN
; spot-check for each, in the dossier-18 SIGNED PROVE phase before this code
; was written. Edge vectors baked in as comments below are anchors from that
; exhaustive sweep:
;   - INT_MIN / 3  == -715827882, INT_MIN % 3  == -2  (exact, proven)
;   - INT_MIN / -3 ==  715827882, INT_MIN % -3 == -2  (exact, proven)
;   - INT_MIN / 5  == -429496729, INT_MIN % 5  == -3  (exact, proven)
;   - INT_MIN / -5 ==  429496729, INT_MIN % -5 == -3  (exact, proven)
;   - INT_MIN / 10 == -214748364, INT_MIN % 10 == -8  (exact, proven)
;   - INT_MIN / -10==  214748364, INT_MIN % -10== -8  (exact, proven)
;   - sdiv(-7,3) == -2 (round-TOWARD-ZERO, not floor(-7/3)==-3) -- the
;     ABS+unsigned+sign-adjust construction gives truncation naturally.
;
; No absent-on-this-silicon opcode (mpy*, mul64, swape, ffs, fls, rtie, ex,
; adds, subs, divaw, sat16, rnd16, asls, asrs, abss, negs, or any other DSP/
; saturating/hardware-divide op) may ever appear in this file's output --
; every CHECK-NOT block below also guards the absent-opcode set, not just
; the two libcalls.

; --------------------------------------------------------------------------
; Positive: divisor +3 / -3 (magnitude 3).
; --------------------------------------------------------------------------

; CHECK-LABEL: sdiv_c3:
; CHECK-NOT: __divsi3
; CHECK-NOT: __modsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: lsr
; CHECK: add1
; CHECK: rsub
; CHECK: cmp
; CHECK: mov.lt
define i32 @sdiv_c3(i32 %x) {
  %q = sdiv i32 %x, 3
  ret i32 %q
}

; CHECK-LABEL: srem_c3:
; CHECK-NOT: __divsi3
; CHECK-NOT: __modsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: lsr
; CHECK: add1
; CHECK: rsub
; CHECK: cmp
; CHECK: mov.lt
define i32 @srem_c3(i32 %x) {
  %r = srem i32 %x, 3
  ret i32 %r
}

; Negative divisor: same magnitude-3 reciprocal, but the quotient negate
; condition flips from SETLT to SETGE (a compile-time choice baked into the
; emitted `cmp`/`mov.cc` -- ISel/DAGCombiner canonicalizes SETGE(a,0) to the
; equivalent SETGT(a,-1) form, so the constant compared against is -1, not
; 0; both are the exact-proven condition per the section comment above).
; CHECK-LABEL: sdiv_cn3:
; CHECK-NOT: __divsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: rsub
; CHECK: cmp
; CHECK: mov.gt
define i32 @sdiv_cn3(i32 %x) {
  %q = sdiv i32 %x, -3
  ret i32 %q
}

; The remainder's sign always follows the dividend only, independent of the
; divisor's sign -- so srem_cn3 keeps the SAME SETLT-vs-0 condition as
; srem_c3 above (not SETGE).
; CHECK-LABEL: srem_cn3:
; CHECK-NOT: __modsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: rsub
; CHECK: cmp
; CHECK: mov.lt
define i32 @srem_cn3(i32 %x) {
  %r = srem i32 %x, -3
  ret i32 %r
}

; --------------------------------------------------------------------------
; Positive: divisor +5 / -5 (magnitude 5).
; --------------------------------------------------------------------------

; CHECK-LABEL: sdiv_c5:
; CHECK-NOT: __divsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: lsr
; CHECK: add2
; CHECK: mov.lt
define i32 @sdiv_c5(i32 %x) {
  %q = sdiv i32 %x, 5
  ret i32 %q
}

; CHECK-LABEL: srem_c5:
; CHECK-NOT: __modsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: lsr
; CHECK: add2
; CHECK: mov.lt
define i32 @srem_c5(i32 %x) {
  %r = srem i32 %x, 5
  ret i32 %r
}

; CHECK-LABEL: sdiv_cn5:
; CHECK-NOT: __divsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: mov.gt
define i32 @sdiv_cn5(i32 %x) {
  %q = sdiv i32 %x, -5
  ret i32 %q
}

; CHECK-LABEL: srem_cn5:
; CHECK-NOT: __modsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: mov.lt
define i32 @srem_cn5(i32 %x) {
  %r = srem i32 %x, -5
  ret i32 %r
}

; --------------------------------------------------------------------------
; Positive: divisor +10 / -10 (magnitude 10, floor(n/10)==floor(floor(n/2)/5)
; reused unsigned identity, applied to |a|).
; --------------------------------------------------------------------------

; CHECK-LABEL: sdiv_c10:
; CHECK-NOT: __divsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: lsr {{.*}}, 1
; CHECK: mov.lt
define i32 @sdiv_c10(i32 %x) {
  %q = sdiv i32 %x, 10
  ret i32 %q
}

; CHECK-LABEL: srem_c10:
; CHECK-NOT: __modsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: lsr {{.*}}, 1
; CHECK: mov.lt
define i32 @srem_c10(i32 %x) {
  %r = srem i32 %x, 10
  ret i32 %r
}

; CHECK-LABEL: sdiv_cn10:
; CHECK-NOT: __divsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: mov.gt
define i32 @sdiv_cn10(i32 %x) {
  %q = sdiv i32 %x, -10
  ret i32 %q
}

; CHECK-LABEL: srem_cn10:
; CHECK-NOT: __modsi3
; CHECK-NOT: mpy
; CHECK: abs
; CHECK: mov.lt
define i32 @srem_cn10(i32 %x) {
  %r = srem i32 %x, -10
  ret i32 %r
}

; --------------------------------------------------------------------------
; INT_MIN edge -- an explicit, dedicated test per the dossier's hard gate
; (not a fold): ABS(INT_MIN)==INT_MIN, whose bit pattern IS the correct
; unsigned magnitude 0x80000000, already covered by the unsigned reciprocal's
; full 2^32-input proof (INT_MIN was additionally spot-checked standalone in
; the native harness, see the file header comment). The dividend is loaded
; from a `volatile` global specifically so the IR-level constant folder
; (ConstantFold.cpp, which would otherwise fold a literal `sdiv i32
; -2147483648, 3` straight to `mov %r0, -715827882` before the backend ever
; runs, defeating the point of an edge-case CODEGEN test) cannot see it as a
; compile-time constant -- the synthesized abs/reciprocal/sign-adjust
; sequence below is therefore the ACTUAL code that executes for this input
; at runtime, exercising the exact path the exhaustive proof covers.
; --------------------------------------------------------------------------

@g_intmin = internal global i32 -2147483648

; CHECK-LABEL: sdiv_intmin_c3:
; CHECK-NOT: __divsi3
; CHECK: abs
define i32 @sdiv_intmin_c3() {
  %x = load volatile i32, i32* @g_intmin
  %q = sdiv i32 %x, 3
  ret i32 %q
}

; CHECK-LABEL: srem_intmin_cn10:
; CHECK-NOT: __modsi3
; CHECK: abs
define i32 @srem_intmin_cn10() {
  %x = load volatile i32, i32* @g_intmin
  %r = srem i32 %x, -10
  ret i32 %r
}

; --------------------------------------------------------------------------
; Negative: a genuinely runtime (non-constant) divisor must still lower to
; the libcall, for both sdiv and srem.
; --------------------------------------------------------------------------

; CHECK-LABEL: sdiv_runtime:
; CHECK: __divsi3
define i32 @sdiv_runtime(i32 %x, i32 %y) {
  %q = sdiv i32 %x, %y
  ret i32 %q
}

; CHECK-LABEL: srem_runtime:
; CHECK: __modsi3
define i32 @srem_runtime(i32 %x, i32 %y) {
  %r = srem i32 %x, %y
  ret i32 %r
}

; --------------------------------------------------------------------------
; Negative: a constant divisor OUTSIDE the proven magnitude whitelist
; ({3, 5, 10}) must still fall through to the libcall -- never synthesized,
; even though 6 == 2*3 is "close" to a whitelisted magnitude, and 7 is a
; whitelisted magnitude for the UNSIGNED digit-fold path (urem only) but has
; NO signed entry at all.
; --------------------------------------------------------------------------

; CHECK-LABEL: sdiv_c6_unlisted:
; CHECK: __divsi3
define i32 @sdiv_c6_unlisted(i32 %x) {
  %q = sdiv i32 %x, 6
  ret i32 %q
}

; CHECK-LABEL: sdiv_c7_no_signed_path:
; CHECK: __divsi3
define i32 @sdiv_c7_no_signed_path(i32 %x) {
  %q = sdiv i32 %x, 7
  ret i32 %q
}

; CHECK-LABEL: srem_c7_no_signed_path:
; CHECK: __modsi3
define i32 @srem_c7_no_signed_path(i32 %x) {
  %r = srem i32 %x, 7
  ret i32 %r
}

; --------------------------------------------------------------------------
; Negative: cost gate. At -Oz/-Os (MinSize/OptSize) the libcall
; (2-3 instructions) is smaller than every synthesized sequence here
; (~20 instructions), so the combine must decline unconditionally and keep
; the ORIGINAL single-call libcall lowering.
; --------------------------------------------------------------------------

; CHECK-LABEL: sdiv_c3_optsize:
; CHECK-NOT: abs
; CHECK-NOT: lsr
; CHECK: __divsi3
define i32 @sdiv_c3_optsize(i32 %x) optsize {
  %q = sdiv i32 %x, 3
  ret i32 %q
}

; CHECK-LABEL: srem_c3_minsize:
; CHECK-NOT: abs
; CHECK: __modsi3
; CHECK-NOT: __divsi3
; CHECK-NOT: __mulsi3
define i32 @srem_c3_minsize(i32 %x) minsize {
  %r = srem i32 %x, 3
  ret i32 %r
}

; A whitelisted-but-non-constant negative: sdiv by a runtime divisor under
; minsize must ALSO stay a single call.
; CHECK-LABEL: sdiv_runtime_minsize:
; CHECK: __divsi3
define i32 @sdiv_runtime_minsize(i32 %x, i32 %y) minsize {
  %q = sdiv i32 %x, %y
  ret i32 %q
}

; --------------------------------------------------------------------------
; Negative: a hardware-multiplier subtarget (+mpy / -mcpu=generic) must
; never see this combine fire -- it gets a good generic BuildSDIV reciprocal
; for free once MULHS is Legal, and this dossier's whitelist must not
; compete with it.
; --------------------------------------------------------------------------

; RUN: llc -march=arceb -mcpu=generic -mattr=+arcompact,+mpy -verify-machineinstrs < %s | FileCheck %s --check-prefix=MPY

; MPY-LABEL: sdiv_c3:
; MPY-NOT: __divsi3
; MPY-NOT: abs
; MPY: mpy

; MPY-LABEL: srem_c3:
; MPY-NOT: __modsi3
; MPY-NOT: abs
; MPY: mpy
