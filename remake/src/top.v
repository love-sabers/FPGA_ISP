module top
#(
    parameter video_hlength     = 2200,
    parameter video_vlength     = 1125,

    parameter video_hsync_pol   = 1,
    parameter video_hsync_len   = 44,
    parameter video_hbp_len     = 148,
    parameter video_h_visible   = 1920,

    parameter video_vsync_pol   = 1,
    parameter video_vsync_len   = 5,
    parameter video_vbp_len     = 36,
    parameter video_v_visible   = 1080
)
(
    input clk,
    input reset_n,

    // Camera interface
    output      camera_sclk,
    inout       camera_sdat,
    input       camera_vsync,
    input       camera_href,
    input       camera_pclk,
    output      camera_xclk,
    input  [7:0] camera_data,
    output      camera_rst_n,
    output      camera_pwdn,

    // LED
    output [3:0] led,

    // HDMI
    output       tmds_clk_n_0,
    output       tmds_clk_p_0,
    output [2:0] tmds_d_n_0,
    output [2:0] tmds_d_p_0,

    // DDR
    output [2:0]  ddr_bank,
    output [14:0] ddr_addr,
    output ddr_odt,
    output ddr_cke,
    output ddr_we,
    output ddr_cas,
    output ddr_ras,
    output ddr_cs,
    output ddr_reset_n,
    output ddr_clk,
    output ddr_clk_n,

    output [3:0] ddr_dm,
    inout [31:0] ddr_dq,
    inout [3:0] ddr_dqs,
    inout [3:0] ddr_dqs_n
);

    // Internal wires and signals
    wire          hdmi_pll_lock;
    wire          clk_hdmi5;
    wire          clk_hdmi;

    wire          fifo_aclr;
    wire          fifo_wrreq;
    wire [31:0]   fifo_wrdata;

    // DDR PLL
    wire          ddr_pll_lock;
    wire          ddr_clk100m;
    wire          ddr_memory_clk;
    wire          ddr_pll_stop;
    wire          ddr_init_calib_complete;

    // DVI signals
    wire [23:0]   dvi_data;
    wire          dvi_den;
    wire          dvi_hsync;
    wire          dvi_vsync;

    // FIFO control signals
    wire          rd_load;
    wire          rdfifo_rden;
    wire          rdfifo_clk;
    wire [31:0]   rdfifo_dout;

    wire          wr_load;
    wire          wrfifo_wren;
    wire          wrfifo_clk;
    wire [31:0]   wrfifo_din;

    // DDR3 configuration
    wire [28:0]   app_addr_max = video_h_visible * video_v_visible;
    wire [7:0]    burst_len = video_h_visible[10:3];

    // Camera clock assignment
    wire          loc_clk50m;
    wire          loc_clk24m;
    wire          cmos_clk;
    wire[15:0]    cmos_16bit_data;
    wire[9:0]     lut_index;
    wire[31:0]    lut_data;

    assign camera_xclk = loc_clk24m;
    assign camera_pwdn = 1'b0;
    assign camera_rst_n = 1'b1;
    assign wrfifo_din = {cmos_16bit_data[4:0], cmos_16bit_data[10:5], cmos_16bit_data[15:11]};

    reg [5:0] cam_running;
    assign cam_run = cam_running[5];
    always @(posedge camera_vsync)
        cam_running <= cam_running + 6'd1;

    // PLL instances
    Gowin_PLL Gowin_PLL_inst(
        .clkout0(loc_clk50m), //output clkout0
        .clkout1(loc_clk24m), //output clkout1
        .clkin(clk),          //input clkin
        .reset(~reset_n)      //input reset
    );

    // I2C master controller for camera configuration
    i2c_config i2c_config_m0(
        .rst(~reset_n),
        .clk(clk_hdmi),
        .clk_div_cnt(16'd500),
        .i2c_addr_2byte(1'b1),
        .lut_index(lut_index),
        .lut_dev_addr(lut_data[31:24]),
        .lut_reg_addr(lut_data[23:8]),
        .lut_reg_data(lut_data[7:0]),
        .i2c_scl(camera_sclk),
        .i2c_sda(camera_sdat)
    );

    // Look-up table for camera configuration
    lut_ov5640_rgb565_480_272 lut_ov5640_rgb565_480_272_m0(
        .lut_index(lut_index),
        .lut_data(lut_data)
    );

    // CMOS sensor 8-bit to 16-bit data conversion
    cmos_8_16bit cmos_8_16bit_m0(
        .rst(~reset_n),
        .pclk(camera_pclk),
        .pdata_i(camera_data),
        .de_i(camera_href),
        .pdata_o(cmos_16bit_data),
        .de_o(cmos_16bit_wr)
    );


    assign wrfifo_wren = cmos_16bit_wr;   // 将DVP的写入请求与DDR写入使能同步
    assign wrfifo_clk = camera_pclk;
    assign rdfifo_clk = clk_hdmi;   
    assign wr_load = camera_vsync;   


    // HDMI PLL instance
    hdmi_PLL hdmi_PLL_inst(
        .lock(hdmi_pll_lock),
        .clkout0(clk_hdmi),
        .clkout1(clk_hdmi5),
        .clkin(clk)
    );

    // DDR PLL instance
    ddr_PLL ddr_PLL_inst(
        .lock(ddr_pll_lock), //output lock
        .clkout0(), //output clkout0
        .clkout1(ddr_clk100m), //output clkout1 100
        .clkout2(ddr_memory_clk), //output clkout2 400
        .clkin(clk), //input clkin
        .reset(~reset_n), //input reset
        .enclk0(1'b1), //input enclk0
        .enclk1(1'b1), //input enclk1
        .enclk2(ddr_pll_stop) //input enclk2
    );

    // DDR3 controller instance
    ddr3_ctrl_2port ddr3_ctrl_2port(
        .clk(ddr_clk100m), //100M时钟信号
        .memory_clk(ddr_memory_clk), //DDR3参考时钟信号
        .pll_lock(ddr_pll_lock),
        .pll_stop(ddr_pll_stop),
        .sys_rst_n(reset_n), //外部复位信号
        .init_calib_complete(ddr_init_calib_complete), //DDR初始化完成信号
        .rd_load(rd_load), //输出源更新信号
        .wr_load(wr_load), //输入源更新信号
        .app_addr_rd_min(29'd0), //读DDR3的起始地址
        .app_addr_rd_max(app_addr_max), //读DDR3的结束地址
        .rd_bust_len(burst_len), //从DDR3中读数据时的突发长度
        .app_addr_wr_min(29'd0), //写DD3的起始地址
        .app_addr_wr_max(app_addr_max), //写DDR的结束地址
        .wr_bust_len(burst_len), //向DDR3中写数据时的突发长度
        .wr_clk(wrfifo_clk), //wr_fifo的写时钟信号
        .wfifo_wren(wrfifo_wren), //wr_fifo的写使能信号
        .wfifo_din(wrfifo_din), //写入到wr_fifo中的数据
        .rd_clk(rdfifo_clk), //rd_fifo的读时钟信号
        .rfifo_rden(rdfifo_rden), //rd_fifo的读使能信号
        .rfifo_dout(rdfifo_dout), //rd_fifo读出的数据信号
        .ddr3_dq(ddr_dq), //DDR3 数据
        .ddr3_dqs_n(ddr_dqs_n), //DDR3 dqs负
        .ddr3_dqs(ddr_dqs), //DDR3 dqs正
        .ddr3_addr(ddr_addr), //DDR3 地址
        .ddr3_ba(ddr_bank), //DDR3 banck 选择
        .ddr3_ras_n(ddr_ras), //DDR3 行选择
        .ddr3_cas_n(ddr_cas), //DDR3 列选择
        .ddr3_we_n(ddr_we), //DDR3 读写选择
        .ddr3_reset_n(ddr_reset_n), //DDR3 复位
        .ddr3_ck_p(ddr_clk), //DDR3 时钟正
        .ddr3_ck_n(ddr_clk_n), //DDR3 时钟负
        .ddr3_cke(ddr_cke), //DDR3 时钟使能
        .ddr3_cs_n(ddr_cs), //DDR3 片选
        .ddr3_dm(ddr_dm), //DDR3_dm
        .ddr3_odt(ddr_odt) //DDR3_odt
    );

    

    // HDMI reset synchronization
    wire sys_resetn;
    Reset_Sync u_Reset_Sync (
        .reset_n(sys_resetn),
        .ext_reset(reset_n & hdmi_pll_lock),
        .clk(clk_hdmi)
    );

    // Display driver instance
    disp_driver #(
        .video_hlength(video_hlength),
        .video_vlength(video_vlength),
        .video_hsync_pol(video_hsync_pol),
        .video_hsync_len(video_hsync_len),
        .video_hbp_len(video_hbp_len),
        .video_h_visible(video_h_visible),
        .video_vsync_pol(video_vsync_pol),
        .video_vsync_len(video_vsync_len),
        .video_vbp_len(video_vbp_len),
        .video_v_visible(video_v_visible)
    ) disp_driver0 (
        .pixel_clock(clk_hdmi),
        .reset(~sys_resetn),
        .rd_load(rd_load), //输出源更新信号
        .rd_clk(rdfifo_clk), //rd_fifo的读时钟信号
        .rfifo_rden(rdfifo_rden), //rd_fifo的读使能信号
        .rfifo_dout(rdfifo_dout), //rd_fifo读出的数据信号
        .video_vsync(dvi_vsync),
        .video_hsync(dvi_hsync),
        .video_den(dvi_den),
        .video_pixel(dvi_data),
        .video_line_start()
    );

    // DVI transmitter instance
    dvi_tx_top dvi_tx_top_inst(
        .pixel_clock(clk_hdmi),
        .ddr_bit_clock(clk_hdmi5),
        .reset(~sys_resetn),
        .den(dvi_den),
        .hsync(dvi_hsync),
        .vsync(dvi_vsync),
        .pixel_data(dvi_data),
        .tmds_clk({tmds_clk_p_0, tmds_clk_n_0}),
        .tmds_d0({tmds_d_p_0[0], tmds_d_n_0[0]}),
        .tmds_d1({tmds_d_p_0[1], tmds_d_n_0[1]}),
        .tmds_d2({tmds_d_p_0[2], tmds_d_n_0[2]})
    );

endmodule