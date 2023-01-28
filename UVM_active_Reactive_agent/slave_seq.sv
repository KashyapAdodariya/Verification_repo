class slave_seq_h extends uvm_sequence#(sequence_item_h);; 
  `uvm_object_utils(slave_seq_h)
  sequence_item_h m_req;
  sequence_item_h resp_item;
  bit [31:0]data_r;
  `uvm_declare_p_sequencer(slave_seqr_h)
  
  function new(string name = "slave_seq_h");
    super.new(name);
    `uvm_info(get_type_name(),"slave_seq_h new call",UVM_LOW)
  endfunction: new

  virtual task body(); 
    `uvm_info(get_type_name(),"slave_seq_h body call",UVM_LOW)
    //forever begin 
    p_sequencer.m_request_fifo.get(m_req); // wait for a transaction request (get is blocking)
    m_req.print();
    `uvm_info(get_type_name(),$sformatf("slave_seq_h body print : %0s",m_req.sprint()),UVM_LOW)
    wait(m_req.kind==READ);
    data_r = p_sequencer.slave_mem.read(m_req.addr);
    $display("\n\n\t\t\tdata_r : %0h\n",data_r);
    `uvm_do_with(resp_item,{resp_item.kind == READ;
                            resp_item.data == data_r;})
    // end
  endtask
endclass 
