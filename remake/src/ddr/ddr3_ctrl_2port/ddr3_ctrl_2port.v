module ddr3_ctrl_2port(
    input           clk                 ,      //50M时钟信号
    input           memory_clk          ,      //DDR3参考时钟信号
    input           sys_rst_n           ,      //外部复位信号
    input           pll_lock            ,
    output          pll_stop            ,
    output          init_calib_complete ,    //DDR初始化完成信号
    //用户接口
    input           rd_load             ,   //输出源更新信号
    input           wr_load             ,   //输入源更新信号
    input   [28:0]  app_addr_rd_min     ,   //读DDR3的起始地址
    input   [28:0]  app_addr_rd_max     ,   //读DDR3的结束地址
    input   [7:0]   rd_bust_len         ,   //从DDR3中读数据时的突发长度
    input   [28:0]  app_addr_wr_min     ,   //写DD3的起始地址
    input   [28:0]  app_addr_wr_max     ,   //写DDR的结束地址
    input   [7:0]   wr_bust_len         ,   //向DDR3中写数据时的突发长度

    input           wr_clk              ,//wr_fifo的写时钟信号
    input           wrfifo_wren          , //wr_fifo的写使能信号
    input   [31:0]  wrfifo_din           , //写入到wr_fifo中的数据
    input           rd_clk              , //rd_fifo的读时钟信号
    input           rdfifo_rden          , //rd_fifo的读使能信号
    output  [31:0]  rdfifo_dout          , //rd_fifo读出的数据信号 

    //DDR3   
    inout   [31:0]     ddr3_dq             ,   //DDR3 数据
    inout   [3:0]      ddr3_dqs_n          ,   //DDR3 dqs负
    inout   [3:0]      ddr3_dqs            ,   //DDR3 dqs正  
    output  [14:0]     ddr3_addr           ,   //DDR3 地址   
    output  [2:0]      ddr3_ba             ,   //DDR3 banck 选择
    output             ddr3_ras_n          ,   //DDR3 行选择
    output             ddr3_cas_n          ,   //DDR3 列选择
    output             ddr3_we_n           ,   //DDR3 读写选择
    output             ddr3_reset_n        ,   //DDR3 复位
    output  [0:0]      ddr3_ck_p           ,   //DDR3 时钟正
    output  [0:0]      ddr3_ck_n           ,   //DDR3 时钟负
    output  [0:0]      ddr3_cke            ,   //DDR3 时钟使能
    output  [0:0]      ddr3_cs_n           ,   //DDR3 片选
    output  [3:0]      ddr3_dm             ,   //DDR3_dm
    output  [0:0]      ddr3_odt                //DDR3_odt   
);
    wire    ui_clk;
    wire    ui_clk_sync_rst;
    wire    app_rdy;
    wire    app_wdf_rdy;
    wire    app_rd_data_valid;
    wire [255:0] app_rd_data;
    wire [28:0] app_addr;
    wire app_en;
    wire app_wdf_wren;
    wire app_wdf_end;
    wire [2:0] app_cmd;
    wire [255:0] app_wdf_data;

    fifo_ddr3_adapter fifo_ddr3_adapter(
       .ui_clk(ui_clk)              ,    //DDR用户时钟信号
       .rst_n(sys_rst_n)               ,    //外部按键复位信号
       .init_calib_complete(init_calib_complete) ,   //DDR初始化完成信号
       .app_rdy(app_rdy)             ,   //DDR IP核空闲
       .app_wdf_rdy(app_wdf_rdy)         ,   //DDR IP写空闲
       .app_rd_data_valid(app_rd_data_valid)   ,   //DDR读数据有效信号
       .app_rd_data(app_rd_data)         ,
       .app_addr(app_addr)            ,   //DDR3地址信号
       .app_en(app_en)              ,   //DDR3命令和数据使能信号
       .app_wdf_wren(app_wdf_wren)        ,   //DDR3用户写使能信号
       .app_wdf_end(app_wdf_end)         ,   //DDR3写数据结束信号
       .app_cmd(app_cmd)             ,   //DDR3命令信号：0：写；1：读
       .app_wdf_data(app_wdf_data)        ,   //写入进DDR的数据
       .rd_load(rd_load)             ,   //输出源更新信号
       .wr_load(wr_load)             ,   //输入源更新信号
       .app_addr_rd_min(app_addr_rd_min)     ,   //读DDR3的起始地址
       .app_addr_rd_max(app_addr_rd_max)     ,   //读DDR3的结束地址
       .rd_bust_len(rd_bust_len)         ,   //从DDR3中读数据时的突发长度
       .app_addr_wr_min(app_addr_wr_min)     ,   //写DD3的起始地址
       .app_addr_wr_max(app_addr_wr_max)     ,   //写DDR的结束地址
       .wr_bust_len(wr_bust_len)         ,   //向DDR3中写数据时的突发长度
       .wr_clk(wr_clk)              ,//wr_fifo的写时钟信号
       .wrfifo_wren(wrfifo_wren)          , //wr_fifo的写使能信号
       .wrfifo_din(wrfifo_din)           , //写入到wr_fifo中的数据
       .rd_clk(rd_clk)              , //rd_fifo的读时钟信号
       .rdfifo_rden(rdfifo_rden)          , //rd_fifo的读使能信号
       .rdfifo_dout(rdfifo_dout)           //rd_fifo读出的数据信号                                      
    );

	DDR3_Memory_Interface_Top your_instance_name(
		.clk(clk), //input clk
		.pll_stop(pll_stop), //output pll_stop
		.memory_clk(memory_clk), //input memory_clk
		.pll_lock(pll_lock), //input pll_lock
		.rst_n(sys_rst_n), //input rst_n
		.cmd_ready(app_rdy), //output cmd_ready
		.cmd(app_cmd), //input [2:0] cmd
		.cmd_en(app_en), //input cmd_en
		.addr(app_addr), //input [28:0] addr
		.wr_data_rdy(app_wdf_rdy), //output wr_data_rdy
		.wr_data(app_wdf_data), //input [255:0] wr_data
		.wr_data_en(app_wdf_wren), //input wr_data_en
		.wr_data_end(app_wdf_end), //input wr_data_end
		.wr_data_mask(32'b0), //input [15:0] wr_data_mask
		.rd_data(app_rd_data), //output [255:0] rd_data
		.rd_data_valid(app_rd_data_valid), //output rd_data_valid
		.rd_data_end(), //output rd_data_end
		.sr_req(1'b0), //input sr_req
		.ref_req(1'b0), //input ref_req
		.sr_ack(), //output sr_ack
		.ref_ack(), //output ref_ack
		.init_calib_complete(init_calib_complete), //output init_calib_complete
		.clk_out(ui_clk), //output clk_out
		.ddr_rst(ui_clk_sync_rst), //output ddr_rst
		.burst(1'b1), //input burst
		.O_ddr_addr(ddr3_addr), //output [14:0] O_ddr_addr
		.O_ddr_ba(ddr3_ba), //output [2:0] O_ddr_ba
		.O_ddr_cs_n(ddr3_cs_n), //output O_ddr_cs_n
		.O_ddr_ras_n(ddr3_ras_n), //output O_ddr_ras_n
		.O_ddr_cas_n(ddr3_cas_n), //output O_ddr_cas_n
		.O_ddr_we_n(ddr3_we_n), //output O_ddr_we_n
		.O_ddr_clk(ddr3_ck_p), //output O_ddr_clk
		.O_ddr_clk_n(ddr3_ck_n), //output O_ddr_clk_n
		.O_ddr_cke(ddr3_cke), //output O_ddr_cke
		.O_ddr_odt(ddr3_odt), //output O_ddr_odt
		.O_ddr_reset_n(ddr3_reset_n), //output O_ddr_reset_n
		.O_ddr_dqm(ddr3_dm), //output [3:0] O_ddr_dqm
		.IO_ddr_dq(ddr3_dq), //inout [31:0] IO_ddr_dq
		.IO_ddr_dqs(ddr3_dqs), //inout [3:0] IO_ddr_dqs
		.IO_ddr_dqs_n(ddr3_dqs_n) //inout [3:0] IO_ddr_dqs_n
	);

endmodule 