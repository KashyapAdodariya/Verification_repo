class slave_agt_h extends uvm_agent;
  `uvm_component_utils(slave_agt_h)
  
  slave_drv_h slave_drv;
  slave_mon_h slave_mon;
  slave_seqr_h slave_seqr;
  slave_seq_h slave_seq;
  
  function new(string name = "slave_agt_h", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(),"slave_agt_h new call",UVM_LOW)
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"slave_agt_h build_phase call",UVM_LOW)
    slave_drv = slave_drv_h::type_id::create("slave_drv",this);
    slave_mon = slave_mon_h::type_id::create("slave_mon",this);
    slave_seqr = slave_seqr_h::type_id::create("slave_seqr",this);
  endfunction: build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(),"slave_agt_h connect_phase call",UVM_LOW)
    slave_mon.m_req_port.connect(slave_seqr.m_request_fifo.analysis_export);
    slave_drv.seq_item_port.connect(slave_seqr.seq_item_export);
  endfunction
  
endclass:slave_agt_h
