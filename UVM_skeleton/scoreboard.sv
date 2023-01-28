//`define sb_fifo
class scoreboard_h extends uvm_scoreboard;
  `uvm_component_utils(scoreboard_h)
  
  `ifdef sb_fifo
  uvm_blocking_get_port#(sequence_item_h) fifo;
  `else
  uvm_tlm_analysis_fifo #(sequence_item_h) fifo;
  `endif
  
  cfg_h cfg;
  sequence_item_h seq_item;
  
  function new(string name = "scoreboard" ,uvm_component parent);
	super.new(name,parent);
    fifo=new("fifo",this);
    `uvm_info(get_type_name(),"scb new call",UVM_LOW)
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),"scb report_phase call",UVM_LOW)
  endfunction: report_phase

  task run_phase(uvm_phase phase);
    forever begin
      fifo.get(seq_item); //for analysis_fifo and normal fifo both used direct fifo.get() method only
      `uvm_info(get_type_name(),"scb run_phase call",UVM_LOW)
    end
  endtask
  
endclass 


