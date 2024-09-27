//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.9 Beta-3
//Part Number: GW5A-LV25UG324ES
//Device: GW5A-25
//Device Version: A
//Created Time: Wed Aug 30 15:12:55 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	c_shift_ram_0 your_instance_name(
		.clk(clk_i), //input clk
		.Reset(Reset_i), //input Reset
		.Din(Din_i), //input [7:0] Din
		.SCLR(SCLR_i), //input SCLR
		.Q(Q_o) //output [7:0] Q
	);

//--------Copy end-------------------
