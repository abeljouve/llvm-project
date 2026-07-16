# RUN: llvm-mca -mtriple=arceb-unknown-elf -mcpu=bcm55030 -iterations=100 < %s | FileCheck %s

# Pins BCM55030Model's load timing against the silicon it was measured on, and
# in doing so pins the fact that llvm-mca runs on ARC at all.
#
# Two things had to be true for this test to be possible, and each is easy to
# undo by accident:
#
#  1. A scheduling model exists for this CPU. Without one, llvm-mca refuses the
#     target outright ("unable to find instruction-level scheduling
#     information") and never reaches the first instruction.
#  2. ARC registers an MCInstrAnalysis (ARCMCTargetDesc.cpp). llvm-mca's
#     InstrBuilder dereferences it without a null check when it classifies calls
#     and returns, so a target without one crashes there. ARC only escaped that
#     path for as long as llvm-mca was bailing out at (1).
#
# Delete either and this test stops running rather than failing loudly, so keep
# the CHECK on a real number.

  ld  %r9, [%r9, 0]

# A self-referential chase: every iteration's load address is the previous
# iteration's loaded value, so the recurrence is one load-use edge per
# iteration and the cost per iteration IS the load-use latency.
#
# 100 iterations => 1001 cycles = 1 + 100 x 10, i.e. exactly 10 cycles per
# dependent load. Sweeping the iteration count gives cycles = 1 + 10N with zero
# residual (N = 10/20/40/80 -> 101/201/401/801), so the 10 is a measured slope
# here and not an artifact of one data point.
#
# That is the same 10 the silicon reports: a 64-node chase measures 632 ticks =
# 1 (harness) + 63 (edges) x 10 + 1 (tail). This model and that part agree to
# the clock.
#
# There is no D-cache in the shipping configuration, so 10 is what EVERY load
# costs -- not a hit time to be averaged against a miss.

# CHECK: Iterations:        100
# CHECK-NEXT: Instructions:      100
# CHECK-NEXT: Total Cycles:      1001

# Dispatch Width 1: single-issue, from 64 INDEPENDENT adds measuring 65 ticks
# (= 1 + 64 x 1). RThroughput 2.00: the load holds the load/store pipe for 2
# cycles, from the shadow sweep (see bcm55030-load-shadow.s).

# CHECK: Dispatch Width:    1
# CHECK: Block RThroughput: 2.0

# CHECK: [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT: 1      10    2.00    *                   ld	%r9, [%r9,0]

# Two separate pipes, and a load touches only the load/store one. The ALU pipe
# must show no pressure at all here -- an interleaved load/ALU mix costs about
# max(load-only, alu-only) rather than their sum, which is what says these
# overlap instead of sharing one issue unit.

# CHECK: Resources:
# CHECK-NEXT: [0]   - BCM55030ALU
# CHECK-NEXT: [1]   - BCM55030LSU

# CHECK: Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]
# CHECK-NEXT:  -     2.00
