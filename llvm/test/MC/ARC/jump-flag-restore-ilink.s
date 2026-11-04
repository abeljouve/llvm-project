// Interrupt / exception return: `j.f [ilink1]` / `j.f [ilink2]` jump to
// ILINKn and restore STATUS32 from STATUS32_L1 / STATUS32_L2. This is the
// return the `rtie` diagnostic points to on ARC700 profiles without RTIE.
// The parser used to reject both the `j.f` mnemonic and the `ilink1` /
// `ilink2` register names (only `ilink` was known).
//
// Encoding: J (major 0x04, sub-opcode 0x20, P = 00) with F (bit 15) set,
// C = 29 / 30: 0x20208740 / 0x20208780 (the ARC_J_ilink1 / ARC_J_ilink2
// opcodes). Byte-verified with an independent ARCompact decoder, which
// reports both as a jump to r29 / r30 with flag restore. The F form is only
// defined with ILINK1/2; any other register raises an Instruction Error, so
// the assembler refuses it.

// RUN: llvm-mc -triple=arceb-unknown-elf -mcpu=arc700eb -filetype=obj %s -o %t.o
// RUN: llvm-objdump -s -j .text %t.o | FileCheck --check-prefix=BYTES %s
// RUN: llvm-mc -triple=arceb-unknown-elf -mcpu=arc700eb -show-encoding %s \
// RUN:   | FileCheck %s
// RUN: not llvm-mc -triple=arceb-unknown-elf -mcpu=arc700eb --defsym=ERR=1 \
// RUN:   %s -o /dev/null 2>&1 | FileCheck --check-prefix=ERR %s

j.f [ilink1]
j.f [ilink2]
// The architectural names alias the numeric registers.
j.f [r29]
j.f [r30]
j.f [ilink]
// ilink1 / ilink2 are ordinary register operands elsewhere too.
j [ilink1]
// CHECK: j [%ilink] {{.*}}encoding: [0x20,0x20,0x07,0x40]
j [ilink2]
// CHECK: j [%r30] {{.*}}encoding: [0x20,0x20,0x07,0x80]
mov r0, ilink2
// CHECK: mov %r0, %r30 {{.*}}encoding: [0x20,0x0a,0x07,0x80]

// BYTES:      0000 20208740 20208780 20208740 20208780
// BYTES-NEXT: 0010 20208740 20200740 20200780 200a0780

.ifdef ERR
j.f [blink]
// ERR: error: j.f target must be ilink1 or ilink2 (any other register raises an Instruction Error)
j.f [r1]
// ERR: error: j.f target must be ilink1 or ilink2 (any other register raises an Instruction Error)
j.f [ilink1, 4]
// ERR: error: expected `j.f [ilink1]` or `j.f [ilink2]`
j.f ilink1
// ERR: error: expected `j.f [ilink1]` or `j.f [ilink2]`
.endif
