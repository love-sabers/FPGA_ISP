module LUT6_2 #(
    parameter INIT = 64'h0000_0000_0000_0000  // 64位初始化参数
)(
    input wire I0, I1, I2, I3, I4, I5,
    output wire O5, O6
)/* synthesis keep_hierarchy=true */;

    // 提取 INIT 参数的不同部分
    localparam [15:0] INIT_LUT4_1 = INIT[15:0];    // 前16位给第一个LUT4
    localparam [15:0] INIT_LUT4_2 = INIT[31:16];   // 中间16位给第二个LUT4
    localparam [15:0] INIT_MUX_LUT5 = INIT[47:32]; // 中间的16位给MUX2逻辑
    localparam [15:0] INIT_MUX_LUT6 = INIT[63:48]; // 高16位给MUX2逻辑

    // 使用 LUT4 实现前4个输入的逻辑
    wire lut4_out1, lut4_out2;
    LUT4 #(
        .INIT(INIT_LUT4_1)
    ) lut4_1 (
        .I0(I0), .I1(I1), .I2(I2), .I3(I3),
        .F(lut4_out1)
    );

    LUT4 #(
        .INIT(INIT_LUT4_2)
    ) lut4_2 (
        .I0(I0), .I1(I1), .I2(I2), .I3(I3),
        .F(lut4_out2)
    );

    // 手动实现 MUX2_LUT5 的逻辑
    wire mux_lut5_out;
    assign mux_lut5_out = (I4) ? lut4_out2 : lut4_out1;

    // 将 O5 设置为 MUX2_LUT5 的输出
    assign O5 = mux_lut5_out;

    // 手动实现 MUX2_LUT6 的逻辑
    assign O6 = (I5) ? INIT_MUX_LUT6[mux_lut5_out] : mux_lut5_out;

endmodule

module enhance_image_processing (
    input wire clk,
    input wire rst_n,
    input wire valid_in,
    input wire [23:0] x_in,      // Original input: 8-bit*3 channels (RGB)
    input wire [767:0] x_r,      // Intermediate results: 32-bit*24 channels
    output reg [23:0] enhance_image, // Enhanced output: 8-bit*3 channels (RGB)
    output reg valid_out
);

    // Internal registers
    reg [31:0] r1, r2, r3, r4, r5, r6, r7, r8;
    reg [31:0] x_r_norm, x_g_norm, x_b_norm; // Normalized input (float32)
    reg [31:0] x_temp_r, x_temp_g, x_temp_b; // Temporary enhanced values
    reg [31:0] temp_1, temp_2;
    reg [7:0] final_r, final_g, final_b;    // Final output (uint8)

    // State machine
    reg [3:0] state;
    localparam IDLE = 4'd0, LOAD = 4'd1, PROCESS_R = 4'd2, PROCESS_G = 4'd3,
               PROCESS_B = 4'd4, DONE = 4'd5;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            valid_out <= 1'b0;
            enhance_image <= 24'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (valid_in) begin
                        state <= LOAD;
                        valid_out <= 1'b0;
                    end
                end

                LOAD: begin
                    // Load r1 to r8 from x_r
                    r1 <= x_r[31:0];
                    r2 <= x_r[63:32];
                    r3 <= x_r[95:64];
                    r4 <= x_r[127:96];
                    r5 <= x_r[159:128];
                    r6 <= x_r[191:160];
                    r7 <= x_r[223:192];
                    r8 <= x_r[255:224];

                    // Normalize x_in (uint8 -> float32 in [0, 1])
                    x_r_norm <= {24'b0, x_in[23:16]} / 8'd255; // Red channel
                    x_g_norm <= {24'b0, x_in[15:8]} / 8'd255;  // Green channel
                    x_b_norm <= {24'b0, x_in[7:0]} / 8'd255;   // Blue channel

                    state <= PROCESS_R;
                end

                PROCESS_R: begin
                    // Process Red channel
                    temp_1 <= x_r_norm * x_r_norm;    // x^2
                    temp_2 <= temp_1 - x_r_norm;      // x^2 - x
                    x_temp_r <= x_r_norm + r1 * temp_2;
                    state <= PROCESS_G;
                end

                PROCESS_G: begin
                    // Process Green channel
                    temp_1 <= x_g_norm * x_g_norm;    // x^2
                    temp_2 <= temp_1 - x_g_norm;      // x^2 - x
                    x_temp_g <= x_g_norm + r1 * temp_2;
                    state <= PROCESS_B;
                end

                PROCESS_B: begin
                    // Process Blue channel
                    temp_1 <= x_b_norm * x_b_norm;    // x^2
                    temp_2 <= temp_1 - x_b_norm;      // x^2 - x
                    x_temp_b <= x_b_norm + r1 * temp_2;

                    // Convert float32 back to uint8
                    final_r <= (x_temp_r * 8'd255) > 8'd255 ? 8'd255 : (x_temp_r * 8'd255);
                    final_g <= (x_temp_g * 8'd255) > 8'd255 ? 8'd255 : (x_temp_g * 8'd255);
                    final_b <= (x_temp_b * 8'd255) > 8'd255 ? 8'd255 : (x_temp_b * 8'd255);

                    enhance_image <= {final_r, final_g, final_b};
                    valid_out <= 1'b1;
                    state <= DONE;
                end

                DONE: begin
                    state <= IDLE;
                    valid_out <= 1'b0;
                end
            endcase
        end
    end
endmodule
