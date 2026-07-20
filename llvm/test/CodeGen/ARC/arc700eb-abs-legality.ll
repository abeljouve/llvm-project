; RUN: llc -march=arceb -mcpu=bcm55030 < %s | FileCheck %s --check-prefix=ARCOMPACT
; RUN: llc -march=arceb -mcpu=arc700eb < %s | FileCheck %s --check-prefix=ARCOMPACT
; RUN: llc -march=arc -mcpu=arc700 < %s | FileCheck %s --check-prefix=ARCOMPACT
; RUN: llc -march=arc -mcpu=generic < %s | FileCheck %s --check-prefix=NOARCOMPACT
; RUN: llc -mtriple=arceb-unknown-elf < %s | FileCheck %s --check-prefixes=NOARCOMPACT,FEATURELESS
; RUN: llc -march=arc -mcpu=generic < %s | not grep -E "abs %r"
; RUN: llc -mtriple=arceb-unknown-elf < %s | not grep -E "abs %r"

; ISD::ABS must keep its action in lockstep with the predicate on its only
; selection pattern. `abs b,c` is an ARCompact-only opcode with no ARCv2
; encoding, so its Pat lives under `let Predicates = [IsARCompact]` in
; ARCARCompactPatterns.td. An unconditional Legal action left every
; non-ARCompact subtarget with a legal node and no pattern able to select it,
; i.e. a hard "LLVM ERROR: Cannot select: i32 = abs" compiler crash.
;
; Two RUN lines above cover the two distinct non-ARCompact configurations that
; crashed, which are NOT the same thing:
;   -mcpu=generic          -- FeatureMPY + FeatureSEXT + FeatureBitScan.
;   no -mcpu at all        -- an empty CPU string matches no `Proc` in ARC.td,
;                             so NO features are set: this is a featureless
;                             config, not `generic`. Only IsBigEndian gets set,
;                             via the arceb triple fallback in ARCSubtarget.
; The featureless one is the config an LTO link reaches when the link line
; omits --plugin-opt=mcpu=.
;
; NOTE -- the bare-triple RUN line is DELIBERATE here, and this test is the one
; place in CodeGen/ARC that keeps one. Its sibling tests (alu.ll, brcc.ll,
; call.ll, ldst.ll, ...) were repinned onto -mcpu=generic plus the real ARC700
; profiles, because pinning a POSITIVE opcode expectation on a featureless
; pseudo-subtarget freezes a lowering no shipping configuration ever runs. This
; test asserts the opposite kind of property: a NEGATIVE safety invariant --
; must not crash, must not emit an opcode this silicon lacks -- on a config that
; is genuinely reachable. Guarding a reachable config against crashing is
; legitimate precisely BECAUSE it is reachable, so do not "modernise" line 5
; away.
;
; It is also not redundant with -mcpu=generic: see the FEATURELESS checks on
; sdiv_by_3 below, which only that config exercises.
;
; On non-ARCompact, Expand routes through TargetLowering::expandABS, which
; prefers smax(x, sub(0,x)) because ISD::SUB and ISD::SMAX are both Legal on
; every ARC subtarget -- selecting as rsub+max. That preserves the wrapping,
; non-saturating semantics ABS has on this silicon: ABS(INT_MIN) == INT_MIN,
; since 0-INT_MIN wraps to INT_MIN and smax(INT_MIN, INT_MIN) == INT_MIN.

declare i32 @llvm.abs.i32(i32, i1)

; The minimal reproducer: a bare abs intrinsic, no division anywhere in the
; function. This is provenance (i) -- it refutes the idea that the crash came
; from the constant-divisor synthesis path, and it is what plain source-level
; abs() / labs() / (x < 0 ? -x : x) lowers to at every -O level.
define i32 @abs_intrinsic(i32 %a) {
; ARCOMPACT-LABEL: abs_intrinsic:
; ARCOMPACT: abs %r0, %r0
; ARCOMPACT-NOT: max
;
; NOARCOMPACT-LABEL: abs_intrinsic:
; NOARCOMPACT: rsub [[NEG:%r[0-9]+]], %r0, 0
; NOARCOMPACT: max %r0, %r0, [[NEG]]
  %r = call i32 @llvm.abs.i32(i32 %a, i1 false)
  ret i32 %r
}

; The hand-written idiom, reached without any intrinsic. Deliberately NOT
; checked for an exact non-ARCompact sequence: the DAGCombiner fold that turns
; this select into ISD::ABS is itself gated on ABS being legal-or-custom, so
; making ABS Expand legitimately means the idiom may simply stay a select
; there. The only invariant this case must hold on non-ARCompact is "does not
; crash, and does not emit the absent opcode" -- covered by the label match
; plus the `not grep "abs %r"` RUN lines above.
define i32 @abs_idiom(i32 %a) {
; ARCOMPACT-LABEL: abs_idiom:
; ARCOMPACT: abs %r0, %r0
;
; NOARCOMPACT-LABEL: abs_idiom:
  %neg = sub i32 0, %a
  %cmp = icmp slt i32 %a, 0
  %r = select i1 %cmp, i32 %neg, i32 %a
  ret i32 %r
}

; Provenance (ii): performSDivRemCombine synthesizes sdiv-by-constant as
; ABS + unsigned reciprocal + sign-adjust. It gates on !hasMPY() only, NOT on
; isARCompact(), so on the featureless config it fires and emits a bare
; ISD::ABS -- a second, independent route into the same crash. (On
; -mcpu=generic the combine declines because MPY is present, and the generic
; BuildSDIV reciprocal handles it via mpym instead, so no ABS is created
; there; hence only a loose check for the shared NOARCOMPACT prefix here.)
;
; The expansion itself is therefore pinned under the FEATURELESS prefix rather
; than the shared one -- it cannot go on the shared prefix, because
; -mcpu=generic legitimately emits mpym here and would fail it. That makes the
; featureless RUN line the only one covering provenance (ii), so it is not
; deletable. (Prose here must never write a prefix name directly followed by a
; colon: FileCheck would parse it as a directive.)
;
; The -NOT patterns here are deliberately BARE mnemonics, not the operand-
; suffixed "mpy %r" form that alu.ll uses. That suffix is required *there*
; because alu.ll contains functions literally named mpy_r / mpy_u6 / mpy_limm,
; so a bare "mpy" would match the emitted label and self-satisfy. No function
; in this file is named that way, and neither "mpy" nor "max" occurs anywhere
; in any of these subtargets' output, so the bare form is safe here -- and it
; is strictly stronger, because it also catches mpyh / mpyhu / mpy_s and any
; other mpy* mnemonic that an operand-suffixed pattern would let through.
; (Prose here must never write a prefix name directly followed by a colon:
; FileCheck would parse it as a directive.)
define i32 @sdiv_by_3(i32 %a) {
; ARCOMPACT-LABEL: sdiv_by_3:
; ARCOMPACT: abs %r
; ARCOMPACT-NOT: mpy
;
; NOARCOMPACT-LABEL: sdiv_by_3:
; NOARCOMPACT-NOT: abs %r
;
; FEATURELESS: rsub [[NEG:%r[0-9]+]], %r0, 0
; FEATURELESS: max %r{{[0-9]+}}, %r0, [[NEG]]
; FEATURELESS-NOT: mpy
  %r = sdiv i32 %a, 3
  ret i32 %r
}
