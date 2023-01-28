//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------

class user_callback extends mem_callback;
  
  `uvm_object_utils(user_callback)
  
  function new(string name = "user_callback");
    super.new(name);
  endfunction
  
  task update_pkt(ref mem_seq_item pkt);
    `uvm_info("USER_CALLBACK","[update_pkt] before packet modification",UVM_LOW);
    pkt.print();
    pkt.addr = ~pkt.addr;
    `uvm_info("USER_CALLBACK","[update_pkt] after packet modification",UVM_LOW);
    pkt.print();
  endtask
endclass