module Reset_Sync (
 input clk,
 input ext_reset,
 output reset_n
);

 reg [3:0] reset_cnt = 0;
 
 always @(posedge clk or negedge ext_reset) begin
     if (~ext_reset)
         reset_cnt <= 4'b0;
     else
         reset_cnt <= reset_cnt + !reset_n;
 end
 
 assign reset_n = &reset_cnt;

endmodule