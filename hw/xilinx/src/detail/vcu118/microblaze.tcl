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
startgroup
# version 10.0 and 11.0 should work
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze microblaze_0
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config { axi_intc {0} axi_periph {Enabled} cache {8KB} clk {/mig_0/c0_ddr4_ui_clk (300 MHz)} debug_module {Debug Only} ecc {None} local_mem {128KB} preset {None}}  [get_bd_cells microblaze_0]
set_property -dict [list CONFIG.C_ADDR_SIZE {32} CONFIG.C_AREA_OPTIMIZED {1} CONFIG.C_I_AXI {1} CONFIG.G_USE_EXCEPTIONS {0} CONFIG.C_USE_MSR_INSTR {0} CONFIG.C_USE_PCMP_INSTR {1} CONFIG.C_USE_REORDER_INSTR {1} CONFIG.C_USE_BARREL {1} CONFIG.C_USE_DIV {0} CONFIG.C_USE_HW_MUL {1} CONFIG.C_USE_FPU {0}] [get_bd_cells microblaze_0]
# connect to MIG SMC
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_0/c0_ddr4_ui_clk (300 MHz)} Clk_slave {/mig_0/c0_ddr4_ui_clk (300 MHz)} Clk_xbar {/mig_0/c0_ddr4_ui_clk (300 MHz)} Master {/microblaze_0/M_AXI_DC} Slave {/mig_0/C0_DDR4_S_AXI} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins microblaze_0/M_AXI_DC]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_0/c0_ddr4_ui_clk (300 MHz)} Clk_slave {/mig_0/c0_ddr4_ui_clk (300 MHz)} Clk_xbar {/mig_0/c0_ddr4_ui_clk (300 MHz)} Master {/microblaze_0/M_AXI_IC} Slave {/mig_0/C0_DDR4_S_AXI} intc_ip {/axi_smc} master_apm {0}}  [get_bd_intf_pins microblaze_0/M_AXI_IC]
# increase slave port count on axi lite crossbar and connect microblaze to it
set num_p [get_property CONFIG.NUM_SI [get_bd_cells axi_periph_interconnect]]
set pn [expr $num_p - 1]
if { [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_periph_interconnect/S0${pn}_AXI]] != "" } {
    set num_p [expr $num_p + 2]
    incr pn
} else {
    incr num_p
}
set_property CONFIG.NUM_SI $num_p [get_bd_cells axi_periph_interconnect]
connect_bd_intf_net [get_bd_intf_pins microblaze_0/M_AXI_DP] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/S0${pn}_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/mig_0/c0_ddr4_ui_clk (300 MHz)" }  [get_bd_pins axi_periph_interconnect/S0${pn}_ACLK]
incr pn
connect_bd_intf_net [get_bd_intf_pins microblaze_0/M_AXI_IP] -boundary_type upper [get_bd_intf_pins axi_periph_interconnect/S0${pn}_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/mig_0/c0_ddr4_ui_clk (300 MHz)" }  [get_bd_pins axi_periph_interconnect/S0${pn}_ACLK]
endgroup
