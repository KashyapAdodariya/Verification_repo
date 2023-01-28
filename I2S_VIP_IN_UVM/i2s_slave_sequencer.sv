//-------------------------------------------------------------------------
//------------------------SLAVE-SEQUENCER i2c---------------------------- 
//-------------------------------------------------------------------------

class i2s_slave_sequencer extends uvm_sequencer#(i2s_seq_item);

  `uvm_component_utils(i2s_slave_sequencer) 

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name = "i2s_slave_sequencer", uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass