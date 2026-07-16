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

void ARCPassConfig::addIRPasses() {
  addPass(createAtomicExpandLegacyPass());

  TargetPassConfig::addIRPasses();
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
    // Formation should be rebuilt on the generic llvm/lib/CodeGen/
    // HardwareLoops.cpp IR pass (SCEV trip counts + a real zero-trip guard,
    // as ARM/PPC use it) plus a late commit-or-fall-back step that runs
    // AFTER size reduction and the delay-slot filler, where instruction
    // sizes are final and the word-separation rule and LP's +/-4 KiB range
    // can actually be checked.
    //
    // The LP *encoding* path is now correct and byte-verified against the
    // reference ARCompact decoder (see
    // llvm/test/CodeGen/ARC/arc700eb-lp-encoding.mir), so that rebuild
    // starts from a working encoder rather than a silently wrong one.
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
}

TargetTransformInfo
ARCTargetMachine::getTargetTransformInfo(const Function &F) const {
  return TargetTransformInfo(std::make_unique<ARCTTIImpl>(this, F));
}
