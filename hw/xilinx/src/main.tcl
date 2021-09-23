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
set root_path [lindex $argv 0]
set conf_path [lindex $argv 1]

proc source_with_args {file args} {
  set argv $::argv
  set argc $::argc
  set ::argv $args
  set ::argc [llength $args]
  set code [catch {uplevel [list source $file]} return]
  set ::argv $argv
  set ::argc $argc
  return -code $code $return
}

set vivado_version [version -short]

# Load settings.tcl
puts "Loading settings..."
if {[expr ! [file exists "${conf_path}/settings.tcl"]]} {
    puts "settings.tcl not found! Run configurator first and provide path to generated files! Exiting..."
    exit 0
}
source "${conf_path}/settings.tcl"

set dest_path $bitstream_export_dir
puts "Bitstream export dir was set to $dest_path"

## == Prepare directory variables ==============================
set target_board            $platform_name

set design_dir              [file normalize "$design_dir"]

## Archive existing design if it already exists
##-----------------------------------------------------------
#puts "NOTE: Archive existing $design_name_full design if it exists"
#set format_date [clock format [clock seconds] -format %Y%m%d_%H%m]
#set date_suffix _$format_date
#puts "Date: $format_date"
#if { [file exists "$design_dir/$design_name_full"] == 1 } { 
#  puts "Moving existing $design_name_full to time-stamped suffix $design_name_full$date_suffix"
#  file rename "$design_dir/$design_name_full" "$design_dir/$design_name_full$date_suffix"
#} else {
#  file mkdir "$design_dir"
#}
puts "Deleting: $design_dir/$proj_name_long/$proj_name_short"
file delete -force "$design_dir/$proj_name_long"

#-----------------------------------------------------------
# Create project
#-----------------------------------------------------------
puts "Creating project for $proj_name_long ..."
if { $target_board == "arty" } {
	set target_part xc7a35ticsg324-1L
	set board_property digilentinc.com:arty:part0:1.1
    set manufacturer_board "Digilent"
    set manufacturer_fpga "Xilinx"
} elseif { $target_board == "arty-a7-100" } {
	set target_part xc7a100tcsg324-1
	set board_property digilentinc.com:arty-a7-100:part0:1.0
    set manufacturer_board "Digilent"
    set manufacturer_fpga "Xilinx"
} elseif { $target_board == "vc709" } {
	set target_part xc7vx690tffg1761-2
	set board_property xilinx.com:vc709:part0:1.7
    set manufacturer_board "Xilinx"
    set manufacturer_fpga "Xilinx"
} elseif { $target_board == "vcu118" } {
	set target_part xcvu9p-flga2104-2L-e
	set board_property xilinx.com:vcu118:part0:2.0
    set manufacturer_board "Xilinx"
    set manufacturer_fpga "Xilinx"
} else {
	puts "ERROR! Selected board '$target_board' is not supported."
	exit
}

if { $enable_gui == "1" } {
    start_gui
}

create_project $proj_name_short "$design_dir/$proj_name_long" -part $target_part
set_property board_part $board_property [current_project]
set_property target_language VHDL [current_project]

#-----------------------------------------------------------
# Create BD source
#-----------------------------------------------------------
puts "Creating block diagram..."
if { [source "${root_path}/src/blockdesign.tcl"] != 0 } {
    puts "Error while generating block diagram. Aborting..."
    return 1
}
save_bd_design

#-----------------------------------------------------------
# Create wrapper code
#-----------------------------------------------------------

puts $design_dir/$proj_name_long
make_wrapper -files [get_files $design_dir/$proj_name_long/$proj_name_short\.srcs/sources_1/bd/$bd_design_name/$bd_design_name\.bd] -top

add_files -norecurse -verbose $design_dir/$proj_name_long/$proj_name_short\.srcs/sources_1/bd/$bd_design_name/hdl/$bd_design_name\_wrapper.vhd

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

#-----------------------------------------------------------
# Create constraints file
#-----------------------------------------------------------
if { [file exists "${root_path}/src/detail/${platform_name}/constraints.tcl"] } {
    source "${root_path}/src/detail/${platform_name}/constraints.tcl"
}

##-----------------------------------------------------------
if { ${only_build_bd} == 1 } {
    return
}
##-----------------------------------------------------------

##-----------------------------------------------------------
## Synthesize design
##-----------------------------------------------------------
#launch_runs synth_1 -jobs 4
#wait_on_run [current_run]
#open_run synth_1 -name synth_1
#
##-----------------------------------------------------------
## Setup debug core
##-----------------------------------------------------------
#source "./ProcessVIVdebug_$target_board.tcl"
#

#-----------------------------------------------------------
# Generate bitstream
#-----------------------------------------------------------
launch_runs impl_1 -to_step write_bitstream -jobs $num_cpu_cores
wait_on_run [current_run]
# copy bitstream to a more convenient location
file copy -force ${design_dir}/pcieDMA/orka.runs/impl_1/axi_pcie_mig_wrapper.bit "${dest_path}/${bitstream_filename}"

#-----------------------------------------------------------
# Export utilization and timing reports and mmi file
#-----------------------------------------------------------
open_run impl_1
# File destination within workspace
set util_file "${design_dir}/utilization_report"
set timing_file "${design_dir}/timing_report"
set mmi_file "${design_dir}/mem_info"
report_utilization -file "${util_file}" -name utilization_1
report_timing -file ${timing_file} -name timing_1
write_mem_info -force "${mmi_file}"


#-----------------------------------------------------------
# Write Firmware to bitstream
#-----------------------------------------------------------
if { ${enable_microblaze} == 1 && ${enable_axi_ethernet_lite} == 1 } {
    #TODO get value for '-proc'
    puts "Injecting MicroBlaze Firmware into Bitstream..."
    puts "ELF File: [exec realpath "${root_path}/../../sw/orkafw/${platform_name}/firmware.elf"]"
    puts "[exec updatemem -force -meminfo "${design_dir}/mem_info.mmi" -data "${root_path}/../../sw/orkafw/${platform_name}/firmware.elf" -bit "${dest_path}/${bitstream_filename}" -proc axi_pcie_mig_i/microblaze_0 -out "${dest_path}/${bitstream_filename}"]"
}

##-----------------------------------------------------------
## Export to SDK
##-----------------------------------------------------------
#file mkdir $design_dir/$proj_name_long/$proj_name_short\.sdk
#file copy -force $design_dir/$proj_name_long/$proj_name_short\.runs/impl_1/design_1_wrapper.sysdef $design_dir/$proj_name_long/$proj_name_short\.sdk/$bd_design_name\_wrapper.hdf
#
##-----------------------------------------------------------
## Start SDK
##-----------------------------------------------------------
#launch_sdk -workspace $design_dir/$proj_name_long/$proj_name_short\.sdk -hwspec $design_dir/$proj_name_long/$proj_name_short\.sdk/$bd_design_name\_wrapper.hdf
