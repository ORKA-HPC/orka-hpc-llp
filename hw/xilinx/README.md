
Script 1: generate_bitsteram
    This will build an infrastructure block design, generate the bitstream and export the components
    and address map in a JSON file.
    - Source Vivado settings and make sure the Vivado license is in your PATH:
        source /opt/Xilinx/Vivado/2018.2/settings64.sh
        export LM_LICENSE_FILE=[PATH_TO_FILE]
    - Configure the infrastructure and add custom IPs as desired with Configurator (see below)
    - Run the script. It will export LAST_UUID variable and write .bit and .json files.

Script 2: configure_fpga FILE
    - Takes a bitstream file as argument and configures the vcu118 via JTAG.
