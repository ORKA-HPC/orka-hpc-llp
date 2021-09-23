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
// TODO Support a data width of 32 too.
module alt_pr_enhanced_compression_magic_words_decoder_and_suppressor#(
    parameter DATA_WIDTH = 16 // Supports 16 only.
) (
    input  logic                   clk,
    input  logic                   nreset,

    input  logic                   sink_valid,
    input  logic[DATA_WIDTH - 1:0] sink_data,
    output logic                   sink_ready,

    output logic                   source_valid,
    output logic[DATA_WIDTH - 1:0] source_data,
    input  logic                   source_ready,

    output logic                   is_enhanced_compressed_bitstream
);
    typedef enum logic[2:0] {
        ACCEPT_WORD0 = 3'h0,
        ACCEPT_WORD1 = 3'h1,
        PASS_THROUGH_WORD0 = 3'h2,
        PASS_THROUGH_WORD1 = 3'h3,
        PASS_THROUGH = 3'h4
    } state_e;

    state_e state;
    logic is_enhanced_compressed_bitstream_w;
    logic[15:0] word0_buffer;
    logic[15:0] word1_buffer;

    always_ff @(posedge clk) begin
        if (~nreset) begin
            state <= ACCEPT_WORD0;
        end else begin
            if ((state == ACCEPT_WORD0) & sink_valid & sink_ready) begin
                state <= ACCEPT_WORD1;
            end else if ((state == ACCEPT_WORD1) & sink_valid & sink_ready) begin
                if (is_enhanced_compressed_bitstream_w) begin
                    state <= PASS_THROUGH;
                end else begin
                    state <= PASS_THROUGH_WORD0;
                end
            end else if ((state == PASS_THROUGH_WORD0) & source_valid & source_ready) begin
                state <= PASS_THROUGH_WORD1;
            end else if ((state == PASS_THROUGH_WORD1) & source_valid & source_ready) begin
                state <= PASS_THROUGH;
            end
        end
    end

    // These are only valid the moment `word1` is accepted.
    assign is_enhanced_compressed_bitstream_w = {word0_buffer, sink_data} >> 1 == 32'h0200_0000 >> 1;

    always_ff @(posedge clk) begin
        if (~nreset) begin
            is_enhanced_compressed_bitstream <= 1'b0;
        end else begin
            if ((state == ACCEPT_WORD1) & sink_valid & sink_ready) begin
                is_enhanced_compressed_bitstream <= is_enhanced_compressed_bitstream_w;
            end
        end
    end

    always_ff @(posedge clk) begin
        if ((state == ACCEPT_WORD0) & sink_valid) begin
            word0_buffer <= sink_data;
        end
    end

    always_ff @(posedge clk) begin
        if ((state == ACCEPT_WORD1) & sink_valid) begin
            word1_buffer <= sink_data;
        end
    end

    assign sink_ready = (state == PASS_THROUGH) ? source_ready : ((state == ACCEPT_WORD0) | (state == ACCEPT_WORD1));

    assign source_valid = (state == PASS_THROUGH) ? sink_valid : ((state == PASS_THROUGH_WORD0) | (state == PASS_THROUGH_WORD1));
    assign source_data = (state == PASS_THROUGH_WORD0) ? word0_buffer : ((state == PASS_THROUGH_WORD1) ? word1_buffer : sink_data);
endmodule
