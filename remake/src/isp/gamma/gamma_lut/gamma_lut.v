module gamma_lut
(
    input      [7:0] in_R,      // 8位输入
    input      [7:0] in_G,      // 8位输入
    input      [7:0] in_B,      // 8位输入
    input      [1:0] gamma_type,//1 : gamma = 1    2 : gamma = 2.2
    output reg [7:0] out_R,     // 8位输出
    output reg [7:0] out_G,     // 8位输出
    output reg [7:0] out_B      // 8位输出
);

    // 定义查找表，256个条目，每个条目是8位
    reg [7:0] lut1 [255:0];  // Gamma 1.8 的查找表
    reg [7:0] lut2 [255:0];  // Gamma 2.2 的查找表
    reg [7:0] lut3 [255:0];  // Gamma 2.4 的查找表

    // 初始化查找表，存储预先计算的乘积结果
    initial begin : init_lut
        // 读取查找表数据
        $readmemh("gamma_lut1p8.txt", lut1);  // gamma = 1.8 的查找表
        $readmemh("gamma_lut2p2.txt", lut2);  // gamma = 2.2 的查找表
        $readmemh("gamma_lut2p4.txt", lut3);  // gamma = 2.4 的查找表
    end

    // 查找并输出结果，根据 gamma_type 切换查找表
    always @(*) begin
        case(gamma_type)
            2'd1: begin
                // 如果 gamma_type 为 1.8，使用 lut1 查找表
                out_R = lut1[in_R][7:0];  // 查找并输出
                out_G = lut1[in_G][7:0];
                out_B = lut1[in_B][7:0];
            end
            2'd2: begin
                // 如果 gamma_type 为 2.2，使用 lut2 查找表
                out_R = lut2[in_R][7:0];  // 查找并输出
                out_G = lut2[in_G][7:0];
                out_B = lut2[in_B][7:0];
            end
            2'd3: begin
                // 如果 gamma_type 为 2.4，使用 lut3 查找表
                out_R = lut3[in_R][7:0];  // 查找并输出
                out_G = lut3[in_G][7:0];
                out_B = lut3[in_B][7:0];
            end
            default: begin
                // 默认情况下，使用 lut2（可以是任何您想要的默认行为）
                out_R = lut2[in_R][7:0];
                out_G = lut2[in_G][7:0];
                out_B = lut2[in_B][7:0];
            end
        endcase
    end
endmodule
