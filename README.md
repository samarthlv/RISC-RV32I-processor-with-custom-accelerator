# RISC-RV32I-processor-with-custom-accelerator
This repository contains a Verilog-based RV32I single-cycle processor and a custom hardware accelerator integrated through a memory-mapped interface.

## Contents

- [`rv32i_single_cycle/`](./rv32i_single_cycle): 32-bit RV32I processor with modular fetch, decode, execute, memory, and writeback blocks.
- [`accelerator/`](./accelerator): standalone accelerator with MAC, 4-element dot product, and 4x4 systolic matrix multiply modes.
- [`images/`](./images): place for output waveform images.

## Features

- RV32I subset support for arithmetic, logical, branch, load, and store instructions
- Reusable accelerator modes:
  - MAC
  - 4-element dot product
  - 4x4 systolic matrix multiplication
- CPU-to-accelerator integration through MMIO registers in [`accel_mmio.v`](./rv32i_single_cycle/rtl/accel_mmio.v)
- Self-checking testbenches and GTKWave-compatible VCD dumps

## Main Files

- Processor top: [`rv32i_single_cycle/rtl/rv32i_top.v`](./rv32i_single_cycle/rtl/rv32i_top.v)
- Accelerator top: [`accelerator/rtl/hardware_accelerator.v`](./accelerator/rtl/hardware_accelerator.v)
- MMIO wrapper: [`rv32i_single_cycle/rtl/accel_mmio.v`](./rv32i_single_cycle/rtl/accel_mmio.v)
- Processor testbench: [`rv32i_single_cycle/tb/tb_rv32i.v`](./rv32i_single_cycle/tb/tb_rv32i.v)
- Accelerator testbench: [`accelerator/tb/tb_hardware_accelerator.v`](./accelerator/tb/tb_hardware_accelerator.v)

## Quick Start

Processor:

```sh
cd rv32i_single_cycle
iverilog -g2012 -o simv_cpu -s tb_rv32i tb/tb_rv32i.v rtl/*.v ../accelerator/rtl/*.v
vvp simv_cpu
gtkwave tb_rv32i.vcd
```

Accelerator:

```sh
cd accelerator
iverilog -g2012 -o simv_accel_only -s tb_hardware_accelerator tb/tb_hardware_accelerator.v rtl/*.v
vvp simv_accel_only 
gtkwave tb_hardware_accelerator.vcd
```

CPU + accelerator integration mode1-MAC:

```sh
cd rv32i_single_cycle
iverilog -g2012 -o simv_accel -s tb_rv32i_accel tb/tb_rv32i_accel.v rtl/*.v ../accelerator/rtl/*.v
vvp simv_accel
gtkwave tb_rv32i_accel.vcd
```

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE).

## Code Of Conduct

Please read [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) before contributing.
