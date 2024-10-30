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


	//cfa
	wire 		cfa_vsync;
    wire 		cfa_hsync;
    wire 		cfa_den;
    wire [7:0] 	cfa_R;
    wire [7:0] 	cfa_G;
    wire [7:0] 	cfa_B;

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
	wire 		awb_vsync;
    wire 		awb_hsync;
    wire 		awb_den;
    wire [7:0] 	awb_R;
    wire [7:0] 	awb_G;
    wire [7:0] 	awb_B;

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
	wire 		ccm_vsync;
    wire 		ccm_hsync;
    wire 		ccm_den;
    wire [7:0] 	ccm_R;
    wire [7:0] 	ccm_G;
    wire [7:0] 	ccm_B;

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


	always @(posedge clk or negedge reset_n) begin
		if(~reset_n)begin
			out_vsync	<=1'd0;
			out_hsync	<=1'd0;
			out_den		<=1'd0;
			out_data_R	<=8'd0;
			out_data_G	<=8'd0;
			out_data_B	<=8'd0;
		end else begin
			casez(isp_disp_mode)
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
				// 4'h4: begin									// CCM
				// 	out_vsync 	<=  in_vsync;
				// 	out_hsync 	<=  in_hsync;
				// 	out_den    	<=  in_den;
				// 	out_data_R 	<= 	in_R;
				// 	out_data_G 	<=  in_G;
				// 	out_data_B 	<=  in_B;
				// end
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