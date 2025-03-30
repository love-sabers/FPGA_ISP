module top
#(
	parameter source_h  = 1024,
	parameter source_v  = 1024,

	parameter video_hlength		= 2200,
	parameter video_hsync_pol	= 1,
	parameter video_hsync_len	= 44,
	parameter video_hbp_len		= 148,
	parameter video_h_visible	= 1920,

    parameter video_vlength		= 1125,
	parameter video_vsync_pol	= 1,
	parameter video_vsync_len	= 5,
	parameter video_vbp_len		= 36,
	parameter video_v_visible	= 1080,

    parameter isp_disp_mode_num	= 6
)
(

    input clk50m,
    input reset_n,
    //led
    output [5:0] led,

    //
    input button,

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
	output [2:0] tmds_d_p_0,

    //uart
    input                        uart_rx,
	output                       uart_tx,

    //e203 uart
    input                        e203_uart_rx,
	output                       e203_uart_tx
);
    assign i2c_sel = 'b101;
    assign led={1'b1,~camera_init_done,~ddr_init_calib_complete,1'b0,1'b0,1'b0};


    // wire 	[7 : 0]	    gen_data;
	// wire				gen_den;
	// wire				gen_hsync;
	// wire				gen_vsync;
    
    // test_pattern_gen test_gen0(
		
	// 	.pixel_clock		(hdmi_clk148m5),
	// 	.reset				(~sys_resetn),
		
	// 	.video_vsync		(gen_vsync),
	// 	.video_hsync		(gen_hsync),
	// 	.video_den			(gen_den),
	// 	.video_pixel_raw 	(gen_data)
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

    wire DVP_clk;
    wire DVP_DataValid;
    wire DVP_DataVs;
    wire DVP_DataHs;
    wire [7:0] DVP_DataPixel;

    DVP_Capture_raw DVP_Capture(
        .Rst_n      (reset_n         ),//input
        .PCLK       (camera_pclk      ),//input
        .Vsync      (camera_vsync     ),//input
        .Href       (camera_href      ),//input
        .Data       (camera_data      ),//input     [7:0]

        .ImageState (                 ),//output reg
        .DataClk    (DVP_clk          ),
        .DataValid  (DVP_DataValid    ),//output
        .DataPixel  (DVP_DataPixel    ),//output    [15:0]
        .DataHs     (DVP_DataHs       ),//output
        .DataVs     (DVP_DataVs       )//output
        // .Xaddr      (                 ),//output    [11:0],start is 1
        // .Yaddr      (                 ) //output    [11:0],start is 1
    );

    // assign outlook_clk_cam=camera_pclk;
    // assign outlook_vs_cam=camera_vsync;
    // assign outlook_den_cam=camera_href;

    // assign outlook_clk_dvp=DVP_clk;
    // assign outlook_vs_dvp=DVP_DataVs;
    // assign outlook_den_dvp=DVP_DataValid;

    // assign outlook_clk=tmp_clk;
    // assign outlook_vs=gen_vsync;
    // assign outlook_den=gen_den;

    reg [7:0] tx_data;
    uart_test myuart(
        .clk(clk50m),
        .rst(~reset_n),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .tx_data(tx_data)
    );


    wire [31:0] gpio_in;
    wire [31:0] gpio_out;
    wire [3:0]  e203_gamma_type;
    e203_soc_demo e203_inst(
        .clk_in(clk50m), //50MHz clock input 
        .erstn(erstn), // Erst is input need to be pull-up by default
        .gpio_in(gpio_in),
        .gpio_out(gpio_out)
    );
    assign gpio_in[16:16]=e203_uart_rx;
    assign e203_uart_tx=gpio_out[17:17];
    assign e203_gamma_type=gpio_out[3:0];



    reg [1:0] gamma_type;  // 用来保存 gamma 的值
    // gamma_type 的值根据 tx_data 来设置
    always @ (posedge clk50m or negedge reset_n) begin
        if (~reset_n) begin
            gamma_type <= 2'd2;  // 复位时，gamma_type 初始化为 0
        end else begin
            case (tx_data)
                8'h31: gamma_type <= 2'd1;  // gamma=1.8
                8'h32: gamma_type <= 2'd2;  // gamma=2.2
                8'h33: gamma_type <= 2'd3;  // gamma=2.4
                default: gamma_type <= 2'd2; // 其他情况下，gamma_type 保持为 0
            endcase
        end
    end
    

    //isp
	wire isp_clk;
	wire isp_vsync;
	wire isp_den;
	wire [7:0] isp_data_R;
	wire [7:0] isp_data_G;
	wire [7:0] isp_data_B;
	
    //isp mode select
	wire [3:0] isp_disp_mode;

    reg [3:0] isp_mode;//0:RAW 1:CFA 2:AWB 3:CCM 4:GAMMA  
    reg lastbutton;
    reg curbutton;

    initial begin
        isp_mode<=4'd0;
    end
    always @(posedge clk50m or negedge reset_n) begin
        if(!reset_n)begin
            isp_mode<=4'd0;
        end else begin
            lastbutton<=curbutton;
            curbutton<=button;
            if(!lastbutton & curbutton)begin
                if(isp_mode < isp_disp_mode_num)
                    isp_mode<=isp_mode + 4'b1;
                else 
                    isp_mode<=4'd0;
            end    
        end
    end

    
    
    
    isp_top  #(
        .source_h(source_h),
        .source_v(source_v)
	)isp_inst(
		.reset_n    (reset_n),

        .clk        (DVP_clk),
        .in_vsync   (DVP_DataVs),
        .in_hsync   (DVP_DataHs),
		.in_den     (DVP_DataValid),
		.in_data    (DVP_DataPixel),

        .isp_disp_mode(isp_mode),
        .gamma_type(e203_gamma_type[1:0]),
	
        .out_clk    (isp_clk),
		.out_vsync  (isp_vsync),
		.out_den    (isp_den),
		.out_data_R (isp_data_R),
		.out_data_G (isp_data_G),
		.out_data_B (isp_data_B)
	);

    // assign outlook_clk=isp_clk;
    // assign outlook_den=isp_den;
    // assign outlook_vs=isp_vsync;


    

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

    //isp
    assign wr_load=isp_vsync;
    assign wrfifo_wren=isp_den;
    assign wrfifo_clk=isp_clk;
    assign wrfifo_din={isp_data_R[7:0],isp_data_G[7:0],isp_data_B[7:0],8'hFF};

    //dvp raw
    // assign wr_load=DVP_DataVs;
    // assign wrfifo_wren=DVP_DataValid;
    // assign wrfifo_clk=camera_pclk;
    // assign wrfifo_din={DVP_DataPixel[7:0],DVP_DataPixel[7:0],DVP_DataPixel[7:0],8'hFF};

    //dvp rgb
    // assign wr_load=DVP_DataVs;
    // assign wrfifo_wren=DVP_DataValid;
    // assign wrfifo_clk=camera_pclk;
    // assign wrfifo_din={DVP_DataPixel[15:11],3'd0,DVP_DataPixel[10:5],2'd0,DVP_DataPixel[4:0],3'd0,8'hFF};

    //gen
    // assign wr_load=gen_vsync;
    // assign wrfifo_wren=gen_den;
    // assign wrfifo_clk=hdmi_clk148m5;
    // assign wrfifo_din={gen_data,8'hFF};

    //大小参数
    wire [28:0] app_addr_max = source_h*source_v;
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
        .app_addr_rd_min_in(29'd0)     ,   //读DDR3的起始地址
        .app_addr_rd_max_in(app_addr_max)     ,   //读DDR3的结束地址
        .rd_bust_len(burst_len)         ,   //从DDR3中读数据时的突发长度
        .app_addr_wr_min_in(29'd0)     ,   //写DD3的起始地址
        .app_addr_wr_max_in(app_addr_max)     ,   //写DDR的结束地址
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
        .ext_sync			(1'b0),

        //读ddr
        .rd_load(rd_load)                   ,//输出源更新信号
        .rd_clk(rdfifo_clk)                 ,//rd_fifo的读时钟信号
        .rdfifo_rden(rdfifo_rden)            ,//rd_fifo的读使能信号
        .rdfifo_dout(rdfifo_dout)            ,//rd_fifo读出的数据信号 
		
        //tmds 发送器 输入
		.video_vsync		(dvi_vsync),
		.video_hsync		(dvi_hsync),
		.video_den			(dvi_den),
		.video_pixel       	(dvi_data)
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

	


endmodule