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

### Evening: R-type decoder

- Added field extraction for `rs1`, `rs2`, and `rd`.
- Decoded all ten RV32I register-register ALU operations.
- Ensured unsupported and illegal encodings cannot enable register writes.
- Added 13 self-checking tests, including M-extension and illegal-shift cases.

Next slice: add I-type ALU decoding and sign-extended immediate generation.

## Day 5 — 2026-09-05

### Morning: immediate generator

- Implemented I, S, B, U, and J immediate layouts.
- Added sign extension for negative offsets and preserved implicit low zero bits.
- Added a validity output that rejects instructions without an immediate.
- Added 12 self-checking tests across positive, negative, and boundary values.

Next slice: expand the decoder for immediate ALU instructions and shifts.

### Afternoon: immediate ALU decoding

- Added an explicit ALU operand-source control output.
- Decoded ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, and SRAI.
- Rejected reserved shift-immediate encodings without enabling register writes.
- Expanded the decoder testbench from 13 to 24 self-checking cases.

Next slice: implement the program counter with sequential and redirected updates.
