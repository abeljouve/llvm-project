; REQUIRES: arc
;; Test we can infer the e_machine value of an ARC bitcode file.
;;
;; ARC is unusual: one triple covers two ELF machine types, EM_ARC_COMPACT for
;; the ARCompact ISA (ARC600/ARC700) and EM_ARC_COMPACT2 for ARCv2. Code
;; generation chooses between them from the "arcompact" subtarget feature, so
;; the e_machine we infer here has to follow the CPU/features that reach the LTO
;; backend -- --plugin-opt=mcpu= and -mllvm -mattr= -- rather than the triple.

; RUN: split-file %s %t

; RUN: llvm-as %t/be.s -o %t/be.o
; RUN: llvm-as %t/le.s -o %t/le.o

;; With no CPU or features given, the generic ARC subtarget is ARCv2.
; RUN: ld.lld %t/be.o -o %t/be-v2
; RUN: llvm-readobj -h %t/be-v2 | FileCheck %s --check-prefixes=CHECK,BE,ARCV2
; RUN: ld.lld %t/le.o -o %t/le-v2
; RUN: llvm-readobj -h %t/le-v2 | FileCheck %s --check-prefixes=CHECK,LE,ARCV2

;; An ARCompact CPU selects EM_ARC_COMPACT, for either endianness.
; RUN: ld.lld --plugin-opt=mcpu=arc700eb %t/be.o -o %t/be-compact
; RUN: llvm-readobj -h %t/be-compact | FileCheck %s --check-prefixes=CHECK,BE,COMPACT
; RUN: ld.lld --plugin-opt=mcpu=arc700 %t/le.o -o %t/le-compact
; RUN: llvm-readobj -h %t/le-compact | FileCheck %s --check-prefixes=CHECK,LE,COMPACT

;; Requesting the bare feature works too, without naming a CPU.
; RUN: ld.lld -mllvm -mattr=+arcompact %t/be.o -o %t/be-compact-attr
; RUN: llvm-readobj -h %t/be-compact-attr | FileCheck %s --check-prefixes=CHECK,BE,COMPACT

;; Match the numeric value too: "EM_ARC_COMPACT" is a prefix of
;; "EM_ARC_COMPACT2", so a bare name would match either.
; CHECK:       Class: 32-bit
; BE:          DataEncoding: BigEndian
; LE:          DataEncoding: LittleEndian
; ARCV2:       Machine: EM_ARC_COMPACT2 (0xC3)
; COMPACT:     Machine: EM_ARC_COMPACT (0x5D)

;--- be.s
target datalayout = "E-m:e-p:32:32-i1:8:32-i8:8:32-i16:16:32-i32:32:32-f32:32:32-i64:32-f64:32-a:0:32-n32"
target triple = "arceb-unknown-unknown-elf"

define void @_start() {
entry:
  ret void
}

;--- le.s
target datalayout = "e-m:e-p:32:32-i1:8:32-i8:8:32-i16:16:32-i32:32:32-f32:32:32-i64:32-f64:32-a:0:32-n32"
target triple = "arc-unknown-unknown-elf"

define void @_start() {
entry:
  ret void
}
