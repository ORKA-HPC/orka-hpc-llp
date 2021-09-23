#!/bin/tcl
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

package require cmdline

#Read Cmdline Options
set options {\
{ "PROJECT_NAME.arg" "" "Name of project / Top Level Entity?" } \
{ "PERSONA_NAME.arg" "" "Name of persona (and revision) to be added" } \
{ "HLS_PROJECT_DIR.arg" "" "Path to HLS Project" }
}
array set opts [::cmdline::getoptions quartus(args) $options]

#Open Project
project_open $opts(PROJECT_NAME).qpf

##Switch to persona revision (create new one if necessary)
#set revisions_list [get_project_revisions]
#if {[string first " $opts(PERSONA_NAME) " $revisions_list] == -1} {
#    puts "Revision does not exist yet. Creating new one."
#    create_revision $opts(PERSONA_NAME)
#} else {
#    puts "WARNING: Found revision with matching name. Switching to it without overwriting with template files"
#}
set_current_revision $opts(PERSONA_NAME)

#add IP search path
#if {[string first " $opts(PERSONA_NAME) " $revisions_list] == -1} {
##    set new_ip_search_path "source/$opts(PERSONA_NAME)/hls"
    set new_ip_search_path "$opts(HLS_PROJECT_DIR)"
    puts "Adding search path to IP Catalog: ${new_ip_search_path}"
    set_global_assignment -name IP_SEARCH_PATHS "[get_global_assignment -name IP_SEARCH_PATHS];${new_ip_search_path}"
#}

###Specify the QDB File – generated by the full compilation
#set_instance_assignment -name QDB_FILE_PARTITION root_partition.qdb -to | -entity a10_pcie_ref_design
#
##Specify the revision type
#set_global_assignment -name REVISION_TYPE PR_IMPL
#
##Force the compiler to generate the respective RBF file
#set_global_assignment -name GENERATE_PR_RBF_FILE ON
#
##Define all files that belongs to the persona:
#set_global_assignment -name SYSTEMVERILOG_FILE source/$opts(PERSONA_NAME)/$opts(PERSONA_NAME)_top.sv
#set_global_assignment -name SYSTEMVERILOG_FILE source/$opts(PERSONA_NAME)/$opts(PERSONA_NAME).sv
#set_global_assignment -name QSYS_FILE  source/$opts(PERSONA_NAME)/local_qsys.qsys
#set_global_assignment -name IP_FILE source/$opts(PERSONA_NAME)/ip/local_qsys/local_qsys_sysid_qsys_0.ip
#set_global_assignment -name IP_FILE source/$opts(PERSONA_NAME)/ip/local_qsys/local_qsys_clock_in.ip
#set_global_assignment -name IP_FILE source/$opts(PERSONA_NAME)/ip/local_qsys/local_qsys_mm_bridge_0.ip
#set_global_assignment -name IP_FILE source/$opts(PERSONA_NAME)/ip/local_qsys/local_qsys_reset_in.ip
#set_global_assignment -name IP_FILE source/$opts(PERSONA_NAME)/ip/local_qsys/local_qsys_slavereg_comp_internal_0.ip

project_close
