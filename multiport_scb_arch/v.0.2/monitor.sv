
class monitor extends uvm_monitor;
  
  transaction_item trans_item;
  transaction_item_1 trans_item_1;
  uvm_analysis_port#(transaction_item) analysis_port;
  uvm_analysis_port#(transaction_item_1) analysis_port_1;
  bit [3:0] a,b;
  
  `uvm_component_utils(monitor)
  
  function new(string name = "monitor", uvm_component parent);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
    analysis_port_1 = new("analysis_port_1", this);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //`print("MONITOR: BUILD CALLED")
    trans_item = transaction_item::type_id::create("trans_item");
    trans_item_1 = transaction_item_1::type_id::create("trans_item_1");
  endfunction: build_phase
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    //`print("MONITOR: RUN_PHASE CALLED")
    trans_item.temp = $urandom;;
    `print($sformatf("MON: TRANS: %0h",trans_item.temp))
    #11ns;
    trans_item_1.temp = $urandom;
    `print($sformatf("MON: TRANS_1: %0h",trans_item_1.temp))
    analysis_port.write(trans_item);
    analysis_port_1.write(trans_item_1);
    `print("MONITOR: SEND A TRANS TO ANALYSIS")
    phase.drop_objection(this);
  endtask: run_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //`print("MONITOR: CONNECT_PHASE CALLED")
  endfunction: connect_phase
  
endclass: monitor