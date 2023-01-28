class i2s_config extends uvm_object;
  `uvm_object_utils(i2s_config)

  virtual i2s_interface vif;
  
  //veriables with control fields veriable

  extern function new(string name = "i2s_config");
  
endclass:i2s_config


function i2s_config :: new(string name = "i2s_config");
  super.new(name);
  $display("i2s_config run");
endfunction