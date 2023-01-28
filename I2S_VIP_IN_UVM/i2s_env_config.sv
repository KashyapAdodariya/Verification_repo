

// Revision: 3
//-------------------------------------------------------------------------------

//enable disable switch
//typedef enum {ENABLE, DISABLE} en_dis_switch;

class i2s_env_config extends uvm_object;
  `uvm_object_utils(i2s_env_config)

  //declear all control veriable only
  en_dis_switch en_scr = ENABLE;
  en_dis_switch en_sub = DISABLE;
  
  en_dis_switch en_master_agent = ENABLE;
  en_dis_switch en_slave_agent = DISABLE;
  
  extern function new(string name = "i2s_env_config");
    
endclass

  //////////////////////////////////////////////////////// 
	// Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : null  
  // Description        : constrctor
  //////////////////////////////////////////////////////// 

function i2s_env_config :: new(string name = "i2s_env_config");
  super.new(name);
  `uvm_info(get_type_name(),"I2S_ENV_CONFIG NEW",UVM_LOW)
endfunction
