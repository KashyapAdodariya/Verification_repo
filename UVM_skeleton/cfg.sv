class cfg_h extends uvm_object;
  `uvm_object_utils(cfg_h)
  
  //veriables with control fields veriable

  function new(string name = "cfg_h");
    super.new(name);
    `uvm_info(get_type_name(),"cfg new call",UVM_LOW)
  endfunction
  
endclass:cfg_h


