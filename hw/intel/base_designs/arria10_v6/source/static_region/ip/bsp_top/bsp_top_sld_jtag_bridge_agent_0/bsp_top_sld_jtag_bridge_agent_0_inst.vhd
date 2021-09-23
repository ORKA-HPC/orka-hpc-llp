	component bsp_top_sld_jtag_bridge_agent_0 is
		port (
			tck     : out std_logic;        -- tck
			tms     : out std_logic;        -- tms
			tdi     : out std_logic;        -- tdi
			vir_tdi : out std_logic;        -- vir_tdi
			ena     : out std_logic;        -- ena
			tdo     : in  std_logic := 'X'  -- tdo
		);
	end component bsp_top_sld_jtag_bridge_agent_0;

	u0 : component bsp_top_sld_jtag_bridge_agent_0
		port map (
			tck     => CONNECTED_TO_tck,     -- connect_to_bridge_host.tck
			tms     => CONNECTED_TO_tms,     --                       .tms
			tdi     => CONNECTED_TO_tdi,     --                       .tdi
			vir_tdi => CONNECTED_TO_vir_tdi, --                       .vir_tdi
			ena     => CONNECTED_TO_ena,     --                       .ena
			tdo     => CONNECTED_TO_tdo      --                       .tdo
		);

