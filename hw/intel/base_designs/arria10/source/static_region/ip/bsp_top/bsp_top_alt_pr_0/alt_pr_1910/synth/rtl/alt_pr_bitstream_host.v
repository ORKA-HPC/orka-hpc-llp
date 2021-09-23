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
module alt_pr_bitstream_host(
	clk,
	nreset,
	pr_start,
	double_pr,
	freeze,
	crc_error,
	pr_error,
	pr_ready,
	pr_done,
	data,
	data_valid,
	o_data_ready,
	o_pr_clk,
	o_pr_data,
	o_bitstream_incompatible,
    o_pr_pof_id,
	o_bitstream_ready,
	o_update_list
);
	parameter PR_INTERNAL_HOST = 1;
	parameter CDRATIO = 1;
	parameter DONE_TO_END = 7;
	parameter CB_DATA_WIDTH = 16;
	parameter ENABLE_HPR = 0;
	parameter ENABLE_PRPOF_ID_CHECK = 1;
	parameter EXT_HOST_PRPOF_ID = 0;
	parameter DEVICE_FAMILY	= "Stratix V";
    parameter EXT_HOST_TARGET_DEVICE_FAMILY	= "Stratix V";
	
	input clk; 
	input nreset;
	input pr_start;
	input double_pr;
	input freeze;
	input crc_error;
	input pr_error;
	input pr_ready;
	input pr_done;
	input [CB_DATA_WIDTH-1:0] data;
	input data_valid;
	
	output o_data_ready;
	output o_pr_clk;
	output [CB_DATA_WIDTH-1:0] o_pr_data;
	output o_bitstream_incompatible;
    output [31:0] o_pr_pof_id;
	output o_bitstream_ready;
	output o_update_list;
	
	wire pr_clk_w;
	wire [CB_DATA_WIDTH-1:0] pr_data_w;
	wire bitstream_incompatible_w;
	wire bitstream_ready_w;
	wire data_ready_w;
	wire update_list_w;
	
	assign o_pr_clk = pr_clk_w;
	assign o_pr_data = pr_data_w;
	assign o_bitstream_incompatible = bitstream_incompatible_w;
	assign o_bitstream_ready = bitstream_ready_w;
	assign o_data_ready = data_ready_w;
	assign o_update_list = update_list_w;
	
	generate
		if (PR_INTERNAL_HOST == 1) begin
            if ((DEVICE_FAMILY == "Stratix V") || (DEVICE_FAMILY == "Cyclone V") ||
                (DEVICE_FAMILY == "Arria V") || (DEVICE_FAMILY == "Arria V GZ")) begin
                alt_pr_bitstream_controller_v1 alt_pr_bitstream_controller_v1(
                    .clk(clk),
                    .nreset(nreset),
                    .pr_start(pr_start),
                    .double_pr(double_pr),
                    .freeze(freeze),
                    .crc_error(crc_error),
                    .pr_error(pr_error),
                    .pr_ready(pr_ready),
                    .pr_done(pr_done),
                    .data(data),
                    .data_valid(data_valid),
                    .o_data_ready(data_ready_w),
                    .o_pr_clk(pr_clk_w),
                    .o_pr_data(pr_data_w),
                    .bitstream_incompatible(bitstream_incompatible_w),
                    .o_bitstream_ready(bitstream_ready_w)
                );
                defparam alt_pr_bitstream_controller_v1.CDRATIO = CDRATIO;
                defparam alt_pr_bitstream_controller_v1.DONE_TO_END = DONE_TO_END;
                defparam alt_pr_bitstream_controller_v1.CB_DATA_WIDTH = CB_DATA_WIDTH;
            end
            else begin
                // for Arria 10 onwards
                alt_pr_bitstream_controller_v2 alt_pr_bitstream_controller_v2(
                    .clk(clk),
                    .nreset(nreset),
                    .pr_start(pr_start),
                    .freeze(freeze),
                    .crc_error(crc_error),
                    .pr_error(pr_error),
                    .pr_ready(pr_ready),
                    .pr_done(pr_done),
                    .data(data),
                    .data_valid(data_valid),
                    .o_data_ready(data_ready_w),
                    .o_pr_clk(pr_clk_w),
                    .o_pr_data(pr_data_w),
                    .bitstream_incompatible(bitstream_incompatible_w),
                    .o_bitstream_ready(bitstream_ready_w)
                );
                defparam alt_pr_bitstream_controller_v2.CDRATIO = CDRATIO;
                defparam alt_pr_bitstream_controller_v2.CB_DATA_WIDTH = CB_DATA_WIDTH;
            end
        end
        else begin
            if ((EXT_HOST_TARGET_DEVICE_FAMILY == "Stratix V") || (EXT_HOST_TARGET_DEVICE_FAMILY == "Cyclone V") ||
                (EXT_HOST_TARGET_DEVICE_FAMILY == "Arria V") || (EXT_HOST_TARGET_DEVICE_FAMILY == "Arria V GZ")) begin
                alt_pr_bitstream_controller_v1 alt_pr_bitstream_controller_v1(
                    .clk(clk),
                    .nreset(nreset),
                    .pr_start(pr_start),
                    .double_pr(double_pr),
                    .freeze(freeze),
                    .crc_error(crc_error),
                    .pr_error(pr_error),
                    .pr_ready(pr_ready),
                    .pr_done(pr_done),
                    .data(data),
                    .data_valid(data_valid),
                    .o_data_ready(data_ready_w),
                    .o_pr_clk(pr_clk_w),
                    .o_pr_data(pr_data_w),
                    .bitstream_incompatible(bitstream_incompatible_w),
                    .o_bitstream_ready(bitstream_ready_w)
                );
                defparam alt_pr_bitstream_controller_v1.CDRATIO = CDRATIO;
                defparam alt_pr_bitstream_controller_v1.DONE_TO_END = DONE_TO_END;
                defparam alt_pr_bitstream_controller_v1.CB_DATA_WIDTH = CB_DATA_WIDTH;
            end
            else begin
                // for Arria 10 onwards
                alt_pr_bitstream_controller_v2 alt_pr_bitstream_controller_v2(
                    .clk(clk),
                    .nreset(nreset),
                    .pr_start(pr_start),
                    .freeze(freeze),
                    .crc_error(crc_error),
                    .pr_error(pr_error),
                    .pr_ready(pr_ready),
                    .pr_done(pr_done),
                    .data(data),
                    .data_valid(data_valid),
                    .o_data_ready(data_ready_w),
                    .o_pr_clk(pr_clk_w),
                    .o_pr_data(pr_data_w),
                    .bitstream_incompatible(bitstream_incompatible_w),
                    .o_bitstream_ready(bitstream_ready_w)
                );
                defparam alt_pr_bitstream_controller_v2.CDRATIO = CDRATIO;
                defparam alt_pr_bitstream_controller_v2.CB_DATA_WIDTH = CB_DATA_WIDTH;
            end
        end
	endgenerate
	
	generate
		if ((DEVICE_FAMILY != "Arria 10" && DEVICE_FAMILY != "Cyclone 10 GX") && (PR_INTERNAL_HOST == 1) &&
			(ENABLE_PRPOF_ID_CHECK == 1) && ((CDRATIO == 1) || (CDRATIO == 4))) begin
			alt_pr_bitstream_compatibility_checker_int_host alt_pr_bitstream_compatibility_checker_int_host(
				.clk(clk),
				.nreset(nreset),
				.freeze(freeze),
				.crc_error(crc_error),
				.pr_error(pr_error),
				.pr_ready(pr_ready),
				.pr_done(pr_done),
				.data(data),
				.data_valid(data_valid),
				.data_ready(data_ready_w),
				.o_bitstream_incompatible(bitstream_incompatible_w)
			);
			defparam alt_pr_bitstream_compatibility_checker_int_host.CDRATIO = CDRATIO;
			defparam alt_pr_bitstream_compatibility_checker_int_host.CB_DATA_WIDTH = CB_DATA_WIDTH;
            
			assign update_list_w = 1'b0;
		end
		else if ((EXT_HOST_TARGET_DEVICE_FAMILY != "Arria 10" && EXT_HOST_TARGET_DEVICE_FAMILY != "Cyclone 10 GX") && (PR_INTERNAL_HOST == 0) &&
					(ENABLE_PRPOF_ID_CHECK == 1) && ((CDRATIO == 1) || (CDRATIO == 4))) begin
			alt_pr_bitstream_compatibility_checker_ext_host alt_pr_bitstream_compatibility_checker_ext_host(
				.clk(clk),
				.nreset(nreset),
				.freeze(freeze),
				.crc_error(crc_error),
				.pr_error(pr_error),
				.pr_ready(pr_ready),
				.pr_done(pr_done),
				.data(data),
				.data_valid(data_valid),
				.data_ready(data_ready_w),
				.o_bitstream_incompatible(bitstream_incompatible_w)
			);
			defparam alt_pr_bitstream_compatibility_checker_ext_host.CDRATIO = CDRATIO;
			defparam alt_pr_bitstream_compatibility_checker_ext_host.CB_DATA_WIDTH = CB_DATA_WIDTH;
			defparam alt_pr_bitstream_compatibility_checker_ext_host.EXT_HOST_PRPOF_ID = EXT_HOST_PRPOF_ID;
            
			assign update_list_w = 1'b0;
		end
		else if ( (((DEVICE_FAMILY == "Arria 10" || DEVICE_FAMILY == "Cyclone 10 GX")&& PR_INTERNAL_HOST == 1) || (EXT_HOST_TARGET_DEVICE_FAMILY == "Arria 10" && PR_INTERNAL_HOST == 0)) 
					&& ((CDRATIO == 1) || (CDRATIO == 4 && CB_DATA_WIDTH == 16) || (CDRATIO == 8))
					&& (ENABLE_PRPOF_ID_CHECK == 1) && (ENABLE_HPR == 0) ) begin
			alt_pr_bitstream_compatibility_checker_v2 alt_pr_bitstream_compatibility_checker_v2(
				.clk(clk),
				.nreset(nreset),
				.freeze(freeze),
				.crc_error(crc_error),
				.pr_error(pr_error),
				.pr_ready(pr_ready),
				.pr_done(pr_done),
				.data(data),
				.data_valid(data_valid),
				.data_ready(data_ready_w),
                .o_pr_pof_id(o_pr_pof_id),
				.o_bitstream_incompatible(bitstream_incompatible_w)
			);
			defparam alt_pr_bitstream_compatibility_checker_v2.CDRATIO = CDRATIO;
			defparam alt_pr_bitstream_compatibility_checker_v2.CB_DATA_WIDTH = CB_DATA_WIDTH;
			defparam alt_pr_bitstream_compatibility_checker_v2.PR_INTERNAL_HOST = PR_INTERNAL_HOST;
			defparam alt_pr_bitstream_compatibility_checker_v2.EXT_HOST_PRPOF_ID = EXT_HOST_PRPOF_ID;
            
			assign update_list_w = 1'b0;
		end
		else if (( DEVICE_FAMILY == "Arria 10" || DEVICE_FAMILY == "Cyclone 10 GX" )
					&& ((CDRATIO == 1) || (CDRATIO == 4 && CB_DATA_WIDTH == 16) || (CDRATIO == 8))
					&& (ENABLE_PRPOF_ID_CHECK == 1) && (ENABLE_HPR == 1) ) begin
			alt_pr_bitstream_compatibility_checker_v3 alt_pr_bitstream_compatibility_checker_v3(
				.clk(clk),
				.nreset(nreset),
				.freeze(freeze),
				.crc_error(crc_error),
				.pr_error(pr_error),
				.pr_ready(pr_ready),
				.pr_done(pr_done),
				.data(data),
				.data_valid(data_valid),
				.data_ready(data_ready_w),
				.o_bitstream_incompatible(bitstream_incompatible_w),
				.o_update_list(update_list_w)
			);
			defparam alt_pr_bitstream_compatibility_checker_v3.CDRATIO = CDRATIO;
			defparam alt_pr_bitstream_compatibility_checker_v3.CB_DATA_WIDTH = CB_DATA_WIDTH;
            
            assign o_pr_pof_id = 32'b0;
		end
		else begin
            assign o_pr_pof_id = 32'b0;
			assign bitstream_incompatible_w = 1'b0;
			assign update_list_w = 1'b0;
		end
	endgenerate 
	
endmodule

