module corelet (clk, l0_in, l0_rd, l0_wr, reset, ififo_in, ififo_rd, ififo_wr);
  
  parameter row  = 8;
  parameter bw = 4;
  parameter col = 8; 
 
  
  input  clk;
  input [bw*col-1:0] l0_in;
  input [bw*col-1:0] ififo_in;
  input ififo_rd;
  input l0_rd;
  input ififo_wr;
  input l0_wr;
  input reset;

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
        .wr(ififo_wr_q), 
        .o_full(ififo_full), 
        .reset(reset), 
        .o_ready(ififo_ready)
  );


 //////////////////////////////////////////////////////




 //////////////// Mac Array Instance ///////////////////


 /////////////////////////////////////////////////////



 //////////////// Ofifo Instance ///////////////////////


//////////////////////////////////////////////////////////



/////////////////////// SFP ///////////////////////////////

//////////////////////////////////////////////////////////



  always @(posedge clk)
  begin
     l0_wr_q <= l0_wr;
     ififo_wr_q <= ififo_wr;
  end

endmodule