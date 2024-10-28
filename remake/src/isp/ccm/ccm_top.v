module ccm_top #(
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

//初始化修正参数
initial begin
    
end

//计算图像

wire [24-1:0]    r_data_R_fix;
wire [24-1:0]    r_data_G_fix;
wire [24-1:0]    r_data_B_fix;

assign r_data_R_fix = {16'd0,r_data_R}*gain_R;
assign r_data_G_fix = {16'd0,r_data_G};
assign r_data_B_fix = {16'd0,r_data_B}*gain_B;

//打拍同步
reg             rr_vsync;
reg             rr_hsync;
reg             rr_den;
reg [24-1:0]     rr_data_R;
reg [24-1:0]     rr_data_G;
reg [24-1:0]     rr_data_B;

always @(posedge clk ) begin
    rr_vsync<=r_vsync;
    rr_hsync<=r_hsync;
    rr_den<=r_den;
    rr_data_R<=r_data_R_fix;
    rr_data_G<=r_data_G_fix;
    rr_data_B<=r_data_B_fix;   
end


wire [8-1:0]    rr_data_R_cut;
wire [8-1:0]    rr_data_G_cut;
wire [8-1:0]    rr_data_B_cut;

assign rr_data_R_cut = rr_data_R[23:8]>255?8'hff:rr_data_R[15:8];
assign rr_data_G_cut = rr_data_G[7:0];
assign rr_data_B_cut = rr_data_B[23:8]>255?8'hff:rr_data_B[15:8];

//ccm输出
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        out_vsync   <=1'b0;
        out_hsync   <=1'b0;
        out_den     <=1'b0;
        out_data_R  <=8'd0;
        out_data_G  <=8'd0;
        out_data_B  <=8'd0;
    end else begin
        out_vsync   <=rr_vsync;
        out_hsync   <=rr_hsync;
        out_den     <=rr_den;
        out_data_R  <=rr_data_R_cut;
        out_data_G  <=rr_data_G_cut;
        out_data_B  <=rr_data_B_cut;

    end
end
    
endmodule