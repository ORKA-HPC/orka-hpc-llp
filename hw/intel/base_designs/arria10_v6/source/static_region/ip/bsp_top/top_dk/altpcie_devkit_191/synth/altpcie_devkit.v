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


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on



module altpcie_devkit (
   input  wire [255:0]  devkit_status,
   output wire [255:0]  devkit_ctrl,

   // devkit board pins
   input  wire free_clk                , //    devkit_pins.free_clk
   input  wire req_compliance_pb       , //               .req_compliance_pb
   input  wire set_compliance_mode     , //               .set_compliance_mode
   output wire [3:0] lane_active_led  , //               .lane_active_led
   output wire L0_led                 , //               .L0_led
   output wire alive_led              , //               .alive_led
   output wire comp_led               , //               .comp_led
   output wire gen2_led               , //               .gen2_led
   output wire gen3_led               , //               .gen3_led

   input clk
   );

localparam [255:0] ONES                                  = 256'HFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
localparam [255:0] ZEROS                                 = 256'H0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
//synthesis translate_off
localparam ALTPCIE_ED_SIM_ONLY  = 1;
//synthesis translate_on
//synthesis read_comments_as_HDL on
//localparam ALTPCIE_ED_SIM_ONLY  = 0;
//synthesis read_comments_as_HDL off

   wire [1 : 0] currentspeed             ;
// wire         derr_cor_ext_rcv         ;
// wire         derr_cor_ext_rpl         ;
// wire         derr_rpl                 ;
// wire         rx_par_err               ;
// wire [1:0]   tx_par_err               ;
// wire         cfg_par_err              ;
// wire         dlup                     ;
// wire         dlup_exit                ;
// wire         ev128ns                  ;
// wire         ev1us                    ;
// wire         hotrst_exit              ;
// wire [3 : 0] int_status               ;
// wire         l2_exit                  ;
   wire [3 : 0] lane_act                 ;
   wire [4 : 0] ltssmstate               ;
// wire [7 :0]  ko_cpl_spc_header        ;
// wire [11 :0] ko_cpl_spc_data          ;
// wire         rxfc_cplbuf_ovf          ;
   wire         reset_status             ;

reg [ 26: 0] alive_cnt     ;
reg alive_led_r            ;
reg comp_led_r             ;
reg L0_led_r               ;
reg gen2_led_r             ;
reg gen3_led_r             ;
reg [3:0] lane_active_led_r;
wire gen2_speed            ;
reg  [4:0] ltssmstate_r    ;
reg  [3:0] lane_act_r      ;
reg  [3:0] currentspeed_r      ;

// CBB Logic
reg    req_compliance_pulse;
reg    force_exit_compliance;
reg [15:0] dbc_cnt;
reg        ltssm_compliance, ltssm_detect;

  assign currentspeed          [1 : 0]   = devkit_status[1:0]   ;
//assign derr_cor_ext_rcv                = devkit_status[2]     ;
//assign derr_cor_ext_rpl                = devkit_status[3]     ;
//assign derr_rpl                        = devkit_status[4]     ;
//assign rx_par_err                      = devkit_status[5]     ;
//assign tx_par_err            [1:0]     = devkit_status[7:6]   ;
//assign cfg_par_err                     = devkit_status[8]     ;
//assign dlup                            = devkit_status[9]     ;
//assign dlup_exit                       = devkit_status[10]    ;
//assign ev128ns                         = devkit_status[11]    ;
//assign ev1us                           = devkit_status[12]    ;
//assign hotrst_exit                     = devkit_status[13]    ;
//assign int_status            [3 : 0]   = devkit_status[17:14] ;
//assign l2_exit                         = devkit_status[18]    ;
  assign lane_act              [3 : 0]   = devkit_status[22:19] ;
  assign ltssmstate            [4 : 0]   = devkit_status[27:23] ;
//assign ko_cpl_spc_header     [7 :0]    = devkit_status[35:28] ;
//assign ko_cpl_spc_data       [11 :0]   = devkit_status[47:36] ;
//assign rxfc_cplbuf_ovf                 = devkit_status[48]    ;
  assign reset_status                    = devkit_status[49]    ;


generate begin : g_testin
   if (ALTPCIE_ED_SIM_ONLY==1) begin : g_sim
      assign devkit_ctrl[31 : 10] = 22'h0;
      assign devkit_ctrl[9]       = 1'b0;
      assign devkit_ctrl[8 : 0]   = 9'h1;
   end
   else begin : g_synth
      assign devkit_ctrl[31:7]    = 25'h1;
      assign devkit_ctrl[6:5]     = 2'b01;
      assign devkit_ctrl[4:1]     = 4'b0100;
      assign devkit_ctrl[0]       = 1'b0;
   end
end
endgenerate

assign devkit_ctrl[63:32]              = 32'h0;
assign devkit_ctrl[255:64]             = ZEROS[255:64];

always @(posedge clk) begin
   if (reset_status == 1'b1) begin
      lane_act_r   <= 4'h0;
      ltssmstate_r <= 5'h0;
   end
   else begin
      lane_act_r   <= lane_act;
      ltssmstate_r <= ltssmstate;
   end
end

always @(posedge clk) begin
   if (reset_status == 1'b1) begin
      alive_cnt             <= 27'h0;
      alive_led_r           <= 1'h0;
      comp_led_r            <= 1'h0;
      L0_led_r              <= 1'h0;
      gen2_led_r            <= 1'h0;
      gen3_led_r            <= 1'h0;
      lane_active_led_r[3:0]<= 4'h0;
      currentspeed_r        <= 2'h0;
   end
   else begin
      alive_cnt      <= alive_cnt +27'h1;
      alive_led_r    <= alive_cnt[26];
      currentspeed_r <= currentspeed;
      comp_led_r     <= ~(ltssmstate_r[4 : 0] == 5'b00011);
      L0_led_r       <= ~(ltssmstate_r[4 : 0] == 5'b01111);
      gen2_led_r     <= (currentspeed_r == 2'b10)?1'b0:1'b1;
      gen3_led_r     <= (currentspeed_r == 2'b11)?1'b0:1'b1;
      if (lane_act_r[0])
        lane_active_led_r <= ~(4'b0001);
      else if (lane_act_r[1])
        lane_active_led_r <= ~(4'b0011);
      else if (lane_act_r[2])
        lane_active_led_r <= ~(4'b0111);
      else if (lane_act_r[3])
        lane_active_led_r <= ~(4'b1111);
   end
end
assign alive_led       = alive_led_r            ;
assign comp_led        = comp_led_r             ;
assign L0_led          = L0_led_r               ;
assign gen2_led        = gen2_led_r             ;
assign gen3_led        = gen3_led_r             ;
assign lane_active_led = lane_active_led_r      ;

endmodule
