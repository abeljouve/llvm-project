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
#include "ARCTargetTransformInfo.h"
#include "MCTargetDesc/ARCInfo.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"
#include <algorithm>
#include <optional>

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

  // Bounded scaled-add synthesis for `mul x, C` on cores without a hardware
  // multiplier -- see performMULCombine / synthesizeConstMul below and
  // docs/llvm-arc700-optimizations/02-constant-multiplication.md. Registered
  // unconditionally; the per-node handler itself gates on
  // !Subtarget.hasMPY() so this is a no-op when MUL is Legal.
  setTargetDAGCombine(ISD::MUL);

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

//===----------------------------------------------------------------------===//
//  Bounded constant-multiply synthesizer (no HW multiplier)
//
//  See docs/llvm-arc700-optimizations/02-constant-multiplication.md and
//  docs/notes/isa-characterization.md section 4.1 for the primitive set.
//
//  Synthesizes `mul x, C` (ARC700 / !Subtarget.hasMPY()) into a bounded
//  chain of the seven silicon-characterized 1-instruction ARCompact
//  primitives -- ADD, SUB, NEG, immediate ASL, and ADD1/2/3 & SUB1/2/3
//  scaled-adds -- instead of a `bl __mulsi3` libcall. Every primitive is
//  LINEAR in its x-derived operand(s) over Z/2^32Z and the seed `x` is the
//  only free variable ever injected, so any recipe built purely from these
//  primitives computes exactly `K*x mod 2^32` for a fixed K determined by
//  the op sequence -- checking `interpret(recipe, 1) == C` is therefore
//  mathematically sufficient to prove correctness for every x (see the
//  NDEBUG-gated asserts in synthesizeConstMul).
//===----------------------------------------------------------------------===//

namespace {

// One step of a synthesized recipe. Operand references are indices into the
// SAME SynthRecipe::Steps vector: 0 means "the seed x", N>0 means
// "the result of Steps[N-1]". This is an ABSTRACT recipe -- never an
// SDValue/SDNode pointer -- so it is safe to memoize across unrelated
// SelectionDAGs (different functions / a persistent cache).
enum class StepOp : uint8_t { Shl, Add, Sub, AddSh, SubSh, Neg };

struct Step {
  StepOp Op;
  uint8_t Imm = 0;  // shift amount, for Shl/AddSh/SubSh only.
  int32_t Lhs = 0;  // operand ref (0 = seed x).
  int32_t Rhs = 0;  // operand ref (0 = seed x); unused by Shl/Neg.
};

// A self-contained recipe: Steps.back() (or the seed x, if Steps is empty)
// is the result. Cost == Steps.size() == instruction count, since every
// Step above is exactly one 4-byte ARCompact instruction and none of them
// ever carries a runtime-materialized immediate (shift amounts are
// compile-time-fixed opcode operands, not DAG leaves), so no LIMM is ever
// needed by a synthesized sequence.
struct SynthRecipe {
  bool Found = false;
  SmallVector<Step, 8> Steps;

  // ref to this recipe's own result, for use as an operand of the NEXT step
  // a caller appends.
  int32_t root() const { return static_cast<int32_t>(Steps.size()); }

  static SynthRecipe seed() {
    SynthRecipe R;
    R.Found = true; // Steps empty -> root() == 0 == the seed x itself.
    return R;
  }

  // Append `Op(Operand.root() [, Imm])`, i.e. a unary/Shl/Neg step.
  static SynthRecipe unary(StepOp Op, uint8_t Imm, const SynthRecipe &Operand) {
    SynthRecipe R;
    if (!Operand.Found)
      return R;
    R.Steps = Operand.Steps;
    R.Steps.push_back(Step{Op, Imm, Operand.root(), 0});
    R.Found = true;
    return R;
  }

  // Append `Op(Operand.root(), Operand.root() [, Imm])` -- self-peel: BOTH
  // operands reference the SAME earlier step, giving free CSE by
  // construction (e.g. ADD1(t,t) for a *3 self-peel), never a duplicated
  // subexpression.
  static SynthRecipe binarySelf(StepOp Op, uint8_t Imm,
                                const SynthRecipe &Operand) {
    SynthRecipe R;
    if (!Operand.Found)
      return R;
    R.Steps = Operand.Steps;
    int32_t Root = Operand.root();
    R.Steps.push_back(Step{Op, Imm, Root, Root});
    R.Found = true;
    return R;
  }

  // Append `Op(Operand.root(), x [, Imm])` -- the "adjacent bump" shape,
  // combining a recursed sub-recipe with the free seed.
  static SynthRecipe withSeedRhs(StepOp Op, uint8_t Imm,
                                 const SynthRecipe &Operand) {
    SynthRecipe R;
    if (!Operand.Found)
      return R;
    R.Steps = Operand.Steps;
    R.Steps.push_back(Step{Op, Imm, Operand.root(), 0});
    R.Found = true;
    return R;
  }
};

// Three independent, all-enforced compile-time bounds (per the dossier's
// "hard node/depth budget for deterministic compile time" requirement):
//   MaxDepth    -- recursion-depth ceiling; also an upper bound on the final
//                  instruction count of any accepted recipe, since every
//                  recursive branch below adds exactly one Step per level.
//   MaxExplored -- total recursive-call ceiling for one top-level query,
//                  independent of MaxDepth (defense-in-depth: bounds compile
//                  time even if a future edit widens the branch set without
//                  updating MaxDepth).
//   CacheCap    -- steady-state memory ceiling on the persistent cache below
//                  (a pure perf tradeoff: queries beyond the cap still
//                  compute correctly, just uncached).
constexpr unsigned MaxDepth = 4;
constexpr unsigned MaxExplored = 4096;
constexpr size_t CacheCap = 16384;

// Reduce an arbitrary intermediate back to the canonical signed-32-bit
// representative. Well-defined two's-complement truncation -- matches every
// other place in this codebase that assumes wraparound i32 arithmetic.
// Deliberately int64_t throughout the search (never raw int32_t negation) so
// negating INT32_MIN is always well-defined (int64_t has headroom), sidestepping
// the APInt::abs()-on-INT_MIN footgun the old decomposeMulByConstant had to
// special-case.
static int64_t canon32(int64_t V) {
  return static_cast<int64_t>(static_cast<int32_t>(static_cast<uint32_t>(V)));
}

struct SearchCtx {
  // Per-top-level-query memo, keyed by (canon32'd C, remaining depth). Safe
  // to key on the exact remaining depth (rather than trying to reuse across
  // different depths): a search at depth d can never find a result cheaper
  // than one found at depth d' < d, so this has no cross-depth correctness
  // subtlety -- it is a plain memoized recursion, not an attempt at a
  // depth-independent global optimum.
  DenseMap<std::pair<int64_t, unsigned>, SynthRecipe> Memo;
  unsigned Explored = 0;
};

static SynthRecipe searchC(int64_t C, unsigned Depth, SearchCtx &Ctx);

// The uncached body of searchC: fast paths first (never consuming search
// budget beyond their own 1-2 steps), then the five recursive branches from
// docs/llvm-arc700-optimizations/02-constant-multiplication.md, trying ALL
// of them and keeping the minimum-cost result (branch-and-bound would only
// prune a sub-call whose cost already exceeds the current best; we skip
// that refinement since MaxDepth/MaxExplored already bound the work).
static SynthRecipe searchCUncached(int64_t Cc, unsigned Depth, SearchCtx &Ctx) {
  // --- Fast paths: 0, 1, -1, +-2^k (including INT_MIN), never touch the
  //     general branches below. Reachability note: because these are always
  //     checked (at every recursive entry, not just the top level) BEFORE
  //     the general branches run, a caller can never recurse into branch
  //     4/5's "C-+1"/"C-+2^k" adjacent-bump shapes starting from a C that
  //     itself was 0/+-1/+-2^k -- so Cc==0 is unreachable in practice here
  //     (defensively handled by declining rather than asserting, so a
  //     reachability mistake can only cost a missed optimization, never a
  //     miscompile).
  if (Cc == 0)
    return SynthRecipe();
  if (Cc == 1)
    return SynthRecipe::seed(); // cost 0, already-live register.
  if (Cc == -1) {
    if (Depth < 1)
      return SynthRecipe();
    return SynthRecipe::unary(StepOp::Neg, 0, SynthRecipe::seed()); // cost 1.
  }
  SynthRecipe FastBest;
  {
    uint32_t U = static_cast<uint32_t>(Cc);
    if (isPowerOf2_32(U)) {
      unsigned Sh = Log2_32(U);
      if (Sh >= 1 && Sh <= 31 && Depth >= 1)
        FastBest = SynthRecipe::unary(StepOp::Shl, Sh, SynthRecipe::seed());
    }
  }
  {
    uint32_t UNeg = static_cast<uint32_t>(-Cc);
    if (isPowerOf2_32(UNeg)) {
      unsigned Sh = Log2_32(UNeg);
      if (Sh >= 1 && Sh <= 31 && Depth >= 2) {
        SynthRecipe Shl =
            SynthRecipe::unary(StepOp::Shl, Sh, SynthRecipe::seed());
        SynthRecipe NegShl = SynthRecipe::unary(StepOp::Neg, 0, Shl);
        if (!FastBest.Found ||
            NegShl.Steps.size() < FastBest.Steps.size())
          FastBest = NegShl;
      }
    }
  }
  if (FastBest.Found)
    return FastBest; // power-of-two shapes never consume the general budget.

  if (Depth == 0)
    return SynthRecipe(); // no budget left for the general branches below.

  SynthRecipe Best;
  auto consider = [&](SynthRecipe &&Cand) {
    if (Cand.Found && (!Best.Found || Cand.Steps.size() < Best.Steps.size()))
      Best = std::move(Cand);
  };

  // Branch 1: strip an ARBITRARY run of trailing zero bits in one Shl.
  // Generalizes the old decomposeMulByConstant's TZeros-stripping idea to
  // recurse instead of requiring the residue to immediately be 2^N+-1.
  {
    uint32_t Bits = static_cast<uint32_t>(Cc);
    unsigned Tz = countr_zero(Bits);
    if (Tz >= 1 && Tz <= 31) {
      int64_t Residue = Cc >> Tz; // exact: Cc is divisible by 2^Tz.
      consider(SynthRecipe::unary(
          StepOp::Shl, Tz, searchC(Residue, Depth - 1, Ctx)));
    }
  }

  // Branch 2: self-scaled ADD-peel. ADDk(t,t) = t*(1+2^k) for k in {1,2,3}
  // (divisors 3, 5, 9) -- this is exactly how x*3/5/9 arise (A=1, the
  // trivial seed base case) and how x*11/13's inner ADD1/ADD2 arise.
  for (unsigned K : {1u, 2u, 3u}) {
    int64_t Divisor = (int64_t{1} << K) + 1;
    if (Cc % Divisor == 0) {
      int64_t A = Cc / Divisor;
      consider(SynthRecipe::binarySelf(
          StepOp::AddSh, static_cast<uint8_t>(K), searchC(A, Depth - 1, Ctx)));
    }
  }

  // Branch 3: self-scaled SUB-peel. SUBk(t,t) = t*(1-2^k) = -t*(2^k-1) for
  // k in {2,3} (divisors 3, 7); k=1 would give divisor 1 (degenerate,
  // already covered by the NEG fast path) so it is skipped.
  for (unsigned K : {2u, 3u}) {
    int64_t Divisor = (int64_t{1} << K) - 1;
    if (Cc % Divisor == 0) {
      int64_t A = -(Cc / Divisor);
      consider(SynthRecipe::binarySelf(
          StepOp::SubSh, static_cast<uint8_t>(K), searchC(A, Depth - 1, Ctx)));
    }
  }

  // Branch 4: adjacent +-1 bump -- generalizes the 2^N+-1 shape to allow an
  // arbitrary PRECEDING chain instead of requiring a bare Shl in front.
  consider(SynthRecipe::withSeedRhs(StepOp::Add, 0,
                                    searchC(Cc - 1, Depth - 1, Ctx)));
  consider(SynthRecipe::withSeedRhs(StepOp::Sub, 0,
                                    searchC(Cc + 1, Depth - 1, Ctx)));

  // Branch 5: adjacent scaled +-2^k bump, k in {1,2,3}. This is the branch
  // that finds x*11 = ADD3(ADD1(x,x),x) [11-8=3 -> branch2 k=1 cost1 -> wrap
  // ADD3 cost2] and x*13 = ADD3(ADD2(x,x),x) [13-8=5 -> branch2 k=2 cost1 ->
  // wrap ADD3 cost2].
  for (unsigned K : {1u, 2u, 3u}) {
    int64_t Bump = int64_t{1} << K;
    consider(SynthRecipe::withSeedRhs(
        StepOp::AddSh, static_cast<uint8_t>(K),
        searchC(Cc - Bump, Depth - 1, Ctx)));
    consider(SynthRecipe::withSeedRhs(
        StepOp::SubSh, static_cast<uint8_t>(K),
        searchC(Cc + Bump, Depth - 1, Ctx)));
  }

  return Best;
}

static SynthRecipe searchC(int64_t C, unsigned Depth, SearchCtx &Ctx) {
  int64_t Cc = canon32(C);
  if (++Ctx.Explored > MaxExplored)
    return SynthRecipe(); // compile-time guardrail: stop exploring.

  auto Key = std::make_pair(Cc, Depth);
  if (auto It = Ctx.Memo.find(Key); It != Ctx.Memo.end())
    return It->second;

  SynthRecipe R = searchCUncached(Cc, Depth, Ctx);
  Ctx.Memo.try_emplace(Key, R);
  return R;
}

// Host-side interpreter over the SAME 7-primitive enum, used only for the
// NDEBUG-gated correctness assertions in synthesizeConstMul. uint32_t
// arithmetic gives the mod-2^32 wraparound for free.
static uint32_t interpretRecipe(const SynthRecipe &R, uint32_t X) {
  SmallVector<uint32_t, 8> Vals;
  auto Val = [&](int32_t Ref) -> uint32_t {
    return Ref == 0 ? X : Vals[Ref - 1];
  };
  for (const Step &S : R.Steps) {
    uint32_t V;
    switch (S.Op) {
    case StepOp::Shl:
      V = Val(S.Lhs) << S.Imm;
      break;
    case StepOp::Add:
      V = Val(S.Lhs) + Val(S.Rhs);
      break;
    case StepOp::Sub:
      V = Val(S.Lhs) - Val(S.Rhs);
      break;
    case StepOp::AddSh:
      V = Val(S.Lhs) + (Val(S.Rhs) << S.Imm);
      break;
    case StepOp::SubSh:
      V = Val(S.Lhs) - (Val(S.Rhs) << S.Imm);
      break;
    case StepOp::Neg:
      V = 0u - Val(S.Lhs);
      break;
    }
    Vals.push_back(V);
  }
  return R.Steps.empty() ? X : Vals.back();
}

// Top-level entry: search(C, MaxDepth), memoized persistently by canon32'd C
// alone. Safe to key on C alone (ignoring context) because every top-level
// query always searches with the SAME fixed MaxDepth budget -- there is no
// "partial budget" top-level query this cache could serve incorrectly.
// thread_local sidesteps any data race if this toolchain's codegen pipeline
// ever parallelizes per-function combines (e.g. ThinLTO codegen
// partitioning); costs nothing extra if it never does.
static std::optional<SynthRecipe> synthesizeConstMul(int64_t C) {
  int64_t Cc = canon32(C);

  static thread_local DenseMap<int64_t, std::optional<SynthRecipe>> Cache;
  if (auto It = Cache.find(Cc); It != Cache.end())
    return It->second;

  SearchCtx Ctx;
  SynthRecipe R = searchC(Cc, MaxDepth, Ctx);

  std::optional<SynthRecipe> Result;
  if (R.Found) {
#ifndef NDEBUG
    // Linearity proof (see file header comment): DAG(x) = K*x mod 2^32 for
    // every primitive here, so DAG(1) == C is mathematically sufficient.
    // Also exercised at a handful of concrete x as defense-in-depth against
    // a bug in the interpreter/lemma itself (e.g. a stray non-linear
    // primitive slipping in) -- redundant with the proof, not a substitute
    // for it.
    assert(interpretRecipe(R, 1) == static_cast<uint32_t>(Cc) &&
           "ARC constant-mul synthesizer: recipe fails linearity check at "
           "x=1 -- DAG(1) must equal C for the search to be sound");
    for (uint32_t X :
        {0u, 1u, 0xFFFFFFFFu, 0x80000000u, 0xDEADBEEFu, 0x12345678u}) {
      uint32_t Want = static_cast<uint32_t>(
          static_cast<uint64_t>(static_cast<uint32_t>(Cc)) *
          static_cast<uint64_t>(X));
      assert(interpretRecipe(R, X) == Want &&
             "ARC constant-mul synthesizer: recipe failed randomized-x "
             "check -- a non-linear primitive must have slipped in");
    }
#endif
    Result = R;
  }

  if (Cache.size() < CacheCap)
    Cache.try_emplace(Cc, Result);
  return Result;
}

// Materialize a SynthRecipe as ordinary ISD::ADD/SUB/SHL DAG nodes (there is
// no such thing as an "ADD1 SDNode" -- ADD1/2/3/SUB1/2/3 are ISel Pats in
// ARCARCompactPatterns.td matching the shape `(add $b,(shl $c,N))` /
// `(sub $b,(shl $c,N))`, which fire automatically once the DAG has this
// shape; no new TableGen pattern is needed). SUB/SubSh are not commutative,
// so the true minuend is always placed as the Lhs operand -- this falls out
// naturally from which side each branch above tracked as "sub" vs
// "x"/"SHL(x,k)". No nsw/nuw flags are propagated (default SDNodeFlags()):
// intermediate synthesized steps are not provably no-wrap even when the
// overall `mul` had such a flag.
static SDValue emitRecipe(const SynthRecipe &R, SDValue X, const SDLoc &dl,
                          SelectionDAG &DAG) {
  EVT VT = X.getValueType();
  SmallVector<SDValue, 8> Vals;
  auto Val = [&](int32_t Ref) -> SDValue {
    return Ref == 0 ? X : Vals[Ref - 1];
  };
  for (const Step &S : R.Steps) {
    SDValue V;
    switch (S.Op) {
    case StepOp::Shl:
      V = DAG.getNode(ISD::SHL, dl, VT, Val(S.Lhs),
                      DAG.getConstant(S.Imm, dl, VT));
      break;
    case StepOp::Add:
      V = DAG.getNode(ISD::ADD, dl, VT, Val(S.Lhs), Val(S.Rhs));
      break;
    case StepOp::Sub:
      V = DAG.getNode(ISD::SUB, dl, VT, Val(S.Lhs), Val(S.Rhs));
      break;
    case StepOp::AddSh: {
      SDValue Sh = DAG.getNode(ISD::SHL, dl, VT, Val(S.Rhs),
                               DAG.getConstant(S.Imm, dl, VT));
      V = DAG.getNode(ISD::ADD, dl, VT, Val(S.Lhs), Sh);
      break;
    }
    case StepOp::SubSh: {
      SDValue Sh = DAG.getNode(ISD::SHL, dl, VT, Val(S.Rhs),
                               DAG.getConstant(S.Imm, dl, VT));
      V = DAG.getNode(ISD::SUB, dl, VT, Val(S.Lhs), Sh);
      break;
    }
    case StepOp::Neg:
      V = DAG.getNode(ISD::SUB, dl, VT, DAG.getConstant(0, dl, VT),
                      Val(S.Lhs));
      break;
    }
    Vals.push_back(V);
  }
  return R.Steps.empty() ? X : Vals.back();
}

} // end anonymous namespace

SDValue ARCTargetLowering::PerformDAGCombine(SDNode *N,
                                             DAGCombinerInfo &DCI) const {
  switch (N->getOpcode()) {
  case ISD::MUL:
    return performMULCombine(N, DCI);
  default:
    return {};
  }
}

// Rewrite `mul x, C` into a bounded chain of add/sub/shl/neg DAG nodes (see
// the synthesizer above) when that is cheaper than the __mulsi3 libcall
// ARC700 would otherwise emit (no hardware multiplier). This DAGCombine
// fires at Level::BeforeLegalizeTypes -- strictly before SelectionDAGLegalize
// would ever turn the LibCall-marked MUL into a call node -- because
// DAGCombiner::combine() only calls TLI.PerformDAGCombine() after the
// generic visit(N) (here, DAGCombiner::visitMUL) has run to completion and
// found nothing to do; with decomposeMulByConstant unconditionally disabled
// (see its definition), visitMUL's own 2-term shape rewrite never fires on
// this target, so every non-trivial constant MUL reaches this hook.
SDValue ARCTargetLowering::performMULCombine(SDNode *N,
                                             DAGCombinerInfo &DCI) const {
  // Never touch MUL when a hardware multiplier is present -- MUL is Legal
  // there and must reach ISel as-is, never rewritten into a scaled-add
  // chain. (Guarding here, independently of the setTargetDAGCombine
  // registration above, is the belt to that call site's suspenders.)
  if (Subtarget.hasMPY())
    return {};

  // Explicit VT guard (mirrors the old decomposeMulByConstant) rather than
  // relying on "i32 is currently ARC's only legal scalar type" -- protects
  // against a future subtarget variant or vector extension silently routing
  // through this combine incorrectly.
  EVT VT = N->getValueType(0);
  if (VT != MVT::i32)
    return {};

  SDValue N0 = N->getOperand(0);
  SDValue N1 = N->getOperand(1);

  SDValue X;
  ConstantSDNode *CN = dyn_cast<ConstantSDNode>(N1);
  if (CN) {
    X = N0;
  } else if ((CN = dyn_cast<ConstantSDNode>(N0))) {
    X = N1;
  } else {
    return {}; // No constant operand -- variable*variable stays a libcall.
  }
  if (CN->isOpaque())
    return {}; // Opaque constants must not be inspected/rewritten.

  int64_t C = CN->getSExtValue();

  std::optional<SynthRecipe> Recipe = synthesizeConstMul(C);
  if (!Recipe)
    return {}; // Nothing found within budget -- fall through to __mulsi3.

  unsigned SynthInstrs = Recipe->Steps.size();

  // Cost threshold: compare against the ACTUAL call-site cost, not an
  // abstract instruction count, and never assume anything about whether
  // __mulsi3's body is "already linked elsewhere" (whole-program information
  // unavailable here, and ignoring it is always conservative-safe -- a
  // synth that is no larger than the local call site can never make THIS
  // call site's bytes larger than the call it replaces).
  //   CallSiteInstrs = 1 (`bl __mulsi3`) +
  //                    1 (MOV_rs12, C fits s12) or 2 (MOV_rlimm, else).
  // Reuses the exact same s12 fold window ARCTTIImpl::materializeCost32 /
  // isLegalAddImmediate already use, so this DAGCombine-time cost model can
  // never drift from the ConstantHoisting-time one.
  unsigned CallSiteInstrs = 1 + (isInt<12>(C) ? 1 : 2);

  const MachineFunction &MF = DCI.DAG.getMachineFunction();
  bool Accept;
  if (MF.getFunction().hasMinSize() || MF.getFunction().hasOptSize()) {
    // -Oz/-Os: bytes are the objective. Ties are resolved in favor of synth
    // -- it strictly dominates the call on every axis bytes don't capture
    // (no blink clobber / possible caller-side spill, no caller-saved
    // register clobber, no call/return latency).
    Accept = SynthInstrs <= CallSiteInstrs;
  } else {
    // -O0/-O1/-O2/-O3: speed-tuned. Accept anything the bounded search
    // found (SynthInstrs <= MaxDepth is trivially true here, since every
    // branch above only ever appends within its remaining depth budget).
    // isa-characterization.md section 8 measures one ALU instruction per
    // clock on this in-order core, so even a full MaxDepth-deep dependent
    // chain (~MaxDepth cycles) is far cheaper than a call's
    // mov+bl+callee-prologue+shift-add-loop+ret.
    Accept = SynthInstrs <= MaxDepth;
  }
  if (!Accept)
    return {};

  SDLoc dl(N);
  return emitRecipe(*Recipe, X, dl, DCI.DAG);
}

// Subsumed by performMULCombine above. Always declining here means
// DAGCombiner::visitMUL's own 2-term (2^N+-1 / 2^N+-2^M) decomposition never
// fires for this target, so every non-trivial constant MUL falls through
// uniformly to performMULCombine's bounded search instead of being stolen
// piecemeal by the generic combine with no way for the target hook to
// improve an already-replaced node. Verified (grep) that DAGCombiner.cpp's
// visitMUL is the ONLY caller of this hook in-tree, so disabling it has no
// other observable effect. Every constant the OLD predicate used to accept
// (2^N+-1 / 2^N+-2^M, after stripping trailing zeros) is proven to reach an
// equal-or-better instruction count under the new search --  see
// docs/llvm-arc700-optimizations/02-constant-multiplication.md's
// acceptance criteria and the FileCheck coverage in
// llvm/test/CodeGen/ARC/arc700eb-scaled-sub.ll.
bool ARCTargetLowering::decomposeMulByConstant(LLVMContext &Context, EVT VT,
                                               SDValue C) const {
  (void)Context;
  (void)VT;
  (void)C;
  return false;
}

//===----------------------------------------------------------------------===//
//  targetShrinkDemandedConstant -- AND/OR/XOR immediate narrowing (idea 2)
//===----------------------------------------------------------------------===//

// Maps an ISD AND/OR/XOR opcode to the corresponding llvm::Instruction
// opcode that ARCTTIImpl::foldsViaBitOp (the single source of truth for
// "does this immediate fold into a 4-byte host instruction with no LIMM")
// expects. Kept local to this translation unit: nothing else needs it.
static unsigned toIRBinOp(unsigned ISDOpc) {
  switch (ISDOpc) {
  case ISD::AND:
    return Instruction::And;
  case ISD::OR:
    return Instruction::Or;
  case ISD::XOR:
    return Instruction::Xor;
  default:
    llvm_unreachable("toIRBinOp: not an AND/OR/XOR opcode");
  }
}

// True when materializing this AND/OR/XOR immediate costs a single 4-byte
// host instruction (fits s12, or matches one of the BSET/BCLR/BMSK
// constant-bit-position shapes) -- i.e. it is already in the cheapest tier
// and there is nothing left for targetShrinkDemandedConstant to win by
// replacing it. Deliberately reuses ARCTTIImpl::foldsViaBitOp (the exact
// predicate ARCTTIImpl::getIntImmCostInst's Instruction::And/Or/Xor case
// already uses) instead of re-deriving the u6/s12/bit-op shapes a second
// time, so the DAGCombine-time notion of "cheap" can never drift from the
// ConstantHoisting-time notion of "cheap".
static bool isFreeALUImm(unsigned ISDOpc, const APInt &V) {
  return V.isSignedIntN(12) || ARCTTIImpl::foldsViaBitOp(toIRBinOp(ISDOpc), V);
}

// See docs/llvm-arc700-optimizations/21-immediate-cost-and-rematerialization.md
// idea 2. SimplifyDemandedBits calls this hook for AND/OR/XOR nodes with a
// constant RHS; we may substitute a different constant Cp for C as long as
// Cp agrees with C on every DEMANDED bit -- i.e. the single non-negotiable
// invariant enforced below is:
//
//     ((Cp xor C) & DemandedBits) == 0
//
// Only bits OUTSIDE DemandedBits may differ between C and Cp. This is
// checked explicitly (the `agrees` lambda) on every candidate before it is
// used, even where the construction also makes it provable algebraically,
// so a bug in candidate *derivation* can only ever cost a missed
// optimization, never a miscompile.
bool ARCTargetLowering::targetShrinkDemandedConstant(
    SDValue Op, const APInt &DemandedBits, const APInt &DemandedElts,
    TargetLoweringOpt &TLO) const {
  (void)DemandedElts; // ARC has no vector register class; always all-ones.

  // Delay past type/op legalization, mirroring ARM/RISCV.
  if (!TLO.LegalOps)
    return false;

  if (Op.getValueType() != MVT::i32)
    return false;

  unsigned Opcode = Op.getOpcode();
  if (Opcode != ISD::AND && Opcode != ISD::OR && Opcode != ISD::XOR)
    return false;

  auto *CN = dyn_cast<ConstantSDNode>(Op.getOperand(1));
  if (!CN || CN->isOpaque())
    return false;
  const APInt &C = CN->getAPIntValue();

  // Redundant with the Step-1 free-tier precheck below for an all-ones XOR
  // mask (it already fits s12), kept explicit so the invariant survives if
  // the free-cost tiers are ever changed independently of this guard.
  if (Opcode == ISD::XOR && C.isAllOnes())
    return false;

  // If C is already in the cheapest tier there is nothing strictly cheaper
  // to find. How we report that matters for termination:
  //
  // TargetLowering::ShrinkDemandedConstant calls this hook FIRST and, if it
  // returns false, immediately falls through to ITS OWN generic clear-only
  // clamp: `if (!C.isSubsetOf(DemandedBits)) NewC = DemandedBits & C;`. That
  // clamp is unconditional and mechanical -- it does not know a bit outside
  // DemandedBits was set DELIBERATELY (by Tier A/B below, on an earlier
  // visit of this same node) to reach a free encoding. If we returned false
  // here whenever C is merely free -- regardless of whether C still has
  // 1-bits outside the CURRENT DemandedBits -- the generic clamp would
  // immediately strip those bits back to (C & DemandedBits) on the very
  // next revisit, which is not guaranteed to still be free; this hook would
  // then widen it right back on the revisit after that, forever. Reproduced
  // concretely while developing this hook: and(zext_i16, 0xFFFF0) with
  // DemandedBits=0xFFFF narrowed Tier A to C=0xFFFFFFF0 (-16, free), but the
  // very next visit's generic clamp reduced it straight back to C=0xFFF0
  // (not free), which this hook then widened back to -16 again -- llc hung.
  //
  // The fix: a free C with no 1-bits outside DemandedBits is one the
  // generic clamp would leave untouched anyway (its own `!C.isSubsetOf(...)`
  // guard is false), so deferring to it is provably a no-op -- safe to
  // return false. A free C that DOES have 1-bits outside DemandedBits can
  // only have gotten that way from this hook's own Tier A/B widening on a
  // prior visit (a freshly-legalized constant is never pre-widened), so we
  // must return true (a no-op "handled" report -- TLO.New is left unset,
  // so no CombineTo happens) to suppress the generic clamp and stop the
  // oscillation. Either branch is a correct "nothing cheaper" answer; the
  // choice between them only controls whether the generic clamp is allowed
  // to run afterward.
  if (isFreeALUImm(Opcode, C))
    return !C.isSubsetOf(DemandedBits);

  auto agrees = [&](const APInt &Cand) -> bool {
    return ((Cand ^ C) & DemandedBits).isZero();
  };

  auto tryUse = [&](const APInt &Cand) -> bool {
    if (!agrees(Cand))
      return false;
    if (!isFreeALUImm(Opcode, Cand))
      return false;
    SDLoc DL(Op);
    SDValue NewC = TLO.DAG.getConstant(Cand, DL, Op.getValueType());
    SDNodeFlags Flags = Op->getFlags();
    if (Opcode == ISD::OR)
      // Cand may set bits beyond C at undemanded positions (that is the
      // only way Tier A can differ from C here, since C was already proven
      // not free above), so the rewritten OR can no longer be assumed
      // bit-disjoint from its other operand even though it is still
      // correct on every demanded bit. Drop a stale `or disjoint` flag
      // rather than let it survive onto a node it no longer describes.
      Flags.setDisjoint(false);
    SDValue NewOp = TLO.DAG.getNode(Opcode, DL, Op.getValueType(),
                                    Op.getOperand(0), NewC, Flags);
    return TLO.CombineTo(Op, NewOp);
  };

  // Tier A (AND/OR/XOR): force every undemanded bit to 1. This is the
  // extremal point that can SET bits the clear-only generic fallback
  // (TargetLowering::ShrinkDemandedConstant's own ShrunkMask = C &
  // DemandedBits, which runs unconditionally when this hook returns false)
  // structurally cannot reach. Covers the s12 sign-extension win common to
  // all three opcodes (the dossier's y & 0x00FFFFF0 example: ExpandedMask =
  // 0x00FFFFF0 | 0xFF000000 = 0xFFFFFFF0 = -16, isSignedIntN(12)) and
  // AND's BCLR shape specifically (a single DEMANDED 0-bit with every other
  // bit -- demanded-1 or undemanded-forced-1 -- ending up 1, i.e. exactly
  // ~(1<<k)). It does NOT reach OR/XOR's BSET/BXOR single-SET-bit shape --
  // that needs the opposite polarity (undemanded bits forced to 0), which
  // is exactly what TargetLowering::ShrinkDemandedConstant's own
  // clear-only clamp (ShrunkMask = C & DemandedBits) already reproduces for
  // free whenever C's demanded bits are already a lone bit -- so no
  // separate tier for it is needed here.
  APInt ExpandedMask = C | ~DemandedBits;
  if (tryUse(ExpandedMask))
    return true;

  // Tier B (AND only): BMSK contiguous-low-mask shape (2^M - 1). Not
  // reachable via ExpandedMask (which forces high undemanded bits to 1, the
  // opposite of what BMSK's high region needs) nor via pure clearing (which
  // forces LOW undemanded bits to 0, the opposite of what BMSK's low region
  // needs) -- it needs its own targeted construction. This is a heuristic
  // guess (sized to the highest demanded set bit of the clear-only
  // baseline), not an algebraic guarantee like ExpandedMask; `agrees()`
  // below is what keeps a wrong guess from ever reaching CombineTo.
  if (Opcode == ISD::AND) {
    APInt ShrunkMask = C & DemandedBits;
    unsigned M = ShrunkMask.getActiveBits();
    if (M > 0 && M < 32) {
      APInt BmskCand = APInt::getLowBitsSet(32, M);
      if (tryUse(BmskCand))
        return true;
    }
  }

  // No cheaper equivalent constant found on the checked candidates. Let the
  // generic clear-only ShrinkDemandedConstant fallback run instead -- it
  // may still narrow C for later combines even when no cost tier changes.
  return false;
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
