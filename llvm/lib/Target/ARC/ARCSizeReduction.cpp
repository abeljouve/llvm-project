//===- ARCSizeReduction.cpp - ARC700 16-bit size reduction pass ---*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass replaces 32-bit ARCompact instructions with their 16-bit (_S)
// equivalents when possible, reducing code size for ARC700 targets.
//
// The ARCompact ISA has compact 16-bit variants for common ALU operations.
// These are only available when:
//   1. All register operands are in GPR_S = {R0, R1, R2, R3, R12, R13, R14, R15}
//   2. For 3-operand forms: the destination equals the first source (A == B)
//
// The pass only runs when:
//   - The subtarget isARCompact() (ARC700 only, not ARCv2)
//   - The function is compiled with -Os or -Oz (optimize for size)
//
// This is a post-RA pass: physical registers have been assigned, so GPR_S
// membership can be checked directly via GPR_SRegClass.contains(Reg).
//
//===----------------------------------------------------------------------===//

#include "ARC.h"
#include "ARCSubtarget.h"
#include "MCTargetDesc/ARCMCTargetDesc.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/CodeGen/TargetRegisterInfo.h"
#include "llvm/InitializePasses.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define DEBUG_TYPE "arc-size-reduction"

STATISTIC(NumReduced, "Number of instructions reduced to 16-bit");

namespace llvm {
void initializeARCSizeReductionPass(PassRegistry &Registry);
} // end namespace llvm

namespace {

/// Describes a 32-bit -> 16-bit reduction rule.
struct ReduceEntry {
  unsigned WideOpc;    ///< 32-bit opcode to match
  unsigned NarrowOpc;  ///< 16-bit replacement opcode
  /// Number of explicit register operands that must be in GPR_S.
  /// For 3-op (A=B form): NarrowNumRegs==3, with constraint [0]==[1].
  /// For 2-op (single dest+src): NarrowNumRegs==2.
  unsigned NarrowNumRegs;
  /// When true: operand[0] (dest) must equal operand[1] (first src).
  bool DestEqSrc1;
};

/// Table of reducible instructions.
/// All entries require all listed register operands in GPR_S.
/// "DestEqSrc1" entries correspond to instructions of the form "OP b,b,c"
/// where the 16-bit encoding implies dest==first-src.
static const ReduceEntry ReduceTable[] = {
  // 3-operand ALU: ADD_S / SUB_S / AND_S / OR_S / XOR_S (b,b,c form)
  // 32-bit: ARC_ADD_a_b_c  (outs ra), (ins rb, rc)  -- a==b checked at runtime
  { ARC::ARC_ADD_a_b_c, ARC::ARC_ADD_S_ra_s_b_c, 3, true  },
  { ARC::ARC_SUB_a_b_c, ARC::ARC_SUB_S_b_c,      2, true  },
  { ARC::ARC_AND_a_b_c, ARC::ARC_AND_S_b_c,       2, true  },
  { ARC::ARC_OR_a_b_c,  ARC::ARC_OR_S_b_c,        2, true  },
  { ARC::ARC_XOR_a_b_c, ARC::ARC_XOR_S_b_c,       2, true  },

  // Shift instructions (b,b,c form) -- use _v1 variants (b,b,c)
  { ARC::ARC_ASL_a_b_c, ARC::ARC_ASL_S_b_c_v1,   2, true  },
  { ARC::ARC_ASR_a_b_c, ARC::ARC_ASR_S_b_c_v1,   2, true  },
  { ARC::ARC_LSR_a_b_c, ARC::ARC_LSR_S_b_c_v1,   2, true  },

  // ---- Real ISel-emitted GEN4 ALU opcodes ------------------------------
  // The entries above reference ARCompact-namespace opcodes that ISel never
  // produces. ISel lowers add/sub/and/or/xor to the *_rrr forms
  // (ArcBinaryGEN4Inst), whose operand layout is exactly
  //   (outs GPR32:$A), (ins GPR32:$B, GPR32:$C)  ==  [A(def), B(use), C(use)]
  // -- the same shape the DestEqSrc1 path already handles. Reduce them to the
  // identical 16-bit b,b,c encodings when A==B and all regs are in GPR_S.
  // (verified: ADD_S 0x6018, SUB_S 0x7802, AND_S 0x7804, OR_S 0x7805,
  //  XOR_S 0x7807 all encode rb_s[10:8]/rc_s[7:5] correctly and match the
  //  ARCompact 0x0F general-ops sub-opcode table.)
  { ARC::ADD_rrr, ARC::ARC_ADD_S_ra_s_b_c, 3, true },
  { ARC::SUB_rrr, ARC::ARC_SUB_S_b_c,      2, true },
  { ARC::AND_rrr, ARC::ARC_AND_S_b_c,      2, true },
  { ARC::OR_rrr,  ARC::ARC_OR_S_b_c,       2, true },
  { ARC::XOR_rrr, ARC::ARC_XOR_S_b_c,      2, true },
  // NOTE: shift reductions (ASL_rrr/ASR_rrr/LSR_rrr) are deliberately NOT
  // added. The 16-bit shift defs in ARCARCompactInstr16.td are buggy: the
  // operand-encoding variants ARC_{ASL,ASR,LSR}_S_b_c_v1 (sub-opcodes
  // 0x18/0x1A/0x19, the correct "B <- B SHIFT C" operation) do NOT bind
  // rb_s/rc_s to any instruction bits, so they assemble to a fixed r0,r0
  // encoding; the *_S_b_c forms that DO encode operands (0x1B/0x1C/0x1D) are
  // the "shift by one" sub-opcodes (B <- C+C etc.), a different operation.
  // Reducing shifts with either would silently miscompile (caught by the
  // test suite on a shift-by-register case). Leave shifts at 32-bit
  // until the .td shift encodings are fixed.

  // 2-operand: MOV_S, CMP_S  (b,c form -- any GPR32 for src is OK via ARC_MOV_S_b_h)
  // We use the reg-reg form which requires dest in GPR_S; src can be any reg.
  { ARC::ARC_MOV_b_c,   ARC::ARC_MOV_S_b_h,       1, false },
  { ARC::ARC_CMP_b_c,   ARC::ARC_CMP_S_b_h,       1, false },

  // Real ISel-emitted move-immediate. MOV_rs12 layout:
  //   (outs GPR32:$B), (ins immS<12>:$S12)  -- reg dest + signed-12 imm.
  // Reduced to the 2-byte MOV_S b,u8 when dest is in GPR_S and the immediate
  // fits an unsigned 8-bit field (0..255). Handled by a dedicated path in
  // tryReduce (the immediate operand needs special checking, not GPR_S).
  // This is the single largest reduction contributor (mov-imm is the most
  // common opcode ISel emits).
  { ARC::MOV_rs12,      ARC::ARC_MOV_S_b_u8,      1, false },
  // NOTE: the ISel reg-reg copy MOV_rr is deliberately NOT reduced to
  // ARC_MOV_S_b_h. That 16-bit "mov_s b,h" form mis-encodes the source
  // register (the 6-bit r6h field scatter produces the wrong source for high
  // GPRs), so reducing reg-reg moves silently copies the wrong register --
  // caught by the test suite (a value-returning move produced the wrong register instead of
  // the original pointer). Leave reg-reg moves at 32-bit until the r6h
  // encoding is fixed.

  // 1-operand (dest+src both in GPR_S): NOT_S, NEG_S
  { ARC::ARC_NOT_b_c,   ARC::ARC_NOT_S_b_c,        2, false },
  { ARC::ARC_NEG_a_b,   ARC::ARC_NEG_S_b_c,        2, false },
};

class ARCSizeReduction : public MachineFunctionPass {
public:
  static char ID;

  ARCSizeReduction() : MachineFunctionPass(ID) {
    initializeARCSizeReductionPass(*PassRegistry::getPassRegistry());
  }

  StringRef getPassName() const override {
    return "ARC 16-bit Size Reduction";
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  MachineFunctionProperties getRequiredProperties() const override {
    return MachineFunctionProperties().setNoVRegs();
  }

private:
  const TargetRegisterInfo *TRI = nullptr;
  const TargetInstrInfo *TII = nullptr;

  bool runOnMachineBasicBlock(MachineBasicBlock &MBB);
  bool tryReduce(MachineBasicBlock &MBB, MachineBasicBlock::iterator &MI,
                 const ReduceEntry &Entry);
};

char ARCSizeReduction::ID = 0;

} // end anonymous namespace

INITIALIZE_PASS(ARCSizeReduction, "arc-size-reduction",
                "ARC 16-bit Size Reduction", false, false)

/// Return true if \p Reg is in the GPR_S register class
/// (R0, R1, R2, R3, R12, R13, R14, R15).
static bool isGPR_S(Register Reg, const TargetRegisterInfo *TRI) {
  return ARC::GPR_SRegClass.contains(Reg);
}

bool ARCSizeReduction::runOnMachineFunction(MachineFunction &MF) {
  const ARCSubtarget &Subtarget = MF.getSubtarget<ARCSubtarget>();

  // Only run for ARCompact (ARC700). ARCv2 has no 16-bit compact instructions.
  if (!Subtarget.isARCompact())
    return false;

  // Only reduce when optimizing for size (-Os / -Oz).
  const Function &F = MF.getFunction();
  if (!F.hasOptSize() && !F.hasMinSize())
    return false;

  TII = Subtarget.getInstrInfo();
  TRI = Subtarget.getRegisterInfo();

  LLVM_DEBUG(dbgs() << "Running ARC Size Reduction on " << MF.getName() << "\n");

  bool Changed = false;
  for (MachineBasicBlock &MBB : MF)
    Changed |= runOnMachineBasicBlock(MBB);
  return Changed;
}

bool ARCSizeReduction::runOnMachineBasicBlock(MachineBasicBlock &MBB) {
  bool Changed = false;

  for (MachineBasicBlock::iterator I = MBB.begin(), E = MBB.end(); I != E;) {
    MachineBasicBlock::iterator MI = I++;

    // Skip debug instructions.
    if (MI->isDebugInstr())
      continue;

    unsigned Opc = MI->getOpcode();

    for (const ReduceEntry &Entry : ReduceTable) {
      if (Entry.WideOpc != Opc)
        continue;

      if (tryReduce(MBB, MI, Entry)) {
        Changed = true;
        // MI now points to the new (16-bit) instruction; I already advanced.
      }
      break; // Each opcode appears at most once in the table.
    }
  }

  return Changed;
}

bool ARCSizeReduction::tryReduce(MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator &MI,
                                  const ReduceEntry &Entry) {
  // Only consider instructions with no flag-setting (F bit == 0).
  // Flag-setting variants have different opcodes in 32-bit form; we only
  // reduce plain (non-.f) forms here.

  // Collect the first few register operands and check GPR_S membership.
  // Layout for the instructions we target:
  //   3-op (DestEqSrc1==true):  op[0]=RA(def), op[1]=RB(use), op[2]=RC(use)
  //   2-op (DestEqSrc1==false, NarrowNumRegs==2): op[0]=RB(def+use), op[1]=RC(use)
  //   MOV/CMP (NarrowNumRegs==1): op[0]=RB; src may be any GPR32
  //   NOT/NEG 2-op: op[0]=dest, op[1]=src -- both must be in GPR_S

  const MachineInstr &Old = *MI;
  unsigned NumOps = Old.getNumExplicitOperands();

  // Dedicated path: MOV_rs12 (reg <- signed-12 imm) -> MOV_S b,u8 (reg <- u8).
  // The 16-bit form only carries an unsigned 8-bit immediate and requires the
  // destination in GPR_S. Layout: op[0]=dest(reg), op[1]=imm.
  if (Entry.WideOpc == ARC::MOV_rs12) {
    if (NumOps < 2)
      return false;
    const MachineOperand &OpB = Old.getOperand(0); // dest
    const MachineOperand &OpImm = Old.getOperand(1); // signed-12 immediate
    if (!OpB.isReg() || !OpImm.isImm())
      return false;
    Register RB = OpB.getReg();
    int64_t Imm = OpImm.getImm();
    // Dest must be in the compact register set; immediate must fit u8 [0,255].
    if (!isGPR_S(RB, TRI) || Imm < 0 || Imm > 255)
      return false;

    LLVM_DEBUG(dbgs() << "  Reducing " << Old << " to 16-bit (MOV_S b,u8)\n");

    MachineInstrBuilder MIB =
        BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(Entry.NarrowOpc))
            .addReg(RB, RegState::Define)
            .addImm(Imm);

    for (unsigned i = 2, e = Old.getNumOperands(); i != e; ++i) {
      const MachineOperand &MO = Old.getOperand(i);
      if (MO.isImplicit())
        MIB.add(MO);
    }

    MI->eraseFromParent();
    ++NumReduced;
    return true;
  }

  if (Entry.DestEqSrc1) {
    // Pattern: A,B,C where we need A==B and all three in GPR_S.
    // For 32-bit ADD_a_b_c: operands are [RA(def), RB(use), RC(use)]
    if (NumOps < 3)
      return false;

    const MachineOperand &OpA = Old.getOperand(0); // dest
    const MachineOperand &OpB = Old.getOperand(1); // src1
    const MachineOperand &OpC = Old.getOperand(2); // src2

    if (!OpA.isReg() || !OpB.isReg() || !OpC.isReg())
      return false;

    Register RA = OpA.getReg();
    Register RB = OpB.getReg();
    Register RC = OpC.getReg();

    // Constraint: dest must equal first source for 16-bit b,b,c encoding.
    if (RA != RB)
      return false;

    // All three must be in GPR_S.
    if (!isGPR_S(RA, TRI) || !isGPR_S(RB, TRI) || !isGPR_S(RC, TRI))
      return false;

    LLVM_DEBUG(dbgs() << "  Reducing " << Old << " to 16-bit (3-op b,b,c)\n");

    // Build the 16-bit replacement.
    // ARC_ADD_S_ra_s_b_c: (outs GPR_S:$ra_s), (ins GPR_S:$rb_s, GPR_S:$rc_s)
    // ARC_*_S_b_c (2-op compact for sub/and/or/xor/shifts):
    //   (outs GPR_S:$rb_s), (ins GPR_S:$rc_s)  -- dest implicit == first src
    MachineInstrBuilder MIB;
    if (Entry.NarrowOpc == ARC::ARC_ADD_S_ra_s_b_c) {
      // ADD_S a,b,c — explicit 3-op form in TableGen
      MIB = BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(Entry.NarrowOpc))
                .addReg(RA, RegState::Define)
                .addReg(RB)
                .addReg(RC);
    } else {
      // All other DestEqSrc1 instructions: 2-operand compact (b,b,c encoded
      // as (outs rb), (ins rc) since dest==first-src is implicit in encoding).
      MIB = BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(Entry.NarrowOpc))
                .addReg(RA, RegState::Define)
                .addReg(RC);
    }

    // Copy implicit operands (e.g. kill flags).
    for (unsigned i = 3, e = Old.getNumOperands(); i != e; ++i) {
      const MachineOperand &MO = Old.getOperand(i);
      if (MO.isImplicit())
        MIB.add(MO);
    }

    MI->eraseFromParent();
    ++NumReduced;
    return true;
  }

  // Non-DestEqSrc1 cases.
  switch (Entry.NarrowNumRegs) {
  case 1: {
    // MOV_S b,h  and  CMP_S b,h
    // 32-bit: (outs GPR32:$rb), (ins GPR32:$rc)
    // 16-bit: (outs GPR_S:$rb_s), (ins GPR32:$r6h)  -- dest must be GPR_S
    if (NumOps < 2)
      return false;

    const MachineOperand &OpB = Old.getOperand(0);
    const MachineOperand &OpC = Old.getOperand(1);

    if (!OpB.isReg() || !OpC.isReg())
      return false;

    Register RB = OpB.getReg();
    Register RC = OpC.getReg();

    // Only dest needs to be in GPR_S; src can be any GPR32.
    if (!isGPR_S(RB, TRI))
      return false;

    LLVM_DEBUG(dbgs() << "  Reducing " << Old << " to 16-bit (MOV/CMP b,h)\n");

    MachineInstrBuilder MIB =
        BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(Entry.NarrowOpc))
            .addReg(RB, RegState::Define)
            .addReg(RC);

    for (unsigned i = 2, e = Old.getNumOperands(); i != e; ++i) {
      const MachineOperand &MO = Old.getOperand(i);
      if (MO.isImplicit())
        MIB.add(MO);
    }

    MI->eraseFromParent();
    ++NumReduced;
    return true;
  }

  case 2: {
    // NOT_S b,c  and  NEG_S b,c
    // 32-bit: (outs GPR32:$rb), (ins GPR32:$rc)
    // 16-bit: (outs GPR_S:$rb_s), (ins GPR_S:$rc_s)  -- both must be GPR_S
    if (NumOps < 2)
      return false;

    const MachineOperand &OpB = Old.getOperand(0);
    const MachineOperand &OpC = Old.getOperand(1);

    if (!OpB.isReg() || !OpC.isReg())
      return false;

    Register RB = OpB.getReg();
    Register RC = OpC.getReg();

    if (!isGPR_S(RB, TRI) || !isGPR_S(RC, TRI))
      return false;

    LLVM_DEBUG(dbgs() << "  Reducing " << Old << " to 16-bit (2-op b,c)\n");

    MachineInstrBuilder MIB =
        BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(Entry.NarrowOpc))
            .addReg(RB, RegState::Define)
            .addReg(RC);

    for (unsigned i = 2, e = Old.getNumOperands(); i != e; ++i) {
      const MachineOperand &MO = Old.getOperand(i);
      if (MO.isImplicit())
        MIB.add(MO);
    }

    MI->eraseFromParent();
    ++NumReduced;
    return true;
  }

  default:
    llvm_unreachable("Unexpected NarrowNumRegs value in ReduceTable");
  }
}

FunctionPass *llvm::createARCSizeReductionPass() {
  return new ARCSizeReduction();
}
