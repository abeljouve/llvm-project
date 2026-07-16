; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -march=arceb -mcpu=arc700eb -mattr=-arcompact -verify-machineinstrs < %s | FileCheck %s --check-prefix=NOCOMPACT
; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs < %s | not grep -E "mpy|swape|\bffs\b|\bfls\b|rtie|\bex\b|adds|subs"

; ARCSizeReduction: immediate-offset compact 16-bit load/store.
; Dossier 05 step 5 covered the general register-relative forms (SP-relative
; word was dossier 04); dossier 05's remaining work added the sign-extending
; half-word load (ldw_s.x) and the SP-relative byte forms, in their own
; labelled sections at the end of this file. PCL-relative/GP-relative are
; dossiers 04/03, not exercised here.
;
; Two structural bugs in ARCARCompactInstr16.td had to be fixed before any
; of this could fire:
;   - ARC_LD_S_c_b_u7 / ARC_LDB_S_c_b_u5 / ARC_LDW_S_c_b_u6 had their
;     outs/ins DAG roles swapped: the generator bound the DESTINATION to
;     the BASE register's bitfield and vice versa, a silent register-swap
;     miscompile. Byte-verified against the authoritative BE-ARC
;     disassembler (projects/bcm55030-retools/target/release/disasm):
;     encoding 0x8143 (rb_s=1, rc_s=2, u7enc=3) decodes to `ld r2,[r1,0xC]`
;     -- dest is the rc_s field, base is the rb_s field.
;   - every compact 16-bit load/store descriptor (plus the pre-existing
;     SP_LD_S/SP_ST_S) never declared mayLoad/mayStore, so attaching a
;     MachineMemOperand for MMO preservation tripped MachineVerifier.
; The store forms (ARC_ST_S_c_b_u7/ARC_STB_S_c_b_u5/ARC_STW_S_c_b_u6) were
; already byte-correct (stores have no destination, so no def/use swap was
; possible).
;
; MIR-level boundary/negative coverage (max-in-range, just-over-range,
; misaligned, non-GPR_S operands, volatile) lives in
; arc700eb-size-reduction-compact-ldst.mir; this file is the source-level
; (llc mnemonic) coverage confirming the reduction actually fires end to
; end and is gated correctly behind the ARCompact feature.

; ============================================================================
; Word load/store, general (non-SP) GPR_S base. Offset 12 -- exercises the
; word scale (encoded field 3 = 12/4).
; ============================================================================

; CHECK-LABEL: ld_word_general:
; CHECK: ld_s %r0, [%r0, 3]
; NOCOMPACT-LABEL: ld_word_general:
; NOCOMPACT-NOT: ld_s
define i32 @ld_word_general(ptr %p) minsize optsize {
  %g = getelementptr inbounds i8, ptr %p, i32 12
  %v = load i32, ptr %g, align 4
  ret i32 %v
}

; CHECK-LABEL: st_word_general:
; CHECK: st_s %r1, [%r0, 3]
; NOCOMPACT-LABEL: st_word_general:
; NOCOMPACT-NOT: st_s
define void @st_word_general(ptr %p, i32 %v) minsize optsize {
  %g = getelementptr inbounds i8, ptr %p, i32 12
  store i32 %v, ptr %g, align 4
  ret void
}

; ============================================================================
; Byte load/store, general base. Offset 5 -- byte access is unscaled.
; ============================================================================

; CHECK-LABEL: ld_byte_general:
; CHECK: ldb_s %r0, [%r0, 5]
; NOCOMPACT-LABEL: ld_byte_general:
; NOCOMPACT-NOT: ldb_s
define i32 @ld_byte_general(ptr %p) minsize optsize {
  %g = getelementptr inbounds i8, ptr %p, i32 5
  %v = load i8, ptr %g, align 1
  %z = zext i8 %v to i32
  ret i32 %z
}

; CHECK-LABEL: st_byte_general:
; CHECK: stb_s %r1, [%r0, 5]
; NOCOMPACT-LABEL: st_byte_general:
; NOCOMPACT-NOT: stb_s
define void @st_byte_general(ptr %p, i8 %v) minsize optsize {
  %g = getelementptr inbounds i8, ptr %p, i32 5
  store i8 %v, ptr %g, align 1
  ret void
}

; ============================================================================
; Half-word load/store, general base. Offset 6 -- exercises the half scale
; (encoded field 3 = 6/2).
; ============================================================================

; CHECK-LABEL: ld_half_general:
; CHECK: ldw_s %r0, [%r0, 3]
; NOCOMPACT-LABEL: ld_half_general:
; NOCOMPACT-NOT: ldw_s
define i32 @ld_half_general(ptr %p) minsize optsize {
  %g = getelementptr inbounds i8, ptr %p, i32 6
  %v = load i16, ptr %g, align 2
  %z = zext i16 %v to i32
  ret i32 %z
}

; CHECK-LABEL: st_half_general:
; CHECK: stw_s %r1, [%r0, 3]
; NOCOMPACT-LABEL: st_half_general:
; NOCOMPACT-NOT: stw_s
define void @st_half_general(ptr %p, i16 %v) minsize optsize {
  %g = getelementptr inbounds i8, ptr %p, i32 6
  store i16 %v, ptr %g, align 2
  ret void
}

; ============================================================================
; Zero-offset [rb] is not a separate opcode -- just Off==0 within the
; immediate-offset encoding. Confirm it still reduces.
; ============================================================================

; CHECK-LABEL: ld_word_zero_offset:
; CHECK: ld_s %r0, [%r0, 0]
define i32 @ld_word_zero_offset(ptr %p) minsize optsize {
  %v = load i32, ptr %p, align 4
  ret i32 %v
}

; ============================================================================
; Sign-extending half-word load, general base -> ldw_s.x (major 0x13).
;
; `sextloadi16` selects LDH_X_rs9, which is a distinct opcode from the
; zero-extending LDH_rs9 and needs the distinct narrow target
; ARC_LDW_S_c_b_u6_v1. That descriptor previously had NO bit bindings at all
; (it encoded a fixed 0x9800 = `ldw.x r0,[r0,0x0]` regardless of operands) and
; a destination/base def-use swap; both repaired in ARCARCompactInstr16.td and
; byte-verified with the authoritative BE-ARC disassembler:
; 0x9943 (rb_s=1, rc_s=2, u6enc=3) -> `ldw.x r2,[r1,0x6]`.
;
; Offset 6 exercises the half scale (encoded field 3 = 6/2), same as
; ld_half_general above -- the printed operand is the ENCODED field, not the
; byte offset.
; ============================================================================

; CHECK-LABEL: ld_half_sext_general:
; CHECK: ldw_s.x %r0, [%r0, 3]
; NOCOMPACT-LABEL: ld_half_sext_general:
; NOCOMPACT: ldh.x %r0, [%r0,6]
; NOCOMPACT-NOT: ldw_s.x
define signext i16 @ld_half_sext_general(ptr %p) minsize optsize {
  %g = getelementptr inbounds i8, ptr %p, i32 6
  %v = load i16, ptr %g, align 2
  ret i16 %v
}

; ============================================================================
; SP-relative byte load/store -> ldb_s/stb_s b3,[%sp,u7] (major 0x18,
; sub-opcodes 0x01/0x03).
;
; MIND THE SCALING ASYMMETRY: unlike the general-base byte forms above (u5,
; unscaled), the SP format's U7 field is 4-SCALED even for byte access --
; Table 76 specifies "actual offset is U7 = u[4:0] << 2" for ALL of its
; sub-opcodes. The td class F16_SP_OPS_u7_aligned performs the >>2 itself, so
; the PRINTED operand here is the full byte offset (20), whereas the
; general-base forms print the pre-divided encoded field. Byte-verified:
; 0xC523 -> `ldb r13,[sp,0xC]`, 0xC563 -> `stb r13,[sp,0xC]`.
;
; The alloca gives a 4-aligned byte slot at %sp+20; the call to @use forces
; the alloca to stay addressable in memory rather than being promoted. These
; functions carry no "frame-pointer" attribute, so the frame pointer is
; eliminated and the accesses are SP-based -- with a frame pointer the base
; would be %fp (R27, not in GPR_S) at a negative offset and no compact form
; would apply at all.
; ============================================================================

; CHECK-LABEL: ldst_byte_sp:
; CHECK: stb_s %r0, [%sp, 20]
; CHECK: ldb_s %r0, [%sp, 20]
; NOCOMPACT-LABEL: ldst_byte_sp:
; NOCOMPACT-NOT: stb_s
; NOCOMPACT-NOT: ldb_s
define i32 @ldst_byte_sp(i8 %v) minsize optsize {
  %a = alloca [64 x i8], align 4
  %p = getelementptr inbounds [64 x i8], ptr %a, i32 0, i32 16
  store i8 %v, ptr %p, align 4
  call void @use_ptr(ptr %a)
  %l = load i8, ptr %p, align 4
  %z = zext i8 %l to i32
  ret i32 %z
}

declare void @use_ptr(ptr)
