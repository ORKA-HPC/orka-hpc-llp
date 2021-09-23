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
//`define INC_PR_DATA_COUNT

module alt_pr_bitstream_controller_v2(
	clk,
	nreset,
	pr_start,
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
	bitstream_incompatible,
	o_bitstream_ready
);
	parameter CDRATIO = 1;
	parameter CB_DATA_WIDTH = 16;
	
	localparam CDRATIO_WIDTH = (CDRATIO == 8) ? 3 : 2;
	localparam [1:0]	IDLE = 0,
						WAIT_FOR_READY = 1,
						SEND_PR_DATA = 2,
						ERR0 = 3;
						
	input clk; 
	input nreset;
	input pr_start;
	input freeze;
	input crc_error;
	input pr_error;
	input pr_ready;
	input pr_done;
	input [CB_DATA_WIDTH-1:0] data;
	input data_valid;
	input bitstream_incompatible;
	
	output o_data_ready;
	output o_pr_clk;
	output [CB_DATA_WIDTH-1:0] o_pr_data;
	output o_bitstream_ready;
						
	reg [1:0] bitstream_state = 2'b0 /* synthesis preserve dont_replicate */;
	reg [CB_DATA_WIDTH-1:0] pr_data_reg;
    reg [CB_DATA_WIDTH-1:0] pr_data_reg2;
	reg [CDRATIO_WIDTH-1:0] count;
	reg enable_dclk_reg;
    reg enable_dclk_reg2;

`ifdef INC_PR_DATA_COUNT
	reg [29:0] PR_DATA_COUNT /* synthesis noprune */;
`endif
    
	assign o_data_ready = data_valid && (count == (CDRATIO-1)) && (bitstream_state == SEND_PR_DATA);
    assign o_pr_clk = clk & enable_dclk_reg2;
	assign o_pr_data = pr_data_reg2;
	assign o_bitstream_ready = (bitstream_state == IDLE);
    
    // phase shift data and pr clock gating
    always @(negedge clk)
	begin
		enable_dclk_reg2 <= enable_dclk_reg;
        pr_data_reg2 <= pr_data_reg;
	end
	
	always @(posedge clk)
	begin
		if (~nreset) begin
			bitstream_state <= IDLE;
		end
		else begin
			case (bitstream_state)
				IDLE: 
				begin
					count <= 0;
					pr_data_reg <= 0;
					
`ifdef INC_PR_DATA_COUNT
					PR_DATA_COUNT <= 0;
`endif
					
					if (pr_start && ~freeze && ~pr_ready) begin
						enable_dclk_reg <= 1;
						bitstream_state <= WAIT_FOR_READY;
					end
					else if (freeze || pr_ready || pr_error) begin
						enable_dclk_reg <= 1;
					end
					else begin
						enable_dclk_reg <= 0;
					end
				end

				WAIT_FOR_READY: 
				begin
					if (pr_ready) begin
						enable_dclk_reg <= 0;
						bitstream_state <= SEND_PR_DATA;
					end
					else if (pr_error) begin
						bitstream_state <= IDLE;
					end
				end
				
				SEND_PR_DATA: 
				begin
					if (crc_error || pr_error || pr_done) begin
						bitstream_state <= ERR0;
					end
					else if (data_valid) begin
						if (count == (CDRATIO-1)) begin
							count <= 0;
							enable_dclk_reg <= 1;
							
							if (~bitstream_incompatible) begin
								pr_data_reg <= data;
							end
							else begin
								// send all 0's to assert PR_ERROR
								pr_data_reg <= 0;
							end
`ifdef INC_PR_DATA_COUNT
							PR_DATA_COUNT <= PR_DATA_COUNT + 30'd1;
`endif
						end
						else begin
							count <= count + {{(CDRATIO_WIDTH-1){1'b0}}, 1'b1};
						end
					end
					else if (count == (CDRATIO-1)) begin
						enable_dclk_reg <= 0;
						pr_data_reg <= 0;
					end
					else begin
						count <= count + {{(CDRATIO_WIDTH-1){1'b0}}, 1'b1};
					end
				end
				
				ERR0: 
				begin
					bitstream_state <= IDLE;
				end
			endcase
		end
	end
						
endmodule

