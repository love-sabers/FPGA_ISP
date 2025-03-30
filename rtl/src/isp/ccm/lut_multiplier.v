module lut_multiplier#(
    parameter r_value = 256,
    parameter g_value = 256,
    parameter b_value = 256
) (
    input [7:0] in,            // 8位输入值
    output reg [12-1:0] r_out,    //12位输出结果（20位舍弃末8位）
    output reg [12-1:0] g_out,    //12位输出结果（20位舍弃末8位）
    output reg [12-1:0] b_out     //12位输出结果（20位舍弃末8位）
);
    // 定义查找表，256个条目，每个条目是16位
    reg [32-1:0] r_lut [255:0];   
    reg [32-1:0] g_lut [255:0];
    reg [32-1:0] b_lut [255:0];

    // 初始化查找表，存储预先计算的乘积结果
    initial begin : init_lut
        integer i;
        for (i = 0; i < 256; i = i + 1) begin
            r_lut[i] = i * r_value;  
            g_lut[i] = i * g_value;  
            b_lut[i] = i * b_value;  
        end
    end

    // 查找并输出结果
    always @(*) begin
        r_out = r_lut[in][19:8];
        g_out = g_lut[in][19:8];
        b_out = b_lut[in][19:8];
    end
endmodule
