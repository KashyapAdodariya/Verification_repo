`include "header.sv"
class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  
  sys_env env;
  base_seq seq;
  
  function new(string name = "base_test", uvm_component parent);
    super.new(name,parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = sys_env::type_id::create("env",this);
    seq = base_seq::type_id::create("seq");
  endfunction: build_phase
  
  task run_phase(uvm_phase phase);
  	super.run_phase(phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(),"running base_seq in base_test",UVM_LOW)
    seq.start(env.agent_h.seqr_h);
    phase.drop_objection(this);
  endtask: run_phase
  
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
  
  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
    
    svr = uvm_report_server::get_server();
    if(svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) begin
      `uvm_info("Final Report phase","\n\nTEST_FAIL\n\n",UVM_LOW)
    end
    else begin
      `uvm_info("Final Report phase","\n\nTEAT_PASS\n",UVM_LOW)
    end
  endfunction: report_phase
  
endclass: base_test


class ral_test extends base_test;
  `uvm_component_utils(ral_test)
  
  ral_seq ral_seq_h;
  
  function new(string name = "ral_test", uvm_component parent);
    super.new(name,parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
  super.build_phase(phase);
    ral_seq_h = ral_seq::type_id::create("ral_seq_h");
  endfunction: build_phase
  
  task run_phase(uvm_phase phase);
  	super.run_phase(phase);
   	phase.raise_objection(this);
    `uvm_info(get_type_name(),"running ral_seq in ral_test",UVM_LOW)
    repeat(2) begin
      `uvm_info(get_type_name(),"\n",UVM_LOW)
      ral_seq_h.start(env.agent_h.seqr_h);
    end
   	phase.drop_objection(this);
 endtask: run_phase

endclass: ral_test

///////////////////////////////////////////////////////////////////////////////////////////////

class reset_ral_test extends base_test;
  `uvm_component_utils(reset_ral_test)
  
  reset_reg_seq ral_seq_h;
  
  function new(string name = "reset_ral_test", uvm_component parent);
    super.new(name,parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
  super.build_phase(phase);
    ral_seq_h = reset_reg_seq::type_id::create("ral_seq_h");
  endfunction: build_phase
  
  task run_phase(uvm_phase phase);
  	super.run_phase(phase);
   	phase.raise_objection(this);
    `uvm_info(get_type_name(),"running ral_seq in ral_test",UVM_LOW)
    repeat(2) begin
      `uvm_info(get_type_name(),"\n",UVM_LOW)
      ral_seq_h.start(env.agent_h.seqr_h);
    end
   	phase.drop_objection(this);
 endtask: run_phase

endclass: reset_ral_test