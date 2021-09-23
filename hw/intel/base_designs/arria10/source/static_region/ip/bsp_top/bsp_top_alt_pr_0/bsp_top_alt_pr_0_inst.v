	bsp_top_alt_pr_0 u0 (
		.clk                    (_connected_to_clk_),                    //   input,   width = 1,        clk.clk
		.nreset                 (_connected_to_nreset_),                 //   input,   width = 1,     nreset.reset_n
		.avmm_slave_address     (_connected_to_avmm_slave_address_),     //   input,   width = 4, avmm_slave.address
		.avmm_slave_read        (_connected_to_avmm_slave_read_),        //   input,   width = 1,           .read
		.avmm_slave_writedata   (_connected_to_avmm_slave_writedata_),   //   input,  width = 32,           .writedata
		.avmm_slave_write       (_connected_to_avmm_slave_write_),       //   input,   width = 1,           .write
		.avmm_slave_readdata    (_connected_to_avmm_slave_readdata_),    //  output,  width = 32,           .readdata
		.avmm_slave_waitrequest (_connected_to_avmm_slave_waitrequest_)  //  output,   width = 1,           .waitrequest
	);

