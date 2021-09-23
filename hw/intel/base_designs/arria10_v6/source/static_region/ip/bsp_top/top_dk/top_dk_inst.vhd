	component top_dk is
		port (
			clk                 : in  std_logic                      := 'X';             -- clk
			devkit_ctrl         : out std_logic_vector(255 downto 0);                    -- devkit_ctrl
			devkit_status       : in  std_logic_vector(255 downto 0) := (others => 'X'); -- devkit_status
			L0_led              : out std_logic;                                         -- L0_led
			alive_led           : out std_logic;                                         -- alive_led
			comp_led            : out std_logic;                                         -- comp_led
			free_clk            : in  std_logic                      := 'X';             -- free_clk
			gen2_led            : out std_logic;                                         -- gen2_led
			gen3_led            : out std_logic;                                         -- gen3_led
			lane_active_led     : out std_logic_vector(3 downto 0);                      -- lane_active_led
			req_compliance_pb   : in  std_logic                      := 'X';             -- req_compliance_pb
			set_compliance_mode : in  std_logic                      := 'X'              -- set_compliance_mode
		);
	end component top_dk;

	u0 : component top_dk
		port map (
			clk                 => CONNECTED_TO_clk,                 --    clock.clk
			devkit_ctrl         => CONNECTED_TO_devkit_ctrl,         --   dk_hip.devkit_ctrl
			devkit_status       => CONNECTED_TO_devkit_status,       --         .devkit_status
			L0_led              => CONNECTED_TO_L0_led,              -- dk_board.L0_led
			alive_led           => CONNECTED_TO_alive_led,           --         .alive_led
			comp_led            => CONNECTED_TO_comp_led,            --         .comp_led
			free_clk            => CONNECTED_TO_free_clk,            --         .free_clk
			gen2_led            => CONNECTED_TO_gen2_led,            --         .gen2_led
			gen3_led            => CONNECTED_TO_gen3_led,            --         .gen3_led
			lane_active_led     => CONNECTED_TO_lane_active_led,     --         .lane_active_led
			req_compliance_pb   => CONNECTED_TO_req_compliance_pb,   --         .req_compliance_pb
			set_compliance_mode => CONNECTED_TO_set_compliance_mode  --         .set_compliance_mode
		);

