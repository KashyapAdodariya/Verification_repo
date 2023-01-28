class sys_env extends uvm_env;
  `uvm_component_utils(sys_env)
  
  ral_env ral_env_h;
  agent agent_h;
  
  function new(string name = "sys_env", uvm_component parent);
    super.new(name,parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent_h = agent::type_id::create("agent_h",this);
    ral_env_h = ral_env::type_id::create("ral_env_h",this);
  endfunction: build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
   // if(ral_env.reg_blk.en_predictor_type inside {EXPLICIT, PASSIVE}) begin
    ral_env_h.ral_predictor.map = ral_env_h.reg_blk.default_map;
    ral_env_h.ral_predictor.adapter = ral_env_h.adapter;
   // end
    agent_h.mon.item_collect_port.connect(ral_env_h.ral_predictor.bus_in);
    ral_env_h.reg_blk.default_map.set_sequencer(.sequencer(agent_h.seqr_h),.adapter(ral_env_h.adapter));
  endfunction: connect_phase
  
endclass: sys_env