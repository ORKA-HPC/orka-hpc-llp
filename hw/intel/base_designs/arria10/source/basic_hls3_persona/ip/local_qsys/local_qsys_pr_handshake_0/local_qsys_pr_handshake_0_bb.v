module local_qsys_pr_handshake_0 (
		input  wire  clk,                    //        clock.clk
		input  wire  rst,                    //   reset_sink.reset
		input  wire  pr_handshake_start_req, // pr_handshake.start_req
		output wire  pr_handshake_start_ack, //             .start_ack
		input  wire  pr_handshake_stop_req,  //             .stop_req
		output wire  pr_handshake_stop_ack   //             .stop_ack
	);
endmodule

