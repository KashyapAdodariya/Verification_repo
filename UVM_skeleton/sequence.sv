class sequence_h extends uvm_sequence#(sequence_item_h);
  `uvm_object_utils(sequence_h)
  
   sequence_item_h seq;

  function new(string name = "sequence_h");
    super.new(name);
    `uvm_info(get_type_name(),"sequence new call",UVM_LOW)
  endfunction
   
  task body();
    begin
      `uvm_do(seq)
//       seq = sequence_item_h::type_id::create("seq");
//       start_item(seq);
//       assert(seq.randomize());
//       `uvm_info(get_type_name(),"sequence body call",UVM_LOW)
//       finish_item(seq);
    end
  endtask
  
endclass

//----------------------------------------------------------------------------------------------------

class ral_seq_h extends sequence_h;
  `uvm_object_utils(ral_seq_h)

  sequence_item_h seq;
  reg_block_h reg_blk;
  uvm_status_e   status;
  uvm_reg_data_t read_data;

  function new(string name = "ral_seq_h");
    super.new(name);
  endfunction: new

  task body();
    `uvm_info(get_type_name(),"ral_seq_h body task",UVM_LOW)
    reg_blk = reg_block_h::type_id::create("reg_blk");

    if(!(uvm_config_db#(reg_block_h)::get(uvm_root::get()," ","reg_blk",reg_blk)))
      `uvm_fatal(get_type_name(),"Not getting reg_block_h")    

    reg_blk.reg_name.write(status,32'h1234_1234);
    reg_blk.reg_name.read(status, read_data);

  endtask: body

endclass: ral_seq_h

//----------------------------------------------------------------------------------------------------

class sequence_cb_h extends sequence_h;
  `uvm_object_utils(sequence_cb_h)
  
   sequence_item_h seq;
   sequencer_h sequencer_cb; // Provided sequencer hierarchy from base_test before starting the sequence.
  
  function new(string name = "sequence_cb_h");
    super.new(name);
    `uvm_info(get_type_name(),"sequence_cb_h new call",UVM_LOW)
  endfunction
   
  task body();
    begin
      //`uvm_do(seq)
      seq = sequence_item_h::type_id::create("seq");
      start_item(seq);
      assert(seq.randomize());
      `uvm_do_obj_callbacks(sequencer_h,callback_seq_h,sequencer_cb,pre_modified_pkt(seq));
      `uvm_do_obj_callbacks(sequencer_h,callback_seq_h,sequencer_cb,post_modified_pkt(seq));
      `uvm_info(get_type_name(),"sequence body call",UVM_LOW)
      finish_item(seq);
    end
  endtask
  
endclass

//----------------------------------------------------------------------------------------------------

class concurrent_seq_h extends uvm_sequence#(sequence_item_h);
    `uvm_object_utils(concurrent_seq_h)
    sequence_h seq1;
    ral_seq_h seq2;
    sequence_cb_h seq3;
  
    //if need add more veriable and sequence
    function new(string name = "concurrent_seq_h");
        super.new(name);
      `uvm_info(get_type_name(),"concurrent_seq_h new call",UVM_LOW)
    endfunction: new
  
    virtual task body();
        super.body();
      `uvm_info(get_type_name(),"concurrent_seq_h body call",UVM_LOW)
        seq1 = sequence_h::type_id::create("seq1");
        seq2 = ral_seq_h::type_id::create("seq2");
        seq3 = sequence_cb_h::type_id::create("seq3");
      
        fork 
          `uvm_info(get_type_name(), "concurrent_seq_h body LOCK START", UVM_LOW);
            begin: thread_1
              `uvm_do(seq1)
              `uvm_info(get_type_name(), "FOR SEQ1\n", UVM_LOW)
            end: thread_1
            begin: thread_2
              `uvm_do(seq2)
              `uvm_info(get_type_name(), "FOR SEQ2\n", UVM_LOW)
            end: thread_2
            begin: thread_3
                `uvm_do(seq3)
              `uvm_info(get_type_name(), "FOR SEQ3\n", UVM_LOW)
            end: thread_3
        join
    endtask: body
endclass: concurrent_seq_h