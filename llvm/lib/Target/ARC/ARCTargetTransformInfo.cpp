//===- ARCTargetTransformInfo.cpp - ARC specific TTI ----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Out-of-line ARC TTI queries. Only the hardware-loop (LP) profitability hook
// lives here; the immediate cost model stays inline in the header. Kept in a
// .cpp because the LP hook pulls in ScalarEvolution / LoopInfo and a command
// line flag, which the header has no reason to include.
//
//===----------------------------------------------------------------------===//

// ARCSubtarget.h / ARCTargetMachine.h must precede the primary header: the
// latter's inline members (the ctor's TM->getSubtargetImpl() /
// ST->getTargetLowering(), and getIntImmCostInst's ST->hasMPY()) reference these
// types, whose completeness is required at end-of-class when this TU compiles the
// header standalone (ARCTargetMachine.cpp happened to include them first, which
// is why the header's forward declarations sufficed there).
#include "ARCSubtarget.h"
#include "ARCTargetMachine.h"
#include "ARCTargetTransformInfo.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/CodeGen/ISDOpcodes.h"
#include "llvm/CodeGen/TargetLowering.h"
#include "llvm/CodeGenTypes/MachineValueType.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InlineAsm.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define DEBUG_TYPE "arctti"

// OFF by default. Turning this on emits `lp` zero-overhead loops, which is only
// safe once the runtime saves/restores LP_COUNT (r60) + LP_START (AUX 0x02) +
// LP_END (AUX 0x03) across every interrupt, OR every interrupt handler is
// proven LP-free. Until then the compiler must NOT emit LP: a handler that
// itself runs an LP loop would silently corrupt the interrupted foreground
// loop's counter. See docs/notes/isa-characterization.md 4.4 and the note in
// ARCTargetMachine.cpp::addPreEmitPass.
static cl::opt<bool> EnableARCHardwareLoops(
    "arc-hardware-loops", cl::Hidden, cl::init(false),
    cl::desc("Enable ARC zero-overhead (LP) hardware-loop formation. OFF by "
             "default: requires interrupt entry code that preserves "
             "LP_COUNT / LP_START / LP_END."));

bool llvm::ARCEnableHardwareLoops() { return EnableARCHardwareLoops; }

bool ARCTTIImpl::maybeLoweredToCall(Instruction &I) const {
  // Any call clobbers architecturally-unknown state and, on this silicon,
  // LP_COUNT liveness across a call is uncharacterized. Reject the loop. This
  // also covers inline asm (a CallInst whose callee is an InlineAsm) and
  // memcpy/memset-style intrinsics, all of which may touch r60.
  if (isa<CallInst>(I) || isa<InvokeInst>(I) || isa<CallBrInst>(I))
    return true;

  unsigned Opc = I.getOpcode();
  int ISD = TLI->InstructionOpcodeToISD(Opc);
  if (ISD == 0)
    // Not a normal ISD-mapped operation (PHI, GEP, ExtractValue, ...): it does
    // not lower to a bl.
    return false;

  // arc700 is soft-float: every floating-point operation becomes a libcall.
  // Test both the result and the operands (an FP compare has an i1 result but
  // FP operands).
  if (I.getType()->isFPOrFPVectorTy())
    return true;
  for (const Value *Op : I.operands())
    if (Op->getType()->isFPOrFPVectorTy())
      return true;

  const DataLayout &DL = getDataLayout();
  EVT VT = TLI->getValueType(DL, I.getType(), /*AllowUnknown=*/true);
  if (VT != MVT::Other &&
      TLI->getOperationAction(ISD, VT) == TargetLowering::LibCall)
    return true;

  // Belt-and-suspenders for the integer helpers this subtarget always routes
  // through a libcall (no 32x32 multiply, no integer divide unit; 64-bit
  // integer mul/div/rem are helpers regardless of the FeatureMPY state).
  switch (ISD) {
  default:
    break;
  case ISD::MUL:
  case ISD::MULHU:
  case ISD::MULHS:
  case ISD::SDIV:
  case ISD::UDIV:
  case ISD::SREM:
  case ISD::UREM:
    return true;
  }
  return false;
}

bool ARCTTIImpl::isHardwareLoopProfitable(Loop *L, ScalarEvolution &SE,
                                          AssumptionCache &AC,
                                          TargetLibraryInfo *LibInfo,
                                          HardwareLoopInfo &HWLoopInfo) const {
  // Gated OFF by default (see EnableARCHardwareLoops above).
  if (!ARCEnableHardwareLoops()) {
    LLVM_DEBUG(dbgs() << "ARCHWLoops: disabled by flag\n");
    return false;
  }

  // The LP engine is wired for ARCompact / ARC700 only.
  if (!ST->isARCompact()) {
    LLVM_DEBUG(dbgs() << "ARCHWLoops: not an ARCompact subtarget\n");
    return false;
  }

  // Require an SCEV-computable trip count. This is the whole point of building
  // on the generic pass: the trip count is proven, never guessed by ad-hoc MI
  // pattern matching (the failure mode of the deleted ARCHardwareLoops pass).
  if (!SE.hasLoopInvariantBackedgeTakenCount(L)) {
    LLVM_DEBUG(dbgs() << "ARCHWLoops: no loop-invariant backedge-taken count\n");
    return false;
  }
  const SCEV *BackedgeTakenCount = SE.getBackedgeTakenCount(L);
  if (isa<SCEVCouldNotCompute>(BackedgeTakenCount)) {
    LLVM_DEBUG(dbgs() << "ARCHWLoops: uncomputable backedge-taken count\n");
    return false;
  }

  const SCEV *TripCountSCEV = SE.getAddExpr(
      BackedgeTakenCount, SE.getOne(BackedgeTakenCount->getType()));

  // LP_COUNT (r60) is a 32-bit counter.
  if (SE.getUnsignedRangeMax(TripCountSCEV).getBitWidth() > 32) {
    LLVM_DEBUG(dbgs() << "ARCHWLoops: trip count wider than 32 bits\n");
    return false;
  }

  auto IsHardwareLoopIntrinsic = [](Instruction &I) {
    if (auto *Call = dyn_cast<IntrinsicInst>(&I)) {
      switch (Call->getIntrinsicID()) {
      default:
        break;
      case Intrinsic::set_loop_iterations:
      case Intrinsic::test_set_loop_iterations:
      case Intrinsic::start_loop_iterations:
      case Intrinsic::test_start_loop_iterations:
      case Intrinsic::loop_decrement:
      case Intrinsic::loop_decrement_reg:
        return true;
      }
    }
    return false;
  };

  // Reject any loop (or inner loop) that contains a call, inline asm, a
  // libcall-lowered op, or a pre-existing hardware-loop intrinsic. The call
  // rejection is load-bearing, not just profitability: it is the first ship's
  // guarantee that no `bl` sits between the LP_COUNT setup and the body, and it
  // keeps the interrupt-safety obligation (§4.4) confined to leaf loops.
  auto ScanLoop = [&](Loop *Scan) {
    for (auto *BB : Scan->getBlocks()) {
      for (auto &I : *BB) {
        if (maybeLoweredToCall(I) || IsHardwareLoopIntrinsic(I) ||
            isa<InlineAsm>(I)) {
          LLVM_DEBUG(dbgs() << "ARCHWLoops: bad instruction: " << I << "\n");
          return false;
        }
      }
    }
    return true;
  };
  for (auto *Inner : *L)
    if (!ScanLoop(Inner))
      return false;
  if (!ScanLoop(L))
    return false;

  LLVMContext &C = L->getHeader()->getContext();

  // ARM-style representation (an explicit counter register carried by a PHI and
  // decremented by llvm.loop.decrement.reg), NOT PowerPC's opaque CTR model.
  // The reason is the revert requirement: keeping the counter, compare and
  // back-branch as ordinary machine code means ARCLowOverheadLoops can walk
  // away from any loop whose silicon preconditions (>=4-word separation, s13
  // reach, block adjacency) it cannot prove, leaving a correct ordinary loop
  // behind instead of committing to an invalid `lp`.
  HWLoopInfo.CounterInReg = true;
  HWLoopInfo.IsNestingLegal = false;
  // The generic guard machinery assumes the hardware skips a zero count (ARM
  // WLS). This core does NOT: a count of 0 runs the body once (§4.4). So we do
  // not let the generic pass emit test.set.loop.iterations; ARCLowOverheadLoops
  // always emits an explicit zero-trip BRcc guard when it commits to LP.
  HWLoopInfo.PerformEntryTest = false;
  HWLoopInfo.CountType = Type::getInt32Ty(C);
  HWLoopInfo.LoopDecrement = ConstantInt::get(HWLoopInfo.CountType, 1);
  return true;
}

void ARCTTIImpl::getUnrollingPreferences(
    Loop *L, ScalarEvolution &SE, TTI::UnrollingPreferences &UP,
    OptimizationRemarkEmitter *ORE) const {
  // Size builds must not grow: at -Os/-Oz the goal is smaller .text, and
  // unrolling only ever adds instructions. Zero the size-mode thresholds and
  // leave the flags off so a MinSize/OptSize function keeps its rolled loop.
  UP.OptSizeThreshold = 0;
  UP.PartialOptSizeThreshold = 0;
  if (L->getHeader()->getParent()->hasOptSize())
    return;

  // Enable partial (compile-time-known trip count) and runtime (unknown trip
  // count `n`) unrolling with a scalar remainder loop. The reduction that
  // motivates this -- `for (i) s += a[i]` with an unknown `n` -- takes the
  // runtime path.
  UP.Partial = true;
  UP.Runtime = true;
  UP.AllowRemainder = true;
  // Do not unroll the remainder loop itself: it runs at most Count-1 times, so
  // unrolling it only adds code for no steady-state benefit.
  UP.UnrollRemainder = false;

  // Default unroll factor = 4.
  //
  // Dossier 20: steady-state throughput of the clustered reduction follows
  // cyc/elem = 2 + 9/k (k = unroll factor). The load-latency saturation point
  // is k = ceil(LoadLatency / load-ReleaseAtCycles) = ceil(10/2) = 5 -- five
  // independent 2-slot loads fill one load's 10-clock shadow. Returns diminish
  // sharply past there (k=4 is 2.6x, k=8 only 3.5x), so 4 is the pressure-cheap
  // default and is the value used by BOTH code paths:
  //   * the partial path (known trip count) reads UP.Count;
  //   * the runtime path (unknown trip count) ignores UP.Count -- the unroller
  //     resets it to 0 and then reads UP.DefaultUnrollRuntimeCount instead --
  //     so that field must be set to the same 4 or the runtime reduction would
  //     silently fall back to the generic default.
  UP.Count = 4;
  UP.DefaultUnrollRuntimeCount = 4;

  // Hard register-pressure cap. This is the load-bearing bound, not the cost
  // threshold: on this core the D-cache is disabled and a spill is an uncached
  // 10-clock load, so an unroll factor that spills makes the loop SLOWER. The
  // realistic single-accumulator clustered reduction has peak pressure
  // ~= k load temps + accumulator + pointer + counter ~= k + 3; the empirical
  // spill cliff on this backend (26 allocatable GPRs: R0..R24 and R30) is at 22
  // simultaneously-live temps. MaxCount = 8 -> peak ~11, less than half the
  // allocatable file and far under the cliff, so spills stay at 0 with
  // comfortable headroom for the enclosing function's own registers. The
  // generic LoopUnroll pass does not model register pressure itself, so this
  // cap is the only thing bounding it.
  UP.MaxCount = 8;
}
