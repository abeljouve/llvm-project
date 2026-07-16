//===- ARCDelaySlotFiller.cpp - ARC700 delay slot filler ---------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass fills delay slots for ARCompact (ARC700) transfers.
//
// ARC700 gives every branch, call and jump one architectural delay slot,
// selected by the N bit: N=0 (ND) nullifies the following instruction when
// the transfer is taken; N=1 (D) always executes it. ISel selects only the
// ND forms, so this pass is what makes the slot usable at all: it scans
// backward for an instruction that already executes unconditionally before
// the transfer, moves it into the slot, and only then converts the transfer
// to its delayed (.d) twin.
//
// That ordering is the whole correctness argument. D-mode executes the slot
// on both the taken and the not-taken path, so an instruction that already
// ran unconditionally before the transfer has exactly the same execution
// count after the move -- on either path. Nothing is copied from a successor
// and nothing is speculated.
//
// A slot we cannot fill costs nothing: we leave the plain ND encoding alone.
// Unlike SPARC -- from which this pass's structure is borrowed -- ARC's slot
// is optional, and the ND encoding *is* the "no slot" case. There is no NOP
// to insert, and inserting one would be a strict regression (4 bytes and an
// extra issue on the not-taken path).
//
// This pass only runs for ARCompact subtargets; ARCv2 does not have delay
// slots.
//
//===----------------------------------------------------------------------===//

#include "ARC.h"
#include "ARCInstrInfo.h"
#include "ARCSubtarget.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineInstrBundle.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/InitializePasses.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include <optional>

using namespace llvm;

#define DEBUG_TYPE "arc-delay-slot-filler"

STATISTIC(TotalSlots, "Number of delay slots seen (fillable transfers)");
STATISTIC(FilledSlots, "Number of delay slots filled");
STATISTIC(UnfilledSlots, "Number of delay slots left empty (plain ND branch)");
STATISTIC(NopSlots, "Number of delay slots filled with NOPs");
// Per-class fill counters. The saving is exactly FilledSlots x 1 clock: the
// silicon characterisation measured a taken branch with an unused slot and
// the same branch with a filled slot at an identical 321 cycles, so the
// instruction moved into the slot retires for free. Reporting the fill rate
// per class is therefore the whole measurement -- the cycle constant is
// already known, and llvm-mca cannot be used here (it models no branch
// redirect at all, so it is structurally blind to this transform).
STATISTIC(FilledCondBranch, "Delay slots filled: conditional branches");
STATISTIC(FilledUncondBranch, "Delay slots filled: unconditional branches");
STATISTIC(FilledCall, "Delay slots filled: calls");
STATISTIC(FilledReturn, "Delay slots filled: returns");
STATISTIC(FilledIndirect, "Delay slots filled: indirect jumps");

static cl::opt<bool>
    DisableDelaySlotFiller("arc-disable-delay-filler", cl::init(false),
                           cl::desc("Disable ARC delay slot filler."),
                           cl::Hidden);

// A/B knob only. Fills every slot with a NOP instead of a real instruction,
// so the cost of the transform can be separated from the cost of the code
// motion. This is never a win -- it is what design (b) would do on every
// unfilled slot -- and is off by default.
//
// The NOP stays 4 bytes (ARC_NOP_0) deliberately: a 2-byte NOP_S exists, but
// neither the compact NOP encoding nor its validity in every delayed slot has
// been characterised on this part, so shrinking it is not yet justified.
static cl::opt<bool>
    NopOnlyDelaySlotFiller("arc-nop-delay-filler", cl::init(false),
                           cl::desc("Fill ARC delay slots with NOPs only."),
                           cl::Hidden);

namespace llvm {
void initializeARCDelaySlotFillerPass(PassRegistry &Registry);
} // end namespace llvm

namespace {

class ARCDelaySlotFiller : public MachineFunctionPass {
public:
  static char ID;

  ARCDelaySlotFiller() : MachineFunctionPass(ID) {
    initializeARCDelaySlotFillerPass(*PassRegistry::getPassRegistry());
  }

  StringRef getPassName() const override {
    return "ARC Delay Slot Filler";
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  MachineFunctionProperties getRequiredProperties() const override {
    return MachineFunctionProperties().setNoVRegs();
  }

private:
  const ARCInstrInfo *TII = nullptr;
  const TargetRegisterInfo *TRI = nullptr;
  MachineBasicBlock::instr_iterator LastFiller;

  bool runOnMachineBasicBlock(MachineBasicBlock &MBB);

  bool findDelayInstr(MachineBasicBlock &MBB,
                      MachineBasicBlock::instr_iterator Slot,
                      MachineBasicBlock::instr_iterator &Filler);

  bool delayHasHazard(MachineBasicBlock::instr_iterator MI,
                      bool &SawLoad, bool &SawStore,
                      SmallSet<unsigned, 32> &RegDefs,
                      SmallSet<unsigned, 32> &RegUses);

  void insertDefsUses(MachineBasicBlock::instr_iterator MI,
                      SmallSet<unsigned, 32> &RegDefs,
                      SmallSet<unsigned, 32> &RegUses);

  bool isRegInSet(SmallSet<unsigned, 32> &RegSet, unsigned Reg);
};

char ARCDelaySlotFiller::ID = 0;

} // end anonymous namespace

INITIALIZE_PASS(ARCDelaySlotFiller, "arc-delay-slot-filler",
                "ARC Delay Slot Filler", false, false)

bool ARCDelaySlotFiller::runOnMachineFunction(MachineFunction &MF) {
  const ARCSubtarget &Subtarget = MF.getSubtarget<ARCSubtarget>();

  // Only ARCompact (ARC700) has delay slots.
  if (!Subtarget.isARCompact())
    return false;

  if (DisableDelaySlotFiller)
    return false;

  TII = Subtarget.getInstrInfo();
  TRI = Subtarget.getRegisterInfo();

  LLVM_DEBUG(dbgs() << "Running ARC Delay Slot Filler on " << MF.getName()
                    << "\n");

  bool Changed = false;
  for (MachineBasicBlock &MBB : MF)
    Changed |= runOnMachineBasicBlock(MBB);
  return Changed;
}

// Drop the transfer's implicit ABI-marker uses that the slot instruction now
// supplies itself.
//
// A return carries `implicit $r0` to keep the return value live, and a call
// carries `implicit $r0, $r1, ...` for its argument registers. The transfer
// does not read any of them -- `j [blink]` reads BLINK and nothing else -- so
// insertDefsUses deliberately ignores them and lets their producer be sunk
// into the slot. That is exactly the transform's main win (compute the return
// value in the return's own delay slot), and it is architecturally sound: the
// slot retires before control reaches the target.
//
// But it leaves the marker behind pointing at a value now defined *inside* the
// transfer's own bundle, and an MI bundle has parallel semantics: the verifier
// merges a bundle's defs into the live set only at visitMachineBundleAfter, so
// the header's use resolves against the state live *before* the bundle and is
// reported as "Using an undefined physical register". The marker is not merely
// awkward here, it is false -- so remove it rather than weaken the transform.
// The bundle as a whole still defines the register, which is what live-out
// wants.
//
// Only markers the slot actually defines are dropped, and only implicit ones:
// an explicit operand (an indirect transfer's target register) is a real input
// and is never touched -- nor could it be, since a def of it is a hazard that
// findDelayInstr rejects outright.
static void dropImplicitUsesSatisfiedBySlot(MachineInstr &Transfer,
                                            const MachineInstr &Slot) {
  SmallVector<unsigned, 4> ToRemove;
  for (unsigned Idx = Transfer.getNumOperands(); Idx-- > 0;) {
    const MachineOperand &MO = Transfer.getOperand(Idx);
    if (!MO.isReg() || !MO.isUse() || !MO.isImplicit())
      continue;
    Register Reg = MO.getReg();
    if (!Reg || !Reg.isPhysical())
      continue;
    // BLINK and SP are real transfer inputs, never ABI markers. They are
    // already protected as hazards; this is belt and braces.
    if (Reg == ARC::BLINK || Reg == ARC::SP)
      continue;
    if (Slot.definesRegister(Reg, /*TRI=*/nullptr))
      ToRemove.push_back(Idx);
  }
  // Collected in decreasing index order, so removal cannot invalidate the
  // indices still queued.
  for (unsigned Idx : ToRemove)
    Transfer.removeOperand(Idx);
}

static void countFilledClass(const MachineInstr &MI) {
  if (MI.isReturn())
    ++FilledReturn;
  else if (MI.isCall())
    ++FilledCall;
  else if (MI.isIndirectBranch())
    ++FilledIndirect;
  else if (MI.isConditionalBranch())
    ++FilledCondBranch;
  else
    ++FilledUncondBranch;
}

bool ARCDelaySlotFiller::runOnMachineBasicBlock(MachineBasicBlock &MBB) {
  bool Changed = false;
  LastFiller = MBB.instr_end();

  for (MachineBasicBlock::instr_iterator I = MBB.instr_begin();
       I != MBB.instr_end(); ++I) {
    // Deliberately NOT keyed on hasDelaySlot(): the transfers ISel selects
    // are the non-delayed (N=0) encodings, which correctly report
    // hasDelaySlot() == false. Keying on hasDelaySlot() is what made this
    // pass inert -- it matched nothing codegen ever produced.
    std::optional<unsigned> DelayedOpc =
        ARCInstrInfo::getDelayedOpcode(I->getOpcode());
    if (!DelayedOpc)
      continue;

    // Already delayed (hand-written MIR, or a form some earlier pass built
    // in its .d shape): its slot is already spoken for.
    if (I->getDesc().hasDelaySlot() || I->isBundledWithSucc())
      continue;

    ++TotalSlots;

    MachineBasicBlock::instr_iterator InstrWithSlot = I;
    MachineBasicBlock::instr_iterator J = I;

    if (NopOnlyDelaySlotFiller) {
      // A/B knob: see the note on -arc-nop-delay-filler.
      BuildMI(MBB, std::next(I), DebugLoc(), TII->get(ARC::ARC_NOP_0));
      ++NopSlots;
    } else if (findDelayInstr(MBB, I, J)) {
      MBB.splice(std::next(I), &MBB, J);
      dropImplicitUsesSatisfiedBySlot(*I, *std::next(I));
      ++FilledSlots;
    } else {
      // Nothing safe to move. Leave the plain ND encoding exactly as it is:
      // on ARC an unfilled slot must cost nothing. ND already nullifies the
      // next instruction on the taken path and executes the fall-through's
      // first instruction on the not-taken path, which is precisely correct
      // branch behaviour. Converting to .d and padding with a NOP -- what a
      // SPARC-shaped filler must do, because SPARC's slot is mandatory --
      // would cost 4 bytes and one extra issue on the not-taken path for no
      // gain whatsoever.
      ++UnfilledSlots;
      continue;
    }

    // The slot is now genuinely occupied, so -- and only so -- select the
    // delayed encoding. Order matters: setting N=1 with nothing in the slot
    // would make the hardware execute whatever word follows the transfer.
    //
    // Both twin families are size-preserving (N-bit forms keep their 4 bytes;
    // j_s [blink] -> j_s.d [blink] stays 2), and the splice moves an
    // instruction within the block rather than adding one, so the block's
    // size is unchanged and ARCBranchFinalize's already-computed
    // displacements stay valid. The transfer's own PC does shift up to 4
    // bytes earlier, but that pass bounds BRcc range to a signed 9-bit *byte*
    // displacement (~+/-256) while the hardware encodes half-words (~+/-510),
    // so the ~2x margin absorbs it.
    I->setDesc(TII->get(*DelayedOpc));

    // Classify after the conversion, not before: the pre-conversion BBIT
    // forms report isBranch = 0, so classifying them first would file every
    // filled bit-test-and-branch under the wrong counter.
    countFilledClass(*I);

    Changed = true;
    // Record the filler instruction that filled the delay slot.
    // The instruction after it will be visited in the next iteration.
    LastFiller = ++I;

    // Bundle the delay slot filler with the transfer so that the machine
    // verifier does not expect the filler to be a terminator. NOTE: this is
    // also why ARCAsmPrinter::emitInstruction must walk bundles -- without
    // that walk the slot instruction is silently dropped from the object.
    MIBundleBuilder(MBB, InstrWithSlot, std::next(LastFiller));
  }
  return Changed;
}

bool ARCDelaySlotFiller::findDelayInstr(
    MachineBasicBlock &MBB,
    MachineBasicBlock::instr_iterator Slot,
    MachineBasicBlock::instr_iterator &Filler) {
  SmallSet<unsigned, 32> RegDefs;
  SmallSet<unsigned, 32> RegUses;

  insertDefsUses(Slot, RegDefs, RegUses);

  bool SawLoad = false;
  bool SawStore = false;

  for (MachineBasicBlock::reverse_instr_iterator I = ++Slot.getReverse();
       I != MBB.instr_rend(); ++I) {
    // Labels and CFI must not be crossed. A label means some other edge can
    // enter here: an instruction sitting *before* the label is not executed
    // by a path arriving at it, so sinking that instruction past the label
    // into the delay slot would make those paths execute it. CFI records the
    // frame state at a PC, so moving code across it invalidates unwinding.
    if (I->isPosition())
      break;

    // Other meta instructions (DBG_VALUE, lifetime markers, ...) emit no code
    // and can simply be stepped over. The previous `isPseudo()` break aborted
    // the scan on them instead, silently costing fill opportunities.
    if (I->isMetaInstruction())
      continue;

    // Convert to forward iterator.
    MachineBasicBlock::instr_iterator FI = I.getReverse();

    // Cannot move past inline asm, instructions with unmodeled side effects,
    // pseudos of unknown size/semantics, an instruction already bundled into
    // a slot, or the last filler we placed.
    if (I->hasUnmodeledSideEffects() || I->isInlineAsm() ||
        FI == LastFiller || I->isBundledWithSucc() || I->isPseudo())
      break;

    // Cannot put branches, calls or returns in the delay slot -- and, just as
    // importantly, cannot scan *past* one. isBranch() alone is not enough:
    // ARC_BBIT{0,1}_b_u6_s9_d, which ARCBranchFinalize::tryFuseBBIT builds
    // from ordinary code, has isBranch = 0 and isTerminator = 0, so a scan
    // guarded only by isBranch() would walk straight through a live
    // conditional branch and sink an instruction from before it into a later
    // transfer's slot -- where it stops executing whenever the bbit is taken.
    // getDelayedOpcode() recognises every transfer we know about, modelled or
    // not, so it closes that hole.
    if (I->isCall() || I->isReturn() || I->isBranch() || I->isTerminator() ||
        I->getDesc().hasDelaySlot() ||
        ARCInstrInfo::getDelayedOpcode(I->getOpcode()))
      break;

    // Volatile / atomic / unknown memory is a full barrier. hasSideEffects is
    // 0 for a volatile load -- volatility lives only in the MachineMemOperand,
    // which nothing else here reads -- so without this a pair of volatile MMIO
    // accesses could be reordered with the MMO still saying `volatile`.
    // (Inline-asm MMIO is already covered by isInlineAsm above; C `volatile`
    // is not.) memoperands_empty() counts as ordered: if we do not know what
    // an access touches, we do not move it or anything across it.
    if (I->hasOrderedMemoryRef())
      break;

    if (delayHasHazard(FI, SawLoad, SawStore, RegDefs, RegUses)) {
      insertDefsUses(FI, RegDefs, RegUses);
      continue;
    }

    Filler = FI;
    return true;
  }
  return false;
}

bool ARCDelaySlotFiller::delayHasHazard(
    MachineBasicBlock::instr_iterator MI,
    bool &SawLoad, bool &SawStore,
    SmallSet<unsigned, 32> &RegDefs,
    SmallSet<unsigned, 32> &RegUses) {
  if (MI->isImplicitDef() || MI->isKill())
    return true;

  // Restrict the slot occupant to a 4-byte instruction.
  //
  // ARCompact mixes 2-, 4- and 8-byte encodings, and only the 4-byte case is
  // proven: the silicon delay-slot probe used a 4-byte `add`. Whether an
  // 8-byte LIMM-carrying instruction is a legal slot occupant is NOT settled
  // -- the ISA says only that a *transfer* carrying a LIMM has no delay slot,
  // and is silent on a LIMM instruction sitting *in* one -- and neither is a
  // 2-byte compact instruction in a 32-bit transfer's slot. Until either is
  // characterised, do not guess.
  if (TII->getInstSizeInBytes(*MI) != 4)
    return true;

  // Prologue / epilogue instructions carry frame meaning that the CFI
  // directives around them describe positionally.
  if (MI->getFlag(MachineInstr::FrameSetup) ||
      MI->getFlag(MachineInstr::FrameDestroy))
    return true;

  // Never sink a volatile / atomic / unknown memory access. See the matching
  // barrier in findDelayInstr.
  if (MI->hasOrderedMemoryRef())
    return true;

  // AUX access (lr/sr), loop setup (lp) and traps. Redundant with the
  // hasUnmodeledSideEffects() break above now that those defs carry an
  // explicit `let hasSideEffects = 1`, but kept so that regenerating the .td
  // files cannot silently disarm the guard. The trap case is also ISA rule 3:
  // a trap must not immediately follow a BRcc / BBIT, i.e. sit in its slot.
  if (ARCInstrInfo::hasUnmodeledARCompactSideEffects(*MI))
    return true;

  // Loads or stores cannot be moved past a store to the delay slot
  // and stores cannot be moved past a load.
  //
  // Load-after-load motion is intentionally still permitted: reordering two
  // plain loads cannot change any result, and the volatile/atomic case --
  // the one that actually matters for MMIO -- is already rejected by the
  // hasOrderedMemoryRef() checks above.
  if (MI->mayLoad()) {
    if (SawStore)
      return true;
    SawLoad = true;
  }

  if (MI->mayStore()) {
    if (SawStore)
      return true;
    SawStore = true;
    if (SawLoad)
      return true;
  }

  for (const MachineOperand &MO : MI->operands()) {
    unsigned Reg;

    if (!MO.isReg() || !(Reg = MO.getReg()))
      continue;

    if (MO.isDef()) {
      // Check whether Reg is defined or used before delay slot.
      if (isRegInSet(RegDefs, Reg) || isRegInSet(RegUses, Reg))
        return true;
    }
    if (MO.isUse()) {
      // Check whether Reg is defined before delay slot.
      if (isRegInSet(RegDefs, Reg))
        return true;
    }
  }
  return false;
}

void ARCDelaySlotFiller::insertDefsUses(
    MachineBasicBlock::instr_iterator MI,
    SmallSet<unsigned, 32> &RegDefs,
    SmallSet<unsigned, 32> &RegUses) {
  // For a call or return, walk only the explicit, non-variadic operands; for
  // everything else, walk every operand including the implicit ones.
  //
  // The distinction is what a transfer actually *reads to do its job* versus
  // what is merely an ABI liveness marker hanging off it. A return carries
  // `implicit $r0` to keep the return value live, and a call carries
  // `implicit $r0, $r1, ...` for its argument registers -- but the transfer
  // does not consult any of them: `j [blink]` reads BLINK and nothing else.
  // Treating those markers as real uses rejects the single most common shape
  // there is -- compute the return value, then return -- even though sinking
  // that computation into the slot is exactly correct: the slot instruction
  // retires before control reaches the target, so $r0 is written before the
  // caller can read it. Walking every operand here measured a 3.6% fill rate
  // across the ARC test corpus, i.e. the pass did almost nothing.
  //
  // The registers a transfer genuinely depends on are re-inserted by hand
  // below. This mirrors SPARC's filler, from which this pass is derived.
  // Note the ARC port originally copied SPARC's truncation but *not* its
  // by-hand re-insertion, which is a real bug in the opposite direction:
  // BL's implicit `Defs = [BLINK]` never reached RegDefs (its sole declared
  // operand is the target, not a register) and J_S_BLINK declared no operands
  // at all, so nothing whatsoever was recorded for a return -- an epilogue
  // `ld blink, [sp]` could be sunk into the return's own delay slot and the
  // return would go to a stale address. Both halves are needed.
  const MCInstrDesc &MCID = MI->getDesc();
  unsigned E = (MI->isCall() || MI->isReturn()) ? MCID.getNumOperands()
                                                : MI->getNumOperands();
  for (unsigned I = 0; I != E; ++I) {
    const MachineOperand &MO = MI->getOperand(I);
    unsigned Reg;

    if (!MO.isReg() || !(Reg = MO.getReg()))
      continue;

    if (MO.isDef())
      RegDefs.insert(Reg);
    else if (MO.isUse())
      RegUses.insert(Reg);
  }

  // Re-insert, by hand, the state a call or return actually depends on -- the
  // half of SPARC's design the ARC port originally omitted. This is what the
  // truncation above is safe *because* of.
  //
  // An indirect transfer's target register needs no special handling: it is an
  // explicit operand (`JL`/`J` take (ins GPR32:$C)), so the loop above already
  // recorded it and nothing can clobber it in the slot.
  //
  // Register masks are deliberately not consulted. A call's mask describes
  // what the *callee* clobbers, but the slot instruction issues before control
  // transfers -- exactly where it already was relative to the call -- so the
  // set of values the callee destroys is unchanged by the move.
  if (MI->isCall()) {
    RegDefs.insert(ARC::SP);
    RegDefs.insert(ARC::BLINK); // The call writes the return address.
  }
  if (MI->isReturn()) {
    RegDefs.insert(ARC::SP);
    RegUses.insert(ARC::BLINK); // j [blink] reads it.
  }
}

bool ARCDelaySlotFiller::isRegInSet(SmallSet<unsigned, 32> &RegSet,
                                     unsigned Reg) {
  for (MCRegAliasIterator AI(Reg, TRI, true); AI.isValid(); ++AI)
    if (RegSet.count(*AI))
      return true;
  return false;
}

FunctionPass *llvm::createARCDelaySlotFillerPass() {
  return new ARCDelaySlotFiller();
}
