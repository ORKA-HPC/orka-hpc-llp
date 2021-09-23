// ------------------------------------------------------------------------- 
// High Level Design Compiler for Intel(R) FPGAs Version 21.1 (Release Build #173.3)
// 
// Legal Notice: Copyright 2021 Intel Corporation.  All rights reserved.
// Your use of  Intel Corporation's design tools,  logic functions and other
// software and  tools, and its AMPP partner logic functions, and any output
// files any  of the foregoing (including  device programming  or simulation
// files), and  any associated  documentation  or information  are expressly
// subject  to the terms and  conditions of the  Intel FPGA Software License
// Agreement, Intel MegaCore Function License Agreement, or other applicable
// license agreement,  including,  without limitation,  that your use is for
// the  sole  purpose of  programming  logic devices  manufactured by  Intel
// and  sold by Intel  or its authorized  distributors. Please refer  to the
// applicable agreement for further details.
// ---------------------------------------------------------------------------

// SystemVerilog created from slavereg_comp_bb_B3
// SystemVerilog created on Fri Apr 16 11:58:54 2021


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module slavereg_comp_bb_B3 (
    input wire [0:0] in_flush,
    input wire [0:0] in_forked_0,
    input wire [0:0] in_forked_1,
    input wire [31:0] in_intel_reserved_ffwd_0_0,
    input wire [31:0] in_intel_reserved_ffwd_1_0,
    input wire [63:0] in_intel_reserved_ffwd_2_0,
    input wire [63:0] in_intel_reserved_ffwd_4_0,
    input wire [63:0] in_intel_reserved_ffwd_5_0,
    input wire [32:0] in_intel_reserved_ffwd_6_0,
    input wire [511:0] in_lm1_slavereg_comp_avm_readdata,
    input wire [0:0] in_lm1_slavereg_comp_avm_readdatavalid,
    input wire [0:0] in_lm1_slavereg_comp_avm_waitrequest,
    input wire [0:0] in_lm1_slavereg_comp_avm_writeack,
    input wire [511:0] in_lm22_slavereg_comp_avm_readdata,
    input wire [0:0] in_lm22_slavereg_comp_avm_readdatavalid,
    input wire [0:0] in_lm22_slavereg_comp_avm_waitrequest,
    input wire [0:0] in_lm22_slavereg_comp_avm_writeack,
    input wire [511:0] in_memdep_5_slavereg_comp_avm_readdata,
    input wire [0:0] in_memdep_5_slavereg_comp_avm_readdatavalid,
    input wire [0:0] in_memdep_5_slavereg_comp_avm_waitrequest,
    input wire [0:0] in_memdep_5_slavereg_comp_avm_writeack,
    input wire [511:0] in_memdep_slavereg_comp_avm_readdata,
    input wire [0:0] in_memdep_slavereg_comp_avm_readdatavalid,
    input wire [0:0] in_memdep_slavereg_comp_avm_waitrequest,
    input wire [0:0] in_memdep_slavereg_comp_avm_writeack,
    input wire [0:0] in_stall_in_0,
    input wire [0:0] in_stall_in_1,
    input wire [0:0] in_valid_in_0,
    input wire [0:0] in_valid_in_1,
    output wire [0:0] out_exiting_stall_out,
    output wire [0:0] out_exiting_valid_out,
    output wire [31:0] out_lm1_slavereg_comp_avm_address,
    output wire [4:0] out_lm1_slavereg_comp_avm_burstcount,
    output wire [63:0] out_lm1_slavereg_comp_avm_byteenable,
    output wire [0:0] out_lm1_slavereg_comp_avm_enable,
    output wire [0:0] out_lm1_slavereg_comp_avm_read,
    output wire [0:0] out_lm1_slavereg_comp_avm_write,
    output wire [511:0] out_lm1_slavereg_comp_avm_writedata,
    output wire [31:0] out_lm22_slavereg_comp_avm_address,
    output wire [4:0] out_lm22_slavereg_comp_avm_burstcount,
    output wire [63:0] out_lm22_slavereg_comp_avm_byteenable,
    output wire [0:0] out_lm22_slavereg_comp_avm_enable,
    output wire [0:0] out_lm22_slavereg_comp_avm_read,
    output wire [0:0] out_lm22_slavereg_comp_avm_write,
    output wire [511:0] out_lm22_slavereg_comp_avm_writedata,
    output wire [0:0] out_lsu_memdep_5_o_active,
    output wire [0:0] out_lsu_memdep_o_active,
    output wire [31:0] out_memdep_5_slavereg_comp_avm_address,
    output wire [4:0] out_memdep_5_slavereg_comp_avm_burstcount,
    output wire [63:0] out_memdep_5_slavereg_comp_avm_byteenable,
    output wire [0:0] out_memdep_5_slavereg_comp_avm_enable,
    output wire [0:0] out_memdep_5_slavereg_comp_avm_read,
    output wire [0:0] out_memdep_5_slavereg_comp_avm_write,
    output wire [511:0] out_memdep_5_slavereg_comp_avm_writedata,
    output wire [31:0] out_memdep_slavereg_comp_avm_address,
    output wire [4:0] out_memdep_slavereg_comp_avm_burstcount,
    output wire [63:0] out_memdep_slavereg_comp_avm_byteenable,
    output wire [0:0] out_memdep_slavereg_comp_avm_enable,
    output wire [0:0] out_memdep_slavereg_comp_avm_read,
    output wire [0:0] out_memdep_slavereg_comp_avm_write,
    output wire [511:0] out_memdep_slavereg_comp_avm_writedata,
    output wire [0:0] out_stall_in_0,
    output wire [0:0] out_stall_out_0,
    output wire [0:0] out_stall_out_1,
    output wire [0:0] out_valid_in_0,
    output wire [0:0] out_valid_in_1,
    output wire [0:0] out_valid_out_0,
    output wire [0:0] out_valid_out_1,
    input wire [0:0] in_pipeline_stall_in,
    output wire [0:0] out_pipeline_valid_out,
    input wire clock,
    input wire resetn
    );

    wire [0:0] bb_slavereg_comp_B3_stall_region_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_stall_out;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_valid_out;
    wire [31:0] bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_address;
    wire [4:0] bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_burstcount;
    wire [63:0] bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_byteenable;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_enable;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_read;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_write;
    wire [511:0] bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_writedata;
    wire [31:0] bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_address;
    wire [4:0] bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_burstcount;
    wire [63:0] bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_byteenable;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_enable;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_read;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_write;
    wire [511:0] bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_writedata;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_lsu_memdep_5_o_active;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_lsu_memdep_o_active;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_masked;
    wire [31:0] bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_address;
    wire [4:0] bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_burstcount;
    wire [63:0] bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_byteenable;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_enable;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_read;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_write;
    wire [511:0] bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_writedata;
    wire [31:0] bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_address;
    wire [4:0] bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_burstcount;
    wire [63:0] bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_byteenable;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_enable;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_read;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_write;
    wire [511:0] bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_writedata;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_pipeline_valid_out;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_stall_out;
    wire [0:0] bb_slavereg_comp_B3_stall_region_out_valid_out;
    wire [0:0] slavereg_comp_B3_branch_out_stall_out;
    wire [0:0] slavereg_comp_B3_branch_out_valid_out_0;
    wire [0:0] slavereg_comp_B3_branch_out_valid_out_1;
    wire [0:0] slavereg_comp_B3_merge_out_forked;
    wire [0:0] slavereg_comp_B3_merge_out_stall_out_0;
    wire [0:0] slavereg_comp_B3_merge_out_stall_out_1;
    wire [0:0] slavereg_comp_B3_merge_out_valid_out;


    // slavereg_comp_B3_branch(BLACKBOX,73)
    slavereg_comp_B3_branch theslavereg_comp_B3_branch (
        .in_masked(bb_slavereg_comp_B3_stall_region_out_masked),
        .in_stall_in_0(in_stall_in_0),
        .in_stall_in_1(in_stall_in_1),
        .in_valid_in(bb_slavereg_comp_B3_stall_region_out_valid_out),
        .out_stall_out(slavereg_comp_B3_branch_out_stall_out),
        .out_valid_out_0(slavereg_comp_B3_branch_out_valid_out_0),
        .out_valid_out_1(slavereg_comp_B3_branch_out_valid_out_1),
        .clock(clock),
        .resetn(resetn)
    );

    // slavereg_comp_B3_merge(BLACKBOX,74)
    slavereg_comp_B3_merge theslavereg_comp_B3_merge (
        .in_forked_0(in_forked_0),
        .in_forked_1(in_forked_1),
        .in_stall_in(bb_slavereg_comp_B3_stall_region_out_stall_out),
        .in_valid_in_0(in_valid_in_0),
        .in_valid_in_1(in_valid_in_1),
        .out_forked(slavereg_comp_B3_merge_out_forked),
        .out_stall_out_0(slavereg_comp_B3_merge_out_stall_out_0),
        .out_stall_out_1(slavereg_comp_B3_merge_out_stall_out_1),
        .out_valid_out(slavereg_comp_B3_merge_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bb_slavereg_comp_B3_stall_region(BLACKBOX,2)
    slavereg_comp_bb_B3_stall_region thebb_slavereg_comp_B3_stall_region (
        .in_flush(in_flush),
        .in_forked(slavereg_comp_B3_merge_out_forked),
        .in_intel_reserved_ffwd_0_0(in_intel_reserved_ffwd_0_0),
        .in_intel_reserved_ffwd_1_0(in_intel_reserved_ffwd_1_0),
        .in_intel_reserved_ffwd_2_0(in_intel_reserved_ffwd_2_0),
        .in_intel_reserved_ffwd_4_0(in_intel_reserved_ffwd_4_0),
        .in_intel_reserved_ffwd_5_0(in_intel_reserved_ffwd_5_0),
        .in_intel_reserved_ffwd_6_0(in_intel_reserved_ffwd_6_0),
        .in_lm1_slavereg_comp_avm_readdata(in_lm1_slavereg_comp_avm_readdata),
        .in_lm1_slavereg_comp_avm_readdatavalid(in_lm1_slavereg_comp_avm_readdatavalid),
        .in_lm1_slavereg_comp_avm_waitrequest(in_lm1_slavereg_comp_avm_waitrequest),
        .in_lm1_slavereg_comp_avm_writeack(in_lm1_slavereg_comp_avm_writeack),
        .in_lm22_slavereg_comp_avm_readdata(in_lm22_slavereg_comp_avm_readdata),
        .in_lm22_slavereg_comp_avm_readdatavalid(in_lm22_slavereg_comp_avm_readdatavalid),
        .in_lm22_slavereg_comp_avm_waitrequest(in_lm22_slavereg_comp_avm_waitrequest),
        .in_lm22_slavereg_comp_avm_writeack(in_lm22_slavereg_comp_avm_writeack),
        .in_memdep_5_slavereg_comp_avm_readdata(in_memdep_5_slavereg_comp_avm_readdata),
        .in_memdep_5_slavereg_comp_avm_readdatavalid(in_memdep_5_slavereg_comp_avm_readdatavalid),
        .in_memdep_5_slavereg_comp_avm_waitrequest(in_memdep_5_slavereg_comp_avm_waitrequest),
        .in_memdep_5_slavereg_comp_avm_writeack(in_memdep_5_slavereg_comp_avm_writeack),
        .in_memdep_slavereg_comp_avm_readdata(in_memdep_slavereg_comp_avm_readdata),
        .in_memdep_slavereg_comp_avm_readdatavalid(in_memdep_slavereg_comp_avm_readdatavalid),
        .in_memdep_slavereg_comp_avm_waitrequest(in_memdep_slavereg_comp_avm_waitrequest),
        .in_memdep_slavereg_comp_avm_writeack(in_memdep_slavereg_comp_avm_writeack),
        .in_pipeline_stall_in(in_pipeline_stall_in),
        .in_stall_in(slavereg_comp_B3_branch_out_stall_out),
        .in_valid_in(slavereg_comp_B3_merge_out_valid_out),
        .out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_stall_out(bb_slavereg_comp_B3_stall_region_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_stall_out),
        .out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_valid_out(bb_slavereg_comp_B3_stall_region_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_valid_out),
        .out_lm1_slavereg_comp_avm_address(bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_address),
        .out_lm1_slavereg_comp_avm_burstcount(bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_burstcount),
        .out_lm1_slavereg_comp_avm_byteenable(bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_byteenable),
        .out_lm1_slavereg_comp_avm_enable(bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_enable),
        .out_lm1_slavereg_comp_avm_read(bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_read),
        .out_lm1_slavereg_comp_avm_write(bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_write),
        .out_lm1_slavereg_comp_avm_writedata(bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_writedata),
        .out_lm22_slavereg_comp_avm_address(bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_address),
        .out_lm22_slavereg_comp_avm_burstcount(bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_burstcount),
        .out_lm22_slavereg_comp_avm_byteenable(bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_byteenable),
        .out_lm22_slavereg_comp_avm_enable(bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_enable),
        .out_lm22_slavereg_comp_avm_read(bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_read),
        .out_lm22_slavereg_comp_avm_write(bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_write),
        .out_lm22_slavereg_comp_avm_writedata(bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_writedata),
        .out_lsu_memdep_5_o_active(bb_slavereg_comp_B3_stall_region_out_lsu_memdep_5_o_active),
        .out_lsu_memdep_o_active(bb_slavereg_comp_B3_stall_region_out_lsu_memdep_o_active),
        .out_masked(bb_slavereg_comp_B3_stall_region_out_masked),
        .out_memdep_5_slavereg_comp_avm_address(bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_address),
        .out_memdep_5_slavereg_comp_avm_burstcount(bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_burstcount),
        .out_memdep_5_slavereg_comp_avm_byteenable(bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_byteenable),
        .out_memdep_5_slavereg_comp_avm_enable(bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_enable),
        .out_memdep_5_slavereg_comp_avm_read(bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_read),
        .out_memdep_5_slavereg_comp_avm_write(bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_write),
        .out_memdep_5_slavereg_comp_avm_writedata(bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_writedata),
        .out_memdep_slavereg_comp_avm_address(bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_address),
        .out_memdep_slavereg_comp_avm_burstcount(bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_burstcount),
        .out_memdep_slavereg_comp_avm_byteenable(bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_byteenable),
        .out_memdep_slavereg_comp_avm_enable(bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_enable),
        .out_memdep_slavereg_comp_avm_read(bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_read),
        .out_memdep_slavereg_comp_avm_write(bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_write),
        .out_memdep_slavereg_comp_avm_writedata(bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_writedata),
        .out_pipeline_valid_out(bb_slavereg_comp_B3_stall_region_out_pipeline_valid_out),
        .out_stall_out(bb_slavereg_comp_B3_stall_region_out_stall_out),
        .out_valid_out(bb_slavereg_comp_B3_stall_region_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // out_exiting_stall_out(GPOUT,32)
    assign out_exiting_stall_out = bb_slavereg_comp_B3_stall_region_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_stall_out;

    // out_exiting_valid_out(GPOUT,33)
    assign out_exiting_valid_out = bb_slavereg_comp_B3_stall_region_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_valid_out;

    // out_lm1_slavereg_comp_avm_address(GPOUT,34)
    assign out_lm1_slavereg_comp_avm_address = bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_address;

    // out_lm1_slavereg_comp_avm_burstcount(GPOUT,35)
    assign out_lm1_slavereg_comp_avm_burstcount = bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_burstcount;

    // out_lm1_slavereg_comp_avm_byteenable(GPOUT,36)
    assign out_lm1_slavereg_comp_avm_byteenable = bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_byteenable;

    // out_lm1_slavereg_comp_avm_enable(GPOUT,37)
    assign out_lm1_slavereg_comp_avm_enable = bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_enable;

    // out_lm1_slavereg_comp_avm_read(GPOUT,38)
    assign out_lm1_slavereg_comp_avm_read = bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_read;

    // out_lm1_slavereg_comp_avm_write(GPOUT,39)
    assign out_lm1_slavereg_comp_avm_write = bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_write;

    // out_lm1_slavereg_comp_avm_writedata(GPOUT,40)
    assign out_lm1_slavereg_comp_avm_writedata = bb_slavereg_comp_B3_stall_region_out_lm1_slavereg_comp_avm_writedata;

    // out_lm22_slavereg_comp_avm_address(GPOUT,41)
    assign out_lm22_slavereg_comp_avm_address = bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_address;

    // out_lm22_slavereg_comp_avm_burstcount(GPOUT,42)
    assign out_lm22_slavereg_comp_avm_burstcount = bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_burstcount;

    // out_lm22_slavereg_comp_avm_byteenable(GPOUT,43)
    assign out_lm22_slavereg_comp_avm_byteenable = bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_byteenable;

    // out_lm22_slavereg_comp_avm_enable(GPOUT,44)
    assign out_lm22_slavereg_comp_avm_enable = bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_enable;

    // out_lm22_slavereg_comp_avm_read(GPOUT,45)
    assign out_lm22_slavereg_comp_avm_read = bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_read;

    // out_lm22_slavereg_comp_avm_write(GPOUT,46)
    assign out_lm22_slavereg_comp_avm_write = bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_write;

    // out_lm22_slavereg_comp_avm_writedata(GPOUT,47)
    assign out_lm22_slavereg_comp_avm_writedata = bb_slavereg_comp_B3_stall_region_out_lm22_slavereg_comp_avm_writedata;

    // out_lsu_memdep_5_o_active(GPOUT,48)
    assign out_lsu_memdep_5_o_active = bb_slavereg_comp_B3_stall_region_out_lsu_memdep_5_o_active;

    // out_lsu_memdep_o_active(GPOUT,49)
    assign out_lsu_memdep_o_active = bb_slavereg_comp_B3_stall_region_out_lsu_memdep_o_active;

    // out_memdep_5_slavereg_comp_avm_address(GPOUT,50)
    assign out_memdep_5_slavereg_comp_avm_address = bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_address;

    // out_memdep_5_slavereg_comp_avm_burstcount(GPOUT,51)
    assign out_memdep_5_slavereg_comp_avm_burstcount = bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_burstcount;

    // out_memdep_5_slavereg_comp_avm_byteenable(GPOUT,52)
    assign out_memdep_5_slavereg_comp_avm_byteenable = bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_byteenable;

    // out_memdep_5_slavereg_comp_avm_enable(GPOUT,53)
    assign out_memdep_5_slavereg_comp_avm_enable = bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_enable;

    // out_memdep_5_slavereg_comp_avm_read(GPOUT,54)
    assign out_memdep_5_slavereg_comp_avm_read = bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_read;

    // out_memdep_5_slavereg_comp_avm_write(GPOUT,55)
    assign out_memdep_5_slavereg_comp_avm_write = bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_write;

    // out_memdep_5_slavereg_comp_avm_writedata(GPOUT,56)
    assign out_memdep_5_slavereg_comp_avm_writedata = bb_slavereg_comp_B3_stall_region_out_memdep_5_slavereg_comp_avm_writedata;

    // out_memdep_slavereg_comp_avm_address(GPOUT,57)
    assign out_memdep_slavereg_comp_avm_address = bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_address;

    // out_memdep_slavereg_comp_avm_burstcount(GPOUT,58)
    assign out_memdep_slavereg_comp_avm_burstcount = bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_burstcount;

    // out_memdep_slavereg_comp_avm_byteenable(GPOUT,59)
    assign out_memdep_slavereg_comp_avm_byteenable = bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_byteenable;

    // out_memdep_slavereg_comp_avm_enable(GPOUT,60)
    assign out_memdep_slavereg_comp_avm_enable = bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_enable;

    // out_memdep_slavereg_comp_avm_read(GPOUT,61)
    assign out_memdep_slavereg_comp_avm_read = bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_read;

    // out_memdep_slavereg_comp_avm_write(GPOUT,62)
    assign out_memdep_slavereg_comp_avm_write = bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_write;

    // out_memdep_slavereg_comp_avm_writedata(GPOUT,63)
    assign out_memdep_slavereg_comp_avm_writedata = bb_slavereg_comp_B3_stall_region_out_memdep_slavereg_comp_avm_writedata;

    // out_stall_in_0(GPOUT,64)
    assign out_stall_in_0 = in_stall_in_0;

    // out_stall_out_0(GPOUT,65)
    assign out_stall_out_0 = slavereg_comp_B3_merge_out_stall_out_0;

    // out_stall_out_1(GPOUT,66)
    assign out_stall_out_1 = slavereg_comp_B3_merge_out_stall_out_1;

    // out_valid_in_0(GPOUT,67)
    assign out_valid_in_0 = in_valid_in_0;

    // out_valid_in_1(GPOUT,68)
    assign out_valid_in_1 = in_valid_in_1;

    // out_valid_out_0(GPOUT,69)
    assign out_valid_out_0 = slavereg_comp_B3_branch_out_valid_out_0;

    // out_valid_out_1(GPOUT,70)
    assign out_valid_out_1 = slavereg_comp_B3_branch_out_valid_out_1;

    // pipeline_valid_out_sync(GPOUT,72)
    assign out_pipeline_valid_out = bb_slavereg_comp_B3_stall_region_out_pipeline_valid_out;

endmodule
