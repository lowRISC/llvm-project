; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

define i32 @leaf(i32 %x) {
; RV32I-LABEL: leaf:
; RV32I-NOT: pac t6, ra, sp
; RV32I-NOT: sw t6, {{[0-9]+}}(sp)
; RV32I-NOT: lw t6, {{[0-9]+}}(sp)
; RV32I-NOT: aut ra, ra, t6, sp
; RV32I: ret
  ret i32 %x
}

define i32 @leaf_sign_none(i32 %x) "sign-return-address"="none" {
; RV32I-LABEL: leaf_sign_none:
; RV32I-NOT: pac t6, ra, sp
; RV32I-NOT: sw t6, {{[0-9]+}}(sp)
; RV32I-NOT: lw t6, {{[0-9]+}}(sp)
; RV32I-NOT: aut ra, ra, t6, sp
; RV32I: ret
  ret i32 %x
}

define i32 @leaf_sign_non_leaf(i32 %x) "sign-return-address"="non-leaf" {
; RV32I-LABEL: leaf_sign_non_leaf:
; RV32I-NOT: pac t6, ra, sp
; RV32I-NOT: sw t6, {{[0-9]+}}(sp)
; RV32I-NOT: lw t6, {{[0-9]+}}(sp)
; RV32I-NOT: aut ra, ra, t6, sp
; RV32I: ret
  ret i32 %x
}

define i32 @leaf_sign_all(i32 %x) "sign-return-address"="all" {
; RV32I-LABEL: leaf_sign_all:
; RV32I: pac t6, ra, sp
; RV32I-NOT: sw t6, {{[0-9]+}}(sp)
; RV32I-NOT: lw t6, {{[0-9]+}}(sp)
; RV32I: aut ra, ra, t6, sp
; RV32I-NEXT: ret
  ret i32 %x
}

declare i32 @foo(i32)

define i32 @non_leaf_sign_all(i32 %x) "sign-return-address"="all" {
; RV32I-LABEL: non_leaf_sign_all:
; RV32I: pac t6, ra, sp
; RV32I: sw t6, {{[0-9]+}}(sp)
; RV32I: lw t6, {{[0-9]+}}(sp)
; RV32I: aut ra, ra, t6, sp
; RV32I-NEXT: ret
  %call = call i32 @foo(i32 %x)
  ret i32 %call
}

define i32 @non_leaf_sign_non_leaf(i32 %x) "sign-return-address"="non-leaf" {
; RV32I-LABEL: non_leaf_sign_non_leaf:
; RV32I: pac t6, ra, sp
; RV32I: sw t6, {{[0-9]+}}(sp)
; RV32I: lw t6, {{[0-9]+}}(sp)
; RV32I: aut ra, ra, t6, sp
; RV32I-NEXT: ret
  %call = call i32 @foo(i32 %x)
  ret i32 %call
}
