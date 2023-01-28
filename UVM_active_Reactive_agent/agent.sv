`define use_virtual_seqr

class agent_h extends uvm_agent;
  `uvm_component_utils(agent_h)
  //declear config, driver, sequencer, monitor
  agent_cfg_h agt_cfg;
  driver_h drv;
  cfg_h cfg;
  monitor_h monitor;
  
 // `ifdef use_virtual_seqr
 // virtual_seqr_h virtual_seqr;
  //`else
  sequencer_h seqr;
  //`endif
  
  function new(string name = "agent_h", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(),"agent new call",UVM_LOW)
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"agent build_phase call",UVM_LOW)
    agt_cfg = agent_cfg_h::type_id::create("agt_cfg");
    if(!uvm_config_db #(cfg_h)::get(this,"","cfg_h",cfg))
  	  `uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
    monitor = monitor_h::type_id::create("monitor",this);
    if(agt_cfg.is_active==UVM_ACTIVE) begin
      drv = driver_h::type_id::create("drv",this);
     // `ifdef use_virtual_seqr
      //virtual_seqr = virtual_seqr_h::type_id::create("virtual_seqr",this);
      //`else
      seqr = sequencer_h::type_id::create("seqr",this);
      //`endif
    end
  endfunction
  
  function void connect_phase(uvm_phase phase);
    //write active passive condition
    `uvm_info(get_type_name(),"agent connect_phase call",UVM_LOW)
    if(agt_cfg.is_active==UVM_ACTIVE) begin
     // `ifdef use_virtual_seqr
      //drv.seq_item_port.connect(virtual_seqr.seqr.seq_item_export);   //if want change hireachy accoding to used of seqr. or write child class for it.
      //`else
      drv.seq_item_port.connect(seqr.seq_item_export);
      //`endif
    end
  endfunction:connect_phase

endclass:agent_h

