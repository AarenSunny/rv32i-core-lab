# Build Log

## Day 4 — 2026-09-04

### Morning: RV32I ALU

- Defined a compact ALU control map for ten RV32I datapath operations.
- Implemented 32-bit arithmetic, logic, comparisons, and masked shifts.
- Added a zero-result output for later branch control.
- Added 16 self-checking tests covering signedness and edge cases.
- Verified the design with Icarus Verilog host-side simulation.

Next slice: implement and verify the 32 × 32-bit register file with hard-wired
`x0` behavior.

