/*============================================================================
*
*  LOGIC CORE:          显示设备驱动硬件配置头文件	
*  MODULE NAME:         disp_parameter_cfg()
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
//`include "sys_cfg.v"

//建议直接修改sys_cfg文件中的各种参数配置，而不是直接修改本文件中的各种参数。

/*
使用时根据实际工作需求选择几个预定义参数就可以

MODE_RGB888和MODE_RGB565两个参数二选一，用来决定驱动工作在16位模式还是24位模式
针对小梅哥提供的一系列显示设备，各个设备参数如下所述
	4.3寸屏：16位色RGB565模式
	5寸屏：16位色RGB565模式
	GM7123模块使用24位色RGB888模式，

Resolution_xxxx预定义用来决定显示设备分辨率，常见设备分辨率如下所述

4.3寸TFT显示屏：Resolution_480x272
5寸TFT显示屏：Resolution_800x480

VGA常见分辨率：
	Resolution_640x480
	Resolution_800x600
	Resolution_1024x768
	Resolution_1280x720
	Resolution_1920x1080
*/


`define HW_VGA

//以下两行预定义根据实际使用的模式，选择一个使能，另外一个使用注释的方式屏蔽
`define MODE_RGB888
//`define MODE_RGB565

//以下7行预定义根据实际使用的分辨率，选择一个使能，另外6个使用注释的方式屏蔽

`ifdef HW_TFT43	//使用4.3寸480*272分辨率显示屏
	`define Resolution_480x272 1	//时钟为9MHz
	
`elsif HW_TFT50	//使用5寸800*480分辨率显示屏
	`define Resolution_800x480 1	//时钟为33MHz
	
`elsif HW_VGA		//使用VGA显示器，默认为640*480分辨率，也可选择其他分辨率，不过摄像头捕获存储部分当前没做其他分辨率适配
	//`define Resolution_640x480 1	//时钟为25.175MHz
	//`define Resolution_800x480 1	//时钟为33MHz
	//`define Resolution_800x600 1	//时钟为40MHz
	//`define Resolution_1024x600 1 //时钟为51MHz
	//`define Resolution_1024x768 1	//时钟为65MHz
	`define Resolution_1280x720 1	//时钟为74.25MHz
	//`define Resolution_1920x1080 1	//时钟为148.5MHz
`endif

//定义不同的颜色深度
`ifdef MODE_RGB888
	`define Red_Bits 8
	`define Green_Bits 8
	`define Blue_Bits 8
	
`elsif MODE_RGB565
	`define Red_Bits 5
	`define Green_Bits 6
	`define Blue_Bits 5
`endif

//定义不同分辨率的时序参数
`ifdef Resolution_480x272
	`define H_Total_Time  12'd525
	`define H_Right_Border  12'd0
	`define H_Front_Porch  12'd2
	`define H_Sync_Time  12'd41
	`define H_Back_Porch  12'd2
	`define H_Left_Border  12'd0

	`define V_Total_Time  12'd286
	`define V_Bottom_Border  12'd0
	`define V_Front_Porch  12'd2
	`define V_Sync_Time  12'd10
	`define V_Back_Porch  12'd2
	`define V_Top_Border  12'd0
	
`elsif Resolution_640x480
	`define H_Total_Time  12'd800
	`define H_Right_Border  12'd8
	`define H_Front_Porch  12'd8
	`define H_Sync_Time  12'd96
	`define H_Back_Porch  12'd40
	`define H_Left_Border  12'd8

	`define V_Total_Time  12'd525
	`define V_Bottom_Border  12'd8
	`define V_Front_Porch  12'd2
	`define V_Sync_Time  12'd2
	`define V_Back_Porch  12'd25
	`define V_Top_Border  12'd8

`elsif Resolution_800x480
	`define H_Total_Time 12'd1056
	`define H_Right_Border 12'd0
	`define H_Front_Porch 12'd40
	`define H_Sync_Time 12'd128
	`define H_Back_Porch 12'd88
	`define H_Left_Border 12'd0

	`define V_Total_Time 12'd525
	`define V_Bottom_Border 12'd8
	`define V_Front_Porch 12'd2
	`define V_Sync_Time 12'd2
	`define V_Back_Porch 12'd25
	`define V_Top_Border 12'd8

`elsif Resolution_800x600
	`define H_Total_Time 12'd1056
	`define H_Right_Border 12'd0
	`define H_Front_Porch 12'd40
	`define H_Sync_Time 12'd128
	`define H_Back_Porch 12'd88
	`define H_Left_Border 12'd0

	`define V_Total_Time 12'd628
	`define V_Bottom_Border 12'd0
	`define V_Front_Porch 12'd1
	`define V_Sync_Time 12'd4
	`define V_Back_Porch 12'd23
	`define V_Top_Border 12'd0

`elsif Resolution_1024x600
	`define H_Total_Time 12'd1344
	`define H_Right_Border 12'd0
	`define H_Front_Porch 12'd24
	`define H_Sync_Time 12'd136
	`define H_Back_Porch 12'd160
	`define H_Left_Border 12'd0

	`define V_Total_Time 12'd628
	`define V_Bottom_Border 12'd0
	`define V_Front_Porch 12'd1
	`define V_Sync_Time 12'd4
	`define V_Back_Porch 12'd23
	`define V_Top_Border 12'd0

`elsif Resolution_1024x768
	`define H_Total_Time 12'd1344
	`define H_Right_Border 12'd0
	`define H_Front_Porch 12'd24
	`define H_Sync_Time 12'd136
	`define H_Back_Porch 12'd160
	`define H_Left_Border 12'd0

	`define V_Total_Time 12'd806
	`define V_Bottom_Border 12'd0
	`define V_Front_Porch 12'd3
	`define V_Sync_Time 12'd6
	`define V_Back_Porch 12'd29
	`define V_Top_Border 12'd0

`elsif Resolution_1280x720
	`define H_Total_Time 12'd1650
	`define H_Right_Border 12'd0
	`define H_Front_Porch 12'd110
	`define H_Sync_Time 12'd40
	`define H_Back_Porch 12'd220
	`define H_Left_Border 12'd0

	`define V_Total_Time 12'd750
	`define V_Bottom_Border 12'd0
	`define V_Front_Porch 12'd5
	`define V_Sync_Time 12'd5
	`define V_Back_Porch 12'd20
	`define V_Top_Border 12'd0
	
`elsif Resolution_1920x1080
	`define H_Total_Time 12'd2200
	`define H_Right_Border 12'd0
	`define H_Front_Porch 12'd88
	`define H_Sync_Time 12'd44
	`define H_Back_Porch 12'd148
	`define H_Left_Border 12'd0

	`define V_Total_Time 12'd1125
	`define V_Bottom_Border 12'd0
	`define V_Front_Porch 12'd4
	`define V_Sync_Time 12'd5
	`define V_Back_Porch 12'd36
	`define V_Top_Border 12'd0	
	
`endif

	

