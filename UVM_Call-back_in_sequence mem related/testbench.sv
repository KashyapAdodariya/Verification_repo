//-------------------------------------------------------------------------
//				www.verificationguide.com   testbench.sv
//-------------------------------------------------------------------------
//---------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "mem_base_test.sv"
`include "mem_test.sv"

`include "user_callback.sv"
`include "user_callback_test.sv"
//---------------------------------------------------------------

module tbench_top;
      
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin 
    run_test("user_callback_tes");
  end
  
endmodule