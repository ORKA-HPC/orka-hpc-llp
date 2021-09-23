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
module alt_pr_bitstream_compatibility_checker_v2(
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
    o_pr_pof_id,
    o_bitstream_incompatible
);

    parameter CDRATIO = 1;
    parameter CB_DATA_WIDTH = 16;
    parameter PR_INTERNAL_HOST = 1;
    parameter EXT_HOST_PRPOF_ID = 32'hFFFFFFFF; //4294967295

    localparam [1:0]	IDLE = 0,
                        WAIT_FOR_READY = 1,
                        CHECK_START = 2,
                        CHECK_COMPLETE = 3;

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

    output [31:0] o_pr_pof_id;
    output o_bitstream_incompatible;

    reg [7:0] data_count;
    reg [1:0] check_state;
    reg bitstream_incompatible_reg;

    wire [31:0] prpof_id_holder;

    generate
        if (PR_INTERNAL_HOST == 1) begin
            (* preserve, altera_attribute = "-name PRPOF_ID on; -name ADV_NETLIST_OPT_DONT_TOUCH on" *) reg [31:0] prpof_id_reg;

            always @(posedge clk) begin
                prpof_id_reg <= {32{1'b1}};
               // synthesis translate_off
               // In simulation use a constant DEADBEEF
               prpof_id_reg <= 32'hDEAD_BEEF;
               // synthesis translate_on
            end
            assign prpof_id_holder = prpof_id_reg; 
        end
        else
            assign prpof_id_holder = EXT_HOST_PRPOF_ID;       
    endgenerate
    
    assign o_pr_pof_id = prpof_id_holder;

    assign o_bitstream_incompatible = bitstream_incompatible_reg;

    always @(posedge clk) begin
        if (~nreset)
            check_state <= IDLE;
        else begin
            case (check_state)
                IDLE: 
                    begin
                        data_count <= 8'd0;
                        bitstream_incompatible_reg <= 1'b0;

                        if (freeze)
                            check_state <= WAIT_FOR_READY;
                    end

                WAIT_FOR_READY: 
                    begin
                        if (~freeze)
                            check_state <= IDLE;
                        else if (pr_ready)
                            check_state <= CHECK_START;
                    end

                CHECK_START: 
                    begin
                        if (~freeze || ~pr_ready || crc_error || pr_error || pr_done)
                            check_state <= CHECK_COMPLETE;
                        else if (data_count == 8'd71) begin     // use for 32
                            if (data_valid && data_ready) begin
                                if (CB_DATA_WIDTH == 32) begin
                                    if (data[31:0] != prpof_id_holder[31:0])
                                        bitstream_incompatible_reg <= 1'b1;
                                    
                                    check_state <= CHECK_COMPLETE;
                                end
                                else
                                    data_count <= data_count + 8'd1;
                            end
                        end
                        else if (data_count == 8'd142) begin    // use for 16
                            if (data_valid && data_ready) begin
                                if (data[15:0] != prpof_id_holder[15:0]) begin
                                    bitstream_incompatible_reg <= 1'b1;
                                    check_state <= CHECK_COMPLETE;
                                end
                                else
                                    data_count <= data_count + 8'd1;
                            end
                        end
                        else if (data_count == 8'd143) begin    // use for 16
                            if (data_valid && data_ready) begin
                                if (data[15:0] != prpof_id_holder[31:16])
                                    bitstream_incompatible_reg <= 1'b1;
                                    
                                check_state <= CHECK_COMPLETE;
                            end
                        end
                        else if (data_valid && data_ready)
                                data_count <= data_count + 8'd1;
                    end

                CHECK_COMPLETE: 
                    begin
                        if (~freeze)
                            check_state <= IDLE;
                    end

                default: 
                    begin
                        check_state <= IDLE;
                    end
            endcase
        end
    end

endmodule

