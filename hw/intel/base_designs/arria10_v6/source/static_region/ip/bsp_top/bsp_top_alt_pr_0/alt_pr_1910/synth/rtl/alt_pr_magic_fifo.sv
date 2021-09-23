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
// This is a modified version of `alt_pfl_magic_fifo`.
module alt_pr_magic_fifo
(
	clk,
	// clear
	sclr,
	// writing data
	data_in,
	data_in_ready,
	data_in_read,
	// reading data
	one_ready,
	one_rd,
	
	two_ready,
	two_rd,
	
	three_ready,
	three_rd,
	
	four_ready,
	four_rd,
	
	five_ready,
	five_rd,
	
	six_ready,
	six_rd,
	
	seven_ready,
	seven_rd,
	
	eight_ready,
	eight_rd,
	
	auto_byte_align,
	q
);

	parameter DATA_IN_WIDTH = 16;
	localparam NUMWORDS = (DATA_IN_WIDTH == 32) ? 16 : 12;
	localparam SHIFT_PLUS_VALID_BITS = DATA_IN_WIDTH / 4;
	localparam TOTAL_DATA_BITS = NUMWORDS * 4;
	localparam MAX_NIBBLE = 8;
	input clk;
	// clear
	input sclr;
	// writing data
	input [DATA_IN_WIDTH-1:0] data_in;
	input data_in_ready;
	output data_in_read;
	// reading data
	output one_ready;
	input one_rd;
	
	output two_ready;
	input two_rd;
	
	output three_ready;
	input three_rd;
	
	output four_ready;
	input four_rd;
	
	output five_ready;
	input five_rd;
	
	output six_ready;
	input six_rd;
	
	output seven_ready;
	input seven_rd;
	
	output eight_ready;
	input eight_rd;
	
	input auto_byte_align;
	output [(MAX_NIBBLE*4)-1:0] q;
	
	reg [NUMWORDS-1:0] valid_bits;
	wire write_pointer_en = (~valid_bits[NUMWORDS-SHIFT_PLUS_VALID_BITS]) & data_in_ready;
	
	wire read_one_en = one_ready & one_rd;
	wire read_two_en = two_ready & two_rd;
	wire read_three_en = three_ready & three_rd;
	wire read_four_en = four_ready & four_rd;
	wire read_five_en = five_ready & five_rd;
	wire read_six_en = six_ready & six_rd;
	wire read_seven_en = seven_ready & seven_rd;
	wire read_eight_en = eight_ready & eight_rd;

	// Telling whether we are in odd nibBLE
	reg odd;
	always @ (posedge clk) begin
		if (sclr)
			odd <= 1'b0;
		else if (read_one_en | read_three_en | read_five_en | read_seven_en)
			odd <= ~odd;
		else if (auto_byte_align)
			odd <= 1'b0;
	end
	
	// This is to tell which bit (bit to represent NIBBLE) is valid
	wire [NUMWORDS-1:0] plus_valid_bits = write_pointer_en ? 
														{valid_bits[NUMWORDS-SHIFT_PLUS_VALID_BITS-1:0], {(SHIFT_PLUS_VALID_BITS){1'b1}}} :
														valid_bits;
	wire [NUMWORDS-1:0] read_eight_valid_bits = {8'd0, plus_valid_bits[NUMWORDS-1:8]};
	wire [NUMWORDS-1:0] read_seven_valid_bits = {7'd0, plus_valid_bits[NUMWORDS-1:7]};
	wire [NUMWORDS-1:0] read_six_valid_bits = {6'd0, plus_valid_bits[NUMWORDS-1:6]};
	wire [NUMWORDS-1:0] read_five_valid_bits = {5'd0, plus_valid_bits[NUMWORDS-1:5]};
	wire [NUMWORDS-1:0] read_four_valid_bits = {4'd0, plus_valid_bits[NUMWORDS-1:4]};
	wire [NUMWORDS-1:0] read_three_valid_bits = {3'd0, plus_valid_bits[NUMWORDS-1:3]};
	wire [NUMWORDS-1:0] read_two_valid_bits = {2'd0, plus_valid_bits[NUMWORDS-1:2]};
	wire [NUMWORDS-1:0] read_one_valid_bits = {1'd0, plus_valid_bits[NUMWORDS-1:1]};
	always @ (posedge clk) begin
		if (sclr)
			valid_bits <= {(NUMWORDS){1'b0}};
		else begin
			if (read_eight_en)
				valid_bits <= read_eight_valid_bits;
			else if (read_seven_en)
				valid_bits <= read_seven_valid_bits;
			else if (read_six_en)
				valid_bits <= read_six_valid_bits;
			else if (read_five_en)
				valid_bits <= read_five_valid_bits;
			else if (read_four_en)
				valid_bits <= read_four_valid_bits;
			else if (read_three_en)
				valid_bits <= read_three_valid_bits;
			else if (read_two_en)
				valid_bits <= read_two_valid_bits;
			else if (read_one_en)
				valid_bits <= read_one_valid_bits;
			else if (auto_byte_align & odd)
				valid_bits <= read_one_valid_bits;
			else if (write_pointer_en)
				valid_bits <= plus_valid_bits;
		end
	end
	
	// Storing NIBBLE
	reg [TOTAL_DATA_BITS-1:0] valid_nibbles;
	reg [TOTAL_DATA_BITS-1:0] always_plus_valid_nibbles;
	wire [TOTAL_DATA_BITS-1:0] plus_valid_nibbles = write_pointer_en ? always_plus_valid_nibbles : valid_nibbles;
	wire [TOTAL_DATA_BITS-1:0] read_eight_valid_nibbles = {32'd0, plus_valid_nibbles[TOTAL_DATA_BITS-1:32]};
	wire [TOTAL_DATA_BITS-1:0] read_seven_valid_nibbles = {28'd0, plus_valid_nibbles[TOTAL_DATA_BITS-1:28]};
	wire [TOTAL_DATA_BITS-1:0] read_six_valid_nibbles = {24'd0, plus_valid_nibbles[TOTAL_DATA_BITS-1:24]};
	wire [TOTAL_DATA_BITS-1:0] read_five_valid_nibbles = {20'd0, plus_valid_nibbles[TOTAL_DATA_BITS-1:20]};
	wire [TOTAL_DATA_BITS-1:0] read_four_valid_nibbles = {16'd0, plus_valid_nibbles[TOTAL_DATA_BITS-1:16]};
	wire [TOTAL_DATA_BITS-1:0] read_three_valid_nibbles = {12'd0, plus_valid_nibbles[TOTAL_DATA_BITS-1:12]};
	wire [TOTAL_DATA_BITS-1:0] read_two_valid_nibbles = {8'd0, plus_valid_nibbles[TOTAL_DATA_BITS-1:8]};
	wire [TOTAL_DATA_BITS-1:0] read_one_valid_nibbles = {4'd0, plus_valid_nibbles[TOTAL_DATA_BITS-1:4]};
	
	always @ (valid_bits, valid_nibbles, data_in) begin
		if (valid_bits[7])
			always_plus_valid_nibbles = {data_in, valid_nibbles[31:0]};
		else if (valid_bits[6])
			always_plus_valid_nibbles = {4'd0, data_in, valid_nibbles[27:0]};
		else if (valid_bits[5])
			always_plus_valid_nibbles = {8'd0, data_in, valid_nibbles[23:0]};
		else if (valid_bits[4])
			always_plus_valid_nibbles = {12'd0, data_in, valid_nibbles[19:0]};
		else if (valid_bits[3])
			always_plus_valid_nibbles = {16'd0, data_in, valid_nibbles[15:0]};
		else if (valid_bits[2])
			always_plus_valid_nibbles = {20'd0, data_in, valid_nibbles[11:0]};
		else if (valid_bits[1])
			always_plus_valid_nibbles = {24'd0, data_in, valid_nibbles[7:0]};
		else if (valid_bits[0])
			always_plus_valid_nibbles = {28'd0, data_in, valid_nibbles[3:0]};	
		else
			always_plus_valid_nibbles = {32'd0, data_in};	
	end
	
	always @ (posedge clk) begin
		if (read_eight_en)
			valid_nibbles <= read_eight_valid_nibbles;
		else if (read_seven_en)
			valid_nibbles <= read_seven_valid_nibbles;
		else if (read_six_en)
			valid_nibbles <= read_six_valid_nibbles;
		else if (read_five_en)
			valid_nibbles <= read_five_valid_nibbles;
		else if (read_four_en)
			valid_nibbles <= read_four_valid_nibbles;
		else if (read_three_en)
			valid_nibbles <= read_three_valid_nibbles;
		else if (read_two_en)
			valid_nibbles <= read_two_valid_nibbles;
		else if (read_one_en)
			valid_nibbles <= read_one_valid_nibbles;
		else if (auto_byte_align & odd)
			valid_nibbles <= read_one_valid_nibbles;
		else if (write_pointer_en)
			valid_nibbles <= plus_valid_nibbles;
	end

	assign data_in_read = write_pointer_en & ~sclr;
	assign one_ready = valid_bits[0];
	assign two_ready = valid_bits[1];
	assign three_ready = valid_bits[2];
	assign four_ready = valid_bits[3];
	assign five_ready = valid_bits[4];
	assign six_ready = valid_bits[5];
	assign seven_ready = valid_bits[6];
	assign eight_ready = valid_bits[7];
	assign q = valid_nibbles[31:0];

	function integer log2;
		input integer value;
		begin
			integer temporary;
			temporary = value;
			for (log2=0; temporary>0; log2=log2+1)
				temporary = temporary >> 1;
		end
	endfunction
endmodule
