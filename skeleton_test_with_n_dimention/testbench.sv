
`include "i2s_interface.sv" 

module top;

	import i2s_pkg::*;
	import uvm_pkg::*;

	bit clock;
	
	always
		begin
			#10 clock=~clock;
		end

	i2s_interface in0(clock);
initial
	begin
      
      $dumpfile("dump.vcd");
	    $dumpvars(1);
		//write_xtn_master req;
	 
      uvm_config_db #(virtual i2s_interface)::set(null,"*","vif",in0);
		run_test("i2s_test");

	end

endmodule

