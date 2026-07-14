//===- ARCISelLowering.cpp - ARC DAG Lowering Impl --------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the ARCTargetLowering class.
//
//===----------------------------------------------------------------------===//

#include "ARCISelLowering.h"
#include "ARC.h"
#include "ARCMachineFunctionInfo.h"
#include "ARCSelectionDAGInfo.h"
#include "ARCSubtarget.h"
#include "ARCTargetMachine.h"
#include "MCTargetDesc/ARCInfo.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/Debug.h"
#include <algorithm>

#define DEBUG_TYPE "arc-lower"

using namespace llvm;

static SDValue lowerCallResult(SDValue Chain, SDValue InGlue,
                               const SmallVectorImpl<CCValAssign> &RVLocs,
                               SDLoc dl, SelectionDAG &DAG,
                               SmallVectorImpl<SDValue> &InVals);

static ARCCC::CondCode ISDCCtoARCCC(ISD::CondCode isdCC) {
  switch (isdCC) {
  case ISD::SETUEQ:
    return ARCCC::EQ;
  case ISD::SETUGT:
    return ARCCC::HI;
  case ISD::SETUGE:
    return ARCCC::HS;
  case ISD::SETULT:
    return ARCCC::LO;
  case ISD::SETULE:
    return ARCCC::LS;
  case ISD::SETUNE:
    return ARCCC::NE;
  case ISD::SETEQ:
    return ARCCC::EQ;
  case ISD::SETGT:
    return ARCCC::GT;
  case ISD::SETGE:
    return ARCCC::GE;
  case ISD::SETLT:
    return ARCCC::LT;
  case ISD::SETLE:
    return ARCCC::LE;
  case ISD::SETNE:
    return ARCCC::NE;
  default:
    llvm_unreachable("Unhandled ISDCC code.");
  }
}

void ARCTargetLowering::ReplaceNodeResults(SDNode *N,
                                           SmallVectorImpl<SDValue> &Results,
                                           SelectionDAG &DAG) const {
  LLVM_DEBUG(dbgs() << "[ARC-ISEL] ReplaceNodeResults ");
  LLVM_DEBUG(N->dump(&DAG));
  LLVM_DEBUG(dbgs() << "; use_count=" << N->use_size() << "\n");

  switch (N->getOpcode()) {
  case ISD::READCYCLECOUNTER:
    if (N->getValueType(0) == MVT::i64) {
      // We read the TIMER0 and zero-extend it to 64-bits as the intrinsic
      // requires.
      SDValue V =
          DAG.getNode(ISD::READCYCLECOUNTER, SDLoc(N),
                      DAG.getVTList(MVT::i32, MVT::Other), N->getOperand(0));
      SDValue Op = DAG.getNode(ISD::ZERO_EXTEND, SDLoc(N), MVT::i64, V);
      Results.push_back(Op);
      Results.push_back(V.getValue(1));
    }
    break;
  default:
    break;
  }
}

ARCTargetLowering::ARCTargetLowering(const TargetMachine &TM,
                                     const ARCSubtarget &Subtarget)
    : TargetLowering(TM, Subtarget), Subtarget(Subtarget) {
  // Set up the register classes.
  addRegisterClass(MVT::i32, &ARC::GPR32RegClass);

  // Compute derived properties from the register classes
  computeRegisterProperties(Subtarget.getRegisterInfo());

  setStackPointerRegisterToSaveRestore(ARC::SP);

  setSchedulingPreference(Sched::Source);

  // Use i32 for setcc operations results (slt, sgt, ...).
  setBooleanContents(ZeroOrOneBooleanContent);
  setBooleanVectorContents(ZeroOrOneBooleanContent);

  for (unsigned Opc = 0; Opc < ISD::BUILTIN_OP_END; ++Opc)
    setOperationAction(Opc, MVT::i32, Expand);

  // Operations to get us off of the ground.
  // Basic.
  setOperationAction(ISD::ADD, MVT::i32, Legal);
  setOperationAction(ISD::SUB, MVT::i32, Legal);
  setOperationAction(ISD::AND, MVT::i32, Legal);
  setOperationAction(ISD::SMAX, MVT::i32, Legal);
  setOperationAction(ISD::SMIN, MVT::i32, Legal);

  setOperationAction(ISD::ADDC, MVT::i32, Legal);
  setOperationAction(ISD::ADDE, MVT::i32, Legal);
  setOperationAction(ISD::SUBC, MVT::i32, Legal);
  setOperationAction(ISD::SUBE, MVT::i32, Legal);

  // Need barrel shifter.
  setOperationAction(ISD::SHL, MVT::i32, Legal);
  setOperationAction(ISD::SRA, MVT::i32, Legal);
  setOperationAction(ISD::SRL, MVT::i32, Legal);
  setOperationAction(ISD::ROTR, MVT::i32, Legal);

  // SWAPE (the ARCompact full-32-bit byte-reversal instruction) has NO
  // encoding on ARC700 / BCM55030 -- it is an ARCv2-only opcode that this
  // silicon does not implement (confirmed by silicon characterization, see
  // docs/notes/isa-characterization.md). BSWAP must therefore never select
  // ARC_SWAPE_b_c on this profile. We Custom-lower ISD::BSWAP to a
  // mask/shift/or halfword-lane swap followed by ISD::ROTR by 16, which
  // reaches ISel already in Legal form and selects the existing `swap`
  // (halfword-exchange) instruction -- itself a real, present ARC700
  // instruction, unrelated to and unaffected by the absent SWAPE. The
  // bswap->SWAPE Pat in ARCARCompactPatterns.td is gated behind the
  // off-by-default HasSwape predicate so it can never fire here; it exists
  // only for a hypothetical future ARCv2-word CPU that genuinely has swape.
  //
  // ABS executes on this silicon (wrapping, non-saturating: ABS(INT_MIN) ==
  // INT_MIN) and keeps its single-instruction Legal lowering + Pat below.
  setOperationAction(ISD::BSWAP, MVT::i32, Custom);
  setOperationAction(ISD::ABS, MVT::i32, Legal);

  setOperationAction(ISD::Constant, MVT::i32, Legal);
  setOperationAction(ISD::UNDEF, MVT::i32, Legal);

  // 32x32 multiply is an optional extension. On ARC700 cores without
  // MULTIPLY_BUILD (reads 0 on such cores), mul/mulhs/mulhu must lower to
  // compiler-rt libcalls — __mulsi3, __mulhisi3 (MULHS i16→i32), and the
  // 64-bit helpers via LibCallLoweringInfo. Using LibCall here keeps the
  // legalizer away from mpy/mpym/mpymu which the backend can no longer
  // select once the TableGen patterns are gated behind HasMPY.
  if (Subtarget.hasMPY()) {
    setOperationAction(ISD::MUL, MVT::i32, Legal);
    setOperationAction(ISD::MULHS, MVT::i32, Legal);
    setOperationAction(ISD::MULHU, MVT::i32, Legal);
  } else {
    setOperationAction(ISD::MUL, MVT::i32, LibCall);
    setOperationAction(ISD::MULHS, MVT::i32, LibCall);
    setOperationAction(ISD::MULHU, MVT::i32, LibCall);
    // Also lower 64-bit multiply and SMUL_LOHI/UMUL_LOHI via libcalls.
    setOperationAction(ISD::SMUL_LOHI, MVT::i32, LibCall);
    setOperationAction(ISD::UMUL_LOHI, MVT::i32, LibCall);
  }
  setOperationAction(ISD::LOAD, MVT::i32, Legal);
  setOperationAction(ISD::STORE, MVT::i32, Legal);

  setOperationAction(ISD::SELECT_CC, MVT::i32, Custom);
  setOperationAction(ISD::BR_CC, MVT::i32, Custom);
  setOperationAction(ISD::BRCOND, MVT::Other, Expand);
  setOperationAction(ISD::BR_JT, MVT::Other, Expand);
  setOperationAction(ISD::JumpTable, MVT::i32, Custom);

  // Have pseudo instruction for frame addresses.
  setOperationAction(ISD::FRAMEADDR, MVT::i32, Legal);
  // Custom lower global addresses.
  setOperationAction(ISD::GlobalAddress, MVT::i32, Custom);
  // Custom lower constant pool entries — needed by the CTTZ de Bruijn
  // lookup-table expansion and by soft-float constants.
  setOperationAction(ISD::ConstantPool, MVT::i32, Custom);

  // Expand var-args ops.
  setOperationAction(ISD::VASTART, MVT::Other, Custom);
  setOperationAction(ISD::VAEND, MVT::Other, Expand);
  setOperationAction(ISD::VAARG, MVT::Other, Expand);
  setOperationAction(ISD::VACOPY, MVT::Other, Expand);

  // Other expansions
  setOperationAction(ISD::STACKSAVE, MVT::Other, Expand);
  setOperationAction(ISD::STACKRESTORE, MVT::Other, Expand);

  // Sign extend inreg
  setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i1, Custom);

  // ARC700/ARCompact lacks sexb/sexh. Expand to shl+ashr pair so the
  // legalizer materialises the sign extension via plain shifts.
  if (!Subtarget.hasSEXT()) {
    setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i8, Expand);
    setOperationAction(ISD::SIGN_EXTEND_INREG, MVT::i16, Expand);
  }

  // CTLZ/CTTZ are Legal when the target has fls/ffs (ARCv2). ARCompact
  // (ARC600/ARC700) lacks bit-scan instructions, so we expand every
  // count-bits opcode to shift/or + popcount, and CTPOP itself to the
  // generic bit-twiddle sequence. This avoids a compiler-rt dependency
  // (no __clzsi2/__ctzsi2/__popcountsi2 libcall in the sysroot) and
  // matches what compiler_builtins would emit anyway.
  //
  // ConvertNodeToLibcall has no case for plain ISD::CTLZ, so a LibCall
  // action on that opcode is a trap — the node survives legalization
  // and reaches ISel as "Cannot select". Hence Expand for all four
  // and for CTPOP (whose default action is Legal).
  if (Subtarget.hasBitScan()) {
    setOperationAction(ISD::CTLZ, MVT::i32, Legal);
    setOperationAction(ISD::CTLZ_ZERO_UNDEF, MVT::i32, Legal);
    setOperationAction(ISD::CTTZ, MVT::i32, Legal);
    setOperationAction(ISD::CTTZ_ZERO_UNDEF, MVT::i32, Legal);
  } else {
    setOperationAction(ISD::CTLZ, MVT::i32, Expand);
    // CTLZ_ZERO_UNDEF escapes the default Expand path on some DAG shapes
    // (late-combiner insertions from overflow-check / non-zero
    // leading_zeros expansions in debug / opt-level=s Rust codegen).
    // Custom-lower to plain CTLZ which then Expand-legalizes to the
    // shift-OR + popcount bit-twiddle sequence.
    setOperationAction(ISD::CTLZ_ZERO_UNDEF, MVT::i32, Custom);
    setOperationAction(ISD::CTTZ, MVT::i32, Expand);
    setOperationAction(ISD::CTTZ_ZERO_UNDEF, MVT::i32, Custom);
    setOperationAction(ISD::CTPOP, MVT::i32, Expand);
  }

  setOperationAction(ISD::READCYCLECOUNTER, MVT::i32, Legal);
  setOperationAction(ISD::READCYCLECOUNTER, MVT::i64,
                     isTypeLegal(MVT::i64) ? Legal : Custom);

  setMaxAtomicSizeInBitsSupported(0);

  // Inline fixed-size memcpy/memset/memmove as ld/st runs instead of calling
  // the compiler-rt helpers. ARC700 has 32-bit word load/store only, so each
  // store covers up to 4 bytes; 16 stores inlines an aligned 64-byte copy. The
  // base defaults (8 / 4) collapse every copy >32B (>16B at -Oz) to a `bl`.
  MaxStoresPerMemcpy = 16;
  MaxStoresPerMemcpyOptSize = 8;
  MaxStoresPerMemset = 16;
  MaxStoresPerMemsetOptSize = 8;
  MaxStoresPerMemmove = 16;
  MaxStoresPerMemmoveOptSize = 8;
}

//===----------------------------------------------------------------------===//
//  Misc Lower Operation implementation
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Inline assembly constraint handling
//===----------------------------------------------------------------------===//

TargetLowering::ConstraintType
ARCTargetLowering::getConstraintType(StringRef Constraint) const {
  if (Constraint.size() == 1) {
    switch (Constraint[0]) {
    case 'r':
      return C_RegisterClass;
    default:
      break;
    }
  }
  return TargetLowering::getConstraintType(Constraint);
}

std::pair<unsigned, const TargetRegisterClass *>
ARCTargetLowering::getRegForInlineAsmConstraint(const TargetRegisterInfo *TRI,
                                                 StringRef Constraint,
                                                 MVT VT) const {
  if (Constraint.size() == 1 && Constraint[0] == 'r')
    return std::make_pair(0U, &ARC::GPR32RegClass);

  return TargetLowering::getRegForInlineAsmConstraint(TRI, Constraint, VT);
}

SDValue ARCTargetLowering::LowerSELECT_CC(SDValue Op, SelectionDAG &DAG) const {
  SDValue LHS = Op.getOperand(0);
  SDValue RHS = Op.getOperand(1);
  ISD::CondCode CC = cast<CondCodeSDNode>(Op.getOperand(4))->get();
  SDValue TVal = Op.getOperand(2);
  SDValue FVal = Op.getOperand(3);
  SDLoc dl(Op);
  ARCCC::CondCode ArcCC = ISDCCtoARCCC(CC);
  assert(LHS.getValueType() == MVT::i32 && "Only know how to SELECT_CC i32");
  SDValue Cmp = DAG.getNode(ARCISD::CMP, dl, MVT::Glue, LHS, RHS);
  return DAG.getNode(ARCISD::CMOV, dl, TVal.getValueType(), TVal, FVal,
                     DAG.getConstant(ArcCC, dl, MVT::i32), Cmp);
}

SDValue ARCTargetLowering::LowerSIGN_EXTEND_INREG(SDValue Op,
                                                  SelectionDAG &DAG) const {
  SDValue Op0 = Op.getOperand(0);
  SDLoc dl(Op);
  assert(Op.getValueType() == MVT::i32 &&
         "Unhandled target sign_extend_inreg.");
  // These are legal
  unsigned Width = cast<VTSDNode>(Op.getOperand(1))->getVT().getSizeInBits();
  if (Width == 16 || Width == 8)
    return Op;
  if (Width >= 32) {
    return {};
  }
  SDValue LS = DAG.getNode(ISD::SHL, dl, MVT::i32, Op0,
                           DAG.getConstant(32 - Width, dl, MVT::i32));
  SDValue SR = DAG.getNode(ISD::SRA, dl, MVT::i32, LS,
                           DAG.getConstant(32 - Width, dl, MVT::i32));
  return SR;
}

SDValue ARCTargetLowering::LowerBSWAP(SDValue Op, SelectionDAG &DAG) const {
  SDLoc dl(Op);
  EVT VT = Op.getValueType();
  assert(VT == MVT::i32 && "Only know how to BSWAP i32");
  SDValue X = Op.getOperand(0);
  SDValue Mask = DAG.getConstant(0x00FF00FFU, dl, VT);
  EVT ShVT = getShiftAmountTy(VT, DAG.getDataLayout());
  // t = ((x & 0x00FF00FF) << 8) | ((x >> 8) & 0x00FF00FF)
  // This swaps byte 0<->1 and byte 2<->3 within each halfword lane.
  SDValue Lo = DAG.getNode(ISD::SHL, dl, VT,
                           DAG.getNode(ISD::AND, dl, VT, X, Mask),
                           DAG.getConstant(8, dl, ShVT));
  SDValue Hi = DAG.getNode(ISD::AND, dl, VT,
                           DAG.getNode(ISD::SRL, dl, VT, X,
                                       DAG.getConstant(8, dl, ShVT)),
                           Mask);
  SDValue T = DAG.getNode(ISD::OR, dl, VT, Lo, Hi);
  // bswap(x) = SWAP(t) -- exchange the two halfword lanes. ISD::ROTR by 16
  // is Legal (set above) and the existing
  // Pat<(rotr GPR32:$c, (i32 16)), (ARC_SWAP_b_c GPR32:$c)> in
  // ARCARCompactPatterns.td selects it directly to the real ARC700 `swap`
  // instruction. Do NOT use ROTL here: it is not marked Legal (falls
  // through the blanket Expand set at the top of this constructor) and
  // would re-enter legalization instead of hitting the SWAP Pat.
  return DAG.getNode(ISD::ROTR, dl, VT, T, DAG.getConstant(16, dl, ShVT));
}

SDValue ARCTargetLowering::LowerBR_CC(SDValue Op, SelectionDAG &DAG) const {
  SDValue Chain = Op.getOperand(0);
  ISD::CondCode CC = cast<CondCodeSDNode>(Op.getOperand(1))->get();
  SDValue LHS = Op.getOperand(2);
  SDValue RHS = Op.getOperand(3);
  SDValue Dest = Op.getOperand(4);
  SDLoc dl(Op);

  ARCCC::CondCode arcCC = ISDCCtoARCCC(CC);
  assert(LHS.getValueType() == MVT::i32 && "Only know how to BR_CC i32");
  return DAG.getNode(ARCISD::BRcc, dl, MVT::Other, Chain, Dest, LHS, RHS,
                     DAG.getConstant(arcCC, dl, MVT::i32));
}

SDValue ARCTargetLowering::LowerJumpTable(SDValue Op, SelectionDAG &DAG) const {
  auto *N = cast<JumpTableSDNode>(Op);
  SDValue GA = DAG.getTargetJumpTable(N->getIndex(), MVT::i32);
  return DAG.getNode(ARCISD::GAWRAPPER, SDLoc(N), MVT::i32, GA);
}

#include "ARCGenCallingConv.inc"

//===----------------------------------------------------------------------===//
//                  Call Calling Convention Implementation
//===----------------------------------------------------------------------===//

/// ARC call implementation
SDValue ARCTargetLowering::LowerCall(TargetLowering::CallLoweringInfo &CLI,
                                     SmallVectorImpl<SDValue> &InVals) const {
  SelectionDAG &DAG = CLI.DAG;
  SDLoc &dl = CLI.DL;
  SmallVectorImpl<ISD::OutputArg> &Outs = CLI.Outs;
  SmallVectorImpl<SDValue> &OutVals = CLI.OutVals;
  SmallVectorImpl<ISD::InputArg> &Ins = CLI.Ins;
  SDValue Chain = CLI.Chain;
  SDValue Callee = CLI.Callee;
  CallingConv::ID CallConv = CLI.CallConv;
  bool IsVarArg = CLI.IsVarArg;
  bool &IsTailCall = CLI.IsTailCall;
  bool WantTail = IsTailCall; // frontend hint (call in tail position)
  IsTailCall = false;

  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), ArgLocs,
                 *DAG.getContext());

  CCInfo.AnalyzeCallOperands(Outs, CC_ARC);

  // Tail-call eligibility (conservative): direct call (GA/extsym) under the
  // C/Fast conv, no varargs, and every argument in a register (no outgoing
  // stack args). The frontend already gates WantTail on tail position + a
  // compatible return, so we trust it for the return contract. Indirect tail
  // calls and stack-arg tail calls are left as normal calls.
  bool CalleeIsDirect =
      isa<GlobalAddressSDNode>(Callee) || isa<ExternalSymbolSDNode>(Callee);
  if (WantTail && !IsVarArg && CalleeIsDirect &&
      (CallConv == CallingConv::C || CallConv == CallingConv::Fast)) {
    IsTailCall = true;
    for (const CCValAssign &VA : ArgLocs)
      if (!VA.isRegLoc()) {
        IsTailCall = false;
        break;
      }
  }

  SmallVector<CCValAssign, 16> RVLocs;
  // Analyze return values to determine the number of bytes of stack required.
  CCState RetCCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), RVLocs,
                    *DAG.getContext());
  RetCCInfo.AllocateStack(CCInfo.getStackSize(), Align(4));
  RetCCInfo.AnalyzeCallResult(Ins, RetCC_ARC);

  // Get a count of how many bytes are to be pushed on the stack.
  unsigned NumBytes = RetCCInfo.getStackSize();

  // A tail call has no outgoing stack args (eligibility required all-reg args)
  // and reuses the caller's frame, so no call-frame sequence is emitted.
  if (!IsTailCall)
    Chain = DAG.getCALLSEQ_START(Chain, NumBytes, 0, dl);

  SmallVector<std::pair<unsigned, SDValue>, 4> RegsToPass;
  SmallVector<SDValue, 12> MemOpChains;

  SDValue StackPtr;
  // Walk the register/memloc assignments, inserting copies/loads.
  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    CCValAssign &VA = ArgLocs[i];
    SDValue Arg = OutVals[i];

    // Promote the value if needed.
    switch (VA.getLocInfo()) {
    default:
      llvm_unreachable("Unknown loc info!");
    case CCValAssign::Full:
      break;
    case CCValAssign::SExt:
      Arg = DAG.getNode(ISD::SIGN_EXTEND, dl, VA.getLocVT(), Arg);
      break;
    case CCValAssign::ZExt:
      Arg = DAG.getNode(ISD::ZERO_EXTEND, dl, VA.getLocVT(), Arg);
      break;
    case CCValAssign::AExt:
      Arg = DAG.getNode(ISD::ANY_EXTEND, dl, VA.getLocVT(), Arg);
      break;
    }

    // Arguments that can be passed on register must be kept at
    // RegsToPass vector
    if (VA.isRegLoc()) {
      RegsToPass.push_back(std::make_pair(VA.getLocReg(), Arg));
    } else {
      assert(VA.isMemLoc() && "Must be register or memory argument.");
      if (!StackPtr.getNode())
        StackPtr = DAG.getCopyFromReg(Chain, dl, ARC::SP,
                                      getPointerTy(DAG.getDataLayout()));
      // Calculate the stack position.
      SDValue SOffset = DAG.getIntPtrConstant(VA.getLocMemOffset(), dl);
      SDValue PtrOff = DAG.getNode(
          ISD::ADD, dl, getPointerTy(DAG.getDataLayout()), StackPtr, SOffset);

      SDValue Store =
          DAG.getStore(Chain, dl, Arg, PtrOff, MachinePointerInfo());
      MemOpChains.push_back(Store);
      IsTailCall = false;
    }
  }

  // Transform all store nodes into one single node because
  // all store nodes are independent of each other.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, MemOpChains);

  // Build a sequence of copy-to-reg nodes chained together with token
  // chain and flag operands which copy the outgoing args into registers.
  // The Glue in necessary since all emitted instructions must be
  // stuck together.
  SDValue Glue;
  for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i) {
    Chain = DAG.getCopyToReg(Chain, dl, RegsToPass[i].first,
                             RegsToPass[i].second, Glue);
    Glue = Chain.getValue(1);
  }

  // If the callee is a GlobalAddress node (quite common, every direct call is)
  // turn it into a TargetGlobalAddress node so that legalize doesn't hack it.
  // Likewise ExternalSymbol -> TargetExternalSymbol.
  bool IsDirect = true;
  if (auto *G = dyn_cast<GlobalAddressSDNode>(Callee))
    Callee = DAG.getTargetGlobalAddress(G->getGlobal(), dl, MVT::i32);
  else if (auto *E = dyn_cast<ExternalSymbolSDNode>(Callee))
    Callee = DAG.getTargetExternalSymbol(E->getSymbol(), MVT::i32);
  else
    IsDirect = false;
  // Branch + Link = #chain, #target_address, #opt_in_flags...
  //             = Chain, Callee, Reg#1, Reg#2, ...
  //
  // Returns a chain & a glue for retval copy to use.
  SDVTList NodeTys = DAG.getVTList(MVT::Other, MVT::Glue);
  SmallVector<SDValue, 8> Ops;
  Ops.push_back(Chain);
  Ops.push_back(Callee);

  for (unsigned i = 0, e = RegsToPass.size(); i != e; ++i)
    Ops.push_back(DAG.getRegister(RegsToPass[i].first,
                                  RegsToPass[i].second.getValueType()));

  // Add a register mask operand representing the call-preserved registers.
  const TargetRegisterInfo *TRI = Subtarget.getRegisterInfo();
  const uint32_t *Mask =
      TRI->getCallPreservedMask(DAG.getMachineFunction(), CallConv);
  assert(Mask && "Missing call preserved mask for calling convention");
  Ops.push_back(DAG.getRegisterMask(Mask));

  if (Glue.getNode())
    Ops.push_back(Glue);

  // Tail call: emit the terminator return-jump. PEI inserts the epilogue before
  // it (frame teardown); TCRETURN_di then expands to `mov r12,@callee; j[r12]`.
  // No CALLSEQ_END / result copy -- the callee returns straight to our caller.
  if (IsTailCall)
    return DAG.getNode(ARCISD::TC_RETURN, dl, MVT::Other, Ops);

  Chain = DAG.getNode(IsDirect ? ARCISD::BL : ARCISD::JL, dl, NodeTys, Ops);
  Glue = Chain.getValue(1);

  // Create the CALLSEQ_END node.
  Chain = DAG.getCALLSEQ_END(Chain, NumBytes, 0, Glue, dl);
  Glue = Chain.getValue(1);

  // Handle result values, copying them out of physregs into vregs that we
  // return.
  if (IsTailCall)
    return Chain;
  return lowerCallResult(Chain, Glue, RVLocs, dl, DAG, InVals);
}

/// Lower the result values of a call into the appropriate copies out of
/// physical registers / memory locations.
static SDValue lowerCallResult(SDValue Chain, SDValue Glue,
                               const SmallVectorImpl<CCValAssign> &RVLocs,
                               SDLoc dl, SelectionDAG &DAG,
                               SmallVectorImpl<SDValue> &InVals) {
  SmallVector<std::pair<int, unsigned>, 4> ResultMemLocs;
  // Copy results out of physical registers.
  for (unsigned i = 0, e = RVLocs.size(); i != e; ++i) {
    const CCValAssign &VA = RVLocs[i];
    if (VA.isRegLoc()) {
      SDValue RetValue;
      RetValue =
          DAG.getCopyFromReg(Chain, dl, VA.getLocReg(), VA.getValVT(), Glue);
      Chain = RetValue.getValue(1);
      Glue = RetValue.getValue(2);
      InVals.push_back(RetValue);
    } else {
      assert(VA.isMemLoc() && "Must be memory location.");
      ResultMemLocs.push_back(
          std::make_pair(VA.getLocMemOffset(), InVals.size()));

      // Reserve space for this result.
      InVals.push_back(SDValue());
    }
  }

  // Copy results out of memory.
  SmallVector<SDValue, 4> MemOpChains;
  for (unsigned i = 0, e = ResultMemLocs.size(); i != e; ++i) {
    int Offset = ResultMemLocs[i].first;
    unsigned Index = ResultMemLocs[i].second;
    SDValue StackPtr = DAG.getRegister(ARC::SP, MVT::i32);
    SDValue SpLoc = DAG.getNode(ISD::ADD, dl, MVT::i32, StackPtr,
                                DAG.getConstant(Offset, dl, MVT::i32));
    SDValue Load =
        DAG.getLoad(MVT::i32, dl, Chain, SpLoc, MachinePointerInfo());
    InVals[Index] = Load;
    MemOpChains.push_back(Load.getValue(1));
  }

  // Transform all loads nodes into one single node because
  // all load nodes are independent of each other.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, MemOpChains);

  return Chain;
}

//===----------------------------------------------------------------------===//
//             Formal Arguments Calling Convention Implementation
//===----------------------------------------------------------------------===//

namespace {

struct ArgDataPair {
  SDValue SDV;
  ISD::ArgFlagsTy Flags;
};

} // end anonymous namespace

/// ARC formal arguments implementation
SDValue ARCTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &dl,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {
  switch (CallConv) {
  default:
    llvm_unreachable("Unsupported calling convention");
  case CallingConv::C:
  case CallingConv::Fast:
    return LowerCallArguments(Chain, CallConv, IsVarArg, Ins, dl, DAG, InVals);
  }
}

/// Transform physical registers into virtual registers, and generate load
/// operations for argument places on the stack.
SDValue ARCTargetLowering::LowerCallArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, SDLoc dl, SelectionDAG &DAG,
    SmallVectorImpl<SDValue> &InVals) const {
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  MachineRegisterInfo &RegInfo = MF.getRegInfo();
  auto *AFI = MF.getInfo<ARCFunctionInfo>();

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), ArgLocs,
                 *DAG.getContext());

  CCInfo.AnalyzeFormalArguments(Ins, CC_ARC);

  unsigned StackSlotSize = 4;

  if (!IsVarArg)
    AFI->setReturnStackOffset(CCInfo.getStackSize());

  // All getCopyFromReg ops must precede any getMemcpys to prevent the
  // scheduler clobbering a register before it has been copied.
  // The stages are:
  // 1. CopyFromReg (and load) arg & vararg registers.
  // 2. Chain CopyFromReg nodes into a TokenFactor.
  // 3. Memcpy 'byVal' args & push final InVals.
  // 4. Chain mem ops nodes into a TokenFactor.
  SmallVector<SDValue, 4> CFRegNode;
  SmallVector<ArgDataPair, 4> ArgData;
  SmallVector<SDValue, 4> MemOps;

  // 1a. CopyFromReg (and load) arg registers.
  for (unsigned i = 0, e = ArgLocs.size(); i != e; ++i) {
    CCValAssign &VA = ArgLocs[i];
    SDValue ArgIn;

    if (VA.isRegLoc()) {
      // Arguments passed in registers
      EVT RegVT = VA.getLocVT();
      switch (RegVT.getSimpleVT().SimpleTy) {
      default: {
        LLVM_DEBUG(errs() << "LowerFormalArguments Unhandled argument type: "
                          << (unsigned)RegVT.getSimpleVT().SimpleTy << "\n");
        llvm_unreachable("Unhandled LowerFormalArguments type.");
      }
      case MVT::i32:
        unsigned VReg = RegInfo.createVirtualRegister(&ARC::GPR32RegClass);
        RegInfo.addLiveIn(VA.getLocReg(), VReg);
        ArgIn = DAG.getCopyFromReg(Chain, dl, VReg, RegVT);
        CFRegNode.push_back(ArgIn.getValue(ArgIn->getNumValues() - 1));
      }
    } else {
      // Only arguments passed on the stack should make it here.
      assert(VA.isMemLoc());
      // Load the argument to a virtual register
      unsigned ObjSize = VA.getLocVT().getStoreSize();
      assert((ObjSize <= StackSlotSize) && "Unhandled argument");

      // Create the frame index object for this incoming parameter...
      int FI = MFI.CreateFixedObject(ObjSize, VA.getLocMemOffset(), true);

      // Create the SelectionDAG nodes corresponding to a load
      // from this parameter
      SDValue FIN = DAG.getFrameIndex(FI, MVT::i32);
      ArgIn = DAG.getLoad(VA.getLocVT(), dl, Chain, FIN,
                          MachinePointerInfo::getFixedStack(MF, FI));
    }
    const ArgDataPair ADP = {ArgIn, Ins[i].Flags};
    ArgData.push_back(ADP);
  }

  // 1b. CopyFromReg vararg registers.
  if (IsVarArg) {
    // Argument registers
    static const MCPhysReg ArgRegs[] = {ARC::R0, ARC::R1, ARC::R2, ARC::R3,
                                        ARC::R4, ARC::R5, ARC::R6, ARC::R7};
    auto *AFI = MF.getInfo<ARCFunctionInfo>();
    unsigned FirstVAReg = CCInfo.getFirstUnallocated(ArgRegs);
    if (FirstVAReg < std::size(ArgRegs)) {
      int Offset = 0;
      // Save remaining registers, storing higher register numbers at a higher
      // address
      // There are (std::size(ArgRegs) - FirstVAReg) registers which
      // need to be saved.
      int VarFI = MFI.CreateFixedObject((std::size(ArgRegs) - FirstVAReg) * 4,
                                        CCInfo.getStackSize(), true);
      AFI->setVarArgsFrameIndex(VarFI);
      SDValue FIN = DAG.getFrameIndex(VarFI, MVT::i32);
      for (unsigned i = FirstVAReg; i < std::size(ArgRegs); i++) {
        // Move argument from phys reg -> virt reg
        unsigned VReg = RegInfo.createVirtualRegister(&ARC::GPR32RegClass);
        RegInfo.addLiveIn(ArgRegs[i], VReg);
        SDValue Val = DAG.getCopyFromReg(Chain, dl, VReg, MVT::i32);
        CFRegNode.push_back(Val.getValue(Val->getNumValues() - 1));
        SDValue VAObj = DAG.getNode(ISD::ADD, dl, MVT::i32, FIN,
                                    DAG.getConstant(Offset, dl, MVT::i32));
        // Move argument from virt reg -> stack
        SDValue Store =
            DAG.getStore(Val.getValue(1), dl, Val, VAObj, MachinePointerInfo());
        MemOps.push_back(Store);
        Offset += 4;
      }
    } else {
      llvm_unreachable("Too many var args parameters.");
    }
  }

  // 2. Chain CopyFromReg nodes into a TokenFactor.
  if (!CFRegNode.empty())
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, CFRegNode);

  // 3. Memcpy 'byVal' args & push final InVals.
  // Aggregates passed "byVal" need to be copied by the callee.
  // The callee will use a pointer to this copy, rather than the original
  // pointer.
  for (const auto &ArgDI : ArgData) {
    if (ArgDI.Flags.isByVal() && ArgDI.Flags.getByValSize()) {
      unsigned Size = ArgDI.Flags.getByValSize();
      Align Alignment =
          std::max(Align(StackSlotSize), ArgDI.Flags.getNonZeroByValAlign());
      // Create a new object on the stack and copy the pointee into it.
      int FI = MFI.CreateStackObject(Size, Alignment, false);
      SDValue FIN = DAG.getFrameIndex(FI, MVT::i32);
      InVals.push_back(FIN);
      MemOps.push_back(DAG.getMemcpy(
          Chain, dl, FIN, ArgDI.SDV, DAG.getConstant(Size, dl, MVT::i32),
          Alignment, false, false, /*CI=*/nullptr, false, MachinePointerInfo(),
          MachinePointerInfo()));
    } else {
      InVals.push_back(ArgDI.SDV);
    }
  }

  // 4. Chain mem ops nodes into a TokenFactor.
  if (!MemOps.empty()) {
    MemOps.push_back(Chain);
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, MemOps);
  }

  return Chain;
}

//===----------------------------------------------------------------------===//
//               Return Value Calling Convention Implementation
//===----------------------------------------------------------------------===//

bool ARCTargetLowering::CanLowerReturn(
    CallingConv::ID CallConv, MachineFunction &MF, bool IsVarArg,
    const SmallVectorImpl<ISD::OutputArg> &Outs, LLVMContext &Context,
    const Type *RetTy) const {
  SmallVector<CCValAssign, 16> RVLocs;
  CCState CCInfo(CallConv, IsVarArg, MF, RVLocs, Context);
  if (!CCInfo.CheckReturn(Outs, RetCC_ARC))
    return false;
  if (CCInfo.getStackSize() != 0 && IsVarArg)
    return false;
  return true;
}

SDValue
ARCTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                               bool IsVarArg,
                               const SmallVectorImpl<ISD::OutputArg> &Outs,
                               const SmallVectorImpl<SDValue> &OutVals,
                               const SDLoc &dl, SelectionDAG &DAG) const {
  auto *AFI = DAG.getMachineFunction().getInfo<ARCFunctionInfo>();
  MachineFrameInfo &MFI = DAG.getMachineFunction().getFrameInfo();

  // CCValAssign - represent the assignment of
  // the return value to a location
  SmallVector<CCValAssign, 16> RVLocs;

  // CCState - Info about the registers and stack slot.
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), RVLocs,
                 *DAG.getContext());

  // Analyze return values.
  if (!IsVarArg)
    CCInfo.AllocateStack(AFI->getReturnStackOffset(), Align(4));

  CCInfo.AnalyzeReturn(Outs, RetCC_ARC);

  SDValue Glue;
  SmallVector<SDValue, 4> RetOps(1, Chain);
  SmallVector<SDValue, 4> MemOpChains;
  // Handle return values that must be copied to memory.
  for (unsigned i = 0, e = RVLocs.size(); i != e; ++i) {
    CCValAssign &VA = RVLocs[i];
    if (VA.isRegLoc())
      continue;
    assert(VA.isMemLoc());
    if (IsVarArg) {
      report_fatal_error("Can't return value from vararg function in memory");
    }

    int Offset = VA.getLocMemOffset();
    unsigned ObjSize = VA.getLocVT().getStoreSize();
    // Create the frame index object for the memory location.
    int FI = MFI.CreateFixedObject(ObjSize, Offset, false);

    // Create a SelectionDAG node corresponding to a store
    // to this memory location.
    SDValue FIN = DAG.getFrameIndex(FI, MVT::i32);
    MemOpChains.push_back(DAG.getStore(
        Chain, dl, OutVals[i], FIN,
        MachinePointerInfo::getFixedStack(DAG.getMachineFunction(), FI)));
  }

  // Transform all store nodes into one single node because
  // all stores are independent of each other.
  if (!MemOpChains.empty())
    Chain = DAG.getNode(ISD::TokenFactor, dl, MVT::Other, MemOpChains);

  // Now handle return values copied to registers.
  for (unsigned i = 0, e = RVLocs.size(); i != e; ++i) {
    CCValAssign &VA = RVLocs[i];
    if (!VA.isRegLoc())
      continue;
    // Copy the result values into the output registers.
    Chain = DAG.getCopyToReg(Chain, dl, VA.getLocReg(), OutVals[i], Glue);

    // guarantee that all emitted copies are
    // stuck together, avoiding something bad
    Glue = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
  }

  RetOps[0] = Chain; // Update chain.

  // Add the glue if we have it.
  if (Glue.getNode())
    RetOps.push_back(Glue);

  // What to do with the RetOps?
  return DAG.getNode(ARCISD::RET, dl, MVT::Other, RetOps);
}

//===----------------------------------------------------------------------===//
// Target Optimization Hooks
//===----------------------------------------------------------------------===//

SDValue ARCTargetLowering::PerformDAGCombine(SDNode *N,
                                             DAGCombinerInfo &DCI) const {
  return {};
}

// ARC700 has no hardware multiplier, so `mul x, C` would otherwise lower to a
// __mulsi3 libcall (push blink / mov C / bl / pop blink). For constants of the
// form 2^N±1 / 2^N±2^M the generic DAGCombiner.visitMUL decomposition (gated on
// this hook) rewrites the multiply into shl + add/sub, which select to the
// already-emitted asl/add/sub (and add1/add2/add3 scaled-adds for x*3/5/9) —
// 1-3 single-cycle ALU ops instead of a call. Constants that don't match the
// two-term shapes keep the libcall path automatically.
bool ARCTargetLowering::decomposeMulByConstant(LLVMContext &Context, EVT VT,
                                               SDValue C) const {
  // With a hardware multiplier MUL is Legal and decomposition is undesirable.
  if (Subtarget.hasMPY())
    return false;
  if (VT != MVT::i32)
    return false;
  auto *CN = dyn_cast<ConstantSDNode>(C);
  if (!CN)
    return false;
  // Mirror EXACTLY the predicate under which DAGCombiner::visitMUL sets its
  // MathOp (see DAGCombiner.cpp, "multiply-by-(power-of-2 +/- power-of-2)"):
  // take the magnitude, strip the trailing-zero 2^M factor, then require the
  // residue to be 2^N±1. This covers BOTH the single-term 2^N±1 shapes
  // (3,5,9,15,17,33,…) and the two-term 2^N±2^M shapes (6,12,20,24,40,48,…) —
  // every constant the generic combine can turn into <=2 shifts + 1 add/sub.
  // The previous predicate omitted the trailing-zero strip, so e.g. C=12 (=
  // 0b1100 = (x<<3)+(x<<2)) fell through to a __mulsi3 libcall in a hot loop.
  APInt MulC = CN->getAPIntValue().abs();
  unsigned TZeros = MulC == 2 ? 0 : MulC.countr_zero();
  MulC.lshrInPlace(TZeros);
  return (MulC - 1).isPowerOf2() || (MulC + 1).isPowerOf2();
}

//===----------------------------------------------------------------------===//
//  Addressing mode description hooks
//===----------------------------------------------------------------------===//

/// Return true if the addressing mode represented by AM is legal for this
/// target, for a load/store of the specified type.
bool ARCTargetLowering::isLegalAddressingMode(const DataLayout &DL,
                                              const AddrMode &AM, Type *Ty,
                                              unsigned AS,
                                              Instruction *I) const {
  // Allow reg + reg<<2 (the scaled `ld.as` word addressing mode) so LSR keeps
  // an indexed word access folded instead of pre-computing the scaled add.
  return AM.Scale == 0 ||
         (AM.Scale == 4 && !AM.BaseGV && AM.BaseOffs == 0 && AM.HasBaseReg);
}

bool ARCTargetLowering::allowsMisalignedMemoryAccesses(
    EVT VT, unsigned AddrSpace, Align Alignment,
    MachineMemOperand::Flags Flags, unsigned *Fast) const {
  // ARC700/BCM55030 has no hardware unaligned-access fixup and no
  // STATUS32.AD "unaligned enable" behavior (that assumption was disproved
  // by silicon characterization -- see docs/notes/isa-characterization.md
  // and the deleted comment this replaces in ARCRegisterInfo.cpp).
  // Misaligned word/half-word loads/stores silently clear the low address
  // bits (word: addr & ~3, half-word: addr & ~1) instead of trapping or
  // being fixed up, so an under-aligned multi-byte access reads/writes the
  // wrong location without any error signal. Unconditionally report every
  // misaligned scalar access as neither legal nor fast, for every width and
  // address space, so callers (SelectionDAGBuilder / DAG Legalize / the
  // memcpy-inlining combine) never emit a naturally-misaligned LD/ST and
  // instead peel to byte/half-word operations.
  //
  // This is a pinning override, not a behavior change: TargetLoweringBase's
  // default implementation already returns false unconditionally, and
  // allowsMemoryAccessForAlignment() only calls into this hook once it has
  // already proven Alignment < the type's ABI alignment -- so the aligned
  // fast path (Alignment >= ABI align) never reaches this function and is
  // unaffected. Made explicit so behavior cannot silently change if a
  // future legalization/vectorization feature relies on a friendlier
  // generic default.
  (void)VT;
  (void)AddrSpace;
  (void)Alignment;
  (void)Flags;
  if (Fast)
    *Fast = 0;
  return false;
}

// Allow the generic code to mark calls as tail-call candidates; LowerCall
// applies the conservative eligibility (direct, C/Fast, no stack args).
bool ARCTargetLowering::mayBeEmittedAsTailCall(const CallInst *CI) const {
  return CI->isTailCall();
}

SDValue ARCTargetLowering::LowerFRAMEADDR(SDValue Op, SelectionDAG &DAG) const {
  const ARCRegisterInfo &ARI = *Subtarget.getRegisterInfo();
  MachineFunction &MF = DAG.getMachineFunction();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  MFI.setFrameAddressIsTaken(true);

  EVT VT = Op.getValueType();
  SDLoc dl(Op);
  assert(Op.getConstantOperandVal(0) == 0 &&
         "Only support lowering frame addr of current frame.");
  Register FrameReg = ARI.getFrameRegister(MF);
  return DAG.getCopyFromReg(DAG.getEntryNode(), dl, FrameReg, VT);
}

SDValue ARCTargetLowering::LowerGlobalAddress(SDValue Op,
                                              SelectionDAG &DAG) const {
  const GlobalAddressSDNode *GN = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = GN->getGlobal();
  SDLoc dl(GN);
  int64_t Offset = GN->getOffset();
  SDValue GA = DAG.getTargetGlobalAddress(GV, dl, MVT::i32, Offset);
  return DAG.getNode(ARCISD::GAWRAPPER, dl, MVT::i32, GA);
}

SDValue ARCTargetLowering::LowerConstantPool(SDValue Op,
                                              SelectionDAG &DAG) const {
  ConstantPoolSDNode *CP = cast<ConstantPoolSDNode>(Op);
  SDLoc dl(Op);
  SDValue Res;
  if (CP->isMachineConstantPoolEntry())
    Res = DAG.getTargetConstantPool(CP->getMachineCPVal(), MVT::i32,
                                    CP->getAlign(), CP->getOffset());
  else
    Res = DAG.getTargetConstantPool(CP->getConstVal(), MVT::i32, CP->getAlign(),
                                    CP->getOffset());
  return DAG.getNode(ARCISD::GAWRAPPER, dl, MVT::i32, Res);
}

static SDValue LowerVASTART(SDValue Op, SelectionDAG &DAG) {
  MachineFunction &MF = DAG.getMachineFunction();
  auto *FuncInfo = MF.getInfo<ARCFunctionInfo>();

  // vastart just stores the address of the VarArgsFrameIndex slot into the
  // memory location argument.
  SDLoc dl(Op);
  EVT PtrVT = DAG.getTargetLoweringInfo().getPointerTy(DAG.getDataLayout());
  SDValue FR = DAG.getFrameIndex(FuncInfo->getVarArgsFrameIndex(), PtrVT);
  const Value *SV = cast<SrcValueSDNode>(Op.getOperand(2))->getValue();
  return DAG.getStore(Op.getOperand(0), dl, FR, Op.getOperand(1),
                      MachinePointerInfo(SV));
}

SDValue ARCTargetLowering::LowerOperation(SDValue Op, SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  case ISD::GlobalAddress:
    return LowerGlobalAddress(Op, DAG);
  case ISD::ConstantPool:
    return LowerConstantPool(Op, DAG);
  case ISD::FRAMEADDR:
    return LowerFRAMEADDR(Op, DAG);
  case ISD::SELECT_CC:
    return LowerSELECT_CC(Op, DAG);
  case ISD::BR_CC:
    return LowerBR_CC(Op, DAG);
  case ISD::SIGN_EXTEND_INREG:
    return LowerSIGN_EXTEND_INREG(Op, DAG);
  case ISD::JumpTable:
    return LowerJumpTable(Op, DAG);
  case ISD::BSWAP:
    return LowerBSWAP(Op, DAG);
  case ISD::VASTART:
    return LowerVASTART(Op, DAG);
  case ISD::READCYCLECOUNTER:
    // As of LLVM 3.8, the lowering code insists that we customize it even
    // though we've declared the i32 version as legal. This is because it only
    // thinks i64 is the truly supported version. We've already converted the
    // i64 version to a widened i32.
    assert(Op.getSimpleValueType() == MVT::i32);
    return Op;
  case ISD::CTLZ_ZERO_UNDEF: {
    SDLoc dl(Op);
    EVT VT = Op.getValueType();
    SDValue X = Op.getOperand(0);
    if (Subtarget.hasNorm()) {
      // clz(x) = norm((unsigned)x >> 1) for x != 0 (NORM counts redundant
      // sign bits; shifting in a 0 MSB makes norm equal the leading-zero
      // count). Two instructions: lsr + norm.
      EVT ShVT = getShiftAmountTy(VT, DAG.getDataLayout());
      SDValue Sh =
          DAG.getNode(ISD::SRL, dl, VT, X, DAG.getConstant(1, dl, ShVT));
      return DAG.getNode(ARCISD::NORM, dl, VT, Sh);
    }
    // Hand-lower to the shift-OR + popcount bit-twiddle sequence from
    // Hacker's Delight. We cannot delegate to TargetLowering::expandCTLZ
    // or to plain ISD::CTLZ because both paths eventually construct a
    // CTLZ_ZERO_UNDEF node (expandCTLZ's LegalOrCustom check matches
    // our Custom action), which our Custom handler would re-lower and
    // spin into an infinite recursion.
    unsigned NumBits = VT.getScalarSizeInBits();
    EVT ShVT = getShiftAmountTy(VT, DAG.getDataLayout());
    for (unsigned i = 0; (1U << i) < NumBits; ++i) {
      SDValue Sh = DAG.getConstant(1ULL << i, dl, ShVT);
      X = DAG.getNode(ISD::OR, dl, VT, X,
                      DAG.getNode(ISD::SRL, dl, VT, X, Sh));
    }
    X = DAG.getNOT(dl, X, VT);
    return DAG.getNode(ISD::CTPOP, dl, VT, X);
  }
  case ISD::CTTZ_ZERO_UNDEF: {
    SDLoc dl(Op);
    EVT VT = Op.getValueType();
    SDValue X = Op.getOperand(0);
    SDValue Neg = DAG.getNegative(X, dl, VT);
    SDValue IsolateLow = DAG.getNode(ISD::AND, dl, VT, X, Neg);
    if (Subtarget.hasNorm()) {
      // ctz(x) = 31 - norm((x & -x) >> 1) for x != 0.
      EVT ShVT = getShiftAmountTy(VT, DAG.getDataLayout());
      SDValue Sh = DAG.getNode(ISD::SRL, dl, VT, IsolateLow,
                               DAG.getConstant(1, dl, ShVT));
      SDValue N = DAG.getNode(ARCISD::NORM, dl, VT, Sh);
      return DAG.getNode(ISD::SUB, dl, VT, DAG.getConstant(31, dl, VT), N);
    }
    // ctz(x) = popcount((x & -x) - 1)
    SDValue Mask = DAG.getNode(ISD::SUB, dl, VT, IsolateLow,
                               DAG.getConstant(1, dl, VT));
    return DAG.getNode(ISD::CTPOP, dl, VT, Mask);
  }
  default:
    llvm_unreachable("unimplemented operand");
  }
}
