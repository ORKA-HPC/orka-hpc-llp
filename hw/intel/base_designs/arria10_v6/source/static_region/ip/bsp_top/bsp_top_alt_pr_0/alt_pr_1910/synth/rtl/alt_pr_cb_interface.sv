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
module alt_pr_cb_interface(
	clk,

	// These interface with an external PR block.
	o_pr_clk_pin,
	o_pr_data_pin,
	pr_done_pin,
	pr_error_pin,
	pr_ready_pin,
	o_pr_request_pin,

	// These PR block signals are to be used in internally.
	pr_clk,
	pr_data,
	o_pr_done,
	o_pr_error,
	o_pr_ready,
	pr_request,

	// This interfaces with an external PR block.
	crc_error_pin,

	// These CRC block signals is to be used in internally.
	o_crc_error
);
	parameter CDRATIO = 1;
	parameter CB_DATA_WIDTH = 16;
	parameter EDCRC_OSC_DIVIDER = 1;
	parameter DEVICE_FAMILY	= "Stratix V";
	parameter INSTANTIATE_PR_BLOCK = 1;
	parameter INSTANTIATE_CRC_BLOCK = 1;

	input clk;

	output o_pr_clk_pin;
	output [CB_DATA_WIDTH-1:0] o_pr_data_pin;
	input  pr_done_pin;
	input  pr_error_pin;
	input  pr_ready_pin;
	output o_pr_request_pin;

	input  pr_clk;
	input  [CB_DATA_WIDTH-1:0] pr_data;
	output o_pr_done;
	output o_pr_error;
	output o_pr_ready;
	input  pr_request;

	input crc_error_pin;

	output o_crc_error;

	// synthesis translate_off
    wire [31:0] sim_only_state;
    wire [31:0] sim_only_pr_id;

    alt_pr_test_pkg::twentynm_prblock_if_mgr cb_mgr;
	// synthesis translate_on

	assign o_pr_clk_pin = pr_clk;
	assign o_pr_data_pin = pr_data;
	assign o_pr_request_pin = pr_request;

	// -----------------------------------------------------------------------
	// Instantiate wysiwyg for prblock and crcblock according to device family
	// -----------------------------------------------------------------------
	generate
		if (!INSTANTIATE_PR_BLOCK) begin
			assign o_pr_done = pr_done_pin;
			assign o_pr_error = pr_error_pin;
			assign o_pr_ready = pr_ready_pin;
		end
		else if (DEVICE_FAMILY == "Arria 10" || DEVICE_FAMILY == "Cyclone 10 GX") begin
			twentynm_prblock m_prblock
			(
            		// synthesis translate_off
				.sim_only_state(sim_only_state),
				.sim_only_pr_id(sim_only_pr_id),
            			// synthesis translate_on
				.clk(pr_clk),
				.corectl(1'b1),
				.prrequest(pr_request),
				.data(pr_data),
				.error(o_pr_error),
				.ready(o_pr_ready),
				.done(o_pr_done)
			);
            		// synthesis translate_off
            		defparam m_prblock.CDRATIO = CDRATIO;
			
			twentynm_prblock_if pr_cb_if(
				.clk(clk),
				.pr_clk(pr_clk)
			);
			assign pr_cb_if.prrequest = pr_request;
			assign pr_cb_if.data = pr_data;
			assign pr_cb_if.error = o_pr_error;
			assign pr_cb_if.ready = o_pr_ready;
			assign pr_cb_if.done = o_pr_done;
			assign pr_cb_if.sim_only_state = sim_only_state;
			assign pr_cb_if.sim_only_pr_id = sim_only_pr_id;
			
			initial begin
               			// Set the instance of control block in the singleton
               			cb_mgr = alt_pr_test_pkg::twentynm_prblock_if_mgr::get();
               			cb_mgr.set_if_reference(pr_cb_if);
            		end
			
            		// synthesis translate_on
            
		end
		else if (DEVICE_FAMILY == "Cyclone V") begin
			cyclonev_prblock m_prblock
			(
				.clk(pr_clk),
				.corectl(1'b1),
				.prrequest(pr_request),
				.data(pr_data),
				.error(o_pr_error),
				.ready(o_pr_ready),
				.done(o_pr_done)
			);
		end
		else if (DEVICE_FAMILY == "Arria V") begin
			arriav_prblock m_prblock
			(
				.clk(pr_clk),
				.corectl(1'b1),
				.prrequest(pr_request),
				.data(pr_data),
				.error(o_pr_error),
				.ready(o_pr_ready),
				.done(o_pr_done)
			);
		end
		else if (DEVICE_FAMILY == "Arria V GZ") begin
			arriavgz_prblock m_prblock
			(
				.clk(pr_clk),
				.corectl(1'b1),
				.prrequest(pr_request),
				.data(pr_data),
				.error(o_pr_error),
				.ready(o_pr_ready),
				.done(o_pr_done)
			);
		end
		else begin	// default to Stratix V
			stratixv_prblock m_prblock
			(
				.clk(pr_clk),
				.corectl(1'b1),
				.prrequest(pr_request),
				.data(pr_data),
				.error(o_pr_error),
				.ready(o_pr_ready),
				.done(o_pr_done)
			);
		end
	endgenerate
	
	generate
		if (!INSTANTIATE_CRC_BLOCK) begin
			assign o_crc_error = crc_error_pin;
		end
		else if (DEVICE_FAMILY == "Cyclone 10 GX") begin
			cyclone10gx_crcblock m_crcblock
			(
				.clk(clk),
				.shiftnld(1'b1),
				.crcerror(o_crc_error)
			);
			defparam m_crcblock.oscillator_divider = EDCRC_OSC_DIVIDER;
		end
		else if (DEVICE_FAMILY == "Arria 10") begin
			twentynm_crcblock m_crcblock
			(
				.clk(clk),
				.shiftnld(1'b1),
				.crcerror(o_crc_error)
			);
			defparam m_crcblock.oscillator_divider = EDCRC_OSC_DIVIDER;
		end
		else if (DEVICE_FAMILY == "Cyclone V") begin
			cyclonev_crcblock m_crcblock
			(
				.clk(clk),
				.shiftnld(1'b1),
				.crcerror(o_crc_error)
			);
			defparam m_crcblock.oscillator_divider = EDCRC_OSC_DIVIDER;
		end
		else if (DEVICE_FAMILY == "Arria V") begin
			arriav_crcblock m_crcblock
			(
				.clk(clk),
				.shiftnld(1'b1),
				.crcerror(o_crc_error)
			);
			defparam m_crcblock.oscillator_divider = EDCRC_OSC_DIVIDER;
		end
		else if (DEVICE_FAMILY == "Arria V GZ") begin
			arriavgz_crcblock m_crcblock
			(
				.clk(clk),
				.shiftnld(1'b1),
				.crcerror(o_crc_error)
			);
			defparam m_crcblock.oscillator_divider = EDCRC_OSC_DIVIDER;
		end
		else begin	// default to Stratix V
			stratixv_crcblock m_crcblock
			(
				.clk(clk),
				.shiftnld(1'b1),
				.crcerror(o_crc_error)
			);
			defparam m_crcblock.oscillator_divider = EDCRC_OSC_DIVIDER;
		end
	endgenerate
	
endmodule



