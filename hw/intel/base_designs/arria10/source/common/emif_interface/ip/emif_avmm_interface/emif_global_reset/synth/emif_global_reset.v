// emif_global_reset.v

// Generated using ACDS version 21.1 169

`timescale 1 ps / 1 ps
module emif_global_reset (
		input  wire  clk,       //       clk.clk
		input  wire  in_reset,  //  in_reset.reset
		output wire  out_reset  // out_reset.reset
	);

	assign out_reset = in_reset;

endmodule
