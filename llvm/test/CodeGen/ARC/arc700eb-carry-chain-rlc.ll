; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact -verify-machineinstrs -arc-disable-delay-filler < %s | FileCheck %s
; RUN: llc -march=arc -mcpu=generic < %s | FileCheck %s --check-prefix=NOARCOMPACT

; -arc-disable-delay-filler: this file tests instruction *selection* and
; encodings, not scheduling. The delay slot filler is a late pass that sinks
; the last instruction of a block into the return's delay slot, which leaves
; `j_s.d` sitting between instructions this file asserts are adjacent with
; CHECK-NEXT. The selected instructions and their encodings are unchanged --
; only the return moves -- so the filler is turned off here to keep those
; adjacency assertions meaningful and independent of the filler's heuristics.
; Delay-slot behaviour has its own coverage in delay-slot-filler.mir and
; arc700eb-delay-slot-*.mir.

; RLC/RRC carry-chain enablement (dossier 24,
; docs/llvm-arc700-optimizations/24-carry-chain-and-bit-serial-idioms.md).
;
; RLC/RRC exist in the ISA but previously had no ISel pattern of any kind
; (their carry operand is STATUS32.C, not a plain DAG value). They are now
; selected ONLY via two atomic MI pseudos (SHL64_1_PSEUDO /
; BITREV_STEP_PSEUDO, ARCInstrInfo.td) that bundle a `.f`-form ASL/LSR
; carry producer with its RLC consumer as one pre-RA instruction, recognized
; from ordinary i64/i32 DAG shapes by a DAGCombine on ISD::OR
; (performShl64By1Combine / performBitRevStepCombine, ARCISelLowering.cpp)
; and split into the two real instructions post-scheduling
; (ARCExpandPseudos.cpp), so nothing can be scheduled between the carry
; producer and consumer.
;
; PIN: only a literal 1-bit shift ever fuses. Multi-bit and variable shifts
; must fall through unchanged to the generic shift-add lowering -- no
; asl.f/lsr.f/rlc leaks. NOARCOMPACT confirms the negative-subtarget case
; (ARC_ASL_b_c_f/ARC_LSR_b_c_f/ARC_RLC_b_c are ARCompact-only encodings):
; the DAGCombine must decline (Subtarget.isARCompact() guard) rather than
; emit an encoding that hard-crashes at scheduling-info resolution.

; i64 << 1 -> asl.f (lo) + rlc (hi). 2 instructions instead of the generic
; 4-instruction lsr/asl/asl/or sequence.
; CHECK-LABEL: shl64by1:
; CHECK:      asl.f %r1, %r1
; CHECK-NEXT: rlc %r0, %r0
; CHECK-NOT:  lsr
; CHECK-NOT:  or
; NOARCOMPACT-LABEL: shl64by1:
; NOARCOMPACT-NOT: rlc
; NOARCOMPACT-NOT: asl.f
define i64 @shl64by1(i64 %x) {
entry:
  %r = shl i64 %x, 1
  ret i64 %r
}

; One bit-reverse step (unrolled `y = (y<<1)|(x&1); x >>= 1;`) -> lsr.f (x)
; + rlc (y).
; CHECK-LABEL: bitrevstep:
; CHECK:      lsr.f %r0, %r0
; CHECK-NEXT: rlc %r1, %r1
; NOARCOMPACT-LABEL: bitrevstep:
; NOARCOMPACT-NOT: rlc
; NOARCOMPACT-NOT: lsr.f
define { i32, i32 } @bitrevstep(i32 %x, i32 %y) {
entry:
  %bit = and i32 %x, 1
  %xn = lshr i32 %x, 1
  %ys = shl i32 %y, 1
  %yn = or i32 %ys, %bit
  %r0 = insertvalue { i32, i32 } undef, i32 %xn, 0
  %r1 = insertvalue { i32, i32 } %r0, i32 %yn, 1
  ret { i32, i32 } %r1
}

; Negative: multi-bit shift amount must NOT synthesize a carry chain --
; multi-bit barrel .f is not flag-identical to the single-bit SOP form
; (isa-characterization.md 5.1).
; CHECK-LABEL: shl64by3:
; CHECK-NOT: rlc
; CHECK:     asl {{.*}}, 3
define i64 @shl64by3(i64 %x) {
entry:
  %r = shl i64 %x, 3
  ret i64 %r
}

; Negative: variable (non-constant) shift amount never reaches the
; OR(SHL,SRL) shape at all (a different, compare-and-select expansion path
; is taken) -- confirm it falls through to the __ashldi3 libcall, no rlc.
; CHECK-LABEL: shl64var:
; CHECK-NOT: rlc
; CHECK: bl @__ashldi3
define i64 @shl64var(i64 %x, i32 %n) {
entry:
  %nn = zext i32 %n to i64
  %r = shl i64 %x, %nn
  ret i64 %r
}
