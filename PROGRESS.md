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

### Evening: program counter

- Implemented asynchronous reset and four-byte sequential advancement.
- Added explicit redirect and stall controls with documented priority.
- Verified redirect-over-stall behavior and 32-bit address wraparound.
- Added nine self-checking sequential-control tests.

Next slice: implement branch condition evaluation for all six RV32I branches.

## Day 6 — 2026-09-06

### Afternoon: branch condition unit

- Implemented BEQ, BNE, BLT, BGE, BLTU, and BGEU evaluation.
- Kept signed and unsigned comparisons explicit at the module boundary.
- Rejected both reserved branch `funct3` encodings with a safe not-taken result.
- Added 14 self-checking simulation cases spanning true, false, and invalid paths.

Next slice: integrate the existing decoder, register file, immediate generator,
ALU, branch unit, and program counter into a minimal single-cycle core.

### Evening: branch decoder controls

- Recognized all six legal RV32I branch encodings in the instruction decoder.
- Added a dedicated branch control signal without enabling register writes.
- Rejected the two reserved branch encodings before they reach the datapath.
- Expanded the decoder testbench from 24 to 32 self-checking cases.

Next slice: integrate register-register and immediate ALU execution into a
minimal single-cycle core before connecting branch redirects.

## Day 7 — 2026-09-07

### Morning: single-cycle ALU integration

- Connected the decoder, register file, immediate generator, ALU, and program
  counter in a minimal core module.
- Executed a dependent six-instruction register/immediate sequence in simulation.
- Verified writeback dependencies, sign-extended immediates, and sequential PC
  advancement with eight self-checking integration cases.
- Kept branch execution explicitly out of scope until redirect control is wired.

Next slice: connect the tested branch comparator and B-type immediate to program-
counter redirects, then verify taken and not-taken control flow.
