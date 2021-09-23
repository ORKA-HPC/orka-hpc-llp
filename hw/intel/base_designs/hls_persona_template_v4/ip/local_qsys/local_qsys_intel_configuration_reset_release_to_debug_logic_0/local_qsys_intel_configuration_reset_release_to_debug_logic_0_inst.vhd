	component local_qsys_intel_configuration_reset_release_to_debug_logic_0 is
		port (
			conf_reset : in std_logic := 'X'  -- reset
		);
	end component local_qsys_intel_configuration_reset_release_to_debug_logic_0;

	u0 : component local_qsys_intel_configuration_reset_release_to_debug_logic_0
		port map (
			conf_reset => CONNECTED_TO_conf_reset  -- conf_reset_in.reset
		);

