

class scb_wrapper extends uvm_scoreboard;
  
  scb_subscriber subscr[3];
  scb_subscriber_1 subscr_1[3];
  scb scb_i;
  
  `uvm_component_utils(scb_wrapper)
  
  function new(string name = "scb_wrapper", uvm_component parent = null);
    super.new(name,parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `print("SCB_WRAPPER: BUILD_PHASE CALLED")
    scb_i = scb::type_id::create("scb_i", this);
    for(int i=0;i<3;i++) begin
      subscr[i] = scb_subscriber::type_id::create($sformatf("subscr[%0d]",i), this);
      subscr[i].set_id_n_scb(i, scb_i);
    end
    for(int i=0;i<3;i++) begin
      subscr_1[i] = scb_subscriber_1::type_id::create($sformatf("subscr_1[%0d]",i), this);
      subscr_1[i].set_id_n_scb('hF - i, scb_i);
    end
  endfunction: build_phase
  
endclass: scb_wrapper