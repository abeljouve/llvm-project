; RUN: llc -mtriple=arceb-unknown-elf -mcpu=bcm55030 < %s | FileCheck %s --check-prefix=SCHED
; RUN: llc -mtriple=arceb-unknown-elf -mcpu=arc700eb < %s | FileCheck %s --check-prefix=NOSCHED

; Pins two things about BCM55030Model (ARCScheduleBCM55030.td):
;
;   1. The model is ACTIVE for -mcpu=bcm55030: ARCSubtarget::enableMachineScheduler()
;      gates on the CPU carrying an instruction-level model, so the machine
;      scheduler runs here and nowhere else on this target.
;   2. It separates a load from its use. A dependent load-use costs 10 clocks
;      on this core and there is no D-cache, so every load pays it in full.
;      Loads are non-blocking -- the interlock is on the consumer -- so the
;      shadow can be filled with independent work nearly for free. That is the
;      whole point of having a model at all.
;
; The arc700eb run is the control: it has no scheduling model (NoItineraries),
; must keep the source order, and must stay bit-for-bit unaffected by this
; change. The model characterizes one specific part; it is deliberately not
; extended to the generic profiles.

; Three independent load -> shift -> store chains, noalias so nothing forces an
; ordering. Shifts (not adds) keep reassociation from folding the chains
; together before the scheduler ever sees them.

define void @load_use_is_separated(ptr noalias %p, ptr noalias %q, ptr noalias %r,
                                   ptr noalias %o1, ptr noalias %o2, ptr noalias %o3) nounwind {
entry:
  %a = load i32, ptr %p, align 4
  %sa = shl i32 %a, 3
  store i32 %sa, ptr %o1, align 4
  %b = load i32, ptr %q, align 4
  %sb = shl i32 %b, 5
  store i32 %sb, ptr %o2, align 4
  %c = load i32, ptr %r, align 4
  %sc = shl i32 %c, 7
  store i32 %sc, ptr %o3, align 4
  ret void
}

; Scheduled: an independent load is hoisted into the first load's shadow, so the
; first load is followed by another load rather than by its own consumer. The
; check is deliberately loose about how MANY loads get hoisted (the model's
; 10-cycle latency pulls up all three) and about register numbers -- the
; load-bearing property is only that the use no longer sits on top of the load.
;
; SCHED-LABEL: load_use_is_separated:
; SCHED:       ld_s [[A:%r[0-9]+]], [
; SCHED-NEXT:  ld_s {{%r[0-9]+}}, [

; Unscheduled control: source order, so the shift consumes the load result
; immediately and eats the full 10-cycle interlock.
;
; NOSCHED-LABEL: load_use_is_separated:
; NOSCHED:       ld_s [[A:%r[0-9]+]], [
; NOSCHED-NEXT:  asl [[A]], [[A]], 3
