//===- ARCSubtarget.cpp - ARC Subtarget Information -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the ARC specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "ARCSubtarget.h"
#include "ARC.h"
#include "ARCSelectionDAGInfo.h"
#include "llvm/CodeGen/LibcallLoweringInfo.h"
#include "llvm/IR/RuntimeLibcalls.h"
#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "arc-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "ARCGenSubtargetInfo.inc"

void ARCSubtarget::anchor() {}

ARCSubtarget &ARCSubtarget::initializeSubtargetDependencies(const Triple &TT,
                                                           StringRef CPU,
                                                           StringRef FS) {
  // Parse the subtarget features to set HasMPY, IsARCompact, IsBigEndian, etc.
  ParseSubtargetFeatures(CPU, /*TuneCPU=*/CPU, FS);

  // Also detect big-endian from triple as a fallback.
  if (TT.getArch() == Triple::arceb)
    IsBigEndian = true;

  return *this;
}

ARCSubtarget::ARCSubtarget(const Triple &TT, const std::string &CPU,
                           const std::string &FS, const TargetMachine &TM)
    : ARCGenSubtargetInfo(TT, CPU, /*TuneCPU=*/CPU, FS),
      // Parse features FIRST (via initializeSubtargetDependencies) so the
      // feature flags are correct before InstrInfo / FrameLowering / TLInfo
      // read them. TLInfo's constructor gates MUL/MULHU lowering on hasMPY();
      // latching a stale flag here causes a TargetLowering/ISel desync that
      // surfaces as "Cannot select mul" under LTO codegen.
      InstrInfo(initializeSubtargetDependencies(TT, CPU, FS)),
      FrameLowering(*this), TLInfo(TM, *this) {
  TSInfo = std::make_unique<ARCSelectionDAGInfo>();
}

ARCSubtarget::~ARCSubtarget() = default;

const SelectionDAGTargetInfo *ARCSubtarget::getSelectionDAGInfo() const {
  return TSInfo.get();
}

bool ARCSubtarget::enableMachineScheduler() const {
  // True only for a CPU that actually carries an instruction-level scheduling
  // model (hasInstrSchedModel() <=> the model has a SchedClassTable; a
  // NoItineraries CPU gets NoSchedModel, whose table is null). See the header
  // for why this is not simply `return true`.
  return getSchedModel().hasInstrSchedModel();
}

bool ARCSubtarget::enableJoinGlobalCopies() const {
  // Deliberately NOT the default (which mirrors enableMachineScheduler() and
  // would silently turn the coalescer aggressive the moment the scheduler was
  // switched on). Keeps the pre-scheduler behaviour so the scheduler's effect
  // can be attributed on its own. See the header.
  return false;
}

void ARCSubtarget::initLibcallLoweringInfo(LibcallLoweringInfo &Info) const {
  // For arceb (big-endian ARC), RuntimeLibcalls.td's isDefaultLibcallArch
  // predicate only covers Triple::arc (LE). This function populates the same
  // libcall set for arceb so that soft-float, integer division, and i64
  // operations work correctly on both ARC endiannesses.
  //
  // Entries are only set when still Unsupported (no-op for arc-LE which already
  // has the default set populated by the TableGen-generated machinery).
  using LC = RTLIB::Libcall;
  using LI = RTLIB::LibcallImpl;
  const std::pair<LC, LI> Table[] = {
      // Soft-float arithmetic
      {RTLIB::ADD_F32, LI::impl___addsf3},
      {RTLIB::ADD_F64, LI::impl___adddf3},
      {RTLIB::SUB_F32, LI::impl___subsf3},
      {RTLIB::SUB_F64, LI::impl___subdf3},
      {RTLIB::MUL_F32, LI::impl___mulsf3},
      {RTLIB::MUL_F64, LI::impl___muldf3},
      {RTLIB::DIV_F32, LI::impl___divsf3},
      {RTLIB::DIV_F64, LI::impl___divdf3},
      // Soft-float comparisons
      {RTLIB::OEQ_F32, LI::impl___eqsf2},
      {RTLIB::OEQ_F64, LI::impl___eqdf2},
      {RTLIB::UNE_F32, LI::impl___nesf2},
      {RTLIB::UNE_F64, LI::impl___nedf2},
      {RTLIB::OGE_F32, LI::impl___gesf2},
      {RTLIB::OGE_F64, LI::impl___gedf2},
      {RTLIB::OGT_F32, LI::impl___gtsf2},
      {RTLIB::OGT_F64, LI::impl___gtdf2},
      {RTLIB::OLE_F32, LI::impl___lesf2},
      {RTLIB::OLE_F64, LI::impl___ledf2},
      {RTLIB::OLT_F32, LI::impl___ltsf2},
      {RTLIB::OLT_F64, LI::impl___ltdf2},
      {RTLIB::UO_F32,  LI::impl___unordsf2},
      {RTLIB::UO_F64,  LI::impl___unorddf2},
      // Float <-> Int conversions
      {RTLIB::FPTOSINT_F32_I32, LI::impl___fixsfsi},
      {RTLIB::FPTOSINT_F64_I32, LI::impl___fixdfsi},
      {RTLIB::FPTOSINT_F32_I64, LI::impl___fixsfdi},
      {RTLIB::FPTOSINT_F64_I64, LI::impl___fixdfdi},
      {RTLIB::FPTOUINT_F32_I32, LI::impl___fixunssfsi},
      {RTLIB::FPTOUINT_F64_I32, LI::impl___fixunsdfsi},
      {RTLIB::FPTOUINT_F32_I64, LI::impl___fixunssfdi},
      {RTLIB::FPTOUINT_F64_I64, LI::impl___fixunsdfdi},
      {RTLIB::SINTTOFP_I32_F32, LI::impl___floatsisf},
      {RTLIB::SINTTOFP_I32_F64, LI::impl___floatsidf},
      {RTLIB::SINTTOFP_I64_F32, LI::impl___floatdisf},
      {RTLIB::SINTTOFP_I64_F64, LI::impl___floatdidf},
      {RTLIB::UINTTOFP_I32_F32, LI::impl___floatunsisf},
      {RTLIB::UINTTOFP_I32_F64, LI::impl___floatunsidf},
      {RTLIB::UINTTOFP_I64_F32, LI::impl___floatundisf},
      {RTLIB::UINTTOFP_I64_F64, LI::impl___floatundidf},
      // Float extend / truncate
      {RTLIB::FPEXT_F32_F64,   LI::impl___extendsfdf2},
      {RTLIB::FPROUND_F64_F32, LI::impl___truncdfsf2},
      // Integer division (ARC700 has no hardware divide)
      {RTLIB::SDIV_I32, LI::impl___divsi3},
      {RTLIB::UDIV_I32, LI::impl___udivsi3},
      {RTLIB::SREM_I32, LI::impl___modsi3},
      {RTLIB::UREM_I32, LI::impl___umodsi3},
      {RTLIB::SDIV_I64, LI::impl___divdi3},
      {RTLIB::UDIV_I64, LI::impl___udivdi3},
      {RTLIB::SREM_I64, LI::impl___moddi3},
      {RTLIB::UREM_I64, LI::impl___umoddi3},
      // 64-bit integer helpers (on 32-bit target)
      {RTLIB::SHL_I64, LI::impl___ashldi3},
      {RTLIB::SRL_I64, LI::impl___lshrdi3},
      {RTLIB::SRA_I64, LI::impl___ashrdi3},
      {RTLIB::MUL_I64, LI::impl___muldi3},
      // 32x32 multiply helpers (ARC700 ships without MULTIPLY_BUILD)
      {RTLIB::MUL_I32, LI::impl___mulsi3},
      // CTLZ/CTTZ are NOT registered as libcalls: ARCISelLowering sets
      // ISD::CTLZ/CTTZ to Expand (or Custom→inline shift-OR + popcount), so a
      // CTLZ_I32 libcall impl would never be consulted (and a LibCall action on
      // CTLZ is itself a trap — ConvertNodeToLibcall has no CTLZ case).
      // Memory functions
      {RTLIB::MEMCPY,  LI::impl_memcpy},
      {RTLIB::MEMMOVE, LI::impl_memmove},
      {RTLIB::MEMSET,  LI::impl_memset},
  };
  for (const auto &[Libcall, Impl] : Table)
    if (Info.getLibcallImpl(Libcall) == LI::Unsupported)
      Info.setLibcallImpl(Libcall, Impl);
}
