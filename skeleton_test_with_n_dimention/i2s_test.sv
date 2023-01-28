class i2s_test extends uvm_test;

 `uvm_component_utils(i2s_test)

 	i2s_env env;

  i2s_sequence seqh1;
  i2s_env_config env_cfg;
  i2s_config cfg;

	extern function new(string name = "i2s_test" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

      function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
      endfunction
endclass


function i2s_test::new(string name = "i2s_test" , uvm_component parent);
	super.new(name,parent);
  $display("i2s_test run");
endfunction

function void i2s_test :: build_phase(uvm_phase phase);
  super.build_phase(phase);
  env_cfg = i2s_env_config::type_id::create("env_cfg",this);
  env = i2s_env::type_id::create("env",this);
  cfg = i2s_config::type_id::create("cfg");
  uvm_config_db #(i2s_env_config) :: set(this,"*","i2s_env_config",env_cfg);
  uvm_config_db #(i2s_config) :: set(this,"env.agt_top.*","i2s_config",cfg);
  $display("i2s_test build_phase");
endfunction

task i2s_test :: run_phase(uvm_phase phase);
  phase.raise_objection(this);
  seqh1 = i2s_sequence::type_id::create("seqh1");
  seqh1.start(env.agt_top.agt[2].seqr);

  $display("i2s_test run_phase");
  phase.drop_objection(this);
endtask