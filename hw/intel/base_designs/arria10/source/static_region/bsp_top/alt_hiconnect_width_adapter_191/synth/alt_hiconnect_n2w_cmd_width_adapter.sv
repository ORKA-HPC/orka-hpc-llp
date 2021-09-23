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


// Hyperflex-Optimized Interconnect Command Width Adapter
 
`timescale 1 ns / 1 ns
`default_nettype none

module alt_hiconnect_n2w_cmd_width_adapter
#(
   parameter IN_PKT_ADDR_L                 = 0,
   parameter IN_PKT_ADDR_H                 = 31,
   parameter IN_PKT_DATA_L                 = 32,
   parameter IN_PKT_DATA_H                 = 47,
   parameter IN_PKT_BYTEEN_L               = 48,
   parameter IN_PKT_BYTEEN_H               = 49,
   parameter IN_PKT_TRANS_COMPRESSED_READ  = 54,
   parameter IN_PKT_BYTE_CNT_L             = 55,
   parameter IN_PKT_BYTE_CNT_H             = 59,
   parameter IN_PKT_BURSTWRAP_L            = 60,
   parameter IN_PKT_BURSTWRAP_H            = 64,
   parameter IN_PKT_BURST_SIZE_L           = 65,
   parameter IN_PKT_BURST_SIZE_H           = 67,
   parameter IN_PKT_RESPONSE_STATUS_L      = 68,
   parameter IN_PKT_RESPONSE_STATUS_H      = 69,
   parameter IN_PKT_TRANS_EXCLUSIVE        = 70,
   parameter IN_PKT_BURST_TYPE_L           = 71,
   parameter IN_PKT_BURST_TYPE_H           = 72,
   parameter IN_PKT_ORI_BURST_SIZE_L       = 73,
   parameter IN_PKT_ORI_BURST_SIZE_H       = 75,
   parameter IN_PKT_TRANS_WRITE            = 76,
   parameter IN_ST_DATA_W                  = 92,
                                             
   parameter OUT_PKT_ADDR_L                = 0,
   parameter OUT_PKT_ADDR_H                = 31,
   parameter OUT_PKT_DATA_L                = 32,
   parameter OUT_PKT_DATA_H                = 63,
   parameter OUT_PKT_BYTEEN_L              = 64,
   parameter OUT_PKT_BYTEEN_H              = 67,
   parameter OUT_PKT_TRANS_COMPRESSED_READ = 72,
   parameter OUT_PKT_BYTE_CNT_L            = 73,
   parameter OUT_PKT_BYTE_CNT_H            = 77,
   parameter OUT_PKT_BURST_SIZE_L          = 83,
   parameter OUT_PKT_BURST_SIZE_H          = 85,
   parameter OUT_PKT_RESPONSE_STATUS_L     = 86,
   parameter OUT_PKT_RESPONSE_STATUS_H     = 87,
   parameter OUT_PKT_TRANS_EXCLUSIVE       = 88,
   parameter OUT_PKT_BURST_TYPE_L          = 89,
   parameter OUT_PKT_BURST_TYPE_H          = 90,
   parameter OUT_PKT_ORI_BURST_SIZE_L      = 91,
   parameter OUT_PKT_ORI_BURST_SIZE_H      = 93,
   parameter OUT_ST_DATA_W                 = 110,
   
   parameter ST_CHANNEL_W                  = 32,
   
   // Address alignment can be omitted (an optimization) if all connected
   // masters only issue aligned addresses (think Avalon W2N).
   parameter ENABLE_ADDRESS_ALIGNMENT      = 1,
   parameter CONSTANT_BURST_SIZE           = 1,    // 1: Optimizes for Avalon-only systems as those always have full size transactions

   parameter LOG_RATIO = $clog2((OUT_PKT_DATA_H-OUT_PKT_DATA_L+1)/(IN_PKT_DATA_H-IN_PKT_DATA_L+1))
)
(
   input wire                       clk,
   input wire                       reset,
   
   output reg                       in_ready,
   input wire                       in_valid,
   input wire [ST_CHANNEL_W-1:0]    in_channel,
   input wire [IN_ST_DATA_W-1:0]    in_data,
   input wire                       in_startofpacket,
   input wire                       in_endofpacket,
   
   input wire                       out_ready,
   output reg                       out_valid,
   output wire [ST_CHANNEL_W-1:0]   out_channel,
   output reg [OUT_ST_DATA_W-1:0]   out_data,
   output reg                       out_startofpacket,
   output reg                       out_endofpacket,

   input  wire                      out_cmd_shamt_ready,
   output wire [2*LOG_RATIO-1:0]    out_cmd_shamt_data,
   output wire                      out_cmd_shamt_valid
);

    // For shared derived parameters, including pseudo-field parameters and helper functions
   `include "alt_hiconnect_width_adapter_utils.iv"
   reg                           internal_sclr;

   reg                           in_valid_q;  
   reg  [IN_ST_DATA_W-1:0]       in_data_q; 
   reg                           in_sop_q;  
   reg                           in_eop_q;   
   reg  [ST_CHANNEL_W-1:0]       in_channel_q;

   wire [BURST_SIZE_W-1:0]      in_burst_size_field; 
   wire [IN_DATA_W-1:0]         in_data_field; 
   wire [IN_BYTEEN_W-1:0]       in_byteen_field;
   reg  [IN_BYTEEN_W-1:0]       in_byteen_reg;  
   wire [ADDRESS_W-1:0]         in_address_field;
   wire [BYTE_CNT_W-1:0]        in_byte_cnt_field;
   reg  [BYTE_CNT_W-1:0]        in_byte_cnt_reg;
   reg                          in_non_burst_trans_reg;
   wire                         in_cmpr_read;
   wire                         in_write;
   reg  [ST_CHANNEL_W-1:0]      in_channel_reg;
   
   reg  [BURST_SIZE_W-1:0]      out_size_field; 
   reg  [OUT_DATA_W-1:0]        out_data_field; 
   reg  [OUT_DATA_W-1:0]        out_data_reg; 
   reg  [OUT_BYTEEN_W-1:0]      out_byteen_field;
   reg  [OUT_BYTEEN_W-1:0]      out_byteen_reg;
   reg  [ADDRESS_W-1:0]         out_address_field;
   reg  [BYTE_CNT_W-1:0]        out_byte_cnt_field;
   wire [BURST_SIZE_W-1:0]      out_burst_size_field;
   reg                          out_cmpr_read;
   reg                          out_write;

   reg [IN_DATA_W-1:0]          in_data_reg;
   reg [LOG_RATIO-1:0]          count;
   
   reg [FIRST_W-1:0]           in_first_field;
   reg [FIRST_W-1:0]           out_first_field;
   reg [MID_W-1:0]             in_mid_field;
   reg [MID_W-1:0]             out_mid_field;
   reg [LAST_W-1:0]            in_last_field;
   reg [LAST_W-1:0]            out_last_field;

   reg [LAST_W-1:0]            out_last_internal;
   reg                         in_ready_q;

   wire stage0_occupied;

   wire [ADDRESS_W-1:0] n_address_field;

   reg  [BYTE_CNT_W-1:0] overflow_byte_cnt;
   wire [LOG_RATIO-1:0]  overflow_valid_byte_cnt; 
   reg  [LOG_RATIO-1:0]  unaligned_addr_index; 

   reg  [LOG_RATIO-1:0]  overflow_valid_byte_cnt_reg; 
   reg  [LOG_RATIO-1:0]  unaligned_addr_index_reg; 
   wire [2*LOG_RATIO-1:0] transform_shamt_reg;
   reg  transform_shamt_fifo_write;

   reg [BYTE_CNT_W-1:0] n_byte_count;
   wire update_byte_count; 
   reg [LOG_RATIO-1:0] n_count;

   wire transform_shamt_fifo_ready;
   wire [2*LOG_RATIO-1:0] w2n_cmd_transform_shamt;
   wire w2n_cmd_transform_valid;
   wire n2w_rsp_valid;


   integer i;

   always @(posedge clk) begin
      internal_sclr <= reset;
   end
   
   //------------------------------------------------------------//
   //---------- Unpack incoming packet into fields --------------//
   //------------------------------------------------------------//

   assign stage0_occupied = in_valid_q && ~in_ready_q; 

   assign in_ready = ~stage0_occupied;

   always @ (posedge clk) begin
      if(in_valid && ~stage0_occupied) begin
         in_valid_q <= in_valid;
      end
      else if(in_ready_q) begin
         in_valid_q <= 1'b0;
      end
   end

   always @ (posedge clk) begin
      if(in_valid && ~stage0_occupied) begin  // ?? do we need in_valid here?
         in_data_q    <= in_data;
         in_sop_q     <= in_startofpacket;
         in_eop_q     <= in_endofpacket;
         in_channel_q <= in_channel;
      end
   end

   wire [ADDRESS_W-1:0]  in_address  = in_data[IN_PKT_ADDR_H    :IN_PKT_ADDR_L    ];
   wire [BYTE_CNT_W-1:0] in_byte_cnt = in_data[IN_PKT_BYTE_CNT_H:IN_PKT_BYTE_CNT_L];

   assign in_burst_size_field      = in_data_q[IN_PKT_BURST_SIZE_H :IN_PKT_BURST_SIZE_L ]; 
   assign in_data_field            = in_data_q[IN_PKT_DATA_H       :IN_PKT_DATA_L       ];
   assign in_byteen_field          = in_data_q[IN_PKT_BYTEEN_H     :IN_PKT_BYTEEN_L     ];
   assign in_address_field         = in_data_q[IN_PKT_ADDR_H       :IN_PKT_ADDR_L       ];
   assign in_byte_cnt_field        = in_data_q[IN_PKT_BYTE_CNT_H   :IN_PKT_BYTE_CNT_L   ];
   assign in_cmpr_read             = in_data_q[IN_PKT_TRANS_COMPRESSED_READ];
   assign in_write                 = in_data_q[IN_PKT_TRANS_WRITE];
  
   assign out_burst_size_field = LOG_OUT_NUMSYMBOLS;
 
   generate begin
      if (FIRST_EXISTS) begin
         always @* begin
            in_first_field = in_data_q[IN_FIRST_H:IN_FIRST_L];
         end
      end else begin
         always @* begin
            in_first_field = '0;
         end
      end
      if (MID_EXISTS) begin
         always @* begin
            in_mid_field = in_data_q[IN_MID_H:IN_MID_L];
         end
      end else begin
         always @* begin
            in_mid_field = '0;
         end
      end
      if (LAST_EXISTS) begin
         always @* begin
            in_last_field = in_data_q[IN_LAST_H:IN_LAST_L];
         end
      end
   end
   endgenerate

   localparam [1:0] ST_IDLE         = 2'b00,
                    ST_BUSY         = 2'b01,
                    ST_FINAL        = 2'b10;
    
   reg [1:0] state;
   reg [1:0] next_state;

   //------------------------------------------------------------//
   //---------- Control logic for inputs ------------------------//
   //------------------------------------------------------------//

   // N2W cmd adapter may receive unaligned beats wrt output.
   // In order to align the address and update the output byte count,
   // address alignment bits are used. First count value is based on the
   // address index. 
   // For updating byte count ceiling operation is performed on the input byte
   // count.
   // Starting address index and extra bytes being requested for reads need to
   // be preseved so that W2N rsp adapter can mask out appropriate data.
   // This information is preserved in a FIFO.
 
   always @ (posedge clk) begin
      if(~stage0_occupied) begin
         overflow_byte_cnt    <= in_address[ALIGNED_BITS_L:0] + in_byte_cnt;     
         unaligned_addr_index <= in_address[ALIGNED_BITS_L:LOG_IN_NUMSYMBOLS];   // Starting point for response data
      end
   end

   // Extra bytes being requsted which will be in the last response packet
   assign overflow_valid_byte_cnt = overflow_byte_cnt[LOG_OUT_NUMSYMBOLS-1:LOG_IN_NUMSYMBOLS];

   always @ (posedge clk) begin
      if(in_ready_q) begin
         overflow_valid_byte_cnt_reg <= overflow_valid_byte_cnt;
         unaligned_addr_index_reg <= unaligned_addr_index;
      end
   end

   assign transform_shamt_reg = {overflow_valid_byte_cnt_reg, unaligned_addr_index_reg};

   always @ (posedge clk) begin
      transform_shamt_fifo_write <= in_ready_q && in_valid_q && ~in_write;
   end

   // Aligned output address
   assign n_address_field = {in_address_field[ADDRESS_W-1:ALIGNED_BITS_L+1], {LOG_OUT_NUMSYMBOLS{1'b0}}};

   // Ceiling operation on byte count
   always @ (*) begin   
      n_byte_count = overflow_byte_cnt + {LOG_OUT_NUMSYMBOLS{1'b1}};
      n_byte_count[ALIGNED_BITS_L:0] = {LOG_OUT_NUMSYMBOLS{1'b0}};
   end

   // At start of packet, use input byte count.
   // Decrement byte count when one output beat has been sent.
   assign update_byte_count = out_valid && out_ready; 

   always @ (posedge clk) begin
      if(in_valid_q && in_ready_q && in_sop_q) begin
         out_byte_cnt_field <= n_byte_count;
      end
      else if(update_byte_count) begin
         out_byte_cnt_field <= out_byte_cnt_field - OUT_NUMSYMBOLS;
      end
   end

   // Counter controlling the state machine
   // Starts at the unaligned address index when sop=1; increment with each
   // valid input.
   always @ (*) begin
      if(in_valid_q & in_ready_q) begin
         if(in_sop_q) begin
            n_count = unaligned_addr_index; 
         end
         else begin
            n_count = count + 1'b1;
         end
      end
      else begin
         n_count = count;
      end
   end

   always @ (posedge clk) begin
      count <= n_count;
   end

   // Control state machine
   // Output is valid in FINAL state. 
   always @ (*) begin
      next_state = state;

      case(state)
         ST_IDLE : begin
            // Starting blank or after a gap between valid output and valid input
            if(in_valid_q && in_ready_q) begin
               if(in_eop_q || (in_sop_q && (unaligned_addr_index == (RATIO-1)))) begin
                  next_state = ST_FINAL;
               end
               else begin
                  next_state = ST_BUSY;
               end
            end
            else begin
               next_state = ST_IDLE;
            end
         end

         ST_BUSY : begin
            // Remain here till eop or counter is one below staturation
            if(in_valid_q & in_ready_q & (in_eop_q || (count == (RATIO-2)))) begin
               next_state = ST_FINAL;
            end
            else begin
               next_state = ST_BUSY;
            end
         end

         ST_FINAL : begin
            // Output state.
            // Come here for one beat input packet OR end of packet OR
            // saturated counter OR starting index is RATIO-1
            if(~out_ready) begin
               next_state = ST_FINAL;
            end
            else if(in_valid_q && in_ready_q) begin
               if(in_eop_q || (in_sop_q && (unaligned_addr_index == (RATIO-1)))) begin
                  next_state = ST_FINAL;
               end
               else begin
                  next_state = ST_BUSY;
               end
            end
            else begin
               next_state = ST_IDLE;
            end
         end
      endcase
   end

   always @ (posedge clk) begin
      if(internal_sclr) begin
         state <= ST_IDLE;
      end
      else begin
         state <= next_state;
      end
   end

   assign out_valid = (state == ST_FINAL);

   always @ (posedge clk) begin
      if(in_ready_q) begin
         in_byteen_reg <= in_byteen_field;
         in_data_reg <= in_data_field;
         in_non_burst_trans_reg <= (in_byte_cnt_field == IN_NUMSYMBOLS); // Non-Burst in terms of input
         in_byte_cnt_reg <= in_byte_cnt_field;
         in_channel_reg <= in_channel_q;
      end
   end

   // Register the previous output byte enable until we have a valid output.
   // Zero-out output byte en when output has been accepted so that there are
   // no write side effects.
   always @ (posedge clk) begin
      if(state == ST_FINAL) begin
         if(out_ready) begin
            out_byteen_reg <= {OUT_BYTEEN_W{1'b0}};
         end
         else begin
            out_byteen_reg <= out_byteen_field;
         end
      end
      else if(in_sop_q || (state == ST_IDLE)) begin
         out_byteen_reg <= {OUT_BYTEEN_W{1'b0}};
      end
      else begin
         out_byteen_reg <= out_byteen_field;
      end
   end

   // Choose where the registered byte enable goes in output byte enable based
   // on current count value. 
   always @ (*) begin
      out_byteen_field = out_byteen_reg;

      if(out_write) begin
         out_byteen_field[count*IN_BYTEEN_W +: IN_BYTEEN_W] = in_byteen_reg;   
      end
      else if(in_non_burst_trans_reg) begin
         out_byteen_field[count*IN_BYTEEN_W +: IN_BYTEEN_W] = in_byteen_reg;   // ?? Check if this works in W2N command adapter with optimization for byte enable compression.
      end
      else begin
         out_byteen_field = {OUT_BYTEEN_W{1'b1}};
      end
   end

   // Choose where the registered data goes in output data based
   // on current count value. Data need not be zeroed out because byte enable
   // will act as a mask.
   always @ (*) begin
      out_data_field = out_data_reg;
      out_data_field[count*IN_DATA_W +: IN_DATA_W] = in_data_reg;
   end

   always @ (posedge clk) begin
      out_data_reg <= out_data_field; 
   end

   assign out_channel = in_channel_reg;

   // Conservative: When FIFO with information for response adapter is almost full,
   // stop accepting new data until FIFO is not full.
   
   assign in_ready_q = (out_ready || ~out_valid) & transform_shamt_fifo_ready;

   always @ (posedge clk) begin
      if(in_ready_q) begin
         out_address_field    <= n_address_field;
      end
   end

   always @ (posedge clk) begin
      if(in_ready_q && in_sop_q) begin
         out_first_field      <= in_first_field;
         out_mid_field        <= in_mid_field;
         out_last_field       <= in_last_field;

         out_write            <= in_write;
         out_cmpr_read        <= in_cmpr_read;
      end
   end
   
   // Register the start of packet and end of packet.
   // Start of packet is updated when counter saturates.
   always @ (posedge clk) begin
      if(in_ready_q) begin
         out_endofpacket <= in_eop_q;

         if(in_sop_q || (count == (RATIO-1))) begin
            out_startofpacket <= in_sop_q;
         end
      end
   end
 
   // Prepare output data by assembling all the pieces together. 
   always @ (*) begin
       if (FIRST_EXISTS) 
         out_data[OUT_FIRST_H:OUT_FIRST_L] = out_first_field;

       if (MID_EXISTS)
         out_data[OUT_MID_H:OUT_MID_L]     = out_mid_field;

       if (LAST_EXISTS) 
         out_data[OUT_LAST_H:OUT_LAST_L]   = out_last_field;
       
       out_data[OUT_PKT_TRANS_COMPRESSED_READ] = out_cmpr_read; 
       out_data[OUT_PKT_DATA_H:OUT_PKT_DATA_L] = out_data_field;
       out_data[OUT_PKT_BYTEEN_H:OUT_PKT_BYTEEN_L] = out_byteen_field;
       out_data[OUT_PKT_BYTE_CNT_H:OUT_PKT_BYTE_CNT_L] = out_byte_cnt_field;
       out_data[OUT_PKT_BURST_SIZE_H:OUT_PKT_BURST_SIZE_L] = out_burst_size_field;
       out_data[OUT_PKT_ADDR_H:OUT_PKT_ADDR_L] = out_address_field;
   end


   // FIFO preserving data for response adapter
   // Read comes from response adapter and data goes to response adapter.
   alt_hiconnect_sc_fifo #(
       .IMPL             ("mlab"),
       .SYMBOLS_PER_BEAT (1),
       .BITS_PER_SYMBOL  (2*LOG_RATIO),
       .FIFO_DEPTH       (31),
       .CHANNEL_WIDTH    (0),
       .ERROR_WIDTH      (0),
       .USE_PACKETS      (0),
       .EMPTY_LATENCY    (3),
       .SHOWAHEAD        (0),
       .ALMOST_FULL_THRESHOLD (8)
   ) w2n_transform_shamt_fifo (
       .clk               (clk), 
       .reset             (reset),
   
       .in_data           (transform_shamt_reg),
       .in_valid          (transform_shamt_fifo_write),  // write
       .in_ready          (transform_shamt_fifo_ready),  // ~full
       .in_startofpacket  (1'b0),
       .in_endofpacket    (1'b0),
   
       .out_data          (out_cmd_shamt_data),
       .out_valid         (out_cmd_shamt_valid), // ~empty
       .out_ready         (out_cmd_shamt_ready),        // read
       .out_startofpacket ( ),
       .out_endofpacket   ( ),
                  
       .in_empty          (1'b0),
       .out_empty         ( ),
       .in_error          (1'b0),
       .out_error         ( ),
       .in_channel        (1'b0),
       .out_channel       ( )
   );

endmodule
`default_nettype wire

