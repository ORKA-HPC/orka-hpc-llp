// global_rst_n.v

// Generated using ACDS version 21.1 169

`timescale 1 ps / 1 ps
module global_rst_n (
		input  wire  in_reset_n,  //  in_reset.reset_n
		output wire  out_reset_n  // out_reset.reset_n
	);

	assign out_reset_n = in_reset_n;

endmodule
