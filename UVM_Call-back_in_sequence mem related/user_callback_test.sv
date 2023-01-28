//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------

class user_callback_test extends mem_test;
  user_callback callback_1;
  
  `uvm_component_utils(user_callback_test)
  
  function new(string name = "user_callback_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    callback_1 = user_callback::type_id::create("callback_1", this);
  endfunction
  
  function void end_of_elaboration();
    super.end_of_elaboration();
    uvm_callbacks#(mem_sequencer,mem_callback)::add(env.mem_agnt.sequencer,callback_1);
  endfunction : end_of_elaboration
endclass