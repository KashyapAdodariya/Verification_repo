class coverage_h extends uvm_subscriber#(sequence_item_h);
  `uvm_component_utils(coverage_h)
  
  sequence_item_h seq_item;
  
  covergroup cov_sample(sequence_item_h seq_item);
    option.per_instance = 1;
    coverpoint seq_item.addr{option.auto_bin_max = 4;}
  endgroup: cov_sample
  
  function new(string name = "coverage_h", uvm_component parent);
    super.new(name,parent); 
    `uvm_info(get_type_name(),"coverage_h new and cov_sample new call",UVM_LOW)
    cov_sample = new(this.seq_item);
  endfunction: new
  
  function void write(sequence_item_h seq_item);
    `uvm_info(get_type_name(),"coverage_h write call",UVM_LOW)
    this.seq_item = seq_item;
    //doing sample here or top hierarchy
    //cov_sample.sample();
  endfunction
  
endclass: coverage_h