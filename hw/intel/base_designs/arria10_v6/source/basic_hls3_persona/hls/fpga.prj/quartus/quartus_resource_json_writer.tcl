# (c) 1992-2021 Intel Corporation.                            
# Intel, the Intel logo, Intel, MegaCore, NIOS II, Quartus and TalkBack words    
# and logos are trademarks of Intel Corporation or its subsidiaries in the U.S.  
# and/or other countries. Other marks and brands may be claimed as the property  
# of others. See Trademarks on intel.com for full list of Intel trademarks or    
# the Trademarks & Brands Names Database (if Intel) or See www.Intel.com/legal (if Altera) 
# Your use of Intel Corporation's design tools, logic functions and other        
# software and tools, and its AMPP partner logic functions, and any output       
# files any of the foregoing (including device programming or simulation         
# files), and any associated documentation or information are expressly subject  
# to the terms and conditions of the Altera Program License Subscription         
# Agreement, Intel MegaCore Function License Agreement, or other applicable      
# license agreement, including, without limitation, that your use is for the     
# sole purpose of programming logic devices manufactured by Intel and sold by    
# Intel or its authorized distributors.  Please refer to the applicable          
# agreement for further details.                                                 

# This utility is expected to be used by adjust_pll for OPENCL or quartus_compile_report for HLS

# https://core.tcl-lang.org/tcllib/doc/tcllib-1-19/embedded/www/tcllib/files/modules/json/json_write.html
package req json::write

proc get_entity_resources_incl_subhier { fit_rpt_resource } {
    regexp {([0-9.]+)\s+\([0-9.]+\)} $fit_rpt_resource match usage
    return $usage
}

#
# Documented global proc \c getFitterResourceRow gets the resources broken down by row
# \param[in] r is the row number used to get report data from.
# \param[in] by_entity_panel_id is the id of the report panel.
# \param[in] alms_col is column number used to locate information of ALM usage.
# \param[in] registers_col is column number used to locate information of register usage.
# \param[in] dsp_col is column number used to locate information of DSP usage.
# \param[in] ram_col is column number used to locate information of RAM usage.
# \param[in] mem_alm_col is column number used to locate information of mem usage.
# 
proc getFitterResourceRow {r by_entity_panel_id alms_col registers_col dsp_col ram_col mem_alm_col} {
  set func_alms      [get_entity_resources_incl_subhier [get_report_panel_data -id $by_entity_panel_id -row $r -col $alms_col     ] ]
  set func_registers [get_entity_resources_incl_subhier [get_report_panel_data -id $by_entity_panel_id -row $r -col $registers_col] ]
  set func_dsps                                         [get_report_panel_data -id $by_entity_panel_id -row $r -col $dsp_col      ]
  set func_rams                                         [get_report_panel_data -id $by_entity_panel_id -row $r -col $ram_col      ]
  set func_mem_alms  [get_entity_resources_incl_subhier [get_report_panel_data -id $by_entity_panel_id -row $r -col $mem_alm_col  ] ]
  set func_mlabs     [expr {int($func_mem_alms/10)}]
  set my_list [list $func_alms $func_registers $func_dsps $func_rams $func_mem_alms $func_mlabs]
  return $my_list
}

#
# Documented global proc \c getFitterResourceByFunction gets the resources broken down by function
# \param[in] workdir is the working directory which kernel_report.tcl resides.
# \param[in] function_prefix is an optional argument. Value can either be "kernel" or "component". It's used for appending the proper string 
#            to user-friendly function name. Default is "kernel".
# \param[in] function_list is an optional argument. It a list of entity names to query for the resource in design. When supplied, it will 
#            When not supplied, it ignored workdir value. The default is use "kernel_report.tcl" that's generated during compilation in the workdir.
# 
proc getFitterResourceByFunction {workdir {function_prefix "kernel"} {function_list 0}} {
  # initialize undefined arguments
  if {$function_list == 0} {
    # Load design dependent utility for report
    set path "./"
    if {$workdir != 0} {
      set path $workdir
    }
    # TODO: check for file exist and check for info proc getEntityNames
    source "${workdir}/kernel_report.tcl"
    set function_list [getEntityNames]
  }
  set is_kernel [string equal $function_prefix "kernel"]

  # Since we might be paritioning the kernels/components and registering them, we need to get the resources from the "by Entity" summary
  set panel_name "Fitter Resource Utilization by Entity"
  set is_pro [sw_edition_is -pro]
  if { $is_pro } {
    set by_entity_panel_str "Fitter||Place Stage||"
    append by_entity_panel_str $panel_name
  } else {
    set by_entity_panel_str "Fitter||Resource Section||"
    append by_entity_panel_str $panel_name
  }
  set by_entity_panel_id [get_report_panel_id $by_entity_panel_str]
  set by_entity_num_rows [get_number_of_rows -id $by_entity_panel_id]

  # define family
  set family [get_global_assignment -name FAMILY]
  post_message "Get Quartus Fitter Resource Utilization: family: ${family}"
  set entity_name_col 0
  if { $is_kernel } {
    set entity_name_col 16
  }

  # TODO: Clean up the code is have a function dedicated to setup column values and names based on family
  # Setup the columns to be analyzed based on family
  set alms_col       1
  set registers_col  7
  set dsp_col       11
  set ram_col       10
  set mem_alm_col    5
  set full_name_col 15
  if { [string compare $family "Stratix10"] == 0 || [string compare $family "Stratix 10"] == 0 || [string compare $family "Agilex"] == 0 } {
    # Stratix 10 does not have virtual pin in by entity report
    set full_name_col 14
    if { $is_kernel } {
      set entity_name_col 15
    }
  }

  if { [string compare $family "MAX 10"] == 0 } {
    set alms_col      1
    set registers_col 2
    set dsp_col       7
    set ram_col       5
  }
  # Setup resource names based on family
  set logic_name "ALMs"
  if { [string compare $family "MAX 10"] == 0 } {
    set logic_name "LCs"
  }

  # Dictionary of functions of resource usage
  set functions_res_usage [dict create]

  foreach function $function_list {
    # Convert user-friendly names to RTL module name (aka entity name)
    if { $is_kernel == 0 } {
      set function_inst_name "${function}:${function}_inst";
      if { $is_pro } {
        set function_inst_name "${function}_inst";
      }
    } else {
      set function_inst_name [string map {"," "_top_wrapper_"} $function]
    }

    # number of entities matches function name
    set match_entity_num 0
    set func_list [list 0 0 0 0 0 0]

    for {set r 0} {$r < $by_entity_num_rows} {incr r} {
      if {[catch {get_report_panel_data -id $by_entity_panel_id -row $r -col $entity_name_col} entity] == 0} {
        set entity_name [string trim $entity " |"]
        if {[string equal $function_inst_name $entity_name] } {

          # HLS
          if { $is_kernel == 0 } {
            if ($is_pro) {
              if {[catch {get_report_panel_data -id $by_entity_panel_id -row $r -col $full_name_col } full_hr] == 0} {
                set full_hr_name [string trim $full_hr " |"]
                if {[string equal $function_inst_name $full_hr_name] } {
                  set match_entity_num  [expr $match_entity_num + 1 ]
                  set func_list [getFitterResourceRow $r $by_entity_panel_id $alms_col $registers_col $dsp_col $ram_col $mem_alm_col]
                }
              }
            } else {
              set match_entity_num  [expr $match_entity_num + 1 ]
              set func_list [getFitterResourceRow $r $by_entity_panel_id $alms_col $registers_col $dsp_col $ram_col $mem_alm_col]
            }
          # OpenCL
          } else {
            if ($is_pro) {
              set match_entity_num  [expr $match_entity_num + 1 ]
              set func_list [getFitterResourceRow $r $by_entity_panel_id $alms_col $registers_col $dsp_col $ram_col $mem_alm_col]
            } else {
              # Cyclone V not supported in OpenCL
              post_message -type error "Cyclone V is not supported in OpenCL."
            }
          }
        }
      }
    }
    # match_entity_num should be 1, otherwise data reported is wrong
    if { $match_entity_num != 1 } {
      post_message -type error "Found $match_entity_num entrie(s) that matches the $function_prefix name: $function_inst_name, this will cause reporting issue!"
    }
    set func_alms [lindex $func_list 0]
    set func_registers [lindex $func_list 1]
    set func_dsps [lindex $func_list 2]
    set func_rams [lindex $func_list 3]
    set func_mem_alms [lindex $func_list 4]
    set func_mlabs [lindex $func_list 5]
    set functions_res_usage [addResourceUse $functions_res_usage $function $func_alms $func_registers $func_dsps $func_rams $func_mlabs]
  }
  return $functions_res_usage
}

proc addAttribute {dbVar key val} {
    upvar 1 $dbVar db
    # Create the new record
    dict set db $key $val
}

#
# Documented global proc \c gatherClockFrequency gathers the clock frequencies and their name into a dictionary and
# annotate necessary details when clock2x limits clock1x
# \param[in] clock1x_fmax is clock frequency that can be used by the kernel or component. It's the minimum of itself or
#            half of clock2x_fmax.
#            Value less than 0 means does not exist which means error because the design needs at least one clock.
# \param[in] fmax1 is the theortical maximum on clock1x domain.
# \param[in] clock2x_fmax is the frequency on the 2x clock. -1 means does not exist, -2 means error when get data from
#            Quartus report panel.
# \param[in] clock1x_actual is used by OpenCL to show the final frequency after finding the PLL settings that achieve 
#            closest value to clock1x_fmax.
# 
proc gatherClockFrequency {clock1x_fmax fmax1 clock1x_name clock2x_fmax clock2x_name {clock1x_actual -1}} {
  dict set clk_sum_dict name "Quartus Fitter: Clock Frequency (MHz)"
  if { $clock1x_fmax < 0 } {
    # Error handling: get_report_panel_data is likely outdated
    addAttribute clk_sum_dict ${clock1x_name} Error
    return $clk_sum_dict
  }
  # actual frequency is only applicable if adjust PLL is called for OpenCL
  set clk_detail_text {}
  if { $clock1x_actual != -1} {
    set actual_freq [format "%.2f" $clock1x_actual]
    set clock1x_freq [format "%.2f" $clock1x_fmax]
    addAttribute clk_sum_dict $clock1x_name $actual_freq
    # Hidden attribute
    addAttribute clk_sum_dict "$clock1x_name fmax" $clock1x_freq
    # Handles PLL adjust could lower actual frequency.
    set clk_detail_text "The actual frequency of $clock1x_name is $actual_freq MHz after platform PLL adjustment. The maximum frequency for $clock1x_name is $clock1x_freq MHz. "
  } else {
    addAttribute clk_sum_dict $clock1x_name [format "%.2f" $clock1x_fmax]
  }
  # Hidden attribute
  addAttribute clk_sum_dict "clock1x" [format "%.2f" $fmax1]

  if { $clock2x_fmax == -2 } {
    # Error handling: get_report_panel_data is likely outdated
    # We don't have check for -1 because -1 means not available
    addAttribute clk_sum_dict $clock2x_name Error
  } elseif { $clock2x_fmax > 0 } {
    set clock2x_freq [format "%.2f" $clock2x_fmax]
    addAttribute clk_sum_dict $clock2x_name $clock2x_freq
    if { $fmax1 > $clock1x_fmax } { 
      # Higher 1x clock fmax could be achieved without the 2x clock. This condition means clock1x_fmax was reduced by clock2x_fmax
      # We don't use the clock2x_fmax because that value could be post-PLL adjust. And so we just compute the original value.
      set fmax_freq [format "%.2f" $fmax1]
      set clock1x_freq [format "%.2f" $clock1x_fmax]
      set clock2x_freq [format "%.2f" [expr 2 * $clock1x_fmax]]
      set clk_detail_text "${clk_detail_text}${clock1x_name} frequency is limited by the ${clock2x_name}. Maximum frequency achieved on the ${clock1x_name} is reduced from ${fmax_freq} MHz to ${clock1x_freq} MHz (${clock2x_freq} MHz ${clock2x_name} frequency divided by 2)."
    }
  }
  # Avoid nested dictionary due to serialization problems with pipe delimiter. Use Text as key until details schema is switch over to new one.
  set clk_detail_text "text|${clk_detail_text}"
  dict set clk_sum_dict details $clk_detail_text
  return $clk_sum_dict
}

proc addResourceUse {res_dict name alm_used reg_used dsp_used ram_used {mlab_used -1} {alut_used -1}} {
  dict set res_dict $name alm $alm_used
  dict set res_dict $name reg $reg_used
  dict set res_dict $name dsp $dsp_used
  dict set res_dict $name ram $ram_used
  if { [expr {$mlab_used >= 0}] } {
    dict set res_dict $name mlab $mlab_used
  }
  if { [expr {$alut_used >= 0}] } {
    dict set res_dict $name alut $alut_used
  }
  return $res_dict
}

#
# Documented global proc \c serializeQuartusJSON serializes fitter data into quartus.json or quartus_data.js that is accepted by report.html.
# \param[in] path is the output directory for the json or javascript file. Slash will be added.
# \param[in] fitter_clk_freq_node is a dictionary formatted ready to be print.
# \param[in] fitter_res_usage_nodes is a dictionary formatted ready to be print. When there's no top level in fitter_res_usage_nodes,
#            The function will compute sum all the nodes and add a total design as top level.
# \param[in] json_format is 1 to set output to JSON file: quartus.json, 0 for Javascript: quartus_data.js.
# \param[in] use_exact_name is for name matching. 1 means look for exact name. 0 is designed for OpenCL num_compute_unit where the kernel and id
#            is in the format of <kernel name>,<id #>.
#
proc serializeQuartusJSON {path fitter_clk_freq_node fitter_res_usage_nodes json_format use_exact_name} {
  set report_file_name [expr {$json_format ? "quartus.json" : "quartus_data.js"}]
  set report_file_path "${path}/${report_file_name}"

  if { $json_format == 0 } {
    # remove indent
    json::write indented false
  } else {
    json::write indented true
  }
  
  # TODO: check for empty fitter_clk_freq_node

  # fitter clock summary
  # add type to system for clock section as this affects the entire system
  dict set fitter_clk_freq_node type system
  set nodes_json [json::write array [json::write object {*}[dict map {key val} $fitter_clk_freq_node {
        if { [string equal $key "details"] } {
          # format details to proper JSON as it's an array
          set tmp [split $val {|}]
          json::write array [json::write object [lindex $tmp 0] [json::write string [lindex $tmp 1]]]
        } else {
          json::write string $val
        }
      }]]]
  set clk_summary_json [json::write object "nodes" $nodes_json]
  dict set quartus_data "quartusFitClockSummary" $clk_summary_json

  # TODO: check for empty fitter_res_usage_nodes

  # Determine if this contains top level. If not, we compute the sum on the fly.
  # We also use this to determine if it's node type since HLS does not compute Full design up front.
  set has_top_level 0
  set node_type component
  dict for {function_name res_util} $fitter_res_usage_nodes {
    if {[string first "Total Used" $function_name] >= 0 || [string first "kernel_system" $function_name] >= 0} {
      # We would have top level
      set node_type kernel
      set has_top_level 1
      break;
    }
  }

  # We create a new top level if the function list does not contain one
  if {$has_top_level == 0} {
    set alms      0
    set registers 0
    set dsps      0
    set rams      0
    set mlabs     0
    dict for {function_name res_util} $fitter_res_usage_nodes {
      set tmp [split $res_util { }]
      for { set i 0 } { $i < [llength $tmp] } { set i [expr $i+2] } {
        set restype [lindex $tmp $i]
        set val [lindex $tmp [expr $i+1]]
        switch $restype {
          alm {
            set alms      [expr $alms      + $val]
          }
          reg {
            set registers [expr $registers + $val]
          }
          dsp {
            set dsps      [expr $dsps      + $val]
          }
          ram {
            set rams      [expr $rams      + $val]
          }
          mlab {
            set mlabs     [expr $mlabs     + $val]
          }
        }
      }
    }
    set title_name [string totitle $node_type]
    set full_design_name "Quartus Fitter: Full Design (All ${title_name}s)"
    dict set fitter_res_usage_nodes $full_design_name alm $alms
    dict set fitter_res_usage_nodes $full_design_name reg $registers
    dict set fitter_res_usage_nodes $full_design_name dsp $dsps
    dict set fitter_res_usage_nodes $full_design_name ram $rams
    dict set fitter_res_usage_nodes $full_design_name mlab $mlabs
  }
  # fitter resource utilizaton summary
  set nodes_list [list]
  # each function is one node
  dict for {function_name res_util} $fitter_res_usage_nodes {
    set func_res_dict [dict create]
    # add type to fitter_res_usage_nodes
    set cur_node_type ""
    set cur_node_id 1010  ;# TODO: add id for component or kernel
    if {[string first "Total Used" $function_name] >= 0} {
      # OpenCL always have total used because it includes static region
      set cur_node_type aclsystem
      set cur_node_id 1001
    } elseif {[string first "kernel_system" $function_name] >= 0} {
      set cur_node_type system
      set cur_node_id 1000
    } elseif {[string first "Full Design" $function_name] >= 0} {
      set cur_node_type system
      set cur_node_id 1000
    } else {
      # set the node type for the rest of functions
      set cur_node_type $node_type
    }
    dict set func_res_dict type [json::write string $cur_node_type]
    dict set func_res_dict id [json::write string $cur_node_id]

    # OpenCL can make multiple copies of the same kernel with num_compute_units
    # The kernel name and compute id is separated by a comma
    if { $use_exact_name == 0 && [string first "," $function_name] >= 0} {
      set func_info [split $function_name ","]
      set has_multiple [info exists fitter_res_usage_nodes([lindex $func_info 0],[expr [lindex $func_info 1] + 1])]
      if { [lindex $func_info 1] == 0 && !$has_multiple } {
        # first one and no multiple, then we just element 0
        set final_function_name [lindex $func_info 0]
      } else {
        # replace all comma with underscore for user-friendly name
        set final_function_name [string map {"," "_"} $function_name]
      }
    } else {
      if {[string first "kernel_system" $function_name] >= 0} {
        set final_function_name "Quartus Fitter: Kernel System"
      } else {
        set final_function_name $function_name
      }
    }

    dict set func_res_dict name [json::write string $final_function_name]

    set tmp [split $res_util { }]
    for { set i 0 } { $i < [llength $tmp] } { set i [expr $i+2] } {
      set restype [lindex $tmp $i]
      set val [lindex $tmp [expr $i+1]]
      dict set func_res_dict $restype [json::write string $val]
    }
    set node_json [json::write object {*}$func_res_dict]
    lappend nodes_list $node_json
  }
  set nodes_json [json::write array {*}$nodes_list]
  set res_summary_json [json::write object "nodes" $nodes_json]
  dict set quartus_data "quartusFitResourceUsageSummary" $res_summary_json
  set quartus_json [json::write object {*}$quartus_data]
  set outfile [open $report_file_path w]
  # add variable when
  if { $json_format == 0 } {
    set quartus_js "var quartusJSON=${quartus_json};"
    puts $outfile $quartus_js
  } else {
    puts $outfile $quartus_json
  }
  close $outfile
  return 0
}

#
# Documented global proc \c serializeQuartusData serializes fitter data into report folder.
# \param[in] workdir is the working directory during compilation. It's the same folder that contains reports folder.
# \param[in] fitter_clk_freq_node is a dictionary formatted ready to be print.
# \param[in] fitter_res_usage_nodes is a dictionary formatted ready to be print.
# \param[in] use_exact_name is an optional argument for name matching. 1 means look for exact name. 0 is designed for OpenCL num_compute_unit where the kernel and id
#            is in the format of <kernel name>,<id #>. Default is 0.
#
proc serializeQuartusData {workdir fitter_clk_freq_node fitter_res_usage_nodes {use_exact_name 0}} {
  # invoke JSON serialization for reporting
  #                    path                                                                quartus.json
  serializeQuartusJSON "${workdir}/reports/lib/json" $fitter_clk_freq_node $fitter_res_usage_nodes 1 $use_exact_name
  #                    path                                                         quartus_data.js
  serializeQuartusJSON "${workdir}/reports/lib" $fitter_clk_freq_node $fitter_res_usage_nodes 0 $use_exact_name
}