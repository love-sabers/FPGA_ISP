`timescale 1ns/1ns

module RAW2RGB_tb;

	reg Clk;
	reg Rst_n;
	wire DinReq;
	wire [7:0]RAW_Data;
	
	wire [11:0]H_Addr;
	wire [11:0]V_Addr;
	
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

	initial Clk = 1;
	always#10 Clk = ~Clk;
	
	initial begin
		Rst_n = 0;
		DoutReq = 0;
		
		#201;
		Rst_n = 1;
		#20000000;
		$stop;
	end
	
	reg flag;
	always@(posedge Clk)
	if(DinReq)
		flag <= #1 ~flag;
	else
		flag <= 0;
		
	assign data = V_Addr[0]?16'h00f7:16'h7f00;
	
	assign RAW_Data = DinReq?flag?data[7:0]:data[15:8]:0;
		
endmodule
