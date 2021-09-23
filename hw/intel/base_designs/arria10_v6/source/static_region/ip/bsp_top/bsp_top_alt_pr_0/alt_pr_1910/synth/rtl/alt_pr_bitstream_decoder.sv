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
module alt_pr_bitstream_decoder#(
    parameter DATA_WIDTH                    = 16, // Supports 16 only if enhanced compression is enabled.
    parameter ENABLE_ENHANCED_DECOMPRESSION = 0
) (
    input  logic                   clk,
    input  logic                   nreset,

    input  logic                   sink_valid,
    input  logic[DATA_WIDTH - 1:0] sink_data,
    output logic                   sink_ready,

    output logic                   source_valid,
    output logic[DATA_WIDTH - 1:0] source_data,
    input  logic                   source_ready
);
    generate
        if (ENABLE_ENHANCED_DECOMPRESSION) begin
            logic stage1_valid;
            logic[DATA_WIDTH - 1:0] state1_data;
            logic stage1_ready;

            logic is_enhanced_compressed_bitstream;

            alt_pr_enhanced_compression_magic_words_decoder_and_suppressor#(
                .DATA_WIDTH(DATA_WIDTH)
            ) alt_pr_enhanced_compression_magic_words_decoder_and_suppressor (
                .clk(clk),
                .nreset(nreset),

                .sink_valid(sink_valid),
                .sink_data(sink_data),
                .sink_ready(sink_ready),

                .source_valid(stage1_valid),
                .source_data(state1_data),
                .source_ready(stage1_ready),

                .is_enhanced_compressed_bitstream(is_enhanced_compressed_bitstream)
            );

            alt_pr_enhanced_decompressor#(
                .DATA_WIDTH(DATA_WIDTH)
            ) alt_pr_enhanced_decompressor (
                .clk(clk),
                .nreset(nreset),

                .enable(is_enhanced_compressed_bitstream),

                .sink_valid(stage1_valid),
                .sink_data(state1_data),
                .sink_ready(stage1_ready),

                .source_valid(source_valid),
                .source_data(source_data),
                .source_ready(source_ready)
            );
        end else begin
            assign sink_ready = source_ready;

            assign source_valid = sink_valid;
            assign source_data = sink_data;
        end
    endgenerate
endmodule
