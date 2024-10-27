module cfa_top #(
    parameter source_h  = 512,
	parameter source_v  = 512
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
	output reg[7:0] out_R, 	
    output reg[7:0] out_G,
    output reg[7:0] out_B
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
reg [9:0] r_index;
reg [9:0] r_Xaddr;
reg [9:0] r_Yaddr;

always @(posedge clk or negedge reset_n) begin
    if(!reset_n)begin
        r_Xaddr<=10'd0;
        r_index<=10'd0;
    end else if (in_hsync) begin
        r_Xaddr<=r_Xaddr+10'd1;
        r_index<=r_index+10'd1;
    end else begin
        r_Xaddr<=10'd0;
        r_index<=10'd0;
    end
end

always @(posedge clk or negedge reset_n) begin
    if(!reset_n)begin
        r_Yaddr<=10'd0;
    end else if (~in_vsync) begin
        r_Yaddr<=10'd0;
    end else if ({r_hsync,in_hsync}==2'b01) begin
        r_Yaddr<=r_Yaddr+10'd1;
    end else begin
        r_Yaddr<=r_Yaddr;
    end
end

//计算行延迟
reg [9:0] delay_count;
reg [9:0] delay_value;
reg delay_over_vs;

// always @(posedge clk or negedge reset_n) begin
//     if(!reset_n)begin
//         delay_count<=10'd0;
//         delay_value<=10'd0;
//         delay_over_vs<=1'b0;
//     end else begin
//         delay_value<=in_delay;
//     end
//     // end else if(!in_vsync) begin
//     //     delay_over_vs<=1'b1;
//     // end else if ({r_hsync,in_hsync}==2'b01) begin
//     //     if (~delay_over_vs & delay_count>delay_value) begin
//     //         delay_value<=delay_count;
//     //     end
//     //     delay_over_vs<=1'b0;
//     //     delay_count<=10'd0;
//     // end else begin
//     //     delay_count<=delay_count+10'd1;
//     // end
// end

// assign delay_value=10'd512;

wire[7:0]  r_up_raw;//up 
reg [7:0]  r_ul_raw;//up left
reg [7:0]  r_le_raw;//left

reg [7:0]  ram[source_h:0];
assign r_up_raw=ram[r_index];
// assign r_up_raw=r_in_raw;

always @(posedge clk ) begin
    ram[r_index]<=r_in_raw;
end

// //RAW reg
// RAM_reg_top RAM_reg(
//     .clk(clk), //input clk
//     .Reset(reset_n), //input Reset
//     .Din(r_in_raw), //input [7:0] Din
//     .ADDR(in_delay), //input [9:0] ADDR
//     .Q(r_up_raw) //output [7:0] Q
// );

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
        out_R<=8'd0;
        out_G<=8'd0;
        out_B<=8'd0;
    end else begin
        out_vsync<=r_vsync;
        out_hsync<=r_hsync;
        out_den<=r_den;
        
        if (r_Xaddr<=10'd1 | r_Yaddr<=10'd1) begin
            out_R<=8'hff;
            out_G<=8'h00; 
            out_B<=8'h00;
        // end else begin
        //     out_R<=r_up_raw;
        //     out_G<=r_up_raw; 
        //     out_B<=r_up_raw;
        // end

        end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b00) begin
            out_R<=r_ul_raw;
            out_G<={1'b0,r_up_raw[7:1]}+{1'b0,r_le_raw[7:1]};
            out_B<=r_in_raw;
        end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b10) begin
            out_R<=r_up_raw;
            out_G<={1'b0,r_in_raw[7:1]}+{1'b0,r_ul_raw[7:1]};
            out_B<=r_le_raw;
        end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b01) begin
            out_R<=r_le_raw;
            out_G<={1'b0,r_in_raw[7:1]}+{1'b0,r_ul_raw[7:1]};
            out_B<=r_up_raw;
        end else if ({r_Xaddr[0],r_Yaddr[0]}==2'b11) begin
            out_R<=r_in_raw;
            out_G<={1'b0,r_up_raw[7:1]}+{1'b0,r_le_raw[7:1]};
            out_B<=r_ul_raw;
        end

    end
end


    
endmodule