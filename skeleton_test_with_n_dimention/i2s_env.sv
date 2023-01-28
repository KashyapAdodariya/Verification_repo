class i2s_env extends uvm_env;
  `uvm_component_utils(i2s_env)

  //declear all required class
  i2s_agent_top agt_top;
  i2s_scoreboard sb;
  i2s_env_config env_cfg;

  extern function new(string name = "i2s_env", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass

function i2s_env :: new(string name = "i2s_env", uvm_component parent);
  super.new(name,parent);
  $display("i2s_env run");
endfunction

function void i2s_env :: build_phase(uvm_phase phase);
  super.build_phase(phase);

  if(!uvm_config_db #(i2s_env_config)::get(this,"","i2s_env_config",env_cfg))
			`uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
    agt_top = i2s_agent_top::type_id::create("agt_top",this);
    sb = i2s_scoreboard::type_id::create("sb",this);
  $display("i2s_env build_phase");
endfunction
    

function void i2s_env :: connect_phase(uvm_phase phase);
  //agt_top.agt.monitor.monitor_port.connect(sb.fifo.analysis_export);
  $display("i2s_env connect_phase");
endfunction
    