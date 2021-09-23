	top_dk u0 (
		.clk                 (_connected_to_clk_),                 //   input,    width = 1,    clock.clk
		.devkit_ctrl         (_connected_to_devkit_ctrl_),         //  output,  width = 256,   dk_hip.devkit_ctrl
		.devkit_status       (_connected_to_devkit_status_),       //   input,  width = 256,         .devkit_status
		.L0_led              (_connected_to_L0_led_),              //  output,    width = 1, dk_board.L0_led
		.alive_led           (_connected_to_alive_led_),           //  output,    width = 1,         .alive_led
		.comp_led            (_connected_to_comp_led_),            //  output,    width = 1,         .comp_led
		.free_clk            (_connected_to_free_clk_),            //   input,    width = 1,         .free_clk
		.gen2_led            (_connected_to_gen2_led_),            //  output,    width = 1,         .gen2_led
		.gen3_led            (_connected_to_gen3_led_),            //  output,    width = 1,         .gen3_led
		.lane_active_led     (_connected_to_lane_active_led_),     //  output,    width = 4,         .lane_active_led
		.req_compliance_pb   (_connected_to_req_compliance_pb_),   //   input,    width = 1,         .req_compliance_pb
		.set_compliance_mode (_connected_to_set_compliance_mode_)  //   input,    width = 1,         .set_compliance_mode
	);

