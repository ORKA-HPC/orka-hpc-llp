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
set NUM_GPIO_BLOCKS 3

startgroup

## Increase AXI X-Bar size
set num_p [get_property CONFIG.NUM_MI [get_bd_cells axi_periph_interconnect]]
set pn [expr $num_p - 1]
if { [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_periph_interconnect/M0${pn}_AXI]] != "" } {
    set num_p [expr $num_p + $NUM_GPIO_BLOCKS]
    incr pn
} else {
    set num_p [expr $num_p + [expr $NUM_GPIO_BLOCKS - 1]]
}
set_property CONFIG.NUM_MI $num_p [get_bd_cells axi_periph_interconnect]

## GPIO 0 #####################################################################
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
apply_board_connection -board_interface "led_4bits" -ip_intf "axi_gpio_0/GPIO" -diagram "axi_pcie_mig" 
apply_board_connection -board_interface "push_buttons_4bits" -ip_intf "axi_gpio_0/GPIO2" -diagram "axi_pcie_mig" 
connect_bd_intf_net [get_bd_intf_pins axi_gpio_0/S_AXI] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/M0${pn}_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/periph_clk_wiz/clk_out1 (100 MHz)" }  [get_bd_pins axi_gpio_0/s_axi_aclk]
incr pn

## GPIO 1 #####################################################################
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1
apply_board_connection -board_interface "rgb_led" -ip_intf "axi_gpio_1/GPIO" -diagram "axi_pcie_mig" 
apply_board_connection -board_interface "dip_switches_4bits" -ip_intf "axi_gpio_1/GPIO2" -diagram "axi_pcie_mig" 
connect_bd_intf_net [get_bd_intf_pins axi_gpio_1/S_AXI] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/M0${pn}_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/periph_clk_wiz/clk_out1 (100 MHz)" }  [get_bd_pins axi_gpio_1/s_axi_aclk]
incr pn

## GPIO 2 #####################################################################
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_2
apply_board_connection -board_interface "shield_dp0_dp19" -ip_intf "axi_gpio_2/GPIO" -diagram "axi_pcie_mig" 
apply_board_connection -board_interface "shield_dp26_dp41" -ip_intf "axi_gpio_2/GPIO2" -diagram "axi_pcie_mig" 
connect_bd_intf_net [get_bd_intf_pins axi_gpio_2/S_AXI] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/M0${pn}_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/periph_clk_wiz/clk_out1 (100 MHz)" }  [get_bd_pins axi_gpio_2/s_axi_aclk]
incr pn

endgroup
