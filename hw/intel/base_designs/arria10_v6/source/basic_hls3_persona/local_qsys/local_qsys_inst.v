	local_qsys u0 (
		.avs_ctrl_waitrequest    (_connected_to_avs_ctrl_waitrequest_),    //  output,    width = 1,        avs_ctrl.waitrequest
		.avs_ctrl_readdata       (_connected_to_avs_ctrl_readdata_),       //  output,   width = 64,                .readdata
		.avs_ctrl_readdatavalid  (_connected_to_avs_ctrl_readdatavalid_),  //  output,    width = 1,                .readdatavalid
		.avs_ctrl_burstcount     (_connected_to_avs_ctrl_burstcount_),     //   input,    width = 1,                .burstcount
		.avs_ctrl_writedata      (_connected_to_avs_ctrl_writedata_),      //   input,   width = 64,                .writedata
		.avs_ctrl_address        (_connected_to_avs_ctrl_address_),        //   input,   width = 16,                .address
		.avs_ctrl_write          (_connected_to_avs_ctrl_write_),          //   input,    width = 1,                .write
		.avs_ctrl_read           (_connected_to_avs_ctrl_read_),           //   input,    width = 1,                .read
		.avs_ctrl_byteenable     (_connected_to_avs_ctrl_byteenable_),     //   input,    width = 8,                .byteenable
		.avs_ctrl_debugaccess    (_connected_to_avs_ctrl_debugaccess_),    //   input,    width = 1,                .debugaccess
		.clk_clk                 (_connected_to_clk_clk_),                 //   input,    width = 1,             clk.clk
		.emif_clk_clk            (_connected_to_emif_clk_clk_),            //   input,    width = 1,        emif_clk.clk
		.avm_emif_waitrequest    (_connected_to_avm_emif_waitrequest_),    //   input,    width = 1,        avm_emif.waitrequest
		.avm_emif_readdata       (_connected_to_avm_emif_readdata_),       //   input,  width = 512,                .readdata
		.avm_emif_readdatavalid  (_connected_to_avm_emif_readdatavalid_),  //   input,    width = 1,                .readdatavalid
		.avm_emif_burstcount     (_connected_to_avm_emif_burstcount_),     //  output,    width = 5,                .burstcount
		.avm_emif_writedata      (_connected_to_avm_emif_writedata_),      //  output,  width = 512,                .writedata
		.avm_emif_address        (_connected_to_avm_emif_address_),        //  output,   width = 31,                .address
		.avm_emif_write          (_connected_to_avm_emif_write_),          //  output,    width = 1,                .write
		.avm_emif_read           (_connected_to_avm_emif_read_),           //  output,    width = 1,                .read
		.avm_emif_byteenable     (_connected_to_avm_emif_byteenable_),     //  output,   width = 64,                .byteenable
		.avm_emif_debugaccess    (_connected_to_avm_emif_debugaccess_),    //  output,    width = 1,                .debugaccess
		.pr_handshake_start_req  (_connected_to_pr_handshake_start_req_),  //   input,    width = 1,    pr_handshake.start_req
		.pr_handshake_start_ack  (_connected_to_pr_handshake_start_ack_),  //  output,    width = 1,                .start_ack
		.pr_handshake_stop_req   (_connected_to_pr_handshake_stop_req_),   //   input,    width = 1,                .stop_req
		.pr_handshake_stop_ack   (_connected_to_pr_handshake_stop_ack_),   //  output,    width = 1,                .stop_ack
		.reset_reset_n           (_connected_to_reset_reset_n_),           //   input,    width = 1,           reset.reset_n
		.reset_emif_reset_n      (_connected_to_reset_emif_reset_n_),      //   input,    width = 1,      reset_emif.reset_n
		.sld_jtag_bridge_tck     (_connected_to_sld_jtag_bridge_tck_),     //   input,    width = 1, sld_jtag_bridge.tck
		.sld_jtag_bridge_tms     (_connected_to_sld_jtag_bridge_tms_),     //   input,    width = 1,                .tms
		.sld_jtag_bridge_tdi     (_connected_to_sld_jtag_bridge_tdi_),     //   input,    width = 1,                .tdi
		.sld_jtag_bridge_vir_tdi (_connected_to_sld_jtag_bridge_vir_tdi_), //   input,    width = 1,                .vir_tdi
		.sld_jtag_bridge_ena     (_connected_to_sld_jtag_bridge_ena_),     //   input,    width = 1,                .ena
		.sld_jtag_bridge_tdo     (_connected_to_sld_jtag_bridge_tdo_)      //  output,    width = 1,                .tdo
	);

