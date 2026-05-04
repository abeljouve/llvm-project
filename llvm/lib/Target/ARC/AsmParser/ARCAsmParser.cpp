//===-- ARCAsmParser.cpp - Hand-coded ARC Assembly Parser -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Hand-coded ARCompact assembly parser covering the subset of the ISA that
// bare-metal Rust code actually needs:
//
//   - `.di` MMIO loads / stores inlined via Rust `asm!` blocks
//     (`stb.di`, `ldb.di`, `st.di`, `ld.di`, `sth.di`, `ldh.di`,
//      `stw.di`, `ldw.di` — stw/ldw are ARCompact halfword aliases)
//   - `.x.di` sign-extending uncached loads
//     (`ldb.x.di`, `ldh.x.di`, `ldw.x.di`)
//   - The complete set of ARCompact mnemonics used by start.S and by
//     hand-written inline `asm!` blocks:
//       mov   (immediate / s12 / LIMM symbol)
//       st / stb / sth / stw      (register base + signed 9-bit offset)
//       ld / ldb / ldh / ldw      (register base + signed 9-bit offset)
//       ld    (register base + register offset, word only)
//       ld.ab (post-increment register + register offset)
//       add / sub / and / or / xor             (rrr, rru6, rrlimm)
//       asl / lsr / asr / ror                  (rrr, rru6, rrlimm)
//       bclr / bset / bmsk / bxor              (rrr, rru6)
//       brcc  (brge/brne/breq/brlt/brlo/brhs reg, reg|u6, label)
//       b     (unconditional far branch)
//       bl    (unconditional far call)
//       flag  (u6 immediate / register)
//       j     [reg] / <expr>           (long form, no delay slot)
//       j_s   [blink]
//       j.d   [blink]
//       lr / sr [aux]  (aux-register access, u6 / s12 / limm)
//       rtie / nop / nop_s / sync / sleep / brk  (zero-operand)
//
// Every other mnemonic returns a parse error so misuse is immediately
// visible. The parser builds an MCInst for each accepted statement and
// emits it through the streamer so the downstream MCCodeEmitter /
// MCAsmBackend pipeline (including the branch / LIMM fixups and the
// scattered bit-field encoding) handles relocation and endianness
// transparently. A small handful of ARCompact-specific encodings
// (register-offset LD, LD.ab, J.d, LR / SR) bypass MCInst and emit raw
// 4-byte instruction words because their td definitions are marked
// `isCodeGenOnly` and don't round-trip cleanly through the matcher.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/ARCInfo.h"
#include "MCTargetDesc/ARCMCTargetDesc.h"
#include "TargetInfo/ARCTargetInfo.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCParser/AsmLexer.h"
#include "llvm/MC/MCParser/MCAsmParser.h"
#include "llvm/MC/MCParser/MCParsedAsmOperand.h"
#include "llvm/MC/MCParser/MCTargetAsmParser.h"
#include "llvm/MC/MCRegister.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/SMLoc.h"

using namespace llvm;

namespace {

// ARCOperand — parsed operand tracked between parseInstruction and
// matchAndEmitInstruction. Five kinds:
//   Token     — mnemonic string
//   Register  — single GPR
//   Immediate — MCExpr (constant or symbol reference)
//   Memory    — `[base, imm]` with constant offset
//   MemoryRR  — `[base, offset_reg]` with register offset
struct ARCOperand : public MCParsedAsmOperand {
  enum KindTy { Token, Register, Immediate, Memory, MemoryRR } Kind;

  SMLoc StartLoc, EndLoc;

  struct RegOp {
    MCRegister Num;
  };
  struct ImmOp {
    const MCExpr *Val;
  };
  struct MemOp {
    MCRegister Base;
    int64_t Offset;
  };
  struct MemRROp {
    MCRegister Base;
    MCRegister OffsetReg;
  };
  union {
    StringRef Tok;
    RegOp Reg;
    ImmOp Imm;
    MemOp Mem;
    MemRROp MemRR;
  };

  ARCOperand(KindTy K) : Kind(K) {}

public:
  bool isToken() const override { return Kind == Token; }
  bool isReg() const override { return Kind == Register; }
  bool isImm() const override { return Kind == Immediate; }
  bool isMem() const override { return Kind == Memory || Kind == MemoryRR; }

  StringRef getToken() const {
    assert(Kind == Token);
    return Tok;
  }
  MCRegister getReg() const override {
    assert(Kind == Register);
    return Reg.Num;
  }
  const MCExpr *getImmExpr() const {
    assert(Kind == Immediate);
    return Imm.Val;
  }
  MCRegister getMemBase() const {
    assert(Kind == Memory);
    return Mem.Base;
  }
  int64_t getMemOffset() const {
    assert(Kind == Memory);
    return Mem.Offset;
  }
  MCRegister getMemRRBase() const {
    assert(Kind == MemoryRR);
    return MemRR.Base;
  }
  MCRegister getMemRROffReg() const {
    assert(Kind == MemoryRR);
    return MemRR.OffsetReg;
  }

  SMLoc getStartLoc() const override { return StartLoc; }
  SMLoc getEndLoc() const override { return EndLoc; }

  void print(raw_ostream &OS, const MCAsmInfo &) const override {
    switch (Kind) {
    case Token:
      OS << "Token:" << Tok;
      break;
    case Register:
      OS << "Reg:" << Reg.Num.id();
      break;
    case Immediate:
      OS << "Imm";
      break;
    case Memory:
      OS << "Mem:[" << Mem.Base.id() << ", " << Mem.Offset << "]";
      break;
    case MemoryRR:
      OS << "MemRR:[" << MemRR.Base.id() << ", " << MemRR.OffsetReg.id() << "]";
      break;
    }
  }

  static std::unique_ptr<ARCOperand> CreateToken(StringRef Str, SMLoc S) {
    auto Op = std::make_unique<ARCOperand>(Token);
    Op->Tok = Str;
    Op->StartLoc = S;
    Op->EndLoc = S;
    return Op;
  }
  static std::unique_ptr<ARCOperand> CreateReg(MCRegister R, SMLoc S, SMLoc E) {
    auto Op = std::make_unique<ARCOperand>(Register);
    Op->Reg.Num = R;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }
  static std::unique_ptr<ARCOperand> CreateImm(const MCExpr *Val, SMLoc S,
                                                SMLoc E) {
    auto Op = std::make_unique<ARCOperand>(Immediate);
    Op->Imm.Val = Val;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }
  static std::unique_ptr<ARCOperand> CreateMem(MCRegister Base, int64_t Offset,
                                                SMLoc S, SMLoc E) {
    auto Op = std::make_unique<ARCOperand>(Memory);
    Op->Mem.Base = Base;
    Op->Mem.Offset = Offset;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }
  static std::unique_ptr<ARCOperand> CreateMemRR(MCRegister Base,
                                                  MCRegister OffReg, SMLoc S,
                                                  SMLoc E) {
    auto Op = std::make_unique<ARCOperand>(MemoryRR);
    Op->MemRR.Base = Base;
    Op->MemRR.OffsetReg = OffReg;
    Op->StartLoc = S;
    Op->EndLoc = E;
    return Op;
  }
};

class ARCAsmParser : public MCTargetAsmParser {
  SMLoc getLoc() const { return getParser().getTok().getLoc(); }

  bool parseReg(MCRegister &Reg, SMLoc &StartLoc, SMLoc &EndLoc);
  ParseStatus parseOperand(OperandVector &Operands);
  ParseStatus parseMemoryOperand(OperandVector &Operands);
  ParseStatus parseBlinkBracket(OperandVector &Operands);

  bool matchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                               OperandVector &Operands, MCStreamer &Out,
                               uint64_t &ErrorInfo,
                               bool MatchingInlineAsm) override;

  // Individual mnemonic handlers. Each returns false on success, true on
  // error (after calling Error()).
  bool emitMov(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out);
  bool emitDiMem(SMLoc IDLoc, StringRef Name, OperandVector &Operands,
                 MCStreamer &Out);
  bool emitSt(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out,
              unsigned Opcode);
  bool emitLd(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out,
              unsigned Rs9Op);
  bool emitLdAb(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out);
  bool emitBinaryALU(SMLoc IDLoc, StringRef Name, OperandVector &Operands,
                     MCStreamer &Out, unsigned RRR, unsigned RRU6,
                     unsigned RRLImm);
  bool emitBitOp(SMLoc IDLoc, StringRef Name, OperandVector &Operands,
                 MCStreamer &Out, unsigned RRR, unsigned RRU6);
  bool emitZeroOp(SMLoc IDLoc, StringRef Name, OperandVector &Operands,
                  MCStreamer &Out, unsigned Opcode);
  bool emitBr(SMLoc IDLoc, StringRef Name, OperandVector &Operands,
              MCStreamer &Out);
  bool emitBUncond(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out);
  bool emitBl(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out);
  bool emitFlag(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out);
  bool emitJ(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out);
  bool emitJsBlink(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out);
  bool emitJdBlink(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out);
  bool emitLr(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out);
  bool emitSr(SMLoc IDLoc, OperandVector &Operands, MCStreamer &Out);
  bool emitPushPop(SMLoc IDLoc, StringRef Name, OperandVector &Operands,
                   MCStreamer &Out);

  bool parseRegister(MCRegister &Reg, SMLoc &StartLoc,
                     SMLoc &EndLoc) override {
    if (parseReg(Reg, StartLoc, EndLoc))
      return Error(StartLoc, "expected register");
    return false;
  }

  ParseStatus tryParseRegister(MCRegister &Reg, SMLoc &StartLoc,
                               SMLoc &EndLoc) override {
    if (parseReg(Reg, StartLoc, EndLoc))
      return ParseStatus::NoMatch;
    return ParseStatus::Success;
  }

  bool parseInstruction(ParseInstructionInfo &Info, StringRef Name,
                        SMLoc NameLoc, OperandVector &Operands) override;

  ParseStatus parseDirective(AsmToken DirectiveID) override {
    return ParseStatus::NoMatch;
  }

  void convertToMapAndConstraints(unsigned Kind,
                                  const OperandVector &Operands) override {}

public:
  ARCAsmParser(const MCSubtargetInfo &STI, MCAsmParser &Parser,
               const MCInstrInfo &MII, const MCTargetOptions &Options)
      : MCTargetAsmParser(Options, STI, MII) {
    MCAsmParserExtension::Initialize(Parser);
  }
};

// ===========================================================================
// Register lookup
// ===========================================================================
//
// Map `%rN` / `%sp` / `%blink` / `%fp` / `%gp` / `%ilink` plus the bare
// `rN` / `sp` / `blink` forms used in GNU `.S` files to the MC register
// enum from ARCGenRegisterInfo.inc.
//
static MCRegister matchRegisterName(StringRef Name) {
  if (Name.starts_with("%"))
    Name = Name.drop_front();

  if (Name.starts_with_insensitive("r")) {
    StringRef Digits = Name.drop_front();
    unsigned Num;
    if (!Digits.getAsInteger(10, Num) && Num <= 63) {
      static constexpr MCPhysReg RegTable[64] = {
          ARC::R0,  ARC::R1,  ARC::R2,  ARC::R3,  ARC::R4,  ARC::R5,  ARC::R6,
          ARC::R7,  ARC::R8,  ARC::R9,  ARC::R10, ARC::R11, ARC::R12, ARC::R13,
          ARC::R14, ARC::R15, ARC::R16, ARC::R17, ARC::R18, ARC::R19, ARC::R20,
          ARC::R21, ARC::R22, ARC::R23, ARC::R24, ARC::R25, ARC::GP,  ARC::FP,
          ARC::SP,  ARC::ILINK, ARC::R30, ARC::BLINK,
          ARC::R32, ARC::R33, ARC::R34, ARC::R35, ARC::R36, ARC::R37, ARC::R38,
          ARC::R39, ARC::R40, ARC::R41, ARC::R42, ARC::R43, ARC::R44, ARC::R45,
          ARC::R46, ARC::R47, ARC::R48, ARC::R49, ARC::R50, ARC::R51, ARC::R52,
          ARC::R53, ARC::R54, ARC::R55, ARC::R56, ARC::R57, ARC::R58, ARC::R59,
          ARC::R60, ARC::R61, ARC::R62, ARC::R63};
      return MCRegister(RegTable[Num]);
    }
  }

  return StringSwitch<MCRegister>(Name.lower())
      .Case("sp", ARC::SP)
      .Case("fp", ARC::FP)
      .Case("gp", ARC::GP)
      .Case("blink", ARC::BLINK)
      .Case("ilink", ARC::ILINK)
      .Case("pcl", ARC::R63)
      .Default(MCRegister());
}

// Register encoding value (6-bit) for a parsed MCRegister. We need this
// for hand-rolled raw-byte instruction encoders that bypass MCInst.
static unsigned regEncoding(MCRegister R) {
  unsigned Id = R.id();
  if (Id >= ARC::R0 && Id <= ARC::R25)
    return Id - ARC::R0;
  if (Id == ARC::GP)
    return 26;
  if (Id == ARC::FP)
    return 27;
  if (Id == ARC::SP)
    return 28;
  if (Id == ARC::ILINK)
    return 29;
  if (Id == ARC::R30)
    return 30;
  if (Id == ARC::BLINK)
    return 31;
  if (Id >= ARC::R32 && Id <= ARC::R63)
    return 32 + (Id - ARC::R32);
  return 0;
}

// ===========================================================================
// Lexer / operand parsing
// ===========================================================================

bool ARCAsmParser::parseReg(MCRegister &Reg, SMLoc &StartLoc, SMLoc &EndLoc) {
  MCAsmParser &P = getParser();
  const AsmToken &Tok = P.getTok();

  StartLoc = Tok.getLoc();
  EndLoc = Tok.getEndLoc();

  if (Tok.is(AsmToken::Percent)) {
    AsmToken Next = P.getLexer().peekTok();
    if (Next.isNot(AsmToken::Identifier))
      return true;
    MCRegister R = matchRegisterName(Next.getString());
    if (!R)
      return true;
    P.Lex();
    EndLoc = P.getTok().getEndLoc();
    P.Lex();
    Reg = R;
    return false;
  }

  if (Tok.is(AsmToken::Identifier)) {
    MCRegister R = matchRegisterName(Tok.getString());
    if (!R)
      return true;
    EndLoc = Tok.getEndLoc();
    P.Lex();
    Reg = R;
    return false;
  }

  return true;
}

ParseStatus ARCAsmParser::parseMemoryOperand(OperandVector &Operands) {
  MCAsmParser &P = getParser();
  SMLoc S = P.getTok().getLoc();

  if (P.getTok().isNot(AsmToken::LBrac))
    return ParseStatus::NoMatch;
  P.Lex();

  // `[imm]` — bare aux-register reference used by `lr` / `sr`. We
  // detect it by looking at the first token: an integer literal or an
  // identifier that isn't a known register name means the base slot
  // is empty and the bracket contains a plain constant. Emit it as a
  // Memory operand with a zero base register; the `lr` / `sr`
  // handlers special-case `Base == MCRegister()` as "aux reg".
  bool FirstIsNonReg =
      P.getTok().is(AsmToken::Integer) ||
      (P.getTok().is(AsmToken::Identifier) &&
       !matchRegisterName(P.getTok().getString()));
  if (FirstIsNonReg) {
    const MCExpr *AuxExpr;
    if (P.parseExpression(AuxExpr))
      return Error(P.getTok().getLoc(), "expected aux-reg expression");
    int64_t AuxImm = 0;
    if (auto *CE = dyn_cast<MCConstantExpr>(AuxExpr))
      AuxImm = CE->getValue();
    else
      return Error(P.getTok().getLoc(), "aux-reg index must be a constant");
    if (P.getTok().isNot(AsmToken::RBrac))
      return Error(P.getTok().getLoc(), "expected ']'");
    SMLoc E = P.getTok().getEndLoc();
    P.Lex();
    Operands.push_back(ARCOperand::CreateMem(MCRegister(), AuxImm, S, E));
    return ParseStatus::Success;
  }

  MCRegister Base;
  SMLoc RegStart, RegEnd;
  if (parseReg(Base, RegStart, RegEnd))
    return Error(RegStart, "expected base register in memory operand");

  // `[rB]` — no offset.
  if (P.getTok().is(AsmToken::RBrac)) {
    SMLoc E = P.getTok().getEndLoc();
    P.Lex();
    Operands.push_back(ARCOperand::CreateMem(Base, 0, S, E));
    return ParseStatus::Success;
  }

  if (P.getTok().isNot(AsmToken::Comma))
    return Error(P.getTok().getLoc(), "expected ',' or ']' in memory operand");
  P.Lex();

  // The second operand may be a register (`[rB, rC]`) or a constant
  // offset (`[rB, imm]`). We need to disambiguate without a rewind:
  // peek the current token kind first.
  MCRegister OffReg;
  SMLoc OffRegStart, OffRegEnd;
  if (P.getTok().is(AsmToken::Percent) ||
      (P.getTok().is(AsmToken::Identifier) &&
       matchRegisterName(P.getTok().getString()))) {
    if (parseReg(OffReg, OffRegStart, OffRegEnd))
      return Error(OffRegStart, "expected offset register");
    if (P.getTok().isNot(AsmToken::RBrac))
      return Error(P.getTok().getLoc(), "expected ']' after offset register");
    SMLoc E = P.getTok().getEndLoc();
    P.Lex();
    Operands.push_back(ARCOperand::CreateMemRR(Base, OffReg, S, E));
    return ParseStatus::Success;
  }

  // Constant offset.
  const MCExpr *OffExpr;
  if (P.parseExpression(OffExpr))
    return Error(P.getTok().getLoc(), "expected offset expression");
  int64_t Offset = 0;
  if (auto *CE = dyn_cast<MCConstantExpr>(OffExpr))
    Offset = CE->getValue();
  else
    return Error(P.getTok().getLoc(), "memory offset must be a constant");

  if (P.getTok().isNot(AsmToken::RBrac))
    return Error(P.getTok().getLoc(), "expected ']'");
  SMLoc E = P.getTok().getEndLoc();
  P.Lex();

  Operands.push_back(ARCOperand::CreateMem(Base, Offset, S, E));
  return ParseStatus::Success;
}

ParseStatus ARCAsmParser::parseOperand(OperandVector &Operands) {
  MCAsmParser &P = getParser();
  SMLoc S = P.getTok().getLoc();

  if (P.getTok().is(AsmToken::LBrac))
    return parseMemoryOperand(Operands);

  if (P.getTok().is(AsmToken::Percent) || P.getTok().is(AsmToken::Identifier)) {
    // Identifier tokens might be a register name OR a plain symbol. Try
    // the register lookup first without consuming the token; if it
    // succeeds, take the register path. Otherwise fall through to the
    // expression parser.
    if (P.getTok().is(AsmToken::Percent) ||
        (P.getTok().is(AsmToken::Identifier) &&
         matchRegisterName(P.getTok().getString()))) {
      MCRegister R;
      SMLoc RS, RE;
      if (!parseReg(R, RS, RE)) {
        Operands.push_back(ARCOperand::CreateReg(R, RS, RE));
        return ParseStatus::Success;
      }
    }
  }

  const MCExpr *Expr;
  if (P.parseExpression(Expr))
    return Error(S, "expected operand");
  SMLoc E = SMLoc::getFromPointer(P.getTok().getLoc().getPointer() - 1);
  Operands.push_back(ARCOperand::CreateImm(Expr, S, E));
  return ParseStatus::Success;
}

ParseStatus ARCAsmParser::parseBlinkBracket(OperandVector &Operands) {
  // `j_s [blink]` / `j.d [blink]` — memory-form with no offset, treated
  // as a plain register operand by the handler.
  return parseMemoryOperand(Operands);
}

bool ARCAsmParser::parseInstruction(ParseInstructionInfo &Info, StringRef Name,
                                     SMLoc NameLoc, OperandVector &Operands) {
  Operands.push_back(ARCOperand::CreateToken(Name, NameLoc));

  if (getLexer().is(AsmToken::EndOfStatement))
    return false;

  if (!parseOperand(Operands).isSuccess())
    return true;

  while (getLexer().is(AsmToken::Comma)) {
    getParser().Lex();
    if (!parseOperand(Operands).isSuccess())
      return true;
  }

  if (getLexer().isNot(AsmToken::EndOfStatement))
    return Error(getLoc(), "unexpected token");

  return false;
}

// ===========================================================================
// Helpers
// ===========================================================================

static bool fitsInSigned(int64_t V, unsigned Bits) {
  int64_t Max = (int64_t(1) << (Bits - 1)) - 1;
  int64_t Min = -(int64_t(1) << (Bits - 1));
  return V >= Min && V <= Max;
}

static bool fitsInUnsigned(int64_t V, unsigned Bits) {
  int64_t Max = (int64_t(1) << Bits) - 1;
  return V >= 0 && V <= Max;
}

// Emit a raw 4-byte big-endian instruction word. Used for ARCompact
// forms whose td definitions are marked `isCodeGenOnly` and don't
// round-trip through MCInst cleanly.
static void emitRawInsn32(MCStreamer &Out, uint32_t Insn) {
  uint8_t Bytes[4];
  support::endian::write32be(Bytes, Insn);
  Out.emitBytes(StringRef(reinterpret_cast<const char *>(Bytes), 4));
}
static void emitRawInsn16(MCStreamer &Out, uint16_t Insn) {
  uint8_t Bytes[2];
  support::endian::write16be(Bytes, Insn);
  Out.emitBytes(StringRef(reinterpret_cast<const char *>(Bytes), 2));
}

// ===========================================================================
// Instruction handlers
// ===========================================================================

// `mov rB, <expr>` where expr is either a constant (→ MOV_rs12 or
// MOV_rlimm) or a symbol (→ MOV_rlimm with a R_ARC_32 relocation on the
// LIMM word).
bool ARCAsmParser::emitMov(SMLoc IDLoc, OperandVector &Operands,
                            MCStreamer &Out) {
  if (Operands.size() != 3)
    return Error(IDLoc, "expected `mov rB, <expr>`");
  auto &RegOp = static_cast<ARCOperand &>(*Operands[1]);
  auto &RhsOp = static_cast<ARCOperand &>(*Operands[2]);
  if (RegOp.Kind != ARCOperand::Register)
    return Error(IDLoc, "mov destination must be a register");

  // reg-to-reg mov
  if (RhsOp.Kind == ARCOperand::Register) {
    MCInst Inst;
    Inst.setOpcode(ARC::MOV_rr);
    Inst.addOperand(MCOperand::createReg(RegOp.getReg()));
    Inst.addOperand(MCOperand::createReg(RhsOp.getReg()));
    Inst.setLoc(IDLoc);
    Out.emitInstruction(Inst, getSTI());
    return false;
  }

  if (RhsOp.Kind != ARCOperand::Immediate)
    return Error(IDLoc, "mov source must be an immediate or register");

  const MCExpr *Expr = RhsOp.getImmExpr();

  // Constant that fits in s12 → MOV_rs12 (4-byte).
  if (auto *CE = dyn_cast<MCConstantExpr>(Expr)) {
    int64_t V = CE->getValue();
    if (fitsInSigned(V, 12)) {
      MCInst Inst;
      Inst.setOpcode(ARC::MOV_rs12);
      Inst.addOperand(MCOperand::createReg(RegOp.getReg()));
      Inst.addOperand(MCOperand::createImm(V));
      Inst.setLoc(IDLoc);
      Out.emitInstruction(Inst, getSTI());
      return false;
    }
    // Wide constant → fall through to MOV_rlimm.
  }

  // Symbol or wide constant → MOV_rlimm (8-byte with LIMM word).
  MCInst Inst;
  Inst.setOpcode(ARC::MOV_rlimm);
  Inst.addOperand(MCOperand::createReg(RegOp.getReg()));
  Inst.addOperand(MCOperand::createExpr(Expr));
  Inst.setLoc(IDLoc);
  Out.emitInstruction(Inst, getSTI());
  return false;
}

bool ARCAsmParser::emitDiMem(SMLoc IDLoc, StringRef Name,
                              OperandVector &Operands, MCStreamer &Out) {
  if (Operands.size() != 3)
    return Error(IDLoc, "expected `<mnem> rC, [rB, imm]`");
  auto &RegOp = static_cast<ARCOperand &>(*Operands[1]);
  auto &MemOp = static_cast<ARCOperand &>(*Operands[2]);
  if (RegOp.Kind != ARCOperand::Register || MemOp.Kind != ARCOperand::Memory)
    return Error(IDLoc, "expected register + `[rB, imm]`");

  unsigned Op = StringSwitch<unsigned>(Name)
                    .Case("stb.di", ARC::STB_DI_rs9)
                    .Case("ldb.di", ARC::LDB_DI_rs9)
                    .Case("st.di", ARC::ST_DI_rs9)
                    .Case("ld.di", ARC::LD_DI_rs9)
                    .Case("sth.di", ARC::STH_DI_rs9)
                    .Case("ldh.di", ARC::LDH_DI_rs9)
                    .Case("stw.di", ARC::STH_DI_rs9)
                    .Case("ldw.di", ARC::LDH_DI_rs9)
                    .Case("ldb.x.di", ARC::LDB_X_DI_rs9)
                    .Case("ldh.x.di", ARC::LDH_X_DI_rs9)
                    .Case("ldw.x.di", ARC::LDH_X_DI_rs9)
                    .Default(0);
  if (!Op)
    return Error(IDLoc, "unsupported `.di` mnemonic");

  MCInst Inst;
  Inst.setOpcode(Op);
  Inst.addOperand(MCOperand::createReg(RegOp.getReg()));
  Inst.addOperand(MCOperand::createReg(MemOp.getMemBase()));
  Inst.addOperand(MCOperand::createImm(MemOp.getMemOffset()));
  Inst.setLoc(IDLoc);
  Out.emitInstruction(Inst, getSTI());
  return false;
}

// `st rC, [rB]` / `st rC, [rB, imm]` — also used for stb/sth/stw via Opcode.
bool ARCAsmParser::emitSt(SMLoc IDLoc, OperandVector &Operands,
                           MCStreamer &Out, unsigned Opcode) {
  if (Operands.size() != 3)
    return Error(IDLoc, "expected `st* rC, [rB, imm]`");
  auto &RegOp = static_cast<ARCOperand &>(*Operands[1]);
  auto &MemOp = static_cast<ARCOperand &>(*Operands[2]);
  if (RegOp.Kind != ARCOperand::Register || MemOp.Kind != ARCOperand::Memory)
    return Error(IDLoc, "st* requires register + `[rB, imm]`");

  MCInst Inst;
  Inst.setOpcode(Opcode);
  Inst.addOperand(MCOperand::createReg(RegOp.getReg()));
  Inst.addOperand(MCOperand::createReg(MemOp.getMemBase()));
  Inst.addOperand(MCOperand::createImm(MemOp.getMemOffset()));
  Inst.setLoc(IDLoc);
  Out.emitInstruction(Inst, getSTI());
  return false;
}

// `ld rA, [rB, imm]`  → Rs9Op (LD_rs9 / LDB_rs9 / LDH_rs9)
// `ld rA, [rB, rC]`   → raw 4-byte instruction (word loads only;
//                       ARCompact alu-form load whose td entry is
//                       isCodeGenOnly).
//
// Encoding for `ld rA, [rB, rC]` (big-endian word, captured from GNU as
// on arceb-elf32-gcc 15.2.0):
//
//   0x24 0x30 0xB0_C0 | (rA_as_A)
//
// i.e. the 32-bit word = 0x24303000 | (C << 6) | (B_lo << 24) |
// (B_hi << 12) | A. GCC output:
//
//   ld blink, [sp, r12]   → 0x2430 331f
//   ld.ab r13, [sp, r12]  → 0x24b0 330d    (bit 22 set = post-increment)
//
// We compose the instruction word from the parsed operand values.
bool ARCAsmParser::emitLd(SMLoc IDLoc, OperandVector &Operands,
                           MCStreamer &Out, unsigned Rs9Op) {
  if (Operands.size() != 3)
    return Error(IDLoc, "expected `ld* rA, [rB, imm|rC]`");
  auto &RegOp = static_cast<ARCOperand &>(*Operands[1]);
  auto &MemOp = static_cast<ARCOperand &>(*Operands[2]);
  if (RegOp.Kind != ARCOperand::Register)
    return Error(IDLoc, "ld* destination must be a register");

  if (MemOp.Kind == ARCOperand::Memory) {
    MCInst Inst;
    Inst.setOpcode(Rs9Op);
    Inst.addOperand(MCOperand::createReg(RegOp.getReg()));
    Inst.addOperand(MCOperand::createReg(MemOp.getMemBase()));
    Inst.addOperand(MCOperand::createImm(MemOp.getMemOffset()));
    Inst.setLoc(IDLoc);
    Out.emitInstruction(Inst, getSTI());
    return false;
  }

  if (MemOp.Kind == ARCOperand::MemoryRR) {
    if (Rs9Op != ARC::LD_rs9)
      return Error(IDLoc, "register-offset [rB, rC] form only supported "
                          "for word-size ld; use ld with computed address");
    unsigned A = regEncoding(RegOp.getReg());
    unsigned B = regEncoding(MemOp.getMemRRBase());
    unsigned C = regEncoding(MemOp.getMemRROffReg());
    // ARCompact `ld rA, [rB, rC]` — 32-bit ALU-form load. Base word
    // `0x20300000` captured from `arceb-elf32-gcc -mcpu=arc700`; bits
    // [26:24] = B[2:0], [14:12] = B[5:3], [11:6] = C, [5:0] = A.
    // Bit 22 stays 0 (plain load, no base-register update).
    uint32_t Insn = 0x20300000u;
    Insn |= (B & 0x7) << 24;
    Insn |= ((B >> 3) & 0x7) << 12;
    Insn |= (C & 0x3F) << 6;
    Insn |= (A & 0x3F);
    emitRawInsn32(Out, Insn);
    return false;
  }

  return Error(IDLoc, "unsupported ld addressing mode");
}

// `ld.ab rA, [rB, rC]` — post-increment load. Bit 22 (AA = PostInc) is
// the differentiator from the plain `ld` register-offset form.
bool ARCAsmParser::emitLdAb(SMLoc IDLoc, OperandVector &Operands,
                             MCStreamer &Out) {
  if (Operands.size() != 3)
    return Error(IDLoc, "expected `ld.ab rA, [rB, rC]`");
  auto &RegOp = static_cast<ARCOperand &>(*Operands[1]);
  auto &MemOp = static_cast<ARCOperand &>(*Operands[2]);
  if (RegOp.Kind != ARCOperand::Register || MemOp.Kind != ARCOperand::MemoryRR)
    return Error(IDLoc, "ld.ab requires `rA, [rB, rC]`");

  unsigned A = regEncoding(RegOp.getReg());
  unsigned B = regEncoding(MemOp.getMemRRBase());
  unsigned C = regEncoding(MemOp.getMemRROffReg());
  // 0x24b0_330d captured for `ld.ab r13, [sp, r12]` (sp=28, r12=12,
  // r13=13). Base = 0x20B00000 (bit 23 set for post-inc), same field
  // layout as the plain register-offset LD above.
  uint32_t Insn = 0x20B00000u;
  Insn |= (B & 0x7) << 24;
  Insn |= ((B >> 3) & 0x7) << 12;
  Insn |= (C & 0x3F) << 6;
  Insn |= (A & 0x3F);
  emitRawInsn32(Out, Insn);
  return false;
}

// Shared ALU dispatch used by the GEN4 (major 0x04) binary ops ADD / SUB /
// AND / OR / XOR and the EXT5 (major 0x05) shift ops ASL / LSR / ASR /
// ROR. All of them share the same (rA, rB, rC|u6|limm) operand shape and
// the td multiclass `ArcBinaryInst` generates `_rrr` / `_rru6` /
// `_rrlimm` definitions with matching MCInst operand ordering. Callers
// pass the three opcode enums; the helper picks the encoding that fits
// the third operand.
bool ARCAsmParser::emitBinaryALU(SMLoc IDLoc, StringRef Name,
                                  OperandVector &Operands, MCStreamer &Out,
                                  unsigned RRR, unsigned RRU6,
                                  unsigned RRLImm) {
  if (Operands.size() != 4)
    return Error(IDLoc, Twine("expected `") + Name + " rA, rB, <op>`");
  auto &A = static_cast<ARCOperand &>(*Operands[1]);
  auto &B = static_cast<ARCOperand &>(*Operands[2]);
  auto &C = static_cast<ARCOperand &>(*Operands[3]);
  if (A.Kind != ARCOperand::Register || B.Kind != ARCOperand::Register)
    return Error(IDLoc,
                 Twine(Name) + " first two operands must be registers");

  if (C.Kind == ARCOperand::Register) {
    MCInst Inst;
    Inst.setOpcode(RRR);
    Inst.addOperand(MCOperand::createReg(A.getReg()));
    Inst.addOperand(MCOperand::createReg(B.getReg()));
    Inst.addOperand(MCOperand::createReg(C.getReg()));
    Inst.setLoc(IDLoc);
    Out.emitInstruction(Inst, getSTI());
    return false;
  }

  if (C.Kind != ARCOperand::Immediate)
    return Error(IDLoc, Twine(Name) +
                            " third operand must be register or immediate");

  if (auto *CE = dyn_cast<MCConstantExpr>(C.getImmExpr())) {
    int64_t V = CE->getValue();
    if (fitsInUnsigned(V, 6)) {
      MCInst Inst;
      Inst.setOpcode(RRU6);
      Inst.addOperand(MCOperand::createReg(A.getReg()));
      Inst.addOperand(MCOperand::createReg(B.getReg()));
      Inst.addOperand(MCOperand::createImm(V));
      Inst.setLoc(IDLoc);
      Out.emitInstruction(Inst, getSTI());
      return false;
    }
  }

  MCInst Inst;
  Inst.setOpcode(RRLImm);
  Inst.addOperand(MCOperand::createReg(A.getReg()));
  Inst.addOperand(MCOperand::createReg(B.getReg()));
  Inst.addOperand(MCOperand::createExpr(C.getImmExpr()));
  Inst.setLoc(IDLoc);
  Out.emitInstruction(Inst, getSTI());
  return false;
}

// Single-bit ops (BCLR / BSET / BMSK / BXOR) share the same shape as the
// ALU binaries but have no usable LIMM encoding in our .td: the
// `ARC_B{CLR,SET,MSK,XOR}_a_b_limm` definitions are marked
// `isCodeGenOnly = 1`. In practice bit-position operands are always
// 0..31 so the u6 form suffices. We emit an error for out-of-range
// immediates rather than silently falling through to a raw word.
bool ARCAsmParser::emitBitOp(SMLoc IDLoc, StringRef Name,
                              OperandVector &Operands, MCStreamer &Out,
                              unsigned RRR, unsigned RRU6) {
  if (Operands.size() != 4)
    return Error(IDLoc, Twine("expected `") + Name + " rA, rB, rC|u6`");
  auto &A = static_cast<ARCOperand &>(*Operands[1]);
  auto &B = static_cast<ARCOperand &>(*Operands[2]);
  auto &C = static_cast<ARCOperand &>(*Operands[3]);
  if (A.Kind != ARCOperand::Register || B.Kind != ARCOperand::Register)
    return Error(IDLoc,
                 Twine(Name) + " first two operands must be registers");

  if (C.Kind == ARCOperand::Register) {
    MCInst Inst;
    Inst.setOpcode(RRR);
    Inst.addOperand(MCOperand::createReg(A.getReg()));
    Inst.addOperand(MCOperand::createReg(B.getReg()));
    Inst.addOperand(MCOperand::createReg(C.getReg()));
    Inst.setLoc(IDLoc);
    Out.emitInstruction(Inst, getSTI());
    return false;
  }

  if (C.Kind != ARCOperand::Immediate)
    return Error(IDLoc, Twine(Name) +
                            " third operand must be register or immediate");

  auto *CE = dyn_cast<MCConstantExpr>(C.getImmExpr());
  if (!CE)
    return Error(IDLoc, Twine(Name) +
                            " bit-position operand must be a constant");
  int64_t V = CE->getValue();
  if (!fitsInUnsigned(V, 6))
    return Error(IDLoc, Twine(Name) +
                            " bit position must fit in u6 (0..63)");

  MCInst Inst;
  Inst.setOpcode(RRU6);
  Inst.addOperand(MCOperand::createReg(A.getReg()));
  Inst.addOperand(MCOperand::createReg(B.getReg()));
  Inst.addOperand(MCOperand::createImm(V));
  Inst.setLoc(IDLoc);
  Out.emitInstruction(Inst, getSTI());
  return false;
}

// Zero-operand mnemonics: `rtie`, `nop`, `nop_s`. The underlying td defs
// pin every instruction bit via `let Inst{31-0} = ...` so we just build
// an empty MCInst and let the streamer pick the right width (4 bytes for
// `rtie` / `nop`, 2 bytes for `nop_s`).
bool ARCAsmParser::emitZeroOp(SMLoc IDLoc, StringRef Name,
                               OperandVector &Operands, MCStreamer &Out,
                               unsigned Opcode) {
  if (Operands.size() != 1)
    return Error(IDLoc, Twine("expected bare `") + Name + "`");
  MCInst Inst;
  Inst.setOpcode(Opcode);
  Inst.setLoc(IDLoc);
  Out.emitInstruction(Inst, getSTI());
  return false;
}

// `j [<reg>]` — 32-bit indirect jump without delay slot (ARC::J, subop
// 0x20, F32_DOP_RR with A=0 and B=0 pinned by the td). `j <expr>` — same
// subop but LIMM form (ARC::J_LImm). Delay-slot `j.d [<reg>]` stays in
// emitJdBlink because its td def is isCodeGenOnly.
bool ARCAsmParser::emitJ(SMLoc IDLoc, OperandVector &Operands,
                          MCStreamer &Out) {
  if (Operands.size() != 2)
    return Error(IDLoc, "expected `j [<reg>]` or `j <expr>`");
  auto &Op = static_cast<ARCOperand &>(*Operands[1]);

  if (Op.Kind == ARCOperand::Memory) {
    if (Op.getMemBase() == MCRegister() || Op.getMemOffset() != 0)
      return Error(IDLoc, "j target must be `[<reg>]`");
    MCInst Inst;
    Inst.setOpcode(ARC::J);
    Inst.addOperand(MCOperand::createReg(Op.getMemBase()));
    Inst.setLoc(IDLoc);
    Out.emitInstruction(Inst, getSTI());
    return false;
  }

  if (Op.Kind == ARCOperand::Immediate) {
    MCInst Inst;
    Inst.setOpcode(ARC::J_LImm);
    Inst.addOperand(MCOperand::createExpr(Op.getImmExpr()));
    Inst.setLoc(IDLoc);
    Out.emitInstruction(Inst, getSTI());
    return false;
  }

  return Error(IDLoc, "j target must be `[<reg>]` or a constant/symbol");
}

// `brcc rB, rC_or_u6, label` where `cc` is one of the six compare-branch
// predicates. Maps to BRcc_rr or BRcc_ru6 depending on operand kind.
bool ARCAsmParser::emitBr(SMLoc IDLoc, StringRef Name, OperandVector &Operands,
                           MCStreamer &Out) {
  if (Operands.size() != 4)
    return Error(IDLoc, "expected `br<cc> rB, rC|u6, label`");
  auto &Left = static_cast<ARCOperand &>(*Operands[1]);
  auto &Right = static_cast<ARCOperand &>(*Operands[2]);
  auto &Target = static_cast<ARCOperand &>(*Operands[3]);
  if (Left.Kind != ARCOperand::Register)
    return Error(IDLoc, "brcc first operand must be a register");
  if (Target.Kind != ARCOperand::Immediate)
    return Error(IDLoc, "brcc branch target must be a label");

  unsigned CC = StringSwitch<unsigned>(Name)
                    .Case("breq", ARCCC::BREQ)
                    .Case("brne", ARCCC::BRNE)
                    .Case("brlt", ARCCC::BRLT)
                    .Case("brge", ARCCC::BRGE)
                    .Case("brlo", ARCCC::BRLO)
                    .Case("brhs", ARCCC::BRHS)
                    .Default(~0u);
  if (CC == ~0u)
    return Error(IDLoc, "unknown brcc mnemonic");

  if (Right.Kind == ARCOperand::Register) {
    MCInst Inst;
    Inst.setOpcode(ARC::BRcc_rr);
    Inst.addOperand(MCOperand::createExpr(Target.getImmExpr()));
    Inst.addOperand(MCOperand::createReg(Left.getReg()));
    Inst.addOperand(MCOperand::createReg(Right.getReg()));
    Inst.addOperand(MCOperand::createImm(CC));
    Inst.setLoc(IDLoc);
    Out.emitInstruction(Inst, getSTI());
    return false;
  }

  if (Right.Kind == ARCOperand::Immediate) {
    int64_t V = 0;
    if (auto *CE = dyn_cast<MCConstantExpr>(Right.getImmExpr()))
      V = CE->getValue();
    else
      return Error(IDLoc, "brcc second operand must be constant or register");
    if (!fitsInUnsigned(V, 6))
      return Error(IDLoc, "brcc immediate does not fit in u6");
    MCInst Inst;
    Inst.setOpcode(ARC::BRcc_ru6);
    Inst.addOperand(MCOperand::createExpr(Target.getImmExpr()));
    Inst.addOperand(MCOperand::createReg(Left.getReg()));
    Inst.addOperand(MCOperand::createImm(V));
    Inst.addOperand(MCOperand::createImm(CC));
    Inst.setLoc(IDLoc);
    Out.emitInstruction(Inst, getSTI());
    return false;
  }

  return Error(IDLoc, "brcc second operand must be register or immediate");
}

// `b <label>` — unconditional 25-bit far branch. Encoded as Bcc with
// condition code AL.
bool ARCAsmParser::emitBUncond(SMLoc IDLoc, OperandVector &Operands,
                                MCStreamer &Out) {
  if (Operands.size() != 2)
    return Error(IDLoc, "expected `b <label>`");
  auto &Target = static_cast<ARCOperand &>(*Operands[1]);
  if (Target.Kind != ARCOperand::Immediate)
    return Error(IDLoc, "b target must be a label");
  MCInst Inst;
  Inst.setOpcode(ARC::Bcc);
  Inst.addOperand(MCOperand::createExpr(Target.getImmExpr()));
  Inst.addOperand(MCOperand::createImm(ARCCC::AL));
  Inst.setLoc(IDLoc);
  Out.emitInstruction(Inst, getSTI());
  return false;
}

// `bl <label>` — unconditional 25-bit far call.
bool ARCAsmParser::emitBl(SMLoc IDLoc, OperandVector &Operands,
                           MCStreamer &Out) {
  if (Operands.size() != 2)
    return Error(IDLoc, "expected `bl <label>`");
  auto &Target = static_cast<ARCOperand &>(*Operands[1]);
  if (Target.Kind != ARCOperand::Immediate)
    return Error(IDLoc, "bl target must be a label");
  MCInst Inst;
  Inst.setOpcode(ARC::BL);
  Inst.addOperand(MCOperand::createExpr(Target.getImmExpr()));
  Inst.setLoc(IDLoc);
  Out.emitInstruction(Inst, getSTI());
  return false;
}

// `flag <op>` — set / clear status flags.
// Register form maps to ARC_FLAG_c, immediate to ARC_FLAG_u6.
bool ARCAsmParser::emitFlag(SMLoc IDLoc, OperandVector &Operands,
                             MCStreamer &Out) {
  if (Operands.size() != 2)
    return Error(IDLoc, "expected `flag <reg>` or `flag <u6>`");
  auto &Op = static_cast<ARCOperand &>(*Operands[1]);

  if (Op.Kind == ARCOperand::Register) {
    MCInst Inst;
    Inst.setOpcode(ARC::ARC_FLAG_c);
    Inst.addOperand(MCOperand::createReg(Op.getReg()));
    Inst.setLoc(IDLoc);
    Out.emitInstruction(Inst, getSTI());
    return false;
  }

  if (Op.Kind != ARCOperand::Immediate)
    return Error(IDLoc, "flag operand must be register or constant");
  int64_t V = 0;
  if (auto *CE = dyn_cast<MCConstantExpr>(Op.getImmExpr()))
    V = CE->getValue();
  else
    return Error(IDLoc, "flag operand must be a constant expression");
  if (!fitsInUnsigned(V, 6))
    return Error(IDLoc, "flag value does not fit in u6");
  MCInst Inst;
  Inst.setOpcode(ARC::ARC_FLAG_u6);
  Inst.addOperand(MCOperand::createImm(V));
  Inst.setLoc(IDLoc);
  Out.emitInstruction(Inst, getSTI());
  return false;
}

// `j_s [blink]` — 16-bit compact return. Fixed encoding 0x7EE0 per
// J_S_BLINK in ARCInstrInfo.td.
bool ARCAsmParser::emitJsBlink(SMLoc IDLoc, OperandVector &Operands,
                                MCStreamer &Out) {
  if (Operands.size() != 2)
    return Error(IDLoc, "expected `j_s [blink]`");
  auto &MemOp = static_cast<ARCOperand &>(*Operands[1]);
  if (MemOp.Kind != ARCOperand::Memory || MemOp.getMemBase() != ARC::BLINK ||
      MemOp.getMemOffset() != 0)
    return Error(IDLoc, "j_s only supports `[blink]`");
  emitRawInsn16(Out, 0x7EE0);
  return false;
}

// `lr rB, [aux]` — load aux-register into GPR. Aux index is expected to
// fit in u6 (0..63); STATUS32 (0x0A), STATUS32_L1 (0x0B), IDENTITY
// (0x04) and every other standard ARC700 aux reg we care about fit
// trivially. Wider aux references would need the s12 or LIMM form,
// which we can add later if needed.
// Raw encoding for `lr rB, [...]` / `sr rB, [...]`. Major opcode 0b00100,
// subop 0x2A (lr) or 0x2B (sr). Operand format selected via the P field:
//
//   P=00: `rB, [rC]` (reg-indirect; rC=62 selects the LIMM form)
//   P=01: `rB, [u6]` — 6-bit unsigned aux index
//   P=10: `rB, [s12]` — 12-bit signed aux index, split across bits 11:6 (low)
//                       and bits 5:0 (high)
//
// Bit layout:
//   [31:27] = major (0b00100)
//   [26:24] = B[2:0]
//   [23:22] = P
//   [21:16] = subop (0x2A lr / 0x2B sr)
//   [15]    = F (0 for lr/sr)
//   [14:12] = B[5:3]
//   [11:6]  = u6 / C / s12-low / LIMM-marker (62) depending on P
//   [5:0]   = 0 / A / s12-high
//
static uint32_t encodeLrSrBase(unsigned Subop, unsigned BReg, unsigned P) {
  uint32_t Insn = 0x20000000u;            // major 0b00100
  Insn |= ((BReg & 0x07) << 24);          // B[2:0]
  Insn |= ((BReg & 0x38) << (12 - 3));    // B[5:3] → bits 14:12
  Insn |= ((P & 0x03) << 22);             // P field
  Insn |= ((Subop & 0x3F) << 16);         // sub-opcode
  return Insn;
}

// Emit `lr rB, [aux]` or `sr rB, [aux]`. Chooses u6 / s12 / limm encoding
// based on the aux index.
bool ARCAsmParser::emitLr(SMLoc IDLoc, OperandVector &Operands,
                           MCStreamer &Out) {
  if (Operands.size() != 3)
    return Error(IDLoc, "expected `lr rB, [aux]`");
  auto &Dst = static_cast<ARCOperand &>(*Operands[1]);
  auto &Src = static_cast<ARCOperand &>(*Operands[2]);
  if (Dst.Kind != ARCOperand::Register)
    return Error(IDLoc, "lr destination must be a register");
  if (Src.Kind != ARCOperand::Memory)
    return Error(IDLoc, "lr source must be `[aux]` or `[rC]`");
  unsigned B = regEncoding(Dst.getReg());

  // `lr rB, [rC]` — reg-indirect aux access, P=00, rC at bits 11:6.
  if (Src.getMemBase() != MCRegister()) {
    if (Src.getMemOffset() != 0)
      return Error(IDLoc, "lr `[rC, imm]` form not supported");
    unsigned C = regEncoding(Src.getMemBase());
    if (C == 62)
      return Error(IDLoc, "lr `[limm]` use bare immediate instead");
    uint32_t Insn = encodeLrSrBase(0x2A, B, 0b00);
    Insn |= ((uint32_t)C & 0x3F) << 6;
    emitRawInsn32(Out, Insn);
    return false;
  }
  int64_t Aux = Src.getMemOffset();

  if (fitsInUnsigned(Aux, 6)) {
    // u6 → P=01, bits 11:6 = u6, bits 5:0 = 0
    uint32_t Insn = encodeLrSrBase(0x2A, B, 0b01);
    Insn |= ((uint32_t)Aux & 0x3F) << 6;
    emitRawInsn32(Out, Insn);
    return false;
  }
  if (fitsInSigned(Aux, 12)) {
    // s12 → P=10, bits 11:6 = s12[5:0], bits 5:0 = s12[11:6]
    uint32_t Insn = encodeLrSrBase(0x2A, B, 0b10);
    uint32_t S = (uint32_t)(Aux & 0xFFF);
    Insn |= (S & 0x3F) << 6;          // low 6 bits at [11:6]
    Insn |= (S >> 6) & 0x3F;          // high 6 bits at [5:0]
    emitRawInsn32(Out, Insn);
    return false;
  }
  // limm → P=00, bits 11:6 = 62 (C=LIMM marker), bits 5:0 = 0, followed
  // by a 4-byte LIMM word big-endian.
  uint32_t Insn = encodeLrSrBase(0x2A, B, 0b00);
  Insn |= 62u << 6;
  emitRawInsn32(Out, Insn);
  emitRawInsn32(Out, (uint32_t)(Aux & 0xFFFFFFFF));
  return false;
}

// `sr rB, [aux]` — store GPR into aux-register. Mirror of emitLr.
bool ARCAsmParser::emitSr(SMLoc IDLoc, OperandVector &Operands,
                           MCStreamer &Out) {
  if (Operands.size() != 3)
    return Error(IDLoc, "expected `sr rB, [aux]`");
  auto &Src = static_cast<ARCOperand &>(*Operands[1]);
  auto &Dst = static_cast<ARCOperand &>(*Operands[2]);
  if (Src.Kind != ARCOperand::Register)
    return Error(IDLoc, "sr source must be a register");
  if (Dst.Kind != ARCOperand::Memory)
    return Error(IDLoc, "sr destination must be `[aux]` or `[rC]`");
  unsigned B = regEncoding(Src.getReg());

  // `sr rB, [rC]` — reg-indirect aux access, P=00.
  if (Dst.getMemBase() != MCRegister()) {
    if (Dst.getMemOffset() != 0)
      return Error(IDLoc, "sr `[rC, imm]` form not supported");
    unsigned C = regEncoding(Dst.getMemBase());
    if (C == 62)
      return Error(IDLoc, "sr `[limm]` use bare immediate instead");
    uint32_t Insn = encodeLrSrBase(0x2B, B, 0b00);
    Insn |= ((uint32_t)C & 0x3F) << 6;
    emitRawInsn32(Out, Insn);
    return false;
  }
  int64_t Aux = Dst.getMemOffset();

  if (fitsInUnsigned(Aux, 6)) {
    uint32_t Insn = encodeLrSrBase(0x2B, B, 0b01);
    Insn |= ((uint32_t)Aux & 0x3F) << 6;
    emitRawInsn32(Out, Insn);
    return false;
  }
  if (fitsInSigned(Aux, 12)) {
    uint32_t Insn = encodeLrSrBase(0x2B, B, 0b10);
    uint32_t S = (uint32_t)(Aux & 0xFFF);
    Insn |= (S & 0x3F) << 6;
    Insn |= (S >> 6) & 0x3F;
    emitRawInsn32(Out, Insn);
    return false;
  }
  uint32_t Insn = encodeLrSrBase(0x2B, B, 0b00);
  Insn |= 62u << 6;
  emitRawInsn32(Out, Insn);
  emitRawInsn32(Out, (uint32_t)(Aux & 0xFFFFFFFF));
  return false;
}

// Compact-reg encoding for ARCompact 16-bit insns (h_b table):
//   r0=0, r1=1, r2=2, r3=3, r12=4, r13=5, r14=6, r15=7.
// Returns -1 if the register has no compact encoding.
static int compactRegEncoding(MCRegister R) {
  unsigned E = regEncoding(R);
  if (E <= 3) return E;
  if (E >= 12 && E <= 15) return E - 8;
  return -1;
}

// `push rB`     -> st.a   rB, [sp, -4]   (32-bit, ST major 0x03, AA=01)
// `pop  rB`     -> ld.ab  rB, [sp,  4]   (32-bit, LD major 0x02, AA=10)
// `push_s rB`   -> 16-bit ARC_PUSH_S_b   (b is compact-reg) | blink form
// `pop_s  rB`   -> 16-bit ARC_POP_S_b    (b is compact-reg) | blink form
//
// Encoding refs: ARCInstrFormats.td F32_ST_RS9 / F32_LD_RS9,
// ARCARCompactInstr16.td ARC_{PUSH,POP}_S_{b,blink}.
bool ARCAsmParser::emitPushPop(SMLoc IDLoc, StringRef Name,
                                OperandVector &Operands, MCStreamer &Out) {
  if (Operands.size() != 2)
    return Error(IDLoc, Twine("expected `") + Name + " <reg>`");
  auto &Op = static_cast<ARCOperand &>(*Operands[1]);
  if (Op.Kind != ARCOperand::Register)
    return Error(IDLoc, Twine(Name) + " operand must be a register");
  MCRegister Reg = Op.getReg();

  // 16-bit compact forms.
  if (Name == "push_s" || Name == "pop_s") {
    uint16_t Insn;
    if (Reg == ARC::BLINK) {
      Insn = (Name == "push_s") ? 0xC0F1 : 0xC0D1;
    } else {
      int B3 = compactRegEncoding(Reg);
      if (B3 < 0)
        return Error(IDLoc, Twine(Name) +
                              " requires r0-r3, r12-r15, or blink");
      uint16_t Base = (Name == "push_s") ? 0xC0E1 : 0xC0C1;
      Insn = Base | ((uint16_t)B3 << 8);
    }
    emitRawInsn16(Out, Insn);
    return false;
  }

  // 32-bit forms via st.a / ld.ab on sp.
  unsigned C = regEncoding(Reg);                 // operand reg
  unsigned B = regEncoding(ARC::SP);             // base = sp = 28
  if (Name == "push") {
    // st.a C, [sp, -4]: aa=01, di=0, zz=00, S9=-4 (0x1FC in 9-bit)
    uint32_t S9 = 0x1FCu;
    uint32_t Insn = 0x18000000u;                 // [31:27]=00011 (ST major)
    Insn |= ((B & 0x07) << 24);                  // B[2:0]
    Insn |= ((S9 & 0xFF) << 16);                 // S9[7:0]
    Insn |= ((S9 >> 8) & 0x1) << 15;             // S9[8]
    Insn |= ((B & 0x38) << (12 - 3));            // B[5:3] -> 14:12
    Insn |= ((C & 0x3F) << 6);                   // C
    Insn |= (0b01u << 3);                        // aa = PreInc
    emitRawInsn32(Out, Insn);
    return false;
  }
  // pop -> ld.ab C, [sp, 4]: aa=10, di=0, zz=00, x=0, S9=4
  uint32_t S9 = 0x004u;
  uint32_t Insn = 0x10000000u;                   // [31:27]=00010 (LD major)
  Insn |= ((B & 0x07) << 24);                    // B[2:0]
  Insn |= ((S9 & 0xFF) << 16);                   // S9[7:0]
  Insn |= ((S9 >> 8) & 0x1) << 15;               // S9[8]
  Insn |= ((B & 0x38) << (12 - 3));              // B[5:3]
  Insn |= (0b10u << 9);                          // aa = PostInc
  Insn |= (C & 0x3F);                            // A field [5:0]
  emitRawInsn32(Out, Insn);
  return false;
}

// `j.d [blink]` — 32-bit indirect jump with delay slot via blink.
// Captured from GNU as: `0x20210740` + (blink_id << 6) = `0x202107C0`
// because blink's 6-bit register id is 0x1F = 31, landing at bits 11..6.
bool ARCAsmParser::emitJdBlink(SMLoc IDLoc, OperandVector &Operands,
                                MCStreamer &Out) {
  if (Operands.size() != 2)
    return Error(IDLoc, "expected `j.d [<reg>]`");
  auto &MemOp = static_cast<ARCOperand &>(*Operands[1]);
  if (MemOp.Kind != ARCOperand::Memory || MemOp.getMemOffset() != 0)
    return Error(IDLoc, "j.d target must be `[<reg>]`");
  unsigned C = regEncoding(MemOp.getMemBase());
  uint32_t Insn = 0x20210740u | ((C & 0x3F) << 6);
  emitRawInsn32(Out, Insn);
  return false;
}

// ===========================================================================
// Top-level dispatch
// ===========================================================================

bool ARCAsmParser::matchAndEmitInstruction(SMLoc IDLoc, unsigned &Opcode,
                                            OperandVector &Operands,
                                            MCStreamer &Out,
                                            uint64_t &ErrorInfo,
                                            bool MatchingInlineAsm) {
  if (Operands.empty())
    return Error(IDLoc, "no mnemonic");

  auto &Mnem = static_cast<ARCOperand &>(*Operands[0]);
  StringRef Name = Mnem.getToken();
  Opcode = 0;

  if (Name == "mov")
    return emitMov(IDLoc, Operands, Out);
  if (Name.ends_with(".di"))
    return emitDiMem(IDLoc, Name, Operands, Out);
  if (Name == "st")
    return emitSt(IDLoc, Operands, Out, ARC::ST_rs9);
  if (Name == "stb")
    return emitSt(IDLoc, Operands, Out, ARC::STB_rs9);
  if (Name == "sth" || Name == "stw")
    return emitSt(IDLoc, Operands, Out, ARC::STH_rs9);
  if (Name == "ld")
    return emitLd(IDLoc, Operands, Out, ARC::LD_rs9);
  if (Name == "ldb")
    return emitLd(IDLoc, Operands, Out, ARC::LDB_rs9);
  if (Name == "ldh" || Name == "ldw")
    return emitLd(IDLoc, Operands, Out, ARC::LDH_rs9);
  if (Name == "ld.ab")
    return emitLdAb(IDLoc, Operands, Out);

  // GEN4 ALU binary ops — major opcode 0b00100 (0x04).
  if (Name == "add")
    return emitBinaryALU(IDLoc, Name, Operands, Out, ARC::ADD_rrr,
                         ARC::ADD_rru6, ARC::ADD_rrlimm);
  if (Name == "sub")
    return emitBinaryALU(IDLoc, Name, Operands, Out, ARC::SUB_rrr,
                         ARC::SUB_rru6, ARC::SUB_rrlimm);
  if (Name == "and")
    return emitBinaryALU(IDLoc, Name, Operands, Out, ARC::AND_rrr,
                         ARC::AND_rru6, ARC::AND_rrlimm);
  if (Name == "or")
    return emitBinaryALU(IDLoc, Name, Operands, Out, ARC::OR_rrr,
                         ARC::OR_rru6, ARC::OR_rrlimm);
  if (Name == "xor")
    return emitBinaryALU(IDLoc, Name, Operands, Out, ARC::XOR_rrr,
                         ARC::XOR_rru6, ARC::XOR_rrlimm);

  // EXT5 shifts — major opcode 0b00101 (0x05).
  if (Name == "asl")
    return emitBinaryALU(IDLoc, Name, Operands, Out, ARC::ASL_rrr,
                         ARC::ASL_rru6, ARC::ASL_rrlimm);
  if (Name == "lsr")
    return emitBinaryALU(IDLoc, Name, Operands, Out, ARC::LSR_rrr,
                         ARC::LSR_rru6, ARC::LSR_rrlimm);
  if (Name == "asr")
    return emitBinaryALU(IDLoc, Name, Operands, Out, ARC::ASR_rrr,
                         ARC::ASR_rru6, ARC::ASR_rrlimm);
  if (Name == "ror")
    return emitBinaryALU(IDLoc, Name, Operands, Out, ARC::ROR_rrr,
                         ARC::ROR_rru6, ARC::ROR_rrlimm);

  // Single-bit ops — GEN4 sub-opcodes 0x0F..0x13.
  if (Name == "bclr")
    return emitBitOp(IDLoc, Name, Operands, Out, ARC::ARC_BCLR_a_b_c,
                     ARC::ARC_BCLR_a_b_u6);
  if (Name == "bset")
    return emitBitOp(IDLoc, Name, Operands, Out, ARC::ARC_BSET_a_b_c,
                     ARC::ARC_BSET_a_b_u6);
  if (Name == "bmsk")
    return emitBitOp(IDLoc, Name, Operands, Out, ARC::ARC_BMSK_a_b_c,
                     ARC::ARC_BMSK_a_b_u6);
  if (Name == "bxor")
    return emitBitOp(IDLoc, Name, Operands, Out, ARC::ARC_BXOR_a_b_c,
                     ARC::ARC_BXOR_a_b_u6);

  // Zero-operand mnemonics.
  if (Name == "rtie")
    return emitZeroOp(IDLoc, Name, Operands, Out, ARC::ARC_RTIE_0);
  if (Name == "nop")
    return emitZeroOp(IDLoc, Name, Operands, Out, ARC::ARC_NOP_0);
  if (Name == "nop_s")
    return emitZeroOp(IDLoc, Name, Operands, Out, ARC::ARC_NOP_S_0);
  if (Name == "sync")
    return emitZeroOp(IDLoc, Name, Operands, Out, ARC::ARC_SYNC_0);
  if (Name == "sleep")
    return emitZeroOp(IDLoc, Name, Operands, Out, ARC::ARC_SLEEP_0);
  if (Name == "brk")
    return emitZeroOp(IDLoc, Name, Operands, Out, ARC::ARC_BRK_0);

  if (Name == "breq" || Name == "brne" || Name == "brlt" || Name == "brge" ||
      Name == "brlo" || Name == "brhs")
    return emitBr(IDLoc, Name, Operands, Out);
  if (Name == "b")
    return emitBUncond(IDLoc, Operands, Out);
  if (Name == "bl")
    return emitBl(IDLoc, Operands, Out);
  if (Name == "flag")
    return emitFlag(IDLoc, Operands, Out);
  if (Name == "j")
    return emitJ(IDLoc, Operands, Out);
  if (Name == "j_s")
    return emitJsBlink(IDLoc, Operands, Out);
  if (Name == "j.d")
    return emitJdBlink(IDLoc, Operands, Out);
  if (Name == "lr")
    return emitLr(IDLoc, Operands, Out);
  if (Name == "sr")
    return emitSr(IDLoc, Operands, Out);
  if (Name == "push" || Name == "pop" || Name == "push_s" || Name == "pop_s")
    return emitPushPop(IDLoc, Name, Operands, Out);

  return Error(IDLoc, Twine("ARC asm parser: unsupported mnemonic `") + Name +
                           "`");
}

} // end anonymous namespace

extern "C" LLVM_ABI LLVM_EXTERNAL_VISIBILITY void LLVMInitializeARCAsmParser() {
  RegisterMCAsmParser<ARCAsmParser> X(getTheARCTarget());
  RegisterMCAsmParser<ARCAsmParser> Y(getTheARCebTarget());
}
