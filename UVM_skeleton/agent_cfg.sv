class agent_cfg_h extends uvm_object;
  `uvm_object_utils(agent_cfg_h)
  
  //veriables with control fields veriable

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  function new(string name = "agent_cfg_h");
    super.new(name);
    `uvm_info(get_type_name(),"agent_cfg_h new call",UVM_LOW)
  endfunction
  
endclass:agent_cfg_h


