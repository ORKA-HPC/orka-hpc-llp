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

// SystemVerilog created from slavereg_comp_i_sfc_logic_s_c0_in_for_bo0000er232_slavereg_comp0
// SystemVerilog created on Fri Apr 16 11:58:54 2021


(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007; -name MESSAGE_DISABLE 10958" *)
module slavereg_comp_i_sfc_logic_s_c0_in_for_bo0000er232_slavereg_comp0 (
    output wire [0:0] out_c0_exi2_0_tpl,
    output wire [0:0] out_c0_exi2_1_tpl,
    output wire [31:0] out_c0_exi2_2_tpl,
    output wire [0:0] out_o_valid,
    output wire [0:0] out_unnamed_slavereg_comp1,
    input wire [0:0] in_c0_eni1_0_tpl,
    input wire [31:0] in_c0_eni1_1_tpl,
    input wire [0:0] in_i_valid,
    input wire clock,
    input wire resetn
    );

    wire [0:0] GND_q;
    wire [0:0] VCC_q;
    wire [31:0] c_float_3_500000e_007_q;
    wire [31:0] i_conv_slavereg_comp3_out_primWireOut;
    wire [31:0] i_mul4_slavereg_comp4_out_primWireOut;
    wire [0:0] i_lm22_toi1_intcast_slavereg_comp2_sel_x_b;
    reg [0:0] redist0_sync_together10_aunroll_x_in_i_valid_9_q;
    reg [0:0] redist1_i_lm22_toi1_intcast_slavereg_comp2_sel_x_b_9_q;


    // VCC(CONSTANT,1)
    assign VCC_q = $unsigned(1'b1);

    // redist0_sync_together10_aunroll_x_in_i_valid_9(DELAY,12)
    dspba_delay_ver #( .width(1), .depth(9), .reset_kind("ASYNC"), .phase(0), .modulus(1), .reset_high(1'b0) )
    redist0_sync_together10_aunroll_x_in_i_valid_9 ( .xin(in_i_valid), .xout(redist0_sync_together10_aunroll_x_in_i_valid_9_q), .clk(clock), .aclr(resetn), .ena(1'b1) );

    // c_float_3_500000e_007(FLOATCONSTANT,2)
    assign c_float_3_500000e_007_q = $unsigned(32'b01000000011000000000000000000000);

    // i_conv_slavereg_comp3(BLACKBOX,4)@830
    // out out_primWireOut@836
    slavereg_comp_flt_i_sfc_logic_s_c0_in_fo00002cdo6u2ocpq6c0ouq3cz thei_conv_slavereg_comp3 (
        .in_0(in_c0_eni1_1_tpl),
        .out_primWireOut(i_conv_slavereg_comp3_out_primWireOut),
        .clock(clock),
        .resetn(resetn)
    );

    // i_mul4_slavereg_comp4(BLACKBOX,6)@836
    // out out_primWireOut@839
    slavereg_comp_flt_i_sfc_logic_s_c0_in_fo000024ad20454ge26154gk5u thei_mul4_slavereg_comp4 (
        .in_0(i_conv_slavereg_comp3_out_primWireOut),
        .in_1(c_float_3_500000e_007_q),
        .out_primWireOut(i_mul4_slavereg_comp4_out_primWireOut),
        .clock(clock),
        .resetn(resetn)
    );

    // i_lm22_toi1_intcast_slavereg_comp2_sel_x(BITSELECT,8)@830
    assign i_lm22_toi1_intcast_slavereg_comp2_sel_x_b = in_c0_eni1_1_tpl[0:0];

    // redist1_i_lm22_toi1_intcast_slavereg_comp2_sel_x_b_9(DELAY,13)
    dspba_delay_ver #( .width(1), .depth(9), .reset_kind("ASYNC"), .phase(0), .modulus(1), .reset_high(1'b0) )
    redist1_i_lm22_toi1_intcast_slavereg_comp2_sel_x_b_9 ( .xin(i_lm22_toi1_intcast_slavereg_comp2_sel_x_b), .xout(redist1_i_lm22_toi1_intcast_slavereg_comp2_sel_x_b_9_q), .clk(clock), .aclr(resetn), .ena(1'b1) );

    // GND(CONSTANT,0)
    assign GND_q = $unsigned(1'b0);

    // sync_out_aunroll_x(GPOUT,9)@839
    assign out_c0_exi2_0_tpl = GND_q;
    assign out_c0_exi2_1_tpl = redist1_i_lm22_toi1_intcast_slavereg_comp2_sel_x_b_9_q;
    assign out_c0_exi2_2_tpl = i_mul4_slavereg_comp4_out_primWireOut;
    assign out_o_valid = redist0_sync_together10_aunroll_x_in_i_valid_9_q;
    assign out_unnamed_slavereg_comp1 = GND_q;

endmodule
