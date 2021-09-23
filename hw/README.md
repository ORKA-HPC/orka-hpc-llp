Script 1: pci_rescan
-   Removes Altera and Xilinx PCIe devices and performs a PCIe rescan.
    Run this after reconfiguring the FPGA (including the PCIe block).
    A (cold) restart might be necessary when the PCIe IP has been modified.


Known bugs and limitations:
This script was tested with Vivado 2018.2 and 2019.1
-   Vivado GUI crashes with Java Error during launch on tripple-screen setups.
    Either disable GUI or use Xephyr/VNC etc.
-   Clashing/missing awk versions on Ubuntu 18.04.
    Create a symlink to your existing lib (of your Vivado installation).
-   Missing board part for vcu118 rev. 2.0 in 2019.1
    copy the files in fpgaInfrastructure/hw/board_files to 
    [VIVADO_INSTALL_DIR]/data/boards/board_files
