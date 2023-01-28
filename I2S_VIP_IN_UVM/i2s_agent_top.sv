
// Revision: 3
//-------------------------------------------------------------------------------


class i2s_agent_top extends uvm_env;
  `uvm_component_utils(i2s_agent_top);

  //declear env and agent config
  i2s_env_config env_cfg;
  i2s_agent_config agt_cfg;
  
  //declear dyn. array of agents
  i2s_agent master_agt[]; 
  i2s_agent slave_agt[]; 

  //declear dyn. array of config class
  i2s_config master_cfg[], slave_cfg[];
  //declear single element of config class 
  //for convert and set config class for each and every agent
  i2s_config m_cfg_1d, s_cfg_1d;
  
  //prototype 
  extern function new(string name = "i2s_agent_top" , uvm_component parent);  
  extern function void build_phase(uvm_phase phase);
  //extern function void connect_phase(uvm_phase phase);
      
endclass

  //////////////////////////////////////////////////////// 
  // Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : void  
  // Description        : constrctor
  //////////////////////////////////////////////////////// 

  function i2s_agent_top :: new(string name = "i2s_agent_top", uvm_component parent);
    super.new(name,parent);
    //get env_config from base_test
    if(!uvm_config_db #(i2s_env_config)::get(this,"","i2s_env_config",env_cfg))
      `uvm_fatal(get_type_name(),"not get env_cfg")
    
    //get agent_config from base_test   
    if(!uvm_config_db #(i2s_agent_config)::get(this,"","i2s_agent_config",agt_cfg))
      `uvm_fatal(get_type_name(),"not get agt_cfg")
    
    //allocate memory for n-master_agent and config
    if(env_cfg.en_master_agent == ENABLE) begin
      master_agt = new[agt_cfg.no_of_master_agent];
       master_cfg = new[agt_cfg.no_of_master_agent];
      `uvm_info(get_type_name(),"create master_agent in NEW",UVM_LOW)
    end
    
    ////allocate memory for n-slave_agent and config
    if(env_cfg.en_slave_agent==ENABLE) begin
      slave_agt = new[agt_cfg.no_of_slave_agent];
      slave_cfg = new[agt_cfg.no_of_slave_agent];
      `uvm_info(get_type_name(),"create slave_agent in NEW",UVM_LOW)
    end
      
    `uvm_info(get_type_name(),"I2S_AGENT_TOP NEW DONE",UVM_LOW)
  endfunction:new

  //////////////////////////////////////////////////////// 
	// Method name        : build_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : create and build object 
  ////////////////////////////////////////////////////////

  function void i2s_agent_top :: build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    //create config
    m_cfg_1d = i2s_config::type_id::create("m_cfg_1d");
    s_cfg_1d = i2s_config::type_id::create("s_cfg_1d");
    
    //check condition for master_agent enable and create n-master_agent with config
    if(env_cfg.en_master_agent == ENABLE) begin
      for(int i=0;i<agt_cfg.no_of_master_agent;i++) begin
        //create
        master_agt[i] = i2s_agent::type_id::create($sformatf("master_agt[%0d]",i),this);
        //get config 
        if(!uvm_config_db #(i2s_config) :: get(this,"",$sformatf("i2s_master_config[%0d]",i),master_cfg[i]))
          `uvm_fatal(get_type_name(),"not getting config in agent_top")
        //assign with 1-d config
        m_cfg_1d = master_cfg[i];
        //set config for each agent
        uvm_config_db #(i2s_config)::set(null,"*","m_cfg_1d",m_cfg_1d);
        //debug print
        `uvm_info(get_type_name(),$sformatf("no of master_agent and master_cfg build : %0d",i),UVM_LOW)
      end
    end
    
    //check condition for master_agent enable and create n-master_agent with config
    if(env_cfg.en_slave_agent == ENABLE) begin
      for(int i=0;i<agt_cfg.no_of_slave_agent;i++) begin
        //create
        slave_agt[i] = i2s_agent::type_id::create($sformatf("slave_agt[%0d]",i),this);
        //get config
        if(!uvm_config_db #(i2s_config) :: get(this,"",$sformatf("i2s_slave_config[%0d]",i),slave_cfg[i]))
          `uvm_fatal(get_type_name(),"not getting config in agent_top")
        //assign with 1-d config
        s_cfg_1d = slave_cfg[i];
        uvm_config_db #(i2s_config)::set(null,"*","s_cfg_1d",s_cfg_1d);
        //debug print
        `uvm_info(get_type_name(),$sformatf("no of slave_agent and slave_cfg build : %0d",i),UVM_LOW)
      end 
    end

  endfunction:build_phase
      
      
   //function void i2s_agent_top :: connect_phase(uvm_phase phase);
     /* if(env_cfg.en_master_agent == ENABLE) begin
        for(int i=0; i<agt_cfg.no_of_master_agent; i++)  begin
          master_agt[i].m_monitor.item_master_collected_port.connect(i2s_scb.item_collected.analysis_export);
          master_agt[i].agent2scb.connect(env.scb.item_drive_collect);
        end
       end
      
       if(env_cfg.en_slave_agent == ENABLE) begin
        for(int i=0; i<agt_cfg.no_of_master_agent; i++)  begin
          slave_agt[i].s_monitor.item_master_collected_port.connect(i2s_scb.item_collected.analysis_export);
          slave_agt[i].agent2scb.connect(env.scb.item_drive_collect);
        end
      end*/
  //endfunction : connect_phase
     
  
      
    

    
