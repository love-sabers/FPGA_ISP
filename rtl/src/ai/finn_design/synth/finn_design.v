//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
//Date        : Mon Nov  4 08:38:11 2024
//Host        : finn_dev_renren running 64-bit Ubuntu 22.04.1 LTS
//Command     : generate_target finn_design.bd
//Design      : finn_design
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module MVAU_rtl_0_imp_1DNJB9Y
   (ap_clk,
    ap_rst_n,
    in0_V_tdata,
    in0_V_tready,
    in0_V_tvalid,
    out_V_tdata,
    out_V_tready,
    out_V_tvalid);
  input ap_clk;
  input ap_rst_n;
  input [71:0]in0_V_tdata;
  output in0_V_tready;
  input in0_V_tvalid;
  output [767:0]out_V_tdata;
  input out_V_tready;
  output out_V_tvalid;

  wire [767:0]MVAU_rtl_0_out_V_TDATA;
  wire MVAU_rtl_0_out_V_TREADY;
  wire MVAU_rtl_0_out_V_TVALID;
  wire [2303:0]MVAU_rtl_0_wstrm_m_axis_0_TDATA;
  wire MVAU_rtl_0_wstrm_m_axis_0_TREADY;
  wire MVAU_rtl_0_wstrm_m_axis_0_TVALID;
  wire ap_clk_1;
  wire ap_rst_n_1;
  wire [71:0]in0_V_1_TDATA;
  wire in0_V_1_TREADY;
  wire in0_V_1_TVALID;

  assign MVAU_rtl_0_out_V_TREADY = out_V_tready;
  assign ap_clk_1 = ap_clk;
  assign ap_rst_n_1 = ap_rst_n;
  assign in0_V_1_TDATA = in0_V_tdata[71:0];
  assign in0_V_1_TVALID = in0_V_tvalid;
  assign in0_V_tready = in0_V_1_TREADY;
  assign out_V_tdata[767:0] = MVAU_rtl_0_out_V_TDATA;
  assign out_V_tvalid = MVAU_rtl_0_out_V_TVALID;
  finn_design_MVAU_rtl_0_0 MVAU_rtl_0
       (.ap_clk(ap_clk_1),
        .ap_rst_n(ap_rst_n_1),
        .in0_V_TDATA(in0_V_1_TDATA),
        .in0_V_TREADY(in0_V_1_TREADY),
        .in0_V_TVALID(in0_V_1_TVALID),
        .out_V_TDATA(MVAU_rtl_0_out_V_TDATA),
        .out_V_TREADY(MVAU_rtl_0_out_V_TREADY),
        .out_V_TVALID(MVAU_rtl_0_out_V_TVALID),
        .weights_V_TDATA(MVAU_rtl_0_wstrm_m_axis_0_TDATA),
        .weights_V_TREADY(MVAU_rtl_0_wstrm_m_axis_0_TREADY),
        .weights_V_TVALID(MVAU_rtl_0_wstrm_m_axis_0_TVALID));
  finn_design_MVAU_rtl_0_wstrm_0 MVAU_rtl_0_wstrm
       (.ap_clk(ap_clk_1),
        .ap_rst_n(ap_rst_n_1),
        .araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .arprot({1'b0,1'b0,1'b0}),
        .arvalid(1'b0),
        .awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .awprot({1'b0,1'b0,1'b0}),
        .awvalid(1'b0),
        .bready(1'b0),
        .m_axis_0_tdata(MVAU_rtl_0_wstrm_m_axis_0_TDATA),
        .m_axis_0_tready(MVAU_rtl_0_wstrm_m_axis_0_TREADY),
        .m_axis_0_tvalid(MVAU_rtl_0_wstrm_m_axis_0_TVALID),
        .rready(1'b0),
        .wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .wstrb({1'b1,1'b1,1'b1,1'b1}),
        .wvalid(1'b0));
endmodule

(* CORE_GENERATION_INFO = "finn_design,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=finn_design,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=11,numReposBlks=10,numNonXlnxBlks=1,numHierBlks=1,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=9,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "finn_design.hwdef" *) 
module finn_design
   (ap_clk,
    ap_rst_n,
    m_axis_0_tdata,
    m_axis_0_tready,
    m_axis_0_tvalid,
    s_axis_0_tdata,
    s_axis_0_tready,
    s_axis_0_tvalid);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.AP_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.AP_CLK, ASSOCIATED_BUSIF s_axis_0:m_axis_0, ASSOCIATED_RESET ap_rst_n, CLK_DOMAIN finn_design_ap_clk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input ap_clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.AP_RST_N RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.AP_RST_N, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input ap_rst_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_0 " *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis_0, CLK_DOMAIN finn_design_ap_clk_0, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 96, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) output [767:0]m_axis_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_0 " *) input m_axis_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_0 " *) output m_axis_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_0 " *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_0, CLK_DOMAIN finn_design_ap_clk_0, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 3, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [23:0]s_axis_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_0 " *) output s_axis_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_0 " *) input s_axis_0_tvalid;

  wire [215:0]ConvolutionInputGenerator_rtl_0_out_V_TDATA;
  wire ConvolutionInputGenerator_rtl_0_out_V_TREADY;
  wire ConvolutionInputGenerator_rtl_0_out_V_TVALID;
  wire [23:0]FMPadding_rtl_0_out_V_TDATA;
  wire FMPadding_rtl_0_out_V_TREADY;
  wire FMPadding_rtl_0_out_V_TVALID;
  wire [767:0]MVAU_rtl_0_out_V_TDATA;
  wire MVAU_rtl_0_out_V_TREADY;
  wire MVAU_rtl_0_out_V_TVALID;
  wire [71:0]StreamingDataWidthConverter_rtl_0_out_V_TDATA;
  wire StreamingDataWidthConverter_rtl_0_out_V_TREADY;
  wire StreamingDataWidthConverter_rtl_0_out_V_TVALID;
  wire [23:0]StreamingFIFO_rtl_0_out_V_TDATA;
  wire StreamingFIFO_rtl_0_out_V_TREADY;
  wire StreamingFIFO_rtl_0_out_V_TVALID;
  wire [23:0]StreamingFIFO_rtl_1_out_V_TDATA;
  wire StreamingFIFO_rtl_1_out_V_TREADY;
  wire StreamingFIFO_rtl_1_out_V_TVALID;
  wire [215:0]StreamingFIFO_rtl_2_out_V_TDATA;
  wire StreamingFIFO_rtl_2_out_V_TREADY;
  wire StreamingFIFO_rtl_2_out_V_TVALID;
  wire [71:0]StreamingFIFO_rtl_3_out_V_TDATA;
  wire StreamingFIFO_rtl_3_out_V_TREADY;
  wire StreamingFIFO_rtl_3_out_V_TVALID;
  wire [767:0]StreamingFIFO_rtl_4_out_V_TDATA;
  wire StreamingFIFO_rtl_4_out_V_TREADY;
  wire StreamingFIFO_rtl_4_out_V_TVALID;
  wire ap_clk_0_1;
  wire ap_rst_n_0_1;
  wire [23:0]in0_V_0_1_TDATA;
  wire in0_V_0_1_TREADY;
  wire in0_V_0_1_TVALID;

  assign StreamingFIFO_rtl_4_out_V_TREADY = m_axis_0_tready;
  assign ap_clk_0_1 = ap_clk;
  assign ap_rst_n_0_1 = ap_rst_n;
  assign in0_V_0_1_TDATA = s_axis_0_tdata[23:0];
  assign in0_V_0_1_TVALID = s_axis_0_tvalid;
  assign m_axis_0_tdata[767:0] = StreamingFIFO_rtl_4_out_V_TDATA;
  assign m_axis_0_tvalid = StreamingFIFO_rtl_4_out_V_TVALID;
  assign s_axis_0_tready = in0_V_0_1_TREADY;
  finn_design_ConvolutionInputGenerator_rtl_0_0 ConvolutionInputGenerator_rtl_0
       (.ap_clk(ap_clk_0_1),
        .ap_rst_n(ap_rst_n_0_1),
        .in0_V_TDATA(StreamingFIFO_rtl_1_out_V_TDATA),
        .in0_V_TREADY(StreamingFIFO_rtl_1_out_V_TREADY),
        .in0_V_TVALID(StreamingFIFO_rtl_1_out_V_TVALID),
        .out_V_TDATA(ConvolutionInputGenerator_rtl_0_out_V_TDATA),
        .out_V_TREADY(ConvolutionInputGenerator_rtl_0_out_V_TREADY),
        .out_V_TVALID(ConvolutionInputGenerator_rtl_0_out_V_TVALID));
  finn_design_FMPadding_rtl_0_0 FMPadding_rtl_0
       (.ap_clk(ap_clk_0_1),
        .ap_rst_n(ap_rst_n_0_1),
        .in0_V_TDATA(StreamingFIFO_rtl_0_out_V_TDATA),
        .in0_V_TREADY(StreamingFIFO_rtl_0_out_V_TREADY),
        .in0_V_TVALID(StreamingFIFO_rtl_0_out_V_TVALID),
        .out_V_TDATA(FMPadding_rtl_0_out_V_TDATA),
        .out_V_TREADY(FMPadding_rtl_0_out_V_TREADY),
        .out_V_TVALID(FMPadding_rtl_0_out_V_TVALID),
        .s_axilite_ARADDR({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axilite_ARVALID(1'b0),
        .s_axilite_AWADDR({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axilite_AWVALID(1'b0),
        .s_axilite_BREADY(1'b0),
        .s_axilite_RREADY(1'b0),
        .s_axilite_WDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axilite_WSTRB({1'b1,1'b1,1'b1,1'b1}),
        .s_axilite_WVALID(1'b0));
  MVAU_rtl_0_imp_1DNJB9Y MVAU_rtl_0
       (.ap_clk(ap_clk_0_1),
        .ap_rst_n(ap_rst_n_0_1),
        .in0_V_tdata(StreamingFIFO_rtl_3_out_V_TDATA),
        .in0_V_tready(StreamingFIFO_rtl_3_out_V_TREADY),
        .in0_V_tvalid(StreamingFIFO_rtl_3_out_V_TVALID),
        .out_V_tdata(MVAU_rtl_0_out_V_TDATA),
        .out_V_tready(MVAU_rtl_0_out_V_TREADY),
        .out_V_tvalid(MVAU_rtl_0_out_V_TVALID));
  finn_design_StreamingDataWidthConverter_rtl_0_0 StreamingDataWidthConverter_rtl_0
       (.ap_clk(ap_clk_0_1),
        .ap_rst_n(ap_rst_n_0_1),
        .in0_V_TDATA(StreamingFIFO_rtl_2_out_V_TDATA),
        .in0_V_TREADY(StreamingFIFO_rtl_2_out_V_TREADY),
        .in0_V_TVALID(StreamingFIFO_rtl_2_out_V_TVALID),
        .out_V_TDATA(StreamingDataWidthConverter_rtl_0_out_V_TDATA),
        .out_V_TREADY(StreamingDataWidthConverter_rtl_0_out_V_TREADY),
        .out_V_TVALID(StreamingDataWidthConverter_rtl_0_out_V_TVALID));
  finn_design_StreamingFIFO_rtl_0_0 StreamingFIFO_rtl_0
       (.ap_clk(ap_clk_0_1),
        .ap_rst_n(ap_rst_n_0_1),
        .in0_V_TDATA(in0_V_0_1_TDATA),
        .in0_V_TREADY(in0_V_0_1_TREADY),
        .in0_V_TVALID(in0_V_0_1_TVALID),
        .out_V_TDATA(StreamingFIFO_rtl_0_out_V_TDATA),
        .out_V_TREADY(StreamingFIFO_rtl_0_out_V_TREADY),
        .out_V_TVALID(StreamingFIFO_rtl_0_out_V_TVALID));
  finn_design_StreamingFIFO_rtl_1_0 StreamingFIFO_rtl_1
       (.ap_clk(ap_clk_0_1),
        .ap_rst_n(ap_rst_n_0_1),
        .in0_V_TDATA(FMPadding_rtl_0_out_V_TDATA),
        .in0_V_TREADY(FMPadding_rtl_0_out_V_TREADY),
        .in0_V_TVALID(FMPadding_rtl_0_out_V_TVALID),
        .out_V_TDATA(StreamingFIFO_rtl_1_out_V_TDATA),
        .out_V_TREADY(StreamingFIFO_rtl_1_out_V_TREADY),
        .out_V_TVALID(StreamingFIFO_rtl_1_out_V_TVALID));
  finn_design_StreamingFIFO_rtl_2_0 StreamingFIFO_rtl_2
       (.ap_clk(ap_clk_0_1),
        .ap_rst_n(ap_rst_n_0_1),
        .in0_V_TDATA(ConvolutionInputGenerator_rtl_0_out_V_TDATA),
        .in0_V_TREADY(ConvolutionInputGenerator_rtl_0_out_V_TREADY),
        .in0_V_TVALID(ConvolutionInputGenerator_rtl_0_out_V_TVALID),
        .out_V_TDATA(StreamingFIFO_rtl_2_out_V_TDATA),
        .out_V_TREADY(StreamingFIFO_rtl_2_out_V_TREADY),
        .out_V_TVALID(StreamingFIFO_rtl_2_out_V_TVALID));
  finn_design_StreamingFIFO_rtl_3_0 StreamingFIFO_rtl_3
       (.ap_clk(ap_clk_0_1),
        .ap_rst_n(ap_rst_n_0_1),
        .in0_V_TDATA(StreamingDataWidthConverter_rtl_0_out_V_TDATA),
        .in0_V_TREADY(StreamingDataWidthConverter_rtl_0_out_V_TREADY),
        .in0_V_TVALID(StreamingDataWidthConverter_rtl_0_out_V_TVALID),
        .out_V_TDATA(StreamingFIFO_rtl_3_out_V_TDATA),
        .out_V_TREADY(StreamingFIFO_rtl_3_out_V_TREADY),
        .out_V_TVALID(StreamingFIFO_rtl_3_out_V_TVALID));
  finn_design_StreamingFIFO_rtl_4_0 StreamingFIFO_rtl_4
       (.ap_clk(ap_clk_0_1),
        .ap_rst_n(ap_rst_n_0_1),
        .in0_V_TDATA(MVAU_rtl_0_out_V_TDATA),
        .in0_V_TREADY(MVAU_rtl_0_out_V_TREADY),
        .in0_V_TVALID(MVAU_rtl_0_out_V_TVALID),
        .out_V_TDATA(StreamingFIFO_rtl_4_out_V_TDATA),
        .out_V_TREADY(StreamingFIFO_rtl_4_out_V_TREADY),
        .out_V_TVALID(StreamingFIFO_rtl_4_out_V_TVALID));
endmodule
