//===- ARCInstrInfo.cpp - ARC Instruction Information -----------*- C++ -*-===//
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

#include "ARCInstrInfo.h"
#include "ARC.h"
#include "ARCConstantMaterialization.h"
#include "ARCMachineFunctionInfo.h"
#include "ARCSubtarget.h"
#include "MCTargetDesc/ARCInfo.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "ARCGenInstrInfo.inc"

#define DEBUG_TYPE "arc-inst-info"

enum AddrIncType {
    NoAddInc = 0,
    PreInc   = 1,
    PostInc  = 2,
    Scaled   = 3
};

enum TSFlagsConstants {
    TSF_AddrModeOff = 0,
    TSF_AddModeMask = 3
};

// Pin the vtable to this file.
void ARCInstrInfo::anchor() {}

ARCInstrInfo::ARCInstrInfo(const ARCSubtarget &ST)
    : ARCGenInstrInfo(ST, RI, ARC::ADJCALLSTACKDOWN, ARC::ADJCALLSTACKUP),
      RI(ST) {}

static bool isZeroImm(const MachineOperand &Op) {
  return Op.isImm() && Op.getImm() == 0;
}

static bool isLoad(int Opcode) {
  return Opcode == ARC::LD_rs9 || Opcode == ARC::LDH_rs9 ||
         Opcode == ARC::LDB_rs9;
}

static bool isStore(int Opcode) {
  return Opcode == ARC::ST_rs9 || Opcode == ARC::STH_rs9 ||
         Opcode == ARC::STB_rs9;
}

/// If the specified machine instruction is a direct
/// load from a stack slot, return the virtual or physical register number of
/// the destination along with the FrameIndex of the loaded stack slot.  If
/// not, return 0.  This predicate must return 0 if the instruction has
/// any side effects other than loading from the stack slot.
Register ARCInstrInfo::isLoadFromStackSlot(const MachineInstr &MI,
                                           int &FrameIndex) const {
  int Opcode = MI.getOpcode();
  if (isLoad(Opcode)) {
    if ((MI.getOperand(1).isFI()) &&  // is a stack slot
        (MI.getOperand(2).isImm()) && // the imm is zero
        (isZeroImm(MI.getOperand(2)))) {
      FrameIndex = MI.getOperand(1).getIndex();
      return MI.getOperand(0).getReg();
    }
  }
  return 0;
}

/// If the specified machine instruction is a direct
/// store to a stack slot, return the virtual or physical register number of
/// the source reg along with the FrameIndex of the loaded stack slot.  If
/// not, return 0.  This predicate must return 0 if the instruction has
/// any side effects other than storing to the stack slot.
Register ARCInstrInfo::isStoreToStackSlot(const MachineInstr &MI,
                                          int &FrameIndex) const {
  int Opcode = MI.getOpcode();
  if (isStore(Opcode)) {
    if ((MI.getOperand(1).isFI()) &&  // is a stack slot
        (MI.getOperand(2).isImm()) && // the imm is zero
        (isZeroImm(MI.getOperand(2)))) {
      FrameIndex = MI.getOperand(1).getIndex();
      return MI.getOperand(0).getReg();
    }
  }
  return 0;
}

/// Return the inverse of passed condition, i.e. turning COND_E to COND_NE.
static ARCCC::CondCode getOppositeBranchCondition(ARCCC::CondCode CC) {
  switch (CC) {
  default:
    llvm_unreachable("Illegal condition code!");
  case ARCCC::EQ:
    return ARCCC::NE;
  case ARCCC::NE:
    return ARCCC::EQ;
  case ARCCC::LO:
    return ARCCC::HS;
  case ARCCC::HS:
    return ARCCC::LO;
  case ARCCC::GT:
    return ARCCC::LE;
  case ARCCC::GE:
    return ARCCC::LT;
  case ARCCC::VS:
    return ARCCC::VC;
  case ARCCC::VC:
    return ARCCC::VS;
  case ARCCC::LT:
    return ARCCC::GE;
  case ARCCC::LE:
    return ARCCC::GT;
  case ARCCC::HI:
    return ARCCC::LS;
  case ARCCC::LS:
    return ARCCC::HI;
  case ARCCC::NZ:
    return ARCCC::Z;
  case ARCCC::Z:
    return ARCCC::NZ;
  }
}

static bool isUncondBranchOpcode(int Opc) { return Opc == ARC::BR; }

// Conditional-branch terminators analyzeBranch understands. All three are
// SELF-CONTAINED pseudos: the whole compare -- operands and condition code --
// lives inside the one MI, and the flag producer it expands into is created by
// that same expansion, back-to-back with the branch, in addPreEmitPass
// (ARCBranchFinalize), which runs strictly AFTER branch-folder, tailduplication
// and block-placement. So at the time these callers run there is no separate
// flag producer to lose adjacency with, and moving/deleting/re-inserting the
// pseudo can never split a `cmp`/`sbc.f` from its `Bcc`.
//
// That property, not the opcode list, is the admission criterion. A branch that
// reads STATUS32 from a DIFFERENT, already-materialized instruction (the
// flag-recycling `<flag-op>.f`+`Bcc` fusions in ARCBranchFinalize.cpp, say)
// must stay OUT of this list: analyzeBranch cannot hand its producer back in
// Cond, so a caller could reorder the branch away from it or invert the test
// without inverting the producer. Those are deliberately fused late, after every
// CFG-shape-dependent pass has already run.
static bool isCondBranchOpcode(int Opc) {
  return Opc == ARC::BRcc_rr_p || Opc == ARC::BRcc_ru6_p ||
         Opc == ARC::BRCARRY_p;
}

/// Number of operands following the target block that make up a conditional
/// branch's condition -- what analyzeBranch copies into Cond and insertBranch
/// hands back to BuildMI. BRcc's condition is {B, C, cc}; BRCARRY_p's fused i64
/// compare is {ALo, BLo, AHi, BHi, cc}. The condition code is always the last
/// one, so reverseBranchCondition can invert either shape via Cond.back().
///
/// Cond is target-opaque -- TargetInstrInfo.h only requires "a list of operands
/// that evaluate the condition" and fixes no arity -- so carrying both shapes is
/// within the contract.
static unsigned getNumCondOperands(int Opc) {
  assert(isCondBranchOpcode(Opc) && "Not a conditional branch!");
  return Opc == ARC::BRCARRY_p ? 5 : 3;
}

static bool isJumpOpcode(int Opc) { return Opc == ARC::J; }

/// Analyze the branching code at the end of MBB, returning
/// true if it cannot be understood (e.g. it's a switch dispatch or isn't
/// implemented for a target).  Upon success, this returns false and returns
/// with the following information in various cases:
///
/// 1. If this block ends with no branches (it just falls through to its succ)
///    just return false, leaving TBB/FBB null.
/// 2. If this block ends with only an unconditional branch, it sets TBB to be
///    the destination block.
/// 3. If this block ends with a conditional branch and it falls through to a
///    successor block, it sets TBB to be the branch destination block and a
///    list of operands that evaluate the condition. These operands can be
///    passed to other TargetInstrInfo methods to create new branches.
/// 4. If this block ends with a conditional branch followed by an
///    unconditional branch, it returns the 'true' destination in TBB, the
///    'false' destination in FBB, and a list of operands that evaluate the
///    condition.  These operands can be passed to other TargetInstrInfo
///    methods to create new branches.
///
/// Note that RemoveBranch and insertBranch must be implemented to support
/// cases where this method returns success.
///
/// If AllowModify is true, then this routine is allowed to modify the basic
/// block (e.g. delete instructions after the unconditional branch).

bool ARCInstrInfo::analyzeBranch(MachineBasicBlock &MBB,
                                 MachineBasicBlock *&TBB,
                                 MachineBasicBlock *&FBB,
                                 SmallVectorImpl<MachineOperand> &Cond,
                                 bool AllowModify) const {
  TBB = FBB = nullptr;
  MachineBasicBlock::iterator I = MBB.end();
  if (I == MBB.begin())
    return false;
  --I;

  while (isPredicated(*I) || I->isTerminator() || I->isDebugValue()) {
    // Flag to be raised on unanalyzeable instructions. This is useful in cases
    // where we want to clean up on the end of the basic block before we bail
    // out.
    bool CantAnalyze = false;

    // Skip over DEBUG values and predicated nonterminators.
    while (I->isDebugInstr() || !I->isTerminator()) {
      if (I == MBB.begin())
        return false;
      --I;
    }

    if (isJumpOpcode(I->getOpcode())) {
      // Indirect branches and jump tables can't be analyzed, but we still want
      // to clean up any instructions at the tail of the basic block.
      CantAnalyze = true;
    } else if (isUncondBranchOpcode(I->getOpcode())) {
      TBB = I->getOperand(0).getMBB();
    } else if (isCondBranchOpcode(I->getOpcode())) {
      // Bail out if we encounter multiple conditional branches.
      if (!Cond.empty())
        return true;

      assert(!FBB && "FBB should have been null.");
      FBB = TBB;
      // Operand 0 is the target block; every explicit operand after it is the
      // condition. Any implicit STATUS32 def (BRCARRY_p has one) is left out --
      // BuildMI re-adds it from the MCInstrDesc when insertBranch rebuilds.
      TBB = I->getOperand(0).getMBB();
      for (unsigned i = 1, e = getNumCondOperands(I->getOpcode()); i <= e; ++i)
        Cond.push_back(I->getOperand(i));
    } else if (I->isReturn()) {
      // Returns can't be analyzed, but we should run cleanup.
      CantAnalyze = !isPredicated(*I);
    } else {
      // We encountered other unrecognized terminator. Bail out immediately.
      return true;
    }

    // Cleanup code - to be run for unpredicated unconditional branches and
    //                returns.
    if (!isPredicated(*I) && (isUncondBranchOpcode(I->getOpcode()) ||
                              isJumpOpcode(I->getOpcode()) || I->isReturn())) {
      // Forget any previous condition branch information - it no longer
      // applies.
      Cond.clear();
      FBB = nullptr;

      // If we can modify the function, delete everything below this
      // unconditional branch.
      if (AllowModify) {
        MachineBasicBlock::iterator DI = std::next(I);
        while (DI != MBB.end()) {
          MachineInstr &InstToDelete = *DI;
          ++DI;
          InstToDelete.eraseFromParent();
        }
      }
    }

    if (CantAnalyze)
      return true;

    if (I == MBB.begin())
      return false;

    --I;
  }

  // We made it past the terminators without bailing out - we must have
  // analyzed this branch successfully.
  return false;
}

unsigned ARCInstrInfo::removeBranch(MachineBasicBlock &MBB,
                                    int *BytesRemoved) const {
  assert(!BytesRemoved && "Code size not handled");
  MachineBasicBlock::iterator I = MBB.getLastNonDebugInstr();
  if (I == MBB.end())
    return 0;

  if (!isUncondBranchOpcode(I->getOpcode()) &&
      !isCondBranchOpcode(I->getOpcode()))
    return 0;

  // Remove the branch.
  I->eraseFromParent();

  I = MBB.end();

  if (I == MBB.begin())
    return 1;
  --I;
  if (!isCondBranchOpcode(I->getOpcode()))
    return 1;

  // Remove the branch.
  I->eraseFromParent();
  return 2;
}

void ARCInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                               MachineBasicBlock::iterator I,
                               const DebugLoc &DL, Register DestReg,
                               Register SrcReg, bool KillSrc,
                               bool RenamableDest, bool RenamableSrc) const {
  assert(ARC::GPR32RegClass.contains(SrcReg) &&
         "Only GPR32 src copy supported.");
  assert(ARC::GPR32RegClass.contains(DestReg) &&
         "Only GPR32 dest copy supported.");
  BuildMI(MBB, I, DL, get(ARC::MOV_rr), DestReg)
      .addReg(SrcReg, getKillRegState(KillSrc));
}

void ARCInstrInfo::storeRegToStackSlot(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator I, Register SrcReg,
    bool IsKill, int FrameIndex, const TargetRegisterClass *RC, Register VReg,
    MachineInstr::MIFlag Flags) const {
  DebugLoc DL = MBB.findDebugLoc(I);
  MachineFunction &MF = *MBB.getParent();
  MachineFrameInfo &MFI = MF.getFrameInfo();

  MachineMemOperand *MMO = MF.getMachineMemOperand(
      MachinePointerInfo::getFixedStack(MF, FrameIndex),
      MachineMemOperand::MOStore, MFI.getObjectSize(FrameIndex),
      MFI.getObjectAlign(FrameIndex));

  assert(MMO && "Couldn't get MachineMemOperand for store to stack.");
  assert(TRI.getSpillSize(*RC) == 4 &&
         "Only support 4-byte stores to stack now.");
  assert(ARC::GPR32RegClass.hasSubClassEq(RC) &&
         "Only support GPR32 stores to stack now.");
  LLVM_DEBUG(dbgs() << "Created store reg=" << printReg(SrcReg, &TRI)
                    << " to FrameIndex=" << FrameIndex << "\n");
  BuildMI(MBB, I, DL, get(ARC::ST_rs9))
      .addReg(SrcReg, getKillRegState(IsKill))
      .addFrameIndex(FrameIndex)
      .addImm(0)
      .addMemOperand(MMO);
}

void ARCInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator I,
                                        Register DestReg, int FrameIndex,
                                        const TargetRegisterClass *RC,
                                        Register VReg, unsigned SubReg,
                                        MachineInstr::MIFlag Flags) const {
  DebugLoc DL = MBB.findDebugLoc(I);
  MachineFunction &MF = *MBB.getParent();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  MachineMemOperand *MMO = MF.getMachineMemOperand(
      MachinePointerInfo::getFixedStack(MF, FrameIndex),
      MachineMemOperand::MOLoad, MFI.getObjectSize(FrameIndex),
      MFI.getObjectAlign(FrameIndex));

  assert(MMO && "Couldn't get MachineMemOperand for store to stack.");
  assert(TRI.getSpillSize(*RC) == 4 &&
         "Only support 4-byte loads from stack now.");
  assert(ARC::GPR32RegClass.hasSubClassEq(RC) &&
         "Only support GPR32 stores to stack now.");
  LLVM_DEBUG(dbgs() << "Created load reg=" << printReg(DestReg, &TRI)
                    << " from FrameIndex=" << FrameIndex << "\n");
  BuildMI(MBB, I, DL, get(ARC::LD_rs9))
      .addReg(DestReg, RegState::Define)
      .addFrameIndex(FrameIndex)
      .addImm(0)
      .addMemOperand(MMO);
}

/// Return the inverse opcode of the specified Branch instruction.
///
/// Both Cond shapes end in the condition code (see getNumCondOperands), so
/// inverting Cond.back() covers BRcc {B, C, cc} and BRCARRY_p
/// {ALo, BLo, AHi, BHi, cc} alike, and the operands are left untouched.
///
/// That is exact for BRCARRY_p, not merely convenient: its cc is LO or HS --
/// carry-set vs carry-clear -- and both read the SAME carry bit produced by the
/// same `cmp`/`sbc.f` over the same operands. Negating `a <u b` to `a >=u b` is
/// therefore purely a flip of the test, with nothing to swap and no producer to
/// re-derive. getOppositeBranchCondition already maps LO<->HS.
bool ARCInstrInfo::reverseBranchCondition(
    SmallVectorImpl<MachineOperand> &Cond) const {
  assert((Cond.size() == 3 || Cond.size() == 5) &&
         "Invalid ARC branch condition!");
  Cond.back().setImm(
      getOppositeBranchCondition((ARCCC::CondCode)Cond.back().getImm()));
  return false;
}

MachineBasicBlock::iterator
ARCInstrInfo::loadImmediate(MachineBasicBlock &MBB,
                            MachineBasicBlock::iterator MI, unsigned Reg,
                            uint64_t Value) const {
  DebugLoc DL = MBB.findDebugLoc(MI);
  if (isInt<12>(Value)) {
    return BuildMI(MBB, MI, DL, get(ARC::MOV_rs12), Reg)
        .addImm(Value)
        .getInstr();
  }
  llvm_unreachable("Need Arc long immediate instructions.");
}

unsigned ARCInstrInfo::insertBranch(MachineBasicBlock &MBB,
                                    MachineBasicBlock *TBB,
                                    MachineBasicBlock *FBB,
                                    ArrayRef<MachineOperand> Cond,
                                    const DebugLoc &DL, int *BytesAdded) const {
  assert(!BytesAdded && "Code size not handled.");

  // Shouldn't be a fall through.
  assert(TBB && "insertBranch must not be told to insert a fallthrough");
  // 0 = unconditional, 3 = BRcc {B, C, cc}, 5 = BRCARRY_p's fused i64 compare
  // {ALo, BLo, AHi, BHi, cc}. See getNumCondOperands.
  assert((Cond.size() == 0 || Cond.size() == 3 || Cond.size() == 5) &&
         "Invalid ARC branch condition!");

  if (Cond.empty()) {
    BuildMI(&MBB, DL, get(ARC::BR)).addMBB(TBB);
    return 1;
  }
  // The arity alone picks the opcode: only BRCARRY_p has a 5-operand
  // condition, and it rebuilds exactly what analyzeBranch took apart.
  int BccOpc;
  if (Cond.size() == 5)
    BccOpc = ARC::BRCARRY_p;
  else
    BccOpc = Cond[1].isImm() ? ARC::BRcc_ru6_p : ARC::BRcc_rr_p;
  MachineInstrBuilder MIB = BuildMI(&MBB, DL, get(BccOpc));
  MIB.addMBB(TBB);
  for (const MachineOperand &MO : Cond)
    MIB.add(MO);

  // One-way conditional branch.
  if (!FBB) {
    return 1;
  }

  // Two-way conditional branch.
  BuildMI(&MBB, DL, get(ARC::BR)).addMBB(FBB);
  return 2;
}

unsigned ARCInstrInfo::getInstSizeInBytes(const MachineInstr &MI) const {
  if (MI.isInlineAsm()) {
    const MachineFunction *MF = MI.getParent()->getParent();
    const char *AsmStr = MI.getOperand(0).getSymbolName();
    return getInlineAsmLength(AsmStr, *MF->getTarget().getMCAsmInfo());
  }
  return MI.getDesc().getSize();
}

// CONST32 recipe expansion (dossier 21 idea 4). Runs POST-register-
// allocation via the target-independent ExpandPostRAPseudos pass, which is
// what lets isReMaterializable actually do something: CONST32 has no
// register operands, so as long as it survives to the register allocator
// as a single pseudo, the allocator can choose to recompute a spilled
// value via this recipe instead of emitting a reload. Expanding any
// earlier (e.g. in the pre-RA ARCExpandPseudos pass) would turn it into
// ordinary instructions before that decision is ever made.
//
// synthesizeConst32() is a pure, memoized function of the raw immediate
// operand, so re-calling it here reproduces EXACTLY the recipe ISel found
// when it decided to emit CONST32 instead of MOV_rlimm -- the two call
// sites cannot disagree.
//
// By this point $dst is already a concrete physical register, and
// CONST32's TableGen def constrains it to the compact GPR_S class (R0-R3,
// R12-R15), so the seed instruction (`mov_s`, which can only address that
// 8-register subset) can target $dst directly. The chain is therefore
// self-contained -- no scratch register is created or needed.
bool ARCInstrInfo::expandPostRAPseudo(MachineInstr &MI) const {
  if (MI.getOpcode() != ARC::CONST32)
    return false;

  MachineBasicBlock &MBB = *MI.getParent();
  const MachineOperand &Dst = MI.getOperand(0);
  Register DstReg = Dst.getReg();
  uint32_t Imm = static_cast<uint32_t>(MI.getOperand(1).getImm());

  std::optional<Const32Recipe> R = synthesizeConst32(Imm);
  assert(R && "ARCInstrInfo::expandPostRAPseudo: CONST32 selected for a "
              "constant with no synthesizable recipe -- ISel/expand "
              "disagreement");

  // %DstReg<def>            = ARC_MOV_S_b_u8 Recipe.Seed
  // %DstReg<def> (redefine) = ASL_rru6 %DstReg, Recipe.Shift
  BuildMI(MBB, MI, MI.getDebugLoc(), get(ARC::ARC_MOV_S_b_u8), DstReg)
      .addImm(R->Seed);
  BuildMI(MBB, MI, MI.getDebugLoc(), get(ARC::ASL_rru6))
      .add(Dst)
      .addReg(DstReg)
      .addImm(R->Shift);
  MI.eraseFromParent();
  return true;
}

bool ARCInstrInfo::isPostIncrement(const MachineInstr &MI) const {
  const MCInstrDesc &MID = MI.getDesc();
  const uint64_t F = MID.TSFlags;
  return ((F >> TSF_AddrModeOff) & TSF_AddModeMask) == PostInc;
}

bool ARCInstrInfo::isPreIncrement(const MachineInstr &MI) const {
  const MCInstrDesc &MID = MI.getDesc();
  const uint64_t F = MID.TSFlags;
  return ((F >> TSF_AddrModeOff) & TSF_AddModeMask) == PreInc;
}

bool ARCInstrInfo::getBaseAndOffsetPosition(const MachineInstr &MI,
                                        unsigned &BasePos,
                                        unsigned &OffsetPos) const {
  if (!MI.mayLoad() && !MI.mayStore())
    return false;

  BasePos = 1;
  OffsetPos = 2;

  if (isPostIncrement(MI) || isPreIncrement(MI)) {
    BasePos++;
    OffsetPos++;
  }

  if (!MI.getOperand(BasePos).isReg() || !MI.getOperand(OffsetPos).isImm())
    return false;

  return true;
}

std::optional<unsigned> ARCInstrInfo::getDelayedOpcode(unsigned Opc) {
  switch (Opc) {
  default:
    // Everything not listed -- including the delayed forms themselves, so a
    // transfer is never converted twice, and including J_LImm / JL_LImm,
    // which carry long-immediate data and therefore have no delay slot at
    // all (ARCompact ISA, delay slots, rule 2).
    return std::nullopt;

  // N-bit family: same opcode, Inst{5} (N) 0 -> 1. Size is unchanged.
  case ARC::BR:         return ARC::BR_D;
  case ARC::Bcc:        return ARC::Bcc_D;
  case ARC::BRcc_rr:    return ARC::BRcc_rr_D;
  case ARC::BRcc_ru6:   return ARC::BRcc_ru6_D;
  case ARC::BL:         return ARC::BL_D;
  case ARC::TCB:        return ARC::TCB_D;
  case ARC::ARC_BBIT0_b_u6_s9_d: return ARC::ARC_BBIT0_b_u6_s9_delayed;
  case ARC::ARC_BBIT1_b_u6_s9_d: return ARC::ARC_BBIT1_b_u6_s9_delayed;

  // Sub-opcode family: .d is a distinct encoding, not a bit. Size unchanged.
  case ARC::J:          return ARC::J_D;   // 0x20200000 -> 0x20210000
  case ARC::JL:         return ARC::JL_D;  // 0x20220000 -> 0x20230000

  // 16-bit return. Highest-value target of the pass: every function ends in
  // one, and the delayed twin is also 2 bytes (0x7EE0 -> 0x7FE0), so the
  // conversion is size-neutral.
  case ARC::J_S_BLINK:  return ARC::J_S_BLINK_D;
  }
}

bool ARCInstrInfo::hasUnmodeledARCompactSideEffects(const MachineInstr &MI) {
  switch (MI.getOpcode()) {
  default:
    return false;
  // Auxiliary-register reads. AUX space contains clear-on-read and FIFO
  // registers, so an `lr` is neither repeatable nor reorderable against
  // another AUX access.
  case ARC::ARC_LR_b_c:
  case ARC::ARC_LR_z_c:
  case ARC::ARC_LR_b_u6:
  case ARC::ARC_LR_z_u6:
  case ARC::ARC_LR_b_s12:
  case ARC::ARC_LR_z_s12:
  case ARC::ARC_LR_b_limm:
  case ARC::ARC_LR_z_limm:
  // Auxiliary-register writes.
  case ARC::ARC_SR_b_c:
  case ARC::ARC_SR_b_u6:
  case ARC::ARC_SR_b_s12:
  case ARC::ARC_SR_limm_c:
  case ARC::ARC_SR_b_limm:
  case ARC::ARC_SR_limm_u6:
  case ARC::ARC_SR_limm_s12:
  case ARC::ARC_SR_limm:
  // Zero-overhead loop setup. LP_COUNT / LP_START / LP_END are not modelled
  // as registers, and the ISA requires >= 4 instruction *words* of
  // separation after an LP_COUNT write -- a constraint nothing here can
  // express, so the only safe rule is not to move across it.
  case ARC::ARC_LP_s13:
  case ARC::ARC_LP_u7_cc:
  // Zero-overhead loop formation pseudos (ARCLowOverheadLoops). They must be
  // immovable barriers so the delay-slot filler cannot raid the setup window or
  // sink the decrement into the back-branch's slot before the >=4-word
  // separation is measured; the decrement sitting immovable right before the
  // back-branch is also what keeps that branch a plain (non-delayed) BRcc the
  // finalize pass can recognize. Redundant with their explicit
  // `let hasSideEffects = 1`, listed here for the same defensive reason as the
  // LP setup forms above.
  case ARC::HWLOOP_START:
  case ARC::HWLOOP_DEC:
  // Traps.
  case ARC::ARC_TRAP0_0:
  case ARC::ARC_TRAP_S_u6:
    return true;
  }
}
