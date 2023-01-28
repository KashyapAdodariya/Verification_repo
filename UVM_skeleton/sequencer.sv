`define cb_seq_on
class sequencer_h extends uvm_sequencer #(sequence_item_h);
  `uvm_component_utils(sequencer_h)
  
  `ifdef cb_seq_on
  `uvm_register_cb(sequencer_h,callback_seq_h)
  `endif
  
  function new(string name="sequencer_h",uvm_component parent);
	super.new(name,parent);
    `uvm_info(get_type_name(),"sequencer new call",UVM_LOW)
endfunction 
	
endclass: sequencer_h


