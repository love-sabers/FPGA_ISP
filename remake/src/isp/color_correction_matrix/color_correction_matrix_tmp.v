//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9
//Part Number: GW5AST-LV138FPG676AES
//Device: GW5AST-138
//Device Version: B
//Created Time: Thu Oct 10 16:36:48 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Color_Correction_Matrix_Top your_instance_name(
		.clk(clk_i), //input clk
		.rstn(rstn_i), //input rstn
		.frame_sync(frame_sync_i), //input frame_sync
		.line_sync(line_sync_i), //input line_sync
		.inpvalid(inpvalid_i), //input inpvalid
		.R_din(R_din_i), //input [7:0] R_din
		.G_din(G_din_i), //input [7:0] G_din
		.B_din(B_din_i), //input [7:0] B_din
		.wr(wr_i), //input wr
		.waddr(waddr_i), //input [15:0] waddr
		.wdata(wdata_i), //input [31:0] wdata
		.frame_sync_o(frame_sync_o_o), //output frame_sync_o
		.line_sync_o(line_sync_o_o), //output line_sync_o
		.outvalid(outvalid_o), //output outvalid
		.R_dout(R_dout_o), //output [7:0] R_dout
		.G_dout(G_dout_o), //output [7:0] G_dout
		.B_dout(B_dout_o) //output [7:0] B_dout
	);

//--------Copy end-------------------
