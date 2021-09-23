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

// SystemVerilog created from slavereg_comp_function_wrapper
// SystemVerilog created on Fri Apr 16 11:58:54 2021


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module slavereg_comp_function_wrapper (
    input wire [511:0] avm_lm1_slavereg_comp_readdata,
    input wire [0:0] avm_lm1_slavereg_comp_readdatavalid,
    input wire [0:0] avm_lm1_slavereg_comp_waitrequest,
    input wire [0:0] avm_lm1_slavereg_comp_writeack,
    input wire [511:0] avm_lm22_slavereg_comp_readdata,
    input wire [0:0] avm_lm22_slavereg_comp_readdatavalid,
    input wire [0:0] avm_lm22_slavereg_comp_waitrequest,
    input wire [0:0] avm_lm22_slavereg_comp_writeack,
    input wire [511:0] avm_memdep_5_slavereg_comp_readdata,
    input wire [0:0] avm_memdep_5_slavereg_comp_readdatavalid,
    input wire [0:0] avm_memdep_5_slavereg_comp_waitrequest,
    input wire [0:0] avm_memdep_5_slavereg_comp_writeack,
    input wire [511:0] avm_memdep_slavereg_comp_readdata,
    input wire [0:0] avm_memdep_slavereg_comp_readdatavalid,
    input wire [0:0] avm_memdep_slavereg_comp_waitrequest,
    input wire [0:0] avm_memdep_slavereg_comp_writeack,
    input wire [511:0] avm_unnamed_slavereg_comp8_slavereg_comp_readdata,
    input wire [0:0] avm_unnamed_slavereg_comp8_slavereg_comp_readdatavalid,
    input wire [0:0] avm_unnamed_slavereg_comp8_slavereg_comp_waitrequest,
    input wire [0:0] avm_unnamed_slavereg_comp8_slavereg_comp_writeack,
    input wire [3:0] avs_cra_address,
    input wire [7:0] avs_cra_byteenable,
    input wire [0:0] avs_cra_enable,
    input wire [0:0] avs_cra_read,
    input wire [0:0] avs_cra_write,
    input wire [63:0] avs_cra_writedata,
    input wire [255:0] avst_iord_bl_call_slavereg_comp_data,
    input wire [0:0] avst_iord_bl_call_slavereg_comp_valid,
    input wire [0:0] avst_iowr_nb_return_slavereg_comp_almostfull,
    input wire [0:0] stall_in,
    input wire [0:0] start,
    input wire [0:0] valid_in,
    output wire [31:0] avm_lm1_slavereg_comp_address,
    output wire [4:0] avm_lm1_slavereg_comp_burstcount,
    output wire [63:0] avm_lm1_slavereg_comp_byteenable,
    output wire [0:0] avm_lm1_slavereg_comp_enable,
    output wire [0:0] avm_lm1_slavereg_comp_read,
    output wire [0:0] avm_lm1_slavereg_comp_write,
    output wire [511:0] avm_lm1_slavereg_comp_writedata,
    output wire [31:0] avm_lm22_slavereg_comp_address,
    output wire [4:0] avm_lm22_slavereg_comp_burstcount,
    output wire [63:0] avm_lm22_slavereg_comp_byteenable,
    output wire [0:0] avm_lm22_slavereg_comp_enable,
    output wire [0:0] avm_lm22_slavereg_comp_read,
    output wire [0:0] avm_lm22_slavereg_comp_write,
    output wire [511:0] avm_lm22_slavereg_comp_writedata,
    output wire [31:0] avm_memdep_5_slavereg_comp_address,
    output wire [4:0] avm_memdep_5_slavereg_comp_burstcount,
    output wire [63:0] avm_memdep_5_slavereg_comp_byteenable,
    output wire [0:0] avm_memdep_5_slavereg_comp_enable,
    output wire [0:0] avm_memdep_5_slavereg_comp_read,
    output wire [0:0] avm_memdep_5_slavereg_comp_write,
    output wire [511:0] avm_memdep_5_slavereg_comp_writedata,
    output wire [31:0] avm_memdep_slavereg_comp_address,
    output wire [4:0] avm_memdep_slavereg_comp_burstcount,
    output wire [63:0] avm_memdep_slavereg_comp_byteenable,
    output wire [0:0] avm_memdep_slavereg_comp_enable,
    output wire [0:0] avm_memdep_slavereg_comp_read,
    output wire [0:0] avm_memdep_slavereg_comp_write,
    output wire [511:0] avm_memdep_slavereg_comp_writedata,
    output wire [31:0] avm_unnamed_slavereg_comp8_slavereg_comp_address,
    output wire [4:0] avm_unnamed_slavereg_comp8_slavereg_comp_burstcount,
    output wire [63:0] avm_unnamed_slavereg_comp8_slavereg_comp_byteenable,
    output wire [0:0] avm_unnamed_slavereg_comp8_slavereg_comp_enable,
    output wire [0:0] avm_unnamed_slavereg_comp8_slavereg_comp_read,
    output wire [0:0] avm_unnamed_slavereg_comp8_slavereg_comp_write,
    output wire [511:0] avm_unnamed_slavereg_comp8_slavereg_comp_writedata,
    output wire [63:0] avs_cra_readdata,
    output wire [0:0] avs_cra_readdatavalid,
    output wire [0:0] avst_iord_bl_call_slavereg_comp_almost_full,
    output wire [0:0] avst_iord_bl_call_slavereg_comp_ready,
    output wire [127:0] avst_iowr_nb_return_slavereg_comp_data,
    output wire [0:0] avst_iowr_nb_return_slavereg_comp_valid,
    output wire [0:0] done_irq,
    input wire clock,
    input wire resetn
    );

    wire [0:0] GND_q;
    wire [0:0] VCC_q;
    reg [63:0] avs_cra_readdata_r_NO_SHIFT_REG_q;
    wire [3:0] avs_readdata_mux_s;
    reg [63:0] avs_readdata_mux_q;
    wire [0:0] avs_start_q;
    wire [63:0] bit_enable_q;
    wire [0:0] bitenable_lsb_b;
    wire [0:0] busy_and_q;
    wire [63:0] busy_join_q;
    wire [0:0] busy_or_q;
    wire [63:0] call_const_q;
    wire [0:0] component_not_ready_q;
    wire [62:0] const_status_pad_q;
    wire [0:0] data_and_enable_q;
    wire [3:0] done_address_q;
    wire [0:0] done_and_q;
    wire [63:0] done_join_q;
    wire [0:0] done_or_q;
    reg [0:0] done_r_NO_SHIFT_REG_q;
    wire [0:0] hold_done_q;
    wire [255:0] implicit_input_q;
    wire [63:0] instmask_join_q;
    reg [0:0] interrupt_mask_r_NO_SHIFT_REG_q;
    reg [0:0] interrupt_r_NO_SHIFT_REG_q;
    reg [63:0] mm_slave_address_10_data_NO_SHIFT_REG_q;
    reg [63:0] mm_slave_address_6_data_NO_SHIFT_REG_q;
    reg [63:0] mm_slave_address_7_data_NO_SHIFT_REG_q;
    reg [63:0] mm_slave_address_8_data_NO_SHIFT_REG_q;
    reg [63:0] mm_slave_address_9_data_NO_SHIFT_REG_q;
    wire [0:0] next_done_q;
    wire [0:0] next_reg_q;
    wire [0:0] next_start_q;
    wire [0:0] not_bitenable_q;
    wire [0:0] not_reset_done_q;
    wire [0:0] not_start_q;
    wire [0:0] pos_reset_q;
    wire [3:0] reg_address_q;
    wire [0:0] reg_and_not_enable_q;
    wire [0:0] reset_done_q;
    wire [0:0] reset_wire_inst_o_resetn;
    wire reset_wire_inst_o_resetn_bitsignaltemp;
    wire [63:0] return_bits_b;
    reg [127:0] return_data_r_NO_SHIFT_REG_q;
    wire [0:0] select_0_b;
    wire [0:0] select_1_b;
    wire [0:0] select_2_b;
    wire [0:0] select_3_b;
    wire [0:0] select_4_b;
    wire [0:0] select_5_b;
    wire [0:0] select_6_b;
    wire [0:0] select_7_b;
    wire [0:0] set_start_b;
    wire [63:0] slave_arg_register_join_q;
    wire [0:0] slavereg_comp_function_out_iord_bl_call_slavereg_comp_o_fifoalmost_full;
    wire [0:0] slavereg_comp_function_out_iord_bl_call_slavereg_comp_o_fifoready;
    wire [127:0] slavereg_comp_function_out_iowr_nb_return_slavereg_comp_o_fifodata;
    wire [0:0] slavereg_comp_function_out_iowr_nb_return_slavereg_comp_o_fifovalid;
    wire [31:0] slavereg_comp_function_out_lm1_slavereg_comp_avm_address;
    wire [4:0] slavereg_comp_function_out_lm1_slavereg_comp_avm_burstcount;
    wire [63:0] slavereg_comp_function_out_lm1_slavereg_comp_avm_byteenable;
    wire [0:0] slavereg_comp_function_out_lm1_slavereg_comp_avm_enable;
    wire [0:0] slavereg_comp_function_out_lm1_slavereg_comp_avm_read;
    wire [0:0] slavereg_comp_function_out_lm1_slavereg_comp_avm_write;
    wire [511:0] slavereg_comp_function_out_lm1_slavereg_comp_avm_writedata;
    wire [31:0] slavereg_comp_function_out_lm22_slavereg_comp_avm_address;
    wire [4:0] slavereg_comp_function_out_lm22_slavereg_comp_avm_burstcount;
    wire [63:0] slavereg_comp_function_out_lm22_slavereg_comp_avm_byteenable;
    wire [0:0] slavereg_comp_function_out_lm22_slavereg_comp_avm_enable;
    wire [0:0] slavereg_comp_function_out_lm22_slavereg_comp_avm_read;
    wire [0:0] slavereg_comp_function_out_lm22_slavereg_comp_avm_write;
    wire [511:0] slavereg_comp_function_out_lm22_slavereg_comp_avm_writedata;
    wire [31:0] slavereg_comp_function_out_memdep_5_slavereg_comp_avm_address;
    wire [4:0] slavereg_comp_function_out_memdep_5_slavereg_comp_avm_burstcount;
    wire [63:0] slavereg_comp_function_out_memdep_5_slavereg_comp_avm_byteenable;
    wire [0:0] slavereg_comp_function_out_memdep_5_slavereg_comp_avm_enable;
    wire [0:0] slavereg_comp_function_out_memdep_5_slavereg_comp_avm_read;
    wire [0:0] slavereg_comp_function_out_memdep_5_slavereg_comp_avm_write;
    wire [511:0] slavereg_comp_function_out_memdep_5_slavereg_comp_avm_writedata;
    wire [31:0] slavereg_comp_function_out_memdep_slavereg_comp_avm_address;
    wire [4:0] slavereg_comp_function_out_memdep_slavereg_comp_avm_burstcount;
    wire [63:0] slavereg_comp_function_out_memdep_slavereg_comp_avm_byteenable;
    wire [0:0] slavereg_comp_function_out_memdep_slavereg_comp_avm_enable;
    wire [0:0] slavereg_comp_function_out_memdep_slavereg_comp_avm_read;
    wire [0:0] slavereg_comp_function_out_memdep_slavereg_comp_avm_write;
    wire [511:0] slavereg_comp_function_out_memdep_slavereg_comp_avm_writedata;
    wire [31:0] slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_address;
    wire [4:0] slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount;
    wire [63:0] slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable;
    wire [0:0] slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_enable;
    wire [0:0] slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_read;
    wire [0:0] slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_write;
    wire [511:0] slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata;
    wire [3:0] start_address_q;
    reg [0:0] start_r_NO_SHIFT_REG_q;
    wire [0:0] write_done_q;
    wire [0:0] write_reg_q;
    wire [0:0] write_start_reg_q;
    wire [0:0] write_to_address_q;
    wire [0:0] write_to_done_q;
    wire [0:0] write_to_start_address_q;
    wire [61:0] dupName_0_const_status_pad_x_q;
    wire [63:0] dupName_0_data_and_enable_x_q;
    wire [63:0] dupName_0_next_reg_x_q;
    wire [63:0] dupName_0_not_bitenable_x_q;
    wire [3:0] dupName_0_reg_address_x_q;
    wire [63:0] dupName_0_reg_and_not_enable_x_q;
    wire [63:0] dupName_0_return_bits_x_b;
    wire [63:0] dupName_0_slave_arg_register_join_x_q;
    wire [0:0] dupName_0_write_reg_x_q;
    wire [0:0] dupName_0_write_to_address_x_q;
    wire [63:0] dupName_1_next_reg_x_q;
    wire [3:0] dupName_1_reg_address_x_q;
    wire [63:0] dupName_1_reg_and_not_enable_x_q;
    wire [63:0] dupName_1_slave_arg_register_join_x_q;
    wire [0:0] dupName_1_write_reg_x_q;
    wire [0:0] dupName_1_write_to_address_x_q;
    wire [31:0] dupName_2_arg_bits_x_b;
    wire [63:0] dupName_2_next_reg_x_q;
    wire [3:0] dupName_2_reg_address_x_q;
    wire [63:0] dupName_2_reg_and_not_enable_x_q;
    wire [31:0] dupName_2_slave_arg_register_join_x_q;
    wire [0:0] dupName_2_write_reg_x_q;
    wire [0:0] dupName_2_write_to_address_x_q;
    wire [31:0] dupName_3_arg_bits_x_b;
    wire [63:0] dupName_3_next_reg_x_q;
    wire [3:0] dupName_3_reg_address_x_q;
    wire [63:0] dupName_3_reg_and_not_enable_x_q;
    wire [31:0] dupName_3_slave_arg_register_join_x_q;
    wire [0:0] dupName_3_write_reg_x_q;
    wire [0:0] dupName_3_write_to_address_x_q;
    wire [63:0] dupName_4_next_reg_x_q;
    wire [3:0] dupName_4_reg_address_x_q;
    wire [63:0] dupName_4_reg_and_not_enable_x_q;
    wire [0:0] dupName_4_write_reg_x_q;
    wire [0:0] dupName_4_write_to_address_x_q;


    // VCC(CONSTANT,1)
    assign VCC_q = $unsigned(1'b1);

    // GND(CONSTANT,0)
    assign GND_q = $unsigned(1'b0);

    // select_7(BITSELECT,135)
    assign select_7_b = avs_cra_byteenable[7:7];

    // select_6(BITSELECT,134)
    assign select_6_b = avs_cra_byteenable[6:6];

    // select_5(BITSELECT,133)
    assign select_5_b = avs_cra_byteenable[5:5];

    // select_4(BITSELECT,132)
    assign select_4_b = avs_cra_byteenable[4:4];

    // select_3(BITSELECT,131)
    assign select_3_b = avs_cra_byteenable[3:3];

    // select_2(BITSELECT,130)
    assign select_2_b = avs_cra_byteenable[2:2];

    // select_1(BITSELECT,129)
    assign select_1_b = avs_cra_byteenable[1:1];

    // select_0(BITSELECT,128)
    assign select_0_b = avs_cra_byteenable[0:0];

    // bit_enable(BITJOIN,6)
    assign bit_enable_q = {select_7_b, select_7_b, select_7_b, select_7_b, select_7_b, select_7_b, select_7_b, select_7_b, select_6_b, select_6_b, select_6_b, select_6_b, select_6_b, select_6_b, select_6_b, select_6_b, select_5_b, select_5_b, select_5_b, select_5_b, select_5_b, select_5_b, select_5_b, select_5_b, select_4_b, select_4_b, select_4_b, select_4_b, select_4_b, select_4_b, select_4_b, select_4_b, select_3_b, select_3_b, select_3_b, select_3_b, select_3_b, select_3_b, select_3_b, select_3_b, select_2_b, select_2_b, select_2_b, select_2_b, select_2_b, select_2_b, select_2_b, select_2_b, select_1_b, select_1_b, select_1_b, select_1_b, select_1_b, select_1_b, select_1_b, select_1_b, select_0_b, select_0_b, select_0_b, select_0_b, select_0_b, select_0_b, select_0_b, select_0_b};

    // bitenable_lsb(BITSELECT,7)
    assign bitenable_lsb_b = bit_enable_q[0:0];

    // set_start(BITSELECT,136)
    assign set_start_b = avs_cra_writedata[0:0];

    // data_and_enable(LOGICAL,17)
    assign data_and_enable_q = set_start_b & bitenable_lsb_b;

    // start_address(CONSTANT,139)
    assign start_address_q = $unsigned(4'b0001);

    // write_to_start_address(LOGICAL,148)
    assign write_to_start_address_q = $unsigned(avs_cra_address == start_address_q ? 1'b1 : 1'b0);

    // write_start_reg(LOGICAL,145)
    assign write_start_reg_q = avs_cra_write & write_to_start_address_q;

    // avs_start(LOGICAL,5)
    assign avs_start_q = write_start_reg_q & data_and_enable_q;

    // component_not_ready(LOGICAL,12)
    assign component_not_ready_q = ~ (slavereg_comp_function_out_iord_bl_call_slavereg_comp_o_fifoready);

    // busy_and(LOGICAL,8)
    assign busy_and_q = component_not_ready_q & start_r_NO_SHIFT_REG_q;

    // next_start(LOGICAL,72)
    assign next_start_q = busy_and_q | avs_start_q;

    // start_r_NO_SHIFT_REG(REG,140)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            start_r_NO_SHIFT_REG_q <= $unsigned(1'b0);
        end
        else
        begin
            start_r_NO_SHIFT_REG_q <= next_start_q;
        end
    end

    // dupName_4_reg_address_x(CONSTANT,193)
    assign dupName_4_reg_address_x_q = $unsigned(4'b1010);

    // dupName_4_write_to_address_x(LOGICAL,196)
    assign dupName_4_write_to_address_x_q = $unsigned(avs_cra_address == dupName_4_reg_address_x_q ? 1'b1 : 1'b0);

    // dupName_4_write_reg_x(LOGICAL,195)
    assign dupName_4_write_reg_x_q = avs_cra_write & dupName_4_write_to_address_x_q;

    // dupName_0_data_and_enable_x(LOGICAL,153)
    assign dupName_0_data_and_enable_x_q = avs_cra_writedata & bit_enable_q;

    // dupName_0_not_bitenable_x(LOGICAL,155)
    assign dupName_0_not_bitenable_x_q = ~ (bit_enable_q);

    // dupName_4_reg_and_not_enable_x(LOGICAL,194)
    assign dupName_4_reg_and_not_enable_x_q = mm_slave_address_10_data_NO_SHIFT_REG_q & dupName_0_not_bitenable_x_q;

    // dupName_4_next_reg_x(LOGICAL,191)
    assign dupName_4_next_reg_x_q = dupName_4_reg_and_not_enable_x_q | dupName_0_data_and_enable_x_q;

    // mm_slave_address_10_data_NO_SHIFT_REG(REG,65)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            mm_slave_address_10_data_NO_SHIFT_REG_q <= $unsigned(64'b0000000000000000000000000000000000000000000000000000000000000000);
        end
        else if (dupName_4_write_reg_x_q == 1'b1)
        begin
            mm_slave_address_10_data_NO_SHIFT_REG_q <= dupName_4_next_reg_x_q;
        end
    end

    // dupName_3_arg_bits_x(BITSELECT,181)
    assign dupName_3_arg_bits_x_b = mm_slave_address_10_data_NO_SHIFT_REG_q[31:0];

    // dupName_3_slave_arg_register_join_x(BITJOIN,187)
    assign dupName_3_slave_arg_register_join_x_q = dupName_3_arg_bits_x_b;

    // dupName_3_reg_address_x(CONSTANT,185)
    assign dupName_3_reg_address_x_q = $unsigned(4'b1001);

    // dupName_3_write_to_address_x(LOGICAL,189)
    assign dupName_3_write_to_address_x_q = $unsigned(avs_cra_address == dupName_3_reg_address_x_q ? 1'b1 : 1'b0);

    // dupName_3_write_reg_x(LOGICAL,188)
    assign dupName_3_write_reg_x_q = avs_cra_write & dupName_3_write_to_address_x_q;

    // dupName_3_reg_and_not_enable_x(LOGICAL,186)
    assign dupName_3_reg_and_not_enable_x_q = mm_slave_address_9_data_NO_SHIFT_REG_q & dupName_0_not_bitenable_x_q;

    // dupName_3_next_reg_x(LOGICAL,183)
    assign dupName_3_next_reg_x_q = dupName_3_reg_and_not_enable_x_q | dupName_0_data_and_enable_x_q;

    // mm_slave_address_9_data_NO_SHIFT_REG(REG,69)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            mm_slave_address_9_data_NO_SHIFT_REG_q <= $unsigned(64'b0000000000000000000000000000000000000000000000000000000000000000);
        end
        else if (dupName_3_write_reg_x_q == 1'b1)
        begin
            mm_slave_address_9_data_NO_SHIFT_REG_q <= dupName_3_next_reg_x_q;
        end
    end

    // dupName_2_arg_bits_x(BITSELECT,172)
    assign dupName_2_arg_bits_x_b = mm_slave_address_9_data_NO_SHIFT_REG_q[31:0];

    // dupName_2_slave_arg_register_join_x(BITJOIN,178)
    assign dupName_2_slave_arg_register_join_x_q = dupName_2_arg_bits_x_b;

    // dupName_2_reg_address_x(CONSTANT,176)
    assign dupName_2_reg_address_x_q = $unsigned(4'b1000);

    // dupName_2_write_to_address_x(LOGICAL,180)
    assign dupName_2_write_to_address_x_q = $unsigned(avs_cra_address == dupName_2_reg_address_x_q ? 1'b1 : 1'b0);

    // dupName_2_write_reg_x(LOGICAL,179)
    assign dupName_2_write_reg_x_q = avs_cra_write & dupName_2_write_to_address_x_q;

    // dupName_2_reg_and_not_enable_x(LOGICAL,177)
    assign dupName_2_reg_and_not_enable_x_q = mm_slave_address_8_data_NO_SHIFT_REG_q & dupName_0_not_bitenable_x_q;

    // dupName_2_next_reg_x(LOGICAL,174)
    assign dupName_2_next_reg_x_q = dupName_2_reg_and_not_enable_x_q | dupName_0_data_and_enable_x_q;

    // mm_slave_address_8_data_NO_SHIFT_REG(REG,68)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            mm_slave_address_8_data_NO_SHIFT_REG_q <= $unsigned(64'b0000000000000000000000000000000000000000000000000000000000000000);
        end
        else if (dupName_2_write_reg_x_q == 1'b1)
        begin
            mm_slave_address_8_data_NO_SHIFT_REG_q <= dupName_2_next_reg_x_q;
        end
    end

    // dupName_1_slave_arg_register_join_x(BITJOIN,169)
    assign dupName_1_slave_arg_register_join_x_q = mm_slave_address_8_data_NO_SHIFT_REG_q;

    // dupName_1_reg_address_x(CONSTANT,167)
    assign dupName_1_reg_address_x_q = $unsigned(4'b0111);

    // dupName_1_write_to_address_x(LOGICAL,171)
    assign dupName_1_write_to_address_x_q = $unsigned(avs_cra_address == dupName_1_reg_address_x_q ? 1'b1 : 1'b0);

    // dupName_1_write_reg_x(LOGICAL,170)
    assign dupName_1_write_reg_x_q = avs_cra_write & dupName_1_write_to_address_x_q;

    // dupName_1_reg_and_not_enable_x(LOGICAL,168)
    assign dupName_1_reg_and_not_enable_x_q = mm_slave_address_7_data_NO_SHIFT_REG_q & dupName_0_not_bitenable_x_q;

    // dupName_1_next_reg_x(LOGICAL,165)
    assign dupName_1_next_reg_x_q = dupName_1_reg_and_not_enable_x_q | dupName_0_data_and_enable_x_q;

    // mm_slave_address_7_data_NO_SHIFT_REG(REG,67)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            mm_slave_address_7_data_NO_SHIFT_REG_q <= $unsigned(64'b0000000000000000000000000000000000000000000000000000000000000000);
        end
        else if (dupName_1_write_reg_x_q == 1'b1)
        begin
            mm_slave_address_7_data_NO_SHIFT_REG_q <= dupName_1_next_reg_x_q;
        end
    end

    // dupName_0_slave_arg_register_join_x(BITJOIN,159)
    assign dupName_0_slave_arg_register_join_x_q = mm_slave_address_7_data_NO_SHIFT_REG_q;

    // dupName_0_reg_address_x(CONSTANT,156)
    assign dupName_0_reg_address_x_q = $unsigned(4'b0110);

    // dupName_0_write_to_address_x(LOGICAL,161)
    assign dupName_0_write_to_address_x_q = $unsigned(avs_cra_address == dupName_0_reg_address_x_q ? 1'b1 : 1'b0);

    // dupName_0_write_reg_x(LOGICAL,160)
    assign dupName_0_write_reg_x_q = avs_cra_write & dupName_0_write_to_address_x_q;

    // dupName_0_reg_and_not_enable_x(LOGICAL,157)
    assign dupName_0_reg_and_not_enable_x_q = mm_slave_address_6_data_NO_SHIFT_REG_q & dupName_0_not_bitenable_x_q;

    // dupName_0_next_reg_x(LOGICAL,154)
    assign dupName_0_next_reg_x_q = dupName_0_reg_and_not_enable_x_q | dupName_0_data_and_enable_x_q;

    // mm_slave_address_6_data_NO_SHIFT_REG(REG,66)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            mm_slave_address_6_data_NO_SHIFT_REG_q <= $unsigned(64'b0000000000000000000000000000000000000000000000000000000000000000);
        end
        else if (dupName_0_write_reg_x_q == 1'b1)
        begin
            mm_slave_address_6_data_NO_SHIFT_REG_q <= dupName_0_next_reg_x_q;
        end
    end

    // slave_arg_register_join(BITJOIN,137)
    assign slave_arg_register_join_q = mm_slave_address_6_data_NO_SHIFT_REG_q;

    // implicit_input(BITJOIN,26)
    assign implicit_input_q = {dupName_3_slave_arg_register_join_x_q, dupName_2_slave_arg_register_join_x_q, dupName_1_slave_arg_register_join_x_q, dupName_0_slave_arg_register_join_x_q, slave_arg_register_join_q};

    // call_const(CONSTANT,11)
    assign call_const_q = $unsigned(64'b0000000000000000000000000000000000000000000000000000000000000000);

    // slavereg_comp_function(BLACKBOX,138)
    slavereg_comp_function theslavereg_comp_function (
        .in_arg_call(call_const_q),
        .in_arg_memdata1(call_const_q),
        .in_arg_memdata2(call_const_q),
        .in_arg_memdata3(call_const_q),
        .in_arg_return(call_const_q),
        .in_iord_bl_call_slavereg_comp_i_fifodata(implicit_input_q),
        .in_iord_bl_call_slavereg_comp_i_fifovalid(start_r_NO_SHIFT_REG_q),
        .in_lm1_slavereg_comp_avm_readdata(avm_lm1_slavereg_comp_readdata),
        .in_lm1_slavereg_comp_avm_readdatavalid(avm_lm1_slavereg_comp_readdatavalid),
        .in_lm1_slavereg_comp_avm_waitrequest(avm_lm1_slavereg_comp_waitrequest),
        .in_lm1_slavereg_comp_avm_writeack(avm_lm1_slavereg_comp_writeack),
        .in_lm22_slavereg_comp_avm_readdata(avm_lm22_slavereg_comp_readdata),
        .in_lm22_slavereg_comp_avm_readdatavalid(avm_lm22_slavereg_comp_readdatavalid),
        .in_lm22_slavereg_comp_avm_waitrequest(avm_lm22_slavereg_comp_waitrequest),
        .in_lm22_slavereg_comp_avm_writeack(avm_lm22_slavereg_comp_writeack),
        .in_memdep_5_slavereg_comp_avm_readdata(avm_memdep_5_slavereg_comp_readdata),
        .in_memdep_5_slavereg_comp_avm_readdatavalid(avm_memdep_5_slavereg_comp_readdatavalid),
        .in_memdep_5_slavereg_comp_avm_waitrequest(avm_memdep_5_slavereg_comp_waitrequest),
        .in_memdep_5_slavereg_comp_avm_writeack(avm_memdep_5_slavereg_comp_writeack),
        .in_memdep_slavereg_comp_avm_readdata(avm_memdep_slavereg_comp_readdata),
        .in_memdep_slavereg_comp_avm_readdatavalid(avm_memdep_slavereg_comp_readdatavalid),
        .in_memdep_slavereg_comp_avm_waitrequest(avm_memdep_slavereg_comp_waitrequest),
        .in_memdep_slavereg_comp_avm_writeack(avm_memdep_slavereg_comp_writeack),
        .in_stall_in(GND_q),
        .in_start(GND_q),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_readdata(avm_unnamed_slavereg_comp8_slavereg_comp_readdata),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_readdatavalid(avm_unnamed_slavereg_comp8_slavereg_comp_readdatavalid),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_waitrequest(avm_unnamed_slavereg_comp8_slavereg_comp_waitrequest),
        .in_unnamed_slavereg_comp8_slavereg_comp_avm_writeack(avm_unnamed_slavereg_comp8_slavereg_comp_writeack),
        .in_valid_in(VCC_q),
        .out_iord_bl_call_slavereg_comp_o_fifoalmost_full(slavereg_comp_function_out_iord_bl_call_slavereg_comp_o_fifoalmost_full),
        .out_iord_bl_call_slavereg_comp_o_fifoready(slavereg_comp_function_out_iord_bl_call_slavereg_comp_o_fifoready),
        .out_iowr_nb_return_slavereg_comp_o_fifodata(slavereg_comp_function_out_iowr_nb_return_slavereg_comp_o_fifodata),
        .out_iowr_nb_return_slavereg_comp_o_fifovalid(slavereg_comp_function_out_iowr_nb_return_slavereg_comp_o_fifovalid),
        .out_lm1_slavereg_comp_avm_address(slavereg_comp_function_out_lm1_slavereg_comp_avm_address),
        .out_lm1_slavereg_comp_avm_burstcount(slavereg_comp_function_out_lm1_slavereg_comp_avm_burstcount),
        .out_lm1_slavereg_comp_avm_byteenable(slavereg_comp_function_out_lm1_slavereg_comp_avm_byteenable),
        .out_lm1_slavereg_comp_avm_enable(slavereg_comp_function_out_lm1_slavereg_comp_avm_enable),
        .out_lm1_slavereg_comp_avm_read(slavereg_comp_function_out_lm1_slavereg_comp_avm_read),
        .out_lm1_slavereg_comp_avm_write(slavereg_comp_function_out_lm1_slavereg_comp_avm_write),
        .out_lm1_slavereg_comp_avm_writedata(slavereg_comp_function_out_lm1_slavereg_comp_avm_writedata),
        .out_lm22_slavereg_comp_avm_address(slavereg_comp_function_out_lm22_slavereg_comp_avm_address),
        .out_lm22_slavereg_comp_avm_burstcount(slavereg_comp_function_out_lm22_slavereg_comp_avm_burstcount),
        .out_lm22_slavereg_comp_avm_byteenable(slavereg_comp_function_out_lm22_slavereg_comp_avm_byteenable),
        .out_lm22_slavereg_comp_avm_enable(slavereg_comp_function_out_lm22_slavereg_comp_avm_enable),
        .out_lm22_slavereg_comp_avm_read(slavereg_comp_function_out_lm22_slavereg_comp_avm_read),
        .out_lm22_slavereg_comp_avm_write(slavereg_comp_function_out_lm22_slavereg_comp_avm_write),
        .out_lm22_slavereg_comp_avm_writedata(slavereg_comp_function_out_lm22_slavereg_comp_avm_writedata),
        .out_memdep_5_slavereg_comp_avm_address(slavereg_comp_function_out_memdep_5_slavereg_comp_avm_address),
        .out_memdep_5_slavereg_comp_avm_burstcount(slavereg_comp_function_out_memdep_5_slavereg_comp_avm_burstcount),
        .out_memdep_5_slavereg_comp_avm_byteenable(slavereg_comp_function_out_memdep_5_slavereg_comp_avm_byteenable),
        .out_memdep_5_slavereg_comp_avm_enable(slavereg_comp_function_out_memdep_5_slavereg_comp_avm_enable),
        .out_memdep_5_slavereg_comp_avm_read(slavereg_comp_function_out_memdep_5_slavereg_comp_avm_read),
        .out_memdep_5_slavereg_comp_avm_write(slavereg_comp_function_out_memdep_5_slavereg_comp_avm_write),
        .out_memdep_5_slavereg_comp_avm_writedata(slavereg_comp_function_out_memdep_5_slavereg_comp_avm_writedata),
        .out_memdep_slavereg_comp_avm_address(slavereg_comp_function_out_memdep_slavereg_comp_avm_address),
        .out_memdep_slavereg_comp_avm_burstcount(slavereg_comp_function_out_memdep_slavereg_comp_avm_burstcount),
        .out_memdep_slavereg_comp_avm_byteenable(slavereg_comp_function_out_memdep_slavereg_comp_avm_byteenable),
        .out_memdep_slavereg_comp_avm_enable(slavereg_comp_function_out_memdep_slavereg_comp_avm_enable),
        .out_memdep_slavereg_comp_avm_read(slavereg_comp_function_out_memdep_slavereg_comp_avm_read),
        .out_memdep_slavereg_comp_avm_write(slavereg_comp_function_out_memdep_slavereg_comp_avm_write),
        .out_memdep_slavereg_comp_avm_writedata(slavereg_comp_function_out_memdep_slavereg_comp_avm_writedata),
        .out_o_active_memdep(),
        .out_o_active_memdep_5(),
        .out_stall_out(),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_address(slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_address),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount(slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable(slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_enable(slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_enable),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_read(slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_read),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_write(slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_write),
        .out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata(slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata),
        .out_valid_out(),
        .clock(clock),
        .resetn(resetn)
    );

    // avm_lm1_slavereg_comp_address(GPOUT,77)
    assign avm_lm1_slavereg_comp_address = slavereg_comp_function_out_lm1_slavereg_comp_avm_address;

    // avm_lm1_slavereg_comp_burstcount(GPOUT,78)
    assign avm_lm1_slavereg_comp_burstcount = slavereg_comp_function_out_lm1_slavereg_comp_avm_burstcount;

    // avm_lm1_slavereg_comp_byteenable(GPOUT,79)
    assign avm_lm1_slavereg_comp_byteenable = slavereg_comp_function_out_lm1_slavereg_comp_avm_byteenable;

    // avm_lm1_slavereg_comp_enable(GPOUT,80)
    assign avm_lm1_slavereg_comp_enable = slavereg_comp_function_out_lm1_slavereg_comp_avm_enable;

    // avm_lm1_slavereg_comp_read(GPOUT,81)
    assign avm_lm1_slavereg_comp_read = slavereg_comp_function_out_lm1_slavereg_comp_avm_read;

    // avm_lm1_slavereg_comp_write(GPOUT,82)
    assign avm_lm1_slavereg_comp_write = slavereg_comp_function_out_lm1_slavereg_comp_avm_write;

    // avm_lm1_slavereg_comp_writedata(GPOUT,83)
    assign avm_lm1_slavereg_comp_writedata = slavereg_comp_function_out_lm1_slavereg_comp_avm_writedata;

    // avm_lm22_slavereg_comp_address(GPOUT,84)
    assign avm_lm22_slavereg_comp_address = slavereg_comp_function_out_lm22_slavereg_comp_avm_address;

    // avm_lm22_slavereg_comp_burstcount(GPOUT,85)
    assign avm_lm22_slavereg_comp_burstcount = slavereg_comp_function_out_lm22_slavereg_comp_avm_burstcount;

    // avm_lm22_slavereg_comp_byteenable(GPOUT,86)
    assign avm_lm22_slavereg_comp_byteenable = slavereg_comp_function_out_lm22_slavereg_comp_avm_byteenable;

    // avm_lm22_slavereg_comp_enable(GPOUT,87)
    assign avm_lm22_slavereg_comp_enable = slavereg_comp_function_out_lm22_slavereg_comp_avm_enable;

    // avm_lm22_slavereg_comp_read(GPOUT,88)
    assign avm_lm22_slavereg_comp_read = slavereg_comp_function_out_lm22_slavereg_comp_avm_read;

    // avm_lm22_slavereg_comp_write(GPOUT,89)
    assign avm_lm22_slavereg_comp_write = slavereg_comp_function_out_lm22_slavereg_comp_avm_write;

    // avm_lm22_slavereg_comp_writedata(GPOUT,90)
    assign avm_lm22_slavereg_comp_writedata = slavereg_comp_function_out_lm22_slavereg_comp_avm_writedata;

    // avm_memdep_5_slavereg_comp_address(GPOUT,91)
    assign avm_memdep_5_slavereg_comp_address = slavereg_comp_function_out_memdep_5_slavereg_comp_avm_address;

    // avm_memdep_5_slavereg_comp_burstcount(GPOUT,92)
    assign avm_memdep_5_slavereg_comp_burstcount = slavereg_comp_function_out_memdep_5_slavereg_comp_avm_burstcount;

    // avm_memdep_5_slavereg_comp_byteenable(GPOUT,93)
    assign avm_memdep_5_slavereg_comp_byteenable = slavereg_comp_function_out_memdep_5_slavereg_comp_avm_byteenable;

    // avm_memdep_5_slavereg_comp_enable(GPOUT,94)
    assign avm_memdep_5_slavereg_comp_enable = slavereg_comp_function_out_memdep_5_slavereg_comp_avm_enable;

    // avm_memdep_5_slavereg_comp_read(GPOUT,95)
    assign avm_memdep_5_slavereg_comp_read = slavereg_comp_function_out_memdep_5_slavereg_comp_avm_read;

    // avm_memdep_5_slavereg_comp_write(GPOUT,96)
    assign avm_memdep_5_slavereg_comp_write = slavereg_comp_function_out_memdep_5_slavereg_comp_avm_write;

    // avm_memdep_5_slavereg_comp_writedata(GPOUT,97)
    assign avm_memdep_5_slavereg_comp_writedata = slavereg_comp_function_out_memdep_5_slavereg_comp_avm_writedata;

    // avm_memdep_slavereg_comp_address(GPOUT,98)
    assign avm_memdep_slavereg_comp_address = slavereg_comp_function_out_memdep_slavereg_comp_avm_address;

    // avm_memdep_slavereg_comp_burstcount(GPOUT,99)
    assign avm_memdep_slavereg_comp_burstcount = slavereg_comp_function_out_memdep_slavereg_comp_avm_burstcount;

    // avm_memdep_slavereg_comp_byteenable(GPOUT,100)
    assign avm_memdep_slavereg_comp_byteenable = slavereg_comp_function_out_memdep_slavereg_comp_avm_byteenable;

    // avm_memdep_slavereg_comp_enable(GPOUT,101)
    assign avm_memdep_slavereg_comp_enable = slavereg_comp_function_out_memdep_slavereg_comp_avm_enable;

    // avm_memdep_slavereg_comp_read(GPOUT,102)
    assign avm_memdep_slavereg_comp_read = slavereg_comp_function_out_memdep_slavereg_comp_avm_read;

    // avm_memdep_slavereg_comp_write(GPOUT,103)
    assign avm_memdep_slavereg_comp_write = slavereg_comp_function_out_memdep_slavereg_comp_avm_write;

    // avm_memdep_slavereg_comp_writedata(GPOUT,104)
    assign avm_memdep_slavereg_comp_writedata = slavereg_comp_function_out_memdep_slavereg_comp_avm_writedata;

    // avm_unnamed_slavereg_comp8_slavereg_comp_address(GPOUT,105)
    assign avm_unnamed_slavereg_comp8_slavereg_comp_address = slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_address;

    // avm_unnamed_slavereg_comp8_slavereg_comp_burstcount(GPOUT,106)
    assign avm_unnamed_slavereg_comp8_slavereg_comp_burstcount = slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_burstcount;

    // avm_unnamed_slavereg_comp8_slavereg_comp_byteenable(GPOUT,107)
    assign avm_unnamed_slavereg_comp8_slavereg_comp_byteenable = slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_byteenable;

    // avm_unnamed_slavereg_comp8_slavereg_comp_enable(GPOUT,108)
    assign avm_unnamed_slavereg_comp8_slavereg_comp_enable = slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_enable;

    // avm_unnamed_slavereg_comp8_slavereg_comp_read(GPOUT,109)
    assign avm_unnamed_slavereg_comp8_slavereg_comp_read = slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_read;

    // avm_unnamed_slavereg_comp8_slavereg_comp_write(GPOUT,110)
    assign avm_unnamed_slavereg_comp8_slavereg_comp_write = slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_write;

    // avm_unnamed_slavereg_comp8_slavereg_comp_writedata(GPOUT,111)
    assign avm_unnamed_slavereg_comp8_slavereg_comp_writedata = slavereg_comp_function_out_unnamed_slavereg_comp8_slavereg_comp_avm_writedata;

    // return_data_r_NO_SHIFT_REG(REG,127)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            return_data_r_NO_SHIFT_REG_q <= $unsigned(128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000);
        end
        else if (slavereg_comp_function_out_iowr_nb_return_slavereg_comp_o_fifovalid == 1'b1)
        begin
            return_data_r_NO_SHIFT_REG_q <= slavereg_comp_function_out_iowr_nb_return_slavereg_comp_o_fifodata;
        end
    end

    // dupName_0_return_bits_x(BITSELECT,158)
    assign dupName_0_return_bits_x_b = return_data_r_NO_SHIFT_REG_q[127:64];

    // return_bits(BITSELECT,125)
    assign return_bits_b = return_data_r_NO_SHIFT_REG_q[63:0];

    // dupName_0_const_status_pad_x(CONSTANT,152)
    assign dupName_0_const_status_pad_x_q = $unsigned(62'b00000000000000000000000000000000000000000000000000000000000000);

    // not_start(LOGICAL,76)
    assign not_start_q = ~ (start_r_NO_SHIFT_REG_q);

    // done_and(LOGICAL,19)
    assign done_and_q = done_r_NO_SHIFT_REG_q & not_start_q;

    // done_or(LOGICAL,21)
    assign done_or_q = slavereg_comp_function_out_iowr_nb_return_slavereg_comp_o_fifovalid | done_and_q;

    // done_r_NO_SHIFT_REG(REG,22)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            done_r_NO_SHIFT_REG_q <= $unsigned(1'b1);
        end
        else
        begin
            done_r_NO_SHIFT_REG_q <= done_or_q;
        end
    end

    // done_address(CONSTANT,18)
    assign done_address_q = $unsigned(4'b0011);

    // write_to_done(LOGICAL,147)
    assign write_to_done_q = $unsigned(avs_cra_address == done_address_q ? 1'b1 : 1'b0);

    // write_done(LOGICAL,142)
    assign write_done_q = write_to_done_q & avs_cra_write;

    // reset_done(LOGICAL,123)
    assign reset_done_q = write_done_q & data_and_enable_q;

    // not_reset_done(LOGICAL,75)
    assign not_reset_done_q = ~ (reset_done_q);

    // hold_done(LOGICAL,24)
    assign hold_done_q = not_reset_done_q & interrupt_r_NO_SHIFT_REG_q;

    // next_done(LOGICAL,70)
    assign next_done_q = hold_done_q | slavereg_comp_function_out_iowr_nb_return_slavereg_comp_o_fifovalid;

    // interrupt_r_NO_SHIFT_REG(REG,61)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            interrupt_r_NO_SHIFT_REG_q <= $unsigned(1'b0);
        end
        else
        begin
            interrupt_r_NO_SHIFT_REG_q <= next_done_q;
        end
    end

    // done_join(BITJOIN,20)
    assign done_join_q = {dupName_0_const_status_pad_x_q, done_r_NO_SHIFT_REG_q, interrupt_r_NO_SHIFT_REG_q};

    // const_status_pad(CONSTANT,16)
    assign const_status_pad_q = $unsigned(63'b000000000000000000000000000000000000000000000000000000000000000);

    // reg_address(CONSTANT,120)
    assign reg_address_q = $unsigned(4'b0010);

    // write_to_address(LOGICAL,146)
    assign write_to_address_q = $unsigned(avs_cra_address == reg_address_q ? 1'b1 : 1'b0);

    // write_reg(LOGICAL,144)
    assign write_reg_q = avs_cra_write & write_to_address_q;

    // not_bitenable(LOGICAL,73)
    assign not_bitenable_q = ~ (bitenable_lsb_b);

    // reg_and_not_enable(LOGICAL,121)
    assign reg_and_not_enable_q = interrupt_mask_r_NO_SHIFT_REG_q & not_bitenable_q;

    // next_reg(LOGICAL,71)
    assign next_reg_q = reg_and_not_enable_q | data_and_enable_q;

    // interrupt_mask_r_NO_SHIFT_REG(REG,60)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            interrupt_mask_r_NO_SHIFT_REG_q <= $unsigned(1'b0);
        end
        else if (write_reg_q == 1'b1)
        begin
            interrupt_mask_r_NO_SHIFT_REG_q <= next_reg_q;
        end
    end

    // instmask_join(BITJOIN,59)
    assign instmask_join_q = {const_status_pad_q, interrupt_mask_r_NO_SHIFT_REG_q};

    // reset_wire_inst(EXTIFACE,124)
    assign reset_wire_inst_o_resetn[0] = reset_wire_inst_o_resetn_bitsignaltemp;
    acl_reset_wire thereset_wire_inst (
        .o_resetn(reset_wire_inst_o_resetn_bitsignaltemp),
        .clock(clock),
        .resetn(resetn)
    );

    // pos_reset(LOGICAL,119)
    assign pos_reset_q = ~ (reset_wire_inst_o_resetn);

    // busy_or(LOGICAL,10)
    assign busy_or_q = pos_reset_q | busy_and_q;

    // busy_join(BITJOIN,9)
    assign busy_join_q = {const_status_pad_q, busy_or_q};

    // avs_readdata_mux(MUX,4)
    assign avs_readdata_mux_s = avs_cra_address;
    always @(avs_readdata_mux_s or busy_join_q or call_const_q or instmask_join_q or done_join_q or return_bits_b or dupName_0_return_bits_x_b or mm_slave_address_6_data_NO_SHIFT_REG_q or mm_slave_address_7_data_NO_SHIFT_REG_q or mm_slave_address_8_data_NO_SHIFT_REG_q or mm_slave_address_9_data_NO_SHIFT_REG_q or mm_slave_address_10_data_NO_SHIFT_REG_q)
    begin
        unique case (avs_readdata_mux_s)
            4'b0000 : avs_readdata_mux_q = busy_join_q;
            4'b0001 : avs_readdata_mux_q = call_const_q;
            4'b0010 : avs_readdata_mux_q = instmask_join_q;
            4'b0011 : avs_readdata_mux_q = done_join_q;
            4'b0100 : avs_readdata_mux_q = return_bits_b;
            4'b0101 : avs_readdata_mux_q = dupName_0_return_bits_x_b;
            4'b0110 : avs_readdata_mux_q = mm_slave_address_6_data_NO_SHIFT_REG_q;
            4'b0111 : avs_readdata_mux_q = mm_slave_address_7_data_NO_SHIFT_REG_q;
            4'b1000 : avs_readdata_mux_q = mm_slave_address_8_data_NO_SHIFT_REG_q;
            4'b1001 : avs_readdata_mux_q = mm_slave_address_9_data_NO_SHIFT_REG_q;
            4'b1010 : avs_readdata_mux_q = mm_slave_address_10_data_NO_SHIFT_REG_q;
            default : avs_readdata_mux_q = 64'b0;
        endcase
    end

    // avs_cra_readdata_r_NO_SHIFT_REG(REG,3)
    always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
        begin
            avs_cra_readdata_r_NO_SHIFT_REG_q <= $unsigned(64'b0000000000000000000000000000000000000000000000000000000000000000);
        end
        else
        begin
            avs_cra_readdata_r_NO_SHIFT_REG_q <= avs_readdata_mux_q;
        end
    end

    // avs_cra_readdata(GPOUT,112)
    assign avs_cra_readdata = avs_cra_readdata_r_NO_SHIFT_REG_q;

    // avs_cra_readdatavalid(GPOUT,113)
    assign avs_cra_readdatavalid = GND_q;

    // avst_iord_bl_call_slavereg_comp_almost_full(GPOUT,114)
    assign avst_iord_bl_call_slavereg_comp_almost_full = slavereg_comp_function_out_iord_bl_call_slavereg_comp_o_fifoalmost_full;

    // avst_iord_bl_call_slavereg_comp_ready(GPOUT,115)
    assign avst_iord_bl_call_slavereg_comp_ready = slavereg_comp_function_out_iord_bl_call_slavereg_comp_o_fifoready;

    // avst_iowr_nb_return_slavereg_comp_data(GPOUT,116)
    assign avst_iowr_nb_return_slavereg_comp_data = slavereg_comp_function_out_iowr_nb_return_slavereg_comp_o_fifodata;

    // avst_iowr_nb_return_slavereg_comp_valid(GPOUT,117)
    assign avst_iowr_nb_return_slavereg_comp_valid = slavereg_comp_function_out_iowr_nb_return_slavereg_comp_o_fifovalid;

    // done_irq(GPOUT,118)
    assign done_irq = interrupt_r_NO_SHIFT_REG_q;

endmodule
