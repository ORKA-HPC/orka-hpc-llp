	bsp_top_iopll_0 u0 (
		.rst      (_connected_to_rst_),      //   input,  width = 1,   reset.reset
		.refclk   (_connected_to_refclk_),   //   input,  width = 1,  refclk.clk
		.locked   (_connected_to_locked_),   //  output,  width = 1,  locked.export
		.outclk_0 (_connected_to_outclk_0_)  //  output,  width = 1, outclk0.clk
	);

