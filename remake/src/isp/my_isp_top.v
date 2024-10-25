//**********************************************************************
// 	Project: 
//	File: isp_top.v
// 	Description: 
//	Author: Noa
//  Timestamp: 
//----------------------------------------------------------------------
// Code Revision History:
// Ver:		| Author 	| Mod. Date		| Changes Made:
// v1.0.0	| Noa		| xx/xx/20xx	| Initial version
//**********************************************************************
// `include "define.vh"
// `include "parameter.vh"
module isp_top #(
	parameter	DATA_WIDTH = 8,
	parameter	H_PIXELS = 1920,
	parameter   V_PIXELS = 1080
	)(
	input 							    clk, 
	input							    rstn,

	input 							    in_vs,
	input 							    in_hs,
	input 							    in_de,
	input [8-1:0] 			    		in_data,
	
	
	// output reg						    isp_rd_rdy,
	// input								isp_reg_wr_en,
	// input								isp_reg_rd_en,
	// input [15:0]						isp_reg_addr,
	// input [31:0]						isp_reg_wr_data,
	// output reg [31:0]					isp_reg_rd_data,
	input [3:0]                         isp_disp_mode,
	
	output 								out_clk,
	output	reg						    out_vs,
	output	reg						    out_de,
	output  reg [DATA_WIDTH-1:0] 		out_data_R,
	output  reg [DATA_WIDTH-1:0] 		out_data_G,
	output  reg [DATA_WIDTH-1:0] 		out_data_B	
);
//**********************************************************************
// --- Parameter
//**********************************************************************
	localparam NUM_CYCLE = 2;
	localparam NUM_FRAME = 8;
	
//**********************************************************************
// --- Inter Signal Declaration
//**********************************************************************
	reg vs_r0, vs_r1, vs_r2;
	reg hs_r0, hs_r1, hs_r2;
	// wire vs_posedge, vs_negedge;
	// reg vs_posedge_d;
	reg de_r0, de_r1, de_r2;
	// wire de_posedge, de_negedge;
	// reg de_posedge_d;
	reg [8-1:0] data_r0, data_r1, data_r2;

	// reg isp_reg_wr_en_r0, isp_reg_wr_en_r1, isp_reg_wr_en_r2;
	// reg isp_reg_rd_en_r0, isp_reg_rd_en_r1, isp_reg_rd_en_r2;
	// reg [31:0] isp_reg_wr_data_r0, isp_reg_wr_data_r1, isp_reg_wr_data_r2;
	// reg [15:0] isp_reg_addr_r0, isp_reg_addr_r1, isp_reg_addr_r2;
	// reg [3:0] isp_disp_mode_r0, isp_disp_mode_r1, isp_disp_mode_r2;
    // wire [31:0] isp_reg_rd_data_r;

	reg [3:0] cnt_cycle_in;

	wire isp_frame_sync_i/*synthesis syn_keep=1*/;
	wire isp_line_sync_i;
	wire isp_inpvalid_i;
	wire [8-1:0] isp_din;
	
    // wire aa_frame_sync_o;
	// wire aa_line_sync_o;
	// wire aa_outvalid_o;
    // wire [8-1:0] aa_dout;	
	
    wire cfa_frame_sync_i;
	wire cfa_line_sync_i;
	wire cfa_inpvalid_i;	
	wire [8-1:0] cfa_din;

	wire cfa_frame_sync_o;
	wire cfa_line_sync_o;
	wire cfa_outvalid_o;	
	wire [DATA_WIDTH-1:0] cfa_R_dout;
	wire [DATA_WIDTH-1:0] cfa_G_dout;
	wire [DATA_WIDTH-1:0] cfa_B_dout;

	wire ccm_frame_sync_o;
	wire ccm_line_sync_o;
	wire ccm_outvalid_o;	
	wire [DATA_WIDTH-1:0] ccm_R_dout;
	wire [DATA_WIDTH-1:0] ccm_G_dout;
	wire [DATA_WIDTH-1:0] ccm_B_dout;

    wire gamma_frame_sync_o;
	wire gamma_line_sync_o;
	wire gamma_outvalid_o;	
	wire [DATA_WIDTH-1:0] gamma_R_dout;
	wire [DATA_WIDTH-1:0] gamma_G_dout;
	wire [DATA_WIDTH-1:0] gamma_B_dout;
	
	reg [3:0] cnt_cycle_out;
	reg [15:0] cnt_out_h/*synthesis syn_keep=1*/;
    reg [15:0] cnt_out_v/*synthesis syn_keep=1*/;
    reg [DATA_WIDTH-1:0] reg_data_R;
    reg [DATA_WIDTH-1:0] reg_data_G;
    reg [DATA_WIDTH-1:0] reg_data_B;

    reg isp_frame_sync_o;
	reg isp_line_sync_o;
	reg isp_outvalid_o;	
	reg [DATA_WIDTH-1:0] isp_R_dout;
	reg [DATA_WIDTH-1:0] isp_G_dout;
	reg [DATA_WIDTH-1:0] isp_B_dout;

	reg reg_isp_de;
	reg reg_isp_vs;
	reg isp_de;
	reg isp_vs;

	reg [$clog2(NUM_FRAME):0] cnt_frame;

//**********************************************************************
// --- Module: 
// --- Description:	out_clk
//**********************************************************************
	assign out_clk=clk;
//**********************************************************************
// --- Module: sync up input data
// --- Description:	sync up input data
//**********************************************************************
	always @(posedge clk or negedge rstn) begin
		if(!rstn) begin
			vs_r0 <= 0;
			vs_r1 <= 0;
			vs_r2 <= 0;
		end
		else begin
			vs_r0 <= in_vs;
			vs_r1 <= vs_r0;
			vs_r2 <= vs_r1;
		end
	end

	always @(posedge clk or negedge rstn) begin
		if(!rstn) begin
			hs_r0 <= 0;
			hs_r1 <= 0;
			hs_r2 <= 0;
		end
		else begin
			hs_r0 <= in_hs;
			hs_r1 <= hs_r0;
			hs_r2 <= hs_r1;
		end
	end

	// assign vs_posedge = ~vs_r2 & vs_r1;
	// assign vs_negedge = ~vs_r1 & vs_r2;
	
	always @(posedge clk or negedge rstn) begin
		if(!rstn) begin
			de_r0 <= 0;
			de_r1 <= 0;
			de_r2 <= 0;
		end
		else begin
			de_r0 <= in_de;
			de_r1 <= de_r0;
			de_r2 <= de_r1;
		end
	end
	// assign de_posedge = ~de_r2 & de_r1;
	// assign de_negedge = ~de_r1 & de_r2;
	
	
	always @(posedge clk or negedge rstn) begin
		if(!rstn) begin
			data_r0 <= 0;
			data_r1 <= 0;
			data_r2 <= 0;
		end
		else begin
			data_r0 <= in_data;
			data_r1 <= data_r0;
			data_r2 <= data_r1;
		end
	end

            
	
    // always @(posedge clk or negedge rstn) begin
	// 	if(!rstn) begin
	// 		isp_reg_wr_en_r0 <= 0;
	// 		isp_reg_wr_en_r1 <= 0;
	// 		isp_reg_wr_en_r2 <= 0;

    //         isp_reg_rd_en_r0 <= 0;
	// 		isp_reg_rd_en_r1 <= 0;
	// 		isp_reg_rd_en_r2 <= 0;

    //         isp_reg_wr_data_r0 <= 0;
    //         isp_reg_wr_data_r1 <= 0; 
    //         isp_reg_wr_data_r2 <= 0;

    //         isp_reg_addr_r0 <= 0;
    //         isp_reg_addr_r1 <= 0;
    //         isp_reg_addr_r2 <= 0;

    //         isp_disp_mode_r0 <= 0;
    //         isp_disp_mode_r1 <= 0; 
    //         isp_disp_mode_r2 <= 0;
	// 	end
	// 	else begin
	// 		isp_reg_wr_en_r0 <= isp_reg_wr_en;
	// 		isp_reg_wr_en_r1 <= isp_reg_wr_en_r0;
	// 		isp_reg_wr_en_r2 <= isp_reg_wr_en_r1;

    //         isp_reg_rd_en_r0 <= isp_reg_rd_en;
	// 		isp_reg_rd_en_r1 <= isp_reg_rd_en_r0;
	// 		isp_reg_rd_en_r2 <= isp_reg_rd_en_r1;

    //         isp_reg_wr_data_r0 <= isp_reg_wr_data;
    //         isp_reg_wr_data_r1 <= isp_reg_wr_data_r0; 
    //         isp_reg_wr_data_r2 <= isp_reg_wr_data_r1;

    //         isp_reg_addr_r0 <= isp_reg_addr;
    //         isp_reg_addr_r1 <= isp_reg_addr_r0;
    //         isp_reg_addr_r2 <= isp_reg_addr_r1;

    //         isp_disp_mode_r0 <= isp_disp_mode;
    //         isp_disp_mode_r1 <= isp_disp_mode_r0; 
    //         isp_disp_mode_r2 <= isp_disp_mode_r1;
	// 	end
	// end

//**********************************************************************
// --- Module: 
// --- Description:	vs de => inpvalid, line_sync, frame_sync
//**********************************************************************
	// always @(posedge clk or negedge rstn) begin
	// 	if(!rstn) begin
	// 		vs_posedge_d <= 0;
	// 	end
	// 	else begin
	// 		vs_posedge_d <= vs_posedge;
	// 	end
	// end
	
	// always @(posedge clk or negedge rstn) begin
	// 	if(!rstn) begin
	// 		de_posedge_d <= 0;
	// 	end
	// 	else begin
	// 		de_posedge_d <= de_posedge;
	// 	end
	// end

	// assign isp_frame_sync_i = (vs_posedge_d)?1'b1:1'b0;
	// assign isp_line_sync_i = (de_posedge_d)?1'b1:1'b0;
	assign isp_frame_sync_i = vs_r2;
	assign isp_line_sync_i = hs_r2;
	assign isp_inpvalid_i = de_r2;
	assign isp_din = data_r2;

//**********************************************************************
// --- Module: AEAWB
// --- Description:	
//**********************************************************************
    // wire histo_rd_rdy;

	// AEAWB_Top AEAWB_top_inst(
	// 	.clk(clk), //input clk
	// 	.rstn(rstn), //input rstn
	// 	.ce(1'b1), //input ce
		
	// 	.waddr(isp_reg_addr_r2), //input [15:0] waddr
	// 	.wdata(isp_reg_wr_data_r2), //input [31:0] wdata
	// 	.wr(isp_reg_wr_en_r2), //input wr

	// 	.rdata(isp_reg_rd_data_r), //output [31:0] rdata
	// 	.rd(isp_reg_rd_en_r2), //input rd

	// 	.frame_sync(isp_frame_sync_i), //input frame_sync
	// 	.line_sync(isp_line_sync_i), //input line_sync
	// 	.inpvalid(isp_inpvalid_i), //input inpvalid
	// 	.din(isp_din), //input [7:0] din

	// 	.frame_sync_o(aa_frame_sync_o), //output frame_sync_o
	// 	.line_sync_o(aa_line_sync_o), //output line_sync_o
	// 	.outvalid(aa_outvalid_o), //output outvalid
	// 	.dout(aa_dout) //output [7:0] dout
	// );

//**********************************************************************
// --- Module: CFA
// --- Description:	
//**********************************************************************

	assign cfa_frame_sync_i =  isp_frame_sync_i;
	assign cfa_line_sync_i =   isp_line_sync_i;
	assign cfa_inpvalid_i =    isp_inpvalid_i;
	assign cfa_din =       	   isp_din;

	Color_Filter_Array_Interpolation_Top cfa_Top_inst(
		.clk(clk), //input clk
		.rstn(rstn), //input rstn

		.frame_sync(cfa_frame_sync_i), //input frame_sync
		.line_sync(cfa_line_sync_i), //input line_sync
		.inpvalid(cfa_inpvalid_i), //input inpvalid
		.din(cfa_din), //input [7:0] din
		
		.frame_sync_o(cfa_frame_sync_o), //output frame_sync_o
		.line_sync_o(cfa_line_sync_o), //output line_sync_o
		.outvalid(cfa_outvalid_o), //output outvalid
		
		.R_dout(cfa_R_dout), //output [7:0] R_dout
		.G_dout(cfa_G_dout), //output [7:0] G_dout
		.B_dout(cfa_B_dout) //output [7:0] B_dout
	);

//**********************************************************************
// --- Module: CCM
// --- Description:	
//**********************************************************************
    Color_Correction_Matrix_Top ccm_Top_inst(
		.clk(clk), //input clk
		.rstn(rstn), //input rstn

		.frame_sync(cfa_frame_sync_o), //input frame_sync
		.line_sync(cfa_line_sync_o), //input line_sync
		.inpvalid(cfa_outvalid_o), //input inpvalid
		
		.R_din(cfa_R_dout), //input [7:0] R_din
		.G_din(cfa_G_dout), //input [7:0] G_din
		.B_din(cfa_B_dout), //input [7:0] B_din
		
		.wr(1'b0), //input wr
		.waddr(16'd0), //input [15:0] waddr
		.wdata(32'd0), //input [31:0] wdata
		
		.frame_sync_o(ccm_frame_sync_o), //output frame_sync_o
		.line_sync_o(ccm_line_sync_o), //output line_sync_o
		.outvalid(ccm_outvalid_o), //output outvalid
		
		.R_dout(ccm_R_dout), //output [7:0] R_dout
		.G_dout(ccm_G_dout), //output [7:0] G_dout
		.B_dout(ccm_B_dout) //output [7:0] B_dout
	);

//**********************************************************************
// --- Module: GAMMA
// --- Description:	
//**********************************************************************
    
	Gamma_Correction_Top Gamma_Top_inst(
		.clk(clk), //input clk
		.rstn(rstn), //input rstn

		.frame_sync(ccm_frame_sync_o), //input frame_sync
		.line_sync(ccm_line_sync_o), //input line_sync
		.inpvalid(ccm_outvalid_o), //input inpvalid
		
		.R_din(ccm_R_dout), //input [7:0] R_din
		.G_din(ccm_G_dout), //input [7:0] G_din
		.B_din(ccm_B_dout), //input [7:0] B_din
		
		.wr(1'b0), //input wr
		.waddr(16'd0), //input [15:0] waddr
		.wdata(32'd0), //input [31:0] wdata
		
		.frame_sync_o(gamma_frame_sync_o), //output frame_sync_o
		.line_sync_o(gamma_line_sync_o), //output line_sync_o
		.outvalid(gamma_outvalid_o), //output outvalid
		
		.R_dout(gamma_R_dout), //output [7:0] R_dout
		.G_dout(gamma_G_dout), //output [7:0] G_dout
		.B_dout(gamma_B_dout) //output [7:0] B_dout
	);
	


//**********************************************************************
// --- Module: function switch
// --- Description:	
//**********************************************************************
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            isp_frame_sync_o <=   0;
            isp_line_sync_o <=    0;
            isp_outvalid_o <=       0;
            isp_R_dout <=         0;
            isp_G_dout <=         0;
            isp_B_dout <=         0;
        end 
        else begin
            casez(isp_disp_mode)
            4'h0: begin									// GAMMA
                isp_frame_sync_o <=   gamma_frame_sync_o;
                isp_line_sync_o <=    gamma_line_sync_o;
                isp_outvalid_o <=     gamma_outvalid_o;
                isp_R_dout <=         gamma_R_dout;
                isp_G_dout <=         gamma_G_dout;
                isp_B_dout <=         gamma_B_dout;
            end
            4'h1: begin									// RAW
                isp_frame_sync_o <=   isp_frame_sync_i;
                isp_line_sync_o <=    isp_line_sync_i;
                isp_outvalid_o <=     isp_inpvalid_i;
                isp_R_dout <=         isp_din;
                isp_G_dout <=         isp_din;
                isp_B_dout <=         isp_din;
            end
            4'h2: begin									// CFA
                isp_frame_sync_o <=   cfa_frame_sync_o;
                isp_line_sync_o <=    cfa_line_sync_o;
                isp_outvalid_o <=     cfa_outvalid_o;
                isp_R_dout <=         cfa_R_dout;
                isp_G_dout <=         cfa_G_dout;
                isp_B_dout <=         cfa_B_dout;		
            end	
            4'h4: begin									// CCM
                isp_frame_sync_o <=   ccm_frame_sync_o;
                isp_line_sync_o <=    ccm_line_sync_o;
                isp_outvalid_o <=     ccm_outvalid_o;
                isp_R_dout <=         ccm_R_dout;
                isp_G_dout <=         ccm_G_dout;
                isp_B_dout <=         ccm_B_dout;
            end
            default: begin
                isp_frame_sync_o <=   gamma_frame_sync_o;
                isp_line_sync_o <=    gamma_line_sync_o;
                isp_outvalid_o <=     gamma_outvalid_o;
                isp_R_dout <=         gamma_R_dout;
                isp_G_dout <=         gamma_G_dout;
                isp_B_dout <=         gamma_B_dout;
            end
            endcase
        end
    end


//**********************************************************************
// --- Module: 
// --- Description:	frame_sync, line_sync, outvalid => vs, de
//**********************************************************************
//    always @(posedge clk or negedge rstn) begin
// 		if(!rstn) begin
// 			cnt_cycle_out <= NUM_CYCLE-1;
// 		end
// 		else begin
// 			if(isp_outvalid_o && cnt_cycle_out == NUM_CYCLE-1)
// 				cnt_cycle_out <= 0;
// 			else if(cnt_cycle_out == NUM_CYCLE-1)
// 				cnt_cycle_out <= NUM_CYCLE-1;
// 			else 
// 				cnt_cycle_out <= cnt_cycle_out + 4'd1;
// 		end
// 	end

    // always @(posedge clk or negedge rstn) begin
    //     if(!rstn) begin
    //         cnt_out_h <= H_PIXELS-1;
    //     end
	// 	else if(isp_line_sync_o)
	// 		cnt_out_h <= 0;
    //     else if(isp_outvalid_o) begin
    //         if(cnt_out_h == H_PIXELS-1) 
    //             cnt_out_h <= H_PIXELS-1;
    //         else
    //             cnt_out_h <= cnt_out_h + 16'd1;
    //     end
    // end 

    // always @(posedge clk or negedge rstn) begin
    //     if(!rstn) begin
    //         cnt_out_v <= V_PIXELS;
    //     end
	// 	else if(isp_frame_sync_o) begin
	// 		cnt_out_v <= 0;
	// 	end
    //     else if(isp_line_sync_o) begin
    //         if(cnt_out_v == V_PIXELS) 
    //             cnt_out_v <= V_PIXELS;
    //         else
    //             cnt_out_v <= cnt_out_v + 16'd1;
    //     end
    // end 

//    always @(posedge clk or negedge rstn) begin
//         if(!rstn) begin
//             isp_de <= 1'b0;
//         end
//         else begin
//             if(isp_line_sync_o)
//                 isp_de <= 1'b1;
//             else if(isp_de == 1'b1 && cnt_out_h == H_PIXELS-1)
//                 isp_de <= 1'b0;
    
//         end
//     end


    // always @(posedge clk or negedge rstn) begin
    //     if(!rstn) begin
    //         isp_vs <= 1'b0;
    //     end
    //     else begin
    //         if(isp_frame_sync_o)
    //             isp_vs <= 1'b1;
    //         else if(isp_vs == 1'b1 && cnt_out_v == V_PIXELS && cnt_out_h == H_PIXELS-1)
    //              isp_vs <= 1'b0;
    //     end
    // end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            reg_data_R <= 0;
            out_data_R <= 0;

            reg_data_G <= 0;
            out_data_G <= 0;

            reg_data_B <= 0;
            out_data_B <= 0;
            
//            isp_rd_rdy <= 1'b0;
        end
        else begin
            reg_data_R <= isp_R_dout;
            out_data_R <= reg_data_R;

            reg_data_G <= isp_G_dout;
            out_data_G <= reg_data_G;

            reg_data_B <= isp_B_dout;
            out_data_B <= reg_data_B;

//            isp_rd_rdy <= 1'd1;
        end
    end

	// always @(posedge clk or negedge rstn) begin
	// 	if(!rstn) begin
	// 		isp_reg_rd_data <= 32'hffff_ffff;
	// 	end
	// 	else if(isp_reg_rd_en_r2) begin
	// 		isp_reg_rd_data <= isp_reg_rd_data_r;
	// 	end
	// end


	always @(posedge clk or negedge rstn) begin
		if(!rstn) begin
			out_de <= 1'b0;
			out_vs <= 1'b0;
		end
		else begin
			out_de <= isp_outvalid_o;
			out_vs <= isp_frame_sync_o;
		end
	end

endmodule