; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs < %s | FileCheck %s

; Dossier 06: restrict the scaled `ld.as` legality hook to what LD_AS_rr can
; actually select (32-bit, non-extending, non-volatile/atomic, generic-AS
; LOAD only -- never a store, never byte/half, never volatile); add
; volatile/atomic MMO rejection to the post-increment address-mode pass so
; MMIO ordering is never disturbed by fusion/hoisting/rebasing; and pin the
; existing sextb(ldb)->ldb.x / sexth(ldw)->ldh.x fold (default SEXTLOAD
; legality + the ARCInstrInfo.td `.x` Pats) so it doesn't silently regress.
;
; No absent-on-this-silicon opcode (mpy*, swape, ffs, fls, rtie, ex, or any
; DSP/saturating/hardware-divide op) may appear in this file's output.

;===----------------------------------------------------------------------===
; Item 1, positive: base + (index<<2), full 32-bit non-volatile load ->
; the scaled reg+reg word load `ld.as`.
;===----------------------------------------------------------------------===

; CHECK-LABEL: pos_ldas:
; CHECK: ld.as %r{{[0-9]+}}, [%r{{[0-9]+}},%r{{[0-9]+}}]
define i32 @pos_ldas(ptr inreg %base, i32 inreg %idx) {
entry:
  %p = getelementptr inbounds i32, ptr %base, i32 %idx
  %v = load i32, ptr %p, align 4
  ret i32 %v
}

;===----------------------------------------------------------------------===
; Item 1, negative: identical index arithmetic, but a STORE. There is no
; scaled store form in this ISA -- must never emit `ld.as`/`st.as`, and must
; still compute the correct address explicitly.
;===----------------------------------------------------------------------===

; CHECK-LABEL: neg_store_no_scaled:
; CHECK-NOT: ld.as
; CHECK-NOT: st.as
define void @neg_store_no_scaled(ptr inreg %base, i32 inreg %idx, i32 inreg %val) {
entry:
  %p = getelementptr inbounds i32, ptr %base, i32 %idx
  store i32 %val, ptr %p, align 4
  ret void
}

;===----------------------------------------------------------------------===
; Item 1, negative: same base+(idx<<2) address shape, but the loaded value
; is a byte (not a full 32-bit word) -- there is no scaled byte load form.
;===----------------------------------------------------------------------===

; CHECK-LABEL: neg_byte_load_no_ldas:
; CHECK-NOT: ld.as
; CHECK: ldb %r{{[0-9]+}}, [%r{{[0-9]+}},0]
define i32 @neg_byte_load_no_ldas(ptr inreg %base, i32 inreg %idx) {
entry:
  %p = getelementptr inbounds i32, ptr %base, i32 %idx
  %v = load i8, ptr %p, align 1
  %z = zext i8 %v to i32
  ret i32 %z
}

;===----------------------------------------------------------------------===
; Item 1, negative: same shape, half-word load -- there is no scaled
; half-word load form (the only documented scaled form is 32-bit word).
;===----------------------------------------------------------------------===

; CHECK-LABEL: neg_half_load_no_ldas:
; CHECK-NOT: ld.as
; CHECK: ldh %r{{[0-9]+}}, [%r{{[0-9]+}},0]
define i32 @neg_half_load_no_ldas(ptr inreg %base, i32 inreg %idx) {
entry:
  %p = getelementptr inbounds i32, ptr %base, i32 %idx
  %v = load i16, ptr %p, align 2
  %z = zext i16 %v to i32
  ret i32 %z
}

;===----------------------------------------------------------------------===
; Item 1 + Item 2, negative: same base+(idx<<2) shape, but the load is
; volatile. `ld.as` has no `.di`/ordering-preserving variant -- a volatile
; access must never be told the scaled mode is legal for it (this exercises
; the `Instruction *I` / LoadInst::isUnordered() branch of the legality
; hook, and independently the SelectAddrModeAS `WantsRoot` volatile check).
;===----------------------------------------------------------------------===

; CHECK-LABEL: neg_volatile_no_ldas:
; CHECK-NOT: ld.as
define i32 @neg_volatile_no_ldas(ptr inreg %base, i32 inreg %idx) {
entry:
  %p = getelementptr inbounds i32, ptr %base, i32 %idx
  %v = load volatile i32, ptr %p, align 4
  ret i32 %v
}

;===----------------------------------------------------------------------===
; Item 2, negative: the load/store post-increment fold (ARCOptAddrMode) must
; never fuse a volatile access into a `.ab` post-increment form. This
; exercises the top-of-tryToCombine hasOrderedMemoryRef() guard directly:
; the offset-0 load itself is volatile.
;===----------------------------------------------------------------------===

; CHECK-LABEL: neg_volatile_no_postinc:
; CHECK-NOT: .ab
define i32 @neg_volatile_no_postinc(ptr inreg %p) {
entry:
  %v0 = load volatile i32, ptr %p, align 4
  %p1 = getelementptr inbounds i8, ptr %p, i32 4
  %v1 = load volatile i32, ptr %p1, align 4
  %sum = add i32 %v0, %v1
  ret i32 %sum
}

;===----------------------------------------------------------------------===
; Item 2, negative: past-uses rebasing must not touch a volatile sibling
; access. Same shape as addrmode.ll's `past_uses` positive test, but the
; middle byte load is volatile -- canFixPastUses must reject the whole fold
; rather than silently renumber the volatile access's base/offset. (The
; unrelated `dst` pointer's store side is free to fold into `st.ab` on its
; own -- only the `src`-side byte loads sharing a base with the volatile
; access must stay unfused, so the negative check is scoped to `ldb.ab`.)
;===----------------------------------------------------------------------===

; CHECK-LABEL: neg_pastuse_volatile:
; CHECK-NOT: ldb.ab
define void @neg_pastuse_volatile(ptr inreg nocapture %dst, ptr inreg nocapture %src, i32 inreg %n) {
entry:
  %c = icmp sgt i32 %n, 0
  br i1 %c, label %body, label %done
done:
  ret void
body:
  %i = phi i32 [ %inc, %body ], [ 0, %entry ]
  %s = phi ptr [ %s.next, %body ], [ %src, %entry ]
  %d = phi ptr [ %d.next, %body ], [ %dst, %entry ]
  %p0 = load i8, ptr %s, align 1
  %g1 = getelementptr inbounds i8, ptr %s, i32 1
  %p1 = load volatile i8, ptr %g1, align 1
  %g2 = getelementptr inbounds i8, ptr %s, i32 2
  %p2 = load i8, ptr %g2, align 1
  %z0 = zext i8 %p0 to i32
  %z1 = zext i8 %p1 to i32
  %z2 = zext i8 %p2 to i32
  %s1 = shl i32 %z1, 8
  %s2 = shl i32 %z2, 16
  %o1 = or i32 %z0, %s1
  %o2 = or i32 %o1, %s2
  store i32 %o2, ptr %d, align 4
  %s.next = getelementptr inbounds i8, ptr %s, i32 3
  %d.next = getelementptr inbounds i8, ptr %d, i32 4
  %inc = add nuw nsw i32 %i, 1
  %e = icmp eq i32 %inc, %n
  br i1 %e, label %done, label %body
}

;===----------------------------------------------------------------------===
; Item 2, negative: a plain (non-volatile) load must not be hoisted across
; an intervening VOLATILE load to reach a post-increment fusion point.
; Exercises canHoistLoadStoreTo's hasOrderedMemoryRef() rejection: %p2 (the
; ADD) is used by the volatile load %x before %v's offset-0 load, so the
; only way to fold %v into a post-increment is to hoist it up across %x --
; which must be refused because %x is volatile.
;===----------------------------------------------------------------------===

; CHECK-LABEL: neg_hoist_across_volatile:
; CHECK-NOT: .ab
define i32 @neg_hoist_across_volatile(ptr inreg %p) {
entry:
  %p2 = getelementptr inbounds i8, ptr %p, i32 4
  %x = load volatile i32, ptr %p2, align 4
  %v = load i32, ptr %p, align 4
  %sum = add i32 %x, %v
  ret i32 %sum
}

;===----------------------------------------------------------------------===
; Item 3, positive: sextb(ldb x) -> ldb.x x. Pinning test for the existing
; default-SEXTLOAD-legal + ARCInstrInfo.td `.x` Pat fold -- no separate
; shift pair, single instruction, byte-width memory access preserved.
;===----------------------------------------------------------------------===

; CHECK-LABEL: pos_sextb_ldb:
; CHECK: ldb.x %r{{[0-9]+}}, [%r{{[0-9]+}},0]
; CHECK-NOT: asl
; CHECK-NOT: asr
define i32 @pos_sextb_ldb(ptr inreg %p) {
entry:
  %v = load i8, ptr %p, align 1
  %s = sext i8 %v to i32
  ret i32 %s
}

;===----------------------------------------------------------------------===
; Item 3, positive: sexth(ldw x) -> ldh.x x. Same fold, half-word width.
;===----------------------------------------------------------------------===

; CHECK-LABEL: pos_sexth_ldh:
; CHECK: ldh.x %r{{[0-9]+}}, [%r{{[0-9]+}},0]
; CHECK-NOT: asl
; CHECK-NOT: asr
define i32 @pos_sexth_ldh(ptr inreg %p) {
entry:
  %v = load i16, ptr %p, align 2
  %s = sext i16 %v to i32
  ret i32 %s
}

;===----------------------------------------------------------------------===
; Item 3, negative: the SAME byte is both sign- and zero-extended (multi-use
; of one load). The fold must NOT turn this into a wider (word) access --
; the memory operand stays a single-byte `ldb.x`, and the zext consumer gets
; an explicit mask, never a fused wide load.
;===----------------------------------------------------------------------===

; CHECK-LABEL: neg_sext_no_widen:
; CHECK: ldb.x %r{{[0-9]+}}, [%r{{[0-9]+}},0]
; CHECK-NOT: ld %r
define i32 @neg_sext_no_widen(ptr inreg %p) {
entry:
  %v = load i8, ptr %p, align 1
  %s = sext i8 %v to i32
  %z = zext i8 %v to i32
  %sum = add i32 %s, %z
  ret i32 %sum
}
