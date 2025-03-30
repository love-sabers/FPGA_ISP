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
// Designer   : Bob Hu
//
// Description:
//  The ITCM-SRAM module to implement ITCM SRAM
//
// ====================================================================

`include "e203_defines.v"

  `ifdef E203_HAS_ITCM //{
module e203_itcm_ram(
    input                              sd,
    input                              ds,
    input                              ls,

    input                              cs,  
    input                              we,  
    input  [`E203_ITCM_RAM_AW-1:0]     addr, 
    input  [`E203_ITCM_RAM_MW-1:0]     wem,
    input  [`E203_ITCM_RAM_DW-1:0]     din,          
    output [`E203_ITCM_RAM_DW-1:0]     dout,
    input                              rst_n,
    input                              clk

);

 
    sirv_gnrl_ram_itcm #(
        .DP(`E203_ITCM_RAM_DP),
        .DW(`E203_ITCM_RAM_DW),
        .MW(`E203_ITCM_RAM_MW),
        .AW(`E203_ITCM_RAM_AW) 
    ) u_e203_itcm_gnrl_ram(
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


module sirv_gnrl_ram_itcm
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

sirv_sim_ram_itcm #(
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW) 
)u_sirv_sim_ram_itcm (
    .clk   (clk),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);

endmodule


module sirv_sim_ram_itcm 
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
    
    wire [7:0] din_0 = din [ 7: 0];
    wire [7:0] din_1 = din [15: 8];
    wire [7:0] din_2 = din [23:16];
    wire [7:0] din_3 = din [31:24];
    wire [7:0] din_4 = din [39:32];
    wire [7:0] din_5 = din [47:40];
    wire [7:0] din_6 = din [55:48];
    wire [7:0] din_7 = din [63:56];

    reg [63:0] mem_r [0:DP-1] /*synthesis syn_ramstyle = "block_ram"*/;
    
    reg [AW-1:0] addr_r;
    wire [MW-1:0] wen;
    wire ren;


    assign ren = cs & (~we);
    assign wen = ({MW{cs & we}} & wem);    

`ifdef E203_LOAD_PROGRAM
    initial begin
`ifdef USING_IVERILOG   //simulation
        $display("loading firmware from simulator\n");
        $readmemh("../firmware/hello_world/Debug/ram.hex", mem_r);
`else                   //implementation
        $display("loading firmware from sythesizer\n");
        $readmemh("ram.hex", mem_r);
`endif
    end
`endif

    genvar i;

    always @(posedge clk)
    begin
        if (ren) begin
            addr_r <= addr;
        end
    end


    //reg [63:0] mem_r [0:DP-1]
    generate
      for (i = 0; i < MW; i = i+1) begin :mem
        if((8*i+8) > DW ) begin: last
          always @(posedge clk) begin
            if (wen[i]) begin
               mem_r[addr][DW-1:8*i] <= din[DW-1:8*i];
            end
          end
        end
        else begin: non_last
          always @(posedge clk) begin
            if (wen[i]) begin
               mem_r[addr][8*i+7:8*i] <= din[8*i+7:8*i];
            end
          end
        end
      end
    endgenerate

    wire [DW-1:0] dout_pre;
    assign dout_pre = mem_r[addr_r];
    assign dout = dout_pre;

endmodule


