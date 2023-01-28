class ral_config extends uvm_object;
  `uvm_object_utils(ral_config)
  
  rand bit[7:0] timer;
  rand bit[7:0] count;
  rand bit[15:0] timer_counter;  
  
  function new (string name = "ral_config");
    super.new(name);  
  endfunction: new 
  
  function bit [31:0] pack_reg;
    bit [31:0]temp;
    temp = {>>{timer_counter,count,timer}};
  endfunction:pack_reg
  
endclass: ral_config