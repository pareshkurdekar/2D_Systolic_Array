module corelet (clk, D, Q, CEN, WEN, A, reset);
  input  clk;
  input  WEN;
  input reset;
  input  CEN;
  input  [127:0] D;
  input  [10:0] A;
  output [127:0] Q;


  parameter row  = 8;
  parameter bw = 4;
  parameter col = 8; 
 
  reg [bw*col-1:0] L0_in;
  wire L0_rd;
  reg L0_wr;
  wire [row-1:0] L0_empty;
  wire  [row*bw-1:0] L0_out;
  
  ////////////// L0 Instance /////////////////////

    l0 #(.bw(bw)) l0_instance 
  (
        .clk(clk),
        .in(L0_in), 
        .out(L0_out), 
        .rd(L0_rd),
        .wr(L0_wr), 
        .o_full(L0_full), 
        .reset(reset), 
        .o_ready(L0_ready));
 //////////////////////////////////////////////////////




 //////////////// IFIFO Instance ///////////////////////


 //////////////////////////////////////////////////////




 //////////////// Mac Array Instance ///////////////////


 /////////////////////////////////////////////////////



 //////////////// Ofifo Instance ///////////////////////


//////////////////////////////////////////////////////////



/////////////////////// SFP ///////////////////////////////

//////////////////////////////////////////////////////////



  always @(posedge clk)
  begin
		L0_in <= Q;
		L0_wr <= !CEN && WEN;
  end

endmodule