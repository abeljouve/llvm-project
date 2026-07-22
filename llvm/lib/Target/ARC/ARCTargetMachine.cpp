//===- ARCTargetMachine.cpp - Define TargetMachine for ARC ------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

#include "ARCTargetMachine.h"
#include "ARC.h"
#include "ARCMachineFunctionInfo.h"
#include "ARCTargetTransformInfo.h"
#include "TargetInfo/ARCTargetInfo.h"
#include "llvm/CodeGen/MachineScheduler.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/MC/TargetRegistry.h"
#include <optional>

using namespace llvm;

static Reloc::Model getRelocModel(std::optional<Reloc::Model> RM) {
  return RM.value_or(Reloc::Static);
}

/// ARCTargetMachine ctor - Create an ILP32 architecture model
ARCTargetMachine::ARCTargetMachine(const Target &T, const Triple &TT,
                                   StringRef CPU, StringRef FS,
                                   const TargetOptions &Options,
                                   std::optional<Reloc::Model> RM,
                                   std::optional<CodeModel::Model> CM,
                                   CodeGenOptLevel OL, bool JIT)
    : CodeGenTargetMachineImpl(T, TT.computeDataLayout(), TT, CPU, FS, Options,
                               getRelocModel(RM),
                               getEffectiveCodeModel(CM, CodeModel::Small), OL),
      TLOF(std::make_unique<TargetLoweringObjectFileELF>()),
      Subtarget(TT, std::string(CPU), std::string(FS), *this) {
  initAsmInfo();
}

ARCTargetMachine::~ARCTargetMachine() = default;

namespace {

/// ARC Code Generator Pass Configuration Options.
class ARCPassConfig : public TargetPassConfig {
public:
  ARCPassConfig(ARCTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  ARCTargetMachine &getARCTargetMachine() const {
    return getTM<ARCTargetMachine>();
  }

  void addIRPasses() override;
  bool addInstSelector() override;
  void addPreEmitPass() override;
  void addPreRegAlloc() override;
};

} // end anonymous namespace

TargetPassConfig *ARCTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new ARCPassConfig(*this, PM);
}

ScheduleDAGInstrs *
ARCTargetMachine::createMachineScheduler(MachineSchedContext *C) const {
  // Standard converging pre-RA scheduler (the pass that already runs for
  // bcm55030 via ARCSubtarget::enableMachineScheduler, which is gated on a
  // real instruction-scheduling model being present). Attach the load-cluster
  // mutation so neighbouring loads off the same base are grouped and the
  // scheduler can fill each load's 10-cycle shadow with the other independent
  // loads (dossier 20). ReorderWhileClustering=false keeps clustered ops in
  // their original program order -- the conservative choice, and on this core
  // the volatile/MMIO ordering guarantee already lives in ARCInstrInfo's
  // getMemOperandsWithOffsetWidth (ordered accesses are never candidates).
  // No store-cluster mutation: stores are posted / write-buffered here, so
  // grouping them buys nothing.
  ScheduleDAGMILive *DAG = createSchedLive<GenericScheduler>(C);
  DAG->addMutation(createLoadClusterDAGMutation(
      DAG->TII, DAG->TRI, /*ReorderWhileClustering=*/false));
  return DAG;
}

void ARCPassConfig::addIRPasses() {
  addPass(createAtomicExpandLegacyPass());

  TargetPassConfig::addIRPasses();

  // Zero-overhead (LP) hardware-loop formation, gated OFF by default (see
  // ARCTargetTransformInfo.cpp and the note in addPreEmitPass below). The
  // generic pass proves the trip count with SCEV and emits the
  // start.loop.iterations / loop.decrement.reg contract; ARCLowOverheadLoops
  // (addPreEmitPass) later commits it to `lp` or reverts to an ordinary loop.
  // Placed after the base IR passes, mirroring ARM. Adding it is cheap when the
  // flag is off -- ARCTTIImpl::isHardwareLoopProfitable returns false and it
  // converts nothing.
  if (ARCEnableHardwareLoops())
    addPass(createHardwareLoopsLegacyPass());
}

bool ARCPassConfig::addInstSelector() {
  addPass(createARCISelDag(getARCTargetMachine(), getOptLevel()));
  return false;
}

void ARCPassConfig::addPreEmitPass() {
  addPass(createARCBranchFinalizePass());
  // Replace 32-bit instructions with compact 16-bit equivalents when
  // optimizing for size (-Os/-Oz). ARCompact (ARC700) only.
  addPass(createARCSizeReductionPass());
  // Delay slot filler runs after branch finalization, only for ARCompact.
  addPass(createARCDelaySlotFillerPass());

  // Zero-overhead loop finalize MUST be last: it is the only point where
  // instruction sizes are final, so it is the only point where the ISA's
  // >=4-instruction-WORD LP_COUNT setup separation and the `lp` +/-4 KiB reach
  // can be checked against the real layout (the deleted pass got this wrong by
  // deciding padding ~50 passes before block placement). It commits a proven
  // counted loop to `lp` -- with a zero-trip guard folded into the conditional
  // `lp<cc>` form and word-separation padding -- or reverts it to an ordinary
  // countdown loop. Gated OFF by default: the target's interrupt entry code
  // does not save LP_COUNT / LP_START / LP_END (r60 + AUX 0x02/0x03), so
  // emitting LP unconditionally would let an LP-using handler silently corrupt
  // a foreground loop it interrupts. Turning -arc-hardware-loops on is only
  // safe once every interrupt trampoline preserves those three, OR every
  // handler is proven LP-free (docs/notes/isa-characterization.md 4.4). That
  // code lives in the separate firmware repo, so the backend ships gated and
  // the firmware flips it on.
  if (ARCEnableHardwareLoops())
    addPass(createARCLowOverheadLoopsPass());
}

void ARCPassConfig::addPreRegAlloc() {
    addPass(createARCExpandPseudosPass());
    addPass(createARCOptAddrMode());
    // No zero-overhead loop (LP) formation runs here. The ARCHardwareLoops
    // pass that used to sit at this point has been REMOVED rather than left
    // disabled, because its disable note mis-diagnosed the failure and sent
    // every later reader after the wrong layer:
    //
    //   * It claimed the pass "runs after phi elimination". It does not --
    //     this hook is ~pos 97 and phi elimination is pos 103.
    //   * It claimed the pass "corrupts live intervals". It cannot --
    //     LiveIntervals is not computed until pos 106, ten passes later.
    //
    // What actually happened: the pass emitted invalid MIR on the spot
    // (`llc -run-pass=arc-hwloops -verify-machineinstrs` reported 6 errors
    // on the first counted loop -- it deleted the latch->header edge while
    // leaving the header PHIs naming the latch). LiveIntervals was then
    // built from already-broken MIR and the allocator crashed downstream.
    // The allocator SIGSEGV was a symptom, so "fix the live intervals" was
    // never actionable and the pass stayed dead.
    //
    // It was not repairable: the trip count was an ad-hoc MI pattern match
    // rather than SCEV, there was no zero-trip guard at all (a count of 0
    // does not skip the body on this core -- it runs once), the ISA's
    // >= 4 instruction *word* separation after an LP_COUNT write was
    // approximated as an instruction tally behind a tuning knob, and block
    // layout was queried ~50 passes before Block Placement decides it.
    //
    // Formation has since been rebuilt exactly this way and does NOT run
    // here: it is the generic llvm/lib/CodeGen/HardwareLoops.cpp IR pass
    // (SCEV trip counts; added in addIRPasses, ARM/PPC-style) driven by
    // ARCTTIImpl::isHardwareLoopProfitable, plus ARCLowOverheadLoops as the
    // late commit-or-fall-back step (added LAST in addPreEmitPass, after size
    // reduction and the delay-slot filler, where sizes are final and the
    // word-separation rule and LP's +/-4 KiB range can actually be checked).
    // Both are gated behind the off-by-default -arc-hardware-loops flag.
    //
    // The LP *encoding* path is correct and byte-verified against the
    // reference ARCompact decoder (see
    // llvm/test/CodeGen/ARC/arc700eb-lp-encoding.mir), so that rebuild
    // started from a working encoder rather than a silently wrong one.
    //
    // NOTE for whoever enables formation: this target's runtime interrupt
    // entry code does not save LP_COUNT / LP_START / LP_END, and says so in
    // its own source with the stated precondition that the compiler never
    // emits zero-overhead loops. Emitting LP by default breaks that
    // precondition silently. Formation must stay off by default until that
    // entry code saves r60 + AUX 0x02/0x03, or every handler is proven
    // LP-free.
}

MachineFunctionInfo *ARCTargetMachine::createMachineFunctionInfo(
    BumpPtrAllocator &Allocator, const Function &F,
    const TargetSubtargetInfo *STI) const {
    return ARCFunctionInfo::create<ARCFunctionInfo>(Allocator, F, STI);
}

// Force static initialization.
extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeARCTarget() {
  RegisterTargetMachine<ARCTargetMachine> X(getTheARCTarget());
  RegisterTargetMachine<ARCTargetMachine> Y(getTheARCebTarget());
  PassRegistry &PR = *PassRegistry::getPassRegistry();
  initializeARCAsmPrinterPass(PR);
  initializeARCDAGToDAGISelLegacyPass(PR);
  initializeARCDelaySlotFillerPass(PR);
  initializeARCSizeReductionPass(PR);
  initializeARCLowOverheadLoopsPass(PR);
  // Both of these carry INITIALIZE_PASS macros but were never handed to the
  // registry, so their -run-pass / -stop-after / -print-after names did not
  // resolve and neither could be driven from a MIR test in isolation --
  // ARCOptAddrMode was also invisible to -print-after-all, which is what hid
  // the stale kill flags it used to leave behind.
  initializeARCOptAddrModePass(PR);
  initializeARCBranchFinalizePass(PR);
}

TargetTransformInfo
ARCTargetMachine::getTargetTransformInfo(const Function &F) const {
  return TargetTransformInfo(std::make_unique<ARCTTIImpl>(this, F));
}
