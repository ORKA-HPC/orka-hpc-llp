// bsp_top_sld_jtag_bridge_agent_0.v

// Generated using ACDS version 21.1 169

`timescale 1 ps / 1 ps
module bsp_top_sld_jtag_bridge_agent_0 (
		output wire  tck,     // connect_to_bridge_host.tck
		output wire  tms,     //                       .tms
		output wire  tdi,     //                       .tdi
		output wire  vir_tdi, //                       .vir_tdi
		output wire  ena,     //                       .ena
		input  wire  tdo      //                       .tdo
	);

	altera_sld_jtag_bridge_agent_wrapper #(
		.PREFER_HOST    (" "),
		.INSTANCE_INDEX (-1)
	) sld_jtag_bridge_agent_0 (
		.tck     (tck),     //  output,  width = 1, connect_to_bridge_host.tck
		.tms     (tms),     //  output,  width = 1,                       .tms
		.tdi     (tdi),     //  output,  width = 1,                       .tdi
		.vir_tdi (vir_tdi), //  output,  width = 1,                       .vir_tdi
		.ena     (ena),     //  output,  width = 1,                       .ena
		.tdo     (tdo)      //   input,  width = 1,                       .tdo
	);

endmodule
