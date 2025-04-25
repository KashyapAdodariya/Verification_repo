
class monitor extends uvm_monitor;
  
  transaction_item trans_item;
  uvm_analysis_port#(transaction_item) analysis_port;
  bit [3:0] a;
  
  `uvm_component_utils(monitor)
  
  function new(string name = "monitor", uvm_component parent);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `print("MONITOR: BUILD CALLED")
    trans_item = transaction_item::type_id::create("trans_item");
  endfunction: build_phase
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `print("MONITOR: RUN_PHASE CALLED")
    trans_item.temp = a;
    analysis_port.write(trans_item);
    `print("MONITOR: SEND A TRANS TO ANALYSIS")
  endtask: run_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `print("MONITOR: CONNECT_PHASE CALLED")
  endfunction: connect_phase
  
endclass: monitor