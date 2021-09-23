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

// SystemVerilog created from slavereg_comp_bb_B2_stall_region
// SystemVerilog created on Fri Apr 16 11:58:54 2021


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module slavereg_comp_bb_B2_stall_region (
    output wire [127:0] out_iowr_nb_return_slavereg_comp_o_fifodata,
    output wire [0:0] out_iowr_nb_return_slavereg_comp_o_fifovalid,
    output wire [0:0] out_feedback_out_1,
    input wire [0:0] in_feedback_stall_in_1,
    output wire [0:0] out_feedback_valid_out_1,
    input wire [31:0] in_intel_reserved_ffwd_0_0,
    input wire [31:0] in_intel_reserved_ffwd_1_0,
    input wire [31:0] in_intel_reserved_ffwd_3_0,
    input wire [0:0] in_stall_in,
    output wire [0:0] out_stall_out,
    input wire [0:0] in_valid_in,
    output wire [0:0] out_valid_out,
    input wire clock,
    input wire resetn
    );

    wire [31:0] c_i32_5390346467_q;
    wire [31:0] i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_out_dest_data_out_0_0;
    wire [0:0] i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_out_valid_out;
    wire [31:0] i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_out_dest_data_out_3_0;
    wire [0:0] i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_out_valid_out;
    wire [31:0] i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_out_dest_data_out_1_0;
    wire [0:0] i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_out_valid_out;
    wire [0:0] i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_feedback_out_1;
    wire [0:0] i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_feedback_valid_out_1;
    wire [0:0] i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_stall_out;
    wire [0:0] i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_valid_out;
    wire [127:0] i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_iowr_nb_return_slavereg_comp_o_fifodata;
    wire [0:0] i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_iowr_nb_return_slavereg_comp_o_fifovalid;
    wire [0:0] i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_o_ack;
    wire [0:0] i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_o_stall;
    wire [0:0] i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_o_valid;
    wire [31:0] bubble_join_i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_q;
    wire [31:0] bubble_select_i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_b;
    wire [31:0] bubble_join_i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_q;
    wire [31:0] bubble_select_i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_b;
    wire [31:0] bubble_join_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_q;
    wire [31:0] bubble_select_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_b;
    wire [0:0] bubble_join_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_q;
    wire [0:0] bubble_select_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_b;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_and0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_and1;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_or0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_V0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_V1;
    wire [0:0] SE_out_i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_backStall;
    wire [0:0] SE_stall_entry_wireValid;
    wire [0:0] SE_stall_entry_wireStall;
    wire [0:0] SE_stall_entry_StallValid;
    wire [0:0] SE_stall_entry_toReg0;
    reg [0:0] SE_stall_entry_fromReg0;
    wire [0:0] SE_stall_entry_consumed0;
    wire [0:0] SE_stall_entry_toReg1;
    reg [0:0] SE_stall_entry_fromReg1;
    wire [0:0] SE_stall_entry_consumed1;
    wire [0:0] SE_stall_entry_toReg2;
    reg [0:0] SE_stall_entry_fromReg2;
    wire [0:0] SE_stall_entry_consumed2;
    wire [0:0] SE_stall_entry_or0;
    wire [0:0] SE_stall_entry_or1;
    wire [0:0] SE_stall_entry_backStall;
    wire [0:0] SE_stall_entry_V0;
    wire [0:0] SE_stall_entry_V1;
    wire [0:0] SE_stall_entry_V2;
    wire [0:0] SE_out_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_wireValid;
    wire [0:0] SE_out_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_backStall;
    wire [0:0] SE_out_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_V0;


    // i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2(BLACKBOX,10)@0
    // in in_stall_in@20000000
    // out out_dest_data_out_3_0@1
    // out out_stall_out@20000000
    // out out_valid_out@1
    slavereg_comp_i_llvm_fpga_ffwd_dest_i32_0000ed_11_slavereg_comp0 thei_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2 (
        .in_intel_reserved_ffwd_3_0(in_intel_reserved_ffwd_3_0),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_backStall),
        .in_valid_in(SE_stall_entry_V1),
        .out_dest_data_out_3_0(i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_out_dest_data_out_3_0),
        .out_stall_out(i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0(BLACKBOX,9)@0
    // in in_stall_in@20000000
    // out out_dest_data_out_0_0@1
    // out out_stall_out@20000000
    // out out_valid_out@1
    slavereg_comp_i_llvm_fpga_ffwd_dest_i32_index679_0 thei_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0 (
        .in_intel_reserved_ffwd_0_0(in_intel_reserved_ffwd_0_0),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_backStall),
        .in_valid_in(SE_stall_entry_V0),
        .out_dest_data_out_0_0(i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_out_dest_data_out_0_0),
        .out_stall_out(i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_stall_entry(STALLENABLE,59)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_stall_entry_fromReg0 <= '0;
            SE_stall_entry_fromReg1 <= '0;
            SE_stall_entry_fromReg2 <= '0;
        end
        else
        begin
            // Successor 0
            SE_stall_entry_fromReg0 <= SE_stall_entry_toReg0;
            // Successor 1
            SE_stall_entry_fromReg1 <= SE_stall_entry_toReg1;
            // Successor 2
            SE_stall_entry_fromReg2 <= SE_stall_entry_toReg2;
        end
    end
    // Input Stall processing
    assign SE_stall_entry_consumed0 = (~ (i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_out_stall_out) & SE_stall_entry_wireValid) | SE_stall_entry_fromReg0;
    assign SE_stall_entry_consumed1 = (~ (i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_out_stall_out) & SE_stall_entry_wireValid) | SE_stall_entry_fromReg1;
    assign SE_stall_entry_consumed2 = (~ (i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_out_stall_out) & SE_stall_entry_wireValid) | SE_stall_entry_fromReg2;
    // Consuming
    assign SE_stall_entry_StallValid = SE_stall_entry_backStall & SE_stall_entry_wireValid;
    assign SE_stall_entry_toReg0 = SE_stall_entry_StallValid & SE_stall_entry_consumed0;
    assign SE_stall_entry_toReg1 = SE_stall_entry_StallValid & SE_stall_entry_consumed1;
    assign SE_stall_entry_toReg2 = SE_stall_entry_StallValid & SE_stall_entry_consumed2;
    // Backward Stall generation
    assign SE_stall_entry_or0 = SE_stall_entry_consumed0;
    assign SE_stall_entry_or1 = SE_stall_entry_consumed1 & SE_stall_entry_or0;
    assign SE_stall_entry_wireStall = ~ (SE_stall_entry_consumed2 & SE_stall_entry_or1);
    assign SE_stall_entry_backStall = SE_stall_entry_wireStall;
    // Valid signal propagation
    assign SE_stall_entry_V0 = SE_stall_entry_wireValid & ~ (SE_stall_entry_fromReg0);
    assign SE_stall_entry_V1 = SE_stall_entry_wireValid & ~ (SE_stall_entry_fromReg1);
    assign SE_stall_entry_V2 = SE_stall_entry_wireValid & ~ (SE_stall_entry_fromReg2);
    // Computing multiple Valid(s)
    assign SE_stall_entry_wireValid = in_valid_in;

    // i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3(BLACKBOX,11)@0
    // in in_stall_in@20000000
    // out out_dest_data_out_1_0@1
    // out out_stall_out@20000000
    // out out_valid_out@1
    slavereg_comp_i_llvm_fpga_ffwd_dest_i32_value6812_0 thei_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3 (
        .in_intel_reserved_ffwd_1_0(in_intel_reserved_ffwd_1_0),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_backStall),
        .in_valid_in(SE_stall_entry_V2),
        .out_dest_data_out_1_0(i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_out_dest_data_out_1_0),
        .out_stall_out(i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3(BITJOIN,42)
    assign bubble_join_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_q = i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_out_dest_data_out_1_0;

    // bubble_select_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3(BITSELECT,43)
    assign bubble_select_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_b = $unsigned(bubble_join_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_q[31:0]);

    // bubble_join_i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2(BITJOIN,38)
    assign bubble_join_i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_q = i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_out_dest_data_out_3_0;

    // bubble_select_i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2(BITSELECT,39)
    assign bubble_select_i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_b = $unsigned(bubble_join_i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_q[31:0]);

    // bubble_join_i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0(BITJOIN,34)
    assign bubble_join_i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_q = i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_out_dest_data_out_0_0;

    // bubble_select_i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0(BITSELECT,35)
    assign bubble_select_i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_b = $unsigned(bubble_join_i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_q[31:0]);

    // c_i32_5390346467(CONSTANT,2)
    assign c_i32_5390346467_q = $unsigned(32'b00100000001000010000010000010110);

    // SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3(STALLENABLE,56)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_fromReg0 <= '0;
            SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_fromReg0 <= SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_fromReg1 <= SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_consumed0 = (~ (in_stall_in) & SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_wireValid) | SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_fromReg0;
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_consumed1 = (~ (i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_o_stall) & SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_wireValid) | SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_fromReg1;
    // Consuming
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_StallValid = SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_backStall & SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_wireValid;
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_toReg0 = SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_StallValid & SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_consumed0;
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_toReg1 = SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_StallValid & SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_consumed1;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_or0 = SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_consumed0;
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_wireStall = ~ (SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_consumed1 & SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_or0);
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_backStall = SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_V0 = SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_wireValid & ~ (SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_fromReg0);
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_V1 = SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_wireValid & ~ (SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_and0 = i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_out_valid_out;
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_and1 = i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_out_valid_out & SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_and0;
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_wireValid = i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_out_valid_out & SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_and1;

    // SE_out_i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5(STALLENABLE,58)
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_backStall = $unsigned(1'b0);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_wireValid = i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_valid_out;

    // bubble_join_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x(BITJOIN,49)
    assign bubble_join_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_q = i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_o_ack;

    // bubble_select_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x(BITSELECT,50)
    assign bubble_select_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_b = $unsigned(bubble_join_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_q[0:0]);

    // i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5(BLACKBOX,12)@1
    // in in_stall_in@20000000
    // out out_data_out@2
    // out out_feedback_out_1@20000000
    // out out_feedback_valid_out_1@20000000
    // out out_stall_out@20000000
    // out out_valid_out@2
    slavereg_comp_i_llvm_fpga_push_token_i1_throttle_push_0 thei_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5 (
        .in_data_in(bubble_select_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_b),
        .in_feedback_stall_in_1(in_feedback_stall_in_1),
        .in_stall_in(SE_out_i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_backStall),
        .in_valid_in(SE_out_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_V0),
        .out_data_out(),
        .out_feedback_out_1(i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_feedback_out_1),
        .out_feedback_valid_out_1(i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_feedback_valid_out_1),
        .out_stall_out(i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_stall_out),
        .out_valid_out(i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x(STALLENABLE,62)
    // Valid signal propagation
    assign SE_out_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_V0 = SE_out_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_wireValid;
    // Backward Stall generation
    assign SE_out_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_backStall = i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_stall_out | ~ (SE_out_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_wireValid = i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_o_valid;

    // i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x(BLACKBOX,32)@1
    // in in_i_stall@20000000
    // out out_iowr_nb_return_slavereg_comp_o_fifodata@20000000
    // out out_iowr_nb_return_slavereg_comp_o_fifovalid@20000000
    // out out_o_stall@20000000
    slavereg_comp_i_iowr_nb_return_unnamed_s0000omp12_slavereg_comp0 thei_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x (
        .in_i_stall(SE_out_i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_backStall),
        .in_i_valid(SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_V1),
        .in_i_data_0_tpl(c_i32_5390346467_q),
        .in_i_data_1_tpl(bubble_select_i_llvm_fpga_ffwd_dest_i32_index679_slavereg_comp0_b),
        .in_i_data_2_tpl(bubble_select_i_llvm_fpga_ffwd_dest_i32_unnamed_slavereg_comp11_slavereg_comp2_b),
        .in_i_data_3_tpl(bubble_select_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_b),
        .out_iowr_nb_return_slavereg_comp_o_fifodata(i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_iowr_nb_return_slavereg_comp_o_fifodata),
        .out_iowr_nb_return_slavereg_comp_o_fifovalid(i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_iowr_nb_return_slavereg_comp_o_fifovalid),
        .out_o_ack(i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_o_ack),
        .out_o_stall(i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_o_stall),
        .out_o_valid(i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_o_valid),
        .clock(clock),
        .resetn(resetn)
    );

    // ext_sig_sync_out(GPOUT,5)
    assign out_iowr_nb_return_slavereg_comp_o_fifodata = i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_iowr_nb_return_slavereg_comp_o_fifodata;
    assign out_iowr_nb_return_slavereg_comp_o_fifovalid = i_iowr_nb_return_slavereg_comp_unnamed_slavereg_comp12_slavereg_comp4_aunroll_x_out_iowr_nb_return_slavereg_comp_o_fifovalid;

    // feedback_out_1_sync(GPOUT,6)
    assign out_feedback_out_1 = i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_feedback_out_1;

    // feedback_valid_out_1_sync(GPOUT,8)
    assign out_feedback_valid_out_1 = i_llvm_fpga_push_token_i1_throttle_push_slavereg_comp5_out_feedback_valid_out_1;

    // sync_out(GPOUT,29)@0
    assign out_stall_out = SE_stall_entry_backStall;

    // dupName_0_sync_out_x(GPOUT,31)@1
    assign out_valid_out = SE_out_i_llvm_fpga_ffwd_dest_i32_value6812_slavereg_comp3_V0;

endmodule
