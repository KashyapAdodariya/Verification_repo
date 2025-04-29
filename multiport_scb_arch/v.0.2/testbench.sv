


import uvm_pkg::*;
`include "uvm_macros.svh"
`include "define.sv"

`include "sv_pkg.sv"
import sv_pkg::*;

module top();
 
  initial begin
    run_test("base_test");
  end
 
  //initial begin #100ns; $finish(); end
endmodule