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


//===----------------------------------------------------------------------===//
//
// C backend 'push' primitive
//
// Upstream are signals that go to the feedback (snk node is a acl_pop),
// downstream are signals that continue into our "normal" pipeline.
//
// dir indicates if you want to push it to the feedback
//   1 - push to feedback
//   0 - bypass, just push out to downstream
//===----------------------------------------------------------------------===//

// altera message_off 10036

`default_nettype none

module acl_push (
	clock,
	resetn,

	// interface from kernel pipeline, input stream
	dir,
	data_in,
    valid_in,
    stall_out,
    predicate,

	// interface to kernel pipeline, downstream
    valid_out,
    stall_in,
    data_out,

	// interface to pipeline feedback, upstream
    feedback_out,
    feedback_valid_out,
    feedback_stall_in,
    ecc_err_status
);

    parameter DATA_WIDTH = 32;
    parameter FIFO_DEPTH = 1;
    parameter MIN_FIFO_LATENCY = 0;
    // style can be "REGULAR", for a regular push
    // or "TOKEN" for a special fifo that hands out tokens 
    parameter string STYLE = "REGULAR";     // "REGULAR"/"TOKEN"
    parameter STALLFREE = 0;
    parameter ENABLED = 0;
    parameter INF_LOOP = 0;
    parameter INF_LOOP_INITIALIZATION = 32'b0;  // Initial value to use, when INITIALIZE_TO_VALID is 1
    parameter RAM_FIFO_DEPTH_INC = 1; // allows incrementing RAM fifo depth by 1
    parameter bit ASYNC_RESET = 1;          // how do the registers CONSUME reset: 1 means registers are reset asynchronously, 0 means registers are reset synchronously
    parameter bit SYNCHRONIZE_RESET = 0;    // before consumption, do we SYNCHRONIZE the reset: 1 means use a synchronizer (assume reset arrived asynchronously), 0 means passthrough (assume reset was already synchronized)
    parameter bit RESET_EVERYTHING = 0;
    parameter enable_ecc = "FALSE";    // Enable error correction coding
    parameter FEEDBACK_INITIAL_OCCUPANCY = 0; // =0 means the feedback FIFO is implemented in acl_data_fifo. >0 means hld_fifo is used with the given initial occupany (requires that the pop reads this garbage data at the start of a loop), and we always write to the feedback FIFO (ie. dir is ignored)

input wire clock, resetn, stall_in, valid_in, feedback_stall_in;
output logic stall_out, valid_out, feedback_valid_out;
input wire [DATA_WIDTH-1:0] data_in;
input wire dir;
input wire predicate;
output logic [DATA_WIDTH-1:0] data_out, feedback_out;
output logic  [1:0] ecc_err_status;  // ecc status signals


localparam IGNORE_DIR = FEEDBACK_INITIAL_OCCUPANCY > 0;

//////////////////////////////////////
//                                  //
//  Sanity check on the parameters  //
//                                  //
//////////////////////////////////////

// the checks are done in Quartus pro and Modelsim, it is disabled in Quartus standard because it results in a syntax error (parser is based on an older systemverilog standard)
// the workaround is to use synthesis translate to hide this from Quartus standard, ALTERA_RESERVED_QHD is only defined in Quartus pro, and Modelsim ignores the synthesis comment
`ifdef ALTERA_RESERVED_QHD
`else
//synthesis translate_off
`endif
generate
if (IGNORE_DIR && INF_LOOP) begin
    $fatal(1, "acl_push: Cannot set FEEDBACK_INITIAL_OCCUPANCY>0 and INF_LOOP=1. The initial occupancy feature requires hld_fifo, but hld_fifo does not support INF_LOOP."); 
end
endgenerate
`ifdef ALTERA_RESERVED_QHD
`else
//synthesis translate_on
`endif

logic [DATA_WIDTH-1:0] feedback;
logic data_downstream, data_upstream;

logic push_upstream;
// Write data into the feedback FIFO on non-predicated valids when dir=1. But if IGNORE_DIR=1, then consider non-predicated valids
assign push_upstream = (IGNORE_DIR | dir) & ~predicate;

assign data_upstream = valid_in & push_upstream;
assign data_downstream = valid_in;

logic feedback_stall, feedback_valid;

logic consumed_downstream, consumed_upstream;

logic aclrn, sclrn, resetn_synchronized;
acl_reset_handler
#(
    .ASYNC_RESET            (ASYNC_RESET),
    .SYNCHRONIZE_ACLRN      (SYNCHRONIZE_RESET),
    .USE_SYNCHRONIZER       (SYNCHRONIZE_RESET),
    .PULSE_EXTENSION        (0),
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

generate
if (STYLE == "BYPASS") begin
  // Turn this push into wires
  assign valid_out = valid_in;
  assign stall_out = stall_in;
  assign feedback_valid_out = 1'b0;
  assign feedback_out = 'bx;
  assign data_out = data_in;
end else begin

  assign valid_out = data_downstream & !consumed_downstream;
  assign feedback_valid = data_upstream & !consumed_upstream & (ENABLED ? ~stall_in : 1'b1);
  assign data_out = data_in;
  assign feedback = data_in;
  
  assign stall_out = stall_in | (feedback_stall & push_upstream );
  
     if (ENABLED) begin
  
        always @(posedge clock or negedge aclrn) begin
           if (!aclrn) begin
              consumed_downstream <= 1'b0;
              consumed_upstream <= 1'b0;
           end
           else begin
              if (~stall_in) begin
                 if (consumed_downstream)
                   consumed_downstream <= stall_out;
                 else  
                   consumed_downstream <= stall_out & data_downstream;
  
                 consumed_upstream <= 1'b0;
              end
              if (!sclrn) begin
                 consumed_downstream <= 1'b0;
                 consumed_upstream <= 1'b0;
              end
           end
        end
  
     end else begin
  
        always @(posedge clock or negedge aclrn) begin
           if (!aclrn) begin
              consumed_downstream <= 1'b0;
              consumed_upstream <= 1'b0;
           end
           else begin
              if (consumed_downstream)
                consumed_downstream <= stall_out;
              else  
                consumed_downstream <= stall_out & (data_downstream & ~stall_in);
  
              if (consumed_upstream)
                consumed_upstream <= stall_out;
              else  
                consumed_upstream <= stall_out & (data_upstream & ~feedback_stall);
              if (!sclrn) begin
                 consumed_downstream <= 1'b0;
                 consumed_upstream <= 1'b0;
              end
           end
        end
  
     end
  
  if ( STYLE == "TOKEN" )
  begin
    // Initializes to full. Behaves as though its initial occupancy is FIFO_DEPTH.
    acl_token_fifo_counter 
    #(
      .DEPTH(FIFO_DEPTH),
      .ASYNC_RESET(ASYNC_RESET),
      .SYNCHRONIZE_RESET(0)
     )
    fifo (
      .clock(clock),
      .resetn(resetn_synchronized),
      .data_out(feedback_out),
      .valid_in(feedback_valid),
      .valid_out(feedback_valid_out),
      .stall_in(feedback_stall_in),
      .stall_out(feedback_stall)
    );
    assign ecc_err_status = 2'h0;
  end
  else if (FIFO_DEPTH == 0) begin
    // if no FIFO depth is requested, just connect
    // feedback directly to output
    assign feedback_out = feedback;
    assign feedback_valid_out = feedback_valid;
    assign feedback_stall = feedback_stall_in;
    assign ecc_err_status = 2'h0;
  end
  else
  begin
  
    if (!IGNORE_DIR) begin // Don't implement FIFO initial occupancy

      if (FIFO_DEPTH == 1 && MIN_FIFO_LATENCY == 0) begin
        // simply add a staging register if the requested depth is 1
        // and the latency must be 0
        acl_staging_reg #(
        .WIDTH(DATA_WIDTH),
        .ASYNC_RESET(ASYNC_RESET),
        .SYNCHRONIZE_RESET(0)
        ) staging_reg (
        .clk(clock), 
        .reset(~resetn_synchronized), 
        .i_data(feedback),
        .i_valid(feedback_valid),
        .o_stall(feedback_stall),
        .o_data(feedback_out), 
        .o_valid(feedback_valid_out), 
        .i_stall(feedback_stall_in)
        );
        assign ecc_err_status = 2'h0;
      end else begin
        localparam TYPE = MIN_FIFO_LATENCY < 1 ? (FIFO_DEPTH < 8 ? "zl_reg" : "zl_ram") : (MIN_FIFO_LATENCY < 3 ? (FIFO_DEPTH < 8 ? "ll_reg" : "ll_ram") : (FIFO_DEPTH < 8 ? "ll_reg" : "ram"));
        localparam OFFSET = ( (TYPE == "ll_reg") && !STALLFREE ) ? 1 : 0;
        // only allow full write in stall free clusters if you're an ll_reg
        // otherwise, comb cycles can form, since stall_out depends on
        // stall_in the acl_data_fifo.  To make up for the last space, we
        // add a capacity of 1 to the FIFO      
        localparam ALLOW_FULL_WRITE = ( (TYPE == "ll_reg") && !STALLFREE ) ? 0 : 1;

        acl_data_fifo #(
         .DATA_WIDTH(DATA_WIDTH),
         .DEPTH(((TYPE == "ram")  || (TYPE == "ll_ram") || (TYPE == "zl_ram")) ? FIFO_DEPTH + RAM_FIFO_DEPTH_INC : FIFO_DEPTH + OFFSET),
         .IMPL(TYPE),
         .ALLOW_FULL_WRITE(ALLOW_FULL_WRITE),
         .INITIALIZE_TO_VALID(INF_LOOP),
         .INITIAL_FIFO_VALUE(INF_LOOP_INITIALIZATION),
         .ASYNC_RESET(ASYNC_RESET),
         .SYNCHRONIZE_RESET(0),
         .enable_ecc(enable_ecc)
         )
        fifo (
        .clock(clock),
        .resetn(resetn_synchronized),
        .data_in(feedback),
        .data_out(feedback_out),
        .valid_in(feedback_valid),
        .valid_out(feedback_valid_out),
        .stall_in(feedback_stall_in),
        .stall_out(feedback_stall),
        .ecc_err_status(ecc_err_status)
        );
      end
    end else begin  // Initial occupancy needed. hld_fifo doesn't support INF_LOOP so we'll error out if INF_LOOP=1.
      
      localparam TYPE = MIN_FIFO_LATENCY < 1 ? "zl" : (MIN_FIFO_LATENCY < 3 ? "ll" : "ms");
      localparam OFFSET = ( (STYLE == "ll") && !STALLFREE ) ? 1 : 0;
      localparam ALLOW_FULL_WRITE = ( (TYPE == "ll") && !STALLFREE ) ? 0 : 1;      
      localparam FIFO_DEPTH_ADJUSTED = ((TYPE == "ms")  || (TYPE == "ll") || (TYPE == "zl")) ? FIFO_DEPTH + RAM_FIFO_DEPTH_INC : FIFO_DEPTH + OFFSET;
      // Defaults to stall-valid mode
      hld_fifo #(
        .WIDTH (DATA_WIDTH),
        .DEPTH (FIFO_DEPTH_ADJUSTED),
        .INITIAL_OCCUPANCY (FEEDBACK_INITIAL_OCCUPANCY),
        .ASYNC_RESET (ASYNC_RESET),
        .SYNCHRONIZE_RESET (SYNCHRONIZE_RESET),
        .RESET_EVERYTHING (RESET_EVERYTHING),
        .WRITE_AND_READ_DURING_FULL (ALLOW_FULL_WRITE),
        .STYLE (TYPE),
        .enable_ecc (enable_ecc)
      ) fifo
      (
        .clock  (clock),
        .resetn (resetn_synchronized) ,
        .i_valid (feedback_valid),
        .i_data (feedback),
        .o_stall (feedback_stall),
        .o_valid (feedback_valid_out),
        .o_data (feedback_out),
        .i_stall (feedback_stall_in),
        .ecc_err_status (ecc_err_status)
      );

    end
  end
end
endgenerate

endmodule

`default_nettype wire
