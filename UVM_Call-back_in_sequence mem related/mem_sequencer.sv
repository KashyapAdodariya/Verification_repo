//-------------------------------------------------------------------------
//						mem_sequencer - www.verificationguide.com
//-------------------------------------------------------------------------

class mem_sequencer extends uvm_sequencer#(mem_seq_item);

  `uvm_component_utils(mem_sequencer) 
  `uvm_register_cb(mem_sequencer,mem_callback)
  
  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass