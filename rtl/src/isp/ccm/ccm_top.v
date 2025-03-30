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
reg [7:0]       r_data_R;
reg [7:0]       r_data_G;
reg [7:0]       r_data_B;

always @(posedge clk) begin
    r_vsync     <=in_vsync;
    r_hsync     <=in_hsync;
    r_den       <=in_den;
    r_data_R    <=in_data_R;
    r_data_G    <=in_data_G;
    r_data_B    <=in_data_B;
end

//初始化修正参数
//x*256
localparam m_rr =  20'd398      ;//1.56
localparam m_rg = ~20'd30 +20'd1;//-0.12
localparam m_rb = ~20'd112+20'd1;//-0.44
localparam m_gr = ~20'd58 +20'd1;//-0.23
localparam m_gg =  20'd388      ;//1.52
localparam m_gb = ~20'd74 +20'd1;//-0.29
localparam m_br = ~20'd25 +20'd1;//0.0
localparam m_bg = ~20'd112+20'd1;//-0.54
localparam m_bb =  20'd393      ;//1.54

//计算图像
//求积

wire [12-1:0]    r_data_fix [9-1:0];
//x*256*val/256
//x*val
lut_multiplier#(
    .r_value(m_rr),
    .g_value(m_gr),
    .b_value(m_br)
)lut_mul_instR(
    .in     (r_data_R),              // 8位输入值
    .r_out  (r_data_fix[0]),         //10位输出结果（18位舍弃末8位）
    .g_out  (r_data_fix[1]),         //10位输出结果（18位舍弃末8位）
    .b_out  (r_data_fix[2])          //10位输出结果（18位舍弃末8位）
);

lut_multiplier#(
    .r_value(m_rg),
    .g_value(m_gg),
    .b_value(m_bg)
)lut_mul_instG(
    .in     (r_data_G),              // 8位输入值
    .r_out  (r_data_fix[3]),         //10位输出结果（18位舍弃末8位）
    .g_out  (r_data_fix[4]),         //10位输出结果（18位舍弃末8位）
    .b_out  (r_data_fix[5])          //10位输出结果（18位舍弃末8位）
);

lut_multiplier#(
    .r_value(m_rb),
    .g_value(m_gb),
    .b_value(m_bb)
)lut_mul_instB(
    .in     (r_data_B),              // 8位输入值
    .r_out  (r_data_fix[6]),         //10位输出结果（18位舍弃末8位）
    .g_out  (r_data_fix[7]),         //10位输出结果（18位舍弃末8位）
    .b_out  (r_data_fix[8])          //10位输出结果（18位舍弃末8位）
);

    //奇偶帧
reg parity;
always @(posedge clk ) begin
    parity<=~parity;
end
    //打拍同步
reg            rr_vsync_o;
reg            rr_hsync_o;
reg            rr_den_o;
reg            rr_vsync_e;
reg            rr_hsync_e;
reg            rr_den_e;
// reg [7:0]      rr_data_R;
// reg [7:0]      rr_data_G;
// reg [7:0]      rr_data_B;

reg [12-1:0]   rr_data_fix_o [9-1:0];
reg [12-1:0]   rr_data_fix_e [9-1:0];

integer i;
always @(posedge clk ) begin
    
    // rr_data_R   <=r_data_R;
    // rr_data_G   <=r_data_G;
    // rr_data_B   <=r_data_B;

    //奇偶分拍
    if(parity)begin
        rr_vsync_o    <=r_vsync;
        rr_hsync_o    <=r_hsync;
        rr_den_o      <=r_den;
        for(i=0;i<9;i=i+1)begin
            rr_data_fix_o[i]<=r_data_fix[i];
        end
    end else begin
        rr_vsync_e    <=r_vsync;
        rr_hsync_e    <=r_hsync;
        rr_den_e      <=r_den;
        for(i=0;i<9;i=i+1)begin
            rr_data_fix_e[i]<=r_data_fix[i];
        end
    end
    
end

//求和
//奇偶分和
wire [12-1:0]    rr_data_R_sum_o;
wire [12-1:0]    rr_data_G_sum_o;
wire [12-1:0]    rr_data_B_sum_o;
assign rr_data_R_sum_o = rr_data_fix_o[0] + rr_data_fix_o[3] + rr_data_fix_o[6] /* synthesis syn_dspstyle = "dsp" */;
assign rr_data_G_sum_o = rr_data_fix_o[1] + rr_data_fix_o[4] + rr_data_fix_o[7] /* synthesis syn_dspstyle = "dsp" */;
assign rr_data_B_sum_o = rr_data_fix_o[2] + rr_data_fix_o[5] + rr_data_fix_o[8] /* synthesis syn_dspstyle = "dsp" */;

wire [12-1:0]    rr_data_R_sum_e;
wire [12-1:0]    rr_data_G_sum_e;
wire [12-1:0]    rr_data_B_sum_e;
assign rr_data_R_sum_e = rr_data_fix_e[0] + rr_data_fix_e[3] + rr_data_fix_e[6] /* synthesis syn_dspstyle = "dsp" */;
assign rr_data_G_sum_e = rr_data_fix_e[1] + rr_data_fix_e[4] + rr_data_fix_e[7] /* synthesis syn_dspstyle = "dsp" */;
assign rr_data_B_sum_e = rr_data_fix_e[2] + rr_data_fix_e[5] + rr_data_fix_e[8] /* synthesis syn_dspstyle = "dsp" */;

    //打拍同步
reg             rrr_vsync;
reg             rrr_hsync;
reg             rrr_den;
// reg [7:0]       rrr_data_R;
// reg [7:0]       rrr_data_G;
// reg [7:0]       rrr_data_B;
reg [12-1:0]    rrr_data_R_sum;
reg [12-1:0]    rrr_data_G_sum;
reg [12-1:0]    rrr_data_B_sum;

always @(posedge clk ) begin
    
    // rrr_data_R      <=rr_data_R;
    // rrr_data_G      <=rr_data_G;
    // rrr_data_B      <=rr_data_B;
    //奇偶同拍
    if(parity)begin
        rrr_vsync       <=rr_vsync_o;
        rrr_hsync       <=rr_hsync_o;
        rrr_den         <=rr_den_o;
        rrr_data_R_sum  <=rr_data_R_sum_o;
        rrr_data_G_sum  <=rr_data_G_sum_o;
        rrr_data_B_sum  <=rr_data_B_sum_o;
    end else begin
        rrr_vsync       <=rr_vsync_e;
        rrr_hsync       <=rr_hsync_e;
        rrr_den         <=rr_den_e;
        rrr_data_R_sum  <=rr_data_R_sum_e;
        rrr_data_G_sum  <=rr_data_G_sum_e;
        rrr_data_B_sum  <=rr_data_B_sum_e;
    end
    
end

//裁剪
wire [8-1:0]    rrr_data_R_cut;
wire [8-1:0]    rrr_data_G_cut;
wire [8-1:0]    rrr_data_B_cut;

assign rrr_data_R_cut = rrr_data_R_sum[12-1] ? 8'h00 : rrr_data_R_sum[12-2:8]>0 ? 8'hff : rrr_data_R_sum[7:0];
assign rrr_data_G_cut = rrr_data_G_sum[12-1] ? 8'h00 : rrr_data_G_sum[12-2:8]>0 ? 8'hff : rrr_data_G_sum[7:0];
assign rrr_data_B_cut = rrr_data_B_sum[12-1] ? 8'h00 : rrr_data_B_sum[12-2:8]>0 ? 8'hff : rrr_data_B_sum[7:0];


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
        out_vsync   <=rrr_vsync;
        out_hsync   <=rrr_hsync;
        out_den     <=rrr_den;
        out_data_R  <=rrr_data_R_cut;
        out_data_G  <=rrr_data_G_cut;
        out_data_B  <=rrr_data_B_cut;

        // out_vsync   <=rr_vsync;
        // out_hsync   <=rr_hsync;
        // out_den     <=rr_den;
        // out_data_R  <=rr_data_R_sum[7:0];
        // out_data_G  <=rr_data_G_sum[7:0];
        // out_data_B  <=rr_data_B_sum[7:0];

    end
end
    
endmodule