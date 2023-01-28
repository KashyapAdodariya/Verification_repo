class stereo_mode_master_tx_test extends i2s_base_test;

  `uvm_component_utils(stereo_mode_master_tx_test)
  
  //---------------------------------------
  // sequence instance 
  //--------------------------------------- 
  write_sequence seq;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "stereo_mode_master_tx_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the sequence
    seq = write_sequence::type_id::create("seq");
  endfunction : build_phase
  
  //---------------------------------------
  // run_phase - starting the test
  //---------------------------------------
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
    seq.start(env.i2s_magnt.sequencer);
    phase.drop_objection(this);
    
  endtask : run_phase
  
endclass : stereo_mode_master_tx_test