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
// This is an ST-compliant wrapper.
module alt_pr_enhanced_decompressor#(
    parameter DATA_WIDTH = 16 // Supports 16 or 32 only.
) (
    input  logic                   clk,
    input  logic                   nreset,

    input  logic                   enable,

    input  logic                   sink_valid,
    input  logic[DATA_WIDTH - 1:0] sink_data,
    output logic                   sink_ready,

    output logic                   source_valid,
    output logic[DATA_WIDTH - 1:0] source_data,
    input  logic                   source_ready
);
    alt_pr_cfg_speed2_decompressor_cb32#(
        .CONF_DATA_WIDTH(DATA_WIDTH)
    ) alt_pr_cfg_speed2_decompressor_cb32 (
        .clk(clk),
        .nreset(nreset),

        .control_ready(nreset),
        .enable(enable),

        .flash_data_ready(sink_valid),
        .flash_data(sink_data),
        .flash_data_read(sink_ready),

        .fpga_data_ready(source_valid),
        .fpga_data(source_data),
        // To workaround the fact that `fpga_data_read` shouldn't be asserted
        // if `fpga_data_ready` is not. This makes the `source` ST-compliant.
        .fpga_data_read(source_valid & source_ready)
    );
endmodule

`timescale 1ns/1ns
// This is a modified version of `alt_pfl_cfg_speed2_decompressor_cb32`.
module alt_pr_cfg_speed2_decompressor_cb32 (
	clk,
	nreset,
	
	// Control block interface
	flash_data_ready,
	flash_data_read,
	flash_data,
	control_ready,
	
	// FPGA configuration block interface
	fpga_data,
	fpga_data_ready,
	fpga_data_read,
	
	enable
);
	parameter CONF_DATA_WIDTH = 16;
	localparam REAL_COUNTER_WIDTH = (CONF_DATA_WIDTH == 16)? 11 : 10;
	localparam MINUS_REAL_COUNTER_WIDTH = (CONF_DATA_WIDTH == 16)? 1 : 2;
	localparam NUMBER_OF_VARIABLE_DUPLICATION = CONF_DATA_WIDTH / 8;
	localparam NUMBER_OF_NIBBLE = CONF_DATA_WIDTH / 4;
	localparam NUMBER_OF_ACCUMULATED_COUNTER = (CONF_DATA_WIDTH == 16)? 8 : 4;
	localparam [1:0] CONF_DATA_INDEX = (CONF_DATA_WIDTH == 16)? 2'b01 : 2'b10;
	localparam [1:0] CONF_DATA_NO_INDEX = 2'b00;
	localparam WORD_COUNTER_WIDTH = (CONF_DATA_WIDTH == 16) ? 3 : 2;
	localparam NIBBLE_INFO_READ_INDEX = (CONF_DATA_WIDTH == 16) ? 1 : 0;
	localparam NIBBLE_COUNTER_WIDTH = (CONF_DATA_WIDTH == 16) ? 3 : 4;

	// State machine
	parameter DCMP_SAME 						= 4'd0;
	parameter DCMP_INIT 						= 4'd1;	// wait FLASH to be ready
	parameter DCMP_HEADER 					= 4'd2;
	parameter DCMP_SEND_VARIABLE			= 4'd3;
	parameter DCMP_SEND_DATA 				= 4'd4;
	parameter DCMP_NIBBLE_SIZE				= 4'd5;
	parameter DCMP_NIBBLE_BIT				= 4'd6;
	parameter DCMP_CALCULATE_NIBBLE		= 4'd7;
	parameter DCMP_NIBBLE					= 4'd8;
	parameter DCMP_ODD						= 4'd9;

	input 	clk;
	input 	nreset;
	
	input		flash_data_ready;
	output	flash_data_read;
	input		[CONF_DATA_WIDTH-1:0] flash_data;
	input		control_ready;
	
	output	[CONF_DATA_WIDTH-1:0] fpga_data;
	output	fpga_data_ready;
	input		fpga_data_read;
	
	input 	enable;

	reg [3:0] current_state /* synthesis altera_attribute = "-name SUPPRESS_REG_MINIMIZATION_MSG ON" */;
	reg [3:0] next_state;
	
	genvar i;
	
	wire [31:0] flash_data_in;
	wire flash_data_read_in;

	wire one_data_ready;
	wire two_data_ready;
	wire three_data_ready;
	wire four_data_ready;
	wire five_data_ready;
	wire six_data_ready;
	wire seven_data_ready;
	wire eight_data_ready;
	wire conf_data_ready;

	wire nibble_data_need_zero;
	wire nibble_data_need_one;
	wire nibble_data_need_two;
	wire nibble_data_need_three;
	wire nibble_data_need_four;
	wire nibble_data_need_five;
	wire nibble_data_need_six;
	wire nibble_data_need_seven;
	wire nibble_data_need_eight;

	wire nibble_data_read_one = nibble_data_need_one & one_data_ready;
	wire nibble_data_read_two = nibble_data_need_two & two_data_ready;
	wire nibble_data_read_three = nibble_data_need_three & three_data_ready;
	wire nibble_data_read_four = nibble_data_need_four & four_data_ready;
	wire nibble_data_read_five = nibble_data_need_five & five_data_ready;
	wire nibble_data_read_six = nibble_data_need_six & six_data_ready;
	wire nibble_data_read_seven = nibble_data_need_seven & seven_data_ready;
	wire nibble_data_read_eight = nibble_data_need_eight & eight_data_ready;
	wire nibble_data_read = nibble_data_need_zero | nibble_data_read_one | nibble_data_read_two |
									nibble_data_read_three | nibble_data_read_four | nibble_data_read_five |
									nibble_data_read_six | nibble_data_read_seven | nibble_data_read_eight;				

	wire alt_pr_data_read;

	// Everything start with HEADER state
	// Here you either read data in 2, 4, 6 
	// However to make life easier ready signal depends on 6
	wire compressed_variable_wire = (flash_data_in[6:4] == 3'b010);
	wire compressed_none_wire 		= (flash_data_in[6:4] == 3'b101);
	wire compressed_nibble_wire 	= (flash_data_in[6:4] == 3'b100);
	wire header_read_six = (current_state == DCMP_HEADER & six_data_ready & flash_data_in[7] & compressed_variable_wire);
	wire header_read_four = (current_state == DCMP_HEADER & six_data_ready & (flash_data_in[7] ^ compressed_variable_wire));
	wire header_read_two = (current_state == DCMP_HEADER & six_data_ready & ~header_read_six & ~header_read_four);

	reg[1:0] nibble_size;

	// Then in NIBBLE_BIT state, determine how many data we need to read
	wire nibble_need_two = (current_state == DCMP_NIBBLE_BIT) && nibble_size == 2'b00;
	wire nibble_need_four = (current_state == DCMP_NIBBLE_BIT) && nibble_size == 2'b01;
	wire nibble_need_six = (current_state == DCMP_NIBBLE_BIT) && nibble_size == 2'b10;
	wire nibble_need_eight = (current_state == DCMP_NIBBLE_BIT) && nibble_size == 2'b11;
	wire nibble_read_two = (nibble_need_two & two_data_ready);
	wire nibble_read_four = (nibble_need_four & four_data_ready);
	wire nibble_read_six = (nibble_need_six & six_data_ready);
	wire nibble_read_eight = (nibble_need_eight & eight_data_ready);
	wire nibble_read = nibble_read_two | nibble_read_four | nibble_read_six | nibble_read_eight;

	wire [CONF_DATA_WIDTH-1:0] config_data;
	reg [7:0] variable;

	wire [CONF_DATA_WIDTH-1:0] fpga_data_wire = (current_state == DCMP_NIBBLE) ? config_data :
																(current_state == DCMP_SEND_DATA)? flash_data_in[CONF_DATA_WIDTH-1:0] :
																{(NUMBER_OF_VARIABLE_DUPLICATION){variable}};
	wire fpga_data_ready_wire = ((current_state == DCMP_NIBBLE & nibble_data_read) || 
											(current_state == DCMP_SEND_DATA && conf_data_ready) ||
											current_state == DCMP_SEND_VARIABLE);
	wire [1:0] conf_data_read = (current_state == DCMP_SEND_DATA & conf_data_ready & alt_pr_data_read)? 
											CONF_DATA_INDEX : CONF_DATA_NO_INDEX;

	wire one_data_read = (nibble_data_read_one & alt_pr_data_read);
	wire two_data_read = header_read_two | nibble_read_two | (nibble_data_read_two & alt_pr_data_read);
	wire three_data_read = (nibble_data_read_three & alt_pr_data_read);
	wire four_data_read = header_read_four | conf_data_read[0] | nibble_read_four | (nibble_data_read_four & alt_pr_data_read);
	wire five_data_read = (nibble_data_read_five & alt_pr_data_read);
	wire six_data_read = header_read_six | nibble_read_six | (nibble_data_read_six & alt_pr_data_read);
	wire seven_data_read = (nibble_data_read_seven & alt_pr_data_read);
	wire eight_data_read = conf_data_read[1] | nibble_read_eight | (nibble_data_read_eight & alt_pr_data_read);
	wire auto_byte_align = (current_state == DCMP_NIBBLE_SIZE || current_state == DCMP_ODD);

	alt_pr_magic_fifo alt_pr_magic_fifo 
	(
		.clk(clk),
		.sclr(current_state == DCMP_INIT),
		
		// Interface with flash
		.data_in(flash_data),
		.data_in_ready(flash_data_ready),
		.data_in_read(flash_data_read_in),
		
		// Interface with internal
		.q(flash_data_in),
		.one_ready(one_data_ready),
		.two_ready(two_data_ready),
		.three_ready(three_data_ready),
		.four_ready(four_data_ready),
		.five_ready(five_data_ready),
		.six_ready(six_data_ready),
		.seven_ready(seven_data_ready),
		.eight_ready(eight_data_ready),
		
		.one_rd(one_data_read),
		.two_rd(two_data_read),
		.three_rd(three_data_read),
		.four_rd(four_data_read),
		.five_rd(five_data_read),
		.six_rd(six_data_read),
		.seven_rd(seven_data_read),
		.eight_rd(eight_data_read),
		
		.auto_byte_align(auto_byte_align)
	);
	defparam
		alt_pr_magic_fifo.DATA_IN_WIDTH = CONF_DATA_WIDTH;

	generate
		if (CONF_DATA_WIDTH == 16)
			assign conf_data_ready = four_data_ready;
		else if (CONF_DATA_WIDTH == 32)
			assign conf_data_ready = eight_data_ready;
	endgenerate

	// latching data
	wire [CONF_DATA_WIDTH-1:0] latched_fpga_data;
	wire latched_fpga_data_ready;
	alt_pr_data alt_pr_data
	(
		.clk(clk),
		.data_request(enable & control_ready),
		.data_in(fpga_data_wire),
		.data_in_ready(fpga_data_ready_wire),
		.data_in_read(alt_pr_data_read),
	
		.data_out(latched_fpga_data),
		.data_out_ready(latched_fpga_data_ready),
		.data_out_read(fpga_data_read)
	);
	defparam
		alt_pr_data.DATA_WIDTH = CONF_DATA_WIDTH;
		
	// version4
	assign fpga_data_ready = enable? latched_fpga_data_ready : flash_data_ready;
	assign fpga_data = enable? latched_fpga_data: flash_data;
	assign flash_data_read = enable? flash_data_read_in : fpga_data_read;
	
	// Now you determine variable in HEADER state
	always @(posedge clk) begin
		if(current_state == DCMP_HEADER & six_data_ready) begin
			if (flash_data_in[6:4] == 2'b0)
				variable <= 8'h00;
			else if(flash_data_in[6:4] == 3'b111)
				variable <= 8'hFF;
			else if (flash_data_in[7] & flash_data_in[6:4] == 3'b010)
				variable <= flash_data_in[23:16];
			else if (flash_data_in[6:4] == 3'b010)
				variable <= flash_data_in[15:8];
		end
	end
	
	// Here you determine the PACKET size
	wire [11:0] header_size = flash_data_in[7]? 
										{flash_data_in[15:8], flash_data_in[3:0]} : 
										{8'b0, flash_data_in[3:0]};
	reg [REAL_COUNTER_WIDTH-1:0] decompress_count_q;
	wire decompress_count_done = (decompress_count_q == {(REAL_COUNTER_WIDTH){1'b0}});
	wire sload_decompress_counter = (current_state == DCMP_HEADER) & six_data_ready;
	wire [REAL_COUNTER_WIDTH-1:0] decompress_count_data = header_size[11:MINUS_REAL_COUNTER_WIDTH];
	lpm_counter decompress_counter (
		.clock(clk),
		.cnt_en((fpga_data_ready_wire && alt_pr_data_read)),
		.sload(sload_decompress_counter),
		.data(decompress_count_data),
		.q(decompress_count_q)
	);
	defparam
	decompress_counter.lpm_type = "LPM_COUNTER",
	decompress_counter.lpm_direction= "DOWN",
	decompress_counter.lpm_width = REAL_COUNTER_WIDTH;
	
	// Now for NIBBLE sub PACKET size
	reg [WORD_COUNTER_WIDTH-1:0] word_count_q;	
	wire en_word_counter = current_state == DCMP_NIBBLE & alt_pr_data_read;
	wire sload_word_counter = next_state == DCMP_NIBBLE_SIZE;
	lpm_counter word_counter (
		.clock(clk),
		.cnt_en(en_word_counter),
		.sload(sload_word_counter),
		.data({(WORD_COUNTER_WIDTH){1'b1}}),
		.q(word_count_q)
	);
	defparam
		word_counter.lpm_type = "LPM_COUNTER",
		word_counter.lpm_direction= "DOWN",
		word_counter.lpm_width = WORD_COUNTER_WIDTH;
	
	// Now for size of NIBBLE INFO
	// This NIBBLE INFO will be processed during NIBBLE_BIT state
	always @(posedge clk) begin
		if (current_state == DCMP_NIBBLE_SIZE) begin
			if (decompress_count_q[REAL_COUNTER_WIDTH-1:NIBBLE_INFO_READ_INDEX+2] == 8'b0)
				nibble_size <= decompress_count_q[NIBBLE_INFO_READ_INDEX+1:NIBBLE_INFO_READ_INDEX];
			else
				nibble_size <= 2'b11;
		end
	end

	// Update this reg at NIBBLE_BIT state when data is ready
	// nibble_info determine which nibble to be zero and which to be data
	reg [31:0] nibble_info; 
	always @(posedge clk) begin
		if (nibble_read_eight)
			nibble_info <= flash_data_in[31:0];
		else if (nibble_read_six)
			nibble_info <= {8'd0, flash_data_in[23:0]};
		else if (nibble_read_four)
			nibble_info <= {16'd0, flash_data_in[15:0]};
		else if (nibble_read_two)
			nibble_info <= {24'd0, flash_data_in[7:0]};
		else if (current_state == DCMP_NIBBLE & alt_pr_data_read)
			nibble_info <= {{(NUMBER_OF_NIBBLE){1'b0}}, nibble_info[31:NUMBER_OF_NIBBLE]};
	end
	
	//	localparam NUMBER_OF_ACCUMULATED_COUNTER = (CONF_DATA_WIDTH == 16)? 8 : 4;	// 
	// localparam NIBBLE_COUNTER_WIDTH = (CONF_DATA_WIDTH == 16) ? 3 : 4; 			// MAX is 8
	reg [NIBBLE_COUNTER_WIDTH-1:0] nibble_counter [0:NUMBER_OF_ACCUMULATED_COUNTER-1];
	// Calculate counter
	generate
		if (CONF_DATA_WIDTH == 32) begin
			always @(posedge clk) begin
				if (current_state == DCMP_CALCULATE_NIBBLE) begin
					nibble_counter[3] <= nibble_info[7] + nibble_info[6] + nibble_info[5] + nibble_info[4] + nibble_info[3] + nibble_info[2] + nibble_info[1] + nibble_info[0];
					nibble_counter[2] <= nibble_info[15] + nibble_info[14] + nibble_info[13] + nibble_info[12] + nibble_info[11] + nibble_info[10] + nibble_info[9] + nibble_info[8];
					nibble_counter[1] <= nibble_info[23] + nibble_info[22] + nibble_info[21] + nibble_info[20] + nibble_info[19] + nibble_info[18] + nibble_info[17] + nibble_info[16];
					nibble_counter[0] <= nibble_info[31] + nibble_info[30] + nibble_info[29] + nibble_info[28] + nibble_info[27] + nibble_info[26] + nibble_info[25] + nibble_info[24];
				end
			end
		end
		else begin
			always @(posedge clk) begin
				if (current_state == DCMP_CALCULATE_NIBBLE) begin
					nibble_counter[7] <= nibble_info[3] + nibble_info[2] + nibble_info[1] + nibble_info[0];
					nibble_counter[6] <= nibble_info[7] + nibble_info[6] + nibble_info[5] + nibble_info[4];
					nibble_counter[5] <= nibble_info[11] + nibble_info[10] + nibble_info[9] + nibble_info[8];
					nibble_counter[4] <= nibble_info[15] + nibble_info[14] + nibble_info[13] + nibble_info[12];
					nibble_counter[3] <= nibble_info[19] + nibble_info[18] + nibble_info[17] + nibble_info[16];
					nibble_counter[2] <= nibble_info[23] + nibble_info[22] + nibble_info[21] + nibble_info[20];
					nibble_counter[1] <= nibble_info[27] + nibble_info[26] + nibble_info[25] + nibble_info[24];
					nibble_counter[0] <= nibble_info[31] + nibble_info[30] + nibble_info[29] + nibble_info[28];
				end
			end
		end
	endgenerate
	
	// Determine the ODD
	reg odd;
	always @ (posedge clk) begin
		if (current_state == DCMP_CALCULATE_NIBBLE) begin
			odd <= ^nibble_info;
		end
	end
	
	// Determine how many data we need to read
	generate
		if (CONF_DATA_WIDTH == 32) begin
			assign nibble_data_need_zero = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 4'd0;
			assign nibble_data_need_one = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 4'd1;
			assign nibble_data_need_two = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 4'd2;
			assign nibble_data_need_three = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 4'd3;
			assign nibble_data_need_four = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 4'd4;
			assign nibble_data_need_five = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 4'd5;
			assign nibble_data_need_six = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 4'd6;
			assign nibble_data_need_seven = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 4'd7;
			assign nibble_data_need_eight = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 4'd8;
		end
		else begin
			assign nibble_data_need_zero = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 3'd0;
			assign nibble_data_need_one = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 3'd1;
			assign nibble_data_need_two = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 3'd2;
			assign nibble_data_need_three = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 3'd3;
			assign nibble_data_need_four = current_state == DCMP_NIBBLE & nibble_counter[word_count_q] == 3'd4;
			assign nibble_data_need_five = 1'b0;
			assign nibble_data_need_six = 1'b0;
			assign nibble_data_need_seven = 1'b0;
			assign nibble_data_need_eight = 1'b0;
		end
	endgenerate

	generate
		if (CONF_DATA_WIDTH == 32) begin
			wire [27:0] nibbles1 = nibble_info[0]? flash_data_in[31:4] : flash_data_in[27:0];
			wire [23:0] nibbles2 = nibble_info[1]? nibbles1[27:4] : nibbles1[23:0];
			wire [19:0] nibbles3 = nibble_info[2]? nibbles2[23:4] : nibbles2[19:0];
			wire [15:0] nibbles4 = nibble_info[3]? nibbles3[19:4] : nibbles3[15:0];
			wire [11:0] nibbles5 = nibble_info[4]? nibbles4[15:4] : nibbles4[11:0];
			wire [7:0] nibbles6 =  nibble_info[5]? nibbles5[11:4] : nibbles5[7:0];
			wire [3:0] nibbles7 = nibble_info[6]? nibbles6[7:4] : nibbles6[3:0];

			wire [3:0] nibble7 = nibble_info[7] ? nibbles7[3:0] : 4'd0;
			wire [3:0] nibble6 = nibble_info[6] ? nibbles6[3:0] : 4'd0;
			wire [3:0] nibble5 = nibble_info[5] ? nibbles5[3:0] : 4'd0;
			wire [3:0] nibble4 = nibble_info[4] ? nibbles4[3:0] : 4'd0;
			wire [3:0] nibble3 = nibble_info[3] ? nibbles3[3:0] : 4'd0;
			wire [3:0] nibble2 = nibble_info[2] ? nibbles2[3:0] : 4'd0;
			wire [3:0] nibble1 = nibble_info[1] ? nibbles1[3:0] : 4'd0;
			wire [3:0] nibble0 = nibble_info[0] ? flash_data_in[3:0] : 4'd0;
			assign config_data = {
											nibble7,
											nibble6,
											nibble5,
											nibble4,
											nibble3,
											nibble2,
											nibble1,
											nibble0
										};
		end
		else begin
			wire [11:0] nibbles1 = nibble_info[0]? flash_data_in[15:4] : flash_data_in[11:0];
			wire [7:0] nibbles2 = nibble_info[1]? nibbles1[11:4] : nibbles1[7:0];
			wire [3:0] nibbles3 = nibble_info[2]? nibbles2[7:4] : nibbles2[3:0];

			wire [3:0] nibble3 = nibble_info[3] ? nibbles3[3:0] : 4'd0;
			wire [3:0] nibble2 = nibble_info[2] ? nibbles2[3:0] : 4'd0;
			wire [3:0] nibble1 = nibble_info[1] ? nibbles1[3:0] : 4'd0;
			wire [3:0] nibble0 = nibble_info[0] ? flash_data_in[3:0] : 4'd0;
			assign config_data = {
											nibble3,
											nibble2,
											nibble1,
											nibble0
										};
		end
	endgenerate
			
	always @(nreset, current_state, alt_pr_data_read, one_data_ready, flash_data_in, 
				decompress_count_q, word_count_q, nibble_size, compressed_none_wire, 
				 compressed_variable_wire, compressed_nibble_wire, decompress_count_done,
				 control_ready, enable, three_data_ready, conf_data_ready, nibble_data_read, 
				 nibble_read, six_data_ready, odd)
	begin
		if (~nreset | ~control_ready | ~enable)
			next_state = DCMP_INIT;
		else begin
			case (current_state)
				DCMP_INIT:				// 1
					if(control_ready)
						next_state = DCMP_HEADER;
					else
						next_state = DCMP_SAME;
				DCMP_HEADER:			// 2
					if (six_data_ready) begin
						if(compressed_none_wire)										// compressed_none
							next_state = DCMP_SEND_DATA;
						else if(compressed_nibble_wire)								// compressed nibble
							next_state = DCMP_NIBBLE_SIZE;
						else																	// compressed zero or compressed high
							next_state = DCMP_SEND_VARIABLE;
						end
					else
						next_state = DCMP_SAME;
				DCMP_SEND_VARIABLE:	// 3
					if(decompress_count_done & alt_pr_data_read)
						next_state = DCMP_HEADER;
					else 
						next_state = DCMP_SAME;
				DCMP_SEND_DATA:		// 4
					if (decompress_count_done & alt_pr_data_read & conf_data_ready)
						next_state = DCMP_HEADER;
					else
						next_state = DCMP_SAME;
				DCMP_NIBBLE_SIZE:		// 5				
					next_state = DCMP_NIBBLE_BIT;
				DCMP_NIBBLE_BIT:
					if (nibble_read)
						next_state = DCMP_CALCULATE_NIBBLE;
					else
						next_state = DCMP_SAME;
				DCMP_CALCULATE_NIBBLE:	// 7
					next_state = DCMP_NIBBLE;
				DCMP_NIBBLE:			// 8
					if (alt_pr_data_read & decompress_count_done & odd)
						next_state = DCMP_ODD;
					else if (alt_pr_data_read & decompress_count_done)
						next_state = DCMP_HEADER;	
					else if (alt_pr_data_read & word_count_q == {(WORD_COUNTER_WIDTH){1'b0}})
						next_state = DCMP_NIBBLE_SIZE;
					else
						next_state = DCMP_SAME;
				DCMP_ODD:
					next_state = DCMP_HEADER;
				default:
					next_state = DCMP_INIT;
			endcase
		end
	end

	initial begin
		current_state = DCMP_INIT;
	end

	always @(negedge nreset or posedge clk)
	begin
		if(~nreset) begin
			current_state <= DCMP_INIT;
		end
		else begin
			if (next_state != DCMP_SAME) begin
				current_state <= next_state;
			end
		end
	end

endmodule
