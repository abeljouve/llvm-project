//===- ARCELFObjectWriter.cpp - ARC ELF Writer ----------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the ARCELFObjectWriter class for ARC/ARCompact targets.
// Uses EM_ARC_COMPACT (93) for ARCompact and EM_ARC_COMPACT2 (195) for ARCv2.
//
//===----------------------------------------------------------------------===//

#include "ARCFixupKinds.h"
#include "MCTargetDesc/ARCMCTargetDesc.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {

class ARCELFObjectWriter : public MCELFObjectTargetWriter {
public:
  explicit ARCELFObjectWriter(uint8_t OSABI, bool IsARCompact);

  ~ARCELFObjectWriter() override = default;

protected:
  unsigned getRelocType(const MCFixup &Fixup, const MCValue &Target,
                        bool IsPCRel) const override;

  bool needsRelocateWithSymbol(const MCValue &, unsigned Type) const override;
};

} // end anonymous namespace

ARCELFObjectWriter::ARCELFObjectWriter(uint8_t OSABI, bool IsARCompact)
    : MCELFObjectTargetWriter(/*Is64Bit=*/false, OSABI,
                              IsARCompact ? ELF::EM_ARC_COMPACT
                                          : ELF::EM_ARC_COMPACT2,
                              /*HasRelocationAddend=*/true) {}

unsigned ARCELFObjectWriter::getRelocType(const MCFixup &Fixup,
                                          const MCValue &Target,
                                          bool IsPCRel) const {
  unsigned Kind = static_cast<unsigned>(Fixup.getKind());
  switch (Kind) {
  case FK_Data_1:
    return ELF::R_ARC_8;
  case FK_Data_2:
    return ELF::R_ARC_16;
  case FK_Data_4:
    return ELF::R_ARC_32;
  case ARC::fixup_arc_32:
    return ELF::R_ARC_32;
  case ARC::fixup_arc_s21h_pcrel:
    return ELF::R_ARC_S21H_PCREL;
  case ARC::fixup_arc_s21w_pcrel:
    return ELF::R_ARC_S21W_PCREL;
  case ARC::fixup_arc_s25h_pcrel:
    return ELF::R_ARC_S25H_PCREL;
  case ARC::fixup_arc_s25w_pcrel:
    return ELF::R_ARC_S25W_PCREL;
  case ARC::fixup_arc_32_pcrel:
    return ELF::R_ARC_32_PCREL;
  case ARC::fixup_arc_s9h_pcrel:
    // BRcc/BBIT0/BBIT1 are intra-function ±256 byte branches and are
    // always resolved locally by ARCAsmBackend::applyFixup. There is no
    // standard ARC ELF reloc for 9-bit PC-relative, so reaching this
    // point means the assembler was asked to emit a cross-section S9
    // relocation — which would overflow at link time anyway.
    report_fatal_error("ARC S9 branch target out of range (no S9 reloc)");
  default:
    llvm_unreachable("Invalid fixup kind!");
  }
}

bool ARCELFObjectWriter::needsRelocateWithSymbol(const MCValue &,
                                                  unsigned Type) const {
  switch (Type) {
  case ELF::R_ARC_32:
  case ELF::R_ARC_S21H_PCREL:
  case ELF::R_ARC_S21W_PCREL:
  case ELF::R_ARC_S25H_PCREL:
  case ELF::R_ARC_S25W_PCREL:
    return true;
  default:
    return false;
  }
}

std::unique_ptr<MCObjectTargetWriter>
llvm::createARCELFObjectWriter(uint8_t OSABI, bool IsARCompact) {
  return std::make_unique<ARCELFObjectWriter>(OSABI, IsARCompact);
}
