//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9
//Part Number: GW5AST-LV138FPG676AES
//Device: GW5AST-138
//Device Version: B
//Created Time: Sat Oct 26 14:08:56 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	RAM_reg_top your_instance_name(
		.clk(clk_i), //input clk
		.Reset(Reset_i), //input Reset
		.Din(Din_i), //input [7:0] Din
		.ADDR(ADDR_i), //input [9:0] ADDR
		.Q(Q_o) //output [7:0] Q
	);

//--------Copy end-------------------
