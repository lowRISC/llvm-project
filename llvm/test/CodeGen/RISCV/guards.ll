; RUN: llc -mtriple=riscv32 -mattr=+guards -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s
;
; RUN: llc -mtriple=riscv32 -mattr=+c,+guards -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32IC %s
;
; RUN: llc -mtriple=riscv32 -mattr=+guards -filetype=obj < %s \
; RUN:   | llvm-objdump -d --triple=riscv32 --no-print-imm-hex - \
; RUN:   | FileCheck -check-prefix=RV32I-OBJ %s
;
; RUN: llc -mtriple=riscv32 -mattr=+c,+guards -filetype=obj < %s \
; RUN:   | llvm-objdump -d --triple=riscv32 --no-print-imm-hex - \
; RUN:   | FileCheck -check-prefix=RV32IC-OBJ %s


define i32 @test_tail(i32 %i) nounwind {
; RV32I-LABEL: test_tail:
; RV32I:       # %bb.0:
; RV32I-NEXT:    tail test_tail
; RV32I-NEXT:  # %bb.1:
; RV32I-NEXT:    unimp
; RV32I-NEXT:    unimp
; RV32I-NOT:     unimp
;
; RV32IC-LABEL: test_tail:
; RV32IC:       # %bb.0:
; RV32IC-NEXT:    tail test_tail
; RV32IC-NEXT:  # %bb.1:
; RV32IC-NEXT:    unimp
; RV32IC-NEXT:    unimp
; RV32IC-NOT:     unimp
;
; RV32I-OBJ-LABEL: <test_tail>:
; RV32I-OBJ-NEXT:   auipc t1, 0
; RV32I-OBJ-NEXT:   jr t1
; RV32I-OBJ-NEXT:   unimp
; RV32I-OBJ-NEXT:   unimp
; RV32I-OBJ-NOT:    unimp
;
; RV32IC-OBJ-LABEL: <test_tail>:
; RV32IC-OBJ-NEXT:  auipc t1, 0
; RV32IC-OBJ-NEXT:  jr t1
; RV32IC-OBJ-NEXT:  unimp
; RV32IC-OBJ-NEXT:  unimp
; RV32IC-OBJ-NOT:   unimp
  %r = tail call i32 @test_tail(i32 %i)
  ret i32 %r
}

define i32 @test_jump_and_ret(i1 %a) nounwind {
; RV32I-LABEL: test_jump_and_ret:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    andi a0, a0, 1
; RV32I-NEXT:    bnez a0, .LBB1_1
; RV32I-NEXT:  # %bb.4:
; RV32I-NEXT:    jump .LBB1_2, a0
; RV32I-NEXT:  # %bb.6:
; RV32I-NEXT:    unimp
; RV32I-NEXT:    unimp
; RV32I-NEXT:  .LBB1_1: # %iftrue
; RV32I-NEXT:    #APP
; RV32I-NEXT:    #NO_APP
; RV32I-NEXT:    #APP
; RV32I-NEXT:    .zero 1048576
; RV32I-NEXT:    #NO_APP
; RV32I-NEXT:    j .LBB1_3
; RV32I-NEXT:  # %bb.7:
; RV32I-NEXT:    unimp
; RV32I-NEXT:    unimp
; RV32I-NEXT:  .LBB1_2: # %jmp
; RV32I-NEXT:    #APP
; RV32I-NEXT:    #NO_APP
; RV32I-NEXT:  .LBB1_3: # %tail
; RV32I-NEXT:    li a0, 1
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
; RV32I-NEXT:  # %bb.8:
; RV32I-NEXT:    unimp
; RV32I-NEXT:    unimp
;
; RV32IC-LABEL: test_jump_and_ret:
; RV32IC:       # %bb.0:
; RV32IC-NEXT:    addi sp, sp, -16
; RV32IC-NEXT:    andi a0, a0, 1
; RV32IC-NEXT:    bnez a0, .LBB1_1
; RV32IC-NEXT:  # %bb.4:
; RV32IC-NEXT:    jump .LBB1_2, a0
; RV32IC-NEXT:  # %bb.6:
; RV32IC-NEXT:    unimp
; RV32IC-NEXT:    unimp
; RV32IC-NEXT:  .LBB1_1: # %iftrue
; RV32IC-NEXT:    #APP
; RV32IC-NEXT:    #NO_APP
; RV32IC-NEXT:    #APP
; RV32IC-NEXT:    .zero 1048576
; RV32IC-NEXT:    #NO_APP
; RV32IC-NEXT:    j .LBB1_3
; RV32IC-NEXT:  # %bb.7:
; RV32IC-NEXT:    unimp
; RV32IC-NEXT:    unimp
; RV32IC-NEXT:  .LBB1_2: # %jmp
; RV32IC-NEXT:    #APP
; RV32IC-NEXT:    #NO_APP
; RV32IC-NEXT:  .LBB1_3: # %tail
; RV32IC-NEXT:    li a0, 1
; RV32IC-NEXT:    addi sp, sp, 16
; RV32IC-NEXT:    ret
; RV32IC-NEXT:  # %bb.8:
; RV32IC-NEXT:    unimp
; RV32IC-NEXT:    unimp
;
; RV32I-OBJ-LABEL: <test_jump_and_ret>:
; RV32I-OBJ-NEXT:   addi sp, sp, -16
; RV32I-OBJ-NEXT:   andi  a0, a0, 1
; RV32I-OBJ-NEXT:   bnez  a0, 0x2c
; RV32I-OBJ-NEXT:   auipc a0, 256
; RV32I-OBJ-NEXT:   jr    28(a0)
; RV32I-OBJ-NEXT:   unimp
; RV32I-OBJ-NEXT:   unimp
; RV32I-OBJ-NEXT:   ...
; RV32I-OBJ-NEXT:   j       0x100038
; RV32I-OBJ-NEXT:   unimp
; RV32I-OBJ-NEXT:   unimp
; RV32I-OBJ-NEXT:   li      a0, 1
; RV32I-OBJ-NEXT:   addi    sp, sp, 16
; RV32I-OBJ-NEXT:   ret
; RV32I-OBJ-NEXT:   unimp
; RV32I-OBJ-NEXT:   unimp
; RV32I-OBJ-NOT:    unimp
;
; RV32IC-OBJ-LABEL: <test_jump_and_ret>:
; RV32IC-OBJ-NEXT:  addi sp, sp, -16
; RV32IC-OBJ-NEXT:  andi  a0, a0, 1
; RV32IC-OBJ-NEXT:  bnez  a0, 0x26
; RV32IC-OBJ-NEXT:  auipc a0, 256
; RV32IC-OBJ-NEXT:  jr    26(a0)
; RV32IC-OBJ-NEXT:  unimp
; RV32IC-OBJ-NEXT:  unimp
; RV32IC-OBJ-NEXT:  ...
; RV32IC-OBJ-NEXT:  j       0x100030
; RV32IC-OBJ-NEXT:  unimp
; RV32IC-OBJ-NEXT:  unimp
; RV32IC-OBJ-NEXT:  li      a0, 1
; RV32IC-OBJ-NEXT:  addi    sp, sp, 16
; RV32IC-OBJ-NEXT:  ret
; RV32IC-OBJ-NEXT:  unimp
; RV32IC-OBJ-NEXT:  unimp
; RV32IC-OBJ-NOT:   unimp
  br i1 %a, label %iftrue, label %jmp

jmp:
  call void asm sideeffect "", ""()
  br label %tail

iftrue:
  call void asm sideeffect "", ""()
  br label %space

space:
  call void asm sideeffect ".space 1048576", ""()
  br label %tail

tail:
  ret i32 1
}
