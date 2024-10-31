module integer_division_core_top(
    input               clk,
    input               reset_n,
    input               vsync,//vs信号，用于启动模块
    input [32-1:0]      mean_R,
    input [32-1:0]      mean_G,
    input [32-1:0]      mean_B,
    output reg [23:0]   gain_R,
    output reg [23:0]   gain_G,
    output reg [23:0]   gain_B
);

//时序控制
//vs触发，计数两个div_delay后停止
reg [7:0] count;
initial begin
    count<=8'd0;
end
always @(posedge clk or negedge reset_n) begin
    if(~reset_n)begin
        count<=8'd0;
    end else begin
        if(count==8'd0)begin
            if(~vsync)begin
                count<=8'd1;
            end else begin
                count<=count;
            end
        end else  begin
            if(count < 30*2)begin
                count<=count+8'd1;
            end else begin
                count<=8'd0;
            end
        end
    end
end

reg  [23:0] dividend;
reg  [15:0] divisor;
wire [23:0] quotient;
reg  [23:0] quotient_reg;

Integer_Division_Top div_inst(
    .clk(clk), //input clk
    .rstn(reset_n), //input rstn
    .dividend(dividend), //input [23:0] dividend//补低8位，乘256
    .divisor(divisor), //input [15:0] divisor//丢弃低16位，除256*256
    .quotient(quotient) //output [23:0] quotient
);

wire isblack;
assign isblack = mean_R[31:16]<16 & mean_G[31:16]<16 & mean_B[31:16]<16;

reg [23:0]   gain_R_reg/* synthesis syn_keep= 1 */;
reg [23:0]   gain_G_reg/* synthesis syn_keep= 1 */;
reg [23:0]   gain_B_reg/* synthesis syn_keep= 1 */;

always @(posedge clk or negedge reset_n) begin
    if(~reset_n)begin
        dividend<=24'd1;
        divisor<=16'd1;
    end else if (isblack) begin
        gain_R_reg<=24'd0;//make pure black
        gain_G_reg<=24'd0;
        gain_B_reg<=24'd0;
    end else begin
        casez (count)/* synthesis parallel_case */
            8'd1 : begin
                dividend<={mean_G[31:16],8'd0};
                divisor<=mean_R[31:16];
            end
            8'd30 : begin
                quotient_reg<=quotient;
            end
            8'd31 : begin
                dividend<={mean_G[31:16],8'd0};
                divisor<=mean_B[31:16];
            end
            8'd60 : begin
                gain_R_reg<=quotient_reg;
                gain_G_reg<=24'd256;
                gain_B_reg<=quotient;
                
            end
            default:begin
                dividend<=dividend;
                divisor<=divisor;
                quotient_reg<=quotient;
            end 
        endcase
    end
end

always @(posedge clk ) begin
    if(~vsync)begin
        gain_R<=gain_R_reg;
        gain_G<=gain_G_reg;
        gain_B<=gain_B_reg;
    end
end




endmodule
