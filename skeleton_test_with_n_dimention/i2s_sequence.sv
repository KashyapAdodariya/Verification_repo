class i2s_sequence extends uvm_sequence#(i2s_sequence_item);
   
  `uvm_object_utils(i2s_sequence)
   i2s_sequence_item seq;
  //function definetion
  extern task body();

  //Constructor
  function new(string name = "i2s_sequence");
    super.new(name);
  endfunction
   
endclass


task i2s_sequence :: body();
  begin
    seq = i2s_sequence_item::type_id::create("seq");
    start_item(seq);
    assert(seq.randomize());
    $display("body of sequence");
    //randomization
    finish_item(seq);
  end
endtask