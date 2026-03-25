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
  // Expand HWLOOP_SETUP/HWLOOP_SETUP_IMM pseudos into MOV+NOP+LP sequence.
  addPass(createARCExpandHWLoopsPass());
  // Replace 32-bit instructions with compact 16-bit equivalents when
  // optimizing for size (-Os/-Oz). ARCompact (ARC700) only.
  addPass(createARCSizeReductionPass());
  // Delay slot filler runs after branch finalization, only for ARCompact.
  addPass(createARCDelaySlotFillerPass());
}

void ARCPassConfig::addPreRegAlloc() {
    addPass(createARCExpandPseudosPass());
    addPass(createARCOptAddrMode());
    addPass(createARCHardwareLoopsPass());
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
  initializeARCExpandHWLoopsPass(PR);
  initializeARCHardwareLoopsPass(PR);
  initializeARCSizeReductionPass(PR);
}

TargetTransformInfo
ARCTargetMachine::getTargetTransformInfo(const Function &F) const {
  return TargetTransformInfo(std::make_unique<ARCTTIImpl>(this, F));
}
