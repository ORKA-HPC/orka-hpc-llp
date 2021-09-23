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

// SystemVerilog created from slavereg_comp_bb_B3_stall_region
// SystemVerilog created on Fri Apr 16 11:58:54 2021


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module slavereg_comp_bb_B3_stall_region (
    input wire [511:0] in_lm1_slavereg_comp_avm_readdata,
    input wire [0:0] in_lm1_slavereg_comp_avm_writeack,
    input wire [0:0] in_lm1_slavereg_comp_avm_waitrequest,
    input wire [0:0] in_lm1_slavereg_comp_avm_readdatavalid,
    output wire [0:0] out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_valid_out,
    output wire [0:0] out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_stall_out,
    input wire [0:0] in_pipeline_stall_in,
    output wire [0:0] out_pipeline_valid_out,
    input wire [0:0] in_flush,
    input wire [31:0] in_intel_reserved_ffwd_0_0,
    input wire [31:0] in_intel_reserved_ffwd_1_0,
    input wire [63:0] in_intel_reserved_ffwd_2_0,
    input wire [63:0] in_intel_reserved_ffwd_4_0,
    input wire [63:0] in_intel_reserved_ffwd_5_0,
    input wire [32:0] in_intel_reserved_ffwd_6_0,
    input wire [0:0] in_stall_in,
    output wire [0:0] out_stall_out,
    input wire [0:0] in_forked,
    input wire [0:0] in_valid_in,
    input wire [511:0] in_memdep_slavereg_comp_avm_readdata,
    input wire [0:0] in_memdep_slavereg_comp_avm_writeack,
    input wire [0:0] in_memdep_slavereg_comp_avm_waitrequest,
    input wire [0:0] in_memdep_slavereg_comp_avm_readdatavalid,
    output wire [31:0] out_lm1_slavereg_comp_avm_address,
    output wire [0:0] out_lm1_slavereg_comp_avm_enable,
    output wire [0:0] out_lm1_slavereg_comp_avm_read,
    output wire [0:0] out_lm1_slavereg_comp_avm_write,
    output wire [511:0] out_lm1_slavereg_comp_avm_writedata,
    output wire [63:0] out_lm1_slavereg_comp_avm_byteenable,
    output wire [4:0] out_lm1_slavereg_comp_avm_burstcount,
    output wire [0:0] out_masked,
    output wire [0:0] out_valid_out,
    input wire [511:0] in_lm22_slavereg_comp_avm_readdata,
    input wire [0:0] in_lm22_slavereg_comp_avm_writeack,
    input wire [0:0] in_lm22_slavereg_comp_avm_waitrequest,
    input wire [0:0] in_lm22_slavereg_comp_avm_readdatavalid,
    output wire [31:0] out_memdep_slavereg_comp_avm_address,
    output wire [0:0] out_memdep_slavereg_comp_avm_enable,
    output wire [0:0] out_memdep_slavereg_comp_avm_read,
    output wire [0:0] out_memdep_slavereg_comp_avm_write,
    output wire [511:0] out_memdep_slavereg_comp_avm_writedata,
    output wire [63:0] out_memdep_slavereg_comp_avm_byteenable,
    output wire [4:0] out_memdep_slavereg_comp_avm_burstcount,
    input wire [511:0] in_memdep_5_slavereg_comp_avm_readdata,
    input wire [0:0] in_memdep_5_slavereg_comp_avm_writeack,
    input wire [0:0] in_memdep_5_slavereg_comp_avm_waitrequest,
    input wire [0:0] in_memdep_5_slavereg_comp_avm_readdatavalid,
    output wire [0:0] out_lsu_memdep_o_active,
    output wire [31:0] out_lm22_slavereg_comp_avm_address,
    output wire [0:0] out_lm22_slavereg_comp_avm_enable,
    output wire [0:0] out_lm22_slavereg_comp_avm_read,
    output wire [0:0] out_lm22_slavereg_comp_avm_write,
    output wire [511:0] out_lm22_slavereg_comp_avm_writedata,
    output wire [63:0] out_lm22_slavereg_comp_avm_byteenable,
    output wire [4:0] out_lm22_slavereg_comp_avm_burstcount,
    output wire [31:0] out_memdep_5_slavereg_comp_avm_address,
    output wire [0:0] out_memdep_5_slavereg_comp_avm_enable,
    output wire [0:0] out_memdep_5_slavereg_comp_avm_read,
    output wire [0:0] out_memdep_5_slavereg_comp_avm_write,
    output wire [511:0] out_memdep_5_slavereg_comp_avm_writedata,
    output wire [63:0] out_memdep_5_slavereg_comp_avm_byteenable,
    output wire [4:0] out_memdep_5_slavereg_comp_avm_burstcount,
    output wire [0:0] out_lsu_memdep_5_o_active,
    input wire clock,
    input wire resetn
    );

    wire [0:0] GND_q;
    wire [0:0] VCC_q;
    wire [31:0] c_i32_062_q;
    wire [31:0] c_i32_164_q;
    wire [32:0] c_i33_167_q;
    wire [32:0] c_i33_undef61_q;
    wire [3:0] c_i4_759_q;
    wire [3:0] i_cleanups_shl_slavereg_comp18_vt_join_q;
    wire [2:0] i_cleanups_shl_slavereg_comp18_vt_select_3_b;
    wire [0:0] i_cmp49_slavereg_comp15_q;
    wire [0:0] i_first_cleanup_xor_or_slavereg_comp36_q;
    wire [0:0] i_first_cleanup_xor_slavereg_comp26_q;
    wire [33:0] i_fpga_indvars_iv_next_slavereg_comp31_a;
    wire [33:0] i_fpga_indvars_iv_next_slavereg_comp31_b;
    logic [33:0] i_fpga_indvars_iv_next_slavereg_comp31_o;
    wire [33:0] i_fpga_indvars_iv_next_slavereg_comp31_q;
    wire [0:0] i_fpga_indvars_iv_replace_phi_slavereg_comp20_s;
    reg [32:0] i_fpga_indvars_iv_replace_phi_slavereg_comp20_q;
    wire [32:0] i_inc_slavereg_comp22_a;
    wire [32:0] i_inc_slavereg_comp22_b;
    logic [32:0] i_inc_slavereg_comp22_o;
    wire [32:0] i_inc_slavereg_comp22_q;
    wire [31:0] i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_out_dest_data_out_0_0;
    wire [0:0] i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_out_valid_out;
    wire [31:0] i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_out_dest_data_out_1_0;
    wire [0:0] i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_out_valid_out;
    wire [32:0] i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_out_dest_data_out_6_0;
    wire [0:0] i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_out_valid_out;
    wire [63:0] i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_out_dest_data_out_5_0;
    wire [0:0] i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_out_valid_out;
    wire [63:0] i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_out_dest_data_out_2_0;
    wire [0:0] i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_out_valid_out;
    wire [63:0] i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_out_dest_data_out_4_0;
    wire [0:0] i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_out_stall_out;
    wire [0:0] i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_out_valid_out;
    wire [31:0] i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_address;
    wire [4:0] i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_burstcount;
    wire [63:0] i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_byteenable;
    wire [0:0] i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_enable;
    wire [0:0] i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_read;
    wire [0:0] i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_write;
    wire [511:0] i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_writedata;
    wire [31:0] i_llvm_fpga_mem_lm1_slavereg_comp41_out_o_readdata;
    wire [0:0] i_llvm_fpga_mem_lm1_slavereg_comp41_out_o_stall;
    wire [0:0] i_llvm_fpga_mem_lm1_slavereg_comp41_out_o_valid;
    wire [31:0] i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_address;
    wire [4:0] i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_burstcount;
    wire [63:0] i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_byteenable;
    wire [0:0] i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_enable;
    wire [0:0] i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_read;
    wire [0:0] i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_write;
    wire [511:0] i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_writedata;
    wire [31:0] i_llvm_fpga_mem_lm22_slavereg_comp52_out_o_readdata;
    wire [0:0] i_llvm_fpga_mem_lm22_slavereg_comp52_out_o_stall;
    wire [0:0] i_llvm_fpga_mem_lm22_slavereg_comp52_out_o_valid;
    wire [0:0] i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_lsu_memdep_5_o_active;
    wire [31:0] i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_address;
    wire [4:0] i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_burstcount;
    wire [63:0] i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_byteenable;
    wire [0:0] i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_enable;
    wire [0:0] i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_read;
    wire [0:0] i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_write;
    wire [511:0] i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_writedata;
    wire [0:0] i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_o_stall;
    wire [0:0] i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_o_valid;
    wire [0:0] i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_o_writeack;
    wire [0:0] i_llvm_fpga_mem_memdep_slavereg_comp48_out_lsu_memdep_o_active;
    wire [31:0] i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_address;
    wire [4:0] i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_burstcount;
    wire [63:0] i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_byteenable;
    wire [0:0] i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_enable;
    wire [0:0] i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_read;
    wire [0:0] i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_write;
    wire [511:0] i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_writedata;
    wire [0:0] i_llvm_fpga_mem_memdep_slavereg_comp48_out_o_stall;
    wire [0:0] i_llvm_fpga_mem_memdep_slavereg_comp48_out_o_valid;
    wire [0:0] i_llvm_fpga_mem_memdep_slavereg_comp48_out_o_writeack;
    wire [0:0] i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out;
    wire [0:0] i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_exiting_stall_out;
    wire [0:0] i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_exiting_valid_out;
    wire [0:0] i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_initeration_stall_out;
    wire [0:0] i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_not_exitcond_stall_out;
    wire [0:0] i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_pipeline_valid_out;
    wire [0:0] i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_stall_out;
    wire [0:0] i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_valid_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_feedback_stall_out_9;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_stall_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_valid_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_data_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_feedback_stall_out_10;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_stall_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_valid_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_feedback_stall_out_11;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_stall_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_valid_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_data_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_feedback_stall_out_8;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_stall_out;
    wire [0:0] i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_valid_out;
    wire [31:0] i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_data_out;
    wire [0:0] i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_feedback_stall_out_7;
    wire [0:0] i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_stall_out;
    wire [0:0] i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_valid_out;
    wire [32:0] i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_data_out;
    wire [0:0] i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_feedback_stall_out_6;
    wire [0:0] i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_stall_out;
    wire [0:0] i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_valid_out;
    wire [3:0] i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_data_out;
    wire [0:0] i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_feedback_stall_out_13;
    wire [0:0] i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_stall_out;
    wire [0:0] i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_valid_out;
    wire [3:0] i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_data_out;
    wire [0:0] i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_feedback_stall_out_12;
    wire [0:0] i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_stall_out;
    wire [0:0] i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_valid_out;
    wire [0:0] i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_feedback_out_2;
    wire [0:0] i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_feedback_valid_out_2;
    wire [0:0] i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_stall_out;
    wire [0:0] i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_valid_out;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_feedback_out_9;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_feedback_valid_out_9;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_stall_out;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_valid_out;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_feedback_out_10;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_feedback_valid_out_10;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_stall_out;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_valid_out;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_feedback_out_11;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_feedback_valid_out_11;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_stall_out;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_valid_out;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_feedback_out_8;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_feedback_valid_out_8;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_stall_out;
    wire [0:0] i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_valid_out;
    wire [0:0] i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_feedback_out_3;
    wire [0:0] i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_feedback_valid_out_3;
    wire [0:0] i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_stall_out;
    wire [0:0] i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_valid_out;
    wire [31:0] i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_feedback_out_7;
    wire [0:0] i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_feedback_valid_out_7;
    wire [0:0] i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_stall_out;
    wire [0:0] i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_valid_out;
    wire [63:0] i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_feedback_out_6;
    wire [0:0] i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_feedback_valid_out_6;
    wire [0:0] i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_stall_out;
    wire [0:0] i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_valid_out;
    wire [7:0] i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_feedback_out_13;
    wire [0:0] i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_feedback_valid_out_13;
    wire [0:0] i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_stall_out;
    wire [0:0] i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_valid_out;
    wire [7:0] i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_feedback_out_12;
    wire [0:0] i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_feedback_valid_out_12;
    wire [0:0] i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_stall_out;
    wire [0:0] i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_valid_out;
    wire [0:0] i_masked_slavereg_comp43_qi;
    reg [0:0] i_masked_slavereg_comp43_q;
    wire [0:0] i_memdep_phi3_or_slavereg_comp25_qi;
    reg [0:0] i_memdep_phi3_or_slavereg_comp25_q;
    wire [0:0] i_memdep_phi6_or7_slavereg_comp24_q;
    wire [0:0] i_memdep_phi6_or8_slavereg_comp51_q;
    wire [0:0] i_memdep_phi6_or_slavereg_comp23_q;
    wire [0:0] i_next_cleanups_slavereg_comp46_s;
    reg [3:0] i_next_cleanups_slavereg_comp46_q;
    wire [3:0] i_next_initerations_slavereg_comp19_vt_join_q;
    wire [2:0] i_next_initerations_slavereg_comp19_vt_select_2_b;
    wire [0:0] i_notcmp_slavereg_comp38_q;
    wire [0:0] i_or_slavereg_comp42_q;
    wire [32:0] bgTrunc_i_fpga_indvars_iv_next_slavereg_comp31_sel_x_b;
    wire [31:0] bgTrunc_i_inc_slavereg_comp22_sel_x_b;
    wire [63:0] bgTrunc_i_mul_slavereg_comp45_sel_x_in;
    wire [31:0] bgTrunc_i_mul_slavereg_comp45_sel_x_b;
    wire [0:0] i_first_cleanup_slavereg_comp17_sel_x_b;
    wire [0:0] i_last_initeration_slavereg_comp28_sel_x_b;
    wire [0:0] i_lm1_toi1_intcast_slavereg_comp44_sel_x_b;
    wire [64:0] i_mptr_bitcast_index52_slavereg_comp0_add_x_a;
    wire [64:0] i_mptr_bitcast_index52_slavereg_comp0_add_x_b;
    logic [64:0] i_mptr_bitcast_index52_slavereg_comp0_add_x_o;
    wire [64:0] i_mptr_bitcast_index52_slavereg_comp0_add_x_q;
    wire [1:0] i_mptr_bitcast_index52_slavereg_comp0_c_i2_01_x_q;
    wire [61:0] i_mptr_bitcast_index52_slavereg_comp0_narrow_x_b;
    wire [63:0] i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q;
    wire [63:0] i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b;
    wire [64:0] i_mptr_bitcast_index56_slavereg_comp0_add_x_a;
    wire [64:0] i_mptr_bitcast_index56_slavereg_comp0_add_x_b;
    logic [64:0] i_mptr_bitcast_index56_slavereg_comp0_add_x_o;
    wire [64:0] i_mptr_bitcast_index56_slavereg_comp0_add_x_q;
    wire [63:0] i_mptr_bitcast_index56_slavereg_comp0_dupName_0_trunc_sel_x_b;
    wire [64:0] i_mptr_bitcast_index58_slavereg_comp0_add_x_a;
    wire [64:0] i_mptr_bitcast_index58_slavereg_comp0_add_x_b;
    logic [64:0] i_mptr_bitcast_index58_slavereg_comp0_add_x_o;
    wire [64:0] i_mptr_bitcast_index58_slavereg_comp0_add_x_q;
    wire [63:0] i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b;
    wire [0:0] i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_o_stall;
    wire [0:0] i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_o_valid;
    wire [0:0] i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_c0_exit25_1_tpl;
    wire [31:0] i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_c0_exit25_2_tpl;
    wire [63:0] i_unnamed_slavereg_comp21_sel_x_b;
    wire [0:0] slavereg_comp_B3_merge_reg_aunroll_x_out_stall_out;
    wire [0:0] slavereg_comp_B3_merge_reg_aunroll_x_out_valid_out;
    wire [0:0] slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl;
    wire [0:0] i_exitcond_slavereg_comp29_cmp_nsign_q;
    wire [13:0] i_mul_slavereg_comp45_bs1_b;
    wire [17:0] i_mul_slavereg_comp45_bs4_in;
    wire [17:0] i_mul_slavereg_comp45_bs4_b;
    wire [63:0] i_mul_slavereg_comp45_sums_join_0_q;
    wire [50:0] i_mul_slavereg_comp45_sums_align_1_q;
    wire [50:0] i_mul_slavereg_comp45_sums_align_1_qint;
    wire [64:0] i_mul_slavereg_comp45_sums_result_add_0_0_a;
    wire [64:0] i_mul_slavereg_comp45_sums_result_add_0_0_b;
    logic [64:0] i_mul_slavereg_comp45_sums_result_add_0_0_o;
    wire [64:0] i_mul_slavereg_comp45_sums_result_add_0_0_q;
    wire [2:0] leftShiftStage0Idx1Rng1_uid229_i_cleanups_shl_slavereg_comp0_shift_x_in;
    wire [2:0] leftShiftStage0Idx1Rng1_uid229_i_cleanups_shl_slavereg_comp0_shift_x_b;
    wire [3:0] leftShiftStage0Idx1_uid230_i_cleanups_shl_slavereg_comp0_shift_x_q;
    wire [0:0] leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_s;
    reg [3:0] leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_q;
    wire [2:0] rightShiftStage0Idx1Rng1_uid236_i_next_initerations_slavereg_comp0_shift_x_b;
    wire [3:0] rightShiftStage0Idx1_uid238_i_next_initerations_slavereg_comp0_shift_x_q;
    wire [0:0] rightShiftStage0_uid240_i_next_initerations_slavereg_comp0_shift_x_s;
    reg [3:0] rightShiftStage0_uid240_i_next_initerations_slavereg_comp0_shift_x_q;
    wire i_mul_slavereg_comp45_im0_cma_reset;
    wire [13:0] i_mul_slavereg_comp45_im0_cma_a0;
    wire [13:0] i_mul_slavereg_comp45_im0_cma_c0;
    wire [27:0] i_mul_slavereg_comp45_im0_cma_s0;
    wire [27:0] i_mul_slavereg_comp45_im0_cma_qq;
    wire [27:0] i_mul_slavereg_comp45_im0_cma_q;
    wire i_mul_slavereg_comp45_im0_cma_ena0;
    wire i_mul_slavereg_comp45_im0_cma_ena1;
    wire i_mul_slavereg_comp45_im0_cma_ena2;
    wire i_mul_slavereg_comp45_im8_cma_reset;
    wire [17:0] i_mul_slavereg_comp45_im8_cma_a0;
    wire [17:0] i_mul_slavereg_comp45_im8_cma_c0;
    wire [35:0] i_mul_slavereg_comp45_im8_cma_s0;
    wire [35:0] i_mul_slavereg_comp45_im8_cma_qq;
    wire [35:0] i_mul_slavereg_comp45_im8_cma_q;
    wire i_mul_slavereg_comp45_im8_cma_ena0;
    wire i_mul_slavereg_comp45_im8_cma_ena1;
    wire i_mul_slavereg_comp45_im8_cma_ena2;
    wire i_mul_slavereg_comp45_ma3_cma_reset;
    wire [13:0] i_mul_slavereg_comp45_ma3_cma_a0;
    wire [17:0] i_mul_slavereg_comp45_ma3_cma_c0;
    wire [13:0] i_mul_slavereg_comp45_ma3_cma_a1;
    wire [17:0] i_mul_slavereg_comp45_ma3_cma_c1;
    wire [32:0] i_mul_slavereg_comp45_ma3_cma_s0;
    wire [32:0] i_mul_slavereg_comp45_ma3_cma_qq;
    wire [32:0] i_mul_slavereg_comp45_ma3_cma_q;
    wire i_mul_slavereg_comp45_ma3_cma_ena0;
    wire i_mul_slavereg_comp45_ma3_cma_ena1;
    wire i_mul_slavereg_comp45_ma3_cma_ena2;
    wire [13:0] i_mul_slavereg_comp45_bs2_merged_bit_select_b;
    wire [17:0] i_mul_slavereg_comp45_bs2_merged_bit_select_c;
    wire [0:0] redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_in;
    wire redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_in;
    wire redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_data_in;
    wire [0:0] redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_out;
    wire redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_out;
    wire redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_data_out;
    reg [0:0] redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_q;
    wire [0:0] redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_in;
    wire redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_in;
    wire redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_data_in;
    wire [0:0] redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_out;
    wire redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_out;
    wire redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_data_out;
    reg [0:0] redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_q;
    reg [0:0] redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_q;
    wire [0:0] redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_in;
    wire redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_in;
    wire redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_data_in;
    wire [0:0] redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_out;
    wire redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_out;
    wire redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_data_out;
    wire [0:0] redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_in;
    wire redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_in;
    wire redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_in_bitsignaltemp;
    wire [63:0] redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_data_in;
    wire [0:0] redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_out;
    wire redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_out;
    wire redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_out_bitsignaltemp;
    wire [63:0] redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_data_out;
    wire [0:0] redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_in;
    wire redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_in;
    wire redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_in_bitsignaltemp;
    wire [63:0] redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_data_in;
    wire [0:0] redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_out;
    wire redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_out;
    wire redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_out_bitsignaltemp;
    wire [63:0] redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_data_out;
    wire [0:0] redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_in;
    wire redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_in;
    wire redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_in_bitsignaltemp;
    wire [63:0] redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_data_in;
    wire [0:0] redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_out;
    wire redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_out;
    wire redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_out_bitsignaltemp;
    wire [63:0] redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_data_out;
    wire [0:0] redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_in;
    wire redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_in;
    wire redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_data_in;
    wire [0:0] redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_out;
    wire redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_out;
    wire redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_data_out;
    wire [0:0] redist9_i_masked_slavereg_comp43_q_465_fifo_valid_in;
    wire redist9_i_masked_slavereg_comp43_q_465_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist9_i_masked_slavereg_comp43_q_465_fifo_stall_in;
    wire redist9_i_masked_slavereg_comp43_q_465_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist9_i_masked_slavereg_comp43_q_465_fifo_data_in;
    wire [0:0] redist9_i_masked_slavereg_comp43_q_465_fifo_valid_out;
    wire redist9_i_masked_slavereg_comp43_q_465_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist9_i_masked_slavereg_comp43_q_465_fifo_stall_out;
    wire redist9_i_masked_slavereg_comp43_q_465_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist9_i_masked_slavereg_comp43_q_465_fifo_data_out;
    wire [0:0] redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_in;
    wire redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_in;
    wire redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_data_in;
    wire [0:0] redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_out;
    wire redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_out;
    wire redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_data_out;
    wire [0:0] redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_in;
    wire redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_in;
    wire redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_data_in;
    wire [0:0] redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_out;
    wire redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_out;
    wire redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_data_out;
    wire [0:0] redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_in;
    wire redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_in;
    wire redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_data_in;
    wire [0:0] redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_out;
    wire redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_out;
    wire redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_data_out;
    wire [0:0] redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_in;
    wire redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_in;
    wire redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_data_in;
    wire [0:0] redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_out;
    wire redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_out;
    wire redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_data_out;
    wire [0:0] redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_in;
    wire redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_in;
    wire redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_data_in;
    wire [0:0] redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_out;
    wire redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_out;
    wire redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_data_out;
    wire [0:0] redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_in;
    wire redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_in;
    wire redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_data_in;
    wire [0:0] redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_out;
    wire redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_out;
    wire redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_data_out;
    wire [0:0] redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_in;
    wire redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_in;
    wire redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_data_in;
    wire [0:0] redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_out;
    wire redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_out;
    wire redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_data_out;
    wire [0:0] redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_in;
    wire redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_in;
    wire redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_data_in;
    wire [0:0] redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_out;
    wire redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_out;
    wire redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_data_out;
    wire [0:0] redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_in;
    wire redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_in;
    wire redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_data_in;
    wire [0:0] redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_out;
    wire redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_out;
    wire redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_data_out;
    wire [0:0] redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_in;
    wire redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_in_bitsignaltemp;
    wire [0:0] redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_in;
    wire redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_in_bitsignaltemp;
    wire [0:0] redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_data_in;
    wire [0:0] redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_out;
    wire redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_out_bitsignaltemp;
    wire [0:0] redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_out;
    wire redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_out_bitsignaltemp;
    wire [0:0] redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_data_out;
    wire [31:0] bubble_join_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_q;
    wire [31:0] bubble_select_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_b;
    wire [31:0] bubble_join_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_q;
    wire [31:0] bubble_select_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_b;
    wire [32:0] bubble_join_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_q;
    wire [32:0] bubble_select_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_b;
    wire [63:0] bubble_join_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_q;
    wire [63:0] bubble_select_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_b;
    wire [63:0] bubble_join_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_q;
    wire [63:0] bubble_select_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_b;
    wire [63:0] bubble_join_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_q;
    wire [63:0] bubble_select_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_b;
    wire [31:0] bubble_join_i_llvm_fpga_mem_lm1_slavereg_comp41_q;
    wire [31:0] bubble_select_i_llvm_fpga_mem_lm1_slavereg_comp41_b;
    wire [31:0] bubble_join_i_llvm_fpga_mem_lm22_slavereg_comp52_q;
    wire [31:0] bubble_select_i_llvm_fpga_mem_lm22_slavereg_comp52_b;
    wire [0:0] bubble_join_i_llvm_fpga_mem_memdep_5_slavereg_comp57_q;
    wire [0:0] bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_b;
    wire [0:0] bubble_join_i_llvm_fpga_mem_memdep_slavereg_comp48_q;
    wire [0:0] bubble_select_i_llvm_fpga_mem_memdep_slavereg_comp48_b;
    wire [0:0] bubble_join_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_q;
    wire [0:0] bubble_select_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_b;
    wire [0:0] bubble_join_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_q;
    wire [0:0] bubble_select_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_b;
    wire [0:0] bubble_join_i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_q;
    wire [0:0] bubble_select_i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_b;
    wire [0:0] bubble_join_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_q;
    wire [0:0] bubble_select_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_b;
    wire [0:0] bubble_join_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_q;
    wire [0:0] bubble_select_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_b;
    wire [31:0] bubble_join_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_q;
    wire [31:0] bubble_select_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_b;
    wire [32:0] bubble_join_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_q;
    wire [32:0] bubble_select_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_b;
    wire [3:0] bubble_join_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_q;
    wire [3:0] bubble_select_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_b;
    wire [3:0] bubble_join_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_q;
    wire [3:0] bubble_select_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_b;
    wire [0:0] bubble_join_stall_entry_q;
    wire [0:0] bubble_select_stall_entry_b;
    wire [32:0] bubble_join_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_q;
    wire [0:0] bubble_select_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_b;
    wire [31:0] bubble_select_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_c;
    wire [0:0] bubble_join_slavereg_comp_B3_merge_reg_aunroll_x_q;
    wire [0:0] bubble_select_slavereg_comp_B3_merge_reg_aunroll_x_b;
    wire [27:0] bubble_join_i_mul_slavereg_comp45_im0_cma_q;
    wire [27:0] bubble_select_i_mul_slavereg_comp45_im0_cma_b;
    wire [35:0] bubble_join_i_mul_slavereg_comp45_im8_cma_q;
    wire [35:0] bubble_select_i_mul_slavereg_comp45_im8_cma_b;
    wire [32:0] bubble_join_i_mul_slavereg_comp45_ma3_cma_q;
    wire [32:0] bubble_select_i_mul_slavereg_comp45_ma3_cma_b;
    wire [0:0] bubble_join_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_q;
    wire [0:0] bubble_select_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_b;
    wire [0:0] bubble_join_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_q;
    wire [0:0] bubble_select_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_b;
    wire [0:0] bubble_join_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_q;
    wire [0:0] bubble_select_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_b;
    wire [63:0] bubble_join_redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_q;
    wire [63:0] bubble_select_redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_b;
    wire [63:0] bubble_join_redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_q;
    wire [63:0] bubble_select_redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_b;
    wire [63:0] bubble_join_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_q;
    wire [63:0] bubble_select_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_b;
    wire [0:0] bubble_join_redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_q;
    wire [0:0] bubble_select_redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_b;
    wire [0:0] bubble_join_redist9_i_masked_slavereg_comp43_q_465_fifo_q;
    wire [0:0] bubble_select_redist9_i_masked_slavereg_comp43_q_465_fifo_b;
    wire [0:0] bubble_join_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_q;
    wire [0:0] bubble_select_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_b;
    wire [0:0] bubble_join_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_q;
    wire [0:0] bubble_select_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_b;
    wire [0:0] bubble_join_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_q;
    wire [0:0] bubble_select_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_b;
    wire [0:0] bubble_join_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_q;
    wire [0:0] bubble_select_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_b;
    wire [0:0] bubble_join_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_q;
    wire [0:0] bubble_select_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_b;
    wire [0:0] bubble_join_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_q;
    wire [0:0] bubble_select_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_b;
    wire [0:0] bubble_join_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_q;
    wire [0:0] bubble_select_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_b;
    wire [0:0] bubble_join_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_q;
    wire [0:0] bubble_select_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_b;
    wire [0:0] bubble_join_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_q;
    wire [0:0] bubble_select_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_b;
    wire [0:0] bubble_join_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_q;
    wire [0:0] bubble_select_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_b;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireValid;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireStall;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_StallValid;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_toReg0;
    reg [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg0;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed0;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_toReg1;
    reg [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg1;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed1;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_toReg2;
    reg [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg2;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed2;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_and0;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_and1;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_or0;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_or1;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_backStall;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_V0;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_V1;
    wire [0:0] SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_V2;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_and0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_or0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_V0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_V1;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_V0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_or0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_V0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_V1;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_and0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_V0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_and0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_or0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_backStall;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_V0;
    wire [0:0] SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_V1;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_or0;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_backStall;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_V0;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_V1;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm22_slavereg_comp52_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm22_slavereg_comp52_backStall;
    wire [0:0] SE_out_i_llvm_fpga_mem_lm22_slavereg_comp52_V0;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_or0;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_backStall;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V0;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V1;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_or0;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_backStall;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_V0;
    wire [0:0] SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_V1;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg2;
    reg [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg2;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed2;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg3;
    reg [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg3;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed3;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg4;
    reg [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg4;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed4;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or0;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or1;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or2;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or3;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_backStall;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V0;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V1;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V2;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V3;
    wire [0:0] SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V4;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_or0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_backStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_V0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_V1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_or0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_backStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_V0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_V1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_backStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_V0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_toReg2;
    reg [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg2;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed2;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_or0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_or1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_backStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_V0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_V1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_V2;
    wire [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_or0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_backStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_V0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_V1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg2;
    reg [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg2;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed2;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg3;
    reg [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg3;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed3;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_or0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_or1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_or2;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_backStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V2;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V3;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_wireStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_StallValid;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_toReg0;
    reg [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_fromReg0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_consumed0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_toReg1;
    reg [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_fromReg1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_consumed1;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_or0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_backStall;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_V0;
    wire [0:0] SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_V1;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_wireValid;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_and0;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_V0;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_wireValid;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_and0;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_V0;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_backStall;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_wireValid;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_and0;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_V0;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireValid;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_StallValid;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_toReg0;
    reg [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_fromReg0;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_consumed0;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_toReg1;
    reg [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_fromReg1;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_consumed1;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_and0;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_or0;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_V0;
    wire [0:0] SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_V1;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_wireValid;
    wire [0:0] SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_and0;
    wire [0:0] SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_V0;
    wire [0:0] SE_out_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_wireValid;
    wire [0:0] SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_backStall;
    wire [0:0] SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_V0;
    wire [0:0] SE_out_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_backStall;
    wire [0:0] SE_out_i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_backStall;
    wire [0:0] SE_out_i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_wireValid;
    wire [0:0] SE_out_i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_backStall;
    reg [0:0] SE_i_masked_slavereg_comp43_R_v_0;
    wire [0:0] SE_i_masked_slavereg_comp43_v_s_0;
    wire [0:0] SE_i_masked_slavereg_comp43_s_tv_0;
    wire [0:0] SE_i_masked_slavereg_comp43_backEN;
    wire [0:0] SE_i_masked_slavereg_comp43_backStall;
    wire [0:0] SE_i_masked_slavereg_comp43_V0;
    reg [0:0] SE_i_memdep_phi3_or_slavereg_comp25_R_v_0;
    wire [0:0] SE_i_memdep_phi3_or_slavereg_comp25_v_s_0;
    wire [0:0] SE_i_memdep_phi3_or_slavereg_comp25_s_tv_0;
    wire [0:0] SE_i_memdep_phi3_or_slavereg_comp25_backEN;
    wire [0:0] SE_i_memdep_phi3_or_slavereg_comp25_and0;
    wire [0:0] SE_i_memdep_phi3_or_slavereg_comp25_backStall;
    wire [0:0] SE_i_memdep_phi3_or_slavereg_comp25_V0;
    wire [0:0] SE_i_memdep_phi6_or_slavereg_comp23_wireValid;
    wire [0:0] SE_i_memdep_phi6_or_slavereg_comp23_and0;
    wire [0:0] SE_i_memdep_phi6_or_slavereg_comp23_and1;
    wire [0:0] SE_i_memdep_phi6_or_slavereg_comp23_and2;
    wire [0:0] SE_i_memdep_phi6_or_slavereg_comp23_backStall;
    wire [0:0] SE_i_memdep_phi6_or_slavereg_comp23_V0;
    wire [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_wireValid;
    wire [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_wireStall;
    wire [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_StallValid;
    wire [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_toReg0;
    reg [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_fromReg0;
    wire [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_consumed0;
    wire [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_toReg1;
    reg [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_fromReg1;
    wire [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_consumed1;
    wire [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_or0;
    wire [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_backStall;
    wire [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_V0;
    wire [0:0] SE_i_next_initerations_slavereg_comp19_vt_join_V1;
    wire [0:0] SE_stall_entry_wireValid;
    wire [0:0] SE_stall_entry_backStall;
    wire [0:0] SE_stall_entry_V0;
    wire [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_wireValid;
    wire [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_wireStall;
    wire [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_StallValid;
    wire [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_toReg0;
    reg [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_fromReg0;
    wire [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_consumed0;
    wire [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_toReg1;
    reg [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_fromReg1;
    wire [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_consumed1;
    wire [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_or0;
    wire [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_backStall;
    wire [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_V0;
    wire [0:0] SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_V1;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireStall;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_StallValid;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg0;
    reg [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg0;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed0;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg1;
    reg [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg1;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed1;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg2;
    reg [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg2;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed2;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg3;
    reg [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg3;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed3;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg4;
    reg [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg4;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed4;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg5;
    reg [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg5;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed5;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg6;
    reg [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg6;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed6;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or0;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or1;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or2;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or3;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or4;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or5;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_backStall;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V0;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V1;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V2;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V3;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V4;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V5;
    wire [0:0] SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V6;
    wire [0:0] SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_wireValid;
    wire [0:0] SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_backStall;
    wire [0:0] SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_V0;
    reg [0:0] SE_i_mul_slavereg_comp45_im0_cma_R_s_0;
    reg [0:0] SE_i_mul_slavereg_comp45_im0_cma_R_s_1;
    reg [0:0] SE_i_mul_slavereg_comp45_im0_cma_R_v_0;
    reg [0:0] SE_i_mul_slavereg_comp45_im0_cma_R_v_1;
    reg [0:0] SE_i_mul_slavereg_comp45_im0_cma_R_v_2;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_v_s_0;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_s_tv_0;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_s_tv_1;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_s_tv_2;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_backEN;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_and0;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_or0;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_or1;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_backStall;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_V0;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_V1;
    wire [0:0] SE_i_mul_slavereg_comp45_im0_cma_V2;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireStall;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_StallValid;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg0;
    reg [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg0;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed0;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg1;
    reg [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg1;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed1;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg2;
    reg [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg2;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed2;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg3;
    reg [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg3;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed3;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg4;
    reg [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg4;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed4;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg5;
    reg [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg5;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed5;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg6;
    reg [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg6;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed6;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or0;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or1;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or2;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or3;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or4;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or5;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_backStall;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V0;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V1;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V2;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V3;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V4;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V5;
    wire [0:0] SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V6;
    reg [0:0] SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_0;
    reg [0:0] SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_1;
    wire [0:0] SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_v_s_0;
    wire [0:0] SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_s_tv_0;
    wire [0:0] SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_s_tv_1;
    wire [0:0] SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_backEN;
    wire [0:0] SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_or0;
    wire [0:0] SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_backStall;
    wire [0:0] SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_V0;
    wire [0:0] SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_V1;
    wire [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_wireValid;
    wire [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_wireStall;
    wire [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_StallValid;
    wire [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_toReg0;
    reg [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_fromReg0;
    wire [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_consumed0;
    wire [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_toReg1;
    reg [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_fromReg1;
    wire [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_consumed1;
    wire [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_or0;
    wire [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_backStall;
    wire [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_V0;
    wire [0:0] SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_V1;
    reg [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_R_v_0;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_v_s_0;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_s_tv_0;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_backEN;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_backStall;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_V0;
    reg [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_0;
    reg [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_1;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_v_s_0;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_s_tv_0;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_s_tv_1;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_backEN;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_or0;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_backStall;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_V0;
    wire [0:0] SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_V1;
    wire [0:0] SE_out_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_wireValid;
    wire [0:0] SE_out_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_backStall;
    wire [0:0] SE_out_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_V0;
    wire [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_wireValid;
    wire [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_wireStall;
    wire [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_StallValid;
    wire [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_toReg0;
    reg [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_fromReg0;
    wire [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_consumed0;
    wire [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_toReg1;
    reg [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_fromReg1;
    wire [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_consumed1;
    wire [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_or0;
    wire [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_backStall;
    wire [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_V0;
    wire [0:0] SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_V1;
    wire [0:0] SE_in_redist9_i_masked_slavereg_comp43_q_465_fifo_wireValid;
    wire [0:0] SE_in_redist9_i_masked_slavereg_comp43_q_465_fifo_backStall;
    wire [0:0] SE_in_redist9_i_masked_slavereg_comp43_q_465_fifo_V0;
    wire [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_wireValid;
    wire [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_wireStall;
    wire [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_StallValid;
    wire [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_toReg0;
    reg [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_fromReg0;
    wire [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_consumed0;
    wire [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_toReg1;
    reg [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_fromReg1;
    wire [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_consumed1;
    wire [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_or0;
    wire [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_backStall;
    wire [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_V0;
    wire [0:0] SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_V1;
    wire [0:0] SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_wireValid;
    wire [0:0] SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_and0;
    wire [0:0] SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_and1;
    wire [0:0] SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_and2;
    wire [0:0] SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_backStall;
    wire [0:0] SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_V0;
    wire [0:0] SE_out_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_wireValid;
    wire [0:0] SE_out_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_backStall;
    wire [0:0] SE_out_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_V0;
    wire [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_wireValid;
    wire [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_wireStall;
    wire [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_StallValid;
    wire [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_toReg0;
    reg [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_fromReg0;
    wire [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_consumed0;
    wire [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_toReg1;
    reg [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_fromReg1;
    wire [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_consumed1;
    wire [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_or0;
    wire [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_backStall;
    wire [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_V0;
    wire [0:0] SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_V1;
    wire [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_wireValid;
    wire [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_wireStall;
    wire [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_StallValid;
    wire [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_toReg0;
    reg [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_fromReg0;
    wire [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_consumed0;
    wire [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_toReg1;
    reg [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_fromReg1;
    wire [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_consumed1;
    wire [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_or0;
    wire [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_backStall;
    wire [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_V0;
    wire [0:0] SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_V1;
    wire [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_wireValid;
    wire [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_wireStall;
    wire [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_StallValid;
    wire [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_toReg0;
    reg [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_fromReg0;
    wire [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_consumed0;
    wire [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_toReg1;
    reg [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_fromReg1;
    wire [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_consumed1;
    wire [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_or0;
    wire [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_backStall;
    wire [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_V0;
    wire [0:0] SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_V1;
    wire [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_wireValid;
    wire [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_wireStall;
    wire [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_StallValid;
    wire [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_toReg0;
    reg [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_fromReg0;
    wire [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_consumed0;
    wire [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_toReg1;
    reg [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_fromReg1;
    wire [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_consumed1;
    wire [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_or0;
    wire [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_backStall;
    wire [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_V0;
    wire [0:0] SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_V1;
    wire [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_wireValid;
    wire [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_wireStall;
    wire [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_StallValid;
    wire [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_toReg0;
    reg [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_fromReg0;
    wire [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_consumed0;
    wire [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_toReg1;
    reg [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_fromReg1;
    wire [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_consumed1;
    wire [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_or0;
    wire [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_backStall;
    wire [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_V0;
    wire [0:0] SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_V1;
    wire [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_wireValid;
    wire [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_wireStall;
    wire [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_StallValid;
    wire [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_toReg0;
    reg [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_fromReg0;
    wire [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_consumed0;
    wire [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_toReg1;
    reg [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_fromReg1;
    wire [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_consumed1;
    wire [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_or0;
    wire [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_backStall;
    wire [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_V0;
    wire [0:0] SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_V1;
    wire [0:0] SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_wireValid;
    wire [0:0] SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_and0;
    wire [0:0] SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_and1;
    wire [0:0] SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_and2;
    wire [0:0] SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_backStall;
    wire [0:0] SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_V0;
    wire [0:0] SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireValid;
    wire [0:0] SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_backStall;
    wire [0:0] SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V0;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_wireValid;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and0;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and1;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and2;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and3;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and4;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_backStall;
    wire [0:0] SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_V0;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_wireValid;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_backStall;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_V0;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_wireValid;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_backStall;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_V0;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_wireValid;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_backStall;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_V0;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_wireValid;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_backStall;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_V0;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_wireValid;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_backStall;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_V0;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_wireValid;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_backStall;
    wire [0:0] SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_V0;
    wire [0:0] SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_wireValid;
    wire [0:0] SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and0;
    wire [0:0] SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and1;
    wire [0:0] SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and2;
    wire [0:0] SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and3;
    wire [0:0] SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and4;
    wire [0:0] SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and5;
    wire [0:0] SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and6;
    wire [0:0] SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_backStall;
    wire [0:0] SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_V0;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_in;
    wire bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_in;
    wire bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_out;
    wire bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_out;
    wire bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_in;
    wire bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_in;
    wire bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_out;
    wire bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_out;
    wire bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_in;
    wire bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_in;
    wire bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_out;
    wire bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_out;
    wire bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_in;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_in_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_out;
    wire bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_out_bitsignaltemp;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_in;
    wire bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_in;
    wire bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_in_bitsignaltemp;
    wire [27:0] bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_data_in;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_out;
    wire bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_out;
    wire bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_out_bitsignaltemp;
    wire [27:0] bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_data_out;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_in;
    wire bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_in;
    wire bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_in_bitsignaltemp;
    wire [35:0] bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_data_in;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_out;
    wire bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_out;
    wire bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_out_bitsignaltemp;
    wire [35:0] bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_data_out;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_in;
    wire bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_in_bitsignaltemp;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_in;
    wire bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_in_bitsignaltemp;
    wire [32:0] bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_data_in;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_out;
    wire bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_out_bitsignaltemp;
    wire [0:0] bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_out;
    wire bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_out_bitsignaltemp;
    wire [32:0] bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_data_out;
    wire [0:0] SR_SE_i_masked_slavereg_comp43_i_valid;
    reg [0:0] SR_SE_i_masked_slavereg_comp43_r_valid;
    wire [0:0] SR_SE_i_masked_slavereg_comp43_and0;
    reg [0:0] SR_SE_i_masked_slavereg_comp43_r_data0;
    reg [0:0] SR_SE_i_masked_slavereg_comp43_r_data1;
    wire [0:0] SR_SE_i_masked_slavereg_comp43_backStall;
    wire [0:0] SR_SE_i_masked_slavereg_comp43_V;
    wire [0:0] SR_SE_i_masked_slavereg_comp43_D0;
    wire [0:0] SR_SE_i_masked_slavereg_comp43_D1;
    wire [0:0] SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_i_valid;
    reg [0:0] SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_valid;
    reg [0:0] SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_data0;
    reg [0:0] SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_data1;
    wire [0:0] SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_backStall;
    wire [0:0] SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_V;
    wire [0:0] SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_D0;
    wire [0:0] SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_D1;
    wire [0:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_i_valid;
    reg [0:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid;
    wire [0:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_and0;
    reg [0:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data0;
    reg [0:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data1;
    reg [0:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data2;
    reg [3:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data3;
    wire [0:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_backStall;
    wire [0:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_V;
    wire [0:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_D0;
    wire [0:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_D1;
    wire [0:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_D2;
    wire [3:0] SR_SE_i_next_initerations_slavereg_comp19_vt_join_D3;
    wire [0:0] SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_i_valid;
    reg [0:0] SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_valid;
    wire [0:0] SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_and0;
    reg [0:0] SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_data0;
    reg [0:0] SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_data1;
    wire [0:0] SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_backStall;
    wire [0:0] SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V;
    wire [0:0] SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_D0;
    wire [0:0] SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_D1;
    wire [0:0] SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_i_valid;
    reg [0:0] SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_valid;
    wire [0:0] SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_and0;
    reg [32:0] SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_data0;
    reg [0:0] SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_data1;
    wire [0:0] SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_backStall;
    wire [0:0] SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_V;
    wire [32:0] SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_D0;
    wire [0:0] SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_D1;
    wire [0:0] SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_i_valid;
    reg [0:0] SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_valid;
    wire [0:0] SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_and0;
    wire [0:0] SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_and1;
    reg [3:0] SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_data0;
    reg [0:0] SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_data1;
    wire [0:0] SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_backStall;
    wire [0:0] SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_V;
    wire [3:0] SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_D0;
    wire [0:0] SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_D1;


    // VCC(CONSTANT,1)
    assign VCC_q = $unsigned(1'b1);

    // bubble_join_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6(BITJOIN,342)
    assign bubble_join_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_q = i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_data_out;

    // bubble_select_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6(BITSELECT,343)
    assign bubble_select_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_b = $unsigned(bubble_join_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_q[3:0]);

    // i_first_cleanup_slavereg_comp17_sel_x(BITSELECT,171)@467
    assign i_first_cleanup_slavereg_comp17_sel_x_b = bubble_select_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_b[0:0];

    // i_first_cleanup_xor_slavereg_comp26(LOGICAL,24)@467
    assign i_first_cleanup_xor_slavereg_comp26_q = i_first_cleanup_slavereg_comp17_sel_x_b ^ VCC_q;

    // c_i32_062(CONSTANT,7)
    assign c_i32_062_q = $unsigned(32'b00000000000000000000000000000000);

    // bubble_join_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1(BITJOIN,287)
    assign bubble_join_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_q = i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_out_dest_data_out_0_0;

    // bubble_select_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1(BITSELECT,288)
    assign bubble_select_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_b = $unsigned(bubble_join_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_q[31:0]);

    // i_cmp49_slavereg_comp15(LOGICAL,20)@467
    assign i_cmp49_slavereg_comp15_q = $unsigned(bubble_select_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_b == c_i32_062_q ? 1'b1 : 1'b0);

    // i_first_cleanup_xor_or_slavereg_comp36(LOGICAL,23)@467
    assign i_first_cleanup_xor_or_slavereg_comp36_q = i_cmp49_slavereg_comp15_q | i_first_cleanup_xor_slavereg_comp26_q;

    // bubble_join_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo(BITJOIN,419)
    assign bubble_join_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_q = redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_data_out;

    // bubble_select_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo(BITSELECT,420)
    assign bubble_select_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_b = $unsigned(bubble_join_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_q[0:0]);

    // bubble_join_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo(BITJOIN,422)
    assign bubble_join_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_q = redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_data_out;

    // bubble_select_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo(BITSELECT,423)
    assign bubble_select_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_b = $unsigned(bubble_join_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_q[0:0]);

    // bubble_join_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12(BITJOIN,329)
    assign bubble_join_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_q = i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out;

    // bubble_select_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12(BITSELECT,330)
    assign bubble_select_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_b = $unsigned(bubble_join_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_q[0:0]);

    // SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12(STALLENABLE,462)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_fromReg0 <= '0;
            SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_fromReg0 <= SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_fromReg1 <= SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_consumed0 = (~ (SE_i_memdep_phi6_or_slavereg_comp23_backStall) & SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_wireValid) | SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_fromReg0;
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_consumed1 = (~ (redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_out) & SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_wireValid) | SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_fromReg1;
    // Consuming
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_StallValid = SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_backStall & SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_wireValid;
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_toReg0 = SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_StallValid & SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_consumed0;
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_toReg1 = SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_StallValid & SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_consumed1;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_or0 = SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_consumed0;
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_wireStall = ~ (SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_consumed1 & SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_or0);
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_backStall = SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_V0 = SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_wireValid & ~ (SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_fromReg0);
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_V1 = SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_wireValid & ~ (SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_wireValid = i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_valid_out;

    // redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo(STALLFIFO,276)
    assign redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_in = SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_V1;
    assign redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_in = SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_backStall;
    assign redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_data_in = bubble_select_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_b;
    assign redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_in_bitsignaltemp = redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_in[0];
    assign redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_in_bitsignaltemp = redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_in[0];
    assign redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_out[0] = redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_out_bitsignaltemp;
    assign redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_out[0] = redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(139),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo (
        .valid_in(redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_in_bitsignaltemp),
        .stall_in(redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_in_bitsignaltemp),
        .data_in(bubble_select_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_b),
        .valid_out(redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_out_bitsignaltemp),
        .stall_out(redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_stall_out_bitsignaltemp),
        .data_out(redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo(BITJOIN,398)
    assign bubble_join_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_q = redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_data_out;

    // bubble_select_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo(BITSELECT,399)
    assign bubble_select_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_b = $unsigned(bubble_join_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_q[0:0]);

    // SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo(STALLENABLE,560)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_fromReg0 <= '0;
            SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_fromReg0 <= SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_toReg0;
            // Successor 1
            SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_fromReg1 <= SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_consumed0 = (~ (SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_backStall) & SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_wireValid) | SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_fromReg0;
    assign SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_consumed1 = (~ (redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_out) & SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_wireValid) | SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_fromReg1;
    // Consuming
    assign SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_StallValid = SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_backStall & SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_wireValid;
    assign SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_toReg0 = SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_StallValid & SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_consumed0;
    assign SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_toReg1 = SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_StallValid & SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_consumed1;
    // Backward Stall generation
    assign SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_or0 = SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_consumed0;
    assign SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_wireStall = ~ (SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_consumed1 & SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_or0);
    assign SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_backStall = SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_wireStall;
    // Valid signal propagation
    assign SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_V0 = SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_wireValid & ~ (SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_fromReg0);
    assign SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_V1 = SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_wireValid & ~ (SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_wireValid = redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_valid_out;

    // redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo(STALLFIFO,277)
    assign redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_in = SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_V1;
    assign redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_in = SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_backStall;
    assign redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_data_in = bubble_select_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_b;
    assign redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_in_bitsignaltemp = redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_in[0];
    assign redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_in_bitsignaltemp = redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_in[0];
    assign redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_out[0] = redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_out_bitsignaltemp;
    assign redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_out[0] = redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(91),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo (
        .valid_in(redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_in_bitsignaltemp),
        .stall_in(redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_in_bitsignaltemp),
        .data_in(bubble_select_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_b),
        .valid_out(redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_out_bitsignaltemp),
        .stall_out(redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_stall_out_bitsignaltemp),
        .data_out(redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo(BITJOIN,401)
    assign bubble_join_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_q = redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_data_out;

    // bubble_select_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo(BITSELECT,402)
    assign bubble_select_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_b = $unsigned(bubble_join_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_q[0:0]);

    // SE_out_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47(STALLENABLE,482)
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_backStall = $unsigned(1'b0);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_wireValid = i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_valid_out;

    // bubble_join_i_llvm_fpga_pipeline_keep_going_slavereg_comp7(BITJOIN,319)
    assign bubble_join_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_q = i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out;

    // bubble_select_i_llvm_fpga_pipeline_keep_going_slavereg_comp7(BITSELECT,320)
    assign bubble_select_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_b = $unsigned(bubble_join_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_q[0:0]);

    // redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo(STALLFIFO,279)
    assign redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_in = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V4;
    assign redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_in = SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_backStall;
    assign redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_data_in = bubble_select_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_b;
    assign redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_in_bitsignaltemp = redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_in[0];
    assign redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_in_bitsignaltemp = redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_in[0];
    assign redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_out[0] = redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_out_bitsignaltemp;
    assign redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_out[0] = redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(136),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo (
        .valid_in(redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_in_bitsignaltemp),
        .stall_in(redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_in_bitsignaltemp),
        .data_in(bubble_select_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_b),
        .valid_out(redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_out_bitsignaltemp),
        .stall_out(redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_out_bitsignaltemp),
        .data_out(redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo(BITJOIN,407)
    assign bubble_join_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_q = redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_data_out;

    // bubble_select_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo(BITSELECT,408)
    assign bubble_select_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_b = $unsigned(bubble_join_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_q[0:0]);

    // redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0(REG,268)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_q <= $unsigned(1'b0);
        end
        else if (SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_backEN == 1'b1)
        begin
            redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_q <= $unsigned(SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_D1);
        end
    end

    // redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1(REG,269)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_q <= $unsigned(1'b0);
        end
        else if (SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_backEN == 1'b1)
        begin
            redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_q <= $unsigned(redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_q);
        end
    end

    // rightShiftStage0Idx1Rng1_uid236_i_next_initerations_slavereg_comp0_shift_x(BITSELECT,235)@932
    assign rightShiftStage0Idx1Rng1_uid236_i_next_initerations_slavereg_comp0_shift_x_b = bubble_select_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_b[3:1];

    // rightShiftStage0Idx1_uid238_i_next_initerations_slavereg_comp0_shift_x(BITJOIN,237)@932
    assign rightShiftStage0Idx1_uid238_i_next_initerations_slavereg_comp0_shift_x_q = {GND_q, rightShiftStage0Idx1Rng1_uid236_i_next_initerations_slavereg_comp0_shift_x_b};

    // bubble_join_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8(BITJOIN,345)
    assign bubble_join_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_q = i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_data_out;

    // bubble_select_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8(BITSELECT,346)
    assign bubble_select_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_b = $unsigned(bubble_join_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_q[3:0]);

    // rightShiftStage0_uid240_i_next_initerations_slavereg_comp0_shift_x(MUX,239)@932
    assign rightShiftStage0_uid240_i_next_initerations_slavereg_comp0_shift_x_s = VCC_q;
    always @(rightShiftStage0_uid240_i_next_initerations_slavereg_comp0_shift_x_s or bubble_select_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_b or rightShiftStage0Idx1_uid238_i_next_initerations_slavereg_comp0_shift_x_q)
    begin
        unique case (rightShiftStage0_uid240_i_next_initerations_slavereg_comp0_shift_x_s)
            1'b0 : rightShiftStage0_uid240_i_next_initerations_slavereg_comp0_shift_x_q = bubble_select_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_b;
            1'b1 : rightShiftStage0_uid240_i_next_initerations_slavereg_comp0_shift_x_q = rightShiftStage0Idx1_uid238_i_next_initerations_slavereg_comp0_shift_x_q;
            default : rightShiftStage0_uid240_i_next_initerations_slavereg_comp0_shift_x_q = 4'b0;
        endcase
    end

    // i_next_initerations_slavereg_comp19_vt_select_2(BITSELECT,68)@932
    assign i_next_initerations_slavereg_comp19_vt_select_2_b = rightShiftStage0_uid240_i_next_initerations_slavereg_comp0_shift_x_q[2:0];

    // i_next_initerations_slavereg_comp19_vt_join(BITJOIN,67)@932
    assign i_next_initerations_slavereg_comp19_vt_join_q = {GND_q, i_next_initerations_slavereg_comp19_vt_select_2_b};

    // redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo(STALLFIFO,280)
    assign redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_in = SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_V1;
    assign redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_in = SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_backStall;
    assign redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_data_in = bubble_select_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_b;
    assign redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_in_bitsignaltemp = redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_in[0];
    assign redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_in_bitsignaltemp = redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_in[0];
    assign redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_out[0] = redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_out_bitsignaltemp;
    assign redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_out[0] = redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(94),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo (
        .valid_in(redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_in_bitsignaltemp),
        .stall_in(redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_in_bitsignaltemp),
        .data_in(bubble_select_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_b),
        .valid_out(redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_out_bitsignaltemp),
        .stall_out(redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_out_bitsignaltemp),
        .data_out(redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo(BITJOIN,410)
    assign bubble_join_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_q = redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_data_out;

    // bubble_select_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo(BITSELECT,411)
    assign bubble_select_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_b = $unsigned(bubble_join_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_q[0:0]);

    // SE_out_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50(STALLENABLE,476)
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_backStall = $unsigned(1'b0);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_wireValid = i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_valid_out;

    // i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50(BLACKBOX,49)@695
    // in in_stall_in@20000000
    // out out_data_out@696
    // out out_feedback_out_9@20000000
    // out out_feedback_valid_out_9@20000000
    // out out_stall_out@20000000
    // out out_valid_out@696
    slavereg_comp_i_llvm_fpga_push_i1_memdep_phi3_push9_0 thei_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50 (
        .in_data_in(bubble_select_i_llvm_fpga_mem_memdep_slavereg_comp48_b),
        .in_feedback_stall_in_9(i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_feedback_stall_out_9),
        .in_keep_going(bubble_select_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_b),
        .in_stall_in(SE_out_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_backStall),
        .in_valid_in(SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_V0),
        .out_data_out(),
        .out_feedback_out_9(i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_feedback_out_9),
        .out_feedback_valid_out_9(i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_feedback_valid_out_9),
        .out_stall_out(i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_stall_out),
        .out_valid_out(i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50(STALLENABLE,475)
    // Valid signal propagation
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_V0 = SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_wireValid;
    // Backward Stall generation
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_backStall = i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_stall_out | ~ (SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_wireValid);
    // Computing multiple Valid(s)
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_and0 = SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_V0;
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_wireValid = SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_V0 & SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_and0;

    // SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo(STALLENABLE,568)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_fromReg0 <= '0;
            SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_fromReg0 <= SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_toReg0;
            // Successor 1
            SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_fromReg1 <= SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_consumed0 = (~ (SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_backStall) & SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_wireValid) | SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_fromReg0;
    assign SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_consumed1 = (~ (redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_out) & SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_wireValid) | SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_fromReg1;
    // Consuming
    assign SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_StallValid = SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_backStall & SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_wireValid;
    assign SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_toReg0 = SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_StallValid & SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_consumed0;
    assign SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_toReg1 = SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_StallValid & SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_consumed1;
    // Backward Stall generation
    assign SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_or0 = SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_consumed0;
    assign SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_wireStall = ~ (SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_consumed1 & SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_or0);
    assign SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_backStall = SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_wireStall;
    // Valid signal propagation
    assign SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_V0 = SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_wireValid & ~ (SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_fromReg0);
    assign SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_V1 = SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_wireValid & ~ (SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_wireValid = redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_valid_out;

    // redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo(STALLFIFO,281)
    assign redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_in = SE_out_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_V1;
    assign redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_in = SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_backStall;
    assign redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_data_in = bubble_select_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_b;
    assign redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_in_bitsignaltemp = redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_in[0];
    assign redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_in_bitsignaltemp = redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_in[0];
    assign redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_out[0] = redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_out_bitsignaltemp;
    assign redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_out[0] = redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(148),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo (
        .valid_in(redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_in_bitsignaltemp),
        .stall_in(redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_in_bitsignaltemp),
        .data_in(bubble_select_redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_b),
        .valid_out(redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_out_bitsignaltemp),
        .stall_out(redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_stall_out_bitsignaltemp),
        .data_out(redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo(BITJOIN,413)
    assign bubble_join_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_q = redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_data_out;

    // bubble_select_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo(BITSELECT,414)
    assign bubble_select_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_b = $unsigned(bubble_join_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_q[0:0]);

    // SE_out_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56(STALLENABLE,478)
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_backStall = $unsigned(1'b0);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_wireValid = i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_valid_out;

    // i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56(BLACKBOX,50)@842
    // in in_stall_in@20000000
    // out out_data_out@843
    // out out_feedback_out_10@20000000
    // out out_feedback_valid_out_10@20000000
    // out out_stall_out@20000000
    // out out_valid_out@843
    slavereg_comp_i_llvm_fpga_push_i1_memdep_phi4_push10_0 thei_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56 (
        .in_data_in(bubble_select_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_b),
        .in_feedback_stall_in_10(i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_feedback_stall_out_10),
        .in_keep_going(bubble_select_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_b),
        .in_stall_in(SE_out_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_backStall),
        .in_valid_in(SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_V0),
        .out_data_out(),
        .out_feedback_out_10(i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_feedback_out_10),
        .out_feedback_valid_out_10(i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_feedback_valid_out_10),
        .out_stall_out(i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_stall_out),
        .out_valid_out(i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56(STALLENABLE,477)
    // Valid signal propagation
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_V0 = SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_wireValid;
    // Backward Stall generation
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_backStall = i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_stall_out | ~ (SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_wireValid);
    // Computing multiple Valid(s)
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_and0 = SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_V1;
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_wireValid = SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_V0 & SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_and0;

    // SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo(STALLENABLE,570)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_fromReg0 <= '0;
            SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_fromReg0 <= SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_toReg0;
            // Successor 1
            SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_fromReg1 <= SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_consumed0 = (~ (SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_backStall) & SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_wireValid) | SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_fromReg0;
    assign SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_consumed1 = (~ (redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_out) & SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_wireValid) | SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_fromReg1;
    // Consuming
    assign SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_StallValid = SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_backStall & SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_wireValid;
    assign SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_toReg0 = SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_StallValid & SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_consumed0;
    assign SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_toReg1 = SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_StallValid & SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_consumed1;
    // Backward Stall generation
    assign SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_or0 = SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_consumed0;
    assign SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_wireStall = ~ (SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_consumed1 & SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_or0);
    assign SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_backStall = SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_wireStall;
    // Valid signal propagation
    assign SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_V0 = SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_wireValid & ~ (SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_fromReg0);
    assign SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_V1 = SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_wireValid & ~ (SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_wireValid = redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_valid_out;

    // redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo(STALLFIFO,282)
    assign redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_in = SE_out_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_V1;
    assign redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_in = SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_backStall;
    assign redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_data_in = bubble_select_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_b;
    assign redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_in_bitsignaltemp = redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_in[0];
    assign redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_in_bitsignaltemp = redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_in[0];
    assign redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_out[0] = redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_out_bitsignaltemp;
    assign redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_out[0] = redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(91),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo (
        .valid_in(redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_in_bitsignaltemp),
        .stall_in(redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_in_bitsignaltemp),
        .data_in(bubble_select_redist15_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_375_fifo_b),
        .valid_out(redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_out_bitsignaltemp),
        .stall_out(redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_stall_out_bitsignaltemp),
        .data_out(redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo(BITJOIN,416)
    assign bubble_join_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_q = redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_data_out;

    // bubble_select_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo(BITSELECT,417)
    assign bubble_select_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_b = $unsigned(bubble_join_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_q[0:0]);

    // i_last_initeration_slavereg_comp28_sel_x(BITSELECT,172)@932
    assign i_last_initeration_slavereg_comp28_sel_x_b = i_next_initerations_slavereg_comp19_vt_join_q[0:0];

    // bubble_join_i_llvm_fpga_mem_memdep_5_slavereg_comp57(BITJOIN,312)
    assign bubble_join_i_llvm_fpga_mem_memdep_5_slavereg_comp57_q = i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_o_writeack;

    // bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57(BITSELECT,313)
    assign bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_b = $unsigned(bubble_join_i_llvm_fpga_mem_memdep_5_slavereg_comp57_q[0:0]);

    // SE_out_i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58(STALLENABLE,480)
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_backStall = $unsigned(1'b0);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_wireValid = i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_valid_out;

    // i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58(BLACKBOX,51)@932
    // in in_stall_in@20000000
    // out out_data_out@933
    // out out_feedback_out_11@20000000
    // out out_feedback_valid_out_11@20000000
    // out out_stall_out@20000000
    // out out_valid_out@933
    slavereg_comp_i_llvm_fpga_push_i1_memdep_phi6_push11_0 thei_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58 (
        .in_data_in(SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_D0),
        .in_feedback_stall_in_11(i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_feedback_stall_out_11),
        .in_keep_going(SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_D1),
        .in_stall_in(SE_out_i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_backStall),
        .in_valid_in(SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V0),
        .out_data_out(),
        .out_feedback_out_11(i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_feedback_out_11),
        .out_feedback_valid_out_11(i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_feedback_valid_out_11),
        .out_stall_out(i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_stall_out),
        .out_valid_out(i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57(STALLENABLE,616)
    // Valid signal propagation
    assign SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V0 = SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireValid;
    // Backward Stall generation
    assign SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_backStall = i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_stall_out | ~ (SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireValid);
    // Computing multiple Valid(s)
    assign SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireValid = SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V;

    // SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57(STALLREG,790)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_valid <= 1'b0;
            SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_data0 <= 1'bx;
            SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_data1 <= 1'bx;
        end
        else
        begin
            // Valid
            SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_valid <= SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_backStall & (SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_valid | SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_i_valid);

            if (SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_valid == 1'b0)
            begin
                // Data(s)
                SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_data0 <= $unsigned(bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_b);
                SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_data1 <= $unsigned(bubble_select_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_b);
            end

        end
    end
    // Computing multiple Valid(s)
    assign SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_and0 = SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V1;
    assign SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_i_valid = SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_V1 & SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_and0;
    // Stall signal propagation
    assign SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_backStall = SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_valid | ~ (SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_i_valid);

    // Valid
    assign SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V = SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_valid == 1'b1 ? SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_valid : SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_i_valid;

    // Data0
    assign SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_D0 = SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_valid == 1'b1 ? SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_data0 : bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_b;
    // Data1
    assign SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_D1 = SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_valid == 1'b1 ? SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_r_data1 : bubble_select_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_b;

    // SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo(STALLENABLE,572)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_fromReg0 <= '0;
            SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_fromReg0 <= SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_toReg0;
            // Successor 1
            SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_fromReg1 <= SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_consumed0 = (~ (SR_SE_i_next_initerations_slavereg_comp19_vt_join_backStall) & SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_wireValid) | SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_fromReg0;
    assign SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_consumed1 = (~ (SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_backStall) & SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_wireValid) | SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_fromReg1;
    // Consuming
    assign SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_StallValid = SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_backStall & SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_wireValid;
    assign SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_toReg0 = SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_StallValid & SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_consumed0;
    assign SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_toReg1 = SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_StallValid & SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_consumed1;
    // Backward Stall generation
    assign SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_or0 = SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_consumed0;
    assign SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_wireStall = ~ (SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_consumed1 & SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_or0);
    assign SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_backStall = SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_wireStall;
    // Valid signal propagation
    assign SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_V0 = SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_wireValid & ~ (SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_fromReg0);
    assign SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_V1 = SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_wireValid & ~ (SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_wireValid = redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_valid_out;

    // SE_i_next_initerations_slavereg_comp19_vt_join(STALLENABLE,499)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_i_next_initerations_slavereg_comp19_vt_join_fromReg0 <= '0;
            SE_i_next_initerations_slavereg_comp19_vt_join_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_i_next_initerations_slavereg_comp19_vt_join_fromReg0 <= SE_i_next_initerations_slavereg_comp19_vt_join_toReg0;
            // Successor 1
            SE_i_next_initerations_slavereg_comp19_vt_join_fromReg1 <= SE_i_next_initerations_slavereg_comp19_vt_join_toReg1;
        end
    end
    // Input Stall processing
    assign SE_i_next_initerations_slavereg_comp19_vt_join_consumed0 = (~ (i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_stall_out) & SE_i_next_initerations_slavereg_comp19_vt_join_wireValid) | SE_i_next_initerations_slavereg_comp19_vt_join_fromReg0;
    assign SE_i_next_initerations_slavereg_comp19_vt_join_consumed1 = (~ (i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_stall_out) & SE_i_next_initerations_slavereg_comp19_vt_join_wireValid) | SE_i_next_initerations_slavereg_comp19_vt_join_fromReg1;
    // Consuming
    assign SE_i_next_initerations_slavereg_comp19_vt_join_StallValid = SE_i_next_initerations_slavereg_comp19_vt_join_backStall & SE_i_next_initerations_slavereg_comp19_vt_join_wireValid;
    assign SE_i_next_initerations_slavereg_comp19_vt_join_toReg0 = SE_i_next_initerations_slavereg_comp19_vt_join_StallValid & SE_i_next_initerations_slavereg_comp19_vt_join_consumed0;
    assign SE_i_next_initerations_slavereg_comp19_vt_join_toReg1 = SE_i_next_initerations_slavereg_comp19_vt_join_StallValid & SE_i_next_initerations_slavereg_comp19_vt_join_consumed1;
    // Backward Stall generation
    assign SE_i_next_initerations_slavereg_comp19_vt_join_or0 = SE_i_next_initerations_slavereg_comp19_vt_join_consumed0;
    assign SE_i_next_initerations_slavereg_comp19_vt_join_wireStall = ~ (SE_i_next_initerations_slavereg_comp19_vt_join_consumed1 & SE_i_next_initerations_slavereg_comp19_vt_join_or0);
    assign SE_i_next_initerations_slavereg_comp19_vt_join_backStall = SE_i_next_initerations_slavereg_comp19_vt_join_wireStall;
    // Valid signal propagation
    assign SE_i_next_initerations_slavereg_comp19_vt_join_V0 = SE_i_next_initerations_slavereg_comp19_vt_join_wireValid & ~ (SE_i_next_initerations_slavereg_comp19_vt_join_fromReg0);
    assign SE_i_next_initerations_slavereg_comp19_vt_join_V1 = SE_i_next_initerations_slavereg_comp19_vt_join_wireValid & ~ (SE_i_next_initerations_slavereg_comp19_vt_join_fromReg1);
    // Computing multiple Valid(s)
    assign SE_i_next_initerations_slavereg_comp19_vt_join_wireValid = SR_SE_i_next_initerations_slavereg_comp19_vt_join_V;

    // SR_SE_i_next_initerations_slavereg_comp19_vt_join(STALLREG,789)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid <= 1'b0;
            SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data0 <= 1'bx;
            SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data1 <= 1'bx;
            SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data2 <= 1'bx;
            SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data3 <= 4'bxxxx;
        end
        else
        begin
            // Valid
            SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid <= SE_i_next_initerations_slavereg_comp19_vt_join_backStall & (SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid | SR_SE_i_next_initerations_slavereg_comp19_vt_join_i_valid);

            if (SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid == 1'b0)
            begin
                // Data(s)
                SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data0 <= i_last_initeration_slavereg_comp28_sel_x_b;
                SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data1 <= $unsigned(bubble_select_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_b);
                SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data2 <= $unsigned(bubble_select_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_b);
                SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data3 <= i_next_initerations_slavereg_comp19_vt_join_q;
            end

        end
    end
    // Computing multiple Valid(s)
    assign SR_SE_i_next_initerations_slavereg_comp19_vt_join_and0 = SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_V1;
    assign SR_SE_i_next_initerations_slavereg_comp19_vt_join_i_valid = SE_out_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_V0 & SR_SE_i_next_initerations_slavereg_comp19_vt_join_and0;
    // Stall signal propagation
    assign SR_SE_i_next_initerations_slavereg_comp19_vt_join_backStall = SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid | ~ (SR_SE_i_next_initerations_slavereg_comp19_vt_join_i_valid);

    // Valid
    assign SR_SE_i_next_initerations_slavereg_comp19_vt_join_V = SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid == 1'b1 ? SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid : SR_SE_i_next_initerations_slavereg_comp19_vt_join_i_valid;

    // Data0
    assign SR_SE_i_next_initerations_slavereg_comp19_vt_join_D0 = SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid == 1'b1 ? SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data0 : i_last_initeration_slavereg_comp28_sel_x_b;
    // Data1
    assign SR_SE_i_next_initerations_slavereg_comp19_vt_join_D1 = SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid == 1'b1 ? SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data1 : bubble_select_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_b;
    // Data2
    assign SR_SE_i_next_initerations_slavereg_comp19_vt_join_D2 = SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid == 1'b1 ? SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data2 : bubble_select_redist16_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_465_fifo_b;
    // Data3
    assign SR_SE_i_next_initerations_slavereg_comp19_vt_join_D3 = SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_valid == 1'b1 ? SR_SE_i_next_initerations_slavereg_comp19_vt_join_r_data3 : i_next_initerations_slavereg_comp19_vt_join_q;

    // c_i33_167(CONSTANT,9)
    assign c_i33_167_q = $unsigned(33'b111111111111111111111111111111111);

    // bubble_join_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0(BITJOIN,293)
    assign bubble_join_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_q = i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_out_dest_data_out_6_0;

    // bubble_select_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0(BITSELECT,294)
    assign bubble_select_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_b = $unsigned(bubble_join_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_q[32:0]);

    // bubble_join_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9(BITJOIN,338)
    assign bubble_join_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_q = i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_data_out;

    // bubble_select_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9(BITSELECT,339)
    assign bubble_select_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_b = $unsigned(bubble_join_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_q[32:0]);

    // redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0(REG,266)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_q <= $unsigned(1'b0);
        end
        else if (SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_backEN == 1'b1)
        begin
            redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_q <= $unsigned(bubble_select_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_b);
        end
    end

    // i_fpga_indvars_iv_replace_phi_slavereg_comp20(MUX,26)@467
    assign i_fpga_indvars_iv_replace_phi_slavereg_comp20_s = redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_q;
    always @(i_fpga_indvars_iv_replace_phi_slavereg_comp20_s or bubble_select_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_b or bubble_select_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_b)
    begin
        unique case (i_fpga_indvars_iv_replace_phi_slavereg_comp20_s)
            1'b0 : i_fpga_indvars_iv_replace_phi_slavereg_comp20_q = bubble_select_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_b;
            1'b1 : i_fpga_indvars_iv_replace_phi_slavereg_comp20_q = bubble_select_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_b;
            default : i_fpga_indvars_iv_replace_phi_slavereg_comp20_q = 33'b0;
        endcase
    end

    // i_fpga_indvars_iv_next_slavereg_comp31(ADD,25)@467
    assign i_fpga_indvars_iv_next_slavereg_comp31_a = {1'b0, i_fpga_indvars_iv_replace_phi_slavereg_comp20_q};
    assign i_fpga_indvars_iv_next_slavereg_comp31_b = {1'b0, c_i33_167_q};
    assign i_fpga_indvars_iv_next_slavereg_comp31_o = $unsigned(i_fpga_indvars_iv_next_slavereg_comp31_a) + $unsigned(i_fpga_indvars_iv_next_slavereg_comp31_b);
    assign i_fpga_indvars_iv_next_slavereg_comp31_q = i_fpga_indvars_iv_next_slavereg_comp31_o[33:0];

    // bgTrunc_i_fpga_indvars_iv_next_slavereg_comp31_sel_x(BITSELECT,152)@467
    assign bgTrunc_i_fpga_indvars_iv_next_slavereg_comp31_sel_x_b = i_fpga_indvars_iv_next_slavereg_comp31_q[32:0];

    // SE_out_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40(STALLENABLE,488)
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_backStall = $unsigned(1'b0);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_wireValid = i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_valid_out;

    // i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40(BLACKBOX,55)@467
    // in in_stall_in@20000000
    // out out_data_out@468
    // out out_feedback_out_6@20000000
    // out out_feedback_valid_out_6@20000000
    // out out_stall_out@20000000
    // out out_valid_out@468
    slavereg_comp_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_0 thei_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40 (
        .in_data_in(SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_D0),
        .in_feedback_stall_in_6(i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_feedback_stall_out_6),
        .in_keep_going(SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_D1),
        .in_stall_in(SE_out_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_backStall),
        .in_valid_in(SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_V0),
        .out_data_out(),
        .out_feedback_out_6(i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_feedback_out_6),
        .out_feedback_valid_out_6(i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_feedback_valid_out_6),
        .out_stall_out(i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_stall_out),
        .out_valid_out(i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40(STALLENABLE,487)
    // Valid signal propagation
    assign SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_V0 = SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_wireValid;
    // Backward Stall generation
    assign SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_backStall = i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_stall_out | ~ (SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_wireValid);
    // Computing multiple Valid(s)
    assign SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_wireValid = SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_V;

    // SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40(STALLREG,791)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_valid <= 1'b0;
            SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_data0 <= 33'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
            SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_data1 <= 1'bx;
        end
        else
        begin
            // Valid
            SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_valid <= SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_backStall & (SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_valid | SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_i_valid);

            if (SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_valid == 1'b0)
            begin
                // Data(s)
                SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_data0 <= bgTrunc_i_fpga_indvars_iv_next_slavereg_comp31_sel_x_b;
                SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_data1 <= $unsigned(bubble_select_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_b);
            end

        end
    end
    // Computing multiple Valid(s)
    assign SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_and0 = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_V2;
    assign SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_i_valid = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V2 & SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_and0;
    // Stall signal propagation
    assign SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_backStall = SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_valid | ~ (SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_i_valid);

    // Valid
    assign SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_V = SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_valid == 1'b1 ? SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_valid : SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_i_valid;

    // Data0
    assign SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_D0 = SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_valid == 1'b1 ? SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_data0 : bgTrunc_i_fpga_indvars_iv_next_slavereg_comp31_sel_x_b;
    // Data1
    assign SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_D1 = SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_valid == 1'b1 ? SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_r_data1 : bubble_select_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_b;

    // SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9(STALLENABLE,468)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_fromReg0 <= '0;
            SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_fromReg0 <= SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_fromReg1 <= SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_consumed0 = (~ (bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_out) & SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_wireValid) | SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_fromReg0;
    assign SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_consumed1 = (~ (SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_backStall) & SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_wireValid) | SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_fromReg1;
    // Consuming
    assign SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_StallValid = SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_backStall & SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_wireValid;
    assign SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_toReg0 = SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_StallValid & SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_consumed0;
    assign SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_toReg1 = SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_StallValid & SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_consumed1;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_or0 = SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_consumed0;
    assign SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_wireStall = ~ (SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_consumed1 & SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_or0);
    assign SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_backStall = SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_V0 = SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_wireValid & ~ (SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_fromReg0);
    assign SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_V1 = SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_wireValid & ~ (SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_wireValid = i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_valid_out;

    // SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20(STALLENABLE,433)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg0 <= '0;
            SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg1 <= '0;
            SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg2 <= '0;
        end
        else
        begin
            // Successor 0
            SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg0 <= SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_toReg0;
            // Successor 1
            SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg1 <= SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_toReg1;
            // Successor 2
            SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg2 <= SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_toReg2;
        end
    end
    // Input Stall processing
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed0 = (~ (SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_backStall) & SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireValid) | SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg0;
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed1 = (~ (SR_SE_i_masked_slavereg_comp43_backStall) & SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireValid) | SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg1;
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed2 = (~ (SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_backStall) & SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireValid) | SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg2;
    // Consuming
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_StallValid = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_backStall & SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireValid;
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_toReg0 = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_StallValid & SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed0;
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_toReg1 = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_StallValid & SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed1;
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_toReg2 = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_StallValid & SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed2;
    // Backward Stall generation
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_or0 = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed0;
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_or1 = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed1 & SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_or0;
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireStall = ~ (SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_consumed2 & SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_or1);
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_backStall = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireStall;
    // Valid signal propagation
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_V0 = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireValid & ~ (SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg0);
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_V1 = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireValid & ~ (SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg1);
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_V2 = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireValid & ~ (SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_fromReg2);
    // Computing multiple Valid(s)
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_and0 = SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_V0;
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_and1 = SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_V1 & SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_and0;
    assign SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_wireValid = SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_V1 & SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_and1;

    // bubble_join_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10(BITJOIN,335)
    assign bubble_join_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_q = i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_data_out;

    // bubble_select_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10(BITSELECT,336)
    assign bubble_select_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_b = $unsigned(bubble_join_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_q[31:0]);

    // i_unnamed_slavereg_comp21_sel_x(BITSELECT,197)@467
    assign i_unnamed_slavereg_comp21_sel_x_b = $unsigned({{32{bubble_select_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_b[31]}}, bubble_select_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_b[31:0]});

    // i_mptr_bitcast_index52_slavereg_comp0_narrow_x(BITSELECT,176)@467
    assign i_mptr_bitcast_index52_slavereg_comp0_narrow_x_b = i_unnamed_slavereg_comp21_sel_x_b[61:0];

    // i_mptr_bitcast_index52_slavereg_comp0_c_i2_01_x(CONSTANT,175)
    assign i_mptr_bitcast_index52_slavereg_comp0_c_i2_01_x_q = $unsigned(2'b00);

    // i_mptr_bitcast_index52_slavereg_comp0_shift_join_x(BITJOIN,177)@467
    assign i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q = {i_mptr_bitcast_index52_slavereg_comp0_narrow_x_b, i_mptr_bitcast_index52_slavereg_comp0_c_i2_01_x_q};

    // redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo(STALLFIFO,272)
    assign redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_in = SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_V1;
    assign redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_in = SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_backStall;
    assign redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_data_in = i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b;
    assign redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_in_bitsignaltemp = redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_in[0];
    assign redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_in_bitsignaltemp = redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_in[0];
    assign redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_out[0] = redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_out_bitsignaltemp;
    assign redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_out[0] = redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(229),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(64),
        .IMPL("ram")
    ) theredist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo (
        .valid_in(redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_in_bitsignaltemp),
        .stall_in(redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_in_bitsignaltemp),
        .data_in(i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b),
        .valid_out(redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_out_bitsignaltemp),
        .stall_out(redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_out_bitsignaltemp),
        .data_out(redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3(STALLENABLE,684)
    // Valid signal propagation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_V0 = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_wireValid;
    // Backward Stall generation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_backStall = i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_out_stall_out | ~ (SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_wireValid = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_out;

    // i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2(BLACKBOX,33)@466
    // in in_stall_in@20000000
    // out out_dest_data_out_2_0@467
    // out out_stall_out@20000000
    // out out_valid_out@467
    slavereg_comp_i_llvm_fpga_ffwd_dest_p1020000mptr_bitcast535913_0 thei_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2 (
        .in_intel_reserved_ffwd_2_0(in_intel_reserved_ffwd_2_0),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_backStall),
        .in_valid_in(SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_V0),
        .out_dest_data_out_2_0(i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_out_dest_data_out_2_0),
        .out_stall_out(i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2(STALLENABLE,444)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_fromReg0 <= '0;
            SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_fromReg0 <= SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_fromReg1 <= SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_consumed0 = (~ (SE_i_memdep_phi6_or_slavereg_comp23_backStall) & SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_wireValid) | SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_fromReg0;
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_consumed1 = (~ (redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_stall_out) & SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_wireValid) | SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_fromReg1;
    // Consuming
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_StallValid = SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_backStall & SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_wireValid;
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_toReg0 = SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_StallValid & SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_consumed0;
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_toReg1 = SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_StallValid & SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_consumed1;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_or0 = SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_consumed0;
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_wireStall = ~ (SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_consumed1 & SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_or0);
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_backStall = SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_V0 = SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_wireValid & ~ (SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_fromReg0);
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_V1 = SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_wireValid & ~ (SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_and0 = i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_out_valid_out;
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_wireValid = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_V1 & SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_and0;

    // SE_out_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35(STALLENABLE,486)
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_backStall = $unsigned(1'b0);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_wireValid = i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_valid_out;

    // c_i32_164(CONSTANT,8)
    assign c_i32_164_q = $unsigned(32'b00000000000000000000000000000001);

    // i_inc_slavereg_comp22(ADD,27)@467
    assign i_inc_slavereg_comp22_a = {1'b0, bubble_select_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_b};
    assign i_inc_slavereg_comp22_b = {1'b0, c_i32_164_q};
    assign i_inc_slavereg_comp22_o = $unsigned(i_inc_slavereg_comp22_a) + $unsigned(i_inc_slavereg_comp22_b);
    assign i_inc_slavereg_comp22_q = i_inc_slavereg_comp22_o[32:0];

    // bgTrunc_i_inc_slavereg_comp22_sel_x(BITSELECT,153)@467
    assign bgTrunc_i_inc_slavereg_comp22_sel_x_b = i_inc_slavereg_comp22_q[31:0];

    // i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35(BLACKBOX,54)@467
    // in in_stall_in@20000000
    // out out_data_out@468
    // out out_feedback_out_7@20000000
    // out out_feedback_valid_out_7@20000000
    // out out_stall_out@20000000
    // out out_valid_out@468
    slavereg_comp_i_llvm_fpga_push_i32_i_050_push7_0 thei_llvm_fpga_push_i32_i_050_push7_slavereg_comp35 (
        .in_data_in(bgTrunc_i_inc_slavereg_comp22_sel_x_b),
        .in_feedback_stall_in_7(i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_feedback_stall_out_7),
        .in_keep_going(bubble_select_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_b),
        .in_stall_in(SE_out_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_backStall),
        .in_valid_in(SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_V0),
        .out_data_out(),
        .out_feedback_out_7(i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_feedback_out_7),
        .out_feedback_valid_out_7(i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_feedback_valid_out_7),
        .out_stall_out(i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_stall_out),
        .out_valid_out(i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35(STALLENABLE,485)
    // Valid signal propagation
    assign SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_V0 = SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_wireValid;
    // Backward Stall generation
    assign SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_backStall = i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_stall_out | ~ (SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_wireValid);
    // Computing multiple Valid(s)
    assign SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_and0 = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_V0;
    assign SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_wireValid = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V1 & SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_and0;

    // SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10(STALLENABLE,466)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg0 <= '0;
            SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg1 <= '0;
            SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg2 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg0 <= SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg1 <= SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_toReg1;
            // Successor 2
            SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg2 <= SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_toReg2;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed0 = (~ (SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_backStall) & SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireValid) | SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg0;
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed1 = (~ (SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_backStall) & SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireValid) | SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg1;
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed2 = (~ (redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_out) & SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireValid) | SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg2;
    // Consuming
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_StallValid = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_backStall & SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireValid;
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_toReg0 = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_StallValid & SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed0;
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_toReg1 = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_StallValid & SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed1;
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_toReg2 = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_StallValid & SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed2;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_or0 = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed0;
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_or1 = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed1 & SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_or0;
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireStall = ~ (SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_consumed2 & SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_or1);
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_backStall = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_V0 = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireValid & ~ (SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg0);
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_V1 = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireValid & ~ (SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg1);
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_V2 = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireValid & ~ (SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_fromReg2);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_wireValid = i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_valid_out;

    // redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo(STALLFIFO,273)
    assign redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_in = SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_V2;
    assign redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_in = SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_backStall;
    assign redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_data_in = i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q;
    assign redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_in_bitsignaltemp = redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_in[0];
    assign redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_in_bitsignaltemp = redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_in[0];
    assign redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_out[0] = redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_out_bitsignaltemp;
    assign redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_out[0] = redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(139),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(64),
        .IMPL("ram")
    ) theredist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo (
        .valid_in(redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_in_bitsignaltemp),
        .stall_in(redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_in_bitsignaltemp),
        .data_in(i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q),
        .valid_out(redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_out_bitsignaltemp),
        .stall_out(redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_stall_out_bitsignaltemp),
        .data_out(redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo(STALLENABLE,554)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_fromReg0 <= '0;
            SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_fromReg0 <= SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_toReg0;
            // Successor 1
            SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_fromReg1 <= SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_consumed0 = (~ (SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_backStall) & SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_wireValid) | SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_fromReg0;
    assign SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_consumed1 = (~ (SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_backStall) & SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_wireValid) | SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_fromReg1;
    // Consuming
    assign SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_StallValid = SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_backStall & SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_wireValid;
    assign SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_toReg0 = SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_StallValid & SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_consumed0;
    assign SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_toReg1 = SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_StallValid & SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_consumed1;
    // Backward Stall generation
    assign SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_or0 = SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_consumed0;
    assign SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_wireStall = ~ (SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_consumed1 & SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_or0);
    assign SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_backStall = SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_wireStall;
    // Valid signal propagation
    assign SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_V0 = SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_wireValid & ~ (SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_fromReg0);
    assign SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_V1 = SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_wireValid & ~ (SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_wireValid = redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_valid_out;

    // SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5(STALLENABLE,442)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_V0 = SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_backStall = redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_out | ~ (SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_and0 = i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_out_valid_out;
    assign SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_wireValid = SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_V1 & SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_and0;

    // i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5(BLACKBOX,32)@604
    // in in_stall_in@20000000
    // out out_dest_data_out_5_0@605
    // out out_stall_out@20000000
    // out out_valid_out@605
    slavereg_comp_i_llvm_fpga_ffwd_dest_p1020000mptr_bitcast576315_0 thei_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5 (
        .in_intel_reserved_ffwd_5_0(in_intel_reserved_ffwd_5_0),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_backStall),
        .in_valid_in(SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_V0),
        .out_dest_data_out_5_0(i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_out_dest_data_out_5_0),
        .out_stall_out(i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6(STALLENABLE,690)
    // Valid signal propagation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_V0 = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_wireValid;
    // Backward Stall generation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_backStall = i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_out_stall_out | ~ (SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_wireValid = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_out;

    // bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg(STALLFIFO,783)
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_in = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V5;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_in = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_backStall;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_out_bitsignaltemp;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(604),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg (
        .valid_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4(BLACKBOX,34)@604
    // in in_stall_in@20000000
    // out out_dest_data_out_4_0@605
    // out out_stall_out@20000000
    // out out_valid_out@605
    slavereg_comp_i_llvm_fpga_ffwd_dest_p1020000mptr_bitcast556214_0 thei_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4 (
        .in_intel_reserved_ffwd_4_0(in_intel_reserved_ffwd_4_0),
        .in_stall_in(SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_backStall),
        .in_valid_in(SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_V0),
        .out_dest_data_out_4_0(i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_out_dest_data_out_4_0),
        .out_stall_out(i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5(STALLENABLE,688)
    // Valid signal propagation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_V0 = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_wireValid;
    // Backward Stall generation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_backStall = i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_out_stall_out | ~ (SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_wireValid = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_out;

    // bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg(STALLFIFO,782)
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_in = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V4;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_in = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_backStall;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_out_bitsignaltemp;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(604),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg (
        .valid_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3(STALLENABLE,438)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_V0 = SE_out_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_backStall = SE_i_mul_slavereg_comp45_im0_cma_backStall | ~ (SE_out_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_wireValid = i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_out_valid_out;

    // i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3(BLACKBOX,30)@601
    // in in_stall_in@20000000
    // out out_dest_data_out_1_0@602
    // out out_stall_out@20000000
    // out out_valid_out@602
    slavereg_comp_i_llvm_fpga_ffwd_dest_i32_value6811_0 thei_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3 (
        .in_intel_reserved_ffwd_1_0(in_intel_reserved_ffwd_1_0),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_backStall),
        .in_valid_in(SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_V0),
        .out_dest_data_out_1_0(i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_out_dest_data_out_1_0),
        .out_stall_out(i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4(STALLENABLE,686)
    // Valid signal propagation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_V0 = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_wireValid;
    // Backward Stall generation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_backStall = i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_out_stall_out | ~ (SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_wireValid = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_out;

    // bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg(STALLFIFO,781)
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_in = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V3;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_in = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_backStall;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_out_bitsignaltemp;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(601),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg (
        .valid_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg(STALLFIFO,780)
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_in = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V2;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_in = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_backStall;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_out_bitsignaltemp;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(466),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg (
        .valid_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2(STALLENABLE,682)
    // Valid signal propagation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_V0 = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_wireValid;
    // Backward Stall generation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_backStall = i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_out_stall_out | ~ (SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_wireValid = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_out;

    // bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg(STALLFIFO,779)
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_in = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V1;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_in = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_backStall;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_out_bitsignaltemp;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(466),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg (
        .valid_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_stall_entry(BITJOIN,349)
    assign bubble_join_stall_entry_q = in_forked;

    // bubble_select_stall_entry(BITSELECT,350)
    assign bubble_select_stall_entry_b = $unsigned(bubble_join_stall_entry_q[0:0]);

    // SE_stall_entry(STALLENABLE,503)
    // Valid signal propagation
    assign SE_stall_entry_V0 = SE_stall_entry_wireValid;
    // Backward Stall generation
    assign SE_stall_entry_backStall = slavereg_comp_B3_merge_reg_aunroll_x_out_stall_out | ~ (SE_stall_entry_wireValid);
    // Computing multiple Valid(s)
    assign SE_stall_entry_wireValid = in_valid_in;

    // slavereg_comp_B3_merge_reg_aunroll_x(BLACKBOX,198)@0
    // in in_stall_in@20000000
    // out out_stall_out@20000000
    // out out_valid_out@1
    // out out_data_out_0_tpl@1
    slavereg_comp_B3_merge_reg theslavereg_comp_B3_merge_reg_aunroll_x (
        .in_stall_in(SE_out_slavereg_comp_B3_merge_reg_aunroll_x_backStall),
        .in_valid_in(SE_stall_entry_V0),
        .in_data_in_0_tpl(bubble_select_stall_entry_b),
        .out_stall_out(slavereg_comp_B3_merge_reg_aunroll_x_out_stall_out),
        .out_valid_out(slavereg_comp_B3_merge_reg_aunroll_x_out_valid_out),
        .out_data_out_0_tpl(slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_slavereg_comp_B3_merge_reg_aunroll_x(STALLENABLE,523)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg0 <= '0;
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg1 <= '0;
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg2 <= '0;
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg3 <= '0;
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg4 <= '0;
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg5 <= '0;
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg6 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg0 <= SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg0;
            // Successor 1
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg1 <= SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg1;
            // Successor 2
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg2 <= SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg2;
            // Successor 3
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg3 <= SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg3;
            // Successor 4
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg4 <= SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg4;
            // Successor 5
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg5 <= SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg5;
            // Successor 6
            SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg6 <= SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg6;
        end
    end
    // Input Stall processing
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed0 = (~ (bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_out) & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid) | SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg0;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed1 = (~ (bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_reg_stall_out) & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid) | SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg1;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed2 = (~ (bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_3_reg_stall_out) & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid) | SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg2;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed3 = (~ (bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_4_reg_stall_out) & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid) | SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg3;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed4 = (~ (bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_5_reg_stall_out) & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid) | SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg4;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed5 = (~ (bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_6_reg_stall_out) & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid) | SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg5;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed6 = (~ (redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_out) & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid) | SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg6;
    // Consuming
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_StallValid = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_backStall & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg0 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_StallValid & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed0;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg1 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_StallValid & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed1;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg2 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_StallValid & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed2;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg3 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_StallValid & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed3;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg4 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_StallValid & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed4;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg5 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_StallValid & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed5;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_toReg6 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_StallValid & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed6;
    // Backward Stall generation
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or0 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed0;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or1 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed1 & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or0;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or2 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed2 & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or1;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or3 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed3 & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or2;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or4 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed4 & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or3;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or5 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed5 & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or4;
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireStall = ~ (SE_out_slavereg_comp_B3_merge_reg_aunroll_x_consumed6 & SE_out_slavereg_comp_B3_merge_reg_aunroll_x_or5);
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_backStall = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireStall;
    // Valid signal propagation
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V0 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid & ~ (SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg0);
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V1 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid & ~ (SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg1);
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V2 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid & ~ (SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg2);
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V3 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid & ~ (SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg3);
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V4 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid & ~ (SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg4);
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V5 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid & ~ (SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg5);
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V6 = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid & ~ (SE_out_slavereg_comp_B3_merge_reg_aunroll_x_fromReg6);
    // Computing multiple Valid(s)
    assign SE_out_slavereg_comp_B3_merge_reg_aunroll_x_wireValid = slavereg_comp_B3_merge_reg_aunroll_x_out_valid_out;

    // bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg(STALLFIFO,778)
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_in = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V0;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_in = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_backStall;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_in_bitsignaltemp = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_in[0];
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_out_bitsignaltemp;
    assign bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_out[0] = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(466),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg (
        .valid_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1(STALLENABLE,680)
    // Valid signal propagation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_V0 = SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_wireValid;
    // Backward Stall generation
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_backStall = i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_out_stall_out | ~ (SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_wireValid = bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_reg_valid_out;

    // i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0(BLACKBOX,31)@466
    // in in_stall_in@20000000
    // out out_dest_data_out_6_0@467
    // out out_stall_out@20000000
    // out out_valid_out@467
    slavereg_comp_i_llvm_fpga_ffwd_dest_i33_0000ed_13_slavereg_comp0 thei_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0 (
        .in_intel_reserved_ffwd_6_0(in_intel_reserved_ffwd_6_0),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_backStall),
        .in_valid_in(SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_1_V0),
        .out_dest_data_out_6_0(i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_out_dest_data_out_6_0),
        .out_stall_out(i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0(STALLENABLE,440)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_fromReg0 <= '0;
            SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_fromReg0 <= SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_fromReg1 <= SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_consumed0 = (~ (bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_out) & SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_wireValid) | SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_fromReg0;
    assign SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_consumed1 = (~ (SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_backStall) & SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_wireValid) | SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_fromReg1;
    // Consuming
    assign SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_StallValid = SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_backStall & SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_wireValid;
    assign SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_toReg0 = SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_StallValid & SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_consumed0;
    assign SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_toReg1 = SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_StallValid & SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_consumed1;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_or0 = SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_consumed0;
    assign SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_wireStall = ~ (SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_consumed1 & SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_or0);
    assign SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_backStall = SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_V0 = SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_wireValid & ~ (SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_fromReg0);
    assign SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_V1 = SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_wireValid & ~ (SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_wireValid = i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_out_valid_out;

    // bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg(STALLFIFO,775)
    assign bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_in = SE_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_V0;
    assign bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_in = SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_backStall;
    assign bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_in_bitsignaltemp = bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_in[0];
    assign bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_out[0] = bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_out_bitsignaltemp;
    assign bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_out[0] = bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(466),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg (
        .valid_in(bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg(STALLFIFO,776)
    assign bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_in = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V0;
    assign bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_in = SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_backStall;
    assign bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_in_bitsignaltemp = bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_in[0];
    assign bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_in_bitsignaltemp = bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_in[0];
    assign bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_out[0] = bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_out_bitsignaltemp;
    assign bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_out[0] = bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(466),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg (
        .valid_in(bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_i_masked_slavereg_comp43(STALLENABLE,493)
    // Valid signal propagation
    assign SE_i_masked_slavereg_comp43_V0 = SE_i_masked_slavereg_comp43_R_v_0;
    // Stall signal propagation
    assign SE_i_masked_slavereg_comp43_s_tv_0 = SE_in_redist9_i_masked_slavereg_comp43_q_465_fifo_backStall & SE_i_masked_slavereg_comp43_R_v_0;
    // Backward Enable generation
    assign SE_i_masked_slavereg_comp43_backEN = ~ (SE_i_masked_slavereg_comp43_s_tv_0);
    // Determine whether to write valid data into the first register stage
    assign SE_i_masked_slavereg_comp43_v_s_0 = SE_i_masked_slavereg_comp43_backEN & SR_SE_i_masked_slavereg_comp43_V;
    // Backward Stall generation
    assign SE_i_masked_slavereg_comp43_backStall = ~ (SE_i_masked_slavereg_comp43_backEN);
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_i_masked_slavereg_comp43_R_v_0 <= 1'b0;
        end
        else
        begin
            if (SE_i_masked_slavereg_comp43_backEN == 1'b0)
            begin
                SE_i_masked_slavereg_comp43_R_v_0 <= SE_i_masked_slavereg_comp43_R_v_0 & SE_i_masked_slavereg_comp43_s_tv_0;
            end
            else
            begin
                SE_i_masked_slavereg_comp43_R_v_0 <= SE_i_masked_slavereg_comp43_v_s_0;
            end

        end
    end

    // i_masked_slavereg_comp43(LOGICAL,59)@467 + 1
    assign i_masked_slavereg_comp43_qi = SR_SE_i_masked_slavereg_comp43_D0 & SR_SE_i_masked_slavereg_comp43_D1;
    dspba_delay_ver #( .width(1), .depth(1), .reset_kind("ASYNC"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_masked_slavereg_comp43_delay ( .xin(i_masked_slavereg_comp43_qi), .xout(i_masked_slavereg_comp43_q), .ena(SE_i_masked_slavereg_comp43_backEN[0]), .clk(clock), .aclr(resetn) );

    // SE_in_redist9_i_masked_slavereg_comp43_q_465_fifo(STALLENABLE,557)
    // Valid signal propagation
    assign SE_in_redist9_i_masked_slavereg_comp43_q_465_fifo_V0 = SE_in_redist9_i_masked_slavereg_comp43_q_465_fifo_wireValid;
    // Backward Stall generation
    assign SE_in_redist9_i_masked_slavereg_comp43_q_465_fifo_backStall = redist9_i_masked_slavereg_comp43_q_465_fifo_stall_out | ~ (SE_in_redist9_i_masked_slavereg_comp43_q_465_fifo_wireValid);
    // Computing multiple Valid(s)
    assign SE_in_redist9_i_masked_slavereg_comp43_q_465_fifo_wireValid = SE_i_masked_slavereg_comp43_V0;

    // redist9_i_masked_slavereg_comp43_q_465_fifo(STALLFIFO,275)
    assign redist9_i_masked_slavereg_comp43_q_465_fifo_valid_in = SE_in_redist9_i_masked_slavereg_comp43_q_465_fifo_V0;
    assign redist9_i_masked_slavereg_comp43_q_465_fifo_stall_in = SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_backStall;
    assign redist9_i_masked_slavereg_comp43_q_465_fifo_data_in = i_masked_slavereg_comp43_q;
    assign redist9_i_masked_slavereg_comp43_q_465_fifo_valid_in_bitsignaltemp = redist9_i_masked_slavereg_comp43_q_465_fifo_valid_in[0];
    assign redist9_i_masked_slavereg_comp43_q_465_fifo_stall_in_bitsignaltemp = redist9_i_masked_slavereg_comp43_q_465_fifo_stall_in[0];
    assign redist9_i_masked_slavereg_comp43_q_465_fifo_valid_out[0] = redist9_i_masked_slavereg_comp43_q_465_fifo_valid_out_bitsignaltemp;
    assign redist9_i_masked_slavereg_comp43_q_465_fifo_stall_out[0] = redist9_i_masked_slavereg_comp43_q_465_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(465),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist9_i_masked_slavereg_comp43_q_465_fifo (
        .valid_in(redist9_i_masked_slavereg_comp43_q_465_fifo_valid_in_bitsignaltemp),
        .stall_in(redist9_i_masked_slavereg_comp43_q_465_fifo_stall_in_bitsignaltemp),
        .data_in(i_masked_slavereg_comp43_q),
        .valid_out(redist9_i_masked_slavereg_comp43_q_465_fifo_valid_out_bitsignaltemp),
        .stall_out(redist9_i_masked_slavereg_comp43_q_465_fifo_stall_out_bitsignaltemp),
        .data_out(redist9_i_masked_slavereg_comp43_q_465_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg(STALLFIFO,777)
    assign bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_in = SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_V0;
    assign bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_in = SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_backStall;
    assign bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_in_bitsignaltemp = bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_in[0];
    assign bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_in_bitsignaltemp = bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_in[0];
    assign bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_out[0] = bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_out_bitsignaltemp;
    assign bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_out[0] = bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_out_bitsignaltemp;
    acl_valid_fifo_counter #(
        .DEPTH(466),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .ASYNC_RESET(1)
    ) thebubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg (
        .valid_in(bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_in_bitsignaltemp),
        .valid_out(bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_stall_out_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1(STALLENABLE,654)
    // Valid signal propagation
    assign SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_V0 = SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_wireValid;
    // Backward Stall generation
    assign SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_backStall = in_stall_in | ~ (SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and0 = bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_reg_valid_out;
    assign SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and1 = redist9_i_masked_slavereg_comp43_q_465_fifo_valid_out & SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and0;
    assign SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and2 = bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_valid_out & SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and1;
    assign SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and3 = bubble_out_i_llvm_fpga_ffwd_dest_i33_unnamed_slavereg_comp13_slavereg_comp0_1_reg_valid_out & SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and2;
    assign SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and4 = SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_V0 & SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and3;
    assign SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_wireValid = SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V0 & SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_and4;

    // SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8(STALLENABLE,472)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_fromReg0 <= '0;
            SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_fromReg0 <= SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_fromReg1 <= SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_consumed0 = (~ (SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_backStall) & SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_wireValid) | SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_fromReg0;
    assign SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_consumed1 = (~ (SR_SE_i_next_initerations_slavereg_comp19_vt_join_backStall) & SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_wireValid) | SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_fromReg1;
    // Consuming
    assign SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_StallValid = SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_backStall & SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_wireValid;
    assign SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_toReg0 = SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_StallValid & SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_consumed0;
    assign SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_toReg1 = SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_StallValid & SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_consumed1;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_or0 = SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_consumed0;
    assign SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_wireStall = ~ (SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_consumed1 & SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_or0);
    assign SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_backStall = SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_V0 = SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_wireValid & ~ (SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_fromReg0);
    assign SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_V1 = SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_wireValid & ~ (SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_wireValid = i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_valid_out;

    // SE_out_i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27(STALLENABLE,492)
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_backStall = $unsigned(1'b0);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_wireValid = i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_valid_out;

    // i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27(BLACKBOX,57)@932
    // in in_stall_in@20000000
    // out out_data_out@933
    // out out_feedback_out_12@20000000
    // out out_feedback_valid_out_12@20000000
    // out out_stall_out@20000000
    // out out_valid_out@933
    slavereg_comp_i_llvm_fpga_push_i4_initerations_push12_0 thei_llvm_fpga_push_i4_initerations_push12_slavereg_comp27 (
        .in_data_in(SR_SE_i_next_initerations_slavereg_comp19_vt_join_D3),
        .in_feedback_stall_in_12(i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_feedback_stall_out_12),
        .in_keep_going(SR_SE_i_next_initerations_slavereg_comp19_vt_join_D2),
        .in_stall_in(SE_out_i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_backStall),
        .in_valid_in(SE_i_next_initerations_slavereg_comp19_vt_join_V1),
        .out_data_out(),
        .out_feedback_out_12(i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_feedback_out_12),
        .out_feedback_valid_out_12(i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_feedback_valid_out_12),
        .out_stall_out(i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_stall_out),
        .out_valid_out(i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo(BITJOIN,380)
    assign bubble_join_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_q = redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_data_out;

    // bubble_select_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo(BITSELECT,381)
    assign bubble_select_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_b = $unsigned(bubble_join_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_q[0:0]);

    // i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8(BLACKBOX,47)@931
    // in in_stall_in@20000000
    // out out_data_out@932
    // out out_feedback_stall_out_12@20000000
    // out out_stall_out@20000000
    // out out_valid_out@932
    slavereg_comp_i_llvm_fpga_pop_i4_initerations_pop12_0 thei_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8 (
        .in_data_in(c_i4_759_q),
        .in_dir(bubble_select_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_b),
        .in_feedback_in_12(i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_feedback_out_12),
        .in_feedback_valid_in_12(i_llvm_fpga_push_i4_initerations_push12_slavereg_comp27_out_feedback_valid_out_12),
        .in_predicate(GND_q),
        .in_stall_in(SE_out_i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_backStall),
        .in_valid_in(SE_out_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_V0),
        .out_data_out(i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_data_out),
        .out_feedback_stall_out_12(i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_feedback_stall_out_12),
        .out_stall_out(i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_stall_out),
        .out_valid_out(i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo(STALLENABLE,548)
    // Valid signal propagation
    assign SE_out_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_V0 = SE_out_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_wireValid;
    // Backward Stall generation
    assign SE_out_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_backStall = i_llvm_fpga_pop_i4_initerations_pop12_slavereg_comp8_out_stall_out | ~ (SE_out_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_wireValid = redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_out;

    // redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo(STALLFIFO,270)
    assign redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_in = SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_V1;
    assign redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_in = SE_out_redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_backStall;
    assign redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_data_in = redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_q;
    assign redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_in_bitsignaltemp = redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_in[0];
    assign redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_in_bitsignaltemp = redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_in[0];
    assign redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_out[0] = redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_out_bitsignaltemp;
    assign redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_out[0] = redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(328),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo (
        .valid_in(redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_in_bitsignaltemp),
        .stall_in(redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_in_bitsignaltemp),
        .data_in(redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_q),
        .valid_out(redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_valid_out_bitsignaltemp),
        .stall_out(redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_out_bitsignaltemp),
        .data_out(redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13(BLACKBOX,41)@604
    // in in_stall_in@20000000
    // out out_data_out@605
    // out out_feedback_stall_out_10@20000000
    // out out_stall_out@20000000
    // out out_valid_out@605
    slavereg_comp_i_llvm_fpga_pop_i1_memdep_phi4_pop10_0 thei_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13 (
        .in_data_in(GND_q),
        .in_dir(redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_q),
        .in_feedback_in_10(i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_feedback_out_10),
        .in_feedback_valid_in_10(i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_out_feedback_valid_out_10),
        .in_predicate(GND_q),
        .in_stall_in(SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_backStall),
        .in_valid_in(SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_V0),
        .out_data_out(i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_data_out),
        .out_feedback_stall_out_10(i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_feedback_stall_out_10),
        .out_stall_out(i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_stall_out),
        .out_valid_out(i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1(STALLENABLE,546)
    // Valid signal propagation
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_V0 = SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_0;
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_V1 = SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_1;
    // Stall signal propagation
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_s_tv_0 = i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_stall_out & SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_0;
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_s_tv_1 = redist4_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_930_fifo_stall_out & SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_1;
    // Backward Enable generation
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_or0 = SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_s_tv_0;
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_backEN = ~ (SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_s_tv_1 | SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_or0);
    // Determine whether to write valid data into the first register stage
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_v_s_0 = SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_backEN & SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_V0;
    // Backward Stall generation
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_backStall = ~ (SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_v_s_0);
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_0 <= 1'b0;
            SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_1 <= 1'b0;
        end
        else
        begin
            if (SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_backEN == 1'b0)
            begin
                SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_0 <= SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_0 & SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_s_tv_0;
            end
            else
            begin
                SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_0 <= SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_v_s_0;
            end

            if (SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_backEN == 1'b0)
            begin
                SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_1 <= SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_1 & SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_s_tv_1;
            end
            else
            begin
                SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_R_v_1 <= SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_v_s_0;
            end

        end
    end

    // SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0(STALLENABLE,545)
    // Valid signal propagation
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_V0 = SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_R_v_0;
    // Stall signal propagation
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_s_tv_0 = SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_1_backStall & SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_R_v_0;
    // Backward Enable generation
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_backEN = ~ (SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_s_tv_0);
    // Determine whether to write valid data into the first register stage
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_v_s_0 = SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_backEN & SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_V0;
    // Backward Stall generation
    assign SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_backStall = ~ (SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_v_s_0);
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_R_v_0 <= 1'b0;
        end
        else
        begin
            if (SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_backEN == 1'b0)
            begin
                SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_R_v_0 <= SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_R_v_0 & SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_s_tv_0;
            end
            else
            begin
                SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_R_v_0 <= SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_v_s_0;
            end

        end
    end

    // SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo(STALLENABLE,544)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_fromReg0 <= '0;
            SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_fromReg0 <= SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_toReg0;
            // Successor 1
            SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_fromReg1 <= SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_consumed0 = (~ (SE_redist3_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_603_0_backStall) & SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_wireValid) | SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_fromReg0;
    assign SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_consumed1 = (~ (i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_stall_out) & SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_wireValid) | SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_fromReg1;
    // Consuming
    assign SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_StallValid = SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_backStall & SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_wireValid;
    assign SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_toReg0 = SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_StallValid & SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_consumed0;
    assign SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_toReg1 = SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_StallValid & SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_consumed1;
    // Backward Stall generation
    assign SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_or0 = SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_consumed0;
    assign SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_wireStall = ~ (SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_consumed1 & SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_or0);
    assign SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_backStall = SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_wireStall;
    // Valid signal propagation
    assign SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_V0 = SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_wireValid & ~ (SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_fromReg0);
    assign SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_V1 = SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_wireValid & ~ (SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_wireValid = SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_V;

    // bubble_join_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11(BITJOIN,323)
    assign bubble_join_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_q = i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out;

    // bubble_select_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11(BITSELECT,324)
    assign bubble_select_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_b = $unsigned(bubble_join_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_q[0:0]);

    // SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11(STALLENABLE,458)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_fromReg0 <= '0;
            SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_fromReg0 <= SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_fromReg1 <= SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_consumed0 = (~ (SE_i_memdep_phi6_or_slavereg_comp23_backStall) & SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_wireValid) | SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_fromReg0;
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_consumed1 = (~ (redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_out) & SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_wireValid) | SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_fromReg1;
    // Consuming
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_StallValid = SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_backStall & SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_wireValid;
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_toReg0 = SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_StallValid & SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_consumed0;
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_toReg1 = SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_StallValid & SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_consumed1;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_or0 = SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_consumed0;
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_wireStall = ~ (SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_consumed1 & SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_or0);
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_backStall = SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_V0 = SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_wireValid & ~ (SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_fromReg0);
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_V1 = SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_wireValid & ~ (SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_wireValid = i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_valid_out;

    // redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo(STALLFIFO,278)
    assign redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_in = SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_V1;
    assign redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_in = SE_out_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_backStall;
    assign redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_data_in = bubble_select_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_b;
    assign redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_in_bitsignaltemp = redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_in[0];
    assign redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_in_bitsignaltemp = redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_in[0];
    assign redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_out[0] = redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_out_bitsignaltemp;
    assign redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_out[0] = redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(137),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo (
        .valid_in(redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_in_bitsignaltemp),
        .stall_in(redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_in_bitsignaltemp),
        .data_in(bubble_select_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_b),
        .valid_out(redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_out_bitsignaltemp),
        .stall_out(redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_stall_out_bitsignaltemp),
        .data_out(redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo(STALLENABLE,564)
    // Valid signal propagation
    assign SE_out_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_V0 = SE_out_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_wireValid;
    // Backward Stall generation
    assign SE_out_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_backStall = SE_i_memdep_phi3_or_slavereg_comp25_backStall | ~ (SE_out_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_wireValid = redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_valid_out;

    // SE_i_memdep_phi3_or_slavereg_comp25(STALLENABLE,494)
    // Valid signal propagation
    assign SE_i_memdep_phi3_or_slavereg_comp25_V0 = SE_i_memdep_phi3_or_slavereg_comp25_R_v_0;
    // Stall signal propagation
    assign SE_i_memdep_phi3_or_slavereg_comp25_s_tv_0 = redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_out & SE_i_memdep_phi3_or_slavereg_comp25_R_v_0;
    // Backward Enable generation
    assign SE_i_memdep_phi3_or_slavereg_comp25_backEN = ~ (SE_i_memdep_phi3_or_slavereg_comp25_s_tv_0);
    // Determine whether to write valid data into the first register stage
    assign SE_i_memdep_phi3_or_slavereg_comp25_and0 = SE_out_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_V0 & SE_i_memdep_phi3_or_slavereg_comp25_backEN;
    assign SE_i_memdep_phi3_or_slavereg_comp25_v_s_0 = SE_out_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_V0 & SE_i_memdep_phi3_or_slavereg_comp25_and0;
    // Backward Stall generation
    assign SE_i_memdep_phi3_or_slavereg_comp25_backStall = ~ (SE_i_memdep_phi3_or_slavereg_comp25_v_s_0);
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_i_memdep_phi3_or_slavereg_comp25_R_v_0 <= 1'b0;
        end
        else
        begin
            if (SE_i_memdep_phi3_or_slavereg_comp25_backEN == 1'b0)
            begin
                SE_i_memdep_phi3_or_slavereg_comp25_R_v_0 <= SE_i_memdep_phi3_or_slavereg_comp25_R_v_0 & SE_i_memdep_phi3_or_slavereg_comp25_s_tv_0;
            end
            else
            begin
                SE_i_memdep_phi3_or_slavereg_comp25_R_v_0 <= SE_i_memdep_phi3_or_slavereg_comp25_v_s_0;
            end

        end
    end

    // SE_out_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14(STALLENABLE,464)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_V0 = SE_out_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_backStall = SE_i_memdep_phi3_or_slavereg_comp25_backStall | ~ (SE_out_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_wireValid = i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_valid_out;

    // bubble_join_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo(BITJOIN,377)
    assign bubble_join_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_q = redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_data_out;

    // bubble_select_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo(BITSELECT,378)
    assign bubble_select_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_b = $unsigned(bubble_join_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_q[0:0]);

    // redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo(STALLFIFO,267)
    assign redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_in = SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_V1;
    assign redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_in = SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_backStall;
    assign redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_data_in = redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_q;
    assign redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_in_bitsignaltemp = redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_in[0];
    assign redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_in_bitsignaltemp = redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_in[0];
    assign redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_out[0] = redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_out_bitsignaltemp;
    assign redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_out[0] = redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(136),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo (
        .valid_in(redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_in_bitsignaltemp),
        .stall_in(redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_in_bitsignaltemp),
        .data_in(redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_q),
        .valid_out(redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_out_bitsignaltemp),
        .stall_out(redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_out_bitsignaltemp),
        .data_out(redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo(STALLREG,788)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_valid <= 1'b0;
            SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_data0 <= 1'bx;
            SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_data1 <= 1'bx;
        end
        else
        begin
            // Valid
            SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_valid <= SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_backStall & (SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_valid | SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_i_valid);

            if (SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_valid == 1'b0)
            begin
                // Data(s)
                SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_data0 <= $unsigned(bubble_select_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_b);
                SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_data1 <= $unsigned(bubble_select_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_b);
            end

        end
    end
    // Computing multiple Valid(s)
    assign SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_i_valid = redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_valid_out;
    // Stall signal propagation
    assign SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_backStall = SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_valid | ~ (SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_i_valid);

    // Valid
    assign SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_V = SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_valid == 1'b1 ? SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_valid : SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_i_valid;

    // Data0
    assign SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_D0 = SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_valid == 1'b1 ? SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_data0 : bubble_select_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_b;
    // Data1
    assign SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_D1 = SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_valid == 1'b1 ? SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_r_data1 : bubble_select_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_b;

    // i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14(BLACKBOX,43)@602
    // in in_stall_in@20000000
    // out out_data_out@603
    // out out_feedback_stall_out_8@20000000
    // out out_stall_out@20000000
    // out out_valid_out@603
    slavereg_comp_i_llvm_fpga_pop_i1_memdep_phi_pop8_0 thei_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14 (
        .in_data_in(GND_q),
        .in_dir(SR_SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_D0),
        .in_feedback_in_8(i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_feedback_out_8),
        .in_feedback_valid_in_8(i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_feedback_valid_out_8),
        .in_predicate(GND_q),
        .in_stall_in(SE_out_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_backStall),
        .in_valid_in(SE_out_redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_V1),
        .out_data_out(i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_data_out),
        .out_feedback_stall_out_8(i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_feedback_stall_out_8),
        .out_stall_out(i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_stall_out),
        .out_valid_out(i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // i_lm1_toi1_intcast_slavereg_comp44_sel_x(BITSELECT,173)@602
    assign i_lm1_toi1_intcast_slavereg_comp44_sel_x_b = bubble_select_i_llvm_fpga_mem_lm1_slavereg_comp41_b[0:0];

    // i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47(BLACKBOX,52)@602
    // in in_stall_in@20000000
    // out out_data_out@603
    // out out_feedback_out_8@20000000
    // out out_feedback_valid_out_8@20000000
    // out out_stall_out@20000000
    // out out_valid_out@603
    slavereg_comp_i_llvm_fpga_push_i1_memdep_phi_push8_0 thei_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47 (
        .in_data_in(i_lm1_toi1_intcast_slavereg_comp44_sel_x_b),
        .in_feedback_stall_in_8(i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_feedback_stall_out_8),
        .in_keep_going(bubble_select_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_b),
        .in_stall_in(SE_out_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_backStall),
        .in_valid_in(SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_V0),
        .out_data_out(),
        .out_feedback_out_8(i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_feedback_out_8),
        .out_feedback_valid_out_8(i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_feedback_valid_out_8),
        .out_stall_out(i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_stall_out),
        .out_valid_out(i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo(STALLENABLE,566)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_fromReg0 <= '0;
            SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_fromReg0 <= SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_toReg0;
            // Successor 1
            SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_fromReg1 <= SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_consumed0 = (~ (SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_backStall) & SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_wireValid) | SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_fromReg0;
    assign SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_consumed1 = (~ (redist14_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_228_fifo_stall_out) & SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_wireValid) | SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_fromReg1;
    // Consuming
    assign SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_StallValid = SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_backStall & SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_wireValid;
    assign SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_toReg0 = SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_StallValid & SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_consumed0;
    assign SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_toReg1 = SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_StallValid & SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_consumed1;
    // Backward Stall generation
    assign SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_or0 = SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_consumed0;
    assign SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_wireStall = ~ (SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_consumed1 & SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_or0);
    assign SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_backStall = SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_wireStall;
    // Valid signal propagation
    assign SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_V0 = SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_wireValid & ~ (SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_fromReg0);
    assign SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_V1 = SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_wireValid & ~ (SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_wireValid = redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_valid_out;

    // SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47(STALLENABLE,481)
    // Valid signal propagation
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_V0 = SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_wireValid;
    // Backward Stall generation
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_backStall = i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_out_stall_out | ~ (SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_wireValid);
    // Computing multiple Valid(s)
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_and0 = SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_V0;
    assign SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_wireValid = SE_out_redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_V0 & SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_and0;

    // SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41(STALLENABLE,448)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_fromReg0 <= '0;
            SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_fromReg0 <= SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_fromReg1 <= SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_consumed0 = (~ (SE_in_i_llvm_fpga_push_i1_memdep_phi_push8_slavereg_comp47_backStall) & SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_wireValid) | SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_fromReg0;
    assign SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_consumed1 = (~ (SE_i_mul_slavereg_comp45_im0_cma_backStall) & SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_wireValid) | SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_fromReg1;
    // Consuming
    assign SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_StallValid = SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_backStall & SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_wireValid;
    assign SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_toReg0 = SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_StallValid & SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_consumed0;
    assign SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_toReg1 = SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_StallValid & SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_consumed1;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_or0 = SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_consumed0;
    assign SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_wireStall = ~ (SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_consumed1 & SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_or0);
    assign SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_backStall = SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_V0 = SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_wireValid & ~ (SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_fromReg0);
    assign SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_V1 = SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_wireValid & ~ (SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_wireValid = i_llvm_fpga_mem_lm1_slavereg_comp41_out_o_valid;

    // i_memdep_phi6_or_slavereg_comp23(LOGICAL,63)@467
    assign i_memdep_phi6_or_slavereg_comp23_q = bubble_select_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_b | bubble_select_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_b;

    // bubble_join_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2(BITJOIN,300)
    assign bubble_join_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_q = i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_out_dest_data_out_2_0;

    // bubble_select_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2(BITSELECT,301)
    assign bubble_select_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_b = $unsigned(bubble_join_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_q[63:0]);

    // i_mptr_bitcast_index52_slavereg_comp0_add_x(ADD,174)@467
    assign i_mptr_bitcast_index52_slavereg_comp0_add_x_a = {1'b0, bubble_select_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_b};
    assign i_mptr_bitcast_index52_slavereg_comp0_add_x_b = {1'b0, i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q};
    assign i_mptr_bitcast_index52_slavereg_comp0_add_x_o = $unsigned(i_mptr_bitcast_index52_slavereg_comp0_add_x_a) + $unsigned(i_mptr_bitcast_index52_slavereg_comp0_add_x_b);
    assign i_mptr_bitcast_index52_slavereg_comp0_add_x_q = i_mptr_bitcast_index52_slavereg_comp0_add_x_o[64:0];

    // i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x(BITSELECT,179)@467
    assign i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b = i_mptr_bitcast_index52_slavereg_comp0_add_x_q[63:0];

    // i_llvm_fpga_mem_lm1_slavereg_comp41(BLACKBOX,35)@467
    // in in_i_stall@20000000
    // out out_lm1_slavereg_comp_avm_address@20000000
    // out out_lm1_slavereg_comp_avm_burstcount@20000000
    // out out_lm1_slavereg_comp_avm_byteenable@20000000
    // out out_lm1_slavereg_comp_avm_enable@20000000
    // out out_lm1_slavereg_comp_avm_read@20000000
    // out out_lm1_slavereg_comp_avm_write@20000000
    // out out_lm1_slavereg_comp_avm_writedata@20000000
    // out out_o_readdata@602
    // out out_o_stall@20000000
    // out out_o_valid@602
    slavereg_comp_i_llvm_fpga_mem_lm1_0 thei_llvm_fpga_mem_lm1_slavereg_comp41 (
        .in_flush(in_flush),
        .in_i_address(i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b),
        .in_i_dependence(i_memdep_phi6_or_slavereg_comp23_q),
        .in_i_predicate(i_first_cleanup_xor_or_slavereg_comp36_q),
        .in_i_stall(SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_backStall),
        .in_i_valid(SE_i_memdep_phi6_or_slavereg_comp23_V0),
        .in_lm1_slavereg_comp_avm_readdata(in_lm1_slavereg_comp_avm_readdata),
        .in_lm1_slavereg_comp_avm_readdatavalid(in_lm1_slavereg_comp_avm_readdatavalid),
        .in_lm1_slavereg_comp_avm_waitrequest(in_lm1_slavereg_comp_avm_waitrequest),
        .in_lm1_slavereg_comp_avm_writeack(in_lm1_slavereg_comp_avm_writeack),
        .out_lm1_slavereg_comp_avm_address(i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_address),
        .out_lm1_slavereg_comp_avm_burstcount(i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_burstcount),
        .out_lm1_slavereg_comp_avm_byteenable(i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_byteenable),
        .out_lm1_slavereg_comp_avm_enable(i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_enable),
        .out_lm1_slavereg_comp_avm_read(i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_read),
        .out_lm1_slavereg_comp_avm_write(i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_write),
        .out_lm1_slavereg_comp_avm_writedata(i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_writedata),
        .out_o_readdata(i_llvm_fpga_mem_lm1_slavereg_comp41_out_o_readdata),
        .out_o_stall(i_llvm_fpga_mem_lm1_slavereg_comp41_out_o_stall),
        .out_o_valid(i_llvm_fpga_mem_lm1_slavereg_comp41_out_o_valid),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_i_llvm_fpga_mem_lm1_slavereg_comp41(BITJOIN,306)
    assign bubble_join_i_llvm_fpga_mem_lm1_slavereg_comp41_q = i_llvm_fpga_mem_lm1_slavereg_comp41_out_o_readdata;

    // bubble_select_i_llvm_fpga_mem_lm1_slavereg_comp41(BITSELECT,307)
    assign bubble_select_i_llvm_fpga_mem_lm1_slavereg_comp41_b = $unsigned(bubble_join_i_llvm_fpga_mem_lm1_slavereg_comp41_q[31:0]);

    // i_mul_slavereg_comp45_bs4(BITSELECT,214)@602
    assign i_mul_slavereg_comp45_bs4_in = bubble_select_i_llvm_fpga_mem_lm1_slavereg_comp41_b[17:0];
    assign i_mul_slavereg_comp45_bs4_b = i_mul_slavereg_comp45_bs4_in[17:0];

    // bubble_join_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3(BITJOIN,290)
    assign bubble_join_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_q = i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_out_dest_data_out_1_0;

    // bubble_select_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3(BITSELECT,291)
    assign bubble_select_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_b = $unsigned(bubble_join_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_q[31:0]);

    // i_mul_slavereg_comp45_bs2_merged_bit_select(BITSELECT,244)@602
    assign i_mul_slavereg_comp45_bs2_merged_bit_select_b = bubble_select_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_b[31:18];
    assign i_mul_slavereg_comp45_bs2_merged_bit_select_c = bubble_select_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_b[17:0];

    // i_mul_slavereg_comp45_bs1(BITSELECT,211)@602
    assign i_mul_slavereg_comp45_bs1_b = bubble_select_i_llvm_fpga_mem_lm1_slavereg_comp41_b[31:18];

    // i_mul_slavereg_comp45_ma3_cma(CHAINMULTADD,243)@602 + 3
    assign i_mul_slavereg_comp45_ma3_cma_reset = ~ (resetn);
    assign i_mul_slavereg_comp45_ma3_cma_ena0 = SE_i_mul_slavereg_comp45_im0_cma_backEN[0];
    assign i_mul_slavereg_comp45_ma3_cma_ena1 = i_mul_slavereg_comp45_ma3_cma_ena0;
    assign i_mul_slavereg_comp45_ma3_cma_ena2 = i_mul_slavereg_comp45_ma3_cma_ena0;

    assign i_mul_slavereg_comp45_ma3_cma_a0 = i_mul_slavereg_comp45_bs1_b;
    assign i_mul_slavereg_comp45_ma3_cma_c0 = i_mul_slavereg_comp45_bs2_merged_bit_select_c;
    assign i_mul_slavereg_comp45_ma3_cma_a1 = i_mul_slavereg_comp45_bs2_merged_bit_select_b;
    assign i_mul_slavereg_comp45_ma3_cma_c1 = i_mul_slavereg_comp45_bs4_b;
    twentynm_mac #(
        .operation_mode("m18x18_sumof2"),
        .use_chainadder("false"),
        .ay_scan_in_clock("0"),
        .ay_scan_in_width(14),
        .by_clock("0"),
        .by_width(14),
        .ax_clock("0"),
        .bx_clock("0"),
        .ax_width(18),
        .bx_width(18),
        .signed_may("false"),
        .signed_mby("false"),
        .signed_max("false"),
        .signed_mbx("false"),
        .input_pipeline_clock("2"),
        .output_clock("1"),
        .result_a_width(33)
    ) i_mul_slavereg_comp45_ma3_cma_DSP0 (
        .clk({clock,clock,clock}),
        .ena({ i_mul_slavereg_comp45_ma3_cma_ena2, i_mul_slavereg_comp45_ma3_cma_ena1, i_mul_slavereg_comp45_ma3_cma_ena0 }),
        .aclr({ i_mul_slavereg_comp45_ma3_cma_reset, i_mul_slavereg_comp45_ma3_cma_reset }),
        .ay(i_mul_slavereg_comp45_ma3_cma_a1),
        .by(i_mul_slavereg_comp45_ma3_cma_a0),
        .ax(i_mul_slavereg_comp45_ma3_cma_c1),
        .bx(i_mul_slavereg_comp45_ma3_cma_c0),
        .resulta(i_mul_slavereg_comp45_ma3_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bz(),
        .coefselb(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .resultb(),
        .dftout()
    );
    dspba_delay_ver #( .width(33), .depth(0), .reset_kind("ASYNC"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_mul_slavereg_comp45_ma3_cma_delay ( .xin(i_mul_slavereg_comp45_ma3_cma_s0), .xout(i_mul_slavereg_comp45_ma3_cma_qq), .ena(SE_i_mul_slavereg_comp45_im0_cma_backEN[0]), .clk(clock), .aclr(resetn) );
    assign i_mul_slavereg_comp45_ma3_cma_q = $unsigned(i_mul_slavereg_comp45_ma3_cma_qq[32:0]);

    // bubble_join_i_mul_slavereg_comp45_ma3_cma(BITJOIN,371)
    assign bubble_join_i_mul_slavereg_comp45_ma3_cma_q = i_mul_slavereg_comp45_ma3_cma_q;

    // i_mul_slavereg_comp45_im8_cma(CHAINMULTADD,242)@602 + 3
    assign i_mul_slavereg_comp45_im8_cma_reset = ~ (resetn);
    assign i_mul_slavereg_comp45_im8_cma_ena0 = SE_i_mul_slavereg_comp45_im0_cma_backEN[0];
    assign i_mul_slavereg_comp45_im8_cma_ena1 = i_mul_slavereg_comp45_im8_cma_ena0;
    assign i_mul_slavereg_comp45_im8_cma_ena2 = i_mul_slavereg_comp45_im8_cma_ena0;

    assign i_mul_slavereg_comp45_im8_cma_a0 = i_mul_slavereg_comp45_bs4_b;
    assign i_mul_slavereg_comp45_im8_cma_c0 = i_mul_slavereg_comp45_bs2_merged_bit_select_c;
    twentynm_mac #(
        .operation_mode("m18x18_full"),
        .ay_scan_in_clock("0"),
        .ay_scan_in_width(18),
        .ax_clock("0"),
        .ax_width(18),
        .signed_may("false"),
        .signed_max("false"),
        .input_pipeline_clock("2"),
        .output_clock("1"),
        .result_a_width(36)
    ) i_mul_slavereg_comp45_im8_cma_DSP0 (
        .clk({clock,clock,clock}),
        .ena({ i_mul_slavereg_comp45_im8_cma_ena2, i_mul_slavereg_comp45_im8_cma_ena1, i_mul_slavereg_comp45_im8_cma_ena0 }),
        .aclr({ i_mul_slavereg_comp45_im8_cma_reset, i_mul_slavereg_comp45_im8_cma_reset }),
        .ay(i_mul_slavereg_comp45_im8_cma_a0),
        .ax(i_mul_slavereg_comp45_im8_cma_c0),
        .resulta(i_mul_slavereg_comp45_im8_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .resultb(),
        .dftout()
    );
    dspba_delay_ver #( .width(36), .depth(0), .reset_kind("ASYNC"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_mul_slavereg_comp45_im8_cma_delay ( .xin(i_mul_slavereg_comp45_im8_cma_s0), .xout(i_mul_slavereg_comp45_im8_cma_qq), .ena(SE_i_mul_slavereg_comp45_im0_cma_backEN[0]), .clk(clock), .aclr(resetn) );
    assign i_mul_slavereg_comp45_im8_cma_q = $unsigned(i_mul_slavereg_comp45_im8_cma_qq[35:0]);

    // bubble_join_i_mul_slavereg_comp45_im8_cma(BITJOIN,368)
    assign bubble_join_i_mul_slavereg_comp45_im8_cma_q = i_mul_slavereg_comp45_im8_cma_q;

    // bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg(STALLFIFO,785)
    assign bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_in = SE_i_mul_slavereg_comp45_im0_cma_V1;
    assign bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_in = SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_backStall;
    assign bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_data_in = bubble_join_i_mul_slavereg_comp45_im8_cma_q;
    assign bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_in_bitsignaltemp = bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_in[0];
    assign bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_in_bitsignaltemp = bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_in[0];
    assign bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_out[0] = bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_out_bitsignaltemp;
    assign bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_out[0] = bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(3),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(36),
        .IMPL("zl_reg")
    ) thebubble_out_i_mul_slavereg_comp45_im8_cma_data_reg (
        .valid_in(bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_in_bitsignaltemp),
        .data_in(bubble_join_i_mul_slavereg_comp45_im8_cma_q),
        .valid_out(bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_out_bitsignaltemp),
        .data_out(bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // i_mul_slavereg_comp45_im0_cma(CHAINMULTADD,241)@602 + 3
    assign i_mul_slavereg_comp45_im0_cma_reset = ~ (resetn);
    assign i_mul_slavereg_comp45_im0_cma_ena0 = SE_i_mul_slavereg_comp45_im0_cma_backEN[0];
    assign i_mul_slavereg_comp45_im0_cma_ena1 = i_mul_slavereg_comp45_im0_cma_ena0;
    assign i_mul_slavereg_comp45_im0_cma_ena2 = i_mul_slavereg_comp45_im0_cma_ena0;

    assign i_mul_slavereg_comp45_im0_cma_a0 = i_mul_slavereg_comp45_bs1_b;
    assign i_mul_slavereg_comp45_im0_cma_c0 = i_mul_slavereg_comp45_bs2_merged_bit_select_b;
    twentynm_mac #(
        .operation_mode("m18x18_full"),
        .ay_scan_in_clock("0"),
        .ay_scan_in_width(14),
        .ax_clock("0"),
        .ax_width(14),
        .signed_may("false"),
        .signed_max("false"),
        .input_pipeline_clock("2"),
        .output_clock("1"),
        .result_a_width(28)
    ) i_mul_slavereg_comp45_im0_cma_DSP0 (
        .clk({clock,clock,clock}),
        .ena({ i_mul_slavereg_comp45_im0_cma_ena2, i_mul_slavereg_comp45_im0_cma_ena1, i_mul_slavereg_comp45_im0_cma_ena0 }),
        .aclr({ i_mul_slavereg_comp45_im0_cma_reset, i_mul_slavereg_comp45_im0_cma_reset }),
        .ay(i_mul_slavereg_comp45_im0_cma_a0),
        .ax(i_mul_slavereg_comp45_im0_cma_c0),
        .resulta(i_mul_slavereg_comp45_im0_cma_s0),
        .accumulate(),
        .loadconst(),
        .negate(),
        .sub(),
        .az(),
        .coefsela(),
        .bx(),
        .by(),
        .bz(),
        .coefselb(),
        .scanin(),
        .scanout(),
        .chainin(),
        .chainout(),
        .resultb(),
        .dftout()
    );
    dspba_delay_ver #( .width(28), .depth(0), .reset_kind("ASYNC"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_mul_slavereg_comp45_im0_cma_delay ( .xin(i_mul_slavereg_comp45_im0_cma_s0), .xout(i_mul_slavereg_comp45_im0_cma_qq), .ena(SE_i_mul_slavereg_comp45_im0_cma_backEN[0]), .clk(clock), .aclr(resetn) );
    assign i_mul_slavereg_comp45_im0_cma_q = $unsigned(i_mul_slavereg_comp45_im0_cma_qq[27:0]);

    // bubble_join_i_mul_slavereg_comp45_im0_cma(BITJOIN,365)
    assign bubble_join_i_mul_slavereg_comp45_im0_cma_q = i_mul_slavereg_comp45_im0_cma_q;

    // bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg(STALLFIFO,784)
    assign bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_in = SE_i_mul_slavereg_comp45_im0_cma_V0;
    assign bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_in = SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_backStall;
    assign bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_data_in = bubble_join_i_mul_slavereg_comp45_im0_cma_q;
    assign bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_in_bitsignaltemp = bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_in[0];
    assign bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_in_bitsignaltemp = bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_in[0];
    assign bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_out[0] = bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_out_bitsignaltemp;
    assign bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_out[0] = bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(3),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(28),
        .IMPL("zl_reg")
    ) thebubble_out_i_mul_slavereg_comp45_im0_cma_data_reg (
        .valid_in(bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_in_bitsignaltemp),
        .data_in(bubble_join_i_mul_slavereg_comp45_im0_cma_q),
        .valid_out(bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_out_bitsignaltemp),
        .data_out(bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_i_mul_slavereg_comp45_im0_cma(STALLENABLE,536)
    // Valid signal propagation
    assign SE_i_mul_slavereg_comp45_im0_cma_V0 = SE_i_mul_slavereg_comp45_im0_cma_R_v_0;
    assign SE_i_mul_slavereg_comp45_im0_cma_V1 = SE_i_mul_slavereg_comp45_im0_cma_R_v_1;
    assign SE_i_mul_slavereg_comp45_im0_cma_V2 = SE_i_mul_slavereg_comp45_im0_cma_R_v_2;
    // Stall signal propagation
    assign SE_i_mul_slavereg_comp45_im0_cma_s_tv_0 = bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_stall_out & SE_i_mul_slavereg_comp45_im0_cma_R_v_0;
    assign SE_i_mul_slavereg_comp45_im0_cma_s_tv_1 = bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_stall_out & SE_i_mul_slavereg_comp45_im0_cma_R_v_1;
    assign SE_i_mul_slavereg_comp45_im0_cma_s_tv_2 = bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_out & SE_i_mul_slavereg_comp45_im0_cma_R_v_2;
    // Backward Enable generation
    assign SE_i_mul_slavereg_comp45_im0_cma_or0 = SE_i_mul_slavereg_comp45_im0_cma_s_tv_0;
    assign SE_i_mul_slavereg_comp45_im0_cma_or1 = SE_i_mul_slavereg_comp45_im0_cma_s_tv_1 | SE_i_mul_slavereg_comp45_im0_cma_or0;
    assign SE_i_mul_slavereg_comp45_im0_cma_backEN = ~ (SE_i_mul_slavereg_comp45_im0_cma_s_tv_2 | SE_i_mul_slavereg_comp45_im0_cma_or1);
    // Determine whether to write valid data into the first register stage
    assign SE_i_mul_slavereg_comp45_im0_cma_and0 = SE_out_i_llvm_fpga_mem_lm1_slavereg_comp41_V1 & SE_i_mul_slavereg_comp45_im0_cma_backEN;
    assign SE_i_mul_slavereg_comp45_im0_cma_v_s_0 = SE_out_i_llvm_fpga_ffwd_dest_i32_value6811_slavereg_comp3_V0 & SE_i_mul_slavereg_comp45_im0_cma_and0;
    // Backward Stall generation
    assign SE_i_mul_slavereg_comp45_im0_cma_backStall = ~ (SE_i_mul_slavereg_comp45_im0_cma_v_s_0);
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_i_mul_slavereg_comp45_im0_cma_R_s_0 <= 1'b0;
            SE_i_mul_slavereg_comp45_im0_cma_R_s_1 <= 1'b0;
            SE_i_mul_slavereg_comp45_im0_cma_R_v_0 <= 1'b0;
            SE_i_mul_slavereg_comp45_im0_cma_R_v_1 <= 1'b0;
            SE_i_mul_slavereg_comp45_im0_cma_R_v_2 <= 1'b0;
        end
        else
        begin
            if (SE_i_mul_slavereg_comp45_im0_cma_backEN == 1'b1)
            begin
                SE_i_mul_slavereg_comp45_im0_cma_R_s_0 <= SE_i_mul_slavereg_comp45_im0_cma_v_s_0;
            end

            if (SE_i_mul_slavereg_comp45_im0_cma_backEN == 1'b1)
            begin
                SE_i_mul_slavereg_comp45_im0_cma_R_s_1 <= SE_i_mul_slavereg_comp45_im0_cma_R_s_0;
            end

            if (SE_i_mul_slavereg_comp45_im0_cma_backEN == 1'b0)
            begin
                SE_i_mul_slavereg_comp45_im0_cma_R_v_0 <= SE_i_mul_slavereg_comp45_im0_cma_R_v_0 & SE_i_mul_slavereg_comp45_im0_cma_s_tv_0;
            end
            else
            begin
                SE_i_mul_slavereg_comp45_im0_cma_R_v_0 <= SE_i_mul_slavereg_comp45_im0_cma_R_s_1;
            end

            if (SE_i_mul_slavereg_comp45_im0_cma_backEN == 1'b0)
            begin
                SE_i_mul_slavereg_comp45_im0_cma_R_v_1 <= SE_i_mul_slavereg_comp45_im0_cma_R_v_1 & SE_i_mul_slavereg_comp45_im0_cma_s_tv_1;
            end
            else
            begin
                SE_i_mul_slavereg_comp45_im0_cma_R_v_1 <= SE_i_mul_slavereg_comp45_im0_cma_R_s_1;
            end

            if (SE_i_mul_slavereg_comp45_im0_cma_backEN == 1'b0)
            begin
                SE_i_mul_slavereg_comp45_im0_cma_R_v_2 <= SE_i_mul_slavereg_comp45_im0_cma_R_v_2 & SE_i_mul_slavereg_comp45_im0_cma_s_tv_2;
            end
            else
            begin
                SE_i_mul_slavereg_comp45_im0_cma_R_v_2 <= SE_i_mul_slavereg_comp45_im0_cma_R_s_1;
            end

        end
    end

    // bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg(STALLFIFO,786)
    assign bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_in = SE_i_mul_slavereg_comp45_im0_cma_V2;
    assign bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_in = SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_backStall;
    assign bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_data_in = bubble_join_i_mul_slavereg_comp45_ma3_cma_q;
    assign bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_in_bitsignaltemp = bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_in[0];
    assign bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_in_bitsignaltemp = bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_in[0];
    assign bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_out[0] = bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_out_bitsignaltemp;
    assign bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_out[0] = bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(3),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(33),
        .IMPL("zl_reg")
    ) thebubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg (
        .valid_in(bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_in_bitsignaltemp),
        .stall_in(bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_in_bitsignaltemp),
        .data_in(bubble_join_i_mul_slavereg_comp45_ma3_cma_q),
        .valid_out(bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_out_bitsignaltemp),
        .stall_out(bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_stall_out_bitsignaltemp),
        .data_out(bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_select_i_mul_slavereg_comp45_ma3_cma(BITSELECT,372)
    assign bubble_select_i_mul_slavereg_comp45_ma3_cma_b = $unsigned(bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_data_out[32:0]);

    // i_mul_slavereg_comp45_sums_align_1(BITSHIFT,222)@605
    assign i_mul_slavereg_comp45_sums_align_1_qint = { bubble_select_i_mul_slavereg_comp45_ma3_cma_b, 18'b000000000000000000 };
    assign i_mul_slavereg_comp45_sums_align_1_q = i_mul_slavereg_comp45_sums_align_1_qint[50:0];

    // bubble_select_i_mul_slavereg_comp45_im0_cma(BITSELECT,366)
    assign bubble_select_i_mul_slavereg_comp45_im0_cma_b = $unsigned(bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_data_out[27:0]);

    // bubble_select_i_mul_slavereg_comp45_im8_cma(BITSELECT,369)
    assign bubble_select_i_mul_slavereg_comp45_im8_cma_b = $unsigned(bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_data_out[35:0]);

    // i_mul_slavereg_comp45_sums_join_0(BITJOIN,221)@605
    assign i_mul_slavereg_comp45_sums_join_0_q = {bubble_select_i_mul_slavereg_comp45_im0_cma_b, bubble_select_i_mul_slavereg_comp45_im8_cma_b};

    // i_mul_slavereg_comp45_sums_result_add_0_0(ADD,224)@605
    assign i_mul_slavereg_comp45_sums_result_add_0_0_a = {1'b0, i_mul_slavereg_comp45_sums_join_0_q};
    assign i_mul_slavereg_comp45_sums_result_add_0_0_b = {14'b00000000000000, i_mul_slavereg_comp45_sums_align_1_q};
    assign i_mul_slavereg_comp45_sums_result_add_0_0_o = $unsigned(i_mul_slavereg_comp45_sums_result_add_0_0_a) + $unsigned(i_mul_slavereg_comp45_sums_result_add_0_0_b);
    assign i_mul_slavereg_comp45_sums_result_add_0_0_q = i_mul_slavereg_comp45_sums_result_add_0_0_o[64:0];

    // bgTrunc_i_mul_slavereg_comp45_sel_x(BITSELECT,154)@605
    assign bgTrunc_i_mul_slavereg_comp45_sel_x_in = i_mul_slavereg_comp45_sums_result_add_0_0_q[63:0];
    assign bgTrunc_i_mul_slavereg_comp45_sel_x_b = bgTrunc_i_mul_slavereg_comp45_sel_x_in[31:0];

    // SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48(STALLENABLE,454)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_fromReg0 <= '0;
            SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_fromReg0 <= SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_fromReg1 <= SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_consumed0 = (~ (SE_in_i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_backStall) & SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_wireValid) | SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_fromReg0;
    assign SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_consumed1 = (~ (SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_backStall) & SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_wireValid) | SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_fromReg1;
    // Consuming
    assign SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_StallValid = SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_backStall & SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_wireValid;
    assign SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_toReg0 = SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_StallValid & SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_consumed0;
    assign SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_toReg1 = SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_StallValid & SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_consumed1;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_or0 = SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_consumed0;
    assign SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_wireStall = ~ (SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_consumed1 & SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_or0);
    assign SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_backStall = SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_V0 = SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_wireValid & ~ (SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_fromReg0);
    assign SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_V1 = SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_wireValid & ~ (SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_wireValid = i_llvm_fpga_mem_memdep_slavereg_comp48_out_o_valid;

    // bubble_join_i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13(BITJOIN,326)
    assign bubble_join_i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_q = i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_data_out;

    // bubble_select_i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13(BITSELECT,327)
    assign bubble_select_i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_b = $unsigned(bubble_join_i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_q[0:0]);

    // i_memdep_phi6_or7_slavereg_comp24(LOGICAL,61)@605
    assign i_memdep_phi6_or7_slavereg_comp24_q = bubble_select_i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_b | bubble_select_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_b;

    // bubble_join_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo(BITJOIN,389)
    assign bubble_join_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_q = redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_data_out;

    // bubble_select_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo(BITSELECT,390)
    assign bubble_select_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_b = $unsigned(bubble_join_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_q[63:0]);

    // bubble_join_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4(BITJOIN,303)
    assign bubble_join_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_q = i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_out_dest_data_out_4_0;

    // bubble_select_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4(BITSELECT,304)
    assign bubble_select_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_b = $unsigned(bubble_join_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_q[63:0]);

    // i_mptr_bitcast_index56_slavereg_comp0_add_x(ADD,180)@605
    assign i_mptr_bitcast_index56_slavereg_comp0_add_x_a = {1'b0, bubble_select_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_b};
    assign i_mptr_bitcast_index56_slavereg_comp0_add_x_b = {1'b0, bubble_select_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_b};
    assign i_mptr_bitcast_index56_slavereg_comp0_add_x_o = $unsigned(i_mptr_bitcast_index56_slavereg_comp0_add_x_a) + $unsigned(i_mptr_bitcast_index56_slavereg_comp0_add_x_b);
    assign i_mptr_bitcast_index56_slavereg_comp0_add_x_q = i_mptr_bitcast_index56_slavereg_comp0_add_x_o[64:0];

    // i_mptr_bitcast_index56_slavereg_comp0_dupName_0_trunc_sel_x(BITSELECT,185)@605
    assign i_mptr_bitcast_index56_slavereg_comp0_dupName_0_trunc_sel_x_b = i_mptr_bitcast_index56_slavereg_comp0_add_x_q[63:0];

    // i_llvm_fpga_mem_memdep_slavereg_comp48(BLACKBOX,38)@605
    // in in_i_stall@20000000
    // out out_lsu_memdep_o_active@20000000
    // out out_memdep_slavereg_comp_avm_address@20000000
    // out out_memdep_slavereg_comp_avm_burstcount@20000000
    // out out_memdep_slavereg_comp_avm_byteenable@20000000
    // out out_memdep_slavereg_comp_avm_enable@20000000
    // out out_memdep_slavereg_comp_avm_read@20000000
    // out out_memdep_slavereg_comp_avm_write@20000000
    // out out_memdep_slavereg_comp_avm_writedata@20000000
    // out out_o_stall@20000000
    // out out_o_valid@695
    // out out_o_writeack@695
    slavereg_comp_i_llvm_fpga_mem_memdep_0 thei_llvm_fpga_mem_memdep_slavereg_comp48 (
        .in_flush(in_flush),
        .in_i_address(i_mptr_bitcast_index56_slavereg_comp0_dupName_0_trunc_sel_x_b),
        .in_i_dependence(i_memdep_phi6_or7_slavereg_comp24_q),
        .in_i_predicate(bubble_select_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_b),
        .in_i_stall(SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_backStall),
        .in_i_valid(SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_V0),
        .in_i_writedata(bgTrunc_i_mul_slavereg_comp45_sel_x_b),
        .in_memdep_slavereg_comp_avm_readdata(in_memdep_slavereg_comp_avm_readdata),
        .in_memdep_slavereg_comp_avm_readdatavalid(in_memdep_slavereg_comp_avm_readdatavalid),
        .in_memdep_slavereg_comp_avm_waitrequest(in_memdep_slavereg_comp_avm_waitrequest),
        .in_memdep_slavereg_comp_avm_writeack(in_memdep_slavereg_comp_avm_writeack),
        .out_lsu_memdep_o_active(i_llvm_fpga_mem_memdep_slavereg_comp48_out_lsu_memdep_o_active),
        .out_memdep_slavereg_comp_avm_address(i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_address),
        .out_memdep_slavereg_comp_avm_burstcount(i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_burstcount),
        .out_memdep_slavereg_comp_avm_byteenable(i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_byteenable),
        .out_memdep_slavereg_comp_avm_enable(i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_enable),
        .out_memdep_slavereg_comp_avm_read(i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_read),
        .out_memdep_slavereg_comp_avm_write(i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_write),
        .out_memdep_slavereg_comp_avm_writedata(i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_writedata),
        .out_o_stall(i_llvm_fpga_mem_memdep_slavereg_comp48_out_o_stall),
        .out_o_valid(i_llvm_fpga_mem_memdep_slavereg_comp48_out_o_valid),
        .out_o_writeack(i_llvm_fpga_mem_memdep_slavereg_comp48_out_o_writeack),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_i_llvm_fpga_mem_memdep_slavereg_comp48(BITJOIN,316)
    assign bubble_join_i_llvm_fpga_mem_memdep_slavereg_comp48_q = i_llvm_fpga_mem_memdep_slavereg_comp48_out_o_writeack;

    // bubble_select_i_llvm_fpga_mem_memdep_slavereg_comp48(BITSELECT,317)
    assign bubble_select_i_llvm_fpga_mem_memdep_slavereg_comp48_b = $unsigned(bubble_join_i_llvm_fpga_mem_memdep_slavereg_comp48_q[0:0]);

    // i_memdep_phi6_or8_slavereg_comp51(LOGICAL,62)@695
    assign i_memdep_phi6_or8_slavereg_comp51_q = bubble_select_i_llvm_fpga_mem_memdep_slavereg_comp48_b | bubble_select_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_b;

    // bubble_join_redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo(BITJOIN,386)
    assign bubble_join_redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_q = redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_data_out;

    // bubble_select_redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo(BITSELECT,387)
    assign bubble_select_redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_b = $unsigned(bubble_join_redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_q[63:0]);

    // i_llvm_fpga_mem_lm22_slavereg_comp52(BLACKBOX,36)@695
    // in in_i_stall@20000000
    // out out_lm22_slavereg_comp_avm_address@20000000
    // out out_lm22_slavereg_comp_avm_burstcount@20000000
    // out out_lm22_slavereg_comp_avm_byteenable@20000000
    // out out_lm22_slavereg_comp_avm_enable@20000000
    // out out_lm22_slavereg_comp_avm_read@20000000
    // out out_lm22_slavereg_comp_avm_write@20000000
    // out out_lm22_slavereg_comp_avm_writedata@20000000
    // out out_o_readdata@830
    // out out_o_stall@20000000
    // out out_o_valid@830
    slavereg_comp_i_llvm_fpga_mem_lm22_0 thei_llvm_fpga_mem_lm22_slavereg_comp52 (
        .in_flush(in_flush),
        .in_i_address(bubble_select_redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_b),
        .in_i_dependence(i_memdep_phi6_or8_slavereg_comp51_q),
        .in_i_predicate(bubble_select_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_b),
        .in_i_stall(SE_out_i_llvm_fpga_mem_lm22_slavereg_comp52_backStall),
        .in_i_valid(SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_V0),
        .in_lm22_slavereg_comp_avm_readdata(in_lm22_slavereg_comp_avm_readdata),
        .in_lm22_slavereg_comp_avm_readdatavalid(in_lm22_slavereg_comp_avm_readdatavalid),
        .in_lm22_slavereg_comp_avm_waitrequest(in_lm22_slavereg_comp_avm_waitrequest),
        .in_lm22_slavereg_comp_avm_writeack(in_lm22_slavereg_comp_avm_writeack),
        .out_lm22_slavereg_comp_avm_address(i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_address),
        .out_lm22_slavereg_comp_avm_burstcount(i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_burstcount),
        .out_lm22_slavereg_comp_avm_byteenable(i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_byteenable),
        .out_lm22_slavereg_comp_avm_enable(i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_enable),
        .out_lm22_slavereg_comp_avm_read(i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_read),
        .out_lm22_slavereg_comp_avm_write(i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_write),
        .out_lm22_slavereg_comp_avm_writedata(i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_writedata),
        .out_o_readdata(i_llvm_fpga_mem_lm22_slavereg_comp52_out_o_readdata),
        .out_o_stall(i_llvm_fpga_mem_lm22_slavereg_comp52_out_o_stall),
        .out_o_valid(i_llvm_fpga_mem_lm22_slavereg_comp52_out_o_valid),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_i_llvm_fpga_mem_lm22_slavereg_comp52(BITJOIN,309)
    assign bubble_join_i_llvm_fpga_mem_lm22_slavereg_comp52_q = i_llvm_fpga_mem_lm22_slavereg_comp52_out_o_readdata;

    // bubble_select_i_llvm_fpga_mem_lm22_slavereg_comp52(BITSELECT,310)
    assign bubble_select_i_llvm_fpga_mem_lm22_slavereg_comp52_b = $unsigned(bubble_join_i_llvm_fpga_mem_lm22_slavereg_comp52_q[31:0]);

    // SE_out_i_llvm_fpga_mem_lm22_slavereg_comp52(STALLENABLE,450)
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_mem_lm22_slavereg_comp52_V0 = SE_out_i_llvm_fpga_mem_lm22_slavereg_comp52_wireValid;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_mem_lm22_slavereg_comp52_backStall = i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_o_stall | ~ (SE_out_i_llvm_fpga_mem_lm22_slavereg_comp52_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_mem_lm22_slavereg_comp52_wireValid = i_llvm_fpga_mem_lm22_slavereg_comp52_out_o_valid;

    // i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x(BLACKBOX,196)@830
    // in in_i_stall@20000000
    // out out_o_stall@20000000
    // out out_o_valid@842
    // out out_c0_exit25_0_tpl@842
    // out out_c0_exit25_1_tpl@842
    // out out_c0_exit25_2_tpl@842
    slavereg_comp_i_sfc_s_c0_in_for_body_s_c0000r232_slavereg_comp54 thei_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x (
        .in_i_stall(SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_backStall),
        .in_i_valid(SE_out_i_llvm_fpga_mem_lm22_slavereg_comp52_V0),
        .in_c0_eni1_0_tpl(GND_q),
        .in_c0_eni1_1_tpl(bubble_select_i_llvm_fpga_mem_lm22_slavereg_comp52_b),
        .out_o_stall(i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_o_stall),
        .out_o_valid(i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_o_valid),
        .out_c0_exit25_0_tpl(),
        .out_c0_exit25_1_tpl(i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_c0_exit25_1_tpl),
        .out_c0_exit25_2_tpl(i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_c0_exit25_2_tpl),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x(BITJOIN,353)
    assign bubble_join_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_q = {i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_c0_exit25_2_tpl, i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_c0_exit25_1_tpl};

    // bubble_select_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x(BITSELECT,354)
    assign bubble_select_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_b = $unsigned(bubble_join_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_q[0:0]);
    assign bubble_select_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_c = $unsigned(bubble_join_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_q[32:1]);

    // SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57(STALLENABLE,452)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_fromReg0 <= '0;
            SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_fromReg0 <= SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_fromReg1 <= SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_consumed0 = (~ (SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_backStall) & SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireValid) | SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_fromReg0;
    assign SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_consumed1 = (~ (SR_SE_bubble_select_i_llvm_fpga_mem_memdep_5_slavereg_comp57_backStall) & SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireValid) | SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_fromReg1;
    // Consuming
    assign SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_StallValid = SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_backStall & SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireValid;
    assign SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_toReg0 = SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_StallValid & SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_consumed0;
    assign SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_toReg1 = SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_StallValid & SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_consumed1;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_or0 = SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_consumed0;
    assign SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireStall = ~ (SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_consumed1 & SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_or0);
    assign SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_backStall = SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V0 = SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireValid & ~ (SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_fromReg0);
    assign SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_V1 = SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireValid & ~ (SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_wireValid = i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_o_valid;

    // bubble_join_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo(BITJOIN,425)
    assign bubble_join_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_q = redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_data_out;

    // bubble_select_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo(BITSELECT,426)
    assign bubble_select_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_b = $unsigned(bubble_join_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_q[0:0]);

    // bubble_join_redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo(BITJOIN,392)
    assign bubble_join_redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_q = redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_data_out;

    // bubble_select_redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo(BITSELECT,393)
    assign bubble_select_redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_b = $unsigned(bubble_join_redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_q[0:0]);

    // bubble_join_redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo(BITJOIN,383)
    assign bubble_join_redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_q = redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_data_out;

    // bubble_select_redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo(BITSELECT,384)
    assign bubble_select_redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_b = $unsigned(bubble_join_redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_q[63:0]);

    // i_llvm_fpga_mem_memdep_5_slavereg_comp57(BLACKBOX,37)@842
    // in in_i_stall@20000000
    // out out_lsu_memdep_5_o_active@20000000
    // out out_memdep_5_slavereg_comp_avm_address@20000000
    // out out_memdep_5_slavereg_comp_avm_burstcount@20000000
    // out out_memdep_5_slavereg_comp_avm_byteenable@20000000
    // out out_memdep_5_slavereg_comp_avm_enable@20000000
    // out out_memdep_5_slavereg_comp_avm_read@20000000
    // out out_memdep_5_slavereg_comp_avm_write@20000000
    // out out_memdep_5_slavereg_comp_avm_writedata@20000000
    // out out_o_stall@20000000
    // out out_o_valid@932
    // out out_o_writeack@932
    slavereg_comp_i_llvm_fpga_mem_memdep_5_0 thei_llvm_fpga_mem_memdep_5_slavereg_comp57 (
        .in_flush(in_flush),
        .in_i_address(bubble_select_redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_b),
        .in_i_dependence(bubble_select_redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_b),
        .in_i_predicate(bubble_select_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_b),
        .in_i_stall(SE_out_i_llvm_fpga_mem_memdep_5_slavereg_comp57_backStall),
        .in_i_valid(SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_V0),
        .in_i_writedata(bubble_select_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_c),
        .in_memdep_5_slavereg_comp_avm_readdata(in_memdep_5_slavereg_comp_avm_readdata),
        .in_memdep_5_slavereg_comp_avm_readdatavalid(in_memdep_5_slavereg_comp_avm_readdatavalid),
        .in_memdep_5_slavereg_comp_avm_waitrequest(in_memdep_5_slavereg_comp_avm_waitrequest),
        .in_memdep_5_slavereg_comp_avm_writeack(in_memdep_5_slavereg_comp_avm_writeack),
        .out_lsu_memdep_5_o_active(i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_lsu_memdep_5_o_active),
        .out_memdep_5_slavereg_comp_avm_address(i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_address),
        .out_memdep_5_slavereg_comp_avm_burstcount(i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_burstcount),
        .out_memdep_5_slavereg_comp_avm_byteenable(i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_byteenable),
        .out_memdep_5_slavereg_comp_avm_enable(i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_enable),
        .out_memdep_5_slavereg_comp_avm_read(i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_read),
        .out_memdep_5_slavereg_comp_avm_write(i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_write),
        .out_memdep_5_slavereg_comp_avm_writedata(i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_writedata),
        .out_o_stall(i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_o_stall),
        .out_o_valid(i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_o_valid),
        .out_o_writeack(i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_o_writeack),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x(STALLENABLE,520)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_fromReg0 <= '0;
            SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_fromReg0 <= SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_toReg0;
            // Successor 1
            SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_fromReg1 <= SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_consumed0 = (~ (SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_backStall) & SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_wireValid) | SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_fromReg0;
    assign SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_consumed1 = (~ (SE_in_i_llvm_fpga_push_i1_memdep_phi4_push10_slavereg_comp56_backStall) & SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_wireValid) | SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_fromReg1;
    // Consuming
    assign SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_StallValid = SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_backStall & SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_wireValid;
    assign SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_toReg0 = SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_StallValid & SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_consumed0;
    assign SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_toReg1 = SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_StallValid & SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_consumed1;
    // Backward Stall generation
    assign SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_or0 = SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_consumed0;
    assign SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_wireStall = ~ (SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_consumed1 & SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_or0);
    assign SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_backStall = SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_wireStall;
    // Valid signal propagation
    assign SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_V0 = SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_wireValid & ~ (SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_fromReg0);
    assign SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_V1 = SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_wireValid & ~ (SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_wireValid = i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_out_o_valid;

    // bubble_join_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5(BITJOIN,297)
    assign bubble_join_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_q = i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_out_dest_data_out_5_0;

    // bubble_select_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5(BITSELECT,298)
    assign bubble_select_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_b = $unsigned(bubble_join_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_q[63:0]);

    // i_mptr_bitcast_index58_slavereg_comp0_add_x(ADD,186)@605
    assign i_mptr_bitcast_index58_slavereg_comp0_add_x_a = {1'b0, bubble_select_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_b};
    assign i_mptr_bitcast_index58_slavereg_comp0_add_x_b = {1'b0, bubble_select_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_b};
    assign i_mptr_bitcast_index58_slavereg_comp0_add_x_o = $unsigned(i_mptr_bitcast_index58_slavereg_comp0_add_x_a) + $unsigned(i_mptr_bitcast_index58_slavereg_comp0_add_x_b);
    assign i_mptr_bitcast_index58_slavereg_comp0_add_x_q = i_mptr_bitcast_index58_slavereg_comp0_add_x_o[64:0];

    // i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x(BITSELECT,191)@605
    assign i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b = i_mptr_bitcast_index58_slavereg_comp0_add_x_q[63:0];

    // redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo(STALLFIFO,271)
    assign redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_in = SE_out_i_llvm_fpga_ffwd_dest_p1025f32_mptr_bitcast576315_slavereg_comp5_V0;
    assign redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_in = SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_backStall;
    assign redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_data_in = i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b;
    assign redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_in_bitsignaltemp = redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_in[0];
    assign redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_in_bitsignaltemp = redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_in[0];
    assign redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_out[0] = redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_out_bitsignaltemp;
    assign redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_out[0] = redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(238),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(64),
        .IMPL("ram")
    ) theredist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo (
        .valid_in(redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_in_bitsignaltemp),
        .stall_in(redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_in_bitsignaltemp),
        .data_in(i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b),
        .valid_out(redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_out_bitsignaltemp),
        .stall_out(redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_stall_out_bitsignaltemp),
        .data_out(redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo(BITJOIN,404)
    assign bubble_join_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_q = redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_data_out;

    // bubble_select_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo(BITSELECT,405)
    assign bubble_select_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_b = $unsigned(bubble_join_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_q[0:0]);

    // bubble_join_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14(BITJOIN,332)
    assign bubble_join_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_q = i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_out_data_out;

    // bubble_select_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14(BITSELECT,333)
    assign bubble_select_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_b = $unsigned(bubble_join_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_q[0:0]);

    // i_memdep_phi3_or_slavereg_comp25(LOGICAL,60)@603 + 1
    assign i_memdep_phi3_or_slavereg_comp25_qi = bubble_select_i_llvm_fpga_pop_i1_memdep_phi_pop8_slavereg_comp14_b | bubble_select_redist12_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out_136_fifo_b;
    dspba_delay_ver #( .width(1), .depth(1), .reset_kind("ASYNC"), .phase(0), .modulus(1), .reset_high(1'b0) )
    i_memdep_phi3_or_slavereg_comp25_delay ( .xin(i_memdep_phi3_or_slavereg_comp25_qi), .xout(i_memdep_phi3_or_slavereg_comp25_q), .ena(SE_i_memdep_phi3_or_slavereg_comp25_backEN[0]), .clk(clock), .aclr(resetn) );

    // redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo(STALLFIFO,274)
    assign redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_in = SE_i_memdep_phi3_or_slavereg_comp25_V0;
    assign redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_in = SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_backStall;
    assign redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_data_in = i_memdep_phi3_or_slavereg_comp25_q;
    assign redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_in_bitsignaltemp = redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_in[0];
    assign redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_in_bitsignaltemp = redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_in[0];
    assign redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_out[0] = redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_out_bitsignaltemp;
    assign redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_out[0] = redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(239),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo (
        .valid_in(redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_in_bitsignaltemp),
        .stall_in(redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_in_bitsignaltemp),
        .data_in(i_memdep_phi3_or_slavereg_comp25_q),
        .valid_out(redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_out_bitsignaltemp),
        .stall_out(redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_stall_out_bitsignaltemp),
        .data_out(redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo(STALLENABLE,578)
    // Valid signal propagation
    assign SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_V0 = SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_wireValid;
    // Backward Stall generation
    assign SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_backStall = i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_o_stall | ~ (SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_and0 = redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_out;
    assign SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_and1 = redist8_i_memdep_phi3_or_slavereg_comp25_q_239_fifo_valid_out & SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_and0;
    assign SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_and2 = redist5_i_mptr_bitcast_index58_slavereg_comp0_dupName_0_trunc_sel_x_b_237_fifo_valid_out & SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_and1;
    assign SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_wireValid = SE_out_i_sfc_s_c0_in_for_body_slavereg_comps_c0_enter232_slavereg_comp54_aunroll_x_V0 & SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_and2;

    // redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo(STALLFIFO,285)
    assign redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_in = SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_V1;
    assign redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_in = SE_out_redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_backStall;
    assign redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_data_in = bubble_select_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_b;
    assign redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_in_bitsignaltemp = redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_in[0];
    assign redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_in_bitsignaltemp = redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_in[0];
    assign redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_out[0] = redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_out_bitsignaltemp;
    assign redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_out[0] = redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(148),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo (
        .valid_in(redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_in_bitsignaltemp),
        .stall_in(redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_in_bitsignaltemp),
        .data_in(bubble_select_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_b),
        .valid_out(redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_valid_out_bitsignaltemp),
        .stall_out(redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_out_bitsignaltemp),
        .data_out(redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo(STALLENABLE,562)
    // Valid signal propagation
    assign SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_V0 = SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_wireValid;
    // Backward Stall generation
    assign SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_backStall = i_llvm_fpga_mem_lm22_slavereg_comp52_out_o_stall | ~ (SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_and0 = redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_valid_out;
    assign SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_and1 = redist6_i_mptr_bitcast_index52_slavereg_comp0_dupName_0_trunc_sel_x_b_228_fifo_valid_out & SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_and0;
    assign SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_and2 = SE_out_i_llvm_fpga_mem_memdep_slavereg_comp48_V1 & SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_and1;
    assign SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_wireValid = SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_V0 & SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_and2;

    // SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo(STALLENABLE,576)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_fromReg0 <= '0;
            SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_fromReg0 <= SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_toReg0;
            // Successor 1
            SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_fromReg1 <= SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_consumed0 = (~ (SE_out_redist11_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_228_fifo_backStall) & SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_wireValid) | SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_fromReg0;
    assign SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_consumed1 = (~ (redist19_i_first_cleanup_xor_or_slavereg_comp36_q_375_fifo_stall_out) & SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_wireValid) | SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_fromReg1;
    // Consuming
    assign SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_StallValid = SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_backStall & SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_wireValid;
    assign SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_toReg0 = SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_StallValid & SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_consumed0;
    assign SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_toReg1 = SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_StallValid & SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_consumed1;
    // Backward Stall generation
    assign SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_or0 = SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_consumed0;
    assign SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_wireStall = ~ (SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_consumed1 & SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_or0);
    assign SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_backStall = SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_wireStall;
    // Valid signal propagation
    assign SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_V0 = SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_wireValid & ~ (SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_fromReg0);
    assign SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_V1 = SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_wireValid & ~ (SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_wireValid = redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_out;

    // redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo(STALLFIFO,284)
    assign redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_in = SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_V1;
    assign redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_in = SE_out_redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_backStall;
    assign redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_data_in = bubble_select_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_b;
    assign redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_in_bitsignaltemp = redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_in[0];
    assign redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_in_bitsignaltemp = redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_in[0];
    assign redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_out[0] = redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_out_bitsignaltemp;
    assign redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_out[0] = redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(91),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo (
        .valid_in(redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_in_bitsignaltemp),
        .stall_in(redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_in_bitsignaltemp),
        .data_in(bubble_select_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_b),
        .valid_out(redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_valid_out_bitsignaltemp),
        .stall_out(redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_out_bitsignaltemp),
        .data_out(redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data(STALLENABLE,700)
    // Valid signal propagation
    assign SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_V0 = SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_wireValid;
    // Backward Stall generation
    assign SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_backStall = i_llvm_fpga_mem_memdep_slavereg_comp48_out_o_stall | ~ (SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_wireValid);
    // Computing multiple Valid(s)
    assign SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and0 = bubble_out_i_mul_slavereg_comp45_ma3_cma_data_reg_valid_out;
    assign SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and1 = bubble_out_i_mul_slavereg_comp45_im8_cma_data_reg_valid_out & SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and0;
    assign SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and2 = bubble_out_i_mul_slavereg_comp45_im0_cma_data_reg_valid_out & SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and1;
    assign SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and3 = i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast556214_slavereg_comp4_out_valid_out & SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and2;
    assign SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and4 = SE_out_redist7_i_mptr_bitcast_index52_slavereg_comp0_shift_join_x_q_138_fifo_V0 & SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and3;
    assign SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and5 = i_llvm_fpga_pop_i1_memdep_phi4_pop10_slavereg_comp13_out_valid_out & SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and4;
    assign SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and6 = SE_out_redist10_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out_138_fifo_V0 & SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and5;
    assign SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_wireValid = SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_V0 & SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_and6;

    // SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo(STALLENABLE,574)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_fromReg0 <= '0;
            SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_fromReg0 <= SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_toReg0;
            // Successor 1
            SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_fromReg1 <= SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_consumed0 = (~ (SE_out_bubble_out_i_mul_slavereg_comp45_ma3_cma_data_backStall) & SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_wireValid) | SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_fromReg0;
    assign SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_consumed1 = (~ (redist18_i_first_cleanup_xor_or_slavereg_comp36_q_228_fifo_stall_out) & SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_wireValid) | SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_fromReg1;
    // Consuming
    assign SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_StallValid = SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_backStall & SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_wireValid;
    assign SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_toReg0 = SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_StallValid & SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_consumed0;
    assign SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_toReg1 = SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_StallValid & SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_consumed1;
    // Backward Stall generation
    assign SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_or0 = SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_consumed0;
    assign SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_wireStall = ~ (SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_consumed1 & SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_or0);
    assign SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_backStall = SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_wireStall;
    // Valid signal propagation
    assign SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_V0 = SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_wireValid & ~ (SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_fromReg0);
    assign SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_V1 = SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_wireValid & ~ (SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_wireValid = redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_out;

    // redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo(STALLFIFO,283)
    assign redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_in = SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_V1;
    assign redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_in = SE_out_redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_backStall;
    assign redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_data_in = i_first_cleanup_xor_or_slavereg_comp36_q;
    assign redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_in_bitsignaltemp = redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_in[0];
    assign redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_in_bitsignaltemp = redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_in[0];
    assign redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_out[0] = redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_out_bitsignaltemp;
    assign redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_out[0] = redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(139),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo (
        .valid_in(redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_in_bitsignaltemp),
        .stall_in(redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_in_bitsignaltemp),
        .data_in(i_first_cleanup_xor_or_slavereg_comp36_q),
        .valid_out(redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_valid_out_bitsignaltemp),
        .stall_out(redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_out_bitsignaltemp),
        .data_out(redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_i_memdep_phi6_or_slavereg_comp23(STALLENABLE,497)
    // Valid signal propagation
    assign SE_i_memdep_phi6_or_slavereg_comp23_V0 = SE_i_memdep_phi6_or_slavereg_comp23_wireValid;
    // Backward Stall generation
    assign SE_i_memdep_phi6_or_slavereg_comp23_backStall = i_llvm_fpga_mem_lm1_slavereg_comp41_out_o_stall | ~ (SE_i_memdep_phi6_or_slavereg_comp23_wireValid);
    // Computing multiple Valid(s)
    assign SE_i_memdep_phi6_or_slavereg_comp23_and0 = SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_V0;
    assign SE_i_memdep_phi6_or_slavereg_comp23_and1 = SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_V0 & SE_i_memdep_phi6_or_slavereg_comp23_and0;
    assign SE_i_memdep_phi6_or_slavereg_comp23_and2 = SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_V0 & SE_i_memdep_phi6_or_slavereg_comp23_and1;
    assign SE_i_memdep_phi6_or_slavereg_comp23_wireValid = SE_out_i_llvm_fpga_ffwd_dest_p1025i32_mptr_bitcast535913_slavereg_comp2_V0 & SE_i_memdep_phi6_or_slavereg_comp23_and2;

    // i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1(BLACKBOX,29)@466
    // in in_stall_in@20000000
    // out out_dest_data_out_0_0@467
    // out out_stall_out@20000000
    // out out_valid_out@467
    slavereg_comp_i_llvm_fpga_ffwd_dest_i32_index6710_0 thei_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1 (
        .in_intel_reserved_ffwd_0_0(in_intel_reserved_ffwd_0_0),
        .in_stall_in(SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_backStall),
        .in_valid_in(SE_out_bubble_out_slavereg_comp_B3_merge_reg_aunroll_x_2_V0),
        .out_dest_data_out_0_0(i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_out_dest_data_out_0_0),
        .out_stall_out(i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_out_stall_out),
        .out_valid_out(i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1(STALLENABLE,436)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_fromReg0 <= '0;
            SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_fromReg0 <= SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_fromReg1 <= SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_toReg1;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_consumed0 = (~ (SE_i_memdep_phi6_or_slavereg_comp23_backStall) & SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_wireValid) | SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_fromReg0;
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_consumed1 = (~ (redist17_i_first_cleanup_xor_or_slavereg_comp36_q_138_fifo_stall_out) & SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_wireValid) | SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_fromReg1;
    // Consuming
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_StallValid = SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_backStall & SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_wireValid;
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_toReg0 = SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_StallValid & SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_consumed0;
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_toReg1 = SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_StallValid & SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_consumed1;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_or0 = SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_consumed0;
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_wireStall = ~ (SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_consumed1 & SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_or0);
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_backStall = SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_V0 = SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_wireValid & ~ (SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_fromReg0);
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_V1 = SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_wireValid & ~ (SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_fromReg1);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_and0 = i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_out_valid_out;
    assign SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_wireValid = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V3 & SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_and0;

    // i_exitcond_slavereg_comp29_cmp_nsign(LOGICAL,209)@467
    assign i_exitcond_slavereg_comp29_cmp_nsign_q = $unsigned(~ (i_fpga_indvars_iv_replace_phi_slavereg_comp20_q[32:32]));

    // i_notcmp_slavereg_comp38(LOGICAL,69)@467
    assign i_notcmp_slavereg_comp38_q = i_exitcond_slavereg_comp29_cmp_nsign_q ^ VCC_q;

    // SR_SE_i_masked_slavereg_comp43(STALLREG,787)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SR_SE_i_masked_slavereg_comp43_r_valid <= 1'b0;
            SR_SE_i_masked_slavereg_comp43_r_data0 <= 1'bx;
            SR_SE_i_masked_slavereg_comp43_r_data1 <= 1'bx;
        end
        else
        begin
            // Valid
            SR_SE_i_masked_slavereg_comp43_r_valid <= SE_i_masked_slavereg_comp43_backStall & (SR_SE_i_masked_slavereg_comp43_r_valid | SR_SE_i_masked_slavereg_comp43_i_valid);

            if (SR_SE_i_masked_slavereg_comp43_r_valid == 1'b0)
            begin
                // Data(s)
                SR_SE_i_masked_slavereg_comp43_r_data0 <= i_notcmp_slavereg_comp38_q;
                SR_SE_i_masked_slavereg_comp43_r_data1 <= i_first_cleanup_slavereg_comp17_sel_x_b;
            end

        end
    end
    // Computing multiple Valid(s)
    assign SR_SE_i_masked_slavereg_comp43_and0 = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_V1;
    assign SR_SE_i_masked_slavereg_comp43_i_valid = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V2 & SR_SE_i_masked_slavereg_comp43_and0;
    // Stall signal propagation
    assign SR_SE_i_masked_slavereg_comp43_backStall = SR_SE_i_masked_slavereg_comp43_r_valid | ~ (SR_SE_i_masked_slavereg_comp43_i_valid);

    // Valid
    assign SR_SE_i_masked_slavereg_comp43_V = SR_SE_i_masked_slavereg_comp43_r_valid == 1'b1 ? SR_SE_i_masked_slavereg_comp43_r_valid : SR_SE_i_masked_slavereg_comp43_i_valid;

    // Data0
    assign SR_SE_i_masked_slavereg_comp43_D0 = SR_SE_i_masked_slavereg_comp43_r_valid == 1'b1 ? SR_SE_i_masked_slavereg_comp43_r_data0 : i_notcmp_slavereg_comp38_q;
    // Data1
    assign SR_SE_i_masked_slavereg_comp43_D1 = SR_SE_i_masked_slavereg_comp43_r_valid == 1'b1 ? SR_SE_i_masked_slavereg_comp43_r_data1 : i_first_cleanup_slavereg_comp17_sel_x_b;

    // SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39(STALLENABLE,483)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_fromReg0 <= '0;
            SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_fromReg1 <= '0;
        end
        else
        begin
            // Successor 0
            SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_fromReg0 <= SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_toReg0;
            // Successor 1
            SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_fromReg1 <= SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_toReg1;
        end
    end
    // Input Stall processing
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_consumed0 = (~ (i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_stall_out) & SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireValid) | SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_fromReg0;
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_consumed1 = (~ (SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_backStall) & SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireValid) | SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_fromReg1;
    // Consuming
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_StallValid = SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_backStall & SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireValid;
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_toReg0 = SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_StallValid & SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_consumed0;
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_toReg1 = SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_StallValid & SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_consumed1;
    // Backward Stall generation
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_or0 = SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_consumed0;
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireStall = ~ (SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_consumed1 & SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_or0);
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_backStall = SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireStall;
    // Valid signal propagation
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_V0 = SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireValid & ~ (SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_fromReg0);
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_V1 = SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireValid & ~ (SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_fromReg1);
    // Computing multiple Valid(s)
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_and0 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V1;
    assign SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireValid = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_V0 & SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_and0;

    // leftShiftStage0Idx1Rng1_uid229_i_cleanups_shl_slavereg_comp0_shift_x(BITSELECT,228)@467
    assign leftShiftStage0Idx1Rng1_uid229_i_cleanups_shl_slavereg_comp0_shift_x_in = bubble_select_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_b[2:0];
    assign leftShiftStage0Idx1Rng1_uid229_i_cleanups_shl_slavereg_comp0_shift_x_b = leftShiftStage0Idx1Rng1_uid229_i_cleanups_shl_slavereg_comp0_shift_x_in[2:0];

    // leftShiftStage0Idx1_uid230_i_cleanups_shl_slavereg_comp0_shift_x(BITJOIN,229)@467
    assign leftShiftStage0Idx1_uid230_i_cleanups_shl_slavereg_comp0_shift_x_q = {leftShiftStage0Idx1Rng1_uid229_i_cleanups_shl_slavereg_comp0_shift_x_b, GND_q};

    // leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x(MUX,231)@467
    assign leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_s = VCC_q;
    always @(leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_s or bubble_select_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_b or leftShiftStage0Idx1_uid230_i_cleanups_shl_slavereg_comp0_shift_x_q)
    begin
        unique case (leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_s)
            1'b0 : leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_q = bubble_select_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_b;
            1'b1 : leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_q = leftShiftStage0Idx1_uid230_i_cleanups_shl_slavereg_comp0_shift_x_q;
            default : leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_q = 4'b0;
        endcase
    end

    // i_cleanups_shl_slavereg_comp18_vt_select_3(BITSELECT,19)@467
    assign i_cleanups_shl_slavereg_comp18_vt_select_3_b = leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_q[3:1];

    // i_cleanups_shl_slavereg_comp18_vt_join(BITJOIN,18)@467
    assign i_cleanups_shl_slavereg_comp18_vt_join_q = {i_cleanups_shl_slavereg_comp18_vt_select_3_b, GND_q};

    // i_or_slavereg_comp42(LOGICAL,70)@467
    assign i_or_slavereg_comp42_q = i_notcmp_slavereg_comp38_q | i_first_cleanup_xor_slavereg_comp26_q;

    // i_next_cleanups_slavereg_comp46(MUX,65)@467
    assign i_next_cleanups_slavereg_comp46_s = i_or_slavereg_comp42_q;
    always @(i_next_cleanups_slavereg_comp46_s or bubble_select_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_b or i_cleanups_shl_slavereg_comp18_vt_join_q)
    begin
        unique case (i_next_cleanups_slavereg_comp46_s)
            1'b0 : i_next_cleanups_slavereg_comp46_q = bubble_select_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_b;
            1'b1 : i_next_cleanups_slavereg_comp46_q = i_cleanups_shl_slavereg_comp18_vt_join_q;
            default : i_next_cleanups_slavereg_comp46_q = 4'b0;
        endcase
    end

    // SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x(STALLENABLE,532)
    // Valid signal propagation
    assign SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_V0 = SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_wireValid;
    // Backward Stall generation
    assign SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_backStall = i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_stall_out | ~ (SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_wireValid);
    // Computing multiple Valid(s)
    assign SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_wireValid = SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_V;

    // SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x(STALLREG,792)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_valid <= 1'b0;
            SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_data0 <= 4'bxxxx;
            SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_data1 <= 1'bx;
        end
        else
        begin
            // Valid
            SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_valid <= SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_backStall & (SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_valid | SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_i_valid);

            if (SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_valid == 1'b0)
            begin
                // Data(s)
                SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_data0 <= i_next_cleanups_slavereg_comp46_q;
                SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_data1 <= $unsigned(bubble_select_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_b);
            end

        end
    end
    // Computing multiple Valid(s)
    assign SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_and0 = SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_V1;
    assign SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_and1 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V0 & SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_and0;
    assign SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_i_valid = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V3 & SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_and1;
    // Stall signal propagation
    assign SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_backStall = SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_valid | ~ (SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_i_valid);

    // Valid
    assign SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_V = SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_valid == 1'b1 ? SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_valid : SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_i_valid;

    // Data0
    assign SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_D0 = SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_valid == 1'b1 ? SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_data0 : i_next_cleanups_slavereg_comp46_q;
    // Data1
    assign SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_D1 = SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_valid == 1'b1 ? SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_r_data1 : bubble_select_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_b;

    // SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6(STALLENABLE,470)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg0 <= '0;
            SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg1 <= '0;
            SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg2 <= '0;
            SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg3 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg0 <= SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg1 <= SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg1;
            // Successor 2
            SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg2 <= SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg2;
            // Successor 3
            SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg3 <= SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg3;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed0 = (~ (SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_backStall) & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireValid) | SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg0;
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed1 = (~ (SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_backStall) & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireValid) | SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg1;
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed2 = (~ (SR_SE_i_masked_slavereg_comp43_backStall) & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireValid) | SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg2;
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed3 = (~ (SE_out_i_llvm_fpga_ffwd_dest_i32_index6710_slavereg_comp1_backStall) & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireValid) | SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg3;
    // Consuming
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_StallValid = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_backStall & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireValid;
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg0 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_StallValid & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed0;
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg1 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_StallValid & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed1;
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg2 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_StallValid & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed2;
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_toReg3 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_StallValid & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed3;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_or0 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed0;
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_or1 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed1 & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_or0;
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_or2 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed2 & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_or1;
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireStall = ~ (SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_consumed3 & SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_or2);
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_backStall = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V0 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireValid & ~ (SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg0);
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V1 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireValid & ~ (SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg1);
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V2 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireValid & ~ (SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg2);
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_V3 = SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireValid & ~ (SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_fromReg3);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_wireValid = i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_valid_out;

    // GND(CONSTANT,0)
    assign GND_q = $unsigned(1'b0);

    // SE_out_i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49(STALLENABLE,490)
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_backStall = $unsigned(1'b0);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_wireValid = i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_valid_out;

    // i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49(BLACKBOX,56)@467
    // in in_stall_in@20000000
    // out out_data_out@468
    // out out_feedback_out_13@20000000
    // out out_feedback_valid_out_13@20000000
    // out out_stall_out@20000000
    // out out_valid_out@468
    slavereg_comp_i_llvm_fpga_push_i4_cleanups_push13_0 thei_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49 (
        .in_data_in(SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_D0),
        .in_feedback_stall_in_13(i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_feedback_stall_out_13),
        .in_keep_going(SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_D1),
        .in_stall_in(SE_out_i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_backStall),
        .in_valid_in(SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_V0),
        .out_data_out(),
        .out_feedback_out_13(i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_feedback_out_13),
        .out_feedback_valid_out_13(i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_feedback_valid_out_13),
        .out_stall_out(i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_stall_out),
        .out_valid_out(i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // c_i4_759(CONSTANT,12)
    assign c_i4_759_q = $unsigned(4'b0111);

    // i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6(BLACKBOX,46)@466
    // in in_stall_in@20000000
    // out out_data_out@467
    // out out_feedback_stall_out_13@20000000
    // out out_stall_out@20000000
    // out out_valid_out@467
    slavereg_comp_i_llvm_fpga_pop_i4_cleanups_pop13_0 thei_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6 (
        .in_data_in(c_i4_759_q),
        .in_dir(bubble_select_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_b),
        .in_feedback_in_13(i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_feedback_out_13),
        .in_feedback_valid_in_13(i_llvm_fpga_push_i4_cleanups_push13_slavereg_comp49_out_feedback_valid_out_13),
        .in_predicate(GND_q),
        .in_stall_in(SE_out_i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_backStall),
        .in_valid_in(SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V6),
        .out_data_out(i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_data_out),
        .out_feedback_stall_out_13(i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_feedback_stall_out_13),
        .out_stall_out(i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_stall_out),
        .out_valid_out(i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // c_i33_undef61(CONSTANT,10)
    assign c_i33_undef61_q = $unsigned(33'b000000000000000000000000000000000);

    // i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9(BLACKBOX,45)@466
    // in in_stall_in@20000000
    // out out_data_out@467
    // out out_feedback_stall_out_6@20000000
    // out out_stall_out@20000000
    // out out_valid_out@467
    slavereg_comp_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_0 thei_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9 (
        .in_data_in(c_i33_undef61_q),
        .in_dir(bubble_select_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_b),
        .in_feedback_in_6(i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_feedback_out_6),
        .in_feedback_valid_in_6(i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_out_feedback_valid_out_6),
        .in_predicate(GND_q),
        .in_stall_in(SE_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_backStall),
        .in_valid_in(SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V5),
        .out_data_out(i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_data_out),
        .out_feedback_stall_out_6(i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_feedback_stall_out_6),
        .out_stall_out(i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_stall_out),
        .out_valid_out(i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10(BLACKBOX,44)@466
    // in in_stall_in@20000000
    // out out_data_out@467
    // out out_feedback_stall_out_7@20000000
    // out out_stall_out@20000000
    // out out_valid_out@467
    slavereg_comp_i_llvm_fpga_pop_i32_i_050_pop7_0 thei_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10 (
        .in_data_in(c_i32_062_q),
        .in_dir(bubble_select_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_b),
        .in_feedback_in_7(i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_feedback_out_7),
        .in_feedback_valid_in_7(i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_out_feedback_valid_out_7),
        .in_predicate(GND_q),
        .in_stall_in(SE_out_i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_backStall),
        .in_valid_in(SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V4),
        .out_data_out(i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_data_out),
        .out_feedback_stall_out_7(i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_feedback_stall_out_7),
        .out_stall_out(i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_stall_out),
        .out_valid_out(i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12(BLACKBOX,42)@466
    // in in_stall_in@20000000
    // out out_data_out@467
    // out out_feedback_stall_out_11@20000000
    // out out_stall_out@20000000
    // out out_valid_out@467
    slavereg_comp_i_llvm_fpga_pop_i1_memdep_phi6_pop11_0 thei_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12 (
        .in_data_in(GND_q),
        .in_dir(bubble_select_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_b),
        .in_feedback_in_11(i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_feedback_out_11),
        .in_feedback_valid_in_11(i_llvm_fpga_push_i1_memdep_phi6_push11_slavereg_comp58_out_feedback_valid_out_11),
        .in_predicate(GND_q),
        .in_stall_in(SE_out_i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_backStall),
        .in_valid_in(SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V3),
        .out_data_out(i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_data_out),
        .out_feedback_stall_out_11(i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_feedback_stall_out_11),
        .out_stall_out(i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_stall_out),
        .out_valid_out(i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11(BLACKBOX,40)@466
    // in in_stall_in@20000000
    // out out_data_out@467
    // out out_feedback_stall_out_9@20000000
    // out out_stall_out@20000000
    // out out_valid_out@467
    slavereg_comp_i_llvm_fpga_pop_i1_memdep_phi3_pop9_0 thei_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11 (
        .in_data_in(GND_q),
        .in_dir(bubble_select_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_b),
        .in_feedback_in_9(i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_feedback_out_9),
        .in_feedback_valid_in_9(i_llvm_fpga_push_i1_memdep_phi3_push9_slavereg_comp50_out_feedback_valid_out_9),
        .in_predicate(GND_q),
        .in_stall_in(SE_out_i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_backStall),
        .in_valid_in(SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V2),
        .out_data_out(i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_data_out),
        .out_feedback_stall_out_9(i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_feedback_stall_out_9),
        .out_stall_out(i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_stall_out),
        .out_valid_out(i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0(STALLENABLE,542)
    // Valid signal propagation
    assign SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_V0 = SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_0;
    assign SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_V1 = SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_1;
    // Stall signal propagation
    assign SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_s_tv_0 = SE_i_fpga_indvars_iv_replace_phi_slavereg_comp20_backStall & SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_0;
    assign SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_s_tv_1 = redist2_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_601_fifo_stall_out & SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_1;
    // Backward Enable generation
    assign SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_or0 = SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_s_tv_0;
    assign SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_backEN = ~ (SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_s_tv_1 | SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_or0);
    // Determine whether to write valid data into the first register stage
    assign SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_v_s_0 = SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_backEN & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V0;
    // Backward Stall generation
    assign SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_backStall = ~ (SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_v_s_0);
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_0 <= 1'b0;
            SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_1 <= 1'b0;
        end
        else
        begin
            if (SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_backEN == 1'b0)
            begin
                SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_0 <= SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_0 & SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_s_tv_0;
            end
            else
            begin
                SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_0 <= SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_v_s_0;
            end

            if (SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_backEN == 1'b0)
            begin
                SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_1 <= SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_1 & SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_s_tv_1;
            end
            else
            begin
                SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_R_v_1 <= SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_v_s_0;
            end

        end
    end

    // bubble_join_slavereg_comp_B3_merge_reg_aunroll_x(BITJOIN,356)
    assign bubble_join_slavereg_comp_B3_merge_reg_aunroll_x_q = slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl;

    // bubble_select_slavereg_comp_B3_merge_reg_aunroll_x(BITSELECT,357)
    assign bubble_select_slavereg_comp_B3_merge_reg_aunroll_x_b = $unsigned(bubble_join_slavereg_comp_B3_merge_reg_aunroll_x_q[0:0]);

    // redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo(STALLFIFO,265)
    assign redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_in = SE_out_slavereg_comp_B3_merge_reg_aunroll_x_V6;
    assign redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_in = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_backStall;
    assign redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_data_in = bubble_select_slavereg_comp_B3_merge_reg_aunroll_x_b;
    assign redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_in_bitsignaltemp = redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_in[0];
    assign redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_in_bitsignaltemp = redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_in[0];
    assign redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_out[0] = redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_out_bitsignaltemp;
    assign redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_out[0] = redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_out_bitsignaltemp;
    acl_data_fifo #(
        .DEPTH(466),
        .STRICT_DEPTH(0),
        .ALLOW_FULL_WRITE(0),
        .DATA_WIDTH(1),
        .IMPL("ram")
    ) theredist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo (
        .valid_in(redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_in_bitsignaltemp),
        .stall_in(redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_in_bitsignaltemp),
        .data_in(bubble_select_slavereg_comp_B3_merge_reg_aunroll_x_b),
        .valid_out(redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_out_bitsignaltemp),
        .stall_out(redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_stall_out_bitsignaltemp),
        .data_out(redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_data_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo(STALLENABLE,541)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg0 <= '0;
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg1 <= '0;
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg2 <= '0;
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg3 <= '0;
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg4 <= '0;
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg5 <= '0;
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg6 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg0 <= SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg0;
            // Successor 1
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg1 <= SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg1;
            // Successor 2
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg2 <= SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg2;
            // Successor 3
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg3 <= SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg3;
            // Successor 4
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg4 <= SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg4;
            // Successor 5
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg5 <= SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg5;
            // Successor 6
            SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg6 <= SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg6;
        end
    end
    // Input Stall processing
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed0 = (~ (SE_redist1_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_466_0_backStall) & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid) | SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg0;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed1 = (~ (i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_stall_out) & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid) | SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg1;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed2 = (~ (i_llvm_fpga_pop_i1_memdep_phi3_pop9_slavereg_comp11_out_stall_out) & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid) | SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg2;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed3 = (~ (i_llvm_fpga_pop_i1_memdep_phi6_pop11_slavereg_comp12_out_stall_out) & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid) | SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg3;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed4 = (~ (i_llvm_fpga_pop_i32_i_050_pop7_slavereg_comp10_out_stall_out) & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid) | SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg4;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed5 = (~ (i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_out_stall_out) & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid) | SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg5;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed6 = (~ (i_llvm_fpga_pop_i4_cleanups_pop13_slavereg_comp6_out_stall_out) & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid) | SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg6;
    // Consuming
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_StallValid = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_backStall & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg0 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_StallValid & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed0;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg1 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_StallValid & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed1;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg2 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_StallValid & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed2;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg3 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_StallValid & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed3;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg4 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_StallValid & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed4;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg5 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_StallValid & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed5;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_toReg6 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_StallValid & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed6;
    // Backward Stall generation
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or0 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed0;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or1 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed1 & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or0;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or2 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed2 & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or1;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or3 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed3 & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or2;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or4 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed4 & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or3;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or5 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed5 & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or4;
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireStall = ~ (SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_consumed6 & SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_or5);
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_backStall = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireStall;
    // Valid signal propagation
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V0 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid & ~ (SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg0);
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V1 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid & ~ (SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg1);
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V2 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid & ~ (SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg2);
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V3 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid & ~ (SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg3);
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V4 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid & ~ (SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg4);
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V5 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid & ~ (SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg5);
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V6 = SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid & ~ (SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_fromReg6);
    // Computing multiple Valid(s)
    assign SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_wireValid = redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_valid_out;

    // SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7(STALLENABLE,456)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg0 <= '0;
            SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg1 <= '0;
            SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg2 <= '0;
            SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg3 <= '0;
            SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg4 <= '0;
        end
        else
        begin
            // Successor 0
            SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg0 <= SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg0;
            // Successor 1
            SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg1 <= SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg1;
            // Successor 2
            SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg2 <= SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg2;
            // Successor 3
            SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg3 <= SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg3;
            // Successor 4
            SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg4 <= SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg4;
        end
    end
    // Input Stall processing
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed0 = (~ (bubble_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_1_reg_stall_out) & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid) | SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg0;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed1 = (~ (SE_in_i_llvm_fpga_push_i32_i_050_push7_slavereg_comp35_backStall) & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid) | SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg1;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed2 = (~ (SR_SE_in_i_llvm_fpga_push_i33_fpga_indvars_iv_push6_slavereg_comp40_backStall) & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid) | SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg2;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed3 = (~ (SR_SE_leftShiftStage0_uid232_i_cleanups_shl_slavereg_comp0_shift_x_backStall) & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid) | SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg3;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed4 = (~ (redist13_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out_135_fifo_stall_out) & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid) | SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg4;
    // Consuming
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_StallValid = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_backStall & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg0 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_StallValid & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed0;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg1 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_StallValid & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed1;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg2 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_StallValid & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed2;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg3 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_StallValid & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed3;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_toReg4 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_StallValid & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed4;
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or0 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed0;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or1 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed1 & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or0;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or2 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed2 & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or1;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or3 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed3 & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or2;
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireStall = ~ (SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_consumed4 & SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_or3);
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_backStall = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireStall;
    // Valid signal propagation
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V0 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid & ~ (SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg0);
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V1 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid & ~ (SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg1);
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V2 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid & ~ (SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg2);
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V3 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid & ~ (SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg3);
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_V4 = SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid & ~ (SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_fromReg4);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_wireValid = i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_valid_out;

    // SE_out_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39(STALLENABLE,484)
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_backStall = $unsigned(1'b0);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_wireValid = i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_valid_out;

    // i_llvm_fpga_push_i1_notexitcond_slavereg_comp39(BLACKBOX,53)@467
    // in in_stall_in@20000000
    // out out_data_out@468
    // out out_feedback_out_3@20000000
    // out out_feedback_valid_out_3@20000000
    // out out_stall_out@20000000
    // out out_valid_out@468
    slavereg_comp_i_llvm_fpga_push_i1_notexitcond_0 thei_llvm_fpga_push_i1_notexitcond_slavereg_comp39 (
        .in_data_in(i_exitcond_slavereg_comp29_cmp_nsign_q),
        .in_feedback_stall_in_3(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_not_exitcond_stall_out),
        .in_first_cleanup(i_first_cleanup_slavereg_comp17_sel_x_b),
        .in_stall_in(SE_out_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_backStall),
        .in_valid_in(SE_in_i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_V0),
        .out_data_out(),
        .out_feedback_out_3(i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_feedback_out_3),
        .out_feedback_valid_out_3(i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_feedback_valid_out_3),
        .out_stall_out(i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_stall_out),
        .out_valid_out(i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // SE_out_i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37(STALLENABLE,474)
    // Backward Stall generation
    assign SE_out_i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_backStall = $unsigned(1'b0);
    // Computing multiple Valid(s)
    assign SE_out_i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_wireValid = i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_valid_out;

    // i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37(BLACKBOX,48)@932
    // in in_stall_in@20000000
    // out out_data_out@933
    // out out_feedback_out_2@20000000
    // out out_feedback_valid_out_2@20000000
    // out out_stall_out@20000000
    // out out_valid_out@933
    slavereg_comp_i_llvm_fpga_push_i1_lastiniteration_0 thei_llvm_fpga_push_i1_lastiniteration_slavereg_comp37 (
        .in_data_in(SR_SE_i_next_initerations_slavereg_comp19_vt_join_D0),
        .in_feedback_stall_in_2(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_initeration_stall_out),
        .in_keep_going(SR_SE_i_next_initerations_slavereg_comp19_vt_join_D1),
        .in_stall_in(SE_out_i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_backStall),
        .in_valid_in(SE_i_next_initerations_slavereg_comp19_vt_join_V0),
        .out_data_out(),
        .out_feedback_out_2(i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_feedback_out_2),
        .out_feedback_valid_out_2(i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_feedback_valid_out_2),
        .out_stall_out(i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_stall_out),
        .out_valid_out(i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // bubble_join_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo(BITJOIN,374)
    assign bubble_join_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_q = redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_data_out;

    // bubble_select_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo(BITSELECT,375)
    assign bubble_select_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_b = $unsigned(bubble_join_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_q[0:0]);

    // i_llvm_fpga_pipeline_keep_going_slavereg_comp7(BLACKBOX,39)@466
    // in in_stall_in@20000000
    // out out_data_out@467
    // out out_exiting_stall_out@20000000
    // out out_exiting_valid_out@20000000
    // out out_initeration_stall_out@20000000
    // out out_not_exitcond_stall_out@20000000
    // out out_pipeline_valid_out@20000000
    // out out_stall_out@20000000
    // out out_valid_out@467
    slavereg_comp_i_llvm_fpga_pipeline_keep_going_0 thei_llvm_fpga_pipeline_keep_going_slavereg_comp7 (
        .in_data_in(bubble_select_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_b),
        .in_initeration_in(i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_feedback_out_2),
        .in_initeration_valid_in(i_llvm_fpga_push_i1_lastiniteration_slavereg_comp37_out_feedback_valid_out_2),
        .in_not_exitcond_in(i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_feedback_out_3),
        .in_not_exitcond_valid_in(i_llvm_fpga_push_i1_notexitcond_slavereg_comp39_out_feedback_valid_out_3),
        .in_pipeline_stall_in(in_pipeline_stall_in),
        .in_stall_in(SE_out_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_backStall),
        .in_valid_in(SE_out_redist0_slavereg_comp_B3_merge_reg_aunroll_x_out_data_out_0_tpl_465_fifo_V1),
        .out_data_out(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_data_out),
        .out_exiting_stall_out(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_exiting_stall_out),
        .out_exiting_valid_out(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_exiting_valid_out),
        .out_initeration_stall_out(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_initeration_stall_out),
        .out_not_exitcond_stall_out(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_not_exitcond_stall_out),
        .out_pipeline_valid_out(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_pipeline_valid_out),
        .out_stall_out(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_stall_out),
        .out_valid_out(i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_valid_out),
        .clock(clock),
        .resetn(resetn)
    );

    // ext_sig_sync_out(GPOUT,16)
    assign out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_valid_out = i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_exiting_valid_out;
    assign out_aclp_to_limiter_i_llvm_fpga_pipeline_keep_going_slavereg_comp7_exiting_stall_out = i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_exiting_stall_out;

    // pipeline_valid_out_sync(GPOUT,139)
    assign out_pipeline_valid_out = i_llvm_fpga_pipeline_keep_going_slavereg_comp7_out_pipeline_valid_out;

    // sync_out(GPOUT,150)@0
    assign out_stall_out = SE_stall_entry_backStall;

    // dupName_0_ext_sig_sync_out_x(GPOUT,158)
    assign out_lm1_slavereg_comp_avm_address = i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_address;
    assign out_lm1_slavereg_comp_avm_enable = i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_enable;
    assign out_lm1_slavereg_comp_avm_read = i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_read;
    assign out_lm1_slavereg_comp_avm_write = i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_write;
    assign out_lm1_slavereg_comp_avm_writedata = i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_writedata;
    assign out_lm1_slavereg_comp_avm_byteenable = i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_byteenable;
    assign out_lm1_slavereg_comp_avm_burstcount = i_llvm_fpga_mem_lm1_slavereg_comp41_out_lm1_slavereg_comp_avm_burstcount;

    // bubble_join_redist9_i_masked_slavereg_comp43_q_465_fifo(BITJOIN,395)
    assign bubble_join_redist9_i_masked_slavereg_comp43_q_465_fifo_q = redist9_i_masked_slavereg_comp43_q_465_fifo_data_out;

    // bubble_select_redist9_i_masked_slavereg_comp43_q_465_fifo(BITSELECT,396)
    assign bubble_select_redist9_i_masked_slavereg_comp43_q_465_fifo_b = $unsigned(bubble_join_redist9_i_masked_slavereg_comp43_q_465_fifo_q[0:0]);

    // dupName_0_sync_out_x(GPOUT,159)@932
    assign out_masked = bubble_select_redist9_i_masked_slavereg_comp43_q_465_fifo_b;
    assign out_valid_out = SE_out_bubble_out_i_llvm_fpga_pop_i33_fpga_indvars_iv_pop6_slavereg_comp9_1_V0;

    // dupName_1_ext_sig_sync_out_x(GPOUT,161)
    assign out_memdep_slavereg_comp_avm_address = i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_address;
    assign out_memdep_slavereg_comp_avm_enable = i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_enable;
    assign out_memdep_slavereg_comp_avm_read = i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_read;
    assign out_memdep_slavereg_comp_avm_write = i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_write;
    assign out_memdep_slavereg_comp_avm_writedata = i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_writedata;
    assign out_memdep_slavereg_comp_avm_byteenable = i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_byteenable;
    assign out_memdep_slavereg_comp_avm_burstcount = i_llvm_fpga_mem_memdep_slavereg_comp48_out_memdep_slavereg_comp_avm_burstcount;

    // dupName_2_ext_sig_sync_out_x(GPOUT,163)
    assign out_lsu_memdep_o_active = i_llvm_fpga_mem_memdep_slavereg_comp48_out_lsu_memdep_o_active;

    // dupName_3_ext_sig_sync_out_x(GPOUT,164)
    assign out_lm22_slavereg_comp_avm_address = i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_address;
    assign out_lm22_slavereg_comp_avm_enable = i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_enable;
    assign out_lm22_slavereg_comp_avm_read = i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_read;
    assign out_lm22_slavereg_comp_avm_write = i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_write;
    assign out_lm22_slavereg_comp_avm_writedata = i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_writedata;
    assign out_lm22_slavereg_comp_avm_byteenable = i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_byteenable;
    assign out_lm22_slavereg_comp_avm_burstcount = i_llvm_fpga_mem_lm22_slavereg_comp52_out_lm22_slavereg_comp_avm_burstcount;

    // dupName_4_ext_sig_sync_out_x(GPOUT,165)
    assign out_memdep_5_slavereg_comp_avm_address = i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_address;
    assign out_memdep_5_slavereg_comp_avm_enable = i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_enable;
    assign out_memdep_5_slavereg_comp_avm_read = i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_read;
    assign out_memdep_5_slavereg_comp_avm_write = i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_write;
    assign out_memdep_5_slavereg_comp_avm_writedata = i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_writedata;
    assign out_memdep_5_slavereg_comp_avm_byteenable = i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_byteenable;
    assign out_memdep_5_slavereg_comp_avm_burstcount = i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_memdep_5_slavereg_comp_avm_burstcount;

    // dupName_5_ext_sig_sync_out_x(GPOUT,166)
    assign out_lsu_memdep_5_o_active = i_llvm_fpga_mem_memdep_5_slavereg_comp57_out_lsu_memdep_5_o_active;

endmodule
