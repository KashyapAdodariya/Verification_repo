`include "pkg.sv"
`include "interface.sv" 

module top;

	import pkg::*;
	import uvm_pkg::*;

	bit clock;
	
	always
		begin
			#10 clock=~clock;
		end

	intf_h intf(clock);
initial
	begin
      
      $dumpfile("dump.vcd");
	  $dumpvars(1);	 
      uvm_config_db #(virtual intf_h)::set(null,"*","intf_h",intf);
      run_test("test_h");

	end

endmodule

