// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset, mode);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
output [bw-1:0] out_e; 
input  [1:0] inst_w;
output [1:0] inst_e; 
input [psum_bw-1:0] in_n; 
input  clk;
input  reset;
input mode; 

reg    [bw-1:0] a_q;
reg    [bw-1:0] b_q;
reg    [psum_bw-1:0] c_q;
wire   [psum_bw-1:0] mac_out;
reg    [1:0] inst_q;
reg    load_ready_q;
reg  [1:0] inst_w_q;

//assign out_s = output(0)/weight(1)?in_n(weights):mac_out
// mode = 0 => Output Stationary 
// mode = 1 => Weight Stationary

wire [psum_bw-1:0] out_s_os; 
assign out_s_os = inst_w_q[1] ? c_q:b_q; 

assign out_s  = mode ? mac_out : out_s_os;

assign out_e  = a_q;
assign inst_e = inst_q;


mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(mac_out)
); 

always @ (posedge clk) begin
  if (mode) begin // Weight Stationary 
        if (reset) begin
                load_ready_q <= 1;
                inst_q       <= 0;
        end
        else begin
                inst_q[1]  <= inst_w[1];
                if (inst_w) begin
                        a_q <= in_w;
                        c_q <= in_n;
                end
                if (inst_w[0] && load_ready_q ) begin
                        b_q  <= in_w;
                        load_ready_q <= 0;
                end
                else if (!load_ready_q) begin
                        inst_q[0] <= inst_w[0];
                end
        end 
  end

  else begin 
        inst_w_q <= inst_w;
        if (reset) begin 
                // reset the psum 
                c_q <= 0;
                inst_q <= 0;
        end
        else begin 
                // c_q <= mac_out;
                inst_q <= inst_w; // Passing inst to east
                // For output stationary the instrucion does the following: 
                // inst[0]: Execute 
                // inst[1]: Pass down c_q
                // They switch alternatively
                if (inst_w_q[0]) begin
                   a_q <= in_w;
                   b_q <= in_n[bw-1:0];
                   c_q <= mac_out; 
                end

                if ((inst_w[0] == 1) && (inst_w_q[0] == 0)) begin 
                        c_q <= 0; 
                        a_q <= 0; 
                        b_q <= 0; 
                end

                if ((inst_w_q[1] == 1)) begin 
                        c_q <= in_n; 
                        
                end 
        end 
  end
end
endmodule