

// Revision: 3
//-------------------------------------------------------------------------------

class i2s_agent_config extends uvm_env;
  `uvm_component_utils(i2s_agent_config)
  
  //control veriable
  int no_of_master_agent = 1;      //required to define master and slave
  int no_of_slave_agent = 1;
  
  extern function new(string name = "i2s_agent_config", uvm_component parent);

endclass 

  function i2s_agent_config :: new(string name = "i2s_agent_config", uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"I2S_AGENT_CONFIG NEW",UVM_LOW)
  endfunction:new 
