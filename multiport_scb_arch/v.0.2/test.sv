

class base_test extends uvm_test;
  
  env env_i;
  
  `uvm_component_utils(base_test)
  
  function new(string name = "base_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //`print("TEST: BUILD_PHASE CALLED")
    env_i = env::type_id::create("env_i", this);
  endfunction: build_phase
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `print("TEST: RUN_PHASE CALLED")
  endtask: run_phase
  
endclass: base_test