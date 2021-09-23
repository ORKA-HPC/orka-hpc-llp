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


`timescale 1ns/1ns
module alt_pr_mux#(
    parameter DATA_WIDTH = 16
) (
    input  logic                   select,

    input  logic                   sink0_valid,
    input  logic[DATA_WIDTH - 1:0] sink0_data,
    output logic                   sink0_ready,

    input  logic                   sink1_valid,
    input  logic[DATA_WIDTH - 1:0] sink1_data,
    output logic                   sink1_ready,

    output logic                   source_valid,
    output logic[DATA_WIDTH - 1:0] source_data,
    input  logic                   source_ready
);
    assign sink0_ready = select == 0 ? source_ready : 1'b0;

    assign sink1_ready = select == 0 ? 1'b0 : source_ready;

    assign source_valid = select == 0 ? sink0_valid : sink1_valid;
    assign source_data = select == 0 ? sink0_data : sink1_data;
endmodule
