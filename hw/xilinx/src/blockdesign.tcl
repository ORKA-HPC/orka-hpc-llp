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
################################################################
# Check if script is running in correct Vivado version.
################################################################


################################################################
# START
################################################################

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}

set design_name $bd_design_name
create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: design_name is \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

### DMA ###
#startgroup
#create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0
#set_property -dict [list CONFIG.c_include_sg {0} CONFIG.c_sg_include_stscntrl_strm {0} CONFIG.c_include_mm2s {1} CONFIG.c_addr_width {64}] [get_bd_cells axi_dma_0]
#connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/M01_AXI] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
#apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/mig_0/c0_ddr4_ui_clk (300 MHz)" }  [get_bd_pins axi_periph_interconnect/M01_ACLK]
#connect_bd_net [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins mig_0/c0_ddr4_ui_clk]
#connect_bd_net [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins rst_mig_0_300M/peripheral_aresetn]
##apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "New Clocking Wizard (100 MHz)" }  [get_bd_pins xdma_0_axi_periph/ACLK]
#endgroup

## AXI Interconnect for AXI Lite (compatibility to MicroBlaze)
#set any_periph [expr ${enable_system_management} || ${enable_axi_perf_monitor} || ${enable_gpio} || ${enable_axi_iic} || ${enable_axi_intc} || ${enable_axi_timer} || ${enable_usb_uart} || ($enable_custom_ip == 1 && $has_axi_lite_ctrl_port == 1) ] 
set any_periph 1
if { ${any_periph} == "1" } {
    ## Clk for peripheral components
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 periph_clk_wiz
    if { [file exists "${root_path}/src/detail/${platform_name}/periph_clk_wiz.tcl"] } {
        source "${root_path}/src/detail/${platform_name}/periph_clk_wiz.tcl"
    } else {
        puts "Error: Board-specifc script for periph_clk_wiz is missing."
        return
    }
    endgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_periph_interconnect
    apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/periph_clk_wiz/clk_out1 (100 MHz)" }  [get_bd_pins axi_periph_interconnect/ACLK]
    set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {1}] [get_bd_cells axi_periph_interconnect]
}
## AXI SMC for AXI Full
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_smc
set_property CONFIG.NUM_SI {1} [get_bd_cells axi_smc]


## DDR4 #######################################################################
if {${enable_microblaze} == 1 } { set enable_mig 1 }
if {${enable_mig} == 1 } {
    if { [file exists "${root_path}/src/detail/${platform_name}/mig.tcl"] } {
        source "${root_path}/src/detail/${platform_name}/mig.tcl"
    } else {
        puts "Error: Board-specifc script for MIG is missing."
        return
    }
}


## PCIe #######################################################################
if { ${enable_pcie} == "1" } {
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:xdma xdma_0
    apply_board_connection -board_interface "pci_express_x${pcie_lane_width}" -ip_intf "xdma_0/pcie_mgt" -diagram $design_name
    apply_board_connection -board_interface "pcie_perstn" -ip_intf "xdma_0/RST.sys_rst_n" -diagram $design_name
    endgroup
    if { ${infrastructure_type} == "dma" } {
    ## PCIe DMA-Engine ############################################################
        #TODO can't use variables in apply_bd_automation ?! ... get rid of if/else
        if { $pcie_lane_width == "1" } {
            apply_bd_automation -rule xilinx.com:bd_rule:xdma -config { accel {1} auto_level {IP Level} axi_clk {Maximum Data Width} axi_intf {AXI Memory Mapped} bar_size {1 (Megabytes)} bypass_size {Disable} c2h {1} cache_size {32k} h2c {1} lane_width {X1} link_speed {8.0 GT/s (PCIe Gen 3)}}  [get_bd_cells xdma_0]
        } elseif { $pcie_lane_width == "4" } {
            apply_bd_automation -rule xilinx.com:bd_rule:xdma -config { accel {1} auto_level {IP Level} axi_clk {Maximum Data Width} axi_intf {AXI Memory Mapped} bar_size {1 (Megabytes)} bypass_size {Disable} c2h {1} cache_size {32k} h2c {1} lane_width {X4} link_speed {8.0 GT/s (PCIe Gen 3)}}  [get_bd_cells xdma_0]
        } elseif { $pcie_lane_width == "8" } {
            apply_bd_automation -rule xilinx.com:bd_rule:xdma -config { accel {1} auto_level {IP Level} axi_clk {Maximum Data Width} axi_intf {AXI Memory Mapped} bar_size {1 (Megabytes)} bypass_size {Disable} c2h {1} cache_size {32k} h2c {1} lane_width {X8} link_speed {8.0 GT/s (PCIe Gen 3)}}  [get_bd_cells xdma_0]
        } elseif { $pcie_lane_width == "16" } {
            apply_bd_automation -rule xilinx.com:bd_rule:xdma -config { accel {1} auto_level {IP Level} axi_clk {Maximum Data Width} axi_intf {AXI Memory Mapped} bar_size {1 (Megabytes)} bypass_size {Disable} c2h {1} cache_size {32k} h2c {1} lane_width {X16} link_speed {8.0 GT/s (PCIe Gen 3)}}  [get_bd_cells xdma_0]
        } 
        set_property -dict [list CONFIG.xdma_pcie_64bit_en {true} CONFIG.pf0_msix_cap_table_bir {BAR_3:2} CONFIG.pf0_msix_cap_pba_bir {BAR_3:2}] [get_bd_cells xdma_0]
        set_property -dict [list CONFIG.pf0_base_class_menu {Memory_controller} CONFIG.pf0_class_code_base {05} CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} CONFIG.pf0_class_code_sub {80} CONFIG.pf0_class_code_interface {00} CONFIG.pf0_class_code {058000} CONFIG.cfg_mgmt_if {true}] [get_bd_cells xdma_0]
    } elseif { ${infrastructure_type} == "stream" } {
    ## PCIe Stream-Engine #########################################################
        startgroup
        #TODO can't use variables in apply_bd_automation ?! ... get rid of if/else and integrate h2c/c2h channels
        if { $pcie_lane_width == "1" } {
            apply_bd_automation -rule xilinx.com:bd_rule:xdma -config { accel {1} auto_level {IP Level} axi_clk {Maximum Data Width} axi_intf {AXI Stream} bar_size {1 (Megabytes)} bypass_size {Disable} c2h {1} cache_size {32k} h2c {1} lane_width {X1} link_speed {8.0 GT/s (PCIe Gen 3)}}  [get_bd_cells xdma_0]
        } elseif { $pcie_lane_width == "4" } {
            apply_bd_automation -rule xilinx.com:bd_rule:xdma -config { accel {1} auto_level {IP Level} axi_clk {Maximum Data Width} axi_intf {AXI Stream} bar_size {1 (Megabytes)} bypass_size {Disable} c2h {1} cache_size {32k} h2c {1} lane_width {X4} link_speed {8.0 GT/s (PCIe Gen 3)}}  [get_bd_cells xdma_0]
        } elseif { $pcie_lane_width == "8" } {
            apply_bd_automation -rule xilinx.com:bd_rule:xdma -config { accel {1} auto_level {IP Level} axi_clk {Maximum Data Width} axi_intf {AXI Stream} bar_size {1 (Megabytes)} bypass_size {Disable} c2h {1} cache_size {32k} h2c {1} lane_width {X8} link_speed {8.0 GT/s (PCIe Gen 3)}}  [get_bd_cells xdma_0]
        } elseif { $pcie_lane_width == "16" } {
            apply_bd_automation -rule xilinx.com:bd_rule:xdma -config { accel {1} auto_level {IP Level} axi_clk {Maximum Data Width} axi_intf {AXI Stream} bar_size {1 (Megabytes)} bypass_size {Disable} c2h {1} cache_size {32k} h2c {1} lane_width {X16} link_speed {8.0 GT/s (PCIe Gen 3)}}  [get_bd_cells xdma_0]
        } 
        endgroup
    }
#TODO calc number of channels in configurator?
#    # set number of c2h/h2c channels
#    if { ${infrastructure_type} == "stream" } {
#        set h2c_channels [expr max($h2c_channels,$stream_h2c_channels)]
#        set c2h_channels [expr max($c2h_channels,$stream_c2h_channels)]
#    }
    set_property CONFIG.xdma_rnum_chnl $h2c_channels [get_bd_cells xdma_0]
    set_property CONFIG.xdma_wnum_chnl $c2h_channels [get_bd_cells xdma_0]
    # set axilite BAR size to 512 MB
    set axilite_bar_size "512MB"
    set_property -dict [list CONFIG.axilite_master_size {512} CONFIG.axilite_master_scale {Megabytes}] [get_bd_cells xdma_0]
    # can't change axifull BAR size but store in variable for printaddr.tcl
    set axifull_bar_size "64KB"
    # MCAP
    if { [info exists enable_mcap] } {
        #TODO PR_over_PCIe does not exist anymore in Vivado 20.1
        # instead there is a new option: DFX_over_PCIe
        set_property -dict [list CONFIG.mode_selection {Advanced} CONFIG.mcap_enablement $enable_mcap] [get_bd_cells xdma_0]
    }
    if { ${any_periph} } {
    #TODO else: disable axi-lite interface
        set num_p [get_property CONFIG.NUM_SI [get_bd_cells axi_periph_interconnect]]
        set pn [expr $num_p - 1]
        if {$pn < 10} {set pn "0${pn}"}
        if { [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_periph_interconnect/S${pn}_AXI]] != "" } {
            incr num_p
            set_property CONFIG.NUM_SI $num_p [get_bd_cells axi_periph_interconnect]
            set pn [scan $pn %d]
            incr pn
            if {$pn < 10} {set pn "0${pn}"}
        }
        connect_bd_intf_net [get_bd_intf_pins xdma_0/M_AXI_LITE] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/S${pn}_AXI]
        connect_bd_net [get_bd_pins axi_periph_interconnect/S${pn}_ACLK] [get_bd_pins xdma_0/axi_aclk]
        connect_bd_net [get_bd_pins axi_periph_interconnect/S${pn}_ARESETN] [get_bd_pins xdma_0/axi_aresetn]
    }
    if { $enable_mig && $infrastructure_type == "dma" } {
        apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/xdma_0/axi_aclk (250 MHz)} Clk_slave {/mig_0/c0_ddr4_ui_clk (300 MHz)} Clk_xbar {/mig_0/c0_ddr4_ui_clk (300 MHz)} Master {/xdma_0/M_AXI} Slave {/mig_0/C0_DDR4_S_AXI} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins xdma_0/M_AXI]
    }
}

## GPIO #######################################################################
if {${enable_gpio} == 1} {
    if { [file exists "${root_path}/src/detail/${platform_name}/gpio.tcl"] } {
        source "${root_path}/src/detail/${platform_name}/gpio.tcl"
    } else {
        puts "Error: Board-specifc script for GPIO is missing."
        return
    }
}


## System Management Wizard ###################################################
if { ${enable_system_management} == 1 } {
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:system_management_wiz:1.3 system_management_wiz_0
    set_property -dict [list CONFIG.DCLK_FREQUENCY {250} CONFIG.CHANNEL_AVERAGING {16} CONFIG.AVERAGE_ENABLE_VBRAM {true} CONFIG.AVERAGE_ENABLE_TEMPERATURE {true} CONFIG.AVERAGE_ENABLE_VCCINT {true} CONFIG.AVERAGE_ENABLE_VCCAUX {true} CONFIG.OT_ALARM {false} CONFIG.USER_TEMP_ALARM {false} CONFIG.VCCINT_ALARM {false} CONFIG.VCCAUX_ALARM {false} ] [get_bd_cells system_management_wiz_0]
    set num_p [get_property CONFIG.NUM_MI [get_bd_cells axi_periph_interconnect]]
    set pn [expr $num_p - 1]
    if {$pn < 10} {set pn "0${pn}"}
    if { [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]] != "" } {
        incr num_p
        set_property CONFIG.NUM_MI $num_p [get_bd_cells axi_periph_interconnect]
        set pn [scan $pn %d]
        incr pn
        if {$pn < 10} {set pn "0${pn}"}
    }
    connect_bd_intf_net [get_bd_intf_pins system_management_wiz_0/S_AXI_LITE] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]
    connect_bd_net [get_bd_pins system_management_wiz_0/s_axi_aclk] [get_bd_pins periph_clk_wiz/clk_out1]
    connect_bd_net [get_bd_pins system_management_wiz_0/s_axi_aresetn] [get_bd_pins periph_clk_wiz_reset/peripheral_aresetn]
    connect_bd_net [get_bd_pins system_management_wiz_0/s_axi_aclk] [get_bd_pins axi_periph_interconnect/M${pn}_ACLK]
    connect_bd_net [get_bd_pins system_management_wiz_0/s_axi_aresetn] [get_bd_pins axi_periph_interconnect/M${pn}_ARESETN]

    create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn
    connect_bd_intf_net [get_bd_intf_pins system_management_wiz_0/Vp_Vn] [get_bd_intf_ports Vp_Vn]
    endgroup
}


## AXI Performance Monitor ####################################################
if { ${enable_axi_perf_monitor} == 1 && ${enable_pcie} == 1 } {
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_perf_mon:5.0 axi_perf_mon_0
    connect_bd_intf_net [get_bd_intf_pins axi_perf_mon_0/SLOT_0_AXI] [get_bd_intf_pins mig_0/${AXI_MM_PORT_NAME}]
    connect_bd_intf_net [get_bd_intf_pins axi_perf_mon_0/SLOT_1_AXI] [get_bd_intf_pins xdma_0/M_AXI]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/xdma_0/axi_aclk (250 MHz)} Clk_slave {/xdma_0/axi_aclk (250 MHz)} Clk_xbar {/xdma_0/axi_aclk (250 MHz)} Master {/xdma_0/M_AXI_LITE} Slave {/axi_perf_mon_0/S_AXI} intc_ip {/axi_periph_interconnect} master_apm {0}}  [get_bd_intf_pins axi_perf_mon_0/S_AXI]
    apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/xdma_0/axi_aclk (250 MHz)" }  [get_bd_pins axi_perf_mon_0/slot_0_axi_aclk]
    apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/xdma_0/axi_aclk (250 MHz)" }  [get_bd_pins axi_perf_mon_0/core_aclk]
    connect_bd_net [get_bd_pins axi_perf_mon_0/core_aresetn] [get_bd_pins xdma_0/axi_aresetn]
    endgroup
}


## AXI IIC ####################################################################
if { ${enable_axi_iic} == 1 } {
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 axi_iic_0
    set num_p [get_property CONFIG.NUM_MI [get_bd_cells axi_periph_interconnect]]
    set pn [expr $num_p - 1]
    if {$pn < 10} {set pn "0${pn}"}
    if { [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]] != "" } {
        incr num_p
        set_property CONFIG.NUM_MI $num_p [get_bd_cells axi_periph_interconnect]
        set pn [scan $pn %d]
        incr pn
        if {$pn < 10} {set pn "0${pn}"}
    }
    connect_bd_intf_net [get_bd_intf_pins axi_iic_0/S_AXI] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]
    connect_bd_net [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins periph_clk_wiz/clk_out1]
    connect_bd_net [get_bd_pins axi_iic_0/s_axi_aresetn] [get_bd_pins periph_clk_wiz_reset/peripheral_aresetn]
    connect_bd_net [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins axi_periph_interconnect/M${pn}_ACLK]
    connect_bd_net [get_bd_pins axi_iic_0/s_axi_aresetn] [get_bd_pins axi_periph_interconnect/M${pn}_ARESETN]
    apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {iic_main ( IIC ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_iic_0/IIC]
    endgroup
}


## AXI Timer ##################################################################
if { ${enable_axi_timer} == 1 } {
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0
    set num_p [get_property CONFIG.NUM_MI [get_bd_cells axi_periph_interconnect]]
    set pn [expr $num_p - 1]
    if {$pn < 10} {set pn "0${pn}"}
    if { [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]] != "" } {
        incr num_p
        set_property CONFIG.NUM_MI $num_p [get_bd_cells axi_periph_interconnect]
        set pn [scan $pn %d]
        incr pn
        if {$pn < 10} {set pn "0${pn}"}
    }
    connect_bd_intf_net [get_bd_intf_pins axi_timer_0/S_AXI] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]
    connect_bd_net [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins periph_clk_wiz/clk_out1]
    connect_bd_net [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins periph_clk_wiz_reset/peripheral_aresetn]
    connect_bd_net [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins axi_periph_interconnect/M${pn}_ACLK]
    connect_bd_net [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins axi_periph_interconnect/M${pn}_ARESETN]
    endgroup
}


## USB UART ###################################################################
if { ${enable_usb_uart} == "1" || ${enable_usb_uart_lite} == "1" } {
    startgroup

    if { ${enable_usb_uart} == "1" } {
        # Full
        create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart
        apply_board_connection -board_interface "rs232_uart" -ip_intf "axi_uart/UART" -diagram "axi_pcie_mig" 
        set UART_INTC_NAME "ip2intc_irpt"

    } elseif { ${enable_usb_uart_lite} == "1" } {
        # Lite
        create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uart
        apply_board_connection -board_interface "usb_uart" -ip_intf "axi_uart/UART" -diagram "axi_pcie_mig" 
        set UART_INTC_NAME "interrupt"
        set_property -dict [list CONFIG.C_BAUDRATE {230400}] [get_bd_cells axi_uart]
    }

    set num_p [get_property CONFIG.NUM_MI [get_bd_cells axi_periph_interconnect]]
    set pn [expr $num_p - 1]
    if {$pn < 10} {set pn "0${pn}"}
    if { [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]] != "" } {
        incr num_p
        set_property CONFIG.NUM_MI $num_p [get_bd_cells axi_periph_interconnect]
        set pn [scan $pn %d]
        incr pn
        if {$pn < 10} {set pn "0${pn}"}
    }
    connect_bd_intf_net [get_bd_intf_pins axi_uart/S_AXI] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]
    connect_bd_net [get_bd_pins axi_uart/s_axi_aclk] [get_bd_pins periph_clk_wiz/clk_out1]
    connect_bd_net [get_bd_pins axi_uart/s_axi_aresetn] [get_bd_pins periph_clk_wiz_reset/peripheral_aresetn]
    connect_bd_net [get_bd_pins axi_uart/s_axi_aclk] [get_bd_pins axi_periph_interconnect/M${pn}_ACLK]
    connect_bd_net [get_bd_pins axi_uart/s_axi_aresetn] [get_bd_pins axi_periph_interconnect/M${pn}_ARESETN]
    endgroup
}

if { ${enable_axi_ethernet_lite} == 1 } {
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernetlite axi_ethernet_lite
    apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {eth_mii ( Ethernet MII ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_ethernet_lite/MII]
    apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {eth_mdio_mdc ( Ethernet MII ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_ethernet_lite/MDIO]
    set num_p [get_property CONFIG.NUM_MI [get_bd_cells axi_periph_interconnect]]
    set pn [expr $num_p - 1]
    if {$pn < 10} {set pn "0${pn}"}
    if { [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]] != "" } {
        incr num_p
        set_property CONFIG.NUM_MI $num_p [get_bd_cells axi_periph_interconnect]
        set pn [scan $pn %d]
        incr pn
        if {$pn < 10} {set pn "0${pn}"}
    }
    connect_bd_intf_net [get_bd_intf_pins axi_ethernet_lite/S_AXI] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]
    connect_bd_net [get_bd_pins axi_ethernet_lite/s_axi_aclk]    [get_bd_pins periph_clk_wiz/clk_out1]
    connect_bd_net [get_bd_pins axi_ethernet_lite/s_axi_aresetn] [get_bd_pins periph_clk_wiz_reset/peripheral_aresetn]
    connect_bd_net [get_bd_pins axi_ethernet_lite/s_axi_aclk]    [get_bd_pins axi_periph_interconnect/M${pn}_ACLK]
    connect_bd_net [get_bd_pins axi_ethernet_lite/s_axi_aresetn] [get_bd_pins axi_periph_interconnect/M${pn}_ARESETN]
    if { [file exists "${root_path}/src/detail/${platform_name}/ethernet.tcl"] } {
        source "${root_path}/src/detail/${platform_name}/ethernet.tcl"
    } else {
        puts "Warning: Board-specifc script for Ethernet is missing."
    }
    endgroup
}

### ILA (Integrated Logic Analyzer) ############################################
##TODO
##difference ILA vs System ILA ?
#if { ${enable_ila} == 1 } {
#    puts "ILA not implemented yet. Option will be ignored."
#}


### Block Memory Generator #####################################################
#if { ${enable_axi_block_memory} == 1 } {
#   # need to customize ip in catalog and set:
#   # axi4 or axi4lite
#   # ID Width?
#   # Memory Slave or Peripheral Slave?
#   # Port Width
#   # Port Depth
#}


## Microblaze #################################################################
if { ${enable_microblaze} == 1 } {
    if { [file exists "${root_path}/src/detail/${platform_name}/microblaze.tcl"] } {
        source "${root_path}/src/detail/${platform_name}/microblaze.tcl"
    } else {
        puts "Error: Board-specifc script for MicroBlaze is missing."
        return
    }
}


## AXI Interrupt Controller ###################################################
if { ${enable_axi_intc} == 1 } {
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_intc_0
    set num_p [get_property CONFIG.NUM_MI [get_bd_cells axi_periph_interconnect]]
    set pn [expr $num_p - 1]
    if {$pn < 10} {set pn "0${pn}"}
    if { [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]] != "" } {
        incr num_p
        set_property CONFIG.NUM_MI $num_p [get_bd_cells axi_periph_interconnect]
        set pn [scan $pn %d]
        incr pn
        if {$pn < 10} {set pn "0${pn}"}
    }
    connect_bd_intf_net [get_bd_intf_pins axi_intc_0/S_AXI] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/M${pn}_AXI]
    connect_bd_net [get_bd_pins axi_intc_0/s_axi_aclk] [get_bd_pins periph_clk_wiz/clk_out1]
    connect_bd_net [get_bd_pins axi_intc_0/s_axi_aresetn] [get_bd_pins periph_clk_wiz_reset/peripheral_aresetn]
    connect_bd_net [get_bd_pins axi_intc_0/s_axi_aclk] [get_bd_pins axi_periph_interconnect/M${pn}_ACLK]
    connect_bd_net [get_bd_pins axi_intc_0/s_axi_aresetn] [get_bd_pins axi_periph_interconnect/M${pn}_ARESETN]
    endgroup
    ## Connect Interrupts ########################################################
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
    set_property -dict [list CONFIG.NUM_PORTS {1}] [get_bd_cells xlconcat_0]
    connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins axi_intc_0/intr]
    endgroup
    startgroup
    set any_intc "0"
    if { ${enable_axi_perf_monitor} == 1 } {
        set any_intc "1"
        set current_interrupt_ports [get_property CONFIG.NUM_PORTS [get_bd_cells xlconcat_0]]
        set ptnum [expr $current_interrupt_ports - 1]
        connect_bd_net [get_bd_pins xlconcat_0/In${ptnum}] [get_bd_pins axi_perf_mon_0/interrupt]
        set_property -dict [list CONFIG.NUM_PORTS [expr ${current_interrupt_ports} + 1]] [get_bd_cells xlconcat_0]
    }
    if { ${enable_system_management} == 1 } {
        set any_intc "1"
        set current_interrupt_ports [get_property CONFIG.NUM_PORTS [get_bd_cells xlconcat_0]]
        set ptnum [expr $current_interrupt_ports - 1]
        connect_bd_net [get_bd_pins xlconcat_0/In${ptnum}] [get_bd_pins system_management_wiz_0/ip2intc_irpt]
        set_property -dict [list CONFIG.NUM_PORTS [expr ${current_interrupt_ports} + 1]] [get_bd_cells xlconcat_0]
    }
    if { ${enable_axi_iic} == 1 } {
        set any_intc "1"
        set current_interrupt_ports [get_property CONFIG.NUM_PORTS [get_bd_cells xlconcat_0]]
        set ptnum [expr $current_interrupt_ports - 1]
        connect_bd_net [get_bd_pins xlconcat_0/In${ptnum}] [get_bd_pins axi_iic_0/iic2intc_irpt]
        set_property -dict [list CONFIG.NUM_PORTS [expr ${current_interrupt_ports} + 1]] [get_bd_cells xlconcat_0]
    }
    if { ${enable_axi_timer} == 1 } {
        set any_intc "1"
        set current_interrupt_ports [get_property CONFIG.NUM_PORTS [get_bd_cells xlconcat_0]]
        set ptnum [expr $current_interrupt_ports - 1]
        connect_bd_net [get_bd_pins xlconcat_0/In${ptnum}] [get_bd_pins axi_timer_0/interrupt]
        set_property -dict [list CONFIG.NUM_PORTS [expr ${current_interrupt_ports} + 1]] [get_bd_cells xlconcat_0]
    }
    if { ${enable_usb_uart} == 1 || ${enable_usb_uart_lite} == 1 } {
        set any_intc "1"
        set current_interrupt_ports [get_property CONFIG.NUM_PORTS [get_bd_cells xlconcat_0]]
        set ptnum [expr $current_interrupt_ports - 1]
        connect_bd_net [get_bd_pins xlconcat_0/In${ptnum}] [get_bd_pins axi_uart/${UART_INTC_NAME}]
        set_property -dict [list CONFIG.NUM_PORTS [expr ${current_interrupt_ports} + 1]] [get_bd_cells xlconcat_0]
    }
    if { ${enable_axi_ethernet_lite} == 1 } {
        set any_intc "1"
        set current_interrupt_ports [get_property CONFIG.NUM_PORTS [get_bd_cells xlconcat_0]]
        set ptnum [expr $current_interrupt_ports - 1]
        connect_bd_net [get_bd_pins xlconcat_0/In${ptnum}] [get_bd_pins axi_ethernet_lite/ip2intc_irpt]
        set_property -dict [list CONFIG.NUM_PORTS [expr ${current_interrupt_ports} + 1]] [get_bd_cells xlconcat_0]
    }
    if { ${any_intc} == "1" } {
        set current_interrupt_ports [get_property CONFIG.NUM_PORTS [get_bd_cells xlconcat_0]]
        set_property -dict [list CONFIG.NUM_PORTS [expr ${current_interrupt_ports} - 1]] [get_bd_cells xlconcat_0]
    }

    set intc_to_mb  1;  # connect intc to MB instead of pcie xdma
    if { ${enable_microblaze} == 1 && ${intc_to_mb} == 1} {
        puts "Interrupt Controller will be connected to MicroBlaze instead of PCIe xDMA"
        connect_bd_intf_net [get_bd_intf_pins axi_intc_0/interrupt] [get_bd_intf_pins microblaze_0/INTERRUPT]
    } elseif { ${enable_pcie} } {
        set_property -dict [list CONFIG.C_IRQ_CONNECTION {1}] [get_bd_cells axi_intc_0]
        connect_bd_net [get_bd_pins axi_intc_0/irq] [get_bd_pins xdma_0/usr_irq_req]
    }
    endgroup
}



## Address map settings #######################################################

# 0x0000'0000 - 0x0003'FFFF MicroBlaze local memory
# 0x0004'0000 - 0x0004'FFFF Interrupt Controller
# 0x0005'0000 - 0x0005'FFFF AXI Timer
# 0x0006'0000 - 0x0006'FFFF USB UART
# 0x0007'0000 - 0x0007'FFFF System Management Wizzard
# 0x0008'0000 - 0x0008'FFFF AXI Performance Monitor
# 0x0009'0000 - 0x0009'FFFF AXI IIC
# 0x0010'0000 - 0x0010'FFFF AXI Ethernet
#
# 0x0020'0000 - 0x0020'FFFF GPIO
# 0x0021'0000 - 0x0021'FFFF GPIO
# 0x0022'0000 - 0x0022'FFFF GPIO
#
# 0x0100'0000 - 0x0100'FFFF Custom IP (to be defined below)
#
# 0x1'0000'0000 - 0x1'FFFF'FFFF DDR4_1
# 0x2'0000'0000 - 0x2'FFFF'FFFF DDR4_0
# with MicroBlaze:
# 0x4000'0000 - 0x7FFF'FFFF DDR4_1
# 0x8000'0000 - 0xFFFF'FFFF DDR4_0

# XDMA Mapping
if { ${enable_pcie} == "1" } {
    if { ${infrastructure_type} == "dma" && ${enable_mig} == "1" && ${enable_pcie} == "1" } {
        # safety-check that mig is actually connected... more or less just for debugging as this should never happen
        if { [get_bd_intf_nets -of_objects [get_bd_intf_pins mig_0/C0_DDR4_S_AXI]] != "" } {
            set_property offset 0x0000000100000000 [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_0_${MIG_ADDR_POSTFIX}]
            set_property range 4G [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_0_${MIG_ADDR_POSTFIX}]
        }
    }
    # DDR4_1 will be set later to avoid conflicts with MicroBlaze
    
    if { ${enable_axi_intc} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_intc_0/S_AXI/Reg }]
        set_property offset 0x00040000 [get_bd_addr_segs {xdma_0/M_AXI_LITE/SEG_axi_intc_0_Reg}]
        set_property offset 0x00040000 [get_bd_addr_segs {xdma_0/M_AXI_LITE/SEG_axi_intc_0_Reg}]
    }
    if { ${enable_axi_timer} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_timer_0/S_AXI/Reg }]
        set_property offset 0x00050000 [get_bd_addr_segs {xdma_0/M_AXI_LITE/SEG_axi_timer_0_Reg}]
        set_property offset 0x00050000 [get_bd_addr_segs {xdma_0/M_AXI_LITE/SEG_axi_timer_0_Reg}]
    }
    if { ${enable_usb_uart} == 1 || ${enable_usb_uart_lite} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_uart/S_AXI/Reg }]
        set_property offset 0x00060000 [get_bd_addr_segs {xdma_0/M_AXI_LITE/SEG_axi_uart_Reg}]
    }
    if { ${enable_system_management} == 1 } {
        assign_bd_address [get_bd_addr_segs {system_management_wiz_0/S_AXI_LITE/Reg }]
        set_property offset 0x00070000 [get_bd_addr_segs {xdma_0/M_AXI_LITE/SEG_system_management_wiz_0_Reg}]
    }
    if { ${enable_axi_perf_monitor} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_perf_mon_0/S_AXI/Reg }]
        set_property offset 0x00080000 [get_bd_addr_segs {xdma_0/M_AXI_LITE/SEG_axi_perf_mon_0_Reg}]
    }
    if { ${enable_axi_iic} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_iic_0/S_AXI/Reg }]
        set_property offset 0x00090000 [get_bd_addr_segs {xdma_0/M_AXI_LITE/SEG_axi_iic_0_Reg}]
    }
    if { ${enable_axi_ethernet_lite} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_ethernet_lite/S_AXI/Reg }]
        set_property offset 0x00100000 [get_bd_addr_segs {xdma_0/M_AXI_LITE/SEG_axi_ethernet_lite_Reg}]
    }
    if { ${enable_gpio} == 1 } {
        set baseoffset 0x00200000
        for { set i 0 } { $i < $NUM_GPIO_BLOCKS } { incr i } {
            assign_bd_address [get_bd_addr_segs axi_gpio_${i}/S_AXI/Reg]
            set_property offset $baseoffset [get_bd_addr_segs xdma_0/M_AXI_LITE/SEG_axi_gpio_${i}_Reg]
            set baseoffset [expr $baseoffset + 0x00010000]
        }
    }
}

# MicroBlaze Mapping
if { ${enable_microblaze} == 1 } {
    # TODO bugfix if MB enabled: only 32bit support
    if { ${infrastructure_type} == "dma" && ${enable_pcie} == "1" } {
        set_property range 2G [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_0_${MIG_ADDR_POSTFIX}]
        set_property offset 0x0000000080000000 [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_0_${MIG_ADDR_POSTFIX}]
    }
#    set_property -dict [list CONFIG.C_ADDR_SIZE {36}] [get_bd_cells microblaze_0]

    set_property range 2G [get_bd_addr_segs microblaze_0/Data/SEG_mig_0_${MIG_ADDR_POSTFIX}]
    set_property offset 0x80000000 [get_bd_addr_segs microblaze_0/Data/SEG_mig_0_${MIG_ADDR_POSTFIX}]
    set_property range 2G [get_bd_addr_segs microblaze_0/Instruction/SEG_mig_0_${MIG_ADDR_POSTFIX}]
    set_property offset 0x80000000 [get_bd_addr_segs microblaze_0/Instruction/SEG_mig_0_${MIG_ADDR_POSTFIX}]
    if { ${enable_axi_intc} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_intc_0/S_AXI/Reg }]
        set_property offset 0x00040000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_intc_0_Reg}]
        set_property offset 0x00040000 [get_bd_addr_segs {microblaze_0/Instruction/SEG_axi_intc_0_Reg}]
    }
    if { ${enable_axi_timer} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_timer_0/S_AXI/Reg }]
        set_property offset 0x00050000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_timer_0_Reg}]
        set_property offset 0x00050000 [get_bd_addr_segs {microblaze_0/Instruction/SEG_axi_timer_0_Reg}]
    }
    if { ${enable_usb_uart} == 1 || ${enable_usb_uart_lite} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_uart/S_AXI/Reg }]
        set_property offset 0x00060000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_uart_Reg}]
        set_property offset 0x00060000 [get_bd_addr_segs {microblaze_0/Instruction/SEG_axi_uart_Reg}]
    }
    if { ${enable_system_management} == 1 } {
        assign_bd_address [get_bd_addr_segs {system_management_wiz_0/S_AXI_LITE/Reg }]
        set_property offset 0x00070000 [get_bd_addr_segs {microblaze_0/Data/SEG_system_management_wiz_0_Reg}]
        set_property offset 0x00070000 [get_bd_addr_segs {microblaze_0/Instruction/SEG_system_management_wiz_0_Reg}]
    }
    if { ${enable_axi_perf_monitor} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_perf_mon_0/S_AXI/Reg }]
        set_property offset 0x00080000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_perf_mon_0_Reg}]
        set_property offset 0x00080000 [get_bd_addr_segs {microblaze_0/Instruction/SEG_axi_perf_mon_0_Reg}]
    }
    if { ${enable_axi_iic} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_iic_0/S_AXI/Reg }]
        set_property offset 0x00090000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_iic_0_Reg}]
        set_property offset 0x00090000 [get_bd_addr_segs {microblaze_0/Instruction/SEG_axi_iic_0_Reg}]
    }
    if { ${enable_axi_ethernet_lite} == 1 } {
        assign_bd_address [get_bd_addr_segs {axi_ethernet_lite/S_AXI/Reg }]
        set_property offset 0x00100000 [get_bd_addr_segs {microblaze_0/Data/SEG_axi_ethernet_lite_Reg}]
        set_property offset 0x00100000 [get_bd_addr_segs {microblaze_0/Instruction/SEG_axi_ethernet_lite_Reg}]
    }
    if { ${enable_gpio} == 1 } {
    #TODO loop over number of gpio blocks
        set baseoffset 0x00200000
        for { set i 0 } { $i < $NUM_GPIO_BLOCKS } { incr i } {
            assign_bd_address [get_bd_addr_segs axi_gpio_${i}/S_AXI/Reg]
            set_property offset $baseoffset [get_bd_addr_segs microblaze_0/Data/SEG_axi_gpio_${i}_Reg]
            set_property offset $baseoffset [get_bd_addr_segs microblaze_0/Instruction/SEG_axi_gpio_${i}_Reg]
            set baseoffset [expr $baseoffset + 0x00010000]
        }
    }
    if { ${enable_second_ddr_dimm} == 1 } {
        assign_bd_address [get_bd_addr_segs mig_1/C0_DDR4_MEMORY_MAP/${MIG_ADDR_POSTFIX}]
        set_property range 1G [get_bd_addr_segs microblaze_0/Data/SEG_mig_1_${MIG_ADDR_POSTFIX}]
        set_property offset 0x40000000 [get_bd_addr_segs microblaze_0/Data/SEG_mig_1_${MIG_ADDR_POSTFIX}]
        set_property range 1G [get_bd_addr_segs microblaze_0/Instruction/SEG_mig_1_${MIG_ADDR_POSTFIX}]
        set_property offset 0x40000000 [get_bd_addr_segs microblaze_0/Instruction/SEG_mig_1_${MIG_ADDR_POSTFIX}]
        # DDR4_1 access will not be cached unless MB cache is configured accordingly. Addresses need to be power of two.
        # set_property -dict [list CONFIG.C_ICACHE_BASEADDR.VALUE_SRC USER CONFIG.C_ICACHE_HIGHADDR.VALUE_SRC USER CONFIG.C_DCACHE_BASEADDR.VALUE_SRC USER CONFIG.C_DCACHE_HIGHADDR.VALUE_SRC USER] [get_bd_cells microblaze_0]
        # set_property -dict [list CONFIG.C_ICACHE_BASEADDR {0x00000000} CONFIG.C_ICACHE_HIGHADDR {0xFFFFFFFF} CONFIG.C_ADDR_TAG_BITS {19} CONFIG.C_DCACHE_BASEADDR {0x00000000} CONFIG.C_DCACHE_HIGHADDR {0xFFFFFFFF} CONFIG.C_DCACHE_ADDR_TAG {19}] [get_bd_cells microblaze_0]
    }
}

if { ${enable_mig} == 1 && ${enable_second_ddr_dimm} == 1 && ${enable_pcie} == 1 } {
    # Map DDR4_1 into XDMA
    # safety-check that mig is actually connected... more or less just for debugging as this should never happen
    if { [get_bd_intf_nets -of_objects [get_bd_intf_pins mig_1/C0_DDR4_S_AXI]] != "" } {
        assign_bd_address [get_bd_addr_segs mig_1/C0_DDR4_MEMORY_MAP/${MIG_ADDR_POSTFIX}]
        set_property offset 0x0000000200000000 [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_1_${MIG_ADDR_POSTFIX}]
        set_property range 4G [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_1_${MIG_ADDR_POSTFIX}]
        if { ${enable_microblaze} == 1} {
            set_property range 1G [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_1_${MIG_ADDR_POSTFIX}]
            set_property offset 0x0000000040000000 [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_1_${MIG_ADDR_POSTFIX}]
        }
    }
}


## Custom IPs #################################################################

if { ${enable_custom_ip} == 1 && [file exists "${conf_path}/ips.tcl"]} {
    # get ip names and paths as well as clocking information
    source "${conf_path}/ips.tcl"

    # Create Clocking Wizard
    create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 hls_ip_clk_wiz
    #TODO use pci-dma if mig disabled
    if { [file exists "${root_path}/src/detail/${platform_name}/hls_ip_clk_wiz.tcl"] } {
        source "${root_path}/src/detail/${platform_name}/hls_ip_clk_wiz.tcl"
    } else {
        puts "Error: Board-specifc script for periph_clk_wiz is missing."
        return
    }
    # Create all necessary clocks for custom ips
    for { set l 0 } { $l < [llength $hls_ip_clocks] } { incr l } {
        set_property -dict [list CONFIG.CLKOUT[expr ${l} + 1]_USED {true} CONFIG.CLKOUT[expr ${l} + 1]_REQUESTED_OUT_FREQ [lindex $hls_ip_clocks $l]] [get_bd_cells hls_ip_clk_wiz]
        # Create and connect Processor System Reset for each clock
        create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 hls_reset_${l}
        apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {Auto}} [get_bd_pins hls_reset_${l}/ext_reset_in]
        connect_bd_net [get_bd_pins hls_ip_clk_wiz/clk_out[expr ${l} + 1]] [get_bd_pins hls_reset_${l}/slowest_sync_clk]
        connect_bd_net [get_bd_pins hls_ip_clk_wiz/locked] [get_bd_pins hls_reset_${l}/dcm_locked]
    }

    # Add HDL IP repositories
    set_property ip_repo_paths $ip_paths [current_fileset]
    update_ip_catalog -rebuild

    # add all IPs to block design
    for { set l 0 } { $l < [llength $ip_paths] } { incr l } {
        # check if component.xml exists
        if { ! [file exists "[lindex $ip_paths $l]/component.xml"] } {
            puts "[lindex $ip_paths $l]/component.xml not found. IP missing? Aborting..."
            return 1
        }
        set CustomIPName [lindex $ip_names $l]
        create_bd_cell -type ip -vlnv "[lindex ${ip_vlnvs} $l]" ${CustomIPName}
        # ckeck if ip was added
        if { "[get_bd_cells "${CustomIPName}"]" == "" } {
            puts "Error: unable to add IP $CustomIPName. Aborting..."
            return 1
        }
    }

    # base address for aximm registers
    set axilite_offset 1000000
    set axifull_offset 0
    set axifull_range  0
    set axifull2_offset 0
    set axifull2_range  0

    # base address/range for axifull ports
    if { ${enable_mig} == "1" } {
        if { ${enable_pcie} == "1" && ${infrastructure_type} == "dma" } {
            set axifull_offset [get_property offset [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_0_${MIG_ADDR_POSTFIX}]]
            set axifull_range [get_property range [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_0_${MIG_ADDR_POSTFIX}]]
            if { ${enable_second_ddr_dimm} == "1" } {
                set axifull2_offset [get_property offset [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_1_${MIG_ADDR_POSTFIX}]]
                set axifull2_range [get_property range [get_bd_addr_segs xdma_0/M_AXI/SEG_mig_1_${MIG_ADDR_POSTFIX}]]
            }
        } elseif { ${enable_microblaze} == "1" } {
            set axifull_offset [get_property offset [get_bd_addr_segs microblaze_0/Data/SEG_mig_0_${MIG_ADDR_POSTFIX}]]
            set axifull_range [get_property range [get_bd_addr_segs microblaze_0/Data/SEG_mig_0_${MIG_ADDR_POSTFIX}]]
            if { ${enable_second_ddr_dimm} == "1" } {
                set axifull2_offset [get_property offset [get_bd_addr_segs microblaze_0/Data/SEG_mig_1_${MIG_ADDR_POSTFIX}]]
                set axifull2_range [get_property range [get_bd_addr_segs microblaze_0/Data/SEG_mig_1_${MIG_ADDR_POSTFIX}]]
            }
        } else {
            puts "No Master Interface for MIG found: defaulting to 256M per MIG"
            set axifull_offset  "0x80000000"
            set axifull_range   "256M"
            set axifull2_offset "0x90000000"
            set axifull2_range  "256M"
        }
    }

    # make user-specified connections
    if { [file exists "${conf_path}/connections.tcl"] } {
        source "${conf_path}/connections.tcl"
    }

    # connect clock, reset, interrupt, and other ports
    for { set l 0 } { $l < [llength $ip_paths] } { incr l } {
        set CustomIPName [lindex $ip_names $l]
        set CIPPortNames [lindex $ip_portnames $l]
        set CIPPortNames [string map {; " "} "$CIPPortNames"]
        set CIPPortTypes [lindex $ip_porttypes $l]
        set CIPPortTypes [string map {; " "} "$CIPPortTypes"]
        set CIPPortModes [lindex $ip_portmodes $l]
        set CIPPortModes [string map {; " "} "$CIPPortModes"]
        source_with_args "${root_path}/src/customip.tcl" "hls_ip_clk_wiz"
    }

}

## Beautify Layout ############################################################

regenerate_bd_layout -routing
regenerate_bd_layout

## Validate design ############################################################

save_bd_design
validate_bd_design

## Write IP address map to file ###############################################
source "${root_path}/src/printaddr.tcl"

## Store design ###############################################################
save_bd_design

puts "Block design constructed and ready to use ..."
return 0
