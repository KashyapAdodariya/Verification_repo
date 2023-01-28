//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------

class driver extends uvm_component;
  
  `uvm_component_utils(driver)
  `uvm_register_cb(driver,driver_callback)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  task run_phase(uvm_phase phase);
      `uvm_do_callbacks(driver,driver_callback,pre_drive());
      
      drive_pkt();
      
      `uvm_do_callbacks(driver,driver_callback,post_drive());
  endtask
  
  task drive_pkt();
    `uvm_info("DRIVER","Inside drive_pkt method",UVM_LOW);
  endtask
  
endclass