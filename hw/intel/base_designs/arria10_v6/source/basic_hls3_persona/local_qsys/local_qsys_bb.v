module local_qsys (
		output wire         avs_ctrl_waitrequest,    //        avs_ctrl.waitrequest
		output wire [63:0]  avs_ctrl_readdata,       //                .readdata
		output wire         avs_ctrl_readdatavalid,  //                .readdatavalid
		input  wire [0:0]   avs_ctrl_burstcount,     //                .burstcount
		input  wire [63:0]  avs_ctrl_writedata,      //                .writedata
		input  wire [15:0]  avs_ctrl_address,        //                .address
		input  wire         avs_ctrl_write,          //                .write
		input  wire         avs_ctrl_read,           //                .read
		input  wire [7:0]   avs_ctrl_byteenable,     //                .byteenable
		input  wire         avs_ctrl_debugaccess,    //                .debugaccess
		input  wire         clk_clk,                 //             clk.clk
		input  wire         emif_clk_clk,            //        emif_clk.clk
		input  wire         avm_emif_waitrequest,    //        avm_emif.waitrequest
		input  wire [511:0] avm_emif_readdata,       //                .readdata
		input  wire         avm_emif_readdatavalid,  //                .readdatavalid
		output wire [4:0]   avm_emif_burstcount,     //                .burstcount
		output wire [511:0] avm_emif_writedata,      //                .writedata
		output wire [30:0]  avm_emif_address,        //                .address
		output wire         avm_emif_write,          //                .write
		output wire         avm_emif_read,           //                .read
		output wire [63:0]  avm_emif_byteenable,     //                .byteenable
		output wire         avm_emif_debugaccess,    //                .debugaccess
		input  wire         pr_handshake_start_req,  //    pr_handshake.start_req
		output wire         pr_handshake_start_ack,  //                .start_ack
		input  wire         pr_handshake_stop_req,   //                .stop_req
		output wire         pr_handshake_stop_ack,   //                .stop_ack
		input  wire         reset_reset_n,           //           reset.reset_n
		input  wire         reset_emif_reset_n,      //      reset_emif.reset_n
		input  wire         sld_jtag_bridge_tck,     // sld_jtag_bridge.tck
		input  wire         sld_jtag_bridge_tms,     //                .tms
		input  wire         sld_jtag_bridge_tdi,     //                .tdi
		input  wire         sld_jtag_bridge_vir_tdi, //                .vir_tdi
		input  wire         sld_jtag_bridge_ena,     //                .ena
		output wire         sld_jtag_bridge_tdo      //                .tdo
	);
endmodule

