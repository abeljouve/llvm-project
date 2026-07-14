; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact < %s | FileCheck %s

; ARCBranchFinalize per-branch range fix: a compare-and-branch in a function
; larger than the s9 whole-function span used to degrade to `cmp` + `Bcc`
; (2 insns) because the range check looked at the whole function size. With
; the per-branch displacement check the short in-range loop back-edge stays a
; single `brne` compare-and-branch.

define void @big_fn_with_loop(ptr %out, i32 %seed, i32 %n) {
entry:
  %p0 = getelementptr i32, ptr %out, i32 0
  %v0 = add i32 %seed, 1
  store volatile i32 %v0, ptr %p0
  %p1 = getelementptr i32, ptr %out, i32 1
  %v1 = add i32 %seed, 8
  store volatile i32 %v1, ptr %p1
  %p2 = getelementptr i32, ptr %out, i32 2
  %v2 = add i32 %seed, 15
  store volatile i32 %v2, ptr %p2
  %p3 = getelementptr i32, ptr %out, i32 3
  %v3 = add i32 %seed, 22
  store volatile i32 %v3, ptr %p3
  %p4 = getelementptr i32, ptr %out, i32 4
  %v4 = add i32 %seed, 29
  store volatile i32 %v4, ptr %p4
  %p5 = getelementptr i32, ptr %out, i32 5
  %v5 = add i32 %seed, 36
  store volatile i32 %v5, ptr %p5
  %p6 = getelementptr i32, ptr %out, i32 6
  %v6 = add i32 %seed, 43
  store volatile i32 %v6, ptr %p6
  %p7 = getelementptr i32, ptr %out, i32 7
  %v7 = add i32 %seed, 50
  store volatile i32 %v7, ptr %p7
  %p8 = getelementptr i32, ptr %out, i32 8
  %v8 = add i32 %seed, 57
  store volatile i32 %v8, ptr %p8
  %p9 = getelementptr i32, ptr %out, i32 9
  %v9 = add i32 %seed, 64
  store volatile i32 %v9, ptr %p9
  %p10 = getelementptr i32, ptr %out, i32 10
  %v10 = add i32 %seed, 71
  store volatile i32 %v10, ptr %p10
  %p11 = getelementptr i32, ptr %out, i32 11
  %v11 = add i32 %seed, 78
  store volatile i32 %v11, ptr %p11
  %p12 = getelementptr i32, ptr %out, i32 12
  %v12 = add i32 %seed, 85
  store volatile i32 %v12, ptr %p12
  %p13 = getelementptr i32, ptr %out, i32 13
  %v13 = add i32 %seed, 92
  store volatile i32 %v13, ptr %p13
  %p14 = getelementptr i32, ptr %out, i32 14
  %v14 = add i32 %seed, 99
  store volatile i32 %v14, ptr %p14
  %p15 = getelementptr i32, ptr %out, i32 15
  %v15 = add i32 %seed, 106
  store volatile i32 %v15, ptr %p15
  %p16 = getelementptr i32, ptr %out, i32 16
  %v16 = add i32 %seed, 113
  store volatile i32 %v16, ptr %p16
  %p17 = getelementptr i32, ptr %out, i32 17
  %v17 = add i32 %seed, 120
  store volatile i32 %v17, ptr %p17
  %p18 = getelementptr i32, ptr %out, i32 18
  %v18 = add i32 %seed, 127
  store volatile i32 %v18, ptr %p18
  %p19 = getelementptr i32, ptr %out, i32 19
  %v19 = add i32 %seed, 134
  store volatile i32 %v19, ptr %p19
  %p20 = getelementptr i32, ptr %out, i32 20
  %v20 = add i32 %seed, 141
  store volatile i32 %v20, ptr %p20
  %p21 = getelementptr i32, ptr %out, i32 21
  %v21 = add i32 %seed, 148
  store volatile i32 %v21, ptr %p21
  %p22 = getelementptr i32, ptr %out, i32 22
  %v22 = add i32 %seed, 155
  store volatile i32 %v22, ptr %p22
  %p23 = getelementptr i32, ptr %out, i32 23
  %v23 = add i32 %seed, 162
  store volatile i32 %v23, ptr %p23
  %p24 = getelementptr i32, ptr %out, i32 24
  %v24 = add i32 %seed, 169
  store volatile i32 %v24, ptr %p24
  %p25 = getelementptr i32, ptr %out, i32 25
  %v25 = add i32 %seed, 176
  store volatile i32 %v25, ptr %p25
  %p26 = getelementptr i32, ptr %out, i32 26
  %v26 = add i32 %seed, 183
  store volatile i32 %v26, ptr %p26
  %p27 = getelementptr i32, ptr %out, i32 27
  %v27 = add i32 %seed, 190
  store volatile i32 %v27, ptr %p27
  %p28 = getelementptr i32, ptr %out, i32 28
  %v28 = add i32 %seed, 197
  store volatile i32 %v28, ptr %p28
  %p29 = getelementptr i32, ptr %out, i32 29
  %v29 = add i32 %seed, 204
  store volatile i32 %v29, ptr %p29
  %p30 = getelementptr i32, ptr %out, i32 30
  %v30 = add i32 %seed, 211
  store volatile i32 %v30, ptr %p30
  %p31 = getelementptr i32, ptr %out, i32 31
  %v31 = add i32 %seed, 218
  store volatile i32 %v31, ptr %p31
  %p32 = getelementptr i32, ptr %out, i32 32
  %v32 = add i32 %seed, 225
  store volatile i32 %v32, ptr %p32
  %p33 = getelementptr i32, ptr %out, i32 33
  %v33 = add i32 %seed, 232
  store volatile i32 %v33, ptr %p33
  %p34 = getelementptr i32, ptr %out, i32 34
  %v34 = add i32 %seed, 239
  store volatile i32 %v34, ptr %p34
  %p35 = getelementptr i32, ptr %out, i32 35
  %v35 = add i32 %seed, 246
  store volatile i32 %v35, ptr %p35
  %p36 = getelementptr i32, ptr %out, i32 36
  %v36 = add i32 %seed, 253
  store volatile i32 %v36, ptr %p36
  %p37 = getelementptr i32, ptr %out, i32 37
  %v37 = add i32 %seed, 260
  store volatile i32 %v37, ptr %p37
  %p38 = getelementptr i32, ptr %out, i32 38
  %v38 = add i32 %seed, 267
  store volatile i32 %v38, ptr %p38
  %p39 = getelementptr i32, ptr %out, i32 39
  %v39 = add i32 %seed, 274
  store volatile i32 %v39, ptr %p39
  %p40 = getelementptr i32, ptr %out, i32 40
  %v40 = add i32 %seed, 281
  store volatile i32 %v40, ptr %p40
  %p41 = getelementptr i32, ptr %out, i32 41
  %v41 = add i32 %seed, 288
  store volatile i32 %v41, ptr %p41
  %p42 = getelementptr i32, ptr %out, i32 42
  %v42 = add i32 %seed, 295
  store volatile i32 %v42, ptr %p42
  %p43 = getelementptr i32, ptr %out, i32 43
  %v43 = add i32 %seed, 302
  store volatile i32 %v43, ptr %p43
  %p44 = getelementptr i32, ptr %out, i32 44
  %v44 = add i32 %seed, 309
  store volatile i32 %v44, ptr %p44
  %p45 = getelementptr i32, ptr %out, i32 45
  %v45 = add i32 %seed, 316
  store volatile i32 %v45, ptr %p45
  %p46 = getelementptr i32, ptr %out, i32 46
  %v46 = add i32 %seed, 323
  store volatile i32 %v46, ptr %p46
  %p47 = getelementptr i32, ptr %out, i32 47
  %v47 = add i32 %seed, 330
  store volatile i32 %v47, ptr %p47
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
  %acc = getelementptr i32, ptr %out, i32 %i
  store volatile i32 %i, ptr %acc
  %i.next = add i32 %i, 1
  %done = icmp eq i32 %i.next, %n
  br i1 %done, label %exit, label %loop
exit:
  ret void
}

; CHECK-LABEL: big_fn_with_loop:
; The loop exit test is a single compare-and-branch, not cmp + Bcc.
; CHECK: br{{eq|ne}} %r{{[0-9]+}},
; CHECK-NOT: cmp {{.*}}
