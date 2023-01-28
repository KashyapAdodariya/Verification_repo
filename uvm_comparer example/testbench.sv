// Code your testbench here
// or browse Examples
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "transaction.sv"

class base_test extends uvm_test;
  transaction tr1, tr2;
  uvm_comparer comp;

  `uvm_component_utils(base_test)
  
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr1 = transaction::type_id::create("tr1", this);
    tr2 = transaction::type_id::create("tr2", this);
    comp = new();
  endfunction
 
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    assert(tr1.randomize());
    assert(tr2.randomize());
    
    comp.verbosity = UVM_LOW;
    comp.sev = UVM_ERROR;
    comp.show_max = 100;
    
    `uvm_info(get_full_name(), "Comparing objects", UVM_LOW)
    comp.compare_object("tr_compare", tr1, tr2);
    tr2.copy(tr1);
    comp.compare_object("tr_compare", tr1, tr2);
    `uvm_info(get_full_name(), $sformatf("Comparing objects: result = %0d", comp.result), UVM_LOW)
    
    comp.compare_field_int("int_compare", 5'h2, 5'h4, 5);
    comp.compare_string("string_compare", "name", "names");
    
    `uvm_info(get_full_name(), $sformatf("Comparing objects: result = %0d", comp.result), UVM_LOW)
    
    comp.compare_field_int("int_compare", 5'h4, 5'h4, 5);
    comp.compare_string("string_compare", "name", "name");
  endtask
endclass

module tb_top;
  initial begin
    run_test("base_test");
  end
endmodule