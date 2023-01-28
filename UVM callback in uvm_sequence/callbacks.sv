class seq_cb extends uvm_callback;
  `uvm_object_utils(seq_cb)
  
  function new(string name = "seq_cb");
    super.new(name);
  endfunction
   
  virtual task modify_pkt(ref seq_item req);
  endtask
endclass

class derived_seq_cb extends seq_cb;
  `uvm_object_utils(derived_seq_cb)
  
  function new(string name = "derived_seq_cb");
    super.new(name);
  endfunction
  
  task modify_pkt(ref seq_item req); // callback method implementation
    `uvm_info(get_full_name(),"Inside modify_pkt method: Injecting error in the seq item",UVM_LOW);
    req.pkt = BAD_ERR1;
    req.addr = 16'hFFFF;
    req.print();
  endtask
endclass