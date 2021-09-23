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
module alt_pr_jtag_interface(
	nreset,
	freeze,
	pr_ready,
	pr_done,
	pr_error,
	crc_error,
	o_tck,
	o_double_pr,
	o_jtag_control,
	o_jtag_start,
	o_jtag_data,
	o_jtag_data_valid,
	jtag_data_ready,
	bitstream_incompatible
);
	
	parameter PR_INTERNAL_HOST = 1;
	parameter SOURCE_DATA_WIDTH = 16;
	parameter ENABLE_ENHANCED_DECOMPRESSION = 0;

	localparam INFO_SIZE = 17;
	localparam PR_IR_BITS = 4;
	localparam PR_NODE_ID = 113; 
	localparam VERSION = 2;

	localparam FIFO_DEPTH = ENABLE_ENHANCED_DECOMPRESSION ? 32 : 4;

	localparam [PR_IR_BITS-1:0]	IR_INIT_PR = 'h01,
								IR_DOUBLE_PR = 'h02,
								IR_START_PR = 'h03,
								IR_RESET_PR = 'h04,
								IR_SEND_PR_DATA = 'h05,
								IR_SEND_DATA_COMPLETE = 'h06,
								IR_SHIFT_INFO = 'h07,
								IR_ENGAGE_JTAG_CONTROL = 'h08,
								IR_RELEASE_JTAG_CONTROL = 'h09;
	
	localparam [2:0]	IDLE = 0,
						WAIT_FOR_INIT_COMPLETE = 1,
						WAIT_FOR_PR_READY = 2,
						SEND_PR_DATA = 3,
						WAIT_FOR_COMPLETION = 4;
	
	input nreset;
	input freeze;
	input pr_ready;
	input pr_done;
	input pr_error;
	input crc_error;
	input jtag_data_ready;
	input bitstream_incompatible;
	
	output o_tck;
	output o_double_pr;
	output o_jtag_control;
	output o_jtag_start;
	output [SOURCE_DATA_WIDTH-1:0] o_jtag_data;
	output o_jtag_data_valid;
	
	reg [2:0] jtag_state;
	reg [INFO_SIZE-1:0] info_sreg;
	reg double_pr_reg;
	reg doublepr_sec_pass_reg;
	reg pr_done_reg;
	reg pr_error_reg;
	reg crc_error_reg;
	reg bitstream_incompatible_reg;
	reg jtag_control_reg;
	
	// SLD node 
	wire [PR_IR_BITS-1:0] ir_in;
	wire [PR_IR_BITS-1:0] ir_out = ir_in [PR_IR_BITS-1:0];
	wire tdi;
	wire tck;
	wire sdr;
	wire udr;
	wire uir;
	wire tdo;

	wire ir_init_pr = (ir_in == IR_INIT_PR) ? 1'b1 : 1'b0;
	wire ir_double_pr = (ir_in == IR_DOUBLE_PR) ? 1'b1 : 1'b0;
	wire ir_start_pr = (ir_in == IR_START_PR) ? 1'b1 : 1'b0;
	wire ir_reset_pr = (ir_in == IR_RESET_PR) ? 1'b1 : 1'b0;
	wire ir_send_pr_data = (ir_in == IR_SEND_PR_DATA) ? 1'b1 : 1'b0;
	wire ir_send_data_complete = (ir_in == IR_SEND_DATA_COMPLETE) ? 1'b1 : 1'b0;
	wire ir_shift_info = (ir_in == IR_SHIFT_INFO) ? 1'b1 : 1'b0;
	wire ir_engage_jtag_control = (ir_in == IR_ENGAGE_JTAG_CONTROL) ? 1'b1 : 1'b0;
	wire ir_release_jtag_control = (ir_in == IR_RELEASE_JTAG_CONTROL) ? 1'b1 : 1'b0;
	
	wire sreg_tdo;
	wire info_sout = info_sreg[0];
	wire [SOURCE_DATA_WIDTH-1:0] jtag_dataq_w;
	wire jtag_state_idle_w;
	wire ready_for_pr_data_w;
	wire data_fifo_full_w;
	wire data_fifo_empty_w;
	wire pr_internal_host_w;
	wire data_valid_w = ~data_fifo_empty_w || ir_reset_pr;

	wire enhanced_decompression_is_enabled = ENABLE_ENHANCED_DECOMPRESSION == 1;

	assign tdo = ir_shift_info ? info_sout : sreg_tdo;
	assign o_tck = tck;
	assign o_double_pr = double_pr_reg;
	assign o_jtag_control = (jtag_state != IDLE) || jtag_control_reg;
	assign o_jtag_start = (jtag_state == WAIT_FOR_PR_READY);
	assign o_jtag_data_valid = data_valid_w;
	assign jtag_state_idle_w = (jtag_state == IDLE);
	assign ready_for_pr_data_w = (jtag_state == SEND_PR_DATA);
	assign pr_internal_host_w = (PR_INTERNAL_HOST == 1);
	
	always @(posedge tck) begin
		if (ir_shift_info && sdr) begin
			{info_sreg[INFO_SIZE-1:1], info_sreg[0]} <= {info_sreg[0], info_sreg[INFO_SIZE-1:1]};
		end
		else begin
			info_sreg[INFO_SIZE-1:0] <= {
					data_fifo_empty_w, enhanced_decompression_is_enabled,
					bitstream_incompatible_reg, pr_internal_host_w,
					pr_done_reg, pr_error_reg, crc_error_reg, 
					jtag_state[2], jtag_state[1], jtag_state[0], jtag_state_idle_w, ready_for_pr_data_w, 
					freeze, pr_ready, pr_done, pr_error, crc_error};
		end
	end
	
	always @(negedge nreset or posedge tck) begin
		if (~nreset) begin
			bitstream_incompatible_reg <= 0;
		end
		else if (ir_init_pr && uir) begin
			bitstream_incompatible_reg <= 0;
		end
		else if (~bitstream_incompatible_reg) begin
			bitstream_incompatible_reg <= bitstream_incompatible;
		end
	end
	
	always @(negedge nreset or posedge tck) begin
		if (~nreset) begin
			jtag_control_reg <= 0;
		end
		else if (ir_release_jtag_control && uir) begin
			jtag_control_reg <= 0;
		end
		else if (ir_engage_jtag_control && uir) begin
			jtag_control_reg <= 1;
		end
	end
	
	always @(negedge nreset or posedge tck) begin
		if (~nreset) begin
			jtag_state <= IDLE;
		end
		else begin
			case (jtag_state)
				IDLE: 
				begin
					double_pr_reg <= 0;
					doublepr_sec_pass_reg <= 0;
					
					if (ir_init_pr && uir) begin
						pr_done_reg <= 0;
						pr_error_reg <= 0;
						crc_error_reg <= 0;
						jtag_state <= WAIT_FOR_INIT_COMPLETE;
					end
				end

				WAIT_FOR_INIT_COMPLETE: 
				begin
					if (ir_double_pr && uir) begin
						double_pr_reg <= 1;
					end
					else if (ir_reset_pr && uir) begin
						// JTAG debug mode takes precedence
						// withdraw the current pr process
						jtag_state <= SEND_PR_DATA;
					end
					else if (~freeze && (ir_start_pr || ir_shift_info)) begin
						jtag_state <= WAIT_FOR_PR_READY;
					end
				end
				
				WAIT_FOR_PR_READY:
				begin
					if (pr_ready) begin
						jtag_state <= SEND_PR_DATA;
					end
				end
				
				SEND_PR_DATA: 
				begin
					if (pr_done || pr_error || crc_error) begin
						// additional clocks needed to complete PR process
						jtag_state <= WAIT_FOR_COMPLETION;

						if (pr_done) begin
							pr_done_reg <= 1;
						end
						if (pr_error) begin
							pr_error_reg <= 1;
						end
						if (crc_error) begin
							crc_error_reg <= 1;
						end
					end
				end
				
				WAIT_FOR_COMPLETION:
				begin
					// continue clocking with rti until conditions met
					if (~pr_done && ~pr_error && ~crc_error && ~pr_ready) begin
						// If enhanced decompression is enabled, even for a
						// double PR, there should only be one pass. If there
						// are two passes, the decoder will be reset after the
						// first PR_DONE, and the next two words will be
						// suppressed (thinking they are magic words). The
						// decoder knows nothing about double PR.
						if (pr_done_reg && double_pr_reg && ~doublepr_sec_pass_reg && !ENABLE_ENHANCED_DECOMPRESSION) begin
							// reset pr_done_reg to avoid false positive for double PR
							pr_done_reg <= 0;
							doublepr_sec_pass_reg <= 1;
							jtag_state <= WAIT_FOR_PR_READY;
						end
						else if (data_fifo_empty_w && (ir_send_data_complete || ir_reset_pr)) begin
							jtag_state <= IDLE;
						end
					end
				end
				
				default: 
				begin
					jtag_state <= IDLE;
				end
			endcase
		end
	end
	
	scfifo scfifo_component (
		.clock(tck),
		.data(jtag_dataq_w),
		.rdreq(jtag_data_ready && data_valid_w && ~ir_reset_pr),
		.sclr((jtag_state == IDLE) || ir_reset_pr),
		.wrreq(~data_fifo_full_w && ir_send_pr_data && udr && ~ir_reset_pr),
		.empty(data_fifo_empty_w),
		.full(data_fifo_full_w),
		.aclr(~nreset),
		.q(o_jtag_data)
	);
	defparam
	scfifo_component.add_ram_output_register = "ON",
	scfifo_component.lpm_numwords = FIFO_DEPTH,
	scfifo_component.lpm_showahead = "ON",
	scfifo_component.lpm_type = "scfifo",
	scfifo_component.lpm_width = SOURCE_DATA_WIDTH;
	
	lpm_shiftreg jtag_data_reg (
		.clock(tck),
		.enable(ir_send_pr_data && sdr),
		.shiftin(tdi),
		.shiftout(sreg_tdo),
		.aclr(jtag_state == IDLE),
		.q(jtag_dataq_w)
	);
	defparam
	jtag_data_reg.lpm_type = "LPM_SHIFTREG",
	jtag_data_reg.lpm_width = SOURCE_DATA_WIDTH,
	jtag_data_reg.lpm_direction = "RIGHT";

	sld_virtual_jtag_basic vjtag_module (
		.ir_in(ir_in),
		.ir_out(ir_out),
		.tdi(tdi),
		.tck(tck),
		.virtual_state_sdr(sdr),
		.virtual_state_udr(udr),
		.virtual_state_uir(uir),
		.tdo(tdo)
	);
	defparam
	vjtag_module.sld_ir_width = PR_IR_BITS,
	vjtag_module.sld_version = VERSION,
	vjtag_module.sld_type_id = PR_NODE_ID,
	vjtag_module.sld_mfg_id = 110,
	vjtag_module.sld_instance_index = 0;
	
endmodule

