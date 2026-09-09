# RV32I Core Lab

RV32I Core Lab is a from-scratch, educational 32-bit RISC-V processor project
written in SystemVerilog. The goal is a small single-cycle core with a clear
datapath, self-checking verification, and documented design decisions.

## Current milestone: integrated ALU execution

The first working block is a combinational ALU implementing the operations
needed by the RV32I integer datapath:

- addition and subtraction;
- AND, OR, and XOR;
- logical and arithmetic shifts using the low five bits of the shift amount;
- signed and unsigned less-than comparison;
- a zero-result flag for later branch control.

The testbench checks normal results, 32-bit wraparound, signed behavior, shift-
amount masking, the zero flag, and deterministic handling of an invalid control
code.

The register file provides two asynchronous read ports and one synchronous
write port. Register `x0` is not physically stored, so reads always return zero
and writes to it are ignored. Its testbench verifies independent dual reads,
overwrites, disabled writes, the highest register address, and `x0` behavior.

The current core integration executes register-register and immediate ALU
instructions in one cycle. Its testbench runs a dependent six-instruction
sequence, proving that decoded operands, immediate values, ALU results,
register writeback, and sequential program-counter updates work together.

## Test

Requirements: Icarus Verilog 13 or another SystemVerilog-compatible simulator.

```sh
make test
```

Expected summaries:

```text
PASS: 16 RV32I ALU checks
PASS: 7 register-file checks
PASS: 32 decoder checks
PASS: 12 immediate-generator checks
PASS: 9 program-counter checks
PASS: 14 branch-unit checks
PASS: 8 core-integration checks
```

This is simulation only. The design has not yet been synthesized, timed, or
validated on an FPGA.

## Roadmap

- [x] RV32I ALU and self-checking testbench
- [x] 32 × 32-bit register file with hard-wired `x0`
- [x] R-type instruction decoder
- [x] I, S, B, U, and J immediate generation
- [x] I-type ALU decoder expansion
- [x] Program counter with reset, redirect, and stall priority
- [x] Branch decoding and decision logic
- [x] Single-cycle ALU datapath integration
- [ ] Branch redirect integration
- [ ] Memory model and small machine-code program
- [ ] Synthesis report and FPGA validation

## License

MIT
