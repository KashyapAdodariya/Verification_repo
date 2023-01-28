`timescale 1ns/1ps
`define FREQ 48.000
`define toggle ((1000/`FREQ)/2)
`include "i2s_header.svh"
//`timescale 1ns/1fs
 
  
module top;

  bit clk = 1,reset =1;
  
	/*initial begin
      #91ns reset = 0;
      #10ns reset = 1;
    end*/

  always #(`toggle) clk=~clk;
  i2s_intf pif(clk,reset);

  test_tb t(pif);
  
  initial begin

    $dumpfile("WAVE_OUT.vcd");
    $dumpvars;
    #3000;
    i2s_msg_logger::error_display();
    $finish;
  end
  
endmodule:top