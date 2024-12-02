// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module l0 (clk, in, out, rd, data_mode, wr, o_full, reset, o_ready);

  parameter row  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input data_mode;
  input  reset;
  input  [row*bw-1:0] in;
  output [row*bw-1:0] out;
  output o_full;
  output o_ready;

  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en;
  
  genvar i;

  assign o_ready = |empty;
  assign o_full = |full;

  generate
  for (i=0; i<row ; i=i+1) begin : row_num
      fifo_depth16 #(.bw(bw)) fifo_instance (
      //fifo_depth64 #(.bw(bw)) fifo_instance (
	 .rd_clk(clk),
	 .wr_clk(clk),
	 .rd(rd_en[i]),
	 .wr(wr),
    .o_empty(empty[i]),
    .o_full(full[i]),
	 .in(in[bw*(i+1) - 1 : i*bw]),
	 .out(out[bw*(i+1) - 1: i*bw]),
         .reset(reset));
  end

  endgenerate

  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 8'b00000000;
   end
   else

      /////////////// version1: read all row at a time ////////////////
      if(data_mode)
        //rd_en <= {row{rd}};
 	if (rd) begin
        	rd_en <= {row{1'b1}};
        end else begin
        	rd_en <= {row{1'b0}};
      ///////////////////////////////////////////////////////
      end else begin
      //////////////// version2: read 1 row at a time /////////////////
	 if (rd) begin
                    rd_en <= {rd_en[row-2:0], rd_en[row-1]};
                    // Rotate rd_en to enable one row at a time
                    if (rd_en == {row{1'b0}}) begin
                        rd_en[0] <= 1'b1;
                    end
                end else begin
                    rd_en <= {row{1'b0}};
                end
      end
      ///////////////////////////////////////////////////////
    end

endmodule
