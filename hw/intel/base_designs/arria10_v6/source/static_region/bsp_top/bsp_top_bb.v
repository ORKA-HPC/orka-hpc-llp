module bsp_top (
		input  wire        a10_pcie_refclk_clk,            //  a10_pcie_refclk.clk
		input  wire        pcie_rstn_npor,                 //        pcie_rstn.npor
		input  wire        pcie_rstn_pin_perst,            //                 .pin_perst
		input  wire [31:0] hip_ctrl_test_in,               //         hip_ctrl.test_in
		input  wire        hip_ctrl_simu_mode_pipe,        //                 .simu_mode_pipe
		input  wire        pipe_sim_only_sim_pipe_pclk_in, //    pipe_sim_only.sim_pipe_pclk_in
		output wire [1:0]  pipe_sim_only_sim_pipe_rate,    //                 .sim_pipe_rate
		output wire [4:0]  pipe_sim_only_sim_ltssmstate,   //                 .sim_ltssmstate
		output wire [2:0]  pipe_sim_only_eidleinfersel0,   //                 .eidleinfersel0
		output wire [2:0]  pipe_sim_only_eidleinfersel1,   //                 .eidleinfersel1
		output wire [2:0]  pipe_sim_only_eidleinfersel2,   //                 .eidleinfersel2
		output wire [2:0]  pipe_sim_only_eidleinfersel3,   //                 .eidleinfersel3
		output wire [2:0]  pipe_sim_only_eidleinfersel4,   //                 .eidleinfersel4
		output wire [2:0]  pipe_sim_only_eidleinfersel5,   //                 .eidleinfersel5
		output wire [2:0]  pipe_sim_only_eidleinfersel6,   //                 .eidleinfersel6
		output wire [2:0]  pipe_sim_only_eidleinfersel7,   //                 .eidleinfersel7
		output wire [1:0]  pipe_sim_only_powerdown0,       //                 .powerdown0
		output wire [1:0]  pipe_sim_only_powerdown1,       //                 .powerdown1
		output wire [1:0]  pipe_sim_only_powerdown2,       //                 .powerdown2
		output wire [1:0]  pipe_sim_only_powerdown3,       //                 .powerdown3
		output wire [1:0]  pipe_sim_only_powerdown4,       //                 .powerdown4
		output wire [1:0]  pipe_sim_only_powerdown5,       //                 .powerdown5
		output wire [1:0]  pipe_sim_only_powerdown6,       //                 .powerdown6
		output wire [1:0]  pipe_sim_only_powerdown7,       //                 .powerdown7
		output wire        pipe_sim_only_rxpolarity0,      //                 .rxpolarity0
		output wire        pipe_sim_only_rxpolarity1,      //                 .rxpolarity1
		output wire        pipe_sim_only_rxpolarity2,      //                 .rxpolarity2
		output wire        pipe_sim_only_rxpolarity3,      //                 .rxpolarity3
		output wire        pipe_sim_only_rxpolarity4,      //                 .rxpolarity4
		output wire        pipe_sim_only_rxpolarity5,      //                 .rxpolarity5
		output wire        pipe_sim_only_rxpolarity6,      //                 .rxpolarity6
		output wire        pipe_sim_only_rxpolarity7,      //                 .rxpolarity7
		output wire        pipe_sim_only_txcompl0,         //                 .txcompl0
		output wire        pipe_sim_only_txcompl1,         //                 .txcompl1
		output wire        pipe_sim_only_txcompl2,         //                 .txcompl2
		output wire        pipe_sim_only_txcompl3,         //                 .txcompl3
		output wire        pipe_sim_only_txcompl4,         //                 .txcompl4
		output wire        pipe_sim_only_txcompl5,         //                 .txcompl5
		output wire        pipe_sim_only_txcompl6,         //                 .txcompl6
		output wire        pipe_sim_only_txcompl7,         //                 .txcompl7
		output wire [31:0] pipe_sim_only_txdata0,          //                 .txdata0
		output wire [31:0] pipe_sim_only_txdata1,          //                 .txdata1
		output wire [31:0] pipe_sim_only_txdata2,          //                 .txdata2
		output wire [31:0] pipe_sim_only_txdata3,          //                 .txdata3
		output wire [31:0] pipe_sim_only_txdata4,          //                 .txdata4
		output wire [31:0] pipe_sim_only_txdata5,          //                 .txdata5
		output wire [31:0] pipe_sim_only_txdata6,          //                 .txdata6
		output wire [31:0] pipe_sim_only_txdata7,          //                 .txdata7
		output wire [3:0]  pipe_sim_only_txdatak0,         //                 .txdatak0
		output wire [3:0]  pipe_sim_only_txdatak1,         //                 .txdatak1
		output wire [3:0]  pipe_sim_only_txdatak2,         //                 .txdatak2
		output wire [3:0]  pipe_sim_only_txdatak3,         //                 .txdatak3
		output wire [3:0]  pipe_sim_only_txdatak4,         //                 .txdatak4
		output wire [3:0]  pipe_sim_only_txdatak5,         //                 .txdatak5
		output wire [3:0]  pipe_sim_only_txdatak6,         //                 .txdatak6
		output wire [3:0]  pipe_sim_only_txdatak7,         //                 .txdatak7
		output wire        pipe_sim_only_txdetectrx0,      //                 .txdetectrx0
		output wire        pipe_sim_only_txdetectrx1,      //                 .txdetectrx1
		output wire        pipe_sim_only_txdetectrx2,      //                 .txdetectrx2
		output wire        pipe_sim_only_txdetectrx3,      //                 .txdetectrx3
		output wire        pipe_sim_only_txdetectrx4,      //                 .txdetectrx4
		output wire        pipe_sim_only_txdetectrx5,      //                 .txdetectrx5
		output wire        pipe_sim_only_txdetectrx6,      //                 .txdetectrx6
		output wire        pipe_sim_only_txdetectrx7,      //                 .txdetectrx7
		output wire        pipe_sim_only_txelecidle0,      //                 .txelecidle0
		output wire        pipe_sim_only_txelecidle1,      //                 .txelecidle1
		output wire        pipe_sim_only_txelecidle2,      //                 .txelecidle2
		output wire        pipe_sim_only_txelecidle3,      //                 .txelecidle3
		output wire        pipe_sim_only_txelecidle4,      //                 .txelecidle4
		output wire        pipe_sim_only_txelecidle5,      //                 .txelecidle5
		output wire        pipe_sim_only_txelecidle6,      //                 .txelecidle6
		output wire        pipe_sim_only_txelecidle7,      //                 .txelecidle7
		output wire        pipe_sim_only_txdeemph0,        //                 .txdeemph0
		output wire        pipe_sim_only_txdeemph1,        //                 .txdeemph1
		output wire        pipe_sim_only_txdeemph2,        //                 .txdeemph2
		output wire        pipe_sim_only_txdeemph3,        //                 .txdeemph3
		output wire        pipe_sim_only_txdeemph4,        //                 .txdeemph4
		output wire        pipe_sim_only_txdeemph5,        //                 .txdeemph5
		output wire        pipe_sim_only_txdeemph6,        //                 .txdeemph6
		output wire        pipe_sim_only_txdeemph7,        //                 .txdeemph7
		output wire [2:0]  pipe_sim_only_txmargin0,        //                 .txmargin0
		output wire [2:0]  pipe_sim_only_txmargin1,        //                 .txmargin1
		output wire [2:0]  pipe_sim_only_txmargin2,        //                 .txmargin2
		output wire [2:0]  pipe_sim_only_txmargin3,        //                 .txmargin3
		output wire [2:0]  pipe_sim_only_txmargin4,        //                 .txmargin4
		output wire [2:0]  pipe_sim_only_txmargin5,        //                 .txmargin5
		output wire [2:0]  pipe_sim_only_txmargin6,        //                 .txmargin6
		output wire [2:0]  pipe_sim_only_txmargin7,        //                 .txmargin7
		output wire        pipe_sim_only_txswing0,         //                 .txswing0
		output wire        pipe_sim_only_txswing1,         //                 .txswing1
		output wire        pipe_sim_only_txswing2,         //                 .txswing2
		output wire        pipe_sim_only_txswing3,         //                 .txswing3
		output wire        pipe_sim_only_txswing4,         //                 .txswing4
		output wire        pipe_sim_only_txswing5,         //                 .txswing5
		output wire        pipe_sim_only_txswing6,         //                 .txswing6
		output wire        pipe_sim_only_txswing7,         //                 .txswing7
		input  wire        pipe_sim_only_phystatus0,       //                 .phystatus0
		input  wire        pipe_sim_only_phystatus1,       //                 .phystatus1
		input  wire        pipe_sim_only_phystatus2,       //                 .phystatus2
		input  wire        pipe_sim_only_phystatus3,       //                 .phystatus3
		input  wire        pipe_sim_only_phystatus4,       //                 .phystatus4
		input  wire        pipe_sim_only_phystatus5,       //                 .phystatus5
		input  wire        pipe_sim_only_phystatus6,       //                 .phystatus6
		input  wire        pipe_sim_only_phystatus7,       //                 .phystatus7
		input  wire [31:0] pipe_sim_only_rxdata0,          //                 .rxdata0
		input  wire [31:0] pipe_sim_only_rxdata1,          //                 .rxdata1
		input  wire [31:0] pipe_sim_only_rxdata2,          //                 .rxdata2
		input  wire [31:0] pipe_sim_only_rxdata3,          //                 .rxdata3
		input  wire [31:0] pipe_sim_only_rxdata4,          //                 .rxdata4
		input  wire [31:0] pipe_sim_only_rxdata5,          //                 .rxdata5
		input  wire [31:0] pipe_sim_only_rxdata6,          //                 .rxdata6
		input  wire [31:0] pipe_sim_only_rxdata7,          //                 .rxdata7
		input  wire [3:0]  pipe_sim_only_rxdatak0,         //                 .rxdatak0
		input  wire [3:0]  pipe_sim_only_rxdatak1,         //                 .rxdatak1
		input  wire [3:0]  pipe_sim_only_rxdatak2,         //                 .rxdatak2
		input  wire [3:0]  pipe_sim_only_rxdatak3,         //                 .rxdatak3
		input  wire [3:0]  pipe_sim_only_rxdatak4,         //                 .rxdatak4
		input  wire [3:0]  pipe_sim_only_rxdatak5,         //                 .rxdatak5
		input  wire [3:0]  pipe_sim_only_rxdatak6,         //                 .rxdatak6
		input  wire [3:0]  pipe_sim_only_rxdatak7,         //                 .rxdatak7
		input  wire        pipe_sim_only_rxelecidle0,      //                 .rxelecidle0
		input  wire        pipe_sim_only_rxelecidle1,      //                 .rxelecidle1
		input  wire        pipe_sim_only_rxelecidle2,      //                 .rxelecidle2
		input  wire        pipe_sim_only_rxelecidle3,      //                 .rxelecidle3
		input  wire        pipe_sim_only_rxelecidle4,      //                 .rxelecidle4
		input  wire        pipe_sim_only_rxelecidle5,      //                 .rxelecidle5
		input  wire        pipe_sim_only_rxelecidle6,      //                 .rxelecidle6
		input  wire        pipe_sim_only_rxelecidle7,      //                 .rxelecidle7
		input  wire [2:0]  pipe_sim_only_rxstatus0,        //                 .rxstatus0
		input  wire [2:0]  pipe_sim_only_rxstatus1,        //                 .rxstatus1
		input  wire [2:0]  pipe_sim_only_rxstatus2,        //                 .rxstatus2
		input  wire [2:0]  pipe_sim_only_rxstatus3,        //                 .rxstatus3
		input  wire [2:0]  pipe_sim_only_rxstatus4,        //                 .rxstatus4
		input  wire [2:0]  pipe_sim_only_rxstatus5,        //                 .rxstatus5
		input  wire [2:0]  pipe_sim_only_rxstatus6,        //                 .rxstatus6
		input  wire [2:0]  pipe_sim_only_rxstatus7,        //                 .rxstatus7
		input  wire        pipe_sim_only_rxvalid0,         //                 .rxvalid0
		input  wire        pipe_sim_only_rxvalid1,         //                 .rxvalid1
		input  wire        pipe_sim_only_rxvalid2,         //                 .rxvalid2
		input  wire        pipe_sim_only_rxvalid3,         //                 .rxvalid3
		input  wire        pipe_sim_only_rxvalid4,         //                 .rxvalid4
		input  wire        pipe_sim_only_rxvalid5,         //                 .rxvalid5
		input  wire        pipe_sim_only_rxvalid6,         //                 .rxvalid6
		input  wire        pipe_sim_only_rxvalid7,         //                 .rxvalid7
		input  wire        pipe_sim_only_rxdataskip0,      //                 .rxdataskip0
		input  wire        pipe_sim_only_rxdataskip1,      //                 .rxdataskip1
		input  wire        pipe_sim_only_rxdataskip2,      //                 .rxdataskip2
		input  wire        pipe_sim_only_rxdataskip3,      //                 .rxdataskip3
		input  wire        pipe_sim_only_rxdataskip4,      //                 .rxdataskip4
		input  wire        pipe_sim_only_rxdataskip5,      //                 .rxdataskip5
		input  wire        pipe_sim_only_rxdataskip6,      //                 .rxdataskip6
		input  wire        pipe_sim_only_rxdataskip7,      //                 .rxdataskip7
		input  wire        pipe_sim_only_rxblkst0,         //                 .rxblkst0
		input  wire        pipe_sim_only_rxblkst1,         //                 .rxblkst1
		input  wire        pipe_sim_only_rxblkst2,         //                 .rxblkst2
		input  wire        pipe_sim_only_rxblkst3,         //                 .rxblkst3
		input  wire        pipe_sim_only_rxblkst4,         //                 .rxblkst4
		input  wire        pipe_sim_only_rxblkst5,         //                 .rxblkst5
		input  wire        pipe_sim_only_rxblkst6,         //                 .rxblkst6
		input  wire        pipe_sim_only_rxblkst7,         //                 .rxblkst7
		input  wire [1:0]  pipe_sim_only_rxsynchd0,        //                 .rxsynchd0
		input  wire [1:0]  pipe_sim_only_rxsynchd1,        //                 .rxsynchd1
		input  wire [1:0]  pipe_sim_only_rxsynchd2,        //                 .rxsynchd2
		input  wire [1:0]  pipe_sim_only_rxsynchd3,        //                 .rxsynchd3
		input  wire [1:0]  pipe_sim_only_rxsynchd4,        //                 .rxsynchd4
		input  wire [1:0]  pipe_sim_only_rxsynchd5,        //                 .rxsynchd5
		input  wire [1:0]  pipe_sim_only_rxsynchd6,        //                 .rxsynchd6
		input  wire [1:0]  pipe_sim_only_rxsynchd7,        //                 .rxsynchd7
		output wire [17:0] pipe_sim_only_currentcoeff0,    //                 .currentcoeff0
		output wire [17:0] pipe_sim_only_currentcoeff1,    //                 .currentcoeff1
		output wire [17:0] pipe_sim_only_currentcoeff2,    //                 .currentcoeff2
		output wire [17:0] pipe_sim_only_currentcoeff3,    //                 .currentcoeff3
		output wire [17:0] pipe_sim_only_currentcoeff4,    //                 .currentcoeff4
		output wire [17:0] pipe_sim_only_currentcoeff5,    //                 .currentcoeff5
		output wire [17:0] pipe_sim_only_currentcoeff6,    //                 .currentcoeff6
		output wire [17:0] pipe_sim_only_currentcoeff7,    //                 .currentcoeff7
		output wire [2:0]  pipe_sim_only_currentrxpreset0, //                 .currentrxpreset0
		output wire [2:0]  pipe_sim_only_currentrxpreset1, //                 .currentrxpreset1
		output wire [2:0]  pipe_sim_only_currentrxpreset2, //                 .currentrxpreset2
		output wire [2:0]  pipe_sim_only_currentrxpreset3, //                 .currentrxpreset3
		output wire [2:0]  pipe_sim_only_currentrxpreset4, //                 .currentrxpreset4
		output wire [2:0]  pipe_sim_only_currentrxpreset5, //                 .currentrxpreset5
		output wire [2:0]  pipe_sim_only_currentrxpreset6, //                 .currentrxpreset6
		output wire [2:0]  pipe_sim_only_currentrxpreset7, //                 .currentrxpreset7
		output wire [1:0]  pipe_sim_only_txsynchd0,        //                 .txsynchd0
		output wire [1:0]  pipe_sim_only_txsynchd1,        //                 .txsynchd1
		output wire [1:0]  pipe_sim_only_txsynchd2,        //                 .txsynchd2
		output wire [1:0]  pipe_sim_only_txsynchd3,        //                 .txsynchd3
		output wire [1:0]  pipe_sim_only_txsynchd4,        //                 .txsynchd4
		output wire [1:0]  pipe_sim_only_txsynchd5,        //                 .txsynchd5
		output wire [1:0]  pipe_sim_only_txsynchd6,        //                 .txsynchd6
		output wire [1:0]  pipe_sim_only_txsynchd7,        //                 .txsynchd7
		output wire        pipe_sim_only_txblkst0,         //                 .txblkst0
		output wire        pipe_sim_only_txblkst1,         //                 .txblkst1
		output wire        pipe_sim_only_txblkst2,         //                 .txblkst2
		output wire        pipe_sim_only_txblkst3,         //                 .txblkst3
		output wire        pipe_sim_only_txblkst4,         //                 .txblkst4
		output wire        pipe_sim_only_txblkst5,         //                 .txblkst5
		output wire        pipe_sim_only_txblkst6,         //                 .txblkst6
		output wire        pipe_sim_only_txblkst7,         //                 .txblkst7
		output wire        pipe_sim_only_txdataskip0,      //                 .txdataskip0
		output wire        pipe_sim_only_txdataskip1,      //                 .txdataskip1
		output wire        pipe_sim_only_txdataskip2,      //                 .txdataskip2
		output wire        pipe_sim_only_txdataskip3,      //                 .txdataskip3
		output wire        pipe_sim_only_txdataskip4,      //                 .txdataskip4
		output wire        pipe_sim_only_txdataskip5,      //                 .txdataskip5
		output wire        pipe_sim_only_txdataskip6,      //                 .txdataskip6
		output wire        pipe_sim_only_txdataskip7,      //                 .txdataskip7
		output wire [1:0]  pipe_sim_only_rate0,            //                 .rate0
		output wire [1:0]  pipe_sim_only_rate1,            //                 .rate1
		output wire [1:0]  pipe_sim_only_rate2,            //                 .rate2
		output wire [1:0]  pipe_sim_only_rate3,            //                 .rate3
		output wire [1:0]  pipe_sim_only_rate4,            //                 .rate4
		output wire [1:0]  pipe_sim_only_rate5,            //                 .rate5
		output wire [1:0]  pipe_sim_only_rate6,            //                 .rate6
		output wire [1:0]  pipe_sim_only_rate7,            //                 .rate7
		input  wire        xcvr_rx_in0,                    //             xcvr.rx_in0
		input  wire        xcvr_rx_in1,                    //                 .rx_in1
		input  wire        xcvr_rx_in2,                    //                 .rx_in2
		input  wire        xcvr_rx_in3,                    //                 .rx_in3
		input  wire        xcvr_rx_in4,                    //                 .rx_in4
		input  wire        xcvr_rx_in5,                    //                 .rx_in5
		input  wire        xcvr_rx_in6,                    //                 .rx_in6
		input  wire        xcvr_rx_in7,                    //                 .rx_in7
		output wire        xcvr_tx_out0,                   //                 .tx_out0
		output wire        xcvr_tx_out1,                   //                 .tx_out1
		output wire        xcvr_tx_out2,                   //                 .tx_out2
		output wire        xcvr_tx_out3,                   //                 .tx_out3
		output wire        xcvr_tx_out4,                   //                 .tx_out4
		output wire        xcvr_tx_out5,                   //                 .tx_out5
		output wire        xcvr_tx_out6,                   //                 .tx_out6
		output wire        xcvr_tx_out7,                   //                 .tx_out7
		input  wire        ddr4_pll_ref_clk_clk,           // ddr4_pll_ref_clk.clk
		input  wire        ddr4_oct_oct_rzqin,             //         ddr4_oct.oct_rzqin
		output wire [0:0]  ddr4_mem_mem_ck,                //         ddr4_mem.mem_ck
		output wire [0:0]  ddr4_mem_mem_ck_n,              //                 .mem_ck_n
		output wire [16:0] ddr4_mem_mem_a,                 //                 .mem_a
		output wire [0:0]  ddr4_mem_mem_act_n,             //                 .mem_act_n
		output wire [1:0]  ddr4_mem_mem_ba,                //                 .mem_ba
		output wire [0:0]  ddr4_mem_mem_bg,                //                 .mem_bg
		output wire [0:0]  ddr4_mem_mem_cke,               //                 .mem_cke
		output wire [0:0]  ddr4_mem_mem_cs_n,              //                 .mem_cs_n
		output wire [0:0]  ddr4_mem_mem_odt,               //                 .mem_odt
		output wire [0:0]  ddr4_mem_mem_reset_n,           //                 .mem_reset_n
		output wire [0:0]  ddr4_mem_mem_par,               //                 .mem_par
		input  wire [0:0]  ddr4_mem_mem_alert_n,           //                 .mem_alert_n
		inout  wire [7:0]  ddr4_mem_mem_dqs,               //                 .mem_dqs
		inout  wire [7:0]  ddr4_mem_mem_dqs_n,             //                 .mem_dqs_n
		inout  wire [63:0] ddr4_mem_mem_dq,                //                 .mem_dq
		inout  wire [7:0]  ddr4_mem_mem_dbi_n,             //                 .mem_dbi_n
		output wire        board_pins_L0_led,              //       board_pins.L0_led
		output wire        board_pins_alive_led,           //                 .alive_led
		output wire        board_pins_comp_led,            //                 .comp_led
		input  wire        board_pins_free_clk,            //                 .free_clk
		output wire        board_pins_gen2_led,            //                 .gen2_led
		output wire        board_pins_gen3_led,            //                 .gen3_led
		output wire [3:0]  board_pins_lane_active_led,     //                 .lane_active_led
		input  wire        board_pins_req_compliance_pb,   //                 .req_compliance_pb
		input  wire        board_pins_set_compliance_mode, //                 .set_compliance_mode
		input  wire        pll_refclk_clk                  //       pll_refclk.clk
	);
endmodule

