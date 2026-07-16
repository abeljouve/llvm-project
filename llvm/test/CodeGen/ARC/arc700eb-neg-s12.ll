; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs -arc-disable-delay-filler -show-mc-encoding < %s | FileCheck %s
; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs < %s | not grep -E "mpy|swape|\bffs\b|\bfls\b|rtie|\bex\b|adds|subs|bset|bclr|bmsk|bxor"

; -arc-disable-delay-filler: this file tests instruction *selection* and
; encodings, not scheduling. The delay slot filler is a late pass that sinks
; the last instruction of a block into the return's delay slot, which leaves
; `j_s.d` sitting between instructions this file asserts are adjacent with
; CHECK-NEXT. The selected instructions and their encodings are unchanged --
; only the return moves -- so the filler is turned off here to keep those
; adjacency assertions meaningful and independent of the filler's heuristics.
; Delay-slot behaviour has its own coverage in delay-slot-filler.mir and
; arc700eb-delay-slot-*.mir.

; A signed 12-bit-representable i32 constant, positive OR negative, must
; select MOV_rs12 -- a single 4-byte host instruction, no LIMM extension
; word. The ISD::Constant fast-path test in ARCISelDAGToDAG.cpp used to
; check isInt<12> against the ZERO-extended 64-bit representation of the
; constant, which is only ever in [-2048, 2047] for non-negative values --
; every negative s12-fitting constant (e.g. -5, whose zero-extended pattern
; reads back as the large unsigned 0x00000000FFFFFFFB) wrongly fell through
; to the 8-byte MOV_rlimm / CONST32 paths. The fix sign-extends the low 32
; bits before the range test; the value handed to the MachineNode operand
; is unchanged (CVal, truncated to 32 bits, already carries the correct
; two's-complement pattern either way).
;
; `-show-mc-encoding` puts the raw instruction bytes in a trailing comment
; so this text-only lit test can distinguish MOV_rs12 (4-byte encoding)
; from MOV_rlimm (8-byte: 4-byte host + 4-byte LIMM word) or the CONST32
; mov_s+asl recipe (6 bytes across two instructions) without needing the
; workshop's authoritative big-endian disassembler -- that tool was used
; during development to confirm the exact byte patterns below are correct
; (`mov r0, -5` -> `20 8a 0e ff`; `mov r0, -2048` -> `20 8a 00 20`;
; `mov r0, -2049` (unchanged MOV_rlimm) -> `20 0a 0f 80 ff ff f7 ff`).

; ============================================================================
; Section A: negative s12 constants -- THE FIX. Each must be a single
; 4-byte MOV_rs12 encoding, never an 8-byte MOV_rlimm.
; ============================================================================

; --- -1: the most common small-negative sentinel ---
; CHECK-LABEL: c_neg1:
; CHECK: mov %r0, -1{{ *}}; encoding: [0x20,0x8a,0x0f,0xff]
define i32 @c_neg1() {
  ret i32 -1
}

; --- -5: the bug report's headline example ---
; CHECK-LABEL: c_neg5:
; CHECK: mov %r0, -5{{ *}}; encoding: [0x20,0x8a,0x0e,0xff]
define i32 @c_neg5() {
  ret i32 -5
}

; --- -129: crosses the s9/s12 boundary, still well within s12 ---
; CHECK-LABEL: c_neg129:
; CHECK: mov %r0, -129{{ *}}; encoding: [0x20,0x8a,0x0f,0xfd]
define i32 @c_neg129() {
  ret i32 -129
}

; --- -2048: s12 lower (inclusive) boundary -- must still fit MOV_rs12 ---
; CHECK-LABEL: c_neg2048:
; CHECK: mov %r0, -2048{{ *}}; encoding: [0x20,0x8a,0x00,0x20]
define i32 @c_neg2048() {
  ret i32 -2048
}

; ============================================================================
; Section B: boundary just outside s12 on the negative side -- must NOT
; regress to MOV_rs12. Byte-verified unchanged 8-byte MOV_rlimm encoding
; (the CONST32 seed<<shift recipe does not match 0xFFFFF7FF either: its
; residue after stripping trailing zero bits is far wider than a u8 seed).
; ============================================================================

; CHECK-LABEL: c_neg2049:
; CHECK: mov %r0, -2049{{ *}}; encoding: [0x20,0x0a,0x0f,0x80,0xff,0xff,0xf7,0xff]
define i32 @c_neg2049() {
  ret i32 -2049
}

; ============================================================================
; Section C: positive s12 constants -- unchanged. For any constant with
; bit31 of its 32-bit pattern clear, sign-extension is a no-op, so the
; fixed test is provably identical to the old one on these inputs.
; ============================================================================

; CHECK-LABEL: c_2000:
; CHECK: mov %r0, 2000{{ *}}; encoding: [0x20,0x8a,0x04,0x1f]
define i32 @c_2000() {
  ret i32 2000
}

; --- s12 upper (inclusive) boundary ---
; CHECK-LABEL: c_2047:
; CHECK: mov %r0, 2047{{ *}}; encoding: [0x20,0x8a,0x0f,0xdf]
define i32 @c_2047() {
  ret i32 2047
}

; ============================================================================
; Section D: boundary just outside s12 on the positive side -- unchanged,
; takes the CONST32 seed<<shift recipe (dossier 21 idea 4): 2048 == 1 << 11.
; ============================================================================

; CHECK-LABEL: c_2048:
; CHECK: mov_s %r0, 1{{ *}}; encoding: [0xd8,0x01]
; CHECK-NEXT: asl %r0, %r0, 11{{ *}}; encoding: [0x28,0x40,0x02,0xc0]
define i32 @c_2048() {
  ret i32 2048
}
