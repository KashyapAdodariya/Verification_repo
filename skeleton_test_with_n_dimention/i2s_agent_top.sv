class i2s_agent_top extends uvm_env;
  `uvm_component_utils(i2s_agent_top);

  i2s_env_config env_cfg;
  i2s_agent agt[];

  extern function new(string name = "i2s_agent_top" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function i2s_agent_top :: new(string name = "i2s_agent_top", uvm_component parent);
  super.new(name,parent);
  if(!uvm_config_db #(i2s_env_config)::get(this,"","i2s_env_config",env_cfg))
    `uvm_fatal("i2s_agent_top","not get env_cfg")
    agt = new[env_cfg.no_of_master_agent];
  $display("i2s_agent_top run");
endfunction

function void i2s_agent_top :: build_phase(uvm_phase phase);
  super.build_phase(phase);
  foreach(agt[i]) begin
    agt[i] = i2s_agent::type_id::create($sformatf("agt[%0d]",i),this);
  end
    $display("i2s_agent_top build_phase");
endfunction

task i2s_agent_top :: run_phase(uvm_phase phase);
  uvm_top.print_topology;
endtask

    
