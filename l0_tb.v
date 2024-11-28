// Testbench for FIFO module
// Reads data from a file and writes into a FIFO, then reads it back for verification

module l0_tb;

    parameter bw = 4;               // Data bit width
    parameter col = 8;              // Number of columns in FIFO
    parameter total_cycle = 64;     // Total clock cycles for writing
    parameter total_cycle_2nd = 4;  // Total clock cycles for secondary operations

    reg clk = 0;                    // Clock signal
    reg rd = 0;                     // Read enable
    reg wr = 0;                     // Write enable
    reg reset = 0;                  // Reset signal
    wire [bw*col-1:0] out;          // FIFO output
    wire full, ready;               // FIFO status signals

    integer i;                      // Loop iterator
    reg [bw-1:0] memory [0:127];    // Memory to hold data from file
    integer file_ptr;               // File handler for reading data
    
    // Instantiate FIFO (DUT)
l0 #(.bw(bw)) l0_instance (
        .clk(clk),
        .in({memory[0],memory[1],memory[2],memory[3],memory[4],memory[5],memory[6],memory[7]}), 
        .out(out), 
        .rd(rd),
        .wr(wr), 
        .o_full(full), 
        .reset(reset), 
        .o_ready(ready));

    // Clock generation
    always #5 clk = ~clk;

    // Task to write data into FIFO
    task write_to_fifo;
        input integer num_cycles;
        begin
            wr = 1;
            for (i = 0; i < num_cycles; i = i + 1) begin
                #10; // Wait for clock edge
            end
            wr = 0;
        end
    endtask

    // Task to read data from FIFO
    task read_from_fifo;
        input integer num_cycles;
        begin
            rd = 1;
            for (i = 0; i < num_cycles; i = i + 1) begin
                #10; // Wait for clock edge
                $display("Read Data: %h", out); // Print output for verification
            end
            rd = 0;
        end
    endtask

    // Testbench logic
    initial begin
        // Initialize signals
        reset = 1;
        #20 reset = 0;

        // Read data from file into memory
        $readmemh("file.hex", memory);
        $display("Data loaded from file into memory.");

        // Write data into FIFO
        $display("Writing data to FIFO...");
        write_to_fifo(total_cycle_2nd);
		  
        $display("Writing data to FIFO...");
        write_to_fifo(total_cycle_2nd);

        // Read data from FIFO
        $display("Reading data from FIFO...");
        read_from_fifo(total_cycle_2nd);

        // End simulation
        $display("Testbench completed.");
        #10 $finish;
    end

endmodule
