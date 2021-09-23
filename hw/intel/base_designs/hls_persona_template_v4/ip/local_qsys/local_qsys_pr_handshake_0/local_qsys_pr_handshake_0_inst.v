	local_qsys_pr_handshake_0 u0 (
		.clk                    (_connected_to_clk_),                    //   input,  width = 1,        clock.clk
		.rst                    (_connected_to_rst_),                    //   input,  width = 1,   reset_sink.reset
		.pr_handshake_start_req (_connected_to_pr_handshake_start_req_), //   input,  width = 1, pr_handshake.start_req
		.pr_handshake_start_ack (_connected_to_pr_handshake_start_ack_), //  output,  width = 1,             .start_ack
		.pr_handshake_stop_req  (_connected_to_pr_handshake_stop_req_),  //   input,  width = 1,             .stop_req
		.pr_handshake_stop_ack  (_connected_to_pr_handshake_stop_ack_)   //  output,  width = 1,             .stop_ack
	);

