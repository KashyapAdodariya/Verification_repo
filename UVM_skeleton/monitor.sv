
class monitor_h extends uvm_monitor;
  `uvm_component_utils(monitor_h)
   virtual intf_h vif;
   cfg_h cfg;

  `ifdef sb_fifo
   uvm_blocking_put_port#(sequence_item_h) monitor_port;
  `else
  uvm_analysis_port #(sequence_item_h) monitor_port;
  `endif
  
   sequence_item_h seq_item;

  function new(string name = "monitor", uvm_component parent);
	super.new(name,parent);
 	monitor_port = new("monitor_port", this);
    `uvm_info(get_type_name(),"monitor new call",UVM_LOW)
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(cfg_h)::get(this,"","cfg_h",cfg))
  	  `uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
    if(!uvm_config_db#(virtual intf_h)::get(this,"","intf_h",vif))
      `uvm_fatal("INTERFACE","can't get interface in monitor")    
      `uvm_info(get_type_name(),"monitor build_phase call",UVM_LOW)
  endfunction
  
  task run_phase (uvm_phase phase);
     begin
       `ifdef sb_fifo
       monitor_port.put(seq_item)
       `uvm_info(get_type_name(),"monitor run_phase only fifo used",UVM_LOW)
       `else
         monitor_port.write(seq_item);
       `uvm_info(get_type_name(),"monitor run_phase analysis_fifo used",UVM_LOW)
       `endif
       `uvm_info(get_type_name(),"monitor run_phase call",UVM_LOW)
    end
  endtask
  
  function void connect_phase(uvm_phase phase);
    `uvm_info(get_type_name(),"monitor connect_phase call",UVM_LOW)
  endfunction

endclass
    
//-------------------------------------------------------------------------------------------------------------------------------------

class monitor_child_h extends monitor_h;
  `uvm_component_utils(monitor_child_h)
  function new(string name ="monitor_child_h",uvm_component parent);
	super.new(name,parent);
    `uvm_info(get_type_name(),"monitor_child_h new call",UVM_LOW)
  endfunction
endclass

