class driver_h extends uvm_driver#(sequence_item_h);
  `uvm_component_utils(driver_h)
  `uvm_register_cb(driver_h,callback_h)

  virtual intf_h vif;
  cfg_h cfg;
  sequence_item_h seq;

  function new(string name ="driver_h",uvm_component parent);
	super.new(name,parent);
    `uvm_info(get_type_name(),"driver new call",UVM_LOW)
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  	// get the config object using uvm_config_db 
    if(!uvm_config_db #(cfg_h)::get(this,"","cfg_h",cfg))
  	  `uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
    if(!uvm_config_db#(virtual intf_h)::get(this,"","intf_h",vif))
      `uvm_fatal("INTERFACE","can't get interface in driver")
      `uvm_info(get_type_name(),"driver build_phase call",UVM_LOW)
  endfunction
  
  function void connect_phase(uvm_phase phase);
    `uvm_info(get_type_name(),"driver conncet_phase call",UVM_LOW)
  endfunction
  
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(),"driver run_phase call",UVM_LOW)
  	forever begin
  	  seq_item_port.get_next_item(seq);
      `uvm_do_callbacks(driver_h,callback_h,pre_callback())
      `uvm_info(get_type_name(),"driver inside run_phase forever btw callback",UVM_LOW)
      `uvm_do_callbacks(driver_h,callback_h,post_callback())
      seq_item_port.item_done();
  	end
  endtask
    
endclass

//-------------------------------------------------------------------------------------------------------------------------------------

class driver_child_h extends driver_h;
  `uvm_component_utils(driver_child_h)
  function new(string name ="driver_child_h",uvm_component parent);
	super.new(name,parent);
    `uvm_info(get_type_name(),"driver_child_h new call",UVM_LOW)
  endfunction
endclass


      
      
      
    