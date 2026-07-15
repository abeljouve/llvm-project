//===- ARCInstrInfo.h - ARC Instruction Information -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the ARC implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_ARC_ARCINSTRINFO_H
#define LLVM_LIB_TARGET_ARC_ARCINSTRINFO_H

#include "ARCRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "ARCGenInstrInfo.inc"

namespace llvm {

class ARCSubtarget;

class ARCInstrInfo : public ARCGenInstrInfo {
  const ARCRegisterInfo RI;
  virtual void anchor();

public:
  ARCInstrInfo(const ARCSubtarget &);

  const ARCRegisterInfo &getRegisterInfo() const { return RI; }

  /// If the specified machine instruction is a direct
  /// load from a stack slot, return the virtual or physical register number of
  /// the destination along with the FrameIndex of the loaded stack slot.  If
  /// not, return 0.  This predicate must return 0 if the instruction has
  /// any side effects other than loading from the stack slot.
  Register isLoadFromStackSlot(const MachineInstr &MI,
                               int &FrameIndex) const override;

  /// If the specified machine instruction is a direct
  /// store to a stack slot, return the virtual or physical register number of
  /// the source reg along with the FrameIndex of the loaded stack slot.  If
  /// not, return 0.  This predicate must return 0 if the instruction has
  /// any side effects other than storing to the stack slot.
  Register isStoreToStackSlot(const MachineInstr &MI,
                              int &FrameIndex) const override;

  unsigned getInstSizeInBytes(const MachineInstr &MI) const override;

  bool analyzeBranch(MachineBasicBlock &MBB, MachineBasicBlock *&TBB,
                     MachineBasicBlock *&FBB,
                     SmallVectorImpl<MachineOperand> &Cond,
                     bool AllowModify) const override;

  unsigned insertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                        MachineBasicBlock *FBB, ArrayRef<MachineOperand> Cond,
                        const DebugLoc &,
                        int *BytesAdded = nullptr) const override;

  unsigned removeBranch(MachineBasicBlock &MBB,
                        int *BytesRemoved = nullptr) const override;

  void copyPhysReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                   const DebugLoc &, Register DestReg, Register SrcReg,
                   bool KillSrc, bool RenamableDest = false,
                   bool RenamableSrc = false) const override;

  void storeRegToStackSlot(
      MachineBasicBlock &MBB, MachineBasicBlock::iterator MI, Register SrcReg,
      bool IsKill, int FrameIndex, const TargetRegisterClass *RC, Register VReg,
      MachineInstr::MIFlag Flags = MachineInstr::NoFlags) const override;

  void loadRegFromStackSlot(
      MachineBasicBlock &MBB, MachineBasicBlock::iterator MI, Register DestReg,
      int FrameIndex, const TargetRegisterClass *RC, Register VReg,
      unsigned subReg = 0,
      MachineInstr::MIFlag Flags = MachineInstr::NoFlags) const override;

  bool
  reverseBranchCondition(SmallVectorImpl<MachineOperand> &Cond) const override;


  bool isPostIncrement(const MachineInstr &MI) const override;

  // Expands CONST32 (dossier 21 idea 4 -- CONST32 recipe rematerialization,
  // docs/llvm-arc700-optimizations/21-*.md) into its seed<<shift chain.
  // Deliberately implemented here, in the target-independent post-RA
  // pseudo-expansion hook, rather than in the pre-RA ARCExpandPseudos
  // pass: CONST32 must still exist -- as a single pseudo with no register
  // operands -- when the register allocator makes its rematerialize-vs-
  // spill decision, or isReMaterializable has nothing to act on. By the
  // time this hook runs, $dst already names a concrete physical register
  // (constrained to GPR_S by CONST32's TableGen def), so the expansion is
  // self-contained: no scratch register is needed.
  bool expandPostRAPseudo(MachineInstr &MI) const override;

  // ARC-specific
  bool isPreIncrement(const MachineInstr &MI) const;

  virtual bool getBaseAndOffsetPosition(const MachineInstr &MI,
                                        unsigned &BasePos,
                                        unsigned &OffsetPos) const override;

  // Emit code before MBBI to load immediate value into physical register Reg.
  // Returns an iterator to the new instruction.
  MachineBasicBlock::iterator loadImmediate(MachineBasicBlock &MBB,
                                            MachineBasicBlock::iterator MI,
                                            unsigned Reg, uint64_t Value) const;
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_ARC_ARCINSTRINFO_H
