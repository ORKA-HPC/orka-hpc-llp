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


// $Id: //acds/prototype/mm_s10/ip/merlin/altera_merlin_width_adapter/altera_merlin_width_adapter.sv#2 $
// $Revision: #2 $
// $Date: 2015/06/01 $
// $Author: nkrueger $

// -----------------------------------------------------
// Width Adapter
// -----------------------------------------------------

`timescale 1 ns / 1 ns
`default_nettype none

module alt_hiconnect_width_adapter
#(
    parameter IN_PKT_ADDR_L                 = 0,
    parameter IN_PKT_ADDR_H                 = 31,
    parameter IN_PKT_DATA_L                 = 32,
    parameter IN_PKT_DATA_H                 = 63,
    parameter IN_PKT_BYTEEN_L               = 64,
    parameter IN_PKT_BYTEEN_H               = 67,
    parameter IN_PKT_TRANS_COMPRESSED_READ  = 72,
    parameter IN_PKT_BYTE_CNT_L             = 73,
    parameter IN_PKT_BYTE_CNT_H             = 77,
    parameter IN_PKT_BURSTWRAP_L            = 78,
    parameter IN_PKT_BURSTWRAP_H            = 82,
    parameter IN_PKT_BURST_SIZE_L           = 83,
    parameter IN_PKT_BURST_SIZE_H           = 85,
    parameter IN_PKT_RESPONSE_STATUS_L      = 86,
    parameter IN_PKT_RESPONSE_STATUS_H      = 87,
    parameter IN_PKT_TRANS_EXCLUSIVE        = 88,
    parameter IN_PKT_BURST_TYPE_L           = 89,
    parameter IN_PKT_BURST_TYPE_H           = 90,
    parameter IN_PKT_ORI_BURST_SIZE_L       = 91,
    parameter IN_PKT_ORI_BURST_SIZE_H       = 93,
    parameter IN_PKT_TRANS_WRITE            = 94,
    parameter IN_ST_DATA_W                  = 110,

    parameter OUT_PKT_ADDR_L                = 0,
    parameter OUT_PKT_ADDR_H                = 31,
    parameter OUT_PKT_DATA_L                = 32,
    parameter OUT_PKT_DATA_H                = 47,
    parameter OUT_PKT_BYTEEN_L              = 48,
    parameter OUT_PKT_BYTEEN_H              = 49,
    parameter OUT_PKT_TRANS_COMPRESSED_READ = 54,
    parameter OUT_PKT_BYTE_CNT_L            = 55,
    parameter OUT_PKT_BYTE_CNT_H            = 59,
    parameter OUT_PKT_BURST_SIZE_L          = 60,
    parameter OUT_PKT_BURST_SIZE_H          = 62,
    parameter OUT_PKT_RESPONSE_STATUS_L     = 63,
    parameter OUT_PKT_RESPONSE_STATUS_H     = 64,
    parameter OUT_PKT_TRANS_EXCLUSIVE       = 65,
    parameter OUT_PKT_BURST_TYPE_L          = 66,
    parameter OUT_PKT_BURST_TYPE_H          = 67,
    parameter OUT_PKT_ORI_BURST_SIZE_L      = 68,
    parameter OUT_PKT_ORI_BURST_SIZE_H      = 70,
    parameter OUT_ST_DATA_W                 = 92,

    parameter ST_CHANNEL_W                  = 32,

    parameter RESPONSE_PATH                 = 0,    // 0: This adapter is on command path, 1: This adapter is on response path

    // Address alignment can be turned off (an optimisation) if all connected
    // masters only issue aligned addresses.
    parameter ENABLE_ADDRESS_ALIGNMENT      = 1,
    parameter CONSTANT_BURST_SIZE           = 1,    // 1: Optimizes for Avalon-only systems as those always have full size transactions

    parameter LOG_RATIO =     (IN_PKT_DATA_H-IN_PKT_DATA_L+1) > (OUT_PKT_DATA_H-OUT_PKT_DATA_L+1)
                          ?   $clog2 ((IN_PKT_DATA_H-IN_PKT_DATA_L+1)/(OUT_PKT_DATA_H-OUT_PKT_DATA_L+1)) // w2n
                          :   $clog2 ((OUT_PKT_DATA_H-OUT_PKT_DATA_L+1)/(IN_PKT_DATA_H-IN_PKT_DATA_L+1)) // n2w
)
( 
    input wire                       clk,
    input wire                       reset,
    
    output reg                       in_ready,
    input wire                       in_valid,
    input wire [ST_CHANNEL_W-1:0]    in_channel,
    input wire [IN_ST_DATA_W-1:0]    in_data,
    input wire                       in_startofpacket,
    input wire                       in_endofpacket,
    
    input wire                       out_ready,
    output reg                       out_valid,
    output reg [ST_CHANNEL_W-1:0]    out_channel,
    output reg [OUT_ST_DATA_W-1:0]   out_data,
    output reg                       out_startofpacket,
    output reg                       out_endofpacket,

    output wire [2*LOG_RATIO-1:0]    out_cmd_shamt_data,
    output wire                      out_cmd_shamt_valid, // ~empty
    input  wire                      out_cmd_shamt_ready, // read

    input  wire [2*LOG_RATIO-1:0]    in_rsp_shamt_data,
    input  wire                      in_rsp_shamt_valid, // ~empty
    output wire                      in_rsp_shamt_ready  // read

   
);

    // For shared derived parameters, including pseudo-field parameters and helper functions
    `include "alt_hiconnect_width_adapter_utils.iv"
    
    // synthesis translate_off
    initial begin
        assert (IN_NUMSYMBOLS != OUT_NUMSYMBOLS) else $fatal("No width adapter needed, IN_NUMSYMBOLS == OUT_NUMSYMBOLS");
    end
    // synthesis translate_on

    // Width adapter IMPL instantiations
    generate if ((RESPONSE_PATH == 0) && (IN_NUMSYMBOLS > OUT_NUMSYMBOLS)) begin : w2n_cmd_gen
            alt_hiconnect_w2n_cmd_width_adapter #(
                .IN_PKT_ADDR_L(IN_PKT_ADDR_L),
                .IN_PKT_ADDR_H(IN_PKT_ADDR_H),
                .IN_PKT_DATA_L(IN_PKT_DATA_L),
                .IN_PKT_DATA_H(IN_PKT_DATA_H),
                .IN_PKT_BYTEEN_L(IN_PKT_BYTEEN_L),
                .IN_PKT_BYTEEN_H(IN_PKT_BYTEEN_H),
                .IN_PKT_TRANS_COMPRESSED_READ(IN_PKT_TRANS_COMPRESSED_READ),
                .IN_PKT_BYTE_CNT_L(IN_PKT_BYTE_CNT_L),
                .IN_PKT_BYTE_CNT_H(IN_PKT_BYTE_CNT_H),
                .IN_PKT_BURSTWRAP_L(IN_PKT_BURSTWRAP_L),
                .IN_PKT_BURSTWRAP_H(IN_PKT_BURSTWRAP_H),
                .IN_PKT_BURST_SIZE_L(IN_PKT_BURST_SIZE_L),
                .IN_PKT_BURST_SIZE_H(IN_PKT_BURST_SIZE_H),
                .IN_PKT_RESPONSE_STATUS_L(IN_PKT_RESPONSE_STATUS_L),
                .IN_PKT_RESPONSE_STATUS_H(IN_PKT_RESPONSE_STATUS_H),
                .IN_PKT_TRANS_EXCLUSIVE(IN_PKT_TRANS_EXCLUSIVE),
                .IN_PKT_BURST_TYPE_L(IN_PKT_BURST_TYPE_L),
                .IN_PKT_BURST_TYPE_H(IN_PKT_BURST_TYPE_H),
                .IN_PKT_ORI_BURST_SIZE_L(IN_PKT_ORI_BURST_SIZE_L),
                .IN_PKT_ORI_BURST_SIZE_H(IN_PKT_ORI_BURST_SIZE_H),
                .IN_PKT_TRANS_WRITE(IN_PKT_TRANS_WRITE),
                .IN_ST_DATA_W(IN_ST_DATA_W),
                .OUT_PKT_ADDR_L(OUT_PKT_ADDR_L),
                .OUT_PKT_ADDR_H(OUT_PKT_ADDR_H),
                .OUT_PKT_DATA_L(OUT_PKT_DATA_L),
                .OUT_PKT_DATA_H(OUT_PKT_DATA_H),
                .OUT_PKT_BYTEEN_L(OUT_PKT_BYTEEN_L),
                .OUT_PKT_BYTEEN_H(OUT_PKT_BYTEEN_H),
                .OUT_PKT_TRANS_COMPRESSED_READ(OUT_PKT_TRANS_COMPRESSED_READ),
                .OUT_PKT_BYTE_CNT_L(OUT_PKT_BYTE_CNT_L),
                .OUT_PKT_BYTE_CNT_H(OUT_PKT_BYTE_CNT_H),
                .OUT_PKT_BURST_SIZE_L(OUT_PKT_BURST_SIZE_L),
                .OUT_PKT_BURST_SIZE_H(OUT_PKT_BURST_SIZE_H),
                .OUT_PKT_RESPONSE_STATUS_L(OUT_PKT_RESPONSE_STATUS_L),
                .OUT_PKT_RESPONSE_STATUS_H(OUT_PKT_RESPONSE_STATUS_H),
                .OUT_PKT_TRANS_EXCLUSIVE(OUT_PKT_TRANS_EXCLUSIVE),
                .OUT_PKT_BURST_TYPE_L(OUT_PKT_BURST_TYPE_L),
                .OUT_PKT_BURST_TYPE_H(OUT_PKT_BURST_TYPE_H),
                .OUT_PKT_ORI_BURST_SIZE_L(OUT_PKT_ORI_BURST_SIZE_L),
                .OUT_PKT_ORI_BURST_SIZE_H(OUT_PKT_ORI_BURST_SIZE_H),
                .OUT_ST_DATA_W(OUT_ST_DATA_W),
                .ST_CHANNEL_W(ST_CHANNEL_W),
                .ENABLE_ADDRESS_ALIGNMENT(ENABLE_ADDRESS_ALIGNMENT),
                .CONSTANT_BURST_SIZE(CONSTANT_BURST_SIZE)
            ) w2n_cmd_wa_inst (
                .clk(clk),
                .reset(reset),
                .in_ready(in_ready),
                .in_valid(in_valid),
                .in_channel(in_channel),
                .in_data(in_data),
                .in_startofpacket(in_startofpacket),
                .in_endofpacket(in_endofpacket),
                .out_ready(out_ready),
                .out_valid(out_valid),
                .out_channel(out_channel),
                .out_data(out_data),
                .out_startofpacket(out_startofpacket),
                .out_endofpacket(out_endofpacket),
                .out_cmd_shamt_data(out_cmd_shamt_data),
                .out_cmd_shamt_valid(out_cmd_shamt_valid),
                .out_cmd_shamt_ready(out_cmd_shamt_ready)
            );
        end else if((RESPONSE_PATH == 0) && (OUT_NUMSYMBOLS > IN_NUMSYMBOLS)) begin : n2w_cmd_gen
            alt_hiconnect_n2w_cmd_width_adapter #(
                .IN_PKT_ADDR_L(IN_PKT_ADDR_L),
                .IN_PKT_ADDR_H(IN_PKT_ADDR_H),
                .IN_PKT_DATA_L(IN_PKT_DATA_L),
                .IN_PKT_DATA_H(IN_PKT_DATA_H),
                .IN_PKT_BYTEEN_L(IN_PKT_BYTEEN_L),
                .IN_PKT_BYTEEN_H(IN_PKT_BYTEEN_H),
                .IN_PKT_TRANS_COMPRESSED_READ(IN_PKT_TRANS_COMPRESSED_READ),
                .IN_PKT_BYTE_CNT_L(IN_PKT_BYTE_CNT_L),
                .IN_PKT_BYTE_CNT_H(IN_PKT_BYTE_CNT_H),
                .IN_PKT_BURSTWRAP_L(IN_PKT_BURSTWRAP_L),
                .IN_PKT_BURSTWRAP_H(IN_PKT_BURSTWRAP_H),
                .IN_PKT_BURST_SIZE_L(IN_PKT_BURST_SIZE_L),
                .IN_PKT_BURST_SIZE_H(IN_PKT_BURST_SIZE_H),
                .IN_PKT_RESPONSE_STATUS_L(IN_PKT_RESPONSE_STATUS_L),
                .IN_PKT_RESPONSE_STATUS_H(IN_PKT_RESPONSE_STATUS_H),
                .IN_PKT_TRANS_EXCLUSIVE(IN_PKT_TRANS_EXCLUSIVE),
                .IN_PKT_BURST_TYPE_L(IN_PKT_BURST_TYPE_L),
                .IN_PKT_BURST_TYPE_H(IN_PKT_BURST_TYPE_H),
                .IN_PKT_ORI_BURST_SIZE_L(IN_PKT_ORI_BURST_SIZE_L),
                .IN_PKT_ORI_BURST_SIZE_H(IN_PKT_ORI_BURST_SIZE_H),
                .IN_PKT_TRANS_WRITE(IN_PKT_TRANS_WRITE),
                .IN_ST_DATA_W(IN_ST_DATA_W),
                .OUT_PKT_ADDR_L(OUT_PKT_ADDR_L),
                .OUT_PKT_ADDR_H(OUT_PKT_ADDR_H),
                .OUT_PKT_DATA_L(OUT_PKT_DATA_L),
                .OUT_PKT_DATA_H(OUT_PKT_DATA_H),
                .OUT_PKT_BYTEEN_L(OUT_PKT_BYTEEN_L),
                .OUT_PKT_BYTEEN_H(OUT_PKT_BYTEEN_H),
                .OUT_PKT_TRANS_COMPRESSED_READ(OUT_PKT_TRANS_COMPRESSED_READ),
                .OUT_PKT_BYTE_CNT_L(OUT_PKT_BYTE_CNT_L),
                .OUT_PKT_BYTE_CNT_H(OUT_PKT_BYTE_CNT_H),
                .OUT_PKT_BURST_SIZE_L(OUT_PKT_BURST_SIZE_L),
                .OUT_PKT_BURST_SIZE_H(OUT_PKT_BURST_SIZE_H),
                .OUT_PKT_RESPONSE_STATUS_L(OUT_PKT_RESPONSE_STATUS_L),
                .OUT_PKT_RESPONSE_STATUS_H(OUT_PKT_RESPONSE_STATUS_H),
                .OUT_PKT_TRANS_EXCLUSIVE(OUT_PKT_TRANS_EXCLUSIVE),
                .OUT_PKT_BURST_TYPE_L(OUT_PKT_BURST_TYPE_L),
                .OUT_PKT_BURST_TYPE_H(OUT_PKT_BURST_TYPE_H),
                .OUT_PKT_ORI_BURST_SIZE_L(OUT_PKT_ORI_BURST_SIZE_L),
                .OUT_PKT_ORI_BURST_SIZE_H(OUT_PKT_ORI_BURST_SIZE_H),
                .OUT_ST_DATA_W(OUT_ST_DATA_W),
                .ST_CHANNEL_W(ST_CHANNEL_W),
                .ENABLE_ADDRESS_ALIGNMENT(ENABLE_ADDRESS_ALIGNMENT),
                .CONSTANT_BURST_SIZE(CONSTANT_BURST_SIZE)
            ) n2w_cmd_wa_inst (
                .clk(clk),
                .reset(reset),
                .in_ready(in_ready),
                .in_valid(in_valid),
                .in_channel(in_channel),
                .in_data(in_data),
                .in_startofpacket(in_startofpacket),
                .in_endofpacket(in_endofpacket),
                .out_ready(out_ready),
                .out_valid(out_valid),
                .out_channel(out_channel),
                .out_data(out_data),
                .out_startofpacket(out_startofpacket),
                .out_endofpacket(out_endofpacket),
                .out_cmd_shamt_data(out_cmd_shamt_data),
                .out_cmd_shamt_valid(out_cmd_shamt_valid),
                .out_cmd_shamt_ready(out_cmd_shamt_ready)
               
            );        
        end else if((RESPONSE_PATH == 1) && (IN_NUMSYMBOLS > OUT_NUMSYMBOLS)) begin : w2n_rsp_gen
            alt_hiconnect_w2n_rsp_width_adapter #(
                .IN_PKT_ADDR_L(IN_PKT_ADDR_L),
                .IN_PKT_ADDR_H(IN_PKT_ADDR_H),
                .IN_PKT_DATA_L(IN_PKT_DATA_L),
                .IN_PKT_DATA_H(IN_PKT_DATA_H),
                .IN_PKT_BYTEEN_L(IN_PKT_BYTEEN_L),
                .IN_PKT_BYTEEN_H(IN_PKT_BYTEEN_H),
                .IN_PKT_TRANS_COMPRESSED_READ(IN_PKT_TRANS_COMPRESSED_READ),
                .IN_PKT_BYTE_CNT_L(IN_PKT_BYTE_CNT_L),
                .IN_PKT_BYTE_CNT_H(IN_PKT_BYTE_CNT_H),
                .IN_PKT_BURSTWRAP_L(IN_PKT_BURSTWRAP_L),
                .IN_PKT_BURSTWRAP_H(IN_PKT_BURSTWRAP_H),
                .IN_PKT_BURST_SIZE_L(IN_PKT_BURST_SIZE_L),
                .IN_PKT_BURST_SIZE_H(IN_PKT_BURST_SIZE_H),
                .IN_PKT_RESPONSE_STATUS_L(IN_PKT_RESPONSE_STATUS_L),
                .IN_PKT_RESPONSE_STATUS_H(IN_PKT_RESPONSE_STATUS_H),
                .IN_PKT_TRANS_EXCLUSIVE(IN_PKT_TRANS_EXCLUSIVE),
                .IN_PKT_BURST_TYPE_L(IN_PKT_BURST_TYPE_L),
                .IN_PKT_BURST_TYPE_H(IN_PKT_BURST_TYPE_H),
                .IN_PKT_ORI_BURST_SIZE_L(IN_PKT_ORI_BURST_SIZE_L),
                .IN_PKT_ORI_BURST_SIZE_H(IN_PKT_ORI_BURST_SIZE_H),
                .IN_PKT_TRANS_WRITE(IN_PKT_TRANS_WRITE),
                .IN_ST_DATA_W(IN_ST_DATA_W),
                .OUT_PKT_ADDR_L(OUT_PKT_ADDR_L),
                .OUT_PKT_ADDR_H(OUT_PKT_ADDR_H),
                .OUT_PKT_DATA_L(OUT_PKT_DATA_L),
                .OUT_PKT_DATA_H(OUT_PKT_DATA_H),
                .OUT_PKT_BYTEEN_L(OUT_PKT_BYTEEN_L),
                .OUT_PKT_BYTEEN_H(OUT_PKT_BYTEEN_H),
                .OUT_PKT_TRANS_COMPRESSED_READ(OUT_PKT_TRANS_COMPRESSED_READ),
                .OUT_PKT_BYTE_CNT_L(OUT_PKT_BYTE_CNT_L),
                .OUT_PKT_BYTE_CNT_H(OUT_PKT_BYTE_CNT_H),
                .OUT_PKT_BURST_SIZE_L(OUT_PKT_BURST_SIZE_L),
                .OUT_PKT_BURST_SIZE_H(OUT_PKT_BURST_SIZE_H),
                .OUT_PKT_RESPONSE_STATUS_L(OUT_PKT_RESPONSE_STATUS_L),
                .OUT_PKT_RESPONSE_STATUS_H(OUT_PKT_RESPONSE_STATUS_H),
                .OUT_PKT_TRANS_EXCLUSIVE(OUT_PKT_TRANS_EXCLUSIVE),
                .OUT_PKT_BURST_TYPE_L(OUT_PKT_BURST_TYPE_L),
                .OUT_PKT_BURST_TYPE_H(OUT_PKT_BURST_TYPE_H),
                .OUT_PKT_ORI_BURST_SIZE_L(OUT_PKT_ORI_BURST_SIZE_L),
                .OUT_PKT_ORI_BURST_SIZE_H(OUT_PKT_ORI_BURST_SIZE_H),
                .OUT_ST_DATA_W(OUT_ST_DATA_W),
                .ST_CHANNEL_W(ST_CHANNEL_W),
                .ENABLE_ADDRESS_ALIGNMENT(ENABLE_ADDRESS_ALIGNMENT),
                .CONSTANT_BURST_SIZE(CONSTANT_BURST_SIZE)
            ) w2n_rsp_wa_inst (
                .clk(clk),
                .reset(reset),
                .in_ready(in_ready),
                .in_valid(in_valid),
                .in_channel(in_channel),
                .in_data(in_data),
                .in_startofpacket(in_startofpacket),
                .in_endofpacket(in_endofpacket),
                .out_ready(out_ready),
                .out_valid(out_valid),
                .out_channel(out_channel),
                .out_data(out_data),
                .out_startofpacket(out_startofpacket),
                .out_endofpacket(out_endofpacket),
                .in_rsp_shamt_data(in_rsp_shamt_data),
                .in_rsp_shamt_valid(in_rsp_shamt_valid),
                .in_rsp_shamt_ready(in_rsp_shamt_ready)
            );        
        end else if((RESPONSE_PATH == 1) && (OUT_NUMSYMBOLS > IN_NUMSYMBOLS)) begin : n2w_rsp_gen
            alt_hiconnect_n2w_rsp_width_adapter #(
                .IN_PKT_ADDR_L(IN_PKT_ADDR_L),
                .IN_PKT_ADDR_H(IN_PKT_ADDR_H),
                .IN_PKT_DATA_L(IN_PKT_DATA_L),
                .IN_PKT_DATA_H(IN_PKT_DATA_H),
                .IN_PKT_BYTEEN_L(IN_PKT_BYTEEN_L),
                .IN_PKT_BYTEEN_H(IN_PKT_BYTEEN_H),
                .IN_PKT_TRANS_COMPRESSED_READ(IN_PKT_TRANS_COMPRESSED_READ),
                .IN_PKT_BYTE_CNT_L(IN_PKT_BYTE_CNT_L),
                .IN_PKT_BYTE_CNT_H(IN_PKT_BYTE_CNT_H),
                .IN_PKT_BURSTWRAP_L(IN_PKT_BURSTWRAP_L),
                .IN_PKT_BURSTWRAP_H(IN_PKT_BURSTWRAP_H),
                .IN_PKT_BURST_SIZE_L(IN_PKT_BURST_SIZE_L),
                .IN_PKT_BURST_SIZE_H(IN_PKT_BURST_SIZE_H),
                .IN_PKT_RESPONSE_STATUS_L(IN_PKT_RESPONSE_STATUS_L),
                .IN_PKT_RESPONSE_STATUS_H(IN_PKT_RESPONSE_STATUS_H),
                .IN_PKT_TRANS_EXCLUSIVE(IN_PKT_TRANS_EXCLUSIVE),
                .IN_PKT_BURST_TYPE_L(IN_PKT_BURST_TYPE_L),
                .IN_PKT_BURST_TYPE_H(IN_PKT_BURST_TYPE_H),
                .IN_PKT_ORI_BURST_SIZE_L(IN_PKT_ORI_BURST_SIZE_L),
                .IN_PKT_ORI_BURST_SIZE_H(IN_PKT_ORI_BURST_SIZE_H),
                .IN_PKT_TRANS_WRITE(IN_PKT_TRANS_WRITE),
                .IN_ST_DATA_W(IN_ST_DATA_W),
                .OUT_PKT_ADDR_L(OUT_PKT_ADDR_L),
                .OUT_PKT_ADDR_H(OUT_PKT_ADDR_H),
                .OUT_PKT_DATA_L(OUT_PKT_DATA_L),
                .OUT_PKT_DATA_H(OUT_PKT_DATA_H),
                .OUT_PKT_BYTEEN_L(OUT_PKT_BYTEEN_L),
                .OUT_PKT_BYTEEN_H(OUT_PKT_BYTEEN_H),
                .OUT_PKT_TRANS_COMPRESSED_READ(OUT_PKT_TRANS_COMPRESSED_READ),
                .OUT_PKT_BYTE_CNT_L(OUT_PKT_BYTE_CNT_L),
                .OUT_PKT_BYTE_CNT_H(OUT_PKT_BYTE_CNT_H),
                .OUT_PKT_BURST_SIZE_L(OUT_PKT_BURST_SIZE_L),
                .OUT_PKT_BURST_SIZE_H(OUT_PKT_BURST_SIZE_H),
                .OUT_PKT_RESPONSE_STATUS_L(OUT_PKT_RESPONSE_STATUS_L),
                .OUT_PKT_RESPONSE_STATUS_H(OUT_PKT_RESPONSE_STATUS_H),
                .OUT_PKT_TRANS_EXCLUSIVE(OUT_PKT_TRANS_EXCLUSIVE),
                .OUT_PKT_BURST_TYPE_L(OUT_PKT_BURST_TYPE_L),
                .OUT_PKT_BURST_TYPE_H(OUT_PKT_BURST_TYPE_H),
                .OUT_PKT_ORI_BURST_SIZE_L(OUT_PKT_ORI_BURST_SIZE_L),
                .OUT_PKT_ORI_BURST_SIZE_H(OUT_PKT_ORI_BURST_SIZE_H),
                .OUT_ST_DATA_W(OUT_ST_DATA_W),
                .ST_CHANNEL_W(ST_CHANNEL_W),
                .ENABLE_ADDRESS_ALIGNMENT(ENABLE_ADDRESS_ALIGNMENT),
                .CONSTANT_BURST_SIZE(CONSTANT_BURST_SIZE)
            ) n2w_rsp_wa_inst (
                .clk(clk),
                .reset(reset),
                .in_ready(in_ready),
                .in_valid(in_valid),
                .in_channel(in_channel),
                .in_data(in_data),
                .in_startofpacket(in_startofpacket),
                .in_endofpacket(in_endofpacket),
                .out_ready(out_ready),
                .out_valid(out_valid),
                .out_channel(out_channel),
                .out_data(out_data),
                .out_startofpacket(out_startofpacket),
                .out_endofpacket(out_endofpacket),
                .in_rsp_shamt_data(in_rsp_shamt_data),
                .in_rsp_shamt_valid(in_rsp_shamt_valid),
                .in_rsp_shamt_ready(in_rsp_shamt_ready)
            );        
        end
    endgenerate

endmodule // width_adapter

`default_nettype wire
