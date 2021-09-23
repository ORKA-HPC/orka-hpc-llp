	component emif_avmm_interface is
		port (
			emif_clk                         : in  std_logic                      := 'X';             -- clk
			usr_reset_n                      : in  std_logic                      := 'X';             -- reset_n
			global_reset                     : in  std_logic                      := 'X';             -- reset
			pr_region_clk                    : in  std_logic                      := 'X';             -- clk
			pr_to_emif_avmm_s0_waitrequest   : out std_logic;                                         -- waitrequest
			pr_to_emif_avmm_s0_readdata      : out std_logic_vector(511 downto 0);                    -- readdata
			pr_to_emif_avmm_s0_readdatavalid : out std_logic;                                         -- readdatavalid
			pr_to_emif_avmm_s0_burstcount    : in  std_logic_vector(6 downto 0)   := (others => 'X'); -- burstcount
			pr_to_emif_avmm_s0_writedata     : in  std_logic_vector(511 downto 0) := (others => 'X'); -- writedata
			pr_to_emif_avmm_s0_address       : in  std_logic_vector(24 downto 0)  := (others => 'X'); -- address
			pr_to_emif_avmm_s0_write         : in  std_logic                      := 'X';             -- write
			pr_to_emif_avmm_s0_read          : in  std_logic                      := 'X';             -- read
			pr_to_emif_avmm_s0_byteenable    : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- byteenable
			pr_to_emif_avmm_s0_debugaccess   : in  std_logic                      := 'X';             -- debugaccess
			pr_to_emif_avmm_m0_waitrequest   : in  std_logic                      := 'X';             -- waitrequest
			pr_to_emif_avmm_m0_readdata      : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			pr_to_emif_avmm_m0_readdatavalid : in  std_logic                      := 'X';             -- readdatavalid
			pr_to_emif_avmm_m0_burstcount    : out std_logic_vector(6 downto 0);                      -- burstcount
			pr_to_emif_avmm_m0_writedata     : out std_logic_vector(511 downto 0);                    -- writedata
			pr_to_emif_avmm_m0_address       : out std_logic_vector(24 downto 0);                     -- address
			pr_to_emif_avmm_m0_write         : out std_logic;                                         -- write
			pr_to_emif_avmm_m0_read          : out std_logic;                                         -- read
			pr_to_emif_avmm_m0_byteenable    : out std_logic_vector(63 downto 0);                     -- byteenable
			pr_to_emif_avmm_m0_debugaccess   : out std_logic                                          -- debugaccess
		);
	end component emif_avmm_interface;

	u0 : component emif_avmm_interface
		port map (
			emif_clk                         => CONNECTED_TO_emif_clk,                         --               emif.clk
			usr_reset_n                      => CONNECTED_TO_usr_reset_n,                      --                usr.reset_n
			global_reset                     => CONNECTED_TO_global_reset,                     --             global.reset
			pr_region_clk                    => CONNECTED_TO_pr_region_clk,                    --          pr_region.clk
			pr_to_emif_avmm_s0_waitrequest   => CONNECTED_TO_pr_to_emif_avmm_s0_waitrequest,   -- pr_to_emif_avmm_s0.waitrequest
			pr_to_emif_avmm_s0_readdata      => CONNECTED_TO_pr_to_emif_avmm_s0_readdata,      --                   .readdata
			pr_to_emif_avmm_s0_readdatavalid => CONNECTED_TO_pr_to_emif_avmm_s0_readdatavalid, --                   .readdatavalid
			pr_to_emif_avmm_s0_burstcount    => CONNECTED_TO_pr_to_emif_avmm_s0_burstcount,    --                   .burstcount
			pr_to_emif_avmm_s0_writedata     => CONNECTED_TO_pr_to_emif_avmm_s0_writedata,     --                   .writedata
			pr_to_emif_avmm_s0_address       => CONNECTED_TO_pr_to_emif_avmm_s0_address,       --                   .address
			pr_to_emif_avmm_s0_write         => CONNECTED_TO_pr_to_emif_avmm_s0_write,         --                   .write
			pr_to_emif_avmm_s0_read          => CONNECTED_TO_pr_to_emif_avmm_s0_read,          --                   .read
			pr_to_emif_avmm_s0_byteenable    => CONNECTED_TO_pr_to_emif_avmm_s0_byteenable,    --                   .byteenable
			pr_to_emif_avmm_s0_debugaccess   => CONNECTED_TO_pr_to_emif_avmm_s0_debugaccess,   --                   .debugaccess
			pr_to_emif_avmm_m0_waitrequest   => CONNECTED_TO_pr_to_emif_avmm_m0_waitrequest,   -- pr_to_emif_avmm_m0.waitrequest
			pr_to_emif_avmm_m0_readdata      => CONNECTED_TO_pr_to_emif_avmm_m0_readdata,      --                   .readdata
			pr_to_emif_avmm_m0_readdatavalid => CONNECTED_TO_pr_to_emif_avmm_m0_readdatavalid, --                   .readdatavalid
			pr_to_emif_avmm_m0_burstcount    => CONNECTED_TO_pr_to_emif_avmm_m0_burstcount,    --                   .burstcount
			pr_to_emif_avmm_m0_writedata     => CONNECTED_TO_pr_to_emif_avmm_m0_writedata,     --                   .writedata
			pr_to_emif_avmm_m0_address       => CONNECTED_TO_pr_to_emif_avmm_m0_address,       --                   .address
			pr_to_emif_avmm_m0_write         => CONNECTED_TO_pr_to_emif_avmm_m0_write,         --                   .write
			pr_to_emif_avmm_m0_read          => CONNECTED_TO_pr_to_emif_avmm_m0_read,          --                   .read
			pr_to_emif_avmm_m0_byteenable    => CONNECTED_TO_pr_to_emif_avmm_m0_byteenable,    --                   .byteenable
			pr_to_emif_avmm_m0_debugaccess   => CONNECTED_TO_pr_to_emif_avmm_m0_debugaccess    --                   .debugaccess
		);

