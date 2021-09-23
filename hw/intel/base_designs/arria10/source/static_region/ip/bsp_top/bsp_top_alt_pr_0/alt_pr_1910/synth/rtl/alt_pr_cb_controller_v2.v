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
module alt_pr_cb_controller_v2(
	clk,
	nreset,
	pr_start,
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
	bitstream_incompatible,
	update_list
);
	parameter CDRATIO = 1;
	parameter CB_DATA_WIDTH = 16;
	parameter EDCRC_OSC_DIVIDER = 1;
	parameter DEVICE_FAMILY	= "Arria 10";
	parameter INSTANTIATE_PR_BLOCK = 1;
	parameter INSTANTIATE_CRC_BLOCK = 1;

	localparam [2:0]	IDLE = 0,
						WAIT_FOR_PR_READY_HIGH = 1,
						SEND_PR_DATA = 2,
						WAIT_FOR_PR_READY_LOW = 3,
						WAIT_FOR_PR_STATUS_LOW = 4,
						WAIT_FOR_EXIT = 5,
						ERR0 = 6,
						ERR1 = 7;
						
	input clk;
	input nreset;
	input pr_clk;
	input [CB_DATA_WIDTH-1:0] pr_data;
	input pr_start;

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
    
	input bitstream_incompatible;
	input update_list;
				
	reg [2:0] pr_state = 3'b0 /* synthesis preserve dont_replicate */;
	reg pr_request_reg;
	reg freeze_reg;
	
    wire pr_ready_i;
	wire pr_done_i;
	wire pr_error_i;
	wire crc_error_i;
    
    reg pr_ready_r = 1'b0;
	reg pr_done_r = 1'b0;
	reg pr_error_r = 1'b0;
	reg crc_error_r = 1'b0;
    
    reg pr_ready_rr = 1'b0;
	reg pr_done_rr = 1'b0;
	reg pr_error_rr = 1'b0;
	reg crc_error_rr = 1'b0;
    
	wire pr_ready_w;
	wire pr_done_w;
	wire pr_error_w;
	wire crc_error_w;
	
	assign o_freeze = freeze_reg;
	assign o_crc_error = crc_error_w;
	assign o_pr_error = pr_error_w;
	assign o_pr_ready = pr_ready_w;
	assign o_pr_done = pr_done_w;

	alt_pr_cb_interface alt_pr_cb_interface(
		.clk(clk),

		.o_pr_clk_pin(o_pr_clk_pin),
		.o_pr_data_pin(o_pr_data_pin),
		.pr_done_pin(pr_done_pin),
		.pr_error_pin(pr_error_pin),
		.pr_ready_pin(pr_ready_pin),
		.o_pr_request_pin(o_pr_request_pin),

		.pr_clk(pr_clk),
		.pr_data(pr_data),
		.o_pr_done(pr_done_i),
		.o_pr_error(pr_error_i),
		.o_pr_ready(pr_ready_i),
		.pr_request(pr_request_reg),

		.crc_error_pin(crc_error_pin),

		.o_crc_error(crc_error_i)
	);
	defparam alt_pr_cb_interface.CDRATIO = CDRATIO;
    defparam alt_pr_cb_interface.CB_DATA_WIDTH = CB_DATA_WIDTH; 
	defparam alt_pr_cb_interface.EDCRC_OSC_DIVIDER = EDCRC_OSC_DIVIDER;
	defparam alt_pr_cb_interface.DEVICE_FAMILY = DEVICE_FAMILY;
	defparam alt_pr_cb_interface.INSTANTIATE_PR_BLOCK = INSTANTIATE_PR_BLOCK;
	defparam alt_pr_cb_interface.INSTANTIATE_CRC_BLOCK = INSTANTIATE_CRC_BLOCK;

	// double register the signals out of prblock
	always @(posedge clk) begin
	    pr_ready_r <= pr_ready_i;
	    pr_done_r <= pr_done_i;
	    pr_error_r <= pr_error_i;
	    crc_error_r <= crc_error_i;
	end
    
	always @(posedge clk) begin
	    pr_ready_rr <= pr_ready_r;
	    pr_done_rr <= pr_done_r;
	    pr_error_rr <= pr_error_r;
	    crc_error_rr <= crc_error_r;
	end
    
	assign pr_ready_w = pr_ready_rr;
	assign pr_done_w = pr_done_rr;
	assign pr_error_w = pr_error_rr;
	assign crc_error_w = crc_error_rr;
    
	// state machine
	always @(posedge clk)
	begin
		if (~nreset) begin
			pr_state <= IDLE;
		end
		else begin
			case (pr_state)
				IDLE: 
				begin
					pr_request_reg <= 1'b0;
					
					if (pr_start && ~pr_ready_w && ~pr_error_w) begin
						freeze_reg <= 1'b1;
						pr_request_reg <= 1'b1;
						pr_state <= WAIT_FOR_PR_READY_HIGH;
					end
					else if (pr_ready_w || pr_error_w || update_list) begin
						freeze_reg <= 1'b1;
					end
					else begin
						freeze_reg <= 1'b0;
					end
				end
				
				WAIT_FOR_PR_READY_HIGH: 
				begin
					if (pr_ready_w) begin
						pr_state <= SEND_PR_DATA;
					end
					else if (pr_error_w) begin
						pr_state <= ERR0;
					end
				end

				SEND_PR_DATA: 
				begin
					// bitstream host handles pr_clk and pr_data
					// here monitoring for passing or failing condition
					if (pr_error_w || crc_error_w || pr_done_w) begin
						pr_state <= WAIT_FOR_PR_READY_LOW;
					end
					// Withdrawal the request due to bitstream incompatible
					else if (bitstream_incompatible) begin
						pr_request_reg <= 1'b0;
					end
				end

				WAIT_FOR_PR_READY_LOW: 
				begin
					if (~pr_ready_w) begin
						pr_request_reg <= 1'b0;
						pr_state <= WAIT_FOR_PR_STATUS_LOW;
					end
				end

				WAIT_FOR_PR_STATUS_LOW: 
				begin
					if (~pr_error_w && ~pr_done_w) begin
						pr_state <= WAIT_FOR_EXIT;
					end
				end
				
				WAIT_FOR_EXIT: 
				begin
					if (~pr_start) begin
						pr_state <= IDLE;
					end
				end

				ERR0: 
				begin
					pr_state <= ERR1;
				end
                
				ERR1: 
				begin
					pr_state <= IDLE;
				end
			endcase
		end
	end
	
endmodule

