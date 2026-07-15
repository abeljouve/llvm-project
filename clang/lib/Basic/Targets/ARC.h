//===--- ARC.h - Declare ARC target feature support -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares ARC TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_BASIC_TARGETS_ARC_H
#define LLVM_CLANG_LIB_BASIC_TARGETS_ARC_H

#include "clang/Basic/TargetInfo.h"
#include "clang/Basic/TargetOptions.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/Support/Compiler.h"
#include "llvm/TargetParser/Triple.h"

namespace clang {
namespace targets {

class LLVM_LIBRARY_VISIBILITY ARCTargetInfo : public TargetInfo {
public:
  // Recognized -mcpu / -target-cpu values. CK_NONE means "no -mcpu given"
  // (TargetInfo::CreateTargetInfo only calls setCPU when TargetOpts.CPU is
  // non-empty, so this stays the enum's value for the common no-CPU build --
  // it must never be treated as, or silently upgraded to, a "generic"
  // profile: see the giant comment on CPUInfo in ARC.cpp for why "generic"
  // is deliberately NOT an accepted name here).
  enum CPUKind {
    CK_NONE,
    CK_ARC700,
    CK_ARC700EB,
    CK_BCM55030,
  };

private:
  CPUKind CPU = CK_NONE;
  // Set from the "+arcompact" target-feature string by handleTargetFeatures.
  bool IsARCompact = false;

public:
  ARCTargetInfo(const llvm::Triple &Triple, const TargetOptions &)
      : TargetInfo(Triple) {
    NoAsmVariants = true;
    LongLongAlign = 32;
    SuitableAlign = 32;
    DoubleAlign = LongDoubleAlign = 32;
    SizeType = UnsignedInt;
    PtrDiffType = SignedInt;
    IntPtrType = SignedInt;
    UseZeroLengthBitfieldAlignment = true;
    resetDataLayout();
  }

  void getTargetDefines(const LangOptions &Opts,
                        MacroBuilder &Builder) const override;

  llvm::SmallVector<Builtin::InfosShard> getTargetBuiltins() const override {
    return {};
  }

  BuiltinVaListKind getBuiltinVaListKind() const override {
    return TargetInfo::VoidPtrBuiltinVaList;
  }

  std::string_view getClobbers() const override { return ""; }

  // Index N here MUST match the backend's HWEncoding/DwarfRegNum for
  // register N (see llvm/lib/Target/ARC/ARCRegisterInfo.td). Architectural
  // assignment, cross-checked against ARCRegisterInfo.td/.cpp
  // (getFrameRegister(): FP used when hasFP(), SP otherwise -- both are
  // reserved in getReservedRegs()):
  //   r26 = gp, r27 = fp, r28 = sp, r29 = ilink1, r31 = blink.
  ArrayRef<const char *> getGCCRegNames() const override {
    static const char *const GCCRegNames[] = {
        "r0",  "r1",  "r2",  "r3",  "r4",  "r5",     "r6",  "r7",
        "r8",  "r9",  "r10", "r11", "r12", "r13",    "r14", "r15",
        "r16", "r17", "r18", "r19", "r20", "r21",    "r22", "r23",
        "r24", "r25", "gp",  "fp",  "sp",  "ilink1", "r30", "blink"};
    return llvm::ArrayRef(GCCRegNames);
  }

  ArrayRef<TargetInfo::GCCRegAlias> getGCCRegAliases() const override {
    // "ilink2" is the architectural alias of reserved r30 on cores that
    // implement a second interrupt level (docs/llvm-arc700-optimizations/
    // 14-frontend-intrinsics-interrupt-abi.md). r30 is a real physical
    // register in the backend (ARCRegisterInfo.td `def R30 : Core<30,
    // "%r30">`) and already a canonical GCCRegNames entry above, so no
    // assembler-side support for the spelling "ilink2" is required: clang
    // resolves GCCRegAlias to the canonical register name/number before any
    // assembly text is emitted.
    //
    // NOTE: r30 is NOT in ARCRegisterInfo::getReservedRegs() today, so this
    // alias only lets source name r30 via a register variable/constraint --
    // it does not by itself reserve r30 from ordinary codegen allocation.
    // True dual-interrupt-level safety needs a getReservedRegs() change plus
    // real interrupt calling-convention handling, which is out of scope here
    // (deferred -- see workflow SCOPE LIMIT on interrupt CC codegen).
    static const TargetInfo::GCCRegAlias GCCRegAliases[] = {
        {{"ilink2"}, "r30"},
    };
    return llvm::ArrayRef(GCCRegAliases);
  }

  bool validateAsmConstraint(const char *&Name,
                             TargetInfo::ConstraintInfo &Info) const override {
    // Most constraint letters used by typical bare-metal MMIO inline asm
    // (r, m, i, n, g, digit-tied operands and their modifiers) are validated
    // entirely by the shared implementation in
    // TargetInfo::validateOutputConstraint / validateInputConstraint
    // (clang/lib/Basic/TargetInfo.cpp) before this hook is ever reached --
    // empirically confirmed: compiling representative "r"/"i" MMIO
    // register-access asm produces zero diagnostics with this hook
    // unconditionally returning false. This hook only fires for letters the
    // shared code doesn't already know: target-specific classes and
    // unrecognized/hard-register letters.
    //
    // We explicitly accept "r" here too (the one register-class constraint
    // the backend actually implements -- see ARCISelLowering.cpp
    // getConstraintType/getRegForInlineAsmConstraint, which maps "r" to
    // ARC::GPR32RegClass and nothing else) so this function documents and
    // enforces the real contract even though the shared code currently
    // short-circuits before reaching it for plain "r".
    //
    // Everything else -- in particular the GCC arc-elf32 immediate-range
    // letters I/J/K/L/M/N/O/P, and curly-brace hard-register binds -- has
    // NO corresponding LowerAsmOperandForConstraint implementation in this
    // LLVM backend. Accepting one of those letters here without a matching
    // backend lowering would let clang accept inline asm the backend cannot
    // select, trading a clean "invalid input constraint" diagnostic for a
    // silent codegen failure/miscompile. Any future case added here MUST
    // land together with the matching ARCISelLowering.cpp lowering.
    switch (*Name) {
    case 'r':
      Info.setAllowsRegister();
      return true;
    default:
      return false;
    }
  }

  bool hasBitIntType() const override { return true; }

  bool isCLZForZeroUndef() const override { return false; }

  CPUKind getCPUKind(StringRef Name) const;

  bool isValidCPUName(StringRef Name) const override {
    return getCPUKind(Name) != CK_NONE;
  }

  void fillValidCPUList(SmallVectorImpl<StringRef> &Values) const override;

  bool setCPU(const std::string &Name) override {
    CPU = getCPUKind(Name);
    return CPU != CK_NONE;
  }

  bool handleTargetFeatures(std::vector<std::string> &Features,
                            DiagnosticsEngine &Diags) override {
    IsARCompact = llvm::is_contained(Features, "+arcompact");
    return true;
  }

  bool hasFeature(StringRef Feature) const override {
    return llvm::StringSwitch<bool>(Feature)
        .Case("arc", true)
        .Case("arcompact", IsARCompact)
        .Default(false);
  }
};

} // namespace targets
} // namespace clang

#endif // LLVM_CLANG_LIB_BASIC_TARGETS_ARC_H
