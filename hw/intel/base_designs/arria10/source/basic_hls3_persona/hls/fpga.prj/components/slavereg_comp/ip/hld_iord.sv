//// (c) 1992-2021 Intel Corporation.                            
// Intel, the Intel logo, Intel, MegaCore, NIOS II, Quartus and TalkBack words    
// and logos are trademarks of Intel Corporation or its subsidiaries in the U.S.  
// and/or other countries. Other marks and brands may be claimed as the property  
// of others. See Trademarks on intel.com for full list of Intel trademarks or    
// the Trademarks & Brands Names Database (if Intel) or See www.Intel.com/legal (if Altera) 
// Your use of Intel Corporation's design tools, logic functions and other        
// software and tools, and its AMPP partner logic functions, and any output       
// files any of the foregoing (including device programming or simulation         
// files), and any associated documentation or information are expressly subject  
// to the terms and conditions of the Altera Program License Subscription         
// Agreement, Intel MegaCore Function License Agreement, or other applicable      
// license agreement, including, without limitation, that your use is for the     
// sole purpose of programming logic devices manufactured by Intel and sold by    
// Intel or its authorized distributors.  Please refer to the applicable          
// agreement for further details.                                                 


// The HLD compiler uses hld_iord to perform a read from a channel/stream/pipe.
// The basic operation of hld_iord is to transfer data from the channel facing
// interface to the kernel downstream interface when all the following are met:
// - kernel upstream has a valid
// - channel has data
// - kernel downstream has space available
//
// This module is a wrapper around the stall valid and stall latency
// implementations. This wrapper deals with the following:
// - profiling: monitor for backpressure and data starvation
// - cutpaths: tie off the channel interface, this allows one to measure fmax
//     for one kernel in isolation even though that kernel requires channels
// - data packing: bundle data path signals together (data, startofpacket,
//     endofpacket, packetempty)

`include "acl_parameter_assert.svh"
`default_nettype none

module hld_iord #(
    //core specification
    parameter int DATA_WIDTH = 32,                      //width of the data path
    parameter bit NON_BLOCKING = 0,                     //non-blocking means a valid can still go from kernel upstream to downstream without writing to channel if channel is full

    //reset
    parameter bit ASYNC_RESET = 1,                      //should registers consume reset asynchronously (ASYNC_RESET=1) or synchronously (ASYNC_RESET=0)
    parameter bit SYNCHRONIZE_RESET = 0,                //before consumption by registers, should the reset be synchronized to the clock

    //upstream configuration
    parameter bit USE_STALL_LATENCY_UPSTREAM = 0,       //0 means stall valid (valid means transaction may happen but doesn't have to), 1 means use stall latency (valid means forced transaction)
    parameter int ALMOST_FULL_CUTOFF_UPSTREAM = 0,      //specify how early the backpressure to kernel upstream needs to be, note the use of hld_fifo cutoff semantics, this is NOT almost full threshold
    parameter bit NO_PREDICATION = 0,                   //set to 1 if it is known that i_predicate is a constant 0, the IP is simpler and smaller without predication support
    parameter bit DISCONNECT_UPSTREAM = 0,              //HLS launch/collect capacity balancing: remove the dependency if it is covered through the task being launched and collect
    parameter int ADD_CAPACITY_UPSTREAM = 0,            //HLS launch/collect capacity balancing: add capacity if the launch to collect dependency cannot be removed

    //downstream configuration
    parameter bit USE_STALL_LATENCY_DOWNSTREAM = 0,     //0 means stall valid, 1 means stall latency
    parameter int ALMOST_EMPTY_CUTOFF_DOWNSTREAM = 0,   //specify how early the starvation to kernel downstream needs to be
    parameter int STALL_IN_EARLINESS_DOWNSTREAM = 0,    //stall in earliness for the fifo that feeds that to kernel downstream
    parameter bit STAGING_CAPACITY = 0,                 //whether to add a staging register on kernel downstream, avalon spec does not require data to be held constant during backpressure, add capacity to avoid re-sampling

    //sidepath configuration
    parameter bit USE_STALL_LATENCY_SIDEPATH = 0,       //0 means stall valid, 1 means stall latency
    parameter int ALMOST_FULL_CUTOFF_SIDEPATH = 0,      //specify how early the backpressure to the sidepath needs to be, note the use of hld_fifo cutoff semantics, this is NOT almost full threshold
    parameter int CAPACITY_FROM_CHANNEL = 0,            //consolidation of capacity across iowr, channel, and iord -- how much capacity should this module absorb from others
    parameter int INTER_KERNEL_PIPELINING = 0,          //how much pipelining to add before the single fifo that holds all of the capacity for iowr, channel and iord

    //other features
    parameter int EMPTY_WIDTH = 0,                      //width of the empty signal for avalon packet data
    parameter bit CUTPATHS = 0,                         //tie off channel interface, intended for fmax measurement of one kernel in isolation but that kernel uses channels
    parameter bit ACL_PROFILE = 0,                      //enable the profiler
    parameter bit ACL_PROFILE_SHARED = 0,               // Set to 1 to enable shared counters for profiling
    parameter bit ALLOW_HIGH_SPEED_FIFO_USAGE = 0,      //choice of hld_fifo style, 0 = mid speed fifo, 1 = high speed fifo
    parameter     enable_ecc = "FALSE",                //enable error correction codes for RAM, legal values are "FALSE" or "TRUE"
    
    //derived values
    parameter int EMPTY_PORT = (EMPTY_WIDTH > 0) ? EMPTY_WIDTH : 1
) (
    input  wire                     clock,
    input  wire                     resetn,

    //upstream control
    input  wire                     i_valid,            //if USE_STALL_LATENCY_UPSTREAM = 1 this means we must accept the transaction from upstream, else this means upstream has a transaction which we may accept
    output logic                    o_stall,            //backpressure to upstream

    //upstream data
    input  wire                     i_predicate,        //0 means read from the channel, 1 means don't read from the channel (which means downstream can see a valid even if channel is empty)

    //downstream control
    output logic                    o_valid,            //if USE_STALL_LATENCY_DOWNSTREAM = 1 this means downstream must accept the transaction, else this means there is a transaction for downstream which it may accept
    input  wire                     i_stall,            //backpressure from downstream, earliness is determined by STALL_IN_EARLINESS_DOWNSTREAM
    output logic                    o_empty,            //indicates to downstream that there are no transactions available
    output logic                    o_almost_empty,     //will be stuck at 1 if IP has no capacity

    //downstream data
    output logic                    o_datavalid,        //only used in non-blocking, indicates whether the sidepath was read
    output logic   [DATA_WIDTH-1:0] o_data,
    output logic                    o_startofpacket,
    output logic                    o_endofpacket,
    output logic             [31:0] o_packetempty,

    //sidepath control
    input  wire                     i_fifovalid,        //if USE_STALL_LATENCY_SIDEPATH = 1 this means we must accept the transaction from sidepath, else this means sidepath has a transaction which we may accept
    output logic                    o_fifoready,        //intended to replace full signal from channel which goes to the iowr
    output logic                    o_fifoalmost_full,  //intended to replace almost full signal from channel which goes to the full detector associated with iowr
    output logic                    o_fifochannel_stall,//if iowr capacity merges into iord, iord tells iowr when the channel interface would have been stalling upstream, intended for profiler

    //sidepath data
    input  wire    [DATA_WIDTH-1:0] i_fifodata,
    input  wire                     i_fifostartofpacket,
    input  wire                     i_fifoendofpacket,
    input  wire    [EMPTY_PORT-1:0] i_fifoempty,

    //others
    output logic              [1:0] ecc_err_status,     //error correction code status
    input  wire              [31:0] i_fifosize,         //profiler port descriptions are below in the profiler section
    input wire                [1:0] profile_shared_control, // control what the profiler shared counters are counting
    output logic                    profile_shared,     // counting profile_i_valid if control is 0, profile_fifo_stall if control is 1, profile_idle if control is 2, and profile_total_req if control is 3
    output logic                    profile_i_valid,
    output logic                    profile_i_stall,
    output logic                    profile_o_stall,
    output logic                    profile_idle,
    output logic                    profile_total_req,
    output logic                    profile_fifo_stall,
    output logic                    profile_total_fifo_size,
    output logic             [31:0] profile_total_fifo_size_incr,
    output logic             [31:0] o_fifosize
);

    ///////////////////////////////////////
    // Parameter checking
    //
    // Generate an error if any illegal parameter settings or combinations are used
    ///////////////////////////////////////
    initial /* synthesis enable_verilog_initial_construct */
    begin
        if (EMPTY_PORT != ((EMPTY_WIDTH > 0) ? EMPTY_WIDTH : 1))
            $fatal(1, "Illegal parameteriazation, EMPTY_PORT must be not be specified when instantiating this module, it must be left at its default value");
    end

    localparam bit USE_STALL_LATENCY_IP = USE_STALL_LATENCY_UPSTREAM || USE_STALL_LATENCY_DOWNSTREAM || USE_STALL_LATENCY_SIDEPATH;
    logic stall_latency_profile_o_stall, stall_latency_profile_fifo_stall;
    logic [31:0] channel_fifo_occupancy;
    //Padding the flexibly sized packetempty_preext from the stall latency module 
    //to match the 32-bit bus o_packetempty interface of the IP
    logic [EMPTY_PORT-1:0] o_packetempty_preext;  
    assign o_packetempty = {{(32-EMPTY_PORT){1'b0}},o_packetempty_preext};

    ///////////////////////////////////
    //  Simulation-only debug hooks  //
    ///////////////////////////////////

    // to assist in debug of surrounding logic outside of hld_iord -- signals of interest are named sim_only_debug_***
    // technically this is synthesizable logic, but it would degrade fmax and it is not hooked up to anything
    // synthesis translate_off
    int sim_only_debug_upstream_count, sim_only_debug_upstream_nonpredicated_count, sim_only_debug_downstream_count, sim_only_debug_sidepath_count;
    int sim_only_debug_upstream_to_downstream_occupancy, sim_only_debug_upstream_nonpredicated_to_sidepath_occupancy;
    logic sim_only_debug_upstream_incr, sim_only_debug_upstream_nonpredicated_incr, sim_only_debug_downstream_incr, sim_only_debug_sidepath_incr;

    genvar g;
    logic [STALL_IN_EARLINESS_DOWNSTREAM:0] pipe_i_stall;
    logic correct_timing_i_stall;
    generate
    always_comb begin
        pipe_i_stall[0] = i_stall;
    end
    for (g=1; g<=STALL_IN_EARLINESS_DOWNSTREAM; g++) begin : GEN_RANDOM_BLOCK_NAME_R82
        always_ff @(posedge clock) begin
            pipe_i_stall[g] <= pipe_i_stall[g-1];
        end
    end
    endgenerate
    assign correct_timing_i_stall = pipe_i_stall[STALL_IN_EARLINESS_DOWNSTREAM];

    //determine whether a transaction has occurred at various boundary locations in the IP
    assign sim_only_debug_upstream_incr = (USE_STALL_LATENCY_UPSTREAM) ? i_valid : i_valid & ~o_stall;
    assign sim_only_debug_upstream_nonpredicated_incr = sim_only_debug_upstream_incr & ~i_predicate;
    assign sim_only_debug_downstream_incr = ~o_empty & ~correct_timing_i_stall;
    assign sim_only_debug_sidepath_incr = (USE_STALL_LATENCY_SIDEPATH) ? i_fifovalid : i_fifovalid & o_fifoready;

    //keep track of the transaction count at various boundary locations in the IP
    always_ff @(posedge clock or negedge resetn) begin
        if (~resetn) begin
            sim_only_debug_upstream_count <= '0;
            sim_only_debug_upstream_nonpredicated_count <= '0;
            sim_only_debug_downstream_count <= '0;
            sim_only_debug_sidepath_count <= '0;
        end
        else begin
            sim_only_debug_upstream_count <= sim_only_debug_upstream_count + sim_only_debug_upstream_incr;
            sim_only_debug_upstream_nonpredicated_count <= sim_only_debug_upstream_nonpredicated_count + sim_only_debug_upstream_nonpredicated_incr;
            sim_only_debug_downstream_count <= sim_only_debug_downstream_count + sim_only_debug_downstream_incr;
            sim_only_debug_sidepath_count <= sim_only_debug_sidepath_count + sim_only_debug_sidepath_incr;
        end
    end

    //how many transactions have entered upstream but not yet exited downstream
    assign sim_only_debug_upstream_to_downstream_occupancy = sim_only_debug_upstream_count - sim_only_debug_downstream_count;

    //how many nonpredicated transactions have entered upstream but not yet exited from sidepath
    assign sim_only_debug_upstream_nonpredicated_to_sidepath_occupancy = sim_only_debug_upstream_nonpredicated_count - sim_only_debug_sidepath_count;
    // synthesis translate_on



    ////////////////
    //  Profiler  //
    ////////////////

    generate
    if (ACL_PROFILE) begin : GEN_PROFILE
        //there is a fundamental limitation of the stall latency protocol which makes things challenging for the profiler
        //upstream of iord can only communicate that it is forcing a valid, it cannot say that there is work available which may be accepted
        //however, the stall latency implementation of iord has a fifo between the upstream interface and the core iord logic that decides whether a transaction proceeds
        //by looking at the read side of this fifo, we are able to infer that upstream has work available (which has been queued)
        //this is why some profiling signals have been moved inside the stall latency implementation of iord

        logic delayed_i_stall;  //remove earliness on i_stall
        acl_shift_register_no_reset #(.WIDTH(1), .STAGES(STALL_IN_EARLINESS_DOWNSTREAM)) delayed_i_stall_inst (.clock(clock), .D(i_stall), .Q(delayed_i_stall));

        assign profile_i_valid = (USE_STALL_LATENCY_UPSTREAM) ? i_valid : (i_valid & ~o_stall);                         //upstream has sent a valid to us
        assign profile_i_stall = ~o_empty & delayed_i_stall;                                                            //we want to send a valid but downstream is stalling
        assign profile_o_stall = (USE_STALL_LATENCY_UPSTREAM) ? stall_latency_profile_o_stall : (i_valid & o_stall);    //upstream wants to send a valid but we are stalling
        assign profile_total_req = profile_i_valid & ~i_predicate;                                                      //upstream has sent a nonpredicated valid to us
        assign profile_idle = ( ~profile_i_valid & ~profile_fifo_stall );

        if (NON_BLOCKING) begin
            assign profile_fifo_stall  = '0; // cannot stall in a non-blocking read
        end else begin
            assign profile_fifo_stall = (USE_STALL_LATENCY_UPSTREAM) ? stall_latency_profile_fifo_stall : i_valid & ~i_predicate & ~i_fifovalid; //upstream wants to send a nonpredicated valid but channel is empty
        end

        // Count channel depth when the iord is either reading, or being stalled by the channel (ie. it is interacting with the channel)
        assign profile_total_fifo_size = (USE_STALL_LATENCY_SIDEPATH) ? (i_fifovalid | profile_fifo_stall) : ((i_fifovalid & o_fifoready) | profile_fifo_stall);
        assign profile_total_fifo_size_incr = i_fifosize;                                                               // increment by channel depth amounts
        assign o_fifosize = (USE_STALL_LATENCY_IP) ? channel_fifo_occupancy : '0;                                       //how many words are inside the channel fifo if implemented inside iord

        if (ACL_PROFILE_SHARED == 1)
        begin
            always@(posedge clock) begin
                case (profile_shared_control)
                    2'b00: profile_shared <= profile_i_valid;
                    2'b01: profile_shared <= profile_fifo_stall;
                    2'b10: profile_shared <= profile_idle;
                    2'b11: profile_shared <= profile_total_req;
                    default: profile_shared <= 1'b0;
                endcase
            end
        end
    end
    else begin : NO_PROFILE
        assign profile_i_valid = '0;
        assign profile_i_stall = '0;
        assign profile_o_stall = '0;
        assign profile_idle = '0;
        assign profile_total_req = '0;
        assign profile_fifo_stall = '0;
        assign profile_total_fifo_size = '0;
        assign profile_total_fifo_size_incr = '0;
        assign o_fifosize = '0;
        assign profile_shared = '0;
    end
    endgenerate



    ///////////////////////////////////
    //  Intercept channel interface  //
    ///////////////////////////////////

    logic                   ch_i_fifovalid;
    logic  [DATA_WIDTH-1:0] ch_i_fifodata;
    logic                   ch_o_fifostall;
    logic                   ch_o_fifoalmost_full;
    logic                   ch_o_fifochannel_stall;
    logic                   ch_i_fifostartofpacket;
    logic                   ch_i_fifoendofpacket;
    logic  [EMPTY_PORT-1:0] ch_i_fifoempty;

    generate
    if (CUTPATHS) begin : GEN_CUTPATHS
        logic                   virt_i_fifovalid         /* synthesis dont_merge keep preserve noprune */;
        logic  [DATA_WIDTH-1:0] virt_i_fifodata          /* synthesis dont_merge keep preserve noprune */;
        logic                   virt_o_fifostall         /* synthesis dont_merge keep preserve noprune */;
        logic                   virt_o_fifoalmost_full   /* synthesis dont_merge keep preserve noprune */;
        logic                   virt_o_fifochannel_stall /* synthesis dont_merge keep preserve noprune */;
        logic                   virt_i_fifostartofpacket /* synthesis dont_merge keep preserve noprune */;
        logic                   virt_i_fifoendofpacket   /* synthesis dont_merge keep preserve noprune */;
        logic  [EMPTY_PORT-1:0] virt_i_fifoempty         /* synthesis dont_merge keep preserve noprune */;

        //fake inputs
        always_ff @(posedge clock) begin
            virt_i_fifovalid         <= ~virt_i_fifovalid;
            virt_i_fifodata          <= ~virt_i_fifodata;
            virt_i_fifostartofpacket <= ~virt_i_fifostartofpacket;
            virt_i_fifoendofpacket   <= ~virt_i_fifoendofpacket;
            virt_i_fifoempty         <= ~virt_i_fifoempty;
        end
        assign ch_i_fifovalid         = virt_i_fifovalid;
        assign ch_i_fifodata          = virt_i_fifodata;
        assign ch_i_fifostartofpacket = virt_i_fifostartofpacket;
        assign ch_i_fifoendofpacket   = virt_i_fifoendofpacket;
        assign ch_i_fifoempty         = virt_i_fifoempty;

        //fake outputs
        always_ff @(posedge clock) begin
            virt_o_fifostall         <= ch_o_fifostall;
            virt_o_fifoalmost_full   <= ch_o_fifoalmost_full;
            virt_o_fifochannel_stall <= ch_o_fifochannel_stall;
        end
    end
    else begin : NO_CUTPATHS
        assign ch_i_fifovalid         = i_fifovalid;
        assign ch_i_fifodata          = i_fifodata;
        assign ch_i_fifostartofpacket = i_fifostartofpacket;
        assign ch_i_fifoendofpacket   = i_fifoendofpacket;
        assign ch_i_fifoempty         = i_fifoempty;
        assign o_fifoready            = ~ch_o_fifostall;
        assign o_fifoalmost_full      = ch_o_fifoalmost_full;
        assign o_fifochannel_stall    = ch_o_fifochannel_stall;
    end
    endgenerate



    //////////////////////////////////
    //  Choose iord implementation  //
    //////////////////////////////////

    generate
    if (USE_STALL_LATENCY_IP) begin : GEN_STALL_LATENCY

        //parameter legality checks -- ensure stall valid features are not used here
        `ACL_PARAMETER_ASSERT(STAGING_CAPACITY == 0)

        hld_iord_stall_latency #(
            //core spec
            .DATA_WIDTH                     (EMPTY_WIDTH + 2 + DATA_WIDTH),
            .NON_BLOCKING                   (NON_BLOCKING),

            //reset
            .ASYNC_RESET                    (ASYNC_RESET),
            .SYNCHRONIZE_RESET              (SYNCHRONIZE_RESET),

            //upstream
            .USE_STALL_LATENCY_UPSTREAM     (USE_STALL_LATENCY_UPSTREAM),
            .ALMOST_FULL_CUTOFF_UPSTREAM    (ALMOST_FULL_CUTOFF_UPSTREAM),
            .NO_PREDICATION                 (NO_PREDICATION),
            .DISCONNECT_UPSTREAM            (DISCONNECT_UPSTREAM),
            .ADD_CAPACITY_UPSTREAM          (ADD_CAPACITY_UPSTREAM),

            //downstream
            .USE_STALL_LATENCY_DOWNSTREAM   (USE_STALL_LATENCY_DOWNSTREAM),
            .ALMOST_EMPTY_CUTOFF_DOWNSTREAM (ALMOST_EMPTY_CUTOFF_DOWNSTREAM),
            .STALL_IN_EARLINESS_DOWNSTREAM  (STALL_IN_EARLINESS_DOWNSTREAM),

            //sidepath
            .USE_STALL_LATENCY_SIDEPATH     (USE_STALL_LATENCY_SIDEPATH),
            .ALMOST_FULL_CUTOFF_SIDEPATH    (ALMOST_FULL_CUTOFF_SIDEPATH),
            .CAPACITY_FROM_CHANNEL          (CAPACITY_FROM_CHANNEL),
            .INTER_KERNEL_PIPELINING        (INTER_KERNEL_PIPELINING),

            //other features
            .ALLOW_HIGH_SPEED_FIFO_USAGE    (ALLOW_HIGH_SPEED_FIFO_USAGE),
            .enable_ecc                     (enable_ecc)
        )
        hld_iord_stall_latency_inst
        (
            .clock                          (clock),
            .resetn                         (resetn),

            //upstream
            .i_valid                        (i_valid),
            .i_predicate                    (i_predicate),
            .o_stall                        (o_stall),

            //downstream
            .o_valid                        (o_valid),
            .o_empty                        (o_empty),
            .o_almost_empty                 (o_almost_empty),
            .i_stall                        (i_stall),
            .o_datavalid                    (o_datavalid),
            .o_data                         ({o_packetempty_preext, o_endofpacket, o_startofpacket, o_data}),

            //sidepath
            .i_fifovalid                    (ch_i_fifovalid),
            .o_fifostall                    (ch_o_fifostall),
            .o_fifoalmost_full              (ch_o_fifoalmost_full),
            .o_fifochannel_stall            (ch_o_fifochannel_stall),
            .i_fifodata                     ({ch_i_fifoempty, ch_i_fifoendofpacket, ch_i_fifostartofpacket, ch_i_fifodata}),

            //other
            .ecc_err_status                 (ecc_err_status),
            .o_profile_o_stall              (stall_latency_profile_o_stall),
            .o_profile_fifo_stall           (stall_latency_profile_fifo_stall),
            .o_channel_fifo_occupancy       (channel_fifo_occupancy)
        );
    end
    else begin : GEN_STALL_VALID

        //parameter legality checks -- ensure stall latency features are not used here
        `ACL_PARAMETER_ASSERT(ALMOST_FULL_CUTOFF_UPSTREAM == 0)
        `ACL_PARAMETER_ASSERT(ALMOST_EMPTY_CUTOFF_DOWNSTREAM == 0)
        `ACL_PARAMETER_ASSERT(STALL_IN_EARLINESS_DOWNSTREAM == 0)
        `ACL_PARAMETER_ASSERT(ALMOST_FULL_CUTOFF_SIDEPATH == 0)
        `ACL_PARAMETER_ASSERT(CAPACITY_FROM_CHANNEL == 0)
        `ACL_PARAMETER_ASSERT(INTER_KERNEL_PIPELINING == 0)

        hld_iord_stall_valid #(
            //core spec
            .DATA_WIDTH                     (EMPTY_WIDTH + 2 + DATA_WIDTH),
            .NON_BLOCKING                   (NON_BLOCKING),

            //reset
            .ASYNC_RESET                    (ASYNC_RESET),
            .SYNCHRONIZE_RESET              (SYNCHRONIZE_RESET),

            //upstream
            .NO_PREDICATION                 (NO_PREDICATION),
            .DISCONNECT_UPSTREAM            (DISCONNECT_UPSTREAM),
            .ADD_CAPACITY_UPSTREAM          (ADD_CAPACITY_UPSTREAM),

            //downstream
            .STAGING_CAPACITY               (STAGING_CAPACITY),

            //other
            .ALLOW_HIGH_SPEED_FIFO_USAGE    (ALLOW_HIGH_SPEED_FIFO_USAGE),
            .enable_ecc                     (enable_ecc)
        )
        hld_iord_stall_valid_inst
        (
            .clock                          (clock),
            .resetn                         (resetn),

            //upstream
            .i_valid                        (i_valid),
            .i_predicate                    (i_predicate),
            .o_stall                        (o_stall),

            //downstream
            .o_valid                        (o_valid),
            .i_stall                        (i_stall),
            .o_datavalid                    (o_datavalid),
            .o_data                         ({o_packetempty_preext, o_endofpacket, o_startofpacket, o_data}),

            //sidepath
            .i_fifovalid                    (ch_i_fifovalid),
            .o_fifostall                    (ch_o_fifostall),
            .i_fifodata                     ({ch_i_fifoempty, ch_i_fifoendofpacket, ch_i_fifostartofpacket, ch_i_fifodata}),

            //other
            .ecc_err_status                 (ecc_err_status)
        );
        assign o_empty = ~o_valid;
        assign o_almost_empty = 1'b1;
        assign ch_o_fifoalmost_full = 1'b0;
        assign ch_o_fifochannel_stall = 1'b0;
    end
    endgenerate

endmodule

`default_nettype wire
