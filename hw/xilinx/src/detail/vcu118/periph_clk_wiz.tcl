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
#set clk src
set_property -dict [list CONFIG.CLK_IN1_BOARD_INTERFACE {default_sysclk1_300} CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} CONFIG.CLKIN1_JITTER_PS {33.330000000000005} CONFIG.MMCM_CLKFBOUT_MULT_F {4.000} CONFIG.MMCM_CLKIN1_PERIOD {3.333} CONFIG.MMCM_CLKIN2_PERIOD {10.0} CONFIG.CLKOUT1_JITTER {101.475} CONFIG.CLKOUT1_PHASE_ERROR {77.836}] [get_bd_cells periph_clk_wiz]

#bd automation to connect to sys_clk and reset
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {default_sysclk1_300 ( 300 MHz System differential clock ) } Manual_Source {Auto}}  [get_bd_intf_pins periph_clk_wiz/CLK_IN1_D]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {Auto}}  [get_bd_pins periph_clk_wiz/reset]

#reset proc
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset periph_clk_wiz_reset
connect_bd_net [get_bd_pins periph_clk_wiz_reset/slowest_sync_clk] [get_bd_pins periph_clk_wiz/clk_out1]
connect_bd_net [get_bd_pins periph_clk_wiz_reset/dcm_locked] [get_bd_pins periph_clk_wiz/locked]
connect_bd_net [get_bd_ports reset] [get_bd_pins periph_clk_wiz_reset/ext_reset_in]
