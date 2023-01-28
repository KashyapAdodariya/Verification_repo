//`define report_srv_customize
//`define use_virtual_seqr  //on if and if virtual_seq_seqr_test_h test run

class test_h extends uvm_test;

  `uvm_component_utils(test_h)

  env_h env;
  sequence_h seq[$];
  env_cfg_h env_cfg;
  cfg_h cfg;
  
  uvm_report_server srv;
  report_catcher_h rp_cth;
  
  bit factory_overiding = 0;

  function new(string name = "test" , uvm_component parent);
  	super.new(name,parent);
    `uvm_info(get_type_name(),"test new call",UVM_LOW)
  endfunction
  
  function void build_phase(uvm_phase phase);
  	super.build_phase(phase);
    `uvm_info(get_type_name(),"test build_phase call",UVM_LOW)
    
    rp_cth = report_catcher_h::type_id::create("rp_cth");
    uvm_report_cb::add(null,rp_cth);
    
  	env_cfg = env_cfg_h::type_id::create("env_cfg",this);
  	env = env_h::type_id::create("env",this);
  	cfg = cfg_h::type_id::create("cfg");
    
    uvm_config_db #(env_cfg_h) :: set(this,"*","env_cfg",env_cfg);
    uvm_config_db #(cfg_h) :: set(this,"env.agt*","cfg_h",cfg);
    
    //factory_overriding_fun("set_type_by_type","driver","monitor");
    
  endfunction

  function void factory_overriding_fun(string name = "set_type_by_type", string drv = "driver", string mon = "monitor");
    if(factory_overiding==1) begin
      uvm_factory factory = uvm_factory::get();
      case (name)
        "set_type_by_type" : begin 
          if(drv=="driver") begin
            set_type_override_by_type(driver_h::get_type(), driver_child_h::get_type());
          end
          if(mon=="monitor") begin
            set_type_override_by_type(monitor_h::get_type(), monitor_child_h::get_type());
          end
        end
        
        "set_inst_by_type" : begin
          if(drv=="driver") begin
            factory.set_inst_override_by_type(driver_h::get_type(), driver_child_h::get_type(),"env.*");
          end
          if(mon=="monitor") begin
            factory.set_inst_override_by_type(monitor_h::get_type(), monitor_child_h::get_type(),"env.*");
          end
        end
        
        "set_type_by_name" : begin
          if(drv=="driver") begin
            factory.set_type_override_by_name("driver_h", "driver_child_h");
          end
          if(mon=="monitor") begin
            factory.set_type_override_by_name("monitor_h", "monitor_child_h");
          end
        end
        
        "set_inst_by_name" : begin
          if(drv=="driver") begin
            factory.set_inst_override_by_name("driver_h", "driver_child_h", {get_full_name(), "env.*"});
          end
          if(mon=="monitor") begin
            factory.set_inst_override_by_name("monitor_h", "monitor_child_h", {get_full_name(), "env.*"});
          end
        end
        
        default: begin
          `uvm_error(get_type_name(),"Not valid input for factory_overriding_function")
        end
      endcase
    end
        
  endfunction: factory_overriding_fun
  
  function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info(get_type_name(),"test end_of_elaboration_phase call",UVM_LOW)
   	uvm_top.print_topology();
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    for(int i=0;i<env_cfg.no_of_agent;i++) begin
      //allow to run individule sequences for each agent/sequencer
      seq[i] = sequence_h::type_id::create($sformatf("seq[%0d]",i));
      seq[i].start(env.agt[i].seqr);
    end
    `uvm_info(get_type_name(),"test run_phase call",UVM_LOW)
    phase.drop_objection(this);
  endtask
  
  function void report_phase(uvm_phase phase);
    srv = uvm_report_server::get_server();
    //report_catcher_h rp_cth;
    
    super.report_phase(phase);
    `uvm_info(get_type_name(),"test report_phase call",UVM_LOW)
    
    if(srv.get_severity_count(UVM_FATAL) + srv.get_severity_count(UVM_ERROR)>0) begin
      `uvm_info(get_type_name(),"\n\tTESTCASE FAIL\t\n",UVM_LOW)
    end
    else begin
      `uvm_info(get_type_name(),"\n\tTESTCASE PASS\t\n",UVM_LOW)
    end
    
    `uvm_info(get_type_name(),$sformatf("\nerror_injection_count: %0d\nfail_count: %0d\npass_count: %0d",rp_cth.error_injection_count,rp_cth.fail_count,rp_cth.pass_count),UVM_LOW)
    
  endfunction
    
endclass: test_h

//-------------------------------------------------------------------------------------------------------------------------------------------

class test_reactive_h extends test_h;
  `uvm_component_utils(test_reactive_h)
  reactive_seq_h reactive_seq;
  function new(string name = "test_reactive_h", uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"test_reactive_h new call",UVM_LOW)
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"test_reactive_h new call",UVM_LOW)
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //allow to run individule sequences for each agent/sequencer
    reactive_seq = reactive_seq_h::type_id::create("reactive_seq");
    for(int i=0;i<env_cfg.no_of_agent;i++) begin
      //allow to run individule sequences for each agent/sequencer
      reactive_seq.start(env.agt[i].seqr);
    end
    `uvm_info(get_type_name(),"test run_phase call",UVM_LOW)
    phase.drop_objection(this);
  endtask
  
endclass: test_reactive_h

//-------------------------------------------------------------------------------------------------------------------------------------------


//-------------------------------------------------------------------------------------------------------------------------------------------

class ral_test_h extends test_h;
  `uvm_component_utils(ral_test_h)
  
  ral_seq_h ral_seq;
  
  function new(string name = "ral_test_h", uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"ral_test_h new call",UVM_LOW)
  endfunction: new
  
  function void build_phase(uvm_phase phase);
  super.build_phase(phase);
    `uvm_info(get_type_name(),"ral_test_h build_phase call",UVM_LOW)
    ral_seq = ral_seq_h::type_id::create("ral_seq");
  endfunction: build_phase
  
  task run_phase(uvm_phase phase);
  	super.run_phase(phase);
   	phase.raise_objection(this);
    `uvm_info(get_type_name(),"ral_test_h run_phase call",UVM_LOW)
    repeat(1) begin
      ral_seq.start(env.agt[0].seqr);
    end
   	phase.drop_objection(this);
 endtask: run_phase

endclass: ral_test_h

//-------------------------------------------------------------------------------------------------------------------------------------------

class test2_callback_h extends test_h;

  `uvm_component_utils(test2_callback_h)

  callback_1_h callback;
  
  function new(string name = "test2_callback_h" , uvm_component parent);
  	super.new(name,parent);
    `uvm_info(get_type_name(),"test2_callback_h new call",UVM_LOW)
  endfunction
  
  function void build_phase(uvm_phase phase);
  	super.build_phase(phase);
    `uvm_info(get_type_name(),"test2_callback_h build_phase call",UVM_LOW)	
    callback = callback_1_h::type_id::create("callback", this);
  endfunction
  
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    for(int i=0;i<env_cfg.no_of_agent;i++)
      uvm_callbacks#(driver_h,callback_h)::add(env.agt[i].drv,callback);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    for(int i=0;i<env_cfg.no_of_agent;i++) begin
      seq[i] = sequence_h::type_id::create($sformatf("seq[%0d]",i));
      seq[i].start(env.agt[i].seqr);
    end
    `uvm_info(get_type_name(),"test2_callback_h run_phase call",UVM_LOW)
    phase.drop_objection(this);
  endtask
    
endclass: test2_callback_h

//-------------------------------------------------------------------------------------------------------------------------------------------

class test3_callback_seq_h extends test_h;
  callback_1_seq_h callback_1_seq;
  
  `uvm_component_utils(test3_callback_seq_h)
  
  function new(string name = "test3_callback_seq_h" , uvm_component parent);
  	super.new(name,parent);
    `uvm_info(get_type_name(),"test3_callback_seq_h new call",UVM_LOW)
  endfunction
  
  function void build_phase(uvm_phase phase);
  	super.build_phase(phase);
    callback_1_seq = callback_1_seq_h::type_id::create("callback_1_seq");
    `uvm_info(get_type_name(),"test3_callback_seq_h build_phase call",UVM_LOW)	
  endfunction
  
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    for(int i=0;i<env_cfg.no_of_agent;i++)
      uvm_callbacks#(sequencer_h,callback_seq_h)::add(env.agt[i].seqr,callback_1_seq);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    for(int i=0;i<env_cfg.no_of_agent;i++) begin
      seq[i] = sequence_h::type_id::create($sformatf("seq[%0d]",i));
      seq[i].start(env.agt[i].seqr);
    end
    `uvm_info(get_type_name(),"test3_callback_seq_h run_phase call",UVM_LOW)
    phase.drop_objection(this);
  endtask
    
endclass: test3_callback_seq_h

//-------------------------------------------------------------------------------------------------------------------------------------------

`define use_virtual_seqr
class virtual_seq_seqr_test_h extends test_h;
  `uvm_component_utils(virtual_seq_seqr_test_h)
  
  virtual_seq_h virtual_seq;
  
  function new(string name = "virtual_seq_seqr_test_h", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    virtual_seq = virtual_seq_h::type_id::create("virtual_seq");
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    for(int i=0;i<env_cfg.no_of_agent;i++) begin
      `ifdef use_virtual_seqr
      virtual_seq.start(env.virtual_seqr.seqr);
      `else
      seq[i].start(env.agt[i].seqr);
      `endif
    end
    phase.drop_objection(this);
  endtask: run_phase
  
endclass: virtual_seq_seqr_test_h

//-------------------------------------------------------------------------------------------------------------------------------------------
`define SEQ_ARB_FIFO
class con_seq_with_arb_seqr_test_h extends virtual_seq_seqr_test_h;
  `uvm_component_utils(con_seq_with_arb_seqr_test_h)
  
  function new(string name = "con_seq_with_arb_seqr_test_h", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    virtual_seq = virtual_seq_h::type_id::create("virtual_seq");
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    for(int i=0;i<env_cfg.no_of_agent;i++) begin
      
      `ifdef SEQ_ARB_RANDOM 
        env.virtual_seqr.seqr.set_arbitration(UVM_SEQ_ARB_RANDOM);
        `uvm_info(get_type_name(),"set seq arbitration as SEQ_ARB_RANDOM",UVM_LOW)
      `endif
      `ifdef SEQ_ARB_FIFO
        env.virtual_seqr.seqr.set_arbitration(UVM_SEQ_ARB_FIFO);
      `uvm_info(get_type_name(),"set seq arbitration as SEQ_ARB_FIFO\n",UVM_LOW)
      `endif
      `ifdef SEQ_ARB_WEIGHTED   //make sure weight is givien to each and every sequence
        env.virtual_seqr.seqr.set_arbitration(UVM_SEQ_ARB_WEIGHTED);
        `uvm_info(get_type_name(),"set seq arbitration as SEQ_ARB_WEIGHTED",UVM_LOW)
      `endif
      `ifdef SEQ_ARB_STRICT_RANDOM
        env.virtual_seqr.seqr.set_arbitration(UVM_SEQ_ARB_STRICT_RANDOM);
        `uvm_info(get_type_name(),"set seq arbitration as SEQ_ARB_STRICT_RANDOM",UVM_LOW)
      `endif
      `ifdef SEQ_ARB_STRICT_FIFO
        env.virtual_seqr.seqr.set_arbitration(UVM_SEQ_ARB_STRICT_FIFO);
        `uvm_info(get_type_name(),"set seq arbitration as SEQ_ARB_STRICT_FIFO",UVM_LOW)
      `endif
      
      `ifdef use_virtual_seqr
      virtual_seq.start(env.virtual_seqr.seqr);
      `else
      seq[i].start(env.agt[i].seqr);
      `endif
    end
    phase.drop_objection(this);
  endtask: run_phase
  
endclass


