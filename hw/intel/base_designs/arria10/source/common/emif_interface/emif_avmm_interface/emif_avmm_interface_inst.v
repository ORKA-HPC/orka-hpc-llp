	emif_avmm_interface u0 (
		.emif_clk                         (_connected_to_emif_clk_),                         //   input,    width = 1,               emif.clk
		.usr_reset_n                      (_connected_to_usr_reset_n_),                      //   input,    width = 1,                usr.reset_n
		.global_reset                     (_connected_to_global_reset_),                     //   input,    width = 1,             global.reset
		.pr_region_clk                    (_connected_to_pr_region_clk_),                    //   input,    width = 1,          pr_region.clk
		.pr_to_emif_avmm_s0_waitrequest   (_connected_to_pr_to_emif_avmm_s0_waitrequest_),   //  output,    width = 1, pr_to_emif_avmm_s0.waitrequest
		.pr_to_emif_avmm_s0_readdata      (_connected_to_pr_to_emif_avmm_s0_readdata_),      //  output,  width = 512,                   .readdata
		.pr_to_emif_avmm_s0_readdatavalid (_connected_to_pr_to_emif_avmm_s0_readdatavalid_), //  output,    width = 1,                   .readdatavalid
		.pr_to_emif_avmm_s0_burstcount    (_connected_to_pr_to_emif_avmm_s0_burstcount_),    //   input,    width = 7,                   .burstcount
		.pr_to_emif_avmm_s0_writedata     (_connected_to_pr_to_emif_avmm_s0_writedata_),     //   input,  width = 512,                   .writedata
		.pr_to_emif_avmm_s0_address       (_connected_to_pr_to_emif_avmm_s0_address_),       //   input,   width = 25,                   .address
		.pr_to_emif_avmm_s0_write         (_connected_to_pr_to_emif_avmm_s0_write_),         //   input,    width = 1,                   .write
		.pr_to_emif_avmm_s0_read          (_connected_to_pr_to_emif_avmm_s0_read_),          //   input,    width = 1,                   .read
		.pr_to_emif_avmm_s0_byteenable    (_connected_to_pr_to_emif_avmm_s0_byteenable_),    //   input,   width = 64,                   .byteenable
		.pr_to_emif_avmm_s0_debugaccess   (_connected_to_pr_to_emif_avmm_s0_debugaccess_),   //   input,    width = 1,                   .debugaccess
		.pr_to_emif_avmm_m0_waitrequest   (_connected_to_pr_to_emif_avmm_m0_waitrequest_),   //   input,    width = 1, pr_to_emif_avmm_m0.waitrequest
		.pr_to_emif_avmm_m0_readdata      (_connected_to_pr_to_emif_avmm_m0_readdata_),      //   input,  width = 512,                   .readdata
		.pr_to_emif_avmm_m0_readdatavalid (_connected_to_pr_to_emif_avmm_m0_readdatavalid_), //   input,    width = 1,                   .readdatavalid
		.pr_to_emif_avmm_m0_burstcount    (_connected_to_pr_to_emif_avmm_m0_burstcount_),    //  output,    width = 7,                   .burstcount
		.pr_to_emif_avmm_m0_writedata     (_connected_to_pr_to_emif_avmm_m0_writedata_),     //  output,  width = 512,                   .writedata
		.pr_to_emif_avmm_m0_address       (_connected_to_pr_to_emif_avmm_m0_address_),       //  output,   width = 25,                   .address
		.pr_to_emif_avmm_m0_write         (_connected_to_pr_to_emif_avmm_m0_write_),         //  output,    width = 1,                   .write
		.pr_to_emif_avmm_m0_read          (_connected_to_pr_to_emif_avmm_m0_read_),          //  output,    width = 1,                   .read
		.pr_to_emif_avmm_m0_byteenable    (_connected_to_pr_to_emif_avmm_m0_byteenable_),    //  output,   width = 64,                   .byteenable
		.pr_to_emif_avmm_m0_debugaccess   (_connected_to_pr_to_emif_avmm_m0_debugaccess_)    //  output,    width = 1,                   .debugaccess
	);

