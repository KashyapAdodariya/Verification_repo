class callback_seq_h extends uvm_callback;
  `uvm_object_utils(callback_seq_h)
  
  function new(string name = "callback_seq_h");
    super.new(name);
    `uvm_info(get_type_name(),"callback_seq_h new call",UVM_LOW)
  endfunction
   
  virtual task pre_modified_pkt(ref sequence_item_h req);
  	`uvm_info(get_type_name(),"callback_seq_h pre_modified_pkt call",UVM_LOW)
  endtask
  
  virtual task post_modified_pkt(ref sequence_item_h req);
    `uvm_info(get_type_name(),"callback_seq_h post_modified_pkt call",UVM_LOW)
  endtask
  
endclass

//----------------------------------------------------------------------------------------------------------------------------

class callback_1_seq_h extends callback_seq_h;
  `uvm_object_utils(callback_1_seq_h)
  
  function new(string name = "callback_1_seq_h");
    super.new(name);
    `uvm_info(get_type_name(),"callback_1_seq_h new call",UVM_LOW)
  endfunction
   
  virtual task pre_modified_pkt(ref sequence_item_h req);
  	`uvm_info(get_type_name(),"callback_1_seq_h pre_modified_pkt call",UVM_LOW)
  endtask
  
  virtual task post_modified_pkt(ref sequence_item_h req);
    `uvm_info(get_type_name(),"callback_1_seq_h post_modified_pkt call",UVM_LOW)
  endtask
  
endclass