//===- ARCConstantMaterialization.h - CONST32 recipe search ---*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM
// Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Bounded, deterministic search for a cheap seed+shift recipe that
// materializes a 32-bit integer constant in fewer bytes than the 8-byte
// MOV_rlimm baseline (4-byte host instruction + 4-byte LIMM word). Shared
// by ARCISelDAGToDAG.cpp (selection-time recipe lookup, to decide whether
// to select the CONST32 pseudo instead of MOV_rlimm) and
// ARCInstrInfo.cpp's expandPostRAPseudo (post-register-allocation
// re-derivation of the IDENTICAL recipe from the raw immediate operand,
// to expand CONST32 into real instructions once its destination has a
// concrete physical register). CONST32 is deliberately expanded POST-RA
// -- not by the pre-RA ARCExpandPseudos pass -- so that it still exists,
// as a single register-free-input pseudo, when the register allocator
// makes its rematerialize-vs-spill decision; isReMaterializable is
// otherwise inert. Both call sites are pure functions of the 32-bit
// constant -- no subtarget or context dependence -- so they always agree
// on the recipe for a given value.
//
// Only ONE recipe family is implemented here: seed<<shift, i.e.
//
//   mov_s rD, Seed       ; 2 bytes, Seed in [1, 255]
//   asl   rD, rD, Shift  ; 4 bytes, Shift in [1, 31]
//
// which totals 6 bytes -- strictly less than the 8-byte MOV_rlimm baseline.
// This covers any 32-bit constant whose trailing-zero-count shift leaves a
// residue that fits an unsigned 8-bit seed (e.g. the canonical 0x00010000
// = 1 << 16, and 0x80000000 = 1 << 31). Constants that don't fit this
// shape (e.g. 0xFFFF0000, which needs a residue of 0xFFFF) are reported as
// not-found and the caller must keep the existing MOV_rlimm lowering.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_ARC_ARCCONSTANTMATERIALIZATION_H
#define LLVM_LIB_TARGET_ARC_ARCCONSTANTMATERIALIZATION_H

#include <cstdint>
#include <optional>

namespace llvm {

/// A single CONST32 "seed<<shift" recipe. All arithmetic used to interpret
/// or search for a recipe is uint32_t (mod 2^32) -- never a host signed
/// shift -- so high-bit-set constants (0x80000000, 0xFFFFF800, ...) are
/// handled correctly.
struct Const32Recipe {
  uint32_t Seed = 0; ///< u8 immediate for mov_s, in [1, 255].
  uint8_t Shift = 0; ///< shift amount for asl, in [1, 31].
  uint8_t Bytes = 0; ///< total encoded size of the recipe, in bytes.
};

/// Reinterpret a recipe as the 32-bit constant it produces
/// (Seed << Shift, computed in uint32_t). Exposed so both call sites, and
/// the recipe search's own self-check, share one authoritative
/// interpreter.
uint32_t interpretConst32Recipe(const Const32Recipe &R);

/// Search for the cheapest CONST32 recipe that reproduces exactly the
/// 32-bit constant C. Returns std::nullopt when no recipe strictly
/// cheaper than the 8-byte MOV_rlimm baseline exists -- callers MUST fall
/// back to MOV_rlimm (or MOV_rs12, for constants that fit a signed 12-bit
/// immediate, which callers are expected to check before calling this).
/// Memoized; pure function of C.
std::optional<Const32Recipe> synthesizeConst32(uint32_t C);

} // end namespace llvm

#endif // LLVM_LIB_TARGET_ARC_ARCCONSTANTMATERIALIZATION_H
