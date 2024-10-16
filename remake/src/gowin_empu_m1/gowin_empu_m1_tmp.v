//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9
//Part Number: GW5AST-LV138FPG676AES
//Device: GW5AST-138
//Device Version: B
//Created Time: Wed Oct 16 18:19:16 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Gowin_EMPU_M1_Top your_instance_name(
		.LOCKUP(LOCKUP_o), //output LOCKUP
		.HALTED(HALTED_o), //output HALTED
		.GPIOIN(GPIOIN_i), //input [15:0] GPIOIN
		.GPIOOUT(GPIOOUT_o), //output [15:0] GPIOOUT
		.GPIOOUTEN(GPIOOUTEN_o), //output [15:0] GPIOOUTEN
		.JTAG_7(JTAG_7_io), //inout JTAG_7
		.JTAG_9(JTAG_9_io), //inout JTAG_9
		.UART0RXD(UART0RXD_i), //input UART0RXD
		.UART0TXD(UART0TXD_o), //output UART0TXD
		.AHB1HRDATA(AHB1HRDATA_i), //input [31:0] AHB1HRDATA
		.AHB1HREADYOUT(AHB1HREADYOUT_i), //input AHB1HREADYOUT
		.AHB1HRESP(AHB1HRESP_i), //input [1:0] AHB1HRESP
		.AHB1HTRANS(AHB1HTRANS_o), //output [1:0] AHB1HTRANS
		.AHB1HBURST(AHB1HBURST_o), //output [2:0] AHB1HBURST
		.AHB1HPROT(AHB1HPROT_o), //output [3:0] AHB1HPROT
		.AHB1HSIZE(AHB1HSIZE_o), //output [2:0] AHB1HSIZE
		.AHB1HWRITE(AHB1HWRITE_o), //output AHB1HWRITE
		.AHB1HREADYMUX(AHB1HREADYMUX_o), //output AHB1HREADYMUX
		.AHB1HMASTER(AHB1HMASTER_o), //output [3:0] AHB1HMASTER
		.AHB1HMASTLOCK(AHB1HMASTLOCK_o), //output AHB1HMASTLOCK
		.AHB1HADDR(AHB1HADDR_o), //output [31:0] AHB1HADDR
		.AHB1HWDATA(AHB1HWDATA_o), //output [31:0] AHB1HWDATA
		.AHB1HSEL(AHB1HSEL_o), //output AHB1HSEL
		.AHB1HCLK(AHB1HCLK_o), //output AHB1HCLK
		.AHB1HRESET(AHB1HRESET_o), //output AHB1HRESET
		.HCLK(HCLK_i), //input HCLK
		.hwRstn(hwRstn_i) //input hwRstn
	);

//--------Copy end-------------------
