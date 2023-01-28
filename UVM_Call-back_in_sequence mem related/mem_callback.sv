class mem_callback extends uvm_callback;
   
  `uvm_object_utils(mem_callback)
   
  function new(string name = "mem_callback");
    super.new(name);
  endfunction
   
  virtual task update_pkt(ref mem_seq_item pkt); endtask
endclass