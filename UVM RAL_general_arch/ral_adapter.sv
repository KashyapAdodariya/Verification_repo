class ral_adapter extends uvm_reg_adapter;
  `uvm_object_utils(ral_adapter)
  
  function new(string name = "ral_adapter");
    super.new(name);
  endfunction
  
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    seq_item bus_item = seq_item::type_id::create("bus_item");
    bus_item.addr = rw.addr;
    bus_item.data = rw.data;
    bus_item.r_w = (rw.kind==UVM_READ) ? 1 : 0;
    `uvm_info(get_type_name(),$sformatf("addr = %0h\t data = %0h\t read_write = %0s",bus_item.addr,bus_item.data,bus_item.r_w.name()),UVM_LOW)
    return bus_item;
  endfunction: reg2bus
  
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    seq_item seq;
    if(!$cast(seq,bus_item)) `uvm_fatal(get_type_name(),"Casting fail in ral adapter")
    rw.addr = seq.addr;
    rw.data = seq.data;
    rw.kind = (seq.r_w) ? UVM_READ : UVM_WRITE; 
    rw.status = UVM_IS_OK;
  endfunction: bus2reg
  
endclass: ral_adapter