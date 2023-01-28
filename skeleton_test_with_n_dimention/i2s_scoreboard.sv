class i2s_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(i2s_scoreboard)
  uvm_tlm_analysis_fifo #(i2s_sequence_item) fifo;
  //int temp = 1;
  i2s_config cfg;
  
  i2s_sequence_item test;
  
  extern function new(string name = "i2s_scoreboard",uvm_component parent);
	extern task run_phase(uvm_phase phase);
 
endclass 


function i2s_scoreboard::new(string name = "i2s_scoreboard" ,uvm_component parent);
	super.new(name,parent);
  fifo=new("fifo",this);
  $display("i2s_scr run");
endfunction

task i2s_scoreboard :: run_phase(uvm_phase phase);
  forever begin
    fifo.get(test);
    $display("i2s_scr run_phase");
  end
endtask