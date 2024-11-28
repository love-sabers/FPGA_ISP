module gma_top #(
    parameter source_h  = 1024,
	parameter source_v  = 1024
) (
    input       clk,
    input       reset_n,
    input       in_vsync,		
    input       in_hsync,		
    input       in_den,			
	input [7:0] in_data_R, 	
    input [7:0] in_data_G, 	
    input [7:0] in_data_B, 	
    input [1:0] gamma_type,

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

//校正
wire [8-1:0]     r_data_R_fix/* synthesis syn_keep= 1 */;
wire [8-1:0]     r_data_G_fix/* synthesis syn_keep= 1 */;
wire [8-1:0]     r_data_B_fix/* synthesis syn_keep= 1 */;

gamma_lut gamma_lut_inst(
    .in_R (r_data_R),       // 8位输入
    .in_G (r_data_G),       // 8位输入
    .in_B (r_data_B),       // 8位输入
    .gamma_type(gamma_type),//1 : gamma = 1.8    2 : gamma = 2.2   3 : gamma = 2.4
    .out_R(r_data_R_fix),       // 8位输出
    .out_G(r_data_G_fix),       // 8位输出
    .out_B(r_data_B_fix)        // 8位输出
);


//gamma输出
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
        out_data_R  <=r_data_R_fix;
        out_data_G  <=r_data_G_fix;
        out_data_B  <=r_data_B_fix;

    end
end
    
endmodule