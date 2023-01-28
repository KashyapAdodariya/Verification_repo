
/*Used macro switchs to simulate differernt scenario
+define+without_do -> used for create/randomize/start
+define+with_do    -> used for `uvm_do method
No used of switch  -> used fo create/set_item_context/randomize_start*/

`include "uvm_macros.svh"
import uvm_pkg::*;
typedef enum {CORE_A, CORE_B} core_type;
`include "seq_item.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "agent.sv"
`include "env.sv"
`include "sequence.sv"

//`define without_do

class base_test extends uvm_test;
  env env_o;
  
  virtual_seq v_seq;
 
  `uvm_component_utils(base_test)
  
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_o = env::type_id::create("env_o", this);
  endfunction
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    v_seq = virtual_seq::type_id::create("v_seq");
    v_seq.start(env_o.v_seqr);    
    `uvm_info(get_type_name(),"\n",UVM_LOW)
    `uvm_info(get_type_name(),$sformatf("v_seq.Aseq.a = %0d",v_seq.Aseq.a),UVM_LOW)
    `uvm_info(get_type_name(),$sformatf("v_seq.Bseq.a = %0d",v_seq.Bseq.a),UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

module tb_top;
  initial begin
    run_test("base_test");
  end
endmodule