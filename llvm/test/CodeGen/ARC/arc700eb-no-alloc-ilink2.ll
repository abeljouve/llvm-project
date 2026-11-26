; RUN: llc -mtriple=arceb-unknown-unknown-elf -mcpu=bcm55030 -O2 < %s | FileCheck %s
; RUN: llc -mtriple=arceb-unknown-unknown-elf -mcpu=arc700eb -O2 < %s | FileCheck %s
; RUN: llc -mtriple=arceb-unknown-unknown-elf -O2 < %s | FileCheck %s

; On ARCompact r30 is ILINK2: the core writes the return address of a level-2
; interrupt into it on entry, at any instruction boundary, so a value held there
; is lost when such an interrupt is taken. Under enough register pressure the
; allocator used to pick it: with 26 values live at once, the load of p[8] went
; to `ld %r30, [%r0,32]` and its store to `st %r30, [%r1,32]`. r30 is reserved
; for every CPU, `generic` (no -mcpu) included.

; CHECK-LABEL: pressure:
; CHECK-NOT:   %r30
; CHECK-NOT:   ilink2
; CHECK:       j_s [%blink]

define void @pressure(ptr %p, ptr %q) {
entry:
  %a0 = getelementptr inbounds i32, ptr %p, i32 0
  %v0 = load volatile i32, ptr %a0, align 4
  %a1 = getelementptr inbounds i32, ptr %p, i32 1
  %v1 = load volatile i32, ptr %a1, align 4
  %a2 = getelementptr inbounds i32, ptr %p, i32 2
  %v2 = load volatile i32, ptr %a2, align 4
  %a3 = getelementptr inbounds i32, ptr %p, i32 3
  %v3 = load volatile i32, ptr %a3, align 4
  %a4 = getelementptr inbounds i32, ptr %p, i32 4
  %v4 = load volatile i32, ptr %a4, align 4
  %a5 = getelementptr inbounds i32, ptr %p, i32 5
  %v5 = load volatile i32, ptr %a5, align 4
  %a6 = getelementptr inbounds i32, ptr %p, i32 6
  %v6 = load volatile i32, ptr %a6, align 4
  %a7 = getelementptr inbounds i32, ptr %p, i32 7
  %v7 = load volatile i32, ptr %a7, align 4
  %a8 = getelementptr inbounds i32, ptr %p, i32 8
  %v8 = load volatile i32, ptr %a8, align 4
  %a9 = getelementptr inbounds i32, ptr %p, i32 9
  %v9 = load volatile i32, ptr %a9, align 4
  %a10 = getelementptr inbounds i32, ptr %p, i32 10
  %v10 = load volatile i32, ptr %a10, align 4
  %a11 = getelementptr inbounds i32, ptr %p, i32 11
  %v11 = load volatile i32, ptr %a11, align 4
  %a12 = getelementptr inbounds i32, ptr %p, i32 12
  %v12 = load volatile i32, ptr %a12, align 4
  %a13 = getelementptr inbounds i32, ptr %p, i32 13
  %v13 = load volatile i32, ptr %a13, align 4
  %a14 = getelementptr inbounds i32, ptr %p, i32 14
  %v14 = load volatile i32, ptr %a14, align 4
  %a15 = getelementptr inbounds i32, ptr %p, i32 15
  %v15 = load volatile i32, ptr %a15, align 4
  %a16 = getelementptr inbounds i32, ptr %p, i32 16
  %v16 = load volatile i32, ptr %a16, align 4
  %a17 = getelementptr inbounds i32, ptr %p, i32 17
  %v17 = load volatile i32, ptr %a17, align 4
  %a18 = getelementptr inbounds i32, ptr %p, i32 18
  %v18 = load volatile i32, ptr %a18, align 4
  %a19 = getelementptr inbounds i32, ptr %p, i32 19
  %v19 = load volatile i32, ptr %a19, align 4
  %a20 = getelementptr inbounds i32, ptr %p, i32 20
  %v20 = load volatile i32, ptr %a20, align 4
  %a21 = getelementptr inbounds i32, ptr %p, i32 21
  %v21 = load volatile i32, ptr %a21, align 4
  %a22 = getelementptr inbounds i32, ptr %p, i32 22
  %v22 = load volatile i32, ptr %a22, align 4
  %a23 = getelementptr inbounds i32, ptr %p, i32 23
  %v23 = load volatile i32, ptr %a23, align 4
  %a24 = getelementptr inbounds i32, ptr %p, i32 24
  %v24 = load volatile i32, ptr %a24, align 4
  %a25 = getelementptr inbounds i32, ptr %p, i32 25
  %v25 = load volatile i32, ptr %a25, align 4
  %b25 = getelementptr inbounds i32, ptr %q, i32 25
  store volatile i32 %v25, ptr %b25, align 4
  %b24 = getelementptr inbounds i32, ptr %q, i32 24
  store volatile i32 %v24, ptr %b24, align 4
  %b23 = getelementptr inbounds i32, ptr %q, i32 23
  store volatile i32 %v23, ptr %b23, align 4
  %b22 = getelementptr inbounds i32, ptr %q, i32 22
  store volatile i32 %v22, ptr %b22, align 4
  %b21 = getelementptr inbounds i32, ptr %q, i32 21
  store volatile i32 %v21, ptr %b21, align 4
  %b20 = getelementptr inbounds i32, ptr %q, i32 20
  store volatile i32 %v20, ptr %b20, align 4
  %b19 = getelementptr inbounds i32, ptr %q, i32 19
  store volatile i32 %v19, ptr %b19, align 4
  %b18 = getelementptr inbounds i32, ptr %q, i32 18
  store volatile i32 %v18, ptr %b18, align 4
  %b17 = getelementptr inbounds i32, ptr %q, i32 17
  store volatile i32 %v17, ptr %b17, align 4
  %b16 = getelementptr inbounds i32, ptr %q, i32 16
  store volatile i32 %v16, ptr %b16, align 4
  %b15 = getelementptr inbounds i32, ptr %q, i32 15
  store volatile i32 %v15, ptr %b15, align 4
  %b14 = getelementptr inbounds i32, ptr %q, i32 14
  store volatile i32 %v14, ptr %b14, align 4
  %b13 = getelementptr inbounds i32, ptr %q, i32 13
  store volatile i32 %v13, ptr %b13, align 4
  %b12 = getelementptr inbounds i32, ptr %q, i32 12
  store volatile i32 %v12, ptr %b12, align 4
  %b11 = getelementptr inbounds i32, ptr %q, i32 11
  store volatile i32 %v11, ptr %b11, align 4
  %b10 = getelementptr inbounds i32, ptr %q, i32 10
  store volatile i32 %v10, ptr %b10, align 4
  %b9 = getelementptr inbounds i32, ptr %q, i32 9
  store volatile i32 %v9, ptr %b9, align 4
  %b8 = getelementptr inbounds i32, ptr %q, i32 8
  store volatile i32 %v8, ptr %b8, align 4
  %b7 = getelementptr inbounds i32, ptr %q, i32 7
  store volatile i32 %v7, ptr %b7, align 4
  %b6 = getelementptr inbounds i32, ptr %q, i32 6
  store volatile i32 %v6, ptr %b6, align 4
  %b5 = getelementptr inbounds i32, ptr %q, i32 5
  store volatile i32 %v5, ptr %b5, align 4
  %b4 = getelementptr inbounds i32, ptr %q, i32 4
  store volatile i32 %v4, ptr %b4, align 4
  %b3 = getelementptr inbounds i32, ptr %q, i32 3
  store volatile i32 %v3, ptr %b3, align 4
  %b2 = getelementptr inbounds i32, ptr %q, i32 2
  store volatile i32 %v2, ptr %b2, align 4
  %b1 = getelementptr inbounds i32, ptr %q, i32 1
  store volatile i32 %v1, ptr %b1, align 4
  %b0 = getelementptr inbounds i32, ptr %q, i32 0
  store volatile i32 %v0, ptr %b0, align 4
  ret void
}
