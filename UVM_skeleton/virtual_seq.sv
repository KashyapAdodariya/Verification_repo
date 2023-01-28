//`define use_p_seqr
class virtual_seq_h extends uvm_sequence#(sequence_item_h);
  
  sequence_h     seq;			//not used as of now treated as based seq.
  ral_seq_h      ral_seq;
  sequence_cb_h  seq_cb;
  concurrent_seq_h con_seq;
  
  sequencer_h    seqr;
  env_h env;
  
  `uvm_object_utils(virtual_seq_h)
  `ifdef use_p_seqr
  `uvm_declare_p_sequencer(virtual_seqr_h)
  `endif
  
  function new(string name = "virtual_seq_h");
    super.new(name);
    `uvm_info(get_type_name(),"virtual_seq new call",UVM_LOW)
  endfunction
  
  task body();
    `uvm_info(get_type_name(),"virtual_seq body call",UVM_LOW)
    ral_seq = ral_seq_h::type_id::create("ral_seq");
    seq_cb = sequence_cb_h::type_id::create("seq_cb");
    con_seq = concurrent_seq_h::type_id::create("con_seq");
    
    `ifdef use_p_seqr
    ral_seq.start(p_sequencer.seqr);
    seq_cb.start(p_sequencer.seqr);
    con_seq.start(p_sequencer.seqr);
    `else
    if(!$cast(env, uvm_top.find("uvm_test_top.env"))) `uvm_fatal(get_type_name(), "env is not found in virtual seq");
    ral_seq.start(env.virtual_seqr.seqr);
    seq_cb.start(env.virtual_seqr.seqr);
    con_seq.start(env.virtual_seqr.seqr);
    `endif
    
  endtask
  
endclass: virtual_seq_h