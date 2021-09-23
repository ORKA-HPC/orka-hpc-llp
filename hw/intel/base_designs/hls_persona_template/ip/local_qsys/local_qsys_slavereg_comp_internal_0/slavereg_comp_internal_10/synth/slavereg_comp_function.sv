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

// SystemVerilog created from slavereg_comp_function
// SystemVerilog created on Fri Apr 16 11:58:54 2021


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module slavereg_comp_function (
    input wire [63:0] in_arg_call,
    input wire [63:0] in_arg_memdata1,
    input wire [63:0] in_arg_memdata2,
    input wire [63:0] in_arg_memdata3,
    input wire [63:0] in_arg_return,
    input wire [255:0] in_iord_bl_call_slavereg_comp_i_fifodata,
    input wire [0:0] in_iord_bl_call_slavereg_comp_i_fifovalid,
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
    input wire [0:0] in_stall_in,
    input wire [0:0] in_start,
    input wire [511:0] in_unnamed_slavereg_comp8_slavereg_comp_avm_readdata,
    input wire [0:0] in_unnamed_slavereg_comp8_slavereg_comp_avm_readdatavalid,
    input wire [0:0] in_unnamed_slavereg_comp8_slavereg_comp_avm_waitrequest,
    input wire [0:0] in_unnamed_slavereg_comp8_slavereg_comp_avm_writeack,
    input wire [0:0] in_valid_in,
    output wire [0:0] out_iord_bl_call_slavereg_comp_o_fifoalmost_full,
    output wire [0:0] out_iord_bl_call_slavereg_comp_o_fifoready,
    output wire [127:0] out_iowr_nb_return_slavereg_comp_o_fifodata,
    output wire [0:0] out_iowr_nb_return_slavereg_comp_o_fifovalid,
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
    output wire [0:0] out_o_active_memdep,
    output wire [0:0] out_o_active_memdep_5,
    output wire [0:0] out_stall_out,
    output wire [31:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_address,
    output wire [4:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount,
    output wire [63:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable,
    output wire [0:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_enable,
    output wire [0:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_read,
    output wire [0:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_write,
    output wire [511:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata,
    output wire [0:0] out_valid_out,
    input wire clock,
    input wire resetn
    );

    wire [0:0] GND_q;
    wire [0:0] VCC_q;
    wire [0:0] bb_slavereg_comp_B0_runOnce_out_stall_out_0;
    wire [0:0] bb_slavereg_comp_B1_start_out_feedback_stall_out_1;
    wire [31:0] bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_0_0;
    wire [31:0] bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_1_0;
    wire [63:0] bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_2_0;
    wire [31:0] bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_3_0;
    wire [63:0] bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_4_0;
    wire [63:0] bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_5_0;
    wire [32:0] bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_6_0;
    wire [0:0] bb_slavereg_comp_B1_start_out_iord_bl_call_slavereg_comp_o_fifoalmost_full;
    wire [0:0] bb_slavereg_comp_B1_start_out_iord_bl_call_slavereg_comp_o_fifoready;
    wire [0:0] bb_slavereg_comp_B1_start_out_pipeline_valid_out;
    wire [0:0] bb_slavereg_comp_B1_start_out_stall_out_0;
    wire [31:0] bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_address;
    wire [4:0] bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount;
    wire [63:0] bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable;
    wire [0:0] bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_enable;
    wire [0:0] bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_read;
    wire [0:0] bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_write;
    wire [511:0] bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata;
    wire [0:0] bb_slavereg_comp_B1_start_out_valid_in_0;
    wire [0:0] bb_slavereg_comp_B1_start_out_valid_in_1;
    wire [0:0] bb_slavereg_comp_B1_start_out_valid_out_0;
    wire [0:0] bb_slavereg_comp_B2_out_feedback_out_1;
    wire [0:0] bb_slavereg_comp_B2_out_feedback_valid_out_1;
    wire [127:0] bb_slavereg_comp_B2_out_iowr_nb_return_slavereg_comp_o_fifodata;
    wire [0:0] bb_slavereg_comp_B2_out_iowr_nb_return_slavereg_comp_o_fifovalid;
    wire [0:0] bb_slavereg_comp_B2_out_stall_in_0;
    wire [0:0] bb_slavereg_comp_B2_out_stall_out_0;
    wire [0:0] bb_slavereg_comp_B2_out_valid_out_0;
    wire [0:0] bb_slavereg_comp_B3_out_exiting_stall_out;
    wire [0:0] bb_slavereg_comp_B3_out_exiting_valid_out;
    wire [31:0] bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_address;
    wire [4:0] bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_burstcount;
    wire [63:0] bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_byteenable;
    wire [0:0] bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_enable;
    wire [0:0] bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_read;
    wire [0:0] bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_write;
    wire [511:0] bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_writedata;
    wire [31:0] bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_address;
    wire [4:0] bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_burstcount;
    wire [63:0] bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_byteenable;
    wire [0:0] bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_enable;
    wire [0:0] bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_read;
    wire [0:0] bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_write;
    wire [511:0] bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_writedata;
    wire [0:0] bb_slavereg_comp_B3_out_lsu_memdep_5_o_active;
    wire [0:0] bb_slavereg_comp_B3_out_lsu_memdep_o_active;
    wire [31:0] bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_address;
    wire [4:0] bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_burstcount;
    wire [63:0] bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_byteenable;
    wire [0:0] bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_enable;
    wire [0:0] bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_read;
    wire [0:0] bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_write;
    wire [511:0] bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_writedata;
    wire [31:0] bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_address;
    wire [4:0] bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_burstcount;
    wire [63:0] bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_byteenable;
    wire [0:0] bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_enable;
    wire [0:0] bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_read;
    wire [0:0] bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_write;
    wire [511:0] bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_writedata;
    wire [0:0] bb_slavereg_comp_B3_out_pipeline_valid_out;
    wire [0:0] bb_slavereg_comp_B3_out_stall_in_0;
    wire [0:0] bb_slavereg_comp_B3_out_stall_out_0;
    wire [0:0] bb_slavereg_comp_B3_out_stall_out_1;
    wire [0:0] bb_slavereg_comp_B3_out_valid_in_0;
    wire [0:0] bb_slavereg_comp_B3_out_valid_in_1;
    wire [0:0] bb_slavereg_comp_B3_out_valid_out_0;
    wire [1:0] c_i2_011_q;
    wire [0:0] i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_sr_out_o_stall;
    wire [0:0] i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_sr_out_o_valid;
    wire [0:0] i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_valid_fifo_out_stall_out;
    wire [0:0] i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_valid_fifo_out_valid_out;
    wire [0:0] i_llvm_fpga_pipeline_keep_going_slavereg_comp7_sr_out_o_stall;
    wire [0:0] i_llvm_fpga_pipeline_keep_going_slavereg_comp7_sr_out_o_valid;
    wire [0:0] loop_limiter_slavereg_comp0_out_o_stall;
    wire [0:0] loop_limiter_slavereg_comp0_out_o_valid;
    wire [0:0] slavereg_comp_B1_start_x_i_capture;
    wire slavereg_comp_B1_start_x_i_capture_bitsignaltemp;
    wire [0:0] slavereg_comp_B1_start_x_i_clear;
    wire slavereg_comp_B1_start_x_i_clear_bitsignaltemp;
    wire [0:0] slavereg_comp_B1_start_x_i_enable;
    wire slavereg_comp_B1_start_x_i_enable_bitsignaltemp;
    wire [0:0] slavereg_comp_B1_start_x_i_shift;
    wire slavereg_comp_B1_start_x_i_shift_bitsignaltemp;
    wire [0:0] slavereg_comp_B1_start_x_i_stall_pred;
    wire slavereg_comp_B1_start_x_i_stall_pred_bitsignaltemp;
    wire [0:0] slavereg_comp_B1_start_x_i_stall_succ;
    wire slavereg_comp_B1_start_x_i_stall_succ_bitsignaltemp;
    wire [0:0] slavereg_comp_B1_start_x_i_valid_loop;
    wire slavereg_comp_B1_start_x_i_valid_loop_bitsignaltemp;
    wire [0:0] slavereg_comp_B1_start_x_i_valid_pred;
    wire slavereg_comp_B1_start_x_i_valid_pred_bitsignaltemp;
    wire [0:0] slavereg_comp_B1_start_x_i_valid_succ;
    wire slavereg_comp_B1_start_x_i_valid_succ_bitsignaltemp;
    wire [0:0] slavereg_comp_B3_x_i_capture;
    wire slavereg_comp_B3_x_i_capture_bitsignaltemp;
    wire [0:0] slavereg_comp_B3_x_i_clear;
    wire slavereg_comp_B3_x_i_clear_bitsignaltemp;
    wire [0:0] slavereg_comp_B3_x_i_enable;
    wire slavereg_comp_B3_x_i_enable_bitsignaltemp;
    wire [0:0] slavereg_comp_B3_x_i_shift;
    wire slavereg_comp_B3_x_i_shift_bitsignaltemp;
    wire [0:0] slavereg_comp_B3_x_i_stall_pred;
    wire slavereg_comp_B3_x_i_stall_pred_bitsignaltemp;
    wire [0:0] slavereg_comp_B3_x_i_stall_succ;
    wire slavereg_comp_B3_x_i_stall_succ_bitsignaltemp;
    wire [0:0] slavereg_comp_B3_x_i_valid_loop;
    wire slavereg_comp_B3_x_i_valid_loop_bitsignaltemp;
    wire [0:0] slavereg_comp_B3_x_i_valid_pred;
    wire slavereg_comp_B3_x_i_valid_pred_bitsignaltemp;
    wire [0:0] slavereg_comp_B3_x_i_valid_succ;
    wire slavereg_comp_B3_x_i_valid_succ_bitsignaltemp;
    wire [0:0] bb_slavereg_comp_B2_sr_0_aunroll_x_out_o_stall;
    wire [0:0] bb_slavereg_comp_B2_sr_0_aunroll_x_out_o_valid;
    wire [0:0] bb_slavereg_comp_B3_sr_1_aunroll_x_out_o_stall;
    wire [0:0] bb_slavereg_comp_B3_sr_1_aunroll_x_out_o_valid;
    wire [0:0] bb_slavereg_comp_B3_sr_1_aunroll_x_out_o_data_0_tpl;


    // c_i2_011(CONSTANT,18)
    assign c_i2_011_q = $unsigned(2'b00);

    // i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_valid_fifo(BLACKBOX,21)
    slavereg_comp_i_llvm_fpga_pipeline_keep_going20_1_valid_fifo thei_llvm_fpga_pipeline_keep_going20_slavereg_comp1_valid_fifo (
        .in_data_in(c_i2_011_q),
        .in_stall_in(bb_slavereg_comp_B1_start_out_stall_out_0),
        .in_valid_in(i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_sr_out_o_valid),
        .out_almost_full(),
        .out_data_out(),
        .out_stall_out(i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_valid_fifo_out_stall_out),
        .out_valid_out(i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_valid_fifo_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bb_slavereg_comp_B2_sr_0_aunroll_x(BLACKBOX,99)
    slavereg_comp_bb_B2_sr_0 thebb_slavereg_comp_B2_sr_0_aunroll_x (
        .in_i_stall(bb_slavereg_comp_B2_out_stall_out_0),
        .in_i_valid(bb_slavereg_comp_B3_out_valid_out_0),
        .in_i_data_0_tpl(GND_q),
        .out_o_stall(bb_slavereg_comp_B2_sr_0_aunroll_x_out_o_stall),
        .out_o_valid(bb_slavereg_comp_B2_sr_0_aunroll_x_out_o_valid),
        .out_o_data_0_tpl(),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_pipeline_keep_going_slavereg_comp7_sr(BLACKBOX,22)
    slavereg_comp_i_llvm_fpga_pipeline_keep_going_7_sr thei_llvm_fpga_pipeline_keep_going_slavereg_comp7_sr (
        .in_i_data(GND_q),
        .in_i_stall(bb_slavereg_comp_B3_out_stall_out_0),
        .in_i_valid(bb_slavereg_comp_B3_out_pipeline_valid_out),
        .out_o_data(),
        .out_o_stall(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_sr_out_o_stall),
        .out_o_valid(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_sr_out_o_valid),
        .clock(clock),
        .resetn(resetn)
    );

    // GND(CONSTANT,0)
    assign GND_q = $unsigned(1'b0);

    // bb_slavereg_comp_B3(BLACKBOX,5)
    slavereg_comp_bb_B3 thebb_slavereg_comp_B3 (
        .in_flush(in_start),
        .in_forked_0(GND_q),
        .in_forked_1(bb_slavereg_comp_B3_sr_1_aunroll_x_out_o_data_0_tpl),
        .in_intel_reserved_ffwd_0_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_0_0),
        .in_intel_reserved_ffwd_1_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_1_0),
        .in_intel_reserved_ffwd_2_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_2_0),
        .in_intel_reserved_ffwd_4_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_4_0),
        .in_intel_reserved_ffwd_5_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_5_0),
        .in_intel_reserved_ffwd_6_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_6_0),
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
        .in_pipeline_stall_in(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_sr_out_o_stall),
        .in_stall_in_0(bb_slavereg_comp_B2_sr_0_aunroll_x_out_o_stall),
        .in_stall_in_1(GND_q),
        .in_valid_in_0(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_sr_out_o_valid),
        .in_valid_in_1(bb_slavereg_comp_B3_sr_1_aunroll_x_out_o_valid),
        .out_exiting_stall_out(bb_slavereg_comp_B3_out_exiting_stall_out),
        .out_exiting_valid_out(bb_slavereg_comp_B3_out_exiting_valid_out),
        .out_lm1_slavereg_comp_avm_address(bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_address),
        .out_lm1_slavereg_comp_avm_burstcount(bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_burstcount),
        .out_lm1_slavereg_comp_avm_byteenable(bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_byteenable),
        .out_lm1_slavereg_comp_avm_enable(bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_enable),
        .out_lm1_slavereg_comp_avm_read(bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_read),
        .out_lm1_slavereg_comp_avm_write(bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_write),
        .out_lm1_slavereg_comp_avm_writedata(bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_writedata),
        .out_lm22_slavereg_comp_avm_address(bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_address),
        .out_lm22_slavereg_comp_avm_burstcount(bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_burstcount),
        .out_lm22_slavereg_comp_avm_byteenable(bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_byteenable),
        .out_lm22_slavereg_comp_avm_enable(bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_enable),
        .out_lm22_slavereg_comp_avm_read(bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_read),
        .out_lm22_slavereg_comp_avm_write(bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_write),
        .out_lm22_slavereg_comp_avm_writedata(bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_writedata),
        .out_lsu_memdep_5_o_active(bb_slavereg_comp_B3_out_lsu_memdep_5_o_active),
        .out_lsu_memdep_o_active(bb_slavereg_comp_B3_out_lsu_memdep_o_active),
        .out_memdep_5_slavereg_comp_avm_address(bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_address),
        .out_memdep_5_slavereg_comp_avm_burstcount(bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_burstcount),
        .out_memdep_5_slavereg_comp_avm_byteenable(bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_byteenable),
        .out_memdep_5_slavereg_comp_avm_enable(bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_enable),
        .out_memdep_5_slavereg_comp_avm_read(bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_read),
        .out_memdep_5_slavereg_comp_avm_write(bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_write),
        .out_memdep_5_slavereg_comp_avm_writedata(bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_writedata),
        .out_memdep_slavereg_comp_avm_address(bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_address),
        .out_memdep_slavereg_comp_avm_burstcount(bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_burstcount),
        .out_memdep_slavereg_comp_avm_byteenable(bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_byteenable),
        .out_memdep_slavereg_comp_avm_enable(bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_enable),
        .out_memdep_slavereg_comp_avm_read(bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_read),
        .out_memdep_slavereg_comp_avm_write(bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_write),
        .out_memdep_slavereg_comp_avm_writedata(bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_writedata),
        .out_pipeline_valid_out(bb_slavereg_comp_B3_out_pipeline_valid_out),
        .out_stall_in_0(bb_slavereg_comp_B3_out_stall_in_0),
        .out_stall_out_0(bb_slavereg_comp_B3_out_stall_out_0),
        .out_stall_out_1(bb_slavereg_comp_B3_out_stall_out_1),
        .out_valid_in_0(bb_slavereg_comp_B3_out_valid_in_0),
        .out_valid_in_1(bb_slavereg_comp_B3_out_valid_in_1),
        .out_valid_out_0(bb_slavereg_comp_B3_out_valid_out_0),
        .out_valid_out_1(),
        .clock(clock),
        .resetn(resetn)
    );

    // VCC(CONSTANT,1)
    assign VCC_q = $unsigned(1'b1);

    // bb_slavereg_comp_B3_sr_1_aunroll_x(BLACKBOX,100)
    slavereg_comp_bb_B3_sr_1 thebb_slavereg_comp_B3_sr_1_aunroll_x (
        .in_i_stall(bb_slavereg_comp_B3_out_stall_out_1),
        .in_i_valid(loop_limiter_slavereg_comp0_out_o_valid),
        .in_i_data_0_tpl(VCC_q),
        .out_o_stall(bb_slavereg_comp_B3_sr_1_aunroll_x_out_o_stall),
        .out_o_valid(bb_slavereg_comp_B3_sr_1_aunroll_x_out_o_valid),
        .out_o_data_0_tpl(bb_slavereg_comp_B3_sr_1_aunroll_x_out_o_data_0_tpl),
        .clock(clock),
        .resetn(resetn)
    );

    // loop_limiter_slavereg_comp0(BLACKBOX,53)
    slavereg_comp_loop_limiter_0 theloop_limiter_slavereg_comp0 (
        .in_i_stall(bb_slavereg_comp_B3_sr_1_aunroll_x_out_o_stall),
        .in_i_stall_exit(bb_slavereg_comp_B3_out_exiting_stall_out),
        .in_i_valid(bb_slavereg_comp_B1_start_out_valid_out_0),
        .in_i_valid_exit(bb_slavereg_comp_B3_out_exiting_valid_out),
        .out_o_stall(loop_limiter_slavereg_comp0_out_o_stall),
        .out_o_valid(loop_limiter_slavereg_comp0_out_o_valid),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_sr(BLACKBOX,20)
    slavereg_comp_i_llvm_fpga_pipeline_keep_going20_1_sr thei_llvm_fpga_pipeline_keep_going20_slavereg_comp1_sr (
        .in_i_data(GND_q),
        .in_i_stall(i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_valid_fifo_out_stall_out),
        .in_i_valid(bb_slavereg_comp_B1_start_out_pipeline_valid_out),
        .out_o_data(),
        .out_o_stall(i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_sr_out_o_stall),
        .out_o_valid(i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_sr_out_o_valid),
        .clock(clock),
        .resetn(resetn)
    );

    // bb_slavereg_comp_B2(BLACKBOX,4)
    slavereg_comp_bb_B2 thebb_slavereg_comp_B2 (
        .in_feedback_stall_in_1(bb_slavereg_comp_B1_start_out_feedback_stall_out_1),
        .in_intel_reserved_ffwd_0_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_0_0),
        .in_intel_reserved_ffwd_1_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_1_0),
        .in_intel_reserved_ffwd_3_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_3_0),
        .in_stall_in_0(GND_q),
        .in_valid_in_0(bb_slavereg_comp_B2_sr_0_aunroll_x_out_o_valid),
        .out_feedback_out_1(bb_slavereg_comp_B2_out_feedback_out_1),
        .out_feedback_valid_out_1(bb_slavereg_comp_B2_out_feedback_valid_out_1),
        .out_iowr_nb_return_slavereg_comp_o_fifodata(bb_slavereg_comp_B2_out_iowr_nb_return_slavereg_comp_o_fifodata),
        .out_iowr_nb_return_slavereg_comp_o_fifovalid(bb_slavereg_comp_B2_out_iowr_nb_return_slavereg_comp_o_fifovalid),
        .out_stall_in_0(bb_slavereg_comp_B2_out_stall_in_0),
        .out_stall_out_0(bb_slavereg_comp_B2_out_stall_out_0),
        .out_valid_out_0(bb_slavereg_comp_B2_out_valid_out_0),
        .clock(clock),
        .resetn(resetn)
    );

    // bb_slavereg_comp_B1_start(BLACKBOX,3)
    slavereg_comp_bb_B1_start thebb_slavereg_comp_B1_start (
        .in_feedback_in_1(bb_slavereg_comp_B2_out_feedback_out_1),
        .in_feedback_valid_in_1(bb_slavereg_comp_B2_out_feedback_valid_out_1),
        .in_flush(in_start),
        .in_iord_bl_call_slavereg_comp_i_fifodata(in_iord_bl_call_slavereg_comp_i_fifodata),
        .in_iord_bl_call_slavereg_comp_i_fifovalid(in_iord_bl_call_slavereg_comp_i_fifovalid),
        .in_pipeline_stall_in(i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_sr_out_o_stall),
        .in_stall_in_0(loop_limiter_slavereg_comp0_out_o_stall),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_readdata(in_unnamed_slavereg_comp8_slavereg_comp_avm_readdata),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_readdatavalid(in_unnamed_slavereg_comp8_slavereg_comp_avm_readdatavalid),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_waitrequest(in_unnamed_slavereg_comp8_slavereg_comp_avm_waitrequest),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_writeack(in_unnamed_slavereg_comp8_slavereg_comp_avm_writeack),
        .in_valid_in_0(i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_valid_fifo_out_valid_out),
        .in_valid_in_1(in_valid_in),
        .out_exiting_stall_out(),
        .out_exiting_valid_out(),
        .out_feedback_stall_out_1(bb_slavereg_comp_B1_start_out_feedback_stall_out_1),
        .out_intel_reserved_ffwd_0_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_0_0),
        .out_intel_reserved_ffwd_1_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_1_0),
        .out_intel_reserved_ffwd_2_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_2_0),
        .out_intel_reserved_ffwd_3_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_3_0),
        .out_intel_reserved_ffwd_4_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_4_0),
        .out_intel_reserved_ffwd_5_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_5_0),
        .out_intel_reserved_ffwd_6_0(bb_slavereg_comp_B1_start_out_intel_reserved_ffwd_6_0),
        .out_iord_bl_call_slavereg_comp_o_fifoalmost_full(bb_slavereg_comp_B1_start_out_iord_bl_call_slavereg_comp_o_fifoalmost_full),
        .out_iord_bl_call_slavereg_comp_o_fifoready(bb_slavereg_comp_B1_start_out_iord_bl_call_slavereg_comp_o_fifoready),
        .out_pipeline_valid_out(bb_slavereg_comp_B1_start_out_pipeline_valid_out),
        .out_stall_out_0(bb_slavereg_comp_B1_start_out_stall_out_0),
        .out_stall_out_1(),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_address(bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_address),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount(bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable(bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_enable(bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_enable),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_read(bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_read),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_write(bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_write),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata(bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata),
        .out_valid_in_0(bb_slavereg_comp_B1_start_out_valid_in_0),
        .out_valid_in_1(bb_slavereg_comp_B1_start_out_valid_in_1),
        .out_valid_out_0(bb_slavereg_comp_B1_start_out_valid_out_0),
        .clock(clock),
        .resetn(resetn)
    );

    // out_iord_bl_call_slavereg_comp_o_fifoalmost_full(GPOUT,54)
    assign out_iord_bl_call_slavereg_comp_o_fifoalmost_full = bb_slavereg_comp_B1_start_out_iord_bl_call_slavereg_comp_o_fifoalmost_full;

    // out_iord_bl_call_slavereg_comp_o_fifoready(GPOUT,55)
    assign out_iord_bl_call_slavereg_comp_o_fifoready = bb_slavereg_comp_B1_start_out_iord_bl_call_slavereg_comp_o_fifoready;

    // out_iowr_nb_return_slavereg_comp_o_fifodata(GPOUT,56)
    assign out_iowr_nb_return_slavereg_comp_o_fifodata = bb_slavereg_comp_B2_out_iowr_nb_return_slavereg_comp_o_fifodata;

    // out_iowr_nb_return_slavereg_comp_o_fifovalid(GPOUT,57)
    assign out_iowr_nb_return_slavereg_comp_o_fifovalid = bb_slavereg_comp_B2_out_iowr_nb_return_slavereg_comp_o_fifovalid;

    // out_lm1_slavereg_comp_avm_address(GPOUT,58)
    assign out_lm1_slavereg_comp_avm_address = bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_address;

    // out_lm1_slavereg_comp_avm_burstcount(GPOUT,59)
    assign out_lm1_slavereg_comp_avm_burstcount = bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_burstcount;

    // out_lm1_slavereg_comp_avm_byteenable(GPOUT,60)
    assign out_lm1_slavereg_comp_avm_byteenable = bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_byteenable;

    // out_lm1_slavereg_comp_avm_enable(GPOUT,61)
    assign out_lm1_slavereg_comp_avm_enable = bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_enable;

    // out_lm1_slavereg_comp_avm_read(GPOUT,62)
    assign out_lm1_slavereg_comp_avm_read = bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_read;

    // out_lm1_slavereg_comp_avm_write(GPOUT,63)
    assign out_lm1_slavereg_comp_avm_write = bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_write;

    // out_lm1_slavereg_comp_avm_writedata(GPOUT,64)
    assign out_lm1_slavereg_comp_avm_writedata = bb_slavereg_comp_B3_out_lm1_slavereg_comp_avm_writedata;

    // out_lm22_slavereg_comp_avm_address(GPOUT,65)
    assign out_lm22_slavereg_comp_avm_address = bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_address;

    // out_lm22_slavereg_comp_avm_burstcount(GPOUT,66)
    assign out_lm22_slavereg_comp_avm_burstcount = bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_burstcount;

    // out_lm22_slavereg_comp_avm_byteenable(GPOUT,67)
    assign out_lm22_slavereg_comp_avm_byteenable = bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_byteenable;

    // out_lm22_slavereg_comp_avm_enable(GPOUT,68)
    assign out_lm22_slavereg_comp_avm_enable = bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_enable;

    // out_lm22_slavereg_comp_avm_read(GPOUT,69)
    assign out_lm22_slavereg_comp_avm_read = bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_read;

    // out_lm22_slavereg_comp_avm_write(GPOUT,70)
    assign out_lm22_slavereg_comp_avm_write = bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_write;

    // out_lm22_slavereg_comp_avm_writedata(GPOUT,71)
    assign out_lm22_slavereg_comp_avm_writedata = bb_slavereg_comp_B3_out_lm22_slavereg_comp_avm_writedata;

    // out_memdep_5_slavereg_comp_avm_address(GPOUT,72)
    assign out_memdep_5_slavereg_comp_avm_address = bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_address;

    // out_memdep_5_slavereg_comp_avm_burstcount(GPOUT,73)
    assign out_memdep_5_slavereg_comp_avm_burstcount = bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_burstcount;

    // out_memdep_5_slavereg_comp_avm_byteenable(GPOUT,74)
    assign out_memdep_5_slavereg_comp_avm_byteenable = bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_byteenable;

    // out_memdep_5_slavereg_comp_avm_enable(GPOUT,75)
    assign out_memdep_5_slavereg_comp_avm_enable = bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_enable;

    // out_memdep_5_slavereg_comp_avm_read(GPOUT,76)
    assign out_memdep_5_slavereg_comp_avm_read = bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_read;

    // out_memdep_5_slavereg_comp_avm_write(GPOUT,77)
    assign out_memdep_5_slavereg_comp_avm_write = bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_write;

    // out_memdep_5_slavereg_comp_avm_writedata(GPOUT,78)
    assign out_memdep_5_slavereg_comp_avm_writedata = bb_slavereg_comp_B3_out_memdep_5_slavereg_comp_avm_writedata;

    // out_memdep_slavereg_comp_avm_address(GPOUT,79)
    assign out_memdep_slavereg_comp_avm_address = bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_address;

    // out_memdep_slavereg_comp_avm_burstcount(GPOUT,80)
    assign out_memdep_slavereg_comp_avm_burstcount = bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_burstcount;

    // out_memdep_slavereg_comp_avm_byteenable(GPOUT,81)
    assign out_memdep_slavereg_comp_avm_byteenable = bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_byteenable;

    // out_memdep_slavereg_comp_avm_enable(GPOUT,82)
    assign out_memdep_slavereg_comp_avm_enable = bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_enable;

    // out_memdep_slavereg_comp_avm_read(GPOUT,83)
    assign out_memdep_slavereg_comp_avm_read = bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_read;

    // out_memdep_slavereg_comp_avm_write(GPOUT,84)
    assign out_memdep_slavereg_comp_avm_write = bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_write;

    // out_memdep_slavereg_comp_avm_writedata(GPOUT,85)
    assign out_memdep_slavereg_comp_avm_writedata = bb_slavereg_comp_B3_out_memdep_slavereg_comp_avm_writedata;

    // out_o_active_memdep(GPOUT,86)
    assign out_o_active_memdep = bb_slavereg_comp_B3_out_lsu_memdep_o_active;

    // out_o_active_memdep_5(GPOUT,87)
    assign out_o_active_memdep_5 = bb_slavereg_comp_B3_out_lsu_memdep_5_o_active;

    // bb_slavereg_comp_B0_runOnce(BLACKBOX,2)
    slavereg_comp_bb_B0_runOnce thebb_slavereg_comp_B0_runOnce (
        .in_stall_in_0(GND_q),
        .in_valid_in_0(in_valid_in),
        .out_stall_out_0(bb_slavereg_comp_B0_runOnce_out_stall_out_0),
        .out_valid_out_0(),
        .clock(clock),
        .resetn(resetn)
    );

    // out_stall_out(GPOUT,88)
    assign out_stall_out = bb_slavereg_comp_B0_runOnce_out_stall_out_0;

    // out_unnamed_slavereg_comp8_slavereg_comp_avm_address(GPOUT,89)
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_address = bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_address;

    // out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount(GPOUT,90)
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount = bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount;

    // out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable(GPOUT,91)
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable = bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable;

    // out_unnamed_slavereg_comp8_slavereg_comp_avm_enable(GPOUT,92)
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_enable = bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_enable;

    // out_unnamed_slavereg_comp8_slavereg_comp_avm_read(GPOUT,93)
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_read = bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_read;

    // out_unnamed_slavereg_comp8_slavereg_comp_avm_write(GPOUT,94)
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_write = bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_write;

    // out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata(GPOUT,95)
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata = bb_slavereg_comp_B1_start_out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata;

    // out_valid_out(GPOUT,96)
    assign out_valid_out = GND_q;

    // slavereg_comp_B1_start_x(EXTIFACE,97)
    assign slavereg_comp_B1_start_x_i_capture = GND_q;
    assign slavereg_comp_B1_start_x_i_clear = GND_q;
    assign slavereg_comp_B1_start_x_i_enable = VCC_q;
    assign slavereg_comp_B1_start_x_i_shift = GND_q;
    assign slavereg_comp_B1_start_x_i_stall_pred = GND_q;
    assign slavereg_comp_B1_start_x_i_stall_succ = bb_slavereg_comp_B2_out_stall_in_0;
    assign slavereg_comp_B1_start_x_i_valid_loop = bb_slavereg_comp_B1_start_out_valid_in_0;
    assign slavereg_comp_B1_start_x_i_valid_pred = bb_slavereg_comp_B1_start_out_valid_in_1;
    assign slavereg_comp_B1_start_x_i_valid_succ = bb_slavereg_comp_B2_out_valid_out_0;
    assign slavereg_comp_B1_start_x_i_capture_bitsignaltemp = slavereg_comp_B1_start_x_i_capture[0];
    assign slavereg_comp_B1_start_x_i_clear_bitsignaltemp = slavereg_comp_B1_start_x_i_clear[0];
    assign slavereg_comp_B1_start_x_i_enable_bitsignaltemp = slavereg_comp_B1_start_x_i_enable[0];
    assign slavereg_comp_B1_start_x_i_shift_bitsignaltemp = slavereg_comp_B1_start_x_i_shift[0];
    assign slavereg_comp_B1_start_x_i_stall_pred_bitsignaltemp = slavereg_comp_B1_start_x_i_stall_pred[0];
    assign slavereg_comp_B1_start_x_i_stall_succ_bitsignaltemp = slavereg_comp_B1_start_x_i_stall_succ[0];
    assign slavereg_comp_B1_start_x_i_valid_loop_bitsignaltemp = slavereg_comp_B1_start_x_i_valid_loop[0];
    assign slavereg_comp_B1_start_x_i_valid_pred_bitsignaltemp = slavereg_comp_B1_start_x_i_valid_pred[0];
    assign slavereg_comp_B1_start_x_i_valid_succ_bitsignaltemp = slavereg_comp_B1_start_x_i_valid_succ[0];
    hld_loop_profiler #(
        .LOOP_NAME("slavereg_comp.B1.start")
    ) theslavereg_comp_B1_start_x (
        .i_capture(slavereg_comp_B1_start_x_i_capture_bitsignaltemp),
        .i_clear(slavereg_comp_B1_start_x_i_clear_bitsignaltemp),
        .i_enable(slavereg_comp_B1_start_x_i_enable_bitsignaltemp),
        .i_shift(slavereg_comp_B1_start_x_i_shift_bitsignaltemp),
        .i_stall_pred(slavereg_comp_B1_start_x_i_stall_pred_bitsignaltemp),
        .i_stall_succ(slavereg_comp_B1_start_x_i_stall_succ_bitsignaltemp),
        .i_valid_loop(slavereg_comp_B1_start_x_i_valid_loop_bitsignaltemp),
        .i_valid_pred(slavereg_comp_B1_start_x_i_valid_pred_bitsignaltemp),
        .i_valid_succ(slavereg_comp_B1_start_x_i_valid_succ_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // slavereg_comp_B3_x(EXTIFACE,98)
    assign slavereg_comp_B3_x_i_capture = GND_q;
    assign slavereg_comp_B3_x_i_clear = GND_q;
    assign slavereg_comp_B3_x_i_enable = VCC_q;
    assign slavereg_comp_B3_x_i_shift = GND_q;
    assign slavereg_comp_B3_x_i_stall_pred = loop_limiter_slavereg_comp0_out_o_stall;
    assign slavereg_comp_B3_x_i_stall_succ = bb_slavereg_comp_B3_out_stall_in_0;
    assign slavereg_comp_B3_x_i_valid_loop = bb_slavereg_comp_B3_out_valid_in_0;
    assign slavereg_comp_B3_x_i_valid_pred = bb_slavereg_comp_B3_out_valid_in_1;
    assign slavereg_comp_B3_x_i_valid_succ = bb_slavereg_comp_B3_out_valid_out_0;
    assign slavereg_comp_B3_x_i_capture_bitsignaltemp = slavereg_comp_B3_x_i_capture[0];
    assign slavereg_comp_B3_x_i_clear_bitsignaltemp = slavereg_comp_B3_x_i_clear[0];
    assign slavereg_comp_B3_x_i_enable_bitsignaltemp = slavereg_comp_B3_x_i_enable[0];
    assign slavereg_comp_B3_x_i_shift_bitsignaltemp = slavereg_comp_B3_x_i_shift[0];
    assign slavereg_comp_B3_x_i_stall_pred_bitsignaltemp = slavereg_comp_B3_x_i_stall_pred[0];
    assign slavereg_comp_B3_x_i_stall_succ_bitsignaltemp = slavereg_comp_B3_x_i_stall_succ[0];
    assign slavereg_comp_B3_x_i_valid_loop_bitsignaltemp = slavereg_comp_B3_x_i_valid_loop[0];
    assign slavereg_comp_B3_x_i_valid_pred_bitsignaltemp = slavereg_comp_B3_x_i_valid_pred[0];
    assign slavereg_comp_B3_x_i_valid_succ_bitsignaltemp = slavereg_comp_B3_x_i_valid_succ[0];
    hld_loop_profiler #(
        .LOOP_NAME("slavereg_comp.B3")
    ) theslavereg_comp_B3_x (
        .i_capture(slavereg_comp_B3_x_i_capture_bitsignaltemp),
        .i_clear(slavereg_comp_B3_x_i_clear_bitsignaltemp),
        .i_enable(slavereg_comp_B3_x_i_enable_bitsignaltemp),
        .i_shift(slavereg_comp_B3_x_i_shift_bitsignaltemp),
        .i_stall_pred(slavereg_comp_B3_x_i_stall_pred_bitsignaltemp),
        .i_stall_succ(slavereg_comp_B3_x_i_stall_succ_bitsignaltemp),
        .i_valid_loop(slavereg_comp_B3_x_i_valid_loop_bitsignaltemp),
        .i_valid_pred(slavereg_comp_B3_x_i_valid_pred_bitsignaltemp),
        .i_valid_succ(slavereg_comp_B3_x_i_valid_succ_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

endmodule
