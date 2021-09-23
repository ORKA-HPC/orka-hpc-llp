ORKA HW Configurator: Helper tool for generating and exporting configuration files.


How to build:
`make all`


How to run:

Synopsis
    configurator -config {FILE} -o {DIR} [OPTION]...
    
Description
    Generate configuration files and tcl scripts for ORKA HW generation tools.

    Mandatory:

        -config {FILE}
            Specify JSON LLP description file.

        -o {DIR}
            Export dir for generated config files and scripts.

    Optional:

        -defaults {FILE}
            Specify JSON LLP description file (e.g. from default_configs).

        -ips {FILE}
            Specify JSON IP description file.

        -ip {PATH:NAME[:CLOCK]}
            Add IP to design. This option can be added multiple times.

        -gui
            Enable GUI when running Vendor Toolchains (Xilinx Vivado, Intel Quartus).

        -only_bd
            Only build Block Design and skip Synth, Impl, Bs-gen. (Xilinx only).

        -cpus {NUMBER}
            Specify how many cpu cores to be used during Synth and Impl.

        -help
            List all options with short descriptions.



TODOs:
-   Explain options inside (xilinx) config json:
        pcie_lane_width     : 1-16 (2er pot)
        c2h_channels        : 1-4
        h2c_channels        : 1-4
        enable_mcap         :  None, Tandem_PROM, Tandem_PCIe, Tandem_PCIe_with_Field_updates, PR_over_PCIe
        infrastructure_type : dma, stream
        platform_name       : arty, arty-a7-100, vcu118
        optional: set filenames for json and bitstream with json_filename, bitstream_filename
-   Add default config for Intel FPGA
-   Define format for the json file containing the ips
-   Add option to force bitstream+json export filenames (move uuid_gen into this tool instead of xilinx scripts?)
-   Remove unnecessary options in config json
