// Code your testbench here
// or browse Examples


package simpleTBagent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum {IDLE,
                WRITE,
                READ} cmd_t;

  typedef enum {AUTO,
                EXPLICIT,
                PASSIVE} ral_prediction_t;


class simpleTBitem extends uvm_sequence_item;
  
  rand cmd_t     cmd_e;
  rand bit [7:0] data;
  rand bit [7:0] addr;
  rand bit [5:0] idle_clk_cnt;
  
       bit [7:0] rd_data;
  
  `uvm_object_utils(simpleTBitem)
  
  function new(string name = "simpleTBitem");
    super.new(name);
  endfunction
  
  // Constraints
  
  // Constrain command so that IDLE is less likely to happen
  constraint idle_is_least_to_happen {
    cmd_e dist {IDLE := 1, WRITE := 3, READ := 3}; 
  }
  
  // idle_clk_cnt is 0 if cmd is not IDLE
  // idle_clk_cnt should not be 0 if cmd is IDLE
  constraint idle_clk_cnt_is_for_IDLE {
    (cmd_e != IDLE) -> (idle_clk_cnt == 0);
    (cmd_e == IDLE) -> (idle_clk_cnt != 0);
  }
  
  // Solve cmd before idle_clk_cnt
  constraint solve_cmd_b4_idle_clk_cnt {
    solve cmd_e before idle_clk_cnt; 
  }
  
  constraint addr_range_is_16 {
    addr inside {[0:15]}; 
  }
  
  virtual function string convert2string();
    string s;
    
    s = super.convert2string();
    
    s = $sformatf("%0s\n",s);
    s = $sformatf("%0s ============================\n",s);
    s = $sformatf("%0s   seq_id       = %0d\n",s, get_sequence_id());    
    s = $sformatf("%0s   cmd          = %0s\n",s, cmd_e.name());
    s = $sformatf("%0s   addr         = %2h h\n",s, addr);
    s = $sformatf("%0s   data         = %2h h\n",s, data);
    s = $sformatf("%0s   idle_clk_cnt = %0d\n",s, idle_clk_cnt);
    s = $sformatf("%0s   rd_data      = %2h h\n",s, rd_data);
    s = $sformatf("%0s ============================\n",s);
    
    return s;
  endfunction : convert2string
  
  virtual function void do_copy(uvm_object rhs);
    simpleTBitem rhs_new;
    
    if(!$cast(rhs_new, rhs)) begin
      `uvm_fatal(get_type_name(), "Failed to cast rhs to rhs_new")
    end
    
    super.do_copy(rhs);
    
    set_id_info(rhs_new);
    cmd_e        = rhs_new.cmd_e;
    addr         = rhs_new.addr;
    data         = rhs_new.data;
    idle_clk_cnt = rhs_new.idle_clk_cnt;
    rd_data      = rhs_new.rd_data;
  endfunction : do_copy
  
endclass : simpleTBitem
//////////////////////////////////////////////////////////////////////////////////

class simpleTBagent_config extends uvm_object;
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  // Put the interface handle
  virtual simpleTBinterface vintf;
  
  `uvm_object_utils(simpleTBagent_config)
  
  function new(string name = "simpleTBagent_config");
    super.new(name);
  endfunction
endclass : simpleTBagent_config
////////////////////////////////////////////////////////////////////////////////////////////

class simpleTBdriver extends uvm_driver#(simpleTBitem);
  virtual simpleTBinterface vintf;
  
  simpleTBitem tr;
  simpleTBitem rsp_b4pass2sqr;
  
  `uvm_component_utils(simpleTBdriver)
  
  function new(string name = "simpleTBdriver", uvm_component parent = null);
    super.new(name, parent);  
  endfunction
  
  virtual function void send_item_done();
    rsp = simpleTBitem::type_id::create("rsp");
            
    rsp.cmd_e        = !vintf.req   ? IDLE :
                       vintf.wr1rd0 ? WRITE : READ;
    rsp.addr         = vintf.addr;
    rsp.data         = vintf.data;
    rsp.idle_clk_cnt = tr.idle_clk_cnt;
    rsp.rd_data      = vintf.rd_data;
            
    // Set the sequence ID of rsp the same with that of req
    rsp.set_id_info(tr);
            
    // Make a deep copy before passing to response handler.
    $cast(rsp_b4pass2sqr, rsp.clone());
            
    `uvm_info(get_type_name(), $sformatf("Response Item: %0s", rsp_b4pass2sqr.convert2string()), UVM_LOW)
          
    seq_item_port.item_done(rsp_b4pass2sqr);
  endfunction : send_item_done
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      // Get seq item only if driver is about to drive it
      @(posedge vintf.clk);

      if(vintf.resetb) begin
        if((vintf.req === 1) && vintf.ack === 1) begin
          send_item_done();
        end
        
        if(!((vintf.req === 1) && (vintf.ack !== 1))) begin
          seq_item_port.try_next_item(req);
          
          if(req != null) begin
            // Clone the req to txn so that if req is modified here, then the changes
            // will not be reflected to the initiating sequence.
            //
            // clone() will create and return a new object and implements do_copy().
            // $cast() is there to check if the object type of req and tr are the same.
            if(!$cast(tr, req.clone())) begin
              `uvm_fatal(get_type_name(), "Failed to clone sequence item")
            end
          
            `uvm_info(get_type_name(), $sformatf("Transaction Item: %0s", tr.convert2string()), UVM_LOW)
          end
          else begin
            tr = null;
          end
        end
        
        if(tr != null) begin
          vintf.req    <= tr.cmd_e != IDLE;
          vintf.wr1rd0 <= tr.cmd_e == WRITE ? 1 :
                          tr.cmd_e == READ  ? 0 : vintf.wr1rd0;
          vintf.addr   <= tr.addr;
          vintf.data   <= tr.data;
          
          if(tr.cmd_e == IDLE) begin
            repeat(tr.idle_clk_cnt) @(posedge vintf.clk);
            send_item_done();
          end
        end
        else begin
          vintf.req    <= 0;
        end
      end
      else begin
        //reset_state();
      end
    end // end of forever loop
  endtask : run_phase
endclass : simpleTBdriver
////////////////////////////////////////////////////////////////////////////////////////////

class simpleTBmonitor extends uvm_monitor;
  simpleTBitem tr;
  uvm_analysis_port#(simpleTBitem) mon_ap;
  
  virtual simpleTBinterface vintf;
  
  `uvm_component_utils(simpleTBmonitor)
  
  function new(string name = "simpleTBmonitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    mon_ap = new("mon_ap", this);
  endfunction : build_phase
  
  virtual task run_phase(uvm_phase phase);
    simpleTBitem tr_pass2ap;
    
    forever begin
      @(posedge vintf.clk);
      if(vintf.req === 1 && vintf.ack === 1) begin
        tr = simpleTBitem::type_id::create("tr");
        
        tr.cmd_e   = vintf.wr1rd0 ? WRITE : READ;
        tr.addr    = vintf.addr;
        tr.data    = vintf.data;
        tr.rd_data = vintf.rd_data;
        
        `uvm_info(get_type_name(), $sformatf("Monitored Item: %0s", tr.convert2string()), UVM_LOW)
        
        // Make a deep copy before passing to analysis port to avoid
        // accidental modifications on the object.
        $cast(tr_pass2ap, tr.clone());
        mon_ap.write(tr_pass2ap);
      end
    end
  endtask : run_phase
endclass : simpleTBmonitor
////////////////////////////////////////////////////////////////////////////////////////////

class simpleTBagent extends uvm_agent;
  uvm_sequencer #(simpleTBitem) seqr;
  simpleTBdriver  drvr;
  simpleTBmonitor mon;
  simpleTBagent_config agt_cfg;
  
  `uvm_component_utils(simpleTBagent)
  
  function new(string name = "simpleTBagent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Building agent...", UVM_DEBUG)
    
    // Get the configuration object
    if(!uvm_config_db#(simpleTBagent_config)::get(this, "", "agt_cfg", agt_cfg)) begin
      `uvm_fatal(get_type_name(), "Failed to get agent configuration!")
    end
    
    // Construct the components based on whether agent is Active or Passive
    if(agt_cfg.is_active == UVM_ACTIVE) begin
      seqr = uvm_sequencer#(simpleTBitem)::type_id::create("seqr", this);
      drvr = simpleTBdriver::type_id::create("drvr", this);
      drvr.vintf = agt_cfg.vintf;
    end
    
    mon = simpleTBmonitor::type_id::create("mon", this);
    mon.vintf = agt_cfg.vintf;
  endfunction : build_phase
  
  virtual function void connect_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Connecting components of agent", UVM_DEBUG)
    
    if(agt_cfg.is_active == UVM_ACTIVE) begin
      drvr.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction : connect_phase
endclass : simpleTBagent
////////////////////////////////////////////////////////////////////////////////////////////

class simpleTB_seq_base extends uvm_sequence#(simpleTBitem);
  int num_iter = 1;
  
  REQ tr_item;
  RSP rsp_item;
  
  `uvm_object_utils(simpleTB_seq_base)
  
  function new(string name = "simpleTB_seq_base");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_info(get_type_name(), "Starting the sequence", UVM_LOW);
  endtask : body
endclass : simpleTB_seq_base
////////////////////////////////////////////////////////////////////////////////////////////

class simpleTB_seq extends simpleTB_seq_base;
  `uvm_object_utils(simpleTB_seq)
  
  function new(string name = "simpleTB_seq");
    super.new(name);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    
  endfunction : build_phase
  
  virtual task body();
    super.body();
    
    `uvm_info(get_type_name(), $sformatf("Number of iterations = %0d", num_iter), UVM_HIGH);
    
    repeat(num_iter) begin
      tr_item = simpleTBitem::type_id::create("tr_item");
    
      start_item(tr_item);
      
      if(!tr_item.randomize()) begin
        `uvm_fatal(get_type_name(), "Randomization failed on tr_item")
      end
    
      //tr_item.convert2string();
      
      finish_item(tr_item);
      get_response(rsp_item);
      `uvm_info(get_type_name(), $sformatf("Response Item: %0s", rsp_item.convert2string()), UVM_LOW)
    end
    
    `uvm_info(get_type_name(), "End of sequence", UVM_LOW);
  endtask : body
endclass : simpleTB_seq

endpackage : simpleTBagent_pkg
////////////////////////////////////////////////////////////////////////////////////////////

package simpleRAL_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import simpleTBagent_pkg::*;

class simple_reg_adapter extends uvm_reg_adapter;
  
  `uvm_object_utils(simple_reg_adapter)
  
  function new(string name = "simple_reg_adapter");
    super.new(name);
  endfunction
  
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    simpleTBitem bus_tr;
    
    bus_tr = simpleTBitem::type_id::create("bus_tr");
    
    bus_tr.cmd_e = (rw.kind == UVM_WRITE) ? WRITE : READ;
    bus_tr.addr  = rw.addr;
    bus_tr.data  = rw.data;
    
    return bus_tr;
  endfunction : reg2bus
  
  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    
    simpleTBitem bus_tr;
    
    if(!$cast(bus_tr, bus_item.clone())) begin
      `uvm_fatal(get_type_name(), "Failed casting!")
    end
    
    `uvm_info(get_type_name(), $sformatf("BUS2REG:%0s", bus_tr.convert2string()), UVM_LOW)
    
    rw.kind = (bus_tr.cmd_e == WRITE) ? UVM_WRITE : UVM_READ;
    rw.addr = bus_tr.addr;
    rw.data = (bus_tr.cmd_e == WRITE) ? bus_tr.data : bus_tr.rd_data;
    rw.status = UVM_IS_OK;
  endfunction : bus2reg
endclass : simple_reg_adapter
///////////////////////////////////////////////////////////////////////////////////////////////////////////

class simple_reg_a extends uvm_reg;
  rand uvm_reg_field field1;
  rand uvm_reg_field field2;
  rand uvm_reg_field field3;
       uvm_reg_field rsvd;
  
  `uvm_object_utils(simple_reg_a)
  
  function new(string name = "simple_reg_a");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
  
  virtual function void build();
    field1 = uvm_reg_field::type_id::create("field1");
    field2 = uvm_reg_field::type_id::create("field2");
    field3 = uvm_reg_field::type_id::create("field3");
    rsvd   = uvm_reg_field::type_id::create("rsvd");
    
    field1.configure(this, 2, 0, "RW", 0, 2'b00, 1, 1, 0);
    field2.configure(this, 2, 2, "RW", 0, 2'b00, 1, 1, 0);
    field3.configure(this, 2, 4, "RW", 0, 2'b01, 1, 1, 0);
    rsvd.configure  (this, 2, 6, "RW", 0, 2'b00, 1, 1, 0);
  endfunction : build
endclass : simple_reg_a

class simple_reg_b extends uvm_reg;
  rand uvm_reg_field field1;
  rand uvm_reg_field field2;
  rand uvm_reg_field field3;
  rand uvm_reg_field field4;
  rand uvm_reg_field field5;
  
  `uvm_object_utils(simple_reg_b)
  
  function new(string name = "simple_reg_b");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
  
  virtual function void build();
    field1 = uvm_reg_field::type_id::create("field1");
    field2 = uvm_reg_field::type_id::create("field2");
    field3 = uvm_reg_field::type_id::create("field3");
    field4 = uvm_reg_field::type_id::create("field4");
    field5 = uvm_reg_field::type_id::create("field5");
    
    field1.configure(this, 2, 0, "RW", 0, 2'b00, 1, 1, 0);
    field2.configure(this, 2, 2, "RW", 0, 2'b00, 1, 1, 0);
    field3.configure(this, 2, 4, "RW", 0, 2'b01, 1, 1, 0);
    field4.configure(this, 1, 6, "RO", 0, 1'b1 , 1, 1, 0);
    field5.configure(this, 1, 7, "RO", 0, 1'b0 , 1, 1, 0);
  endfunction : build
endclass : simple_reg_b

class simple_mem extends uvm_mem;

  `uvm_object_utils(simple_mem)
  
  function new(string name = "simple_mem");
    super.new(name, 16, 8, "RW", UVM_NO_COVERAGE);
  endfunction
  
endclass : simple_mem
//----------------------------------------------------------------------------------------------------------

class simple_reg_block extends uvm_reg_block;
       ral_prediction_t prediction_type;
  rand simple_reg_a reg_a1;
  rand simple_reg_a reg_a2;
  rand simple_reg_b reg_b1;
  rand simple_reg_b reg_b2;
  rand simple_mem   mem;
  
  uvm_reg_map simple_reg_map;
  
  `uvm_object_utils(simple_reg_block)
  
  function new(string name = "simple_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
  
  virtual function bit en_auto_predict();
    case(prediction_type)
      AUTO             : en_auto_predict = 1;
      EXPLICIT, PASSIVE: en_auto_predict = 0;
      default: `uvm_fatal(get_type_name(), "Unknown enum!")
    endcase
  endfunction : en_auto_predict
  
  virtual function void build();
    reg_a1 = simple_reg_a::type_id::create("reg_a1");
    reg_a1.configure(this, null, "");
    reg_a1.build();
    reg_a1.add_hdl_path_slice("rega1Q", 0, 8);
    
    reg_a2 = simple_reg_a::type_id::create("reg_a2");
    reg_a2.configure(this, null, "");
    reg_a2.build();
    reg_a2.add_hdl_path_slice("rega2Q", 0, 8);
    
    reg_b1 = simple_reg_b::type_id::create("reg_b1");
    reg_b1.configure(this, null, "");
    reg_b1.build();
    reg_b1.add_hdl_path_slice("regb1Q", 0, 8);
    
    reg_b2 = simple_reg_b::type_id::create("reg_b2");
    reg_b2.configure(this, null, "");
    reg_b2.build();
    reg_b2.add_hdl_path_slice("regb2Q", 0, 8);
    
    mem = simple_mem::type_id::create("mem");
    mem.configure(this, "mem");
    
    simple_reg_map = create_map("simple_reg_map", 16'h0000, 1, UVM_LITTLE_ENDIAN);
    
    simple_reg_map.add_reg(reg_a1, 16'h0000, "RW");
    simple_reg_map.add_reg(reg_a2, 16'h0001, "RW");
    simple_reg_map.add_reg(reg_b1, 16'h0002, "RW");
    simple_reg_map.add_reg(reg_b2, 16'h0003, "RW");
    simple_reg_map.add_mem(mem, 16'h0004, "RW");
    simple_reg_map.set_auto_predict(en_auto_predict());
    
    add_hdl_path("myDUT", "RTL");
    lock_model();
  endfunction : build
endclass : simple_reg_block

endpackage : simpleRAL_pkg

package simpleTBenv_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import simpleTBagent_pkg::*;
  import simpleRAL_pkg::*;

class simpleTBenv_config extends uvm_object;
  bit has_scoreboard           = 1;
  bit ral_supports_byte_enable = 0;
  bit ral_provides_responses   = 0;
  
  simple_reg_block reg_model;
  simpleTBagent_config agt_cfg;

  `uvm_object_utils(simpleTBenv_config)
  
  function new(string name = "simpleTBenv_config");
    super.new(name);
  endfunction
  
endclass : simpleTBenv_config

class simpleTBenv extends uvm_env;
  simpleTBagent agent;
  simpleTBenv_config env_cfg;
  
  simple_reg_adapter reg2bus_adapter;
  uvm_reg_predictor#(simpleTBitem) bus2reg_predictor;
  
  `uvm_component_utils(simpleTBenv)
  
  function new(string name = "simpleTBenv", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Building env...", UVM_DEBUG)
    
    if(!uvm_config_db#(simpleTBenv_config)::get(this, "", "env_cfg", env_cfg)) begin
      `uvm_fatal(get_type_name(), "Failed to get environment config!")
    end
    
    // Create the Register Adapter
    reg2bus_adapter = simple_reg_adapter::type_id::create("reg2bus_adapter");
    reg2bus_adapter.supports_byte_enable = env_cfg.ral_supports_byte_enable;
    reg2bus_adapter.provides_responses   = env_cfg.ral_provides_responses;
    
    // Create the Register Predictor based on the prediction type
    if(env_cfg.reg_model.prediction_type inside {EXPLICIT, PASSIVE}) begin
      bus2reg_predictor = uvm_reg_predictor#(simpleTBitem)::type_id::create("bus2reg_predictor", this);
    end
    
    // Configure the agent
    uvm_config_db#(simpleTBagent_config)::set(this, "agent", "agt_cfg", env_cfg.agt_cfg);
    
    // Create the agent
    agent = simpleTBagent::type_id::create("agent", this);
    
  endfunction : build_phase
  
  virtual function void connect_phase(uvm_phase phase);
    // Connect the register map sequencer to the agent's sequencer. Then
    // set the adapter to be used to reg2bus_adapter.
    env_cfg.reg_model.simple_reg_map.set_sequencer(agent.seqr, reg2bus_adapter);
    
    // Set the predictor's register map to the register model's register map
    // based on prediction type. Use the register adapter. Then connect the monitor's
    // analysis port to the predictor's port.
    if(env_cfg.reg_model.prediction_type inside {EXPLICIT, PASSIVE}) begin
      bus2reg_predictor.map     = env_cfg.reg_model.simple_reg_map;
      bus2reg_predictor.adapter = reg2bus_adapter;
      agent.mon.mon_ap.connect(bus2reg_predictor.bus_in);
    end
    
  endfunction : connect_phase
endclass : simpleTBenv

class ral_seq_base extends simpleTB_seq_base;
  simple_reg_block   reg_model;
  simpleTBenv_config env_cfg;
  
  `uvm_object_utils(ral_seq_base)
  
  function new(string name = "ral_seq_base");
    super.new(name);
  endfunction
  
  virtual task body();
    super.body();
    
    if(!uvm_config_db#(simpleTBenv_config)::get(null, $sformatf("uvm_test_top.%0s", get_full_name()), "env_cfg", env_cfg)) begin
      `uvm_fatal(get_type_name(), "Failed getting config db!")
    end
    
    `uvm_info(get_full_name(), "", UVM_LOW)
    
    reg_model = env_cfg.reg_model;
  endtask : body
endclass : ral_seq_base

class write_ral_seq extends ral_seq_base;
  rand bit [7:0] wdata;
  rand bit [7:0] mem_addr_offst;
  
  `uvm_object_utils(write_ral_seq)
  
  function new(string name = "write_ral_seq");
    super.new(name);
  endfunction
  
  virtual task chk_reg_wdata(uvm_reg chk_reg);
    uvm_status_e stat;
    
    fork begin
      #1; // This delay is present because the peek() is returning
          // an incorrect value due to race condition
      
      chk_reg.mirror(stat, UVM_CHECK, .path(UVM_BACKDOOR));
    end // end of begin
    join_none
  endtask : chk_reg_wdata
  
  virtual task chk_mem_wdata(uvm_mem chk_mem,
                             bit [7:0] addr_offst,
                             bit [7:0] exp_data);
    
    uvm_status_e stat;
    bit [7:0] obs_data;
    
    fork begin
      #1;
      chk_mem.peek(stat, addr_offst, obs_data);
    
      if(obs_data != exp_data) begin
        `uvm_error(get_type_name(), $sformatf("Obs = %0h, Exp = %0h", obs_data, exp_data))
      end // end of if obs_data != exp_data
    end // end of fork begin
    join_none
  endtask : chk_mem_wdata
  
  virtual task body();
    uvm_status_e stat;
    bit [7:0] rd_data;
    uvm_reg all_regs[$];
    
    super.body();
    
    reg_model.reset();
    
    // Write (frontdoor) to registers then backdoor checks
    reg_model.get_registers(all_regs);
    all_regs.shuffle();
    
    foreach(all_regs[i]) begin
      if(!this.randomize()) begin
        `uvm_fatal(get_type_name(), "Failed Ranodmization!")  
      end
      
      all_regs[i].write(stat, wdata, .parent(null));
      chk_reg_wdata(all_regs[i]);
    end // end of foreach(all_regs)
    
    repeat(reg_model.mem.get_size()) begin
      if(!this.randomize() with {mem_addr_offst < 16;}) begin
        `uvm_fatal(get_type_name(), "Failed Ranodmization!")  
      end
      
      reg_model.mem.write(stat, mem_addr_offst, wdata, .parent(null));
      chk_mem_wdata(reg_model.mem, mem_addr_offst, wdata);
    end // end of repeat
    
    
    // Read (frontdoor) then check
    all_regs.shuffle();
    
    foreach(all_regs[i]) begin
      all_regs[i].mirror(stat, UVM_CHECK, .path(UVM_FRONTDOOR));
    end
    
    all_regs.shuffle();
    
    foreach(all_regs[i]) begin
      if(!this.randomize()) begin
        `uvm_fatal(get_type_name(), "Failed Ranodmization!")  
      end
      
      all_regs[i].write(stat, wdata, .parent(null));
      
    end // end of foreach(all_regs)
    
    foreach(all_regs[i]) begin
      if(!this.randomize()) begin
        `uvm_fatal(get_type_name(), "Failed Ranodmization!")  
      end
      
      all_regs[i].write(stat, wdata, .parent(null));
      
    end // end of foreach(all_regs)
    
    foreach(all_regs[i]) begin
      chk_reg_wdata(all_regs[i]);
    end // end of foreach(all_regs)
  endtask : body
endclass : write_ral_seq

class simpleTB_base_test extends uvm_test;
  simpleTBenv env;
  simpleTBenv_config env_cfg;
  simpleTBagent_config agt_cfg;
  
  `uvm_component_utils(simpleTB_base_test)
  
  function new(string name = "simpleTB_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Building test...", UVM_DEBUG)

    // Create the environment
    env_cfg = simpleTBenv_config::type_id::create("env_cfg");
    
    // Create the agent
    agt_cfg = simpleTBagent_config::type_id::create("agt_cfg");
    
  endfunction : build_phase
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    // Print factory overrides
    // In previous UVM versions, calling factory.print() is enough.
    // But in UVM1.2, uvm_factory::get() method should be called.
    // It will return an object for uvm_factory. Thus, need to instantiate
    // a uvm_factory handle.
    uvm_factory factory;
    factory = uvm_factory::get();
    factory.print();
    
    // Print the testbench topology
    uvm_top.print_topology();
    
    // Set timeout
    uvm_top.set_timeout(3000);
  endfunction : end_of_elaboration_phase
endclass : simpleTB_base_test

class simpleTB_ral_test extends simpleTB_base_test;
  write_ral_seq wr_ral_seq;
  simpleTB_seq seq;
  
  `uvm_component_utils(simpleTB_ral_test)
  
  function new(string name = "simpleTB_ral_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Configure the environment
    env_cfg.reg_model = simple_reg_block::type_id::create("reg_model");
    env_cfg.reg_model.prediction_type = EXPLICIT;
    env_cfg.reg_model.build();
    
    env_cfg.ral_supports_byte_enable = 0;
    env_cfg.ral_provides_responses   = 1;
    
    // Configure the agent
    if(!uvm_config_db#(virtual simpleTBinterface)::get(this, "", "vintf", agt_cfg.vintf)) begin
      `uvm_fatal(get_type_name(), "Failed to get virtual interface")
    end
    
    agt_cfg.is_active = UVM_ACTIVE;
    
    // Put the agent configuration inside environment configuration
    env_cfg.agt_cfg = agt_cfg;
    
    // Set the env_cfg in the configuration database
    uvm_config_db#(simpleTBenv_config)::set(this, "*", "env_cfg", env_cfg);
    
    env = simpleTBenv::type_id::create("env", this);
  endfunction : build_phase
  
  virtual task run_phase(uvm_phase phase);
    uvm_reg_hw_reset_seq reg_rst_seq;
    uvm_status_e stat;
    bit [7:0] rd_data;
    
    super.run_phase(phase);
    
    `uvm_info(get_type_name(), "Starting the test...", UVM_LOW)
    
    phase.raise_objection(this);
    
    reg_rst_seq = uvm_reg_hw_reset_seq::type_id::create("reg_rst_seq");
    reg_rst_seq.model = env_cfg.reg_model;
    reg_rst_seq.start(env.agent.seqr);
    
    wr_ral_seq = write_ral_seq::type_id::create("wr_ral_seq");
    wr_ral_seq.start(null);
    
    seq = simpleTB_seq::type_id::create("seq");
    seq.num_iter = 10;
    seq.start(env.agent.seqr);
    
    env_cfg.reg_model.reg_a1.mirror(stat, UVM_CHECK, .path(UVM_FRONTDOOR));
    env_cfg.reg_model.reg_a2.mirror(stat, UVM_CHECK, .path(UVM_FRONTDOOR));
    env_cfg.reg_model.reg_b1.mirror(stat, UVM_CHECK, .path(UVM_FRONTDOOR));
    env_cfg.reg_model.reg_b2.mirror(stat, UVM_CHECK, .path(UVM_FRONTDOOR));
    
    phase.phase_done.set_drain_time(this, 100);
    phase.drop_objection(this);
    
    `uvm_info(get_type_name(), "End of test...", UVM_LOW)
  endtask : run_phase
endclass : simpleTB_ral_test

endpackage : simpleTBenv_pkg

interface simpleTBinterface(input clk,
                            input resetb);

  logic       req;
  logic       ack;
  logic       wr1rd0;
  logic [7:0] addr;
  logic [7:0] data;
  logic [7:0] rd_data;
endinterface : simpleTBinterface


module simpleTBTop();
  import uvm_pkg::*;
  import simpleTBenv_pkg::*;
  
  logic clk = 0;
  logic resetb;
  
  parameter CLK_PERIOD = 10;
  
  always #(CLK_PERIOD/2) clk = ~clk;
  
  simpleTBinterface intf(.clk(clk),
                         .resetb(resetb));
  
  simpleDUT myDUT(.clk    (clk),
                  .resetb (resetb),
                  .req    (intf.req),
                  .ack    (intf.ack),
                  .wr1rd0 (intf.wr1rd0),
                  .addr   (intf.addr),
                  .data   (intf.data),
                  .rd_data(intf.rd_data));
  
  // Reset
  initial begin
    resetb = 0;
    #23;
    resetb = 1;
  end
  
  // Set the virtual interface
  initial begin
    uvm_config_db#(virtual simpleTBinterface)::set(null, "uvm_test_top", "vintf", intf);
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
    
    // Choose any of the following:
    // - simpleTB_ral_test
    run_test("simpleTB_ral_test");
  end
endmodule : simpleTBTop