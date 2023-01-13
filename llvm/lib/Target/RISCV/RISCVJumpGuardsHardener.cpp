//===--- RISCVJumpGuardsHardener.cpp - Guard jumps hardening --------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// This pass adds `unimp` instructions after jumps, unconditional branches,
// returns, and tail calls. This protects against glitches that skip these
// instructions.

#include "RISCV.h"
#include "RISCVTargetMachine.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Support/Debug.h"
#include "llvm/Target/TargetOptions.h"
using namespace llvm;

#define DEBUG_TYPE "riscv-jump-guards"
#define RISCV_JUMP_GUARDS_NAME "RISCV Jump Guards Hardening"
namespace {

struct RISCVJumpGuardsHardener : public MachineFunctionPass {
private:
  const RISCVSubtarget *ST = nullptr;

public:
  static char ID;
  bool runOnMachineFunction(MachineFunction &Fn) override;

  RISCVJumpGuardsHardener() : MachineFunctionPass(ID) {}

  StringRef getPassName() const override {
    return RISCV_JUMP_GUARDS_NAME;
  }

private:
  MachineRegisterInfo *MRI;
};
} // end anonymous namespace

char RISCVJumpGuardsHardener::ID = 0;
INITIALIZE_PASS(RISCVJumpGuardsHardener, DEBUG_TYPE,
                RISCV_JUMP_GUARDS_NAME, false, false)

// Indicates if this is a jump instruction that is protected by jump guards
// (e.g. `unimp` instructions) when that option is enabled.
static bool hasJumpGuards(const MachineInstr &MI) {
  switch (MI.getOpcode()) {
  default:
    return false;
  case RISCV::PseudoTAIL:
  case RISCV::PseudoJump:
  case RISCV::PseudoRET:
  case RISCV::PseudoBR:
    return true;
  case RISCV::C_J: // J pseudo-instruction/alias expansion.
    return true;
  case RISCV::JALR: {
    // Check for possible RET pseudo-instruction (PseudoRET) expansion.
    MCRegister Rd = MI.getOperand(0).getReg();
    MCRegister Rs = MI.getOperand(1).getReg();
    return Rd == RISCV::X0 && Rs == RISCV::X1;
  }
  case RISCV::C_JR: {
    // Check for possible RET pseudo-instruction (PseudoRET) expansion.
    MCRegister Rs = MI.getOperand(0).getReg();
    return Rs == RISCV::X1;
  }
  case RISCV::JAL: {
    // Check for possible J pseudo-instruction/alias expansion.
    MCRegister Rd = MI.getOperand(0).getReg();
    return Rd == RISCV::X0;
  }
  }
}

bool RISCVJumpGuardsHardener::runOnMachineFunction(MachineFunction &Fn) {
  if (skipFunction(Fn.getFunction()))
    return false;

  ST = &Fn.getSubtarget<RISCVSubtarget>();
  if (!ST->hasFeature(RISCV::FeatureGuards))
    return false;

  const RISCVInstrInfo *TII;
  TII = static_cast<const RISCVInstrInfo *>(Fn.getSubtarget().getInstrInfo());

  bool MadeChange = false;
  MRI = &Fn.getRegInfo();
  for (MachineBasicBlock &MBB : Fn) {
    MachineBasicBlock::iterator MBBI = MBB.begin(), E = MBB.end();
    while (MBBI != E) {
      MachineBasicBlock::iterator NMBBI = std::next(MBBI);
      MachineInstr &MI = *MBBI;
      MBBI = NMBBI;
      if (hasJumpGuards(MI)) {
        DebugLoc DL = MI.getDebugLoc();
        auto HardeningMBB = Fn.CreateMachineBasicBlock(MBB.getBasicBlock());
        Fn.insert(++MBB.getIterator(), HardeningMBB);
        MachineBasicBlock::iterator HMBBI = HardeningMBB->begin();
        BuildMI(*HardeningMBB, HMBBI, DL, TII->get(RISCV::GUARD_UNIMP));
        BuildMI(*HardeningMBB, HMBBI, DL, TII->get(RISCV::GUARD_UNIMP));
        MadeChange |= true;
        break;
      }
    }
  }

  return MadeChange;
}

FunctionPass *llvm::createRISCVJumpGuardsHardenerPass() {
  return new RISCVJumpGuardsHardener();
}
