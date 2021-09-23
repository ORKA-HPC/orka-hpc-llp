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


# Required packages
package require ::quartus::project
package require ::quartus::report
package require ::quartus::flow

# Common utilities
if {[file exist "quartus_resource_json_writer.tcl"]} {
  source "quartus_resource_json_writer.tcl"
} else {
  source "$::env(INTELFPGAOCLSDKROOT)/share/lib/tcl/quartus_resource_json_writer.tcl";
}

#
# Utility functions
#

# Return values: [retval panel_id row_index]
#   panel_id and row_index are only valid if the query is successful
# retval: 
#    0: success
#   -1: not found
#   -2: panel not found (could be report not loaded)
#   -3: no rows found in panel
#   -4: multiple matches found
proc find_report_panel_row { panel_name col_index string_op string_pattern } {
    if {[catch {get_report_panel_id $panel_name} panel_id] || $panel_id == -1} {
        return -2;
    }

    if {[catch {get_number_of_rows -id $panel_id} num_rows] || $num_rows == -1} {
        return -3;
    }

    # Search for row match.
    set found 0
    set row_index -1;

    for {set r 1} {$r < $num_rows} {incr r} {
        if {[catch {get_report_panel_data -id $panel_id -row $r -col $col_index} value] == 0} {
            if {[string $string_op $string_pattern $value]} {
                if {$found == 0} {
                    # If multiple rows match, return the first
                    set row_index $r
                }
                incr found
            }

        }
    }

    if {$found > 1} {return [list -4 $panel_id $row_index]}
    if {$row_index == -1} {return -1}

    return [list 0 $panel_id $row_index]
}


# get_fmax_from_report: Determines the fmax for the given clock. The fmax value returned
# will meet all timing requirements (setup, hold, recovery, removal, minimum pulse width).
# It's up to the user to find worst case slack across all corners and metrics as well as
# compensate additional slack for for PLL jitter.
# The return value is a 2-element list consisting of the maximum clock frequency in MHz
# and clk name.
# retval for frequency: 
#   -2: not found
proc get_fmax_from_report { project_rev clkname required } {
    # Find the clock period.
    set result [find_report_panel_row "*Timing Analyzer||Clocks" 0 match $clkname]
    set retval [lindex $result 0]

    if {$retval < 0} { 
        post_message -type warning "Could not find clock: $clkname."
        return [list -2 $clkname]
    }

    # Update clock name to full clock name ($clkname as passed in may contain wildcards).
    set panel_id [lindex $result 1]
    set row_index [lindex $result 2]
    set clkname [get_report_panel_data -id $panel_id -row $row_index -col 0]
    set clk_period [get_report_panel_data -id $panel_id -row $row_index -col 2]

    post_message "Clock $clkname"
    post_message "  Period: $clk_period"

    # Determine the most negative slack across all relevant timing metrics (setup, recovery, minimum pulse width)
    # and across all timing corners. Hold and removal metrics are not taken into account
    # because their slack values are independent on the clock period (for kernel clocks at least).
    #
    # Paths that involve both a posedge and negedge of the kernel clocks are not handled properly (slack
    # adjustment needs to be doubled).
    set timing_metrics [list "Setup" "Recovery" "Minimum Pulse Width"]
    set timing_metric_colindex [list 1 3 5 ]
    set timing_metric_required [list 1 0 0]
    set wc_slack $clk_period
    set has_slack 0
    set fmax_from_summary 5000.0

    # Find the "Fmax Summary" numbers reported in Quartus.  This may not
    # account for clock transfers but it does account for pos-to-neg edge same
    # clock transfers.  Whatever we calculate should be less than this.
    
    # Set the fmax panel name according to the Quartus version
    set db_version [get_database_version $project_rev]
    regexp {Version ([0-9,.]*)} $db_version matched_range matched_str
    set q_version [join [lrange [split $matched_str "."] 0 1] "."]
    set is_pro [sw_edition_is -pro]

    if ($is_pro) {
      if {$q_version >= 20.1} {
        set fmax_panel_name "*Timing Analyzer||Fmax Summary"
      } else {
        set fmax_panel_name "*Timing Analyzer||* Model||* Model Fmax Summary"
      }
    } else {
      set fmax_panel_name "*Timing Analyzer||* Model||* Fmax Summary"
    }
    
    foreach panel_name [get_report_panel_names] {
      if {[string match $fmax_panel_name $panel_name] == 1} {
        set result [find_report_panel_row $panel_name 2 equal $clkname]
        set retval [lindex $result 0]
        if {$retval == 0} {
          set restricted_fmax_field [get_report_panel_data -id [lindex $result 1] -row [lindex $result 2] -col 1]
          regexp {([0-9\.]+)} $restricted_fmax_field restricted_fmax 
          if {$restricted_fmax < $fmax_from_summary} {
            set fmax_from_summary $restricted_fmax
          }
        }
      }
    }
    post_message "  Restricted Fmax from STA: $fmax_from_summary"
    set fmax [expr $fmax_from_summary == 5000.0 ? -2 : $fmax_from_summary]

    return [list $fmax $clkname]
}


# get_component_clks_and_fmax gets the clock frequency from Quartus report panel after fitter.
# Prerequiste calling this function is project_open and load_project
proc get_component_clks_and_fmax { project_rev clk1x_info clk2x_info has_2x_clock } {
  # Compute the component fmax
  # In the case, the design has a 2x clock, we have to make sure the frequency of 1x clock is equal to half the 2x clock frequency.
  set fmax1 [ lindex [get_fmax_from_report $project_rev $clk1x_info   1] 0]
  set c_fmax $fmax1
  set fmax2 -1
  if { $has_2x_clock } {
    set fmax2 [ lindex [get_fmax_from_report $project_rev $clk2x_info 1] 0]
    if { [expr 2 * $fmax1] > $fmax2 } {
      # Lower the component fmax, this means component clock is reduced
      set c_fmax [expr $fmax2 / 2.0]
    } else {
      # Match the 2x clock
      set fmax2 [expr 2 * $fmax1]
    }
  }
  return [list $c_fmax $fmax1 $fmax2]
}

# Future work
# Highest non-global fanout signal
  #set result [find_report_panel_row "Fitter||Resource Section||Fitter Resource Usage Summary" 0 equal "Highest non-global fan-out"]
  #if {[lindex $result 0] < 0} {error "Error: Could not find highest non-global fan-out (error $retval)"}
  #set high_fanout_signal_fanout_count [get_report_panel_data -id [lindex $result 1] -row [lindex $result 2] -col 1]

  #puts $outfile "Highest non-global fanout: $high_fanout_signal_fanout_count"

#
# Public function
#

#
## Documented global proc \c generate_hls_report is the public function use for HLS to create Quartus result into report.html
# \param[in] project_name is name of the Quartus project file.
# \param[in] project_rev is the revision name used for this Quartus compile.
# \param[in] has_2x_clock is either 0 or 1. 0 means no 2x clock.
# \param[in] component_list is a list components names from design.
#
proc generate_hls_report { project_name project_rev has_2x_clock component_list } {
  project_open $project_name -revision $project_rev
  load_report $project_rev

  # $clk1x_info and $clk2x_info are set to 'clock' and 'clock2x' are the clock names in HLS components
  # work directory is one directory up. User have cd into quartus directory to call the wrapper script.
  set clk1x_info "clock"
  set clk2x_info "clock2x"
  set work_dir ".."

  set clk_freq_list [get_component_clks_and_fmax $project_rev $clk1x_info $clk2x_info $has_2x_clock]
  set c_fmax [ lindex $clk_freq_list 0 ]
  set fmax1  [ lindex $clk_freq_list 1 ]
  set fmax2  [ lindex $clk_freq_list 2 ]

  # Gather the clock frequency info
  set clock_summary_dict [gatherClockFrequency $c_fmax $fmax1 $clk1x_info $fmax2 $clk2x_info]

  # Get the project's target family and resource utilization by individual functions
  set function_res_dict [getFitterResourceByFunction $work_dir "component" $component_list]

  unload_report

  # Serialize JSON for data parsing and Javascript to incorporate into the report
  #                    path                                        Match exact name
  serializeQuartusData $work_dir $clock_summary_dict $function_res_dict 1
}

proc generate_opencl_report { project_name project_rev work_dir clk1x_info clk2x_info res_util_info} {
  project_open $project_name -revision $project_rev
  load_report $project_rev

  # Split the clock and resource usage arguments
  set clk1x_freq_list [split $clk1x_info "|"]
  set clk1x_name [lindex $clk1x_freq_list 0]
  set k_fmax [lindex $clk1x_freq_list 1]
  set fmax1 [lindex $clk1x_freq_list 2]
  set a_fmax [lindex $clk1x_freq_list 3]
  set clk2x_freq_list [split $clk2x_info "|"]
  set clk2x_name [lindex $clk2x_freq_list 0]
  set fmax2 [lindex $clk2x_freq_list 1]
  set res_util_list [split $res_util_info "|"]
  set sys_name [lindex $res_util_list 0]
  set sys_alm [lindex $res_util_list 1]
  set sys_reg [lindex $res_util_list 2]
  set sys_dsp [lindex $res_util_list 3]
  set sys_ram [lindex $res_util_list 4]

  # Gather the clock frequency info
  set clock_summary_dict [gatherClockFrequency $k_fmax $fmax1 $clk1x_name $fmax2 $clk2x_name $a_fmax]

  # Get the project's target family and resource utilization by individual functions
  set function_res_dict [getFitterResourceByFunction $work_dir]

  unload_report

  # Add the entire system resource usage
  set function_res_dict [addResourceUse $function_res_dict $sys_name $sys_alm $sys_reg $sys_dsp $sys_ram]

  # Serialize JSON for data parsing and Javascript to incorporate into the report
  serializeQuartusData $work_dir $clock_summary_dict $function_res_dict
}

#Checking if it is AOC flow
set expected_arg_len 7
if {[string equal "aoc" [lindex $quartus(args) 0]]} {
  set arglen [llength $quartus(args)]
  if {$arglen != $expected_arg_len} {
    post_message "The expected number of arguments for OpenCL should be ${expected_arg_len}. Please verify your arguments and retry.\n";
  } else {
    set index 1
    while {$index < $arglen} {
      set arg [lindex $quartus(args) $index]
      switch -- $index 1 {
        set project_name $arg
      } 2 {
        set project_rev $arg
      } 3 {
        set work_dir $arg
      } 4 {
        set clk1x_info $arg
      } 5 {
        set clk2x_info $arg
      } 6 {
        set system_res_util $arg
      }
      incr index
    }

    if {[catch {generate_opencl_report $project_name $project_rev $work_dir $clk1x_info $clk2x_info $system_res_util} errmsg]} {
      puts "Generating OpenCL report failed with the following error message:"
      puts $errmsg
      puts "Skipping report generation."
      exit -1
    }
  }
}
