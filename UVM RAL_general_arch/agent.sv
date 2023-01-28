class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  driver drv;
  monitor mon;
  seqr seqr_h;
  
  function new(string name = "agent", uvm_component parent);
    super.new(name,parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(get_is_active == UVM_ACTIVE) begin
      drv = driver::type_id::create("drv",this);
      seqr_h = seqr::type_id::create("seqr_h",this);
    end
    mon = monitor::type_id::create("mon",this);
  endfunction: build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr_h.seq_item_export);
  endfunction: connect_phase
endclass: agent