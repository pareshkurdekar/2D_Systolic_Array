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

wire CEN_xmem;
wire WEN_xmem;
wire [10:0] A_xmem;
wire CEN_pmem ;
wire WEN_pmem;
wire [10:0] A_pmem;
wire ofifo_rd ;
wire ififo_wr;
wire ififo_rd;
wire l0_rd ;
wire l0_wr;
wire execute;
wire load;
wire acc;

assign acc          = inst[33];
assign CEN_pmem     = inst[32];
assign WEN_pmem     = inst[31];
assign A_pmem       = inst[30:20];
assign CEN_xmem     = inst[19];
assign WEN_xmem     = inst[18];
assign A_xmem       = inst[17:7];
assign ofifo_rd     = inst[6];
assign ififo_wr     = inst[5];
assign ififo_rd     = inst[4];
assign l0_rd        = inst[3];
assign l0_wr        = inst[2];
assign execute      = inst[1];
assign load         = inst[0];

wire [127:0 ]Q_act;

reg [bw*col-1:0] l0_in;

// Sram 1 Instantiation for L0

 sram_128b_w2048 activation_sram (
	.CLK(clk), 
	.CEN(CEN_xmem), 
	.WEN(WEN_xmem),
   .A(A_xmem), 
   .D(D_xmem), 
   .Q(Q_act));

/////////////////////////////////


/////////// Corelet Instantation /////////////////

corelet inst1 (
    .clk(clk),
    .l0_in(l0_in)
    .l0_rd(l0_rd),
    .l0_wr(l0_wr),

);

///////////////////////////////////////////////////

// Sram 1 Instantiation for L1



/////////////////////////////////

always @(posedge clk) begin

    l0_in <= Q_act;

end

endmodule