	local_qsys_slavereg_comp_internal_0 u0 (
		.clock                   (_connected_to_clock_),                   //   input,    width = 1,     clock.clk
		.resetn                  (_connected_to_resetn_),                  //   input,    width = 1,     reset.reset_n
		.done_irq                (_connected_to_done_irq_),                //  output,    width = 1,       irq.irq
		.avmm_1_rw_address       (_connected_to_avmm_1_rw_address_),       //  output,   width = 32, avmm_1_rw.address
		.avmm_1_rw_byteenable    (_connected_to_avmm_1_rw_byteenable_),    //  output,   width = 64,          .byteenable
		.avmm_1_rw_readdatavalid (_connected_to_avmm_1_rw_readdatavalid_), //   input,    width = 1,          .readdatavalid
		.avmm_1_rw_read          (_connected_to_avmm_1_rw_read_),          //  output,    width = 1,          .read
		.avmm_1_rw_readdata      (_connected_to_avmm_1_rw_readdata_),      //   input,  width = 512,          .readdata
		.avmm_1_rw_write         (_connected_to_avmm_1_rw_write_),         //  output,    width = 1,          .write
		.avmm_1_rw_writedata     (_connected_to_avmm_1_rw_writedata_),     //  output,  width = 512,          .writedata
		.avmm_1_rw_waitrequest   (_connected_to_avmm_1_rw_waitrequest_),   //   input,    width = 1,          .waitrequest
		.avmm_1_rw_burstcount    (_connected_to_avmm_1_rw_burstcount_),    //  output,    width = 5,          .burstcount
		.avs_cra_read            (_connected_to_avs_cra_read_),            //   input,    width = 1,   avs_cra.read
		.avs_cra_readdata        (_connected_to_avs_cra_readdata_),        //  output,   width = 64,          .readdata
		.avs_cra_write           (_connected_to_avs_cra_write_),           //   input,    width = 1,          .write
		.avs_cra_writedata       (_connected_to_avs_cra_writedata_),       //   input,   width = 64,          .writedata
		.avs_cra_address         (_connected_to_avs_cra_address_),         //   input,    width = 4,          .address
		.avs_cra_byteenable      (_connected_to_avs_cra_byteenable_)       //   input,    width = 8,          .byteenable
	);

