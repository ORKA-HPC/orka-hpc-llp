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
module alt_pr(
	clk,
	nreset,
	freeze,
	pr_start,
	double_pr,
	status,
	data,
	data_valid,
	data_ready,
	avmm_slave_address,
	avmm_slave_read,
	avmm_slave_readdata,
	avmm_slave_write,
	avmm_slave_writedata,
	avmm_slave_waitrequest,
	irq,
	pr_ready_pin,
	pr_done_pin,
	pr_error_pin,
	pr_request_pin,
	pr_clk_pin,
	pr_data_pin,
	crc_error_pin
);
	parameter PR_INTERNAL_HOST = 1; // '1' means Internal Host, '0' means External Host
	parameter CDRATIO = 1; // valid: 1, 2, 4, 8(Arria 10 only)
	parameter DATA_WIDTH_INDEX = 16; // valid: 1, 2, 4, 8, 16, 32. For Avalon-MM interface, always set to 16.
	parameter CB_DATA_WIDTH = 16;
	parameter ENABLE_DATA_PACKING = 1;
	parameter ENABLE_AVMM_SLAVE = 0; // '1' means Enable Avalon-MM slave interface, '0' means Conduit interface
	parameter ENABLE_JTAG = 1;	// '1' means Enable JTAG debug mode, '0' means Disable
	parameter EDCRC_OSC_DIVIDER = 1; // valid: 1, 2, 4, 8, 16, 32, 64, 128, 256
	parameter DEVICE_FAMILY	= "Stratix V";
    parameter EXT_HOST_TARGET_DEVICE_FAMILY	= "Stratix V"; // Target device family for PR when External Host is enabled. 
	parameter ENABLE_HPR = 0; // '1' means Enable, '0' means Disable
	parameter ENABLE_PRPOF_ID_CHECK = 1; // '1' means Enable, '0' means Disable
	parameter EXT_HOST_PRPOF_ID = 0; // valid: 32-bit integer value
	parameter ENABLE_ENHANCED_DECOMPRESSION = 0;
	parameter INSTANTIATE_PR_BLOCK = 1;
	parameter INSTANTIATE_CRC_BLOCK = 1;
	parameter ENABLE_INTERRUPT = 0;

	// We have two different input data paths - ST/MM and JTAG.
	localparam ST_MM_INPUT_DATA_WIDTH = DATA_WIDTH_INDEX; // An alias.
	localparam JTAG_INPUT_DATA_WIDTH = 16;

	localparam EFFECTIVE_DEVICE_FAMILY = PR_INTERNAL_HOST ? DEVICE_FAMILY : EXT_HOST_TARGET_DEVICE_FAMILY;

	localparam CSR_IRQ_BIT_OFFSET = 5;
	
    localparam CSR_VERSION = 32'hAA500003;

	input clk;
	input nreset;
	input pr_start;
	input double_pr;
	input data_valid;
	input [ST_MM_INPUT_DATA_WIDTH-1:0] data;
	input [3:0] avmm_slave_address;
	input avmm_slave_read;
	input avmm_slave_write;
	input [ST_MM_INPUT_DATA_WIDTH-1:0] avmm_slave_writedata;
	input pr_ready_pin;
	input pr_done_pin;
	input pr_error_pin;
	input crc_error_pin;
	
	output freeze;
	output data_ready;
	output [2:0] status;
	output [ST_MM_INPUT_DATA_WIDTH-1:0] avmm_slave_readdata;
	output avmm_slave_waitrequest;
	output pr_request_pin;
	output pr_clk_pin;
	output [CB_DATA_WIDTH-1:0] pr_data_pin;
	output irq;

	reg [1:0] pr_csr;
	reg [2:0] status_reg; // pr_csr[4:2]
	reg lock_error_reg;
	reg nreset_reg1;
	reg nreset_reg2;
	
	wire clk_w;
	wire nreset_w;
	wire pr_start_w;
	wire first_pr_start_cycle_w;
	wire freeze_w;
	wire double_pr_w;
	wire crc_error_w;
	wire pr_error_w;
	wire pr_ready_w;
	wire pr_done_w;
	wire pr_clk_w;
	wire [CB_DATA_WIDTH-1:0] pr_data_w;
	wire jtag_control_w;
	wire jtag_start_w;
	wire jtag_tck_w;
	wire jtag_double_pr_w;
	wire bitstream_incompatible_w;
	wire bitstream_ready_w;
	wire avmm_start_w;
	wire avmm_double_pr_w;
	wire waitrequest_w;
	wire update_list_w;

	wire                              st_mm_input_valid_w;
	wire [ST_MM_INPUT_DATA_WIDTH-1:0] st_mm_input_data_w;
	wire                              st_mm_input_ready_w;
	wire                              st_mm_width_adapted_input_valid_w;
	wire [CB_DATA_WIDTH-1:0]          st_mm_width_adapted_input_data_w;
	wire                              st_mm_width_adapted_input_ready_w;
	wire                              jtag_input_valid_w;
	wire [JTAG_INPUT_DATA_WIDTH-1:0]  jtag_input_data_w;
	wire                              jtag_input_ready_w;
	wire                              jtag_width_adapted_input_valid_w;
	wire [CB_DATA_WIDTH-1:0]          jtag_width_adapted_input_data_w;
	wire                              jtag_width_adapted_input_ready_w;
	wire                              muxed_data_valid_w;
	wire [CB_DATA_WIDTH-1:0]          muxed_data_w;
	wire                              muxed_data_ready_w;
	wire                              decoded_data_valid_w;
	wire [CB_DATA_WIDTH-1:0]          decoded_data_w;
	wire                              decoded_data_ready_w;
    wire [31:0]                       pr_pof_id;

	assign freeze = freeze_w;
	assign nreset_w = nreset_reg2;

    generate
		if (ENABLE_JTAG == 1) begin
            // avoid glitch when muxing clock  
            alt_pr_clk_mux #(
                .NUM_CLOCKS(2),
                .USE_FOLLOWERS(1'b0)
            ) pr_jtag_clk_mux (
                .clk({jtag_tck_w, clk}),
                .clk_select({jtag_control_w, ~jtag_control_w}),
                .clk_out(clk_w)	
            );
		end
		else begin
			assign clk_w = clk;
		end
	endgenerate
	
	// avoid async reset removal issue 
	always @(negedge nreset or posedge clk_w)
	begin
		if (~nreset) begin
			{nreset_reg2, nreset_reg1} <= 2'b0;
		end
		else begin
			{nreset_reg2, nreset_reg1} <= {nreset_reg1, 1'b1};
		end
	end
	
	// manage status[2:0]
	always @(posedge clk_w)
	begin
		if (~nreset_w) begin
			// power-up or nreset asserted
			status_reg <= 3'b000;
			lock_error_reg <= 1'b0;
		end
		else if (crc_error_w && ~lock_error_reg) begin
			// CRC_ERROR detected
			status_reg <= 3'b010;
			lock_error_reg <= 1'b1;
		end
		else if (freeze_w) begin
			if (bitstream_incompatible_w && ~lock_error_reg) begin
				// incompatible bitstream error detected
				status_reg <= 3'b011;
				lock_error_reg <= 1'b1;
			end
			else if (pr_error_w && ~lock_error_reg) begin
				// PR_ERROR detected
				status_reg <= 3'b001;
				lock_error_reg <= 1'b1;
			end
		end
		else if (~freeze_w && (status_reg == 3'b100)) begin
			// PR operation passed
			status_reg <= 3'b101;
			lock_error_reg <= 1'b0;
		end
		else if (pr_start_w) begin
			// PR operation in progress
			status_reg <= 3'b100;
			lock_error_reg <= 1'b0;
		end
	end
	
	// Avalon-MM slave interface or conduit interface
	generate
		if (ENABLE_AVMM_SLAVE == 1) begin
			assign avmm_start_w = pr_csr[0];
			assign avmm_double_pr_w = pr_csr[1];
			assign st_mm_input_data_w = avmm_slave_writedata;
			assign st_mm_input_valid_w = avmm_slave_write && (avmm_slave_address == 4'b000);
			assign avmm_slave_readdata =
               (avmm_slave_address == 4'b001) ? {{(ST_MM_INPUT_DATA_WIDTH-6){1'b0}}, irq, status_reg[2:0], pr_csr[1:0]} :
               (avmm_slave_address == 4'b010) ? CSR_VERSION :
               (avmm_slave_address == 4'b011) ? pr_pof_id :
               {(ST_MM_INPUT_DATA_WIDTH){1'b0}};
			assign avmm_slave_waitrequest = jtag_control_w ? 1'b1 : waitrequest_w;
			assign waitrequest_w = ~nreset_w || avmm_start_w || (freeze_w && st_mm_input_valid_w && ~st_mm_input_ready_w);
			assign pr_start_w = jtag_control_w ? jtag_start_w : avmm_start_w;
			assign double_pr_w = jtag_control_w ? jtag_double_pr_w : avmm_double_pr_w;
			
			always @(posedge clk_w)
			begin
				if (~nreset_w) begin
					pr_csr[1:0] <= 2'd0;
				end
				else if (avmm_slave_write && avmm_slave_address[0]) begin
					pr_csr[0] <= avmm_slave_writedata[0];
					pr_csr[1] <= avmm_slave_writedata[1];
				end
				else begin
					pr_csr[0] <= 1'b0;
				end
			end
		end
		else begin
			assign status[2:0] = status_reg[2:0];
			assign data_ready = st_mm_input_ready_w;
			assign st_mm_input_data_w = data;
			assign st_mm_input_valid_w = data_valid;
			assign avmm_slave_readdata = {(ST_MM_INPUT_DATA_WIDTH){1'b0}};
			assign avmm_slave_waitrequest = 1'b1;
			assign pr_start_w = jtag_control_w ? jtag_start_w : pr_start;
			assign double_pr_w = jtag_control_w ? jtag_double_pr_w : double_pr;
		end
	endgenerate

	generate
		if (ENABLE_AVMM_SLAVE && ENABLE_INTERRUPT) begin
			reg irq_reg;
			always @(posedge clk_w) begin
				if (~nreset_w) begin
					irq_reg <= 1'b0;
				end else if (crc_error_w) begin
					irq_reg <= 1'b1; // CRC_ERROR.
				end else if (freeze_w && (bitstream_incompatible_w || pr_error_w)) begin
					irq_reg <= 1'b1; // Incompatible bitstream or PR_ERROR.
				end else if (~freeze_w && status_reg == 3'b100) begin
					irq_reg <= 1'b1; // Successful PR operation.
				end else if (avmm_slave_write && avmm_slave_address[0] && avmm_slave_writedata[CSR_IRQ_BIT_OFFSET]) begin
					irq_reg <= 1'b0; // Clear interrupt.
				end
			end

			assign irq = irq_reg;
		end else begin
			assign irq = 1'b0;
		end
	endgenerate

	reg previous_pr_start;
	always @(posedge clk_w) begin
		previous_pr_start <= pr_start_w;
	end
	assign first_pr_start_cycle_w = ~previous_pr_start & pr_start_w;

	alt_pr_cb_host alt_pr_cb_host(
		.clk(clk_w),
		.nreset(nreset_w),
		.pr_start(pr_start_w),
		.double_pr(double_pr_w),
		.o_freeze(freeze_w),
		.o_crc_error(crc_error_w),
		.o_pr_error(pr_error_w),
		.o_pr_ready(pr_ready_w),
		.o_pr_done(pr_done_w),
		.pr_clk(pr_clk_w),
		.pr_ready_pin(pr_ready_pin),
		.pr_done_pin(pr_done_pin),
		.pr_error_pin(pr_error_pin),
		.o_pr_request_pin(pr_request_pin),
		.o_pr_clk_pin(pr_clk_pin),
		.o_pr_data_pin(pr_data_pin),
		.crc_error_pin(crc_error_pin),
		.pr_data(pr_data_w),
		.bitstream_ready(bitstream_ready_w),
		.bitstream_incompatible(bitstream_incompatible_w),
		.update_list(update_list_w)
	);
	defparam alt_pr_cb_host.CDRATIO = CDRATIO;
	defparam alt_pr_cb_host.CB_DATA_WIDTH = CB_DATA_WIDTH;
	defparam alt_pr_cb_host.EDCRC_OSC_DIVIDER = EDCRC_OSC_DIVIDER;
	defparam alt_pr_cb_host.DEVICE_FAMILY = EFFECTIVE_DEVICE_FAMILY;
	defparam alt_pr_cb_host.INSTANTIATE_PR_BLOCK = PR_INTERNAL_HOST && INSTANTIATE_PR_BLOCK;
	defparam alt_pr_cb_host.INSTANTIATE_CRC_BLOCK = PR_INTERNAL_HOST && INSTANTIATE_CRC_BLOCK;

	alt_pr_bitstream_host alt_pr_bitstream_host(
		.clk(clk_w),
		.nreset(nreset_w),
		.pr_start(pr_start_w),
		.double_pr(double_pr_w),
		.freeze(freeze_w),
		.crc_error(crc_error_w),
		.pr_error(pr_error_w),
		.pr_ready(pr_ready_w),
		.pr_done(pr_done_w),
		.o_pr_clk(pr_clk_w),
		.o_pr_data(pr_data_w),
		.o_bitstream_incompatible(bitstream_incompatible_w),
        .o_pr_pof_id(pr_pof_id),
		.o_bitstream_ready(bitstream_ready_w),
		.o_update_list(update_list_w),

		.data_valid(decoded_data_valid_w),
		.data(decoded_data_w),
		.o_data_ready(decoded_data_ready_w)
	);
	defparam alt_pr_bitstream_host.PR_INTERNAL_HOST = PR_INTERNAL_HOST; 
	defparam alt_pr_bitstream_host.CDRATIO = CDRATIO;
	defparam alt_pr_bitstream_host.DONE_TO_END = ((CDRATIO==1) ? 7 : ((CDRATIO==2) ? 3 : 1 ));
	defparam alt_pr_bitstream_host.CB_DATA_WIDTH = CB_DATA_WIDTH; 
	defparam alt_pr_bitstream_host.ENABLE_HPR = ENABLE_HPR;
	defparam alt_pr_bitstream_host.ENABLE_PRPOF_ID_CHECK = ENABLE_PRPOF_ID_CHECK;
	defparam alt_pr_bitstream_host.EXT_HOST_PRPOF_ID = EXT_HOST_PRPOF_ID;
	defparam alt_pr_bitstream_host.DEVICE_FAMILY = DEVICE_FAMILY;
    defparam alt_pr_bitstream_host.EXT_HOST_TARGET_DEVICE_FAMILY = EXT_HOST_TARGET_DEVICE_FAMILY;

	alt_pr_bitstream_decoder alt_pr_bitstream_decoder(
		.clk(clk_w),
		.nreset(~(~nreset_w | first_pr_start_cycle_w)),

		.sink_valid(muxed_data_valid_w),
		.sink_data(muxed_data_w),
		.sink_ready(muxed_data_ready_w),

		.source_valid(decoded_data_valid_w),
		.source_data(decoded_data_w),
		.source_ready(decoded_data_ready_w)
	);
	defparam alt_pr_bitstream_decoder.DATA_WIDTH = CB_DATA_WIDTH;
	defparam alt_pr_bitstream_decoder.ENABLE_ENHANCED_DECOMPRESSION = ENABLE_ENHANCED_DECOMPRESSION;

	alt_pr_mux alt_pr_mux(
		.select(jtag_control_w),

		.sink0_valid(st_mm_width_adapted_input_valid_w),
		.sink0_data(st_mm_width_adapted_input_data_w),
		.sink0_ready(st_mm_width_adapted_input_ready_w),

		.sink1_valid(jtag_width_adapted_input_valid_w),
		.sink1_data(jtag_width_adapted_input_data_w),
		.sink1_ready(jtag_width_adapted_input_ready_w),

		.source_valid(muxed_data_valid_w),
		.source_data(muxed_data_w),
		.source_ready(muxed_data_ready_w)
	);
	defparam alt_pr_mux.DATA_WIDTH = CB_DATA_WIDTH; 

	generate
		if (ENABLE_JTAG == 1) begin
			alt_pr_width_adapter jtag_input_width_adapter(
				.clk(clk_w),
				.nreset(~(~nreset_w | ~freeze_w)), // Reset the width adapter every time there's an actual reset or when `freeze` is deasserted.

				.sink_valid(jtag_input_valid_w),
				.sink_data(jtag_input_data_w),
				.sink_ready(jtag_input_ready_w),

				.source_valid(jtag_width_adapted_input_valid_w),
				.source_data(jtag_width_adapted_input_data_w),
				.source_ready(jtag_width_adapted_input_ready_w)
			);
			defparam jtag_input_width_adapter.SINK_DATA_WIDTH = JTAG_INPUT_DATA_WIDTH;
			defparam jtag_input_width_adapter.SOURCE_DATA_WIDTH = CB_DATA_WIDTH;
			defparam jtag_input_width_adapter.ENABLE_DATA_PACKING = ENABLE_DATA_PACKING;

			alt_pr_jtag_interface alt_pr_jtag_interface(
				.nreset(nreset_w),
				.freeze(freeze_w),
				.pr_ready(pr_ready_w),
				.pr_done(pr_done_w),
				.pr_error(pr_error_w),
				.crc_error(crc_error_w),
				.o_tck(jtag_tck_w),
				.o_double_pr(jtag_double_pr_w),
				.o_jtag_control(jtag_control_w),
				.o_jtag_start(jtag_start_w),
				.bitstream_incompatible(bitstream_incompatible_w),

				.o_jtag_data_valid(jtag_input_valid_w),
				.o_jtag_data(jtag_input_data_w),
				.jtag_data_ready(jtag_input_ready_w)
			);
			defparam alt_pr_jtag_interface.PR_INTERNAL_HOST = PR_INTERNAL_HOST;
			defparam alt_pr_jtag_interface.SOURCE_DATA_WIDTH = JTAG_INPUT_DATA_WIDTH;
			defparam alt_pr_jtag_interface.ENABLE_ENHANCED_DECOMPRESSION = ENABLE_ENHANCED_DECOMPRESSION;
		end
		else begin
			assign jtag_tck_w = 1'b0;
			assign jtag_double_pr_w = 1'b0;
			assign jtag_control_w = 1'b0;
			assign jtag_start_w = 1'b0;

			assign jtag_width_adapted_input_valid_w = 1'b0;
			assign jtag_width_adapted_input_data_w = 1'b0;
		end
	endgenerate 

	alt_pr_width_adapter st_mm_input_width_adapter(
		.clk(clk_w),
		.nreset(~(~nreset_w | ~freeze_w)), // Reset the width adapter every time there's an actual reset or when `freeze` is deasserted.

		.sink_valid(st_mm_input_valid_w),
		.sink_data(st_mm_input_data_w),
		.sink_ready(st_mm_input_ready_w),

		.source_valid(st_mm_width_adapted_input_valid_w),
		.source_data(st_mm_width_adapted_input_data_w),
		.source_ready(st_mm_width_adapted_input_ready_w)
	);
	defparam st_mm_input_width_adapter.SINK_DATA_WIDTH = ST_MM_INPUT_DATA_WIDTH;
	defparam st_mm_input_width_adapter.SOURCE_DATA_WIDTH = CB_DATA_WIDTH;
	defparam st_mm_input_width_adapter.ENABLE_DATA_PACKING = ENABLE_DATA_PACKING;
endmodule

