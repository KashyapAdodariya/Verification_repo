typedef enum {GOOD, BAD_ERR1, BAD_ERR2} pkt_type;
class seq_item extends uvm_sequence_item;
  rand bit[15:0] addr;
  rand bit[15:0] data;
  pkt_type pkt;
  `uvm_object_utils_begin(seq_item)
    `uvm_field_int(addr,UVM_ALL_ON)
    `uvm_field_int(data,UVM_ALL_ON)
    `uvm_field_enum(pkt_type,pkt,UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "seq_item");
    super.new(name);
  endfunction
  
  constraint pkt_c {pkt == GOOD;};
endclass