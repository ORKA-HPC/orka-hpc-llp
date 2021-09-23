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
// This is a modified version of `alt_pfl_data`.
module alt_pr_data
(
	clk,
	data_request,
	data_in,
	data_in_ready,
	data_in_read,
	
	data_out,
	data_out_ready,
	data_out_read
);

	parameter DATA_WIDTH = 8;
	parameter DELAY = 0;
	localparam READ_DELAY = (DELAY == 0) ? 0 : DELAY + 2;
	input data_request;
	input clk;
	input [DATA_WIDTH-1:0] data_in;
	input data_in_ready;
	output data_in_read;
	output [DATA_WIDTH-1:0] data_out;
	output data_out_ready;
	input data_out_read;

	reg data_out_ready;
	reg [DATA_WIDTH-1:0] data_out;
	
	// data clocking
	wire data_clk;
	generate
		if (DELAY > 0) begin
			genvar i;
			wire [DELAY-1:0] delays /* synthesis keep */;
			for (i=0; i < DELAY; i=i+1) begin : DELAY_LOOP
				if (i == 0)
					or (delays[i], clk, clk);
				else
					or (delays[i], delays[i-1], delays[i-1]);
			end
			assign data_clk = delays[DELAY-1];
		end
		else begin
			assign data_clk = clk;
		end
	endgenerate
	wire data_ready;
	wire data_in_read_wire = (data_in_ready & (~data_out_ready | data_out_read));
	generate
		if (READ_DELAY > 0) begin
			genvar j;
			wire [READ_DELAY-1:0] read_delays /* synthesis keep */;
			for (j=0; j < READ_DELAY; j=j+1) begin : READ_DELAY_LOOP
				if (j == 0)
					or (read_delays[j], data_in_read_wire, data_in_read_wire);
				else
					or (read_delays[j], read_delays[j-1], read_delays[j-1]);
			end
			assign data_ready = read_delays[READ_DELAY-1];
		end
		else begin
			assign data_ready = data_in_read_wire;
		end
	endgenerate

	always @ (posedge data_clk) begin
		if (data_ready)
			data_out <= data_in;
		else
			data_out <= data_out;
	end
	
	always @ (negedge data_request or posedge clk) begin
		if (~data_request)
			data_out_ready <= 1'b0;
		else if (data_out_ready) begin
			if (data_out_read & ~data_in_ready) // the only condition that can turn me down
				data_out_ready <= 1'b0;
			else 
				data_out_ready <= data_out_ready;
		end
		else if (data_in_ready) // the only condition that can turn me up
				data_out_ready <= 1'b1;
		else 
			data_out_ready <= data_out_ready;
	end

	assign data_in_read = data_in_read_wire;
endmodule
