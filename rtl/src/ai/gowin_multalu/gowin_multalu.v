//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.9 (64-bit)
//Part Number: GW5AST-LV138FPG676AC1/I0
//Device: GW5AST-138B
//Device Version: B
//Created Time: Wed Nov 20 13:29:35 2024

module DSP48E1 (dout, a, b, c, d, accsel, clk, ce, reset);

output [47:0] dout;
input [25:0] a;
input [17:0] b;
input [47:0] c;
input [25:0] d;
input accsel;
input clk;
input ce;
input reset;

wire [47:0] caso;
wire [26:0] soa;
wire gw_gnd;

assign gw_gnd = 1'b0;

MULTALU27X18 multalu27x18_inst (
    .DOUT(dout),
    .CASO(caso),
    .SOA(soa),
    .A({a[25],a[25:0]}),
    .B(b),
    .C(c),
    .D(d),
    .SIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .CASI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .ACCSEL(accsel),
    .CASISEL(gw_gnd),
    .ASEL(gw_gnd),
    .PSEL(gw_gnd),
    .CSEL(gw_gnd),
    .ADDSUB({gw_gnd,gw_gnd}),
    .PADDSUB(gw_gnd),
    .CLK({gw_gnd,clk}),
    .CE({gw_gnd,ce}),
    .RESET({gw_gnd,reset})
);

defparam multalu27x18_inst.AREG_CLK = "CLK0";
defparam multalu27x18_inst.AREG_CE = "CE0";
defparam multalu27x18_inst.AREG_RESET = "RESET0";
defparam multalu27x18_inst.BREG_CLK = "CLK0";
defparam multalu27x18_inst.BREG_CE = "CE0";
defparam multalu27x18_inst.BREG_RESET = "RESET0";
defparam multalu27x18_inst.DREG_CLK = "CLK0";
defparam multalu27x18_inst.DREG_CE = "CE0";
defparam multalu27x18_inst.DREG_RESET = "RESET0";
defparam multalu27x18_inst.C_IREG_CLK = "CLK0";
defparam multalu27x18_inst.C_IREG_CE = "CE0";
defparam multalu27x18_inst.C_IREG_RESET = "RESET0";
defparam multalu27x18_inst.PSEL_IREG_CLK = "BYPASS";
defparam multalu27x18_inst.PSEL_IREG_CE = "CE0";
defparam multalu27x18_inst.PSEL_IREG_RESET = "RESET0";
defparam multalu27x18_inst.PADDSUB_IREG_CLK = "BYPASS";
defparam multalu27x18_inst.PADDSUB_IREG_CE = "CE0";
defparam multalu27x18_inst.PADDSUB_IREG_RESET = "RESET0";
defparam multalu27x18_inst.ADDSUB0_IREG_CLK = "BYPASS";
defparam multalu27x18_inst.ADDSUB0_IREG_CE = "CE0";
defparam multalu27x18_inst.ADDSUB0_IREG_RESET = "RESET0";
defparam multalu27x18_inst.ADDSUB1_IREG_CLK = "BYPASS";
defparam multalu27x18_inst.ADDSUB1_IREG_CE = "CE0";
defparam multalu27x18_inst.ADDSUB1_IREG_RESET = "RESET0";
defparam multalu27x18_inst.CSEL_IREG_CLK = "BYPASS";
defparam multalu27x18_inst.CSEL_IREG_CE = "CE0";
defparam multalu27x18_inst.CSEL_IREG_RESET = "RESET0";
defparam multalu27x18_inst.CASISEL_IREG_CLK = "BYPASS";
defparam multalu27x18_inst.CASISEL_IREG_CE = "CE0";
defparam multalu27x18_inst.CASISEL_IREG_RESET = "RESET0";
defparam multalu27x18_inst.ACCSEL_IREG_CLK = "BYPASS";
defparam multalu27x18_inst.ACCSEL_IREG_CE = "CE0";
defparam multalu27x18_inst.ACCSEL_IREG_RESET = "RESET0";
defparam multalu27x18_inst.PREG_CLK = "BYPASS";
defparam multalu27x18_inst.PREG_CE = "CE0";
defparam multalu27x18_inst.PREG_RESET = "RESET0";
defparam multalu27x18_inst.ADDSUB0_PREG_CLK = "BYPASS";
defparam multalu27x18_inst.ADDSUB0_PREG_CE = "CE0";
defparam multalu27x18_inst.ADDSUB0_PREG_RESET = "RESET0";
defparam multalu27x18_inst.ADDSUB1_PREG_CLK = "BYPASS";
defparam multalu27x18_inst.ADDSUB1_PREG_CE = "CE0";
defparam multalu27x18_inst.ADDSUB1_PREG_RESET = "RESET0";
defparam multalu27x18_inst.CSEL_PREG_CLK = "BYPASS";
defparam multalu27x18_inst.CSEL_PREG_CE = "CE0";
defparam multalu27x18_inst.CSEL_PREG_RESET = "RESET0";
defparam multalu27x18_inst.CASISEL_PREG_CLK = "BYPASS";
defparam multalu27x18_inst.CASISEL_PREG_CE = "CE0";
defparam multalu27x18_inst.CASISEL_PREG_RESET = "RESET0";
defparam multalu27x18_inst.ACCSEL_PREG_CLK = "BYPASS";
defparam multalu27x18_inst.ACCSEL_PREG_CE = "CE0";
defparam multalu27x18_inst.ACCSEL_PREG_RESET = "RESET0";
defparam multalu27x18_inst.C_PREG_CLK = "CLK0";
defparam multalu27x18_inst.C_PREG_CE = "CE0";
defparam multalu27x18_inst.C_PREG_RESET = "RESET0";
defparam multalu27x18_inst.FB_PREG_EN = "TRUE";
defparam multalu27x18_inst.SOA_PREG_EN = "FALSE";
defparam multalu27x18_inst.OREG_CLK = "CLK0";
defparam multalu27x18_inst.OREG_CE = "CE0";
defparam multalu27x18_inst.OREG_RESET = "RESET0";
defparam multalu27x18_inst.MULT_RESET_MODE = "SYNC";
defparam multalu27x18_inst.PRE_LOAD = 48'h000000000000;
defparam multalu27x18_inst.DYN_P_SEL = "FALSE";
defparam multalu27x18_inst.P_SEL = 1'b1;
defparam multalu27x18_inst.DYN_P_ADDSUB = "FALSE";
defparam multalu27x18_inst.P_ADDSUB = 1'b1;
defparam multalu27x18_inst.DYN_A_SEL = "FALSE";
defparam multalu27x18_inst.A_SEL = 1'b0;
defparam multalu27x18_inst.DYN_ADD_SUB_0 = "FALSE";
defparam multalu27x18_inst.ADD_SUB_0 = 1'b0;
defparam multalu27x18_inst.DYN_ADD_SUB_1 = "FALSE";
defparam multalu27x18_inst.ADD_SUB_1 = 1'b0;
defparam multalu27x18_inst.DYN_C_SEL = "FALSE";
defparam multalu27x18_inst.C_SEL = 1'b1;
defparam multalu27x18_inst.DYN_CASI_SEL = "FALSE";
defparam multalu27x18_inst.CASI_SEL = 1'b0;
defparam multalu27x18_inst.DYN_ACC_SEL = "TRUE";
defparam multalu27x18_inst.ACC_SEL = 1'b0;
defparam multalu27x18_inst.MULT12X12_EN = "FALSE";
endmodule //DSP48E1
