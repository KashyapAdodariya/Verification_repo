class sequencer extends uvm_sequencer #(seq_item);
  `uvm_component_utils(sequencer)
  `uvm_register_cb(sequencer,seq_cb)
  
  function new(string name = "sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
endclass