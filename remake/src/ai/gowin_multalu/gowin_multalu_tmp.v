//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9 (64-bit)
//Part Number: GW5AST-LV138FPG676AC1/I0
//Device: GW5AST-138B
//Device Version: B
//Created Time: Wed Nov 20 13:29:35 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    DSP48E1 your_instance_name(
        .dout(dout_o), //output [47:0] dout
        .a(a_i), //input [25:0] a
        .b(b_i), //input [17:0] b
        .c(c_i), //input [47:0] c
        .d(d_i), //input [25:0] d
        .accsel(accsel_i), //input accsel
        .clk(clk_i), //input clk
        .ce(ce_i), //input ce
        .reset(reset_i) //input reset
    );

//--------Copy end-------------------
