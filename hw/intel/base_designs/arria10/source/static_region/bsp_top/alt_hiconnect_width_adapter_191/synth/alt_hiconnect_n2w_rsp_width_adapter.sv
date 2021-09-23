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

module alt_hiconnect_n2w_rsp_width_adapter
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
    parameter CONSTANT_BURST_SIZE           = 1,     // 1: Optimizes for Avalon-only systems as those always have full size transactions

    parameter LOG_RATIO = $clog2 ((OUT_PKT_DATA_H-OUT_PKT_DATA_L+1)/(IN_PKT_DATA_H-IN_PKT_DATA_L+1))
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
    output reg [ST_CHANNEL_W-1:0]    out_channel,
    output reg [OUT_ST_DATA_W-1:0]   out_data,
    output reg                       out_startofpacket,
    output reg                       out_endofpacket,

    input      [LOG_RATIO-1:0]       in_rsp_shamt_data,
    input                            in_rsp_shamt_valid,
    output                           in_rsp_shamt_ready  
);

    // For shared derived parameters, including pseudo-field parameters and helper functions
    `include "alt_hiconnect_width_adapter_utils.iv"

    // Synchronous reset
    reg internal_sclr;
   
    always @(posedge clk) begin
       internal_sclr <= reset;
    end
    
    reg [FIRST_W-1:0]           in_first_field;
    reg [FIRST_W-1:0]           out_first_field;
    reg [MID_W-1:0]             in_mid_field;
    reg [MID_W-1:0]             out_mid_field;
    reg [LAST_W-1:0]            in_last_field;
    reg [LAST_W-1:0]            out_last_field;
    
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
    
    wire in_cmpr_read = in_data[IN_PKT_TRANS_COMPRESSED_READ];
    wire in_write     = in_data[IN_PKT_TRANS_WRITE];
    wire in_read      = !in_write;
    reg new_read_rsp_q;

    reg [IN_DATA_W-1:0] output_data_sr [RATIO-1:0];
    reg [IN_BYTEEN_W-1:0] output_byteen_sr [RATIO-1:0];
    reg [clogb2(RATIO):0] shift_count;
    reg [clogb2(RATIO):0] n_shift_count;
    reg [RESPONSE_STATUS_W-1:0] merged_rsp;
    reg in_sop_reg;
    reg in_eop_reg;
    
    // Control signals
    wire pass_thru = '0; // appropriate when there's no AXI
    wire new_read_rsp = in_valid && in_ready && in_read;
    
    // Input packet fields
    wire [IN_DATA_W-1:0] in_pkt_data = in_data[IN_PKT_DATA_H:IN_PKT_DATA_L];
    wire [RESPONSE_STATUS_W-1:0] in_pkt_rsp = in_data[IN_PKT_RESPONSE_STATUS_H:IN_PKT_RESPONSE_STATUS_L];

    wire [IN_BYTEEN_W-1:0] in_pkt_byteen = in_data[IN_PKT_BYTEEN_H:IN_PKT_BYTEEN_L];
    
    // Output packet fields
    wire [OUT_DATA_W-1:0] out_pkt_data;
    wire [OUT_NUMSYMBOLS-1:0] out_pkt_byteen;
    wire [RESPONSE_STATUS_W-1:0] out_pkt_rsp;
   
    genvar i;

    assign in_rsp_shamt_ready = new_read_rsp && in_startofpacket; 
 
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
                if(in_valid) begin
                    next_state = (in_read && !pass_thru && ~in_endofpacket) ? ST_BUSY : ST_FINAL_BUSY;
                end else begin
                    next_state = ST_IDLE;
                end
            end
            
            ST_BUSY : begin
                next_state = (((n_shift_count == (RATIO-1)) | in_endofpacket) & in_valid) ? ST_FINAL_BUSY : ST_BUSY;
            end
            
            ST_FINAL_BUSY : begin
                if(out_ready) begin
                    if(in_valid) begin
                        next_state = (in_read && !pass_thru && ~in_endofpacket) ? ST_BUSY : ST_FINAL_BUSY;
                    end 
                    else begin 
                        next_state = ST_IDLE;
                    end
                end else begin
                    next_state = ST_FINAL_BUSY;
                end
            end
            
            default : begin
                next_state = ST_IDLE;
            end
        endcase
    end
   
    // N2W shift counter
    always @ (*) begin
       n_shift_count = shift_count;

       if(new_read_rsp) begin
          if ((state == ST_IDLE) || (state == ST_FINAL_BUSY)) begin
            n_shift_count = '0;
          end
          else begin      
             n_shift_count = shift_count + 1'b1;
          end
       end
    end

    always @ (posedge clk) begin
       shift_count <= n_shift_count;
    end
 
    // N2W output shift register
    always @(posedge clk) begin
        if(in_ready & in_valid) begin // Minimize this term as much as possible -- i.e. shifting when we don't have to, but it won't hurt will be faster
            output_data_sr[n_shift_count] <= in_pkt_data; 
        end
    end


    // ?? Do we really need byteen in response path?
    always @(posedge clk) begin
       if(in_ready & in_valid) begin // Minimize this term as much as possible -- i.e. shifting when we don't have to, but it won't hurt will be faster
           output_byteen_sr[n_shift_count] <= in_pkt_byteen;
       end
    end
    
    // Read response merging
    always @(posedge clk) begin
        if(in_ready && in_valid) begin
            if(state == ST_BUSY) begin
                merged_rsp <= (in_pkt_rsp > merged_rsp) ? in_pkt_rsp : merged_rsp;
            end else begin
                merged_rsp <= in_pkt_rsp;
            end
        end
    end
    
    // Flow control
    assign out_valid = (state == ST_FINAL_BUSY); 
    
    // The only time we can't accept new data is on the final shift if the output
    // isn't ready -- we don't want to blast the wide packet we just assembled!
    always @ (*) begin
        in_ready = !((state == ST_FINAL_BUSY) && !out_ready);
    end
    
    // Input packet field storage
    always @ (posedge clk) begin
        if(in_startofpacket && in_valid && (out_ready || state == ST_IDLE)) begin
            out_first_field <= in_first_field;
            out_mid_field <= in_mid_field;
            out_last_field <= in_last_field;
        end
    end
    
    // SOP, EOP Packet signals
    always @ (posedge clk) begin
        if(in_startofpacket && in_valid && (out_ready || state == ST_IDLE)) begin
            in_sop_reg <= 1'b1;
        end else if ((state == ST_FINAL_BUSY) && out_ready) begin
            in_sop_reg <= 1'b0;
        end
    end
    
    always @(posedge clk) begin
        if(in_ready && in_valid) begin
            in_eop_reg <= in_endofpacket;
        end
    end
    
    generate 
      for(i=0; i < RATIO; i = i + 1) begin : pack_out_data
         assign out_pkt_data[(i+1)*IN_DATA_W-1:i*IN_DATA_W] = output_data_sr[i]; // Data is unused in the response network for writes
         assign out_pkt_byteen[(i+1)*IN_BYTEEN_W-1:i*IN_BYTEEN_W] = output_byteen_sr[i];
      end
    endgenerate

    //assign out_pkt_byteen = '0;           // For now we're assuming byteen is unused in the response network 
    assign out_pkt_rsp = merged_rsp;
   
    // Assign the output fields
    always @ (*) begin
        if (FIRST_EXISTS)
            out_data[OUT_FIRST_H:OUT_FIRST_L] = out_first_field;
        if (MID_EXISTS)
            out_data[OUT_MID_H:OUT_MID_L]     = out_mid_field;
        if (LAST_EXISTS)
            out_data[OUT_LAST_H:OUT_LAST_L]   = out_last_field;
        
        out_data[OUT_PKT_DATA_H:OUT_PKT_DATA_L] = out_pkt_data << ({{(OUT_DATA_W-IN_DATA_W){1'b0}}, in_rsp_shamt_data} << $clog2(IN_DATA_W));
        out_data[OUT_PKT_BYTEEN_H:OUT_PKT_BYTEEN_L] = out_pkt_byteen << ({{(OUT_BYTEEN_W-IN_BYTEEN_W){1'b0}}, in_rsp_shamt_data} << $clog2(IN_BYTEEN_W));
        out_data[OUT_PKT_RESPONSE_STATUS_H:OUT_PKT_RESPONSE_STATUS_L] = out_pkt_rsp;
    end
    
    assign out_startofpacket = in_sop_reg;
    assign out_endofpacket = in_eop_reg;

    always @ (posedge clk) begin
        if(internal_sclr) begin
             out_channel <= {ST_CHANNEL_W{1'b0}}; 
        end
        else if(in_ready && in_valid) begin
             out_channel <= in_channel;
        end
    end

endmodule
