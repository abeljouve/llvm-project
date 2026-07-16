; REQUIRES: arc
;; Mixing bitcode with regular ELF objects is supported, so the e_machine we
;; infer for an ARC bitcode input has to agree with the one the LTO backend will
;; actually emit for it. Both are driven by the "arcompact" subtarget feature,
;; which reaches code generation through --plugin-opt=mcpu= / -mllvm -mattr=.
;;
;; Check that an ARCompact link and an ARCv2 link each accept the matching ELF
;; object, and that a genuine ISA mismatch is still rejected in both directions.

; RUN: split-file %s %t
; RUN: llvm-as %t/be.s -o %t/be.o
; RUN: llvm-mc -filetype=obj -triple=arceb-unknown-elf -mcpu=arc700eb %t/asm.s -o %t/compact.o
; RUN: llvm-mc -filetype=obj -triple=arceb-unknown-elf -mcpu=generic %t/asm.s -o %t/v2.o

;; Default (no CPU/features): bitcode is ARCv2, so the ARCv2 object fits.
; RUN: ld.lld %t/be.o %t/v2.o -o %t/v2
; RUN: llvm-readobj -h %t/v2 | FileCheck %s --check-prefix=ARCV2

;; An ARCompact CPU makes the bitcode ARCompact, so the ARCompact object fits.
; RUN: ld.lld --plugin-opt=mcpu=arc700eb %t/be.o %t/compact.o -o %t/compact
; RUN: llvm-readobj -h %t/compact | FileCheck %s --check-prefix=COMPACT

;; Match the numeric value too: "EM_ARC_COMPACT" is a prefix of
;; "EM_ARC_COMPACT2", so a bare name would match either.
; ARCV2:   Machine: EM_ARC_COMPACT2 (0xC3)
; COMPACT: Machine: EM_ARC_COMPACT (0x5D)

;; An ARCompact object in a default (ARCv2) link is a real mismatch: reject it.
; RUN: not ld.lld %t/be.o %t/compact.o -o /dev/null 2>&1 | FileCheck %s --check-prefix=ERR-COMPACT
; ERR-COMPACT: error: {{.*}}compact.o is incompatible with {{.*}}be.o

;; ... and so is an ARCv2 object in an ARCompact link.
; RUN: not ld.lld --plugin-opt=mcpu=arc700eb %t/be.o %t/v2.o -o /dev/null 2>&1 | FileCheck %s --check-prefix=ERR-V2
; ERR-V2: error: {{.*}}v2.o is incompatible with {{.*}}be.o

;--- be.s
target datalayout = "E-m:e-p:32:32-i1:8:32-i8:8:32-i16:16:32-i32:32:32-f32:32:32-i64:32-f64:32-a:0:32-n32"
target triple = "arceb-unknown-unknown-elf"

define void @_start() {
entry:
  ret void
}

;--- asm.s
.text
.globl g
g:
  nop
