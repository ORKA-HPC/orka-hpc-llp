#set constraintCode {set_property -dict { PACKAGE_PIN G18    IOSTANDARD LVCMOS33 } [get_ports { eth_ref_clk }]; #         Sch=eth_ref_clk}
#file mkdir $design_dir/$proj_name_long/$proj_name_short\.srcs/constrs_1
#file mkdir $design_dir/$proj_name_long/$proj_name_short\.srcs/constrs_1/new
#set fileID [ open $design_dir/$proj_name_long/$proj_name_short\.srcs/constrs_1/new/eth_ref_clk.xdc w ]
#puts $fileID $constraintCode
#close $fileID
#add_files -fileset constrs_1 $design_dir/$proj_name_long/$proj_name_short\.srcs/constrs_1/new/eth_ref_clk.xdc
