module cfa_top #(
    parameter source_h  = 1024,
	parameter source_v  = 1024,
    parameter raw_type  = 0
    // 0: BGGR
    // 1: RGGB
    // 2: GBRG
    // 3: GRBG
) (
    input       clk,
    input       reset_n,
    input       in_vsync,		
    input       in_hsync,		
    input       in_den,			
	input [7:0] in_raw, 	

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
reg [7:0]   r_in_raw;
always @(posedge clk) begin
    r_vsync<=in_vsync;
    r_hsync<=in_hsync;
    r_den<=in_den;
end

always @(posedge clk) begin
    if(in_den) begin
        r_in_raw<=in_raw;
    end else begin
        r_in_raw<=8'hff;
    end
    
end

//计算位置
reg [11:0] r_index;
reg [11:0] r_Xaddr;
reg [11:0] r_Yaddr;

initial begin
    r_Xaddr<=12'd0;
    r_index<=12'd0;
    r_Yaddr<=12'd0;
end

always @(posedge clk or negedge reset_n) begin
    if(!reset_n)begin
        r_Xaddr<=12'd0;
        r_index<=12'd0;
    end else if (in_hsync) begin
        r_Xaddr<=r_Xaddr+12'd1;
        r_index<=r_index+12'd1;
    end else begin
        r_Xaddr<=12'd0;
        r_index<=12'd0;
    end
end

always @(posedge clk or negedge reset_n) begin
    if(!reset_n)begin
        r_Yaddr<=12'd0;
    end else if (~in_vsync) begin
        r_Yaddr<=12'd0;
    end else if ({r_hsync,in_hsync}==2'b01) begin
        r_Yaddr<=r_Yaddr+12'd1;
    end else begin
        r_Yaddr<=r_Yaddr;
    end
end

wire[7:0]  r_up_raw;//up 
reg [7:0]  r_ul_raw;//up left
reg [7:0]  r_le_raw;//left

reg [7:0]  ram[source_h:0];
assign r_up_raw=ram[r_index];

always @(posedge clk ) begin
    ram[r_index]<=r_in_raw;
end

//存储left，upleft
always @(posedge clk ) begin
    r_ul_raw<=r_up_raw;
    r_le_raw<=r_in_raw;
end


//cfa输出
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

        case (raw_type)
            0:begin
                if (r_Xaddr<=12'd1 | r_Yaddr<=12'd1) begin
                    out_data_R<=8'h01;
                    out_data_G<=8'h01; 
                    out_data_B<=8'h01;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b00) begin
                    out_data_R<=r_in_raw;
                    out_data_G<={1'b0,r_up_raw[7:1]}+{1'b0,r_le_raw[7:1]};
                    out_data_B<=r_ul_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b10) begin
                    out_data_R<=r_le_raw;
                    out_data_G<={1'b0,r_in_raw[7:1]}+{1'b0,r_ul_raw[7:1]};
                    out_data_B<=r_up_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b01) begin
                    out_data_R<=r_up_raw;
                    out_data_G<={1'b0,r_in_raw[7:1]}+{1'b0,r_ul_raw[7:1]};
                    out_data_B<=r_le_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b11) begin
                    out_data_R<=r_ul_raw;
                    out_data_G<={1'b0,r_up_raw[7:1]}+{1'b0,r_le_raw[7:1]};
                    out_data_B<=r_in_raw;
                end
            end 
            1:begin
                if (r_Xaddr<=12'd1 | r_Yaddr<=12'd1) begin
                    out_data_R<=8'h01;
                    out_data_G<=8'h01; 
                    out_data_B<=8'h01;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b00) begin
                    out_data_R<=r_ul_raw;
                    out_data_G<={1'b0,r_up_raw[7:1]}+{1'b0,r_le_raw[7:1]};
                    out_data_B<=r_in_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b10) begin
                    out_data_R<=r_up_raw;
                    out_data_G<={1'b0,r_in_raw[7:1]}+{1'b0,r_ul_raw[7:1]};
                    out_data_B<=r_le_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b01) begin
                    out_data_R<=r_le_raw;
                    out_data_G<={1'b0,r_in_raw[7:1]}+{1'b0,r_ul_raw[7:1]};
                    out_data_B<=r_up_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b11) begin
                    out_data_R<=r_in_raw;
                    out_data_G<={1'b0,r_up_raw[7:1]}+{1'b0,r_le_raw[7:1]};
                    out_data_B<=r_ul_raw;
                end
            end
            2:begin
                if (r_Xaddr<=12'd1 | r_Yaddr<=12'd1) begin
                    out_data_R<=8'h01;
                    out_data_G<=8'h01; 
                    out_data_B<=8'h01;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b00) begin
                    out_data_R<=r_le_raw;
                    out_data_G<={1'b0,r_in_raw[7:1]}+{1'b0,r_ul_raw[7:1]};
                    out_data_B<=r_up_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b10) begin
                    out_data_R<=r_in_raw;
                    out_data_G<={1'b0,r_le_raw[7:1]}+{1'b0,r_up_raw[7:1]};
                    out_data_B<=r_ul_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b01) begin
                    out_data_R<=r_ul_raw;
                    out_data_G<={1'b0,r_le_raw[7:1]}+{1'b0,r_up_raw[7:1]};
                    out_data_B<=r_in_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b11) begin
                    out_data_R<=r_up_raw;
                    out_data_G<={1'b0,r_in_raw[7:1]}+{1'b0,r_ul_raw[7:1]};
                    out_data_B<=r_le_raw;
                end
            end
            3:begin
                if (r_Xaddr<=12'd1 | r_Yaddr<=12'd1) begin
                    out_data_R<=8'h01;
                    out_data_G<=8'h01; 
                    out_data_B<=8'h01;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b00) begin
                    out_data_R<=r_up_raw;
                    out_data_G<={1'b0,r_in_raw[7:1]}+{1'b0,r_ul_raw[7:1]};
                    out_data_B<=r_le_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b10) begin
                    out_data_R<=r_ul_raw;
                    out_data_G<={1'b0,r_le_raw[7:1]}+{1'b0,r_up_raw[7:1]};
                    out_data_B<=r_le_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b01) begin
                    out_data_R<=r_le_raw;
                    out_data_G<={1'b0,r_le_raw[7:1]}+{1'b0,r_up_raw[7:1]};
                    out_data_B<=r_ul_raw;
                end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b11) begin
                    out_data_R<=r_le_raw;
                    out_data_G<={1'b0,r_in_raw[7:1]}+{1'b0,r_ul_raw[7:1]};
                    out_data_B<=r_up_raw;
                end
            end
             
        endcase
    end
end


    
endmodule