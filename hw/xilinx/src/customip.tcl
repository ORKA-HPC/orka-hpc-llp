#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
## Integrate custom user IP into block design ################################
set clk_src [lindex $argv 0]

#TODO make sure user ip is 64-bit capable if necessary: set config_interface -m_axi_addr64 in Vivado HLS

#TODO bugfix: only pcie clk working for stream design?
#if { ${infrastructure_type} == "stream" } {
#    set use_clock "pcie"
#    puts "Connecting custom user IP to pcie clock. Different clock sources not yet supported for stream designs"
#}

#if { ${use_clock} == "new" } {
#    # Create new clocking wizard with 100 MHz Clock
#    # TODO set to desired clock
#    startgroup
#    create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
#    apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {Custom} Manual_Source {Auto}}  [get_bd_pins clk_wiz_0/reset]
#    # Clock source: xdma
#    #apply_bd_automation -rule xilinx.com:bd_rule:board -config { Clk {/xdma_0/axi_aclk (250 MHz)} Manual_Source {Auto}}  [get_bd_pins clk_wiz_0/clk_in1]
#    # Clock source: mig
#    apply_bd_automation -rule xilinx.com:bd_rule:board -config { Clk {/ddr4_0/c0_ddr4_ui_clk (300 MHz)} Manual_Source {Auto}}  [get_bd_pins clk_wiz_0/clk_in1]
#    endgroup
#}

# Get clock port name as it might be needed when adding interface ports before clock port was added
for {set k 0} {$k < [llength ${CIPPortTypes}]} {incr k} {
    set name [lindex $CIPPortNames $k]
    set type [lindex $CIPPortTypes $k]
    if { $type eq "clock" } {
        set clk_port_name $name
    }
}

# ips.tcl contains the clocking information.
# Variable ${CustomIPName}_clk_idx stores the index of the corresponding output on the Clocking Wizard
# The name of the clk_wiz is passed to this script as an argument
set ip_clk_name ${CustomIPName}_clk_idx
# double dereference variable: eval adds [] brackets around value...
set ip_clk_idx [regsub -all {[][]} [eval $$ip_clk_name] ""]

set regnum ""; # variable to cope with naming scheme for axilite registers...
# loop over ports and connect them
for {set k 0} {$k < [llength ${CIPPortTypes}]} {incr k} {
    set name [lindex $CIPPortNames $k]
    set type [lindex $CIPPortTypes $k]
    set mode [lindex $CIPPortModes $k]

    puts "trying to connect ${type}:${mode}:${name}"

    # Clock ###################################################################
    if { ${type} eq "clock" } {
        set driving_pin [get_bd_pins -of_objects [get_bd_nets -of_objects [get_bd_pins ${CustomIPName}/${name}]] -filter {DIRECTION=="OUT"}]
        if { $driving_pin == "" && ${enable_autoconnect} == "1" } {
#            if { ${use_clock} == "new" } {
#                connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins ${CustomIPName}/${name}]
#            } elseif { ${use_clock} == "dma"} {
#                startgroup
#                connect_bd_net [get_bd_pins ${CustomIPName}/${name}] [get_bd_pins ddr4_0/c0_ddr4_ui_clk]
#                endgroup
#            } else {
#                connect_bd_net [get_bd_pins ${CustomIPName}/${name}] [get_bd_pins xdma_0/axi_aclk]
#            }

            # clk_wiz is 1 based whereas index is 0 based..
            connect_bd_net [get_bd_pins $clk_src/clk_out[expr ${ip_clk_idx} + 1]] [get_bd_pins ${CustomIPName}/${name}]
        }

    # Reset ###################################################################
    } elseif { ${type} eq "reset" } {
        set driving_pin [get_bd_pins -of_objects [get_bd_nets -of_objects [get_bd_pins ${CustomIPName}/${name}]] -filter {DIRECTION=="OUT"}]
        if { $driving_pin == "" && ${enable_autoconnect} == "1" } {
#            if { ${use_clock} == "new" } {
#            #TODO
#                startgroup
#                create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
#                connect_bd_net [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins ddr4_0/c0_ddr4_ui_clk]
#                connect_bd_net [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst]
#                connect_bd_net [get_bd_pins ${CustomIPName}/${name}] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
#                endgroup
#            } elseif { ${use_clock} == "dma"} {
#                connect_bd_net [get_bd_pins ${CustomIPName}/${name}] [get_bd_pins rst_ddr4_0_300M/peripheral_aresetn]
#            } else {
#                connect_bd_net [get_bd_pins ${CustomIPName}/${name}] [get_bd_pins xdma_0/axi_aresetn]
#            }
#            connect_bd_net [get_bd_pins ${CustomIPName}/${name}] [get_bd_pins ${clk_src}/reset]
            connect_bd_net [get_bd_pins ${CustomIPName}/${name}] [get_bd_pins hls_reset_${ip_clk_idx}/peripheral_aresetn]
        }

    # Interrupt ###############################################################
    } elseif { ${type} eq "interrupt" } {
        set nets [get_bd_nets -of_objects [get_bd_pins ${CustomIPName}/${name}]]
        if { $nets == "" && ${enable_autoconnect} == "1" } {
            if { ${enable_axi_intc} == 1 } {
                startgroup
                set current_interrupt_ports [get_property CONFIG.NUM_PORTS [get_bd_cells xlconcat_0]]
                set current_interrupt_ports [expr $current_interrupt_ports - 1]
                if { [get_bd_nets -of_objects [get_bd_pins xlconcat_0/In${current_interrupt_ports}]] != "" } {
                    incr current_interrupt_ports
                    set_property -dict [list CONFIG.NUM_PORTS [expr ${current_interrupt_ports} + 1]] [get_bd_cells xlconcat_0]
                }
                connect_bd_net [get_bd_pins xlconcat_0/In${current_interrupt_ports}] [get_bd_pins ${CustomIPName}/${name}]
                endgroup
            }
        }

    # Memory Mapped AXI #######################################################
    # (can be m_axi or axi_lite and both master or slave)
    } elseif { ${type} eq "aximm" } {
        set nets [get_bd_intf_nets -of_objects [get_bd_intf_pins ${CustomIPName}/${name}]]
        if { $nets == "" && ${enable_autoconnect} == "1" } {
            #TODO how to decide if axim or axilite? using master/slave as indication for now. need to get this somewhere in the properties
            if { ${mode} eq "slave" } {
                startgroup
#                apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/xdma_0/axi_aclk (250 MHz)} Clk_slave {Auto} Clk_xbar {/xdma_0/axi_aclk (250 MHz)} Master {/xdma_0/M_AXI_LITE} Slave {/${CustomIPName}/${name}} intc_ip {/axi_periph_interconnect} master_apm {0}}  [get_bd_intf_pins ${CustomIPName}/${name}]
                set tmp [get_property CONFIG.NUM_MI [get_bd_cells axi_periph_interconnect]]
                set_property CONFIG.NUM_MI [expr ${tmp} + 1] [get_bd_cells axi_periph_interconnect]
                if {$tmp < 10} {set tmp "0${tmp}"}
                connect_bd_intf_net [get_bd_intf_pins ${CustomIPName}/${name}] [get_bd_intf_pins axi_periph_interconnect/M${tmp}_AXI]
                #TODO find names of clock and reset port
                connect_bd_net [get_bd_pins ${CustomIPName}/ap_clk] [get_bd_pins axi_periph_interconnect/M${tmp}_ACLK]
                connect_bd_net [get_bd_pins ${CustomIPName}/ap_rst_n] [get_bd_pins axi_periph_interconnect/M${tmp}_ARESETN]
                endgroup
                startgroup
                assign_bd_address [get_bd_addr_segs {${CustomIPName}/${name}/Reg${regnum}}]
                if { ${enable_pcie} == "1" } {
                    set_property offset "0x$axilite_offset" [get_bd_addr_segs xdma_0/M_AXI_LITE/SEG_${CustomIPName}_Reg${regnum}]
                }
                if { ${enable_microblaze} == "1" } {
                    set_property offset "0x$axilite_offset" [get_bd_addr_segs microblaze_0/Data/SEG_${CustomIPName}_Reg${regnum}]
                    set_property offset "0x$axilite_offset" [get_bd_addr_segs microblaze_0/Instruction/SEG_${CustomIPName}_Reg${regnum}]
                }
                # increase counter for axilite registers (in case ip has multiple axilite ports)
                if { $regnum eq "" } { set regnum 1 } else { incr regnum }
                # increase offset for axilite registers for upcoming ports/ips
                set axilite_offset [expr {$axilite_offset + 10000}]
                endgroup
            } elseif { ${mode} eq "master" } {
                if { ${enable_mig} == 1 } {
#                    if {${enable_ip_cache} == 1} {
#                        startgroup
#                        # Create System Cache IP
#                        create_bd_cell -type ip -vlnv xilinx.com:ip:system_cache:4.0 system_cache_0
#                        # Configure Cache IP
#                        set_property -dict [list CONFIG.C_NUM_WAYS {${ip_cache_set_associativity}} CONFIG.C_CACHE_SIZE {${ip_cache_size}}] [get_bd_cells system_cache_0]
#                        # Connect System Cache IP to Custom IP
#                        #TODO loop if multiple master ports are used
#                        connect_bd_intf_net [get_bd_intf_pins system_cache_0/S0_AXI] [get_bd_intf_pins ${CustomIPName}/${name_m_prefix}${name_master}${name_m_index}${name_suffix}]
#                
#                        # Connect System Cache IP to AXI SMC
#                        #TODO make this fail-safe.. apply_bd_automation won't accept variables
#                #        apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_out1 (100 MHz)} Clk_slave {/ddr4_0/c0_ddr4_ui_clk (300 MHz)} Clk_xbar {/ddr4_0/c0_ddr4_ui_clk (300 MHz)} Master {/system_cache_0/M0_AXI} Slave {/ddr4_0/C0_DDR4_S_AXI} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins system_cache_0/M0_AXI]
#                        if { ${infrastructure_type} == "dma" } {
#                            set tmp [get_property CONFIG.NUM_SI [get_bd_cells axi_smc]]
#                            # incr port count on axi smc
#                            set_property CONFIG.NUM_SI [expr ${tmp} + 1] [get_bd_cells axi_smc]
#                            connect_bd_intf_net [get_bd_intf_pins system_cache_0/M0_AXI] [get_bd_intf_pins axi_smc/S0${tmp}_AXI]
#                        } elseif { ${infrastructure_type} == "stream"} {
#                            create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc
#                            set_property -dict [list CONFIG.NUM_SI {1}] [get_bd_cells axi_smc]
#                            apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {New External Port (ACTIVE_HIGH)}}  [get_bd_pins ddr4_0/sys_rst]
#                            connect_bd_intf_net [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
#                #            set tmp [expr {$tmp - 1}]
#                #TODO
#                puts "not implemented.. aborting"
#                return
#                #            connect_bd_intf_net [get_bd_intf_pins system_cache_0/M0_AXI] [get_bd_intf_pins axi_smc/S00_AXI]
#                            apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/ddr4_0/c0_ddr4_ui_clk (300 MHz)} Clk_xbar {Auto} Master {/${CustomIPName}/${name_m_prefix}${name_master}${name_m_index}${name_suffix}} Slave {/ddr4_0/C0_DDR4_S_AXI} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins ${CustomIPName}/${name_m_prefix}${name_master}${name_m_index}${name_suffix}]
#                        }
#                        endgroup
#                    } else {
                        # Connect IP directly to AXI SMC
                        set tmp [get_property CONFIG.NUM_SI [get_bd_cells axi_smc]]
                        set_property CONFIG.NUM_SI [expr ${tmp} + 1] [get_bd_cells axi_smc]
                        if { $tmp <= 9 } {
                            connect_bd_intf_net [get_bd_intf_pins ${CustomIPName}/${name}] [get_bd_intf_pins axi_smc/S0${tmp}_AXI]
                        } else {
                            connect_bd_intf_net [get_bd_intf_pins ${CustomIPName}/${name}] [get_bd_intf_pins axi_smc/S${tmp}_AXI]
                        }
                        # check if clock already connected to axi_smc
                        set pins [get_bd_pins -of_objects [get_bd_nets -of_objects [get_bd_pins ${CustomIPName}/${clk_port_name}]]]
                        set clk_already_connected 0
                        for { set x 0 } { $x < [llength $pins] } { incr x } {
                            if { [string range [lindex $pins $x] 0 8] eq "/axi_smc/" } {
                                set clk_already_connected 1
                            }
                        }
                        if { ${clk_already_connected} == 0 } {
                            # connect clock to axi_smc
                            set tmp [get_property CONFIG.NUM_CLKS [get_bd_cells axi_smc]]
                            set_property CONFIG.NUM_CLKS [expr $tmp + 1] [get_bd_cells axi_smc]
                            connect_bd_net [get_bd_pins axi_smc/aclk${tmp}] [get_bd_pins ${CustomIPName}/${clk_port_name}]
                        }

                        assign_bd_address [get_bd_addr_segs {ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK}]
                        set_property range  4K                [get_bd_addr_segs ${CustomIPName}/Data_${name}/SEG_mig_0_${MIG_ADDR_POSTFIX}]
                        set_property offset ${axifull_offset} [get_bd_addr_segs ${CustomIPName}/Data_${name}/SEG_mig_0_${MIG_ADDR_POSTFIX}]
                        set_property range  ${axifull_range}  [get_bd_addr_segs ${CustomIPName}/Data_${name}/SEG_mig_0_${MIG_ADDR_POSTFIX}]
                        if { $enable_second_ddr_dimm == "1" } {
                            assign_bd_address [get_bd_addr_segs {ddr4_1/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK}]
                            set_property range  4K                 [get_bd_addr_segs ${CustomIPName}/Data_${name}/SEG_mig_1_${MIG_ADDR_POSTFIX}]
                            set_property offset ${axifull2_offset} [get_bd_addr_segs ${CustomIPName}/Data_${name}/SEG_mig_1_${MIG_ADDR_POSTFIX}]
                            set_property range  ${axifull2_range}  [get_bd_addr_segs ${CustomIPName}/Data_${name}/SEG_mig_1_${MIG_ADDR_POSTFIX}]
                        }
#                    }
                }
            } else {
                puts "Error: Memory Mapped AXI Interface is neither slave nor master"
            }
        }

    # FIFO Read ###############################################################
    } elseif { ${type} eq "acc_fifo_read" } {
        set nets [get_bd_intf_nets -of_objects [get_bd_intf_pins ${CustomIPName}/${name}]]
        if { $nets == "" && ${enable_autoconnect} == "1" } {
            puts "currently unsupported fifo port will be ignored"
        }

    # FIFO Write ##############################################################
    } elseif { ${type} eq "acc_fifo_write" } {
        set nets [get_bd_intf_nets -of_objects [get_bd_intf_pins ${CustomIPName}/${name}]]
        if { $nets == "" && ${enable_autoconnect} == "1" } {
            puts "currently unsupported fifo port will be ignored"
        }

    # AXI Stream #########################################################
    } elseif { ${type} eq "axis" } {
        set nets [get_bd_intf_nets -of_objects [get_bd_intf_pins ${CustomIPName}/${name}]]
        if { $nets == "" && ${enable_autoconnect} == "1" } {
#TODO     where to connect ports to? needs to parameterized/set in settings...
            if { ${infrastructure_type} == "stream" } {
                startgroup
                # connect h2c
                for {set i 0} {$i < ${h2c_channels}} {incr i} {
                    if { [get_bd_intf_nets -of_objects [get_bd_intf_pins xdma_0/M_AXIS_H2C_${i}]] == "" } {
                        connect_bd_intf_net [get_bd_intf_pins $CustomIPName/${name}] [get_bd_intf_pins xdma_0/M_AXIS_H2C_${i}]
                    }
                }
                #connect c2h
                for {set i 0} {$i < ${c2h_channels}} {incr i} {
                    if { [get_bd_intf_nets -of_objects [get_bd_intf_pins xdma_0/M_AXIS_C2H_${i}]] == "" } {
                        connect_bd_intf_net [get_bd_intf_pins $CustomIPName/${name}] [get_bd_intf_pins xdma_0/S_AXIS_C2H_${i}]
                    }
                }
                endgroup
            }
        }

    # BRAM ####################################################################
    } elseif { ${type} eq "bram" } {
        set nets [get_bd_intf_nets -of_objects [get_bd_intf_pins ${CustomIPName}/${name}]]
        if { $nets == "" && ${enable_autoconnect} == "1" } {
            # TODO customize ip in catalog and set size
            #
            # TODO make it possible to choose if bram should be accessible through axi or not
            #apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "New Blk_Mem_Gen" }  [get_bd_intf_pins ${CustomIPName}/${name}]
            
            startgroup
            # bram generator
            create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen ${CustomIPName}_bram
            set_property -dict [list \
                CONFIG.Memory_Type {True_Dual_Port_RAM} \
                CONFIG.Enable_B {Use_ENB_Pin} \
                CONFIG.Use_RSTB_Pin {true} \
                CONFIG.Port_B_Clock {100} \
                CONFIG.Port_B_Write_Rate {50} \
                CONFIG.Port_B_Enable_Rate {100} \
                ] [get_bd_cells ${CustomIPName}_bram]
            # AXI BRAM Controller
            create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl ${CustomIPName}_axi_bram_ctrl
            set_property -dict [list \
                CONFIG.PROTOCOL {AXI4LITE} \
                CONFIG.SINGLE_PORT_BRAM {1} \
                CONFIG.ECC_TYPE {0} \
                ] [get_bd_cells ${CustomIPName}_axi_bram_ctrl]
            connect_bd_net [get_bd_pins $clk_src/clk_out[expr ${ip_clk_idx} + 1]] [get_bd_pins ${CustomIPName}_axi_bram_ctrl/s_axi_aclk]
            connect_bd_net [get_bd_pins hls_reset_${ip_clk_idx}/peripheral_aresetn] [get_bd_pins ${CustomIPName}_axi_bram_ctrl/s_axi_aresetn]
            # connections
            connect_bd_intf_net [get_bd_intf_pins ${CustomIPName}_axi_bram_ctrl/BRAM_PORTA] [get_bd_intf_pins ${CustomIPName}_bram/BRAM_PORTA]
            connect_bd_intf_net [get_bd_intf_pins ${CustomIPName}/${name}] [get_bd_intf_pins ${CustomIPName}_bram/BRAM_PORTB]
            endgroup

            # connect axi bram controller to axi-lite smc
            startgroup
            set tmp [get_property CONFIG.NUM_MI [get_bd_cells axi_periph_interconnect]]
            set_property CONFIG.NUM_MI [expr ${tmp} + 1] [get_bd_cells axi_periph_interconnect]
            #TODO this will fail if tmp > 9
            if {$tmp < 10} {set tmp "0${tmp}"}
            connect_bd_intf_net [get_bd_intf_pins ${CustomIPName}_axi_bram_ctrl/S_AXI] [get_bd_intf_pins axi_periph_interconnect/M${tmp}_AXI]
            #TODO find names of clock and reset port
            connect_bd_net [get_bd_pins ${CustomIPName}_axi_bram_ctrl/s_axi_aclk] [get_bd_pins axi_periph_interconnect/M${tmp}_ACLK]
            connect_bd_net [get_bd_pins ${CustomIPName}_axi_bram_ctrl/s_axi_aresetn] [get_bd_pins axi_periph_interconnect/M${tmp}_ARESETN]
            assign_bd_address [get_bd_addr_segs {${CustomIPName}_axi_bram_ctrl/S_AXI/Mem0}]
            if { ${enable_pcie} == "1" } {
                set_property offset "0x$axilite_offset" [get_bd_addr_segs xdma_0/M_AXI_LITE/SEG_${CustomIPName}_axi_bram_ctrl_Mem0]
            }
            if { ${enable_microblaze} == "1" } {
                set_property offset "0x$axilite_offset" [get_bd_addr_segs microblaze_0/Data/SEG_${CustomIPName}_axi_bram_ctrl_Mem0]
                set_property offset "0x$axilite_offset" [get_bd_addr_segs microblaze_0/Instruction/SEG_${CustomIPName}_axi_bram_ctrl_Mem0]
            }
            # TODO replace "Mem0" with a counter in case the IP has multiple bram ports? compare with axilite port...
            # increase offset for axilite registers for upcoming ports/ips
            set axilite_offset [expr {$axilite_offset + 10000}]
            endgroup
        }


    # Unsupported port types ##################################################
    } else {
        puts "Potential error: unknown port type."
    }

}

puts "Automatic port connection for ${CustomIPName} done."
