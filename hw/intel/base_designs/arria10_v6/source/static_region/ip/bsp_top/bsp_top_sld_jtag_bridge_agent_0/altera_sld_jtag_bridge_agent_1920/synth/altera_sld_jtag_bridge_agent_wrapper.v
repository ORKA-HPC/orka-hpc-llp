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


module altera_sld_jtag_bridge_agent_wrapper
#(
    parameter INSTANCE_INDEX = -1,
    parameter PREFER_HOST = " "
)
(
    output  tck,
    output  tms,
    output  tdi,
    output  vir_tdi,
    output  ena,
    input   tdo
);

    sld_jtag_bridge_agent #(
        .INSTANCE_INDEX(INSTANCE_INDEX),
        .PREFER_HOST(PREFER_HOST)
    ) sld_jtag_bridge_agent_inst
    (
        .child_hub_tck(tck),
        .child_hub_tms(tms),
        .child_hub_tdi(tdi),
        .child_hub_vir_tdi(vir_tdi),
        .child_hub_ena(ena),
        .child_hub_tdo(tdo)
    );
    
endmodule // altera_sld_jtag_bridge_agent_wrapper
