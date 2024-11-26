//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9
//Part Number: GW5AST-LV138FPG676AES
//Device: GW5AST-138
//Device Version: B
//Created Time: Tue Nov 26 21:21:52 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	myshift_register your_instance_name(
		.clk(clk_i), //input clk
		.Reset(Reset_i), //input Reset
		.Din(Din_i), //input [7:0] Din
		.Q(Q_o) //output [7:0] Q
	);

//--------Copy end-------------------
