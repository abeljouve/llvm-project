# RUN: llvm-mca -mtriple=arceb-unknown-elf -mcpu=bcm55030 -iterations=100 < %s | FileCheck %s

# Quantifies the dossier-20 load-use latency-hiding win that the unroll +
# load-cluster hooks together produce, using the same calibrated BCM55030
# scheduling model the codegen uses. Two shapes of the same reduction work:
#
#   SERIAL (k=1): each element's load feeds its own dependent add before the
#   next load can issue. The model is in-order with no reorder buffer
#   (MicroOpBufferSize = 0), so the full 10-clock load-use latency is exposed
#   once per element: 100 iterations => 1101 cycles = 1 + 100 x 11, i.e.
#   11.0 cycles/element. This is what an un-unrolled recurrence costs.
#
#   CLUSTERED (k=4): four independent loads issue back-to-back into distinct
#   registers, filling each load's shadow, then the four adds drain. The
#   load-latency saturation point is ceil(10/2) = 5, so k=4 is already near the
#   knee: 100 iterations => 1701 cycles for 400 elements = 4.2525
#   cycles/element (steady state 2 + 9/4 = 4.25), a 2.6x speed-up over serial.
#
# This test measures the clustered k=4 body -- the shape the two hooks produce.
# It is written with the round-trippable rs9 load form so llvm-mca's assembler
# parses every instruction (the codegen-only register-offset post-increment
# form is emitted as raw bytes elsewhere and would be dropped here). The serial
# k=1 reference (1101 cycles => 11.0 cycles/element) is documented above.

# CHECK: Iterations:        100

# --- clustered k=4 body (the default shape the two hooks produce) ---
  ld  %r3, [%r2, 0]
  ld  %r4, [%r2, 4]
  ld  %r5, [%r2, 8]
  ld  %r6, [%r2, 12]
  add %r0, %r3, %r0
  add %r0, %r4, %r0
  add %r0, %r5, %r0
  add %r0, %r6, %r0

# 100 iterations x 8 instructions = 800; 400 elements over 1701 cycles = 4.25
# cycles/element, versus 11.0 for the serial recurrence.
# CHECK: Instructions:      800
# CHECK: Total Cycles:      1701
