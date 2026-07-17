//===-- ARCScheduleBCM55030.td - BCM55030 ARC700 Scheduling -*- tablegen -*-==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Scheduling model for the ARC700 core integrated in the Broadcom BCM55030.
//
// EVERY number here was measured on that silicon (cycle-characterization run,
// 2026-07-16) and each is annotated with its probe name, its raw tick count,
// and the arithmetic that turns one into the other. Do not "clean up" a value
// without re-deriving it: the whole worth of this model is that it is
// calibrated, and a right value carried by wrong reasoning is a trap for
// whoever edits it next.
//
//===----------------------------------------------------------------------===//
//
// THE MEASUREMENT METHOD (needed to read any number below)
//
// A probe brackets a straight-line, fully-unrolled body between two reads of
// the free-running cycle counter (aux 0x21), with interrupts masked and the
// repetition loop OUTSIDE the bracket. The reported tick count is the counter
// delta. The harness itself costs EXACTLY +1 tick:
//
//     delta = 1 + (cycles spanned by the body)
//
// That +1 is not an estimate. It is a zero-residual fit over 13 independent
// points: a burst of N one-cycle ops measures N+1 for N = 1,2,4,8,16,32,64,
// plus nop_baseline = 65, A5 = 65, A6_ctrlB = 33, B_add1_baseline = 65,
// B5 = 65, B6 = 65. The fit also bounds the counter's rate to [1.0000, 1.0155)
// -- i.e. it counts core clocks 1:1, which falsifies any prescaled-counter
// reading of these numbers.
//
// THE EDGE COUNT -- the trap that produced the long-published wrong answer.
// A chain of N dependent nodes contains N-1 inter-node edges inside the
// window, not N. The first node's input arrives before the window opens and
// the last node's result is never consumed inside it. Dividing a 64-node chain
// measurement by 64 is simply the wrong denominator; that is exactly how
// "9.875 clocks load-use" (632/64) was published. Always: subtract the +1,
// count the EDGES, and check the fit is integer.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Machine model
//===----------------------------------------------------------------------===//

def BCM55030Model : SchedMachineModel {
  // IssueWidth = 1 -- OBSERVED, A5_alu_thru_independent = 65 ticks for 64
  // INDEPENDENT `add r8..r15, r0, r1`:
  //     65 = 1 + 64 x 1     => 1.000 clk/op
  // A 2-wide machine would have produced ~33. This could not be settled by any
  // earlier run: those contained only DEPENDENT ALU chains, which retire at
  // 1/clk on 1-wide and 2-wide machines alike.
  let IssueWidth = 1;

  // In-order: no reorder buffer.
  let MicroOpBufferSize = 0;

  // LoadLatency = 10 -- EXACT, ld_dep_warm_chain = 632 ticks for a 64-node
  // dependent self-pointer chase (`ld r9,[r9,0]` x64):
  //     632 = 1 (harness) + 63 x 10 (edges) + 1 (last load's issue slot)
  //     residual 0
  // One unknown, no freedom: L=9 predicts 569 and L=11 predicts 695. This is
  // the corrected reading of the number that was once divided by 64 and
  // published as 9.875.
  //
  // There is NO D-cache in the shipping configuration (DC_CTRL = 0xC3, bit 0
  // set = disabled), so this is the cost of EVERY load, not a hit time. Four
  // independent probes agree to the tick: a 32 KB permuted chase (8x the
  // D-cache), the same with an explicit invalidate per repetition, an
  // ascending-line walk, and the warm chain all measure 632. There is nothing
  // to miss. Do not model a D-cache and do not model a data prefetcher.
  let LoadLatency = 10;

  // MispredictPenalty = 4 -- OBSERVED by two independent routes.
  // Each node is exactly 8 bytes (`<branch>` to +8, then `add r8,r8,1`), so
  // taken and not-taken run the same bytes and differ only by an argument.
  //   B1_bbit1_TAKEN     = 321 = 1 + 64 x 5  => taken node = 5 clk
  //   B1_bbit1_NOT_TAKEN = 129 = 1 + 64 x 2  => [branch;add] node = 2 clk,
  //                                             and the `add` is 1 clk
  //                                             (B_add1_baseline = 65), so the
  //                                             not-taken branch is 1 clk.
  //   penalty = 5 - 1 = 4.
  // B3 inverts the polarity (`bbit0`) and reproduces 321/129 exactly, so the
  // penalty does not depend on which way the branch is written.
  let MispredictPenalty = 4;

  // The post-RA scheduler is a SEPARATE pass whose effect on this target has
  // never been measured. Enabling it here would fold an unmeasured change into
  // the pre-RA scheduler's first outing and make the two impossible to
  // attribute apart. Left off deliberately; turn it on only with its own
  // measurement. (Cortex-M4's model sets this; that is not a reason to.)
  let PostRAScheduler = 0;

  // Partial model: only the instruction families measured below carry a
  // SchedRW. Without this, LLVM treats every unmodelled opcode as an error.
  // The Cortex-M4 model does the same for the same reason.
  let CompleteModel = 0;
}

//===----------------------------------------------------------------------===//
// Processor resources
//===----------------------------------------------------------------------===//
//
// TWO pipes, not one shared issue unit -- INFERRED from A6, which interleaves
// a load stream with an independent ALU stream and compares against each
// stream alone:
//     A6_ctrlA_ld_spread32     = 86  (32 spread loads)
//     A6_ctrlB_alu32_r16_r23   = 33  (32 independent adds)
//     A6_mix32                 = 95  (32 x [load ; independent add])
// A shared issue slot predicts the SUM, ~118. Separate pipes predict
// ~max(A,B) = 86. The mix lands at 95: 9 above max, 23 below the sum --
// decisively nearer max. The +9 residual is unexplained; it is small and does
// not move the verdict.
//
// Note this does NOT contradict IssueWidth = 1: the two pipes overlap, but
// only one instruction still ISSUES per clock. A3/A4 below measure exactly
// that ceiling.

let SchedModel = BCM55030Model in {

def BCM55030ALU : ProcResource<1> { let BufferSize = 0; } // in-order, unbuffered
def BCM55030LSU : ProcResource<1> { let BufferSize = 0; }

//===----------------------------------------------------------------------===//
// Scheduling writes
//===----------------------------------------------------------------------===//
//
// These are SchedWriteRes rather than WriteRes<SchedWrite, ...> because no ARC
// instruction carries a SchedRW today and this target defines no target-wide
// SchedWrite names to bind to. SchedWriteRes is a SchedWrite and its resources
// in one def, which is what InstRW consumes -- the same shape Cortex-M4 uses
// for its InstRW-attached instructions.

// ALU: Latency 1 -- dependent `add` chains measure B_add1_baseline = 65 for
// 64 nodes => 1.000 clk. ReleaseAtCycles 1 -- A5 = 65 for 64 INDEPENDENT adds,
// so an add occupies the issue slot for exactly one clock.
def BCM55030WrALU : SchedWriteRes<[BCM55030ALU]> {
  let Latency = 1;
  let ReleaseAtCycles = [1];
  // RetireOOO -- OBSERVED, and the same A3/A4 shadow sweep that gave the load
  // its 2-cycle occupancy is what proves it: 8 independent adds placed under an
  // in-flight 10-cycle chase load cost +9 ticks TOTAL across 32 nodes
  // (A3_shadow_MISS_K0 = 315 -> A3_shadow_MISS_K8 = 324), i.e. they complete
  // while the load is still outstanding. This core therefore does NOT serialize
  // writeback: a short op behind a long one retires ahead of it. Had writeback
  // been ordered, those 8 adds would have had to wait out the load and K=8 would
  // have cost ~32 x 18 = 576, which is what K=16 actually costs.
  //
  // This bit exists ONLY for llvm-mca's in-order pipeline, which otherwise
  // assumes in-order writeback and stalls each add until the load ahead of it
  // lands -- turning the free shadow into an additive cost and making mca
  // disagree with silicon by 7 cycles/node at K=8. It is read exclusively by
  // llvm/lib/MCA (InstrBuilder, InOrderIssueStage); no CodeGen pass reads it, so
  // it cannot move a single instruction of generated code. It is the difference
  // between mca being a cycle oracle for this core and mca being wrong about the
  // one property -- non-blocking loads -- this whole model exists to exploit.
  let RetireOOO = 1;
}

// Shift: same numbers as ALU, but kept a separate write because the evidence
// behind it is WEAKER and that difference must not be flattened away.
//
// A dependent `asl` chain measured 65 ticks for 64 nodes => 1.000 clk, i.e.
// one shift per clock. That number comes from the earlier ISA-characterization
// run and was NOT re-measured in the 2026-07-16 run, which contains no shift
// probe at all -- every ALU probe in it uses `add`. It is a min-of-33 sample on
// a warm path, where no repetition can come out faster than the true quantity,
// so the statistic is sound; it simply has one run behind it instead of two.
//
// Do not be tempted to "correct" this by reading BARREL_BUILD (BCR 0x7F), which
// reads 0 on this part. That register lies: multi-bit shifts demonstrably work
// and retire at 1/clk. It is the third capability register on this core caught
// reporting a falsehood (cf. MINMAX_BUILD, AUX_IRQ_LEV). Trust execution, never
// a capability register.
def BCM55030WrShift : SchedWriteRes<[BCM55030ALU]> {
  let Latency = 1;
  let ReleaseAtCycles = [1];
  // See BCM55030WrALU. Carried over here because out-of-order writeback is a
  // property of the CORE's writeback path, not of the `add` opcode -- A3/A4
  // establish that this pipeline has no in-order-writeback interlock at all,
  // and a shift occupies the same ALU pipe with the same 1-cycle latency. The
  // shadow sweep did not itself contain a shift (mca-only bit, no codegen
  // effect, so the cost of being wrong here is a wrong mca number and nothing
  // else).
  let RetireOOO = 1;
}

// Branch: Latency 1, one ALU-pipe slot. B1_bbit1_NOT_TAKEN = 129 = 1 + 64 x 2
// for a [branch; add] node; the add is 1 clk, so the branch itself is 1 clk.
// The extra cost of a TAKEN branch is not this write -- it is
// MispredictPenalty above (taken 5 - not-taken-branch 1 = 4).
//
// Two facts this write cannot express, recorded so they are not lost:
//  * An unconditional taken branch costs 2 clk, not 5: B4_b_uncond_TAKEN
//    = 129 = 1 + 64 x 2. It resolves early, having no condition to evaluate.
//  * Filling a delay slot is FREE. B1 and B2 differ in exactly one bit (the
//    delay-slot field) and both cost 321, while B2 asserts its slot
//    instruction really executed -- 64 extra instructions retired for zero
//    clocks. Always fill it.
def BCM55030WrBr : SchedWriteRes<[BCM55030ALU]> {
  let Latency = 1;
  let ReleaseAtCycles = [1];
}

// Load: Latency 10 (see SchedMachineModel above), occupancy 2 issue slots.
//
// ReleaseAtCycles = 2 -- INFERRED from the A3/A4 shadow sweep, which puts K
// independent adds (in r16..r23, never the chain register) under each chase
// load and fits  delta = 1 + 31 x max(L, S+K) + (S+K)  with L = 10:
//     A3_shadow_MISS_K0  = 315   model(S=2) 313   resid +2
//     A3_shadow_MISS_K8  = 324   model(S=2) 321   resid +3
//     A4_shadow_MISS_K16 = 577   model(S=2) 577   resid  0   <- exact
// S = 1 misses K=16 by ~+30; S = 2 hits it exactly. Read directly off the
// data: 8 adds hide behind a load for +9 ticks total (315 -> 324, free), the
// NEXT 8 cost ~8 clk/node (324 -> 577 = +253 ~ 32 x 8). A shadow that absorbs
// exactly 8 ops behind a 10-clock load means the load holds the pipe for
// 10 - 8 = 2 clocks.
//
// Do NOT substitute the "load issue interval" from the throughput probes
// (CAL-3_ld_thru_SPREAD = 166/64 = 2.58, ld_thru_SAME_addr = 170/64 = 2.64,
// A6_ctrlA = 85/32 = 2.66). None is an integer, they disagree with each other,
// and no integer S satisfies delta = 1 + N x S for any of them. That residual
// is unresolved. The shadow-derived S = 2 is the figure that fits an
// independent shape exactly, and it is the one to use.
//
// Where that unresolved residual shows up in practice, so the next reader is
// not surprised by it: llvm-mca reproduces the shadow sweep exactly at K = 0
// and K = 8 (321 cycles/32 nodes both times -- the adds are free, as on
// silicon), but at K = 16 it reports 17 cycles/node where the part measures 18
// (A4 = 577 = 1 + 31 x 18 + 18). The gap is this S: mca spends the load's ONE
// dispatch slot (IssueWidth = 1) and treats its 2-cycle occupancy as
// load/store-pipe RESOURCE time, which overlaps freely with ALU dispatch; the
// A3/A4 fit instead adds S and K together, i.e. charges the load two slots
// against subsequent ALU work. Both readings survive the data we have -- that
// is precisely the question the non-integer throughput probes leave open. So
// treat mca as exact for load LATENCY and for shadow occupancy up to ~8 ops,
// and as ~1 cycle/node optimistic once a node's independent work exceeds the
// shadow. Settling it needs a probe that separates issue occupancy from
// resource occupancy, not a different constant here.
//
// LOADS ARE NON-BLOCKING and the interlock is on the CONSUMER, not at issue --
// that is what makes this Latency schedulable rather than decorative, and it is
// the whole premise of this model. Had loads blocked, A3 at K=8 would have cost
// ~32 x (10+8) = 576 instead of 324. With no D-cache every load pays the full
// 10 clocks, so hiding them is the highest-value thing this model enables.
def BCM55030WrLd : SchedWriteRes<[BCM55030LSU]> {
  let Latency = 10;
  let ReleaseAtCycles = [2];
}

// Store: no register result, so Latency is nominal (1, as Cortex-M4 does).
//
// ReleaseAtCycles = 2 -- OBSERVED from the A15 burst sweep of exactly K stores
// against a K-matched nop baseline (span = ticks - 1, removing the harness +1):
//     K   nop  distinct  span   2K-5
//     1    2      2        1     --
//     2    3      3        2     --
//     4    5      5        4     --
//     8    9     12       11     11
//    16   17     28       27     27
//    32   33     60       59     59
//    64   65    124      123    123
// span = 2K - 5 EXACTLY at K = 8,16,32,64, and span = K for K <= 4. Solving
// D x 1 + (K-D) x 2 = 2K - D gives write-buffer depth D = 5, with the two
// regimes crossing at exactly K = 5. The SLOPE -- 2 clk per drained store -- is
// what ReleaseAtCycles encodes. A14_st_SPREAD = 128 for 64 stores corroborates
// (~2.0 clk/store).
//
// Stores are POSTED: the first ~5 are absorbed at 1 clk each. `sync` is what
// makes them not -- it forces the drain at ~5 clk/store on top (A16).
def BCM55030WrSt : SchedWriteRes<[BCM55030LSU]> {
  let Latency = 1;
  let ReleaseAtCycles = [2];
}

// Uncached (`.di`) load and store.
//
// These exist as SEPARATE writes on purpose, but they deliberately carry the
// SAME numbers as their cached counterparts, because the run does not support
// a different number. Read this before "fixing" them:
//
// STORE -- positively confirmed identical, not merely unmeasured:
//     A14_st_SPREAD = 128  and  A14_stdi_SPREAD = 128   (64 stores each)
// Same throughput to the tick. (A14_st_SAME = 209 vs A14_stdi_SAME = 128 is a
// same-ADDRESS serialization effect on the cached path, not a `.di` cost, and
// is not a scheduling quantity.)
//
// LOAD -- a "+40 for .di" reading is available in the raw data and is REJECTED:
//     CAL-1_ZL1_warm  ld        714    --
//     A7_zl1_ldb      ldb       714     0
//     A8_zl1_ldw16    ldw       754   +40    <- no .di, yet +40
//     A9_zl1_ld_di    ld.di     754   +40
//     A10_zl1_ldb_di  ldb.di    754   +40
//     A11_zl1_ldw16_di ldw.di   720    +6    <- IS .di, yet only +6
// These do not form a consistent ordering. A cached `ldw` matches `ld.di`
// exactly, while `ldw.di` sits 34 BELOW `ld.di`. No per-width cost and no `.di`
// cost can produce that pattern -- the `.di` effect would have to change sign
// with the access width.
//
// The confound is uncontrolled I-cache placement. Each probe is a separate
// trampoline at a separate link address (0x1159c, 0x117e4, 0x11a2c, 0x11c74,
// 0x11ebc, 0x12104), the I-cache is 4 KB 1-way DIRECT-MAPPED, and nothing
// aligned the bodies -- one of them even straddles a 4 KB boundary. The value
// tracks the link address, not the opcode. The whole spread is <= 40 ticks over
// 64 loads = <= 0.63 clk/load, which is not separable from placement.
//
// So: all six widths are consistent with the same ~10-clock latency inside a
// +-0.6 clk/load placement band. ONE load latency for all widths and both cache
// modes.
//
// Evaluated to a close (2026-07-16): a per-width / .di stage-2 refinement is not
// merely unsupported by this run, it is UNACTIONABLE. The whole spread is
// <= 0.63 clk/load, and SchedMachineModel latencies are INTEGERS -- a sub-clock
// per-width delta rounds to the same Latency = 10 and cannot produce a different
// WriteRes. Even a future placement-controlled experiment could at best confirm
// the physics-predicted null: the D-cache is disabled (DC_CTRL = 0xC3), so a
// cached load and an uncached (.di) load both hit uncached SRAM with no
// cache-participation difference to create a latency delta, and width extraction
// is folded into the load-format stage. It could not change an integer latency.
// So these two writes are kept distinct only as harmless identical placeholders
// -- do NOT split their numbers.
def BCM55030WrLdDI : SchedWriteRes<[BCM55030LSU]> {
  let Latency = 10;
  let ReleaseAtCycles = [2];
}
def BCM55030WrStDI : SchedWriteRes<[BCM55030LSU]> {
  let Latency = 1;
  let ReleaseAtCycles = [2];
}

// Address write-back of an auto-increment (`.aw`/`.ab`) load or store: the
// second def, i.e. the incremented base register.
//
// NO probe measured an auto-increment form -- auto-increment across the load
// and store widths is explicitly named as still outside the characterized
// surface. So this write is deliberately as close to nothing as it can be
// while still giving that second def a defined latency:
//
//  * No ProcResource. The increment happens in the address generator, which
//    lives in the load/store pipe already accounted for by the accompanying
//    WrLd/WrSt; charging the ALU pipe would invent contention with ALU work
//    that A6 shows runs in a separate pipe. (AArch64's in-order A53 model
//    likewise gives its writeback address def an empty resource list.)
//  * NumMicroOps = 0. An auto-increment load is ONE instruction and takes ONE
//    issue slot. Writes sum their micro-ops into the class, so leaving this at
//    the default 1 would tell a 1-wide in-order machine that `ld.ab` costs two
//    issue slots -- an unmeasured penalty against exactly the addressing mode
//    the address-mode pass exists to form.
//  * Latency 1, by analogy with the measured `add` (B_add1_baseline = 65 over
//    64 nodes => 1.000 clk). INFERRED BY ANALOGY, not measured.
def BCM55030WrAGU : SchedWriteRes<[]> {
  let Latency = 1;
  let NumMicroOps = 0;
}

//===----------------------------------------------------------------------===//
// Scheduling reads
//===----------------------------------------------------------------------===//

// ALU result -> load/store base address (the AGU operand): NO penalty and no
// advance.
//
// CAL-1 closes a recurrence through a load's ADDRESS: 64 x [ld r8,[r5,0] ;
// add r5,r5,r8] over a zeroed buffer, so r5 never actually moves but every
// load's base depends on the previous add. CAL-1_ZL1_warm = 714 against the
// pure chase's 632:
//     714 = 1 (harness) + 9 (entry stall) + 63 x 11 + 10 (tail) + 1   resid 0
// with the 11 = L(10) + F(1), i.e. F = 1: an ALU result reaches a load's
// address operand in one clock, with no extra AGU penalty. The alternative --
// a 1-clock AGU penalty, edge 12 -- predicts ~769 and is 55 ticks away.
//
// The two correction terms are real, not fudge:
//  * +9 entry stall: the probe pre-warms with `ld r8,[r5,0]` immediately before
//    opening the window, and the body's FIRST instruction is `ld r8,[r5,0]` --
//    the same destination register, so it stalls (WAW) until the pre-warm
//    lands. The pure chase has no pre-warm and no such stall, which is why its
//    fit needs no such term. An independent sighting agrees: sync_alone minus
//    nop_baseline = 73 - 65 = 8, a window-entry cost of ~8-10 reached by an
//    unrelated mechanism.
//  * +10 tail: this probe's last `add` DOES consume its last load inside the
//    window; the chase's last load is never consumed. Structural.
//
// Caveat, stated because the fit is a three-parameter one against a single
// number and is therefore not separately identifiable: treat F = 1 as
// well-supported, not as proven to the standard of LoadLatency = 10.
//
// ReadAdvance<0> is also the default, so this def changes no behaviour today.
// It is here to record that the value was MEASURED rather than defaulted, and
// to give a future AGU penalty exactly one place to be expressed.
def BCM55030RdAGU : SchedReadAdvance<0>;

//===----------------------------------------------------------------------===//
// Instruction -> write mapping
//===----------------------------------------------------------------------===//
//
// Attached via InstRW keyed by opcode name. No ARC instruction carries a
// SchedRW field, and the ARCompact instruction tables are machine-generated
// from the binutils opcode table ("DO NOT EDIT"), so InstRW is the mapping that
// costs those files nothing.
//
// Only the families measured above are mapped; CompleteModel = 0 covers the
// rest. An instregex that matches nothing is a FATAL TableGen error, and two
// InstRW blocks matching the same opcode in one model is also an error -- these
// patterns were checked against the generated opcode enum and are exhaustive
// and disjoint.

// --- ALU -------------------------------------------------------------------
// GEN4 3-operand integer ops, all encoding variants (.f flag-setting,
// conditional, u6/s12/limm immediate forms).
def : InstRW<[BCM55030WrALU],
             (instregex "^(ADD|ADC|SUB|SBC|SUB1|SUB2|SUB3|RSUB|AND|OR|XOR|MAX|MIN|SETEQ)(_cc)?(_f)?_(rrr|rru6|rrlimm|rrs12)$")>;

// Moves and compares are the same single-clock ALU op. CMP has no register
// result; its write is the flag update.
def : InstRW<[BCM55030WrALU], (instregex "^MOV(_cc)?(_f)?_(rr|ru6|rlimm|rs12)$")>;
def : InstRW<[BCM55030WrALU], (instregex "^CMP_(rr|ru6|rlimm|rs12)$")>;

// --- Shift -----------------------------------------------------------------
def : InstRW<[BCM55030WrShift],
             (instregex "^(ASL|LSR|ASR|ROR)(_cc)?(_f)?_(rrr|rru6|rrlimm|rrs12)$")>;

// --- Load ------------------------------------------------------------------
// One def (the loaded value) + the base register read that CAL-1 calibrated.
// Covers word/byte/half, sign-extending (_X), and the s9 / limm / reg+limm
// address forms, plus the scaled reg+reg form.
def : InstRW<[BCM55030WrLd, BCM55030RdAGU],
             (instregex "^LD(B|H)?(_X)?_(rs9|limm|rlimm)$", "^LD_AS_rr$")>;

// Auto-increment loads define the loaded value AND the updated base.
def : InstRW<[BCM55030WrLd, BCM55030WrAGU, BCM55030RdAGU],
             (instregex "^LD(B|H)?(_X)?(_AW|_AB)_rs9$")>;

// --- Store -----------------------------------------------------------------
def : InstRW<[BCM55030WrSt, BCM55030RdAGU],
             (instregex "^ST(B|H)?_(rs9|limm)$")>;

// Auto-increment stores define only the updated base register.
def : InstRW<[BCM55030WrAGU, BCM55030WrSt, BCM55030RdAGU],
             (instregex "^ST(B|H)?(_AW|_AB)_rs9$")>;

// --- Uncached (.di) load / store -------------------------------------------
def : InstRW<[BCM55030WrLdDI, BCM55030RdAGU],
             (instregex "^LD(B|H)?(_X)?_DI_(rs9|limm|rlimm)$")>;
def : InstRW<[BCM55030WrLdDI, BCM55030WrAGU, BCM55030RdAGU],
             (instregex "^LD(B|H)?(_X)?_DI(_AW|_AB)_rs9$")>;
def : InstRW<[BCM55030WrStDI, BCM55030RdAGU],
             (instregex "^ST(B|H)?_DI_(rs9|limm)$")>;
def : InstRW<[BCM55030WrAGU, BCM55030WrStDI, BCM55030RdAGU],
             (instregex "^ST(B|H)?_DI(_AW|_AB)_rs9$")>;

// --- Branch / call / jump --------------------------------------------------
// None of these define a register operand, so a single write covers each.
// BRcc_*_p are pseudos that survive until after the scheduler (they are lowered
// during branch finalization, in the pre-emit stage), so they are modelled too.
def : InstRW<[BCM55030WrBr], (instregex "^(BR|Bcc|BL|J|JL|J_LImm|JL_LImm)$")>;
def : InstRW<[BCM55030WrBr], (instregex "^BRcc_(rr|ru6)(_p)?$")>;

} // let SchedModel = BCM55030Model
