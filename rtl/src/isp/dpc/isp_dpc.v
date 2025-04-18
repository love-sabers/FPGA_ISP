`timescale 1 ns / 1 ps

/*
 * ISP - Defective Pixel Correction
 */

/*
 * bayer 5x5邻域内同意颜色通道相对于中心像素都有8个临近像素。矫正按以下步骤操作：
 * 计算中心像素与周围八个像素值的差；
 * 判断八个差值是否都为正值或者都为负值；
 * 如果有的为正有的为负，那么就为正常值，否则进行下一步；
 * 设置一个阈值，如果八个差值的绝对值都查过阈值，那么就判断为坏点；
 * 判断为坏点后就用八个临近的像素值的中位值来替换当前的像素值；
*/

module isp_dpc
#(
	parameter BITS = 8,
	parameter WIDTH = 1280,
	parameter HEIGHT = 960,
	parameter BAYER = 0 //0:RGGB 1:GRBG 2:GBRG 3:BGGR
)
(
	input pclk,
	input rst_n,
    input in_den,	

	input [BITS-1:0] threshold, //阈值越小,检测越松,坏点检测数越多

	input in_href,
	input in_vsync,
	input [BITS-1:0] in_raw,

	output out_href,
	output out_vsync,
	output [BITS-1:0] out_raw,
    output out_den
);
	//对输入信号进行打拍处理
	reg             r_vsync;
	reg             r_hsync;
	reg             r_den;
	reg [7:0]       r_in_raw;

	always @(posedge pclk) begin
		r_vsync     <=in_vsync;
		r_hsync     <=in_href;
		r_den       <=in_den;
		r_in_raw    <=in_raw;
	end
	
	wire [BITS-1:0] shiftout/* synthesis syn_keep= 1 */;
	wire [BITS-1:0] tap3x, tap2x, tap1x, tap0x/* synthesis syn_keep= 1 */;
//	shift_register #(BITS, WIDTH, 4) linebuffer(pclk, in_href, in_raw, shiftout, {tap3x, tap2x, tap1x, tap0x})/* synthesis syn_keep= 1 */;
    shift_register #(BITS, 4) linebuffer(pclk, in_href, in_raw, shiftout, {tap3x, tap2x, tap1x, tap0x})/* synthesis syn_keep= 1 */;
	
	reg [BITS-1:0] in_raw_r/* synthesis syn_keep= 1 */;
	reg [BITS-1:0] p11,p12,p13,p14,p15/* synthesis syn_keep= 1 */;
	reg [BITS-1:0] p21,p22,p23,p24,p25/* synthesis syn_keep= 1 */;
	reg [BITS-1:0] p31,p32,p33,p34,p35/* synthesis syn_keep= 1 */;
	reg [BITS-1:0] p41,p42,p43,p44,p45/* synthesis syn_keep= 1 */;
	reg [BITS-1:0] p51,p52,p53,p54,p55/* synthesis syn_keep= 1 */;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			in_raw_r <= 0;
			p11 <= 0; p12 <= 0; p13 <= 0; p14 <= 0; p15 <= 0;
			p21 <= 0; p22 <= 0; p23 <= 0; p24 <= 0; p25 <= 0;
			p31 <= 0; p32 <= 0; p33 <= 0; p34 <= 0; p35 <= 0;
			p41 <= 0; p42 <= 0; p43 <= 0; p44 <= 0; p45 <= 0;
			p51 <= 0; p52 <= 0; p53 <= 0; p54 <= 0; p55 <= 0;
		end
		else begin
			in_raw_r <= in_raw;
			p11 <= p12; p12 <= p13; p13 <= p14; p14 <= p15; p15 <= tap3x;
			p21 <= p22; p22 <= p23; p23 <= p24; p24 <= p25; p25 <= tap2x;
			p31 <= p32; p32 <= p33; p33 <= p34; p34 <= p35; p35 <= tap1x;
			p41 <= p42; p42 <= p43; p43 <= p44; p44 <= p45; p45 <= tap0x;
			p51 <= p52; p52 <= p53; p53 <= p54; p54 <= p55; p55 <= in_raw_r;
		end
	end

	reg odd_pix;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n)
			odd_pix <= 0;
		else if (!in_href)
			odd_pix <= 0;
		else
			odd_pix <= ~odd_pix;
	end
	wire odd_pix_sync_shift = odd_pix;
	
	reg prev_href;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) 
			prev_href <= 0;
		else
			prev_href <= in_href;
	end	
	
	reg odd_line;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) 
			odd_line <= 0;
		else if (in_vsync)
			odd_line <= 0;
		else if (prev_href & (~in_href))
			odd_line <= ~odd_line;
		else
			odd_line <= odd_line;
	end
	wire odd_line_sync_shift = odd_line;

	wire [1:0] p33_fmt = BAYER[1:0] ^ {odd_line_sync_shift, odd_pix_sync_shift}; //pixel format 0:[R]GGB 1:R[G]GB 2:RG[G]B 3:RGG[B]

	reg [BITS-1:0] t1_p1, t1_p2, t1_p3;
	reg [BITS-1:0] t1_p4, t1_p5, t1_p6;
	reg [BITS-1:0] t1_p7, t1_p8, t1_p9;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			t1_p1 <= 0; t1_p2 <= 0; t1_p3 <= 0;
			t1_p4 <= 0; t1_p5 <= 0; t1_p6 <= 0;
			t1_p7 <= 0; t1_p8 <= 0; t1_p9 <= 0;
		end
		else begin
			case (p33_fmt)
				2'd0,2'd3: begin //R/B
					t1_p1 <= p11; t1_p2 <= p13; t1_p3 <= p15;
					t1_p4 <= p31; t1_p5 <= p33; t1_p6 <= p35;
					t1_p7 <= p51; t1_p8 <= p53; t1_p9 <= p55;
				end
				2'd1,2'd2: begin //Gr/Gb
					t1_p1 <= p22; t1_p2 <= p13; t1_p3 <= p24;
					t1_p4 <= p31; t1_p5 <= p33; t1_p6 <= p35;
					t1_p7 <= p42; t1_p8 <= p53; t1_p9 <= p44;
				end
				default: begin
					t1_p1 <= 0; t1_p2 <= 0; t1_p3 <= 0;
					t1_p4 <= 0; t1_p5 <= 0; t1_p6 <= 0;
					t1_p7 <= 0; t1_p8 <= 0; t1_p9 <= 0;
				end
			endcase
		end
	end

	//中值滤波 step1
	reg [BITS-1:0] t2_min1, t2_med1, t2_max1;
	reg [BITS-1:0] t2_min2, t2_med2, t2_max2;
	reg [BITS-1:0] t2_min3, t2_med3, t2_max3;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			t2_min1 <= 0; t2_med1 <= 0; t2_max1 <= 0;
			t2_min2 <= 0; t2_med2 <= 0; t2_max2 <= 0;
			t2_min3 <= 0; t2_med3 <= 0; t2_max3 <= 0;
		end
		else begin
			t2_min1 <= min(t1_p1, t1_p2, t1_p3);
			t2_med1 <= med(t1_p1, t1_p2, t1_p3);
			t2_max1 <= max(t1_p1, t1_p2, t1_p3);
			t2_min2 <= min(t1_p4, t1_p5, t1_p6);
			t2_med2 <= med(t1_p4, t1_p5, t1_p6);
			t2_max2 <= max(t1_p4, t1_p5, t1_p6);
			t2_min3 <= min(t1_p7, t1_p8, t1_p9);
			t2_med3 <= med(t1_p7, t1_p8, t1_p9);
			t2_max3 <= max(t1_p7, t1_p8, t1_p9);
		end
	end

	//中值滤波 step2
	reg [BITS-1:0] t3_max_of_min, t3_med_of_med, t3_min_of_max;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			t3_max_of_min <= 0; t3_med_of_med <= 0; t3_min_of_max <= 0;
		end
		else begin
			t3_max_of_min <= max(t2_min1, t2_min2, t2_min3);
			t3_med_of_med <= med(t2_med1, t2_med2, t2_med3);
			t3_min_of_max <= min(t2_max1, t2_max2, t2_max3);
		end
	end

	//中值滤波 step3
	reg [BITS-1:0] t4_medium;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			t4_medium <= 0;
		end
		else begin
			t4_medium <= med(t3_max_of_min, t3_med_of_med, t3_min_of_max);
		end
	end

	//将中值打拍对齐到坏点检测时序
	reg [BITS-1:0] t5_medium;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			t5_medium <= 0;
		end
		else begin
			t5_medium <= t4_medium;
		end
	end

	//坏点检测 step1 (转有符号数)
	reg signed [BITS:0] t2_p1, t2_p2, t2_p3;
	reg signed [BITS:0] t2_p4, t2_p5, t2_p6;
	reg signed [BITS:0] t2_p7, t2_p8, t2_p9;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			t2_p1 <= 0; t2_p2 <= 0; t2_p3 <= 0;
			t2_p4 <= 0; t2_p5 <= 0; t2_p6 <= 0;
			t2_p7 <= 0; t2_p8 <= 0; t2_p9 <= 0;
		end
		else begin
			t2_p1 <= {1'b0,t1_p1}; t2_p2 <= {1'b0,t1_p2}; t2_p3 <= {1'b0,t1_p3};
			t2_p4 <= {1'b0,t1_p4}; t2_p5 <= {1'b0,t1_p5}; t2_p6 <= {1'b0,t1_p6};
			t2_p7 <= {1'b0,t1_p7}; t2_p8 <= {1'b0,t1_p8}; t2_p9 <= {1'b0,t1_p9};
		end
	end

	//坏点检测 step2 (计算中心像素与周围八个像素值的差)
	reg [BITS:0] t3_center;
	reg signed [BITS:0] t3_diff1, t3_diff2, t3_diff3, t3_diff4, t3_diff5, t3_diff6, t3_diff7, t3_diff8;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			t3_center <= 0;
			t3_diff1 <= 0; t3_diff2 <= 0;
			t3_diff3 <= 0; t3_diff4 <= 0;
			t3_diff5 <= 0; t3_diff6 <= 0;
			t3_diff7 <= 0; t3_diff8 <= 0;
		end
		else begin
			t3_center <= t2_p5[BITS-1:0];
			t3_diff1 <= t2_p5 - t2_p1;
			t3_diff2 <= t2_p5 - t2_p2;
			t3_diff3 <= t2_p5 - t2_p3;
			t3_diff4 <= t2_p5 - t2_p4;
			t3_diff5 <= t2_p5 - t2_p6;
			t3_diff6 <= t2_p5 - t2_p7;
			t3_diff7 <= t2_p5 - t2_p8;
			t3_diff8 <= t2_p5 - t2_p9;
		end
	end

	//坏点检测 step3 (判断差值是否都为正或都为负,计算差值绝对值)
	reg t4_defective_pix;
	reg [BITS-1:0] t4_center;
	reg [BITS-1:0] t4_diff1, t4_diff2, t4_diff3, t4_diff4, t4_diff5, t4_diff6, t4_diff7, t4_diff8;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			t4_defective_pix <= 0;
			t4_center <= 0;
			t4_diff1 <= 0; t4_diff2 <= 0;
			t4_diff3 <= 0; t4_diff4 <= 0;
			t4_diff5 <= 0; t4_diff6 <= 0;
			t4_diff7 <= 0; t4_diff8 <= 0;
		end
		else begin
			t4_center <= t3_center;
			t4_defective_pix <= (8'b0000_0000 == {t3_diff1[BITS],t3_diff2[BITS],t3_diff3[BITS],t3_diff4[BITS],t3_diff5[BITS],t3_diff6[BITS],t3_diff7[BITS],t3_diff8[BITS]})
							 || (8'b1111_1111 == {t3_diff1[BITS],t3_diff2[BITS],t3_diff3[BITS],t3_diff4[BITS],t3_diff5[BITS],t3_diff6[BITS],t3_diff7[BITS],t3_diff8[BITS]});
			t4_diff1 <= t3_diff1[BITS] ? 1'sd0 - t3_diff1 : t3_diff1;
			t4_diff2 <= t3_diff2[BITS] ? 1'sd0 - t3_diff2 : t3_diff2;
			t4_diff3 <= t3_diff3[BITS] ? 1'sd0 - t3_diff3 : t3_diff3;
			t4_diff4 <= t3_diff4[BITS] ? 1'sd0 - t3_diff4 : t3_diff4;
			t4_diff5 <= t3_diff5[BITS] ? 1'sd0 - t3_diff5 : t3_diff5;
			t4_diff6 <= t3_diff6[BITS] ? 1'sd0 - t3_diff6 : t3_diff6;
			t4_diff7 <= t3_diff7[BITS] ? 1'sd0 - t3_diff7 : t3_diff7;
			t4_diff8 <= t3_diff8[BITS] ? 1'sd0 - t3_diff8 : t3_diff8;
		end
	end

	//坏点检测 step4 (判断差值绝对值是否超出阈值)
	reg t5_defective_pix;
	reg [BITS-1:0] t5_center;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			t5_defective_pix <= 0;
			t5_center <= 0;
		end
		else begin
			t5_center <= t4_center;
			t5_defective_pix <= t4_defective_pix && t4_diff1 > threshold && t4_diff2 > threshold && t4_diff3 > threshold && t4_diff4 > threshold && 
													t4_diff5 > threshold && t4_diff6 > threshold && t4_diff7 > threshold && t4_diff8 > threshold;
		end
	end

	//坏点检测 step5 (坏点成立输出中值滤波值, 非坏点输出原值)
	reg [BITS-1:0] t6_center;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			t6_center <= 0;
		end
		else begin
			t6_center <= t5_defective_pix ? t5_medium : t5_center;
		end
	end

	localparam DLY_CLK = 10;
	reg [DLY_CLK-1:0] href_dly;
	reg [DLY_CLK-1:0] vsync_dly;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			href_dly <= 0;
			vsync_dly <= 0;
		end
		else begin
			href_dly <= {href_dly[DLY_CLK-2:0], in_href};
			vsync_dly <= {vsync_dly[DLY_CLK-2:0], in_vsync};
		end
	end
	
	assign out_href = href_dly[DLY_CLK-1];
	assign out_vsync = vsync_dly[DLY_CLK-1];
	assign out_raw = out_href ? t6_center : {BITS{1'b0}};
    assign out_den = r_den;

	function [BITS-1:0] min;
		input [BITS-1:0] a, b, c;
		begin
			min = (a < b) ? ((a < c) ? a : c) : ((b < c) ? b : c);
		end
	endfunction
	function [BITS-1:0] med;
		input [BITS-1:0] a, b, c;
		begin
			med = (a < b) ? ((b < c) ? b : (a < c ? c : a)) : ((b > c) ? b : (a > c ? c : a));
		end
	endfunction
	function [BITS-1:0] max;
		input [BITS-1:0] a, b, c;
		begin
			max = (a > b) ? ((a > c) ? a : c) : ((b > c) ? b : c);
		end
	endfunction
endmodule

//module shift_register
//#(
//    parameter BITS = 8,   // 数据宽度
//    parameter LINES = 4   // 移位寄存器的行数
//)
//(
//    input                   clk,        // 时钟信号
//    input                   Reset,      // 重置信号
//    input  [BITS-1:0]       Din,        // 输入数据
//    output [BITS-1:0]       Q1,          // 最后一行输出
//    output [BITS*LINES-1:0] tapsx       // 每一行的输出
//);

//     内部信号
//    reg [BITS-1:0] shift_reg[LINES-1:0]; // 模拟行级输出
//    integer i;

//     实例化 myshift_register
//    myshift_register myshift_inst (
//        .clk(clk), 
//        .Reset(Reset), 
//        .Din(Din), 
//        .Q(Q1)
//    );

//     捕获每一行的输出
//    always @(posedge clk or posedge Reset) begin
//        if (Reset) begin
//             复位所有寄存器行
//            for (i = 0; i < LINES; i = i + 1) begin
//                shift_reg[i] <= 0;
//            end
//        end else begin
//             移位逻辑
//            shift_reg[0] <= Din;              // 第一行保存输入数据
//            for (i = 1; i < LINES; i = i + 1) begin
//                shift_reg[i] <= shift_reg[i-1]; // 其他行依次移位
//            end
//        end
//    end

//     生成 tapsx 输出
//    generate
//        genvar j;
//        for (j = 0; j < LINES; j = j + 1) begin : taps_assign
//            assign tapsx[(BITS*j)+:BITS] = shift_reg[j]; // 将每一行的输出拼接到 tapsx
//        end
//    endgenerate

//endmodule
module shift_register #(
    parameter BITS = 8,
    parameter STAGES = 4
)(
    input wire pclk,
    input wire in_href,
    input wire [BITS-1:0] in_raw,
    output reg [BITS-1:0] shiftout,
    output wire [BITS*STAGES-1:0] taps
);

    reg [BITS-1:0] shift_reg [0:STAGES-1];

    always @(posedge pclk) begin
        if (in_href) begin
            shift_reg[0] <= in_raw;
            for (int i = 1; i < STAGES; i++) begin
                shift_reg[i] <= shift_reg[i-1];
            end
        end
    end

    assign shiftout = shift_reg[STAGES-1];

    genvar i;
    generate
        for (i=0; i<STAGES; i=i+1) begin : tap_assign
            assign taps[BITS*(STAGES - 1 - i) +: BITS] = shift_reg[i];
        end
    endgenerate

endmodule
/* Simple Dual-Port RAM */
//module simple_dp_ram
//#(
//	parameter DW = 8,
//	parameter AW = 4,
//	parameter SZ = 2**AW
//)
//(
//	input          clk,
//	input          wren,
//	input [AW-1:0] wraddr,
//	input [DW-1:0] data,
//	input          rden,
//	input [AW-1:0] rdaddr,
//	output reg [DW-1:0] q
//);

//	reg [DW-1:0] mem [SZ-1:0]/* synthesis syn_keep= 1 */;
//	always @ (posedge clk) begin
//		if (wren) begin
//			mem[wraddr] <= data;
//		end
//	end
//	always @ (posedge clk) begin
//		if (rden) begin
//			q <= mem[rdaddr];
//		end
//	end
//endmodule
/* Shift Register based on Simple Dual-Port RAM */
//module shift_register
//#(
//	parameter BITS = 8,
//	parameter WIDTH = 480,
//	parameter LINES = 4
//)
//(
//	input                clock,
//	input                clken,
//	input  [BITS-1:0]    shiftin,
//	output [BITS-1:0]    shiftout,
//	output [BITS*LINES-1:0] tapsx
//);

//	localparam RAM_SZ = WIDTH - 1;
//	localparam RAM_AW = clogb2(RAM_SZ);

//	reg [RAM_AW-1:0] pos_r/* synthesis syn_keep= 1 */;
//	wire [RAM_AW-1:0] pos = pos_r < RAM_SZ ? pos_r : (RAM_SZ[RAM_AW-1:0] - 1'b1)/* synthesis syn_keep= 1 */;
//	always @ (posedge clock) begin
//		if (clken) begin
//			if (pos_r < RAM_SZ - 1)
//				pos_r <= pos_r + 1'b1;
//			else
//				pos_r <= 0;
//		end
//	end

//	reg [BITS-1:0] in_r/* synthesis syn_keep= 1 */;
//	always @ (posedge clock) begin
//		if (clken) begin
//			in_r <= shiftin;
//		end
//	end
//	wire [BITS-1:0] line_out[LINES-1:0]/* synthesis syn_keep= 1 */;
//    generate
//		genvar i;
//		for (i = 0; i < LINES; i = i + 1) begin : gen_ram_inst/* synthesis syn_keep= 1 */
//			/* synthesis syn_keep= 1 */
//            simple_dp_ram #(BITS, RAM_AW, RAM_SZ) u_ram (/* synthesis syn_keep= 1 */
//				.clk(clock)/* synthesis syn_keep= 1 */,
//				.wren(clken)/* synthesis syn_keep= 1 */,
//				.wraddr(pos)/* synthesis syn_keep= 1 */,
//				.data(i == 0 ? in_r : line_out[i-1])/* synthesis syn_keep= 1 */,
//				.rden(clken)/* synthesis syn_keep= 1 */,
//				.rdaddr(pos)/* synthesis syn_keep= 1 */,
//				.q(line_out[i]/* synthesis syn_keep= 1 */)/* synthesis syn_keep= 1 */
//			) /* synthesis syn_keep=1 */;
//		end
//	endgenerate	
//     LINES = 4
//	simple_dp_ram #(BITS, RAM_AW, RAM_SZ) u_ram_0 (
//		.clk(clock),
//		.wren(clken),
//		.wraddr(pos),
//		.data(in_r),
//		.rden(clken),
//		.rdaddr(pos),
//		.q(line_out[0])/* synthesis syn_keep=1 */
//	);

//	simple_dp_ram #(BITS, RAM_AW, RAM_SZ) u_ram_1 (
//		.clk(clock),
//		.wren(clken),
//		.wraddr(pos),
//		.data(line_out[0]),
//		.rden(clken),
//		.rdaddr(pos),
//		.q(line_out[1])/* synthesis syn_keep=1 */
//	);

//	simple_dp_ram #(BITS, RAM_AW, RAM_SZ) u_ram_2 (
//		.clk(clock),
//		.wren(clken),
//		.wraddr(pos),
//		.data(line_out[1]),
//		.rden(clken),
//		.rdaddr(pos),
//		.q(line_out[2])/* synthesis syn_keep=1 */
//	);
//	simple_dp_ram #(BITS, RAM_AW, RAM_SZ) u_ram_3 (
//		.clk(clock),
//		.wren(clken),
//		.wraddr(pos),
//		.data(line_out[2]),
//		.rden(clken),
//		.rdaddr(pos),
//		.q(line_out[3])/* synthesis syn_keep=1 */
//	);


//	assign shiftout = line_out[LINES-1]/* synthesis syn_keep= 1 */;
//	generate
//		genvar j;
//		for (j = 0; j < LINES; j = j + 1) begin : gen_taps_assign
//			assign tapsx[(BITS*j)+:BITS] = line_out[j]/* synthesis syn_keep= 1 */;
//		end
//	endgenerate

//	function integer clogb2;
//	input integer depth;
//	begin
//		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
//			depth = depth >> 1;
//	end
//	endfunction
//endmodule