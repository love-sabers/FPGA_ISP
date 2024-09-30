module gao_ov5640_ddr_hdmi(
    //System clock reset
    input       clk50M        , //系统时钟输入，50MHz
    input       reset_n       , //复位信号输入

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
    //led
    output [3:0]led           ,

    //hdmi output
	output       	tmds_clk_p ,
	output       	tmds_clk_n ,
	output 	[2:0]   tmds_data_p,    //rgb
	output 	[2:0]   tmds_data_n,     //rgb

    //ddr
    output [13:0] O_ddr_addr        ,
    output [2:0] O_ddr_ba           ,
    output O_ddr_cs_n               ,
    output O_ddr_ras_n              ,
    output O_ddr_cas_n              ,
    output O_ddr_we_n               ,
    output O_ddr_clk                ,
    output O_ddr_clk_n              ,
    output O_ddr_cke                ,
    output O_ddr_odt                ,
    output O_ddr_reset_n            ,
    output [1:0] O_ddr_dqm          ,
    inout [15:0] IO_ddr_dq          ,
    inout [1:0] IO_ddr_dqs          ,
    inout [1:0] IO_ddr_dqs_n        

);
    //Set IMAGE Size  
    parameter IMAGE_WIDTH  = 1280;
    parameter IMAGE_HEIGHT = 720;

    wire          loc_clk24m;
    wire          g_rst_p;
    wire          clk_200M;
    wire          pll_lock;
    wire          loc_clk50m;
    //camera
    wire          camera_init_done;
    wire          pclk_bufg_o;

    //ddr
	wire fifo_aclr;
	wire fifo_wrreq;
	wire [15:0] fifo_wrdata;
    wire init_calib_complete;
    
    //hdmi
    wire clk_vga;//74.25m
	wire clk_vgax5;//371.25m
    wire hdmi_pll_lock;

	wire [11:0] hcount;
	wire [11:0] vcount;
	wire [23:0] disp_data;
 
	wire video_hs;
	wire video_vs;
	wire video_de;
	wire [7:0] video_r;
	wire [7:0] video_g;
	wire [7:0] video_b;


    assign  g_rst_p = ~pll_lock;

    assign led = {~g_rst_p,camera_init_done,init_calib_complete,pll_lock};
    
    
    camera_pll camera_pll(
        .clkout0(clk_vgax5), //output clkout0
        .clkout1(loc_clk24m), //output clkout1
        .clkin(loc_clk50m) //input clkin
    );

    Gowin_PLL Gowin_PLL(
        .lock(pll_lock), //output lock
        .clkout0(clk_200M), //output clkout0
        .clkout1(loc_clk50m), //output clkout1
        .clkin(clk50M), //input clkin
        .reset(~reset_n) //input reset
    );


    CLKDIV u_clkdiv
    (.RESETN(pll_lock)
    ,.HCLKIN(clk_vgax5) //clk  x5
    ,.CLKOUT(clk_vga)    //clk  x1
    ,.CALIB (1'b1)
    );
    defparam u_clkdiv.DIV_MODE="5";


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
        .Rst_n       (reset_n         ),
        .Init_Done   (camera_init_done ),
        .camera_rst_n(camera_rst_n     ),
        .camera_pwdn (camera_pwdn      ),
        .i2c_sclk    (camera_sclk      ),
        .i2c_sdat    (camera_sdat      )
    );
    
    assign pclk_bufg_o = camera_pclk;

    DVP_Capture DVP_Capture(
        .Rst_n      (reset_n         ),//input
        .PCLK       (pclk_bufg_o      ),//input
        .Vsync      (camera_vsync     ),//input
        .Href       (camera_href      ),//input
        .Data       (camera_data      ),//input     [7:0]

        .ImageState (fifo_aclr        ),//output reg
        .DataValid  (fifo_wrreq       ),//output
        .DataPixel  (fifo_wrdata      ),//output    [15:0]
        .DataHs     (                 ),//output
        .DataVs     (wr_load          ),//output
        .Xaddr      (                 ),//output    [11:0],start is 1
        .Yaddr      (                 )   //output    [11:0],start is 1
    );
    

    wire rdfifo_rden;
    wire wrfifo_clr;
    wire [15:0] wrfifo_din;
    wire wrfifo_clk;
    wire rdfifo_clr;
    wire rdfifo_clk;
    wire [15:0] rdfifo_dout;
    
    
    assign wrfifo_clr = fifo_aclr;
    assign wrfifo_clk = pclk_bufg_o;
    assign rdfifo_clr = 0;
    assign rdfifo_clk = clk_vga;
    assign wrfifo_wren = fifo_wrreq;
    assign wrfifo_din = fifo_wrdata;
    assign disp_data = {rdfifo_dout[15:11],3'd0,rdfifo_dout[10:5],2'd0,rdfifo_dout[4:0],3'd0}; 

    wire [27:0] app_addr_max = IMAGE_WIDTH * IMAGE_HEIGHT;
    wire [7:0] burst_len = IMAGE_WIDTH[10:3];

    ddr3_ctrl_2port ddr3_ctrl_2port(
        .clk(loc_clk50m)                 ,      //50M时钟信号
        .pll_lock(pll_lock)            ,
        .clk_200m(clk_200M)            ,      //DDR3参考时钟信号
        .sys_rst_n(reset_n)           ,      //外部复位信号
        .init_calib_complete(init_calib_complete) ,    //DDR初始化完成信号

        //用户接口
        .rd_load(video_vs)             ,   //输出源更新信号
        .wr_load(wr_load)             ,   //输入源更新信号
        .app_addr_rd_min(28'd0)     ,   //读DDR3的起始地址
        .app_addr_rd_max(app_addr_max)     ,   //读DDR3的结束地址
        .rd_bust_len(burst_len)         ,   //从DDR3中读数据时的突发长度
        .app_addr_wr_min(28'd0)     ,   //写DD3的起始地址
        .app_addr_wr_max(app_addr_max)     ,   //写DDR的结束地址
        .wr_bust_len(burst_len)         ,   //向DDR3中写数据时的突发长度

        .wr_clk(wrfifo_clk)             ,//wr_fifo的写时钟信号
        .wfifo_wren(wrfifo_wren)          , //wr_fifo的写使能信号
        .wfifo_din(wrfifo_din)           , //写入到wr_fifo中的数据
        .rd_clk(rdfifo_clk)              , //rd_fifo的读时钟信号
        .rfifo_rden(rdfifo_rden)          , //rd_fifo的读使能信号
        .rfifo_dout(rdfifo_dout)          , //rd_fifo读出的数据信号 

        //DDR3   
        .ddr3_dq(IO_ddr_dq)             ,   //DDR3 数据
        .ddr3_dqs_n(IO_ddr_dqs_n)          ,   //DDR3 dqs负
        .ddr3_dqs_p(IO_ddr_dqs)          ,   //DDR3 dqs正  
        .ddr3_addr(O_ddr_addr)           ,   //DDR3 地址   
        .ddr3_ba(O_ddr_ba)             ,   //DDR3 banck 选择
        .ddr3_ras_n(O_ddr_ras_n)          ,   //DDR3 行选择
        .ddr3_cas_n(O_ddr_cas_n)          ,   //DDR3 列选择
        .ddr3_we_n(O_ddr_we_n)           ,   //DDR3 读写选择
        .ddr3_reset_n(O_ddr_reset_n)        ,   //DDR3 复位
        .ddr3_ck_p(O_ddr_clk)          ,   //DDR3 时钟正
        .ddr3_ck_n(O_ddr_clk_n)           ,   //DDR3 时钟负
        .ddr3_cke(O_ddr_cke)            ,   //DDR3 时钟使能
        .ddr3_cs_n(O_ddr_cs_n)           ,   //DDR3 片选
        .ddr3_dm(O_ddr_dqm)             ,   //DDR3_dm
        .ddr3_odt(O_ddr_odt)                //DDR3_odt   
    );
   

    //HDMI显示
    disp_driver disp_driver(
		.ClkDisp(clk_vga),
		.Rst_n(reset_n),
		.Data(disp_data),
		.DataReq(rdfifo_rden),
		.H_Addr(hcount),
		.V_Addr(vcount),
		.Disp_HS(video_hs),
		.Disp_VS(video_vs),
		.Disp_Red(video_r),
		.Disp_Green(video_g),
		.Disp_Blue(video_b),
        .Frame_Begin(),
		.Disp_DE(video_de),
		.Disp_PCLK()
	);
	
	dvi_encoder u_dvi_encoder(
		.pixelclk(clk_vga),// system clock
		.pixelclk5x(clk_vgax5),// system clock x5
		.rst_n(reset_n),// reset
		.blue_din(video_b),// Blue data in
		.green_din(video_g),// Green data in
		.red_din(video_r),// Red data in
		.hsync(video_hs),// hsync data
		.vsync(video_vs),// vsync data
		.de(video_de),// data enable
		.tmds_clk_p(tmds_clk_p),
		.tmds_clk_n(tmds_clk_n),
		.tmds_data_p(tmds_data_p),//rgb
		.tmds_data_n(tmds_data_n) //rgb
	);


endmodule