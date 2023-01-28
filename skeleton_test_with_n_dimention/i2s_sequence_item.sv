class i2s_sequence_item extends uvm_sequence_item; 
   rand int test;
  //Utility macro
  `uvm_object_utils_begin(i2s_sequence_item)
  	`uvm_field_int(test, UVM_DEFAULT)
  `uvm_object_utils_end
 
  //declear veriable and control ver.
  //declear pre and post randomization
  //declear constraint 
  
  //Constructor
  function new(string name = "i2s_sequence_item");
    super.new(name);
  endfunction
 
endclass

