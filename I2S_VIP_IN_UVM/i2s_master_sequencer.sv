

// Revision: 3
//-------------------------------------------------------------------------------


class i2s_sequencer extends uvm_sequencer #(i2s_seq_item);
  `uvm_component_utils(i2s_sequencer)
  extern function new(string name = "i2s_sequencer", uvm_component parent);
endclass:i2s_sequencer

  //////////////////////////////////////////////////////// 
  // Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : void  
  // Description        : constrctor
  //////////////////////////////////////////////////////// 

  function i2s_sequencer :: new(string name = "i2s_sequencer", uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(),"i2s_sequence NEW",UVM_LOW)
  endfunction:new

