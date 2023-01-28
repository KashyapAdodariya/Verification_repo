class monitor extends uvm_monitor;
  virtual intf vif;
  uvm_analysis_port #(seq_item) item_collect_port;
  seq_item mon_item;
  `uvm_component_utils(monitor)
  
  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    item_collect_port = new("item_collect_port", this);
    mon_item = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual intf) :: get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Not set at top level");
  endfunction
  
  task run_phase (uvm_phase phase);
    forever begin
      wait(!vif.reset_n);
      @(posedge vif.clk);
      `uvm_info(get_type_name(),"Monitor running",UVM_LOW)
      void'(mon_item.randomize());
      item_collect_port.write(mon_item);
    end
    
  endtask
endclass