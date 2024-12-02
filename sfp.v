// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfp #(
    parameter bw = 4,          // Bit width (currently unused)
    parameter psum_bw = 16     // Partial sum bit width
) (
    input               clk,      // Clock signal
    input               reset,    // Synchronous reset
    input               acc,      // Accumulate enable
    input  signed [psum_bw-1:0] in,  // Input partial sum
    output signed [psum_bw-1:0] out  // Output partial sum
);

    // Register to hold the accumulated partial sum
    reg signed [psum_bw-1:0] psum_q;

    // Output assignment
    assign out = psum_q;

    // Sequential logic for accumulation
    always @(posedge clk) begin
        if (reset || !acc) 
            psum_q <= 0;
        else if (acc) 
            psum_q <= psum_q + in;  
    end

endmodule
