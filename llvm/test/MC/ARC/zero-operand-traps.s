// The ARCompact zero-operand / u6-operand exception and halt family:
// trap_s u6, swi / trap0, brk / brk_s, unimp_s, sleep / sleep u6, plus the
// pre-existing sync / nop_s neighbours. Each needs an explicit dispatch in
// the hand-coded ARC asm parser; before it, `trap_s`, `swi`, `trap0`,
// `brk_s`, `unimp_s` and `sleep u6` were rejected as unsupported.
//
// Encodings (ARCompact PRM, 16-bit Table 71/73 and 32-bit Table 62), all
// byte-verified with an independent ARCompact decoder:
//   trap_s u6  = 0x781E | (u6 << 5)          16-bit, major 0x0F, sub 0x1E
//   brk_s      = 0x7FFF                      16-bit, major 0x0F, sub 0x1F
//   unimp_s    = 0x79E0                      16-bit ZOP_S, b = 0x01
//   swi/trap0  = 0x226F003F                  32-bit ZOP, B = 0x02
//   sleep [u6] = 0x216F003F | (u6 << 6)      32-bit ZOP, B = 0x01
// swi_s is an ARCv2 encoding (16-bit ZOP_S b = 0x02 is reserved on
// ARCompact) and stays rejected.

// RUN: llvm-mc -triple=arceb-unknown-elf -mcpu=arc700eb -show-encoding %s \
// RUN:   | FileCheck %s
// RUN: llvm-mc -triple=arceb-unknown-elf -mcpu=arc700eb -filetype=obj %s -o %t.o
// RUN: llvm-objdump -s -j .text %t.o | FileCheck --check-prefix=BYTES %s
// RUN: not llvm-mc -triple=arceb-unknown-elf -mcpu=arc700eb --defsym=ERR=1 \
// RUN:   %s -o /dev/null 2>&1 | FileCheck --check-prefix=ERR %s

trap_s 0
// CHECK: trap_s 0 {{.*}}encoding: [0x78,0x1e]
trap_s 1
// CHECK: trap_s 1 {{.*}}encoding: [0x78,0x3e]
trap_s 63
// CHECK: trap_s 63 {{.*}}encoding: [0x7f,0xfe]
brk_s
// CHECK: brk_s {{.*}}encoding: [0x7f,0xff]
unimp_s
// CHECK: unimp_s {{.*}}encoding: [0x79,0xe0]
nop_s
// CHECK: nop_s {{.*}}encoding: [0x78,0xe0]
swi
// CHECK: trap0 {{.*}}encoding: [0x22,0x6f,0x00,0x3f]
trap0
// CHECK: trap0 {{.*}}encoding: [0x22,0x6f,0x00,0x3f]
brk
// CHECK: brk {{.*}}encoding: [0x25,0x6f,0x00,0x3f]
sync
// CHECK: sync {{.*}}encoding: [0x23,0x6f,0x00,0x3f]
sleep
// CHECK: sleep {{.*}}encoding: [0x21,0x6f,0x00,0x3f]
// The operand form has no td def and is emitted as a raw word, so it is
// checked on the object bytes below rather than through -show-encoding.
sleep 1
sleep 63

// Big-endian byte stream of the whole .text section, in source order.
// BYTES:      0000 781e783e 7ffe7fff 79e078e0 226f003f
// BYTES-NEXT: 0010 226f003f 256f003f 236f003f 216f003f
// BYTES-NEXT: 0020 216f007f 216f0fff

.ifdef ERR
trap_s 64
// ERR: error: expected `trap_s <u6>` (constant 0..63)
trap_s r1
// ERR: error: expected `trap_s <u6>` (constant 0..63)
trap_s
// ERR: error: expected `trap_s <u6>` (constant 0..63)
sleep 64
// ERR: error: expected `sleep` or `sleep <u6>` (constant 0..63)
unimp_s 1
// ERR: error: expected bare `unimp_s`
swi_s
// ERR: error: ARC asm parser: unsupported mnemonic `swi_s`
.endif
