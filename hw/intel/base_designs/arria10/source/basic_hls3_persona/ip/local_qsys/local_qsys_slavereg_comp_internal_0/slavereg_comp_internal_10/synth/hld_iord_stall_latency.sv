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


// This module is the stall latency implementation of iord. One may choose
// whether to use stall latency or stall valid on each interface. Note that even
// if a design uses stall latency, if the iord is non-blocking, often (but not
// always) the compiler will put it inside a stall free cluster, in which case
// the stall valid implementation would be used.
//
// The basic operation of iord is to transfer data from the channel facing
// interface to the kernel downstream interface when all the following are met:
// - kernel upstream has a valid
// - channel has data
// - kernel downstream has space available
//
// The high level operation of iord is the same between the stall valid and
// stall latency implementations, however the stall latency verion must provide
// capacity at each interface. Technically it is legal to choose capacity=0 for
// each interface (stall latency implementation acts as stall valid), however
// the FIFOs for capacity are not removed so this would be a huge area overhead
// versus using the stall valid implementation.
//
// Stall latency requires capacity for capturing transactions already in flight,
// however with the proper architecture this capacity can be shared between
// interfaces and across modules. The strategies used can be found in this
// powerpoint:
// p4/depot/docs/hld/ip/fifo_merging_across_channels.pptx

`default_nettype none

//refer to hld_iord.sv for a description of the parameters and ports

module hld_iord_stall_latency
import hld_memory_depth_quantization_pkg::*;
#(
    //core spec
    parameter int DATA_WIDTH,
    parameter bit NON_BLOCKING,

    //reset
    parameter bit ASYNC_RESET,
    parameter bit SYNCHRONIZE_RESET,

    //upstream
    parameter bit USE_STALL_LATENCY_UPSTREAM,
    parameter int ALMOST_FULL_CUTOFF_UPSTREAM,
    parameter bit NO_PREDICATION,
    parameter bit DISCONNECT_UPSTREAM,
    parameter int ADD_CAPACITY_UPSTREAM,

    //downstream
    parameter bit USE_STALL_LATENCY_DOWNSTREAM,
    parameter int ALMOST_EMPTY_CUTOFF_DOWNSTREAM,
    parameter int STALL_IN_EARLINESS_DOWNSTREAM,

    //sidepath
    parameter bit USE_STALL_LATENCY_SIDEPATH,
    parameter int ALMOST_FULL_CUTOFF_SIDEPATH,
    parameter int CAPACITY_FROM_CHANNEL,
    parameter int INTER_KERNEL_PIPELINING,

    //other features
    parameter bit ALLOW_HIGH_SPEED_FIFO_USAGE,
    parameter     enable_ecc
) (
    input  wire                     clock,
    input  wire                     resetn,

    //upstream
    input  wire                     i_valid,
    input  wire                     i_predicate,
    output logic                    o_stall,

    //downstream
    output logic                    o_valid,
    output logic                    o_empty,
    output logic                    o_almost_empty,
    input  wire                     i_stall,
    output logic   [DATA_WIDTH-1:0] o_data,
    output logic                    o_datavalid,

    //sidepath
    input  wire                     i_fifovalid,
    output logic                    o_fifostall,
    output logic                    o_fifoalmost_full,
    output logic                    o_fifochannel_stall,
    input  wire    [DATA_WIDTH-1:0] i_fifodata,

    //other
    output logic              [1:0] ecc_err_status,
    output logic                    o_profile_o_stall,
    output logic                    o_profile_fifo_stall,
    output logic             [31:0] o_channel_fifo_occupancy
);

    ////////////////////////////////////////////////////
    //  Determine the depth and latency of each fifo  //
    ////////////////////////////////////////////////////

    //properties of the fifo or occupancy tracker
    //in cases where a fifo is zero width, reduce both area and latency by using the occupancy tracker directly
    localparam     HLD_FIFO_STYLE           = (ALLOW_HIGH_SPEED_FIFO_USAGE) ? "hs" : "ms";
    localparam int HLD_FIFO_LATENCY         = (ALLOW_HIGH_SPEED_FIFO_USAGE) ? 5 : 3;
    localparam int OCC_TRACKER_LATENCY      = 1;

    //upstream fifo holds predication info, if compiler knows that predicate will always be 0 then it sets NO_PREDICATION = 1
    localparam bit UP_FIFO_NEEDS_DATA       = !NO_PREDICATION;
    localparam bit UP_FIFO_LATENCY          = (UP_FIFO_NEEDS_DATA) ? HLD_FIFO_LATENCY : OCC_TRACKER_LATENCY;
    localparam int UP_FIFO_DEPTH_DESIRED    = ADD_CAPACITY_UPSTREAM                                 //for capacity balancing the HLS launch to collect path in parent task against the child task being launched/collect
                                            + ALMOST_FULL_CUTOFF_UPSTREAM                           //catch up to this many transactions already in flight
                                            + 1 + ALMOST_FULL_CUTOFF_UPSTREAM + UP_FIFO_LATENCY;    //ensure no bubbles, latency of i_stall -> o_stall -> i_valid -> o_valid
    localparam int UP_FIFO_DEPTH            = quantizeFifoDepthUsingWidth(UP_FIFO_DEPTH_DESIRED, 1);

    //downstream fifo indicates whether a valid from upstream should result in data released from side fifo
    //an upstream thread does not cause a read from side fifo if predicated, or if nonblocking and the side fifo was empty
    localparam bit DOWN_FIFO_NEEDS_DATA     = !NO_PREDICATION || NON_BLOCKING;
    localparam int DOWN_FIFO_LATENCY        = (DOWN_FIFO_NEEDS_DATA) ? HLD_FIFO_LATENCY : OCC_TRACKER_LATENCY;
    localparam int DOWN_FIFO_DEPTH_DESIRED  = ALMOST_EMPTY_CUTOFF_DOWNSTREAM                        //if there is a sync downstream of this block, need this much occupancy to keep it in fast read mode
                                                                                                    //no transactions in flight to catch, same clock cycle handshaking is used to determine whether to transact
                                            + 1 + DOWN_FIFO_LATENCY;                                //ensure no bubbles, latency of i_stall -> o_stall -> i_valid -> o_valid
    localparam int DOWN_FIFO_DEPTH          = quantizeFifoDepthUsingWidth(DOWN_FIFO_DEPTH_DESIRED, 1);

    //side fifo receives data from the sidepath and provides data to kernel downstream, this is the only wide fifo within iord
    localparam int SIDE_FIFO_LATENCY        = HLD_FIFO_LATENCY + INTER_KERNEL_PIPELINING;           //effective latency through the fifo after factoring in the pipelining in front of hld_fifo
    localparam int SIDE_FIFO_DEPTH_DESIRED  = CAPACITY_FROM_CHANNEL                                 //capacity consolidated from channel and/or iowr
                                            + ALMOST_FULL_CUTOFF_SIDEPATH                           //catch up to this many transactions already in flight
                                            + ALMOST_EMPTY_CUTOFF_DOWNSTREAM                        //if there is a sync downstream of this block, need this much occupancy to keep it in fast read mode
                                            + 1 + ALMOST_FULL_CUTOFF_SIDEPATH + SIDE_FIFO_LATENCY;  //ensure no bubbles, latency of i_stall -> o_stall -> i_valid -> o_valid
    localparam int SIDE_FIFO_DEPTH          = quantizeFifoDepthUsingWidth(SIDE_FIFO_DEPTH_DESIRED, DATA_WIDTH);

    //ensure side lookahead latency is not too small
    localparam int DOWN_TRANSACT_EARLINESS  = (STALL_IN_EARLINESS_DOWNSTREAM >= 1) ? 1 : 0; //how many clocks early do we determine if downstream valid will be forced

    //latency from snooping on writes to side fifo until we know whether to read from side fifo
    localparam int SIDE_LOOKAHEAD_LATENCY   = OCC_TRACKER_LATENCY               //delayed_side_lookahead_incr -> side_lookahead_has_one
                                            + DOWN_FIFO_LATENCY                 //up_transact -> down_has_one
                                            + DOWN_TRANSACT_EARLINESS;          //down_transact -> side_fifo_decr

    //if the lookahead is too fast, delay the snoop on the write into side fifo so that we don't try to read from side fifo before data is actually readable
    localparam int DELAY_SIDE_INCR          = (SIDE_LOOKAHEAD_LATENCY < SIDE_FIFO_LATENCY) ? SIDE_FIFO_LATENCY - SIDE_LOOKAHEAD_LATENCY : 0;

    //to track read_used_words between up_transact and o_empty, if the latency from up_transact to o_empty is N clocks, the increment for read_used_words should be up_transact delayed by N-1 clocks
    localparam int DELAY_DOWN_EMPTY_INCR   = (DOWN_TRANSACT_EARLINESS) ? DOWN_FIFO_LATENCY : DOWN_FIFO_LATENCY-1;



    ///////////////
    //  Signals  //
    ///////////////

    //reset
    logic aclrn, sclrn, resetn_synchronized;

    //error correction code status
    logic [1:0] up_ecc, down_ecc, data_ecc;

    //upstream
    logic up_incr, up_has_one, up_predicate, up_transact;

    //sidepath lookahead
    logic side_lookahead_incr, delayed_side_lookahead_incr, side_lookahead_decr, side_lookahead_has_one;

    //downstream transactions available
    logic down_almost_full, down_has_one, down_predicate;

    //downstream interface
    logic delayed_i_stall, down_transact, down_empty_incr, down_empty_decr, not_o_empty, not_o_almost_empty;

    //side fifo
    logic side_fifo_incr, side_fifo_decr, side_fifo_full, side_fifo_almost_full, side_fifo_somewhat_full, delayed_side_fifo_incr;
    logic [DATA_WIDTH-1:0] delayed_i_fifodata;



    /////////////
    //  Reset  //
    /////////////

    acl_reset_handler
    #(
        .ASYNC_RESET            (ASYNC_RESET),
        .SYNCHRONIZE_ACLRN      (SYNCHRONIZE_RESET),
        .USE_SYNCHRONIZER       (SYNCHRONIZE_RESET),
        .PIPE_DEPTH             (1),
        .NUM_COPIES             (1)
    )
    acl_reset_handler_inst
    (
        .clk                    (clock),
        .i_resetn               (resetn),
        .o_aclrn                (aclrn),
        .o_resetn_synchronized  (resetn_synchronized),
        .o_sclrn                (sclrn)
    );



    // error correction code status
    assign ecc_err_status = up_ecc | down_ecc | data_ecc;



    ////////////////
    //  Upstream  //
    ////////////////

    // Typically if the stall latency implementation of hld_iord is needed, then the both the kernel upstream and downstream interfaces will
    // use stall latency. This means a FIFO is needed to catch transactions in flight. In some cases we can do better than using a FIFO:
    // - upstream can be disconnected in some scenarios when this iord is an HLS system of tasks collect
    // - if predication is not used, then we need a zero width fifo, can reduce area and latency by directly using the occupancy tracker
    //
    // The read side of the upstream FIFO interacts with the central decision maker who decides whether a transaction should occur.

    assign up_incr = (USE_STALL_LATENCY_UPSTREAM) ? i_valid : i_valid & ~o_stall;
    generate
    if (DISCONNECT_UPSTREAM) begin : GEN_UP_DISCONNECT
        assign o_stall = 1'b0;
        assign up_has_one = 1'b1;
        assign up_predicate = 1'b0;
        assign up_ecc = '0;
    end
    else if (!UP_FIFO_NEEDS_DATA) begin : GEN_UP_OCC
        acl_tessellated_incr_decr_threshold #(
            .CAPACITY                   (UP_FIFO_DEPTH),
            .THRESHOLD                  (UP_FIFO_DEPTH - ALMOST_FULL_CUTOFF_UPSTREAM),
            .THRESHOLD_REACHED_AT_RESET (1),
            .ASYNC_RESET                (ASYNC_RESET),
            .SYNCHRONIZE_RESET          (0)
        )
        o_stall_inst
        (
            .clock                      (clock),
            .resetn                     (resetn_synchronized),
            .incr_no_overflow           (up_incr),
            .incr_raw                   (up_incr),
            .decr_no_underflow          (up_transact),
            .decr_raw                   (up_transact),
            .threshold_reached          (o_stall)
        );

        acl_tessellated_incr_decr_threshold #(
            .CAPACITY                   (UP_FIFO_DEPTH),
            .THRESHOLD                  (1),
            .ASYNC_RESET                (ASYNC_RESET),
            .SYNCHRONIZE_RESET          (0)
        )
        up_fifo_has_one_inst
        (
            .clock                      (clock),
            .resetn                     (resetn_synchronized),
            .incr_no_overflow           (up_incr),
            .incr_raw                   (up_incr),
            .decr_no_underflow          (up_transact),
            .decr_raw                   (up_transact),
            .threshold_reached          (up_has_one)
        );

        assign up_predicate = 1'b0;
        assign up_ecc = '0;
    end
    else begin : GEN_UP_FIFO
        hld_fifo
        #(
            .WIDTH                          (1),
            .REGISTERED_DATA_OUT_COUNT      (1),
            .DEPTH                          (UP_FIFO_DEPTH),
            .ASYNC_RESET                    (ASYNC_RESET),
            .SYNCHRONIZE_RESET              (0),
            .STYLE                          (HLD_FIFO_STYLE),
            .ALMOST_FULL_CUTOFF             (ALMOST_FULL_CUTOFF_UPSTREAM),
            .USE_STALL_LATENCY_UPSTREAM     (USE_STALL_LATENCY_UPSTREAM),
            .NEVER_OVERFLOWS                (USE_STALL_LATENCY_UPSTREAM),
            .enable_ecc                     (enable_ecc)
        )
        up_fifo
        (
            .clock                          (clock),
            .resetn                         (resetn_synchronized),
            .i_valid                        (i_valid),
            .i_data                         (i_predicate),
            .o_stall                        (o_stall),
            .o_valid                        (up_has_one),
            .o_data                         (up_predicate),
            .i_stall                        (~up_transact),
            .ecc_err_status                 (up_ecc)
        );
    end
    endgenerate



    //////////////////////////
    //  Sidepath lookahead  //
    //////////////////////////

    // There is only one data fifo that accepts data from the sidepath and provides data to kernel downstream. In order to decide whether to allow
    // that data to be released, need to separately track the how much of that data is available for downstream to use (upstream has to provide a
    // valid before downstream is allowed to use the corresponding data).

    assign side_lookahead_incr = (USE_STALL_LATENCY_SIDEPATH) ? i_fifovalid : i_fifovalid & ~o_fifostall;
    acl_shift_register_no_reset #(.WIDTH(1), .STAGES(DELAY_SIDE_INCR)) delayed_side_incr_inst (.clock(clock), .D(side_lookahead_incr), .Q(delayed_side_lookahead_incr));

    acl_tessellated_incr_decr_threshold #(
        .CAPACITY                   (SIDE_FIFO_DEPTH),
        .THRESHOLD                  (1),
        .ASYNC_RESET                (ASYNC_RESET),
        .SYNCHRONIZE_RESET          (0)
    )
    side_lookahead_has_one_inst
    (
        .clock                      (clock),
        .resetn                     (resetn_synchronized),
        .incr_no_overflow           (delayed_side_lookahead_incr),
        .incr_raw                   (delayed_side_lookahead_incr),
        .decr_no_underflow          (side_lookahead_decr),
        .decr_raw                   (side_lookahead_decr),
        .threshold_reached          (side_lookahead_has_one)
    );



    ///////////////////////////
    //  Transaction control  //
    ///////////////////////////

    // The central decision maker on whether a transaction should occur. Recall the basic operation of hld_iord is to transfer data from the
    // channel facing interface to the kernel downstream interface when all the following are met:
    // - kernel upstream has a valid
    // - channel has data
    // - kernel downstream has space available
    //
    // In the case of NON_BLOCKING, a valid can proceed from kernel upstream to kernel downstream even if the channel is empty.

    //decide whether to transact
    //yes this is same clock cycle handshaking, this is okay because the fanout is small, and there is pipelining for routability between this module and all of the producers and consumers
    assign up_transact = ~down_almost_full & up_has_one & ((NON_BLOCKING) ? 1'b1 : (up_predicate | side_lookahead_has_one));

    //decide whether to tell side lookahead that one piece of channel data should be considered consumed
    assign side_lookahead_decr = ~down_almost_full & up_has_one & ~up_predicate & side_lookahead_has_one;



    ////////////////////////////////////////
    //  Downstream transactions available //
    ////////////////////////////////////////

    // Track the number of transactions available to be released to kernel downstream. With STALL_IN_EARLINESS_DOWNSTREAM >= 1, this is done
    // one clock cycle ahead of time compared to when the data is released. Like the upstream interface, if the fifo is zero width then can save
    // area and latency by using occupancy trackers directly.

    generate
    if (!DOWN_FIFO_NEEDS_DATA) begin : GEN_DOWN_OCC
        acl_tessellated_incr_decr_threshold #(
            .CAPACITY                   (DOWN_FIFO_DEPTH),
            .THRESHOLD                  (DOWN_FIFO_DEPTH - DOWN_TRANSACT_EARLINESS),
            .ASYNC_RESET                (ASYNC_RESET),
            .SYNCHRONIZE_RESET          (0)
        )
        down_almost_full_inst
        (
            .clock                      (clock),
            .resetn                     (resetn_synchronized),
            .incr_no_overflow           (up_transact),
            .incr_raw                   (up_transact),
            .decr_no_underflow          (down_transact),
            .decr_raw                   (down_transact),
            .threshold_reached          (down_almost_full)
        );

        acl_tessellated_incr_decr_threshold #(
            .CAPACITY                   (DOWN_FIFO_DEPTH),
            .THRESHOLD                  (1),
            .ASYNC_RESET                (ASYNC_RESET),
            .SYNCHRONIZE_RESET          (0)
        )
        down_has_one_inst
        (
            .clock                      (clock),
            .resetn                     (resetn_synchronized),
            .incr_no_overflow           (up_transact),
            .incr_raw                   (up_transact),
            .decr_no_underflow          (down_transact),
            .decr_raw                   (down_transact),
            .threshold_reached          (down_has_one)
        );

        assign down_predicate = 1'b0;
        assign down_ecc = '0;
    end
    else begin : GEN_DOWN_FIFO
        hld_fifo
        #(
            .WIDTH                          (1),
            .REGISTERED_DATA_OUT_COUNT      (1),
            .DEPTH                          (DOWN_FIFO_DEPTH),
            .ASYNC_RESET                    (ASYNC_RESET),
            .SYNCHRONIZE_RESET              (0),
            .STYLE                          (HLD_FIFO_STYLE),
            .ALMOST_FULL_CUTOFF             (DOWN_TRANSACT_EARLINESS),    //o_empty is decremented one clock later than this fifo, ensure that counter doesn't overflow
            .USE_STALL_LATENCY_UPSTREAM     (1),
            .NEVER_OVERFLOWS                (1),
            .enable_ecc                     (enable_ecc)
        )
        down_lookahead_fifo
        (
            .clock                          (clock),
            .resetn                         (resetn_synchronized),
            .i_valid                        (up_transact),
            .i_data                         (up_predicate | ((NON_BLOCKING) ? ~side_lookahead_has_one : 1'b0)), //don't read from side fifo later on if predicated or side lookahead was empty
            .o_stall                        (down_almost_full),
            .o_valid                        (down_has_one),
            .o_data                         (down_predicate),
            .i_stall                        (~down_transact),
            .ecc_err_status                 (down_ecc)
        );
    end
    endgenerate



    ////////////////////////////
    //  Downstream interface  //
    ////////////////////////////

    //absorb excess stall in earliness above 1
    acl_shift_register_no_reset #(.WIDTH(1), .STAGES(STALL_IN_EARLINESS_DOWNSTREAM-DOWN_TRANSACT_EARLINESS)) delayed_i_stall_inst (.clock(clock), .D(i_stall), .Q(delayed_i_stall));

    //decide whether to release a valid to kernel downstream
    assign down_transact = ~delayed_i_stall & down_has_one;

    //adjust the timing of the increment and decrement signals for the occupancy trackers that will produce o_empty and o_almost_empty
    //recall that if a fifo has latency N, the increment for read used words should be the write request into that fifo delayed by N-1 clocks
    //also down_transact is DOWN_TRANSACT_EARLINESS clock cycles early compared to o_empty and o_almost_empty
    acl_shift_register_no_reset #(.WIDTH(1), .STAGES(DELAY_DOWN_EMPTY_INCR))   down_empty_incr_inst (.clock(clock), .D(up_transact),   .Q(down_empty_incr));
    acl_shift_register_no_reset #(.WIDTH(1), .STAGES(DOWN_TRANSACT_EARLINESS)) down_empty_decr_inst (.clock(clock), .D(down_transact), .Q(down_empty_decr));

    acl_tessellated_incr_decr_threshold #(
        .CAPACITY                   (DOWN_FIFO_DEPTH),
        .THRESHOLD                  (1),
        .ASYNC_RESET                (ASYNC_RESET),
        .SYNCHRONIZE_RESET          (0)
    )
    down_has_one_inst
    (
        .clock                      (clock),
        .resetn                     (resetn_synchronized),
        .incr_no_overflow           (down_empty_incr),
        .incr_raw                   (down_empty_incr),
        .decr_no_underflow          (down_empty_decr),
        .decr_raw                   (down_empty_decr),
        .threshold_reached          (not_o_empty)
    );
    assign o_empty = ~not_o_empty;
    assign o_valid = (USE_STALL_LATENCY_DOWNSTREAM) ? down_empty_decr : ~o_empty;

    acl_tessellated_incr_decr_threshold #(
        .CAPACITY                   (DOWN_FIFO_DEPTH),
        .THRESHOLD                  (ALMOST_EMPTY_CUTOFF_DOWNSTREAM + 1),
        .ASYNC_RESET                (ASYNC_RESET),
        .SYNCHRONIZE_RESET          (0)
    )
    down_has_many_inst
    (
        .clock                      (clock),
        .resetn                     (resetn_synchronized),
        .incr_no_overflow           (down_empty_incr),
        .incr_raw                   (down_empty_incr),
        .decr_no_underflow          (down_empty_decr),
        .decr_raw                   (down_empty_decr),
        .threshold_reached          (not_o_almost_empty)
    );
    assign o_almost_empty = ~not_o_almost_empty;



    /////////////////
    //  Side fifo  //
    /////////////////

    // There is only one fifo on the data path, this accepts data from the sidepath and provides it to kernel downstream. The occupancy
    // of this fifo is tracked externally so it is known when it is safe to force a read or write.

    assign side_fifo_incr = (USE_STALL_LATENCY_SIDEPATH) ? i_fifovalid : i_fifovalid & ~o_fifostall;
    acl_shift_register_no_reset #(.WIDTH(1), .STAGES(DOWN_TRANSACT_EARLINESS)) side_fifo_rdack_inst (.clock(clock), .D(down_transact & ~down_predicate), .Q(side_fifo_decr));

    //track the fullness of this fifo to backpressure the channel or iowr
    acl_tessellated_incr_decr_threshold #(
        .CAPACITY                   (SIDE_FIFO_DEPTH),
        .THRESHOLD                  (SIDE_FIFO_DEPTH),
        .THRESHOLD_REACHED_AT_RESET (1),
        .ASYNC_RESET                (ASYNC_RESET),
        .SYNCHRONIZE_RESET          (0)
    )
    side_fifo_full_inst
    (
        .clock                      (clock),
        .resetn                     (resetn_synchronized),
        .incr_no_overflow           (side_fifo_incr),
        .incr_raw                   (side_fifo_incr),
        .decr_no_underflow          (side_fifo_decr),
        .decr_raw                   (side_fifo_decr),
        .threshold_reached          (side_fifo_full)
    );

    acl_tessellated_incr_decr_threshold #(
        .CAPACITY                   (SIDE_FIFO_DEPTH),
        .THRESHOLD                  (SIDE_FIFO_DEPTH - ALMOST_FULL_CUTOFF_SIDEPATH),
        .THRESHOLD_REACHED_AT_RESET (1),
        .ASYNC_RESET                (ASYNC_RESET),
        .SYNCHRONIZE_RESET          (0)
    )
    side_fifo_almost_full_inst
    (
        .clock                      (clock),
        .resetn                     (resetn_synchronized),
        .incr_no_overflow           (side_fifo_incr),
        .incr_raw                   (side_fifo_incr),
        .decr_no_underflow          (side_fifo_decr),
        .decr_raw                   (side_fifo_decr),
        .threshold_reached          (side_fifo_almost_full)
    );

    // This is only used by the profiler. If the writer into the channel produces data faster than the reader from the channel
    // can consume it, the steady state behavior an osscillation of many clock cycles of writing into the channel and many clock
    // cycles of the channel being almost full. The profiler is interested in whether upstream has data to send which can be
    // interpreted in a few different ways:
    // - channel not empty: upstream has work queued in this fifo, however this interpretation does not take into account the
    //     depth of the channel which adds elasticity to the data path
    // - channel almost full: this interpretation takes into account the channel depth, however it suffers from the swings in
    //     almost full which doesn't accurately reflect upstream always wants to send data when writer is faster than reader
    // - channel somewhat full: a similar approach to almost full (which takes into account the channel depth) but lower the
    //     threshold enough not be impacted by the swings in almost full
    // Somewhat full is the best interpretation to use.
    acl_tessellated_incr_decr_threshold #(
        .CAPACITY                   (SIDE_FIFO_DEPTH),
        .THRESHOLD                  (SIDE_FIFO_DEPTH - (2*ALMOST_FULL_CUTOFF_SIDEPATH+1)),
        .THRESHOLD_REACHED_AT_RESET (1),
        .ASYNC_RESET                (ASYNC_RESET),
        .SYNCHRONIZE_RESET          (0)
    )
    side_fifo_somewhat_full_inst
    (
        .clock                      (clock),
        .resetn                     (resetn_synchronized),
        .incr_no_overflow           (side_fifo_incr),
        .incr_raw                   (side_fifo_incr),
        .decr_no_underflow          (side_fifo_decr),
        .decr_raw                   (side_fifo_decr),
        .threshold_reached          (side_fifo_somewhat_full)
    );

    assign o_fifostall = (USE_STALL_LATENCY_SIDEPATH) ? side_fifo_almost_full : side_fifo_full;
    assign o_fifoalmost_full = side_fifo_almost_full;

    //inter kernel pipelining -- add some pipelining stages before the fifo
    acl_shift_register_no_reset #(
        .WIDTH      (DATA_WIDTH+1),
        .STAGES     (INTER_KERNEL_PIPELINING)
    )
    delay_write_interface_of_side_fifo
    (
        .clock      (clock),
        .D          ({i_fifodata, side_fifo_incr}),
        .Q          ({delayed_i_fifodata, delayed_side_fifo_incr})
    );

    hld_fifo
    #(
        .WIDTH                          (DATA_WIDTH),
        .REGISTERED_DATA_OUT_COUNT      (0),
        .DEPTH                          (SIDE_FIFO_DEPTH),
        .ASYNC_RESET                    (ASYNC_RESET),
        .SYNCHRONIZE_RESET              (0),
        .STYLE                          (HLD_FIFO_STYLE),
        .USE_STALL_LATENCY_UPSTREAM     (1),
        .NEVER_OVERFLOWS                (1),
        .enable_ecc                     (enable_ecc)
    )
    side_fifo
    (
        .clock                          (clock),
        .resetn                         (resetn_synchronized),
        .i_valid                        (delayed_side_fifo_incr),
        .i_data                         (delayed_i_fifodata),
        .o_data                         (o_data),
        .i_stall                        (~side_fifo_decr),
        .ecc_err_status                 (data_ecc)
    );
    assign o_datavalid = side_fifo_decr;    //only used in non-blocking, indicates whether the sidepath was read



    ////////////////
    //  Profiler  //
    ////////////////

    // Note that all of the logic below will have no fanout (will be synthesized away) unless ACL_PROFILE = 1.
    //
    // If fifo merging decides to implement the channel fifo inside iord, expose how many words are inside the fifo to the profiler. Want the binary count of
    // occupancy, so can't use the occupancy tracker. To mitigate against fmax loss, register the increment and decrement, so the occupancy is slightly stale.

    generate
    if (CAPACITY_FROM_CHANNEL) begin : GEN_CHANNEL_FIFO_OCCUPANCY
        logic incr, decr;
        always_ff @(posedge clock or negedge aclrn) begin
            if (~aclrn) begin
                incr <= 1'b0;
                decr <= 1'b0;
                o_channel_fifo_occupancy <= '0;
            end
            else begin
                incr <= delayed_side_fifo_incr;     //write into fifo
                decr <= side_fifo_decr;             //read from fifo
                o_channel_fifo_occupancy <= o_channel_fifo_occupancy + incr - decr; //how many words are inside the fifo
                if (~sclrn) begin
                    incr <= 1'b0;
                    decr <= 1'b0;
                    o_channel_fifo_occupancy <= '0;
                end
            end
        end
    end
    else begin : NO_CHANNEL_FIFO_OCCUPANCY
        assign o_channel_fifo_occupancy = '0;
    end
    endgenerate

    // The profiler is currently tapping signals that fundamentally do not exist in the stall latency protocol. For example, one thing the profiler is interested
    // in is when the channel stalls the upstream interface. For iord, this means upstream wants to send a valid but cannot since the channel is empty. This
    // requires upstream to be able to say "work is available and may be consumed", however stall latency only allows upstream to force a transaction. This can
    // be worked around by adding a FIFO after the upstream interface but before core iord logic which decides whether a transaction will proceed. This FIFO
    // natually exists for iord, however it does not for iowr if FIFO merging moves the capacity of iowr into iord. Adding a FIFO would be a very large overhead
    // as the FIFO would be the full data path width. However, it turns out the profiling information for iowr is still available inside iord, and a new signal
    // (channel_stall) is routed from iord through channel to iowr (corresponding changes have been made in Griffin/XNodeExternalIP and in system integrator).

    // Profiling for iord
    always_ff @(posedge clock or negedge aclrn) begin
        if (~aclrn) begin
            o_profile_o_stall <= 1'b0;
            o_profile_fifo_stall <= 1'b0;
        end
        else begin
            o_profile_o_stall <= up_has_one & ~up_transact;                                 //upstream wants to send a valid but iord is stalling (channel empty or downstream full)
            o_profile_fifo_stall <= up_has_one & ~up_predicate & ~side_lookahead_has_one;   //upstream wants to send a nonpredicated valid but channel is empty
            if (~sclrn) begin
                o_profile_o_stall <= 1'b0;
                o_profile_fifo_stall <= 1'b0;
            end
        end
    end

    // Profiling for iowr: if iowr capacity merges into iord, iord tells iowr when the channel interface would have been stalling upstream
    // If writing into the channel happens faster than reading from the channel, somewhat full will be persistently asserted
    // Profiler is interested in whether iowr wants to send data but cannot since channel is full, so whenever a channel read happens we ignore somewhat full since forward progress is being made
    assign o_fifochannel_stall = side_fifo_somewhat_full & ~side_fifo_decr;

endmodule

`default_nettype wire
