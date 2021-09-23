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
set root_path       [lindex $argv 2]
set target_board    [lindex $argv 3]
set target_part     [lindex $argv 4]
set export_dir      [lindex $argv 5]
set clk             [lindex $argv 6]
set src_dir         [lindex $argv 7]
set tlf             [lindex $argv 8]
set sourcefiles     [lrange $argv 9 [llength $argv]]

# Remove braces from bash array
set sourcefiles [string trim $sourcefiles "{}"]

set proj_name                "ORKAIP"
set libraryname              "ORKALIB"
set vendor                   "ORKAHPC"
set version_h                1
set version_l                0
set display_name             "ORKA-HPC FPGA Accelerator IP"

set hls_dir         "$export_dir/hls"

file mkdir "$hls_dir"

cd "$hls_dir"
open_project $proj_name

# get CFLAGS:
# source export_dir/cflags.tcl if file exists
set cflags ""
if {[ file exists "$export_dir/cflags.tcl" ]} {
    source "$export_dir/cflags.tcl"
}

# Files to build the hardware
foreach f $sourcefiles {
    add_files "$src_dir/$f" -cflags "$cflags"
}

# Testbench files
#add_files -tb {file...}

set_top $tlf

set solution "v${version_h}-v${version_l}_${clk}"
open_solution -reset $solution
set_part $target_part
create_clock -period $clk -name default

# set axi port behaviour and enable 64 bit address
config_interface -m_axi_offset off -register_io off -m_axi_addr64

## == compile only
#csim_design -clean -setup

## == synthesize design
csynth_design

## == cosim design
#cosim_design -rtl vhdl

# pack and export design
export_design -format ip_catalog \
        -description "ORKA-HLS-IP_${target_part}_${clk}" \
        -library $libraryname \
        -vendor $vendor \
        -version ${version_h}.${version_l} \
        -display_name $display_name
# for Vivado 2020.1 and newer simply specify export path:
#        -output $export_dir/ip

# copy ip to export dir
if { [file exists "$export_dir/ip"] } {
    file delete -force "$export_dir/ip"
}
exec cp -rf "$hls_dir/$proj_name/$solution/impl/ip" "$export_dir/ip"

# for some reason some vivado versions export into a different file tree...
if { ![file exists "$export_dir/ip/hdl"] && [file exists "$export_dir/ip/vhdl"] } {
    file mkdir "$export_dir/ip/hdl"
    exec cp -rf "$export_dir/ip/vhdl" "$export_dir/ip/hdl/vhdl"
}

# copy driver file with register map to export_dir/ip/reg_map
# Vivado is terribly inconsistent... Folder keeps case, file is all lowercase though...
set tlf_lowercase "[string tolower "${tlf}"]"
if { ![file exists "$export_dir/ip/drivers/${tlf}_v1_0/src/x${tlf_lowercase}_hw.h"] } {
    puts "ERROR! HLS did not generate driver file for the ports!"
    puts "File $export_dir/ip/drivers/${tlf}_v1_0/src/x${tlf_lowercase}_hw.h is missing."
    puts "Did you forget to add pragmas for your ports?"
    puts "Aborting..."
    exit
}
exec cp -f "$export_dir/ip/drivers/${tlf}_v1_0/src/x${tlf_lowercase}_hw.h" "$export_dir/ip/reg_map"

### == copy result to repo
#puts =======================================
#puts "* Copying IP ($vendor\_$libraryname\_$tlf\_$version_h\_$version_l\.zip) to repository ($repo_dir)"
#
#file mkdir $repo_dir
#file copy -force $hls_dir/$proj_name/$solution/impl/ip/$vendor\_$libraryname\_$proj_name\_$version_h\_$version_l\.zip $repo_dir/$vendor\_$libraryname\_$proj_name\_$version_h\_$version_l-$clk\.zip

exit
