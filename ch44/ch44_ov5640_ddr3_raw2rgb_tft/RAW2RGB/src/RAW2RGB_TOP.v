`timescale 1ns/1ns

module RAW2RGB_TOP(
    input clk,
    input rst_n,
    output Disp_HS,
	output Disp_VS,
    output Disp_PCLK,
    output Disp_DE,
    output [15:0] TFT_Data
);

	reg Clk;
	reg Rst_n;
	wire DinReq;
	wire [7:0]RAW_Data;
	
	wire [11:0]H_Addr;
	wire [11:0]V_Addr;
	wire      DataReq;
	wire [7:0] Disp_Red;
	wire [7:0] Disp_Green;
	wire [7:0] Disp_Blue;
	
	reg DoutReq;	
	wire [7:0]RED;
	wire [7:0]GREEN;
	wire [7:0]BLUE;
	
	wire [15:0]data;

	RAW2RGB RAW2RGB(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.DinReq(DinReq),
		.RAW_Data(RAW_Data),
		.Xaddr(H_Addr[0]),
		.Yaddr(V_Addr[0]),
		.RED(RED),
		.GREEN(GREEN),
		.BLUE(BLUE),
		.DoutReq(DataReq)
	);
	
	disp_driver disp_driver(
		.ClkDisp(Clk),
		.Rst_n(Rst_n),
		.Data({RED,GREEN,BLUE}),
		.DataReq(DataReq),
		.H_Addr(H_Addr),
		.V_Addr(V_Addr),
		.Disp_HS(Disp_HS),
		.Disp_VS(Disp_VS),
		.Disp_Red(Disp_Red),
		.Disp_Green(Disp_Green),
		.Disp_Blue(Disp_Blue),
		.Disp_DE(Disp_DE),
		.Disp_PCLK(Disp_PCLK)
	);
	
	reg flag;
	always@(posedge Clk)
	if(DinReq)
		flag <= #1 ~flag;
	else
		flag <= 0;
		
	assign data = V_Addr[0]?16'h00f7:16'h7f00;
	
	assign RAW_Data = DinReq?flag?data[7:0]:data[15:8]:0;
	assign TFT_Data = {Disp_Red[7:3],Disp_Green[7:2],Disp_Blue[7:3]};
		
endmodule
