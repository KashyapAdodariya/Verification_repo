class env_cfg_h extends uvm_object;
  `uvm_object_utils(env_cfg_h)

  //declear all control veriable only
  bit scb_en = 1;
  int no_of_agent = 1;      //required to define agent_no and monitor_no
  bit ral_model_on = 1;
  bit cov_en = 1;
  
  function new(string name = "env_config");
    super.new(name);
    `uvm_info(get_type_name(),"env_config new call",UVM_LOW)
  endfunction
  
endclass

