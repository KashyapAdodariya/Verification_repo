


class scb extends uvm_scoreboard;
  
  transaction_item trans[$];
  transaction_item_1 trans_1[$];
  
  `uvm_component_utils(scb)
  
  function new(string name = "scb", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //`print("SCB: BUILD_PHASE CALLED")
  endfunction: build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //`print("SCB: CONNECT_PHASE CALLED")
  endfunction: connect_phase

  virtual function void received_data(uvm_sequence_item pkt, int id);
    `print($sformatf("SCB: RECEIVED_DATA CALLED: ID=%0d",id))
    case(pkt.get_type_name())
      "transaction_item"   : begin
        transaction_item temp_trans;
        if (!$cast(temp_trans, pkt)) begin
          `uvm_fatal(get_type_name(), "SCB: CASTING IS FAIL FOR trans_item")
      	end
        `print($sformatf("SCB: RECIVED DATA FROM TRANS: %0h",temp_trans.temp))
        trans.push_back(temp_trans);
      end
      "transaction_item_1" : begin
        transaction_item_1 temp_trans_1;
        if (!$cast(temp_trans_1, pkt)) begin
          `uvm_fatal(get_type_name(), "SCB: CASTING IS FAIL FOR trans_item_1")
      	end
        `print($sformatf("SCB: RECIVED DATA FROM TRANS1: %0h",temp_trans_1.temp))
        trans_1.push_back(temp_trans_1);
      end
        default : `uvm_fatal(get_type_name(),"SCB: TRANSACTION TYPE NOT MATCH !!")
    endcase
    
  endfunction: received_data
  
endclass: scb 