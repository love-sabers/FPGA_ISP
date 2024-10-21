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
  parameter IMAGE_WIDTH     = 12'd640,
  parameter IMAGE_HEIGHT    = 12'd480,
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


  

  initial begin
    rom[ 0]=   24'h3008_82;//0x3008[7] high 重置摄像头
    rom[ 1]=   24'h3103_03;//看不懂
    
    rom[ 2]=   24'h3017_ff;
    // 3017
    // Bit[7]:FREX output enable
    // Bit[6]:VSYNC output enable
    // Bit[5]:HREF output enable
    // Bit[4]:PCLK output enable
    // Bit[3:0]:   D[9:6] output enable


    rom[ 3]=   24'h3018_ff;
    // 3018
    // Bit[7:2]:   D[5:0] output enable
    // Bit[1]:GPIO1 output enable
    // Bit[0]:GPIO0 output enable

    rom[ 4]=   24'h3108_01;
    // 3108  SYSTEM ROOT DIVIDER
    // Bit[7:6]:   Debug mode
    // Bit[5:4]:   PCLK root divider
    //   00:    PCLK = pll_clki
    //   01:    PCLK = pll_clki/2
    //   10:    PCLK = pll_clki/4
    //   11:PCLK = pll_clki/8
    // Bit[3:2]:   sclk2x root divider
    //   00:    SCLK2x = pll_clki
    //   01:    SCLK2x = pll_clki/2
    //   10:    SCLK2x = pll_clki/4
    //   11:    SCLK2x = pll_clki/8
    // Bit[1:0]:   SCLK root divider
    //   00:    SCLK = pll_clki   
    //   01:    SCLK = pll_clki/2
    //   10:    SCLK = pll_clki/4 
    //   11:    SCLK = pll_clki/8

    rom[ 5]=   24'h3037_13;
    // 3037   SC PLL CONTRL3
    // Bit[7:5]:    Debug mode
    // Bit[4]:      PLL root divider
    //   0:Bypass
    //   1:Divided by 2
    // Bit[3:0]:   PLL pre-divider1,2,3,4,6,8

    rom[ 6]=   24'h3630_2e;
    rom[ 7]=   24'h3632_e2;
    rom[ 8]=   24'h3633_23;
    rom[ 9]=   24'h3634_44;
    rom[10]=   24'h3621_e0;
    rom[11]=   24'h3704_a0;
    rom[12]=   24'h3703_5a;
    rom[13]=   24'h3715_78;
    rom[14]=   24'h3717_01;
    rom[15]=   24'h370b_60;
    rom[16]=   24'h3705_1a;
    rom[17]=   24'h3905_02;
    rom[18]=   24'h3906_10;
    rom[19]=   24'h3901_0a;
    rom[20]=   24'h3731_12;
    rom[21]=   24'h3600_08;
    rom[22]=   24'h3601_33;
    rom[23]=   24'h471c_50;


    rom[24]=   24'h3820_40;
    // Timing Control 
    // Bit[7:3]:   Debug mode
    // Bit[2]:ISP vflip
    // Bit[1]:Sensor vflip


    rom[25]=   24'h3821_00;
    // Timing Control
    // Bit[7:6]:   Debug mode
    // Bit[5]:JPEG enable
    // Bit[4:3]:   Debug mode
    // Bit[2]:ISP mirror
    // Bit[1]:Sensor mirror
    // Bit[0]:Horizontal binning enable

    rom[26]=   24'h3814_11;//Horizontal odd even subsample increment
    rom[27]=   24'h3815_11;//Vertical odd even subsample incremen

    //horizontal start
    rom[28]=   24'h3800_00;
    rom[29]=   24'h3801_00;

    //vertical start 
    rom[30]=   24'h3802_00;
    rom[31]=   24'h3803_00;

    //cam capture width 
    rom[32]=   24'h3804_0a;
    rom[33]=   24'h3805_3f;

    //cam capture height
    rom[34]=   24'h3806_07;
    rom[35]=   24'h3807_9f;


    //width
    rom[36]=   {16'h3808,4'h0,IMAGE_WIDTH[11:8]};//DVP output horizontal width[11:8] high byte
      // Bit[7:4]:   Debug mode
    rom[37]=   {16'h3809, IMAGE_WIDTH[7:0]};//DVP output horizontal width[7:0] low byte

    //height
    rom[38]=   {16'h380a,4'h0,IMAGE_HEIGHT[11:8]};//DVP output vertical height[11:8] high byte
      // Bit[7:4]:   Debug mode
    rom[39]=   {16'h380b, IMAGE_HEIGHT[7:0]};//DVP output vertical height[7:0] low byte

    //Total horizontal size
    rom[40]=   24'h380c_0b;
    rom[41]=   24'h380d_1c;
    //Total vertical size
    rom[42]=   24'h380e_07;
    rom[43]=   24'h380f_b0;


    //ISP horizontal offset
    rom[44]=   24'h3810_00;
    rom[45]=   24'h3811_10;
    //ISP vertical offset
    rom[46]=   24'h3812_00;
    rom[47]=   24'h3813_04;

    //看不懂
    rom[48]=   24'h3618_04;
    rom[49]=   24'h3612_4b;
    rom[50]=   24'h3708_64;
    rom[51]=   24'h3709_12;
    rom[52]=   24'h370c_00;


    //AEC 
    //60Hz Maximum Exposure Output Limit
    rom[53]=   24'h3a02_07;
    rom[54]=   24'h3a03_b0;

    //50Hz Band Width 
    rom[55]=   24'h3a08_01;
    rom[56]=   24'h3a09_27;
    //60Hz Band Width 
    rom[57]=   24'h3a0a_00;
    rom[58]=   24'h3a0b_f6;

    rom[59]=   24'h3a0d_08;//60Hz Max Bands in One Frame
    rom[60]=   24'h3a0e_06;//50Hz Max Bands in One Frame

    //50Hz Maximum Exposure Output Limit
    rom[61]=   24'h3a14_07;
    rom[62]=   24'h3a15_b0;
    //AEC end

    //BLC 
    rom[63]=   24'h4001_02;//BLC start line
    rom[64]=   24'h4004_06;//BLC line number
    //BLC end
    
    rom[65]=   24'h3000_00;//Reset for Individual Block
    rom[66]=   24'h3002_1c;//Reset for Individual Block
    rom[67]=   24'h3004_ff;//Clock Enable Control
    rom[68]=   24'h3006_c3;//Clock Enable Control


    rom[69]=   24'h4300_03;//format control raw

    //ISP top
    rom[70]=   24'h5001_00;
    // Bit[7]:Special digital effect enable
    //   0:Disable
    //   1:Enable
    // Bit[6]:Debug mode
    // Bit[5]:Scale enable
    //   0:Disable
    //   1:Enable
    // Bit[4:3]:   Debug mode
    // Bit[2]:UV average enable
    //   0:Disable
    //   1:Enable
    // Bit[1]:Color matrix enable 
    //   0:Disable
    //   1:Enable
    // Bit[0]:Auto white balance enable
    //   0:Disable
    //   1:Enable

    rom[71]=   24'h501f_03;
    // Format MUX Control
    // Bit[7:4]:   Debug mode
    // Bit[3]:Fmt vfirst
    // Bit[2:0]:   Format select
    //   000:    ISP YUV422
    //   001:    ISP RGB
    //   010:    ISP dither
    //   011:    ISP RAW (DPC)        selected
    //   100:    SNR RAW
    //   101:    ISP RAW (CIP)

    rom[72]=   24'h5000_06;
    // Bit[7]:LENC correction enable
    //   0:Disable
    //   1:Enable 
    // Bit[6]:Debug mode
    // Bit[5]:RAW GMA enable
    //   0:Disable
    //   1:Enable
    // Bit[4:3]:   Debug mode
    // Bit[2]:Black pixel cancellation enable         selected
    //   0:Disable
    //   1:Enable 
    // Bit[1]:White pixel cancellation enable         selected
    //   0:Disable
    //   1:Enable
    // Bit[0]:Color interpolation enable
    //   0:Disable
    //   1:Enable


    //AEC
    //AEC control
    rom[73]=   24'h3a0f_36;
    rom[74]=   24'h3a10_2e;
    rom[75]=   24'h3a1b_38;
    rom[76]=   24'h3a1e_2c;
    rom[77]=   24'h3a11_70;
    rom[78]=   24'h3a1f_18;

    //AEC GAIN Output Top Limit
    rom[79]=   24'h3a18_00;
    rom[80]=   24'h3a19_f8;
    //AEC end

    //fps
    //rom[ 4]=   24'h3108_01;
    // rom[81]=   24'h3034_1A;
    // rom[82]=   24'h3035_21;
    // rom[83]=   24'h3036_fc;
    // rom[84]=   24'h3037_03;
    // rom[85]=   24'h3824_02;

    rom[81]=   24'h3034_18;
    rom[82]=   24'h3035_22;
    rom[83]=   24'h3036_63;
    rom[84]=   24'h3037_02;
    rom[85]=   24'h3824_02;

    // OV5640要求输入的时钟频率为6-27MHz,一般情况下输入24MHz，在本次计算中也以24MHz为输入频率；
    // 输入时钟首先经过pre-divider进行分频，分频系数由3037[3:0]确定，在本次计算中3037[3:0]为2，故经过分频之后的输出为24/2=12MHz；
    // 经过pre-divider分频后需要给分频后的时钟做一次倍频，乘法因子为3036[6:0]=0xfc=252，经过倍频后的时钟频率为12MHz*99=1188MHz;
    // Sys divider0分频，分频系数为0x3035[7:4]，在demo中的值为2；1188MHz/2=594MHz;
    // PLL R divider分频，如果0x3037[4]为高电平，则进行2分频，否则不分频；在demo中3037[4]为0，故没有分频；594MHz/1=594MHz;
    // BIT divider分频，分频系数为0x3034[3:0]，如果是8，则是2分频，如果是A则是2.5分频，如果是其他则为1分频；594MHz/2=297MHz;
    // PCLK divider分频, 分频系数为0x3108[5:4],00:1分频；01:2分频；10:4分频；11:8分频；在demo中0x3108[5:4]=2’b00,故需要进行1分频；297MHz/1=297MHz；
    // P divider分频，如果是mipi2 lane,则分频系数是0x3035[3:0],如果是DVP 接口则分频系数为2*0x3035[3:0]；297MHz/4=74.25MHz；
    // (无用)Scale divider分频，分频系数为0x3824[4:0],在demo中0x3824[4:0]=2故需要进行2分频，148.5MHz/2=74.25MHz。

  end

  always @ (posedge clk)
  begin
    q <= rom[addr];
  end

endmodule
