

module video_timing_ctrl #(
	
	parameter video_hlength		= 2200,//总时钟周期数
	parameter video_vlength		= 1125,//总扫描线数

	parameter video_hsync_pol	= 1,//水平同步信号极性
	parameter video_hsync_len	= 44,//水平同步信号长度
	parameter video_hbp_len		= 148,//水平消隐区长度	
	parameter video_h_visible	= 1920,//水平像素数

	parameter video_vsync_pol	= 1,//垂直同步信号极性
	parameter video_vsync_len	= 5,//垂直同步信号长度
	parameter video_vbp_len		= 36,//垂直消隐区长度
	parameter video_v_visible	= 1080,//垂直行数
	
	//用来决定何时开始渲染下一行或下一帧
	parameter sync_v_pos		= 132,//水平同步参数
	parameter sync_h_pos		= 1079//垂直同步参数
)
(
	input				pixel_clock,
	input				reset,
	input				ext_sync,//外部同步信号输入
	
	output	[13 : 0]	timing_h_pos,//水平时序
	output	[13 : 0]	timing_v_pos,//垂直时序
	output	[13 : 0]	pixel_x,//水平坐标
	output	[13 : 0]	pixel_y,//垂直坐标
	
	output				video_hsync,
	output				video_vsync,
	
	output				video_den,//数据有效信号，指示数据是否在显示区域
	output				video_line_start//行开始信号，
);
	
	localparam t_hsync_end = video_hsync_len - 1;
	localparam t_hvis_begin = video_hsync_len + video_hbp_len;
	localparam t_hvis_end = t_hvis_begin + video_h_visible - 1;
	
	localparam t_vsync_end = video_vsync_len - 1;
	localparam t_vvis_begin = video_vsync_len + video_vbp_len;
	localparam t_vvis_end = t_vvis_begin + video_v_visible - 1;
	
	reg		[13 : 0]	h_pos;
	reg		[13 : 0]	v_pos;
	
	wire	[13 : 0]	x_int;
	wire	[13 : 0]	y_int;
	
	wire				v_visible;
	wire				h_visible;
	
	wire				hsync_pos;
	wire				vsync_pos;
	
	reg					ext_sync_last;
	reg					ext_sync_curr;
	
	always@(posedge pixel_clock)begin
		
		if(reset)begin
			
			h_pos <= 0;
			v_pos <= 0;
			
		end else begin
			
			if(ext_sync_curr & !ext_sync_last)begin
				
				h_pos <= sync_h_pos;
				v_pos <= sync_v_pos;
				
			end else begin
				
				if(h_pos == (video_hlength-1))begin
					
					h_pos <= 0;
					
					if(v_pos == (video_vlength-1))begin
						v_pos <= 0;
					end else begin
						v_pos <= v_pos + 1'b1;
					end
					
				end else begin
					h_pos <= h_pos + 1'b1;
				end
			end
			
			ext_sync_curr <= ext_sync;
			ext_sync_last <= ext_sync_curr;
		end
	end
	
	assign v_visible = ((v_pos >= t_vvis_begin) & (v_pos <= t_vvis_end)) ? 1'b1 : 1'b0;
	assign h_visible = ((h_pos >= t_hvis_begin) & (h_pos <= t_hvis_end)) ? 1'b1 : 1'b0;
	
	assign x_int = (h_visible & v_visible) ? (h_pos - t_hvis_begin[13:0]) : 14'd0;
	assign y_int = (v_visible) ? (v_pos - t_vvis_begin[13:0]) : 14'd0;
	
	assign video_den = (h_visible & v_visible);
	assign video_line_start = (v_visible & (h_pos == 0)) ? 1'b1 : 1'b0;
	
	assign vsync_pos = (v_pos <= t_vsync_end) ? 1'b1 : 1'b0;
	assign hsync_pos = (h_pos <= t_hsync_end) ? 1'b1 : 1'b0;
	
	assign video_vsync = (video_vsync_pol) ? vsync_pos : ~vsync_pos;
	assign video_hsync = (video_hsync_pol) ? hsync_pos : ~hsync_pos;
	
	assign timing_h_pos = h_pos;
	assign timing_v_pos = v_pos;
	assign pixel_x = x_int;
	assign pixel_y = y_int;
	
endmodule
