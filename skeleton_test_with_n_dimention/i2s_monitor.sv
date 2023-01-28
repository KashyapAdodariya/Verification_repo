class i2s_monitor extends uvm_monitor;
  `uvm_component_utils(i2s_monitor)
int temp = 1;
   virtual i2s_interface vif;
   i2s_config cfg;
   uvm_analysis_port #(i2s_sequence_item) monitor_port;
   //declear veriable
  i2s_sequence_item test;

  extern function new(string name = "i2s_monitor", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass

function i2s_monitor::new(string name = "i2s_monitor", uvm_component parent);
	super.new(name,parent);
		// create object for handle monitor_port using new
 	monitor_port = new("monitor_port", this);
  $display("i2s_monitor run");
endfunction

function void i2s_monitor::build_phase(uvm_phase phase);
  
	// call super.build_phase(phase);
  super.build_phase(phase);
  if(!uvm_config_db #(i2s_config)::get(this,"","i2s_config",cfg))
		`uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
  $display("i2s_monitor build_phase");
endfunction

task i2s_monitor :: run_phase (uvm_phase phase);
   begin
    monitor_port.write(test);
    $display("i2s_monitor run_phase");
  end
endtask

function void i2s_monitor :: connect_phase(uvm_phase phase);
  vif = cfg.vif;
  $display("i2s_monitor connect_phase");
endfunction