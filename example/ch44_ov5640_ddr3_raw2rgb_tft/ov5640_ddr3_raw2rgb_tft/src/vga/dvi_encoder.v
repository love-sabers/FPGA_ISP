/*
	// port declare
	//hdmi output
	output       	tmds_clk_p,
	output       	tmds_clk_n,
	output 	[2:0] 	tmds_data_p,    //rgb
	output 	[2:0] 	tmds_data_n     //rgb
	
	
	// internal signal declare
	wire       video_hs;
	wire       video_vs;
	wire       video_de;
	wire [7:0] video_r;
	wire [7:0] video_g;
	wire [7:0] video_b;
	
	dvi_encoder u_dvi_encoder(
		.pixelclk(clk_74m            	),// system clock
		.pixelclk5x(clk_371m           	),// system clock x5
		.rst_n(rst_n             		),// reset
		.blue_din(video_b            	),// Blue data in
		.green_din(video_g            	),// Green data in
		.red_din(video_r            	),// Red data in
		.hsync(video_hs           	),// hsync data
		.vsync(video_vs           	),// vsync data
		.de(video_de           	),// data enable
		.tmds_clk_p(tmds_clk_p         	),
		.tmds_clk_n(tmds_clk_n         	),
		.tmds_data_p(tmds_data_p        	),//rgb
		.tmds_data_n(tmds_data_n        	) //rgb
	);
*/

`timescale 1 ps / 1ps
`define D #1

module dvi_encoder(
	input       pixelclk,       // system clock
	input       pixelclk5x,     // system clock x5
	input       rst_n,          // reset
	input[7:0]  blue_din,       // Blue data in
	input[7:0]  green_din,      // Green data in
	input[7:0]  red_din,        // Red data in
	input       hsync,          // hsync data
	input       vsync,          // vsync data
	input       de,             // data enable
	output      tmds_clk_p,
	output      tmds_clk_n,
	output[2:0] tmds_data_p,    //rgb
	output[2:0] tmds_data_n     //rgb
);

	wire [9:0] red;
	wire [9:0] green;
	wire [9:0] blue;

	encode encb(
		.clk(pixelclk),
		.rst_n(rst_n),
		.din(blue_din),
		.c0(hsync),
		.c1(vsync),
		.de(de),
		.dout(blue)
	);

	encode encg(
		.clk(pixelclk),
		.rst_n(rst_n),
		.din(green_din),
		.c0(1'b0),
		.c1(1'b0),
		.de(de),
		.dout(green)
	);

	encode encr(
		.clk(pixelclk),
		.rst_n(rst_n),
		.din(red_din),
		.c0(1'b0),
		.c1(1'b0),
		.de(de),
		.dout(red)
	);
	
	serdes_4b_10to1 serdes_4b_10to1_inst(
		.clkx5(pixelclk5x),// 5x clock input
		.datain_0(blue),// input data for serialisation
		.datain_1(green),// input data for serialisation
		.datain_2(red),// input data for serialisation
		.datain_3(10'b1111100000),// input data for serialisation
		.dataout_0_p(tmds_data_p[0]),// out DDR data
		.dataout_0_n(tmds_data_n[0]),// out DDR data
		.dataout_1_p(tmds_data_p[1]),// out DDR data
		.dataout_1_n(tmds_data_n[1]),// out DDR data
		.dataout_2_p(tmds_data_p[2]),// out DDR data
		.dataout_2_n(tmds_data_n[2]),// out DDR data
		.dataout_3_p(tmds_clk_p),// out DDR data
		.dataout_3_n(tmds_clk_n) // out DDR data
	); 

endmodule

module encode(
	clk,
	rst_n,
	din,
	c0,
	c1,
	de,
	dout
);
	input            clk;    // 像素时钟输入
	input            rst_n;    // 异步复位高电平有效
	input      [7:0] din;      // 数据输入，需要寄存
	input            c0;       // c0 输入
	input            c1;       // c1 输入
	input            de;       // 数据使能，输入
	output reg [9:0] dout;     // 数据输出
	
	parameter CTL0 = 10'b1101010100;
	parameter CTL1 = 10'b0010101011;
	parameter CTL2 = 10'b0101010100;
	parameter CTL3 = 10'b1010101011;
	
	reg [3:0] n1d; 		//统计输入的8bit数据中1的个数
	reg [7:0] din_q;	//同步寄存输入的8bit数据（统计需要一拍时间）
	
	// 统计每次输入的8bit数据中1和0的个数。流水线输出.同步寄存输入的8bit数据
	always @(posedge clk) begin
		din_q <= `D din;
		n1d <= `D din[0] + din[1] + din[2] + din[3] + din[4] + din[5] + din[6] + din[7];
	end

	// 第一步：8 bit -> 9 bit
	// 参考DVI规范1.0，第29页，图3-5
	wire decision1;	//0
	assign decision1 =(n1d > 4'h4) |((n1d == 4'h4) &(din_q[0] == 1'b0));
	
	// 最低位不变，剩下的等于前一位跟对应的din_q相异或运算，或者是同或运算
	// q_m[0] = din_q[0];
	// q_m[i+1] = q_m[i] ^ din_q[i+1]; q_m[8] = 1;
    // q_m[i+1] = q_m[i] ^~ din_q[i+1]; q_m[8] = 0;
	wire [8:0] q_m;
	assign q_m[0] = din_q[0];
	assign q_m[1] =(decision1) ? ~(q_m[0] ^ din_q[1]) :(q_m[0] ^ din_q[1]);
	assign q_m[2] =(decision1) ? ~(q_m[1] ^ din_q[2]) :(q_m[1] ^ din_q[2]);
	assign q_m[3] =(decision1) ? ~(q_m[2] ^ din_q[3]) :(q_m[2] ^ din_q[3]);
	assign q_m[4] =(decision1) ? ~(q_m[3] ^ din_q[4]) :(q_m[3] ^ din_q[4]);
	assign q_m[5] =(decision1) ? ~(q_m[4] ^ din_q[5]) :(q_m[4] ^ din_q[5]);
	assign q_m[6] =(decision1) ? ~(q_m[5] ^ din_q[6]) :(q_m[5] ^ din_q[6]);
	assign q_m[7] =(decision1) ? ~(q_m[6] ^ din_q[7]) :(q_m[6] ^ din_q[7]);
	assign q_m[8] =(decision1) ? 1'b0 : 1'b1;
	
	// 第二步：9 bit -> 10 bit
	// 参考DVI规范1.0，第29页，图3-5
	reg [3:0] n1q_m, n0q_m; // 统计q_m中1和0的个数
	always @(posedge clk) begin
		n1q_m  <= `D q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7];
		n0q_m  <= `D 4'h8 -(q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7]);
	end

	reg [4:0] cnt; // 计数器差距统计：统计1和0是否过量发送，最高位(cnt[4])是符号位
	wire decision2, decision3;
	assign decision2 =(cnt == 5'h0) |(n1q_m == n0q_m);
	
	// [(cnt > 0) and(N1q_m > N0q_m)] or [(cnt < 0) and(N0q_m > N1q_m)]
	assign decision3 =(~cnt[4] &(n1q_m > n0q_m)) |(cnt[4] &(n0q_m > n1q_m));

	// 流水线对齐(同步寄存器2拍)
	reg [1:0] de_reg;
	reg [1:0] c0_reg;
	reg [1:0] c1_reg;
	reg [8:0] q_m_reg;
	always @(posedge clk) begin
		de_reg  <= `D {de_reg[0], de};
		c0_reg  <= `D {c0_reg[0], c0};
		c1_reg  <= `D {c1_reg[0], c1};
		q_m_reg <= `D q_m;
	end

	// 10-bit  数据输出
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			dout <= 10'h0;
			cnt <= 5'd0;
		end else begin
			if(de_reg[1]) begin// 数据周期：发送对应编码的数据
				if(decision2) begin
					dout[9]   <= `D ~q_m_reg[8]; 
					dout[8]   <= `D q_m_reg[8]; 
					dout[7:0] <= `D(q_m_reg[8]) ? q_m_reg[7:0] : ~q_m_reg[7:0];
					cnt <= `D(~q_m_reg[8]) ?(cnt + n0q_m - n1q_m) :(cnt + n1q_m - n0q_m);
				end else begin if(decision3) begin
						dout[9]   <= `D 1'b1;
						dout[8]   <= `D q_m_reg[8];
						dout[7:0] <= `D ~q_m_reg;
						cnt <= `D cnt + {q_m_reg[8], 1'b0} +(n0q_m - n1q_m);
					end else begin
						dout[9]   <= `D 1'b0;
						dout[8]   <= `D q_m_reg[8];
						dout[7:0] <= `D q_m_reg[7:0];
						cnt <= `D cnt - {~q_m_reg[8], 1'b0} +(n1q_m - n0q_m);
					end
				end
			end else begin	// 控制周期:发送控制信号
				cnt <=  `D 5'd0;
				case({c1_reg[1], c0_reg[1]})
					2'b00:   dout <= `D CTL0;
					2'b01:   dout <= `D CTL1;
					2'b10:   dout <= `D CTL2;
					default: dout <= `D CTL3;
				endcase
			end
		end
	end
  
endmodule

module serdes_4b_10to1(
	input          clkx5,         // 5x clock input
	input [9:0]    datain_0,      // input data for serialisation
	input [9:0]    datain_1,      // input data for serialisation
	input [9:0]    datain_2,      // input data for serialisation
	input [9:0]    datain_3,      // input data for serialisation
	output         dataout_0_p,   // out DDR data
	output         dataout_0_n,   // out DDR data
	output         dataout_1_p,   // out DDR data
	output         dataout_1_n,   // out DDR data
	output         dataout_2_p,   // out DDR data
	output         dataout_2_n,   // out DDR data
	output         dataout_3_p,   // out DDR data
	output         dataout_3_n    // out DDR data
);  
  
	reg [2:0] TMDS_mod5 = 0;  // 模5计数器

	reg [4:0] TMDS_shift_0h = 0, TMDS_shift_0l = 0;
	reg [4:0] TMDS_shift_1h = 0, TMDS_shift_1l = 0;
	reg [4:0] TMDS_shift_2h = 0, TMDS_shift_2l = 0;
	reg [4:0] TMDS_shift_3h = 0, TMDS_shift_3l = 0;

	wire [4:0] TMDS_0_l = {datain_0[9],datain_0[7],datain_0[5],datain_0[3],datain_0[1]};
	wire [4:0] TMDS_0_h = {datain_0[8],datain_0[6],datain_0[4],datain_0[2],datain_0[0]};

	wire [4:0] TMDS_1_l = {datain_1[9],datain_1[7],datain_1[5],datain_1[3],datain_1[1]};
	wire [4:0] TMDS_1_h = {datain_1[8],datain_1[6],datain_1[4],datain_1[2],datain_1[0]};

	wire [4:0] TMDS_2_l = {datain_2[9],datain_2[7],datain_2[5],datain_2[3],datain_3[1]};
	wire [4:0] TMDS_2_h = {datain_2[8],datain_2[6],datain_2[4],datain_2[2],datain_3[0]};

	wire [4:0] TMDS_3_l = {datain_3[9],datain_3[7],datain_3[5],datain_3[3],datain_3[1]};
	wire [4:0] TMDS_3_h = {datain_3[8],datain_3[6],datain_3[4],datain_3[2],datain_3[0]};

	
	// 模5计数器
	always @(posedge clkx5)
	begin
		if(TMDS_mod5 >= 3'd4)
			TMDS_mod5 <= 3'd0;
		else
			TMDS_mod5 <= TMDS_mod5 + 3'd1;
	end
	
	// 5倍速度移位发送数据
	always @(posedge clkx5)
	begin
		if(TMDS_mod5 == 3'd4)begin
			TMDS_shift_0h <= TMDS_0_h;
			TMDS_shift_0l <= TMDS_0_l;
			TMDS_shift_1h <= TMDS_1_h;
			TMDS_shift_1l <= TMDS_1_l;
			TMDS_shift_2h <= TMDS_2_h;
			TMDS_shift_2l <= TMDS_2_l;	
			TMDS_shift_3h <= TMDS_3_h;
			TMDS_shift_3l <= TMDS_3_l;		
		end
		else begin
			TMDS_shift_0h <= TMDS_shift_0h[4:1];
			TMDS_shift_0l <= TMDS_shift_0l[4:1];
			TMDS_shift_1h <= TMDS_shift_1h[4:1];
			TMDS_shift_1l <= TMDS_shift_1l[4:1];
			TMDS_shift_2h <= TMDS_shift_2h[4:1];
			TMDS_shift_2l <= TMDS_shift_2l[4:1];	
			TMDS_shift_3h <= TMDS_shift_3h[4:1];
			TMDS_shift_3l <= TMDS_shift_3l[4:1];				
		end
	end

//	altddio_out	altddio_out_0(
//		.datain_h({TMDS_shift_3h[0],TMDS_shift_2h[0],TMDS_shift_1h[0],TMDS_shift_0h[0]}),
//		.datain_l({TMDS_shift_3l[0],TMDS_shift_2l[0],TMDS_shift_1l[0],TMDS_shift_0l[0]}),
//		.outclock(clkx5),
//		.dataout({dataout_3_p,dataout_2_p,dataout_1_p,dataout_0_p}),
//		.aclr(1'b0),
//		.aset(1'b0),
//		.oe(1'b1),
//		.oe_out(),
//		.outclocken(1'b1),
//		.sclr(1'b0),
//		.sset(1'b0));

//	defparam
//		altddio_out_0.extend_oe_disable = "OFF",
//		altddio_out_0.invert_output = "OFF",
//		altddio_out_0.lpm_hint = "UNUSED",
//		altddio_out_0.lpm_type = "altddio_out",
//		altddio_out_0.oe_reg = "UNREGISTERED",
//		altddio_out_0.power_up_high = "OFF",
//		altddio_out_0.width = 4;
//	
//    ODDR ODDR_0(
//        .Q0({dataout_3_p,dataout_2_p,dataout_1_p,dataout_0_p}),
//        .Q1(),
//        .D0({TMDS_shift_3h[0],TMDS_shift_2h[0],TMDS_shift_1h[0],TMDS_shift_0h[0]}),
//        .D1({TMDS_shift_3l[0],TMDS_shift_2l[0],TMDS_shift_1l[0],TMDS_shift_0l[0]}),
//        .TX(1),
//        .CLK(clkx5)
//    );

	Gowin_DDR_1 Gowin_DDR_1(
		.din({TMDS_shift_3l[0],TMDS_shift_2l[0],TMDS_shift_1l[0],TMDS_shift_0l[0],TMDS_shift_3h[0],TMDS_shift_2h[0],TMDS_shift_1h[0],TMDS_shift_0h[0]}), //input [7:0] din
		.clk(clkx5), //input clk
		.q({dataout_3_p,dataout_2_p,dataout_1_p,dataout_0_p}) //output [3:0] q
	);



//	altddio_out	altddio_out_1(
//		.datain_h(~{TMDS_shift_3h[0],TMDS_shift_2h[0],TMDS_shift_1h[0],TMDS_shift_0h[0]}),
//		.datain_l(~{TMDS_shift_3l[0],TMDS_shift_2l[0],TMDS_shift_1l[0],TMDS_shift_0l[0]}),
//		.outclock(clkx5),
//		.dataout({dataout_3_n,dataout_2_n,dataout_1_n,dataout_0_n}),
//		.aclr(1'b0),
//		.aset(1'b0),
//		.oe(1'b1),
//		.oe_out(),
//		.outclocken(1'b1),
//		.sclr(1'b0),
//		.sset(1'b0));
//	defparam
//		altddio_out_1.extend_oe_disable = "OFF",
//		altddio_out_1.invert_output = "OFF",
//		altddio_out_1.lpm_hint = "UNUSED",
//		altddio_out_1.lpm_type = "altddio_out",
//		altddio_out_1.oe_reg = "UNREGISTERED",
//		altddio_out_1.power_up_high = "OFF",
//		altddio_out_1.width = 4;

//   ODDR ODDR_1(
//        .Q0({dataout_3_n,dataout_2_n,dataout_1_n,dataout_0_n}),
//        .Q1(),
//        .D0(~{TMDS_shift_3h[0],TMDS_shift_2h[0],TMDS_shift_1h[0],TMDS_shift_0h[0]}),
//        .D1(~{TMDS_shift_3l[0],TMDS_shift_2l[0],TMDS_shift_1l[0],TMDS_shift_0l[0]}),
//        .TX(1),
//        .CLK(clkx5)
//    );
    
	Gowin_DDR_1 Gowin_DDR_2(
		.din(~{TMDS_shift_3l[0],TMDS_shift_2l[0],TMDS_shift_1l[0],TMDS_shift_0l[0],TMDS_shift_3h[0],TMDS_shift_2h[0],TMDS_shift_1h[0],TMDS_shift_0h[0]}), //input [7:0] din
		.clk(clkx5), //input clk
		.q({dataout_3_n,dataout_2_n,dataout_1_n,dataout_0_n}) //output [4:0] q
	);



endmodule
