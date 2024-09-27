/*============================================================================
*
*  LOGIC CORE:          显示设备驱动模块		
*  MODULE NAME:         disp_driver()
*  COMPANY:             武汉芯路恒科技有限公司
*                       http://xiaomeige.taobao.com
*  author:              小梅哥
*  Website:             www.corecourse.cn
*  REVISION HISTORY:  
*
*  Revision 1.0  04/10/2019
*  Description: Initial Release.
*
*  FUNCTIONAL DESCRIPTION:
===========================================================================*/
`include "disp_parameter_cfg.v"

module disp_driver(
	ClkDisp,
	Rst_n,
	
	Data,
	DataReq,
	
	H_Addr,
	V_Addr,
	
	Disp_HS,
	Disp_VS,
	Disp_Red,
	Disp_Green,
	Disp_Blue,
    Frame_Begin,
	Disp_DE,
	Disp_PCLK
);

	input ClkDisp;
	input Rst_n;
	input [`Red_Bits + `Green_Bits + `Blue_Bits - 1:0] Data;
	output DataReq;
	
	output [11:0] H_Addr;
	output [11:0] V_Addr;
	
	output reg Disp_HS;
	output reg Disp_VS;

	output reg [`Red_Bits - 1 :0]Disp_Red;
	output reg [`Green_Bits - 1 :0]Disp_Green;
	output reg [`Blue_Bits - 1 :0]Disp_Blue;
	
    output reg Frame_Begin; //一帧图像起始标识信号，ClkDisp时钟域
	output reg Disp_DE;
	output Disp_PCLK;
	
	wire hcount_ov;
	wire vcount_ov;
	
	//----------------内部寄存器定义----------------
	reg [11:0] hcount_r;     //行扫描计数器
	reg [11:0] vcount_r;     //场扫描计数器

	`ifdef HW_VGA
		assign Disp_PCLK = ~ClkDisp;
	`else
		assign Disp_PCLK = ClkDisp;
	`endif	

	assign DataReq = Disp_DE;
	
	parameter hdat_begin = `H_Sync_Time + `H_Back_Porch + `H_Left_Border - 1'b1;
	parameter hdat_end = `H_Total_Time - `H_Right_Border - `H_Front_Porch - 1'b1;
	
	parameter vdat_begin	= `V_Sync_Time + `V_Back_Porch + `V_Top_Border - 1'b1;
	parameter vdat_end = `V_Total_Time - `V_Bottom_Border - `V_Front_Porch - 1'b1;	
	
	assign H_Addr = Disp_DE?(hcount_r - hdat_begin):12'd0;
	assign V_Addr = Disp_DE?(vcount_r - vdat_begin):12'd0;

	//行扫描
	assign hcount_ov = (hcount_r >= `H_Total_Time - 1);
	
	always@(posedge ClkDisp or negedge Rst_n)
	if(!Rst_n)
		hcount_r <= 0;
	else if(hcount_ov)
		hcount_r <= 0;
	else
		hcount_r <= hcount_r + 1'b1;

	//场扫描
	assign vcount_ov = (vcount_r >= `V_Total_Time - 1);

	always@(posedge ClkDisp or negedge Rst_n)
	if(!Rst_n)
		vcount_r <= 0;
	else if(hcount_ov) begin
		if(vcount_ov)
			vcount_r <= 0;
		else
			vcount_r <= vcount_r + 1'd1;
	end
	else 
		vcount_r <= vcount_r;
	
	always@(posedge ClkDisp)
		Disp_DE <= ((hcount_r >= hdat_begin)&&(hcount_r < hdat_end))
					&&((vcount_r >= vdat_begin)&&(vcount_r < vdat_end));
	
	always@(posedge ClkDisp)	begin			
		Disp_HS <= (hcount_r > `H_Sync_Time - 1);
		Disp_VS <= (vcount_r > `V_Sync_Time - 1);
		{Disp_Red,Disp_Green,Disp_Blue} <= (Disp_DE)?Data:1'd0;
	end
	
  /*******************************************/
  reg Disp_VS_dly1;
  always@(posedge ClkDisp)
  begin
    Disp_VS_dly1 <= Disp_VS;
  end

  always@(posedge ClkDisp or negedge Rst_n)
  begin
    if(!Rst_n)
      Frame_Begin <= 1'b0;
    else if(!Disp_VS_dly1 && Disp_VS)
      Frame_Begin <= 1'b1;
    else
      Frame_Begin <= 1'b0;
  end
  /*******************************************/

endmodule
