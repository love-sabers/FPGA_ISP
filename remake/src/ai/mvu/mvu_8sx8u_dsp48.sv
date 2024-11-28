/******************************************************************************
 * Copyright (C) 2024, Advanced Micro Devices, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 *  3. Neither the name of the copyright holder nor the names of its
 *     contributors may be used to endorse or promote products derived from
 *     this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION). HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @brief	Matrix Vector Unit (MVU) core compute kernel utilizing DSP48.
 *****************************************************************************/

module mvu_8sx8u_dsp48 #(
	int unsigned  PE,
	int unsigned  SIMD,
	int unsigned  ACCU_WIDTH,
	int unsigned  ACTIVATION_WIDTH,
	int unsigned  WEIGHT_WIDTH,

	int unsigned  VERSION = 1,
	bit  SIGNED_ACTIVATIONS = 0,
	bit  FORCE_BEHAVIORAL = 0
)(
	// Global Control
	input	logic  clk,
	input	logic  rst,
	input	logic  en,

	// Input
	input	logic  last,
	input	logic  zero,	// ignore current inputs and force this partial product to zero
	input	logic signed [PE-1:0][SIMD-1:0][WEIGHT_WIDTH    -1:0]  w,	// signed weights
	input	logic                [SIMD-1:0][ACTIVATION_WIDTH-1:0]  a,	// unsigned activations (override by SIGNED_ACTIVATIONS)

	// Ouput
	output	logic  vld,
	output	logic signed [PE-1:0][ACCU_WIDTH-1:0]  p
);
	// for verilator always use behavioral code
	localparam bit  BEHAVIORAL = 0;
//`ifdef VERILATOR
//		1 ||
//`endif
//		FORCE_BEHAVIORAL;

	typedef int unsigned  leave_load_t[2*SIMD-1];
	function leave_load_t init_leave_loads();
		automatic leave_load_t  res;
		for(int  i = 2*(SIMD-1); i >= int'(SIMD)-1; i--)  res[i] = 1;
		for(int  i = SIMD-2; i >= 0; i--)  res[i] = res[2*i+1] + res[2*i+2];
		return  res;
	endfunction : init_leave_loads

	// Pipeline for last indicator flag
	logic [1:5] L = '0;
	always_ff @(posedge clk) begin
		if(rst)      L <= '0;
		else if(en)  L <= { last, L[1:4] };
	end
	assign	vld = L[5];

	// Stages #1 - #3: DSP Lanes + cross-lane canaries duplicated with SIMD parallelism
	localparam int unsigned  SINGLE_PROD_WIDTH = ACTIVATION_WIDTH+WEIGHT_WIDTH;
	localparam int unsigned  D[2:0] = '{ ACCU_WIDTH+SINGLE_PROD_WIDTH, SINGLE_PROD_WIDTH, 0 }; // Lane offsets

	localparam int unsigned  PIPE_COUNT = (PE+1)/2;
	for(genvar  c = 0; c < PIPE_COUNT; c++) begin : genPipes/* synthesis syn_keep= 1 */

		localparam int unsigned  PE_BEG = 2*c;
		localparam int unsigned  PE_END = PE < 2*(c+1)? PE : 2*(c+1);
		localparam int unsigned  PE_REM = 2*(c+1) - PE_END;

		uwire        [47:0]  p3[SIMD];
		uwire signed [ 1:0]  h3[SIMD];
		for(genvar  s = 0; s < SIMD; s++) begin : genSIMD

			// Input Lane Assembly
			wire [17:0]  bb = { {(18-ACTIVATION_WIDTH){SIGNED_ACTIVATIONS && a[s][ACTIVATION_WIDTH-1]}}, a[s] }/* synthesis syn_keep= 1 */;
//			logic [29:0]  aa;
			logic [26:0]  aa/* synthesis syn_keep= 1 */;
			logic [26:0]  dd/* synthesis syn_keep= 1 */;
			logic [ 1:0]  xx/* synthesis syn_keep= 1 */;
			if(1) begin : blkVectorize
				uwire [WEIGHT_WIDTH-1:0]  ww[PE_END - PE_BEG]/* synthesis syn_keep= 1 */;
				for(genvar  pe = 0; pe < PE_END - PE_BEG; pe++) begin
					assign	ww[pe] = w[PE_BEG + pe][s];
					if(pe) begin
						if(BEHAVIORAL)  assign  xx = zero? 0 : ww[pe] * a[s];
`ifndef VERILATOR
						else begin
							LUT6_2 #(.INIT(64'h0000_6AC0_0000_8888)) lut_x (//synthesis keep
								.O6(xx[1]),
								.O5(xx[0]),
								.I5(1'b1),
								.I4(zero),
								.I3(ww[pe][1]),
								.I2(a[s][1]),
								.I1(ww[pe][0]),
								.I0(a[s][0])
							);
						end
`endif
					end
				end
				always_comb begin
					dd = '0;
					aa = '0;
					for(int unsigned  pe = 0; pe < PE_END - PE_BEG; pe++) begin
						dd[D[pe + PE_REM] +: WEIGHT_WIDTH-1] = ww[pe];
						aa[D[pe + PE_REM] + WEIGHT_WIDTH-1] = ww[pe][WEIGHT_WIDTH-1];
					end
				end
			end : blkVectorize

			wire [47:0]  pp/* synthesis syn_keep= 1 */;

			// Note: Since the product B * AD is computed,
			//       rst can be only applied to AD and zero only to B
			//       with the same effect as zeroing both.
			if(BEHAVIORAL) begin : genBehav
				// Stage #1: Input Refine
				logic signed [17:0]  B1  = 0;
				always_ff @(posedge clk) begin
					if(zero)     B1  <= 0;
					else if(en)  B1  <= bb;
				end

				logic signed [26:0]  AD1 = 0;
				always_ff @(posedge clk) begin
					if(rst)      AD1 <= 0;
					else if(en)  AD1 <= dd - aa;
				end

				// Stage #2: Multiply
				logic signed [45:0]  M2 = 0;
				always_ff @(posedge clk) begin
					if(rst)      M2 <= 0;
					else if(en)  M2 <=
// synthesis translate off
						(B1 === '0) || (AD1 === '0)? 0 :
// synthesis translate on
						B1 * AD1;
				end

				// Stage #3: Accumulate
				logic signed [47:0]  P3 = 0;
				always_ff @(posedge clk) begin
					if(rst)      P3 <= 0;
					else if(en)  P3 <= M2 + (L[3]? 0 : P3);
				end

				assign	pp = P3;
			end : genBehav
`ifndef VERILATOR
			else begin : genDSP
//P_OUT = P + (D - A) × B + 48'hFFFFFFFFFFFF
				localparam logic [6:0]  OPMODE_INVERSION = 7'b010_01_01;
				uwire [6:0]  opmode = { { 1'b0, L[2], 1'b0 }, 4'b00_00 };
                DSP48E1 dsp(/* synthesis keep_hierarchy=true */
                    .dout(pp), //output [47:0] dout
                    .a(dd), //input [25:0] a
                    .b(bb), //input [17:0] b
                    .c(48'hFFFFFFFFFFFF), //input [47:0] c
                    .d(aa), //input [25:0] d
                    .accsel(rst), //input accsel
                    .clk(clk), //input clk
                    .ce(en), //input ce
                    .reset(
// synthesis translate_off
						rst ||
// synthesis translate_on
						zero
                    ) //input reset
                )/* synthesis syn_keep= 1 */;
//                case(VERSION)
//				1: DSP48E1 dsp(/* synthesis syn_keep= 1 */
//                    .dout(pp), //output [47:0] dout
//                    .a(dd), //input [25:0] a
//                    .b(bb), //input [17:0] b
//                    .c(48'hFFFFFFFFFFFF), //input [47:0] c
//                    .d(aa), //input [25:0] d
//                    .accsel(rst), //input accsel
//                    .clk(clk), //input clk
//                    .ce(en), //input ce
//                    .reset(
// synthesis translate_off
//						rst ||
// synthesis translate_on
//						zero
//                    ) //input reset
//                )/* synthesis syn_keep= 1 */;
//                2: DSP48E1 dsp(
//                    .dout(pp), //output [47:0] dout
//                    .a(dd), //input [25:0] a
//                    .b(bb), //input [17:0] b
//                    .c(48'hFFFFFFFFFFFF), //input [47:0] c
//                    .d(aa), //input [25:0] d
//                    .accsel(rst), //input accsel
//                    .clk(clk), //input clk
//                    .ce(en), //input ce
//                    .reset(
// synthesis translate_off
//						rst ||
// synthesis translate_on
//						zero
//                    ) //input reset
//                )/* synthesis syn_keep= 1 */;
//				default: initial begin
//					$error("Unknown version DSP48E%0d.", VERSION);
//					$finish;
//				end
//				endcase
			end : genDSP
`endif

			// External Canary Pipeline
			logic [1:0]  X1 = '{ default: 0 };
			logic [1:0]  X2 = '{ default: 0 };
			logic [1:0]  X3 = '{ default: 0 };
			always_ff @(posedge clk) begin
				if(rst) begin
					X1 <= '{ default: 0 };
					X2 <= '{ default: 0 };
					X3 <= '{ default: 0 };
				end
				else if(en) begin
					X1 <= xx;
					X2 <= X1;
					X3 <= X2 + (L[3]? 2'h0 : pp[D[1]+:2]);
				end
			end

			// Derive actual cross-lane overflows
			assign  h3[s] = pp[D[1]+:2] - X3;

			assign	p3[s] = pp;

		end : genSIMD

		// Stage #4: Cross-SIMD Reduction

		// Count leaves reachable from each node
		localparam leave_load_t  LEAVE_LOAD = SIMD > 1 ? init_leave_loads() : '{ default: 0}; // SIMD=1 requires no adder tree, so zero-ing out, otherwise init_leave_loads ends up in infinite loop

		// Range of Cross-lane Contribution Tracked in Hi4
		/*
		 * - Assumption: ACCU_WIDTH bounds right lane value at any point in time.
		 * - The value x beyond the lane boundary is hence bounded by:
		 *		-2^(w-1) <= x <= 2^(w-1)-1    with w = ACCU_WIDTH - D[1]
		 * - This value decomposes into the tracked overflow h and the overflow l
		 *   from the low SIMD lane reduction with:
		 *		0 <= l <= SIMD
		 * - From x = l + h follows:
		 *		h = x - l
		 *		-2^(w-1) - SIMD <= h <= 2^(w-1)-1
		 * - This required bit width of the two's complement representation of this
		 *   signed value is determined by its lower bound to be at least:
		 *		1 + $clog2(2^(w-1)+SIMD)
		 */
		localparam int unsigned  HI_WIDTH = 1 + $clog2(2**(ACCU_WIDTH-D[1]-1)+SIMD);

		uwire signed [ACCU_WIDTH       -1:0]  up4;
		uwire signed [HI_WIDTH         -1:0]  hi4;
		uwire        [$clog2(SIMD)+D[1]-1:0]  lo4;

		// Conclusive high part accumulation
		if(PE_REM == 0) begin : genHi

			// Adder Tree across all SIMD high contributions, each from [-1:1]
			uwire signed [2*SIMD-2:0][$clog2(1+SIMD):0]  tree;
			for(genvar  s = 0; s < SIMD;   s++)  assign  tree[SIMD-1+s] = h3[s];
			for(genvar  n = 0; n < SIMD-1; n++) begin
				// Sum truncated to actual maximum bit width at this node
				uwire signed [$clog2(1+LEAVE_LOAD[n]):0]  s = $signed(tree[2*n+1]) + $signed(tree[2*n+2]);
				assign  tree[n] = s;
			end

			// High Sideband Accumulation
			logic signed [HI_WIDTH-1:0]  Hi4 = 0;
			always_ff @(posedge clk) begin
				if(rst)  Hi4 <= 0;
				else if(en) begin
					automatic logic signed [HI_WIDTH:0]  h = $signed(L[4]? 0 : Hi4) + $signed(tree[0]);
//					assert(h[HI_WIDTH] == h[HI_WIDTH-1]) else begin
//						$error("%m: Accumulation overflow for ACCU_WIDTH=%0d", ACCU_WIDTH);
//						$stop;
//					end
                    if(h[HI_WIDTH] != h[HI_WIDTH-1]) begin
                        $fatal("Accumulation overflow detected for ACCU_WIDTH=%0d", HI_WIDTH);
                    end
					Hi4 <= h;
				end
			end
			assign	hi4 = Hi4;
		end : genHi
		else begin : genHiZero
			assign hi4 = '0;
		end : genHiZero

		for(genvar  i = 0; i < 2; i++) begin
			localparam int unsigned  LO_WIDTH = D[i+1] - D[i];
			// Conclusive low part accumulation
			if(i >= PE_REM) begin : blkLo
				// Adder Tree across all SIMD low contributions (all unsigned arithmetic)
				localparam int unsigned  ROOT_WIDTH = $clog2(1 + SIMD*(2**LO_WIDTH-1));
				uwire [2*SIMD-2:0][ROOT_WIDTH-1:0]  tree;
				for(genvar  s = 0; s < SIMD;   s++)  assign  tree[SIMD-1+s] = p3[s][D[i]+:LO_WIDTH];
				for(genvar  n = 0; n < SIMD-1; n++) begin
					// Sum truncated to actual maximum bit width at this node
					localparam int unsigned  NODE_WIDTH = $clog2(1 + LEAVE_LOAD[n]*(2**LO_WIDTH-1));
					uwire [NODE_WIDTH-1:0]  s = tree[2*n+1] + tree[2*n+2];
					assign  tree[n] = s;
				end

				logic [ROOT_WIDTH-1:0]  Lo4 = 0;
				always_ff @(posedge clk) begin
					if(rst)      Lo4 <= 0;
					else if(en)  Lo4 <= tree[0];
				end

				if(i == 1)  assign  up4 = Lo4;
				else  assign  lo4 = Lo4;
			end : blkLo
			else begin : blkLoZero
				assign lo4 = '0;
			end : blkLoZero

		end

		// Stage #5: Resolve lane totals
		logic signed [1:0][ACCU_WIDTH-1:0]  Res5 = '{ default: 0 };
		always_ff @(posedge clk) begin
			if(rst)  Res5 <= '{ default: 0 };
			else if(en) begin
				Res5[1] <= up4 - hi4;
				Res5[0] <= $signed({ hi4, {(D[1] - D[0]){1'b0}} }) + $signed({ 1'b0, lo4 });
			end
		end

		// Output
		for(genvar  pe = PE_BEG; pe < PE_END; pe++) begin
			assign	p[pe] = Res5[pe - PE_BEG + PE_REM];
		end

	end : genPipes

endmodule : mvu_8sx8u_dsp48
