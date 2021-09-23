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
# We need to drive the PHY with 25 MHz...
startgroup

# create port
create_bd_port -dir O -type clk eth_ref_clk

# generate new 25 MHz clock with existing periph_clk_wiz
set i [get_property CONFIG.NUM_OUT_CLKS [get_bd_cells periph_clk_wiz]]
incr i
set_property -dict [list CONFIG.NUM_OUT_CLKS $i CONFIG.CLKOUT${i}_USED {true} CONFIG.CLKOUT${i}_REQUESTED_OUT_FREQ {25.000}] [get_bd_cells periph_clk_wiz]

# connect clock to port
connect_bd_net [get_bd_ports eth_ref_clk] [get_bd_pins periph_clk_wiz/clk_out${i}]

endgroup
