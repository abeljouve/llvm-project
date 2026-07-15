; RUN: llc -march=arceb -mcpu=bcm55030 < %s | FileCheck %s
; RUN: llc -march=arc -mcpu=generic < %s | FileCheck %s --check-prefix=NOARCOMPACT
; RUN: llc -march=arceb -mcpu=bcm55030 -verify-machineinstrs < %s | FileCheck %s --check-prefix=VERIFY
;
; Flag-recycling compares (dossier 21 idea 3): two rewrites, each firing
; ONLY when the compared constant would otherwise need an 8-byte LIMM.
;
;   (i)  `x <u 2^K` (K such that 2^K > 2047, i.e. it would not fit a 4-byte
;        cmp/mov immediate form) -> `lsr.f 0, x, K` (null-destination shift,
;        discards the result, sets Z = ((x>>K)==0) = the ult predicate
;        directly) instead of an 8-byte LIMM compare.
;   (ii) `(x & (2^(K+1)-1)) == 0` with the mask too wide for s12
;        (2^(K+1)-1 > 2047) -> `bmsk.f 0, x, K` (null-destination mask,
;        discards the result, sets Z from the masked value) instead of an
;        8-byte LIMM mask + separate compare.
;
; Both consumers (select and branch) are covered: SELECT_CC folds at the
; SelectionDAG level (ARCISD::LSRTEST / ARCISD::BMSKTEST, mirroring the
; committed BTST modeling in arc700eb-btst.ll); BR_CC is unaffected at the
; SelectionDAG level and instead fuses post-ISel in ARCBranchFinalize.cpp
; (same reason bbit0/bbit1 fusion there is a peephole and not a Pat -- see
; that file's comments). NOARCOMPACT confirms neither null-destination flag
; form is ARCompact-only-encoding-safe to emit on a non-ARCompact profile:
; the fold must not fire there, falling back to the generic mov/and+cmp
; sequence with no absent opcode.
;
; -verify-machineinstrs (VERIFY prefix, ARCompact target only): unlike
; arc700eb-btst.ll, none of these functions fuse into bbit0/bbit1 (that
; fusion's pre-existing, orthogonal MachineVerifier finding is BTST/bbit
; specific -- see that file's header), so MachineVerifier is expected clean
; here.

;===----------------------------------------------------------------------===
; (i) Unsigned range test: x <u 2^K -> lsr.f 0, x, K
;===----------------------------------------------------------------------===

; K = 12 (2^12 = 4096 > 2047): select form. The generic (target-independent)
; SelectionDAG combiner canonicalizes `x <u 2^K` into `(x>>K) == 0` well
; before LowerSELECT_CC runs (confirmed empirically, even at -O0) -- the
; ACTUAL DAG shape LowerSELECT_CC's LSRTEST fold sees is SETEQ/SETNE against
; a shifted value, not the raw SETULT/SETUGE this comment's IR is written
; with. `lsr.f` (the auto-generated null-destination form's `.f` sibling)
; prints with no destination operand at all, hence 2 operands (`%r0, 12`),
; not 3.
define i32 @range_ult_select_k12(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: range_ult_select_k12:
; CHECK-NOT: limm
; CHECK: lsr.f %r0, 12
; CHECK: mov.eq
; VERIFY-LABEL: range_ult_select_k12:
; NOARCOMPACT-LABEL: range_ult_select_k12:
; NOARCOMPACT-NOT: lsr.f
entry:
  %cmp = icmp ult i32 %x, 4096
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Inverse predicate (SETUGE): Z=0 -> NE, not EQ.
define i32 @range_uge_select_k12(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: range_uge_select_k12:
; CHECK: lsr.f %r0, 12
; CHECK: mov.ne
; VERIFY-LABEL: range_uge_select_k12:
entry:
  %cmp = icmp uge i32 %x, 4096
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; K = 30 (2^30 = 0x40000000): near the top of the valid K range. K = 31
; (2^31 = 0x80000000, the sign bit) is deliberately NOT tested here -- the
; generic combiner canonicalizes `x <u 0x80000000` into a SIGNED sign-bit
; test (`cmp x, -1` / `mov.gt`, i.e. `x >s -1`) instead of the shift shape,
; an equally-sized (8-byte), already-optimal, differently-shaped rewrite
; that is outside this dossier's scope (confirmed empirically; no lsr.f is
; missed here, just a different existing DAGCombine claims it first).
define i32 @range_ult_select_k30(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: range_ult_select_k30:
; CHECK: lsr.f %r0, 30
; CHECK: mov.eq
; VERIFY-LABEL: range_ult_select_k30:
entry:
  %cmp = icmp ult i32 %x, 1073741824
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Branch consumer: fuses post-ISel in ARCBranchFinalize.cpp. The same
; SETULT->SETEQ-vs-shifted-value canonicalization noted above means the
; producer actually sitting in front of the compare-and-branch pseudo is a
; dead value-producing `lsr` (LSR_rru6, the generic ARCv2-shape shift), not
; a LIMM-materializing `mov` -- matchRangeTestBRccShift in
; ARCBranchFinalize.cpp recognizes exactly that shape.
declare void @side_a()
declare void @side_b()

define void @range_ult_branch_k12(i32 %x) {
; CHECK-LABEL: range_ult_branch_k12:
; CHECK-NOT: limm
; CHECK: lsr.f %r0, 12
; CHECK: b{{eq|ne}}
; VERIFY-LABEL: range_ult_branch_k12:
; NOARCOMPACT-LABEL: range_ult_branch_k12:
; NOARCOMPACT-NOT: lsr.f
entry:
  %cmp = icmp ult i32 %x, 4096
  br i1 %cmp, label %if.then, label %if.else
if.then:
  call void @side_a()
  ret void
if.else:
  call void @side_b()
  ret void
}

; Branch consumer, inverse predicate.
define void @range_uge_branch_k12(i32 %x) {
; CHECK-LABEL: range_uge_branch_k12:
; CHECK: lsr.f %r0, 12
; CHECK: b{{eq|ne}}
; VERIFY-LABEL: range_uge_branch_k12:
entry:
  %cmp = icmp uge i32 %x, 4096
  br i1 %cmp, label %if.then, label %if.else
if.then:
  call void @side_a()
  ret void
if.else:
  call void @side_b()
  ret void
}

; Negative: x <u 8 (2^3 = 8 <= 2047, fits a 4-byte immediate cmp already) --
; must stay byte-stable, no lsr.f.
define i32 @range_ult_select_small_k3(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: range_ult_select_small_k3:
; CHECK-NOT: lsr.f
; CHECK: cmp %r0, 8
; CHECK: mov.lo
; VERIFY-LABEL: range_ult_select_small_k3:
entry:
  %cmp = icmp ult i32 %x, 8
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Negative: SIGNED predicate against the same power-of-two constant must
; keep the materialized-operand cmp path -- lsr.f is only proven equivalent
; to the UNSIGNED ult/uge predicates.
define i32 @range_slt_select_k12(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: range_slt_select_k12:
; CHECK-NOT: lsr.f
; CHECK: cmp %r0, 4096
; VERIFY-LABEL: range_slt_select_k12:
entry:
  %cmp = icmp slt i32 %x, 4096
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

;===----------------------------------------------------------------------===
; (ii) Low-mask zero test: (x & (2^(K+1)-1)) == 0 -> bmsk.f 0, x, K
;===----------------------------------------------------------------------===

; K = 11 (mask = 0xFFF = 4095 > 2047): select form, EQ.
define i32 @mask_eq_select_k11(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: mask_eq_select_k11:
; CHECK-NOT: limm
; CHECK: bmsk.f %r0, 11
; CHECK: mov.eq
; VERIFY-LABEL: mask_eq_select_k11:
; NOARCOMPACT-LABEL: mask_eq_select_k11:
; NOARCOMPACT-NOT: bmsk.f
entry:
  %and = and i32 %x, 4095
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; NE form.
define i32 @mask_ne_select_k11(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: mask_ne_select_k11:
; CHECK: bmsk.f %r0, 11
; CHECK: mov.ne
; VERIFY-LABEL: mask_ne_select_k11:
entry:
  %and = and i32 %x, 4095
  %cmp = icmp ne i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; K = 30 (mask = 0x7FFFFFFF): near the top of the valid range, one below the
; all-ones exclusion.
define i32 @mask_eq_select_k30(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: mask_eq_select_k30:
; CHECK: bmsk.f %r0, 30
; CHECK: mov.eq
; VERIFY-LABEL: mask_eq_select_k30:
entry:
  %and = and i32 %x, 2147483647
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Branch consumer: fuses post-ISel in ARCBranchFinalize.cpp (a dead
; preceding `and %rN, %r0, 4095` feeding the immediate compare-vs-zero
; BRcc pseudo is replaced by bmsk.f + beq).
define void @mask_eq_branch_k11(i32 %x) {
; CHECK-LABEL: mask_eq_branch_k11:
; CHECK-NOT: limm
; CHECK: bmsk.f %r0, 11
; CHECK: b{{eq|ne}}
; VERIFY-LABEL: mask_eq_branch_k11:
; NOARCOMPACT-LABEL: mask_eq_branch_k11:
; NOARCOMPACT-NOT: bmsk.f
entry:
  %and = and i32 %x, 4095
  %cmp = icmp eq i32 %and, 0
  br i1 %cmp, label %if.then, label %if.else
if.then:
  call void @side_a()
  ret void
if.else:
  call void @side_b()
  ret void
}

; Branch consumer, NE.
define void @mask_ne_branch_k11(i32 %x) {
; CHECK-LABEL: mask_ne_branch_k11:
; CHECK: bmsk.f %r0, 11
; CHECK: b{{eq|ne}}
; VERIFY-LABEL: mask_ne_branch_k11:
entry:
  %and = and i32 %x, 4095
  %cmp = icmp ne i32 %and, 0
  br i1 %cmp, label %if.then, label %if.else
if.then:
  call void @side_a()
  ret void
if.else:
  call void @side_b()
  ret void
}

; Negative: mask = 0xFF (255 <= 2047, already a 4-byte `and` + `cmp`) --
; must stay byte-stable, no bmsk.f.
define i32 @mask_eq_select_small(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: mask_eq_select_small:
; CHECK-NOT: bmsk.f
; VERIFY-LABEL: mask_eq_select_small:
entry:
  %and = and i32 %x, 255
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Negative: single-bit mask (power of two) is BTST's territory, not
; BMSKTEST's -- de-confliction with the committed dossier-24 fold. A
; single-bit mask never satisfies isMask_32 for k>=2, and the one point
; that is simultaneously a single bit and a 1-bit contiguous run (mask=1)
; is nowhere near the LIMM gate, so BTST always claims it uncontested.
define i32 @mask_eq_select_single_bit(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: mask_eq_select_single_bit:
; CHECK-NOT: bmsk.f
; CHECK: btst %r0, 12
; VERIFY-LABEL: mask_eq_select_single_bit:
entry:
  %and = and i32 %x, 4096
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Negative: all-ones mask (0xFFFFFFFF, i.e. `and x, -1`) degenerates to a
; plain `x == 0` test -- bmsk_mask_hi's own guard excludes it (already
; optimal without bmsk), so this must never emit bmsk.f either.
define i32 @mask_eq_select_all_ones(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: mask_eq_select_all_ones:
; CHECK-NOT: bmsk.f
; VERIFY-LABEL: mask_eq_select_all_ones:
entry:
  %and = and i32 %x, -1
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}
