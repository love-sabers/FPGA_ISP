`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/13 18:23:06
// Design Name: 
// Module Name: RAW2RGB_TOP_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RAW2RGB_TOP_tb;
    reg Clk;
    reg Rst_n;
    wire [15:0] TFT_Data;
    wire Disp_HS;
	wire Disp_VS;
    wire Disp_PCLK;
    wire Disp_DE;

    initial Clk = 1;
	always#10 Clk = ~Clk;
	
	initial begin
		Rst_n = 0;
//		DoutReq = 0;
		#201;
		Rst_n = 1;
		#20000000;
		$stop;
	end
endmodule
