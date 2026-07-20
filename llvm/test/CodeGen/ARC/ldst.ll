; RUN: llc -mtriple=arc -mcpu=generic < %s | FileCheck %s
;
; The bare CHECK prefix describes -mcpu=generic. A bare -mtriple=arc with no
; -mcpu selects a featureless pseudo-subtarget matching no shipping
; configuration (no MPY/SEXT/BitScan, so not `generic`; no ARCompact, so
; ARCSizeReduction never runs, so not arc700 either). Its output for this test
; is byte-identical to generic, so naming the real CPU loses no coverage.
;
; The ARC700 prefixes cover the shipping ARC700 profiles, where the
; size-reduction pass fuses the short-displacement loads and stores into the
; 16-bit ARCompact forms LD_S/ST_S/LDW_S/STW_S/LDB_S/STB_S.
;
; IMPORTANT -- the compact forms print a SCALED displacement, so an ARC700
; CHECK naming a smaller number than its generic counterpart is NOT a weakened
; assertion, it is the same byte address. Byte-verified with the ARC
; disassembler:
;   st_s   %r0, [%r1, 16]  encodes a110 = st   r0, [r1, 0x40]   (offset 64)
;   ldw_s.x %r0, [%r0, 16] encodes 9810 = ldw.x r0, [r0, 0x20]  (offset 32)
; ST_S/LD_S scale by 4, STW_S/LDW_S by 2, STB_S/LDB_S not at all. Do not
; "correct" these numbers back to the unscaled ones.
;
; Unaligned i32/i16 accesses are decomposed into per-byte / per-halfword lanes,
; and which lane carries which shift amount is fixed by endianness. That is the
; whole point of the decomposition, so it is pinned per-endianness via the
; ARC700LE / ARC700BE sub-prefixes rather than wildcarded away.
; RUN: llc -mtriple=arc   -mcpu=arc700   < %s | FileCheck %s --check-prefixes=ARC700,ARC700LE
; RUN: llc -mtriple=arceb -mcpu=arc700eb < %s | FileCheck %s --check-prefixes=ARC700,ARC700BE
; RUN: llc -mtriple=arceb -mcpu=bcm55030 < %s | FileCheck %s --check-prefixes=ARC700,ARC700BE

; CHECK-LABEL: load32
; CHECK: ld %r0, [%r0,16000]
;
; Displacement too large for a compact form -- unchanged on ARC700.
; ARC700-LABEL: load32:
; ARC700: ld %r0, [%r0,16000]

define i32 @load32(ptr %bp) nounwind {
entry:
  %gep = getelementptr i32, ptr %bp, i32 4000
  %v = load i32, ptr %gep, align 4
  ret i32 %v
}

; CHECK-LABEL: load16
; CHECK: ldh %r0, [%r0,8000]
;
; ARC700-LABEL: load16:
; ARC700: ldh %r0, [%r0,8000]

define i16 @load16(ptr %bp) nounwind {
entry:
  %gep = getelementptr i16, ptr %bp, i32 4000
  %v = load i16, ptr %gep, align 2
  ret i16 %v
}

; CHECK-LABEL: load8
; CHECK: ldb %r0, [%r0,4000]
;
; ARC700-LABEL: load8:
; ARC700: ldb %r0, [%r0,4000]

define i8 @load8(ptr %bp) nounwind {
entry:
  %gep = getelementptr i8, ptr %bp, i32 4000
  %v = load i8, ptr %gep, align 1
  ret i8 %v
}

; CHECK-LABEL: sextload16
; CHECK: ldh.x %r0, [%r0,8000]
;
; ARC700-LABEL: sextload16:
; ARC700: ldh.x %r0, [%r0,8000]

define i32 @sextload16(ptr %bp) nounwind {
entry:
  %gep = getelementptr i16, ptr %bp, i32 4000
  %vl = load i16, ptr %gep, align 2
  %v = sext i16 %vl to i32
  ret i32 %v
}

; CHECK-LABEL: sextload8
; CHECK: ldb.x %r0, [%r0,4000]
;
; ARC700-LABEL: sextload8:
; ARC700: ldb.x %r0, [%r0,4000]

define i32 @sextload8(ptr %bp) nounwind {
entry:
  %gep = getelementptr i8, ptr %bp, i32 4000
  %vl = load i8, ptr %gep, align 1
  %v = sext i8 %vl to i32
  ret i32 %v
}

; CHECK-LABEL: s_sextload16
; CHECK: ldh.x %r0, [%r0,32]
;
; LDW_S.X scales by 2: [%r0, 16] is byte offset 32, same address.
; ARC700-LABEL: s_sextload16:
; ARC700-NOT: ldh.x
; ARC700: ldw_s.x %r0, [%r0, 16]

define i32 @s_sextload16(ptr %bp) nounwind {
entry:
  %gep = getelementptr i16, ptr %bp, i32 16
  %vl = load i16, ptr %gep, align 2
  %v = sext i16 %vl to i32
  ret i32 %v
}

; CHECK-LABEL: s_sextload8
; CHECK: ldb.x %r0, [%r0,16]
;
; There is no sign-extending compact byte load, so this one stays 32-bit.
; ARC700-LABEL: s_sextload8:
; ARC700: ldb.x %r0, [%r0,16]

define i32 @s_sextload8(ptr %bp) nounwind {
entry:
  %gep = getelementptr i8, ptr %bp, i32 16
  %vl = load i8, ptr %gep, align 1
  %v = sext i8 %vl to i32
  ret i32 %v
}

; CHECK-LABEL: store32
; CHECK: add %r[[REG:[0-9]+]], %r1, 16000
; CHECK: st %r0, [%r[[REG]],0]
;
; ARC700-LABEL: store32:
; ARC700: add %r[[SREG:[0-9]+]], %r1, 16000
; ARC700-NOT: st %r0,
; ARC700: st_s %r0, [%r[[SREG]], 0]

; Long range stores (offset does not fit in s9) must be add followed by st.
define void @store32(i32 %val, ptr %bp) nounwind {
entry:
  %gep = getelementptr i32, ptr %bp, i32 4000
  store i32 %val, ptr %gep, align 4
  ret void
}

; CHECK-LABEL: store16
; CHECK: add %r[[REG:[0-9]+]], %r1, 8000
; CHECK: sth %r0, [%r[[REG]],0]
;
; ARC700-LABEL: store16:
; ARC700: add %r[[HREG:[0-9]+]], %r1, 8000
; ARC700-NOT: sth %r0,
; ARC700: stw_s %r0, [%r[[HREG]], 0]

define void @store16(i16 zeroext %val, ptr %bp) nounwind {
entry:
  %gep = getelementptr i16, ptr %bp, i32 4000
  store i16 %val, ptr %gep, align 2
  ret void
}

; CHECK-LABEL: store8
; CHECK: add %r[[REG:[0-9]+]], %r1, 4000
; CHECK: stb %r0, [%r[[REG]],0]
;
; ARC700-LABEL: store8:
; ARC700: add %r[[BREG:[0-9]+]], %r1, 4000
; ARC700-NOT: stb %r0,
; ARC700: stb_s %r0, [%r[[BREG]], 0]

define void @store8(i8 zeroext %val, ptr %bp) nounwind {
entry:
  %gep = getelementptr i8, ptr %bp, i32 4000
  store i8 %val, ptr %gep, align 1
  ret void
}

; Short range stores can be done with [reg, s9].
; CHECK-LABEL: s_store32
; CHECK-NOT: add
; CHECK: st %r0, [%r1,64]
;
; ST_S scales by 4: [%r1, 16] is byte offset 64, same address.
; ARC700-LABEL: s_store32:
; ARC700-NOT: add
; ARC700: st_s %r0, [%r1, 16]
define void @s_store32(i32 %val, ptr %bp) nounwind {
entry:
  %gep = getelementptr i32, ptr %bp, i32 16
  store i32 %val, ptr %gep, align 4
  ret void
}

; CHECK-LABEL: s_store16
; CHECK-NOT: add
; CHECK: sth %r0, [%r1,32]
;
; STW_S scales by 2: [%r1, 16] is byte offset 32, same address.
; ARC700-LABEL: s_store16:
; ARC700-NOT: add
; ARC700: stw_s %r0, [%r1, 16]
define void @s_store16(i16 zeroext %val, ptr %bp) nounwind {
entry:
  %gep = getelementptr i16, ptr %bp, i32 16
  store i16 %val, ptr %gep, align 2
  ret void
}

; CHECK-LABEL: s_store8
; CHECK-NOT: add
; CHECK: stb %r0, [%r1,16]
;
; STB_S does not scale: byte offset 16 either way.
; ARC700-LABEL: s_store8:
; ARC700-NOT: add
; ARC700: stb_s %r0, [%r1, 16]
define void @s_store8(i8 zeroext %val, ptr %bp) nounwind {
entry:
  %gep = getelementptr i8, ptr %bp, i32 16
  store i8 %val, ptr %gep, align 1
  ret void
}


@aaaa = internal global [128 x i32] zeroinitializer
@bbbb = internal global [128 x i16] zeroinitializer
@cccc = internal global [128 x i8]  zeroinitializer

; CHECK-LABEL: g_store32
; CHECK-NOT: add
; CHECK: st %r0, [@aaaa+64]
;
; Absolute LIMM operand -- no compact encoding, unchanged on ARC700.
; ARC700-LABEL: g_store32:
; ARC700-NOT: add
; ARC700: st %r0, [@aaaa+64]
define void @g_store32(i32 %val) nounwind {
entry:
  store i32 %val, ptr getelementptr inbounds ([128 x i32], ptr @aaaa, i32 0, i32 16), align 4
  ret void
}

; CHECK-LABEL: g_load32
; CHECK-NOT: add
; CHECK: ld %r0, [@aaaa+64]
;
; Absolute LIMM operand -- no compact encoding, unchanged on ARC700.
; ARC700-LABEL: g_load32:
; ARC700-NOT: add
; ARC700: ld %r0, [@aaaa+64]
define i32 @g_load32() nounwind {
  %gep = getelementptr inbounds [128 x i32], ptr @aaaa, i32 0, i32 16
  %v = load i32, ptr %gep, align 4
  ret i32 %v
}

; CHECK-LABEL: g_store16
; CHECK-NOT: add
; CHECK: sth %r0, [@bbbb+32]
;
; Absolute LIMM operand -- no compact encoding, unchanged on ARC700.
; ARC700-LABEL: g_store16:
; ARC700-NOT: add
; ARC700: sth %r0, [@bbbb+32]
define void @g_store16(i16 %val) nounwind {
entry:
  store i16 %val, ptr getelementptr inbounds ([128 x i16], ptr @bbbb, i16 0, i16 16), align 2
  ret void
}

; CHECK-LABEL: g_load16
; CHECK-NOT: add
; CHECK: ldh %r0, [@bbbb+32]
;
; Absolute LIMM operand -- no compact encoding, unchanged on ARC700.
; ARC700-LABEL: g_load16:
; ARC700-NOT: add
; ARC700: ldh %r0, [@bbbb+32]
define i16 @g_load16() nounwind {
  %gep = getelementptr inbounds [128 x i16], ptr @bbbb, i16 0, i16 16
  %v = load i16, ptr %gep, align 2
  ret i16 %v
}

; CHECK-LABEL: g_store8
; CHECK-NOT: add
; CHECK: stb %r0, [@cccc+16]
;
; Absolute LIMM operand -- no compact encoding, unchanged on ARC700.
; ARC700-LABEL: g_store8:
; ARC700-NOT: add
; ARC700: stb %r0, [@cccc+16]
define void @g_store8(i8 %val) nounwind {
entry:
  store i8 %val, ptr getelementptr inbounds ([128 x i8], ptr @cccc, i8 0, i8 16), align 1
  ret void
}

; CHECK-LABEL: g_load8
; CHECK-NOT: add
; CHECK: ldb %r0, [@cccc+16]
;
; Absolute LIMM operand -- no compact encoding, unchanged on ARC700.
; ARC700-LABEL: g_load8:
; ARC700-NOT: add
; ARC700: ldb %r0, [@cccc+16]
define i8 @g_load8() nounwind {
  %gep = getelementptr inbounds [128 x i8], ptr @cccc, i8 0, i8 16
  %v = load i8, ptr %gep, align 1
  ret i8 %v
}

; CHECK-LABEL: align2_load32
; CHECK-DAG: ldh %r[[REG0:[0-9]+]], [%r0,0]
; CHECK-DAG: ldh %r[[REG1:[0-9]+]], [%r0,2]
; CHECK-DAG: asl %r[[REG2:[0-9]+]], %r[[REG1]], 16
;
; LDW_S scales by 2, so [%r0, 1] is byte offset 2. The halfword shifted left by
; 16 (i.e. the most significant one) is the one at byte offset 2 on
; little-endian and at byte offset 0 on big-endian -- that lane assignment IS
; the endianness, and it is what discriminates the two prefixes.
;
; Only the load->shift pair is pinned, not absolute instruction order: arc700eb
; uses the default schedule while bcm55030 has its own ProcessorModel, so the
; two BE profiles legitimately emit these in different orders.
; ARC700-LABEL: align2_load32:
; ARC700-NOT:   ldh %r
; ARC700LE-DAG: ldw_s %r{{[0-9]+}}, [%r0, 0]
; ARC700LE-DAG: ldw_s %r[[HI:[0-9]+]], [%r0, 1]
; ARC700LE:     asl %r{{[0-9]+}}, %r[[HI]], 16
; ARC700BE-DAG: ldw_s %r[[BHI:[0-9]+]], [%r0, 0]
; ARC700BE-DAG: ldw_s %r{{[0-9]+}}, [%r0, 1]
; ARC700BE:     asl %r{{[0-9]+}}, %r[[BHI]], 16
define i32 @align2_load32(ptr %p) nounwind {
entry:
  %bp = bitcast ptr %p to ptr
  %v = load i32, ptr %bp, align 2
  ret i32 %v
}

; CHECK-LABEL: align1_load32
; CHECK-DAG: ldb %r[[REG0:[0-9]+]], [%r0,0]
; CHECK-DAG: ldb %r[[REG1:[0-9]+]], [%r0,1]
; CHECK-DAG: ldb %r[[REG2:[0-9]+]], [%r0,2]
; CHECK-DAG: ldb %r[[REG3:[0-9]+]], [%r0,3]
; CHECK-DAG: asl %r[[AREG1:[0-9]+]], %r[[REG1]], 8
; CHECK-DAG: asl %r[[AREG2:[0-9]+]], %r[[REG2]], 16
; CHECK-DAG: asl %r[[AREG3:[0-9]+]], %r[[REG3]], 24
; CHECK-DAG: or %r[[AREG01:[0-9]+]], %r[[AREG1]], %r[[REG0]]
; CHECK-DAG: or %r[[AREG23:[0-9]+]], %r[[AREG3]], %r[[AREG2]]
; CHECK-DAG: or %r0, %r[[AREG23]], %r[[AREG01]]
;
; Four byte lanes, each with a fixed shift. LE assembles byte offset 0 as the
; least significant byte with offset 3 shifted by 24; BE is the exact mirror.
;
; All four compact loads are asserted unordered (the two BE profiles schedule
; them differently -- see align2_load32). The endianness discriminator is the
; single lane that carries the <<24: byte offset 3 on LE, byte offset 0 on BE.
; That load->shift pair is order-stable on every profile, so it is pinned
; ordered, and it is what makes each prefix reject the other's output.
; ARC700-LABEL: align1_load32:
; ARC700-NOT:   ldb %r
; ARC700LE-DAG: ldb_s %r{{[0-9]+}}, [%r0, 0]
; ARC700LE-DAG: ldb_s %r{{[0-9]+}}, [%r0, 1]
; ARC700LE-DAG: ldb_s %r{{[0-9]+}}, [%r0, 2]
; ARC700LE-DAG: ldb_s %r[[L3:[0-9]+]], [%r0, 3]
; ARC700LE:     asl %r{{[0-9]+}}, %r[[L3]], 24
; ARC700BE-DAG: ldb_s %r[[B0:[0-9]+]], [%r0, 0]
; ARC700BE-DAG: ldb_s %r{{[0-9]+}}, [%r0, 1]
; ARC700BE-DAG: ldb_s %r{{[0-9]+}}, [%r0, 2]
; ARC700BE-DAG: ldb_s %r{{[0-9]+}}, [%r0, 3]
; ARC700BE:     asl %r{{[0-9]+}}, %r[[B0]], 24
define i32 @align1_load32(ptr %p) nounwind {
entry:
  %bp = bitcast ptr %p to ptr
  %v = load i32, ptr %bp, align 1
  ret i32 %v
}

; CHECK-LABEL: align1_load16
; CHECK-DAG: ldb %r[[REG0:[0-9]+]], [%r0,0]
; CHECK-DAG: ldb %r[[REG1:[0-9]+]], [%r0,1]
; CHECK-DAG: asl %r[[REG2:[0-9]+]], %r[[REG1]], 8
;
; The byte carrying the <<8 is at offset 1 on LE and offset 0 on BE.
; ARC700-LABEL: align1_load16:
; ARC700-NOT:   ldb %r
; ARC700LE-DAG: ldb_s %r{{[0-9]+}}, [%r0, 0]
; ARC700LE-DAG: ldb_s %r[[H:[0-9]+]], [%r0, 1]
; ARC700LE:     asl %r{{[0-9]+}}, %r[[H]], 8
; ARC700BE-DAG: ldb_s %r[[BH:[0-9]+]], [%r0, 0]
; ARC700BE-DAG: ldb_s %r{{[0-9]+}}, [%r0, 1]
; ARC700BE:     asl %r{{[0-9]+}}, %r[[BH]], 8
define i16 @align1_load16(ptr %p) nounwind {
entry:
  %bp = bitcast ptr %p to ptr
  %v = load i16, ptr %bp, align 1
  ret i16 %v
}

; CHECK-LABEL: align2_store32
; CHECK-DAG: lsr %r[[REG:[0-9]+]], %r1, 16
; CHECK-DAG: sth %r1, [%r0,0]
; CHECK-DAG: sth %r[[REG:[0-9]+]], [%r0,2]
;
; The halfword shifted right by 16 (the high half of the value) is stored at
; byte offset 2 on LE and byte offset 0 on BE. STW_S scales by 2, so those
; print as [%r0, 1] and [%r0, 0] respectively.
; ARC700-LABEL: align2_store32:
; ARC700-NOT:   sth %r
; ARC700LE:     stw_s %r1, [%r0, 0]
; ARC700LE:     lsr %r[[SH:[0-9]+]], %r1, 16
; ARC700LE:     stw_s %r[[SH]], [%r0, 1]
; ARC700BE:     stw_s %r1, [%r0, 1]
; ARC700BE:     lsr %r[[BSH:[0-9]+]], %r1, 16
; ARC700BE:     stw_s %r[[BSH]], [%r0, 0]
define void @align2_store32(ptr %p, i32 %v) nounwind {
entry:
  %bp = bitcast ptr %p to ptr
  store i32 %v, ptr %bp, align 2
  ret void
}

; CHECK-LABEL: align1_store16
; CHECK-DAG: lsr %r[[REG:[0-9]+]], %r1, 8
; CHECK-DAG: stb %r1, [%r0,0]
; CHECK-DAG: stb %r[[REG:[0-9]+]], [%r0,1]
;
; ARC700-LABEL: align1_store16:
; ARC700-NOT:   stb %r
; ARC700LE:     stb_s %r1, [%r0, 0]
; ARC700LE:     lsr %r[[S8:[0-9]+]], %r1, 8
; ARC700LE:     stb_s %r[[S8]], [%r0, 1]
; ARC700BE:     stb_s %r1, [%r0, 1]
; ARC700BE:     lsr %r[[BS8:[0-9]+]], %r1, 8
; ARC700BE:     stb_s %r[[BS8]], [%r0, 0]
define void @align1_store16(ptr %p, i16 %v) nounwind {
entry:
  %bp = bitcast ptr %p to ptr
  store i16 %v, ptr %bp, align 1
  ret void
}

; CHECK-LABEL: align1_store32
; CHECK-DAG: lsr %r[[REG0:[0-9]+]], %r1, 8
; CHECK-DAG: lsr %r[[REG1:[0-9]+]], %r1, 16
; CHECK-DAG: lsr %r[[REG2:[0-9]+]], %r1, 24
; CHECK-DAG: stb %r1, [%r0,0]
; CHECK-DAG: stb %r[[REG0]], [%r0,1]
; CHECK-DAG: stb %r[[REG1]], [%r0,2]
; CHECK-DAG: stb %r[[REG2]], [%r0,3]
;
; Byte-lane mirror again: the unshifted low byte goes to offset 0 on LE and to
; offset 3 on BE, and the >>24 byte takes the opposite end.
; ARC700-LABEL: align1_store32:
; ARC700-NOT:   stb %r1, [%r0,0]
; ARC700LE:     stb_s %r1, [%r0, 0]
; ARC700LE:     lsr %r[[A:[0-9]+]], %r1, 24
; ARC700LE:     stb_s %r[[A]], [%r0, 3]
; ARC700LE:     lsr %r[[B:[0-9]+]], %r1, 16
; ARC700LE:     stb_s %r[[B]], [%r0, 2]
; ARC700LE:     lsr %r[[C:[0-9]+]], %r1, 8
; ARC700LE:     stb_s %r[[C]], [%r0, 1]
; ARC700BE:     stb_s %r1, [%r0, 3]
; ARC700BE:     lsr %r[[BA:[0-9]+]], %r1, 8
; ARC700BE:     stb_s %r[[BA]], [%r0, 2]
; ARC700BE:     lsr %r[[BB:[0-9]+]], %r1, 16
; ARC700BE:     stb_s %r[[BB]], [%r0, 1]
; ARC700BE:     lsr %r[[BC:[0-9]+]], %r1, 24
; ARC700BE:     stb_s %r[[BC]], [%r0, 0]
define void @align1_store32(ptr %p, i32 %v) nounwind {
entry:
  %bp = bitcast ptr %p to ptr
  store i32 %v, ptr %bp, align 1
  ret void
}
