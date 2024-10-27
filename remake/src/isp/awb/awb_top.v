module awb_top #(
    parameter source_h  = 512,
	parameter source_v  = 512
) (
    input       clk,
    input       reset_n,
    input       in_vsync,		
    input       in_hsync,		
    input       in_den,			
	input [7:0] in_data_R, 	
    input [7:0] in_data_G, 	
    input [7:0] in_data_B, 	

    output reg      out_vsync,		
    output reg      out_hsync,		
    output reg      out_den,			
	output reg[7:0] out_data_R, 	
    output reg[7:0] out_data_G,
    output reg[7:0] out_data_B
);

//对输入信号进行打拍处理
reg             r_vsync;
reg             r_hsync;
reg             r_den;
reg [8-1:0]     r_data_R;
reg [8-1:0]     r_data_G;
reg [8-1:0]     r_data_B;

always @(posedge clk) begin
    r_vsync     <=in_vsync;
    r_hsync     <=in_hsync;
    r_den       <=in_den;
    r_data_R    <=in_data_R;
    r_data_G    <=in_data_G;
    r_data_B    <=in_data_B;
end

//计算增益
reg [32-1:0] line_R;
reg [32-1:0] line_G;
reg [32-1:0] line_B;

reg [32-1:0] frame_R;
reg [32-1:0] frame_G;
reg [32-1:0] frame_B;

reg [32-1:0] mean_R;
reg [32-1:0] mean_G;
reg [32-1:0] mean_B;

initial begin
    mean_R  <=32'd1;
    mean_G  <=32'd1;
    mean_B  <=32'd1;
    // line_R  <=32'd0;
    // line_G  <=32'd0;
    // line_B  <=32'd0;
    frame_R <=32'd1;
    frame_G <=32'd1;
    frame_B <=32'd1;
end
always @(posedge clk or negedge reset_n) begin
    if(!reset_n)begin
        mean_R  <=32'd1;
        mean_G  <=32'd1;
        mean_B  <=32'd1;
        // line_R  <=32'd0;
        // line_G  <=32'd0;
        // line_B  <=32'd0;
        frame_R <=32'd1;
        frame_G <=32'd1;
        frame_B <=32'd1;
    end else if ({r_vsync,in_vsync}==2'b10) begin
        mean_R  <=frame_R;
        mean_G  <=frame_G;
        mean_B  <=frame_B;
    end else if ({r_vsync,in_vsync}==2'b01) begin
        frame_R <=32'd1;
        frame_G <=32'd1;
        frame_B <=32'd1;
    // end else if ({r_hsync,in_hsync}==2'b10) begin
    //     // frame_R <=frame_R+line_R;
    //     // frame_G <=frame_G+line_G;
    //     // frame_B <=frame_B+line_B;
    //     // line_R  <=32'd0;
    //     // line_G  <=32'd0;
    //     // line_B  <=32'd0;
    end else if (in_hsync) begin
        // line_R  <=line_R+in_data_R;
        // line_G  <=line_G+in_data_G;
        // line_B  <=line_B+in_data_B;
        frame_R<=frame_R+in_data_R;
        frame_G<=frame_G+in_data_G;
        frame_B<=frame_B+in_data_B;
    end 
end

//计算增益
wire [23:0] gain_R;
wire [23:0] gain_B;
Integer_Division_Top gain_R_inst(
		.clk(clk), //input clk
		.rstn(reset_n), //input rstn
		.dividend({mean_G[31:16],8'd0}), //input [23:0] dividend
		.divisor(mean_R[31:16]), //input [15:0] divisor
		.quotient(gain_R) //output [23:0] quotient
	);
Integer_Division_Top gain_B_inst(
		.clk(clk), //input clk
		.rstn(reset_n), //input rstn
		.dividend({mean_G[31:16],8'd0}), //input [23:0] dividend
		.divisor(mean_B[31:16]), //input [15:0] divisor
		.quotient(gain_B) //output [23:0] quotient
	);

//计算图像

wire [24-1:0]    r_data_R_fix;
wire [24-1:0]    r_data_G_fix;
wire [24-1:0]    r_data_B_fix;

assign r_data_R_fix = {16'd0,r_data_R}*gain_R;
assign r_data_G_fix = {16'd0,r_data_G};
assign r_data_B_fix = {16'd0,r_data_B}*gain_B;

wire [8-1:0]    r_data_R_cut;
wire [8-1:0]    r_data_G_cut;
wire [8-1:0]    r_data_B_cut;

assign r_data_R_cut = r_data_R_fix[23:8]>255?8'hff:r_data_R_fix[15:8];
assign r_data_G_cut = r_data_G_fix[7:0];
assign r_data_B_cut = r_data_B_fix[23:8]>255?8'hff:r_data_B_fix[15:8];

//awb输出
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        out_vsync   <=1'b0;
        out_hsync   <=1'b0;
        out_den     <=1'b0;
        out_data_R  <=8'd0;
        out_data_G  <=8'd0;
        out_data_B  <=8'd0;
    end else begin
        out_vsync   <=r_vsync;
        out_hsync   <=r_hsync;
        out_den     <=r_den;
        out_data_R  <=r_data_R_cut;
        out_data_G  <=r_data_G_cut;
        out_data_B  <=r_data_B_cut;

    end
end
    
endmodule