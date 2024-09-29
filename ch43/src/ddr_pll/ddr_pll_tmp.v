//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9 (64-bit)
//Part Number: GW5AST-LV138PG676AES
//Device: GW5AST-138B
//Device Version: B
//Created Time: Sat Sep 28 21:02:47 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    ddr_pll your_instance_name(
        .lock(lock_o), //output lock
        .clkout0(clkout0_o), //output clkout0
        .clkin(clkin_i) //input clkin
    );

//--------Copy end-------------------
