	bsp_top_avlmm_pr_freeze_bridge_0 u0 (
		.clock                               (_connected_to_clock_),                               //   input,   width = 1,            clock.clk
		.reset_n                             (_connected_to_reset_n_),                             //   input,   width = 1,          reset_n.reset_n
		.freeze_conduit_freeze               (_connected_to_freeze_conduit_freeze_),               //   input,   width = 1,   freeze_conduit.freeze
		.freeze_conduit_illegal_request      (_connected_to_freeze_conduit_illegal_request_),      //  output,   width = 1,                 .illegal_request
		.slv_bridge_to_pr_read               (_connected_to_slv_bridge_to_pr_read_),               //  output,   width = 1, slv_bridge_to_pr.read
		.slv_bridge_to_pr_waitrequest        (_connected_to_slv_bridge_to_pr_waitrequest_),        //   input,   width = 1,                 .waitrequest
		.slv_bridge_to_pr_write              (_connected_to_slv_bridge_to_pr_write_),              //  output,   width = 1,                 .write
		.slv_bridge_to_pr_address            (_connected_to_slv_bridge_to_pr_address_),            //  output,  width = 16,                 .address
		.slv_bridge_to_pr_byteenable         (_connected_to_slv_bridge_to_pr_byteenable_),         //  output,   width = 8,                 .byteenable
		.slv_bridge_to_pr_writedata          (_connected_to_slv_bridge_to_pr_writedata_),          //  output,  width = 64,                 .writedata
		.slv_bridge_to_pr_readdata           (_connected_to_slv_bridge_to_pr_readdata_),           //   input,  width = 64,                 .readdata
		.slv_bridge_to_pr_burstcount         (_connected_to_slv_bridge_to_pr_burstcount_),         //  output,   width = 3,                 .burstcount
		.slv_bridge_to_pr_readdatavalid      (_connected_to_slv_bridge_to_pr_readdatavalid_),      //   input,   width = 1,                 .readdatavalid
		.slv_bridge_to_pr_beginbursttransfer (_connected_to_slv_bridge_to_pr_beginbursttransfer_), //  output,   width = 1,                 .beginbursttransfer
		.slv_bridge_to_pr_debugaccess        (_connected_to_slv_bridge_to_pr_debugaccess_),        //  output,   width = 1,                 .debugaccess
		.slv_bridge_to_pr_response           (_connected_to_slv_bridge_to_pr_response_),           //   input,   width = 2,                 .response
		.slv_bridge_to_pr_lock               (_connected_to_slv_bridge_to_pr_lock_),               //  output,   width = 1,                 .lock
		.slv_bridge_to_pr_writeresponsevalid (_connected_to_slv_bridge_to_pr_writeresponsevalid_), //   input,   width = 1,                 .writeresponsevalid
		.slv_bridge_to_sr_read               (_connected_to_slv_bridge_to_sr_read_),               //   input,   width = 1, slv_bridge_to_sr.read
		.slv_bridge_to_sr_waitrequest        (_connected_to_slv_bridge_to_sr_waitrequest_),        //  output,   width = 1,                 .waitrequest
		.slv_bridge_to_sr_write              (_connected_to_slv_bridge_to_sr_write_),              //   input,   width = 1,                 .write
		.slv_bridge_to_sr_address            (_connected_to_slv_bridge_to_sr_address_),            //   input,  width = 16,                 .address
		.slv_bridge_to_sr_byteenable         (_connected_to_slv_bridge_to_sr_byteenable_),         //   input,   width = 8,                 .byteenable
		.slv_bridge_to_sr_writedata          (_connected_to_slv_bridge_to_sr_writedata_),          //   input,  width = 64,                 .writedata
		.slv_bridge_to_sr_readdata           (_connected_to_slv_bridge_to_sr_readdata_),           //  output,  width = 64,                 .readdata
		.slv_bridge_to_sr_burstcount         (_connected_to_slv_bridge_to_sr_burstcount_),         //   input,   width = 3,                 .burstcount
		.slv_bridge_to_sr_readdatavalid      (_connected_to_slv_bridge_to_sr_readdatavalid_),      //  output,   width = 1,                 .readdatavalid
		.slv_bridge_to_sr_beginbursttransfer (_connected_to_slv_bridge_to_sr_beginbursttransfer_), //   input,   width = 1,                 .beginbursttransfer
		.slv_bridge_to_sr_debugaccess        (_connected_to_slv_bridge_to_sr_debugaccess_),        //   input,   width = 1,                 .debugaccess
		.slv_bridge_to_sr_response           (_connected_to_slv_bridge_to_sr_response_),           //  output,   width = 2,                 .response
		.slv_bridge_to_sr_lock               (_connected_to_slv_bridge_to_sr_lock_),               //   input,   width = 1,                 .lock
		.slv_bridge_to_sr_writeresponsevalid (_connected_to_slv_bridge_to_sr_writeresponsevalid_)  //  output,   width = 1,                 .writeresponsevalid
	);

