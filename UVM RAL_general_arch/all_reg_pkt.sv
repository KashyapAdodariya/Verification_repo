typedef enum {AUTO,EXPLICIT,PASSIVE} en_predictor;

class timer_counter_reg extends uvm_reg;
  rand uvm_reg_field timer;
  rand uvm_reg_field counter;
  rand uvm_reg_field timer_counter;
  
  `uvm_object_utils(timer_counter_reg)
  
  function new(string name = "timer_counter_reg");
    super.new(name,32,build_coverage(UVM_NO_COVERAGE));
  endfunction: new
  
  virtual function void build();
    timer = uvm_reg_field::type_id::create("timer");
     timer.configure(this, 8, 0, "RW", 0, 'hff, 'h00, 1, 1);
    counter = uvm_reg_field::type_id::create("counter");
    counter.configure(this, 8, 8, "RW", 0, 'hff, 'h00, 1, 1);
    timer_counter = uvm_reg_field::type_id::create("timer_counter");  
    timer_counter.configure(this, 16, 16, "RW", 0, 'h0000, 'hffff, 1, 1);    
  endfunction: build
endclass: timer_counter_reg

//----------------------------------------------------------------------------------------------------------

class ral_intr_sts_reg extends uvm_reg;
  rand uvm_reg_field rsvd;
  rand uvm_reg_field r_axi_err;
  rand uvm_reg_field w_axi_err;
  
  `uvm_object_utils(ral_intr_sts_reg)
  function new(string name = "ral_intr_sts_reg");
    super.new(name, 32, build_coverage(UVM_NO_COVERAGE));
  endfunction
  
  virtual function void build();
    rsvd = uvm_reg_field::type_id::create("rsvd");
    r_axi_err = uvm_reg_field::type_id::create("r_axi_err");
    w_axi_err = uvm_reg_field::type_id::create("w_axi_err");
    
    rsvd.configure        (this, 30, 2, "RO", 0, 1'b0, 1, 1, 0);
    r_axi_err.configure   (this,  1, 1, "W1C", 0, 1'b0, 1, 1, 0);
    w_axi_err.configure   (this,  1, 0, "W1C", 0, 1'b0, 1, 1, 0);
  endfunction
endclass

//----------------------------------------------------------------------------------------------------------

class mem extends uvm_mem;
  `uvm_object_utils(mem)
  
  function new(string name = "mem");
    super.new(name, 16, 8, "RW", UVM_NO_COVERAGE);
  endfunction
  
endclass: mem

//----------------------------------------------------------------------------------------------------------

class reg_block extends uvm_reg_block;
  rand ral_intr_sts_reg sts_reg;
  rand timer_counter_reg tm_cont_reg;
  rand mem mem_h;
  en_predictor en_predictor_type;
  `ifdef
  	uvm_reg_map reg_map;
  `endif
  
  `uvm_object_utils(reg_block)
  
  function new(string name = "reg_block");
    super.new(name,UVM_NO_COVERAGE);
  endfunction
  
//   virtual function int en_auto_predict();
//     case(en_predictor_type)
//       AUTO : return 1;
//       EXPLICIT : return 0; 
//       PASSIVE: return 2;
//       //default: `uvm_error(get_type_name(),"Unknow enum value set");
//   endfunction
  
  virtual function void build();
    tm_cont_reg = timer_counter_reg::type_id::create("tm_cont_reg");
    tm_cont_reg.configure(this,null);
    tm_cont_reg.build();
    
    sts_reg = ral_intr_sts_reg::type_id::create("sts_reg");
    sts_reg.configure(this, null);
    sts_reg.build();
    
    `ifdef reg_map
    	reg_map = create_map("reg_map",32'h0000,1,UVM_LITTLE_ENDIAN);
    	reg_map.add_reg(tm_cont_reg,'h00,"RW");
    	reg_map.add_reg(sts_reg,'h4,"RW");
        //reg_map.set_auto_predict(en_auto_predict());
    `endif
    
    default_map = create_map("", `UVM_REG_ADDR_WIDTH'h0, 4, UVM_LITTLE_ENDIAN, 1);
    default_map.add_reg(tm_cont_reg,'h00,"RW");
    default_map.add_reg(sts_reg,'h4,"RW");
  endfunction: build
endclass: reg_block


