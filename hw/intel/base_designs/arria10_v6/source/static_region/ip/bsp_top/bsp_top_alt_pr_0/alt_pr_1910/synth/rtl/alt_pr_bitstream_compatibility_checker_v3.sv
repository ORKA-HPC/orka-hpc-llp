// (C) 2001-2021 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1ns/1ns
module alt_pr_bitstream_compatibility_checker_v3(
    clk,
    nreset,
    freeze,
    crc_error,
    pr_error,
    pr_ready,
    pr_done,
    data,
    data_valid,
    data_ready,
    o_bitstream_incompatible,
    o_update_list
);

    parameter CDRATIO       = 1;
    parameter CB_DATA_WIDTH = 32;
    
    localparam  LOC_NUM         = (CB_DATA_WIDTH == 32)? 71 : 143;
    localparam  DATA_GAP        = (CB_DATA_WIDTH == 32)? 0 : 1;
    localparam  MAX_RAM_ADDR    = 20;
    localparam  MAX_RAM_ADDR_W  = MAX_RAM_ADDR >> 2;
    
    input clk; 
    input nreset;
    input freeze;
    input crc_error;
    input pr_error;
    input pr_ready;
    input pr_done;
    input data_valid;
    input data_ready;
    input [CB_DATA_WIDTH-1:0] data;

    output o_bitstream_incompatible;
    output o_update_list;
    
    typedef enum logic [6:0]
    {STATE_IDLE, STATE_READY_H, STATE_READ_NUM, STATE_READ_F_HIER, STATE_READ_ID, STATE_READ_HIER,
        STATE_COMP_READ, STATE_COMP_WAIT, STATE_COMP_RUN, STATE_COMP_DONE, 
        STATE_PREUP_READ, STATE_PREUP_WAIT, STATE_PREUP_COMPARE, STATE_PREUP_SKIP, STATE_PREUP_UPDATE, STATE_PREUP_DONE,
        STATE_SORT_READ, STATE_SORT_WAIT, STATE_SORT_STORE, 
        STATE_SORT_READ2, STATE_SORT_WAIT2, STATE_SORT_COMPARE, 
        STATE_SORT_UPT_CURR, STATE_SORT_UPT_NEW, STATE_SORT_CONT, STATE_SORT_NEXT, STATE_SORT_DONE,
        STATE_UPT_READ, STATE_UPT_WAIT, STATE_UPT_WRITE, STATE_UPT_DONE,
        STATE_CLEAR, STATE_COMPLETE} current_t;
    current_t current_state, next_state;

    logic bitstream_incompatible_reg;
    logic update_list_reg;
    
    logic first_data_reg;
    logic clear_end_reg;
    
    logic op_end_sig;
    logic valid_data_sig;
    
    logic [7:0] data_count_reg;
    logic [4:0] num_count_reg;
    logic [4:0] num_count_ref_reg;
    logic [4:0] num_run_reg;
    
    logic [31:0] num_reg;
    logic [31:0] hier_index_reg;
    logic [31:0] prpof_id_reg;

    logic [31:0] data_wire;
    logic [31:0] data_reg;
    
    logic [31:0] ref_hi_reg;
    logic [31:0] ref_pi_reg;
    logic [31:0] run_hi_reg;
    logic [31:0] run_pi_reg;
    
    logic [4:0]  handler_addr;
    logic [31:0] read_handler_hi_data;
    logic [31:0] write_handler_hi_data;
    logic        write_handler_hi;
    logic [31:0] read_handler_pi_data;
    logic [31:0] write_handler_pi_data;
    logic        write_handler_pi;
    
    logic [4:0]  ref_addr;
    logic [31:0] read_ref_hi_data;
    logic [31:0] write_ref_hi_data;
    logic        write_ref_hi;
    logic [31:0] read_ref_pi_data;
    logic [31:0] write_ref_pi_data;
    logic        write_ref_pi;
    
    assign o_bitstream_incompatible = bitstream_incompatible_reg;
    assign o_update_list = update_list_reg;

// Valid adta    
    assign valid_data_sig = data_valid && data_ready;
    
// End operation event
    assign op_end_sig = ~freeze || ~pr_ready || crc_error || pr_error || pr_done;

// ***********************************************************************************************************    
//  State machine
//      - Store bitstream information in IP
//      - Trigger compatibility check
//      - Trigger update & sorting
// ***********************************************************************************************************
//  STATE_IDLE          : Idle state that prepare for bitstream compatibility check.
//                        If freeze signal is asserted, go to STATE_READY_H.
//  STATE_READY_H       : Wait PR_READY signal asserted, go to STATE_READ_NUM.
//                        If freeze signal deasserted, go back to STATE_IDLE.
//  STATE_READ_NUM      : Read total length of hierarchy index + PRPOF ID from bitstream, go to STATE_READ_F_HIER. 
//                        If any end operation event happens, go to STATE_COMPLETE.
//  STATE_READ_F_HIER   : Read hierarchy index from bitstream and store in handler RAM list, go to STATE_READ_ID.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_READ_ID       : Read PR POF ID from bistream  and store in handler RAM list, go to STATE_READ_HIER.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_READ_HIER     : If still have pending pairs of hierarchy index + PRPOF ID, go back to STATE_READ_ID.
//                          Else, go to STATE_COMP_READ.
//                        If any end operation event happens, go to STATE_UPT_DONE. 
//  STATE_COMP_READ     : Start compatibility check by reading PRPOF ID from ref RAM list,
//                          go to STATE_COMP_WAIT.
//                        If any end operation event happens or end of address, go to STATE_UPT_DONE.
//  STATE_COMP_WAIT     : Wait a clock for RAM retrieval, go to STATE_COMP_RUN.
//                        If any end operation event happens or end of address, go to STATE_UPT_DONE.
//  STATE_COMP_RUN      : Compare PRPOF ID from bitstream and those in ref RAM list.
//                        If same, go to STATE_COMP_DONE.
//                          Else, go back to STATE_COMP_READ to compare next value.
//                        If any end operation event happens or all 0's data, go to STATE_UPT_DONE.
//  STATE_COMP_DONE     : Complete compatibility check, any mismatch would be capture here. Go to STATE_PREUP_READ.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_PREUP_READ    : Start update handler RAM list by reading hierarchy index from ref RAM list, 
//                          go to STATE_PREUP_WAIT.
//                        If end of address, go to STATE_PREUP_DONE.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_PREUP_WAIT    : Wait a clock for RAM retrieval, go to STATE_PREUP_COMPARE.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_PREUP_COMPARE : Compare hierarchy index from bitstream and those in ref RAM list.
//                        If all 0's data, go to STATE_PREUP_DONE.
//                          Else if different PR region / parent PR region, go to STATE_PREUP_UPDATE.
//                          Else, go to STATE_PREUP_SKIP.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_PREUP_SKIP    : Skip this data, go back to STATE_PREUP_READ.
//  STATE_PREUP_UPDATE  : Copy data from ref RAM list to handler RAM list, go back to STATE_PREUP_READ.
//  STATE_PREUP_DONE    : Complete update handler RAM list, go to STATE_SORT_READ. 
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_SORT_READ     : Start sorting (ascending) by reading hierarchy index for data1 in handler RAM list,
//                          go to STATE_SORT_WAIT.
//                        If end of address for data1, go to STATE_SORT_DONE.  
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_SORT_WAIT     : Wait a clock for RAM retrieval, go to STATE_SORT_STORE.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_SORT_STORE    : Store data1 into register, go to STATE_SORT_READ2.
//                        If data1 all 0's, go to STATE_SORT_DONE.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_SORT_READ2    : Read hierarchy index for data2 in handler RAM list, go to STATE_SORT_WAIT2.
//                        If end of address for data2, go to STATE_SORT_NEXT.                     
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_SORT_WAIT2    : Wait a clock for RAM retrieval, go to STATE_SORT_COMPARE.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_SORT_COMPARE  : Compare data1 to data2.
//                        If data2 all 0's, go to STATE_SORT_NEXT.
//                        If data1 smaller, go to STATE_SORT_CONT.
//                          Else, go to STATE_SORT_UPT_CURR.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_SORT_UPT_CURR : Replace data1 with data2, go to STATE_SORT_UPT_NEW.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_SORT_UPT_NEW  : Copy data1 back to data2, got to STATE_SORT_CONT.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_SORT_CONT     : Continue to check subsequent data, go to STATE_SORT_READ2.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_SORT_NEXT     : Prepare to sort on next data, go to STATE_SORT_READ.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_SORT_DONE     : Complete sorting handler RAM list, wait for pr_done signal and go to STATE_UPT_READ.
//                        If any end operation event happens, go to STATE_UPT_DONE.
//  STATE_UPT_READ      : Start update ref RAM list by referring to handler RAM list, go to STATE_UPT_WAIT.
//                        If end of address, go to STATE_UPT_DONE.
//  STATE_UPT_WAIT      : Wait a clock for RAM retrieval, go to STATE_UPT_WRITE.
//  STATE_UPT_WRITE     : Update ref RAM list, go to STATE_UPT_READ.
//  STATE_UPT_DONE      : Complete update ref RAM list, go to STATE_CLEAR.
//  STATE_CLEAR         : Clear handler RAM list, go to STATE_COMPLETE.
//  STATE_COMPLETE      : Wait freeze signal deassert and go back to STATE_IDLE.      
    always_ff @(posedge clk) begin
        if (~nreset)
            current_state <= STATE_IDLE;
        else
            current_state <= next_state;
    end

    always_comb begin
        next_state = STATE_IDLE;

        case (current_state)
            STATE_IDLE: begin
                next_state = STATE_IDLE;
                if (freeze)
                    next_state = STATE_READY_H;
            end

            STATE_READY_H: begin
                next_state = STATE_READY_H;
                if (~freeze)
                    next_state = STATE_IDLE;
                else if (pr_ready)
                    next_state = STATE_READ_NUM;
            end

            STATE_READ_NUM: begin
                next_state = STATE_READ_NUM;
                if (op_end_sig)
                    next_state = STATE_COMPLETE;  
                else if (valid_data_sig && data_count_reg == LOC_NUM)                    
                    next_state = STATE_READ_F_HIER;
            end
            
            STATE_READ_F_HIER: begin
                next_state = STATE_READ_F_HIER;
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else if (valid_data_sig && data_count_reg == DATA_GAP)   
                    next_state = STATE_READ_ID;
            end
                
            STATE_READ_ID: begin
                next_state = STATE_READ_ID;
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else if (valid_data_sig && data_count_reg == DATA_GAP)
                    next_state = STATE_READ_HIER;
            end
            
            STATE_READ_HIER: begin
                next_state = STATE_READ_HIER;
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else if (num_count_reg == (num_reg[4:0] - 5'b1))
                    next_state = STATE_COMP_READ;
                else if (valid_data_sig && data_count_reg == DATA_GAP)   
                    next_state = STATE_READ_ID;
            end
                
            STATE_COMP_READ: begin
                if ((op_end_sig) || (ref_addr == (MAX_RAM_ADDR - 1)))
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_COMP_WAIT;
            end
            
            STATE_COMP_WAIT: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_COMP_RUN;
            end
            
            STATE_COMP_RUN: begin
                if ((op_end_sig) || (read_ref_pi_data == '0)) 
                    next_state = STATE_UPT_DONE;
                else if (read_ref_pi_data == prpof_id_reg)
                    next_state = STATE_COMP_DONE;
                else
                    next_state = STATE_COMP_READ;
            end
            
            STATE_COMP_DONE: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_PREUP_READ;
            end
                
            STATE_PREUP_READ: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else if (ref_addr == (MAX_RAM_ADDR - 1))
                    next_state = STATE_PREUP_DONE;
                else
                    next_state = STATE_PREUP_WAIT;
            end
            
            STATE_PREUP_WAIT: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_PREUP_COMPARE;
            end
            
            STATE_PREUP_COMPARE: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else if (read_ref_hi_data == 32'd0)
                    next_state = STATE_PREUP_DONE;
                else if (read_ref_hi_data < hier_index_reg)
                    next_state = STATE_PREUP_UPDATE;
                else if (read_ref_hi_data > hier_index_reg) begin
                    if (read_ref_hi_data[31:24] != hier_index_reg[31:24])
                        next_state = STATE_PREUP_UPDATE;
                    else if ((hier_index_reg[23:20] != 4'd0) 
                                && (read_ref_hi_data[23:20] != hier_index_reg[23:20]))
                        next_state = STATE_PREUP_UPDATE;
                    else if ((hier_index_reg[19:16] != 4'd0) 
                                && (read_ref_hi_data[19:16] != hier_index_reg[19:16]))
                        next_state = STATE_PREUP_UPDATE;
                    else
                        next_state = STATE_PREUP_SKIP;
                end
                else
                    next_state = STATE_PREUP_SKIP;
            end
            
            STATE_PREUP_SKIP: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_PREUP_READ;
            end
            
            STATE_PREUP_UPDATE: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_PREUP_READ;
            end
            
            STATE_PREUP_DONE: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_SORT_READ;
            end
            
            STATE_SORT_READ: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else if (handler_addr == (MAX_RAM_ADDR - 1))
                    next_state = STATE_SORT_DONE;
                else
                    next_state = STATE_SORT_WAIT;
            end
            
            STATE_SORT_WAIT: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_SORT_STORE;
            end
            
            STATE_SORT_STORE: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else if (read_handler_hi_data == 32'd0)
                    next_state = STATE_SORT_DONE;
                else
                    next_state = STATE_SORT_READ2;
            end
            
            STATE_SORT_READ2: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else if (handler_addr == (MAX_RAM_ADDR - 1))
                    next_state = STATE_SORT_NEXT;
                else
                    next_state = STATE_SORT_WAIT2;
            end
            
            STATE_SORT_WAIT2: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_SORT_COMPARE;
            end
            
            STATE_SORT_COMPARE: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else if (read_handler_hi_data == 32'd0)
                    next_state = STATE_SORT_NEXT;
                else if (read_handler_hi_data > ref_hi_reg)
                    next_state = STATE_SORT_CONT;
                else
                    next_state = STATE_SORT_UPT_CURR;
            end
            
            STATE_SORT_UPT_CURR: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_SORT_UPT_NEW;
            end
            
            STATE_SORT_UPT_NEW: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_SORT_CONT;
            end
            
            STATE_SORT_CONT: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_SORT_READ2;
            end
            
            STATE_SORT_NEXT: begin
                if (op_end_sig)
                    next_state = STATE_UPT_DONE;
                else
                    next_state = STATE_SORT_READ;
            end
            
            STATE_SORT_DONE: begin
                next_state = STATE_SORT_DONE;
                if (op_end_sig) begin
                    if (pr_done)
                        next_state = STATE_UPT_READ;
                    else
                        next_state = STATE_UPT_DONE;
                end
            end
            
            STATE_UPT_READ: begin
                next_state = STATE_UPT_WAIT;
                if (handler_addr == (MAX_RAM_ADDR - 1))
                    next_state = STATE_UPT_DONE;
            end
            
            STATE_UPT_WAIT: begin
                next_state = STATE_UPT_WRITE;
            end
            
            STATE_UPT_WRITE: begin
                next_state = STATE_UPT_READ;
            end
            
            STATE_UPT_DONE: begin
                next_state = STATE_CLEAR;
            end
                
            STATE_CLEAR: begin
                next_state = STATE_CLEAR;
                if (clear_end_reg)
                    next_state = STATE_COMPLETE;
            end
            
            STATE_COMPLETE: begin
                next_state = STATE_COMPLETE;
                if (~freeze)
                    next_state = STATE_IDLE;
            end
        endcase
    end
    
// control signal for RAM list
    always_comb begin
        handler_addr            = '0;
        write_handler_hi        = '0;
        write_handler_hi_data   = '0;
        write_handler_pi        = '0;
        write_handler_pi_data   = '0;
        ref_addr                = '0;
        write_ref_hi            = '0;
        write_ref_hi_data       = '0;
        write_ref_pi            = '0;
        write_ref_pi_data       = '0;

        case (current_state)
            STATE_IDLE: begin
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end

            STATE_READY_H: begin
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end

            STATE_READ_NUM: begin
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_READ_F_HIER:begin
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
                
            STATE_READ_ID: begin
                handler_addr            = num_count_reg;
                write_handler_hi_data   = data_reg;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
                
                if (data_count_reg == '0)
                    write_handler_hi        = 1'b1;
                else
                    write_handler_hi        = '0;
                
            end
            
            STATE_READ_HIER:begin
                handler_addr            = num_count_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi_data   = data_reg;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
                
                if (data_count_reg == '0)
                    write_handler_pi        = 1'b1;
                else
                    write_handler_pi        = '0;
            end
                
            STATE_COMP_READ: begin 
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = num_count_ref_reg;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_COMP_WAIT: begin
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = num_count_ref_reg;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_COMP_RUN: begin 
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = num_count_ref_reg;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
                       
            STATE_COMP_DONE: begin 
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_PREUP_READ: begin 
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = num_count_ref_reg;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_PREUP_WAIT: begin 
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = num_count_ref_reg;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_PREUP_COMPARE: begin 
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = num_count_ref_reg;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_PREUP_SKIP: begin 
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = num_count_ref_reg;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_PREUP_UPDATE: begin 
                handler_addr            = num_count_reg;
                write_handler_hi        = 1'b1;
                write_handler_hi_data   = read_ref_hi_data;
                write_handler_pi        = 1'b1;
                write_handler_pi_data   = read_ref_pi_data;
                ref_addr                = num_count_ref_reg;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_PREUP_DONE: begin 
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_SORT_READ: begin
                handler_addr            = num_count_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_SORT_WAIT: begin
                handler_addr            = num_count_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_SORT_STORE: begin
                handler_addr            = num_count_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_SORT_READ2: begin
                handler_addr            = num_run_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_SORT_WAIT2: begin
                handler_addr            = num_count_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_SORT_COMPARE: begin
                handler_addr            = num_run_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_SORT_UPT_CURR: begin
                handler_addr            = num_run_reg;
                write_handler_hi        = 1'b1;
                write_handler_hi_data   = ref_hi_reg;
                write_handler_pi        = 1'b1;
                write_handler_pi_data   = ref_pi_reg;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_SORT_UPT_NEW: begin
                handler_addr            = num_count_reg;
                write_handler_hi        = 1'b1;
                write_handler_hi_data   = run_hi_reg;
                write_handler_pi        = 1'b1;
                write_handler_pi_data   = run_pi_reg;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_SORT_CONT: begin
                handler_addr            = num_count_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_SORT_NEXT: begin
                handler_addr            = num_count_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_SORT_DONE: begin
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_UPT_READ: begin
                handler_addr            = num_count_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_UPT_WAIT: begin
                handler_addr            = num_count_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_UPT_WRITE: begin
                handler_addr            = num_count_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = num_count_ref_reg;
                write_ref_hi            = 1'b1;
                write_ref_hi_data       = read_handler_hi_data;
                write_ref_pi            = 1'b1;
                write_ref_pi_data       = read_handler_pi_data;
            end
            
            STATE_UPT_DONE: begin      
                handler_addr            = num_count_reg;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_CLEAR: begin      
                handler_addr            = num_count_reg;
                write_handler_hi        = 1'b1;
                write_handler_hi_data   = '0;
                write_handler_pi        = 1'b1;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
            
            STATE_COMPLETE: begin
                handler_addr            = '0;
                write_handler_hi        = '0;
                write_handler_hi_data   = '0;
                write_handler_pi        = '0;
                write_handler_pi_data   = '0;
                ref_addr                = '0;
                write_ref_hi            = '0;
                write_ref_hi_data       = '0;
                write_ref_pi            = '0;
                write_ref_pi_data       = '0;
            end
        endcase
    end
    
// data_count_reg
    always_ff @(posedge clk) begin
        if (~nreset)
            data_count_reg  <= '0;
        else if (current_state == STATE_IDLE || current_state == STATE_COMP_READ)
            data_count_reg  <= '0;
            
        else if (current_state == STATE_READ_NUM && valid_data_sig) begin
            if (data_count_reg == LOC_NUM)
                data_count_reg <= '0;
            else
                data_count_reg <= data_count_reg + 8'b1; 
        end
        
        else if (valid_data_sig &&
                    (current_state == STATE_READ_F_HIER || current_state == STATE_READ_ID 
                        || current_state == STATE_READ_HIER)) begin
            if (data_count_reg == DATA_GAP)
                data_count_reg  <= '0;
            else
                data_count_reg <= data_count_reg + 8'b1; 
        end
    end

// first_data_reg
    always_ff @(posedge clk) begin
        if (~nreset)
            first_data_reg  <= 1'b1;
        else if (current_state == STATE_IDLE)
            first_data_reg  <= 1'b1;
        else if (current_state == STATE_READ_ID && valid_data_sig && data_count_reg == DATA_GAP)
            first_data_reg  <= '0;
    end
    
// num_count_reg
    always_ff @(posedge clk) begin
        if (~nreset)
            num_count_reg   <= '0;
        else if ((current_state == STATE_IDLE) 
                    || (current_state == STATE_PREUP_DONE)
                    || (current_state == STATE_SORT_DONE)
                    || (current_state == STATE_UPT_DONE))
            num_count_reg   <= '0;
            
        else if ((current_state == STATE_READ_HIER && valid_data_sig && data_count_reg == DATA_GAP)
                    || (current_state == STATE_PREUP_UPDATE)
                    || (current_state == STATE_SORT_NEXT)
                    || (current_state == STATE_UPT_WRITE)
                    || (current_state == STATE_CLEAR))
            num_count_reg   <= num_count_reg + 5'b1;
            
        else if (current_state == STATE_COMP_DONE)
            num_count_reg   <= num_reg[4:0];
    end
    
// num_count_ref_reg
    always_ff @(posedge clk) begin
        if (~nreset)
            num_count_ref_reg   <= '0;
        else if ((current_state == STATE_IDLE) 
                    || (current_state == STATE_COMP_DONE)
                    || (current_state == STATE_SORT_DONE))
            num_count_ref_reg   <= '0;
        else if ((current_state == STATE_COMP_RUN)
                    || (current_state == STATE_PREUP_SKIP)
                    || (current_state == STATE_PREUP_UPDATE)
                    || (current_state == STATE_UPT_WRITE))
            num_count_ref_reg   <= num_count_ref_reg + 5'b1;
    end

// num_run_reg
    always_ff @(posedge clk) begin
        if (~nreset)
            num_run_reg   <= '0;
        else if ((current_state == STATE_IDLE)
                    || (current_state == STATE_UPT_WRITE))
            num_run_reg   <= '0;
        else if (current_state == STATE_SORT_CONT)
            num_run_reg   <= num_run_reg + 5'b1;
        else if (current_state == STATE_SORT_STORE)
            num_run_reg   <= num_count_reg + 5'b1;
    end    

// data conversion according to CB_DATA_WIDTH
    generate
         if (CB_DATA_WIDTH == 32) begin
            assign data_wire = data;
         end
         else if (CB_DATA_WIDTH == 16) begin
            reg [15:0] data_prev;
            
            always_ff @(posedge clk) begin
                if (~nreset)
                    data_prev <= 16'd0;
                else if (valid_data_sig)
                    data_prev <= data;
            end
            
            assign data_wire = {data, data_prev};
         end
    endgenerate
    
    always_ff @(posedge clk) begin
        if (~nreset)
            data_reg <= '0;
        else if (valid_data_sig)
            data_reg <= data_wire;
    end

// ***********************************************************************************************************    
//  Store bitstream information in IP
// ***********************************************************************************************************
    always_ff @(posedge clk) begin
        if (~nreset) begin
            num_reg         <= '0;
            hier_index_reg  <= '0;
            prpof_id_reg    <= '0;
        end
        else if (current_state == STATE_IDLE) begin
            num_reg         <= '0;
            hier_index_reg  <= '0;
            prpof_id_reg    <= '0;
        end
        else if (valid_data_sig) begin
            if (current_state == STATE_READ_NUM && data_count_reg == LOC_NUM)
                num_reg <= data_wire;
            else if (current_state == STATE_READ_F_HIER && data_count_reg == DATA_GAP)
                hier_index_reg <= data_wire;
            else if (current_state == STATE_READ_ID && first_data_reg && data_count_reg == DATA_GAP)
                prpof_id_reg <= data_wire;
        end
    end
    

// ***********************************************************************************************************    
//  Bitstream incompatibility check
// ***********************************************************************************************************
    always_ff @(posedge clk) begin
        if (~nreset)
            bitstream_incompatible_reg  <= '0;
        else if (current_state == STATE_IDLE)
            bitstream_incompatible_reg  <= '0;
        else if ((current_state == STATE_COMP_READ) && (ref_addr == (MAX_RAM_ADDR - 1)))
            bitstream_incompatible_reg  <= 1'b1;
        else if (current_state == STATE_COMP_RUN) begin
            if (read_ref_pi_data == '0)
                bitstream_incompatible_reg  <= 1'b1;
            else if (read_ref_pi_data == prpof_id_reg)
                bitstream_incompatible_reg  <= '0;
        end
    end

    
// ***********************************************************************************************************    
//  Update handler RAM list by combining existing hierarchy index + PRPOF ID
//      - max 2 layers
// ***********************************************************************************************************    
    always_ff @(posedge clk) begin
        if (~nreset)
            update_list_reg  <= '0;
        else if ((current_state == STATE_IDLE)
                    || (current_state == STATE_COMPLETE))
            update_list_reg  <= '0;
        else if (current_state == STATE_PREUP_READ)
            update_list_reg  <= 1'b1;
    end 
 
    
// ***********************************************************************************************************    
//  Sort handler list of hierarchy index and PRPOF ID
// *********************************************************************************************************** 
    always_ff @(posedge clk) begin
        if (~nreset) begin
            ref_hi_reg  <= '0;
            ref_pi_reg  <= '0;
        end
        else if (current_state == STATE_IDLE) begin
            ref_hi_reg  <= '0;
            ref_pi_reg  <= '0;
        end
        else if (current_state == STATE_SORT_STORE) begin
            ref_hi_reg  <= read_handler_hi_data;
            ref_pi_reg  <= read_handler_pi_data;
        end
        else if (current_state == STATE_SORT_UPT_NEW) begin
            ref_hi_reg  <= run_hi_reg;
            ref_pi_reg  <= run_pi_reg;
        end
    end 
    
    always_ff @(posedge clk) begin
        if (~nreset) begin
            run_hi_reg  <= '0;
            run_pi_reg  <= '0;
        end
        else if (current_state == STATE_IDLE) begin
            run_hi_reg  <= '0;
            run_pi_reg  <= '0;
        end
        else if (current_state == STATE_SORT_COMPARE) begin
            run_hi_reg  <= read_handler_hi_data;
            run_pi_reg  <= read_handler_pi_data;
        end
    end 
          
          
// ***********************************************************************************************************    
//  Move content of temporary list to permanent list
// ***********************************************************************************************************
    always_ff @(posedge clk) begin
        if (~nreset)
            clear_end_reg  <= '0;
        else if (current_state == STATE_IDLE)
            clear_end_reg  <= '0;
        else if (current_state == STATE_CLEAR && handler_addr == (MAX_RAM_ADDR - 2))
            clear_end_reg  <= 1'b1;
    end     


// **********************************************************************   
//  RAM blocks for handling temporary list of Hierarchy index and PR POF ID
// **********************************************************************  
    altera_syncram # (
        .width_byteena_a(1),
        .clock_enable_input_a("BYPASS"),
        .clock_enable_output_a("BYPASS"),
        .init_file(""),
        .intended_device_family("Arria 10"),
        .lpm_hint("ENABLE_RUNTIME_MOD=NO"),
        .lpm_type("altera_syncram"),
        .numwords_a(MAX_RAM_ADDR),
        .operation_mode("SINGLE_PORT"),
        .outdata_aclr_a("NONE"),
        .outdata_sclr_a("NONE"),
        .outdata_reg_a("CLOCK0"),
        .enable_force_to_zero("FALSE"),
        .power_up_uninitialized("FALSE"),
        .read_during_write_mode_port_a("DONT_CARE"),
        .widthad_a(MAX_RAM_ADDR_W),
        .width_a(32)
    ) handler_hier_block (
        .address_a (handler_addr),
        .clock0 (clk),
        .data_a (write_handler_hi_data),
        .wren_a (write_handler_hi),
        .q_a (read_handler_hi_data),
        .aclr0 (1'b0),
        .aclr1 (1'b0),
        .address2_a (1'b1),
        .address2_b (1'b1),
        .address_b (1'b1),
        .addressstall_a (1'b0),
        .addressstall_b (1'b0),
        .byteena_a (1'b1),
        .byteena_b (1'b1),
        .clock1 (1'b1),
        .clocken0 (1'b1),
        .clocken1 (1'b1),
        .clocken2 (1'b1),
        .clocken3 (1'b1),
        .data_b (1'b1),
        .eccencbypass (1'b0),
        .eccencparity (8'b0),
        .eccstatus ( ),
        .q_b ( ),
        .rden_a (1'b1),
        .rden_b (1'b1),
        .sclr (1'b0),
        .wren_b (1'b0));
    
    altera_syncram # (
        .width_byteena_a(1),
        .clock_enable_input_a("BYPASS"),
        .clock_enable_output_a("BYPASS"),
        .init_file(""),
        .intended_device_family("Arria 10"),
        .lpm_hint("ENABLE_RUNTIME_MOD=NO"),
        .lpm_type("altera_syncram"),
        .numwords_a(MAX_RAM_ADDR),
        .operation_mode("SINGLE_PORT"),
        .outdata_aclr_a("NONE"),
        .outdata_sclr_a("NONE"),
        .outdata_reg_a("CLOCK0"),
        .enable_force_to_zero("FALSE"),
        .power_up_uninitialized("FALSE"),
        .read_during_write_mode_port_a("DONT_CARE"),
        .widthad_a(MAX_RAM_ADDR_W),
        .width_a(32)
    ) handler_pof_id_block (
        .address_a (handler_addr),
        .clock0 (clk),
        .data_a (write_handler_pi_data),
        .wren_a (write_handler_pi),
        .q_a (read_handler_pi_data),
        .aclr0 (1'b0),
        .aclr1 (1'b0),
        .address2_a (1'b1),
        .address2_b (1'b1),
        .address_b (1'b1),
        .addressstall_a (1'b0),
        .addressstall_b (1'b0),
        .byteena_a (1'b1),
        .byteena_b (1'b1),
        .clock1 (1'b1),
        .clocken0 (1'b1),
        .clocken1 (1'b1),
        .clocken2 (1'b1),
        .clocken3 (1'b1),
        .data_b (1'b1),
        .eccencbypass (1'b0),
        .eccencparity (8'b0),
        .eccstatus ( ),
        .q_b ( ),
        .rden_a (1'b1),
        .rden_b (1'b1),
        .sclr (1'b0),
        .wren_b (1'b0));
        
// **********************************************************************   
//  RAM blocks for storing list of Hierarchy index and PR POF ID
// **********************************************************************   
    altera_syncram # (
        .width_byteena_a(1),
        .clock_enable_input_a("BYPASS"),
        .clock_enable_output_a("BYPASS"),
        .init_file("output_files/pr_hierarchy_index.mif"),
        .intended_device_family("Arria 10"),
        .lpm_hint("ENABLE_RUNTIME_MOD=NO"),
        .lpm_type("altera_syncram"),
        .numwords_a(MAX_RAM_ADDR),
        .operation_mode("SINGLE_PORT"),
        .outdata_aclr_a("NONE"),
        .outdata_sclr_a("NONE"),
        .outdata_reg_a("CLOCK0"),
        .enable_force_to_zero("FALSE"),
        .power_up_uninitialized("FALSE"),
        .read_during_write_mode_port_a("DONT_CARE"),
        .widthad_a(MAX_RAM_ADDR_W),
        .width_a(32)
    ) hier_block (
        .address_a (ref_addr),
        .clock0 (clk),
        .data_a (write_ref_hi_data),
        .wren_a (write_ref_hi),
        .q_a (read_ref_hi_data),
        .aclr0 (1'b0),
        .aclr1 (1'b0),
        .address2_a (1'b1),
        .address2_b (1'b1),
        .address_b (1'b1),
        .addressstall_a (1'b0),
        .addressstall_b (1'b0),
        .byteena_a (1'b1),
        .byteena_b (1'b1),
        .clock1 (1'b1),
        .clocken0 (1'b1),
        .clocken1 (1'b1),
        .clocken2 (1'b1),
        .clocken3 (1'b1),
        .data_b (1'b1),
        .eccencbypass (1'b0),
        .eccencparity (8'b0),
        .eccstatus ( ),
        .q_b ( ),
        .rden_a (1'b1),
        .rden_b (1'b1),
        .sclr (1'b0),
        .wren_b (1'b0));
    
    altera_syncram # (
        .width_byteena_a(1),
        .clock_enable_input_a("BYPASS"),
        .clock_enable_output_a("BYPASS"),
        .init_file("output_files/pr_pof_id.mif"),
        .intended_device_family("Arria 10"),
        .lpm_hint("ENABLE_RUNTIME_MOD=NO"),
        .lpm_type("altera_syncram"),
        .numwords_a(MAX_RAM_ADDR),
        .operation_mode("SINGLE_PORT"),
        .outdata_aclr_a("NONE"),
        .outdata_sclr_a("NONE"),
        .outdata_reg_a("CLOCK0"),
        .enable_force_to_zero("FALSE"),
        .power_up_uninitialized("FALSE"),
        .read_during_write_mode_port_a("DONT_CARE"),
        .widthad_a(MAX_RAM_ADDR_W),
        .width_a(32)
    ) pof_id_block (
        .address_a (ref_addr),
        .clock0 (clk),
        .data_a (write_ref_pi_data),
        .wren_a (write_ref_pi),
        .q_a (read_ref_pi_data),
        .aclr0 (1'b0),
        .aclr1 (1'b0),
        .address2_a (1'b1),
        .address2_b (1'b1),
        .address_b (1'b1),
        .addressstall_a (1'b0),
        .addressstall_b (1'b0),
        .byteena_a (1'b1),
        .byteena_b (1'b1),
        .clock1 (1'b1),
        .clocken0 (1'b1),
        .clocken1 (1'b1),
        .clocken2 (1'b1),
        .clocken3 (1'b1),
        .data_b (1'b1),
        .eccencbypass (1'b0),
        .eccencparity (8'b0),
        .eccstatus ( ),
        .q_b ( ),
        .rden_a (1'b1),
        .rden_b (1'b1),
        .sclr (1'b0),
        .wren_b (1'b0));

endmodule

