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


// This module is the stall valid implementation of iord. All interfaces must
// use same clock cycle handshaking.
//
// The basic operation of iord is to transfer data from the channel facing
// interface to the kernel downstream interface when all the following are met:
// - kernel upstream has a valid
// - channel has data
// - kernel downstream has space available
//
// The core functionality of iord requires no capacity, however the compiler may
// want to add capacity for specific reasons such as:
// - capacity balancing: between launch and collect in HLS system of tasks
// - Avalon compliance: iord can bring in data from the outside world, Avalon
//     does not require that data be held constant until the valid is accepted,
//     in some cases iord needs a staging register to captured data properly

`default_nettype none

//refer to hld_iord.sv for a description of the parameters and ports

module hld_iord_stall_valid
import hld_memory_depth_quantization_pkg::*;
#(
    //core spec
    parameter int DATA_WIDTH,
    parameter bit NON_BLOCKING,

    //reset
    parameter bit ASYNC_RESET,
    parameter bit SYNCHRONIZE_RESET,

    //upstream
    parameter bit NO_PREDICATION,
    parameter bit DISCONNECT_UPSTREAM,
    parameter int ADD_CAPACITY_UPSTREAM,

    //downstream
    parameter bit STAGING_CAPACITY,

    //other
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
    input  wire                     i_stall,
    output logic                    o_datavalid,
    output logic   [DATA_WIDTH-1:0] o_data,

    //sidepath
    input  wire                     i_fifovalid,
    output logic                    o_fifostall,
    input  wire    [DATA_WIDTH-1:0] i_fifodata,

    //other
    output logic              [1:0] ecc_err_status
);

    ///////////////
    //  Signals  //
    ///////////////

    //reset
    logic                   aclrn, sclrn, resetn_synchronized;

    //intercept upstream interface
    logic                   up_valid, up_predicate, up_stall;

    //intercept downstream interface
    logic                   down_valid, down_stall, down_datavalid;
    logic  [DATA_WIDTH-1:0] down_data;



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



    ////////////////////////////////////
    //  Intercept upstream interface  //
    ////////////////////////////////////

    generate
    if (DISCONNECT_UPSTREAM) begin : GEN_UP_DISCONNECT
        assign up_valid = 1'b1;
        assign up_predicate = 1'b0;
        assign o_stall = 1'b0;
        assign ecc_err_status = '0;
    end
    else if (ADD_CAPACITY_UPSTREAM) begin : GEN_UP_FIFO
        localparam int FIFO_DEPTH = quantizeFifoDepthUsingWidth(ADD_CAPACITY_UPSTREAM, 1);
        logic up_predicate_raw;

        hld_fifo
        #(
            .WIDTH                          (1),
            .DEPTH                          (FIFO_DEPTH),
            .ASYNC_RESET                    (ASYNC_RESET),
            .SYNCHRONIZE_RESET              (0),
            .STYLE                          ((ALLOW_HIGH_SPEED_FIFO_USAGE) ? "hs" : "ms"),
            .enable_ecc                     (enable_ecc)
        )
        upstream_fifo
        (
            .clock                          (clock),
            .resetn                         (resetn_synchronized),
            .i_valid                        (i_valid),
            .i_data                         (i_predicate),
            .o_stall                        (o_stall),
            .o_valid                        (up_valid),
            .o_data                         (up_predicate_raw),
            .i_stall                        (up_stall),
            .ecc_err_status                 (ecc_err_status)
        );

        //if NO_PREDICATION = 1, up_predicate_raw is never consumed, so the memory for fifo storage will be synthesized away
        assign up_predicate = (NO_PREDICATION) ? 1'b0 : up_predicate_raw;
    end
    else begin : GEN_UP_BYPASS
        assign up_valid = i_valid;
        assign up_predicate = i_predicate;
        assign o_stall = up_stall;
        assign ecc_err_status = '0;
    end
    endgenerate



    //////////////////////////////////////
    //  Intercept downstream interface  //
    //////////////////////////////////////

    // If this iord is used to bring data from the outside world into an HLS component for example, then an external Avalon interface
    // is what connects to the iord sidepath interface. The Avalon protocol does not require data to be held constant if valid is held
    // asserted for several clock cycles while waiting for ready to assert. Consider what would happen if downstream of iord has
    // consumed registers, which allows one downstream path to go one valid ahead of another downstream path. We must avoid the scenario
    // in which one downstream path sees a different value than the other because the Avalon interface did not hold its data constant.
    // The iord should sample the data once from the Avalon interface so that the sampled copy is held constant until all downstream
    // interfaces have consumed the data. This is implemented with a staging register, which is like a capacity=1 latency=0 FIFO.
    generate
    if (STAGING_CAPACITY) begin : GEN_DOWN_STAGING_REG
        acl_staging_reg
        #(
            .WIDTH                          (DATA_WIDTH + 1),
            .ASYNC_RESET                    (ASYNC_RESET),
            .SYNCHRONIZE_RESET              (0)
        )
        downstream_staging_reg
        (
            .clk                            (clock),
            .reset                          (~resetn_synchronized),
            .i_valid                        (down_valid),
            .i_data                         ({down_data, down_datavalid}),
            .o_stall                        (down_stall),
            .o_valid                        (o_valid),
            .o_data                         ({o_data, o_datavalid}),
            .i_stall                        (i_stall)
        );
    end
    else begin : GEN_DOWN_BYPASS
        assign o_valid = down_valid;
        assign o_data = down_data;
        assign o_datavalid = down_datavalid;
        assign down_stall = i_stall;
    end
    endgenerate



    //////////////////////////////////
    //  Core functionality of iord  //
    //////////////////////////////////

    generate
    if (NON_BLOCKING) begin : GEN_NON_BLOCKING
        assign up_stall = down_stall;
        assign down_valid = up_valid;
    end
    else begin : GEN_BLOCKING
        assign up_stall = down_stall | (up_valid & ~up_predicate & ~i_fifovalid);
        assign down_valid = up_valid & (up_predicate | i_fifovalid);
    end
    endgenerate
    assign o_fifostall = ~up_valid | up_predicate | down_stall;
    assign down_data = i_fifodata;
    assign down_datavalid = up_valid & ~up_predicate & i_fifovalid;

endmodule

`default_nettype wire
