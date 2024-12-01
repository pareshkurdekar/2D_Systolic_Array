// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps


`include "core.v"
`include "mac_array.v"
`include "mac_row.v"
`include "mac_tile.v"
`include "mac.v"
`include "corelet.v"
`include "sram_128b_w2048.v"
`include "sram_32b_w2048.v"
//`include "fifo_depth64.v"
`include "fifo_mux_16_1.v"
`include "fifo_mux_8_1.v"
`include "fifo_mux_2_1.v"
`include "l0.v"
`include "ofifo.v"
`include "fifo_depth16.v"

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;
parameter len_os = 72; 

reg clk = 0;
reg reset = 1;

wire [37:0] inst_q; 

reg all_row_mode_q = 0;
reg l0_rd_mode_q = 0;
reg mode_q = 0;
reg data_mode_q = 0;
reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg CEN_xmem = 1;
reg WEN_xmem = 1;
reg [10:0] A_xmem = 0;
reg CEN_xmem_q = 1;
reg WEN_xmem_q = 1;
reg [10:0] A_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [10:0] A_pmem = 0;
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [10:0] A_pmem_q = 0;
reg ofifo_rd_q = 0;
reg ififo_wr_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg load_q = 0;
reg acc_q = 0;
reg acc = 0;

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col-1:0] answer;

reg all_row_mode;
reg l0_rd_mode;
reg mode;
reg data_mode;
reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name;
wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij;
integer error;

assign inst_q[37] = all_row_mode_q;
assign inst_q[36] = l0_rd_mode_q;
assign inst_q[35] = mode_q;
assign inst_q[34] = data_mode_q;
assign inst_q[33] = acc_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = ififo_wr_q;
assign inst_q[4]   = ififo_rd_q;
assign inst_q[3]   = l0_rd_q;
assign inst_q[2]   = l0_wr_q;
assign inst_q[1]   = execute_q; 
assign inst_q[0]   = load_q; 


core  #(.bw(bw), .col(col), .row(row)) core_instance (
	.clk(clk), 
	.inst(inst_q),
	.ofifo_valid(ofifo_valid),
        .D_xmem(D_xmem_q), 
        .sfp_out(sfp_out), 
	.reset(reset)); 


initial begin 

  all_row_mode = 0;
  l0_rd_mode = 0;
  mode = 0;
  data_mode = 0;
  inst_w   = 0; 
  D_xmem   = 0;
  CEN_xmem = 1;
  WEN_xmem = 1;
  A_xmem   = 0;
  ofifo_rd = 0;
  ififo_wr = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  execute  = 0;
  load     = 0;

  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);


  // ------------- ACTIVATION DATA WRITING TO MEMORY --------------//
  x_file = $fopen("activation_temp_os.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);

  //////// Reset /////////
  #0.5 clk = 1'b1;   reset = 1;
  #0.5 clk = 1'b0; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b1;
    #0.5 clk = 1'b0;  
  end

  #0.5 clk = 1'b1;   reset = 0;
  #0.5 clk = 1'b0; 

  #0.5 clk = 1'b1;   
  #0.5 clk = 1'b0;   
  /////////////////////////

  /////// Activation data writing to memory ///////
  A_xmem = 0;
  for (t=0; t<len_os; t=t+1) begin  
    #0.5 clk = 1'b1;  x_scan_file = $fscanf(x_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b0;   
  end

  #0.5 clk = 1'b1;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b0; 

  $fclose(x_file);
  // /////////////////////////////////////////////////

// DONE: 1. Activation data writing to memory

// ------------- WEIGHT DATA WRITING TO MEMORY --------------//

  w_file = $fopen("weight_for_output_stationary.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  w_scan_file = $fscanf(w_file,"%s", captured_data);
  w_scan_file = $fscanf(w_file,"%s", captured_data);
  w_scan_file = $fscanf(w_file,"%s", captured_data);

  //////// Reset /////////
  #0.5 clk = 1'b1;   reset = 1;
  #0.5 clk = 1'b0; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b1;
    #0.5 clk = 1'b0;  
  end

  #0.5 clk = 1'b1;   reset = 0;
  #0.5 clk = 1'b0; 

  #0.5 clk = 1'b1;   
  #0.5 clk = 1'b0;   

  //////// Activation data writing to memory ///////
  
  A_pmem = 0;
  for (t=0; t<len_os; t=t+1) begin  
    #0.5 clk = 1'b1;  w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_pmem = 0; CEN_pmem = 0; if (t>0) A_pmem = A_pmem + 1; 
    #0.5 clk = 1'b0;  
  end


  #0.5 clk = 1'b1;  WEN_pmem = 1;  CEN_pmem = 1; A_xmem = 0;
  #0.5 clk = 1'b0; 

  $fclose(w_file);

/*
DONE: 
    1. Activation data writing to memory
    2. Weight Data Writing to memory
*/


// ------------- WEIGHT and ACTIVATION DATA WRITING TO IFIFO anf L0FIFO --------------//

    // Read from SRAM 
    // WEN_pmem = 1 => Read Mode on SRAM
    // ififo_wr = 1 => Write to IFIFO 
    // ififo_rd = 1 => Read from IFIFO
    // mode = 0 => Output Stationary 
    // data_mode = 0 => One row at a time

    #0.5 clk = 1'b1;  
    WEN_pmem = 1;  CEN_pmem = 1; A_pmem = 0;
    WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
    #0.5 clk = 1'b0; 

    #0.5 clk = 1'b1;  mode = 0; data_mode = 0;  // Activation to L0 and weight to IFIFO in output stationary
    #0.5 clk = 1'b0; 

    // #0.5 clk = 1'b1;  load = 1;  // Activation to L0 and weight to IFIFO in output stationary
    // #0.5 clk = 1'b0;  

    #0.5 clk = 1'b1;   reset = 1;
    #0.5 clk = 1'b0;  

    #0.5 clk = 1'b1;   reset = 0;
    #0.5 clk = 1'b0; 
    
    for (t=0; t<len_os; t=t+1) begin  
      #0.5 clk = 1'b1;   
      ififo_rd = 1; ififo_wr = 1; WEN_pmem = 1; CEN_pmem = 0; if (t>0) A_pmem = A_pmem + 1; 
      l0_rd = 1;    l0_wr = 1;    WEN_xmem = 1; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1; load = 1; execute = 0 ;
      #0.5 clk = 1'b0;  

    end

    #0.5 clk = 1'b1;  load = 0;  // Activation to L0 and weight to IFIFO in output stationary
    #0.5 clk = 1'b0; 

    for (i=0;i<100; i=i+1)
    begin
    #0.5 clk = 1'b1; 
    #0.5 clk = 1'b0; 
    end

end



always @ (posedge clk) begin

   
   inst_w_q   <= inst_w; 
   all_row_mode_q <= all_row_mode;
   l0_rd_mode_q <= l0_rd_mode;
   mode_q <= mode;
   data_mode_q <= data_mode;
   D_xmem_q   <= D_xmem;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_xmem_q   <= A_xmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
end


endmodule




