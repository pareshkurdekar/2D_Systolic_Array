module core ( clk, inst, ofifo_valid, D_xmem, Q_out, reset);

parameter bw = 4;
parameter row = 8;
parameter col = 8;
parameter psum_bw = 16;


input clk;
input reset;
input [50:0] inst; 
output ofifo_valid;
input [bw*row-1:0]D_xmem;
output [col*psum_bw-1:0] Q_out;

wire CEN_xmem;
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
wire mode;
wire data_mode;
wire all_row_mode;
wire sfu_enable;
wire [127:0] sfp_out;

wire CEN_omem;
wire WEN_omem;
wire [10:0] A_omem;



assign sfu_enable = inst[50];

assign output_loading_mode = inst[49];

assign CEN_omem     = inst[48];
assign WEN_omem     = inst[47];
assign A_omem       = inst[46:36];

assign mode         = inst[35];
assign data_mode    = inst[34];
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

wire [31:0 ]Q_act;
wire [31:0 ]Q_wt;

reg [bw*col-1:0] l0_in;
reg [bw*col-1:0] ififo_in;

// Sram 1 Instantiation for L0

 sram_32b_w2048 activation_sram (
	.CLK(clk), 
	.CEN(CEN_xmem), 
	.WEN(WEN_xmem & !l0_full),
   .A(A_xmem), 
   .D(D_xmem), 
   .Q(Q_act));

/////////////////////////////////

///////////////////////////////////////////////////

// Sram 1 Instantiation for IFIFO

 sram_32b_w2048 weight_sram (
	.CLK(clk), 
	.CEN(CEN_pmem), 
	.WEN(WEN_pmem & !ififo_full),
   .A(A_pmem), 
   .D(D_xmem), 
   .Q(Q_wt));


/////////////////////////////////

/////////////////////////////////
wire [127:0] o_sram;
assign o_sram = sfp_out;
 sram_128b_w2048 ofifo_sram (
	.CLK(clk), 
	.CEN(CEN_omem), 
	.WEN(WEN_omem),
   .A(A_omem), 
   .D(o_sram), 
   .Q(Q_out));


/////////////////////////////////

/////////// Corelet Instantation /////////////////

corelet core_inst1 (
    .clk(clk),
    .l0_in(l0_in),
    .l0_rd(l0_rd),
    .l0_rd_mode(l0_rd_mode),
    .all_row_mode(all_row_mode),
    .mode(mode),
    .data_mode(data_mode),
    .l0_wr(l0_wr),
    .ofifo_rd(ofifo_rd),
    .sfu_enable(sfu_enable),
    .ififo_in(ififo_in),
    .ififo_rd(ififo_rd),
    .ififo_wr(ififo_wr),
    .load(load),
    .execute(execute),
    .reset(reset),
    .sfp_out(sfp_out),
    .ififo_ready(ififo_ready),
    .l0_ready(l0_ready),
    .ififo_full(ififo_full),
    .l0_full(l0_full)

);

// output or wt stationary

always @(*)
begin
    if(mode)    // Weight Stationary
    begin
        
        if(data_mode) // Send in Weight/ Activation
            l0_in = Q_wt;  // If data mode is 1, send wt to L0
        else                  
            l0_in = Q_act; // If data mode is 0, send act to L0

    end
    else       // Output Stationary
    begin
        l0_in = Q_act;      // L0 will load the activation
        ififo_in = Q_wt;    // IFIFO will load the weights
        // Both these loads will happen ip ch by ip ch
        
    end
end
// assign l0_in = Q_act;
// assign ififo_in = Q_wt;


always @(posedge clk) begin

   // l0_in <= Q_act;

end

endmodule