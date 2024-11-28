//RAW 输入 → DPC → BLC(×) → BNR → DGAIN(×) → DEMOSAIC(×) → cfa → AWB → WB(×) → CCM → (CSC → 2DNR → EE) → Gamma
module isp_top #(
	parameter	source_h = 1024,
	parameter   source_v = 1024
	)(
	input 							    clk, 
	input							    reset_n,

	input 							    in_vsync,
	input 							    in_hsync,
	input 							    in_den,
	input [8-1:0] 			    		in_data,
	
	input [3:0]                         isp_disp_mode,
    input [1:0]                         gamma_type,
	
	output 								out_clk,
	output	reg						    out_vsync,
	output	reg						    out_hsync,
	output	reg						    out_den,
	output  reg [8-1:0] 				out_data_R,
	output  reg [8-1:0] 				out_data_G,
	output  reg [8-1:0] 				out_data_B
);

	// clk
    assign out_clk = clk;

    wire        in_vsync/* synthesis syn_keep= 1 */;
    wire        in_hsync/* synthesis syn_keep= 1 */;
    wire        in_den/* synthesis syn_keep= 1 */;
    wire [7:0]  in_data/* synthesis syn_keep= 1 */;

    // DPC (Defective Pixel Correction)
    wire dpc_vsync/* synthesis syn_keep= 1 */;
    wire dpc_hsync/* synthesis syn_keep= 1 */;
    wire dpc_den/* synthesis syn_keep= 1 */;
    wire [7:0] dpc_data/* synthesis syn_keep= 1 */;

    isp_dpc #(
        .BITS(8),
        .WIDTH(source_h),
        .HEIGHT(source_v),
        .BAYER(0)  // 选择适合的BAYER格式
    ) dpc_inst (
        .pclk(clk),
        .rst_n(reset_n),
        .threshold(8'd50),  // 设定阈值
        .in_den(in_den),
        .in_href(in_hsync),
        .in_vsync(in_vsync),
        .in_raw(in_data),
    
        .out_href(dpc_hsync),
        .out_vsync(dpc_vsync),
        .out_raw(dpc_data),
        .out_den(dpc_den)
    );

    // BNR (Noise Reduction) Module
    wire bnr_vsync/* synthesis syn_keep= 1 */;
    wire bnr_hsync/* synthesis syn_keep= 1 */;
    wire bnr_den = dpc_den/* synthesis syn_keep= 1 */;
    wire [7:0] bnr_data/* synthesis syn_keep= 1 */;

    isp_bnr #(
        .BITS(8),
        .WIDTH(source_h),
        .HEIGHT(source_v),
        .BAYER(0)
    ) bnr_inst (
        .pclk(clk),
        .rst_n(reset_n),
        .nr_level(4'd2), // 选择合适的噪声减少级别
        .in_href(dpc_hsync),
        .in_vsync(dpc_vsync),
        .in_raw(dpc_data),

        .out_href(bnr_hsync),
        .out_vsync(bnr_vsync),
        .out_raw(bnr_data)
    );

    // CFA (Color Filter Array) Module
    wire        cfa_vsync/* synthesis syn_keep= 1 */;
    wire        cfa_hsync/* synthesis syn_keep= 1 */;
    wire        cfa_den/* synthesis syn_keep= 1 */;
    wire [7:0]  cfa_R/* synthesis syn_keep= 1 */;
    wire [7:0]  cfa_G/* synthesis syn_keep= 1 */;
    wire [7:0]  cfa_B/* synthesis syn_keep= 1 */;

    cfa_top #(
        .source_h(source_h),
        .source_v(source_v)
    ) cfa_top_inst (
        .clk(clk),
        .reset_n(reset_n),
        .in_vsync(bnr_vsync),
        .in_hsync(bnr_hsync),
        .in_den(bnr_den),
        .in_raw(bnr_data),

        .out_vsync(cfa_vsync),
        .out_hsync(cfa_hsync),
        .out_den(cfa_den),
        .out_data_R(cfa_R),
        .out_data_G(cfa_G),
        .out_data_B(cfa_B)
    );

	//awb
	wire 		awb_vsync/* synthesis syn_keep= 1 */;
    wire 		awb_hsync/* synthesis syn_keep= 1 */;
    wire 		awb_den/* synthesis syn_keep= 1 */;
    wire [7:0] 	awb_R/* synthesis syn_keep= 1 */;
    wire [7:0] 	awb_G/* synthesis syn_keep= 1 */;
    wire [7:0] 	awb_B/* synthesis syn_keep= 1 */;

	awb_top#(
        .source_h	(source_h),
	    .source_v	(source_v)
    )awb_top_inst(
        .clk		(clk),
        .reset_n	(reset_n),
        .in_vsync	(cfa_vsync),		
        .in_hsync	(cfa_hsync),		
        .in_den		(cfa_den),			
        .in_data_R	(cfa_R), 	
		.in_data_G	(cfa_G), 	
		.in_data_B	(cfa_B), 	

        .out_vsync	(awb_vsync),		
        .out_hsync	(awb_hsync),		
        .out_den	(awb_den),			
        .out_data_R	(awb_R), 	
        .out_data_G	(awb_G),
        .out_data_B	(awb_B)
    );

	//ccm
	wire 		ccm_vsync/* synthesis syn_keep= 1 */;
    wire 		ccm_hsync/* synthesis syn_keep= 1 */;
    wire 		ccm_den/* synthesis syn_keep= 1 */;
    wire [7:0] 	ccm_R/* synthesis syn_keep= 1 */;
    wire [7:0] 	ccm_G/* synthesis syn_keep= 1 */;
    wire [7:0] 	ccm_B/* synthesis syn_keep= 1 */;

	ccm_top#(
        .source_h	(source_h),
	    .source_v	(source_v)
    )ccm_top_inst(
        .clk		(clk),
        .reset_n	(reset_n),
        .in_vsync	(awb_vsync),		
        .in_hsync	(awb_hsync),		
        .in_den		(awb_den),			
        .in_data_R	(awb_R), 	
		.in_data_G	(awb_G), 	
		.in_data_B	(awb_B), 	

        .out_vsync	(ccm_vsync),		
        .out_hsync	(ccm_hsync),		
        .out_den	(ccm_den),			
        .out_data_R	(ccm_R), 	
        .out_data_G	(ccm_G),
        .out_data_B	(ccm_B)
    );

	//gamma
	wire 		gma_vsync/* synthesis syn_keep= 1 */;
    wire 		gma_hsync/* synthesis syn_keep= 1 */;
    wire 		gma_den/* synthesis syn_keep= 1 */;
    wire [7:0] 	gma_R/* synthesis syn_keep= 1 */;
    wire [7:0] 	gma_G/* synthesis syn_keep= 1 */;
    wire [7:0] 	gma_B/* synthesis syn_keep= 1 */;

	gma_top#(
        .source_h	(source_h),
	    .source_v	(source_v)
	)gma_top_inst(
        .clk		(clk),
        .reset_n	(reset_n),
        .in_vsync	(ccm_vsync),		
        .in_hsync	(ccm_hsync),		
        .in_den		(ccm_den),			
        .in_data_R	(ccm_R), 	
		.in_data_G	(ccm_G), 	
		.in_data_B	(ccm_B), 	
        .gamma_type (gamma_type),

        .out_vsync	(gma_vsync),		
        .out_hsync	(gma_hsync),		
        .out_den	(gma_den),			
        .out_data_R	(gma_R), 	
        .out_data_G	(gma_G),
        .out_data_B	(gma_B)
    );

    // Enhance outputs
    wire        enhance_vsync/* synthesis syn_keep= 1 */;
    wire        enhance_hsync/* synthesis syn_keep= 1 */;
    wire        enhance_den/* synthesis syn_keep= 1 */;
    wire [7:0]  enhance_R/* synthesis syn_keep= 1 */;
    wire [7:0]  enhance_G/* synthesis syn_keep= 1 */;
    wire [7:0]  enhance_B/* synthesis syn_keep= 1 */;

    // Top enhancement integration
    top_camera_integration enhance_module (
        .clk(clk),
        .reset_n(reset_n),
        .in_vsync(gma_vsync),
        .in_hsync(gma_hsync),
        .in_den(gma_den),
        .cam_data({gma_R, gma_G, gma_B}), // Concatenate RGB inputs
        .out_vsync(enhance_vsync),
        .out_hsync(enhance_hsync),
        .out_den(enhance_den),
        .enhance_image({enhance_R, enhance_G, enhance_B})
    );

    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            out_vsync   <= 1'd0;
            out_hsync   <= 1'd0;
            out_den     <= 1'd0;
            out_data_R  <= 8'd0;
            out_data_G  <= 8'd0;
            out_data_B  <= 8'd0;
        end else begin
            casez (isp_disp_mode) /* synthesis parallel_case */
                4'h0: begin  // RAW
                    out_vsync   <= in_vsync;
                    out_hsync   <= in_hsync;
                    out_den     <= in_den;
                    out_data_R  <= in_data;
                    out_data_G  <= in_data;
                    out_data_B  <= in_data;
                end
                4'h1: begin  // DPC (Defective Pixel Correction)
                    out_vsync   <= dpc_vsync;
                    out_hsync   <= dpc_hsync;
                    out_den     <= dpc_den;
                    out_data_R  <= dpc_data;
                    out_data_G  <= dpc_data;
                    out_data_B  <= dpc_data;
                end
                4'h2: begin  // BNR (Black Level Noise Reduction)
                    out_vsync   <= bnr_vsync;
                    out_hsync   <= bnr_hsync;
                    out_den     <= bnr_den;
                    out_data_R  <= bnr_data;
                    out_data_G  <= bnr_data;
                    out_data_B  <= bnr_data;
                end
                4'h3: begin  // CFA (Color Filter Array)
                    out_vsync   <= cfa_vsync;
                    out_hsync   <= cfa_hsync;
                    out_den     <= cfa_den;
                    out_data_R  <= cfa_R;
                    out_data_G  <= cfa_G;
                    out_data_B  <= cfa_B;
                end
                4'h4: begin  // AWB (Auto White Balance)
                    out_vsync   <= awb_vsync;
                    out_hsync   <= awb_hsync;
                    out_den     <= awb_den;
                    out_data_R  <= awb_R;
                    out_data_G  <= awb_G;
                    out_data_B  <= awb_B;
                end
                4'h5: begin  // CCM (Color Correction Matrix)
                    out_vsync   <= ccm_vsync;
                    out_hsync   <= ccm_hsync;
                    out_den     <= ccm_den;
                    out_data_R  <= ccm_R;
                    out_data_G  <= ccm_G;
                    out_data_B  <= ccm_B;
                end
                4'h6: begin  // GMA (Gamma Correction)
                    out_vsync   <= gma_vsync;
                    out_hsync   <= gma_hsync;
                    out_den     <= gma_den;
                    out_data_R  <= gma_R;
                    out_data_G  <= gma_G;
                    out_data_B  <= gma_B;
                end
                4'h7: begin  // Enhancement
                    out_vsync   <= enhance_vsync;
                    out_hsync   <= enhance_hsync;
                    out_den     <= enhance_den;
                    out_data_R  <= enhance_R;
                    out_data_G  <= enhance_G;
                    out_data_B  <= enhance_B;
                end
                default: begin  // Debug (default case)
                    out_vsync   <= in_vsync;
                    out_hsync   <= in_hsync;
                    out_den     <= in_den;
                    out_data_R  <= 8'h00;
                    out_data_G  <= 8'hff;
                    out_data_B  <= 8'h00;
                end
            endcase
        end
    end
endmodule