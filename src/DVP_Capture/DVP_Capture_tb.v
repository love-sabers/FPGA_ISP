/////////////////////////////////////////////////////////////////////////////////
// Company       : 武汉芯路恒科技有限公司
//                 http://xiaomeige.taobao.com
// Web           : http://www.corecourse.cn
// 
// Create Date   : 2019/05/01 00:00:00
// Module Name   : DVP_Capture_tb
// Description   : DVP_Capture 模块仿真文件
// 
// Dependencies  : 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module DVP_Capture_tb;

  reg        Rst_n;
  reg        PCLK;
  reg        Vsync;
  reg        Href;
  reg  [7:0] Data;

  wire       ImageState;
  wire       DataValid;
  wire [15:0]DataPixel;
  wire       DataHs;
  wire       DataVs;
  wire [11:0]Xaddr;
  wire [11:0]Yaddr;

  DVP_Capture DVP_Capture(
    .Rst_n      (Rst_n      ),//input
    .PCLK       (PCLK       ),//input
    .Vsync      (Vsync      ),//input
    .Href       (Href       ),//input
    .Data       (Data       ),//input     [7:0]

    .ImageState (ImageState ),//output reg
    .DataValid  (DataValid  ),//output
    .DataPixel  (DataPixel  ),//output    [15:0]
    .DataHs     (DataHs     ),//output
    .DataVs     (DataVs     ),//output
    .Xaddr      (Xaddr      ),//output    [11:0]
    .Yaddr      (Yaddr      ) //output    [11:0]
  );

  initial PCLK = 1;
  always#40 PCLK = ~PCLK;

  parameter WIDTH = 16;
  parameter HIGHT = 12;
  
  integer i,j;
  
  initial begin
    Rst_n = 0;
    Vsync = 0;
    Href  = 0;
    Data  = 8'hff;
    #805;
    Rst_n = 1;
    #400;

    repeat(15)begin
      Vsync = 1;
      #320;
      Vsync = 0;
      #800;
      for(i=0;i<HIGHT;i=i+1)
      begin
        for(j=0;j<WIDTH;j=j+1)
        begin
          Href = 1;
          Data = Data - 1;
          #80;
        end
        Href = 0;
        #800;
      end
    end
    $stop;
  end

endmodule
