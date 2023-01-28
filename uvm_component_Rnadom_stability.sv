//read me
//`define opt1 refer to option 1 and run code with randomize(obj)
//`define opt2 refer to option 2 and run code with obj.randomize()


import uvm_pkg::*;
`include "uvm_macros.svh"
//`define opt1
`define opt2

module top1;
  initial
    begin
      run_test();
    end
endmodule

class comp1 extends uvm_component;
  `uvm_component_utils(comp1)
   rand int a;
   function new (string name = "comp1", uvm_component parent);
    super.new(name, parent);
   endfunction
endclass

// ENV
class env extends uvm_component;
  `uvm_component_utils(env)
  rand int c;
  rand int d;
  int b;
  rand comp1 rand_comp1;
  
  function new(string name = "env", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase); 
    `ifdef opt1
      assert(randomize(c));
      `uvm_info("env",$sformatf("c = %0h\t d = %0h",c,d),UVM_LOW)
      rand_comp1 = comp1::type_id::create("rand_copm1",this);
      assert(randomize(rand_comp1));		//1
      `uvm_info("env",$sformatf("rand_comp1.a = %0h",rand_comp1.a),UVM_LOW)
      assert(randomize(d)); 
      `uvm_info("env",$sformatf("c = %0h\t d = %0h",c,d),UVM_LOW)  
    `endif
    `ifdef opt2
      assert(randomize(c));
      `uvm_info("env",$sformatf("c = %0h\t d = %0h",c,d),UVM_LOW)
      rand_comp1 = comp1::type_id::create("rand_copm1",this);
      assert(rand_comp1.randomize());	    //2
      `uvm_info("env",$sformatf("rand_comp1.a = %0h",rand_comp1.a),UVM_LOW)
      assert(randomize(d)); 
      `uvm_info("env",$sformatf("c = %0h\t d = %0h",c,d),UVM_LOW) 
    `endif
  endfunction  
endclass 

// TEST
class test extends uvm_component;
  `uvm_component_utils(test)
  int b;
  env env_h;
  
  function new(string name = "test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    env_h = env::type_id::create("env_h",this);
  endfunction

  virtual function void end_of_elaboration_phase (uvm_phase phase);
    uvm_top.print_topology ();
  endfunction
    
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //Add logic or start sequence if required
    phase.drop_objection(this);    
  endtask
    
endclass

