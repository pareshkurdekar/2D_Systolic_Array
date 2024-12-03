module zero_detector_row (
    in, out, clk, reset
);


  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

input  clk, reset;
input  [row*bw-1:0] in;
output [row*(bw+1)-1:0] out;

wire [row-1:0]zero_flag =0;

genvar i;
for(i=0; i<row; i=i+1) begin 

    assign out[(bw + 1)*(i+1)-1:i*(bw+1)] = { {!(|in[bw*(i+1) -1: i*bw])}, in[bw*(i+1) -1: i*bw]};
    assign zero_flag[i] = {!(|in[bw*(i+1) -1: i*bw])};

end




endmodule