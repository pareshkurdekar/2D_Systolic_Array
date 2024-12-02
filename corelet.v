module corelet (clk, l0_in, l0_rd, mode, data_mode, l0_wr, Q_out, acc, sfp_out,
                reset, ififo_in, ififo_rd, load, execute, ififo_wr, ofifo_out, ofifo_rd, output_loading_mode);
  
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
  input acc;
  input load;
  input [127:0] Q_out;
  input execute;
  input output_loading_mode;
  input mode;
  input data_mode;
  output [127:0] sfp_out;
  input ofifo_rd;
  output [col*psum_bw-1: 0]  ofifo_out;

  wire l0_ready;
  wire l0_full;
  wire ififo_ready;
  wire ififo_full;
  
  reg l0_wr_q;
  reg ififo_wr_q;


  wire  [row*bw-1:0] l0_out;
  wire  [row*bw-1:0] ififo_out;
  
  ////////////// L0 Instance /////////////////////

    l0 #(.bw(bw)) l0_instance 
  (
        .clk(clk),
        .in(l0_in), 
        .out(l0_out), 
        .rd(l0_rd),
        .data_mode(data_mode),
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
        .rd(ififo_rd),
        .data_mode(data_mode),
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
reg [col-1:0] valid_q;




 //////////////// Mac Array Instance ///////////////////

mac_array mac_array_inst (
  .clk(clk), 
  .reset(reset), 
  .out_s(out_s), 
  .in_w(l0_out),
  .mode(mode),
  .data_mode(data_mode),
  .in_n(128'b0), 
  .inst_w({execute, load}), 
  .valid(valid)
  
  );
     

 /////////////////////////////////////////////////////



 // wire [col*psum_bw-1: 0] ofifo_out; 
  wire ofifo_valid;   
  wire ofifo_full; 



 //////////////// Ofifo Instance ///////////////////////


ofifo ofifo_inst (
  .clk(clk), 
  .in(out_s), 
  .out(ofifo_out), 
  .rd(ofifo_rd), 
  .wr(valid_q), 
  .o_full(ofifo_full), 
  .reset(reset), 
  .o_ready(ofifo_ready), 
  .o_valid(ofifo_valid)
);


//////////////////////////////////////////////////////////



/////////////////////// SFP ///////////////////////////////
reg acc_q;
sfp_row sfp_inst (
    .clk(clk),    // Clock signal
    .reset(reset),  // Reset signal
    .acc(acc_q),    // Accumulate enable
    .in(Q_out), // Input data bus
    .out(sfp_out) // Output data bus after ReLU

);

//////////////////////////////////////////////////////////



  always @(posedge clk)
  begin
    l0_wr_q <= l0_wr; 
    ififo_wr_q <= ififo_wr;
    acc_q <= acc;
    valid_q <= valid;

  end

endmodule
