	component local_qsys_slavereg_comp_internal_0 is
		port (
			clock                   : in  std_logic                      := 'X';             -- clk
			resetn                  : in  std_logic                      := 'X';             -- reset_n
			done_irq                : out std_logic;                                         -- irq
			avmm_1_rw_address       : out std_logic_vector(31 downto 0);                     -- address
			avmm_1_rw_byteenable    : out std_logic_vector(63 downto 0);                     -- byteenable
			avmm_1_rw_readdatavalid : in  std_logic                      := 'X';             -- readdatavalid
			avmm_1_rw_read          : out std_logic;                                         -- read
			avmm_1_rw_readdata      : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			avmm_1_rw_write         : out std_logic;                                         -- write
			avmm_1_rw_writedata     : out std_logic_vector(511 downto 0);                    -- writedata
			avmm_1_rw_waitrequest   : in  std_logic                      := 'X';             -- waitrequest
			avmm_1_rw_burstcount    : out std_logic_vector(4 downto 0);                      -- burstcount
			avs_cra_read            : in  std_logic                      := 'X';             -- read
			avs_cra_readdata        : out std_logic_vector(63 downto 0);                     -- readdata
			avs_cra_write           : in  std_logic                      := 'X';             -- write
			avs_cra_writedata       : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			avs_cra_address         : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- address
			avs_cra_byteenable      : in  std_logic_vector(7 downto 0)   := (others => 'X')  -- byteenable
		);
	end component local_qsys_slavereg_comp_internal_0;

	u0 : component local_qsys_slavereg_comp_internal_0
		port map (
			clock                   => CONNECTED_TO_clock,                   --     clock.clk
			resetn                  => CONNECTED_TO_resetn,                  --     reset.reset_n
			done_irq                => CONNECTED_TO_done_irq,                --       irq.irq
			avmm_1_rw_address       => CONNECTED_TO_avmm_1_rw_address,       -- avmm_1_rw.address
			avmm_1_rw_byteenable    => CONNECTED_TO_avmm_1_rw_byteenable,    --          .byteenable
			avmm_1_rw_readdatavalid => CONNECTED_TO_avmm_1_rw_readdatavalid, --          .readdatavalid
			avmm_1_rw_read          => CONNECTED_TO_avmm_1_rw_read,          --          .read
			avmm_1_rw_readdata      => CONNECTED_TO_avmm_1_rw_readdata,      --          .readdata
			avmm_1_rw_write         => CONNECTED_TO_avmm_1_rw_write,         --          .write
			avmm_1_rw_writedata     => CONNECTED_TO_avmm_1_rw_writedata,     --          .writedata
			avmm_1_rw_waitrequest   => CONNECTED_TO_avmm_1_rw_waitrequest,   --          .waitrequest
			avmm_1_rw_burstcount    => CONNECTED_TO_avmm_1_rw_burstcount,    --          .burstcount
			avs_cra_read            => CONNECTED_TO_avs_cra_read,            --   avs_cra.read
			avs_cra_readdata        => CONNECTED_TO_avs_cra_readdata,        --          .readdata
			avs_cra_write           => CONNECTED_TO_avs_cra_write,           --          .write
			avs_cra_writedata       => CONNECTED_TO_avs_cra_writedata,       --          .writedata
			avs_cra_address         => CONNECTED_TO_avs_cra_address,         --          .address
			avs_cra_byteenable      => CONNECTED_TO_avs_cra_byteenable       --          .byteenable
		);

