# RUN: llvm-mca -mtriple=arceb-unknown-elf -mcpu=bcm55030 -iterations=32 < %s | FileCheck %s

# Pins the single property this whole model exists to exploit: LOADS ARE
# NON-BLOCKING on this core. The interlock is on the CONSUMER of a load, not at
# issue, so independent work placed after a load runs inside its 10-cycle
# shadow for free.
#
# Eight independent adds sit under a dependent chase load. The adds target
# r16..r23 and never touch r9, so nothing here depends on the load.

  ld  %r9, [%r9, 0]
  add %r16, %r0, %r1
  add %r17, %r0, %r1
  add %r18, %r0, %r1
  add %r19, %r0, %r1
  add %r20, %r0, %r1
  add %r21, %r0, %r1
  add %r22, %r0, %r1
  add %r23, %r0, %r1

# 32 iterations => 321 cycles = 1 + 32 x 10. That is the SAME cost as the bare
# chase load with no adds at all (also 321): all eight adds are free.
#
# Silicon agrees: the shadow sweep measures 315 ticks with zero adds and 324
# with eight -- 8 extra instructions per node for +9 ticks TOTAL across 32
# nodes. Had loads blocked, those adds would have had to wait out the load and
# this would cost ~32 x 18 = 576.
#
# This number is the one that would silently rot. It depends on RetireOOO = 1 on
# the ALU write in ARCScheduleBCM55030.td: llvm-mca's in-order pipeline assumes
# writeback happens in program order and, without that bit, stalls each add
# until the load ahead of it lands -- reporting 545 (17 cycles/node) instead of
# 321. The core demonstrably has no such interlock. RetireOOO is read only by
# llvm-mca and changes no generated code, so nothing but this test will notice
# if it disappears.

# CHECK: Iterations:        32
# CHECK-NEXT: Instructions:      288
# CHECK-NEXT: Total Cycles:      321

# CHECK: [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT: 1      10    2.00    *                   ld	%r9, [%r9,0]
# CHECK-NEXT: 1      1     1.00                        add	%r16, %r0, %r1

# The adds land on the ALU pipe (8 x 1.00 = 8.00) while the load holds the
# load/store pipe (2.00). Separate pipes, overlapping.

# CHECK: Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]
# CHECK-NEXT: 8.00   2.00
