# (C) 2001-2021 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# derive_pll_clock is used to calculate all clock derived from PCIe refclk
#  the derive_pll_clocks and derive clock_uncertainty should only
# be applied once across all of the SDC files used in a project
 derive_pll_clocks -create_base_clocks
 derive_clock_uncertainty

set verbose 1

################################################ Applying Constraints ################################################

#derive_pll_clocks -create_base_clocks     ;# derive_pll_clocks needs to be called before calling parent_of_clock
#derive_clock_uncertainty                  ;# in order to generate proper hierarchy.
				

	set inst_prefix [get_current_instance]
	if {$verbose == 1} {
	    puts "INFO:   Processing PCIe SDC for instance $inst_prefix"
	}
	
	set phy_lane0_size 0 ;#Gen 3x1
	set phy_lane1_size 0 ;#Gen 3x2
	set phy_lane3_size 0 ;#Gen 3x4
	set phy_lane7_size 0 ;#Gen 3x8
	
	set phy_lane0 [get_registers -nowarn "*$inst_prefix*phy_g3x*|g_xcvr_native_insts[0]*"]
	set phy_lane1 [get_registers -nowarn "*$inst_prefix*phy_g3x*|g_xcvr_native_insts[1]*"]
	set phy_lane3 [get_registers -nowarn "*$inst_prefix*phy_g3x*|g_xcvr_native_insts[3]*"]
	set phy_lane7 [get_registers -nowarn "*$inst_prefix*phy_g3x*|g_xcvr_native_insts[7]*"]
	
	set phy_lane0_size [get_collection_size $phy_lane0]
	set phy_lane1_size [get_collection_size $phy_lane1]
	set phy_lane3_size [get_collection_size $phy_lane3]
	set phy_lane7_size [get_collection_size $phy_lane7]
	
	if {$phy_lane7_size > 0} {
		set stop 8
		} elseif {$phy_lane3_size > 0} {
		set stop 4
		} elseif {$phy_lane1_size > 0} {
		set stop 2
		} elseif {$phy_lane0_size > 0} {
		set stop 1
		} else {
		set stop 0
		}
	
	for {set i 0} {$i != $stop} {incr i} {
	    # set inst_prefix dut2|dut|dut
	    # set inst_prefix dut2|dut|dut
	    # set i 2

		create_generated_clock -divide_by 1 -source "$inst_prefix|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_xcvr.g_phy_g3x*.phy_g3x*|phy_g3x*|g_xcvr_native_insts[$i].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_8g_rx_pcs.inst_twentynm_hssi_8g_rx_pcs|byte_deserializer_pcs_clk_div_by_2_txclk_reg" -name       "$inst_prefix|rx_pcs_clk_div_by_4[$i]" "$inst_prefix|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_xcvr.g_phy_g3x*.phy_g3x*|phy_g3x*|g_xcvr_native_insts[$i].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_8g_rx_pcs.inst_twentynm_hssi_8g_rx_pcs|sta_rx_clk2_by2_1" ;# target

		create_generated_clock -multiply_by 1 -divide_by 1 -source "$inst_prefix|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_xcvr.g_phy_g3x*.phy_g3x*|phy_g3x*|g_xcvr_native_insts[$i].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_8g_tx_pcs.inst_twentynm_hssi_8g_tx_pcs|byte_serializer_pcs_clk_div_by_2_reg" -name       "$inst_prefix|tx_pcs_clk_div_by_4[$i]" "$inst_prefix|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_xcvr.g_phy_g3x*.phy_g3x*|phy_g3x*|g_xcvr_native_insts[$i].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_8g_tx_pcs.inst_twentynm_hssi_8g_tx_pcs|sta_tx_clk2_by2_1" ;# target
	}
 	
	remove_clock      "$inst_prefix|tx_bonding_clocks[0]"
	
	# Constraint for Gen 3x2 and up
	if {$phy_lane1_size > 0} {
		create_generated_clock -multiply_by 1 -divide_by 10 \
		-source        "$inst_prefix|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_pll.g_pll_g3n.lcpll_g3xn|lcpll_g3xn|a10_xcvr_atx_pll_inst|twentynm_hssi_pma_cgb_master_inst|clk_fpll_*" \
		-master_clock  "$inst_prefix|tx_serial_clk" \
		-name          "$inst_prefix|tx_bonding_clocks[0]" \
						"$inst_prefix|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_pll.g_pll_g3n.lcpll_g3xn|lcpll_g3xn|a10_xcvr_atx_pll_inst|twentynm_hssi_pma_cgb_master_inst|cpulse_out_bus[0]"
        
        
        set_false_path -from ${inst_prefix}|altpcie_a10_hip_pipen1b|wys~ch*_pcs_chnl_hip_clk_out[0].reg  -to ${inst_prefix}|altpcie_a10_hip_pipen1b|*altpcie_a10_hip_pllnphy|*g_xcvr_native_insts[*].twentynm_xcvr_native_inst|*twentynm_xcvr_native_inst|*gen_twentynm_hssi_common_pld_pcs_interface.inst_twentynm_hssi_common_pld_pcs_interface~pld_rate_reg.reg																								
        set_false_path -from ${inst_prefix}|altpcie_a10_hip_pipen1b|wys~ch*_pcs_chnl_hip_clk_out[0].reg  -to ${inst_prefix}|altpcie_a10_hip_pipen1b|*altpcie_a10_hip_pllnphy|*g_xcvr_native_insts[*].twentynm_xcvr_native_inst|*twentynm_xcvr_native_inst|*gen_twentynm_hssi_8g_tx_pcs.inst_twentynm_hssi_8g_tx_pcs~tx_clk2_by2_1.reg	
		set_false_path -from ${inst_prefix}|altpcie_a10_hip_pipen1b|wys~ch*_pcs_chnl_hip_clk_out[0].reg  -to ${inst_prefix}|altpcie_a10_hip_pipen1b|*altpcie_a10_hip_pllnphy|*g_xcvr_native_insts[*].twentynm_xcvr_native_inst|*twentynm_xcvr_native_inst|*gen_twentynm_hssi_8g_tx_pcs.inst_twentynm_hssi_8g_tx_pcs~tx_clk2_by4_1.reg	
		set_false_path -from ${inst_prefix}|altpcie_a10_hip_pipen1b|wys~ch*_pcs_chnl_hip_clk_out[0].reg  -to ${inst_prefix}|altpcie_a10_hip_pipen1b|*altpcie_a10_hip_pllnphy|*g_xcvr_native_insts[*].twentynm_xcvr_native_inst|*twentynm_xcvr_native_inst|*gen_twentynm_hssi_common_pld_pcs_interface.inst_twentynm_hssi_common_pld_pcs_interface~pld_8g_eidleinfersel_reg.reg	
	
				    # SKP Specific - clock domain transfer for the skp pattern detected pulse
				    for {set i 0} {$i != $stop} {incr i} {
                        set skp_pat_det_g3_col 0
                        set skp_pat_det_g3_col [get_registers -nowarn "$inst_prefix|altpcie_a10_hip_pipen1b:altpcie_a10_hip_pipen1b|skp_det_g3:gen_det_skp_os.skp_det\[$i].inst|skp_pat_det_g3_ps"]
                        set skp_pat_det_g3_col_size [get_collection_size $skp_pat_det_g3_col]
                        if {$skp_pat_det_g3_col_size > 0} {
                            if {$verbose == 1} {
                                puts "INFO:   Processing   SKP OS SDC exceptions"
                            }
				    		set_false_path -from $skp_pat_det_g3_col -to "$inst_prefix|altpcie_a10_hip_pipen1b:altpcie_a10_hip_pipen1b|skp_pat_det_g3_ps_r1\[$i]"
                        } else {
                            if {$verbose == 1} {
                                puts "WARNING: No SDC exception -- SKP OS optional logic not enable"                      
                            }
                        }
                    }
				  
     			    # SKP Specific - clock domain transfer for reset_status
                    set reset_status_sync_col 0
                    set reset_status_sync_col [get_registers -nowarn "$inst_prefix|altpcie_a10_hip_pipen1b:altpcie_a10_hip_pipen1b|altpcie_sc_bitsync_node:reset_status_altpcie_sc_bitsync|altpcie_sc_bitsync:altpcie_sc_bitsync|g_bitsync.g_bitsync2.sync_regsb\[0]"]
                    set reset_status_sync_col_size [get_collection_size $reset_status_sync_col]
                    if {$reset_status_sync_col_size > 0} {
                        if {$verbose == 1} {
                            puts "INFO:   Processing reset_status SDC exceptions"
				        }
				        set_false_path -from $reset_status_sync_col -to "$inst_prefix|altpcie_a10_hip_pipen1b|reset_status_1sync\[*]"
                    } else {
                        if {$verbose == 1} {
                            puts "WARNING: No SDC exception -- reset_status_sync"                      
                         }
                    }
    
	}
	# END Constraint for Gen 3x2 and up 
	
	#create_generated_clock -multiply_by 1 -divide_by 10 \
		-source        "$clk_pin_prefix_loop|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_pll.g_pll_g3n.lcpll_g3xn|lcpll_g3xn|a10_xcvr_atx_pll_instntynm_hssi_pma_cgb_master_inst|clk_fpll_b" \
		-master_clock  "$inst_prefix|tx_serial_clk" \
		-name          "$inst_prefix|tx_bonding_clocks[0]" \
							"$clk_pin_prefix_loop|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_pll.g_pll_g3n.lcpll_g3xn|lcpll_g3xn|a10_xcvr_atx_pllt|twentynm_hssi_pma_cgb_master_inst|cpulse_out_bus[0]"
	
	#set_multicycle_path -setup -through [get_pins -compatibility_mode {*pld_rx_data*}] 0
	
	##  Using negedge of rx_clkout to get additional clock insertion delay between rx_clkout (latch clock) and rx_pcs_clk_div_by_4 (launch clock) 
	### foreach_in_collection mpin [get_pins -compatibility_mode {*pld_rx_data*}]  {
	### 	set mpin_name [get_pin_info -name $mpin]
	### 	if [string match "*altpcie_a10_hip_pipen1b*" $mpin_name] {
	### 		set_multicycle_path -setup -through $mpin 0
	### 	}
	### }
	
	set rx_clkouts [list]
	for {set i 0} {$i != $stop} {incr i} {
		remove_clock      "$inst_prefix|g_xcvr_native_insts[$i]|rx_clk"
		remove_clock      "$inst_prefix|g_xcvr_native_insts[$i]|rx_clkout"
		
		create_generated_clock -multiply_by 1 \
			-source        "$inst_prefix|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_xcvr.g_phy_g3x*.phy_g3x*|phy_g3x*|g_xcvr_native_insts[$i].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_8g_rx_pcs.inst_twentynm_hssi_8g_rx_pcs|byte_deserializer_pcs_clk_div_by_4_txclk_reg" \
			-master_clock  "$inst_prefix|tx_bonding_clocks[0]" \
			-name          "$inst_prefix|g_xcvr_native_insts[$i]|rx_clk" \
			"$inst_prefix|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_xcvr.g_phy_g3x*.phy_g3x*|phy_g3x*|g_xcvr_native_insts[$i].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_8g_rx_pcs.inst_twentynm_hssi_8g_rx_pcs|sta_rx_clk2_by4_1" ;# target
	
		create_generated_clock -multiply_by 1 \
			-source        "$inst_prefix|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_xcvr.g_phy_g3x*.phy_g3x*|phy_g3x*|g_xcvr_native_insts[$i].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_8g_rx_pcs.inst_twentynm_hssi_8g_rx_pcs|byte_deserializer_pld_clk_div_by_4_txclk_reg" \
			-master_clock  "$inst_prefix|tx_bonding_clocks[0]" \
			-name          "$inst_prefix|g_xcvr_native_insts[$i]|rx_clkout" \
			"$inst_prefix|altpcie_a10_hip_pipen1b|g_xcvr.altpcie_a10_hip_pllnphy|g_xcvr.g_phy_g3x*.phy_g3x*|phy_g3x*|g_xcvr_native_insts[$i].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_8g_rx_pcs.inst_twentynm_hssi_8g_rx_pcs|sta_rx_clk2_by4_1_out"
	
		set_clock_groups -exclusive -group "$inst_prefix|tx_bonding_clocks[0]" -group "$inst_prefix|g_xcvr_native_insts[$i]|rx_clkout"
		set_clock_groups -exclusive -group "$inst_prefix|tx_bonding_clocks[0]" -group "$inst_prefix|rx_pcs_clk_div_by_4[$i]"
	}
    ## Testin
    set testin_size_collection_pcie 0
    set testin_collection_pcie [get_registers -nowarn $inst_prefix|altpcie_a10_hip_pipen1b|altpcie_test_in_static_signal_to_be_false_path[*]]
    set testin_size_collection_pcie [get_collection_size $testin_collection_pcie]
    if {$testin_size_collection_pcie > 0} {
      if {$verbose == 1} {
        puts "INFO:   Processing Testin SDC exceptions"
      }
      set_false_path -from $testin_collection_pcie
      set_false_path -to   $testin_collection_pcie
    } else {
      if {$verbose == 1} {
        puts "WARNING: No SDC exception -- Testin signals not found"
      }
	}
    ## Polarity invers
    set dbg_rx_data_size_collection_pcie 0
    set dbg_rx_data_collection_pcie [get_registers -nowarn "$inst_prefix|altpcie_a10_hip_pipen1b|dbg_rx_data_reg $inst_prefix|altpcie_a10_hip_pipen1b|dbg_rx_datak_reg[*]"]
  
    set dbg_rx_data_size_collection_pcie [get_collection_size $dbg_rx_data_collection_pcie]
    if {$dbg_rx_data_size_collection_pcie > 0} {
        puts "INFO:   Processing Polarity Inversion soft logic SDC exceptions - data and datak"
        set from_node_list         [get_keepers -nowarn         $inst_prefix|altpcie_a10_hip_pipen1b|wys~pld_clk.reg]
	    set to_node_rx_data_reg    [get_keepers -nowarn         $inst_prefix|altpcie_a10_hip_pipen1b|dbg_rx_data_reg*]
	    set to_node_rx_datak_reg   [get_keepers -nowarn         $inst_prefix|altpcie_a10_hip_pipen1b|dbg_rx_datak_reg*]
	  	set to_node_rx_data_reg_1  [get_keepers -nowarn         $inst_prefix|altpcie_a10_hip_pipen1b|dbg_rx_data_reg_1*]
	  	set to_node_rx_datak_reg_1 [get_keepers -nowarn         $inst_prefix|altpcie_a10_hip_pipen1b|dbg_rx_datak_reg_1*]
	  	set_max_skew -from $from_node_list -to $to_node_rx_data_reg 6.5
	  	set_max_skew -from $from_node_list -to $to_node_rx_datak_reg 6.5
        set_max_skew -from $from_node_list -to $to_node_rx_data_reg_1 6.5
        set_max_skew -from $from_node_list -to $to_node_rx_datak_reg_1 6.5
       
        set_max_delay -from $from_node_list -to $to_node_rx_data_reg 10.000
        set_max_delay -from $from_node_list -to $to_node_rx_datak_reg 10.000
        set_max_delay -from $from_node_list -to $to_node_rx_data_reg_1 10.000
        set_max_delay -from $from_node_list -to $to_node_rx_datak_reg_1 10.
        set dbg_rx_valid_altpcie_sc_bitsync  [get_registers -nowarn $inst_prefix|altpcie_a10_hip_pipen1b|rx_polinv_dbg.dbg_rx_valid*_altpcie_sc_bitsync|altpcie_sc_bitsync|altpcie_sc_bitsync_meta_dff[0] ]
        if {[get_collection_size $dbg_rx_valid_altpcie_sc_bitsync] > 0} {
            foreach_in_collection reg $dbg_rx_valid_altpcie_sc_bitsync {
                if {$verbose == 1} {
                    puts "INFO:   Processing Polarity Inversion soft logic SDC exceptions - rx_valid bit syncing"
                }
                set_false_path -from $from_node_list -to $dbg_rx_valid_altpcie_sc_bitsync
            }
        } else {
            if {$verbose == 1} {
                puts "WARNING:  No SDC exceptions - rx_valid bit sync signal not found"
            }
        }
        
    } else {
        if {$verbose == 1} {
            puts "WARNING:  No SDC exception -- Polarity inversion soft logic not found"
        }
    }           
	set tl_cfg_size_collection_pcie 0
	set tl_cfg_collection_pcie [get_pins -compatibility_mode -nocase -nowarn $inst_prefix|altpcie_a10_hip_pipen1b|wys|tl_cfg_add[*]]
	set tl_cfg_collection_size [get_collection_size $tl_cfg_collection_pcie]
	if {$tl_cfg_collection_size > 0} {
        if {$verbose == 1} {
            puts "INFO:   Processing tl_cfg* SDC exceptions"
        }
        set_multicycle_path -setup -through [get_pins -compatibility_mode -nocase -nowarn $inst_prefix|altpcie_a10_hip_pipen1b|wys|tl_cfg_add[*]] 2 
        set_multicycle_path -hold  -through [get_pins -compatibility_mode -nocase -nowarn $inst_prefix|altpcie_a10_hip_pipen1b|wys|tl_cfg_add[*]] 2 
        set_multicycle_path -setup -through [get_pins -compatibility_mode -nocase -nowarn $inst_prefix|altpcie_a10_hip_pipen1b|wys|tl_cfg_ctl[*]] 2 
        set_multicycle_path -hold  -through [get_pins -compatibility_mode -nocase -nowarn $inst_prefix|altpcie_a10_hip_pipen1b|wys|tl_cfg_ctl[*]] 2
	} else {
	    if {$verbose == 1} {
	        puts  "WARNING:  No SDC exception -- tl_cfg* signals not found"
	    }
	}