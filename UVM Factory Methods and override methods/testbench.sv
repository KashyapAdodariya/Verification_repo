`include "uvm_macros.svh"
import uvm_pkg::*;

class base_cfg extends uvm_object;
  `uvm_object_utils(base_cfg)
  function new(string name = "base_cfg");
    super.new(name);
    `uvm_info(get_full_name, $sformatf("BASE CFG new"), UVM_LOW);
  endfunction
  
    virtual function hello();
    `uvm_info(get_full_name, $sformatf("HELLO from Original class 'base_cfg'"), UVM_LOW);
  endfunction : hello
  
endclass

//class child_cfg extends uvm_object;       //If extends from uvm_object then only INST_BY_TYPE and          											   INST_BY_NAME method will work.
class child_cfg extends base_cfg;           //If extends from the base class (which is extended from 												  uvm_object) then all four method should work.
  `uvm_object_utils(child_cfg)
  function new(string name = "child_cfg");
    super.new(name);
    `uvm_info(get_full_name, $sformatf("CHILD CFG new"), UVM_LOW);
  endfunction
 
  virtual function hello();
    `uvm_info(get_full_name, $sformatf("HELLO from Override class 'child_cfg'"), UVM_LOW);
  endfunction : hello
  
endclass

class base_env extends uvm_env;
  `uvm_component_utils(base_env)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  base_cfg m_cfg;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_cfg = base_cfg::type_id::create("m_cfg");
    
    m_cfg.hello();
    
    `uvm_info("CONFIG", $sformatf("Factory returned cfg of type=%s, path=%s", m_cfg.get_type_name(), m_cfg.get_full_name()), UVM_LOW)
   
  endfunction
 
endclass


class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  base_env m_env;
  
  virtual function void build_phase(uvm_phase phase);
    uvm_factory factory = uvm_factory::get();
    super.build_phase(phase);

`ifdef TYPE_BY_TYPE   
    // 1. Override all types by a given type
    set_type_override_by_type(base_cfg::get_type(), child_cfg::get_type());
    
`elsif INST_BY_TYPE
    // 2. Override a particular instance by its type
    //set_inst_override_by_type("m_env.*", base_cfg::get_type(), child_cfg::get_type());
    factory.set_inst_override_by_type(base_cfg::get_type(), child_cfg::get_type(),"m_env.*");

`elsif TYPE_BY_NAME    
    // 3. Override the type by the items name
    factory.set_type_override_by_name("base_cfg", "child_cfg");

`elsif INST_BY_NAME    
    // 4. Override a particular instance by its name
    //set_inst_override_by_name({get_full_name(), ".m_env.*"},"base_cfg", "child_cfg");
    factory.set_inst_override_by_name("base_cfg", "child_cfg", {get_full_name(), ".m_env.*"});

`else 
    `uvm_error(get_full_name, "Please add any define from TYPE_BY_TYPE / INST_BY_TYPE / TYPE_BY_NAME / INST_BY_NAME in compile Option");
    
`endif
    
//    set_type_override("base_agent", "child_agent");
//    set_inst_override("m_env.m_agent", "base_agent", "child_agent");
    factory.print();
    
    m_env = base_env::type_id::create("m_env", this);
   
  endfunction
  
endclass


module tb;
  initial 
    run_test("base_test");
endmodule