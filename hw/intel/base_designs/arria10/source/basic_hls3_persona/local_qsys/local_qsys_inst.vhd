	component local_qsys is
		port (
			avs_ctrl_waitrequest    : out std_logic;                                         -- waitrequest
			avs_ctrl_readdata       : out std_logic_vector(63 downto 0);                     -- readdata
			avs_ctrl_readdatavalid  : out std_logic;                                         -- readdatavalid
			avs_ctrl_burstcount     : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- burstcount
			avs_ctrl_writedata      : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			avs_ctrl_address        : in  std_logic_vector(15 downto 0)  := (others => 'X'); -- address
			avs_ctrl_write          : in  std_logic                      := 'X';             -- write
			avs_ctrl_read           : in  std_logic                      := 'X';             -- read
			avs_ctrl_byteenable     : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- byteenable
			avs_ctrl_debugaccess    : in  std_logic                      := 'X';             -- debugaccess
			clk_clk                 : in  std_logic                      := 'X';             -- clk
			emif_clk_clk            : in  std_logic                      := 'X';             -- clk
			avm_emif_waitrequest    : in  std_logic                      := 'X';             -- waitrequest
			avm_emif_readdata       : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			avm_emif_readdatavalid  : in  std_logic                      := 'X';             -- readdatavalid
			avm_emif_burstcount     : out std_logic_vector(4 downto 0);                      -- burstcount
			avm_emif_writedata      : out std_logic_vector(511 downto 0);                    -- writedata
			avm_emif_address        : out std_logic_vector(30 downto 0);                     -- address
			avm_emif_write          : out std_logic;                                         -- write
			avm_emif_read           : out std_logic;                                         -- read
			avm_emif_byteenable     : out std_logic_vector(63 downto 0);                     -- byteenable
			avm_emif_debugaccess    : out std_logic;                                         -- debugaccess
			pr_handshake_start_req  : in  std_logic                      := 'X';             -- start_req
			pr_handshake_start_ack  : out std_logic;                                         -- start_ack
			pr_handshake_stop_req   : in  std_logic                      := 'X';             -- stop_req
			pr_handshake_stop_ack   : out std_logic;                                         -- stop_ack
			reset_reset_n           : in  std_logic                      := 'X';             -- reset_n
			reset_emif_reset_n      : in  std_logic                      := 'X';             -- reset_n
			sld_jtag_bridge_tck     : in  std_logic                      := 'X';             -- tck
			sld_jtag_bridge_tms     : in  std_logic                      := 'X';             -- tms
			sld_jtag_bridge_tdi     : in  std_logic                      := 'X';             -- tdi
			sld_jtag_bridge_vir_tdi : in  std_logic                      := 'X';             -- vir_tdi
			sld_jtag_bridge_ena     : in  std_logic                      := 'X';             -- ena
			sld_jtag_bridge_tdo     : out std_logic                                          -- tdo
		);
	end component local_qsys;

	u0 : component local_qsys
		port map (
			avs_ctrl_waitrequest    => CONNECTED_TO_avs_ctrl_waitrequest,    --        avs_ctrl.waitrequest
			avs_ctrl_readdata       => CONNECTED_TO_avs_ctrl_readdata,       --                .readdata
			avs_ctrl_readdatavalid  => CONNECTED_TO_avs_ctrl_readdatavalid,  --                .readdatavalid
			avs_ctrl_burstcount     => CONNECTED_TO_avs_ctrl_burstcount,     --                .burstcount
			avs_ctrl_writedata      => CONNECTED_TO_avs_ctrl_writedata,      --                .writedata
			avs_ctrl_address        => CONNECTED_TO_avs_ctrl_address,        --                .address
			avs_ctrl_write          => CONNECTED_TO_avs_ctrl_write,          --                .write
			avs_ctrl_read           => CONNECTED_TO_avs_ctrl_read,           --                .read
			avs_ctrl_byteenable     => CONNECTED_TO_avs_ctrl_byteenable,     --                .byteenable
			avs_ctrl_debugaccess    => CONNECTED_TO_avs_ctrl_debugaccess,    --                .debugaccess
			clk_clk                 => CONNECTED_TO_clk_clk,                 --             clk.clk
			emif_clk_clk            => CONNECTED_TO_emif_clk_clk,            --        emif_clk.clk
			avm_emif_waitrequest    => CONNECTED_TO_avm_emif_waitrequest,    --        avm_emif.waitrequest
			avm_emif_readdata       => CONNECTED_TO_avm_emif_readdata,       --                .readdata
			avm_emif_readdatavalid  => CONNECTED_TO_avm_emif_readdatavalid,  --                .readdatavalid
			avm_emif_burstcount     => CONNECTED_TO_avm_emif_burstcount,     --                .burstcount
			avm_emif_writedata      => CONNECTED_TO_avm_emif_writedata,      --                .writedata
			avm_emif_address        => CONNECTED_TO_avm_emif_address,        --                .address
			avm_emif_write          => CONNECTED_TO_avm_emif_write,          --                .write
			avm_emif_read           => CONNECTED_TO_avm_emif_read,           --                .read
			avm_emif_byteenable     => CONNECTED_TO_avm_emif_byteenable,     --                .byteenable
			avm_emif_debugaccess    => CONNECTED_TO_avm_emif_debugaccess,    --                .debugaccess
			pr_handshake_start_req  => CONNECTED_TO_pr_handshake_start_req,  --    pr_handshake.start_req
			pr_handshake_start_ack  => CONNECTED_TO_pr_handshake_start_ack,  --                .start_ack
			pr_handshake_stop_req   => CONNECTED_TO_pr_handshake_stop_req,   --                .stop_req
			pr_handshake_stop_ack   => CONNECTED_TO_pr_handshake_stop_ack,   --                .stop_ack
			reset_reset_n           => CONNECTED_TO_reset_reset_n,           --           reset.reset_n
			reset_emif_reset_n      => CONNECTED_TO_reset_emif_reset_n,      --      reset_emif.reset_n
			sld_jtag_bridge_tck     => CONNECTED_TO_sld_jtag_bridge_tck,     -- sld_jtag_bridge.tck
			sld_jtag_bridge_tms     => CONNECTED_TO_sld_jtag_bridge_tms,     --                .tms
			sld_jtag_bridge_tdi     => CONNECTED_TO_sld_jtag_bridge_tdi,     --                .tdi
			sld_jtag_bridge_vir_tdi => CONNECTED_TO_sld_jtag_bridge_vir_tdi, --                .vir_tdi
			sld_jtag_bridge_ena     => CONNECTED_TO_sld_jtag_bridge_ena,     --                .ena
			sld_jtag_bridge_tdo     => CONNECTED_TO_sld_jtag_bridge_tdo      --                .tdo
		);

