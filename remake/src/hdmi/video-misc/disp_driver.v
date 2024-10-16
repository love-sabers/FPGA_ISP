`timescale 1ns / 1ns

module disp_driver #(

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
	input				pixel_clock,
	input				reset,

	output				rd_load		, //输出源更新信号
	output 				rd_clk      , //rd_fifo的读时钟信号
	output 				rdfifo_rden  , //rd_fifo的读使能信号
    input 	[31:0]		rdfifo_dout  , //rd_fifo读出的数据信号 
	
	output				video_vsync,
	output				video_hsync,
	output				video_den,
	output				video_line_start,
	output	[23 : 0]	video_pixel//从高到低，RGB
);

	
	
	wire				den_int;
	wire	[13 : 0]	pixel_x;
	wire	[13 : 0]	pixel_y;

	assign rd_load = video_vsync;
	assign rd_clk = pixel_clock;
	assign rdfifo_rden = den_int & (pixel_x<source_h) & (pixel_y<source_v);
	assign video_den = den_int;

	assign video_pixel = (rdfifo_rden) ? rdfifo_dout[31:8] : 24'h000000;
	
	video_timing_ctrl #(
		
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
		
	)video_timing_ctrl_inst0(
		
		.pixel_clock		(pixel_clock),
		.reset				(reset),
		.ext_sync			(1'b0),
		
		.timing_h_pos		(),
		.timing_v_pos		(),
		.pixel_x			(pixel_x),
		.pixel_y			(pixel_y),
		
		.video_vsync		(video_vsync),
		.video_hsync		(video_hsync),
		.video_den			(den_int),
		.video_line_start	(video_line_start)
	);
	
endmodule
