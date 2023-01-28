typedef enum {WRITE,READ} rd_wr;

class seq_item extends uvm_sequence_item;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand rd_wr r_w;
  `uvm_object_utils_begin(seq_item)
  	`uvm_field_int(addr,UVM_ALL_ON)
  	`uvm_field_int(data,UVM_ALL_ON)
  	`uvm_field_enum(rd_wr,r_w,UVM_ALL_ON)
  `uvm_object_utils_end
  function new(string name = "seq_item");
    super.new(name);
  endfunction: new
endclass: seq_item