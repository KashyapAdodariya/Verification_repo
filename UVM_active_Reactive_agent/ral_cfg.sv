class ral_cfg_h extends uvm_object;
  `uvm_object_utils(ral_cfg_h)
  
  rand bit[7:0] timer;  
  
  function new (string name = "ral_cfg_h");
    super.new(name);  
    `uvm_info(get_type_name(),"ral_cfg new call",UVM_LOW)
  endfunction: new 
  
  function bit [31:0] pack_reg;
    bit [31:0]temp;
    temp = {>>{timer,8'{1'b1}}};
  endfunction:pack_reg
  
endclass: ral_cfg_h