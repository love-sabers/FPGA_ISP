module awb_top #(
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

    output       out_vsync,		
    output       out_hsync,		
    output       out_den,			
	output [7:0] out_data_R, 	
    output [7:0] out_data_G,
    output [7:0] out_data_B
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
    mean_R  <={16'd1,16'd0};
    mean_G  <={16'd1,16'd0};
    mean_B  <={16'd1,16'd0};
    frame_R <=32'd0;
    frame_G <=32'd0;
    frame_B <=32'd0;
end
always @(posedge clk or negedge reset_n) begin
    if(!reset_n)begin
        mean_R  <={16'd1,16'd0};
        mean_G  <={16'd1,16'd0};
        mean_B  <={16'd1,16'd0};
        frame_R <=32'd0;
        frame_G <=32'd0;
        frame_B <=32'd0;
    end else if ({r_vsync,in_vsync}==2'b10) begin
        mean_R  <=frame_R+{16'd1,16'd0};//expand 0
        mean_G  <=frame_G+{16'd1,16'd0};
        mean_B  <=frame_B+{16'd1,16'd0};
    end else if ({r_vsync,in_vsync}==2'b01) begin
        frame_R <=32'd0;
        frame_G <=32'd0;
        frame_B <=32'd0;
    end else if (in_hsync) begin
        frame_R<=frame_R+in_data_R[7:4];//丢弃低4位，除16
        frame_G<=frame_G+in_data_G[7:4];
        frame_B<=frame_B+in_data_B[7:4];
    end 
end

//计算增益
wire [23:0] gain_R;
wire [23:0] gain_G;
wire [23:0] gain_B;
// Integer_Division_Top gain_R_inst(
//     .clk(clk), //input clk
//     .rstn(reset_n), //input rstn
//     .dividend({mean_G[31:16],8'd0}), //input [23:0] dividend//补低8位，乘256
//     .divisor(mean_R[31:16]), //input [15:0] divisor//丢弃低16位，除256*256
//     .quotient(gain_R) //output [23:0] quotient
// );
// Integer_Division_Top gain_G_inst(
//     .clk(clk), //input clk
//     .rstn(reset_n), //input rstn
//     .dividend({mean_G[31:16],8'd0}), //input [23:0] dividend
//     .divisor(mean_G[31:16]), //input [15:0] divisor
//     .quotient(gain_G) //output [23:0] quotient
// );
// Integer_Division_Top gain_B_inst(
//     .clk(clk), //input clk
//     .rstn(reset_n), //input rstn
//     .dividend({mean_G[31:16],8'd0}), //input [23:0] dividend
//     .divisor(mean_B[31:16]), //input [15:0] divisor
//     .quotient(gain_B) //output [23:0] quotient
// );

integer_division_core_top div_core_inst(
    .clk        (clk),
    .reset_n    (reset_n),
    .vsync      (in_vsync),//vs信号，用于启动模块
    .mean_R     (mean_R),
    .mean_G     (mean_G),
    .mean_B     (mean_B),
    .gain_R     (gain_R),
    .gain_G     (gain_G),
    .gain_B     (gain_B)
);

//计算图像

wire [24-1:0]    r_data_R_fix;
wire [24-1:0]    r_data_G_fix;
wire [24-1:0]    r_data_B_fix;
// wire [16-1:0]    r_data_R_fix_l;
// wire [16-1:0]    r_data_G_fix_l;
// wire [16-1:0]    r_data_B_fix_l;

assign r_data_R_fix = r_data_R*gain_R;
assign r_data_G_fix = r_data_G*gain_G;
assign r_data_B_fix = r_data_B*gain_B;

//打拍同步
reg             rr_vsync;
reg             rr_hsync;
reg             rr_den;
reg [16-1:0]    rr_data_R;
reg [16-1:0]    rr_data_G;
reg [16-1:0]    rr_data_B;

always @(posedge clk ) begin
    rr_vsync<=r_vsync;
    rr_hsync<=r_hsync;
    rr_den<=r_den;
    rr_data_R<=r_data_R_fix[23:8];// 丢弃低8位，除256
    rr_data_G<=r_data_G_fix[23:8];
    rr_data_B<=r_data_B_fix[23:8];   
end


wire [8-1:0]    rr_data_R_cut;
wire [8-1:0]    rr_data_G_cut;
wire [8-1:0]    rr_data_B_cut;

assign rr_data_R_cut = rr_data_R>255?8'hff:rr_data_R[7:0];
assign rr_data_G_cut = rr_data_G>255?8'hff:rr_data_G[7:0];
assign rr_data_B_cut = rr_data_B>255?8'hff:rr_data_B[7:0];

//awb输出
assign out_vsync   = rr_vsync;
assign out_hsync   = rr_hsync;
assign out_den     = rr_den;
assign out_data_R  = rr_data_R_cut;
assign out_data_G  = rr_data_G_cut;
assign out_data_B  = rr_data_B_cut;
// always @(posedge clk or negedge reset_n) begin
//     if (!reset_n) begin
//         out_vsync   <=1'b0;
//         out_hsync   <=1'b0;
//         out_den     <=1'b0;
//         out_data_R  <=8'd0;
//         out_data_G  <=8'd0;
//         out_data_B  <=8'd0;
//     end else begin
//         out_vsync   <=rr_vsync;
//         out_hsync   <=rr_hsync;
//         out_den     <=rr_den;
//         out_data_R  <=rr_data_R_cut;
//         out_data_G  <=rr_data_G_cut;
//         out_data_B  <=rr_data_B_cut;

//     end
// end
    
endmodule