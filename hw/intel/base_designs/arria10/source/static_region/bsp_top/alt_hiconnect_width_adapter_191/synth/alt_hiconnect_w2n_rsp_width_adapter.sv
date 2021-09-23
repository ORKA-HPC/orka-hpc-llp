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


// Hyperflex-Optimized Interconnect Response Width Adapter

`timescale 1 ns / 1 ns
`default_nettype none

module alt_hiconnect_w2n_rsp_width_adapter
#(
    parameter IN_PKT_ADDR_L                 = 0,
    parameter IN_PKT_ADDR_H                 = 31,
    parameter IN_PKT_DATA_L                 = 32,
    parameter IN_PKT_DATA_H                 = 63,
    parameter IN_PKT_BYTEEN_L               = 64,
    parameter IN_PKT_BYTEEN_H               = 67,
    parameter IN_PKT_TRANS_COMPRESSED_READ  = 72,
    parameter IN_PKT_BYTE_CNT_L             = 73,
    parameter IN_PKT_BYTE_CNT_H             = 77,
    parameter IN_PKT_BURSTWRAP_L            = 78,
    parameter IN_PKT_BURSTWRAP_H            = 82,
    parameter IN_PKT_BURST_SIZE_L           = 83,
    parameter IN_PKT_BURST_SIZE_H           = 85,
    parameter IN_PKT_RESPONSE_STATUS_L      = 86,
    parameter IN_PKT_RESPONSE_STATUS_H      = 87,
    parameter IN_PKT_TRANS_EXCLUSIVE        = 88,
    parameter IN_PKT_BURST_TYPE_L           = 89,
    parameter IN_PKT_BURST_TYPE_H           = 90,
    parameter IN_PKT_ORI_BURST_SIZE_L       = 91,
    parameter IN_PKT_ORI_BURST_SIZE_H       = 93,
    parameter IN_PKT_TRANS_WRITE            = 94,
    parameter IN_ST_DATA_W                  = 110,

    parameter OUT_PKT_ADDR_L                = 0,
    parameter OUT_PKT_ADDR_H                = 31,
    parameter OUT_PKT_DATA_L                = 32,
    parameter OUT_PKT_DATA_H                = 47,
    parameter OUT_PKT_BYTEEN_L              = 48,
    parameter OUT_PKT_BYTEEN_H              = 49,
    parameter OUT_PKT_TRANS_COMPRESSED_READ = 54,
    parameter OUT_PKT_BYTE_CNT_L            = 55,
    parameter OUT_PKT_BYTE_CNT_H            = 59,
    parameter OUT_PKT_BURST_SIZE_L          = 60,
    parameter OUT_PKT_BURST_SIZE_H          = 62,
    parameter OUT_PKT_RESPONSE_STATUS_L     = 63,
    parameter OUT_PKT_RESPONSE_STATUS_H     = 64,
    parameter OUT_PKT_TRANS_EXCLUSIVE       = 65,
    parameter OUT_PKT_BURST_TYPE_L          = 66,
    parameter OUT_PKT_BURST_TYPE_H          = 67,
    parameter OUT_PKT_ORI_BURST_SIZE_L      = 68,
    parameter OUT_PKT_ORI_BURST_SIZE_H      = 70,
    parameter OUT_ST_DATA_W                 = 92,

    parameter ST_CHANNEL_W                  = 32,

    // Address alignment can be omitted (an optimization) if all connected
    // masters only issue aligned addresses (think Avalon W2N).
    parameter ENABLE_ADDRESS_ALIGNMENT      = 1,
    parameter CONSTANT_BURST_SIZE           = 1,    // 1: Optimizes for Avalon-only systems as those always have full size transactions
    parameter LOG_RATIO = $clog2 ((IN_PKT_DATA_H-IN_PKT_DATA_L+1)/(OUT_PKT_DATA_H-OUT_PKT_DATA_L+1))
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

    input  wire [2*LOG_RATIO-1:0]    in_rsp_shamt_data,
    input  wire                      in_rsp_shamt_valid,
    output wire                      in_rsp_shamt_ready
);

    // For shared derived parameters, including pseudo-field parameters and helper functions
    `include "alt_hiconnect_width_adapter_utils.iv"

   localparam [1:0] ST_IDLE         = 2'b00,
                    ST_BUSY         = 2'b01,
                    ST_FINAL        = 2'b10;
   
   reg [1:0] state;
   reg [1:0] next_state;

   // Synchronous reset
   reg internal_sclr;
   
   always @(posedge clk) begin
      internal_sclr <= reset;
   end

   wire                   in_ready_q0;
   reg                    in_valid_q0;
   reg [ST_CHANNEL_W-1:0] in_channel_q0;
   reg [IN_ST_DATA_W-1:0] in_data_q0;
   reg                    in_startofpacket_q0;
   reg                    in_endofpacket_q0;
   
   wire [LOG_RATIO-1:0] cmd_last_beat_cnt;
   wire one_rsp;
   wire [LOG_RATIO-1:0] in_shamt;
   wire [LOG_RATIO-1:0] last_beat_count;
   reg  [LOG_RATIO-1:0] last_beat_count_reg;
   reg  [LOG_RATIO-1:0] in_shamt_reg;

   wire stage0_occupied;
   assign stage0_occupied = in_valid_q0 && ~in_ready_q0;
   assign in_ready = ~stage0_occupied;

   // Assert FIFO rd_en in first stage so that data is ready in q0
   assign in_rsp_shamt_ready = in_valid && in_ready && ~in_data[IN_PKT_TRANS_WRITE] && in_startofpacket; 

   assign in_shamt = in_rsp_shamt_data[LOG_RATIO-1:0];
   assign cmd_last_beat_cnt = in_rsp_shamt_data[2*LOG_RATIO-1:LOG_RATIO]-1'b1; 

   always @ (posedge clk) begin
      if(in_valid && in_ready) begin
         in_valid_q0 <= 1'b1;
      end
      else if(in_ready_q0) begin
         in_valid_q0 <= 1'b0;
      end
   end

   always @ (posedge clk) begin
      if(in_valid && in_ready) begin
         in_channel_q0        <= in_channel;
         in_data_q0           <= in_data;
         in_startofpacket_q0  <= in_startofpacket;
         in_endofpacket_q0    <= in_endofpacket;
      end
   end
   
   reg [FIRST_W-1:0] in_first_field;
   reg [FIRST_W-1:0] out_first_field_reg;
   reg [MID_W-1:0]   in_mid_field;
   reg [MID_W-1:0]   out_mid_field_reg;
   reg [LAST_W-1:0]  in_last_field;
   reg [LAST_W-1:0]  out_last_field_reg;
   
   // Populate the packet fields
   generate begin : pseudo_field_gen
       if (FIRST_EXISTS) begin
           always @* begin
               in_first_field = in_data_q0[IN_FIRST_H:IN_FIRST_L];
           end
       end else begin
           always @* begin
               in_first_field = '0;
           end
       end
       if (MID_EXISTS) begin
           always @* begin
               in_mid_field = in_data_q0[IN_MID_H:IN_MID_L];
           end
       end else begin
           always @* begin
               in_mid_field = '0;
           end
       end
       if (LAST_EXISTS) begin
           always @* begin
               in_last_field = in_data_q0[IN_LAST_H:IN_LAST_L];
           end
       end else begin
           always @* begin
               in_last_field = '0;
           end        
       end
   end
   endgenerate

   wire [IN_DATA_W-1:0]         in_data_field; 
   wire [IN_DATA_W-1:0]         in_byteen_field; 
   wire [RESPONSE_STATUS_W-1:0] in_rsp_field; 
   wire                         in_write; 
   reg  [IN_DATA_W-1:0]         in_data_reg; 
   reg  [IN_DATA_W-1:0]         in_byteen_reg; 
   reg  [RESPONSE_STATUS_W-1:0] in_rsp_reg;
   reg                          in_write_reg;
   reg                          in_sop_reg;
   reg                          in_eop_reg;
   reg [ST_CHANNEL_W-1:0]       in_channel_reg;

   assign in_rsp_field  = in_data_q0[IN_PKT_RESPONSE_STATUS_H:IN_PKT_RESPONSE_STATUS_L];
   assign in_data_field = in_data_q0[IN_PKT_DATA_H:IN_PKT_DATA_L];
   assign in_byteen_field = in_data_q0[IN_PKT_BYTEEN_H:IN_PKT_BYTEEN_L];
   assign in_write      = in_data_q0[IN_PKT_TRANS_WRITE];

   wire [OUT_DATA_W-1:0] in_data_unpacked [RATIO-1:0];
   wire [OUT_BYTEEN_W-1:0] in_byteen_unpacked [RATIO-1:0];

   genvar blk;
   generate
      for(blk=0; blk<RATIO; blk=blk+1) begin
         assign in_data_unpacked[blk] = in_data_field[blk*OUT_DATA_W +: OUT_DATA_W];
         assign in_byteen_unpacked[blk] = in_byteen_field[blk*OUT_BYTEEN_W +: OUT_BYTEEN_W];
      end
   endgenerate

   always @ (posedge clk) begin
      if(in_valid_q0 & in_ready_q0) begin
         in_data_reg  <= in_data_field;
         in_byteen_reg <= in_byteen_field;
         in_write_reg <= in_write;

         in_rsp_reg <= in_rsp_field;
         out_first_field_reg <= in_first_field;
         out_mid_field_reg   <= in_mid_field;
         out_last_field_reg  <= in_last_field;

         in_channel_reg <= in_channel_q0;
      end
   end

   assign one_rsp = in_startofpacket_q0 && in_endofpacket_q0;
   assign last_beat_count = cmd_last_beat_cnt;

   reg [LOG_RATIO-1:0] count;
   reg [LOG_RATIO-1:0] n_count;

   always @ (posedge clk) begin
      if(in_ready_q0 && in_valid_q0) begin
         last_beat_count_reg <= last_beat_count;
         in_shamt_reg <= in_shamt;
      end
   end

   always @ (*) begin
      n_count = count;
      if(in_valid_q0 && in_ready_q0) begin
         if(in_startofpacket_q0) begin
            n_count = in_shamt;
         end
         else begin
            n_count = {LOG_RATIO{1'b0}};
         end
      end
      else if(out_valid && out_ready) begin
         if(count == RATIO-1) begin
            n_count = {LOG_RATIO{1'b0}};
         end
         else begin
            n_count = count + 1'b1;
         end
      end
   end

   always @ (posedge clk) begin
      count <= n_count;
   end

   always @ (posedge clk) begin
      if(internal_sclr) begin
         state <= ST_IDLE;
      end
      else begin
         state <= next_state;
      end
   end

   always @ (*) begin
      next_state = ST_IDLE;

      case(state)
         ST_IDLE : begin
            if(in_valid_q0) begin
               if (in_write) begin
                  next_state = ST_FINAL;
               end
               else if (in_startofpacket_q0 && ((in_shamt == RATIO-1) || (in_endofpacket_q0 && (last_beat_count == in_shamt)))) begin
                  next_state = ST_FINAL;
               end
               else if (in_endofpacket_q0 && (last_beat_count == '0)) begin
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
            if(out_ready && ((in_eop_reg && (count == (last_beat_count_reg - 1'b1))) || (count == RATIO-2))) begin
               next_state = ST_FINAL;
            end
            else begin
               next_state = ST_BUSY;
            end
         end


         ST_FINAL : begin
            if(out_ready) begin
               if(in_valid_q0) begin 
                  if (in_write) begin
                     next_state = ST_FINAL;
                  end
                  else if (in_startofpacket_q0 && ((in_shamt == RATIO-1) || (in_endofpacket_q0 && (last_beat_count == in_shamt)))) begin
                     next_state = ST_FINAL;
                  end
                  else if (in_endofpacket_q0 && (last_beat_count == '0)) begin
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
            else begin
               next_state = ST_FINAL;
            end
         end
      endcase
   end

   assign in_ready_q0 = (state == ST_IDLE) || ((state == ST_FINAL) && out_ready);

   assign out_valid = (state == ST_BUSY) || (state == ST_FINAL);

   wire [OUT_DATA_W-1:0] out_data_field = in_data_reg[count*OUT_DATA_W +: OUT_DATA_W];
   wire [OUT_BYTEEN_W-1:0] out_byteen_field = in_byteen_reg[count*OUT_BYTEEN_W +: OUT_BYTEEN_W];

   always @ (posedge clk) begin
      if(in_valid_q0 && in_ready_q0) begin
         in_sop_reg <= in_startofpacket_q0;
         in_eop_reg <= in_endofpacket_q0;
      end
      else if(out_ready) begin
         in_sop_reg <= 1'b0;
      end
   end

   assign out_startofpacket = in_sop_reg;
   assign out_endofpacket = in_eop_reg && (state == ST_FINAL);

   always @ (*) begin
      if(FIRST_EXISTS)
          out_data[OUT_FIRST_H:OUT_FIRST_L] = out_first_field_reg;

      if(MID_EXISTS)
          out_data[OUT_MID_H:OUT_MID_L] = out_mid_field_reg;

      if(LAST_EXISTS)
          out_data[OUT_LAST_H:OUT_LAST_L] = out_last_field_reg;

      out_data[OUT_PKT_DATA_H:OUT_PKT_DATA_L] = out_data_field;
      out_data[OUT_PKT_BYTEEN_H:OUT_PKT_BYTEEN_L] = out_byteen_field;
      out_data[OUT_PKT_RESPONSE_STATUS_H:OUT_PKT_RESPONSE_STATUS_L] = in_rsp_reg;
   end

   assign out_channel = in_channel_reg;

endmodule

`default_nettype wire

