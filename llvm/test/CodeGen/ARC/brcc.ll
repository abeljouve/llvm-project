; RUN: llc -mtriple=arc -mcpu=generic < %s | FileCheck %s
;
; The bare CHECK prefix describes -mcpu=generic. A bare -mtriple=arc with no
; -mcpu selects a featureless pseudo-subtarget that matches no shipping
; configuration (no MPY/SEXT/BitScan, so not `generic`; no ARCompact, so
; ARCSizeReduction never runs and it is not arc700 either), so it is not
; pinned here. For this test its output happens to be byte-identical to
; generic, so nothing is lost by naming the real CPU.
;
; The ARC700 prefix covers the shipping ARC700 profiles. The compare-and-branch
; selection under test is feature-independent and identical on all three, but
; the add in the taken block fuses into the 16-bit ARCompact ADD_S, so the two
; prefixes assert different mnemonics and neither can pass against the other's
; output.
; RUN: llc -mtriple=arc   -mcpu=arc700   < %s | FileCheck %s --check-prefix=ARC700
; RUN: llc -mtriple=arceb -mcpu=arc700eb < %s | FileCheck %s --check-prefix=ARC700
; RUN: llc -mtriple=arceb -mcpu=bcm55030 < %s | FileCheck %s --check-prefix=ARC700

; CHECK-LABEL: brcc1:
; CHECK:         brne %r0, %r1, @.LBB0_2
; CHECK:         add %r0, %r0, 4
; CHECK:         .LBB0_2:
;
; ARC700-LABEL: brcc1:
; ARC700:         brne %r0, %r1, @.LBB0_2
; ARC700-NOT:     add %r0, %r0, 4
; ARC700:         add_s %r0, 4
; ARC700:         .LBB0_2:
define i32 @brcc1(i32 %a, i32 %b) nounwind {
entry:
  %wb = icmp eq i32 %a, %b
  br i1 %wb, label %t1, label %t2
t1:
  %t1v = add i32 %a, 4
  br label %exit
t2:
  %t2v = add i32 %b, 8
  br label %exit
exit:
  %v = phi i32 [ %t1v, %t1 ], [ %t2v, %t2 ]
  ret i32 %v
}

; CHECK-LABEL: brcc2
; CHECK: breq %r0, %r1
;
; ARC700-LABEL: brcc2:
; ARC700:         breq %r0, %r1
; ARC700-NOT:     add %r0, %r0, 4
; ARC700:         add_s %r0, 4
define i32 @brcc2(i32 %a, i32 %b) nounwind {
entry:
  %wb = icmp ne i32 %a, %b
  br i1 %wb, label %t1, label %t2
t1:
  %t1v = add i32 %a, 4
  br label %exit
t2:
  %t2v = add i32 %b, 8
  br label %exit
exit:
  %v = phi i32 [ %t1v, %t1 ], [ %t2v, %t2 ]
  ret i32 %v
}


