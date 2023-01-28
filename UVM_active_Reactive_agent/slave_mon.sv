class slave_mon_h extends uvm_monitor;
  `uvm_component_utils(slave_mon_h)
  
  uvm_analysis_port #(sequence_item_h) m_req_port; // partial

  slave_mem_h slv_mem;
  sequence_item_h seq_item;
  virtual intf_h vif;

  function new(string name = "slave_mon_h", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(),"slave_mon new call",UVM_LOW)
    m_req_port = new("m_req_port", this);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"slave_mon build_phase call",UVM_LOW)
    slv_mem = slave_mem_h::type_id::create("slv_mem",this);
    seq_item = sequence_item_h::type_id::create("seq_item");
    if(!uvm_config_db#(virtual intf_h)::get(this,"","intf_h",vif))
      `uvm_fatal("INTERFACE","can't get interface in driver")
  endfunction: build_phase
  
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(),"slave_mon run_phase call",UVM_LOW)
    super.run_phase(phase);
    fork
      begin:th1
        forever begin
          @(posedge vif.clock);
          wait(vif.r_w==READ) begin
            seq_item.addr <= vif.addr;
            seq_item.kind = READ;
            @(posedge vif.clock);
            $display("Time: %0t",$time);
            `uvm_info(get_type_name(),$sformatf("In slave_mon seq_item display: %0s",seq_item.sprint()),UVM_LOW)
            m_req_port.write(seq_item); 
            //`uvm_info(get_type_name(),$sformatf("In slave_mon  %0s",seq_item.sprint()),UVM_LOW)
          end
        end
      end:th1
      begin:th2
        forever begin
          @(posedge vif.clock);
          wait(vif.r_w==WRITE) begin
            slv_mem.write(vif.addr,vif.wdata);
            @(posedge vif.clock);
          end
        end
      end:th2
    join_any
    disable fork;
  endtask: run_phase
  
endclass:slave_mon_h







