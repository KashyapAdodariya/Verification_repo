//-------------------------------------------------------------------------
//						mem_sequence's - www.verificationguide.com
//-------------------------------------------------------------------------

//=========================================================================
// mem_sequence - random stimulus 
//=========================================================================
class mem_sequence extends uvm_sequence#(mem_seq_item);
  
  `uvm_object_utils(mem_sequence)

  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mem_sequence");
    super.new(name);
  endfunction
  
  `uvm_declare_p_sequencer(mem_sequencer)
  
  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
    req = mem_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    `uvm_do_obj_callbacks(mem_sequencer,mem_callback,p_sequencer,update_pkt(req));
    send_request(req);
    wait_for_item_done();
  endtask
endclass
//=========================================================================