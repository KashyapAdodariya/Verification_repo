

// Revision: 3
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------
//------------------------ENVIRONMENT i2s------------------------------- 
//-------------------------------------------------------------------------

class i2s_env extends uvm_env;
  `uvm_component_utils(i2s_env)

  // all config agents and scoreboard instance
  i2s_env_config env_cfg;
  i2s_agent_config agt_cfg;
  i2s_agent_top agt_top;
  i2s_scoreboard i2s_scb;
  i2s_sub sub;

  //prototype
  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  
endclass : i2s_env

  //////////////////////////////////////////////////////// 
  // Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : void  
  // Description        : constrctor
  //////////////////////////////////////////////////////// 

  function i2s_env :: new(string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info(get_type_name(),"I2S_ENV NEW",UVM_LOW)
  endfunction : new

  //////////////////////////////////////////////////////// 
	// Method name        : build_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : create and build object 
  //////////////////////////////////////////////////////// 

  function void i2s_env :: build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    //getting env_config
    if(!uvm_config_db #(i2s_env_config)::get(this,"","i2s_env_config",env_cfg))
      `uvm_fatal(get_type_name(),"cannot get() env_cfg from uvm_config_db.")
    //getting agent_config
    if(!uvm_config_db #(i2s_agent_config)::get(this,"","i2s_agent_config",agt_cfg))
      `uvm_fatal(get_type_name(),"cannot get() agt_cfg from uvm_config_db.")
    
    //create agent_top
    agt_top = i2s_agent_top::type_id::create("agt_top",this);
  
    //check condition for enable and create scoreboard and subscrib
    if(env_cfg.en_scr==ENABLE)
      i2s_scb  = i2s_scoreboard::type_id::create("i2s_scb", this);
    if(env_cfg.en_sub==ENABLE)
      sub = i2s_sub::type_id::create("sub",this);
    `uvm_info(get_type_name(),"I2S_ENV BULID PHASE",UVM_LOW)
    
  endfunction : build_phase

  //////////////////////////////////////////////////////////////// 
	// Method name        : conncet_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : connecting monitor and scoreboard port
  //////////////////////////////////////////////////////////////// 

  function void i2s_env :: connect_phase(uvm_phase phase);
    if(env_cfg.en_master_agent==ENABLE) begin
      //conncet driver with scoreboard and monitor with scoreboard
      for(int i = 0; i< agt_cfg.no_of_master_agent; i++) begin
        //agt_top.master_agt[i].m_monitor.item_master_collected_port.connect(i2s_scb.item_collected.analysis_export);
        //agt_top.master_agt[i].agent2scb.connect(i2s_scb.item_drive_collect);
        agt_top.master_agt[i].m_driver.driv2scb.connect(i2s_scb.master_drv);
        agt_top.master_agt[i].m_monitor.monitor_port.connect(i2s_scb.slave_fifo.analysis_export);
      end
    end
    if(env_cfg.en_slave_agent==ENABLE) begin
      //conncet driver with scoreboard and monitor with scoreboard
      for(int i = 0; i< agt_cfg.no_of_slave_agent; i++) begin
        //agt_top.slave_agt[i].s_monitor.item_slave_collected_port.connect(i2s_scb.item_collected.analysis_export);
        //agt_top.slave_agt[i].agent2scb.connect(i2s_scb.item_drive_collect
        
        agt_top.slave_agt[i].s_driver.driv2scb.connect(i2s_scb.slave_drv);
        agt_top.slave_agt[i].s_monitor.monitor_port.connect(i2s_scb.slave_fifo.analysis_export);
      end
    end
    `uvm_info(get_type_name(),"I2S_ENV CONNECT_PHASE",UVM_LOW)
  endfunction:connect_phase