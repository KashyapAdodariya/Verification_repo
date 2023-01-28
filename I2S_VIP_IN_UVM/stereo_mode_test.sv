

// Revision: 3
//-------------------------------------------------------------------------------


class stereo_mode_test extends i2s_base_test;

  `uvm_component_utils(stereo_mode_test)
  
  // sequence instance 

  write_sequence seq;

  // constructor
 
  function new(string name = "stereo_mode_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  // build_phase
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the sequence
    seq = write_sequence::type_id::create("seq");
    
   
  endfunction : build_phase

  // run_phase - starting the test

  task run_phase(uvm_phase phase);
	//add uvm_report callback as add method
    uvm_report_cb::add(env.i2s_scb, rp_cth);
    
    phase.raise_objection(this);    
    seq.start(env.agt_top.master_agt[0].m_sequencer);
    
    phase.phase_done.set_drain_time(this,10ns);
    phase.drop_objection(this);
    
    uvm_report_cb::delete(env.i2s_scb, rp_cth);
    
    if(rp_cth.fail_count==0)
      uvm_report_info(get_full_name(),"Testcase not geting any error",UVM_HIGH);
    else
      uvm_report_error(get_full_name(),"Testcase fail and getting error");
  endtask : run_phase
  
endclass : stereo_mode_test
