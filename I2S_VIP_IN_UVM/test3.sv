class stereo_mode_slave_tx_test extends i2s_base_test;

  `uvm_component_utils(stereo_mode_slave_tx_test)
  
  //---------------------------------------
  // sequence instance 
  //--------------------------------------- 
  write_sequence seq;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "stereo_mode_slave_tx_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the sequence
    seq = write_sequence::type_id::create("seq");
    set_master_config();
    set_slave_config();
  endfunction : build_phase
  
  //---------------------------------------
  // run_phase - starting the test
  //---------------------------------------
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
    seq.start(env.i2s_sagnt.sequencer);
    phase.drop_objection(this);
    
  endtask : run_phase
  
    function void set_master_config();
    m_cfg.is_active = UVM_PASSIVE;
    m_cfg.mode_sel = RX;
  endfunction:set_master_config
    
  function void set_slave_config();
    s_cfg.is_active = UVM_ACTIVE;
    s_cfg.mode_sel = TX;
  endfunction:set_slave_config
  
endclass : stereo_mode_slave_tx_test