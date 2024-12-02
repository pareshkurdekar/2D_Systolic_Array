module corelet (clk, l0_in, l0_rd, l0_rd_mode, ofifo_rd, sfu_enable, sfp_out, all_row_mode, mode, l0_ready, l0_full,data_mode, ififo_ready, ififo_full, l0_wr, reset, ififo_in, ififo_rd, load, execute, ififo_wr);
  
  parameter row  = 8;
  parameter bw = 4;
  parameter col = 8; 
  parameter psum_bw = 16;

  
  input  clk;
  input [bw*col-1:0] l0_in;
  input [bw*col-1:0] ififo_in;
  input ififo_rd;
  input l0_rd;
  input ififo_wr;
  input l0_wr;
  input reset;
  input load;
  input sfu_enable;
  input execute;
  inout ofifo_rd;
  output ififo_ready;
  output l0_ready;
  output [127:0] sfp_out;
    output ififo_full;
  output l0_full;


  input all_row_mode;
  input l0_rd_mode;
  input mode;
  input data_mode;

  wire l0_full;
  wire ififo_full;
  
  reg l0_wr_q;

  reg l0_rd_q;
  reg ififo_wr_q;
  reg ififo_rd_q;


  wire  [row*bw-1:0] l0_out;
  wire  [row*bw-1:0] ififo_out;
  
  ////////////// L0 Instance /////////////////////

    l0 #(.bw(bw)) l0_instance 
  (
        .clk(clk),
        .in(l0_in), 
        .out(l0_out), 
        .rd(l0_rd_q),
        .l0_rd_mode(l0_rd_mode),
        .wr(l0_wr_q), 
        .o_full(l0_full), 
        .reset(reset), 
        .o_ready(l0_ready)
  );
 //////////////////////////////////////////////////////

 //////////////// IFIFO Instance ///////////////////////

    l0 #(.bw(bw)) IFIFO_instance 
  (
        .clk(clk),
        .in(ififo_in), 
        .out(ififo_out), 
        .rd(ififo_rd_q),
        .l0_rd_mode(1'b0), // row by row 
        .wr(ififo_wr_q), 
        .o_full(ififo_full), 
        .reset(reset), 
        .o_ready(ififo_ready)
  );


 //////////////////////////////////////////////////////

wire [psum_bw*col-1:0] out_s;
wire [row*bw-1:0] in_w;
wire [psum_bw*col-1:0] in_n;
wire [1:0] inst_w;
wire [col-1:0] valid;

wire [psum_bw*col-1:0] ififo_out_temp;
assign ififo_out_temp = { {12'b0,ififo_out[31:28]},{12'b0,ififo_out[27:24]},{12'b0,ififo_out[23:20]},{12'b0,ififo_out[19:16]},{12'b0,ififo_out[15:12]},{12'b0,ififo_out[11:8]},{12'b0,ififo_out[7:4]},{12'b0,ififo_out[3:0]}};
assign in_n = mode ? 0 : ififo_out_temp;

 //////////////// Mac Array Instance ///////////////////

mac_array mac_array_inst (
  .clk(clk), 
  .reset(reset), 
  .out_s(out_s), 
  .in_w(l0_out),
  .mode(mode),
  .data_mode(data_mode),
  .in_n(in_n), 
  .inst_w({execute, load}), 
  .valid(valid)
  
  );
     

 /////////////////////////////////////////////////////

  wire [col*psum_bw-1: 0] ofifo_out;  
  wire ofifo_valid; 
  wire ofifo_full; 

 //////////////// Ofifo Instance ///////////////////////

ofifo ofifo_inst (
  .clk(clk), 
  .in(out_s), 
  .out(ofifo_out), 
  .rd(ofifo_rd), 
  .wr(valid), 
  .o_full(ofifo_full), 
  .reset(reset), 
  .o_ready(ofifo_ready), 
  .o_valid(ofifo_valid)
);

//////////////////////////////////////////////////////////

wire [127:0] Q_out;

wire [127:0]sfp_in;
assign sfp_in = mode ? Q_out : ofifo_out;
/////////////////////// SFP & Relu ///////////////////////////////

reg acc_q;
sfp_row sfp_inst (
    .clk(clk),    // Clock signal
    .reset(reset),  // Reset signal
    .en(sfu_enable),
    .acc(acc_q),    // Accumulate enable
    .in(sfp_in), // Input data bus
    .out(sfp_out) // Output data bus after ReLU

);

//////////////////////////////////////////////////////////



  always @(posedge clk)
  begin
     l0_wr_q <= l0_wr;
     l0_rd_q <= l0_rd;

     ififo_wr_q <= ififo_wr;
     ififo_rd_q <= ififo_rd;

  end

endmodule