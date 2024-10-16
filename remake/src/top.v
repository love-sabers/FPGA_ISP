module top
#(
	parameter source_h  = 800,
	parameter source_v  = 480,

	parameter video_hlength		= 2200,
	parameter video_hsync_pol	= 1,
	parameter video_hsync_len	= 44,
	parameter video_hbp_len		= 148,
	parameter video_h_visible	= 1920,

    parameter video_vlength		= 1125,
	parameter video_vsync_pol	= 1,
	parameter video_vsync_len	= 5,
	parameter video_vbp_len		= 36,
	parameter video_v_visible	= 1080
)
(

    input clk50m,
    input reset_n,
    //led
    output [5:0] led,

    //camera interface
    output      camera_sclk   ,
    inout       camera_sdat   ,
    input       camera_vsync  ,
    input       camera_href   ,
    input       camera_pclk   ,
    output      camera_xclk   ,
    input  [7:0]camera_data   ,
    output      camera_rst_n  ,
    output      camera_pwdn   ,

    output[2:0] i2c_sel, 

    //mcu
    output			MCU_UART_TX,
	input			MCU_UART_RX,
    inout           swdio,
    inout           swclk,

    //ddr
    output [2:0]  ddr_bank        ,
    output [14:0] ddr_addr        ,
    output ddr_odt                ,
    output ddr_cke                ,
    output ddr_we                 ,
    output ddr_cas                ,
    output ddr_ras                ,
    output ddr_cs                 ,
    output ddr_reset_n            ,
    output ddr_clk                ,
    output ddr_clk_n              , 
    
    output [3:0] ddr_dm          ,
    inout [31:0] ddr_dq          ,
    inout [3:0] ddr_dqs          ,
    inout [3:0] ddr_dqs_n        ,

    //hdmi
    output       tmds_clk_n_0,
	output       tmds_clk_p_0,
	output [2:0] tmds_d_n_0,
	output [2:0] tmds_d_p_0

);
    assign i2c_sel = 'b101;
    assign led={1'b1,~camera_init_done,~ddr_init_calib_complete,1'b0,1'b0,1'b0};


    // wire 	[23 : 0]	gen_data;
	// wire				gen_den;
	// wire				gen_hsync;
	// wire				gen_vsync;
    
    // test_pattern_gen test_gen0(
		
	// 	.pixel_clock		(hdmi_clk148m5),
	// 	.reset				(~sys_resetn),
		
	// 	.video_vsync		(gen_vsync),
	// 	.video_hsync		(gen_hsync),
	// 	.video_den			(gen_den),
	// 	.video_pixel_even	(gen_data)
	// );
    

    //camera
    wire camera_pll_lock;
    wire camera_clk24m;
    wire camera_init_done;
    
    camera_PLL camera_PLL_inst(
        .lock(camera_pll_lock), //output lock
        .clkout0(camera_clk24m), //output clkout0//24MHz
        .clkin(clk50m), //input clkin//50MHz
        .reset(~reset_n) //input reset
    );

    assign camera_xclk=camera_clk24m;
    
    camera_init#(
        .SYS_CLOCK      ( 50_000_000   ),//系统时钟采用50MHz
        .SCL_CLOCK      ( 400_000      ),//SCL总线时钟采用400kHz
        .CAMERA_TYPE    ( "ov5640"     ),//"ov5640" or "ov7725"
        .IMAGE_TYPE     ( 2            ),//0:RGB 1:JPEG 2:RAW
        .IMAGE_WIDTH    ( source_h  ),// 图片宽度
        .IMAGE_HEIGHT   ( source_v  ),// 图片高度
        .IMAGE_FLIP_EN  ( 0            ),// 0: 不翻转，1: 上下翻转
        .IMAGE_MIRROR_EN( 0            ) // 0: 不镜像，1: 左右镜像
    )camera_init(
        .Clk         (clk50m       ),
        .Rst_n       (camera_pll_lock  ),
        .Init_Done   (camera_init_done ),
        .camera_rst_n(camera_rst_n     ),
        .camera_pwdn (camera_pwdn      ),
        .i2c_sclk    (camera_sclk      ),
        .i2c_sdat    (camera_sdat      )
    );

        //camera reg
    wire update_valid;
	wire cam_awb_en;
	wire [15:0] cam_awb_gain_r; 
	wire [15:0] cam_awb_gain_g;
	wire [15:0] cam_awb_gain_b; 
	wire cam_agc_en;
	wire [15:0] cam_agc_gain; 
	wire        cam_aec_en; 
	wire [19:0] cam_aec_exposure; 

    //isp
	wire isp_clk;
	wire isp_vs_out;
	wire isp_de_out;
	wire [7:0] isp_data_R;
	wire [7:0] isp_data_G;
	wire [7:0] isp_data_B;
	
	wire isp_rd_rdy;
	wire isp_reg_wr_en;
	wire [15:0] isp_reg_addr;
	wire [31:0] isp_reg_wr_data;
	wire isp_reg_rd_en;
	wire [31:0] isp_reg_rd_data;
	wire [3:0] isp_disp_mode;
    wire isp_image_mask;

    wire [3:0] isp_mode;
    assign isp_mode=4'h0;//0:GAMMA 1:RAW 2:CFA 3:CCM  

    isp_top  #(
		.DATA_WIDTH(8)
	)isp_inst(
		.clk(camera_pclk), 
		.rstn(camera_rst_n),

		.in_vs(camera_vsync),
		.in_de(camera_href),
		.in_data(camera_data),
		
		.isp_rd_rdy(isp_rd_rdy),
		.isp_reg_wr_en(isp_reg_wr_en),
		.isp_reg_addr(isp_reg_addr),
		.isp_reg_wr_data(isp_reg_wr_data),
		.isp_reg_rd_en(isp_reg_rd_en),
		.isp_reg_rd_data(isp_reg_rd_data),
        .isp_disp_mode(isp_mode),
	
        .out_clk(isp_clk),
		.out_vs(isp_vs_out),
		.out_de(isp_de_out),
		.out_data_R(isp_data_R),
		.out_data_G(isp_data_G),
		.out_data_B(isp_data_B)
	);

    // wire DVP_DataValid;
    // wire DVP_DataVs;
    // wire [7:0] DVP_DataPixel;

    // DVP_Capture_raw DVP_Capture(
    //     .Rst_n      (reset_n         ),//input
    //     .PCLK       (camera_pclk      ),//input
    //     .Vsync      (camera_vsync     ),//input
    //     .Href       (camera_href      ),//input
    //     .Data       (camera_data      ),//input     [7:0]

    //     .ImageState (                 ),//output reg
    //     .DataValid  (DVP_DataValid    ),//output
    //     .DataPixel  (DVP_DataPixel    ),//output    [15:0]
    //     .DataHs     (                 ),//output
    //     .DataVs     (DVP_DataVs       ),//output
    //     .Xaddr      (                 ),//output    [11:0],start is 1
    //     .Yaddr      (                 ) //output    [11:0],start is 1
    // );

    //ddr_PLL

    wire ddr_pll_lock;
    wire ddr_clk100m;
    wire ddr_memory_clk400m;
    wire ddr_pll_stop;
    wire ddr_init_calib_complete;
    ddr_PLL ddr_PLL_inst(
        .lock(ddr_pll_lock),//output lock
        .clkout0(), //output clkout0//400MHz
        .clkout1(ddr_clk100m), //output clkout1//100MHz
        .clkout2(ddr_memory_clk400m), //output clkout2//400MHz
        .clkin(clk50m), //input clkin//50MHz
        .reset(~reset_n), //input reset
        .enclk0(1'b1), //input enclk0
        .enclk1(1'b1), //input enclk1
        .enclk2(ddr_pll_stop) //input enclk2
    );

    wire rd_load;
    wire rdfifo_rden;
    wire rdfifo_clk;
    wire [31:0] rdfifo_dout;

    wire wr_load;
    wire wrfifo_wren;
    wire wrfifo_clk;
    wire [31:0] wrfifo_din;

    assign wr_load=isp_vs_out;
    assign wrfifo_wren=isp_de_out;
    assign wrfifo_clk=isp_clk;
    assign wrfifo_din={isp_data_R[7:0],isp_data_G[7:0],isp_data_B[7:0],8'hFF};


    // assign wr_load=DVP_DataVs;
    // assign wrfifo_wren=DVP_DataValid;
    // assign wrfifo_clk=camera_pclk;
    // assign wrfifo_din={DVP_DataPixel[7:0],DVP_DataPixel[7:0],DVP_DataPixel[7:0],8'hFF};


    // assign wr_load=DVP_DataVs;
    // assign wrfifo_wren=DVP_DataValid;
    // assign wrfifo_clk=camera_pclk;
    // assign wrfifo_din={DVP_DataPixel[15:11],3'd0,DVP_DataPixel[10:5],2'd0,DVP_DataPixel[4:0],3'd0,8'hFF};

    // assign wr_load=gen_vsync;
    // assign wrfifo_wren=gen_den;
    // assign wrfifo_clk=hdmi_clk148m5;
    // assign wrfifo_din={gen_data,8'hFF};

    //大小参数
    wire [28:0] app_addr_max = source_h*source_v;//奇偶帧缓存
    wire [7:0] burst_len = source_h[10:3];


    ddr3_ctrl_2port ddr3_ctrl_2port(
        .clk(ddr_clk100m)                 ,      //100M时钟信号
        .memory_clk(ddr_memory_clk400m)            ,      //DDR3参考时钟信号
        .pll_lock(ddr_pll_lock)            ,
        .pll_stop(ddr_pll_stop),
        .sys_rst_n(reset_n)           ,      //外部复位信号
        .init_calib_complete(ddr_init_calib_complete) ,    //DDR初始化完成信号

        //用户接口
        .rd_load(rd_load)             ,   //输出源更新信号
        .wr_load(wr_load)             ,   //输入源更新信号

            //常数
        .app_addr_rd_min(29'd0)     ,   //读DDR3的起始地址
        .app_addr_rd_max(app_addr_max)     ,   //读DDR3的结束地址
        .rd_bust_len(burst_len)         ,   //从DDR3中读数据时的突发长度
        .app_addr_wr_min(29'd0)     ,   //写DD3的起始地址
        .app_addr_wr_max(app_addr_max)     ,   //写DDR的结束地址
        .wr_bust_len(burst_len)         ,   //向DDR3中写数据时的突发长度
            //控制接口
        .wr_clk(wrfifo_clk)             ,//wr_fifo的写时钟信号
        .wrfifo_wren(wrfifo_wren)          , //wr_fifo的写使能信号
        .wrfifo_din(wrfifo_din)           , //写入到wr_fifo中的数据

        .rd_clk(rdfifo_clk)              , //rd_fifo的读时钟信号
        .rdfifo_rden(rdfifo_rden)          , //rd_fifo的读使能信号
        .rdfifo_dout(rdfifo_dout)          , //rd_fifo读出的数据信号 

        //DDR3 物理接口
        .ddr3_dq(ddr_dq)             ,   //DDR3 数据
        .ddr3_dqs_n(ddr_dqs_n)          ,   //DDR3 dqs负
        .ddr3_dqs(ddr_dqs)          ,   //DDR3 dqs正  
        .ddr3_addr(ddr_addr)           ,   //DDR3 地址   
        .ddr3_ba(ddr_bank)             ,   //DDR3 banck 选择
        .ddr3_ras_n(ddr_ras)          ,   //DDR3 行选择
        .ddr3_cas_n(ddr_cas)          ,   //DDR3 列选择
        .ddr3_we_n(ddr_we)           ,   //DDR3 读写选择
        .ddr3_reset_n(ddr_reset_n)        ,   //DDR3 复位
        .ddr3_ck_p(ddr_clk)          ,   //DDR3 时钟正
        .ddr3_ck_n(ddr_clk_n)           ,   //DDR3 时钟负
        .ddr3_cke(ddr_cke)            ,   //DDR3 时钟使能
        .ddr3_cs_n(ddr_cs)           ,   //DDR3 片选
        .ddr3_dm(ddr_dm)             ,   //DDR3_dm
        .ddr3_odt(ddr_odt)                //DDR3_odt   
    );

	
    //hdmi_PLL
	wire        hdmi_pll_lock;
	wire        hdmi5_clk742m5;
	wire        hdmi_clk148m5;

    hdmi_PLL hdmi_PLL_inst(
        .lock(hdmi_pll_lock), //output lock
        .clkout0(hdmi_clk148m5), //output clkout0
        .clkout1(hdmi5_clk742m5), //output clkout1
        .clkin(clk50m), //input clkin
        .reset(~reset_n)
    );

    //hdmi_reset
    wire        sys_resetn;
    Reset_Sync u_Reset_Sync (
		.reset_n(sys_resetn),
		.ext_reset(reset_n & hdmi_pll_lock),
		.clk(hdmi_clk148m5)
	);

    //dvi
    wire 	[23 : 0]	dvi_data;
	wire				dvi_den;
	wire				dvi_hsync;
	wire				dvi_vsync;

    disp_driver  #(	
        .source_h(source_h),
        .source_v(source_v),

		.video_hlength(video_hlength),
		.video_hsync_pol(video_hsync_pol),
		.video_hsync_len(video_hsync_len),
		.video_hbp_len(video_hbp_len),
		.video_h_visible(video_h_visible),
		
        .video_vlength(video_vlength),
		.video_vsync_pol(video_vsync_pol),
		.video_vsync_len(video_vsync_len),
		.video_vbp_len(video_vbp_len),
		.video_v_visible(video_v_visible)	
	)disp_driver0(
		.pixel_clock		(hdmi_clk148m5),
		.reset				(~sys_resetn),

        //读ddr
        .rd_load(rd_load)                   ,//输出源更新信号
        .rd_clk(rdfifo_clk)                 ,//rd_fifo的读时钟信号
        .rdfifo_rden(rdfifo_rden)            ,//rd_fifo的读使能信号
        .rdfifo_dout(rdfifo_dout)            ,//rd_fifo读出的数据信号 
		
        //tmds 发送器 输入
		.video_vsync		(dvi_vsync),
		.video_hsync		(dvi_hsync),
		.video_den			(dvi_den),
		.video_pixel       	(dvi_data),
        .video_line_start   ()
	);

    dvi_tx_top dvi_tx_top_inst(//tmds 发送器
		
		.pixel_clock		(hdmi_clk148m5),
		.ddr_bit_clock		(hdmi5_clk742m5),
		.reset				(~sys_resetn),
		
		.den				(dvi_den),
		.hsync				(dvi_hsync),
		.vsync				(dvi_vsync),
		.pixel_data			(dvi_data),
		
		.tmds_clk			({tmds_clk_p_0, tmds_clk_n_0}),
		.tmds_d0			({tmds_d_p_0[0], tmds_d_n_0[0]}),
		.tmds_d1			({tmds_d_p_0[1], tmds_d_n_0[1]}),
		.tmds_d2			({tmds_d_p_0[2], tmds_d_n_0[2]})
	);


    //ahb
    wire [31:0] AHB1HRDATA;      // Data from slave to master
	wire        AHB1HREADYOUT;   // Slave ready signal
	wire [1:0]  AHB1HRESP;       // Slave response signal  
	wire [1:0]  AHB1HTRANS;      // Transfer type
	wire [2:0]  AHB1HBURST;      // Burst type
	wire [3:0]  AHB1HPROT;       // Transfer protection bits
	wire [2:0]  AHB1HSIZE;       // Transfer size
	wire        AHB1HWRITE;      // Transfer direction
	wire        AHB1HMASTLOCK;   // Transfer is a locked transfer
	wire        AHB1HREADYMUX;   // Ready mux signal
	wire [3:0]  AHB1HMASTER;     // Transfer is a locked transfer
	wire [31:0] AHB1HADDR;       // Transfer address
	wire [31:0] AHB1HWDATA;      // Data from master to slave
	wire        AHB1HSEL;        // Select
	wire        AHB1HCLK;        // Bus clock signal
	wire        AHB1HRESET;      // Bus reset signal

      ahb_isp ahb_isp_inst(
		.AHB_HRDATA(AHB1HRDATA),
		.AHB_HREADY(AHB1HREADYOUT),//ready signal, slave to MCU master, 1'b1
		.AHB_HRESP(AHB1HRESP),//respone signal, slave to MCU master
		.AHB_HTRANS(AHB1HTRANS),
		.AHB_HBURST(AHB1HBURST),
		.AHB_HPROT(AHB1HPROT),
		.AHB_HSIZE(AHB1HSIZE),
		.AHB_HWRITE(AHB1HWRITE),
		.AHB_HMASTLOCK(AHB1HMASTLOCK),
		.AHB_HMASTER(AHB1HMASTER),
		.AHB_HADDR(AHB1HADDR),
		.AHB_HWDATA(AHB1HWDATA),
		.AHB_HSEL(AHB1HSEL),
		.AHB_HCLK(AHB1HCLK),
		.AHB_HRESETn(AHB1HRESET),
		
		.isp_reg_rd_en(isp_reg_rd_en),
		.isp_reg_wr_en(isp_reg_wr_en),
		.isp_reg_addr(isp_reg_addr),
		.isp_reg_wr_data(isp_reg_wr_data),
		.isp_reg_rd_data(isp_reg_rd_data),
		.isp_rd_rdy(isp_rd_rdy),

        .isp_vs(camera_vsync),
		.isp_disp_mode(isp_disp_mode),
		
		.update_valid(update_valid),
		.cam_awb_en(cam_awb_en),
		.cam_awb_gain_r(cam_awb_gain_r),
		.cam_awb_gain_g(cam_awb_gain_g),
		.cam_awb_gain_b(cam_awb_gain_b),
		.cam_agc_en(cam_agc_en),
		.cam_agc_gain(cam_agc_gain),
		.cam_aec_en(cam_aec_en),
		.cam_aec_exposure(cam_aec_exposure)
	);

    //mcu
    Gowin_EMPU_M1_Top Gowin_EMPU_M1_Top_inst(
		.LOCKUP         (),
	    .GPIOIN			({15'b0, isp_rd_rdy}),
		.GPIOOUT		(),
		.GPIOOUTEN		(),
        .JTAG_7(swdio), //inout JTAG_7 //swdio
		.JTAG_9(swclk), //inout JTAG_9 //swclk
		.UART0RXD       (MCU_UART_RX),
		.UART0TXD       (MCU_UART_TX),  
		.AHB1HRDATA		(AHB1HRDATA),       // Data from slave to master
		.AHB1HREADYOUT	(AHB1HREADYOUT), // Slave ready signal, from slave, 1'b1
		.AHB1HRESP		(AHB1HRESP),         // Slave response signal  
		.AHB1HTRANS		(AHB1HTRANS),       // Transfer type
		.AHB1HBURST		(AHB1HBURST),       // Burst type
		.AHB1HPROT		(AHB1HPROT),         // Transfer protection bits
		.AHB1HSIZE		(AHB1HSIZE),         // Transfer size
		.AHB1HWRITE		(AHB1HWRITE),       // Transfer direction
		.AHB1HREADYMUX	(AHB1HREADYMUX), // Ready mux
		.AHB1HMASTLOCK	(AHB1HMASTLOCK), // Transfer is a locked transfer
		.AHB1HMASTER	(AHB1HMASTER),     // Transfer is a locked transfer
		.AHB1HADDR		(AHB1HADDR),         // Transfer address
		.AHB1HWDATA		(AHB1HWDATA),       // Data from master to slave
		.AHB1HSEL		(AHB1HSEL),           // Select
		.AHB1HCLK		(AHB1HCLK),           // Clock
		.AHB1HRESET		(AHB1HRESET),       // Reset
		.HCLK           (clk50m),			// 50M
		.hwRstn         (reset_n)
	  );

	


endmodule