ORKA-HPC LLP Generator
======================

A C/C++/TCL based library


Source Code Organization
---------

### Hardware

Tools to generate infrastructures and incorporate user-defined IPs

Located in `hw/`

### Software

GenericDriver and API for communication between Host and FPGA

Located in `sw/`

### Examples

Complete workflow from C++ source code to running the application on HW 

Located in `example/`

### Third-party Software

Portions of the code use the following third-party libraries (located in `3rdparty`):

- [CmdLine](https://github.com/abolz/CmdLine)
- [TinyXML2](https://github.com/leethomason/tinyxml2)
- [JSON for Modern C++](https://github.com/nlohmann/json)
- [tiny-json](https://github.com/rafagafe/tiny-json)

For convenience we also include PCIe Drivers:
- [Intel FPGA PCIe Driver](https://www.intel.com/content/www/us/en/programmable/documentation/fcx1474252944895.html)
  Published under GPL2
- [Xilinx XDMA Driver](https://github.com/Xilinx/dma_ip_drivers/tree/master/XDMA/linux-kernel)
  Published under BSD, we include a [bugfix](https://github.com/HellmannM/dma_ip_drivers/tree/centos8fix) for CentOS8

How to get it
-------------

- git clone git@github.com:ORKA-HPC/orka-hpc-llp.git
- cd orka-hpc-llp
- git submodule update --init --recursive


License
-------

ORKA-HPC LLP Generator is licensed under the Apache 2.0 License.
