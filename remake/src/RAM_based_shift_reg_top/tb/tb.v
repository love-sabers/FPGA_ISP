
`timescale 1ns/1ps
module tb ;
    parameter DSIZE = 8 ; 
    parameter WDEPTH = 4 ; 
    parameter ASIZE = $clog2(WDEPTH) ; 
    reg [(DSIZE - 1):0] Din ; 
    wire [(DSIZE - 1):0] OUT ; 
    reg Reset = 0 ; 
    reg Clock = 0 ; 
    reg test_result = 0 ; 
    reg [(ASIZE - 1):0] Addr ; 
    GSR GSR (1'b1) ; 
    always
        #(5.0) Clock = (~Clock) ;
    initial
        begin
            Reset <=  1'b1 ;
            #(100) ;
            Reset <=  1'b0 ;
            #(3000) ;
            Reset <=  1'b1 ;
            #(100) ;
            Reset <=  1'b0 ;
            #(50000) ;
            $display ("******************finish******************") ;
            $stop  ;
        end
    initial
        begin
            Addr <=  'd4 ;
            #(1500) @(posedge Clock)
Addr <=  'd15 ;
        end
    always
        @(posedge Clock or posedge Reset)
        begin
            if (Reset) 
                Din <=  'b0 ;
            else
                Din <=  (Din + 1) ;
        end
    RAM_based_shift_reg_top u_DUT (.Din(Din), .clk(Clock), .Reset(Reset), .Q(OUT)) ; 
endmodule


