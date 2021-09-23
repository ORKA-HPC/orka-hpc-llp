module top_dk (
		input  wire         clk,                 //    clock.clk
		output wire [255:0] devkit_ctrl,         //   dk_hip.devkit_ctrl
		input  wire [255:0] devkit_status,       //         .devkit_status
		output wire         L0_led,              // dk_board.L0_led
		output wire         alive_led,           //         .alive_led
		output wire         comp_led,            //         .comp_led
		input  wire         free_clk,            //         .free_clk
		output wire         gen2_led,            //         .gen2_led
		output wire         gen3_led,            //         .gen3_led
		output wire [3:0]   lane_active_led,     //         .lane_active_led
		input  wire         req_compliance_pb,   //         .req_compliance_pb
		input  wire         set_compliance_mode  //         .set_compliance_mode
	);
endmodule

