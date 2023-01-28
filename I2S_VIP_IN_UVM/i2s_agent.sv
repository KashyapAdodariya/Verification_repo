

// Revision: 3
//-------------------------------------------------------------------------------


class i2s_agent extends uvm_agent;
  `uvm_component_utils(i2s_agent)
 
  //declear required veriable
  
  //declear driver
  i2s_master_driver m_driver;
  i2s_slave_driver s_driver;
  i2s_driver_callback drv_cb;
  //declear all required config
  i2s_config m_cfg, s_cfg;
  i2s_env_config env_cfg;
  //declear monitor
  i2s_master_monitor m_monitor;
  i2s_slave_monitor s_monitor;
  //declear sequencer (used only on sequencer as master and slave)
  i2s_sequencer m_sequencer, s_sequencer;  
  //uvm_blocking_put_port#(i2s_seq_item) agent2scb;
  
  //prototype
  extern function new(string name = "i2s_agent", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  
endclass:i2s_agent 

  //////////////////////////////////////////////////////// 
  // Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : void  
  // Description        : constrctor
  ////////////////////////////////////////////////////////

  function i2s_agent :: new (string name = "i2s_agent", uvm_component parent);
    super.new(name, parent);
    //get env_config 
    if(!uvm_config_db #(i2s_env_config)::get(this,"","i2s_env_config",env_cfg))
      `uvm_fatal(get_type_name(),"not getting env_cfg in i2s_agent")
      `uvm_info(get_type_name(),"I2S_AGENT NEW",UVM_LOW)
  endfunction : new

  
  //////////////////////////////////////////////////////// 
	// Method name        : build_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : create and build object 
  //////////////////////////////////////////////////////// 

  function void i2s_agent :: build_phase(uvm_phase phase);
    super.build_phase(phase);
    //check condition for master_agentn and get config
    if(env_cfg.en_master_agent == ENABLE) begin
      //get config
      if(!uvm_config_db #(i2s_config)::get(this,"","m_cfg_1d",m_cfg))
        `uvm_fatal(get_type_name(),"cannot get() m_cfg from uvm_config_db.")
      
      //create monitor for all mode
      m_monitor = i2s_master_monitor::type_id::create("i2s_master_monitor", this);
     
      //creating driver and sequencer only for ACTIVE agent
      if(m_cfg.is_active == UVM_ACTIVE) begin        
        m_driver    = i2s_master_driver::type_id::create("i2s_master_driver", this);
        drv_cb = i2s_driver_callback::type_id::create("drv_cb", this);
        uvm_callbacks#(i2s_master_driver,i2s_driver_callback)::add(m_driver,drv_cb);
        m_sequencer = i2s_sequencer::type_id::create("m_sequencer", this);
      end
    end
    
    //check condition for slave_agentn and get config
    if(env_cfg.en_slave_agent == ENABLE) begin
      //get config
      if(!uvm_config_db #(i2s_config)::get(this,"","s_cfg_1d",s_cfg))
        `uvm_fatal(get_type_name(),"cannot get() s_cfg from uvm_config_db.")
      
      //create monitor for all mode
      s_monitor = i2s_slave_monitor::type_id::create("i2s_slave_monitor", this);
  
      //creating driver and sequencer only for ACTIVE agent
      if(s_cfg.is_active == UVM_ACTIVE) begin
        s_driver    = i2s_slave_driver::type_id::create("i2s_slave_driver", this);
        s_sequencer = i2s_sequencer::type_id::create("s_sequencer", this);
      end
    end
    `uvm_info(get_type_name(),"I2S_AGENT BUILD_PHASE",UVM_LOW)
  endfunction : build_phase

  
  //////////////////////////////////////////////////////////////// 
	// Method name        : conncet_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : connecting monitor and scoreboard port
  ////////////////////////////////////////////////////////////////

  function void i2s_agent :: connect_phase(uvm_phase phase);
    //check condition for master_agent
    if(env_cfg.en_master_agent == ENABLE) begin
      //check for active-passive
      if(m_cfg.is_active == UVM_ACTIVE) begin
        m_driver.seq_item_port.connect(m_sequencer.seq_item_export); 
      end
    end
    //check condition for slave_agentn and get config
    if(env_cfg.en_slave_agent == ENABLE) begin
      //check for active-passive
      if(s_cfg.is_active == UVM_ACTIVE) begin
        s_driver.seq_item_port.connect(s_sequencer.seq_item_export);
      end
    end
    `uvm_info(get_type_name(),"I2S_AGENT CONNECT_PHASE",UVM_LOW)
  endfunction : connect_phase

