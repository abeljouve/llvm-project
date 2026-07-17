//===- ARCExpandPseudosPass - ARC expand pseudo loads -----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass expands stores with large offsets into an appropriate sequence.
//===----------------------------------------------------------------------===//

#include "ARC.h"
#include "ARCInstrInfo.h"
#include "ARCRegisterInfo.h"
#include "ARCSubtarget.h"
#include "MCTargetDesc/ARCInfo.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"

using namespace llvm;

#define DEBUG_TYPE "arc-expand-pseudos"

namespace {

class ARCExpandPseudos : public MachineFunctionPass {
public:
  static char ID;
  ARCExpandPseudos() : MachineFunctionPass(ID) {}

  bool runOnMachineFunction(MachineFunction &Fn) override;

  StringRef getPassName() const override { return "ARC Expand Pseudos"; }

private:
  void expandStore(MachineFunction &, MachineBasicBlock::iterator);
  void expandCTLZ(MachineFunction &, MachineBasicBlock::iterator);
  void expandCTTZ(MachineFunction &, MachineBasicBlock::iterator);
  void expandLR(MachineFunction &, MachineBasicBlock::iterator);
  void expandLRImm(MachineFunction &, MachineBasicBlock::iterator);
  void expandSR(MachineFunction &, MachineBasicBlock::iterator);
  void expandSRImm(MachineFunction &, MachineBasicBlock::iterator);
  // Carry/overflow-consuming arithmetic idioms -- docs/llvm-arc700-
  // optimizations/19-flag-consuming-arithmetic-idioms.md. Each expansion
  // keeps the `.f`-form STATUS32 producer immediately adjacent to its
  // conditional-mov (or, for AVGFLOORU, rrc) consumer (nothing else is
  // inserted between the two final BuildMI calls), the same atomicity
  // CTLZ/CTTZ above rely on. SADDSAT/SSUBSAT's data-dependent clamp-limit
  // construction runs entirely BEFORE the producer (see the comment above
  // expandSADDSAT), so it never sits between a producer and its consumer.
  void expandUADDSAT(MachineFunction &, MachineBasicBlock::iterator);
  void expandUSUBSAT(MachineFunction &, MachineBasicBlock::iterator);
  void expandUADDO(MachineFunction &, MachineBasicBlock::iterator);
  void expandUSUBO(MachineFunction &, MachineBasicBlock::iterator);
  void expandSADDSAT(MachineFunction &, MachineBasicBlock::iterator);
  void expandSSUBSAT(MachineFunction &, MachineBasicBlock::iterator);
  void expandSADDO(MachineFunction &, MachineBasicBlock::iterator);
  void expandSSUBO(MachineFunction &, MachineBasicBlock::iterator);
  void expandAVGFLOORU(MachineFunction &, MachineBasicBlock::iterator);
  // Fused i64 compare, value form (dossier 23 Phase 1,
  // docs/llvm-arc700-optimizations/23-conditional-compare-chaining.md). Same
  // adjacency requirement as the idioms above, with one extra link: here the
  // STATUS32 chain is three instructions long -- `cmp` produces the low
  // borrow, `sbc.f` both CONSUMES and re-produces it, and `mov.$cc` consumes
  // the final value.
  void expandSETCCCARRY(MachineFunction &, MachineBasicBlock::iterator);
  // Carry-chain fusions (dossier 24, docs/llvm-arc700-optimizations/24-
  // carry-chain-and-bit-serial-idioms.md): i64<<1 and one bit-reverse step.
  // Same atomicity requirement as the carry-consuming idioms above -- the
  // `.f`-form ASL/LSR producer and its RLC consumer must land MBB-adjacent
  // with nothing else built between the two BuildMI calls.
  void expandSHL64_1(MachineFunction &, MachineBasicBlock::iterator);
  void expandBitRevStep(MachineFunction &, MachineBasicBlock::iterator);
  // NOTE: CONST32 (dossier 21 idea 4, docs/llvm-arc700-optimizations/21-*.md)
  // is deliberately NOT expanded here. This pass runs pre-register-
  // allocation (see ARCTargetMachine.cpp's addPreRegAlloc), so expanding
  // CONST32 here would turn it into ordinary instructions before the
  // register allocator ever sees it as a single register-free-input
  // pseudo, which silently defeats isReMaterializable (a spilled constant
  // gets a load-use reload instead of being recomputed). CONST32 is
  // expanded POST-register-allocation instead, by
  // ARCInstrInfo::expandPostRAPseudo (ARCInstrInfo.cpp), which runs after
  // isReMaterializable-driven rematerialization decisions have already
  // been made.
  const ARCInstrInfo *TII;
};

char ARCExpandPseudos::ID = 0;

} // end anonymous namespace

static unsigned getMappedOp(unsigned PseudoOp) {
  switch (PseudoOp) {
  case ARC::ST_FAR:
    return ARC::ST_rs9;
  case ARC::STH_FAR:
    return ARC::STH_rs9;
  case ARC::STB_FAR:
    return ARC::STB_rs9;
  default:
    llvm_unreachable("Unhandled pseudo op.");
  }
}

void ARCExpandPseudos::expandStore(MachineFunction &MF,
                                   MachineBasicBlock::iterator SII) {
  MachineInstr &SI = *SII;
  Register AddrReg = MF.getRegInfo().createVirtualRegister(&ARC::GPR32RegClass);
  Register AddOpc =
      isUInt<6>(SI.getOperand(2).getImm()) ? ARC::ADD_rru6 : ARC::ADD_rrlimm;
  BuildMI(*SI.getParent(), SI, SI.getDebugLoc(), TII->get(AddOpc), AddrReg)
      .addReg(SI.getOperand(1).getReg())
      .addImm(SI.getOperand(2).getImm());
  BuildMI(*SI.getParent(), SI, SI.getDebugLoc(),
          TII->get(getMappedOp(SI.getOpcode())))
      .addReg(SI.getOperand(0).getReg())
      .addReg(AddrReg)
      .addImm(0);
  SI.eraseFromParent();
}

void ARCExpandPseudos::expandCTLZ(MachineFunction &MF,
                                  MachineBasicBlock::iterator MII) {
  // Expand:
  //	%R2<def> = CTLZ %R0, %STATUS<imp-def>
  // To:
  //	%R2<def> = FLS_f_rr %R0, %STATUS<imp-def>
  //	%R2<def,tied1> = MOV_cc_ru6 %R2<tied0>, 32, pred:1, %STATUS<imp-use>
  //	%R2<def,tied1> = RSUB_cc_rru6 %R2<tied0>, 31, pred:2, %STATUS<imp-use>
  MachineInstr &MI = *MII;
  const MachineOperand &Dest = MI.getOperand(0);
  const MachineOperand &Src = MI.getOperand(1);
  Register Ra = MF.getRegInfo().createVirtualRegister(&ARC::GPR32RegClass);
  Register Rb = MF.getRegInfo().createVirtualRegister(&ARC::GPR32RegClass);

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::FLS_f_rr), Ra)
      .add(Src);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_cc_ru6), Rb)
      .addImm(32)
      .addImm(ARCCC::EQ)
      .addReg(Ra);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::RSUB_cc_rru6))
      .add(Dest)
      .addImm(31)
      .addImm(ARCCC::NE)
      .addReg(Rb);

  MI.eraseFromParent();
}

void ARCExpandPseudos::expandCTTZ(MachineFunction &MF,
                                  MachineBasicBlock::iterator MII) {
  // Expand:
  //	%R0<def> = CTTZ %R0<kill>, %STATUS<imp-def>
  // To:
  //	%R0<def> = FFS_f_rr %R0<kill>, %STATUS<imp-def>
  //	%R0<def,tied1> = MOVcc_ru6 %R0<tied0>, 32, pred:1, %STATUS<imp-use>
  MachineInstr &MI = *MII;
  const MachineOperand &Dest = MI.getOperand(0);
  const MachineOperand &Src = MI.getOperand(1);
  Register R = MF.getRegInfo().createVirtualRegister(&ARC::GPR32RegClass);

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::FFS_f_rr), R)
      .add(Src);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_cc_ru6))
      .add(Dest)
      .addImm(32)
      .addImm(ARCCC::EQ)
      .addReg(R);

  MI.eraseFromParent();
}

// Carry polarity (silicon/vendor-manual-verified: ARCompact ISA Programmer's
// Reference, Table 50, and the explicit SUB/SBC text "If the carry flag is
// set upon performing the subtract, the carry flag should be interpreted as
// a 'borrow'"; cross-checked against the emulator's alu.rs ALU model, which
// implements the identical polarity). This is the OPPOSITE of the
// "ARM-style, C=1=no-borrow" assumption that appears in some design notes --
// that assumption is WRONG for ARCompact and produced a real, empirically
// confirmed bug here (see below). ARCCC (MCTargetDesc/ARCInfo.h) names
// value 0x5 "LO" (vendor synonyms: CS, C -- tests raw STATUS32.C, fires
// when C=1) and value 0x6 "HS" (vendor synonyms: CC, NC -- tests /C, fires
// when C=0).
//
// The raw C bit's MEANING is producer-dependent:
//   - SUB.f: C=1 means borrow (a<b unsigned). Table 50 confirms this
//     directly: 0x5 "LO ... lower than (unsigned)" tests raw C, so testing
//     C=1 IS "a<b"; 0x6 "HS ... higher or same (unsigned)" tests /C, so
//     testing C=0 IS "a>=b". USUBSAT/USUBO key off a SUB.f producer, so
//     LO<->"a<b, borrow" holds exactly as named: USUBSAT/USUBO select on LO
//     (a<b/borrow).
//   - ADD.f: C=1 means plain unsigned carry-out/overflow -- unambiguous,
//     no "borrow" reinterpretation applies (that vendor text is specific to
//     SUB/SBC). To select "did this add overflow" you must test raw C=1,
//     i.e. LO (0x5) -- NOT HS. Using HS here (as an earlier version of this
//     file did) tests /C and fires on NO overflow: it is the exact inverse
//     of the intended behavior. Empirically confirmed on the arc700
//     emulator: with the (former, buggy) HS-based expansion,
//     uaddsat32(0xFFFFFFFF, 1) returned 0x00000000 instead of the correct
//     saturated 0xFFFFFFFF, and uaddsat32(1, 2) spuriously returned
//     0xFFFFFFFF instead of 3 -- i.e. every input was wrong. UADDSAT and
//     UADDO (both ADD.f-producer consumers) select on LO (C=1, overflow).
void ARCExpandPseudos::expandUADDSAT(MachineFunction &MF,
                                     MachineBasicBlock::iterator MII) {
  // Expand:
  //   %Dst<def> = UADDSAT_PSEUDO %A, %B, %STATUS<imp-def>
  // To:
  //   %Sum<def> = ADD_f_rrr %A, %B, %STATUS<imp-def>
  //   %NegOne<def> = MOV_rs12 -1
  //   %Dst<def,tied1> = MOV_cc %NegOne, %Sum<tied0>, lo, %STATUS<imp-use>
  MachineInstr &MI = *MII;
  const MachineOperand &Dst = MI.getOperand(0);
  const MachineOperand &A = MI.getOperand(1);
  const MachineOperand &B = MI.getOperand(2);
  MachineRegisterInfo &MRI = MF.getRegInfo();
  Register SumReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);
  Register NegOneReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);

  // sum = a+b; C=1 (LO tests raw C) iff unsigned carry-out (the add
  // wrapped). See the polarity comment above expandUADDSAT: ADD.f's C is a
  // plain carry-out, so "did it overflow" is tested by LO (raw C=1), not
  // HS (which tests /C and fires on NO overflow).
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ADD_f_rrr),
         SumReg)
      .add(A)
      .add(B);
  // -1 does not fit MOV_cc_ru6's u6 window (0..63) and ARCompact has no
  // conditional-s12/limm DOP form, so the clamp value is pre-materialized
  // unconditionally (does not touch STATUS32).
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_rs12),
         NegOneReg)
      .addImm(-1);
  // Dst = LO(carry set, i.e. raw C=1, unsigned add overflow) ? -1 : sum.
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_cc))
      .add(Dst)
      .addReg(NegOneReg)
      .addReg(SumReg)
      .addImm(ARCCC::LO);
  MI.eraseFromParent();
}

void ARCExpandPseudos::expandUSUBSAT(MachineFunction &MF,
                                     MachineBasicBlock::iterator MII) {
  // Expand:
  //   %Dst<def> = USUBSAT_PSEUDO %A, %B, %STATUS<imp-def>
  // To:
  //   %Diff<def> = SUB_f_rrr %A, %B, %STATUS<imp-def>
  //   %Dst<def,tied1> = MOV_cc_ru6 0, lo, %Diff<tied0>, %STATUS<imp-use>
  MachineInstr &MI = *MII;
  const MachineOperand &Dst = MI.getOperand(0);
  const MachineOperand &A = MI.getOperand(1);
  const MachineOperand &B = MI.getOperand(2);
  MachineRegisterInfo &MRI = MF.getRegInfo();
  Register DiffReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);

  // diff = a-b; C=0 (LO) iff borrow (a<b).
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::SUB_f_rrr),
         DiffReg)
      .add(A)
      .add(B);
  // Clamp value 0 fits u6 directly -- no extra materialization instruction.
  // Dst = LO(carry clear, borrow) ? 0 : diff.
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_cc_ru6))
      .add(Dst)
      .addImm(0)
      .addImm(ARCCC::LO)
      .addReg(DiffReg);
  MI.eraseFromParent();
}

void ARCExpandPseudos::expandUADDO(MachineFunction &MF,
                                   MachineBasicBlock::iterator MII) {
  // Expand:
  //   %Sum<def>, %Ovf<def> = UADDO_PSEUDO %A, %B, %STATUS<imp-def>
  // To:
  //   %Sum<def> = ADD_f_rrr %A, %B, %STATUS<imp-def>
  //   %Zero<def> = MOV_ru6 0
  //   %Ovf<def,tied1> = MOV_cc_ru6 1, lo, %Zero<tied0>, %STATUS<imp-use>
  MachineInstr &MI = *MII;
  const MachineOperand &SumDst = MI.getOperand(0);
  const MachineOperand &OvfDst = MI.getOperand(1);
  const MachineOperand &A = MI.getOperand(2);
  const MachineOperand &B = MI.getOperand(3);
  MachineRegisterInfo &MRI = MF.getRegInfo();
  Register ZeroReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ADD_f_rrr))
      .add(SumDst)
      .add(A)
      .add(B);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_ru6),
         ZeroReg)
      .addImm(0);
  // Ovf = LO(carry set, i.e. raw C=1, unsigned add overflow) ? 1 : 0. See
  // the polarity comment above expandUADDSAT: ADD.f's C is a plain
  // carry-out, tested by raw-C-true (LO), not by HS (which tests /C).
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_cc_ru6))
      .add(OvfDst)
      .addImm(1)
      .addImm(ARCCC::LO)
      .addReg(ZeroReg);
  MI.eraseFromParent();
}

void ARCExpandPseudos::expandUSUBO(MachineFunction &MF,
                                   MachineBasicBlock::iterator MII) {
  // Expand:
  //   %Diff<def>, %Ovf<def> = USUBO_PSEUDO %A, %B, %STATUS<imp-def>
  // To:
  //   %Diff<def> = SUB_f_rrr %A, %B, %STATUS<imp-def>
  //   %Zero<def> = MOV_ru6 0
  //   %Ovf<def,tied1> = MOV_cc_ru6 1, lo, %Zero<tied0>, %STATUS<imp-use>
  MachineInstr &MI = *MII;
  const MachineOperand &DiffDst = MI.getOperand(0);
  const MachineOperand &OvfDst = MI.getOperand(1);
  const MachineOperand &A = MI.getOperand(2);
  const MachineOperand &B = MI.getOperand(3);
  MachineRegisterInfo &MRI = MF.getRegInfo();
  Register ZeroReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::SUB_f_rrr))
      .add(DiffDst)
      .add(A)
      .add(B);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_ru6),
         ZeroReg)
      .addImm(0);
  // Ovf = LO(carry clear, borrow, unsigned sub overflow) ? 1 : 0.
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_cc_ru6))
      .add(OvfDst)
      .addImm(1)
      .addImm(ARCCC::LO)
      .addReg(ZeroReg);
  MI.eraseFromParent();
}

// Fused i64 compare, value form -- dossier 23 Phase 1. See
// docs/llvm-arc700-optimizations/23-conditional-compare-chaining.md and the
// carry-polarity block above ARCTargetLowering::LowerSETCCCARRY, which is the
// single place the LO/HS rule used here is derived. The compare performed is
// always unsigned; signed operands arrive bit-31-biased (biasHiWord), so this
// expansion is signedness-agnostic.
void ARCExpandPseudos::expandSETCCCARRY(MachineFunction &MF,
                                        MachineBasicBlock::iterator MII) {
  // Expand:
  //   %Dst<def> = SETCCCARRY_PSEUDO %ALo, %BLo, %AHi, %BHi, cc,
  //               %STATUS<imp-def>
  // To:
  //   CMP_rr %ALo, %BLo, %STATUS<imp-def>
  //   SBC_f_null_rrr %AHi, %BHi, %STATUS<imp-def>, %STATUS<imp-use>
  //   %Zero<def> = MOV_ru6 0
  //   %Dst<def,tied1> = MOV_cc_ru6 1, cc, %Zero<tied0>, %STATUS<imp-use>
  //
  // `cmp ALo, BLo` leaves C = borrow = (ALo <u BLo); `sbc.f 0, AHi, BHi`
  // computes AHi - BHi - C and leaves C = the borrow of the FULL 64-bit
  // subtract, i.e. C = (A <u B). cc is ARCCC::LO for `<u` (C=1) or ARCCC::HS
  // for `>=u` (C=0) -- chosen in LowerSETCCCARRY, never here.
  //
  // The `cmp` is the low-half borrow producer, so it must reach `sbc.f` with
  // STATUS32 untouched, and `sbc.f`'s C must reach the `mov.cc` likewise. All
  // four are built back-to-back with nothing inserted between them, and the
  // only instruction that lands *inside* the chain is the `mov Zero, 0`, which
  // is the non-`.f` MOV_ru6 form and does not write STATUS32 -- exactly the
  // shape expandUSUBO above already ships. Everything upstream of this point
  // saw a single opaque pseudo, so nothing could have been scheduled into the
  // middle of it.
  MachineInstr &MI = *MII;
  const MachineOperand &Dst = MI.getOperand(0);
  const MachineOperand &ALo = MI.getOperand(1);
  const MachineOperand &BLo = MI.getOperand(2);
  const MachineOperand &AHi = MI.getOperand(3);
  const MachineOperand &BHi = MI.getOperand(4);
  unsigned CC = MI.getOperand(5).getImm();
  // The compare is always UNSIGNED -- a SIGNED i64 compare reaches here with
  // its high words already bit-31-biased into offset binary, which is what
  // makes it unsigned, so it lands on these same two codes. A signed code here
  // would mean someone started reading V (see LowerSETCCCARRY).
  assert((CC == ARCCC::LO || CC == ARCCC::HS) &&
         "SETCCCARRY_PSEUDO compares unsigned: LowerSETCCCARRY must only ever "
         "build it with ARCCC::LO (a <u b, C=1) or ARCCC::HS (a >=u b, C=0)");
  MachineRegisterInfo &MRI = MF.getRegInfo();
  Register ZeroReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::CMP_rr))
      .add(ALo)
      .add(BLo);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::SBC_f_null_rrr))
      .add(AHi)
      .add(BHi);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_ru6),
          ZeroReg)
      .addImm(0);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_cc_ru6))
      .add(Dst)
      .addImm(1)
      .addImm(CC)
      .addReg(ZeroReg);
  MI.eraseFromParent();
}

// Signed overflow polarity (silicon/vendor-manual-verified, cross-checked
// against the emulator's condition.rs -- VS=0x7 raw `v`, VC=0x8 raw `!v`):
// STATUS32.V is set by `.f`-form ADD/SUB iff the SIGNED result overflowed
// (both operands same sign, result flips sign) -- unambiguous for both
// producers, unlike C which is producer-dependent (see the polarity comment
// above expandUADDSAT). SADDSAT/SSUBSAT/SADDO/SSUBO therefore ALL consume V
// via the VS condition code off their respective `.f` producer; there is no
// LO/HS-style disambiguation needed here.
//
// SADDSAT(a,b)/SSUBSAT(a,b) additionally need a clamp limit that depends
// only on the SIGN of `a` (verified against the required edge cases:
// SADDSAT(INT_MIN,-1)=INT_MIN and SSUBSAT(INT_MIN,1)=INT_MIN both have
// a<0 -> limit=INT_MIN; SADDSAT(INT_MAX,1)=INT_MAX and
// SSUBSAT(INT_MAX,-1)=INT_MAX both have a>=0 -> limit=INT_MAX), so ADD and
// SUB share IDENTICAL limit-construction code -- only the producer opcode
// differs. The limit is built as:
//   t   = asr(a, 31)      ; non-`.f` -- t = 0 (a>=0) or -1 (a<0)
//   max = lsr(-1, 1)      ; non-`.f` -- max = 0x7FFFFFFF (INT_MAX), built via
//                          ; MOV_rs12 -1 (fits s12) + a logical shift instead
//                          ; of an 8-byte LIMM for the literal
//   lim = t ^ max         ; non-`.f` -- INT_MAX when t=0, INT_MIN when t=-1
// None of these four instructions is a `.f` form, so they are built entirely
// BEFORE the atomic producer/consumer pair -- keeping the STATUS32-adjacency
// discipline scoped to exactly the final two real instructions, the same
// shape as every other idiom in this family.
void ARCExpandPseudos::expandSADDSAT(MachineFunction &MF,
                                     MachineBasicBlock::iterator MII) {
  // Expand:
  //   %Dst<def> = SADDSAT_PSEUDO %A, %B, %STATUS<imp-def>
  // To:
  //   %T<def>    = ASR_rru6 %A, 31
  //   %Ones<def> = MOV_rs12 -1
  //   %Max<def>  = LSR_rru6 %Ones, 1
  //   %Lim<def>  = XOR_rrr %T, %Max
  //   %Sum<def>  = ADD_f_rrr %A, %B, %STATUS<imp-def>
  //   %Dst<def,tied1> = MOV_cc %Lim, %Sum<tied0>, vs, %STATUS<imp-use>
  MachineInstr &MI = *MII;
  const MachineOperand &Dst = MI.getOperand(0);
  const MachineOperand &A = MI.getOperand(1);
  const MachineOperand &B = MI.getOperand(2);
  MachineRegisterInfo &MRI = MF.getRegInfo();
  Register TReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);
  Register OnesReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);
  Register MaxReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);
  Register LimReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);
  Register SumReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);

  // %A is read here AND again by the producer below -- only the LAST read
  // of a vreg may carry a kill flag, so this first use is built from a bare
  // .addReg(A.getReg()) (no flags copied) rather than .add(A) (which would
  // copy A's kill flag, if any, onto BOTH uses and trip the MachineVerifier
  // with "Using a killed virtual register").
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ASR_rru6),
         TReg)
      .addReg(A.getReg())
      .addImm(31);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_rs12),
         OnesReg)
      .addImm(-1);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::LSR_rru6),
         MaxReg)
      .addReg(OnesReg)
      .addImm(1);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::XOR_rrr),
         LimReg)
      .addReg(TReg)
      .addReg(MaxReg);
  // sum = a+b; V=1 (vs) iff signed overflow. This IS the last use of %A (and
  // the only use of %B), so it is safe to .add() both verbatim.
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ADD_f_rrr),
         SumReg)
      .add(A)
      .add(B);
  // Dst = VS(signed overflow) ? lim : sum.
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_cc))
      .add(Dst)
      .addReg(LimReg)
      .addReg(SumReg)
      .addImm(ARCCC::VS);
  MI.eraseFromParent();
}

void ARCExpandPseudos::expandSSUBSAT(MachineFunction &MF,
                                     MachineBasicBlock::iterator MII) {
  // Same limit construction as expandSADDSAT (keyed off the sign of %A
  // only); the producer becomes SUB_f_rrr.
  // Expand:
  //   %Dst<def> = SSUBSAT_PSEUDO %A, %B, %STATUS<imp-def>
  // To:
  //   %T<def>    = ASR_rru6 %A, 31
  //   %Ones<def> = MOV_rs12 -1
  //   %Max<def>  = LSR_rru6 %Ones, 1
  //   %Lim<def>  = XOR_rrr %T, %Max
  //   %Diff<def> = SUB_f_rrr %A, %B, %STATUS<imp-def>
  //   %Dst<def,tied1> = MOV_cc %Lim, %Diff<tied0>, vs, %STATUS<imp-use>
  MachineInstr &MI = *MII;
  const MachineOperand &Dst = MI.getOperand(0);
  const MachineOperand &A = MI.getOperand(1);
  const MachineOperand &B = MI.getOperand(2);
  MachineRegisterInfo &MRI = MF.getRegInfo();
  Register TReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);
  Register OnesReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);
  Register MaxReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);
  Register LimReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);
  Register DiffReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);

  // See the identical note in expandSADDSAT: %A is read again by the
  // producer below, so this first read must not copy A's kill flag.
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ASR_rru6),
         TReg)
      .addReg(A.getReg())
      .addImm(31);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_rs12),
         OnesReg)
      .addImm(-1);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::LSR_rru6),
         MaxReg)
      .addReg(OnesReg)
      .addImm(1);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::XOR_rrr),
         LimReg)
      .addReg(TReg)
      .addReg(MaxReg);
  // diff = a-b; V=1 (vs) iff signed overflow. Last use of %A, only use of
  // %B -- safe to .add() both verbatim.
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::SUB_f_rrr),
         DiffReg)
      .add(A)
      .add(B);
  // Dst = VS(signed overflow) ? lim : diff.
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_cc))
      .add(Dst)
      .addReg(LimReg)
      .addReg(DiffReg)
      .addImm(ARCCC::VS);
  MI.eraseFromParent();
}

void ARCExpandPseudos::expandSADDO(MachineFunction &MF,
                                   MachineBasicBlock::iterator MII) {
  // Exact structural mirror of expandUADDO, cc=VS (signed overflow) instead
  // of LO (carry).
  // Expand:
  //   %Sum<def>, %Ovf<def> = SADDO_PSEUDO %A, %B, %STATUS<imp-def>
  // To:
  //   %Sum<def> = ADD_f_rrr %A, %B, %STATUS<imp-def>
  //   %Zero<def> = MOV_ru6 0
  //   %Ovf<def,tied1> = MOV_cc_ru6 1, vs, %Zero<tied0>, %STATUS<imp-use>
  MachineInstr &MI = *MII;
  const MachineOperand &SumDst = MI.getOperand(0);
  const MachineOperand &OvfDst = MI.getOperand(1);
  const MachineOperand &A = MI.getOperand(2);
  const MachineOperand &B = MI.getOperand(3);
  MachineRegisterInfo &MRI = MF.getRegInfo();
  Register ZeroReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ADD_f_rrr))
      .add(SumDst)
      .add(A)
      .add(B);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_ru6),
         ZeroReg)
      .addImm(0);
  // Ovf = VS(signed add overflow) ? 1 : 0.
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_cc_ru6))
      .add(OvfDst)
      .addImm(1)
      .addImm(ARCCC::VS)
      .addReg(ZeroReg);
  MI.eraseFromParent();
}

void ARCExpandPseudos::expandSSUBO(MachineFunction &MF,
                                   MachineBasicBlock::iterator MII) {
  // Exact structural mirror of expandUSUBO, cc=VS instead of LO.
  // Expand:
  //   %Diff<def>, %Ovf<def> = SSUBO_PSEUDO %A, %B, %STATUS<imp-def>
  // To:
  //   %Diff<def> = SUB_f_rrr %A, %B, %STATUS<imp-def>
  //   %Zero<def> = MOV_ru6 0
  //   %Ovf<def,tied1> = MOV_cc_ru6 1, vs, %Zero<tied0>, %STATUS<imp-use>
  MachineInstr &MI = *MII;
  const MachineOperand &DiffDst = MI.getOperand(0);
  const MachineOperand &OvfDst = MI.getOperand(1);
  const MachineOperand &A = MI.getOperand(2);
  const MachineOperand &B = MI.getOperand(3);
  MachineRegisterInfo &MRI = MF.getRegInfo();
  Register ZeroReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::SUB_f_rrr))
      .add(DiffDst)
      .add(A)
      .add(B);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_ru6),
         ZeroReg)
      .addImm(0);
  // Ovf = VS(signed sub overflow) ? 1 : 0.
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::MOV_cc_ru6))
      .add(OvfDst)
      .addImm(1)
      .addImm(ARCCC::VS)
      .addReg(ZeroReg);
  MI.eraseFromParent();
}

// AVGFLOORU: exact unsigned floor((a+b)/2) over the true 33-bit sum, correct
// across a 32-bit wrap. add.f's C is the raw carry-out (bit 32 of the true
// sum, i.e. NOT a compare/borrow flag -- same reading as the SHL64_1/
// BitRevStep producers below, not the SUB/CMP polarity discussion above
// expandUADDSAT). rrc folds that carry into the vacated MSB while shifting
// right by one: rrc(t) = (C<<31)|(t>>1) = exact floor((a+b)/2), including
// when the raw 32-bit sum wrapped.
void ARCExpandPseudos::expandAVGFLOORU(MachineFunction &MF,
                                       MachineBasicBlock::iterator MII) {
  // Expand:
  //   %Dst<def> = AVGFLOORU_PSEUDO %A, %B, %STATUS<imp-def>
  // To:
  //   %T<def>   = ADD_f_rrr %A, %B, %STATUS<imp-def>  ; C = bit 32 of sum
  //   %Dst<def> = ARC_RRC_b_c %T, %STATUS<imp-use>     ; Dst=(C<<31)|(T>>1)
  MachineInstr &MI = *MII;
  const MachineOperand &Dst = MI.getOperand(0);
  const MachineOperand &A = MI.getOperand(1);
  const MachineOperand &B = MI.getOperand(2);
  MachineRegisterInfo &MRI = MF.getRegInfo();
  Register SumReg = MRI.createVirtualRegister(&ARC::GPR32RegClass);

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ADD_f_rrr),
         SumReg)
      .add(A)
      .add(B);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ARC_RRC_b_c))
      .add(Dst)
      .addReg(SumReg);
  MI.eraseFromParent();
}

// i64 `shl x, 1` fused into a 2-instruction carry chain (dossier 24). C is
// the raw ejected bit from asl.f -- NOT a compare/borrow flag, so none of
// the SUB/CMP carry-polarity discussion above expandUADDSAT applies here;
// rlc simply reads whatever asl.f just placed in STATUS32.C.
void ARCExpandPseudos::expandSHL64_1(MachineFunction &MF,
                                     MachineBasicBlock::iterator MII) {
  // Expand:
  //   %Lo<def>, %Hi<def> = SHL64_1_PSEUDO %InLo, %InHi, %STATUS<imp-def>
  // To:
  //   %Lo<def> = ARC_ASL_b_c_f %InLo, %STATUS<imp-def>  ; Lo=InLo<<1, C=MSB
  //   %Hi<def> = ARC_RLC_b_c %InHi, %STATUS<imp-use>    ; Hi=(InHi<<1)|C
  MachineInstr &MI = *MII;
  const MachineOperand &LoDst = MI.getOperand(0);
  const MachineOperand &HiDst = MI.getOperand(1);
  const MachineOperand &InLo = MI.getOperand(2);
  const MachineOperand &InHi = MI.getOperand(3);

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ARC_ASL_b_c_f))
      .add(LoDst)
      .add(InLo);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ARC_RLC_b_c))
      .add(HiDst)
      .add(InHi);
  MI.eraseFromParent();
}

// One bit-reverse step fused into a 2-instruction carry chain (dossier 24).
// lsr.f ejects the LOW bit of XIn into C (the exact bit `(x&1)` the naive
// sequence would compute), and rlc folds it into the low bit of YOut.
void ARCExpandPseudos::expandBitRevStep(MachineFunction &MF,
                                        MachineBasicBlock::iterator MII) {
  // Expand:
  //   %XOut<def>, %YOut<def> = BITREV_STEP_PSEUDO %XIn, %YIn, %STATUS<imp-def>
  // To:
  //   %XOut<def> = ARC_LSR_b_c_f %XIn, %STATUS<imp-def>  ; XOut=XIn>>1, C=LSB
  //   %YOut<def> = ARC_RLC_b_c %YIn, %STATUS<imp-use>    ; YOut=(YIn<<1)|C
  MachineInstr &MI = *MII;
  const MachineOperand &XOutDst = MI.getOperand(0);
  const MachineOperand &YOutDst = MI.getOperand(1);
  const MachineOperand &XIn = MI.getOperand(2);
  const MachineOperand &YIn = MI.getOperand(3);

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ARC_LSR_b_c_f))
      .add(XOutDst)
      .add(XIn);
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ARC_RLC_b_c))
      .add(YOutDst)
      .add(YIn);
  MI.eraseFromParent();
}

void ARCExpandPseudos::expandLR(MachineFunction &MF,
                                MachineBasicBlock::iterator MII) {
  // Expand: %dst = ARC_LR_PSEUDO %aux_addr
  // To:     %dst = ARC_LR_b_c %aux_addr
  MachineInstr &MI = *MII;
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ARC_LR_b_c))
      .add(MI.getOperand(0))  // dst
      .add(MI.getOperand(1)); // aux_addr (register)
  MI.eraseFromParent();
}

void ARCExpandPseudos::expandLRImm(MachineFunction &MF,
                                    MachineBasicBlock::iterator MII) {
  // Expand: %dst = ARC_LR_IMM_PSEUDO imm
  // To:     %dst = ARC_LR_b_u6 imm    (if fits in u6)
  //    or:  %dst = ARC_LR_b_limm imm   (otherwise)
  MachineInstr &MI = *MII;
  int64_t AuxAddr = MI.getOperand(1).getImm();
  unsigned Opc;
  if (isUInt<6>(AuxAddr))
    Opc = ARC::ARC_LR_b_u6;
  else if (isInt<12>(AuxAddr))
    Opc = ARC::ARC_LR_b_s12;
  else
    Opc = ARC::ARC_LR_b_limm;

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(Opc))
      .add(MI.getOperand(0))  // dst
      .addImm(AuxAddr);       // aux address immediate
  MI.eraseFromParent();
}

void ARCExpandPseudos::expandSR(MachineFunction &MF,
                                MachineBasicBlock::iterator MII) {
  // Expand: ARC_SR_PSEUDO %val, %aux_addr
  // To:     ARC_SR_b_c %val, %aux_addr
  // Note: ARC_SR_b_c has rb_chk as (outs) in the auto-generated def,
  // but it is actually a source operand in the encoding. We emit it
  // as the first operand which maps to the B field.
  MachineInstr &MI = *MII;
  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(ARC::ARC_SR_b_c))
      .add(MI.getOperand(0))  // val (mapped to rb_chk / B field)
      .add(MI.getOperand(1)); // aux_addr (register, C field)
  MI.eraseFromParent();
}

void ARCExpandPseudos::expandSRImm(MachineFunction &MF,
                                    MachineBasicBlock::iterator MII) {
  // Expand: ARC_SR_IMM_PSEUDO %val, imm
  // To:     ARC_SR_b_u6 %val, imm     (if fits in u6)
  //    or:  ARC_SR_b_s12 %val, imm    (if fits in s12)
  //    or:  ARC_SR_b_limm %val, imm   (otherwise)
  MachineInstr &MI = *MII;
  int64_t AuxAddr = MI.getOperand(1).getImm();
  unsigned Opc;
  if (isUInt<6>(AuxAddr))
    Opc = ARC::ARC_SR_b_u6;
  else if (isInt<12>(AuxAddr))
    Opc = ARC::ARC_SR_b_s12;
  else
    Opc = ARC::ARC_SR_b_limm;

  BuildMI(*MI.getParent(), MI, MI.getDebugLoc(), TII->get(Opc))
      .add(MI.getOperand(0))  // val (mapped to rb_chk / B field)
      .addImm(AuxAddr);       // aux address immediate
  MI.eraseFromParent();
}

bool ARCExpandPseudos::runOnMachineFunction(MachineFunction &MF) {
  const ARCSubtarget *STI = &MF.getSubtarget<ARCSubtarget>();
  TII = STI->getInstrInfo();
  bool Expanded = false;
  for (auto &MBB : MF) {
    MachineBasicBlock::iterator MBBI = MBB.begin(), E = MBB.end();
    while (MBBI != E) {
      MachineBasicBlock::iterator NMBBI = std::next(MBBI);
      switch (MBBI->getOpcode()) {
      case ARC::ST_FAR:
      case ARC::STH_FAR:
      case ARC::STB_FAR:
        expandStore(MF, MBBI);
        Expanded = true;
        break;
      case ARC::CTLZ:
        expandCTLZ(MF, MBBI);
        Expanded = true;
        break;
      case ARC::CTTZ:
        expandCTTZ(MF, MBBI);
        Expanded = true;
        break;
      case ARC::UADDSAT_PSEUDO:
        expandUADDSAT(MF, MBBI);
        Expanded = true;
        break;
      case ARC::USUBSAT_PSEUDO:
        expandUSUBSAT(MF, MBBI);
        Expanded = true;
        break;
      case ARC::UADDO_PSEUDO:
        expandUADDO(MF, MBBI);
        Expanded = true;
        break;
      case ARC::USUBO_PSEUDO:
        expandUSUBO(MF, MBBI);
        Expanded = true;
        break;
      case ARC::SADDSAT_PSEUDO:
        expandSADDSAT(MF, MBBI);
        Expanded = true;
        break;
      case ARC::SSUBSAT_PSEUDO:
        expandSSUBSAT(MF, MBBI);
        Expanded = true;
        break;
      case ARC::SADDO_PSEUDO:
        expandSADDO(MF, MBBI);
        Expanded = true;
        break;
      case ARC::SSUBO_PSEUDO:
        expandSSUBO(MF, MBBI);
        Expanded = true;
        break;
      case ARC::AVGFLOORU_PSEUDO:
        expandAVGFLOORU(MF, MBBI);
        Expanded = true;
        break;
      case ARC::SETCCCARRY_PSEUDO:
        expandSETCCCARRY(MF, MBBI);
        Expanded = true;
        break;
      case ARC::SHL64_1_PSEUDO:
        expandSHL64_1(MF, MBBI);
        Expanded = true;
        break;
      case ARC::BITREV_STEP_PSEUDO:
        expandBitRevStep(MF, MBBI);
        Expanded = true;
        break;
      case ARC::ARC_LR_PSEUDO:
        expandLR(MF, MBBI);
        Expanded = true;
        break;
      case ARC::ARC_LR_IMM_PSEUDO:
        expandLRImm(MF, MBBI);
        Expanded = true;
        break;
      case ARC::ARC_SR_PSEUDO:
        expandSR(MF, MBBI);
        Expanded = true;
        break;
      case ARC::ARC_SR_IMM_PSEUDO:
        expandSRImm(MF, MBBI);
        Expanded = true;
        break;
      default:
        break;
      }
      MBBI = NMBBI;
    }
  }
  return Expanded;
}

FunctionPass *llvm::createARCExpandPseudosPass() {
  return new ARCExpandPseudos();
}
