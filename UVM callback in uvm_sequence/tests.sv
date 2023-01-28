class base_test extends uvm_test;
  env env_o;
  base_seq bseq;

  `uvm_component_utils(base_test)
  
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_o = env::type_id::create("env_o", this);
  endfunction
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    bseq = base_seq::type_id::create("bseq");
    bseq.l_seqr = env_o.agt.seqr;
    bseq.start(env_o.agt.seqr);
    phase.drop_objection(this);
  endtask
endclass

class err_test extends base_test;
  derived_seq_cb drvd_seq;
  `uvm_component_utils(err_test)
  
  function new(string name = "err_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drvd_seq = derived_seq_cb::type_id::create("drvd_seq", this);
  endfunction
  
  function void end_of_elaboration();
    super.end_of_elaboration();
    uvm_callbacks#(sequencer, seq_cb)::add(env_o.agt.seqr,drvd_seq);
  endfunction : end_of_elaboration
endclass