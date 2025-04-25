


class scb extends uvm_scoreboard;
  
  transaction_item trans[];
  
  `uvm_component_utils(scb)
  
  function new(string name = "scb", uvm_component parent = null);
    super.new(name, parent);
    trans = new[3];
  endfunction: new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `print("SCB: BUILD_PHASE CALLED")
    //for(int i=0;i<3;i++) begin
    //  trans[i] = transaction_item::type_id::create($sformatf("trans[%0d]",i));
    //end
  endfunction: build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `print("SCB: CONNECT_PHASE CALLED")
  endfunction: connect_phase

  virtual function void received_data(transaction_item pkt, int id);
    `print("SCB: RECEIVED_DATA CALLED")
    trans[id] = pkt;
    `print($sformatf("SCB: RECEIVED DATA : trans[%0d].temp = %0h",id, trans[id].temp))
  endfunction: received_data
  
endclass: scb 