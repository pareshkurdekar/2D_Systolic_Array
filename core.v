module core ( clk, inst, ofifo_valid, D_xmem, sfp_out, reset);

parameter bw = 4;
parameter row = 8;
parameter col = 8;
parameter psum_bw = 16;


input clk;
input reset;
input [33:0] inst; 
output ofifo_valid;
input [bw*row-1:0]D_xmem;
output [col*psum_bw-1:0] sfp_out;



// Sram 1 Instantiation for L0



/////////////////////////////////



// Sram 1 Instantiation for L1



/////////////////////////////////


/////////// Corelet Instantation /////////////////





///////////////////////////////////////////////////
//  sram_128b_w2048 activation_sram (
// 	.CLK(clk), 
// 	.CEN(CEN), 
// 	.WEN(WEN),
//    .A(A), 
//    .D(D), 
//    .Q(Q));


endmodule