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

module alt_hiconnect_w2n_cmd_width_adapter
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

  parameter LOG_RATIO = $clog2((IN_PKT_DATA_H-IN_PKT_DATA_L+1)/(OUT_PKT_DATA_H-OUT_PKT_DATA_L+1))
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
  output     [ST_CHANNEL_W-1:0]    out_channel,
  output reg [OUT_ST_DATA_W-1:0]   out_data,
  output reg                       out_startofpacket,
  output reg                       out_endofpacket,

  output reg [LOG_RATIO-1:0]       out_cmd_shamt_data,
  output reg                       out_cmd_shamt_valid, // ~empty
  input                            out_cmd_shamt_ready  // read
);

  // For shared derived parameters, including pseudo-field parameters and helper functions
    `include "alt_hiconnect_width_adapter_utils.iv"

    // Synchronous reset
    reg internal_sclr;
   
    always @(posedge clk) begin
       internal_sclr <= reset;
    end

    wire [IN_DATA_W-1:0]   in_data_field       = in_data[IN_PKT_DATA_H:IN_PKT_DATA_L]; 
    wire [ADDRESS_W-1:0]   in_adrs_field       = in_data[IN_PKT_ADDR_H:IN_PKT_ADDR_L];
    wire [IN_BYTEEN_W-1:0] in_byteen_field     = in_data[IN_PKT_BYTEEN_H:IN_PKT_BYTEEN_L]; 
    wire [BYTE_CNT_W-1:0]  in_byte_cnt_field   = in_data[IN_PKT_BYTE_CNT_H:IN_PKT_BYTE_CNT_L];

    wire in_compr_read = in_data[IN_PKT_TRANS_COMPRESSED_READ];
    wire in_write      = in_data[IN_PKT_TRANS_WRITE];

    reg [IN_DATA_W-1:0]   in_data_field_q; 
    reg [ADDRESS_W-1:0]   in_adrs_field_q; 
    reg [IN_BYTEEN_W-1:0] in_byteen_field_q;
    reg [BYTE_CNT_W-1:0]  in_byte_cnt_field_q; 

    reg in_compr_read_q; 
    reg in_write_q;
    reg in_startofpacket_q;
    reg in_endofpacket_q;
    reg in_valid_q;
    
    reg [FIRST_W-1:0]         in_first_field_q;
    reg [MID_W-1:0]           in_mid_field_q;
    reg [LAST_W-1:0]          in_last_field_q;

    reg [FIRST_W-1:0]         in_first_field;
    reg [MID_W-1:0]           in_mid_field;
    reg [LAST_W-1:0]          in_last_field;

    reg [FIRST_W-1:0]         out_first_field;
    reg [MID_W-1:0]           out_mid_field;
    reg [LAST_W-1:0]          out_last_field;

    reg [IN_DATA_W-1:0]       in_data_reg;
    reg [IN_NUMSYMBOLS-1:0]   in_byteen_reg;
    reg [OUT_BYTE_CNT_W-1:0]  in_byte_cnt_reg;
    reg [ADDRESS_W-1:0]       in_addr_reg;
    reg [ADDRESS_W-1:0]       n_addr_reg;
    reg                       in_compr_read_reg; 
    reg                       in_eop_reg;
    reg                       in_sop_reg;

    reg [ADDRESS_W-1:0]       in_adrs_field_tx;
    reg [IN_BYTEEN_W-1:0]     in_byteen_field_tx;
    reg [BYTE_CNT_W-1:0]      in_byte_cnt_tx;
    
    // Output fields
    wire [OUT_DATA_W-1:0]     out_pkt_data;
    wire [OUT_BYTEEN_W-1:0]   out_pkt_byteen;
    wire [OUT_BYTE_CNT_W-1:0] out_pkt_byte_cnt;
    wire [BURST_SIZE_W-1:0]   out_pkt_burst_size;
    wire [ADDRESS_W-1:0]      out_pkt_addr;
    wire                      out_pkt_compr_read;

    wire                      in_ready_q;
    wire                      transform_shamt_fifo_write;
    wire [LOG_RATIO-1:0]      transform_shamt_data;

    reg [ST_CHANNEL_W-1:0]    in_channel_q;
    reg [ST_CHANNEL_W-1:0]    in_channel_reg;

    // Populate the packet fields
    generate begin : pseudo_field_gen
        if (FIRST_EXISTS) begin
            always @* begin
                in_first_field = in_data[IN_FIRST_H:IN_FIRST_L];
            end
        end else begin
            always @* begin
                in_first_field = '0;
            end
        end
        if (MID_EXISTS) begin
            always @* begin
                in_mid_field = in_data[IN_MID_H:IN_MID_L];
            end
        end else begin
            always @* begin
                in_mid_field = '0;
            end
        end
        if (LAST_EXISTS) begin
            always @* begin
                in_last_field = in_data[IN_LAST_H:IN_LAST_L];
            end
        end else begin
            always @* begin
                in_last_field = '0;
            end        
        end
    end
    endgenerate

    // Registers
    reg [clogb2(RATIO):0] shift_count;
    
    // Control signals
    wire pass_thru = (in_data[IN_PKT_BURST_SIZE_H:IN_PKT_BURST_SIZE_L] <= LOG_OUT_NUMSYMBOLS);
    reg pass_thru_q;
    wire nz_count = shift_count > '0;
    wire gt_one_count = shift_count > 1;
    wire shift_count_eq_2 = shift_count == 2;
    
    integer i;

   // --------------------------------------------------
   // Byte Enable Transformation
   // --------------------------------------------------

   wire [RATIO-1:0]     block_en;
   reg  [LOG_RATIO:0]   block_en_count;
   reg  [LOG_RATIO:0]   block_en_count_q;
   reg [BYTE_CNT_W-1:0] byte_en_count;
   wire transform_reqd = (in_byte_cnt_field == IN_BYTEEN_W) && ~in_write;
   wire transform_shamt_fifo_ready;

   wire tx_occupied = (in_valid_q && ~in_ready_q);
   assign in_ready = ~tx_occupied; 

   // ?? Divide and conquer : Optimize the logic if OUT_BYTEEN_W > 4
	genvar blk;

	generate 
		for(blk = 0; blk < RATIO; blk = blk + 1) begin: gen_block_0
			assign block_en[blk] = |in_byteen_field[(blk+1)*OUT_NUMSYMBOLS-1:blk*OUT_NUMSYMBOLS];
		end	
	endgenerate

	always @ (*) begin
		block_en_count = {LOG_RATIO{1'b0}};
		for(i=0; i < RATIO; i = i + 1) begin
			block_en_count = block_en_count + block_en[i];
		end
	end

   assign byte_en_count = block_en_count << LOG_OUT_NUMSYMBOLS;

   reg [IN_DATA_W-1:0] transform_shamt;
   reg [LOG_RATIO-1:0] transform_shamt_q;

	always @ (*) begin
      transform_shamt = 0;
		for(i = RATIO-1; i >= 0; i = i - 1) begin
			if((block_en[i] == 1'b1) && transform_reqd) begin
            transform_shamt = i;
			end
		end
	end

   always @ (*) begin
      in_adrs_field_tx    = in_adrs_field;
      in_byteen_field_tx  = in_byteen_field;
      in_byte_cnt_tx      = in_byte_cnt_field;

      if(transform_reqd) begin
         in_adrs_field_tx[LOG_IN_NUMSYMBOLS-1:0]  = (transform_shamt << LOG_OUT_NUMSYMBOLS);
         in_byteen_field_tx  = in_byteen_field >> (transform_shamt << LOG_OUT_NUMSYMBOLS);
         in_byte_cnt_tx      = byte_en_count;
      end
   end

   always @ (posedge clk) begin
      if(in_valid & ~tx_occupied) begin
         in_valid_q <= in_valid;
      end
      else if(in_ready_q) begin // from w2n
         in_valid_q <= 1'b0;
      end
   end

   always @ (posedge clk) begin
      if(in_valid & ~tx_occupied) begin
         in_adrs_field_q     <= in_adrs_field_tx;
         in_byteen_field_q   <= in_byteen_field_tx;
         in_byte_cnt_field_q <= in_byte_cnt_tx;

         in_data_field_q     <= in_data_field;
         in_write_q          <= in_write;
         in_compr_read_q     <= in_compr_read;
         in_startofpacket_q  <= in_startofpacket;
         in_endofpacket_q    <= in_endofpacket;

         in_first_field_q    <= in_first_field;
         in_mid_field_q      <= in_mid_field;
         in_last_field_q     <= in_last_field;

         transform_shamt_q   <= transform_shamt[LOG_RATIO-1:0];
         pass_thru_q         <= pass_thru;

         in_channel_q        <= in_channel;
         block_en_count_q    <= block_en_count;
      end
   end

   assign transform_shamt_fifo_write = in_valid_q && in_ready_q && ~in_write_q;
   assign transform_shamt_data = transform_shamt_q[LOG_RATIO-1:0]; 
    
    // ---------------------------------------------------
    // State definitions
    // ---------------------------------------------------
    typedef enum bit [1:0] {
        ST_IDLE         = 2'b00,
        ST_BUSY         = 2'b01,
        ST_FINAL_BUSY   = 2'b10
    } t_state;
    
    t_state state;
    t_state next_state;
    
    always_ff @(posedge clk) begin
        if(internal_sclr) begin
            state <= ST_IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    always_comb begin
        case(state)
            ST_IDLE : begin
                if(in_valid_q & in_ready_q) begin
                    next_state = (in_write_q && !pass_thru_q) ? ST_BUSY : ST_FINAL_BUSY;                
                end else begin
                    next_state = ST_IDLE;
                end
            end
            
            ST_BUSY : begin
                next_state = (shift_count_eq_2 && out_ready) ? ST_FINAL_BUSY : ST_BUSY;
            end
            
            ST_FINAL_BUSY : begin
                if(~out_ready) begin
                    next_state = ST_FINAL_BUSY;
                end
                else if(in_valid_q & in_ready_q) begin
                    next_state = (in_write_q && out_ready && !pass_thru_q) ? ST_BUSY : ST_FINAL_BUSY;
                end
                else begin
                    next_state = ST_IDLE;
                end
            end
            
            default : begin
                next_state = ST_IDLE;
            end
        endcase
    end
    
         
    // W2N shift counter
    always @(posedge clk) begin
        if(internal_sclr) begin
            shift_count <= '0;
        end
        else begin
            // Start a new W2N shift when we accept a write with burstsize > output width
            if(in_ready_q && in_valid_q && in_write_q && !pass_thru_q) begin
                shift_count <= RATIO;
            end else if (nz_count && out_ready) begin      
                // Decrement the count when we're not going to underflow, and the output isn't backpressuring
                shift_count <= shift_count - 1'b1;
            end
        end
    end
    
    // W2N data and byteenable shift registers
    always @(posedge clk) begin
      if(gt_one_count & out_ready) begin
          in_data_reg <= in_data_reg >> OUT_DATA_W;
          in_byteen_reg <= in_byteen_reg >> OUT_BYTEEN_W;
      end 
      else if(in_valid_q & in_ready_q) begin
          in_data_reg <= in_data_field_q;
          if(~in_write_q && (block_en_count_q > 1)) begin
             in_byteen_reg <= {IN_NUMSYMBOLS{1'b1}};
          end
          else begin
             in_byteen_reg <= in_byteen_field_q;
          end
      end
    end

    // Flow control
    assign in_ready_q = in_write_q ? ((state == ST_IDLE) || ((state == ST_FINAL_BUSY) && out_ready)) 
                                   : transform_shamt_fifo_ready & ((state == ST_IDLE) || ((state == ST_FINAL_BUSY) && out_ready));
    
    // Output is valid if we are midway through downsizing a write, we have accepted a new write or read on the last cycle
    // of downsizing a write, or if we receive a new read or write whilst idle.
    assign out_valid = (state == ST_BUSY) || (state == ST_FINAL_BUSY); // Busy downsizing or just accepted a wide datum
    
    // Input packet field storage
    always @(posedge clk) begin
        // We only want to register the input when:
        //    a) Data is valid.
        //    b) We aren't halfway through an uncompressed transaction -- 'gt_one_count' term.
        //    c) The output is ready OR we are in the ST_IDLE state -- this means the adapter
        //       is available to start processing a new input packet.
        if(!gt_one_count && in_valid_q && (out_ready || state == ST_IDLE)) begin // This samples every wide word in an uncompressed burst, we should be able to look @ EOP and
            in_compr_read_reg <= ~in_write_q;

            out_first_field <= in_first_field_q;
            out_mid_field <= in_mid_field_q;
            out_last_field <= in_last_field_q;
        end
    end

    always @ (*) begin
       n_addr_reg = in_addr_reg;
       n_addr_reg[LOG_IN_NUMSYMBOLS:LOG_OUT_NUMSYMBOLS] = in_addr_reg[LOG_IN_NUMSYMBOLS-1:LOG_OUT_NUMSYMBOLS] + 1'b1;
    end


    always @ (posedge clk) begin
       if(in_ready_q) begin
          in_byte_cnt_reg <= in_byte_cnt_field_q; 
          in_addr_reg     <= in_adrs_field_q;
       end
       else if(out_valid && out_ready) begin
          in_byte_cnt_reg <= in_byte_cnt_reg - OUT_NUMSYMBOLS;
          in_addr_reg     <= {in_addr_reg[ADDRESS_W-1:LOG_IN_NUMSYMBOLS], n_addr_reg[LOG_IN_NUMSYMBOLS-1:LOG_OUT_NUMSYMBOLS], {LOG_OUT_NUMSYMBOLS{1'b0}}};
       end
    end
    
    // SOP, EOP Packet signals
    always @(posedge clk) begin
       // Sample the packet signals with the same criterion as the data fields
       if(!gt_one_count && in_valid_q && (out_ready || state == ST_IDLE)) begin
           in_eop_reg <= in_endofpacket_q;
           in_sop_reg <= in_startofpacket_q;
       end else begin
           // Only deassert SOP once it has been accepted.
           if(out_ready) begin
               in_sop_reg <= 1'b0;
           end
       end
    end

    always @ (posedge clk) begin
       if(in_ready_q) begin
           in_channel_reg <= in_channel_q;
       end
    end
    
    assign out_channel = in_channel_reg;
    
    // We only want the registered copy when we're not in pass-through and not processing the first narrow beat
    assign out_pkt_data = in_data_reg[OUT_DATA_W-1:0];
    assign out_pkt_byteen = in_byteen_reg[OUT_BYTEEN_W-1:0];
    assign out_pkt_addr = in_addr_reg;
    assign out_pkt_compr_read = in_compr_read_reg;
    
    // Byte count stays the same -- burstcount at the slave is increased
    assign out_pkt_byte_cnt = in_byte_cnt_reg;
    
    // For systems with no narrow transfers this is correct.  Later on for AXI this will need to be enhanced.
    assign out_pkt_burst_size = LOG_OUT_NUMSYMBOLS;
     
    // Assign the output fields
    always @ (*) begin
        if (FIRST_EXISTS)
            out_data[OUT_FIRST_H:OUT_FIRST_L] = out_first_field;
        if (MID_EXISTS)
            out_data[OUT_MID_H:OUT_MID_L]     = out_mid_field;
        if (LAST_EXISTS)
            out_data[OUT_LAST_H:OUT_LAST_L]   = out_last_field;
        
        out_data[OUT_PKT_TRANS_COMPRESSED_READ] = out_pkt_compr_read; 
        out_data[OUT_PKT_DATA_H:OUT_PKT_DATA_L] = out_pkt_data;
        out_data[OUT_PKT_BYTEEN_H:OUT_PKT_BYTEEN_L] = out_pkt_byteen;
        out_data[OUT_PKT_BYTE_CNT_H:OUT_PKT_BYTE_CNT_L] = out_pkt_byte_cnt;
        out_data[OUT_PKT_BURST_SIZE_H:OUT_PKT_BURST_SIZE_L] = out_pkt_burst_size;
        out_data[OUT_PKT_ADDR_H:OUT_PKT_ADDR_L] = out_pkt_addr;
    end
    
    assign out_startofpacket = in_sop_reg;
    assign out_endofpacket = (state == ST_FINAL_BUSY) && in_eop_reg;
  
    alt_hiconnect_sc_fifo #(
        .IMPL             ("mlab"),
        .SYMBOLS_PER_BEAT (1),
        .BITS_PER_SYMBOL  (LOG_RATIO),
        .FIFO_DEPTH       (31),
        .CHANNEL_WIDTH    (0),
        .ERROR_WIDTH      (0),
        .USE_PACKETS      (0),
        .EMPTY_LATENCY    (3),
        .SHOWAHEAD        (0),
        .ALMOST_FULL_THRESHOLD (24)
    ) w2n_transform_shamt_fifo (
        .clk               (clk), 
        .reset             (reset),

        .in_data           (transform_shamt_data),
        .in_valid          (transform_shamt_fifo_write), // write
        .in_ready          (transform_shamt_fifo_ready), // ~full
        .in_startofpacket  (1'b0),
        .in_endofpacket    (1'b0),

        .out_data          (out_cmd_shamt_data),
        .out_valid         (out_cmd_shamt_valid), // ~empty
        .out_ready         (out_cmd_shamt_ready), // read
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
