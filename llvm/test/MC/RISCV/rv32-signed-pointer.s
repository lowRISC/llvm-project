# RUN: llvm-mc %s -triple=riscv32 -riscv-no-aliases -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-INST,CHECK-ENC %s

# CHECK-INST: pac t6, ra, sp
# CHECK-ENC: # encoding:  [0x8b,0x8f,0x20,0x00]
# pac rd, rs1, rs2
# R-Type: 0000000_00010_00001_000_11111_0001011
pac t6, ra, sp

# CHECK-INST: aut ra, ra, t6, sp
# CHECK-ENC: # encoding:  [0x8b,0x90,0xf0,0x11]
# aut rd, rs1, rs2, rs3
# R4-Type: 00010_00_11111_00001_001_00001_0001011
aut ra, ra, t6, sp
