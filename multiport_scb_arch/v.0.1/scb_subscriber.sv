

class scb_subscriber extends uvm_subscriber #(transaction_item);
  
  int id;
  scb scb_i;				//Only referance not created version
  transaction_item pkt;
  
  `uvm_component_utils(scb_subscriber)
  
  function new(string name = "scb_subscriber", uvm_component parent = null);
    super.new(name, parent);
    `print("SCB_SUB: BUILD_PHASE CALLED")
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `print("SCB_SUB: BUILD_PHASE CALLED")
    pkt = transaction_item::type_id::create("pkt");
  endfunction: build_phase
  
  virtual function void write (transaction_item t);
    `print("SCB_SUB: WRITE METHOD CALLED")
    `print($sformatf("SCB_SUB: DATA PRINT t.temp = %0h",t.temp))
    pkt = t;
    send_data();
  endfunction
  
  virtual function void set_id_n_scb(int id, scb scb_i);
    `print("SCB_SUB: SET_ID_N_SCB CALLED")
    this.id = id;
    this.scb_i = scb_i;
  endfunction: get_id
  
  function void send_data();
    `print("SCB_SUB: SEND_DATA called")
    scb_i.received_data(pkt, this.id);
  endfunction: send_data
  
endclass