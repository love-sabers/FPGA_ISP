module top
#(
	
	parameter video_hlength		= 2200,
	parameter video_vlength		= 1125,

	parameter video_hsync_pol	= 1,
	parameter video_hsync_len	= 44,
	parameter video_hbp_len		= 148,
	parameter video_h_visible	= 1920,

	parameter video_vsync_pol	= 1,
	parameter video_vsync_len	= 5,
	parameter video_vbp_len		= 36,
	parameter video_v_visible	= 1080
)
(
    //system
    input clk,
    input reset_n,

    //led
    output [5:0] led,

    //hdmi
    output       tmds_clk_n_0,
	output       tmds_clk_p_0,
	output [2:0] tmds_d_n_0,
	output [2:0] tmds_d_p_0,

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
    inout [3:0] ddr_dqs_n        

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
);
    assign led={1'b1,1'b0,1'b0,1'b0,1'b0,1'b0};

    //ddr_PLL

    wire ddr_pll_lock;
    wire ddr_clk100m;
    wire ddr_memory_clk;
    wire ddr_pll_stop;
    wire ddr_init_calib_complete;
    ddr_PLL ddr_PLL_inst(
        .lock(ddr_pll_lock),//output lock
        .clkout0(), //output clkout0
        .clkout1(ddr_clk100m), //output clkout1
        .clkout2(ddr_memory_clk), //output clkout2
        .clkin(clk), //input clkin
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
    

    //大小参数
    wire [28:0] app_addr_max = video_h_visible*video_v_visible;
    wire [7:0] burst_len = video_h_visible[10:3];


    ddr3_ctrl_2port ddr3_ctrl_2port(
        .clk(ddr_clk100m)                 ,      //100M时钟信号
        .memory_clk(ddr_memory_clk)            ,      //DDR3参考时钟信号
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
        .wfifo_wren(wrfifo_wren)          , //wr_fifo的写使能信号
        .wfifo_din(wrfifo_din)           , //写入到wr_fifo中的数据

        .rd_clk(rdfifo_clk)              , //rd_fifo的读时钟信号
        .rfifo_rden(rdfifo_rden)          , //rd_fifo的读使能信号
        .rfifo_dout(rdfifo_dout)          , //rd_fifo读出的数据信号 

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
	wire        clk_hdmi5;
	wire        clk_hdmi;

    hdmi_PLL hdmi_PLL_inst(
        .lock(hdmi_pll_lock), //output lock
        .clkout0(clk_hdmi), //output clkout0
        .clkout1(clk_hdmi5), //output clkout1
        .clkin(clk) //input clkin
    );

    //hdmi_reset
    wire        sys_resetn;
    Reset_Sync u_Reset_Sync (
		.reset_n(sys_resetn),
		.ext_reset(reset_n & hdmi_pll_lock),
		.clk(clk_hdmi)
	);

    //dvi
    wire 	[23 : 0]	dvi_data;
	wire				dvi_den;
	wire				dvi_hsync;
	wire				dvi_vsync;

    disp_driver  #(	
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
	)disp_driver0(
		.pixel_clock		(clk_hdmi),
		.reset				(~sys_resetn),

        //读ddr
        .rd_load(rd_load)                   ,//输出源更新信号
        .rd_clk(rdfifo_clk)                 ,//rd_fifo的读时钟信号
        .rfifo_rden(rdfifo_rden)            ,//rd_fifo的读使能信号
        .rfifo_dout(rdfifo_dout)            ,//rd_fifo读出的数据信号 
		
        //tmds 发送器 输入
		.video_vsync		(dvi_vsync),
		.video_hsync		(dvi_hsync),
		.video_den			(dvi_den),
		.video_pixel       	(dvi_data),
        .video_line_start   ()
	);

    dvi_tx_top dvi_tx_top_inst(//tmds 发送器
		
		.pixel_clock		(clk_hdmi),
		.ddr_bit_clock		(clk_hdmi5),
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

    //Set IMAGE Size  
    parameter IMAGE_WIDTH  = 800;
    parameter IMAGE_HEIGHT = 480;

    wire          loc_clk24m;
    wire          g_rst_p;
    wire          clk_200M;
    wire          pll_lock;
    wire          loc_clk50m;
    wire          loc_clk33m;
    //camera
    wire          camera_init_done;
    wire          pclk_bufg_o;
    
    assign  g_rst_p = ~pll_lock;

    Gowin_PLL Gowin_PLL(
        .lock(pll_lock), //output lock
        .clkout0(loc_clk50m), //output clkout0
        .reset(~reset_n) //input reset
    );
	
    assign camera_xclk = loc_clk24m;

    //摄像头
    camera_init
    #(
        .SYS_CLOCK      ( 50_000_000   ),//系统时钟采用50MHz
        .SCL_CLOCK      ( 400_000      ),//SCL总线时钟采用400kHz
        .CAMERA_TYPE    ( "ov5640"     ),//"ov5640" or "ov7725"
        .IMAGE_TYPE     ( 0            ),// 0: RGB; 1: JPEG
        .IMAGE_WIDTH    ( IMAGE_WIDTH  ),// 图片宽度
        .IMAGE_HEIGHT   ( IMAGE_HEIGHT ),// 图片高度
        .IMAGE_FLIP_EN  ( 0            ),// 0: 不翻转，1: 上下翻转
        .IMAGE_MIRROR_EN( 0            ) // 0: 不镜像，1: 左右镜像
    )camera_init
    (
        .Clk         (loc_clk50m       ),
        .Rst_n       (~g_rst_p         ),
        .Init_Done   (camera_init_done ),
        .camera_rst_n(camera_rst_n     ),
        .camera_pwdn (camera_pwdn      ),
        .i2c_sclk    (camera_sclk      ),
        .i2c_sdat    (camera_sdat      )
    );

    assign pclk_bufg_o = camera_pclk;
    //DVP
    DVP_Capture DVP_Capture(
        .Rst_n      (reset_n         ),//input
        .PCLK       (pclk_bufg_o      ),//input
        .Vsync      (camera_vsync     ),//input
        .Href       (camera_href      ),//input
        .Data       (camera_data      ),//input     [7:0]

        .ImageState (wrfifo_clk        ),//output reg
        .DataValid  (wrfifo_wren      ),//output
        .DataPixel  (wrfifo_din      ),//output    [31:0]
        .DataHs     (                 ),//output
        .DataVs     (                 ),//output
        .Xaddr      (                 ),//output    [11:0],start is 1
        .Yaddr      (                 )   //output    [11:0],start is 1
    );

endmodule