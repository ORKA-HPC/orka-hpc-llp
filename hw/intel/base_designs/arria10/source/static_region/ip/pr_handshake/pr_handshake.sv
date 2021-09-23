
module pr_handshake
(
   input wire         clk , 
   input wire         rst , 

   input wire           pr_handshake_start_req ,
   output reg           pr_handshake_start_ack ,
   input wire           pr_handshake_stop_req ,
   output reg           pr_handshake_stop_ack
);

   always_ff @(posedge clk) begin
         pr_handshake_start_ack <=1'b0;
         pr_handshake_stop_ack <=1'b0;
         if (  pr_handshake_start_req == 1'b0 ) begin
            pr_handshake_start_ack <= 1'b1;
         end
         // Active high SW reset
         if (  pr_handshake_stop_req == 1'b1 ) begin
            pr_handshake_stop_ack <=1'b1;
         end
   end
   
endmodule
