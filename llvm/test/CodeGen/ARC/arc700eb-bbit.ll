; RUN: llc -march=arceb -mcpu=arc700eb -mattr=+arcompact < %s | FileCheck %s

; Bit-test-and-branch. A single-bit `and` feeding an in-range compare-against-
; zero branch is fused (in ARCBranchFinalize) into a 1-instruction bbit0/bbit1,
; replacing the `and`+`brne` (or `and`+`cmp`+`bcc`) pair. Branch layout picks
; the polarity/target, so the checks assert the correct bit position and that
; no `and`/`cmp` feeds the branch. The sign bit (x <s 0) is canonicalized away
; from the `and` form and stays a `brlt` compare-and-branch (also 1 insn).

; --- (x & (1<<3)) != 0 : low bit via u6 AND -> bbit, no `and` ---
define i32 @bit3(i32 %x) {
; CHECK-LABEL: bit3:
; CHECK: bbit{{[01]}} %r0, 3, @
; CHECK-NOT: and %r
  %a = and i32 %x, 8
  %c = icmp ne i32 %a, 0
  br i1 %c, label %t, label %f
t:
  ret i32 1
f:
  ret i32 0
}

; --- (x & (1<<20)) == 0 : high bit that needs a limm mask -> bbit, no limm ---
define i32 @bit20(i32 %x) {
; CHECK-LABEL: bit20:
; CHECK: bbit{{[01]}} %r0, 20, @
; CHECK-NOT: and %r
; CHECK-NOT: limm
  %a = and i32 %x, 1048576
  %c = icmp eq i32 %a, 0
  br i1 %c, label %t, label %f
t:
  ret i32 1
f:
  ret i32 0
}

; --- busy-poll on a non-sign bit: while (*r & 2) -> `ld` + `bbit1` ---
; The loop is 2 instructions (one cache line), not ld+and+brne.
define void @poll_bit1(ptr %r) {
; CHECK-LABEL: poll_bit1:
; CHECK: ld_s %r{{[0-9]+}}, [%r0
; CHECK-NEXT: bbit1 %r{{[0-9]+}}, 1, @
; CHECK-NOT: and %r
entry:
  br label %loop
loop:
  %v = load volatile i32, ptr %r
  %a = and i32 %v, 2
  %c = icmp ne i32 %a, 0
  br i1 %c, label %loop, label %done
done:
  ret void
}

; --- sign-bit busy-poll: while (*r <s 0) -> `ld` + `brlt` (1-insn test) ---
; Bit 31 is canonicalized to a sign compare, so it takes the compare-and-branch
; path, not bbit. Still a 2-instruction loop (one cache line), not ld+cmp+bcc.
define void @poll_sign(ptr %r) {
; CHECK-LABEL: poll_sign:
; CHECK: ld_s %r{{[0-9]+}}, [%r0
; CHECK-NEXT: brlt %r{{[0-9]+}}, 0, @
; CHECK-NOT: cmp
entry:
  br label %loop
loop:
  %v = load volatile i32, ptr %r
  %c = icmp slt i32 %v, 0
  br i1 %c, label %loop, label %done
done:
  ret void
}

; --- B still live after the branch: must NOT fuse (the masked value is used) ---
define i32 @and_result_reused(i32 %x) {
; CHECK-LABEL: and_result_reused:
; CHECK: and %r{{[0-9]+}}, %r0, 8
; CHECK-NOT: bbit
  %a = and i32 %x, 8
  %c = icmp ne i32 %a, 0
  br i1 %c, label %t, label %f
t:
  ret i32 %a
f:
  ret i32 0
}
