//-------------------------------------------------------------------------
//						mem_test - www.verificationguide.com 
//-------------------------------------------------------------------------

`include "mem_env.sv"
class mem_model_base_test extends uvm_test;

  `uvm_component_utils(mem_model_base_test)
  
  //---------------------------------------
  // env instance 
  //--------------------------------------- 
  mem_model_env env;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "mem_model_base_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the env
    env = mem_model_env::type_id::create("env", this);
  endfunction : build_phase
  
  //---------------------------------------
  // end_of_elobaration phase
  //---------------------------------------  
  virtual function void end_of_elaboration();
    //print's the topology
    print();
  endfunction
endclass : mem_model_base_test