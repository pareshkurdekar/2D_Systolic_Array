module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;

  wire [psum_bw*(row+1)*col-1:0] psum_temp;
  reg [2*row - 1:0] inst_temp;
  wire [col-1:0] valid_temp [row-1:0];

  assign psum_temp[psum_bw*col-1:0] = in_n;

  genvar i;
    for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
        .clk(clk),
        .in_n(psum_temp[psum_bw*col*i-1:psum_bw*col*(i-1)]),
        .out_s(psum_temp[psum_bw*col*(i+1)-1:psum_bw*col*i]), 
        .in_w(in_w[bw*i-1:bw*(i-1)]),
        .inst_w(inst_temp[2*i-1:2*(i-1)]),
        .reset(reset),
        .valid(valid_temp[i-1])
      );
    end

  assign out_s = psum_temp[psum_bw*col*(row+1)-1:psum_bw*col*row];
  assign valid = valid_temp[row-1];

  integer j;

  always @(posedge clk or posedge reset) begin    
      
      inst_temp <= {row{inst_w}};
  //   inst_temp[1:0] <= inst_w; 
  //   inst_temp[3:2] <= inst_temp [1:0];
  //   inst_temp[5:4] <= inst_temp [3:2];
  //   inst_temp[7:6] <= inst_temp [5:4];
  //   inst_temp[9:8] <= inst_temp [7:6];
  //   inst_temp[11:10] <= inst_temp [9:8];
  //   inst_temp[13:12] <= inst_temp [11:10];
  //   inst_temp[15:14] <= inst_temp [13:12];
  end

endmodule