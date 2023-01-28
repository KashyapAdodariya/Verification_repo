class i2s_env_config extends uvm_object;
  `uvm_object_utils(i2s_env_config)

  //declear all control veriable only
    bit en_master_agent = 1;
  bit en_slave_agent = 1;
  bit en_scr = 1;
  int no_of_master_agent = 4;      //required to define master and slave
  int no_of_slave_agent = 1;
  
  extern function new(string name = "i2s_env_config");
endclass

function i2s_env_config :: new(string name = "i2s_env_config");
  super.new(name);
  $display("i2s_env_config run");
endfunction