class ral_adapter_h extends uvm_reg_adapter;
  `uvm_object_utils(ral_adapter_h)
  
  function new(string name = "ral_adapter_h");
    super.new(name);
    `uvm_info(get_type_name(),"ral_adapter new call",UVM_LOW)
  endfunction
  
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    sequence_item_h bus_item = sequence_item_h::type_id::create("bus_item");
    bus_item.addr = rw.addr;
    bus_item.data[0] = rw.data;
    bus_item.kind = (rw.kind==UVM_READ) ? 1 : 0;
    `uvm_info(get_type_name(),"ral_adapter reg2bus call",UVM_LOW)
    `uvm_info(get_type_name(),$sformatf("addr = %0h\t data = %0h\t read_write = %0d",bus_item.addr,bus_item.data[0],bus_item.kind),UVM_LOW)
    return bus_item;
  endfunction: reg2bus
  
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
//     sequence_item_h seq;
     `uvm_info(get_type_name(),"ral_adapter bus2reg call",UVM_LOW)
//     if(!$cast(seq,bus_item)) `uvm_fatal(get_type_name(),"Casting fail in ral adapter")
//     rw.addr = seq.addr;
//     rw.data = seq.data[0];
//     rw.kind = (seq.r_w) ? UVM_READ : UVM_WRITE; 
//     rw.status = UVM_IS_OK;
  endfunction: bus2reg
  
endclass: ral_adapter_h