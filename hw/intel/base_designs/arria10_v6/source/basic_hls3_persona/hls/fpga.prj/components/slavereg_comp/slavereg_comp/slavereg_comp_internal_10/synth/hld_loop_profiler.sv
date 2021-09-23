// (c) 1992-2021 Intel Corporation.                            
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


// This IP measures the latency for thread execution in loop and nested loop
// in simulation, hardware profiling loop occupancy and stalls by successor for
// profiler-guided optimization.
// The compiler is to insert by compiler one IP per loop.
// For simple loop, it is inserted at the block level.
// For nested loop, it needs to be inserted at function level where it can
// connected to slave of stall-valid of header and master of stall-valid of
// latch.
//
// Usage documentation
// For simple loop, add the following to the basic block that's a loop with the 
// following sample connections.
//   hld_loop_profiler #(
//     .LOOP_NAME("<BLOCK NAME>")
//   ) accum_B2_profiler (
//     .clock(clock),
//     .resetn(resetn),
//     .i_clear(1'b0),      // TO BE CONNECTED BY PROFILER
//     .i_capture(1'b0),    // TO BE CONNECTED BY PROFILER
//     .i_enable(1'b1),     // TO BE CONNECTED BY PROFILER
//     .i_shift(1'b0),      // TO BE CONNECTED BY PROFILER
//     .i_shift_data('b0),  // TO BE CONNECTED BY PROFILER
//     .i_stall_pred(out_stall_out_1),
//     .i_valid_pred(in_valid_in_1),
//     .i_stall_succ(in_stall_in_0),
//     .i_valid_succ(out_valid_out_0),
//     .i_valid_loop(in_valid_in_0)
//   );
//
// Parameters:
//   LOOP_NAME is the name of the loop. Use name of the header or the block
//   DAISY_WIDTH is the width of profiler counter that is serially chained together
//   HLD_PROFILE indicates whether the hardware profiler is being inserted, and the signals to it have to be exposed
//
// Profiler interface control inputs:
//   i_capture      : 1 means load the output of counter to a capture buffer when ENABLE_DOUBLE_BUFFER = 1.
//   i_clear        : 1 means clear the counter.
//   i_enable       : 1 means enable the accumlator.
//   i_shift        : 1 means shift out of counter serially via shift data output.
//   i_shift_data   : input data for profiler counter connected serially during shifting.
//   o_shift_data   : output data for profiler counter connected serially during shifting.
//

`default_nettype none
module hld_loop_profiler #(
  parameter string LOOP_NAME,
  parameter DAISY_WIDTH = 64,
  parameter bit HLD_PROFILE = 0
)
(
  input  wire                         clock,
  input  wire                         resetn,

  // common hardware profiler interface
  input  wire                         i_capture,
  input  wire                         i_clear,
  input  wire                         i_enable,
  input  wire                         i_shift,
  input  wire       [DAISY_WIDTH-1:0] i_shift_data,
  output logic      [DAISY_WIDTH-1:0] o_shift_data,

  // Loop specific counter interface
  // predessor interface
  input  wire                         i_stall_pred,
  input  wire                         i_valid_pred,

  // successor interface
  input  wire                         i_stall_succ,
  input  wire                         i_valid_succ,

  // loop backedge for hardware profiling loop occupancy
  input  wire                         i_valid_loop,  // connect to valid_in_0 in block
  
  // expose the i_valid signal from the loop for profiler to hook up to (to measure loop occupancy)
  output logic                        o_profile_valid
);

  // Expose o_profile_valid for the profiler
  assign o_profile_valid = i_valid_loop;

  // Simulation latency tracker that measures how many clock cycles for one
  // invocation of the loop to finish
  hld_sim_latency_tracker #(
   .NAME (LOOP_NAME)
  ) sim_tracker_inst (
  .clock    (clock),
  .resetn   (resetn),
  .i_enable (1'b1),
  .i_start  (i_valid_pred & !i_stall_pred),
  .i_end    (i_valid_succ & !i_stall_succ)
  );

  // TODO: case:14011070876 Add hardware profiler counters to measure loop occupancy

endmodule
`default_nettype wire
