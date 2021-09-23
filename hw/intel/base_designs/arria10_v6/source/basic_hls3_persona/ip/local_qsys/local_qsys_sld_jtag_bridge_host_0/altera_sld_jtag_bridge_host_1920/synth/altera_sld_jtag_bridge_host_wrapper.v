// (C) 2001-2021 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module altera_sld_jtag_bridge_host_wrapper
#(
    parameter NAME = " "
)
(
    input   tck,
    input   tms,
    input   tdi,
    input   vir_tdi,
    input   ena,
    output  tdo
);

    sld_jtag_bridge_host #(
        .NAME(NAME)
    ) sld_jtag_bridge_host_inst
    (
        .tck(tck),
        .tms(tms),
        .tdi(tdi),
        .vir_tdi(vir_tdi),
        .ena(ena),
        .tdo(tdo)
    );
    
endmodule // altera_sld_jtag_bridge_host_wrapper
