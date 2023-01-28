

// Revision: 3
//-------------------------------------------------------------------------------



//including interfcae and testcase files

`include "i2s_interface.sv"


module i2s_tbench_top;
  
  import i2s_pkg::*;
  import uvm_pkg::*;
  
  bit clock;
	
  always #(`toggle) clock=~clock;
  
  i2s_interface intf(clock);
 
  
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  
  initial begin 
    
    uvm_config_db#(virtual i2s_interface)::set(null,"*","vif",intf);
    //enable wave dump
    $dumpfile("dump.vcd"); 
    $dumpvars;
    #1000 $finish;
  end

  
  //calling test
  
  initial begin 
    run_test("stereo_mode_test");
  end    
  
endmodule
