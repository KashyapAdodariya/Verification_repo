class base_seq extends uvm_sequence #(seq_item);
  seq_item req;
  sequencer l_seqr; // Provided sequencer hierarchy from base_test before starting the sequence.
  `uvm_object_utils(base_seq)
  
  function new (string name = "base_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "Base seq: Inside Body", UVM_LOW);
    req = seq_item::type_id::create("req");
    wait_for_grant();
    assert(req.randomize());
    `uvm_do_obj_callbacks(sequencer,seq_cb,l_seqr,modify_pkt(req));
    send_request(req);
    wait_for_item_done();
  endtask
endclass

