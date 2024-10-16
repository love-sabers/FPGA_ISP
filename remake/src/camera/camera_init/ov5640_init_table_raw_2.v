/////////////////////////////////////////////////////////////////////////////////
// 
// Create Date   : 2019/05/01 00:00:00
// Module Name   : ov5640_init_table_raw
// Description   : OV5640初始化寄存器表(RAW模式专用)
// 
// Dependencies  : 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/////////////////////////////////////////////////////////////////////////////////

module ov5640_init_table_raw #(
  parameter DATA_WIDTH      = 24,
  parameter ADDR_WIDTH      = 8,
  parameter IMAGE_WIDTH     = 16'd640,
  parameter IMAGE_HEIGHT    = 16'd480,
  parameter IMAGE_FLIP_EN   = 1'b0,
  parameter IMAGE_MIRROR_EN = 1'b0
)
(
  clk,
  addr,
  q
);
  input clk;
  input [(ADDR_WIDTH-1):0] addr;
  output reg [(DATA_WIDTH-1):0] q;

  localparam IMAGE_FLIP_DAT   = IMAGE_FLIP_EN ? 8'h47 : 8'h40;
  localparam IMAGE_MIRROR_DAT = IMAGE_MIRROR_EN ? 4'h0 : 4'h7;

  // Declare the ROM variable
  reg [23:0] rom[251:0];


  

  always@(*) begin
    rom[ 0]="24'h3008_82";
    rom[ 1]="24'h3103_03";
    rom[ 2]="24'h3017_ff";
    rom[ 3]="24'h3018_ff";
    rom[ 4]="24'h3108_01";
    rom[ 5]="24'h3037_13";
    rom[ 6]="24'h3630_2e";
    rom[ 7]="24'h3632_e2";
    rom[ 8]="24'h3633_23";
    rom[ 9]="24'h3634_44";
    rom[10]="24'h3621_e0";
    rom[11]="24'h3704_a0";
    rom[12]="24'h3703_5a";
    rom[13]="24'h3715_78";
    rom[14]="24'h3717_01";
    rom[15]="24'h370b_60";
    rom[16]="24'h3705_1a";
    rom[17]="24'h3905_02";
    rom[18]="24'h3906_10";
    rom[19]="24'h3901_0a";
    rom[20]="24'h3731_12";
    rom[21]="24'h3600_08";
    rom[22]="24'h3601_33";
    rom[23]="24'h471c_50";
    rom[24]="24'h3820_40";
    rom[25]="24'h3821_00";
    rom[26]="24'h3814_11";
    rom[27]="24'h3815_11";
    rom[28]="24'h3800_00";
    rom[29]="24'h3801_00";
    rom[30]="24'h3802_00";
    rom[31]="24'h3803_00";
    rom[32]="24'h3804_0a";
    rom[33]="24'h3805_3f";
    rom[34]="24'h3806_07";
    rom[35]="24'h3807_9f";
    rom[36]="24'h3808_0a";
    rom[37]="24'h3809_20";
    rom[38]="24'h380a_07";
    rom[39]="24'h380b_98";
    rom[40]="24'h380c_0b";
    rom[41]="24'h380d_1c";
    rom[42]="24'h380e_07";
    rom[43]="24'h380f_b0";
    rom[44]="24'h3810_00";
    rom[45]="24'h3811_10";
    rom[46]="24'h3812_00";
    rom[47]="24'h3813_04";
    rom[48]="24'h3618_04";
    rom[49]="24'h3612_4b";
    rom[50]="24'h3708_64";
    rom[51]="24'h3709_12";
    rom[52]="24'h370c_00";
    rom[53]="24'h3a02_07";
    rom[54]="24'h3a03_b0";
    rom[55]="24'h3a08_01";
    rom[56]="24'h3a09_27";
    rom[57]="24'h3a0a_00";
    rom[58]="24'h3a0b_f6";
    rom[59]="24'h3a0e_06";
    rom[60]="24'h3a0d_08";
    rom[61]="24'h3a14_07";
    rom[62]="24'h3a15_b0";
    rom[63]="24'h4001_02";
    rom[64]="24'h4004_06";
    rom[65]="24'h3000_00";
    rom[66]="24'h3002_1c";
    rom[67]="24'h3004_ff";
    rom[68]="24'h3006_c3";
    rom[69]="24'h4300_03";//format control raw
    rom[70]="24'h5001_00";
    rom[71]="24'h501f_03";
    rom[72]="24'h5000_06";
    rom[73]="24'h3a0f_36";
    rom[74]="24'h3a10_2e";
    rom[75]="24'h3a1b_38";
    rom[76]="24'h3a1e_2c";
    rom[77]="24'h3a11_70";
    rom[78]="24'h3a1f_18";
    rom[79]="24'h3a18_00";
    rom[80]="24'h3a19_f8";
    rom[81]="24'h3035_41";

  end

  always @ (posedge clk)
  begin
    q <= rom[addr];
  end

endmodule
