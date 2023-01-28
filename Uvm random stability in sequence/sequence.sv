class core_A_seq extends uvm_sequence #(seq_item);
  seq_item req;
  rand byte a;
  `uvm_object_utils(core_A_seq)
  
  function new (string name = "core_A_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "core_A_seq: Inside Body", UVM_LOW);
    req = seq_item::type_id::create("req");
    assert(req.randomize());
    req.print();
  endtask
endclass


class core_B_seq extends uvm_sequence #(seq_item);
  seq_item req;
  rand byte a;
  `uvm_object_utils(core_B_seq)
  
  function new (string name = "core_B_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "core_B_seq: Inside Body", UVM_LOW);
    req = seq_item::type_id::create("req");
    assert(req.randomize());
    req.print();
  endtask
endclass

// create a virtual sequence which holds core_A_seq and core_B_seq

class virtual_seq extends uvm_sequence #(seq_item);
  core_A_seq Aseq;
  core_B_seq Bseq;  
  
  core_A_sequencer seqr_A;
  core_B_sequencer seqr_B;
  `uvm_object_utils(virtual_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)
  
  function new (string name = "virtual_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info(get_type_name(), "virtual_seq: Inside Body", UVM_LOW);
    `ifdef without_do
      `uvm_info(get_type_name(),"Run without uvm_do",UVM_LOW)
      Aseq = core_A_seq::type_id::create("Aseq");
      Bseq = core_B_seq::type_id::create("Bseq");
      assert(Aseq.randomize());
      assert(Bseq.randomize());
      Aseq.start(p_sequencer.seqr_A);
      Bseq.start(p_sequencer.seqr_B);
    `elsif with_do
      `uvm_info(get_type_name(),"Run with uvm_do",UVM_LOW)
      `uvm_do(Aseq)
      `uvm_do(Bseq)
    `else 
      `uvm_info(get_type_name(),"Run without uvm_do with set_item_contaxt",UVM_LOW)
      Aseq = core_A_seq::type_id::create("Aseq");
      Bseq = core_B_seq::type_id::create("Bseq");
      Aseq.set_item_context(this,get_sequencer());
      Bseq.set_item_context(this,get_sequencer());
      assert(Aseq.randomize());
      assert(Bseq.randomize());
      Aseq.start(p_sequencer.seqr_A);
      Bseq.start(p_sequencer.seqr_B);
    `endif
  endtask
endclass