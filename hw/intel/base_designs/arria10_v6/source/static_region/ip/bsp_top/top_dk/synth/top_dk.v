// top_dk.v

// Generated using ACDS version 21.1 169

`timescale 1 ps / 1 ps
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

	altpcie_devkit dk (
		.clk                 (clk),                 //   input,    width = 1,    clock.clk
		.devkit_ctrl         (devkit_ctrl),         //  output,  width = 256,   dk_hip.devkit_ctrl
		.devkit_status       (devkit_status),       //   input,  width = 256,         .devkit_status
		.L0_led              (L0_led),              //  output,    width = 1, dk_board.L0_led
		.alive_led           (alive_led),           //  output,    width = 1,         .alive_led
		.comp_led            (comp_led),            //  output,    width = 1,         .comp_led
		.free_clk            (free_clk),            //   input,    width = 1,         .free_clk
		.gen2_led            (gen2_led),            //  output,    width = 1,         .gen2_led
		.gen3_led            (gen3_led),            //  output,    width = 1,         .gen3_led
		.lane_active_led     (lane_active_led),     //  output,    width = 4,         .lane_active_led
		.req_compliance_pb   (req_compliance_pb),   //   input,    width = 1,         .req_compliance_pb
		.set_compliance_mode (set_compliance_mode)  //   input,    width = 1,         .set_compliance_mode
	);

endmodule
