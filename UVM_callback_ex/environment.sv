//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------

class environment extends uvm_env;
  driver driv;
  
  `uvm_component_utils(environment)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driv = driver::type_id::create("driv", this);
  endfunction
  
endclass