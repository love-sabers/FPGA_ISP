//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9
//Part Number: GW5AST-LV138FPG676AES
//Device: GW5AST-138
//Device Version: B
//Created Time: Mon Oct 28 17:04:51 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Integer_Division_Top your_instance_name(
		.clk(clk_i), //input clk
		.rstn(rstn_i), //input rstn
		.dividend(dividend_i), //input [23:0] dividend
		.divisor(divisor_i), //input [15:0] divisor
		.quotient(quotient_o) //output [23:0] quotient
	);

//--------Copy end-------------------
