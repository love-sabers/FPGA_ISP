 /*                                                                      
 Copyright 2018 Nuclei System Technology, Inc.                
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */                                                                      
                                                                         
                                                                         
                                                                         
//=====================================================================
//
// Designer   : Bob Hu
//
// Description:
//  The DTCM-SRAM module to implement DTCM SRAM
//
// ====================================================================
`include "e203_defines.v"

  `ifdef E203_HAS_DTCM //{


module e203_dtcm_ram(

    input                              sd,
    input                              ds,
    input                              ls,

    input                              cs,  
    input                              we,  
    input  [`E203_DTCM_RAM_AW-1:0]     addr, 
    input  [`E203_DTCM_RAM_MW-1:0]     wem,
    input  [`E203_DTCM_RAM_DW-1:0]     din,          
    output [`E203_DTCM_RAM_DW-1:0]     dout,
    input                              rst_n,
    input                              clk
);

    sirv_gnrl_ram_dtcm #(
        .DP(`E203_DTCM_RAM_DP),
        .DW(`E203_DTCM_RAM_DW),
        .MW(`E203_DTCM_RAM_MW),
        .AW(`E203_DTCM_RAM_AW) 
    ) u_e203_dtcm_gnrl_ram(
        .sd  (sd  ),
        .ds  (ds  ),
        .ls  (ls  ),

        .rst_n (rst_n ),
        .clk (clk ),
        .cs  (cs  ),
        .we  (we  ),
        .addr(addr),
        .din (din ),
        .wem (wem ),
        .dout(dout)
    );
                                                      
endmodule
  `endif//}


module sirv_gnrl_ram_dtcm
#(
    parameter DP = 32,
    parameter DW = 32,
    parameter MW = 4,
    parameter AW = 15 
) (
    input            sd,
    input            ds,
    input            ls,

    input            rst_n,
    input            clk,
    input            cs,
    input            we,
    input [AW-1:0]   addr,
    input [DW-1:0]   din,
    input [MW-1:0]   wem,
    output[DW-1:0]   dout
);


sirv_sim_ram_dtcm #(
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW) 
)u_sirv_sim_ram_dtcm (
    .clk   (clk),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);

endmodule


module sirv_sim_ram_dtcm 
#(
    parameter DP = 512,
    parameter DW = 32,
    parameter MW = 4,
    parameter AW = 32 
)
(
    input             clk, 
    input  [DW-1  :0] din, 
    input  [AW-1  :0] addr,
    input             cs,
    input             we,
    input  [MW-1:0]   wem,
    output [DW-1:0]   dout
);

    reg [7:0] mem_r_A [0:DP-1] /*synthesis syn_ramstyle = "block_ram"*/;
    reg [7:0] mem_r_B [0:DP-1] /*synthesis syn_ramstyle = "block_ram"*/;
    reg [7:0] mem_r_C [0:DP-1] /*synthesis syn_ramstyle = "block_ram"*/;
    reg [7:0] mem_r_D [0:DP-1] /*synthesis syn_ramstyle = "block_ram"*/;

    wire [MW-1:0] wen;
    wire ren;

    assign ren = cs;
    assign wen = ({MW{cs & we}} & wem);

    wire	[DW-1:0]	doo;
   

    wire[7:0]	dinA	=din[7:0];
    wire[7:0]	dinB	=din[15:8];
    wire[7:0]	dinC	=din[23:16];
    wire[7:0]	dinD	=din[31:24];
    
    reg [7:0] 	doA;
    reg [7:0] 	doB;
    reg [7:0] 	doC;
    reg [7:0] 	doD;
   
    assign doo[7:0]		=	doA;
    assign doo[15:8]	=	doB;
    assign doo[23:16]	=	doC;
    assign doo[31:24]	=	doD;
    assign dout = doo;

    always@(posedge clk)
        //if(cs)
    		doA <= mem_r_A[addr];
    always @(posedge clk)
    	if (wen[0]) 
    		mem_r_A[addr] <= dinA;


    always@(posedge clk)
    	//if(cs)
    		doB <= mem_r_B[addr];
    always @(posedge clk)
    	if (wen[1]) 
    		mem_r_B[addr] <= dinB;


    always@(posedge clk)
    	//if(cs)
    		doC <= mem_r_C[addr];
    always @(posedge clk)
    	if (wen[2]) 
    		mem_r_C[addr] <= dinC;

    always@(posedge clk)
    	//if(cs)
    		doD <= mem_r_D[addr];
    always @(posedge clk)
    	if (wen[3]) 
    		mem_r_D[addr] <= dinD;

endmodule 







