module bsp_top_pr_region_controller_0 (
		input  wire        clock_clk,                      //          clock.clk
		input  wire        reset_reset,                    //          reset.reset
		output wire        pr_handshake_start_req,         //   pr_handshake.start_req
		input  wire        pr_handshake_start_ack,         //               .start_ack
		output wire        pr_handshake_stop_req,          //               .stop_req
		input  wire        pr_handshake_stop_ack,          //               .stop_ack
		output wire        reset_source_reset,             //   reset_source.reset
		output wire        bridge_freeze0_freeze,          // bridge_freeze0.freeze
		input  wire        bridge_freeze0_illegal_request, //               .illegal_request
		output wire        bridge_freeze1_freeze,          // bridge_freeze1.freeze
		input  wire        bridge_freeze1_illegal_request, //               .illegal_request
		input  wire        avl_csr_read,                   //        avl_csr.read
		input  wire        avl_csr_write,                  //               .write
		input  wire [1:0]  avl_csr_address,                //               .address
		input  wire [31:0] avl_csr_writedata,              //               .writedata
		output wire [31:0] avl_csr_readdata                //               .readdata
	);
endmodule

