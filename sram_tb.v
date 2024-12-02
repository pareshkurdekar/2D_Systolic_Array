// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1 ns/1 ps
`include "corelet.v"
`include "sram_128b_w2048.v"
`include "fifo_depth64.v"
`include "l0.v"
module sram_tb;


`define NULL 0

reg CLK = 0;
reg [10:0]  A = 0;
reg [127:0] D = 0;
reg CEN_EXT = 0;
reg CEN_Q ;
reg WEN_EXT = 1;
reg WEN_Q ;
reg reset;
wire [127:0] Q;


corelet corelet_instance (
	.clk(CLK), 
	.CEN(CEN_Q), 
	.WEN(WEN_Q),
	.reset(reset),
        .A(A), 
        .D(D), 
        .Q(Q));

always #20 CLK = ~CLK;

initial begin 

  $dumpfile("sram_tb.vcd");
  $dumpvars(0,sram_tb);

    #20 reset = 1'b1;
	 #20 reset = 1'b0;
	 #20 CEN_EXT = 0;
	 
    #20 A = 11'b00000000000; D = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; WEN_EXT = 0;

    #40  WEN_EXT = 1;

    #40  CEN_EXT = 1;


  #10 $finish;


end

 always @ (posedge CLK) begin
   WEN_Q <= WEN_EXT;
   CEN_Q <= CEN_EXT;
 end

endmodule




