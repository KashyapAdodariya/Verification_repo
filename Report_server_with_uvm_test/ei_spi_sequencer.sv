class ei_spi_sequencer_c extends uvm_sequencer#(ei_spi_sequence_item_c); ;

  `uvm_component_utils(ei_spi_sequencer_c) 

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction


endclass : ei_spi_sequencer_c