	component bsp_top is
		port (
			a10_pcie_refclk_clk            : in    std_logic                     := 'X';             -- clk
			pcie_rstn_npor                 : in    std_logic                     := 'X';             -- npor
			pcie_rstn_pin_perst            : in    std_logic                     := 'X';             -- pin_perst
			hip_ctrl_test_in               : in    std_logic_vector(31 downto 0) := (others => 'X'); -- test_in
			hip_ctrl_simu_mode_pipe        : in    std_logic                     := 'X';             -- simu_mode_pipe
			pipe_sim_only_sim_pipe_pclk_in : in    std_logic                     := 'X';             -- sim_pipe_pclk_in
			pipe_sim_only_sim_pipe_rate    : out   std_logic_vector(1 downto 0);                     -- sim_pipe_rate
			pipe_sim_only_sim_ltssmstate   : out   std_logic_vector(4 downto 0);                     -- sim_ltssmstate
			pipe_sim_only_eidleinfersel0   : out   std_logic_vector(2 downto 0);                     -- eidleinfersel0
			pipe_sim_only_eidleinfersel1   : out   std_logic_vector(2 downto 0);                     -- eidleinfersel1
			pipe_sim_only_eidleinfersel2   : out   std_logic_vector(2 downto 0);                     -- eidleinfersel2
			pipe_sim_only_eidleinfersel3   : out   std_logic_vector(2 downto 0);                     -- eidleinfersel3
			pipe_sim_only_eidleinfersel4   : out   std_logic_vector(2 downto 0);                     -- eidleinfersel4
			pipe_sim_only_eidleinfersel5   : out   std_logic_vector(2 downto 0);                     -- eidleinfersel5
			pipe_sim_only_eidleinfersel6   : out   std_logic_vector(2 downto 0);                     -- eidleinfersel6
			pipe_sim_only_eidleinfersel7   : out   std_logic_vector(2 downto 0);                     -- eidleinfersel7
			pipe_sim_only_powerdown0       : out   std_logic_vector(1 downto 0);                     -- powerdown0
			pipe_sim_only_powerdown1       : out   std_logic_vector(1 downto 0);                     -- powerdown1
			pipe_sim_only_powerdown2       : out   std_logic_vector(1 downto 0);                     -- powerdown2
			pipe_sim_only_powerdown3       : out   std_logic_vector(1 downto 0);                     -- powerdown3
			pipe_sim_only_powerdown4       : out   std_logic_vector(1 downto 0);                     -- powerdown4
			pipe_sim_only_powerdown5       : out   std_logic_vector(1 downto 0);                     -- powerdown5
			pipe_sim_only_powerdown6       : out   std_logic_vector(1 downto 0);                     -- powerdown6
			pipe_sim_only_powerdown7       : out   std_logic_vector(1 downto 0);                     -- powerdown7
			pipe_sim_only_rxpolarity0      : out   std_logic;                                        -- rxpolarity0
			pipe_sim_only_rxpolarity1      : out   std_logic;                                        -- rxpolarity1
			pipe_sim_only_rxpolarity2      : out   std_logic;                                        -- rxpolarity2
			pipe_sim_only_rxpolarity3      : out   std_logic;                                        -- rxpolarity3
			pipe_sim_only_rxpolarity4      : out   std_logic;                                        -- rxpolarity4
			pipe_sim_only_rxpolarity5      : out   std_logic;                                        -- rxpolarity5
			pipe_sim_only_rxpolarity6      : out   std_logic;                                        -- rxpolarity6
			pipe_sim_only_rxpolarity7      : out   std_logic;                                        -- rxpolarity7
			pipe_sim_only_txcompl0         : out   std_logic;                                        -- txcompl0
			pipe_sim_only_txcompl1         : out   std_logic;                                        -- txcompl1
			pipe_sim_only_txcompl2         : out   std_logic;                                        -- txcompl2
			pipe_sim_only_txcompl3         : out   std_logic;                                        -- txcompl3
			pipe_sim_only_txcompl4         : out   std_logic;                                        -- txcompl4
			pipe_sim_only_txcompl5         : out   std_logic;                                        -- txcompl5
			pipe_sim_only_txcompl6         : out   std_logic;                                        -- txcompl6
			pipe_sim_only_txcompl7         : out   std_logic;                                        -- txcompl7
			pipe_sim_only_txdata0          : out   std_logic_vector(31 downto 0);                    -- txdata0
			pipe_sim_only_txdata1          : out   std_logic_vector(31 downto 0);                    -- txdata1
			pipe_sim_only_txdata2          : out   std_logic_vector(31 downto 0);                    -- txdata2
			pipe_sim_only_txdata3          : out   std_logic_vector(31 downto 0);                    -- txdata3
			pipe_sim_only_txdata4          : out   std_logic_vector(31 downto 0);                    -- txdata4
			pipe_sim_only_txdata5          : out   std_logic_vector(31 downto 0);                    -- txdata5
			pipe_sim_only_txdata6          : out   std_logic_vector(31 downto 0);                    -- txdata6
			pipe_sim_only_txdata7          : out   std_logic_vector(31 downto 0);                    -- txdata7
			pipe_sim_only_txdatak0         : out   std_logic_vector(3 downto 0);                     -- txdatak0
			pipe_sim_only_txdatak1         : out   std_logic_vector(3 downto 0);                     -- txdatak1
			pipe_sim_only_txdatak2         : out   std_logic_vector(3 downto 0);                     -- txdatak2
			pipe_sim_only_txdatak3         : out   std_logic_vector(3 downto 0);                     -- txdatak3
			pipe_sim_only_txdatak4         : out   std_logic_vector(3 downto 0);                     -- txdatak4
			pipe_sim_only_txdatak5         : out   std_logic_vector(3 downto 0);                     -- txdatak5
			pipe_sim_only_txdatak6         : out   std_logic_vector(3 downto 0);                     -- txdatak6
			pipe_sim_only_txdatak7         : out   std_logic_vector(3 downto 0);                     -- txdatak7
			pipe_sim_only_txdetectrx0      : out   std_logic;                                        -- txdetectrx0
			pipe_sim_only_txdetectrx1      : out   std_logic;                                        -- txdetectrx1
			pipe_sim_only_txdetectrx2      : out   std_logic;                                        -- txdetectrx2
			pipe_sim_only_txdetectrx3      : out   std_logic;                                        -- txdetectrx3
			pipe_sim_only_txdetectrx4      : out   std_logic;                                        -- txdetectrx4
			pipe_sim_only_txdetectrx5      : out   std_logic;                                        -- txdetectrx5
			pipe_sim_only_txdetectrx6      : out   std_logic;                                        -- txdetectrx6
			pipe_sim_only_txdetectrx7      : out   std_logic;                                        -- txdetectrx7
			pipe_sim_only_txelecidle0      : out   std_logic;                                        -- txelecidle0
			pipe_sim_only_txelecidle1      : out   std_logic;                                        -- txelecidle1
			pipe_sim_only_txelecidle2      : out   std_logic;                                        -- txelecidle2
			pipe_sim_only_txelecidle3      : out   std_logic;                                        -- txelecidle3
			pipe_sim_only_txelecidle4      : out   std_logic;                                        -- txelecidle4
			pipe_sim_only_txelecidle5      : out   std_logic;                                        -- txelecidle5
			pipe_sim_only_txelecidle6      : out   std_logic;                                        -- txelecidle6
			pipe_sim_only_txelecidle7      : out   std_logic;                                        -- txelecidle7
			pipe_sim_only_txdeemph0        : out   std_logic;                                        -- txdeemph0
			pipe_sim_only_txdeemph1        : out   std_logic;                                        -- txdeemph1
			pipe_sim_only_txdeemph2        : out   std_logic;                                        -- txdeemph2
			pipe_sim_only_txdeemph3        : out   std_logic;                                        -- txdeemph3
			pipe_sim_only_txdeemph4        : out   std_logic;                                        -- txdeemph4
			pipe_sim_only_txdeemph5        : out   std_logic;                                        -- txdeemph5
			pipe_sim_only_txdeemph6        : out   std_logic;                                        -- txdeemph6
			pipe_sim_only_txdeemph7        : out   std_logic;                                        -- txdeemph7
			pipe_sim_only_txmargin0        : out   std_logic_vector(2 downto 0);                     -- txmargin0
			pipe_sim_only_txmargin1        : out   std_logic_vector(2 downto 0);                     -- txmargin1
			pipe_sim_only_txmargin2        : out   std_logic_vector(2 downto 0);                     -- txmargin2
			pipe_sim_only_txmargin3        : out   std_logic_vector(2 downto 0);                     -- txmargin3
			pipe_sim_only_txmargin4        : out   std_logic_vector(2 downto 0);                     -- txmargin4
			pipe_sim_only_txmargin5        : out   std_logic_vector(2 downto 0);                     -- txmargin5
			pipe_sim_only_txmargin6        : out   std_logic_vector(2 downto 0);                     -- txmargin6
			pipe_sim_only_txmargin7        : out   std_logic_vector(2 downto 0);                     -- txmargin7
			pipe_sim_only_txswing0         : out   std_logic;                                        -- txswing0
			pipe_sim_only_txswing1         : out   std_logic;                                        -- txswing1
			pipe_sim_only_txswing2         : out   std_logic;                                        -- txswing2
			pipe_sim_only_txswing3         : out   std_logic;                                        -- txswing3
			pipe_sim_only_txswing4         : out   std_logic;                                        -- txswing4
			pipe_sim_only_txswing5         : out   std_logic;                                        -- txswing5
			pipe_sim_only_txswing6         : out   std_logic;                                        -- txswing6
			pipe_sim_only_txswing7         : out   std_logic;                                        -- txswing7
			pipe_sim_only_phystatus0       : in    std_logic                     := 'X';             -- phystatus0
			pipe_sim_only_phystatus1       : in    std_logic                     := 'X';             -- phystatus1
			pipe_sim_only_phystatus2       : in    std_logic                     := 'X';             -- phystatus2
			pipe_sim_only_phystatus3       : in    std_logic                     := 'X';             -- phystatus3
			pipe_sim_only_phystatus4       : in    std_logic                     := 'X';             -- phystatus4
			pipe_sim_only_phystatus5       : in    std_logic                     := 'X';             -- phystatus5
			pipe_sim_only_phystatus6       : in    std_logic                     := 'X';             -- phystatus6
			pipe_sim_only_phystatus7       : in    std_logic                     := 'X';             -- phystatus7
			pipe_sim_only_rxdata0          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- rxdata0
			pipe_sim_only_rxdata1          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- rxdata1
			pipe_sim_only_rxdata2          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- rxdata2
			pipe_sim_only_rxdata3          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- rxdata3
			pipe_sim_only_rxdata4          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- rxdata4
			pipe_sim_only_rxdata5          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- rxdata5
			pipe_sim_only_rxdata6          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- rxdata6
			pipe_sim_only_rxdata7          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- rxdata7
			pipe_sim_only_rxdatak0         : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- rxdatak0
			pipe_sim_only_rxdatak1         : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- rxdatak1
			pipe_sim_only_rxdatak2         : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- rxdatak2
			pipe_sim_only_rxdatak3         : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- rxdatak3
			pipe_sim_only_rxdatak4         : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- rxdatak4
			pipe_sim_only_rxdatak5         : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- rxdatak5
			pipe_sim_only_rxdatak6         : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- rxdatak6
			pipe_sim_only_rxdatak7         : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- rxdatak7
			pipe_sim_only_rxelecidle0      : in    std_logic                     := 'X';             -- rxelecidle0
			pipe_sim_only_rxelecidle1      : in    std_logic                     := 'X';             -- rxelecidle1
			pipe_sim_only_rxelecidle2      : in    std_logic                     := 'X';             -- rxelecidle2
			pipe_sim_only_rxelecidle3      : in    std_logic                     := 'X';             -- rxelecidle3
			pipe_sim_only_rxelecidle4      : in    std_logic                     := 'X';             -- rxelecidle4
			pipe_sim_only_rxelecidle5      : in    std_logic                     := 'X';             -- rxelecidle5
			pipe_sim_only_rxelecidle6      : in    std_logic                     := 'X';             -- rxelecidle6
			pipe_sim_only_rxelecidle7      : in    std_logic                     := 'X';             -- rxelecidle7
			pipe_sim_only_rxstatus0        : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus0
			pipe_sim_only_rxstatus1        : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus1
			pipe_sim_only_rxstatus2        : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus2
			pipe_sim_only_rxstatus3        : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus3
			pipe_sim_only_rxstatus4        : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus4
			pipe_sim_only_rxstatus5        : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus5
			pipe_sim_only_rxstatus6        : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus6
			pipe_sim_only_rxstatus7        : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus7
			pipe_sim_only_rxvalid0         : in    std_logic                     := 'X';             -- rxvalid0
			pipe_sim_only_rxvalid1         : in    std_logic                     := 'X';             -- rxvalid1
			pipe_sim_only_rxvalid2         : in    std_logic                     := 'X';             -- rxvalid2
			pipe_sim_only_rxvalid3         : in    std_logic                     := 'X';             -- rxvalid3
			pipe_sim_only_rxvalid4         : in    std_logic                     := 'X';             -- rxvalid4
			pipe_sim_only_rxvalid5         : in    std_logic                     := 'X';             -- rxvalid5
			pipe_sim_only_rxvalid6         : in    std_logic                     := 'X';             -- rxvalid6
			pipe_sim_only_rxvalid7         : in    std_logic                     := 'X';             -- rxvalid7
			pipe_sim_only_rxdataskip0      : in    std_logic                     := 'X';             -- rxdataskip0
			pipe_sim_only_rxdataskip1      : in    std_logic                     := 'X';             -- rxdataskip1
			pipe_sim_only_rxdataskip2      : in    std_logic                     := 'X';             -- rxdataskip2
			pipe_sim_only_rxdataskip3      : in    std_logic                     := 'X';             -- rxdataskip3
			pipe_sim_only_rxdataskip4      : in    std_logic                     := 'X';             -- rxdataskip4
			pipe_sim_only_rxdataskip5      : in    std_logic                     := 'X';             -- rxdataskip5
			pipe_sim_only_rxdataskip6      : in    std_logic                     := 'X';             -- rxdataskip6
			pipe_sim_only_rxdataskip7      : in    std_logic                     := 'X';             -- rxdataskip7
			pipe_sim_only_rxblkst0         : in    std_logic                     := 'X';             -- rxblkst0
			pipe_sim_only_rxblkst1         : in    std_logic                     := 'X';             -- rxblkst1
			pipe_sim_only_rxblkst2         : in    std_logic                     := 'X';             -- rxblkst2
			pipe_sim_only_rxblkst3         : in    std_logic                     := 'X';             -- rxblkst3
			pipe_sim_only_rxblkst4         : in    std_logic                     := 'X';             -- rxblkst4
			pipe_sim_only_rxblkst5         : in    std_logic                     := 'X';             -- rxblkst5
			pipe_sim_only_rxblkst6         : in    std_logic                     := 'X';             -- rxblkst6
			pipe_sim_only_rxblkst7         : in    std_logic                     := 'X';             -- rxblkst7
			pipe_sim_only_rxsynchd0        : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- rxsynchd0
			pipe_sim_only_rxsynchd1        : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- rxsynchd1
			pipe_sim_only_rxsynchd2        : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- rxsynchd2
			pipe_sim_only_rxsynchd3        : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- rxsynchd3
			pipe_sim_only_rxsynchd4        : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- rxsynchd4
			pipe_sim_only_rxsynchd5        : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- rxsynchd5
			pipe_sim_only_rxsynchd6        : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- rxsynchd6
			pipe_sim_only_rxsynchd7        : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- rxsynchd7
			pipe_sim_only_currentcoeff0    : out   std_logic_vector(17 downto 0);                    -- currentcoeff0
			pipe_sim_only_currentcoeff1    : out   std_logic_vector(17 downto 0);                    -- currentcoeff1
			pipe_sim_only_currentcoeff2    : out   std_logic_vector(17 downto 0);                    -- currentcoeff2
			pipe_sim_only_currentcoeff3    : out   std_logic_vector(17 downto 0);                    -- currentcoeff3
			pipe_sim_only_currentcoeff4    : out   std_logic_vector(17 downto 0);                    -- currentcoeff4
			pipe_sim_only_currentcoeff5    : out   std_logic_vector(17 downto 0);                    -- currentcoeff5
			pipe_sim_only_currentcoeff6    : out   std_logic_vector(17 downto 0);                    -- currentcoeff6
			pipe_sim_only_currentcoeff7    : out   std_logic_vector(17 downto 0);                    -- currentcoeff7
			pipe_sim_only_currentrxpreset0 : out   std_logic_vector(2 downto 0);                     -- currentrxpreset0
			pipe_sim_only_currentrxpreset1 : out   std_logic_vector(2 downto 0);                     -- currentrxpreset1
			pipe_sim_only_currentrxpreset2 : out   std_logic_vector(2 downto 0);                     -- currentrxpreset2
			pipe_sim_only_currentrxpreset3 : out   std_logic_vector(2 downto 0);                     -- currentrxpreset3
			pipe_sim_only_currentrxpreset4 : out   std_logic_vector(2 downto 0);                     -- currentrxpreset4
			pipe_sim_only_currentrxpreset5 : out   std_logic_vector(2 downto 0);                     -- currentrxpreset5
			pipe_sim_only_currentrxpreset6 : out   std_logic_vector(2 downto 0);                     -- currentrxpreset6
			pipe_sim_only_currentrxpreset7 : out   std_logic_vector(2 downto 0);                     -- currentrxpreset7
			pipe_sim_only_txsynchd0        : out   std_logic_vector(1 downto 0);                     -- txsynchd0
			pipe_sim_only_txsynchd1        : out   std_logic_vector(1 downto 0);                     -- txsynchd1
			pipe_sim_only_txsynchd2        : out   std_logic_vector(1 downto 0);                     -- txsynchd2
			pipe_sim_only_txsynchd3        : out   std_logic_vector(1 downto 0);                     -- txsynchd3
			pipe_sim_only_txsynchd4        : out   std_logic_vector(1 downto 0);                     -- txsynchd4
			pipe_sim_only_txsynchd5        : out   std_logic_vector(1 downto 0);                     -- txsynchd5
			pipe_sim_only_txsynchd6        : out   std_logic_vector(1 downto 0);                     -- txsynchd6
			pipe_sim_only_txsynchd7        : out   std_logic_vector(1 downto 0);                     -- txsynchd7
			pipe_sim_only_txblkst0         : out   std_logic;                                        -- txblkst0
			pipe_sim_only_txblkst1         : out   std_logic;                                        -- txblkst1
			pipe_sim_only_txblkst2         : out   std_logic;                                        -- txblkst2
			pipe_sim_only_txblkst3         : out   std_logic;                                        -- txblkst3
			pipe_sim_only_txblkst4         : out   std_logic;                                        -- txblkst4
			pipe_sim_only_txblkst5         : out   std_logic;                                        -- txblkst5
			pipe_sim_only_txblkst6         : out   std_logic;                                        -- txblkst6
			pipe_sim_only_txblkst7         : out   std_logic;                                        -- txblkst7
			pipe_sim_only_txdataskip0      : out   std_logic;                                        -- txdataskip0
			pipe_sim_only_txdataskip1      : out   std_logic;                                        -- txdataskip1
			pipe_sim_only_txdataskip2      : out   std_logic;                                        -- txdataskip2
			pipe_sim_only_txdataskip3      : out   std_logic;                                        -- txdataskip3
			pipe_sim_only_txdataskip4      : out   std_logic;                                        -- txdataskip4
			pipe_sim_only_txdataskip5      : out   std_logic;                                        -- txdataskip5
			pipe_sim_only_txdataskip6      : out   std_logic;                                        -- txdataskip6
			pipe_sim_only_txdataskip7      : out   std_logic;                                        -- txdataskip7
			pipe_sim_only_rate0            : out   std_logic_vector(1 downto 0);                     -- rate0
			pipe_sim_only_rate1            : out   std_logic_vector(1 downto 0);                     -- rate1
			pipe_sim_only_rate2            : out   std_logic_vector(1 downto 0);                     -- rate2
			pipe_sim_only_rate3            : out   std_logic_vector(1 downto 0);                     -- rate3
			pipe_sim_only_rate4            : out   std_logic_vector(1 downto 0);                     -- rate4
			pipe_sim_only_rate5            : out   std_logic_vector(1 downto 0);                     -- rate5
			pipe_sim_only_rate6            : out   std_logic_vector(1 downto 0);                     -- rate6
			pipe_sim_only_rate7            : out   std_logic_vector(1 downto 0);                     -- rate7
			xcvr_rx_in0                    : in    std_logic                     := 'X';             -- rx_in0
			xcvr_rx_in1                    : in    std_logic                     := 'X';             -- rx_in1
			xcvr_rx_in2                    : in    std_logic                     := 'X';             -- rx_in2
			xcvr_rx_in3                    : in    std_logic                     := 'X';             -- rx_in3
			xcvr_rx_in4                    : in    std_logic                     := 'X';             -- rx_in4
			xcvr_rx_in5                    : in    std_logic                     := 'X';             -- rx_in5
			xcvr_rx_in6                    : in    std_logic                     := 'X';             -- rx_in6
			xcvr_rx_in7                    : in    std_logic                     := 'X';             -- rx_in7
			xcvr_tx_out0                   : out   std_logic;                                        -- tx_out0
			xcvr_tx_out1                   : out   std_logic;                                        -- tx_out1
			xcvr_tx_out2                   : out   std_logic;                                        -- tx_out2
			xcvr_tx_out3                   : out   std_logic;                                        -- tx_out3
			xcvr_tx_out4                   : out   std_logic;                                        -- tx_out4
			xcvr_tx_out5                   : out   std_logic;                                        -- tx_out5
			xcvr_tx_out6                   : out   std_logic;                                        -- tx_out6
			xcvr_tx_out7                   : out   std_logic;                                        -- tx_out7
			ddr4_pll_ref_clk_clk           : in    std_logic                     := 'X';             -- clk
			ddr4_oct_oct_rzqin             : in    std_logic                     := 'X';             -- oct_rzqin
			ddr4_mem_mem_ck                : out   std_logic_vector(0 downto 0);                     -- mem_ck
			ddr4_mem_mem_ck_n              : out   std_logic_vector(0 downto 0);                     -- mem_ck_n
			ddr4_mem_mem_a                 : out   std_logic_vector(16 downto 0);                    -- mem_a
			ddr4_mem_mem_act_n             : out   std_logic_vector(0 downto 0);                     -- mem_act_n
			ddr4_mem_mem_ba                : out   std_logic_vector(1 downto 0);                     -- mem_ba
			ddr4_mem_mem_bg                : out   std_logic_vector(0 downto 0);                     -- mem_bg
			ddr4_mem_mem_cke               : out   std_logic_vector(0 downto 0);                     -- mem_cke
			ddr4_mem_mem_cs_n              : out   std_logic_vector(0 downto 0);                     -- mem_cs_n
			ddr4_mem_mem_odt               : out   std_logic_vector(0 downto 0);                     -- mem_odt
			ddr4_mem_mem_reset_n           : out   std_logic_vector(0 downto 0);                     -- mem_reset_n
			ddr4_mem_mem_par               : out   std_logic_vector(0 downto 0);                     -- mem_par
			ddr4_mem_mem_alert_n           : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- mem_alert_n
			ddr4_mem_mem_dqs               : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- mem_dqs
			ddr4_mem_mem_dqs_n             : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- mem_dqs_n
			ddr4_mem_mem_dq                : inout std_logic_vector(63 downto 0) := (others => 'X'); -- mem_dq
			ddr4_mem_mem_dbi_n             : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- mem_dbi_n
			board_pins_L0_led              : out   std_logic;                                        -- L0_led
			board_pins_alive_led           : out   std_logic;                                        -- alive_led
			board_pins_comp_led            : out   std_logic;                                        -- comp_led
			board_pins_free_clk            : in    std_logic                     := 'X';             -- free_clk
			board_pins_gen2_led            : out   std_logic;                                        -- gen2_led
			board_pins_gen3_led            : out   std_logic;                                        -- gen3_led
			board_pins_lane_active_led     : out   std_logic_vector(3 downto 0);                     -- lane_active_led
			board_pins_req_compliance_pb   : in    std_logic                     := 'X';             -- req_compliance_pb
			board_pins_set_compliance_mode : in    std_logic                     := 'X';             -- set_compliance_mode
			pll_refclk_clk                 : in    std_logic                     := 'X'              -- clk
		);
	end component bsp_top;

	u0 : component bsp_top
		port map (
			a10_pcie_refclk_clk            => CONNECTED_TO_a10_pcie_refclk_clk,            --  a10_pcie_refclk.clk
			pcie_rstn_npor                 => CONNECTED_TO_pcie_rstn_npor,                 --        pcie_rstn.npor
			pcie_rstn_pin_perst            => CONNECTED_TO_pcie_rstn_pin_perst,            --                 .pin_perst
			hip_ctrl_test_in               => CONNECTED_TO_hip_ctrl_test_in,               --         hip_ctrl.test_in
			hip_ctrl_simu_mode_pipe        => CONNECTED_TO_hip_ctrl_simu_mode_pipe,        --                 .simu_mode_pipe
			pipe_sim_only_sim_pipe_pclk_in => CONNECTED_TO_pipe_sim_only_sim_pipe_pclk_in, --    pipe_sim_only.sim_pipe_pclk_in
			pipe_sim_only_sim_pipe_rate    => CONNECTED_TO_pipe_sim_only_sim_pipe_rate,    --                 .sim_pipe_rate
			pipe_sim_only_sim_ltssmstate   => CONNECTED_TO_pipe_sim_only_sim_ltssmstate,   --                 .sim_ltssmstate
			pipe_sim_only_eidleinfersel0   => CONNECTED_TO_pipe_sim_only_eidleinfersel0,   --                 .eidleinfersel0
			pipe_sim_only_eidleinfersel1   => CONNECTED_TO_pipe_sim_only_eidleinfersel1,   --                 .eidleinfersel1
			pipe_sim_only_eidleinfersel2   => CONNECTED_TO_pipe_sim_only_eidleinfersel2,   --                 .eidleinfersel2
			pipe_sim_only_eidleinfersel3   => CONNECTED_TO_pipe_sim_only_eidleinfersel3,   --                 .eidleinfersel3
			pipe_sim_only_eidleinfersel4   => CONNECTED_TO_pipe_sim_only_eidleinfersel4,   --                 .eidleinfersel4
			pipe_sim_only_eidleinfersel5   => CONNECTED_TO_pipe_sim_only_eidleinfersel5,   --                 .eidleinfersel5
			pipe_sim_only_eidleinfersel6   => CONNECTED_TO_pipe_sim_only_eidleinfersel6,   --                 .eidleinfersel6
			pipe_sim_only_eidleinfersel7   => CONNECTED_TO_pipe_sim_only_eidleinfersel7,   --                 .eidleinfersel7
			pipe_sim_only_powerdown0       => CONNECTED_TO_pipe_sim_only_powerdown0,       --                 .powerdown0
			pipe_sim_only_powerdown1       => CONNECTED_TO_pipe_sim_only_powerdown1,       --                 .powerdown1
			pipe_sim_only_powerdown2       => CONNECTED_TO_pipe_sim_only_powerdown2,       --                 .powerdown2
			pipe_sim_only_powerdown3       => CONNECTED_TO_pipe_sim_only_powerdown3,       --                 .powerdown3
			pipe_sim_only_powerdown4       => CONNECTED_TO_pipe_sim_only_powerdown4,       --                 .powerdown4
			pipe_sim_only_powerdown5       => CONNECTED_TO_pipe_sim_only_powerdown5,       --                 .powerdown5
			pipe_sim_only_powerdown6       => CONNECTED_TO_pipe_sim_only_powerdown6,       --                 .powerdown6
			pipe_sim_only_powerdown7       => CONNECTED_TO_pipe_sim_only_powerdown7,       --                 .powerdown7
			pipe_sim_only_rxpolarity0      => CONNECTED_TO_pipe_sim_only_rxpolarity0,      --                 .rxpolarity0
			pipe_sim_only_rxpolarity1      => CONNECTED_TO_pipe_sim_only_rxpolarity1,      --                 .rxpolarity1
			pipe_sim_only_rxpolarity2      => CONNECTED_TO_pipe_sim_only_rxpolarity2,      --                 .rxpolarity2
			pipe_sim_only_rxpolarity3      => CONNECTED_TO_pipe_sim_only_rxpolarity3,      --                 .rxpolarity3
			pipe_sim_only_rxpolarity4      => CONNECTED_TO_pipe_sim_only_rxpolarity4,      --                 .rxpolarity4
			pipe_sim_only_rxpolarity5      => CONNECTED_TO_pipe_sim_only_rxpolarity5,      --                 .rxpolarity5
			pipe_sim_only_rxpolarity6      => CONNECTED_TO_pipe_sim_only_rxpolarity6,      --                 .rxpolarity6
			pipe_sim_only_rxpolarity7      => CONNECTED_TO_pipe_sim_only_rxpolarity7,      --                 .rxpolarity7
			pipe_sim_only_txcompl0         => CONNECTED_TO_pipe_sim_only_txcompl0,         --                 .txcompl0
			pipe_sim_only_txcompl1         => CONNECTED_TO_pipe_sim_only_txcompl1,         --                 .txcompl1
			pipe_sim_only_txcompl2         => CONNECTED_TO_pipe_sim_only_txcompl2,         --                 .txcompl2
			pipe_sim_only_txcompl3         => CONNECTED_TO_pipe_sim_only_txcompl3,         --                 .txcompl3
			pipe_sim_only_txcompl4         => CONNECTED_TO_pipe_sim_only_txcompl4,         --                 .txcompl4
			pipe_sim_only_txcompl5         => CONNECTED_TO_pipe_sim_only_txcompl5,         --                 .txcompl5
			pipe_sim_only_txcompl6         => CONNECTED_TO_pipe_sim_only_txcompl6,         --                 .txcompl6
			pipe_sim_only_txcompl7         => CONNECTED_TO_pipe_sim_only_txcompl7,         --                 .txcompl7
			pipe_sim_only_txdata0          => CONNECTED_TO_pipe_sim_only_txdata0,          --                 .txdata0
			pipe_sim_only_txdata1          => CONNECTED_TO_pipe_sim_only_txdata1,          --                 .txdata1
			pipe_sim_only_txdata2          => CONNECTED_TO_pipe_sim_only_txdata2,          --                 .txdata2
			pipe_sim_only_txdata3          => CONNECTED_TO_pipe_sim_only_txdata3,          --                 .txdata3
			pipe_sim_only_txdata4          => CONNECTED_TO_pipe_sim_only_txdata4,          --                 .txdata4
			pipe_sim_only_txdata5          => CONNECTED_TO_pipe_sim_only_txdata5,          --                 .txdata5
			pipe_sim_only_txdata6          => CONNECTED_TO_pipe_sim_only_txdata6,          --                 .txdata6
			pipe_sim_only_txdata7          => CONNECTED_TO_pipe_sim_only_txdata7,          --                 .txdata7
			pipe_sim_only_txdatak0         => CONNECTED_TO_pipe_sim_only_txdatak0,         --                 .txdatak0
			pipe_sim_only_txdatak1         => CONNECTED_TO_pipe_sim_only_txdatak1,         --                 .txdatak1
			pipe_sim_only_txdatak2         => CONNECTED_TO_pipe_sim_only_txdatak2,         --                 .txdatak2
			pipe_sim_only_txdatak3         => CONNECTED_TO_pipe_sim_only_txdatak3,         --                 .txdatak3
			pipe_sim_only_txdatak4         => CONNECTED_TO_pipe_sim_only_txdatak4,         --                 .txdatak4
			pipe_sim_only_txdatak5         => CONNECTED_TO_pipe_sim_only_txdatak5,         --                 .txdatak5
			pipe_sim_only_txdatak6         => CONNECTED_TO_pipe_sim_only_txdatak6,         --                 .txdatak6
			pipe_sim_only_txdatak7         => CONNECTED_TO_pipe_sim_only_txdatak7,         --                 .txdatak7
			pipe_sim_only_txdetectrx0      => CONNECTED_TO_pipe_sim_only_txdetectrx0,      --                 .txdetectrx0
			pipe_sim_only_txdetectrx1      => CONNECTED_TO_pipe_sim_only_txdetectrx1,      --                 .txdetectrx1
			pipe_sim_only_txdetectrx2      => CONNECTED_TO_pipe_sim_only_txdetectrx2,      --                 .txdetectrx2
			pipe_sim_only_txdetectrx3      => CONNECTED_TO_pipe_sim_only_txdetectrx3,      --                 .txdetectrx3
			pipe_sim_only_txdetectrx4      => CONNECTED_TO_pipe_sim_only_txdetectrx4,      --                 .txdetectrx4
			pipe_sim_only_txdetectrx5      => CONNECTED_TO_pipe_sim_only_txdetectrx5,      --                 .txdetectrx5
			pipe_sim_only_txdetectrx6      => CONNECTED_TO_pipe_sim_only_txdetectrx6,      --                 .txdetectrx6
			pipe_sim_only_txdetectrx7      => CONNECTED_TO_pipe_sim_only_txdetectrx7,      --                 .txdetectrx7
			pipe_sim_only_txelecidle0      => CONNECTED_TO_pipe_sim_only_txelecidle0,      --                 .txelecidle0
			pipe_sim_only_txelecidle1      => CONNECTED_TO_pipe_sim_only_txelecidle1,      --                 .txelecidle1
			pipe_sim_only_txelecidle2      => CONNECTED_TO_pipe_sim_only_txelecidle2,      --                 .txelecidle2
			pipe_sim_only_txelecidle3      => CONNECTED_TO_pipe_sim_only_txelecidle3,      --                 .txelecidle3
			pipe_sim_only_txelecidle4      => CONNECTED_TO_pipe_sim_only_txelecidle4,      --                 .txelecidle4
			pipe_sim_only_txelecidle5      => CONNECTED_TO_pipe_sim_only_txelecidle5,      --                 .txelecidle5
			pipe_sim_only_txelecidle6      => CONNECTED_TO_pipe_sim_only_txelecidle6,      --                 .txelecidle6
			pipe_sim_only_txelecidle7      => CONNECTED_TO_pipe_sim_only_txelecidle7,      --                 .txelecidle7
			pipe_sim_only_txdeemph0        => CONNECTED_TO_pipe_sim_only_txdeemph0,        --                 .txdeemph0
			pipe_sim_only_txdeemph1        => CONNECTED_TO_pipe_sim_only_txdeemph1,        --                 .txdeemph1
			pipe_sim_only_txdeemph2        => CONNECTED_TO_pipe_sim_only_txdeemph2,        --                 .txdeemph2
			pipe_sim_only_txdeemph3        => CONNECTED_TO_pipe_sim_only_txdeemph3,        --                 .txdeemph3
			pipe_sim_only_txdeemph4        => CONNECTED_TO_pipe_sim_only_txdeemph4,        --                 .txdeemph4
			pipe_sim_only_txdeemph5        => CONNECTED_TO_pipe_sim_only_txdeemph5,        --                 .txdeemph5
			pipe_sim_only_txdeemph6        => CONNECTED_TO_pipe_sim_only_txdeemph6,        --                 .txdeemph6
			pipe_sim_only_txdeemph7        => CONNECTED_TO_pipe_sim_only_txdeemph7,        --                 .txdeemph7
			pipe_sim_only_txmargin0        => CONNECTED_TO_pipe_sim_only_txmargin0,        --                 .txmargin0
			pipe_sim_only_txmargin1        => CONNECTED_TO_pipe_sim_only_txmargin1,        --                 .txmargin1
			pipe_sim_only_txmargin2        => CONNECTED_TO_pipe_sim_only_txmargin2,        --                 .txmargin2
			pipe_sim_only_txmargin3        => CONNECTED_TO_pipe_sim_only_txmargin3,        --                 .txmargin3
			pipe_sim_only_txmargin4        => CONNECTED_TO_pipe_sim_only_txmargin4,        --                 .txmargin4
			pipe_sim_only_txmargin5        => CONNECTED_TO_pipe_sim_only_txmargin5,        --                 .txmargin5
			pipe_sim_only_txmargin6        => CONNECTED_TO_pipe_sim_only_txmargin6,        --                 .txmargin6
			pipe_sim_only_txmargin7        => CONNECTED_TO_pipe_sim_only_txmargin7,        --                 .txmargin7
			pipe_sim_only_txswing0         => CONNECTED_TO_pipe_sim_only_txswing0,         --                 .txswing0
			pipe_sim_only_txswing1         => CONNECTED_TO_pipe_sim_only_txswing1,         --                 .txswing1
			pipe_sim_only_txswing2         => CONNECTED_TO_pipe_sim_only_txswing2,         --                 .txswing2
			pipe_sim_only_txswing3         => CONNECTED_TO_pipe_sim_only_txswing3,         --                 .txswing3
			pipe_sim_only_txswing4         => CONNECTED_TO_pipe_sim_only_txswing4,         --                 .txswing4
			pipe_sim_only_txswing5         => CONNECTED_TO_pipe_sim_only_txswing5,         --                 .txswing5
			pipe_sim_only_txswing6         => CONNECTED_TO_pipe_sim_only_txswing6,         --                 .txswing6
			pipe_sim_only_txswing7         => CONNECTED_TO_pipe_sim_only_txswing7,         --                 .txswing7
			pipe_sim_only_phystatus0       => CONNECTED_TO_pipe_sim_only_phystatus0,       --                 .phystatus0
			pipe_sim_only_phystatus1       => CONNECTED_TO_pipe_sim_only_phystatus1,       --                 .phystatus1
			pipe_sim_only_phystatus2       => CONNECTED_TO_pipe_sim_only_phystatus2,       --                 .phystatus2
			pipe_sim_only_phystatus3       => CONNECTED_TO_pipe_sim_only_phystatus3,       --                 .phystatus3
			pipe_sim_only_phystatus4       => CONNECTED_TO_pipe_sim_only_phystatus4,       --                 .phystatus4
			pipe_sim_only_phystatus5       => CONNECTED_TO_pipe_sim_only_phystatus5,       --                 .phystatus5
			pipe_sim_only_phystatus6       => CONNECTED_TO_pipe_sim_only_phystatus6,       --                 .phystatus6
			pipe_sim_only_phystatus7       => CONNECTED_TO_pipe_sim_only_phystatus7,       --                 .phystatus7
			pipe_sim_only_rxdata0          => CONNECTED_TO_pipe_sim_only_rxdata0,          --                 .rxdata0
			pipe_sim_only_rxdata1          => CONNECTED_TO_pipe_sim_only_rxdata1,          --                 .rxdata1
			pipe_sim_only_rxdata2          => CONNECTED_TO_pipe_sim_only_rxdata2,          --                 .rxdata2
			pipe_sim_only_rxdata3          => CONNECTED_TO_pipe_sim_only_rxdata3,          --                 .rxdata3
			pipe_sim_only_rxdata4          => CONNECTED_TO_pipe_sim_only_rxdata4,          --                 .rxdata4
			pipe_sim_only_rxdata5          => CONNECTED_TO_pipe_sim_only_rxdata5,          --                 .rxdata5
			pipe_sim_only_rxdata6          => CONNECTED_TO_pipe_sim_only_rxdata6,          --                 .rxdata6
			pipe_sim_only_rxdata7          => CONNECTED_TO_pipe_sim_only_rxdata7,          --                 .rxdata7
			pipe_sim_only_rxdatak0         => CONNECTED_TO_pipe_sim_only_rxdatak0,         --                 .rxdatak0
			pipe_sim_only_rxdatak1         => CONNECTED_TO_pipe_sim_only_rxdatak1,         --                 .rxdatak1
			pipe_sim_only_rxdatak2         => CONNECTED_TO_pipe_sim_only_rxdatak2,         --                 .rxdatak2
			pipe_sim_only_rxdatak3         => CONNECTED_TO_pipe_sim_only_rxdatak3,         --                 .rxdatak3
			pipe_sim_only_rxdatak4         => CONNECTED_TO_pipe_sim_only_rxdatak4,         --                 .rxdatak4
			pipe_sim_only_rxdatak5         => CONNECTED_TO_pipe_sim_only_rxdatak5,         --                 .rxdatak5
			pipe_sim_only_rxdatak6         => CONNECTED_TO_pipe_sim_only_rxdatak6,         --                 .rxdatak6
			pipe_sim_only_rxdatak7         => CONNECTED_TO_pipe_sim_only_rxdatak7,         --                 .rxdatak7
			pipe_sim_only_rxelecidle0      => CONNECTED_TO_pipe_sim_only_rxelecidle0,      --                 .rxelecidle0
			pipe_sim_only_rxelecidle1      => CONNECTED_TO_pipe_sim_only_rxelecidle1,      --                 .rxelecidle1
			pipe_sim_only_rxelecidle2      => CONNECTED_TO_pipe_sim_only_rxelecidle2,      --                 .rxelecidle2
			pipe_sim_only_rxelecidle3      => CONNECTED_TO_pipe_sim_only_rxelecidle3,      --                 .rxelecidle3
			pipe_sim_only_rxelecidle4      => CONNECTED_TO_pipe_sim_only_rxelecidle4,      --                 .rxelecidle4
			pipe_sim_only_rxelecidle5      => CONNECTED_TO_pipe_sim_only_rxelecidle5,      --                 .rxelecidle5
			pipe_sim_only_rxelecidle6      => CONNECTED_TO_pipe_sim_only_rxelecidle6,      --                 .rxelecidle6
			pipe_sim_only_rxelecidle7      => CONNECTED_TO_pipe_sim_only_rxelecidle7,      --                 .rxelecidle7
			pipe_sim_only_rxstatus0        => CONNECTED_TO_pipe_sim_only_rxstatus0,        --                 .rxstatus0
			pipe_sim_only_rxstatus1        => CONNECTED_TO_pipe_sim_only_rxstatus1,        --                 .rxstatus1
			pipe_sim_only_rxstatus2        => CONNECTED_TO_pipe_sim_only_rxstatus2,        --                 .rxstatus2
			pipe_sim_only_rxstatus3        => CONNECTED_TO_pipe_sim_only_rxstatus3,        --                 .rxstatus3
			pipe_sim_only_rxstatus4        => CONNECTED_TO_pipe_sim_only_rxstatus4,        --                 .rxstatus4
			pipe_sim_only_rxstatus5        => CONNECTED_TO_pipe_sim_only_rxstatus5,        --                 .rxstatus5
			pipe_sim_only_rxstatus6        => CONNECTED_TO_pipe_sim_only_rxstatus6,        --                 .rxstatus6
			pipe_sim_only_rxstatus7        => CONNECTED_TO_pipe_sim_only_rxstatus7,        --                 .rxstatus7
			pipe_sim_only_rxvalid0         => CONNECTED_TO_pipe_sim_only_rxvalid0,         --                 .rxvalid0
			pipe_sim_only_rxvalid1         => CONNECTED_TO_pipe_sim_only_rxvalid1,         --                 .rxvalid1
			pipe_sim_only_rxvalid2         => CONNECTED_TO_pipe_sim_only_rxvalid2,         --                 .rxvalid2
			pipe_sim_only_rxvalid3         => CONNECTED_TO_pipe_sim_only_rxvalid3,         --                 .rxvalid3
			pipe_sim_only_rxvalid4         => CONNECTED_TO_pipe_sim_only_rxvalid4,         --                 .rxvalid4
			pipe_sim_only_rxvalid5         => CONNECTED_TO_pipe_sim_only_rxvalid5,         --                 .rxvalid5
			pipe_sim_only_rxvalid6         => CONNECTED_TO_pipe_sim_only_rxvalid6,         --                 .rxvalid6
			pipe_sim_only_rxvalid7         => CONNECTED_TO_pipe_sim_only_rxvalid7,         --                 .rxvalid7
			pipe_sim_only_rxdataskip0      => CONNECTED_TO_pipe_sim_only_rxdataskip0,      --                 .rxdataskip0
			pipe_sim_only_rxdataskip1      => CONNECTED_TO_pipe_sim_only_rxdataskip1,      --                 .rxdataskip1
			pipe_sim_only_rxdataskip2      => CONNECTED_TO_pipe_sim_only_rxdataskip2,      --                 .rxdataskip2
			pipe_sim_only_rxdataskip3      => CONNECTED_TO_pipe_sim_only_rxdataskip3,      --                 .rxdataskip3
			pipe_sim_only_rxdataskip4      => CONNECTED_TO_pipe_sim_only_rxdataskip4,      --                 .rxdataskip4
			pipe_sim_only_rxdataskip5      => CONNECTED_TO_pipe_sim_only_rxdataskip5,      --                 .rxdataskip5
			pipe_sim_only_rxdataskip6      => CONNECTED_TO_pipe_sim_only_rxdataskip6,      --                 .rxdataskip6
			pipe_sim_only_rxdataskip7      => CONNECTED_TO_pipe_sim_only_rxdataskip7,      --                 .rxdataskip7
			pipe_sim_only_rxblkst0         => CONNECTED_TO_pipe_sim_only_rxblkst0,         --                 .rxblkst0
			pipe_sim_only_rxblkst1         => CONNECTED_TO_pipe_sim_only_rxblkst1,         --                 .rxblkst1
			pipe_sim_only_rxblkst2         => CONNECTED_TO_pipe_sim_only_rxblkst2,         --                 .rxblkst2
			pipe_sim_only_rxblkst3         => CONNECTED_TO_pipe_sim_only_rxblkst3,         --                 .rxblkst3
			pipe_sim_only_rxblkst4         => CONNECTED_TO_pipe_sim_only_rxblkst4,         --                 .rxblkst4
			pipe_sim_only_rxblkst5         => CONNECTED_TO_pipe_sim_only_rxblkst5,         --                 .rxblkst5
			pipe_sim_only_rxblkst6         => CONNECTED_TO_pipe_sim_only_rxblkst6,         --                 .rxblkst6
			pipe_sim_only_rxblkst7         => CONNECTED_TO_pipe_sim_only_rxblkst7,         --                 .rxblkst7
			pipe_sim_only_rxsynchd0        => CONNECTED_TO_pipe_sim_only_rxsynchd0,        --                 .rxsynchd0
			pipe_sim_only_rxsynchd1        => CONNECTED_TO_pipe_sim_only_rxsynchd1,        --                 .rxsynchd1
			pipe_sim_only_rxsynchd2        => CONNECTED_TO_pipe_sim_only_rxsynchd2,        --                 .rxsynchd2
			pipe_sim_only_rxsynchd3        => CONNECTED_TO_pipe_sim_only_rxsynchd3,        --                 .rxsynchd3
			pipe_sim_only_rxsynchd4        => CONNECTED_TO_pipe_sim_only_rxsynchd4,        --                 .rxsynchd4
			pipe_sim_only_rxsynchd5        => CONNECTED_TO_pipe_sim_only_rxsynchd5,        --                 .rxsynchd5
			pipe_sim_only_rxsynchd6        => CONNECTED_TO_pipe_sim_only_rxsynchd6,        --                 .rxsynchd6
			pipe_sim_only_rxsynchd7        => CONNECTED_TO_pipe_sim_only_rxsynchd7,        --                 .rxsynchd7
			pipe_sim_only_currentcoeff0    => CONNECTED_TO_pipe_sim_only_currentcoeff0,    --                 .currentcoeff0
			pipe_sim_only_currentcoeff1    => CONNECTED_TO_pipe_sim_only_currentcoeff1,    --                 .currentcoeff1
			pipe_sim_only_currentcoeff2    => CONNECTED_TO_pipe_sim_only_currentcoeff2,    --                 .currentcoeff2
			pipe_sim_only_currentcoeff3    => CONNECTED_TO_pipe_sim_only_currentcoeff3,    --                 .currentcoeff3
			pipe_sim_only_currentcoeff4    => CONNECTED_TO_pipe_sim_only_currentcoeff4,    --                 .currentcoeff4
			pipe_sim_only_currentcoeff5    => CONNECTED_TO_pipe_sim_only_currentcoeff5,    --                 .currentcoeff5
			pipe_sim_only_currentcoeff6    => CONNECTED_TO_pipe_sim_only_currentcoeff6,    --                 .currentcoeff6
			pipe_sim_only_currentcoeff7    => CONNECTED_TO_pipe_sim_only_currentcoeff7,    --                 .currentcoeff7
			pipe_sim_only_currentrxpreset0 => CONNECTED_TO_pipe_sim_only_currentrxpreset0, --                 .currentrxpreset0
			pipe_sim_only_currentrxpreset1 => CONNECTED_TO_pipe_sim_only_currentrxpreset1, --                 .currentrxpreset1
			pipe_sim_only_currentrxpreset2 => CONNECTED_TO_pipe_sim_only_currentrxpreset2, --                 .currentrxpreset2
			pipe_sim_only_currentrxpreset3 => CONNECTED_TO_pipe_sim_only_currentrxpreset3, --                 .currentrxpreset3
			pipe_sim_only_currentrxpreset4 => CONNECTED_TO_pipe_sim_only_currentrxpreset4, --                 .currentrxpreset4
			pipe_sim_only_currentrxpreset5 => CONNECTED_TO_pipe_sim_only_currentrxpreset5, --                 .currentrxpreset5
			pipe_sim_only_currentrxpreset6 => CONNECTED_TO_pipe_sim_only_currentrxpreset6, --                 .currentrxpreset6
			pipe_sim_only_currentrxpreset7 => CONNECTED_TO_pipe_sim_only_currentrxpreset7, --                 .currentrxpreset7
			pipe_sim_only_txsynchd0        => CONNECTED_TO_pipe_sim_only_txsynchd0,        --                 .txsynchd0
			pipe_sim_only_txsynchd1        => CONNECTED_TO_pipe_sim_only_txsynchd1,        --                 .txsynchd1
			pipe_sim_only_txsynchd2        => CONNECTED_TO_pipe_sim_only_txsynchd2,        --                 .txsynchd2
			pipe_sim_only_txsynchd3        => CONNECTED_TO_pipe_sim_only_txsynchd3,        --                 .txsynchd3
			pipe_sim_only_txsynchd4        => CONNECTED_TO_pipe_sim_only_txsynchd4,        --                 .txsynchd4
			pipe_sim_only_txsynchd5        => CONNECTED_TO_pipe_sim_only_txsynchd5,        --                 .txsynchd5
			pipe_sim_only_txsynchd6        => CONNECTED_TO_pipe_sim_only_txsynchd6,        --                 .txsynchd6
			pipe_sim_only_txsynchd7        => CONNECTED_TO_pipe_sim_only_txsynchd7,        --                 .txsynchd7
			pipe_sim_only_txblkst0         => CONNECTED_TO_pipe_sim_only_txblkst0,         --                 .txblkst0
			pipe_sim_only_txblkst1         => CONNECTED_TO_pipe_sim_only_txblkst1,         --                 .txblkst1
			pipe_sim_only_txblkst2         => CONNECTED_TO_pipe_sim_only_txblkst2,         --                 .txblkst2
			pipe_sim_only_txblkst3         => CONNECTED_TO_pipe_sim_only_txblkst3,         --                 .txblkst3
			pipe_sim_only_txblkst4         => CONNECTED_TO_pipe_sim_only_txblkst4,         --                 .txblkst4
			pipe_sim_only_txblkst5         => CONNECTED_TO_pipe_sim_only_txblkst5,         --                 .txblkst5
			pipe_sim_only_txblkst6         => CONNECTED_TO_pipe_sim_only_txblkst6,         --                 .txblkst6
			pipe_sim_only_txblkst7         => CONNECTED_TO_pipe_sim_only_txblkst7,         --                 .txblkst7
			pipe_sim_only_txdataskip0      => CONNECTED_TO_pipe_sim_only_txdataskip0,      --                 .txdataskip0
			pipe_sim_only_txdataskip1      => CONNECTED_TO_pipe_sim_only_txdataskip1,      --                 .txdataskip1
			pipe_sim_only_txdataskip2      => CONNECTED_TO_pipe_sim_only_txdataskip2,      --                 .txdataskip2
			pipe_sim_only_txdataskip3      => CONNECTED_TO_pipe_sim_only_txdataskip3,      --                 .txdataskip3
			pipe_sim_only_txdataskip4      => CONNECTED_TO_pipe_sim_only_txdataskip4,      --                 .txdataskip4
			pipe_sim_only_txdataskip5      => CONNECTED_TO_pipe_sim_only_txdataskip5,      --                 .txdataskip5
			pipe_sim_only_txdataskip6      => CONNECTED_TO_pipe_sim_only_txdataskip6,      --                 .txdataskip6
			pipe_sim_only_txdataskip7      => CONNECTED_TO_pipe_sim_only_txdataskip7,      --                 .txdataskip7
			pipe_sim_only_rate0            => CONNECTED_TO_pipe_sim_only_rate0,            --                 .rate0
			pipe_sim_only_rate1            => CONNECTED_TO_pipe_sim_only_rate1,            --                 .rate1
			pipe_sim_only_rate2            => CONNECTED_TO_pipe_sim_only_rate2,            --                 .rate2
			pipe_sim_only_rate3            => CONNECTED_TO_pipe_sim_only_rate3,            --                 .rate3
			pipe_sim_only_rate4            => CONNECTED_TO_pipe_sim_only_rate4,            --                 .rate4
			pipe_sim_only_rate5            => CONNECTED_TO_pipe_sim_only_rate5,            --                 .rate5
			pipe_sim_only_rate6            => CONNECTED_TO_pipe_sim_only_rate6,            --                 .rate6
			pipe_sim_only_rate7            => CONNECTED_TO_pipe_sim_only_rate7,            --                 .rate7
			xcvr_rx_in0                    => CONNECTED_TO_xcvr_rx_in0,                    --             xcvr.rx_in0
			xcvr_rx_in1                    => CONNECTED_TO_xcvr_rx_in1,                    --                 .rx_in1
			xcvr_rx_in2                    => CONNECTED_TO_xcvr_rx_in2,                    --                 .rx_in2
			xcvr_rx_in3                    => CONNECTED_TO_xcvr_rx_in3,                    --                 .rx_in3
			xcvr_rx_in4                    => CONNECTED_TO_xcvr_rx_in4,                    --                 .rx_in4
			xcvr_rx_in5                    => CONNECTED_TO_xcvr_rx_in5,                    --                 .rx_in5
			xcvr_rx_in6                    => CONNECTED_TO_xcvr_rx_in6,                    --                 .rx_in6
			xcvr_rx_in7                    => CONNECTED_TO_xcvr_rx_in7,                    --                 .rx_in7
			xcvr_tx_out0                   => CONNECTED_TO_xcvr_tx_out0,                   --                 .tx_out0
			xcvr_tx_out1                   => CONNECTED_TO_xcvr_tx_out1,                   --                 .tx_out1
			xcvr_tx_out2                   => CONNECTED_TO_xcvr_tx_out2,                   --                 .tx_out2
			xcvr_tx_out3                   => CONNECTED_TO_xcvr_tx_out3,                   --                 .tx_out3
			xcvr_tx_out4                   => CONNECTED_TO_xcvr_tx_out4,                   --                 .tx_out4
			xcvr_tx_out5                   => CONNECTED_TO_xcvr_tx_out5,                   --                 .tx_out5
			xcvr_tx_out6                   => CONNECTED_TO_xcvr_tx_out6,                   --                 .tx_out6
			xcvr_tx_out7                   => CONNECTED_TO_xcvr_tx_out7,                   --                 .tx_out7
			ddr4_pll_ref_clk_clk           => CONNECTED_TO_ddr4_pll_ref_clk_clk,           -- ddr4_pll_ref_clk.clk
			ddr4_oct_oct_rzqin             => CONNECTED_TO_ddr4_oct_oct_rzqin,             --         ddr4_oct.oct_rzqin
			ddr4_mem_mem_ck                => CONNECTED_TO_ddr4_mem_mem_ck,                --         ddr4_mem.mem_ck
			ddr4_mem_mem_ck_n              => CONNECTED_TO_ddr4_mem_mem_ck_n,              --                 .mem_ck_n
			ddr4_mem_mem_a                 => CONNECTED_TO_ddr4_mem_mem_a,                 --                 .mem_a
			ddr4_mem_mem_act_n             => CONNECTED_TO_ddr4_mem_mem_act_n,             --                 .mem_act_n
			ddr4_mem_mem_ba                => CONNECTED_TO_ddr4_mem_mem_ba,                --                 .mem_ba
			ddr4_mem_mem_bg                => CONNECTED_TO_ddr4_mem_mem_bg,                --                 .mem_bg
			ddr4_mem_mem_cke               => CONNECTED_TO_ddr4_mem_mem_cke,               --                 .mem_cke
			ddr4_mem_mem_cs_n              => CONNECTED_TO_ddr4_mem_mem_cs_n,              --                 .mem_cs_n
			ddr4_mem_mem_odt               => CONNECTED_TO_ddr4_mem_mem_odt,               --                 .mem_odt
			ddr4_mem_mem_reset_n           => CONNECTED_TO_ddr4_mem_mem_reset_n,           --                 .mem_reset_n
			ddr4_mem_mem_par               => CONNECTED_TO_ddr4_mem_mem_par,               --                 .mem_par
			ddr4_mem_mem_alert_n           => CONNECTED_TO_ddr4_mem_mem_alert_n,           --                 .mem_alert_n
			ddr4_mem_mem_dqs               => CONNECTED_TO_ddr4_mem_mem_dqs,               --                 .mem_dqs
			ddr4_mem_mem_dqs_n             => CONNECTED_TO_ddr4_mem_mem_dqs_n,             --                 .mem_dqs_n
			ddr4_mem_mem_dq                => CONNECTED_TO_ddr4_mem_mem_dq,                --                 .mem_dq
			ddr4_mem_mem_dbi_n             => CONNECTED_TO_ddr4_mem_mem_dbi_n,             --                 .mem_dbi_n
			board_pins_L0_led              => CONNECTED_TO_board_pins_L0_led,              --       board_pins.L0_led
			board_pins_alive_led           => CONNECTED_TO_board_pins_alive_led,           --                 .alive_led
			board_pins_comp_led            => CONNECTED_TO_board_pins_comp_led,            --                 .comp_led
			board_pins_free_clk            => CONNECTED_TO_board_pins_free_clk,            --                 .free_clk
			board_pins_gen2_led            => CONNECTED_TO_board_pins_gen2_led,            --                 .gen2_led
			board_pins_gen3_led            => CONNECTED_TO_board_pins_gen3_led,            --                 .gen3_led
			board_pins_lane_active_led     => CONNECTED_TO_board_pins_lane_active_led,     --                 .lane_active_led
			board_pins_req_compliance_pb   => CONNECTED_TO_board_pins_req_compliance_pb,   --                 .req_compliance_pb
			board_pins_set_compliance_mode => CONNECTED_TO_board_pins_set_compliance_mode, --                 .set_compliance_mode
			pll_refclk_clk                 => CONNECTED_TO_pll_refclk_clk                  --       pll_refclk.clk
		);

