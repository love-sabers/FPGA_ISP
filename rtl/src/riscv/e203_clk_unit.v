

/****************************************************************
========Oooo=========================================Oooo========
=     Copyright ©2015-2018 Gowin Semiconductor Corporation.     =
=                     All rights reserved.                      =
========Oooo=========================================Oooo========

<File Title>: IP file
<gwModGen version>: 1.8.0Beta
<Series, Device, Package, Speed>: GW2A, GW2A-55, PBGA484
<Created Time>: Thu Jun 14 18:00:03 2018
****************************************************************/

module clk_unit (clkout_rtc, reset, clkin, clkout_system, lock);

output reg clkout_rtc;
input reset;
input clkin;
output clkout_system;
output lock;
// wire lock_sys;
// wire lock_rtc;
wire rtc_rst;
wire sys_rst;

wire clkout_9M;


reg [7:0] lock_rtc_dly =8'h00;

always@(posedge clkout_rtc)
	lock_rtc_dly <= {lock_rtc_dly[6:0],lock};

assign	rtc_rst = !reset;
assign	sys_rst = !lock_rtc_dly[7];
// assign lock = lock_rtc & lock_sys;

rv_PLL rv_PLL_inst(
        .lock(lock), //output lock
        .clkout0(clkout_system), //output clkout0
        .clkout1(clkout_9M), //output clkout1
        .clkin(clkin), //input clkin
        .reset(~reset) //input reset
    );

reg [7:0] counter;      // 8位计数器

always @(posedge clkout_9M or negedge reset) begin
    if (~reset) begin
        counter <= 8'b0;   // 复位计数器
        clkout_rtc <= 1'b0;   // 复位输出时钟
    end else begin
        if (counter == 8'd127) begin
            counter <= 8'b0;      // 计数器清零
            clkout_rtc <= ~clkout_rtc;  // 翻转输出时钟
        end else begin
            counter <= counter + 1'b1;  // 计数器加1
        end
    end
end


endmodule //GW_PLL