`include "uvm_macros.svh"
import uvm_pkg::*;

class singleton_comp extends uvm_component;
  static singleton_comp s_comp;
  rand bit [7:0] addr;
  rand bit [7:0] data;
  
  `uvm_component_utils_begin(singleton_comp)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
  `uvm_component_utils_end
  
  function new(string name = "singleton_comp", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  static function singleton_comp create_singleton();
    if(s_comp == null) begin
      `uvm_info("check_create","creating new object as it found null",UVM_LOW)
      s_comp = new();
    end
    else `uvm_error("check_create","object already exist, separate memory will not be allocated.")
    return s_comp;
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask
endclass

class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  singleton_comp sc1, sc2;

  function new(string name = "base_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // create singleton object
    sc1 = singleton_comp::create_singleton();
    assert(sc1.randomize());
    `uvm_info(get_type_name, $sformatf("Printing sc1 = \n%s",sc1.sprint()), UVM_LOW);
    
    // Trying to create another object but it won't be created
    sc2 = singleton_comp::create_singleton();
    `uvm_info(get_type_name, $sformatf("Printing sc2 = \n%s",sc2.sprint()), UVM_LOW);
  endfunction : build_phase
endclass

module event_pool_example;
  initial begin
    run_test("base_test");
  end
endmodule