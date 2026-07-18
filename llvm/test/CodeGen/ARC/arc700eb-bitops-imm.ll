; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact < %s | FileCheck %s
; RUN: llc -march=arceb -mcpu=arc700eb -mattr=-arcompact < %s | FileCheck %s --check-prefix=NOCOMPACT
; RUN: llc -O0 -march=arceb -mcpu=arc700eb -mattr=+arcompact < %s | FileCheck %s --check-prefix=O0
; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact < %s | not grep -E "mpy|swape|\bffs\b|\bfls\b|rtie|\bex\b|adds|subs"

; Constant-bit-position bit ops. bset/bxor/bclr/bmsk with a compile-time bit
; must select ONLY where it strictly saves an 8-byte LIMM (high bit / wide
; mask). Low bits stay on the already-optimal u6/s12 or/and forms.
; (Function names avoid the mnemonics so CHECK-NOT can't match a .size label.)
;
; The trailing `not grep` RUN line is a whole-file forbidden-opcode sweep:
; none of the DSP/saturating/absent-silicon opcodes (mpy*, swape, ffs, fls,
; rtie, ex, adds, subs -- see docs/notes/isa-characterization.md) may ever
; appear in output compiled from this file, on ANY ARC700/BCM55030 profile.
; The second RUN line (-mattr=-arcompact) is the feature-negative check: the
; IsARCompact predicate must actually gate every bset/bxor/bclr/bmsk pattern
; below -- see the NOCOMPACT-NOT block at the bottom of the file.

; ============================================================================
; Section A: constant bit position, low end (byte-stable: no LIMM saved by a
; dedicated bit op vs. the already-optimal u6/s12 or/and/xor form).
; ============================================================================

; --- set bit 0 -> u6 `or`, no LIMM ---
define i32 @setbit_0(i32 %a) {
; CHECK-LABEL: setbit_0:
; CHECK: or %r0, %r0, 1
; CHECK-NOT: bset %r
  %r = or i32 %a, 1
  ret i32 %r
}

; --- toggle bit 0 -> u6 `xor` ---
define i32 @togglebit_0(i32 %a) {
; CHECK-LABEL: togglebit_0:
; CHECK: xor %r0, %r0, 1
; CHECK-NOT: bxor %r
  %r = xor i32 %a, 1
  ret i32 %r
}

; --- clear bit 0 -> u6/s12 `and` with -2 ---
define i32 @clearbit_0(i32 %a) {
; CHECK-LABEL: clearbit_0:
; CHECK: and %r0, %r0, -2
; CHECK-NOT: bclr %r
  %r = and i32 %a, -2
  ret i32 %r
}

; --- set bit 4 (mask 16) -> u6 `or` ---
define i32 @setbit_4(i32 %a) {
; CHECK-LABEL: setbit_4:
; CHECK: or %r0, %r0, 16
; CHECK-NOT: bset %r
  %r = or i32 %a, 16
  ret i32 %r
}

; --- set low bit (bit 5) must STAY the u6 `or` form (byte-stable) ---
define i32 @setbit_lo(i32 %a) {
; CHECK-LABEL: setbit_lo:
; CHECK: or %r0, %r0, 32
; CHECK-NOT: bset %r
  %r = or i32 %a, 32
  ret i32 %r
}

; --- toggle bit 5 (mask 32) -> u6 `xor` ---
define i32 @togglebit_5(i32 %a) {
; CHECK-LABEL: togglebit_5:
; CHECK: xor %r0, %r0, 32
; CHECK-NOT: bxor %r
  %r = xor i32 %a, 32
  ret i32 %r
}

; --- clear bit 5 -> and ~32 = -33, fits s12, stays plain `and` ---
define i32 @clearbit_5(i32 %a) {
; CHECK-LABEL: clearbit_5:
; CHECK: and %r0, %r0, -33
; CHECK-NOT: bclr %r
  %r = and i32 %a, -33
  ret i32 %r
}

; --- bit 6 (mask 64): first position that no longer fits u6 (<64) but
; still fits s12 (<2048) -- stays the plain `or`/`xor`/`and` form, only the
; encoding width changes, never the mnemonic. ---
define i32 @setbit_6(i32 %a) {
; CHECK-LABEL: setbit_6:
; CHECK: or %r0, %r0, 64
; CHECK-NOT: bset %r
  %r = or i32 %a, 64
  ret i32 %r
}
define i32 @togglebit_6(i32 %a) {
; CHECK-LABEL: togglebit_6:
; CHECK: xor %r0, %r0, 64
; CHECK-NOT: bxor %r
  %r = xor i32 %a, 64
  ret i32 %r
}
define i32 @clearbit_6(i32 %a) {
; CHECK-LABEL: clearbit_6:
; CHECK: and %r0, %r0, -65
; CHECK-NOT: bclr %r
  %r = and i32 %a, -65
  ret i32 %r
}

; --- bit 9 (mask 512), still inside s12 (<2048) -- plain `or` ---
define i32 @setbit_9(i32 %a) {
; CHECK-LABEL: setbit_9:
; CHECK: or %r0, %r0, 512
; CHECK-NOT: bset %r
  %r = or i32 %a, 512
  ret i32 %r
}

; --- bit 10 (mask 1024): last position before the bit-op transition.
; bit_pos_hi fires only for Imm > 2047, so 1024 stays plain for or/xor;
; bclr_mask_hi fires only when ~mask doesn't fit s12, and ~1024 = -1025
; still fits (-2048..2047), so the AND-not case also stays plain. ---
define i32 @setbit_10(i32 %a) {
; CHECK-LABEL: setbit_10:
; CHECK: or %r0, %r0, 1024
; CHECK-NOT: bset %r
  %r = or i32 %a, 1024
  ret i32 %r
}
define i32 @togglebit_10(i32 %a) {
; CHECK-LABEL: togglebit_10:
; CHECK: xor %r0, %r0, 1024
; CHECK-NOT: bxor %r
  %r = xor i32 %a, 1024
  ret i32 %r
}
define i32 @clearbit_10(i32 %a) {
; CHECK-LABEL: clearbit_10:
; CHECK: and %r0, %r0, -1025
; CHECK-NOT: bclr %r
  %r = and i32 %a, -1025
  ret i32 %r
}

; ============================================================================
; Section A (cont.): constant bit position, high end -- this is where a
; dedicated bit op strictly saves an 8-byte LIMM vs. the u6/s12 or/and/xor
; forms, so bset/bxor/bclr must fire and no LIMM may be emitted.
; ============================================================================

; --- bit 11 (mask 2048) is the exact transition point for ALL THREE ops:
; bit_pos_hi requires Imm > 2047 (2048 qualifies) for OR/XOR; bclr_mask_hi
; requires ~mask not fit s12, and ~2048 = -2049 is just outside -2048..2047,
; so AND transitions at the SAME bit position. ---
define i32 @setbit_hi(i32 %a) {
; CHECK-LABEL: setbit_hi:
; CHECK: bset %r0, %r0, 20
; CHECK-NOT: limm
  %r = or i32 %a, 1048576
  ret i32 %r
}
define i32 @setbit_11(i32 %a) {
; CHECK-LABEL: setbit_11:
; CHECK: bset %r0, %r0, 11
; CHECK-NOT: limm
  %r = or i32 %a, 2048
  ret i32 %r
}
define i32 @togglebit_hi(i32 %a) {
; CHECK-LABEL: togglebit_hi:
; CHECK: bxor %r0, %r0, 24
; CHECK-NOT: limm
  %r = xor i32 %a, 16777216
  ret i32 %r
}
define i32 @togglebit_11(i32 %a) {
; CHECK-LABEL: togglebit_11:
; CHECK: bxor %r0, %r0, 11
; CHECK-NOT: limm
  %r = xor i32 %a, 2048
  ret i32 %r
}
define i32 @clearbit_hi(i32 %a) {
; CHECK-LABEL: clearbit_hi:
; CHECK: bclr %r0, %r0, 20
; CHECK-NOT: limm
  %r = and i32 %a, -1048577
  ret i32 %r
}
define i32 @clearbit_11(i32 %a) {
; CHECK-LABEL: clearbit_11:
; CHECK: bclr %r0, %r0, 11
; CHECK-NOT: limm
  %r = and i32 %a, -2049
  ret i32 %r
}

; --- bit 12 (mask 4096), one past the transition -- all three ops ---
define i32 @setbit_12(i32 %a) {
; CHECK-LABEL: setbit_12:
; CHECK: bset %r0, %r0, 12
; CHECK-NOT: limm
  %r = or i32 %a, 4096
  ret i32 %r
}
define i32 @togglebit_12(i32 %a) {
; CHECK-LABEL: togglebit_12:
; CHECK: bxor %r0, %r0, 12
; CHECK-NOT: limm
  %r = xor i32 %a, 4096
  ret i32 %r
}
define i32 @clearbit_12(i32 %a) {
; CHECK-LABEL: clearbit_12:
; CHECK: bclr %r0, %r0, 12
; CHECK-NOT: limm
  %r = and i32 %a, -4097
  ret i32 %r
}

; --- bit 30, deep in the high range -- all three ops ---
define i32 @setbit_30(i32 %a) {
; CHECK-LABEL: setbit_30:
; CHECK: bset %r0, %r0, 30
; CHECK-NOT: limm
  %r = or i32 %a, 1073741824
  ret i32 %r
}
define i32 @togglebit_30(i32 %a) {
; CHECK-LABEL: togglebit_30:
; CHECK: bxor %r0, %r0, 30
; CHECK-NOT: limm
  %r = xor i32 %a, 1073741824
  ret i32 %r
}
define i32 @clearbit_30(i32 %a) {
; CHECK-LABEL: clearbit_30:
; CHECK: bclr %r0, %r0, 30
; CHECK-NOT: limm
  %r = and i32 %a, -1073741825
  ret i32 %r
}

; --- bit 31, the sign-bit endpoint. `Imm` is ImmLeaf's sign-extended
; int64_t view, so 0x80000000 sign-extends negative -- bit_pos_hi and
; bclr_mask_hi both cast to uint32_t first (see ARCARCompactPatterns.td)
; to recover it correctly. Confirms the top endpoint of the domain. ---
define i32 @setbit_31(i32 %a) {
; CHECK-LABEL: setbit_31:
; CHECK: bset %r0, %r0, 31
; CHECK-NOT: limm
  %r = or i32 %a, -2147483648
  ret i32 %r
}
define i32 @togglebit_31(i32 %a) {
; CHECK-LABEL: togglebit_31:
; CHECK: bxor %r0, %r0, 31
; CHECK-NOT: limm
  %r = xor i32 %a, -2147483648
  ret i32 %r
}
; --- clear bit 31 = `and %a, 0x7FFFFFFF`. NOTE: 0x7FFFFFFF is
; SIMULTANEOUSLY a valid BCLR-bit31 mask (~(1<<31)) and a valid BMSK-width31
; mask ((1<<31)-1) -- both are equally-optimal 4-byte encodings and both
; Pats carry the same AddedComplexity, so this is not a defect, just a
; TableGen tie broken by pattern declaration order (BCLR is declared first
; in ARCARCompactPatterns.td and wins). Verified byte-stable via llc+disasm:
; `20 50 07 c0` = bclr r0, r0, 0x1F. ---
define i32 @clearbit_31(i32 %a) {
; CHECK-LABEL: clearbit_31:
; CHECK: bclr %r0, %r0, 31
; CHECK-NOT: limm
  %r = and i32 %a, 2147483647
  ret i32 %r
}

; ============================================================================
; Section B: BMSK mask widths.
; ============================================================================

; --- toggle a high bit (bit 24) [pre-existing case, kept] ---
define i32 @togglebit_hi_orig(i32 %a) {
; CHECK-LABEL: togglebit_hi_orig:
; CHECK: bxor %r0, %r0, 24
; CHECK-NOT: limm
  %r = xor i32 %a, 16777216
  ret i32 %r
}

; --- a 10-bit mask 0x3FF (1023 < 2048) already fits s12 AND: stays `and` ---
define i32 @lowmask10(i32 %a) {
; CHECK-LABEL: lowmask10:
; CHECK: and %r0, %r0, 1023
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 1023
  ret i32 %r
}

; --- width-11 mask 0x7FF (2047): the exact boundary. bmsk_mask_hi requires
; M > 2047 (strictly), so 2047 itself stays the plain s12 `and`, one width
; short of the transition. ---
define i32 @lowmask11(i32 %a) {
; CHECK-LABEL: lowmask11:
; CHECK: and %r0, %r0, 2047
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 2047
  ret i32 %r
}

; --- low 12-bit mask 0xFFF (4095 > 2047) -> bit position 11 ---
define i32 @lowmask12(i32 %a) {
; CHECK-LABEL: lowmask12:
; CHECK: bmsk %r0, %r0, 11
; CHECK-NOT: limm
  %r = and i32 %a, 4095
  ret i32 %r
}

; --- width-24 mask 0xFFFFFF -> bit position 23 ---
define i32 @lowmask24(i32 %a) {
; CHECK-LABEL: lowmask24:
; CHECK: bmsk %r0, %r0, 23
; CHECK-NOT: limm
  %r = and i32 %a, 16777215
  ret i32 %r
}

; --- width-31 mask 0x7FFFFFFF: see the clearbit_31 comment above -- this
; is the identical mask, and BCLR wins the TableGen tie. Kept here too so
; a regression in the pattern-order tie-break shows up under either name. ---
define i32 @lowmask31(i32 %a) {
; CHECK-LABEL: lowmask31:
; CHECK: bclr %r0, %r0, 31
; CHECK-NOT: limm
  %r = and i32 %a, 2147483647
  ret i32 %r
}

; --- must NOT steal the 16-bit width (extw / dedicated form handles 0xFFFF) ---
define i32 @width16(i32 %a) {
; CHECK-LABEL: width16:
; CHECK: extw %r0, %r0
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 65535
  ret i32 %r
}

; --- width16 stability under -O0 too (separate RUN/prefix below covers
; the same shape at a different optimization pipeline). ---
define i32 @width16_o0(i32 %a) {
; O0-LABEL: width16_o0:
; O0: extw %r0, %r0
; O0-NOT: bmsk %r
  %r = and i32 %a, 65535
  ret i32 %r
}

; --- all-ones mask 0xFFFFFFFF (and %a, -1) is a pure no-op: bmsk_mask_hi
; explicitly excludes M == 0xFFFFFFFF (would need Log2_32(0) in the
; SDNodeXForm, which is undefined). The AND itself is eliminated entirely
; by DAGCombiner (AND with all-ones is an identity), so neither `bmsk` nor
; a materialized `and %r0` should ever appear. ---
define i32 @allones_noop(i32 %a) {
; CHECK-LABEL: allones_noop:
; CHECK-NOT: bmsk %r
; CHECK-NOT: and %r0
  %r = and i32 %a, -1
  ret i32 %r
}

; --- degenerate zero mask: and %a, 0 constant-folds to 0, never a bit op ---
define i32 @zeromask(i32 %a) {
; CHECK-LABEL: zeromask:
; CHECK: mov_s %r0, 0
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 0
  ret i32 %r
}

; --- degenerate width-1 mask (and %a, 1): stays u6 `and`, never `bmsk` ---
define i32 @onemask(i32 %a) {
; CHECK-LABEL: onemask:
; CHECK: and %r0, %r0, 1
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 1
  ret i32 %r
}

; ============================================================================
; Section C: low-mask / one-hot byte-stability sanity sweep. Every one of
; these must stay on the plain or/xor/and form -- none is a defect target,
; they exist to catch a future regression that widens the ImmLeaf domains
; too far and starts eating already-optimal low encodings.
; ============================================================================

define i32 @mask_2b(i32 %a) {
; CHECK-LABEL: mask_2b:
; CHECK: and %r0, %r0, 3
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 3
  ret i32 %r
}
define i32 @mask_3b(i32 %a) {
; CHECK-LABEL: mask_3b:
; CHECK: and %r0, %r0, 7
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 7
  ret i32 %r
}
define i32 @mask_4b(i32 %a) {
; CHECK-LABEL: mask_4b:
; CHECK: and %r0, %r0, 15
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 15
  ret i32 %r
}
define i32 @mask_7b(i32 %a) {
; CHECK-LABEL: mask_7b:
; CHECK: and %r0, %r0, 127
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 127
  ret i32 %r
}
define i32 @mask_9b(i32 %a) {
; CHECK-LABEL: mask_9b:
; CHECK: and %r0, %r0, 511
; CHECK-NOT: bmsk %r
  %r = and i32 %a, 511
  ret i32 %r
}

define i32 @onehot_1(i32 %a) {
; CHECK-LABEL: onehot_1:
; CHECK: or %r0, %r0, 2
; CHECK-NOT: bset %r
  %r = or i32 %a, 2
  ret i32 %r
}
define i32 @onehot_2(i32 %a) {
; CHECK-LABEL: onehot_2:
; CHECK: or %r0, %r0, 4
; CHECK-NOT: bset %r
  %r = or i32 %a, 4
  ret i32 %r
}
define i32 @onehot_3(i32 %a) {
; CHECK-LABEL: onehot_3:
; CHECK: or %r0, %r0, 8
; CHECK-NOT: bset %r
  %r = or i32 %a, 8
  ret i32 %r
}
define i32 @onehot_7(i32 %a) {
; CHECK-LABEL: onehot_7:
; CHECK: or %r0, %r0, 128
; CHECK-NOT: bset %r
  %r = or i32 %a, 128
  ret i32 %r
}
define i32 @onehot_9(i32 %a) {
; CHECK-LABEL: onehot_9:
; CHECK: or %r0, %r0, 512
; CHECK-NOT: bset %r
  %r = or i32 %a, 512
  ret i32 %r
}

; ============================================================================
; Section G: flag (.f) / dead-flag differential checks. Value equivalence
; alone is not enough when STATUS32 is live across the bit op -- confirm the
; plain (non-.f) opcode is always chosen (no Pat here ever requests `.f`,
; and a live downstream compare is satisfied by a separate `breq`/`cmp`,
; never by fusing flags out of the bit op itself), both when the flags are
; genuinely used afterward and when they are dead.
; ============================================================================

; --- result feeds a subsequent icmp/branch: flags ARE live downstream, but
; still must come from a separate compare, not a `.f` suffix on bset. ---
define i32 @bsethi_flag_used(i32 %a) {
; CHECK-LABEL: bsethi_flag_used:
; CHECK: bset %r0, %r0, 11
; CHECK-NOT: bset.f
; CHECK: breq %r0, 0,
entry:
  %r = or i32 %a, 2048
  %c = icmp eq i32 %r, 0
  br i1 %c, label %t, label %f
t:
  ret i32 1
f:
  ret i32 %r
}

; --- result used, flags dead: plain opcode, no spurious flag-write ---
define i32 @bsethi_flag_dead(i32 %a) {
; CHECK-LABEL: bsethi_flag_dead:
; CHECK: bset %r0, %r0, 11
; CHECK-NOT: bset.f
; CHECK-NOT: limm
  %r = or i32 %a, 2048
  ret i32 %r
}

; ============================================================================
; Feature-negative sweep: with ARCompact disabled, none of bset/bxor/bclr/
; bmsk may ever be selected, for any of the high-bit/wide-mask shapes above
; that would otherwise pick them. Proves IsARCompact actually gates every
; Pat in this family rather than falling through by accident.
; ============================================================================

; NOCOMPACT-NOT: bset %r
; NOCOMPACT-NOT: bxor %r
; NOCOMPACT-NOT: bclr %r
; NOCOMPACT-NOT: bmsk %r
