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
# Writes and prints IP address map

# File destination
#set addr_file "${design_dir}/AddressMap.json"
set addr_file "${dest_path}/${json_filename}"

###### DEBUG
#set platform_name "vcu118"
#set fpga_id 0
#set bd_design_name "bdname"
#set infrastructure_type "dma"
#set axilite_bar_size 2m
#set axifull_bar_size 2k
#set target_part "xcvu9p-flga2104-2L-e"
#set manufacturer_board "Xilinx"
#set manufacturer_fpga "Xilinx"
#set addr_file "~/work/AddressMap.json"
######



proc indent {dest num} {
    for {set cnt 0} {$cnt < $num} {incr cnt} {
        exec printf "    " >> $dest
    }
}

proc writeobjs {dest idt name value comma} {
    indent $dest $idt
    exec printf "\"%s\": \"%s\"%s\n" "$name" "$value" "$comma" >> $dest
}

proc writeobji {dest idt name value comma} {
    indent $dest $idt
    exec printf "\"%s\": %s%s\n" "$name" "$value" "$comma" >> $dest
}


# Read adress map from bd
set names [get_bd_addr_segs]
set offs [get_property offset [get_bd_addr_segs]]
set rangs [get_property range [get_bd_addr_segs]]
# make list and remove duplicate spaces (otherwise entries with "{}" will be skipped)
set names_l [regexp -all -inline {\S+} $names]
set offs_l [regexp -all -inline {\S+} $offs]
set rangs_l [regexp -all -inline {\S+} $rangs]

# Write json file
# Check if json file already exists
# yes: extend it with info for this bitstream
# no: create new json file
set create_new_json 1
if { [file exists "${dest_path}/${json_filename}"] } {
    set create_new_json 0
}

if { $create_new_json } {
# Code indentation corresponds to json file instead of brackets.
# Variable t saves the current number of tabs to indent with.

set t 0
exec printf "" >  $addr_file
exec printf "\{\n" >> $addr_file
    incr t
    writeobjs $addr_file $t FileType boardsupportpackage ,
    writeobjs $addr_file $t Comment "Kein Kommentar" ,
    writeobjs $addr_file $t BoardName $platform_name ,
    writeobjs $addr_file $t BlockDesignName $bd_design_name ,
    writeobjs $addr_file $t ManufacturerBoard $manufacturer_board ,

# Drivers START
#TODO might need to extend driver section on multi-fpga boards.
#     for now all interfaces must be on fpga 0.
    indent $addr_file $t; exec printf "\"Drivers\":\n" >> $addr_file
    indent $addr_file $t; exec printf "\[\n" >> $addr_file

    if { $enable_pcie == "1" } {
        incr t
        indent $addr_file $t; exec printf "\{\n" >> $addr_file
            incr t
            writeobjs $addr_file $t DriverName xdma ,
            writeobji $addr_file $t Instance 0 ,
            writeobji $addr_file $t Port 0 ,
            writeobji $addr_file $t Speed 0 ""
        set t [expr {$t - 1}]
        # close with "," if there is another item following...
        if { $enable_axi_ethernet_lite == "1" || $enable_usb_uart == "1" || $enable_usb_uart_lite == "1" } {
            indent $addr_file $t; exec printf "\},\n" >> $addr_file
        } else {
            indent $addr_file $t; exec printf "\}\n" >> $addr_file
        }
    set t [expr {$t - 1}]
    }

    if { $enable_axi_ethernet_lite == "1" } {
        incr t
        indent $addr_file $t; exec printf "\{\n" >> $addr_file
            incr t
            writeobjs $addr_file $t DriverName ipv4 ,
            writeobjs $addr_file $t Address "192.168.1.10" ,
            writeobji $addr_file $t Port 6789 ,
            writeobji $addr_file $t Speed 100000000 ""
        set t [expr {$t - 1}]
        # close with "," if there is another item following...
        if { $enable_usb_uart == "1" || $enable_usb_uart_lite == "1" } {
            indent $addr_file $t; exec printf "\},\n" >> $addr_file
        } else {
            indent $addr_file $t; exec printf "\}\n" >> $addr_file
        }
    set t [expr {$t - 1}]
    }
    
    if { $enable_usb_uart == "1" || $enable_usb_uart_lite == "1" } {
        # TODO get baud rate from usb_uart
        set br 9600
        if { $enable_usb_uart_lite == "1" } {
            set br [get_property CONFIG.C_BAUDRATE [get_bd_cells axi_uart]]
        }
        incr t
        indent $addr_file $t; exec printf "\{\n" >> $addr_file
            incr t
            writeobjs $addr_file $t DriverName usb_uart ,
            writeobji $addr_file $t Instance 0 ,
            writeobji $addr_file $t Port 0 ,
            writeobji $addr_file $t Speed $br ""
        set t [expr {$t - 1}]
        indent $addr_file $t; exec printf "\}\n" >> $addr_file
    set t [expr {$t - 1}]
    }

    indent $addr_file $t; exec printf "\],\n" >> $addr_file
# Drivers END
# PCIe BARs START
    if { $enable_pcie == "1" } {
    indent $addr_file $t; exec printf "\"pciebars\":\n" >> $addr_file
    indent $addr_file $t; exec printf "\[\n" >> $addr_file
        incr t
        indent $addr_file $t; exec printf "\{\n" >> $addr_file
            incr t
            writeobjs $addr_file $t type MMIO ,
            writeobjs $addr_file $t size $axilite_bar_size ""
        set t [expr {$t - 1}]
        indent $addr_file $t; exec printf "\},\n" >> $addr_file
        indent $addr_file $t; exec printf "\{\n" >> $addr_file
            incr t
            writeobjs $addr_file $t type DMA ,
            writeobjs $addr_file $t size $axifull_bar_size ""
        set t [expr {$t - 1}]
        indent $addr_file $t; exec printf "\}\n" >> $addr_file
    set t [expr {$t - 1}]
    indent $addr_file $t; exec printf "\],\n" >> $addr_file
    }
# PCIe BARs END
# FPGAs START
    indent $addr_file $t; exec printf "\"FPGAs\":\n" >> $addr_file
    indent $addr_file $t; exec printf "\[\n" >> $addr_file
        incr t

}
if {!$create_new_json} {
    # Modify after last FPGA entry
    # delete last 3 lines of addr_file
    set f [open $addr_file "r+"];
    set ptrList {}
    while {![eof $f]} {
        lappend ptrList [tell $f]
        gets $f
    }
    set newLength [lindex $ptrList end-3]
    chan truncate $f $newLength
    close $f

    #write close last fpga with square close bracket and ,
    set t 2
    indent $addr_file $t; exec printf "\},\n" >> $addr_file
}

        indent $addr_file $t; exec printf "\{\n" >> $addr_file
            incr t
            writeobjs $addr_file $t Manufacturer $manufacturer_fpga ,
            writeobjs $addr_file $t FullNameQualifier $target_part ,
            #TODO
            writeobji $addr_file $t Driver 0 ,
            writeobjs $addr_file $t Bitstream ${bitstream_filename} ,
            indent $addr_file $t; exec printf "\"Components\":\n" >> $addr_file
            indent $addr_file $t; exec printf "\[\n" >> $addr_file
                incr t

                    set num [exec echo ${names} | wc -w]
                    for {set i 0} {$i < $num} {incr i} {
                        set offset [lindex "$offs_l" $i]
                        set range  [lindex "$rangs_l" $i]
                        set name   [lindex "$names_l" $i]
                    
                        #skip if offset is "{}"
                        if {$offset ne "{}"} {
                            indent $addr_file $t; exec printf "\{\n" >> $addr_file
                            incr t
                            writeobjs $addr_file $t name $name ,
                            writeobjs $addr_file $t offset $offset ,
                            writeobjs $addr_file $t range $range ""
                            set t [expr {$t - 1}]
                            indent $addr_file $t; exec printf "\}" >> $addr_file
                            if {$i < [expr {$num - 1}]} { exec printf "," >> $addr_file }
                            exec printf "\n" >> $addr_file
                        }
                    }

            set t [expr {$t - 1}]
            indent $addr_file $t; exec printf "\]\n" >> $addr_file
        set t [expr {$t - 1}]
        indent $addr_file $t; exec printf "\}\n" >> $addr_file
    set t [expr {$t - 1}]
    indent $addr_file $t; exec printf "\]\n" >> $addr_file
# FPGAs END
set t [expr {$t - 1}]
exec printf "\}\n" >> $addr_file

