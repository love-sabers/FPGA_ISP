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
	
	output 								out_clk,
	output	reg						    out_vsync,
	output	reg						    out_hsync,
	output	reg						    out_den,
	output  reg [8-1:0] 				out_data_R,
	output  reg [8-1:0] 				out_data_G,
	output  reg [8-1:0] 				out_data_B
);

	//clk
	assign out_clk=clk;

	wire 		in_vsync/* synthesis syn_keep= 1 */;
    wire 		in_hsync/* synthesis syn_keep= 1 */;
    wire 		in_den/* synthesis syn_keep= 1 */;
    wire [7:0] 	in_data/* synthesis syn_keep= 1 */;


	//cfa
	wire 		cfa_vsync/* synthesis syn_keep= 1 */;
    wire 		cfa_hsync/* synthesis syn_keep= 1 */;
    wire 		cfa_den/* synthesis syn_keep= 1 */;
    wire [7:0] 	cfa_R/* synthesis syn_keep= 1 */;
    wire [7:0] 	cfa_G/* synthesis syn_keep= 1 */;
    wire [7:0] 	cfa_B/* synthesis syn_keep= 1 */;

    cfa_top#(
        .source_h	(source_h),
	    .source_v	(source_v)
    )cfa_top_inst(
        .clk		(clk),
        .reset_n	(reset_n),
        .in_vsync	(in_vsync),		
        .in_hsync	(in_hsync),		
        .in_den		(in_den),			
        .in_raw		(in_data), 	

        .out_vsync	(cfa_vsync),		
        .out_hsync	(cfa_hsync),		
        .out_den	(cfa_den),			
        .out_data_R	(cfa_R), 	
        .out_data_G	(cfa_G),
        .out_data_B	(cfa_B)
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

        .out_vsync	(gma_vsync),		
        .out_hsync	(gma_hsync),		
        .out_den	(gma_den),			
        .out_data_R	(gma_R), 	
        .out_data_G	(gma_G),
        .out_data_B	(gma_B)
    );

    // Enhance outputs
    wire        enhance_vsync;
    wire        enhance_hsync;
    wire        enhance_den;
    wire [7:0]  enhance_R;
    wire [7:0]  enhance_G;
    wire [7:0]  enhance_B;

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
		if(~reset_n)begin
			out_vsync	<=1'd0;
			out_hsync	<=1'd0;
			out_den		<=1'd0;
			out_data_R	<=8'd0;
			out_data_G	<=8'd0;
			out_data_B	<=8'd0;
		end else begin
			casez(isp_disp_mode)/* synthesis parallel_case */
				4'h0: begin									// RAW
					out_vsync 	<=  in_vsync;
					out_hsync 	<=  in_hsync;
					out_den    	<=  in_den;
					out_data_R 	<= 	in_data;
					out_data_G 	<=  in_data;
					out_data_B 	<=  in_data;
				end
				4'h1: begin									// CFA
					out_vsync 	<=  cfa_vsync;
					out_hsync 	<=  cfa_hsync;
					out_den    	<=  cfa_den;
					out_data_R 	<= 	cfa_R;
					out_data_G 	<=  cfa_G;
					out_data_B 	<=  cfa_B;
				end
				4'h2: begin									// AWB
					out_vsync 	<=  awb_vsync;
					out_hsync 	<=  awb_hsync;
					out_den    	<=  awb_den;
					out_data_R 	<= 	awb_R;
					out_data_G 	<=  awb_G;
					out_data_B 	<=  awb_B;		
				end	
				4'h3: begin									// CCM
					out_vsync 	<=  ccm_vsync;
					out_hsync 	<=  ccm_hsync;
					out_den    	<=  ccm_den;
					out_data_R 	<= 	ccm_R;
					out_data_G 	<=  ccm_G;
					out_data_B 	<=  ccm_B;
				end
				4'h4: begin									// CCM
					out_vsync 	<=  gma_vsync;
					out_hsync 	<=  gma_hsync;
					out_den    	<=  gma_den;
					out_data_R 	<= 	gma_R;
					out_data_G 	<=  gma_G;
					out_data_B 	<=  gma_B;
				end
                4'h5: begin  // Enhancement
                    out_vsync   <= enhance_vsync;
                    out_hsync   <= enhance_hsync;
                    out_den     <= enhance_den;
                    out_data_R  <= enhance_R;
                    out_data_G  <= enhance_G;
                    out_data_B  <= enhance_B;
                end
				default: begin                              // debug
					out_vsync 	<=  in_vsync;
					out_hsync 	<=  in_hsync;
					out_den    	<=  in_den;
					out_data_R 	<= 	8'h00;
					out_data_G 	<=  8'hff;
					out_data_B 	<=  8'h00;
				end
			endcase
		end
	end


endmodule