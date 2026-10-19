# RV32I Core Lab

I'm building a 32-bit RISC-V CPU from scratch in SystemVerilog, one block at a time, with a testbench for each piece. My motivation came from hardware work I did in high school. I came back to it because I wanted to understand how a CPU really runs code at the lowest level.

## Where it's at

It's a single-cycle core that can currently run:

- register and immediate ALU instructions (add, sub, shifts, compares, logic)
- conditional branches, forward and backward

Not there yet: loads/stores (there is no memory model), jumps, or running on a real FPGA. Everything so far is simulation only.

## Testing

Each block has its own self-checking testbench: 102 checks in total across the ALU, register file, decoder, immediate generator, PC, branch unit, and integrated core.

```sh
make test   # needs Icarus Verilog
```

One detail I liked: register `x0` is supposed to always read as zero, so instead of storing it and ignoring writes, the register file just never stores it.

## Next

1. Memory model and load/store
2. A small hand-assembled program running end to end
3. Synthesize it and try it on an FPGA

Progress notes are in [`PROGRESS.md`](PROGRESS.md).
