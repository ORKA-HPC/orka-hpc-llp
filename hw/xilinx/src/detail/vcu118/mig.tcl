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
set AXI_MM_PORT_NAME    "C0_DDR4_S_AXI"
set UI_CLK_NAME         "c0_ddr4_ui_clk"
set MIG_ADDR_POSTFIX    "C0_DDR4_ADDRESS_BLOCK"

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 mig_0
apply_board_connection -board_interface "ddr4_sdram_c1" -ip_intf "mig_0/C0_DDR4" -diagram $design_name
apply_board_connection -board_interface "default_250mhz_clk1" -ip_intf "mig_0/C0_SYS_CLK" -diagram $design_name
# SMC:DDR4_0:reset
set_property -dict [list CONFIG.C0.DDR4_SELF_REFRESH {true} CONFIG.C0.DDR4_SAVE_RESTORE {true}] [get_bd_cells mig_0]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {New External Port (ACTIVE_HIGH)}}  [get_bd_pins mig_0/sys_rst]
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 mig_rst_0
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/mig_0/c0_ddr4_ui_clk (300 MHz)" }  [get_bd_pins mig_rst_0/slowest_sync_clk]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {Auto}}  [get_bd_pins mig_rst_0/ext_reset_in]

set num_p [get_property CONFIG.NUM_MI [get_bd_cells axi_smc]]
set pn [expr $num_p - 1]
if { [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_smc/M0${pn}_AXI]] != "" } {
    incr num_p
    set_property CONFIG.NUM_MI $num_p [get_bd_cells axi_smc]
    incr pn
}
connect_bd_intf_net [get_bd_intf_pins axi_smc/M0${pn}_AXI] [get_bd_intf_pins mig_0/${AXI_MM_PORT_NAME}]
connect_bd_net [get_bd_pins axi_smc/aclk] [get_bd_pins mig_0/${UI_CLK_NAME}]
connect_bd_net [get_bd_pins axi_smc/aresetn] [get_bd_pins mig_rst_0/peripheral_aresetn]
endgroup

if { ${enable_second_ddr_dimm} == 1 } {
    startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 mig_1
    apply_board_connection -board_interface "ddr4_sdram_c2" -ip_intf "mig_1/C0_DDR4" -diagram $design_name
    apply_board_connection -board_interface "default_250mhz_clk2" -ip_intf "mig_1/C0_SYS_CLK" -diagram $design_name
    set num_p [get_property CONFIG.NUM_MI [get_bd_cells axi_smc]]
    set pn [expr $num_p - 1]
    if { [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_smc/M0${pn}_AXI]] != "" } {
        incr num_p
        set_property CONFIG.NUM_MI $num_p [get_bd_cells axi_smc]
        incr pn
    }
    connect_bd_intf_net [get_bd_intf_pins axi_smc/M0${pn}_AXI] [get_bd_intf_pins mig_1/${AXI_MM_PORT_NAME}]
    set NUM_CLKS [get_property CONFIG.NUM_CLKS [get_bd_cells axi_smc]]
    incr NUM_CLKS
    set_property CONFIG.NUM_CLKS $NUM_CLKS [get_bd_cells axi_smc]
    connect_bd_net [get_bd_pins mig_1/${UI_CLK_NAME}] [get_bd_pins axi_smc/aclk[expr $NUM_CLKS - 1]]
    apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {Custom} Manual_Source {Auto}}  [get_bd_pins mig_1/sys_rst]
    endgroup
}
