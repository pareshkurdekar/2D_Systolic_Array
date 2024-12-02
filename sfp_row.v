// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

module sfp_row #(
    parameter psum_bw = 16,  // Partial sum bit width
    parameter col = 8        // Number of SFP columns
) (
    input               clk,    // Clock signal
    input               reset,  // Reset signal
    input               acc,    // Accumulate enable
    input  [psum_bw*col-1:0] in, // Input data bus
    input               en,      // SFU enable
    input               mode,      // SFU enable
    output [psum_bw*col-1:0] out // Output data bus after ReLU
);

    wire [psum_bw*col-1:0] out_temp; // Intermediate wire to collect SFP outputs
    genvar i;

    // Instantiate multiple SFP modules
    generate
        for (i = 0; i < col; i = i + 1) begin : col_num
            sfp #(
                .psum_bw(psum_bw)
            ) sfp_instance (
                .clk(clk),
                .reset(reset),
                .acc(acc),
                .en(en),
                .in(in[psum_bw*(i+1)-1 : psum_bw*i]),
                .out(out_temp[psum_bw*(i+1)-1 : psum_bw*i])
            );
        end
    endgenerate

    // Instantiate multiple ReLU modules for each SFP output segment
    generate
        for (i = 0; i < col; i = i + 1) begin : relu_segments
            relu #(
                .psum_bw(psum_bw)
            ) relu_instance (
                .in_relu(out_temp[psum_bw*(i+1)-1 : psum_bw*i]),
                .out_relu(out[psum_bw*(i+1)-1 : psum_bw*i])
            );
        end
    endgenerate

endmodule
