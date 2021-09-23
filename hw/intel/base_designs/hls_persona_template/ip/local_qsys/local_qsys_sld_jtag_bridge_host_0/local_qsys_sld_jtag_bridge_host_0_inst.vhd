	component local_qsys_sld_jtag_bridge_host_0 is
		port (
			tck     : in  std_logic := 'X'; -- tck
			tms     : in  std_logic := 'X'; -- tms
			tdi     : in  std_logic := 'X'; -- tdi
			vir_tdi : in  std_logic := 'X'; -- vir_tdi
			ena     : in  std_logic := 'X'; -- ena
			tdo     : out std_logic         -- tdo
		);
	end component local_qsys_sld_jtag_bridge_host_0;

	u0 : component local_qsys_sld_jtag_bridge_host_0
		port map (
			tck     => CONNECTED_TO_tck,     -- connect_to_bridge_host.tck
			tms     => CONNECTED_TO_tms,     --                       .tms
			tdi     => CONNECTED_TO_tdi,     --                       .tdi
			vir_tdi => CONNECTED_TO_vir_tdi, --                       .vir_tdi
			ena     => CONNECTED_TO_ena,     --                       .ena
			tdo     => CONNECTED_TO_tdo      --                       .tdo
		);

