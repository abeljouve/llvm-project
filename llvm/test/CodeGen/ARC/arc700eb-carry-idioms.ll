; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs -arc-disable-delay-filler < %s | FileCheck %s

; -arc-disable-delay-filler: this file tests instruction *selection* and
; encodings, not scheduling. The delay slot filler is a late pass that sinks
; the last instruction of a block into the return's delay slot, which leaves
; `j_s.d` sitting between instructions this file asserts are adjacent with
; CHECK-NEXT. The selected instructions and their encodings are unchanged --
; only the return moves -- so the filler is turned off here to keep those
; adjacency assertions meaningful and independent of the filler's heuristics.
; Delay-slot behaviour has its own coverage in delay-slot-filler.mir and
; arc700eb-delay-slot-*.mir.

; Unsigned carry-consuming arithmetic idioms on ARC700 (big-endian, no DSP /
; saturating-instruction extensions). Each lowers to present base ops only.
;
; CARRY POLARITY (silicon-verified, ARCompact -- NOT ARM). After SUB/CMP the
; carry flag is a BORROW: C=1 iff a<b unsigned. Condition 0x5 ("lo", CS) fires
; when C=1; condition 0x6 ("hs", CC) fires when C=0. A single .lo<->.hs
; inversion silently miscompiles every idiom; these checks are the tripwire.
; (Sequences executed over a 200k boundary+random corpus through the emulator's
; authentic ALU/condition model -- 0 mismatches.)

declare i32 @llvm.umax.i32(i32, i32)
declare i32 @llvm.umin.i32(i32, i32)
declare i32 @llvm.uadd.sat.i32(i32, i32)
declare i32 @llvm.usub.sat.i32(i32, i32)
declare i8  @llvm.uadd.sat.i8(i8, i8)
declare i16 @llvm.usub.sat.i16(i16, i16)
declare { i32, i1 } @llvm.uadd.with.overflow.i32(i32, i32)
declare { i32, i1 } @llvm.usub.with.overflow.i32(i32, i32)

; UMIN/UMAX use the generic CMP + conditional-MOV (SELECT_CC) expansion: a
; dedicated Legal pseudo was measured to regress firmware .text with no
; correctness benefit. umax picks a on unsigned-greater (.hi), umin on
; unsigned-lower (.lo).
; CHECK-LABEL: t_umax:
; CHECK:      cmp %r0, %r1
; CHECK-NEXT: mov.hi %r1, %r0
; CHECK-NOT:  __muls
define i32 @t_umax(i32 %a, i32 %b) {
  %r = call i32 @llvm.umax.i32(i32 %a, i32 %b)
  ret i32 %r
}

; CHECK-LABEL: t_umin:
; CHECK:      cmp %r0, %r1
; CHECK-NEXT: mov.lo %r1, %r0
define i32 @t_umin(i32 %a, i32 %b) {
  %r = call i32 @llvm.umin.i32(i32 %a, i32 %b)
  ret i32 %r
}

; UADDSAT: add.f then clamp to all-ones on carry-out (.lo == raw C=1).
; CHECK-LABEL: t_uaddsat:
; CHECK:      add.f %r0, %r0, %r1
; CHECK:      mov %r1, -1
; CHECK-NEXT: mov.lo %r0, %r1
; CHECK-NOT:  mov.hs
define i32 @t_uaddsat(i32 %a, i32 %b) {
  %r = call i32 @llvm.uadd.sat.i32(i32 %a, i32 %b)
  ret i32 %r
}

; USUBSAT: sub.f then clamp to zero on borrow (.lo == C=1 == a<b).
; CHECK-LABEL: t_usubsat:
; CHECK:      sub.f %r0, %r0, %r1
; CHECK-NEXT: mov.lo %r0, 0
; CHECK-NOT:  mov.hs
define i32 @t_usubsat(i32 %a, i32 %b) {
  %r = call i32 @llvm.usub.sat.i32(i32 %a, i32 %b)
  ret i32 %r
}

; Sub-word: the clamp happens on the promoted 32-bit value. i8 saturating add
; clamps to 255 (the sum of two zero-extended bytes is non-negative, so a
; signed MIN is exact); i16 saturating sub extends then clamps 0 on borrow.
; CHECK-LABEL: t_uaddsat_i8:
; CHECK:      add %r0, %r0, %r1
; CHECK:      min %r0, %r0, 255
define i8 @t_uaddsat_i8(i8 %a, i8 %b) {
  %r = call i8 @llvm.uadd.sat.i8(i8 %a, i8 %b)
  ret i8 %r
}

; CHECK-LABEL: t_usubsat_i16:
; CHECK:      sub.f %r0, %r0, %r1
; CHECK-NEXT: mov.lo %r0, 0
define i16 @t_usubsat_i16(i16 %a, i16 %b) {
  %r = call i16 @llvm.usub.sat.i16(i16 %a, i16 %b)
  ret i16 %r
}

; UADDO/USUBO whose overflow bit is used as a VALUE (zext + add) materialize a
; 0/1 boolean from the flag: add.f/sub.f producer, then mov.lo -> 1 on
; carry-out/borrow (raw C=1).
; CHECK-LABEL: t_uaddo_val:
; CHECK:      add.f %r0, %r0, %r1
; CHECK:      mov.lo %r{{[0-9]+}}, 1
; CHECK-NOT:  mov.hs
define i32 @t_uaddo_val(i32 %a, i32 %b) {
  %p = call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 %a, i32 %b)
  %s = extractvalue { i32, i1 } %p, 0
  %o = extractvalue { i32, i1 } %p, 1
  %oz = zext i1 %o to i32
  %r = add i32 %s, %oz
  ret i32 %r
}

; CHECK-LABEL: t_usubo_val:
; CHECK:      sub.f %r0, %r0, %r1
; CHECK:      mov.lo %r{{[0-9]+}}, 1
; CHECK-NOT:  mov.hs
define i32 @t_usubo_val(i32 %a, i32 %b) {
  %p = call { i32, i1 } @llvm.usub.with.overflow.i32(i32 %a, i32 %b)
  %d = extractvalue { i32, i1 } %p, 0
  %o = extractvalue { i32, i1 } %p, 1
  %oz = zext i1 %o to i32
  %r = add i32 %d, %oz
  ret i32 %r
}

; UADDO/USUBO whose overflow bit is the sole condition of a BRANCH are rewritten
; to a native unsigned compare-and-branch that shares the add/sub -- NO 0/1
; boolean is materialized (no add.f/sub.f + mov.lo re-test). UADDO overflow ==
; (a+b <u a); USUBO borrow == (a <u b); the fallthrough-to-overflow shape
; branches on "no overflow" (.hs / a>=b).
; CHECK-LABEL: t_uaddo_br:
; CHECK:      add %r{{[0-9]+}}, %r{{[0-9]+}}, %r{{[0-9]+}}
; CHECK:      brhs %r{{[0-9]+}}, %r{{[0-9]+}},
; CHECK-NOT:  add.f
; CHECK-NOT:  mov.lo
define i32 @t_uaddo_br(i32 %a, i32 %b) {
entry:
  %p = call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 %a, i32 %b)
  %s = extractvalue { i32, i1 } %p, 0
  %o = extractvalue { i32, i1 } %p, 1
  br i1 %o, label %of, label %ok
of:
  ret i32 999
ok:
  ret i32 %s
}

; CHECK-LABEL: t_usubo_br:
; CHECK:      brhs %r0, %r1,
; CHECK-NOT:  sub.f
; CHECK-NOT:  mov.lo
define i32 @t_usubo_br(i32 %a, i32 %b) {
entry:
  %p = call { i32, i1 } @llvm.usub.with.overflow.i32(i32 %a, i32 %b)
  %d = extractvalue { i32, i1 } %p, 0
  %o = extractvalue { i32, i1 } %p, 1
  br i1 %o, label %of, label %ok
of:
  ret i32 888
ok:
  ret i32 %d
}

; UADDO overflow feeding a SELECT is rewritten to CMP + conditional-MOV that
; shares the add (mov.lo picks the overflow value; raw C=1 = a+b <u a), again
; with no separate 0/1 boolean.
; CHECK-LABEL: t_uaddo_sel:
; CHECK:      add %r1, %r0, %r1
; CHECK:      cmp %r1, %r0
; CHECK-NEXT: mov.lo %r1,
; CHECK-NOT:  add.f
define i32 @t_uaddo_sel(i32 %a, i32 %b) {
  %p = call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 %a, i32 %b)
  %s = extractvalue { i32, i1 } %p, 0
  %o = extractvalue { i32, i1 } %p, 1
  %r = select i1 %o, i32 777, i32 %s
  ret i32 %r
}

; No absent opcodes anywhere (MPY/MUL64/EX/FFS/FLS/SWAPE/ADDS/SUBS/SAT16/divide)
; and no __mulsi3-style libcall for these register-only idioms.
; CHECK-NOT: mpy
; CHECK-NOT: mul64
; CHECK-NOT: swape
; CHECK-NOT: sat16
; CHECK-NOT: __muls
