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

wire CEN_xmem_q = 1;
wire WEN_xmem_q = 1;
wire [10:0] A_xmem_q = 0;
wire CEN_pmem_q = 1;
wire WEN_pmem_q = 1;
wire [10:0] A_pmem_q = 0;
wire ofifo_rd_q = 0;
wire ififo_wr_q = 0;
wire ififo_rd_q = 0;
wire l0_rd_q = 0;
wire l0_wr_q = 0;
wire execute_q = 0;
wire load_q = 0;
wire acc_q = 0;

assign acc_q          = inst[33];
assign CEN_pmem_q     = inst[32];
assign WEN_pmem_q     = inst[31];
assign A_pmem_q       = inst[30:20];
assign CEN_xmem_q     = inst[19];
assign WEN_xmem_q     = inst[18];
assign A_xmem_q       = inst[17:7];
assign ofifo_rd_q     = inst[6];
assign ififo_wr_q     = inst[5];
assign ififo_rd_q     = inst[4];
assign l0_rd_q        = inst[3];
assign l0_wr_q        = inst[2];
assign execute_q      = inst[1];
assign load_q         = inst[0];




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