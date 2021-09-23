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

// SystemVerilog created from slavereg_comp_bb_B1_start_stall_region
// SystemVerilog created on Fri Apr 16 11:58:54 2021


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module slavereg_comp_bb_B1_start_stall_region (
    input wire [255:0] in_iord_bl_call_slavereg_comp_i_fifodata,
    input wire [0:0] in_iord_bl_call_slavereg_comp_i_fifovalid,
    output wire [0:0] out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_valid_out,
    output wire [0:0] out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_stall_out,
    input wire [0:0] in_feedback_in_1,
    output wire [0:0] out_feedback_stall_out_1,
    input wire [0:0] in_feedback_valid_in_1,
    input wire [0:0] in_pipeline_stall_in,
    output wire [0:0] out_pipeline_valid_out,
    input wire [0:0] in_flush,
    output wire [31:0] out_intel_reserved_ffwd_0_0,
    input wire [0:0] in_stall_in,
    output wire [0:0] out_stall_out,
    input wire [0:0] in_valid_in,
    input wire [511:0] in_unnamed_slavereg_comp8_slavereg_comp_avm_readdata,
    input wire [0:0] in_unnamed_slavereg_comp8_slavereg_comp_avm_writeack,
    input wire [0:0] in_unnamed_slavereg_comp8_slavereg_comp_avm_waitrequest,
    input wire [0:0] in_unnamed_slavereg_comp8_slavereg_comp_avm_readdatavalid,
    output wire [0:0] out_iord_bl_call_slavereg_comp_o_fifoready,
    output wire [0:0] out_iord_bl_call_slavereg_comp_o_fifoalmost_full,
    output wire [31:0] out_intel_reserved_ffwd_1_0,
    output wire [0:0] out_valid_out,
    output wire [31:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_address,
    output wire [0:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_enable,
    output wire [0:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_read,
    output wire [0:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_write,
    output wire [511:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata,
    output wire [63:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable,
    output wire [4:0] out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount,
    output wire [63:0] out_intel_reserved_ffwd_2_0,
    output wire [31:0] out_intel_reserved_ffwd_3_0,
    output wire [63:0] out_intel_reserved_ffwd_4_0,
    output wire [63:0] out_intel_reserved_ffwd_5_0,
    output wire [32:0] out_intel_reserved_ffwd_6_0,
    input wire clock,
    input wire resetn
    );

    wire [0:0] GND_q;
    wire [0:0] VCC_q;
    wire [31:0] c_i32_124_q;
    wire [31:0] c_i32_125_q;
    wire [32:0] c_i33_126_q;
    wire [31:0] i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_out_intel_reserved_ffwd_0_0;
    wire [0:0] i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_out_valid_out;
    wire [31:0] i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_out_intel_reserved_ffwd_1_0;
    wire [0:0] i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_out_valid_out;
    wire [31:0] i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp9_slavereg_comp17_out_intel_reserved_ffwd_3_0;
    wire [0:0] i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp9_slavereg_comp17_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp9_slavereg_comp17_out_valid_out;
    wire [32:0] i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_out_intel_reserved_ffwd_6_0;
    wire [0:0] i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_out_valid_out;
    wire [63:0] i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_out_intel_reserved_ffwd_5_0;
    wire [0:0] i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_out_valid_out;
    wire [63:0] i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_out_intel_reserved_ffwd_2_0;
    wire [0:0] i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_out_valid_out;
    wire [63:0] i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_out_intel_reserved_ffwd_4_0;
    wire [0:0] i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_out_valid_out;
    wire [31:0] i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_o_readdata;
    wire [0:0] i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_o_stall;
    wire [0:0] i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_o_valid;
    wire [31:0] i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_address;
    wire [4:0] i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount;
    wire [63:0] i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable;
    wire [0:0] i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_enable;
    wire [0:0] i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_read;
    wire [0:0] i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_write;
    wire [511:0] i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata;
    wire [0:0] i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_data_out;
    wire [0:0] i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_feedback_stall_out_1;
    wire [0:0] i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_stall_out;
    wire [0:0] i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_valid_out;
    wire [0:0] i_umax_slavereg_comp14_s;
    reg [31:0] i_umax_slavereg_comp14_q;
    wire [32:0] i_unnamed_slavereg_comp16_a;
    wire [32:0] i_unnamed_slavereg_comp16_b;
    logic [32:0] i_unnamed_slavereg_comp16_o;
    wire [32:0] i_unnamed_slavereg_comp16_q;
    wire [32:0] i_unnamed_slavereg_comp18_vt_join_q;
    wire [31:0] i_unnamed_slavereg_comp18_vt_select_31_b;
    wire [33:0] i_unnamed_slavereg_comp19_a;
    wire [33:0] i_unnamed_slavereg_comp19_b;
    logic [33:0] i_unnamed_slavereg_comp19_o;
    wire [33:0] i_unnamed_slavereg_comp19_q;
    wire [33:0] i_unnamed_slavereg_comp7_a;
    wire [33:0] i_unnamed_slavereg_comp7_b;
    logic [33:0] i_unnamed_slavereg_comp7_o;
    wire [0:0] i_unnamed_slavereg_comp7_c;
    wire [0:0] slavereg_comp_B1_start_merge_reg_out_stall_out;
    wire [0:0] slavereg_comp_B1_start_merge_reg_out_valid_out;
    wire [31:0] bgTrunc_i_unnamed_slavereg_comp16_sel_x_b;
    wire [32:0] bgTrunc_i_unnamed_slavereg_comp19_sel_x_b;
    wire [0:0] i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_iord_bl_call_slavereg_comp_o_fifoalmost_full;
    wire [0:0] i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_iord_bl_call_slavereg_comp_o_fifoready;
    wire [0:0] i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_stall;
    wire [0:0] i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_valid;
    wire [63:0] i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_0_tpl;
    wire [63:0] i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_1_tpl;
    wire [63:0] i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_2_tpl;
    wire [31:0] i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_3_tpl;
    wire [31:0] i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_4_tpl;
    wire [64:0] i_mptr_bitcast_index54_slavereg_comp0_add_x_a;
    wire [64:0] i_mptr_bitcast_index54_slavereg_comp0_add_x_b;
    logic [64:0] i_mptr_bitcast_index54_slavereg_comp0_add_x_o;
    wire [64:0] i_mptr_bitcast_index54_slavereg_comp0_add_x_q;
    wire [63:0] i_mptr_bitcast_index54_slavereg_comp0_c_i64_41_x_q;
    wire [63:0] i_mptr_bitcast_index54_slavereg_comp0_trunc_sel_x_b;
    wire [0:0] i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_stall_out;
    wire [0:0] i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_valid_out;
    wire [0:0] i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_o_stall;
    wire [0:0] i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_o_valid;
    wire [0:0] i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_pipeline_valid_out;
    wire [32:0] i_unnamed_slavereg_comp18_sel_x_b;
    reg [31:0] redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_q;
    wire [31:0] bubble_join_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_q;
    wire [31:0] bubble_select_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_b;
    wire [0:0] bubble_join_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_q;
    wire [0:0] bubble_select_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_b;
    wire [255:0] bubble_join_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_q;
    wire [63:0] bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_b;
    wire [63:0] bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_c;
    wire [63:0] bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_d;
    wire [31:0] bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_e;
    wire [31:0] bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_f;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_V0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_V0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_V0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_V0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_V0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_V0;
    wire [0:0] SE_out_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_backStall;
    wire [0:0] SE_out_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_V0;
    wire [0:0] SE_out_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_backStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_V0;
    wire [0:0] SE_out_slavereg_comp_B1_start_merge_reg_wireValid;
    wire [0:0] SE_out_slavereg_comp_B1_start_merge_reg_backStall;
    wire [0:0] SE_out_slavereg_comp_B1_start_merge_reg_V0;
    wire [0:0] SE_stall_entry_wireValid;
    wire [0:0] SE_stall_entry_backStall;
    wire [0:0] SE_stall_entry_V0;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireStall;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_StallValid;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg0;
    reg [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg0;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed0;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg1;
    reg [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg1;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed1;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg2;
    reg [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg2;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed2;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg3;
    reg [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg3;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed3;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg4;
    reg [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg4;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed4;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg5;
    reg [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg5;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed5;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg6;
    reg [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg6;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed6;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or0;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or1;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or2;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or3;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or4;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or5;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_backStall;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V0;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V1;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V2;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V3;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V4;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V5;
    wire [0:0] SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V6;
    wire [0:0] SE_out_i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_wireValid;
    wire [0:0] SE_out_i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_backStall;
    wire [0:0] SE_out_i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_V0;
    reg [0:0] SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_R_v_0;
    wire [0:0] SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_v_s_0;
    wire [0:0] SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_s_tv_0;
    wire [0:0] SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_backEN;
    wire [0:0] SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_backStall;
    wire [0:0] SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_V0;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_wireValid;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and0;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and1;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and2;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and3;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and4;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and5;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_backStall;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_V0;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_in;
    wire bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_in;
    wire bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_out;
    wire bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_out;
    wire bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_in;
    wire bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_in;
    wire bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_out;
    wire bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_out;
    wire bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_out_bitsignaltemp;
    reg [0:0] bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_R_v_0;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_v_s_0;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_s_tv_0;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_backEN;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_backStall;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_V0;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_in;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_in;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_out;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_out;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_in;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_in;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_out;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_out;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_in;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_in;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_out;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_out;
    wire bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_out_bitsignaltemp;


    // GND(CONSTANT,0)
    assign GND_q = $unsigned(1'b0);

    // SE_stall_entry(STALLENABLE,137)
    // Valid signal propagation
    assign SE_stall_entry_V0 = SE_stall_entry_wireValid;
    // Backward Stall generation
    assign SE_stall_entry_backStall = slavereg_comp_B1_start_merge_reg_out_stall_out | ~ (SE_stall_entry_wireValid);
    // Computing multiple Valid(s)
    assign SE_stall_entry_wireValid = in_valid_in;

    // slavereg_comp_B1_start_merge_reg(BLACKBOX,62)@0
    // in in_stall_in@20000000
    // out out_data_out@1
    // out out_stall_out@20000000
    // out out_valid_out@1
    slavereg_comp_B1_start_merge_reg theslavereg_comp_B1_start_merge_reg (
        .in_data_in(GND_q),
        .in_stall_in(SE_out_slavereg_comp_B1_start_merge_reg_backStall),
        .in_valid_in(SE_stall_entry_V0),
        .out_data_out(),
        .out_stall_out(slavereg_comp_B1_start_merge_reg_out_stall_out),
        .out_valid_out(slavereg_comp_B1_start_merge_reg_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_slavereg_comp_B1_start_merge_reg(STALLENABLE,136)
    // Valid signal propagation
    assign SE_out_slavereg_comp_B1_start_merge_reg_V0 = SE_out_slavereg_comp_B1_start_merge_reg_wireValid;
    // Backward Stall generation
    assign SE_out_slavereg_comp_B1_start_merge_reg_backStall = i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_o_stall | ~ (SE_out_slavereg_comp_B1_start_merge_reg_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_slavereg_comp_B1_start_merge_reg_wireValid = slavereg_comp_B1_start_merge_reg_out_valid_out;

    // SE_out_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15(STALLENABLE,126)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_V0 = SE_out_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_backStall = i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp9_slavereg_comp17_out_stall_out | ~ (SE_out_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_wireValid = i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_o_valid;

    // bubble_join_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15(BITJOIN,100)
    assign bubble_join_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_q = i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_o_readdata;

    // bubble_select_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15(BITSELECT,101)
    assign bubble_select_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_b = $unsigned(bubble_join_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_q[31:0]);

    // i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp9_slavereg_comp17(BLACKBOX,19)@4
    // in in_stall_in@20000000
    // out out_intel_reserved_ffwd_3_0@20000000
    // out out_stall_out@20000000
    slavereg_comp_i_llvm_fpga_ffwd_source_i30000med_9_slavereg_comp0 thei_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp9_slavereg_comp17 (
        .in_predicate_in(GND_q),
        .in_src_data_in_3_0(bubble_select_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_b),
        .in_stall_in(SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_backStall),
        .in_valid_in(SE_out_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_V0),
        .out_intel_reserved_ffwd_3_0(i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp9_slavereg_comp17_out_intel_reserved_ffwd_3_0),
        .out_stall_out(i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp9_slavereg_comp17_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp9_slavereg_comp17_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8(STALLENABLE,112)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_V0 = SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_backStall = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_out | ~ (SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_wireValid = i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_out_valid_out;

    // bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg(STALLFIFO,181)
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_in = SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_V0;
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_in = SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_backStall;
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_out[0] = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_out_bitsignaltemp;
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_out[0] = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(3),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg (
        .valid_in(bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9(STALLENABLE,114)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_V0 = SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_backStall = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_out | ~ (SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_wireValid = i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_out_valid_out;

    // bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg(STALLFIFO,182)
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_in = SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_V0;
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_in = SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_backStall;
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_out[0] = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_out_bitsignaltemp;
    assign bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_out[0] = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(3),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg (
        .valid_in(bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13(STALLENABLE,120)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_V0 = SE_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_backStall = bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_out | ~ (SE_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_wireValid = i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_out_valid_out;

    // bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg(STALLFIFO,184)
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_in = SE_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_V0;
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_in = SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_backStall;
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_out[0] = bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_out_bitsignaltemp;
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_out[0] = bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(3),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg (
        .valid_in(bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11(STALLENABLE,122)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_V0 = SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_backStall = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_out | ~ (SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_wireValid = i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_out_valid_out;

    // bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg(STALLFIFO,185)
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_in = SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_V0;
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_in = SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_backStall;
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_out[0] = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_out_bitsignaltemp;
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_out[0] = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(3),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg (
        .valid_in(bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12(STALLENABLE,124)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_V0 = SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_backStall = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_out | ~ (SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_wireValid = i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_out_valid_out;

    // bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg(STALLFIFO,186)
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_in = SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_V0;
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_in = SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_backStall;
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_out[0] = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_out_bitsignaltemp;
    assign bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_out[0] = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(3),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg (
        .valid_in(bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1(STALLENABLE,162)
    // Valid signal propagation
    assign SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_V0 = SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_wireValid;
    // Backward Stall generation
    assign SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_backStall = in_stall_in | ~ (SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and0 = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_reg_valid_out;
    assign SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and1 = bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_1_reg_valid_out & SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and0;
    assign SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and2 = bubble_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_1_reg_valid_out & SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and1;
    assign SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and3 = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_1_reg_valid_out & SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and2;
    assign SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and4 = bubble_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_1_reg_valid_out & SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and3;
    assign SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and5 = i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp9_slavereg_comp17_out_valid_out & SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and4;
    assign SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_wireValid = bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_V0 & SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_and5;

    // bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg(STALLENABLE,183)
    // Valid signal propagation
    assign bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_V0 = bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_R_v_0;
    // Stall signal propagation
    assign bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_s_tv_0 = SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_backStall & bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_R_v_0;
    // Backward Enable generation
    assign bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_backEN = ~ (bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_s_tv_0);
    // Determine whether to write valid data into the first register stage
    assign bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_v_s_0 = bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_backEN & SE_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_V0;
    // Backward Stall generation
    assign bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_backStall = ~ (bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_v_s_0);
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_R_v_0 <= 1'b0;
        end
        else
        begin
            if (bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_backEN == 1'b0)
            begin
                bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_R_v_0 <= bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_R_v_0 & bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_s_tv_0;
            end
            else
            begin
                bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_R_v_0 <= bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_v_s_0;
            end

        end
    end

    // SE_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20(STALLENABLE,118)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_V0 = SE_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_backStall = bubble_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_1_reg_backStall | ~ (SE_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_wireValid = i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_out_valid_out;

    // c_i33_126(CONSTANT,8)
    assign c_i33_126_q = $unsigned(33'b111111111111111111111111111111111);

    // c_i32_125(CONSTANT,7)
    assign c_i32_125_q = $unsigned(32'b11111111111111111111111111111111);

    // bubble_join_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x(BITJOIN,108)
    assign bubble_join_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_q = {i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_4_tpl, i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_3_tpl, i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_2_tpl, i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_1_tpl, i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_0_tpl};

    // bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x(BITSELECT,109)
    assign bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_b = $unsigned(bubble_join_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_q[63:0]);
    assign bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_c = $unsigned(bubble_join_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_q[127:64]);
    assign bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_d = $unsigned(bubble_join_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_q[191:128]);
    assign bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_e = $unsigned(bubble_join_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_q[223:192]);
    assign bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_f = $unsigned(bubble_join_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_q[255:224]);

    // c_i32_124(CONSTANT,6)
    assign c_i32_124_q = $unsigned(32'b00000000000000000000000000000001);

    // i_unnamed_slavereg_comp7(COMPARE,33)@2
    assign i_unnamed_slavereg_comp7_a = {2'b00, c_i32_124_q};
    assign i_unnamed_slavereg_comp7_b = {2'b00, bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_e};
    assign i_unnamed_slavereg_comp7_o = $unsigned(i_unnamed_slavereg_comp7_a) - $unsigned(i_unnamed_slavereg_comp7_b);
    assign i_unnamed_slavereg_comp7_c[0] = i_unnamed_slavereg_comp7_o[33];

    // VCC(CONSTANT,1)
    assign VCC_q = $unsigned(1'b1);

    // i_umax_slavereg_comp14(MUX,26)@2
    assign i_umax_slavereg_comp14_s = i_unnamed_slavereg_comp7_c;
    always @(i_umax_slavereg_comp14_s or c_i32_124_q or bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_e)
    begin
        unique case (i_umax_slavereg_comp14_s)
            1'b0 : i_umax_slavereg_comp14_q = c_i32_124_q;
            1'b1 : i_umax_slavereg_comp14_q = bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_e;
            default : i_umax_slavereg_comp14_q = 32'b0;
        endcase
    end

    // i_unnamed_slavereg_comp16(ADD,27)@2
    assign i_unnamed_slavereg_comp16_a = {1'b0, i_umax_slavereg_comp14_q};
    assign i_unnamed_slavereg_comp16_b = {1'b0, c_i32_125_q};
    assign i_unnamed_slavereg_comp16_o = $unsigned(i_unnamed_slavereg_comp16_a) + $unsigned(i_unnamed_slavereg_comp16_b);
    assign i_unnamed_slavereg_comp16_q = i_unnamed_slavereg_comp16_o[32:0];

    // bgTrunc_i_unnamed_slavereg_comp16_sel_x(BITSELECT,68)@2
    assign bgTrunc_i_unnamed_slavereg_comp16_sel_x_b = i_unnamed_slavereg_comp16_q[31:0];

    // i_unnamed_slavereg_comp18_sel_x(BITSELECT,86)@2
    assign i_unnamed_slavereg_comp18_sel_x_b = {1'b0, bgTrunc_i_unnamed_slavereg_comp16_sel_x_b[31:0]};

    // i_unnamed_slavereg_comp18_vt_select_31(BITSELECT,31)@2
    assign i_unnamed_slavereg_comp18_vt_select_31_b = i_unnamed_slavereg_comp18_sel_x_b[31:0];

    // redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0(REG,91)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_q <= $unsigned(32'b00000000000000000000000000000000);
        end
        else if (SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_backEN == 1'b1)
        begin
            redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_q <= $unsigned(i_unnamed_slavereg_comp18_vt_select_31_b);
        end
    end

    // i_unnamed_slavereg_comp18_vt_join(BITJOIN,30)@3
    assign i_unnamed_slavereg_comp18_vt_join_q = {GND_q, redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_q};

    // i_unnamed_slavereg_comp19(ADD,32)@3
    assign i_unnamed_slavereg_comp19_a = {1'b0, i_unnamed_slavereg_comp18_vt_join_q};
    assign i_unnamed_slavereg_comp19_b = {1'b0, c_i33_126_q};
    assign i_unnamed_slavereg_comp19_o = $unsigned(i_unnamed_slavereg_comp19_a) + $unsigned(i_unnamed_slavereg_comp19_b);
    assign i_unnamed_slavereg_comp19_q = i_unnamed_slavereg_comp19_o[33:0];

    // bgTrunc_i_unnamed_slavereg_comp19_sel_x(BITSELECT,69)@3
    assign bgTrunc_i_unnamed_slavereg_comp19_sel_x_b = i_unnamed_slavereg_comp19_q[32:0];

    // i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20(BLACKBOX,20)@3
    // in in_stall_in@20000000
    // out out_intel_reserved_ffwd_6_0@20000000
    // out out_stall_out@20000000
    slavereg_comp_i_llvm_fpga_ffwd_source_i30000ed_10_slavereg_comp0 thei_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20 (
        .in_predicate_in(GND_q),
        .in_src_data_in_6_0(bgTrunc_i_unnamed_slavereg_comp19_sel_x_b),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_backStall),
        .in_valid_in(SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_V0),
        .out_intel_reserved_ffwd_6_0(i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_out_intel_reserved_ffwd_6_0),
        .out_stall_out(i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0(STALLENABLE,148)
    // Valid signal propagation
    assign SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_V0 = SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_R_v_0;
    // Stall signal propagation
    assign SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_s_tv_0 = i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_out_stall_out & SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_R_v_0;
    // Backward Enable generation
    assign SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_backEN = ~ (SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_s_tv_0);
    // Determine whether to write valid data into the first register stage
    assign SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_v_s_0 = SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_backEN & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V6;
    // Backward Stall generation
    assign SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_backStall = ~ (SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_v_s_0);
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_R_v_0 <= 1'b0;
        end
        else
        begin
            if (SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_backEN == 1'b0)
            begin
                SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_R_v_0 <= SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_R_v_0 & SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_s_tv_0;
            end
            else
            begin
                SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_R_v_0 <= SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_v_s_0;
            end

        end
    end

    // i_mptr_bitcast_index54_slavereg_comp0_c_i64_41_x(CONSTANT,82)
    assign i_mptr_bitcast_index54_slavereg_comp0_c_i64_41_x_q = $unsigned(64'b0000000000000000000000000000000000000000000000000000000000000100);

    // i_mptr_bitcast_index54_slavereg_comp0_add_x(ADD,81)@2
    assign i_mptr_bitcast_index54_slavereg_comp0_add_x_a = {1'b0, bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_b};
    assign i_mptr_bitcast_index54_slavereg_comp0_add_x_b = {1'b0, i_mptr_bitcast_index54_slavereg_comp0_c_i64_41_x_q};
    assign i_mptr_bitcast_index54_slavereg_comp0_add_x_o = $unsigned(i_mptr_bitcast_index54_slavereg_comp0_add_x_a) + $unsigned(i_mptr_bitcast_index54_slavereg_comp0_add_x_b);
    assign i_mptr_bitcast_index54_slavereg_comp0_add_x_q = i_mptr_bitcast_index54_slavereg_comp0_add_x_o[64:0];

    // i_mptr_bitcast_index54_slavereg_comp0_trunc_sel_x(BITSELECT,84)@2
    assign i_mptr_bitcast_index54_slavereg_comp0_trunc_sel_x_b = i_mptr_bitcast_index54_slavereg_comp0_add_x_q[63:0];

    // i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15(BLACKBOX,24)@2
    // in in_i_stall@20000000
    // out out_o_readdata@4
    // out out_o_stall@20000000
    // out out_o_valid@4
    // out out_unnamed_slavereg_comp8_slavereg_comp_avm_address@20000000
    // out out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount@20000000
    // out out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable@20000000
    // out out_unnamed_slavereg_comp8_slavereg_comp_avm_enable@20000000
    // out out_unnamed_slavereg_comp8_slavereg_comp_avm_read@20000000
    // out out_unnamed_slavereg_comp8_slavereg_comp_avm_write@20000000
    // out out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata@20000000
    slavereg_comp_i_llvm_fpga_mem_unnamed_8_slavereg_comp0 thei_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15 (
        .in_flush(in_flush),
        .in_i_address(i_mptr_bitcast_index54_slavereg_comp0_trunc_sel_x_b),
        .in_i_predicate(GND_q),
        .in_i_stall(SE_out_i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_backStall),
        .in_i_valid(SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V5),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_readdata(in_unnamed_slavereg_comp8_slavereg_comp_avm_readdata),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_readdatavalid(in_unnamed_slavereg_comp8_slavereg_comp_avm_readdatavalid),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_waitrequest(in_unnamed_slavereg_comp8_slavereg_comp_avm_waitrequest),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_writeack(in_unnamed_slavereg_comp8_slavereg_comp_avm_writeack),
        .out_o_readdata(i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_o_readdata),
        .out_o_stall(i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_o_stall),
        .out_o_valid(i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_o_valid),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_address(i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_address),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount(i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable(i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_enable(i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_enable),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_read(i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_read),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_write(i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_write),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata(i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12(BLACKBOX,23)@2
    // in in_stall_in@20000000
    // out out_intel_reserved_ffwd_4_0@20000000
    // out out_stall_out@20000000
    slavereg_comp_i_llvm_fpga_ffwd_source_p10000med_6_slavereg_comp0 thei_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12 (
        .in_predicate_in(GND_q),
        .in_src_data_in_4_0(bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_c),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_backStall),
        .in_valid_in(SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V4),
        .out_intel_reserved_ffwd_4_0(i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_out_intel_reserved_ffwd_4_0),
        .out_stall_out(i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11(BLACKBOX,22)@2
    // in in_stall_in@20000000
    // out out_intel_reserved_ffwd_2_0@20000000
    // out out_stall_out@20000000
    slavereg_comp_i_llvm_fpga_ffwd_source_p10000med_5_slavereg_comp0 thei_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11 (
        .in_predicate_in(GND_q),
        .in_src_data_in_2_0(bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_b),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_backStall),
        .in_valid_in(SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V3),
        .out_intel_reserved_ffwd_2_0(i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_out_intel_reserved_ffwd_2_0),
        .out_stall_out(i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13(BLACKBOX,21)@2
    // in in_stall_in@20000000
    // out out_intel_reserved_ffwd_5_0@20000000
    // out out_stall_out@20000000
    slavereg_comp_i_llvm_fpga_ffwd_source_p10000med_7_slavereg_comp0 thei_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13 (
        .in_predicate_in(GND_q),
        .in_src_data_in_5_0(bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_d),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_backStall),
        .in_valid_in(SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V2),
        .out_intel_reserved_ffwd_5_0(i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_out_intel_reserved_ffwd_5_0),
        .out_stall_out(i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9(BLACKBOX,18)@2
    // in in_stall_in@20000000
    // out out_intel_reserved_ffwd_1_0@20000000
    // out out_stall_out@20000000
    slavereg_comp_i_llvm_fpga_ffwd_source_i30000med_4_slavereg_comp0 thei_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9 (
        .in_predicate_in(GND_q),
        .in_src_data_in_1_0(bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_f),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_backStall),
        .in_valid_in(SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V1),
        .out_intel_reserved_ffwd_1_0(i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_out_intel_reserved_ffwd_1_0),
        .out_stall_out(i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8(BLACKBOX,17)@2
    // in in_stall_in@20000000
    // out out_intel_reserved_ffwd_0_0@20000000
    // out out_stall_out@20000000
    slavereg_comp_i_llvm_fpga_ffwd_source_i30000med_3_slavereg_comp0 thei_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8 (
        .in_predicate_in(GND_q),
        .in_src_data_in_0_0(bubble_select_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_e),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_backStall),
        .in_valid_in(SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V0),
        .out_intel_reserved_ffwd_0_0(i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_out_intel_reserved_ffwd_0_0),
        .out_stall_out(i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x(STALLENABLE,142)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg0 <= '0;
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg1 <= '0;
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg2 <= '0;
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg3 <= '0;
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg4 <= '0;
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg5 <= '0;
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg6 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg0 <= SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg0;
            // Successor 1
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg1 <= SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg1;
            // Successor 2
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg2 <= SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg2;
            // Successor 3
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg3 <= SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg3;
            // Successor 4
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg4 <= SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg4;
            // Successor 5
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg5 <= SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg5;
            // Successor 6
            SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg6 <= SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg6;
        end
    end
    // Input Stall processing
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed0 = (~ (i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_out_stall_out) & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid) | SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg0;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed1 = (~ (i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_out_stall_out) & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid) | SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg1;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed2 = (~ (i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_out_stall_out) & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid) | SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg2;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed3 = (~ (i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_out_stall_out) & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid) | SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg3;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed4 = (~ (i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_out_stall_out) & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid) | SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg4;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed5 = (~ (i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_o_stall) & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid) | SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg5;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed6 = (~ (SE_redist0_i_unnamed_slavereg_comp18_vt_select_31_b_1_0_backStall) & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid) | SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg6;
    // Consuming
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_StallValid = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_backStall & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg0 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_StallValid & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed0;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg1 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_StallValid & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed1;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg2 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_StallValid & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed2;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg3 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_StallValid & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed3;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg4 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_StallValid & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed4;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg5 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_StallValid & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed5;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_toReg6 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_StallValid & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed6;
    // Backward Stall generation
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or0 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed0;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or1 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed1 & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or0;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or2 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed2 & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or1;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or3 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed3 & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or2;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or4 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed4 & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or3;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or5 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed5 & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or4;
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireStall = ~ (SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_consumed6 & SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_or5);
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_backStall = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireStall;
    // Valid signal propagation
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V0 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid & ~ (SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg0);
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V1 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid & ~ (SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg1);
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V2 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid & ~ (SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg2);
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V3 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid & ~ (SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg3);
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V4 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid & ~ (SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg4);
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V5 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid & ~ (SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg5);
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_V6 = SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid & ~ (SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_fromReg6);
    // Computing multiple Valid(s)
    assign SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_wireValid = i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_valid;

    // bubble_join_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1(BITJOIN,103)
    assign bubble_join_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_q = i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_data_out;

    // bubble_select_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1(BITSELECT,104)
    assign bubble_select_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_b = $unsigned(bubble_join_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_q[0:0]);

    // i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x(BLACKBOX,80)@2
    // in in_i_stall@20000000
    // out out_iord_bl_call_slavereg_comp_o_fifoalmost_full@20000000
    // out out_iord_bl_call_slavereg_comp_o_fifoready@20000000
    // out out_o_stall@20000000
    slavereg_comp_i_iord_bl_call_unnamed_sla0000comp2_slavereg_comp0 thei_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x (
        .in_i_dependence(bubble_select_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_b),
        .in_i_stall(SE_out_i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_backStall),
        .in_i_valid(SE_out_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_V0),
        .in_iord_bl_call_slavereg_comp_i_fifodata(in_iord_bl_call_slavereg_comp_i_fifodata),
        .in_iord_bl_call_slavereg_comp_i_fifovalid(in_iord_bl_call_slavereg_comp_i_fifovalid),
        .out_iord_bl_call_slavereg_comp_o_fifoalmost_full(i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_iord_bl_call_slavereg_comp_o_fifoalmost_full),
        .out_iord_bl_call_slavereg_comp_o_fifoready(i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_iord_bl_call_slavereg_comp_o_fifoready),
        .out_o_stall(i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_stall),
        .out_o_valid(i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_valid),
        .out_o_data_0_tpl(i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_0_tpl),
        .out_o_data_1_tpl(i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_1_tpl),
        .out_o_data_2_tpl(i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_2_tpl),
        .out_o_data_3_tpl(i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_3_tpl),
        .out_o_data_4_tpl(i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_data_4_tpl),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1(STALLENABLE,128)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_V0 = SE_out_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_backStall = i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_o_stall | ~ (SE_out_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_wireValid = i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_valid_out;

    // i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1(BLACKBOX,25)@1
    // in in_stall_in@20000000
    // out out_data_out@2
    // out out_feedback_stall_out_1@20000000
    // out out_stall_out@20000000
    // out out_valid_out@2
    slavereg_comp_i_llvm_fpga_pop_throttle_i1_throttle_pop_0 thei_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1 (
        .in_data_in(GND_q),
        .in_dir(GND_q),
        .in_feedback_in_1(in_feedback_in_1),
        .in_feedback_valid_in_1(in_feedback_valid_in_1),
        .in_predicate(GND_q),
        .in_stall_in(SE_out_i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_backStall),
        .in_valid_in(SE_out_i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_V0),
        .out_data_out(i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_data_out),
        .out_feedback_stall_out_1(i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_feedback_stall_out_1),
        .out_stall_out(i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_stall_out),
        .out_valid_out(i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x(STALLENABLE,146)
    // Valid signal propagation
    assign SE_out_i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_V0 = SE_out_i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_wireValid;
    // Backward Stall generation
    assign SE_out_i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_backStall = i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_stall_out | ~ (SE_out_i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_wireValid = i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_o_valid;

    // i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x(BLACKBOX,85)@1
    // in in_i_stall@20000000
    // out out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_stall_out@20000000
    // out out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_valid_out@20000000
    // out out_o_stall@20000000
    // out out_pipeline_valid_out@20000000
    slavereg_comp_i_sfc_s_c0_in_wt_entry_s_c0_enter1_slavereg_comp0 thei_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x (
        .in_i_stall(SE_out_i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_backStall),
        .in_i_valid(SE_out_slavereg_comp_B1_start_merge_reg_V0),
        .in_pipeline_stall_in(in_pipeline_stall_in),
        .in_unnamed_slavereg_comp0_0_tpl(GND_q),
        .out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_stall_out(i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_stall_out),
        .out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_valid_out(i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_valid_out),
        .out_o_stall(i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_o_stall),
        .out_o_valid(i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_o_valid),
        .out_pipeline_valid_out(i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_pipeline_valid_out),
        .out_c0_exit_0_tpl(),
        .out_c0_exit_1_tpl(),
        .clock(clock),
        .resetn(resetn)
    );

    // ext_sig_sync_out(GPOUT,13)
    assign out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_valid_out = i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_valid_out;
    assign out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_stall_out = i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going20_slavereg_comp1_exiting_stall_out;

    // feedback_stall_out_1_sync(GPOUT,15)
    assign out_feedback_stall_out_1 = i_llvm_fpga_pop_throttle_i1_throttle_pop_slavereg_comp1_out_feedback_stall_out_1;

    // pipeline_valid_out_sync(GPOUT,59)
    assign out_pipeline_valid_out = i_sfc_s_c0_in_wt_entry_slavereg_comps_c0_enter1_slavereg_comp0_aunroll_x_out_pipeline_valid_out;

    // regfree_osync(GPOUT,61)
    assign out_intel_reserved_ffwd_0_0 = i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp3_slavereg_comp8_out_intel_reserved_ffwd_0_0;

    // sync_out(GPOUT,66)@0
    assign out_stall_out = SE_stall_entry_backStall;

    // dupName_0_ext_sig_sync_out_x(GPOUT,71)
    assign out_iord_bl_call_slavereg_comp_o_fifoready = i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_iord_bl_call_slavereg_comp_o_fifoready;
    assign out_iord_bl_call_slavereg_comp_o_fifoalmost_full = i_iord_bl_call_slavereg_comp_unnamed_slavereg_comp2_slavereg_comp2_aunroll_x_out_iord_bl_call_slavereg_comp_o_fifoalmost_full;

    // dupName_0_regfree_osync_x(GPOUT,72)
    assign out_intel_reserved_ffwd_1_0 = i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp4_slavereg_comp9_out_intel_reserved_ffwd_1_0;

    // dupName_0_sync_out_x(GPOUT,73)@4
    assign out_valid_out = SE_out_bubble_out_i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_1_V0;

    // dupName_1_ext_sig_sync_out_x(GPOUT,74)
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_address = i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_address;
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_enable = i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_enable;
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_read = i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_read;
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_write = i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_write;
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata = i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata;
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable = i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable;
    assign out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount = i_llvm_fpga_mem_unnamed_slavereg_comp8_slavereg_comp15_out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount;

    // dupName_1_regfree_osync_x(GPOUT,75)
    assign out_intel_reserved_ffwd_2_0 = i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp5_slavereg_comp11_out_intel_reserved_ffwd_2_0;

    // dupName_2_regfree_osync_x(GPOUT,76)
    assign out_intel_reserved_ffwd_3_0 = i_llvm_fpga_ffwd_source_i32_unnamed_slavereg_comp9_slavereg_comp17_out_intel_reserved_ffwd_3_0;

    // dupName_3_regfree_osync_x(GPOUT,77)
    assign out_intel_reserved_ffwd_4_0 = i_llvm_fpga_ffwd_source_p1025i32_unnamed_slavereg_comp6_slavereg_comp12_out_intel_reserved_ffwd_4_0;

    // dupName_4_regfree_osync_x(GPOUT,78)
    assign out_intel_reserved_ffwd_5_0 = i_llvm_fpga_ffwd_source_p1025f32_unnamed_slavereg_comp7_slavereg_comp13_out_intel_reserved_ffwd_5_0;

    // dupName_5_regfree_osync_x(GPOUT,79)
    assign out_intel_reserved_ffwd_6_0 = i_llvm_fpga_ffwd_source_i33_unnamed_slavereg_comp10_slavereg_comp20_out_intel_reserved_ffwd_6_0;

endmodule
