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
set AXI_MM_PORT_NAME    "S_AXI"
set UI_CLK_NAME         "ui_clk"
set MIG_ADDR_POSTFIX    "memaddr"

create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series mig_0
apply_board_connection -board_interface "ddr3_sdram" -ip_intf "mig_0/mig_ddr_interface" -diagram "axi_pcie_mig" 
delete_bd_objs [get_bd_nets clk_ref_i_1] [get_bd_ports clk_ref_i]
delete_bd_objs [get_bd_nets sys_clk_i_1] [get_bd_ports sys_clk_i]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( System Reset ) } Manual_Source {New External Port (ACTIVE_LOW)}}  [get_bd_pins mig_0/sys_rst]

## Use periph_clk_wiz as clock input (sys_clk can only be used once...)
set_property -dict [list CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT3_USED {true} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {166.667} CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {200} CONFIG.MMCM_CLKOUT1_DIVIDE {6} CONFIG.MMCM_CLKOUT2_DIVIDE {5} CONFIG.NUM_OUT_CLKS {3} CONFIG.CLKOUT2_JITTER {118.758} CONFIG.CLKOUT2_PHASE_ERROR {98.575} CONFIG.CLKOUT3_JITTER {114.829} CONFIG.CLKOUT3_PHASE_ERROR {98.575}] [get_bd_cells periph_clk_wiz]
connect_bd_net [get_bd_pins periph_clk_wiz/clk_out2] [get_bd_pins mig_0/sys_clk_i]
connect_bd_net [get_bd_pins periph_clk_wiz/clk_out3] [get_bd_pins mig_0/clk_ref_i]

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 mig_rst_0
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/mig_0/ui_clk (83 MHz)" }  [get_bd_pins mig_rst_0/slowest_sync_clk]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( System Reset ) } Manual_Source {Auto}}  [get_bd_pins mig_rst_0/ext_reset_in]

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
