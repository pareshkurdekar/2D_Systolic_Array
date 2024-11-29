// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module relu #(
    parameter psum_bw = 16  // Partial sum bit width
) (
    input  [psum_bw-1:0] in_relu,   // Input data segment
    output [psum_bw-1:0] out_relu   // Output after ReLU
);

    // Apply ReLU: if MSB (sign bit) is 0, pass the input; else, output 0
    assign out_relu = (in_relu[psum_bw-1] == 0) ? in_relu : 0;

endmodule
