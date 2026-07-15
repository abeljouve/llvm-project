//===- ARCConstantMaterialization.cpp - CONST32 recipe search -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM
// Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "ARCConstantMaterialization.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/Support/MathExtras.h"
#include <cassert>

using namespace llvm;

uint32_t llvm::interpretConst32Recipe(const Const32Recipe &R) {
  // Well-defined uint32_t shift (Shift <= 31), no host signed-shift UB.
  return R.Seed << R.Shift;
}

std::optional<Const32Recipe> llvm::synthesizeConst32(uint32_t C) {
  // DenseMap<uint32_t, ...> reserves 0xFFFFFFFF/0xFFFFFFFE (~0U/~0U-1) as
  // its Empty/Tombstone sentinel KEYS -- inserting either value as a real
  // key aborts with "Empty/Tombstone value shouldn't be inserted into
  // map!" regardless of what Result would have been. Both constants are
  // odd/low-trailing-zero shapes that never produce a seed<<shift recipe
  // anyway (see the search below), so short-circuiting them to nullopt
  // BEFORE any cache access is exact, not an approximation: callers fall
  // back to MOV_rlimm for -1 and -2 exactly as they would have if the
  // search below had been allowed to run to completion for them.
  if (C == 0xFFFFFFFFu || C == 0xFFFFFFFEu)
    return std::nullopt;

  // Persistent, deterministic memo -- both call sites (ISel and
  // ARCInstrInfo::expandPostRAPseudo) query the same cache and always
  // agree on the recipe for a given C. thread_local sidesteps any data
  // race if this toolchain's codegen pipeline ever parallelizes per-
  // function work.
  static thread_local DenseMap<uint32_t, std::optional<Const32Recipe>> Cache;
  if (auto It = Cache.find(C); It != Cache.end())
    return It->second;

  std::optional<Const32Recipe> Result;

  // C == 0 has no nonzero trailing-zero-count shift that produces it via
  // seed<<shift with a nonzero seed, so it is correctly left unhandled
  // here -- callers fall back to MOV_rlimm (0 is also always representable
  // via the s12 fast path anyway, so this recipe is never reached for it).
  if (C != 0) {
    unsigned Tz = countr_zero(C);
    // The ARCompact shift-count field is 5 bits wide (0..31); a 32-bit
    // nonzero value's trailing-zero-count is always in [0, 31], so Tz is
    // already bounded -- this check is defense-in-depth, not load-bearing.
    if (Tz >= 1 && Tz <= 31) {
      uint32_t Residue = C >> Tz; // exact: C is divisible by 2^Tz.
      // Residue is guaranteed odd (bit 0 set) hence nonzero here, so the
      // only remaining condition is that it fits the u8 seed window.
      if (Residue <= 0xFFu) {
        Const32Recipe R;
        R.Seed = Residue;
        R.Shift = static_cast<uint8_t>(Tz);
        // mov_s (2B) + asl (4B) = 6B, strictly less than the 8B
        // MOV_rlimm baseline (4B host + 4B LIMM word) this replaces.
        R.Bytes = 6;
        assert(interpretConst32Recipe(R) == C &&
               "ARC CONST32 recipe failed self-check: seed<<shift != C");
        Result = R;
      }
    }
  }

  constexpr size_t CacheCap = 16384;
  if (Cache.size() < CacheCap)
    Cache.try_emplace(C, Result);
  return Result;
}
