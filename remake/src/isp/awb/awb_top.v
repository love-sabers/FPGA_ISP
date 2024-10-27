module awb_top #(
    parameter source_h  = 512,
	parameter source_v  = 512
) (
    input       clk,
    input       reset_n,
    input       in_vsync,		
    input       in_hsync,		
    input       in_den,			
	input [7:0] in_data_R, 	
    input [7:0] in_data_G, 	
    input [7:0] in_data_B, 	

    output reg      out_vsync,		
    output reg      out_hsync,		
    output reg      out_den,			
	output reg[7:0] out_data_R, 	
    output reg[7:0] out_data_G,
    output reg[7:0] out_data_B
);

//对输入信号进行打拍处理
reg         r_vsync;
reg         r_hsync;
reg         r_den;
always @(posedge clk) begin
    r_vsync<=in_vsync;
    r_hsync<=in_hsync;
    r_den<=in_den;
end

//计算增益
reg [16-1:0] line_R;
reg [16-1:0] line_G;
reg [16-1:0] line_B;

reg [16-1:0] frame_R;
reg [16-1:0] frame_G;
reg [16-1:0] frame_B;

reg [16-1:0] mean_R;
reg [16-1:0] mean_G;
reg [16-1:0] mean_B;

reg [24-1:0] gain_R;
reg [24-1:0] gain_B;


initial begin
    // mean_R  <=16'd1;
    // mean_G  <=16'd1;
    // mean_B  <=16'd1;
    gain_R  <=24'd1;
    gain_B  <=24'd1;
    line_R  <=16'd0;
    line_G  <=16'd0;
    line_B  <=16'd0;
    frame_R <=16'd16;
    frame_G <=16'd16;
    frame_B <=16'd16;
end
always @(posedge clk or negedge reset_n) begin
    if(!reset_n)begin
        // mean_R  <=16'd1;
        // mean_G  <=16'd1;
        // mean_B  <=16'd1;
        gain_R  <=24'd1;
        gain_B  <=24'd1;
        line_R  <=16'd0;
        line_G  <=16'd0;
        line_B  <=16'd0;
        frame_R <=16'd16;
        frame_G <=16'd16;
        frame_B <=16'd16;
    end else if (~in_vsync) begin
        gain_R<=24'd256*{8'd0,frame_G}/{{8'd0,frame_R}};
        gain_B<=24'd256*{8'd0,frame_G}/{{8'd0,frame_B}};
        // mean_R  <={4'd0,frame_R[15:4]};
        // mean_G  <={4'd0,frame_G[15:4]};
        // mean_B  <={4'd0,frame_B[15:4]};
        frame_R <=16'd0;
        frame_G <=16'd0;
        frame_B <=16'd0;
    end else if ({r_hsync,in_hsync}==2'b10) begin
        frame_R <=frame_R+{8'd0,line_R[15:8]};
        frame_G <=frame_G+{8'd0,line_R[15:8]};
        frame_B <=frame_B+{8'd0,line_R[15:8]};
        line_R  <=16'd0;
        line_G  <=16'd0;
        line_B  <=16'd0;
    end else if (in_hsync) begin
        line_R  <=line_R+{12'd0,in_data_R[7:4]};
        line_G  <=line_G+{12'd0,in_data_G[7:4]};
        line_B  <=line_B+{12'd0,in_data_B[7:4]};
    end 
end

//计算图像
reg [16-1:0] r_data_R;
reg [8-1:0] r_data_G;
reg [16-1:0] r_data_B;
always @(posedge clk ) begin
    r_data_R<={8'd0,in_data_R}*gain_R[15:0];
    r_data_G<=in_data_G;
    r_data_B<={8'd0,in_data_B}*gain_B[15:0];

    // r_data_R<={4'd0,mean_R+mean_G};
    // r_data_B<={4'd0,mean_B+mean_G};
end

//awb输出
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        out_vsync<=1'b0;
        out_hsync<=1'b0;
        out_den<=1'b0;
        out_data_R<=8'd0;
        out_data_G<=8'd0;
        out_data_B<=8'd0;
    end else begin
        out_vsync<=r_vsync;
        out_hsync<=r_hsync;
        out_den<=r_den;

        out_data_R<=r_data_R[15:8];
        out_data_G<=r_data_G[7:0];
        out_data_B<=r_data_B[15:8];

        // if (r_data_R<20'd255) begin
        //     out_data_R<=r_data_R[7:0];
        // end else begin
        //     out_data_R<=8'hff;
        // end

        // out_data_G<=r_data_G; 

        // if (r_data_B<20'd255) begin
        //     out_data_B<=r_data_B[7:0];
        // end else begin
        //     out_data_B<=8'hff;
        // end
        

    end
end
    
endmodule