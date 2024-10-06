//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.10.02
//Part Number: GW5AST-LV138FPG676AES
//Device: GW5AST-138
//Device Version: B
//Created Time: Sun Oct  6 11:44:45 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    CAMERA_PLL your_instance_name(
        .lock(lock), //output lock
        .clkout0(clkout0), //output clkout0
        .clkin(clkin), //input clkin
        .reset(reset) //input reset
    );

//--------Copy end-------------------
