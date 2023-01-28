class seq_item extends uvm_sequence_item;
  core_type core;
  rand int a; 
  `uvm_object_utils_begin (seq_item)
  	`uvm_field_int(a, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "seq_item");
    super.new(name);
  endfunction
  
endclass