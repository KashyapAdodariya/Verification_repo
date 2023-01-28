class sequence_item_h extends uvm_sequence_item; 
  rand bit [7:0]addr;
  rand bit [31:0]data[$];
  bit r_w;
  `uvm_object_utils_begin(sequence_item_h)
  `uvm_field_int(addr, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new(string name = "sequence_item_h");
    super.new(name);
    `uvm_info(get_type_name(),"sequence_item new call",UVM_LOW)
  endfunction
 
  //function void do_print(uvm_printer printer);
  //function void do_copy(uvm_object local_copy);
  
  constraint data_len {data.size() inside {2,4,8,16,32};}
  
endclass

