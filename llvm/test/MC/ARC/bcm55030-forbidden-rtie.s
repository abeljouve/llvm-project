// Negative-legality regression test (dossier 00): `rtie` is a valid
// ARCompact encoding, but silicon characterization shows it is ABSENT on
// the BCM55030 ARC700 integration -- it enters Instruction Error vector 2
// instead of returning from an interrupt (docs/notes/isa-characterization.md).
// The required interrupt-return mechanism on this profile is
// `j.f [ILINK1/2]`, not RTIE. FeatureRTIE stays OFF for every current Proc
// (see ARC.td), so the assembler must reject `rtie` with a feature
// diagnostic rather than silently emitting a trapping opcode.

// RUN: not llvm-mc -triple=arceb-unknown-elf -filetype=asm %s 2>&1 | FileCheck %s
// RUN: llvm-mc -triple=arceb-unknown-elf -mattr=+rtie -filetype=asm %s -o /dev/null

rtie
// CHECK: error: rtie is not available on this ARC700 profile
