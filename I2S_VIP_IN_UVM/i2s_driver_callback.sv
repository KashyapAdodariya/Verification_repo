class i2s_driver_callback extends uvm_callback;
  
  `uvm_object_utils(i2s_driver_callback)
  
  function new(string name = "driver_callback");
    super.new(name);
    `uvm_info(get_type_name(),"I2S_DRIVER CALLBACK NEW",UVM_LOW)
  endfunction
  
  virtual task pre_run; 
    `uvm_info(get_type_name(),"CALLBACK PRE-RUN",UVM_LOW)
  endtask:pre_run
  
  virtual task post_run; 
    `uvm_info(get_type_name(),"CALLBACK POST-RUN",UVM_LOW)
  endtask:post_run
  
endclass:i2s_driver_callback