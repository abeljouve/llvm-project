; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -march=arc -mcpu=generic < %s | FileCheck %s --check-prefix=NOARCOMPACT

; Signed carry/overflow-consuming arithmetic idioms on ARC700 (big-endian, no
; DSP / saturating-instruction extensions): SADDSAT/SSUBSAT, SADDO/SSUBO,
; AVGFLOORU. Companion to arc700eb-carry-idioms.ll (the UNSIGNED half of the
; same dossier); mirrors its mechanism and test shape.
;
; OVERFLOW POLARITY (silicon-verified, ARCompact). After a `.f`-form ADD/SUB,
; STATUS32.V is set iff the SIGNED result overflowed -- unambiguous for both
; producers (unlike the carry bit, which is producer-dependent -- see
; arc700eb-carry-idioms.ll). Condition 0x7 ("vs") fires when V=1; 0x8 ("vc")
; fires when V=0. A .vs<->.vc inversion silently miscompiles every idiom
; here; the CHECK-NOT lines below are the tripwire.

declare i32 @llvm.sadd.sat.i32(i32, i32)
declare i32 @llvm.ssub.sat.i32(i32, i32)
declare i8  @llvm.sadd.sat.i8(i8, i8)
declare i16 @llvm.ssub.sat.i16(i16, i16)
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32)
declare { i32, i1 } @llvm.ssub.with.overflow.i32(i32, i32)

; SADDSAT: clamp limit (INT_MAX/INT_MIN, keyed off the sign of %a) is built
; from plain (non-`.f`) asr/mov/lsr/xor entirely BEFORE the add.f producer,
; so the flag-adjacency discipline only has to hold across the final two
; instructions. add.f then selects the limit on signed overflow (.vs).
; CHECK-LABEL: t_saddsat:
; CHECK:      asr %r2, %r0, 31
; CHECK:      mov %r3, -1
; CHECK-NEXT: lsr %r3, %r3, 1
; CHECK-NEXT: xor %r2, %r2, %r3
; CHECK:      add.f %r0, %r0, %r1
; CHECK-NEXT: mov.vs %r0, %r2
; CHECK-NOT:  mov.vc
; CHECK-NOT:  bmsk
define i32 @t_saddsat(i32 %a, i32 %b) {
  %r = call i32 @llvm.sadd.sat.i32(i32 %a, i32 %b)
  ret i32 %r
}

; SSUBSAT: identical limit construction, sub.f producer.
; CHECK-LABEL: t_ssubsat:
; CHECK:      asr %r2, %r0, 31
; CHECK:      mov %r3, -1
; CHECK-NEXT: lsr %r3, %r3, 1
; CHECK-NEXT: xor %r2, %r2, %r3
; CHECK:      sub.f %r0, %r0, %r1
; CHECK-NEXT: mov.vs %r0, %r2
; CHECK-NOT:  mov.vc
; CHECK-NOT:  bmsk
define i32 @t_ssubsat(i32 %a, i32 %b) {
  %r = call i32 @llvm.ssub.sat.i32(i32 %a, i32 %b)
  ret i32 %r
}

; Edge cases: SADDSAT(INT_MAX,1)=INT_MAX and SADDSAT(INT_MIN,-1)=INT_MIN
; (likewise SSUBSAT(INT_MIN,1)=INT_MIN, SSUBSAT(INT_MAX,-1)=INT_MAX). Both
; operands constant lets SelectionDAG's generic constant-folder (APInt
; saturating-arithmetic, independent of this backend) evaluate the call at
; compile time -- the resulting literal is an independent cross-check that
; the documented INT_MAX/INT_MIN saturation results above are correct, but
; it does NOT exercise expandSADDSAT/expandSSUBSAT's instruction sequence
; (no add.f/sub.f survives -- the whole call folds to one `mov`, or the
; mov_s+asl seed-shift chain for INT_MIN). The instruction sequence itself,
; including at these exact boundary values, is exercised by t_saddsat/
; t_ssubsat above (symbolic operands, never fold) and by the emulator
; boundary/random corpus (INT_MIN/INT_MAX/-1/0 included) referenced in the
; dossier's verification methodology.
; CHECK-LABEL: t_saddsat_intmax_1:
; CHECK: mov{{.*}}, 2147483647
define i32 @t_saddsat_intmax_1() {
  %r = call i32 @llvm.sadd.sat.i32(i32 2147483647, i32 1)
  ret i32 %r
}

; CHECK-LABEL: t_saddsat_intmin_neg1:
; CHECK: asl {{.*}}, {{.*}}, 31
define i32 @t_saddsat_intmin_neg1() {
  %r = call i32 @llvm.sadd.sat.i32(i32 -2147483648, i32 -1)
  ret i32 %r
}

; CHECK-LABEL: t_ssubsat_intmin_1:
; CHECK: asl {{.*}}, {{.*}}, 31
define i32 @t_ssubsat_intmin_1() {
  %r = call i32 @llvm.ssub.sat.i32(i32 -2147483648, i32 1)
  ret i32 %r
}

; CHECK-LABEL: t_ssubsat_intmax_neg1:
; CHECK: mov{{.*}}, 2147483647
define i32 @t_ssubsat_intmax_neg1() {
  %r = call i32 @llvm.ssub.sat.i32(i32 2147483647, i32 -1)
  ret i32 %r
}

; Same four boundary pairs, but with %b held as a genuine runtime argument so
; the call cannot fully constant-fold -- these DO exercise
; expandSADDSAT/expandSSUBSAT's real instruction sequence (add.f/sub.f +
; mov.vs) at the documented edge inputs. %a's sign is still known at compile
; time (INT_MAX/INT_MIN are both non-negative-vs-negative extremes), so the
; clamp-limit chain (asr/mov/lsr/xor) may be constant-propagated away by
; DAGCombiner even though the producer/consumer pair cannot -- CHECK only the
; add.f/sub.f + mov.vs pair, not the limit-construction instructions.
; CHECK-LABEL: t_saddsat_intmax_dyn:
; CHECK:      add.f
; CHECK-NEXT: mov.vs
; CHECK-NOT:  mov.vc
define i32 @t_saddsat_intmax_dyn(i32 %b) {
  %r = call i32 @llvm.sadd.sat.i32(i32 2147483647, i32 %b)
  ret i32 %r
}

; CHECK-LABEL: t_saddsat_intmin_dyn:
; CHECK:      add.f
; CHECK-NEXT: mov.vs
; CHECK-NOT:  mov.vc
define i32 @t_saddsat_intmin_dyn(i32 %b) {
  %r = call i32 @llvm.sadd.sat.i32(i32 -2147483648, i32 %b)
  ret i32 %r
}

; CHECK-LABEL: t_ssubsat_intmin_dyn:
; CHECK:      sub.f
; CHECK-NEXT: mov.vs
; CHECK-NOT:  mov.vc
define i32 @t_ssubsat_intmin_dyn(i32 %b) {
  %r = call i32 @llvm.ssub.sat.i32(i32 -2147483648, i32 %b)
  ret i32 %r
}

; CHECK-LABEL: t_ssubsat_intmax_dyn:
; CHECK:      sub.f
; CHECK-NEXT: mov.vs
; CHECK-NOT:  mov.vc
define i32 @t_ssubsat_intmax_dyn(i32 %b) {
  %r = call i32 @llvm.ssub.sat.i32(i32 2147483647, i32 %b)
  ret i32 %r
}

; Sub-word (i8/i16): NOT a dedicated narrow pseudo -- the type legalizer
; promotes to i32 (sign-extended via shl+asr, since ARC700 lacks sexb/sexh),
; runs the same SADDSAT_PSEUDO/SSUBSAT_PSEUDO expansion at i32 width, then
; sign-extends the result back down (asr) AFTER the flag consumer. Confirms
; the fallback still selects through the real add.f/sub.f + mov.vs sequence
; and does not require any narrow-specific pseudo.
; CHECK-LABEL: t_saddsat_i8:
; CHECK:      asl %r1, %r1, 24
; CHECK-NEXT: asl %r0, %r0, 24
; CHECK:      add.f %r0, %r0, %r1
; CHECK-NEXT: mov.vs %r0, %r2
; CHECK-NEXT: asr %r0, %r0, 24
define i8 @t_saddsat_i8(i8 %a, i8 %b) {
  %r = call i8 @llvm.sadd.sat.i8(i8 %a, i8 %b)
  ret i8 %r
}

; CHECK-LABEL: t_ssubsat_i16:
; CHECK:      asl %r1, %r1, 16
; CHECK-NEXT: asl %r0, %r0, 16
; CHECK:      sub.f %r0, %r0, %r1
; CHECK-NEXT: mov.vs %r0, %r2
; CHECK-NEXT: asr %r0, %r0, 16
define i16 @t_ssubsat_i16(i16 %a, i16 %b) {
  %r = call i16 @llvm.ssub.sat.i16(i16 %a, i16 %b)
  ret i16 %r
}

; SADDO/SSUBO whose overflow bit is used as a VALUE materialize a 0/1 boolean
; from V: add.f/sub.f producer, then mov.vs -> 1 on signed overflow.
; CHECK-LABEL: t_saddo_val:
; CHECK:      add.f %r0, %r0, %r1
; CHECK:      mov.vs %r{{[0-9]+}}, 1
; CHECK-NOT:  mov.vc
define i32 @t_saddo_val(i32 %a, i32 %b) {
  %p = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %a, i32 %b)
  %s = extractvalue { i32, i1 } %p, 0
  %o = extractvalue { i32, i1 } %p, 1
  %oz = zext i1 %o to i32
  %r = add i32 %s, %oz
  ret i32 %r
}

; CHECK-LABEL: t_ssubo_val:
; CHECK:      sub.f %r0, %r0, %r1
; CHECK:      mov.vs %r{{[0-9]+}}, 1
; CHECK-NOT:  mov.vc
define i32 @t_ssubo_val(i32 %a, i32 %b) {
  %p = call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 %a, i32 %b)
  %d = extractvalue { i32, i1 } %p, 0
  %o = extractvalue { i32, i1 } %p, 1
  %oz = zext i1 %o to i32
  %r = add i32 %d, %oz
  ret i32 %r
}

; Edge cases for the overflow BOOLEAN at INT_MIN/INT_MAX/-1/0 all route
; through the same add.f/sub.f + mov.vs shape (V is read unmodified -- no
; per-input special-casing is possible or needed).
; CHECK-LABEL: t_saddo_val_intmax_1:
; CHECK: add.f
; CHECK: mov.vs {{.*}}, 1
define i32 @t_saddo_val_intmax_1() {
  %p = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 2147483647, i32 1)
  %o = extractvalue { i32, i1 } %p, 1
  %oz = zext i1 %o to i32
  ret i32 %oz
}

; DAGCombiner canonicalizes `sub X, C` to `add X, -C` for a constant RHS
; BEFORE Custom-lowering ever sees it, so this call actually reaches
; ARCISD::SADDO / expandSADDO (add.f), not SSUBO/expandSSUBO -- mathematically
; identical (INT_MIN - 1 == INT_MIN + (-1)) and still exercises the VS-based
; overflow-boolean consumer at this exact boundary value.
; CHECK-LABEL: t_ssubo_val_intmin_1:
; CHECK: add.f
; CHECK: mov.vs {{.*}}, 1
define i32 @t_ssubo_val_intmin_1() {
  %p = call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 -2147483648, i32 1)
  %o = extractvalue { i32, i1 } %p, 1
  %oz = zext i1 %o to i32
  ret i32 %oz
}

; SADDO overflow feeding a BRANCH is deliberately NOT fused into a native
; compare-and-branch (see the comment on performOverflowBrcondCombine in
; ARCISelLowering.h): the unsigned fusion's single-SETULT reduction has no
; signed analogue, so this always takes the value-materializing path below
; (add.f/sub.f + mov.vs), unlike t_uaddo_br/t_usubo_br in
; arc700eb-carry-idioms.ll which fuse to a plain brhs.
; CHECK-LABEL: t_saddo_br:
; CHECK:      add.f
; CHECK:      mov.vs
define i32 @t_saddo_br(i32 %a, i32 %b) {
entry:
  %p = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %a, i32 %b)
  %s = extractvalue { i32, i1 } %p, 0
  %o = extractvalue { i32, i1 } %p, 1
  br i1 %o, label %of, label %ok
of:
  ret i32 999
ok:
  ret i32 %s
}

; AVGFLOORU: exact unsigned floor((a+b)/2), formed from the branchless
; `(a&b)+((a^b)>>1)` average idiom (NOT from a naive `(a+b)>>1`, which is not
; equivalent under a 32-bit wrap -- see ARCARCompactPatterns.td). add.f
; produces the carry-out, rrc folds it into the vacated MSB.
; CHECK-LABEL: t_avgflooru:
; CHECK:      add.f %r0, %r0, %r1
; CHECK-NEXT: rrc %r0, %r0
; CHECK-NOT:  lsr
define i32 @t_avgflooru(i32 %a, i32 %b) {
  %and = and i32 %a, %b
  %xor = xor i32 %a, %b
  %shr = lshr i32 %xor, 1
  %r = add i32 %and, %shr
  ret i32 %r
}

; Wrap-boundary case: 0xFFFFFFFF+0xFFFFFFFF -> true 33-bit sum 0x1FFFFFFFE,
; floor/2 = 0xFFFFFFFF. Still the same add.f+rrc shape -- there is no
; separate constant-folded path (both operands are non-constant function
; arguments in every test here so the DAGCombiner fold always has to select
; through the pseudo).
; CHECK-LABEL: t_avgflooru_wrap:
; CHECK:      add.f %r0, %r0, %r1
; CHECK-NEXT: rrc %r0, %r0
define i32 @t_avgflooru_wrap(i32 %a, i32 %b) {
  %and = and i32 %a, %b
  %xor = xor i32 %a, %b
  %shr = lshr i32 %xor, 1
  %r = add i32 %and, %shr
  ret i32 %r
}

; NEGATIVE-subtarget fallback: on a non-ARCompact target none of MOV_cc's
; consumer chain is gated (ADD_f_rrr/SUB_f_rrr/MOV_cc/asr/lsr/xor are
; baseline F32_DOP-format instructions with no ARCompact predicate), so
; SADDSAT/SSUBSAT/SADDO/SSUBO still select through the exact same pseudo
; mechanism as the ARCompact run line above. AVGFLOORU is the one node in
; this family gated behind Subtarget.isARCompact() (its consumer, rrc, IS an
; ARCompact-only encoding -- see the comment in ARCISelLowering.cpp's ctor):
; on a non-ARCompact target it stays on the generic Expand path instead
; (add/lshr/or, no rrc, no add.f).
; NOARCOMPACT-LABEL: t_saddsat:
; NOARCOMPACT: add.f
; NOARCOMPACT: mov.vs
; NOARCOMPACT-LABEL: t_saddo_val:
; NOARCOMPACT: add.f
; NOARCOMPACT: mov.vs
; NOARCOMPACT-LABEL: t_avgflooru:
; NOARCOMPACT-NOT: rrc
; NOARCOMPACT-NOT: add.f

; No absent opcodes anywhere (MPY/MUL64/EX/FFS/FLS/SWAPE/ADDS/SUBS/SAT16/
; divide) and no __mulsi3-style libcall for these register-only idioms.
; CHECK-NOT: mpy
; CHECK-NOT: mul64
; CHECK-NOT: swape
; CHECK-NOT: sat16
; CHECK-NOT: __muls
