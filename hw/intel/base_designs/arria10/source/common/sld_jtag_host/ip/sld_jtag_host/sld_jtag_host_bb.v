module sld_jtag_host (
		input  wire  tck,     // connect_to_bridge_host.tck
		input  wire  tms,     //                       .tms
		input  wire  tdi,     //                       .tdi
		input  wire  vir_tdi, //                       .vir_tdi
		input  wire  ena,     //                       .ena
		output wire  tdo      //                       .tdo
	);
endmodule

