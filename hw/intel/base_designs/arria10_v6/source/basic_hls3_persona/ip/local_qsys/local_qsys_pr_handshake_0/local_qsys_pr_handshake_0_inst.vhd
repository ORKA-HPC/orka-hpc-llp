	component local_qsys_pr_handshake_0 is
		port (
			clk                    : in  std_logic := 'X'; -- clk
			rst                    : in  std_logic := 'X'; -- reset
			pr_handshake_start_req : in  std_logic := 'X'; -- start_req
			pr_handshake_start_ack : out std_logic;        -- start_ack
			pr_handshake_stop_req  : in  std_logic := 'X'; -- stop_req
			pr_handshake_stop_ack  : out std_logic         -- stop_ack
		);
	end component local_qsys_pr_handshake_0;

	u0 : component local_qsys_pr_handshake_0
		port map (
			clk                    => CONNECTED_TO_clk,                    --        clock.clk
			rst                    => CONNECTED_TO_rst,                    --   reset_sink.reset
			pr_handshake_start_req => CONNECTED_TO_pr_handshake_start_req, -- pr_handshake.start_req
			pr_handshake_start_ack => CONNECTED_TO_pr_handshake_start_ack, --             .start_ack
			pr_handshake_stop_req  => CONNECTED_TO_pr_handshake_stop_req,  --             .stop_req
			pr_handshake_stop_ack  => CONNECTED_TO_pr_handshake_stop_ack   --             .stop_ack
		);

