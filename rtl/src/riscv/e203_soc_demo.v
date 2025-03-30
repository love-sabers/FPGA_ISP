module e203_soc_demo (
    input          clk_in, //50MHz clock input 

    input          tck, // The JTAG TCK is input, need to be pull-up
    input          tms, // The JTAG TMS is input, need to be pull-up
    input          tdi, // The JTAG TDI is input, need to be pull-up
    output         tdo, // The JTAG TDO is output 

    input   [31:0] gpio_in,
    output  [31:0] gpio_out,

    //QSPI DQ is bidir I/O with enable, and need pull-up enable
    input    [3:0] qspi_in,
    output   [3:0] qspi_out, 

    output         qspi_sck,  //QSPI SCK and CS is output without enable
    output         qspi_cs,   //QSPI SCK and CS is output without enable

    input          erstn, // Erst is input need to be pull-up by default

    input          dbgmode0_n, // dbgmode are inputs need to be pull-up by default
    input          dbgmode1_n,
    input          dbgmode3_n,
  
    input          bootrom_n, // BootRom is input need to be pull-up by default
  
    input          aon_pmu_dwakeup_n, // dwakeup is input need to be pull-up by default
    output         aon_pmu_padrst,    // PMU output is just output without enable
    output         aon_pmu_vddpaden 
);

    wire hfextclk;  // This clock should comes from the crystal pad generated high speed clock (16MHz)
    wire lfextclk;  // This clock should comes from the crystal pad generated low speed clock (32.768KHz)

    wire reset_n;

    clk_unit clk_unit (.clkout_rtc(lfextclk), .reset(erstn), .clkin(clk_in), .clkout_system(hfextclk), .lock(pll_lock));
    
    //wire wire_resetn = erstn & pll_lock;

    reg [15:0] rstdly =0;

    always @(negedge hfextclk)
    begin
        if(pll_lock)
            rstdly <= {rstdly[14:0],1'b1};
        else if(!erstn)
            rstdly <= 0;
    end

    assign reset_n = rstdly[15];

e203_soc_top e203_soc_ins (
    // This clock should comes from the crystal pad generated high speed clock (16MHz)
    .hfextclk   (hfextclk),
    // The signal to enable the crystal pad generated clock
    .hfxoscen   (),

    // This clock should comes from the crystal pad generated low speed clock (32.768KHz)
    .lfextclk   (lfextclk),
    // The signal to enable the crystal pad generated clock
    .lfxoscen   (),

    // The JTAG TCK is input, need to be pull-up
    .io_pads_jtag_TCK_i_ival   (tck),
    // The JTAG TMS is input, need to be pull-up
    .io_pads_jtag_TMS_i_ival   (tms),
    // The JTAG TDI is input, need to be pull-up
    .io_pads_jtag_TDI_i_ival   (tdi),
    // The JTAG TDO is output have enable
    .io_pads_jtag_TDO_o_oval   (tdo),
    .io_pads_jtag_TDO_o_oe     (),

    // The GPIO are all bidir pad have enables
    .io_pads_gpio_0_i_ival   (gpio_in[0]),
    .io_pads_gpio_0_o_oval   (gpio_out[0]),
    .io_pads_gpio_0_o_oe     (),
    .io_pads_gpio_0_o_ie     (),
    .io_pads_gpio_0_o_pue    (),
    .io_pads_gpio_0_o_ds     (),
  
    .io_pads_gpio_1_i_ival   (gpio_in[1]),
    .io_pads_gpio_1_o_oval   (gpio_out[1]),
    .io_pads_gpio_1_o_oe     (),
    .io_pads_gpio_1_o_ie     (),
    .io_pads_gpio_1_o_pue    (),
    .io_pads_gpio_1_o_ds     (),
  
    .io_pads_gpio_2_i_ival   (gpio_in[2]),
    .io_pads_gpio_2_o_oval   (gpio_out[2]),
    .io_pads_gpio_2_o_oe     (),
    .io_pads_gpio_2_o_ie     (),
    .io_pads_gpio_2_o_pue    (),
    .io_pads_gpio_2_o_ds     (),
  
    .io_pads_gpio_3_i_ival   (gpio_in[3]),
    .io_pads_gpio_3_o_oval   (gpio_out[3]),
    .io_pads_gpio_3_o_oe     (),
    .io_pads_gpio_3_o_ie     (),
    .io_pads_gpio_3_o_pue    (),
    .io_pads_gpio_3_o_ds     (),
  
    .io_pads_gpio_4_i_ival   (gpio_in[4]),
    .io_pads_gpio_4_o_oval   (gpio_out[4]),
    .io_pads_gpio_4_o_oe     (),
    .io_pads_gpio_4_o_ie     (),
    .io_pads_gpio_4_o_pue    (),
    .io_pads_gpio_4_o_ds     (),
  
    .io_pads_gpio_5_i_ival   (gpio_in[5]),
    .io_pads_gpio_5_o_oval   (gpio_out[5]),
    .io_pads_gpio_5_o_oe     (),
    .io_pads_gpio_5_o_ie     (),
    .io_pads_gpio_5_o_pue    (),
    .io_pads_gpio_5_o_ds     (),
  
    .io_pads_gpio_6_i_ival   (gpio_in[6]),
    .io_pads_gpio_6_o_oval   (gpio_out[6]),
    .io_pads_gpio_6_o_oe     (),
    .io_pads_gpio_6_o_ie     (),
    .io_pads_gpio_6_o_pue    (),
    .io_pads_gpio_6_o_ds     (),
  
    .io_pads_gpio_7_i_ival   (gpio_in[7]),
    .io_pads_gpio_7_o_oval   (gpio_out[7]),
    .io_pads_gpio_7_o_oe     (),
    .io_pads_gpio_7_o_ie     (),
    .io_pads_gpio_7_o_pue    (),
    .io_pads_gpio_7_o_ds     (),
  
    .io_pads_gpio_8_i_ival   (gpio_in[8]),
    .io_pads_gpio_8_o_oval   (gpio_out[8]),
    .io_pads_gpio_8_o_oe     (),
    .io_pads_gpio_8_o_ie     (),
    .io_pads_gpio_8_o_pue    (),
    .io_pads_gpio_8_o_ds     (),
  
    .io_pads_gpio_9_i_ival   (gpio_in[9]),
    .io_pads_gpio_9_o_oval   (gpio_out[9]),
    .io_pads_gpio_9_o_oe     (),
    .io_pads_gpio_9_o_ie     (),
    .io_pads_gpio_9_o_pue    (),
    .io_pads_gpio_9_o_ds     (),
  
    .io_pads_gpio_10_i_ival  (gpio_in[10]),
    .io_pads_gpio_10_o_oval  (gpio_out[10]),
    .io_pads_gpio_10_o_oe    (),
    .io_pads_gpio_10_o_ie    (),
    .io_pads_gpio_10_o_pue   (),
    .io_pads_gpio_10_o_ds    (),
  
    .io_pads_gpio_11_i_ival  (gpio_in[11]),
    .io_pads_gpio_11_o_oval  (gpio_out[11]),
    .io_pads_gpio_11_o_oe    (),
    .io_pads_gpio_11_o_ie    (),
    .io_pads_gpio_11_o_pue   (),
    .io_pads_gpio_11_o_ds    (),
  
    .io_pads_gpio_12_i_ival  (gpio_in[12]),
    .io_pads_gpio_12_o_oval  (gpio_out[12]),
    .io_pads_gpio_12_o_oe    (),
    .io_pads_gpio_12_o_ie    (),
    .io_pads_gpio_12_o_pue   (),
    .io_pads_gpio_12_o_ds    (),
  
    .io_pads_gpio_13_i_ival  (gpio_in[13]),
    .io_pads_gpio_13_o_oval  (gpio_out[13]),
    .io_pads_gpio_13_o_oe    (),
    .io_pads_gpio_13_o_ie    (),
    .io_pads_gpio_13_o_pue   (),
    .io_pads_gpio_13_o_ds    (),
  
    .io_pads_gpio_14_i_ival  (gpio_in[14]),
    .io_pads_gpio_14_o_oval  (gpio_out[14]),
    .io_pads_gpio_14_o_oe    (),
    .io_pads_gpio_14_o_ie    (),
    .io_pads_gpio_14_o_pue   (),
    .io_pads_gpio_14_o_ds    (),
  
    .io_pads_gpio_15_i_ival  (gpio_in[15]),
    .io_pads_gpio_15_o_oval  (gpio_out[15]),
    .io_pads_gpio_15_o_oe    (),
    .io_pads_gpio_15_o_ie    (),
    .io_pads_gpio_15_o_pue   (),
    .io_pads_gpio_15_o_ds    (),
  
    .io_pads_gpio_16_i_ival  (gpio_in[16]),
    .io_pads_gpio_16_o_oval  (gpio_out[16]),
    .io_pads_gpio_16_o_oe    (),
    .io_pads_gpio_16_o_ie    (),
    .io_pads_gpio_16_o_pue   (),
    .io_pads_gpio_16_o_ds    (),
  
    .io_pads_gpio_17_i_ival  (gpio_in[17]),
    .io_pads_gpio_17_o_oval  (gpio_out[17]),
    .io_pads_gpio_17_o_oe    (),
    .io_pads_gpio_17_o_ie    (),
    .io_pads_gpio_17_o_pue   (),
    .io_pads_gpio_17_o_ds    (),
  
    .io_pads_gpio_18_i_ival  (gpio_in[18]),
    .io_pads_gpio_18_o_oval  (gpio_out[18]),
    .io_pads_gpio_18_o_oe    (),
    .io_pads_gpio_18_o_ie    (),
    .io_pads_gpio_18_o_pue   (),
    .io_pads_gpio_18_o_ds    (),
  
    .io_pads_gpio_19_i_ival  (gpio_in[19]),
    .io_pads_gpio_19_o_oval  (gpio_out[19]),
    .io_pads_gpio_19_o_oe    (),
    .io_pads_gpio_19_o_ie    (),
    .io_pads_gpio_19_o_pue   (),
    .io_pads_gpio_19_o_ds    (),
  
    .io_pads_gpio_20_i_ival  (gpio_in[20]),
    .io_pads_gpio_20_o_oval  (gpio_out[20]),
    .io_pads_gpio_20_o_oe    (),
    .io_pads_gpio_20_o_ie    (),
    .io_pads_gpio_20_o_pue   (),
    .io_pads_gpio_20_o_ds    (),
  
    .io_pads_gpio_21_i_ival  (gpio_in[21]),
    .io_pads_gpio_21_o_oval  (gpio_out[21]),
    .io_pads_gpio_21_o_oe    (),
    .io_pads_gpio_21_o_ie    (),
    .io_pads_gpio_21_o_pue   (),
    .io_pads_gpio_21_o_ds    (),
  
    .io_pads_gpio_22_i_ival  (gpio_in[22]),
    .io_pads_gpio_22_o_oval  (gpio_out[22]),
    .io_pads_gpio_22_o_oe    (),
    .io_pads_gpio_22_o_ie    (),
    .io_pads_gpio_22_o_pue   (),
    .io_pads_gpio_22_o_ds    (),
  
    .io_pads_gpio_23_i_ival  (gpio_in[23]),
    .io_pads_gpio_23_o_oval  (gpio_out[23]),
    .io_pads_gpio_23_o_oe    (),
    .io_pads_gpio_23_o_ie    (),
    .io_pads_gpio_23_o_pue   (),
    .io_pads_gpio_23_o_ds    (),
  
    .io_pads_gpio_24_i_ival  (gpio_in[24]),
    .io_pads_gpio_24_o_oval  (gpio_out[24]),
    .io_pads_gpio_24_o_oe    (),
    .io_pads_gpio_24_o_ie    (),
    .io_pads_gpio_24_o_pue   (),
    .io_pads_gpio_24_o_ds    (),
  
    .io_pads_gpio_25_i_ival  (gpio_in[25]),
    .io_pads_gpio_25_o_oval  (gpio_out[25]),
    .io_pads_gpio_25_o_oe    (),
    .io_pads_gpio_25_o_ie    (),
    .io_pads_gpio_25_o_pue   (),
    .io_pads_gpio_25_o_ds    (),
  
    .io_pads_gpio_26_i_ival  (gpio_in[26]),
    .io_pads_gpio_26_o_oval  (gpio_out[26]),
    .io_pads_gpio_26_o_oe    (),
    .io_pads_gpio_26_o_ie    (),
    .io_pads_gpio_26_o_pue   (),
    .io_pads_gpio_26_o_ds    (),
  
    .io_pads_gpio_27_i_ival  (gpio_in[27]),
    .io_pads_gpio_27_o_oval  (gpio_out[27]),
    .io_pads_gpio_27_o_oe    (),
    .io_pads_gpio_27_o_ie    (),
    .io_pads_gpio_27_o_pue   (),
    .io_pads_gpio_27_o_ds    (),
  
    .io_pads_gpio_28_i_ival  (gpio_in[28]),
    .io_pads_gpio_28_o_oval  (gpio_out[28]),
    .io_pads_gpio_28_o_oe    (),
    .io_pads_gpio_28_o_ie    (),
    .io_pads_gpio_28_o_pue   (),
    .io_pads_gpio_28_o_ds    (),
  
    .io_pads_gpio_29_i_ival  (gpio_in[29]),
    .io_pads_gpio_29_o_oval  (gpio_out[29]),
    .io_pads_gpio_29_o_oe    (),
    .io_pads_gpio_29_o_ie    (),
    .io_pads_gpio_29_o_pue   (),
    .io_pads_gpio_29_o_ds    (),
  
    .io_pads_gpio_30_i_ival  (gpio_in[30]),
    .io_pads_gpio_30_o_oval  (gpio_out[30]),
    .io_pads_gpio_30_o_oe    (),
    .io_pads_gpio_30_o_ie    (),
    .io_pads_gpio_30_o_pue   (),
    .io_pads_gpio_30_o_ds    (),
  
    .io_pads_gpio_31_i_ival  (gpio_in[31]),
    .io_pads_gpio_31_o_oval  (gpio_out[31]),
    .io_pads_gpio_31_o_oe    (),
    .io_pads_gpio_31_o_ie    (),
    .io_pads_gpio_31_o_pue   (),
    .io_pads_gpio_31_o_ds    (),

    //QSPI SCK and CS is output without enable
    .io_pads_qspi_sck_o_oval  (qspi_sck),
    .io_pads_qspi_cs_0_o_oval (qspi_cs),

    //QSPI DQ is bidir I/O with enable(), and need pull-up enable
    .io_pads_qspi_dq_0_i_ival   (qspi_in[0]),
    .io_pads_qspi_dq_0_o_oval   (qspi_out[0]),
    .io_pads_qspi_dq_0_o_oe     (),
    .io_pads_qspi_dq_0_o_ie     (),
    .io_pads_qspi_dq_0_o_pue    (),
    .io_pads_qspi_dq_0_o_ds     (),

    .io_pads_qspi_dq_1_i_ival   (qspi_in[1]),
    .io_pads_qspi_dq_1_o_oval   (qspi_out[1]),
    .io_pads_qspi_dq_1_o_oe     (),
    .io_pads_qspi_dq_1_o_ie     (),
    .io_pads_qspi_dq_1_o_pue    (),
    .io_pads_qspi_dq_1_o_ds     (),

    .io_pads_qspi_dq_2_i_ival   (qspi_in[2]),
    .io_pads_qspi_dq_2_o_oval   (qspi_out[2]),
    .io_pads_qspi_dq_2_o_oe     (),
    .io_pads_qspi_dq_2_o_ie     (),
    .io_pads_qspi_dq_2_o_pue    (),
    .io_pads_qspi_dq_2_o_ds     (),

    .io_pads_qspi_dq_3_i_ival   (qspi_in[3]),
    .io_pads_qspi_dq_3_o_oval   (qspi_out[3]),
    .io_pads_qspi_dq_3_o_oe     (),
    .io_pads_qspi_dq_3_o_ie     (),
    .io_pads_qspi_dq_3_o_pue    (),
    .io_pads_qspi_dq_3_o_ds     (),

    // Erst is input need to be pull-up by default
    .io_pads_aon_erst_n_i_ival  (reset_n),

    // dbgmode are inputs need to be pull-up by default
    .io_pads_dbgmode0_n_i_ival  (1'b1),
    .io_pads_dbgmode1_n_i_ival  (1'b1),
    .io_pads_dbgmode2_n_i_ival  (1'b1),

    // BootRom is input need to be pull-up by default
    .io_pads_bootrom_n_i_ival   (1'b0),

    // dwakeup is input need to be pull-up by default
    .io_pads_aon_pmu_dwakeup_n_i_ival (aon_pmu_dwakeup_n),

    // PMU output is just output without enable
    .io_pads_aon_pmu_padrst_o_oval    (aon_pmu_padrst),
    .io_pads_aon_pmu_vddpaden_o_oval  (aon_pmu_vddpaden)
);

endmodule 
