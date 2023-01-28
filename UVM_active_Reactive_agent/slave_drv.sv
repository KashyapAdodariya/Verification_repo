class slave_drv_h extends uvm_driver#(sequence_item_h);
  `uvm_component_utils(slave_drv_h)
  
  virtual intf_h vif; 
  sequence_item_h seq_item;
  
  function new(string name = "slave_drv_h", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(),"slave_drv_h new call",UVM_LOW)
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"slave_drv_h build_phase call",UVM_LOW)
    if(!uvm_config_db#(virtual intf_h)::get(this,"","intf_h",vif))
      `uvm_fatal("INTERFACE","can't get interface in driver")
  endfunction
      
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(),"slave_drv_h run_phase call",UVM_LOW)
    forever begin
      seq_item_port.get_next_item(seq_item);
      drive();
      seq_item_port.item_done();
    end
  endtask
    
    task drive();
      `uvm_info(get_type_name(),$sformatf("In slave_driver seq_item display: %0s",seq_item.sprint()),UVM_LOW)
      @(posedge vif.clock);
      vif.addr <= seq_item.addr;
      if(seq_item.kind==READ) begin 
        vif.rdata <= seq_item.data; 
        vif.r_w <= 0;
        vif.wdata <= 'hz;
        @(posedge vif.clock);
      end
      else begin
        vif.rdata <='hz;
      end
  endtask: drive
  
endclass:slave_drv_h
