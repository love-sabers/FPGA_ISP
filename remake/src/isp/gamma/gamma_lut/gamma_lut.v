module gamma_lut#(
    parameter  gamma_type = 1
    //1 : gamma = 1
    //2 : gamma = 2.2
) (
    input      [7:0] in_R,      // 8位输入
    input      [7:0] in_G,      // 8位输入
    input      [7:0] in_B,      // 8位输入
    output reg [7:0] out_R,     // 8位输出
    output reg [7:0] out_G,     // 8位输出
    output reg [7:0] out_B      // 8位输出
) ;
    // // 定义查找表，256个条目，每个条目是8位
    reg [7:0] lut [255:0] /* synthesis syn_preserve = 1 */;   

    // 初始化查找表，存储预先计算的乘积结果
    initial begin : init_lut
        if(gamma_type==1)begin
            $readmemh("gamma_lut1.txt", lut);
        end else begin
            $readmemh("gamma_lut2p2.txt", lut);
        end
    end

    // 查找并输出结果
    always @(*) begin
        out_R = lut[in_R][7:0];
        out_G = lut[in_G][7:0];
        out_B = lut[in_B][7:0];
    end
endmodule
