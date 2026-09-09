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

### Afternoon: register file

- Implemented two asynchronous read ports and one clocked write port.
- Omitted `x0` from storage so its zero value is structural, not conventional.
- Verified independent reads, overwrites, disabled writes, and address 31.
- Verified that attempted writes to `x0` cannot change its value.

Next slice: define the instruction decoder's control interface and implement
the first R-type decode cases.
