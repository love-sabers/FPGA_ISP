//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.10.02
//Part Number: GW5AST-LV138FPG676AES
//Device: GW5AST-138
//Device Version: B
//Created Time: Sun Oct  6 11:37:27 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	RAM_based_shift_reg_top your_instance_name(
		.clk(clk), //input clk
		.Reset(Reset), //input Reset
		.Din(Din), //input [7:0] Din
		.Q(Q) //output [7:0] Q
	);

//--------Copy end-------------------
