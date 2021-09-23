module emif_avmm_interface (
		input  wire         emif_clk,                         //               emif.clk
		input  wire         usr_reset_n,                      //                usr.reset_n
		input  wire         global_reset,                     //             global.reset
		input  wire         pr_region_clk,                    //          pr_region.clk
		output wire         pr_to_emif_avmm_s0_waitrequest,   // pr_to_emif_avmm_s0.waitrequest
		output wire [511:0] pr_to_emif_avmm_s0_readdata,      //                   .readdata
		output wire         pr_to_emif_avmm_s0_readdatavalid, //                   .readdatavalid
		input  wire [6:0]   pr_to_emif_avmm_s0_burstcount,    //                   .burstcount
		input  wire [511:0] pr_to_emif_avmm_s0_writedata,     //                   .writedata
		input  wire [24:0]  pr_to_emif_avmm_s0_address,       //                   .address
		input  wire         pr_to_emif_avmm_s0_write,         //                   .write
		input  wire         pr_to_emif_avmm_s0_read,          //                   .read
		input  wire [63:0]  pr_to_emif_avmm_s0_byteenable,    //                   .byteenable
		input  wire         pr_to_emif_avmm_s0_debugaccess,   //                   .debugaccess
		input  wire         pr_to_emif_avmm_m0_waitrequest,   // pr_to_emif_avmm_m0.waitrequest
		input  wire [511:0] pr_to_emif_avmm_m0_readdata,      //                   .readdata
		input  wire         pr_to_emif_avmm_m0_readdatavalid, //                   .readdatavalid
		output wire [6:0]   pr_to_emif_avmm_m0_burstcount,    //                   .burstcount
		output wire [511:0] pr_to_emif_avmm_m0_writedata,     //                   .writedata
		output wire [24:0]  pr_to_emif_avmm_m0_address,       //                   .address
		output wire         pr_to_emif_avmm_m0_write,         //                   .write
		output wire         pr_to_emif_avmm_m0_read,          //                   .read
		output wire [63:0]  pr_to_emif_avmm_m0_byteenable,    //                   .byteenable
		output wire         pr_to_emif_avmm_m0_debugaccess    //                   .debugaccess
	);
endmodule

