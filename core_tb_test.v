// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps


//`include "core.v"
//`include "mac_array.v"
//`include "mac_row.v"
//`include "mac_tile.v"
//`include "mac.v"
//`include "ofifo.v"
//`include "corelet.v"
//`include "sfp_row.v"
//`include "sfp.v"
//`include "relu.v"
//`include "sram_128b_w2048.v"
//`include "sram_32b_w2048.v"
//`include "fifo_depth64.v"
//`include "fifo_mux_16_1.v"
//`include "fifo_mux_8_1.v"
//`include "fifo_mux_2_1.v"
//`include "l0.v"



module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;

reg clk = 0;
reg reset = 1;

wire [52:0] inst_q; 

reg all_row_mode_q = 0;
reg l0_rd_mode_q = 0;
reg mode_q = 0;
reg data_mode_q = 0;
reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg CEN_xmem = 1;
reg WEN_xmem = 1;

reg CEN_omem = 1;
reg WEN_omem = 1;
reg CEN_omem_q = 1;
reg WEN_omem_q = 1;

reg [10:0] A_omem = 0;
reg [10:0] A_omem_q = 0;


reg output_loading_mode = 0;
reg output_loading_mode_q = 0;
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
wire [col*psum_bw-1:0] Q_out;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij;
integer error;

assign inst_q[51] = output_loading_mode_q;

assign inst_q[50] = CEN_omem_q;
assign inst_q[49] = WEN_omem_q;
assign inst_q[48:38] = A_omem_q;

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
  .Q_out(Q_out), 
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

  x_file = $fopen("./activation.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;   
  /////////////////////////

  /////// Activation data writing to memory ///////
  for (t=0; t<len_nij; t=t+1) begin  
    #0.5 clk = 1'b0;  x_scan_file = $fscanf(x_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 
  

  // Can be used to test SRAM
  //   #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 0; A_xmem = 1;
  // #0.5 clk = 1'b1; 
  // for (t=0; t<len_nij; t=t+1) begin  
  //   #0.5 clk = 1'b0; A_xmem = A_xmem + 1;
  //   #0.5 clk = 1'b1;  
  // end

  // #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  // #0.5 clk = 1'b1; 

  $fclose(x_file);
  // /////////////////////////////////////////////////


  for (kij=0; kij<9; kij=kij+1) begin  // kij loop

    case(kij)
     0: w_file_name = "weight_itile0_otile0_kij0.txt";
     1: w_file_name = "weight_itile0_otile0_kij1.txt";
     2: w_file_name = "weight_itile0_otile0_kij2.txt";
     3: w_file_name = "weight_itile0_otile0_kij3.txt";
     4: w_file_name = "weight_itile0_otile0_kij4.txt";
     5: w_file_name = "weight_itile0_otile0_kij5.txt";
     6: w_file_name = "weight_itile0_otile0_kij6.txt";
     7: w_file_name = "weight_itile0_otile0_kij7.txt";
     8: w_file_name = "weight_itile0_otile0_kij8.txt";
    endcase
    

    w_file = $fopen(w_file_name, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

    #0.5 clk = 1'b0;   reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   





    /////// Kernel data writing to memory ///////

    //A_xmem = 11'b10000000000;

    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_pmem = 0; CEN_pmem = 0; if (t>0) A_pmem = A_pmem + 1; 
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_pmem = 1;  CEN_pmem = 1; A_pmem = 0;
    #0.5 clk = 1'b1; 

  
   //// Reading data from SRAM for testing
    // for (t=0; t<col; t=t+1) begin  
    //   #0.5 clk = 1'b0;  w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_pmem = 1; CEN_pmem = 0; if (t>0) A_pmem = A_pmem + 1; 
    //   #0.5 clk = 1'b1;  
    // end

    // #0.5 clk = 1'b0;  WEN_pmem = 1;  CEN_pmem = 1; A_pmem = 0;
    // #0.5 clk = 1'b1; 


    /////////////////////////////////////



    /////// Kernel data writing to L0 ///////
 
    #0.5 clk = 1'b0;  mode = 1; data_mode = 1;  // Send wt in wt stationary mode
    #0.5 clk = 1'b1; 

    
    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;   l0_rd = 0; l0_wr = 1; WEN_pmem = 1; CEN_pmem = 0; if (t>0) A_pmem = A_pmem + 1; 
      #0.5 clk = 1'b1;  

    end

    #0.5 clk = 1'b0;   l0_rd = 0; l0_wr = 0; WEN_pmem = 1;  CEN_pmem = 1; A_pmem = 0;
    #0.5 clk = 1'b1;   
    /////////////////////////////////////



    /////// Kernel loading to PEs ///////

   for (t=0; t<col; t=t+1) begin  

      #0.5 clk = 1'b0;   l0_rd = 1; l0_wr = 0; l0_rd_mode = 1; load = 1; execute = 0;
      #0.5 clk = 1'b1;   
   end


    /////////////////////////////////////
  


    ////// provide some intermission to clear up the kernel loading ///
    #0.5 clk = 1'b0;  load = 0; l0_rd = 0;
    #0.5 clk = 1'b1;  
  

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////



    /////// Activation data writing to L0 ///////
    
 // Writing into L0

    #0.5 clk = 1'b0;  mode = 1; data_mode = 0;  // Send wt in wt stationary mode
    #0.5 clk = 1'b1; 


  for (t=0; t<len_nij; t=t+1) begin  

    #0.5 clk = 1'b0;   l0_rd = 0; l0_wr = 1; WEN_xmem = 1;  CEN_xmem = 0;if (t>0) A_xmem = A_xmem + 1; 
    #0.5 clk = 1'b1;    
  end

  // Stop Writes & Reads

    #0.5 clk = 1'b0;   l0_rd = 0; l0_wr = 0; WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0; 
    #0.5 clk = 1'b1;
  

  // Wait for 10 cycles
  for (t=0; t<10; t=t+1) begin  

    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;   
       
  end

  // Reading from L0 for testing

  // for (t=0; t<len_nij; t=t+1) begin  

  //   #0.5 clk = 1'b0;   l0_rd = 1; l0_wr = 0; WEN_xmem = 1;  CEN_xmem = 1;
  //   #0.5 clk = 1'b1;   

  // end
  //   #0.5 clk = 1'b0;   l0_rd = 0; l0_wr = 0; WEN_xmem = 1;  CEN_xmem = 1;
  //   #0.5 clk = 1'b1;   

  // for (t=0; t<10; t=t+1) begin  

  //   #0.5 clk = 1'b0;  
  //   #0.5 clk = 1'b1;   
       
  // end



    /////////////////////////////////////



    /////// Execution ///////
    // Load L0 and Execute simultaneously

    for (t=0; t<len_nij; t=t+1) begin  

      #0.5 clk = 1'b0;   l0_rd = 1; l0_wr = 0; l0_rd_mode = 0; l0_rd_mode = 0; load = 1;execute = 1;
      #0.5 clk = 1'b1;   

   end

      #0.5 clk = 1'b0;   l0_rd = 0; l0_wr = 0; l0_rd_mode = 0; load = 0; execute = 0;
      #0.5 clk = 1'b1;   

  for (t=0; t<35; t=t+1) begin  

    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;   
       
  end

    /////////////////////////////////////



    //////// OFIFO READ ////////
    // Ideally, OFIFO should be read while execution, but we have enough ofifo
    // depth so we can fetch out after execution.
      #0.5 clk = 1'b0;   ofifo_rd = 1; 
      #0.5 clk = 1'b1;   

      for (t=0; t<36; t=t+1) 
      begin  
        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = A_omem + 1; if(t == len_nij-1) ofifo_rd = 0; 
        #0.5 clk = 1'b1;   
      end

      #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1 ; ofifo_rd = 0; 
      #0.5 clk = 1'b1;   

    /////////////////////////////////////


  end  // end of kij loop
   ////////// Accumulation /////////
   out_file = $fopen("out.txt", "r");  
   acc_file = $fopen("acc_address.txt", "r");

   // Following three lines are to remove the first three comment lines of the file
   out_scan_file = $fscanf(out_file,"%s", answer); 
   out_scan_file = $fscanf(out_file,"%s", answer); 
   out_scan_file = $fscanf(out_file,"%s", answer); 

   error = 0;



   $display("############ Verification Start during accumulation #############"); 

   for (i=0; i<len_onij+1; i=i+1) begin 

     #0.5 clk = 1'b0; 
     #0.5 clk = 1'b1; 

     if (i>0) begin
      out_scan_file = $fscanf(out_file,"%128b", answer); // reading from out file to answer
        if (Q_out == answer)
          $display("%2d-th output featuremap Data matched! :D", i); 
        else begin
          $display("%2d-th output featuremap Data ERROR!!", i); 
          $display("sfpout: %128b", Q_out);
          $display("answer: %128b", answer);
          error = 1;
        end
     end
  
 
     #0.5 clk = 1'b0; reset = 1;
     #0.5 clk = 1'b1;  
     #0.5 clk = 1'b0; reset = 0; 
     #0.5 clk = 1'b1;  

     for (j=0; j<len_kij+1; j=j+1) begin 

       #0.5 clk = 1'b0;   
         if (j<len_kij) begin CEN_pmem = 0; WEN_pmem = 1; acc_scan_file = $fscanf(acc_file,"%11b", A_pmem); end
                        else  begin CEN_pmem = 1; WEN_pmem = 1; end

         if (j>0)  acc = 1;  
       #0.5 clk = 1'b1;   
     end

     #0.5 clk = 1'b0; acc = 0;
     #0.5 clk = 1'b1; 
   end
   if (error == 0) begin
   	$display("############ No error detected ##############"); 
   	$display("########### Project Completed !! ############"); 

   end

   $fclose(acc_file);

// 1 //////

//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 1;   acc = 1;
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 38;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 75;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 115;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 152;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 189;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 229;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 266;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 303;  
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 500; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 500;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 2 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 2;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 39;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 76;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 116;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 153;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 190;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 230;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 267;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 304;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 501; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 501;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 3 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 3;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 40;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 77;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 117;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 154;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 191;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 231;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 268;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 305;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 502; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 502;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 4 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 4;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 41;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 78;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 118;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 155;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 192;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 232;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 269;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 306;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 503; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 503;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 5 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 7;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 44;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 81;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 121;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 158;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 195;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 235;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 272;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 309;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 504; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 504;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 6 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 8;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 45;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 82;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 122;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 159;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 196;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 236;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 273;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 310;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 505; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 505;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 7 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 9;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 46;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 83;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 123;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 160;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 197;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 237;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 274;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 311;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 506; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 506;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 8 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 10;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 47;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 84;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 124;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 161;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 198;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 238;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 275;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 312;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 507; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 507;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 9 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 13;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 50;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 87;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 127;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 164;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 201;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 241;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 278;   
//        #0.5 clk = 1'b1;  
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 315;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 508; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 508;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 10 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 14;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 51;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 88;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 128;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 165;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 202;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 242;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 279;   
//        #0.5 clk = 1'b1;  
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 316;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 509; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 509;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 11 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 15;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 52;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 89;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 129;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 166;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 203;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 243;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 280;   
//        #0.5 clk = 1'b1;  
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 317;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 510; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 510;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 12 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 16;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 53;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 90;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 130;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 167;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 204;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 244;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 281;   
//        #0.5 clk = 1'b1;  
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 318;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 511; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 511;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 13 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 19;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 56;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 93;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 133;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 170;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 207;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 247;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 284;   
//        #0.5 clk = 1'b1;  
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 321;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 512; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 512;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 14 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 20;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 57;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 94;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 134;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 171;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 208;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 248;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 285;   
//        #0.5 clk = 1'b1;  
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 322;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 513; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 513;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//// 15 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 21;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 58;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 95;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 135;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 172;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 209;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 249;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 286;   
//        #0.5 clk = 1'b1;  
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 323;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 514; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 514;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//
//// 15 //////
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 22;    acc = 1;
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 59;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 96;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 136;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 173;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 210;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 250;   
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 287;   
//        #0.5 clk = 1'b1;  
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 0;  A_omem = 324;   
//        #0.5 clk = 1'b1;   
//
//        #0.5 clk = 1'b0;  acc = 0;
//        #0.5 clk = 1'b1; 
//
//        #0.5 clk = 1'b0;   WEN_omem = 0;  CEN_omem = 0;  A_omem = 515; output_loading_mode = 1;
//
//        #0.5 clk = 1'b1;   
//        #0.5 clk = 1'b0;   WEN_omem = 1;  CEN_omem = 1;  A_omem = 515;  output_loading_mode = 0;
//        #0.5 clk = 1'b1;   
//
//
//
//  for (i=0; i<10 ; i=i+1) begin
//    #0.5 clk = 1'b0;
//    #0.5 clk = 1'b1;  
//  end
//
//  ////////// Accumulation /////////
//  out_file = $fopen("output.txt", "r");  
//
//  // Following three lines are to remove the first three comment lines of the file
//  out_scan_file = $fscanf(out_file,"%s", answer); 
//  out_scan_file = $fscanf(out_file,"%s", answer); 
//  out_scan_file = $fscanf(out_file,"%s", answer); 
//
//  error = 0;
//
//
//
//  $display("############ Verification Start during accumulation #############"); 
//
//  for (i=0; i<len_onij+1; i=i+1) begin 
//
//    #0.5 clk = 1'b0;  WEN_omem = 1;  CEN_omem = 0;  A_omem = 500 +i ; 
//    #0.5 clk = 1'b1; 
//
//    if (i>0) begin
//     out_scan_file = $fscanf(out_file,"%128b", answer); // reading from out file to answer
//       if (Q_out == answer)
//         $display("%2d-th output featuremap Data matched! :D", i); 
//       else begin
//         $display("%2d-th output featuremap Data ERROR!!", i); 
//         $display("sfpout: %128b", Q_out);
//         $display("answer: %128b", answer);
//         error = 1;
//       end
//    end
//   
// 
//    #0.5 clk = 1'b0; reset = 1;
//    #0.5 clk = 1'b1;  
//    #0.5 clk = 1'b0; reset = 0; 
//    #0.5 clk = 1'b1;  
//
//    // for (j=0; j<len_kij+1; j=j+1) begin 
//
//    //   #0.5 clk = 1'b0;   
//    //     if (j<len_kij) begin CEN_pmem = 0; WEN_pmem = 1; acc_scan_file = $fscanf(acc_file,"%11b", A_pmem); end
//    //                    else  begin CEN_pmem = 1; WEN_pmem = 1; end
//
//    //     if (j>0)  acc = 1;  
//    //   #0.5 clk = 1'b1;   
//    // end
//
//    #0.5 clk = 1'b0; acc = 0;
//    #0.5 clk = 1'b1; 
//  end
//
//
//  if (error == 0) begin
//  	$display("############ No error detected ##############"); 
//  	$display("########### Project Completed !! ############"); 
//
//  end

  // $fclose(acc_file);
  // //////////////////////////////////

  // for (t=0; t<10; t=t+1) begin  
  //   #0.5 clk = 1'b0;  
  //   #0.5 clk = 1'b1;  
  // end

  #10 $finish;

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

      A_omem_q   <= A_omem;
   CEN_omem_q <= CEN_omem;
   WEN_omem_q <= WEN_omem;

  output_loading_mode_q = output_loading_mode;

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




