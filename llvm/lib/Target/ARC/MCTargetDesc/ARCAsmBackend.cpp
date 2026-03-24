//===- ARCAsmBackend.cpp - ARC Assembler Backend --------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the ARCAsmBackend class for ARC/ARCompact targets.
// Supports both little-endian and big-endian byte ordering.
//
//===----------------------------------------------------------------------===//

#include "ARCFixupKinds.h"
#include "MCTargetDesc/ARCMCTargetDesc.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {

class ARCAsmBackend : public MCAsmBackend {
  uint8_t OSABI;

public:
  ARCAsmBackend(llvm::endianness Endian, uint8_t OSABI)
      : MCAsmBackend(Endian), OSABI(OSABI) {}

  void applyFixup(const MCFragment &, const MCFixup &, const MCValue &Target,
                  uint8_t *Data, uint64_t Value, bool IsResolved) override;

  std::unique_ptr<MCObjectTargetWriter>
  createObjectTargetWriter() const override;

  MCFixupKindInfo getFixupKindInfo(MCFixupKind Kind) const override;

  bool writeNopData(raw_ostream &OS, uint64_t Count,
                    const MCSubtargetInfo *STI) const override;
};

} // end anonymous namespace

MCFixupKindInfo ARCAsmBackend::getFixupKindInfo(MCFixupKind Kind) const {
  // clang-format off
  const static MCFixupKindInfo Infos[ARC::NumTargetFixupKinds] = {
    // This table must be in the same order as enum in ARCFixupKinds.h.
    //
    // name                    offset bits flags
    {"fixup_arc_32",             0,    32,  0},
    {"fixup_arc_s21h_pcrel",     0,    21,  0},
    {"fixup_arc_s21w_pcrel",     0,    21,  0},
    {"fixup_arc_s25h_pcrel",     0,    25,  0},
    {"fixup_arc_s25w_pcrel",     0,    25,  0},
    {"fixup_arc_32_pcrel",       0,    32,  0},
  };
  // clang-format on
  static_assert((std::size(Infos)) == ARC::NumTargetFixupKinds,
                "Not all fixup kinds added to Infos array");

  if (Kind < FirstTargetFixupKind)
    return MCAsmBackend::getFixupKindInfo(Kind);

  assert(unsigned(Kind - FirstTargetFixupKind) < ARC::NumTargetFixupKinds &&
         "Invalid kind!");
  return Infos[Kind - FirstTargetFixupKind];
}

void ARCAsmBackend::applyFixup(const MCFragment &F, const MCFixup &Fixup,
                               const MCValue &Target, uint8_t *Data,
                               uint64_t Value, bool IsResolved) {
  maybeAddReloc(F, Fixup, Target, Value, IsResolved);
  MCFixupKindInfo Info = getFixupKindInfo(Fixup.getKind());
  if (!Value)
    return; // This value doesn't change the encoding.

  // Shift the value into position.
  Value <<= Info.TargetOffset;

  unsigned NumBytes = alignTo(Info.TargetSize + Info.TargetOffset, 8) / 8;
  assert(Fixup.getOffset() + NumBytes <= F.getSize() &&
         "Invalid fixup offset!");

  // For each byte of the fragment that the fixup touches, mask in the
  // bits from the fixup value. Handle endianness.
  if (Endian == llvm::endianness::big) {
    for (unsigned i = 0; i != NumBytes; ++i) {
      unsigned Idx = NumBytes - 1 - i;
      Data[Idx] |= uint8_t((Value >> (i * 8)) & 0xff);
    }
  } else {
    for (unsigned i = 0; i != NumBytes; ++i) {
      Data[i] |= uint8_t((Value >> (i * 8)) & 0xff);
    }
  }
}

bool ARCAsmBackend::writeNopData(raw_ostream &OS, uint64_t Count,
                                 const MCSubtargetInfo *STI) const {
  if ((Count % 2) != 0)
    return false;

  // ARC NOP encodings:
  // 32-bit NOP: 0x264A7000 (mov 0,0)
  // 16-bit NOP_S: 0x78E0
  for (uint64_t i = 0; i + 4 <= Count; i += 4) {
    if (Endian == llvm::endianness::big)
      OS.write("\x26\x4A\x70\x00", 4);
    else
      OS.write("\x00\x70\x4A\x26", 4);
  }

  // If there are 2 remaining bytes, emit a 16-bit NOP_S.
  if (Count % 4 == 2) {
    if (Endian == llvm::endianness::big)
      OS.write("\x78\xE0", 2);
    else
      OS.write("\xE0\x78", 2);
  }

  return true;
}

std::unique_ptr<MCObjectTargetWriter>
ARCAsmBackend::createObjectTargetWriter() const {
  return createARCELFObjectWriter(OSABI,
                                  Endian == llvm::endianness::big);
}

MCAsmBackend *llvm::createARCAsmBackend(const Target &T,
                                        const MCSubtargetInfo &STI,
                                        const MCRegisterInfo &MRI,
                                        const MCTargetOptions &Options) {
  const Triple &TT = STI.getTargetTriple();
  llvm::endianness End = TT.isLittleEndian() ? llvm::endianness::little
                                              : llvm::endianness::big;
  uint8_t OSABI = MCELFObjectTargetWriter::getOSABI(TT.getOS());
  return new ARCAsmBackend(End, OSABI);
}
