`include "pkg.sv"
`include "interface.sv" 

module top;

  import pkg::*;
  import uvm_pkg::*;

  bit clock;

  always #1 clock=~clock;

  intf_h intf(clock);
  
  initial begin	 
    uvm_config_db #(virtual intf_h)::set(null,"*","intf_h",intf);
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  initial begin
    run_test("test_h");
  end

endmodule

