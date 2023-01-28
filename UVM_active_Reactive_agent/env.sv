//`define sb_fifo
//`define use_virtual_seqr
`define sb_analysis_fifo

class env_h extends uvm_env;
  `uvm_component_utils(env_h)

  //declear all required class
  agent_h agt[$];
  scoreboard_h sb;				//used only one
  coverage_h coverage;          //used only one
  
  env_cfg_h env_cfg;
  ral_env_h ral_env;
  slave_agt_h slave_agt;
   
  //just for experiment purpose 
  `ifdef sb_fifo
  uvm_tlm_fifo#(sequence_item_h) fifo_mon2scb;
  `endif
  
  `ifdef use_virtual_seqr
  virtual_seqr_h virtual_seqr;
  `endif

  function new(string name = "env_h", uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"env_h new call",UVM_LOW)
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"env_h bulid_phase call",UVM_LOW)

    if(!uvm_config_db #(env_cfg_h)::get(this,"","env_cfg",env_cfg))
      `uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")

      ral_env = ral_env_h::type_id::create("ral_env",this);

    `ifdef use_virtual_seqr
    virtual_seqr = virtual_seqr_h::type_id::create("virtual_seqr",this);
    `endif

    for(int i=0;i<env_cfg.no_of_agent;i++) begin
      agt[i] = agent_h::type_id::create($sformatf("agt[%0d]",i),this);
      `uvm_info(get_type_name(),$sformatf("agent_no: %0d\n",i),UVM_LOW)
    end
    slave_agt = slave_agt_h::type_id::create("slave_agt",this);

    if(env_cfg.cov_en==1)
      coverage = coverage_h::type_id::create("coverage",this);
    if(env_cfg.scb_en==1)
      sb = scoreboard_h::type_id::create("sb",this);

    `ifdef sb_fifo
    fifo_mon2scb = new("fifo_mon2scb",this);
    `endif
    
  endfunction
    
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(),"env_h connect_phase call",UVM_LOW)
    
    for(int i=0;i<env_cfg.no_of_agent;i++) begin
      `ifdef sb_analysis_fifo
      if(env_cfg.scb_en==1)
        agt[i].monitor.monitor_port.connect(sb.fifo.analysis_export);
      if(env_cfg.cov_en==1)
        agt[i].monitor.monitor_port.connect(coverage.analysis_export);
      `endif
      `ifdef sb_fifo
      if(env_cfg.scb_en==1) begin
        agt[i].monitor.monitor_port.connect(fifo_mon2scb.put_export);
        sb.fifo.connect(fifo_mon2scb.get_export);
      end
      `endif
    end
    for(int i=0;i<env_cfg.no_of_agent;i++) begin
      if(env_cfg.ral_model_on==1) begin
        ral_env.ral_predictor.map = ral_env.reg_blk.default_map;
        ral_env.ral_predictor.adapter = ral_env.adapter;
        agt[i].monitor.monitor_port.connect(ral_env.ral_predictor.bus_in);
        `ifdef use_virtual_seqr
        virtual_seqr.seqr = agt[i].seqr;
        //virtual_seqr.seqr = agt_B.seqr_B;
          ral_env.reg_blk.default_map.set_sequencer(.sequencer(virtual_seqr.seqr),.adapter(ral_env.adapter));
        `else
          ral_env.reg_blk.default_map.set_sequencer(.sequencer(agt[i].seqr),.adapter(ral_env.adapter));
        `endif
      end
    end
    
  endfunction
  
endclass

