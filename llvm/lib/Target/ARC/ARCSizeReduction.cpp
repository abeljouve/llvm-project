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
///
/// CMP_rr / CMP_ru6 also appear here (as markers only -- see tryReduce's
/// dedicated `if (Entry.WideOpc == ARC::CMP_rr || ...)` path) because their
/// narrow descriptors are (outs), all-uses, and cannot be built by the
/// shared MOV/CMP "case 1" handler below, which marks operand 0 as a
/// Define -- correct for MOV_S, wrong for a compare.
static const ReduceEntry ReduceTable[] = {
  // 3-operand ALU: ADD_S / SUB_S / AND_S / OR_S / XOR_S (b,b,c form)
  // 32-bit: ARC_ADD_a_b_c  (outs ra), (ins rb, rc)  -- a==b checked at runtime
  { ARC::ARC_ADD_a_b_c, ARC::ARC_ADD_S_ra_s_b_c, 3, true  },
  { ARC::ARC_SUB_a_b_c, ARC::ARC_SUB_S_b_c,      2, true  },
  { ARC::ARC_AND_a_b_c, ARC::ARC_AND_S_b_c,       2, true  },
  { ARC::ARC_OR_a_b_c,  ARC::ARC_OR_S_b_c,        2, true  },
  { ARC::ARC_XOR_a_b_c, ARC::ARC_XOR_S_b_c,       2, true  },

  // NOTE: ARC_ASL_a_b_c / ARC_ASR_a_b_c / ARC_LSR_a_b_c (ARCompact-namespace
  // shift opcodes) are deliberately NOT listed here. Like ARC_ADD_a_b_c's
  // siblings above they are never selected by ISel (empty `[]` DAG Pattern
  // lists in ARCARCompactInstrALU.td) -- but unlike ADD/SUB/AND/OR/XOR, the
  // real ISel-emitted shift opcodes are handled below via ASL_rrr/ASR_rrr/
  // LSR_rrr, so keeping these dead rows around is pure redundant weight with
  // no live coverage they'd add. Removed for hygiene (dossier 05 quarantine).

  // ---- Real ISel-emitted GEN4/EXT5 ALU opcodes -------------------------
  // The entries above reference ARCompact-namespace opcodes that ISel never
  // produces. ISel lowers add/sub/and/or/xor/shifts to the *_rrr forms
  // (ArcBinaryGEN4Inst / ArcBinaryEXT5Inst), whose operand layout is exactly
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

  // Register-count shifts (B <- B SHIFT C). Previously blocked: the 16-bit
  // _v1 defs (sub-opcodes 0x18/0x19/0x1A, the real "B <- B SHIFT C"
  // operation per docs/isa/15-encoding-16bit.md Table 71) did not bind
  // rb_s/rc_s to any instruction bits, so the MC encoder emitted a fixed
  // r0,r0 encoding regardless of operands. Fixed in ARCARCompactInstr16.td
  // (dossier 05) -- byte-verified via the authoritative disassembler
  // (0x7DD8 -> `asl r13, r13, r14`). Same DestEqSrc1 b,b,c shape as
  // ADD_rrr/SUB_rrr/etc. above.
  { ARC::ASL_rrr, ARC::ARC_ASL_S_b_c_v1, 2, true },
  { ARC::ASR_rrr, ARC::ARC_ASR_S_b_c_v1, 2, true },
  { ARC::LSR_rrr, ARC::ARC_LSR_S_b_c_v1, 2, true },

  // Reg-reg move. MOV_rr layout: (outs GPR32:$B), (ins GPR32:$C) --
  // op[0]=dest(def), op[1]=src(use), identical shape the shared MOV/CMP
  // "case 1" handler already builds (`.addReg(RB,Define).addReg(RC)`).
  // Dest must be in GPR_S; src can be any GPR32 via the r6h field. Was
  // previously blocked by the r6h scatter bug (fixed in
  // ARCARCompactInstr16.td, dossier 05; byte-verified 0x74A9 ->
  // `mov r12, r13`).
  { ARC::MOV_rr, ARC::ARC_MOV_S_b_h, 1, false },

  // CMP_rr / CMP_ru6 -> CMP_S b,h / CMP_S b,u7. Markers only -- built by the
  // dedicated `if (Entry.WideOpc == ARC::CMP_rr || ...)` path in tryReduce,
  // not the generic switch (see the doc comment above ReduceTable). Was
  // previously blocked by both the r6h scatter bug and the CMP_S
  // operand-as-def bug; both fixed in ARCARCompactInstr16.td (dossier 05).
  { ARC::CMP_rr,  ARC::ARC_CMP_S_b_h,  1, false },
  { ARC::CMP_ru6, ARC::ARC_CMP_S_b_u7, 1, false },

  // Real ISel-emitted move-immediate. MOV_rs12 layout:
  //   (outs GPR32:$B), (ins immS<12>:$S12)  -- reg dest + signed-12 imm.
  // Reduced to the 2-byte MOV_S b,u8 when dest is in GPR_S and the immediate
  // fits an unsigned 8-bit field (0..255). Handled by a dedicated path in
  // tryReduce (the immediate operand needs special checking, not GPR_S).
  // This is the single largest reduction contributor (mov-imm is the most
  // common opcode ISel emits).
  { ARC::MOV_rs12,      ARC::ARC_MOV_S_b_u8,      1, false },

  // Real ISel-emitted add-immediate. ADD_rru6 layout:
  //   (outs GPR32:$A), (ins GPR32:$B, immU6:$U6)  -- op[0]=A(def),[1]=B(use),[2]=imm
  // Reduce to the 2-byte add_s b,b,u7 when A==B, A in GPR_S, and the immediate
  // fits u7 [0,127] (immU6 is 0..63, always fits). Handled by a dedicated path
  // in tryReduce (A==B + immediate check). add-imm is a very common ALU op.
  { ARC::ADD_rru6,      ARC::ARC_ADD_S_b_u7,      1, false },

  // SP-relative word load/store. ISel emits these as 3-operand forms:
  //   LD_rs9: $dst = LD_rs9 $base, imm   -> op[0]=dst(def), [1]=base, [2]=imm
  //   ST_rs9: ST_rs9 $val, $base, imm    -> op[0]=val(use), [1]=base, [2]=imm
  // When the base is SP, the value/dest reg is in GPR_S, and the byte offset
  // fits the 4-byte-aligned u7 field [0,124], reduce to the 2-byte
  // SP_LD_S / SP_ST_S (ld_s/st_s b3,[%sp,u7]). Handled by a dedicated path in
  // tryReduce (SP base + offset checks).
  { ARC::LD_rs9,        ARC::SP_LD_S,             1, false },
  { ARC::ST_rs9,        ARC::SP_ST_S,             1, false },

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
  bool tryReduceSextPair(MachineBasicBlock &MBB, MachineInstr &Asl,
                          MachineInstr &Asr);
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

    // Two-instruction fusion: ASL_rru6 immediately followed by ASR_rru6 ->
    // SEXB_S / SEXW_S. This is not expressible in the flat single-opcode
    // ReduceTable (2 MIs in, 1 MI out), so it is matched separately, before
    // the table dispatch below. It must run before `I` (already advanced
    // past MI) is relied on for the next loop iteration, because a
    // successful fusion also erases the instruction `I` currently points
    // to -- the caller must redirect `I` past both erased instructions.
    if (MI->getOpcode() == ARC::ASL_rru6 && I != E && !I->isDebugInstr() &&
        I->getOpcode() == ARC::ASR_rru6) {
      MachineBasicBlock::iterator AsrIt = I;
      MachineBasicBlock::iterator AfterAsr = std::next(AsrIt);
      if (tryReduceSextPair(MBB, *MI, *AsrIt)) {
        Changed = true;
        I = AfterAsr;
        continue;
      }
    }

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

/// Fuse the two-instruction sign-extend idiom the legalizer emits for
/// `sext_inreg i32,i8` / `i16` on ARC700 (there is no single-instruction
/// SEXB/SEXH -- ARCv2-only, gated off via !HasSEXT):
///   $r = ASL_rru6 $rin, Imm
///   $r = ASR_rru6 $r,   Imm     (Imm == 24 for byte, 16 for half)
/// into the compact `sexb_s` / `sexw_s`. ASL_rru6/ASR_rru6 (non-`.f`) carry
/// no implicit STATUS32 def, so the fusion is flag-neutral, matching
/// sexb_s/sexw_s's own "Flags: none".
bool ARCSizeReduction::tryReduceSextPair(MachineBasicBlock &MBB,
                                          MachineInstr &Asl,
                                          MachineInstr &Asr) {
  if (Asl.getNumExplicitOperands() < 3 || Asr.getNumExplicitOperands() < 3)
    return false;

  const MachineOperand &AslDst = Asl.getOperand(0);
  const MachineOperand &AslSrc = Asl.getOperand(1);
  const MachineOperand &AslImm = Asl.getOperand(2);
  const MachineOperand &AsrDst = Asr.getOperand(0);
  const MachineOperand &AsrSrc = Asr.getOperand(1);
  const MachineOperand &AsrImm = Asr.getOperand(2);

  if (!AslDst.isReg() || !AslSrc.isReg() || !AslImm.isImm() ||
      !AsrDst.isReg() || !AsrSrc.isReg() || !AsrImm.isImm())
    return false;

  // Same shift amount on both halves, and it must be a byte (24) or
  // halfword (16) sign-extend -- any other amount is not this idiom.
  int64_t Imm = AslImm.getImm();
  if (Imm != AsrImm.getImm() || (Imm != 16 && Imm != 24))
    return false;

  Register AslD = AslDst.getReg();
  Register AsrS = AsrSrc.getReg();
  Register AsrD = AsrDst.getReg();

  // The ASR must consume exactly the value the ASL just produced, shifting
  // it back in place: the same physical register threads through both
  // halves (ASL's dest == ASR's src == ASR's dest).
  if (AslD != AsrS || AslD != AsrD)
    return false;

  // The intermediate shifted-left-only value must have no other observers:
  // require the ASR's read of it to be a kill. Post-RA there is no use-list
  // to walk, so a kill flag is the only available signal that nothing else
  // reads the intermediate value; without it, fusing could silently drop a
  // write another instruction still depends on. If the flag is conservatively
  // unset the fusion simply does not fire (safe, just misses the size win).
  if (!AsrSrc.isKill())
    return false;

  Register RIn = AslSrc.getReg();
  Register ROut = AslD; // == AsrD
  if (!isGPR_S(RIn, TRI) || !isGPR_S(ROut, TRI))
    return false;

  unsigned NarrowOpc = (Imm == 24) ? ARC::ARC_SEXB_S_b_c : ARC::ARC_SEXW_S_b_c;

  LLVM_DEBUG(dbgs() << "  Fusing " << Asl << "  + " << Asr
                     << "    into 16-bit sext\n");

  MachineInstrBuilder MIB =
      BuildMI(MBB, Asl.getIterator(), Asl.getDebugLoc(), TII->get(NarrowOpc))
          .addReg(ROut, RegState::Define | getDeadRegState(AsrDst.isDead()))
          .addReg(RIn, getKillRegState(AslSrc.isKill()));

  // Carry over any additional implicit operands from either half. Neither
  // ASL_rru6 nor ASR_rru6 (non-.f) declares implicit defs, so this is
  // normally a no-op; kept for robustness against future descriptor changes.
  for (unsigned i = 3, e = Asl.getNumOperands(); i != e; ++i) {
    const MachineOperand &MO = Asl.getOperand(i);
    if (MO.isImplicit())
      MIB.add(MO);
  }
  for (unsigned i = 3, e = Asr.getNumOperands(); i != e; ++i) {
    const MachineOperand &MO = Asr.getOperand(i);
    if (MO.isImplicit())
      MIB.add(MO);
  }

  Asr.eraseFromParent();
  Asl.eraseFromParent();
  ++NumReduced;
  return true;
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

  // Dedicated path: CMP_rr / CMP_ru6 (compare, no destination) -> CMP_S b,h
  // / CMP_S b,u7. `cmp` never writes a GPR: both the wide and (now-fixed)
  // narrow descriptors are (outs), all operands are uses, and STATUS32 is
  // defined implicitly via each MCInstrDesc's `Defs = [STATUS32]` -- BuildMI
  // auto-populates that implicit-def when constructing the narrow MI, so it
  // must NOT also be copied from Old (that would duplicate the def).
  // Layout: op[0]=B(use, must be GPR_S), op[1]=C(use, any GPR32) / u6 imm.
  if (Entry.WideOpc == ARC::CMP_rr || Entry.WideOpc == ARC::CMP_ru6) {
    if (NumOps < 2)
      return false;
    const MachineOperand &OpB = Old.getOperand(0);
    const MachineOperand &OpC = Old.getOperand(1);
    if (!OpB.isReg())
      return false;
    Register RB = OpB.getReg();
    if (!isGPR_S(RB, TRI))
      return false;

    MachineInstrBuilder MIB;
    if (Entry.WideOpc == ARC::CMP_rr) {
      if (!OpC.isReg())
        return false;
      LLVM_DEBUG(dbgs() << "  Reducing " << Old << " to 16-bit (cmp_s b,h)\n");
      MIB = BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(ARC::ARC_CMP_S_b_h))
                .addReg(RB, getKillRegState(OpB.isKill()))
                .addReg(OpC.getReg(), getKillRegState(OpC.isKill()));
    } else {
      if (!OpC.isImm())
        return false;
      int64_t Imm = OpC.getImm();
      // immU6 (the only pattern that selects CMP_ru6) is always 0..63,
      // which always fits the target's u7 [0,127] field; the explicit
      // range check mirrors the same defensive check used for ADD_rru6
      // below rather than trusting the ISel-side invariant blindly.
      if (Imm < 0 || Imm > 127)
        return false;
      LLVM_DEBUG(dbgs() << "  Reducing " << Old << " to 16-bit (cmp_s b,u7)\n");
      MIB = BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(ARC::ARC_CMP_S_b_u7))
                .addReg(RB, getKillRegState(OpB.isKill()))
                .addImm(Imm);
    }

    MI->eraseFromParent();
    ++NumReduced;
    return true;
  }

  // Dedicated path: SP-relative word load/store -> 2-byte SP_LD_S / SP_ST_S.
  //   LD_rs9: op[0]=dst(def),  op[1]=base(use), op[2]=imm offset
  //   ST_rs9: op[0]=val(use),  op[1]=base(use), op[2]=imm offset
  // Reduce only when base == SP, the value/dest reg is in GPR_S, and the byte
  // offset fits the 4-byte-aligned u7 field [0,124]. The compact forms encode
  // [%sp, u7]; SP is implicit.
  if (Entry.WideOpc == ARC::LD_rs9 || Entry.WideOpc == ARC::ST_rs9) {
    if (NumOps < 3)
      return false;
    const bool IsLoad = (Entry.WideOpc == ARC::LD_rs9);
    const MachineOperand &OpVal = Old.getOperand(0);   // dst (load) / val (store)
    const MachineOperand &OpBase = Old.getOperand(1);  // base register
    const MachineOperand &OpOff = Old.getOperand(2);   // byte offset
    if (!OpVal.isReg() || !OpBase.isReg() || !OpOff.isImm())
      return false;
    Register RVal = OpVal.getReg();
    Register RBase = OpBase.getReg();
    int64_t Off = OpOff.getImm();
    // Base must be SP; value/dest reg in the compact set; offset 4-byte-aligned
    // within [0,124].
    if (RBase != ARC::SP || !isGPR_S(RVal, TRI) || Off < 0 || Off > 124 ||
        (Off & 0x3) != 0)
      return false;

    LLVM_DEBUG(dbgs() << "  Reducing " << Old << " to 16-bit (SP_"
                      << (IsLoad ? "LD" : "ST") << "_S)\n");

    MachineInstrBuilder MIB;
    if (IsLoad) {
      // SP_LD_S: (outs GPR32Reduced:$b3), (ins immU<7>:$u7)  -- ld_s b3,[%sp,u7]
      MIB = BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(ARC::SP_LD_S))
                .addReg(RVal, getDefRegState(true) |
                                  getDeadRegState(OpVal.isDead()))
                .addImm(Off);
    } else {
      // SP_ST_S: (outs), (ins GPR32Reduced:$b3, immU<7>:$u7) -- st_s b3,[%sp,u7]
      MIB = BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(ARC::SP_ST_S))
                .addReg(RVal, getKillRegState(OpVal.isKill()))
                .addImm(Off);
    }
    // SP is implicit in the compact form -- model the SP use for liveness.
    MIB.addReg(ARC::SP, RegState::Implicit);
    // Carry over the memory operand so alias analysis / scheduling stay correct.
    for (const MachineMemOperand *MMO : Old.memoperands())
      MIB.addMemOperand(const_cast<MachineMemOperand *>(MMO));

    MI->eraseFromParent();
    ++NumReduced;
    return true;
  }

  // Dedicated path: ADD_rru6 (A <- B + u6) -> add_s b,b,u7 (B <- B + u7).
  // The 16-bit form ties dest==src1, so reduce only when A==B. Layout:
  //   op[0]=A(def), op[1]=B(use), op[2]=imm.
  if (Entry.WideOpc == ARC::ADD_rru6) {
    if (NumOps < 3)
      return false;
    const MachineOperand &OpA = Old.getOperand(0);   // dest
    const MachineOperand &OpB = Old.getOperand(1);   // src1
    const MachineOperand &OpImm = Old.getOperand(2); // u6 immediate
    if (!OpA.isReg() || !OpB.isReg() || !OpImm.isImm())
      return false;
    Register RA = OpA.getReg();
    Register RB = OpB.getReg();
    int64_t Imm = OpImm.getImm();
    if (RA != RB || !isGPR_S(RA, TRI) || Imm < 0 || Imm > 127)
      return false;

    LLVM_DEBUG(dbgs() << "  Reducing " << Old << " to 16-bit (add_s b,b,u7)\n");

    MachineInstrBuilder MIB =
        BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(ARC::ARC_ADD_S_b_u7))
            .addReg(RA, RegState::Define)
            .addImm(Imm);
    for (unsigned i = 3, e = Old.getNumOperands(); i != e; ++i) {
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
                .addReg(RA, RegState::Define | getDeadRegState(OpA.isDead()))
                .addReg(RB, getKillRegState(OpB.isKill()))
                .addReg(RC, getKillRegState(OpC.isKill()));
    } else {
      // All other DestEqSrc1 instructions: 2-operand compact (b,b,c encoded
      // as (outs rb), (ins rc) since dest==first-src is implicit in encoding).
      // RB (src1) is the same physical register as RA (dest) here -- its own
      // kill state is moot, the def below ends that register's live range
      // regardless of any flag on the now-erased wide instruction's src1.
      MIB = BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(Entry.NarrowOpc))
                .addReg(RA, RegState::Define | getDeadRegState(OpA.isDead()))
                .addReg(RC, getKillRegState(OpC.isKill()));
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
    // MOV_S b,h (reg-reg move; CMP_rr/CMP_ru6 are intercepted by the
    // dedicated path above -- CMP's $rb_s is a use, not a def, so it cannot
    // share this Define-based build).
    // 32-bit MOV_rr: (outs GPR32:$B), (ins GPR32:$C)
    // 16-bit ARC_MOV_S_b_h: (outs GPR_S:$rb_s), (ins GPR32:$r6h)  -- dest
    // must be GPR_S; src can be any GPR32 via the r6h field.
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

    LLVM_DEBUG(dbgs() << "  Reducing " << Old << " to 16-bit (mov_s b,h)\n");

    MachineInstrBuilder MIB =
        BuildMI(MBB, MI, MI->getDebugLoc(), TII->get(Entry.NarrowOpc))
            .addReg(RB, RegState::Define | getDeadRegState(OpB.isDead()))
            .addReg(RC, getKillRegState(OpC.isKill()));

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
