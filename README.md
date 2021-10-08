ORKA-HPC LLP Generator
======================

ORKA-HPC Low-Level-Platform Generator fills the gap between HLS and code execution on FPGAs:
- Build IP from C/C++ source code
- Generate a bitstream including your IP
- Generic Driver with C-API for Host-FPGA communication via PCIe/Ethernet/USB
- Support for Xilinx and Intel FPGAs

Currently supported boards:
- Xilinx:
    - [Xilinx VCU118 Development Board (Xilinx UltraScale+ FPGA)](https://www.xilinx.com/products/boards-and-kits/vcu118.html)
    - ~~[Xilinx VC709 Development Board (Xilinx Virtex-7 FPGA)](https://www.xilinx.com/products/boards-and-kits/dk-v7-vc709-g.html)~~
    - [Digilent Arty A7-35 (Xilinx Artix-7 FPGA)](https://digilent.com/reference/programmable-logic/arty-a7/start)
    - [Digilent Arty A7-100 (Xilinx Artix-7 FPGA)](https://digilent.com/reference/programmable-logic/arty-a7/start)
- Intel:
    - [Intel Arria 10 GX FPGA Development Kit](https://www.intel.com/content/www/us/en/programmable/products/boards_and_kits/dev-kits/altera/kit-a10-gx-fpga.html)

How to get it
-------------

```Shell
git clone --recursive git@github.com:ORKA-HPC/orka-hpc-llp.git
```

Documentation
-------------

Documentation can be found in the [Wiki](https://github.com/ORKA-HPC/orka-hpc-llp/wiki).

License
-------

ORKA-HPC LLP Generator is licensed under the Apache 2.0 License.
