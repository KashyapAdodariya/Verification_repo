class reg_name_h extends uvm_reg;
  rand uvm_reg_field timer;
  
  `uvm_object_utils(reg_name_h)
  
  function new(string name = "reg_name_h");
    super.new(name,32,build_coverage(UVM_NO_COVERAGE));
    `uvm_info(get_type_name(),"reg_name new call",UVM_LOW)
  endfunction: new
  
  virtual function void build();
    `uvm_info(get_type_name(),"reg_name build call",UVM_LOW)
    timer = uvm_reg_field::type_id::create("timer");
    timer.configure(this, 32, 0, "RW", 0, 'hff, 'h00, 1, 1);    
  endfunction: build
  
endclass: reg_name_h

//-----------------------------------------------------------------------------------------------

class mem_h extends uvm_mem;
  `uvm_object_utils(mem_h)
  
  function new(string name = "mem_h");
    super.new(name, 16, 8, "RW", UVM_NO_COVERAGE);
    `uvm_info(get_type_name(),"mem_h new call",UVM_LOW)
  endfunction
  
endclass: mem_h

//-----------------------------------------------------------------------------------------------

class reg_block_h extends uvm_reg_block;
  rand reg_name_h reg_name;
  rand mem_h mem;
  `ifdef
  	uvm_reg_map reg_map;
  `endif
  
  `uvm_object_utils(reg_block_h)
  
  function new(string name = "reg_block_h");
    super.new(name,UVM_NO_COVERAGE);
    `uvm_info(get_type_name(),"reg_block new call",UVM_LOW)
  endfunction
    
  virtual function void build();
    `uvm_info(get_type_name(),"reg_block build call",UVM_LOW)
    reg_name = reg_name_h::type_id::create("reg_name");
    reg_name.configure(this,null);
    reg_name.build();
    
    `ifdef reg_map
    	reg_map = create_map("reg_map",32'h0000,1,UVM_LITTLE_ENDIAN);
    	reg_map.add_reg(reg_name,'h00,"RW");
        //reg_map.set_auto_predict(en_auto_predict());
    `endif
    
    default_map = create_map("", `UVM_REG_ADDR_WIDTH'h0, 4, UVM_LITTLE_ENDIAN, 1);
    default_map.add_reg(reg_name,'h00,"RW");
  endfunction: build
  
endclass: reg_block_h
