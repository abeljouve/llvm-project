; RUN: llc -mtriple=arc -mcpu=generic < %s | FileCheck %s
;
; The bare CHECK prefix describes -mcpu=generic. A bare -mtriple=arc with no
; -mcpu selects a featureless pseudo-subtarget matching no shipping
; configuration (no MPY/SEXT/BitScan, so not `generic`; no ARCompact, so
; ARCSizeReduction never runs, so not arc700 either). Its output for this test
; is byte-identical to generic, so naming the real CPU loses no coverage.
;
; The RUN lines below extend the SAME prefix to the three shipping ARC700
; profiles. Unlike alu.ll / brcc.ll / call.ll / ldst.ll this test is
; deliberately NOT split, and that is not an oversight: every assertion here is
; about address-mode folding (post-increment formation, and the rebasing of
; sibling loads onto a post-increment result), which is feature- and
; endianness-independent. The ARC700 output does differ -- some of these
; stores fuse into 16-bit compact forms -- but no assertion in this file
; observes that difference, so a second prefix would be a copy of the first and
; would assert nothing the shared one does not. Splitting only earns its keep
; where the subtargets genuinely disagree about what this test measures.
;
; The negative displacements in past_uses are the load-bearing case and have no
; compact encoding, so they stay 32-bit on every profile.
; RUN: llc -mtriple=arc   -mcpu=arc700   < %s | FileCheck %s
; RUN: llc -mtriple=arceb -mcpu=arc700eb < %s | FileCheck %s
; RUN: llc -mtriple=arceb -mcpu=bcm55030 < %s | FileCheck %s

; CHECK-LABEL: copy
; CHECK-NOT: add
define void @copy(ptr inreg nocapture %p, ptr inreg nocapture readonly %q) {
entry:
  br label %while.cond

while.cond:                                       ; preds = %while.cond, %entry
  %p.addr.0 = phi ptr [ %p, %entry ], [ %incdec.ptr1, %while.cond ]
  %q.addr.0 = phi ptr [ %q, %entry ], [ %incdec.ptr, %while.cond ]
  %incdec.ptr = getelementptr inbounds i8, ptr %q.addr.0, i32 1
  %0 = load i8, ptr %q.addr.0, align 1
  %incdec.ptr1 = getelementptr inbounds i8, ptr %p.addr.0, i32 1
  store i8 %0, ptr %p.addr.0, align 1
  %tobool = icmp eq i8 %0, 0
  br i1 %tobool, label %while.end, label %while.cond

while.end:                                        ; preds = %while.cond
  ret void
}


%struct._llist = type { ptr, ptr, i32 }

; CHECK-LABEL: neg1
; CHECK-NOT:   std.ab
define void @neg1(ptr inreg nocapture %a, ptr inreg nocapture readonly %b, i32 inreg %n) {
entry:
  %cmp6 = icmp sgt i32 %n, 0
  br i1 %cmp6, label %for.body, label %for.cond.cleanup

for.cond.cleanup:
  ret void

for.body:
  %i.07 = phi i32 [ %inc, %for.body ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds i8, ptr %b, i32 %i.07
  %0 = load i8, ptr %arrayidx, align 1
  %mul = mul nuw nsw i32 %i.07, 257
  %arrayidx1 = getelementptr inbounds i8, ptr %a, i32 %mul
  store i8 %0, ptr %arrayidx1, align 1
  %inc = add nuw nsw i32 %i.07, 1
  %exitcond = icmp eq i32 %inc, %n
  br i1 %exitcond, label %for.cond.cleanup, label %for.body
}

; CHECK-LABEL: neg2
; CHECK-NOT:   st.ab
define void @neg2(ptr inreg %a, i32 inreg %n) {
entry:
  %cmp13 = icmp sgt i32 %n, 0
  br i1 %cmp13, label %for.body, label %for.cond.cleanup

for.cond.cleanup:
  ret void

for.body:
  %i.014 = phi i32 [ %inc, %for.body ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds %struct._llist, ptr %a, i32 %i.014
  %next = getelementptr inbounds %struct._llist, ptr %arrayidx, i32 0, i32 0
  store ptr %arrayidx, ptr %next, align 4
  %prev = getelementptr inbounds %struct._llist, ptr %a, i32 %i.014, i32 1
  store ptr %arrayidx, ptr %prev, align 4
  %inc = add nuw nsw i32 %i.014, 1
  %exitcond = icmp eq i32 %inc, %n
  br i1 %exitcond, label %for.cond.cleanup, label %for.body
}

; When the offset==0 load is folded into a post-increment, the remaining
; (sibling) loads off the same base must be rebased onto the post-increment
; result with their displacement reduced by the increment -- each independently.
; Regression for a fixPastUses bug that accumulated a running offset and applied
; it with the wrong sign/base: the src[1]/src[2] byte loads (past a +3 advance)
; became [b,4]/[b,6] instead of [b,-2]/[b,-1], reading the wrong bytes.
; CHECK-LABEL: past_uses
; CHECK:       ldb.ab %r{{[0-9]+}}, {{\[}}[[B:%r[0-9]+]],3]
; CHECK:       ldb %r{{[0-9]+}}, {{\[}}[[B]],-2]
; CHECK:       ldb %r{{[0-9]+}}, {{\[}}[[B]],-1]
; CHECK-NOT:   ldb %r{{[0-9]+}}, {{\[}}[[B]],4]
; CHECK-NOT:   ldb %r{{[0-9]+}}, {{\[}}[[B]],6]
define void @past_uses(ptr inreg nocapture %dst, ptr inreg nocapture readonly %src, i32 inreg %n) {
entry:
  %c = icmp sgt i32 %n, 0
  br i1 %c, label %body, label %done
done:
  ret void
body:
  %i = phi i32 [ %inc, %body ], [ 0, %entry ]
  %s = phi ptr [ %s.next, %body ], [ %src, %entry ]
  %d = phi ptr [ %d.next, %body ], [ %dst, %entry ]
  %p0 = load i8, ptr %s, align 1
  %g1 = getelementptr inbounds i8, ptr %s, i32 1
  %p1 = load i8, ptr %g1, align 1
  %g2 = getelementptr inbounds i8, ptr %s, i32 2
  %p2 = load i8, ptr %g2, align 1
  %z0 = zext i8 %p0 to i32
  %z1 = zext i8 %p1 to i32
  %z2 = zext i8 %p2 to i32
  %s1 = shl i32 %z1, 8
  %s2 = shl i32 %z2, 16
  %o1 = or i32 %z0, %s1
  %o2 = or i32 %o1, %s2
  store i32 %o2, ptr %d, align 4
  %s.next = getelementptr inbounds i8, ptr %s, i32 3
  %d.next = getelementptr inbounds i8, ptr %d, i32 4
  %inc = add nuw nsw i32 %i, 1
  %e = icmp eq i32 %inc, %n
  br i1 %e, label %done, label %body
}
