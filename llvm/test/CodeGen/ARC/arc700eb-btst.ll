; RUN: llc -march=arceb -mcpu=bcm55030 < %s | FileCheck %s
; RUN: llc -march=arc -mcpu=generic < %s | FileCheck %s --check-prefix=NOARCOMPACT
;
; No -verify-machineinstrs here: @bit_test_branch_in_range below exercises
; the already-committed bbit0/1 fusion (dossier 07, ARCBranchFinalize.cpp)
; for de-confliction, and that fusion has a PRE-EXISTING, orthogonal
; MachineVerifier finding ("MBB has unexpected successors...") independent
; of BTST -- reproduced on unmodified HEAD (90eea7161587) with a plain
; AND+BRcc bit-test-branch, so it is not a regression from this dossier.
; Every BTST-producing function in this file (all but the last) was
; separately confirmed -verify-machineinstrs-clean via llc -O0/-O2 and
; -mcpu=arc700/bcm55030/generic during development; see dossier 24 commit
; notes. Root-caused as ARCInstrInfo::analyzeBranch not recognizing
; ARC_BBIT0/1 as an analyzable conditional terminator -- worth its own
; docs/bugs/ entry, out of scope for the BTST def fix.

; BTST def fix + bit-test fold (dossier 24): the auto-generated BTST
; defs had a bogus (outs GPR32:$rb) and no Defs=[STATUS32] -- BTST is
; compare-like (writes only STATUS32, per docs/isa/07-alu-32bit.md). A bit
; test `(x & mask) ==/!= 0` selects to a single `btst` on ARCompact
; subtargets instead of the generic mov-mask + and + cmp expansion.
;
; NOARCOMPACT confirms the negative-subtarget case: on a non-ARCompact
; profile (BTST is an ARCompact-only encoding) the fold must not fire --
; fall back to the generic and/cmp sequence, no absent opcode emitted.
;
; getBitTestOperands (ARCISelLowering.cpp) additionally peels through the
; canonical `(x>>n)&1` shape that the generic SelectionDAG combiner
; rewrites `x & (1<<n)` into ahead of this lowering, so the register-form
; Pat is reachable from ordinary C (@bit_test_reg_pos_natural) and the
; constant-N case (@bit_test_const_via_srl_and1) doesn't pay for an extra
; `lsr`. See those two tests below for the natural (no-workaround) idiom.

; Constant bit position, bit 0 (edge case): btst reg, u6.
define i32 @bit_test_const_bit0(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: bit_test_const_bit0:
; CHECK: btst %r0, 0
; CHECK: mov.eq
; NOARCOMPACT-LABEL: bit_test_const_bit0:
; NOARCOMPACT-NOT: btst
entry:
  %and = and i32 %x, 1
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Constant bit position, mid-range.
define i32 @bit_test_const_bit5(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: bit_test_const_bit5:
; CHECK: btst %r0, 5
; CHECK: mov.eq
; NOARCOMPACT-LABEL: bit_test_const_bit5:
; NOARCOMPACT-NOT: btst
entry:
  %and = and i32 %x, 32
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Constant bit position, bit 30 (near sign bit but not the sign bit itself,
; so the sign-test canonicalization below does not preempt btst).
define i32 @bit_test_const_bit30(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: bit_test_const_bit30:
; CHECK: btst %r0, 30
; CHECK: mov.eq
entry:
  %and = and i32 %x, 1073741824
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Bit 31 (sign bit, mask = 0x80000000). Regression check for a real bug
; found while writing this test: `pow2_mask` (ARCARCompactPatterns.td)
; treats its ImmLeaf `Imm` as a sign-extended int64_t, so 0x80000000
; sign-extends to a NEGATIVE value and the predicate's un-cast `Imm > 0`
; incorrectly rejected exactly this bit position -- an unselectable
; ARCISD::BTST node (hard ISel crash, not a soft fallback) for any i32 AND
; mask of 0x80000000 reaching LowerSELECT_CC. Fixed by casting to uint32_t
; before the power-of-2 test, matching the established bit_pos_hi /
; bclr_mask_hi / bmsk_mask_hi idiom already in the same file. (Clang's IR
; frontend separately canonicalizes `(x & 0x80000000) == 0` into a sign
; compare at the InstCombine level before this ever reaches SelectionDAG,
; so this exact IR shape is only reachable from raw/unoptimized IR like
; this test -- which is exactly how the bug was found.)
define i32 @bit_test_const_bit31(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: bit_test_const_bit31:
; CHECK: btst %r0, 31
; CHECK: mov.eq
entry:
  %and = and i32 %x, -2147483648
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; SETNE against zero also folds (mirrors SETEQ; the cmov CC is NE, not
; inverted -- ISDCCtoARCCC(SETNE) = ARCCC::NE, matching the non-fold cmp+cmov
; baseline exactly, so TVal is selected precisely when the tested bit is
; set).
define i32 @bit_test_const_setne(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: bit_test_const_setne:
; CHECK: btst %r0, 1
; CHECK: mov.ne
entry:
  %and = and i32 %x, 2
  %cmp = icmp ne i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Register bit position (`x & (1 << n)`) with the mask kept live past the
; AND (stored to memory too) so the generic shift-canonicalization DAG
; combine (which requires the AND to be single-use to avoid duplicating the
; shift) does not preempt the fold -- exercises the ARC_BTST_b_c register
; form directly.
define i32 @bit_test_reg_pos(i32 %x, i32 %n, i32 %a, i32 %b, ptr %maskout) {
; CHECK-LABEL: bit_test_reg_pos:
; CHECK: btst
; CHECK: mov.eq
entry:
  %mask = shl i32 1, %n
  store i32 %mask, ptr %maskout
  %and = and i32 %x, %mask
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Same register-bit-position idiom with NO workaround: plain `x & (1u<<n)`
; feeding a select. The generic (target-independent) SelectionDAG combiner
; canonicalizes this into `(x>>n)&1` before LowerSELECT_CC ever runs --
; confirmed empirically, including from hand-written IR using the literal
; `and(x, shl(1,n))` shape -- so recognizing only the raw shape above left
; the ARC_BTST_b_c register-form Pat unreachable from ordinary code, and
; cost an extra `lsr` even in the constant-N case. getBitTestOperands
; (ARCISelLowering.cpp) peels through the canonical `(srl X,N) & 1` shape
; and rebuilds the tested value/mask against the pre-shift X, so this now
; selects `btst %r0, %r1` directly with no preceding shift.
define i32 @bit_test_reg_pos_natural(i32 %x, i32 %n, i32 %a, i32 %b) {
; CHECK-LABEL: bit_test_reg_pos_natural:
; CHECK-NOT: lsr
; CHECK: btst %r0, %r1
; CHECK: mov.eq
entry:
  %mask = shl i32 1, %n
  %and = and i32 %x, %mask
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; Same peel-through-SRL fold, constant N: recognizing `(x>>5)&1` directly
; against the pre-shift x avoids the extra `lsr` that a naive "test operand
; as given" fold would still emit.
define i32 @bit_test_const_via_srl_and1(i32 %x, i32 %a, i32 %b) {
; CHECK-LABEL: bit_test_const_via_srl_and1:
; CHECK-NOT: lsr
; CHECK: btst %r0, 5
; CHECK: mov.eq
entry:
  %shr = lshr i32 %x, 5
  %and = and i32 %shr, 1
  %cmp = icmp eq i32 %and, 0
  %sel = select i1 %cmp, i32 %a, i32 %b
  ret i32 %sel
}

; A bit test that also feeds an in-range branch fuses into bbit0/bbit1
; (dossier 07, ARCBranchFinalize.cpp) rather than btst -- de-confliction:
; btst and bbit must never double-match the same node.
declare void @side_a()
declare void @side_b()

define void @bit_test_branch_in_range(i32 %x) {
; CHECK-LABEL: bit_test_branch_in_range:
; CHECK: bbit{{[01]}} %r0, 5
; CHECK-NOT: btst
entry:
  %and = and i32 %x, 32
  %cmp = icmp eq i32 %and, 0
  br i1 %cmp, label %if.then, label %if.else
if.then:
  call void @side_a()
  ret void
if.else:
  call void @side_b()
  ret void
}
