`timescale 1ns/1ns

module RAW2RGB(
	Clk,
	Rst_n,
	DinReq,
	RAW_Data,
	
	Xaddr,
	Yaddr,
	
	RED,
	GREEN,
	BLUE,
	DoutReq
);

	input Clk;
	input Rst_n;
	output DinReq;
	input [7:0]RAW_Data;
	
	input Xaddr;
	input Yaddr;
	
	input DoutReq;	
	output reg[7:0]RED;
	output [7:0]GREEN;
	output reg[7:0]BLUE;
	
	wire [7:0]RAW_Data_s;
	
	reg [8:0]GREEN_r;
	assign GREEN = GREEN_r[8:1];
	assign DinReq = DoutReq;

   wire clk_ce;
   DCE DCE(
    .CLKIN(Clk),
    .CE(DinReq),
    .CLKOUT(clk_ce)
   );
	
	c_shift_ram_0 c_shift_ram_0(
		.clk(clk_ce), //input clk
		.Reset(~Rst_n), //input Reset
		.Din(RAW_Data), //input [7:0] Din
		.SCLR(~Rst_n), //input SCLR
		.Q(RAW_Data_s) //output [7:0] Q
	);

    
	reg [7:0]r0_RAW_Data;
	reg [7:0]r1_RAW_Data;
	
	reg [7:0]r0_RAW_Data_s;
	reg [7:0]r1_RAW_Data_s;
	
	wire [7:0]DLU = r0_RAW_Data_s;
	wire [7:0]DRU = r1_RAW_Data_s;
	wire [7:0]DLD = r0_RAW_Data;
	wire [7:0]DRD = r1_RAW_Data;
	
	reg r_Xaddr,r_Yaddr;

	always@(posedge Clk)begin
		r0_RAW_Data <= #1  r1_RAW_Data;
		r1_RAW_Data <= #1  RAW_Data;
		
		r0_RAW_Data_s <= #1  r1_RAW_Data_s;
		r1_RAW_Data_s <= #1  RAW_Data_s;
		
		r_Xaddr <= #1 Xaddr;
		r_Yaddr <= #1 Yaddr;
	end
	
	always@(posedge Clk)
		case({r_Xaddr,r_Yaddr})
			// R  Gr
			// Gb B
			2'b00:
				begin
					RED <= #1  DLU;
					GREEN_r <= #1  DLD + DRU;
					BLUE <= #1  DRD;				
				end
				
			// Gb B
			// R  Gr
			2'b01:
				begin
					RED <= #1  DLD;
					GREEN_r <= #1  DLU + DRD;
					BLUE <= #1  DRU;				
				end	

			// Gb R
			// B  Gr
			2'b10:
				begin
					RED <= #1  DRU;
					GREEN_r <= #1  DLU + DRD;
					BLUE <= #1  DLD;				
				end		

			// B  Gb
			// Gr R
			2'b11:
				begin
					RED <= #1  DRD;
					GREEN_r <= #1  DLD + DRU;
					BLUE <= #1  DLU;				
				end
			endcase
			
endmodule
