class i2s_agent extends uvm_agent;
  `uvm_component_utils(i2s_agent)
  //declear config, driver, sequencer, monitor
  i2s_driver drv;
  i2s_config cfg;
  i2s_monitor monitor;
  i2s_sequencer seqr;

  	extern function new(string name = "i2s_agent", uvm_component parent = null);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass:i2s_agent

function i2s_agent::new(string name = "i2s_agent", uvm_component parent = null);
  super.new(name, parent);
  $display("i2s_agent run");
endfunction

function void i2s_agent :: build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db #(i2s_config)::get(this,"","i2s_config",cfg))
			`uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
    monitor = i2s_monitor::type_id::create("monitor",this);

    //write condition for active and passive
    drv = i2s_driver::type_id::create("drv",this);
    seqr = i2s_sequencer::type_id::create("seqr",this);
    $display("i2s_agent build phase");
endfunction

function void i2s_agent::connect_phase(uvm_phase phase);
  //write active passive condition
  drv.seq_item_port.connect(seqr.seq_item_export);
  $display("i2s_agent connect_phase");
endfunction:connect_phase