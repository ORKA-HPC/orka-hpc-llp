	component emif_avmm_interface_reset_in is
		port (
			in_reset_n  : in  std_logic := 'X'; -- reset_n
			out_reset_n : out std_logic         -- reset_n
		);
	end component emif_avmm_interface_reset_in;

	u0 : component emif_avmm_interface_reset_in
		port map (
			in_reset_n  => CONNECTED_TO_in_reset_n,  --  in_reset.reset_n
			out_reset_n => CONNECTED_TO_out_reset_n  -- out_reset.reset_n
		);

