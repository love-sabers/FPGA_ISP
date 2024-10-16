//**********************************************************************
// 	Project: 
//	File: ahb_isp.v
// 	Description: 
//	Author: Noa
//  Timestamp: 
//----------------------------------------------------------------------
// Code Revision History:
// Ver:		| Author 	| Mod. Date		| Changes Made:
// v1.0.0	| Noa		| xx/xx/20xx	| Initial version
//**********************************************************************
`resetall

module ahb_isp (
	output	wire	[31:0]		AHB_HRDATA,
	output	wire				AHB_HREADY,
	output	wire	[ 1:0]		AHB_HRESP,
	input	wire	[ 1:0]  	AHB_HTRANS,
	input	wire	[ 2:0]  	AHB_HBURST,
	input	wire	[ 3:0]  	AHB_HPROT,
	input	wire	[ 2:0]		AHB_HSIZE,
	input	wire				AHB_HWRITE,
	input	wire				AHB_HMASTLOCK,
	input	wire	[ 3:0]		AHB_HMASTER,
	input	wire	[31:0]		AHB_HADDR,
	input	wire	[31:0]  	AHB_HWDATA,
	input	wire				AHB_HSEL,
	input	wire				AHB_HCLK,
	input	wire				AHB_HRESETn,
	
	output	reg					isp_reg_rd_en,
	output	reg					isp_reg_wr_en,
	output  reg 	[15:0]		isp_reg_addr,
	output  reg 	[31:0]		isp_reg_wr_data,
	input   	 	[31:0]		isp_reg_rd_data,
	input						isp_rd_rdy,
	input						isp_vs,
	output	reg		[3:0]		isp_disp_mode,
		
	output	wire 				update_valid,
	output	reg 	 			cam_awb_en,
	output	reg 	 [15:0]		cam_awb_gain_r,
	output	reg 	 [15:0]		cam_awb_gain_g,
	output	reg 	 [15:0]		cam_awb_gain_b,
	output	reg 	 			cam_agc_en,
	output	reg 	 [15:0]		cam_agc_gain,
	output	reg 	 			cam_aec_en,
	output	reg 	 [19:0]		cam_aec_exposure
);
//**********************************************************************
// --- Parameter
//**********************************************************************
//The AHB BUS is always ready
assign AHB_HREADY = 1'b1; //ready signal, slave to MCU master
//Response OKAY
assign AHB_HRESP  = 2'b0;//response signal, slave to MCU master

localparam IMAGE_HEIGHT= 480;
localparam NUM_FRAME = 16;
//**********************************************************************
// --- Inter Signal Declaration
//**********************************************************************
//Define Reg for AHB BUS
reg [31:0]  ahb_address;
reg [31:0]  ahb_data;
reg 		ahb_control;
reg         ahb_sel;
reg         ahb_htrans;

reg 		ahb_ready;
reg [31:0]  ahb_rdata;

reg [3:0]   isp_cmd;
reg 		histo_load_flag;
reg 		histo_get_flag;

reg [15:0]	isp_reg_wr_addr;
reg [15:0]	isp_reg_rd_addr;
reg [15:0]	isp_histo_rd_addr;

reg isp_vs_r0;
reg isp_vs_r1;
reg isp_vs_r2;
wire  isp_frame_sync;
wire  isp_frame_neg;

reg isp_de_r0;
reg isp_de_r1;
wire  isp_line_sync;

reg update_pre;

reg [31:0] isp_reg_rd_data_r0, isp_reg_rd_data_r1, isp_reg_rd_data_r2;
reg  isp_rd_rdy_r0, isp_rd_rdy_r1, isp_rd_rdy_r2;

//**********************************************************************
// --- Main Code
//**********************************************************************
always @(posedge AHB_HCLK or negedge AHB_HRESETn) begin
	if(~AHB_HRESETn) begin
		ahb_address  <= 32'b0;
		ahb_control  <= 1'b0;
        ahb_sel      <= 1'b0;
        ahb_htrans   <= 1'b0;
	end
	else  begin            	
		ahb_address  <= AHB_HADDR;
		ahb_control  <= AHB_HWRITE;
        ahb_sel      <= AHB_HSEL;
        ahb_htrans   <= AHB_HTRANS[1];
	end
end

wire write_enable = ahb_htrans & ahb_control    & ahb_sel;
wire read_enable  = ahb_htrans & (!ahb_control) & ahb_sel;


// --- write data to AHB bus
always @(posedge AHB_HCLK or negedge AHB_HRESETn) begin
	if(~AHB_HRESETn) begin
		isp_disp_mode 	<= 4'h0;
        isp_cmd         <= 4'h0;
		cam_awb_en   	<= 1'b0;
		cam_awb_gain_r  <= 16'h0400;
		cam_awb_gain_g  <= 16'h0400;
		cam_awb_gain_b  <= 16'h0400;
		cam_agc_en  	<= 1'b1;
		cam_agc_gain  	<= 16'h00ff;
        cam_aec_en      <= 1'b1;
        cam_aec_exposure<= 20'h0_0fff;
		isp_reg_wr_data <= 0;
		
	end
	else if(write_enable) begin
		if(ahb_address[11:8] == 4'h0) begin							// ISP
			casez(ahb_address[7:0])
				8'h00: 	isp_cmd <= AHB_HWDATA[3:0];
				8'h10:	isp_disp_mode <= AHB_HWDATA[3:0];
			endcase
		end
		else if(ahb_address[11:8] == 4'h1) begin					// Sensor / CFA
			casez(ahb_address[7:0])
				8'h00: 	cam_awb_en <= AHB_HWDATA[0];
				8'h04: 	cam_awb_gain_r <= AHB_HWDATA[15:0];
				8'h08: 	cam_awb_gain_g <= AHB_HWDATA[15:0];
				8'h0C: 	cam_awb_gain_b <= AHB_HWDATA[15:0];
				8'h10: 	cam_agc_en <= AHB_HWDATA[0];
				8'h14: 	cam_agc_gain <= AHB_HWDATA[15:0];
				8'h18: 	cam_aec_en <= AHB_HWDATA[0];
				8'h1C: 	cam_aec_exposure <= AHB_HWDATA[19:0];
			endcase
		end
		else if(ahb_address[11:8] == 4'h2) begin					// CCM
			isp_reg_wr_data <= AHB_HWDATA;
		end
		else if(ahb_address[11:8] == 4'h3) begin					// GAMMA
			isp_reg_wr_data <= AHB_HWDATA;
		end
		else if(ahb_address[11:8] == 4'h4) begin					// AEAWB
			isp_reg_wr_data <= AHB_HWDATA;
		end
	end
	else begin
		isp_cmd <= 4'h0;
	end
end

always @(posedge AHB_HCLK or negedge AHB_HRESETn) begin
    if(~AHB_HRESETn) begin
		isp_vs_r0 <= 1'b0;
		isp_vs_r1 <= 1'b0;
		isp_vs_r2 <= 1'b0;
	end
    else begin
        isp_vs_r0 <= isp_vs;
        isp_vs_r1 <= isp_vs_r0;
        isp_vs_r2 <= isp_vs_r1;
    end
end
assign isp_frame_sync = ~isp_vs_r2 & isp_vs_r1;
assign isp_frame_neg = isp_vs_r2 & ~isp_vs_r1;

reg [6:0] cnt_frame;
always @(posedge AHB_HCLK or negedge AHB_HRESETn) begin
	if(~AHB_HRESETn) begin
		cnt_frame <= NUM_FRAME-1;
	end
	else if(isp_frame_sync && cnt_frame == NUM_FRAME-1) begin
		cnt_frame <= 0;
	end
	else if(isp_frame_sync) begin
		cnt_frame <= cnt_frame + 7'd1;
	end

end

always @(posedge AHB_HCLK or negedge AHB_HRESETn) begin
	if(~AHB_HRESETn) begin
		update_pre <= 1'b0;
	end
	else if(write_enable & (ahb_address[11:8] == 4'h1)) begin
		update_pre <= 1'b1;
	end
    else if(isp_frame_sync) begin
        update_pre <= 1'b0;
    end
end
assign update_valid = update_pre & isp_frame_sync ;

always @(posedge AHB_HCLK or negedge AHB_HRESETn) begin
	if(~AHB_HRESETn) begin
		isp_reg_addr <= 1'b0;
	end
	else if(write_enable && ahb_address[11:0] == 8'h004) begin
		isp_reg_addr <= AHB_HWDATA[15:0];
	end
	else if(write_enable) begin
		isp_reg_addr <= {4'b0, ahb_address[11:0]};
	end
	else if(histo_get_flag) begin
		isp_reg_addr <= isp_histo_rd_addr;
	end
end

always @(posedge AHB_HCLK or negedge AHB_HRESETn) begin
	if(~AHB_HRESETn) begin
		isp_reg_wr_en <= 1'b0;
	end
	else begin
		isp_reg_wr_en <= write_enable;
	end
end

always @(posedge AHB_HCLK or negedge AHB_HRESETn) begin
	if(~AHB_HRESETn) begin
		isp_reg_rd_en <= 1'b0;
	end
	else begin
		if(isp_reg_addr[11:8] == 4'h4) 
            isp_reg_rd_en <= isp_reg_wr_en;
        else if(isp_reg_addr[11:8] == 4'h5)
            isp_reg_rd_en <= histo_load_flag | histo_get_flag;
	end
end


// --- read data to AHB bus
always @(*) begin
	if(read_enable)  begin	
        if(isp_reg_addr[11:0] == 12'h460)
			ahb_rdata = {31'b0, isp_rd_rdy_r2};
		else if(isp_reg_addr[11:8] == 4'h4 || isp_reg_addr[11:8] == 4'h5)
			ahb_rdata = isp_reg_rd_data_r2;
		else 
			ahb_rdata = 32'hFFFFFFFF;
	end
    else begin
        ahb_rdata = 32'hFFFFFFFF;
    end
end


assign AHB_HRDATA = ahb_rdata;

always @(posedge AHB_HCLK or negedge AHB_HRESETn) begin
	if(~AHB_HRESETn) begin
		histo_load_flag <= 1'b0;
		histo_get_flag <= 1'b0;
	end
	else begin
		histo_load_flag <= (write_enable && ahb_address[11:0] == 12'h004) ? 1'b1:1'b0;
		histo_get_flag <= (read_enable && ahb_address[11:0] == 12'h500) ? 1'b1:1'b0;
	end

end

always @(posedge AHB_HCLK or negedge AHB_HRESETn) begin
	if(~AHB_HRESETn) begin
		isp_histo_rd_addr <= 16'h0;
	end
	else if(write_enable && ahb_address[11:0] == 12'h004) begin
		isp_histo_rd_addr <= AHB_HWDATA[15:0];
	end
	else if(isp_histo_rd_addr == 16'h5ff) begin
		isp_histo_rd_addr <= 16'h5ff;
	end
	else if(read_enable && ahb_address[11:0] == 12'h500) begin
		isp_histo_rd_addr <= isp_histo_rd_addr+16'd1;
	end
end

always @(posedge AHB_HCLK or negedge AHB_HRESETn) begin
    if(!AHB_HRESETn) begin
        isp_reg_rd_data_r0 <= 0;
        isp_reg_rd_data_r1 <= 0;
        isp_reg_rd_data_r2 <= 0;

        isp_rd_rdy_r0 <= 0;
        isp_rd_rdy_r1 <= 0;
        isp_rd_rdy_r2 <= 0;
    end
    else begin
        isp_reg_rd_data_r0 <= isp_reg_rd_data;
        isp_reg_rd_data_r1 <= isp_reg_rd_data_r0;
        isp_reg_rd_data_r2 <= isp_reg_rd_data_r1;

        isp_rd_rdy_r0 <= isp_rd_rdy;
        isp_rd_rdy_r1 <= isp_rd_rdy_r0;
        isp_rd_rdy_r2 <= isp_rd_rdy_r1;
    end
end


endmodule
