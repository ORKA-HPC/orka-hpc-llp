module local_qsys_slavereg_comp_internal_0 (
		input  wire         clock,                   //     clock.clk
		input  wire         resetn,                  //     reset.reset_n
		output wire         done_irq,                //       irq.irq
		output wire [31:0]  avmm_1_rw_address,       // avmm_1_rw.address
		output wire [63:0]  avmm_1_rw_byteenable,    //          .byteenable
		input  wire         avmm_1_rw_readdatavalid, //          .readdatavalid
		output wire         avmm_1_rw_read,          //          .read
		input  wire [511:0] avmm_1_rw_readdata,      //          .readdata
		output wire         avmm_1_rw_write,         //          .write
		output wire [511:0] avmm_1_rw_writedata,     //          .writedata
		input  wire         avmm_1_rw_waitrequest,   //          .waitrequest
		output wire [4:0]   avmm_1_rw_burstcount,    //          .burstcount
		input  wire         avs_cra_read,            //   avs_cra.read
		output wire [63:0]  avs_cra_readdata,        //          .readdata
		input  wire         avs_cra_write,           //          .write
		input  wire [63:0]  avs_cra_writedata,       //          .writedata
		input  wire [3:0]   avs_cra_address,         //          .address
		input  wire [7:0]   avs_cra_byteenable       //          .byteenable
	);
endmodule

