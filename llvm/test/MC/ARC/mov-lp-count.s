; RUN: llvm-mc -triple=arceb-unknown-elf -mcpu=arc700eb -show-encoding %s | FileCheck %s
;
; Negative check: `lp_count` must resolve to the register r60, NOT be captured
; as an undefined symbol reference. If it were still parsed as a symbol the
; printed form would contain the string `lp_count`; after the fix it prints as
; %r60, so the name must not survive into the output:
; RUN: llvm-mc -triple=arceb-unknown-elf -mcpu=arc700eb %s | not grep -i lp_count

; r60 doubles as the zero-overhead-loop counter LP_COUNT. The assembler must
; accept the architectural alias `lp_count` as a MOV destination and emit the
; same 32-bit GEN4 MOV form as the numeric `r60`. Byte-verified against the
; authoritative ARC disassembler: 24 0a 73 00 decodes to `mov lp_count, r12`.

mov lp_count, r12
; CHECK: mov %r60, %r12 {{.*}}encoding: [0x24,0x0a,0x73,0x00]

mov r60, r12
; CHECK: mov %r60, %r12 {{.*}}encoding: [0x24,0x0a,0x73,0x00]
