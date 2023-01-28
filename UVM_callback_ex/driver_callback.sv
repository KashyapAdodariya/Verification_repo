//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------

class driver_callback extends uvm_callback;
  
  `uvm_object_utils(driver_callback)
  
  function new(string name = "driver_callback");
    super.new(name);
  endfunction
  
  virtual task pre_drive; endtask
  virtual task post_drive; endtask
endclass