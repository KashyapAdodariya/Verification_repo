class callback_h extends uvm_callback;
  `uvm_object_utils(callback_h)
  
  function new(string name = "callback_h");
    super.new(name);
    `uvm_info(get_type_name(),"callback new call",UVM_LOW)
  endfunction: new
  
  virtual task pre_callback();
    `uvm_info(get_type_name(),"callback pre_callback call",UVM_LOW)
  endtask
  
  virtual task post_callback();
    `uvm_info(get_type_name(),"callback post_callback call",UVM_LOW)
  endtask
  
endclass: callback_h

//------------------------------------------------------------------------------------------------------
class callback_1_h extends callback_h;
  `uvm_object_utils(callback_1_h)
  
  function new(string name = "callback_1_h");
    super.new(name);
    `uvm_info(get_type_name(),"callback_1 extend one new call",UVM_LOW)
  endfunction: new
  
  virtual task pre_callback();
    `uvm_info(get_type_name(),"callback_1 pre_callback call",UVM_LOW)
  endtask
  
  virtual task post_callback();
    `uvm_info(get_type_name(),"callback_1 post_callback call",UVM_LOW)
    //testing report catcher with test2 
    `uvm_error("ERROR INJECTION MSG","ERROR INJECTION MSG")
  endtask
  
endclass: callback_1_h

