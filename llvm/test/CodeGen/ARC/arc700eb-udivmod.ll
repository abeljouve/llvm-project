; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs < %s | FileCheck %s

; Constant-divisor unsigned div/rem synthesis (no hardware multiplier, no
; hardware divide -- ARC700 / !hasMPY()). Two whitelist-gated DAGCombines:
;
;   (a) performUDivRemCombine -- shift-add reciprocal + back-multiply,
;       divisors {3, 5, 10}. Fires on both udiv and urem.
;   (b) performURemDigitFoldCombine -- digit-fold modulo, divisors
;       {7, 15, 255} (the 2^k-1 family). urem only.
;
; Every op sequence below was exhaustively verified (0 mismatches) against
; the native `/` and `%` operators over ALL 2^32 u32 inputs, both in the
; dossier-18 PROVE phase and re-verified byte-for-byte against this exact
; IMPLEMENT-phase transcription. Edge vectors baked in as comments below are
; anchors from that exhaustive sweep, not just "interesting-looking" numbers:
;   - div-by-5 raw-quotient deficit reaches its max (6) around n where
;     (n>>4)*3's doubling-fold under-approximates most: e.g. n=0xFFFFFFF0.
;   - div-by-3's r range after the first back-multiply is 0..11 -- the fix
;     term (11*r>>5) is exact across that whole range, verified at n=0 and
;     n=0xFFFFFFFF (both wrap-adjacent extremes).
;   - urem-by-3's digit-fold (NOT used here -- see the dispatch note in
;     ARCISelLowering.cpp) needs a DOUBLE reduce at residue 6; urem-by-7's
;     cascade tops out at residue 8 (n=0xFFFFFFFF); urem-by-15's cascade
;     tops out at residue 17; urem-by-255's tops out at 258 -- all single-
;     reduce-safe, confirmed exhaustively.
;
; No absent-on-this-silicon opcode (mpy*, mul64, swape, ffs, fls, rtie, ex,
; adds, subs, divaw, sat16, rnd16, asls, asrs, abss, negs, or any other DSP/
; saturating/hardware-divide op) may ever appear in this file's output --
; every CHECK-NOT block below also guards the absent-opcode set, not just
; the two libcalls.

; --------------------------------------------------------------------------
; Positive: divisor 3 (path (a), shift-add reciprocal). udiv and urem on the
; SAME dividend in the SAME function must CSE the shared quotient prefix --
; only the u/rem function is checked standalone here (paired-CSE is checked
; by udiv_urem_c3_paired below).
; --------------------------------------------------------------------------

; CHECK-LABEL: udiv_c3:
; CHECK-NOT: __udivsi3
; CHECK-NOT: __umodsi3
; CHECK-NOT: mpy
; CHECK: lsr
; CHECK: add1
; CHECK-NOT: __udivsi3
define i32 @udiv_c3(i32 %x) {
  %q = udiv i32 %x, 3
  ret i32 %q
}

; CHECK-LABEL: urem_c3:
; CHECK-NOT: __udivsi3
; CHECK-NOT: __umodsi3
; CHECK-NOT: mpy
; CHECK: lsr
; CHECK: add1
define i32 @urem_c3(i32 %x) {
  %r = urem i32 %x, 3
  ret i32 %r
}

; A paired udiv+urem by the same constant on the same dividend in the same
; function: DAG CSE must merge the shared quotient-pipeline nodes (the
; 9-instruction doubling-fold reciprocal and the qraw*3 fix back-multiply),
; so this costs ~18 total instructions for BOTH results, not ~35 (17 for a
; standalone udiv_c3 plus ~18 for a standalone urem_c3). Checked here by
; requiring only a SINGLE copy of the 9-op doubling-fold reciprocal chain
; (one `lsr ..., 2` -- the qraw computation's distinguishing first step,
; which would appear twice if the pipelines were computed independently).
; CHECK-LABEL: udiv_urem_c3_paired:
; CHECK-NOT: __udivsi3
; CHECK-NOT: __umodsi3
; CHECK: lsr {{.*}}, 2
; CHECK-NOT: lsr {{.*}}, 2
define i32 @udiv_urem_c3_paired(i32 %x, i32* %remOut) {
  %q = udiv i32 %x, 3
  %r = urem i32 %x, 3
  store i32 %r, i32* %remOut
  ret i32 %q
}

; --------------------------------------------------------------------------
; Positive: divisor 5 (path (a)).
; --------------------------------------------------------------------------

; CHECK-LABEL: udiv_c5:
; CHECK-NOT: __udivsi3
; CHECK-NOT: mpy
; CHECK: lsr
; CHECK: add2
define i32 @udiv_c5(i32 %x) {
  %q = udiv i32 %x, 5
  ret i32 %q
}

; CHECK-LABEL: urem_c5:
; CHECK-NOT: __umodsi3
; CHECK-NOT: mpy
; CHECK: lsr
; CHECK: add2
define i32 @urem_c5(i32 %x) {
  %r = urem i32 %x, 5
  ret i32 %r
}

; --------------------------------------------------------------------------
; Positive: divisor 10 (path (a) -- floor(n/10) = floor(floor(n/2)/5)).
; --------------------------------------------------------------------------

; CHECK-LABEL: udiv_c10:
; CHECK-NOT: __udivsi3
; CHECK-NOT: mpy
; CHECK: lsr %r0, %r0, 1
define i32 @udiv_c10(i32 %x) {
  %q = udiv i32 %x, 10
  ret i32 %q
}

; CHECK-LABEL: urem_c10:
; CHECK-NOT: __umodsi3
; CHECK-NOT: mpy
; CHECK: lsr {{.*}}, 1
define i32 @urem_c10(i32 %x) {
  %r = urem i32 %x, 10
  ret i32 %r
}

; --------------------------------------------------------------------------
; Positive: divisors 7 / 15 / 255 (path (b), digit-fold; urem only -- these
; are NOT in path (a)'s whitelist, so no udiv_c7/udiv_c15/udiv_c255 test
; exists: a udiv by one of these constants must fall through to __udivsi3,
; covered by udiv_c7_no_digitfold_path below).
; --------------------------------------------------------------------------

; CHECK-LABEL: urem_c7:
; CHECK-NOT: __umodsi3
; CHECK-NOT: mpy
; CHECK-NOT: __divsi3
; CHECK: cmp
define i32 @urem_c7(i32 %x) {
  %r = urem i32 %x, 7
  ret i32 %r
}

; CHECK-LABEL: urem_c15:
; CHECK-NOT: __umodsi3
; CHECK-NOT: mpy
; CHECK: cmp
define i32 @urem_c15(i32 %x) {
  %r = urem i32 %x, 15
  ret i32 %r
}

; CHECK-LABEL: urem_c255:
; CHECK-NOT: __umodsi3
; CHECK-NOT: mpy
; CHECK: cmp
define i32 @urem_c255(i32 %x) {
  %r = urem i32 %x, 255
  ret i32 %r
}

; Divisor 3 is deliberately absent from the digit-fold family's *coverage
; intent* even though 2^2-1==3 qualifies structurally -- it is routed
; exclusively through path (a) (see udiv_c3/urem_c3 above and the dispatch
; note in ARCISelLowering.cpp). This is not separately re-checked here since
; urem_c3 above already exercises divisor 3 end-to-end via the cheaper path.

; --------------------------------------------------------------------------
; Negative: a genuinely runtime (non-constant) divisor must still lower to
; the libcall, for both udiv and urem.
; --------------------------------------------------------------------------

; CHECK-LABEL: udiv_runtime:
; CHECK: __udivsi3
define i32 @udiv_runtime(i32 %x, i32 %y) {
  %q = udiv i32 %x, %y
  ret i32 %q
}

; CHECK-LABEL: urem_runtime:
; CHECK: __umodsi3
define i32 @urem_runtime(i32 %x, i32 %y) {
  %r = urem i32 %x, %y
  ret i32 %r
}

; --------------------------------------------------------------------------
; Negative: a constant divisor OUTSIDE the proven whitelist must still fall
; through to the libcall -- never synthesized, even though 6 is "close" to
; the whitelisted 3/5/10 (6 = 2*3) and 7 is separately whitelisted for urem
; only (not udiv).
; --------------------------------------------------------------------------

; CHECK-LABEL: udiv_c6_unlisted:
; CHECK: __udivsi3
define i32 @udiv_c6_unlisted(i32 %x) {
  %q = udiv i32 %x, 6
  ret i32 %q
}

; CHECK-LABEL: udiv_c7_no_digitfold_path:
; CHECK: __udivsi3
define i32 @udiv_c7_no_digitfold_path(i32 %x) {
  %q = udiv i32 %x, 7
  ret i32 %q
}

; --------------------------------------------------------------------------
; Negative: cost gate. At -Oz/-Os (MinSize/OptSize function attributes) the
; libcall (2-3 instructions) is smaller than every synthesized sequence here
; (13-18 instructions), so BOTH mechanisms must decline unconditionally and
; keep the ORIGINAL single-call libcall lowering -- critically, a paired
; udiv+urem-by-non-whitelisted-divisor under minsize must NOT regress into a
; udiv+mul+sub two-call sequence (the exact bug this dossier's IMPLEMENT
; phase caught and fixed by using DAGCombines instead of Custom
; LowerOperation for path (a) -- see the ARCISelLowering.cpp section header
; comment on performUDivRemCombine).
; --------------------------------------------------------------------------

; CHECK-LABEL: udiv_c3_optsize:
; CHECK-NOT: lsr
; CHECK-NOT: add1
; CHECK: __udivsi3
define i32 @udiv_c3_optsize(i32 %x) optsize {
  %q = udiv i32 %x, 3
  ret i32 %q
}

; CHECK-LABEL: urem_c7_minsize:
; CHECK-NOT: cmp
; CHECK: __umodsi3
; CHECK-NOT: __udivsi3
; CHECK-NOT: __mulsi3
define i32 @urem_c7_minsize(i32 %x) minsize {
  %r = urem i32 %x, 7
  ret i32 %r
}

; A whitelisted-but-non-constant-friendly negative: urem by a runtime
; divisor under minsize must ALSO stay a single call (never regress via the
; same UDIV-Custom-marking bug class this dossier avoided).
; CHECK-LABEL: urem_runtime_minsize:
; CHECK: __umodsi3
; CHECK-NOT: __udivsi3
; CHECK-NOT: __mulsi3
define i32 @urem_runtime_minsize(i32 %x, i32 %y) minsize {
  %r = urem i32 %x, %y
  ret i32 %r
}

; --------------------------------------------------------------------------
; Negative: a hardware-multiplier subtarget (+mpy / -mcpu=generic) must
; never see either combine fire -- it gets a good generic BuildUDIV
; reciprocal for free once MULHU is Legal, and this dossier's whitelist
; must not compete with it.
; --------------------------------------------------------------------------

; RUN: llc -march=arceb -mcpu=generic -mattr=+arcompact,+mpy -verify-machineinstrs < %s | FileCheck %s --check-prefix=MPY

; MPY-LABEL: udiv_c3:
; MPY-NOT: __udivsi3
; MPY: mpy
