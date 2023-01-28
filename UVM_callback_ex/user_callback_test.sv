//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------

//------------------------------------------------
//	Class - user_callback_test
//------------------------------------------------

class user_callback_test extends basic_test;
  user_callback_1 callback_1;
  user_callback_2 callback_2;
  
  `uvm_component_utils(user_callback_test)
  
  function new(string name = "user_callback_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    callback_1 = user_callback_1::type_id::create("callback_1", this);
    callback_2 = user_callback_2::type_id::create("callback_2", this);
    
    uvm_callbacks#(driver,driver_callback)::add(env.driv,callback_1);
    uvm_callbacks#(driver,driver_callback)::add(env.driv,callback_2);
  endfunction
endclass

//------------------------------------------------
//	Class - user_callback_2_test
//------------------------------------------------

class user_callback_2_test extends basic_test;
  user_callback_1 callback_1;
  user_callback_2 callback_2;
  
  `uvm_component_utils(user_callback_2_test)
  
  function new(string name = "user_callback_2_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    callback_1 = user_callback_1::type_id::create("callback_1", this);
    callback_2 = user_callback_2::type_id::create("callback_2", this);
    
    uvm_callbacks#(driver,driver_callback)::add(env.driv,callback_2);
    uvm_callbacks#(driver,driver_callback)::add(env.driv,callback_1);
  endfunction
endclass