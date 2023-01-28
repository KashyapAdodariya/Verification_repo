//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "driver_callback.sv"
`include "driver.sv"
`include "environment.sv"
`include "basic_test.sv"
`include "user_callback.sv"
`include "user_callback_test.sv"

program testbench_top;
  
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin//{
    run_test();
  end //}
  
endprogram