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
module alt_pr_cb_host(
	clk,
	nreset,
	pr_start,
	double_pr,
	o_freeze,
	o_crc_error,
	o_pr_error,
	o_pr_ready,
	o_pr_done,
	pr_clk,
	pr_data,
	pr_ready_pin,
	pr_done_pin,
	pr_error_pin,
	o_pr_request_pin,
	o_pr_clk_pin,
	o_pr_data_pin,
	crc_error_pin,
	bitstream_ready,
	bitstream_incompatible,
	update_list
);
	parameter CDRATIO = 1;
	parameter CB_DATA_WIDTH = 16;
	parameter EDCRC_OSC_DIVIDER = 1;
	parameter DEVICE_FAMILY	= "Stratix V";
    parameter INSTANTIATE_PR_BLOCK = 1;
    parameter INSTANTIATE_CRC_BLOCK = 1;

	input clk;
	input nreset;
	input pr_clk;
	input [CB_DATA_WIDTH-1:0] pr_data;
	input pr_start;
	input double_pr;
	input bitstream_ready;
	input bitstream_incompatible;
	input update_list;

	output o_freeze;
	output o_crc_error;
	output o_pr_error;
	output o_pr_ready;
	output o_pr_done;

	input pr_ready_pin;
	input pr_done_pin;
	input pr_error_pin;
	input crc_error_pin;
	output o_pr_request_pin;
	output o_pr_clk_pin;
	output [CB_DATA_WIDTH-1:0] o_pr_data_pin;
	
	generate
        if ((DEVICE_FAMILY == "Stratix V") || (DEVICE_FAMILY == "Cyclone V") ||
            (DEVICE_FAMILY == "Arria V") || (DEVICE_FAMILY == "Arria V GZ")) begin
            alt_pr_cb_controller_v1 alt_pr_cb_controller_v1(
                .clk(clk),
                .nreset(nreset),
                .pr_start(pr_start),
                .double_pr(double_pr),
                .o_freeze(o_freeze),
                .o_crc_error(o_crc_error),
                .o_pr_error(o_pr_error),
                .o_pr_ready(o_pr_ready),
                .o_pr_done(o_pr_done),
                .pr_clk(pr_clk),
                .pr_data(pr_data),
                .pr_ready_pin(pr_ready_pin),
                .pr_done_pin(pr_done_pin),
                .pr_error_pin(pr_error_pin),
                .o_pr_request_pin(o_pr_request_pin),
                .o_pr_clk_pin(o_pr_clk_pin),
                .o_pr_data_pin(o_pr_data_pin),
                .crc_error_pin(crc_error_pin),
                .bitstream_ready(bitstream_ready)
            );
            defparam alt_pr_cb_controller_v1.CDRATIO = CDRATIO; 
            defparam alt_pr_cb_controller_v1.CB_DATA_WIDTH = CB_DATA_WIDTH;
            defparam alt_pr_cb_controller_v1.EDCRC_OSC_DIVIDER = EDCRC_OSC_DIVIDER;
            defparam alt_pr_cb_controller_v1.DEVICE_FAMILY = DEVICE_FAMILY;
            defparam alt_pr_cb_controller_v1.INSTANTIATE_PR_BLOCK = INSTANTIATE_PR_BLOCK;
            defparam alt_pr_cb_controller_v1.INSTANTIATE_CRC_BLOCK = INSTANTIATE_CRC_BLOCK;
        end
        else begin
            // for Arria 10 onwards
            alt_pr_cb_controller_v2 alt_pr_cb_controller_v2(
                .clk(clk),
                .nreset(nreset),
                .pr_start(pr_start),
                .o_freeze(o_freeze),
                .o_crc_error(o_crc_error),
                .o_pr_error(o_pr_error),
                .o_pr_ready(o_pr_ready),
                .o_pr_done(o_pr_done),
                .pr_clk(pr_clk),
                .pr_data(pr_data),
                .pr_ready_pin(pr_ready_pin),
                .pr_done_pin(pr_done_pin),
                .pr_error_pin(pr_error_pin),
                .o_pr_request_pin(o_pr_request_pin),
                .o_pr_clk_pin(o_pr_clk_pin),
                .o_pr_data_pin(o_pr_data_pin),
                .crc_error_pin(crc_error_pin),
                .bitstream_incompatible(bitstream_incompatible),
                .update_list(update_list)
            );
            defparam alt_pr_cb_controller_v2.CDRATIO = CDRATIO; 
            defparam alt_pr_cb_controller_v2.CB_DATA_WIDTH = CB_DATA_WIDTH;
            defparam alt_pr_cb_controller_v2.EDCRC_OSC_DIVIDER = EDCRC_OSC_DIVIDER;
            defparam alt_pr_cb_controller_v2.DEVICE_FAMILY = DEVICE_FAMILY;
            defparam alt_pr_cb_controller_v2.INSTANTIATE_PR_BLOCK = INSTANTIATE_PR_BLOCK;
            defparam alt_pr_cb_controller_v2.INSTANTIATE_CRC_BLOCK = INSTANTIATE_CRC_BLOCK;
        end
	endgenerate
	
endmodule

