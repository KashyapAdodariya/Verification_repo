

// Revision: 3
//-------------------------------------------------------------------------------


class i2s_base_test extends uvm_test;

  `uvm_component_utils(i2s_base_test)
  
  // classes instance 
  i2s_env env;
  i2s_env_config env_cfg;
  i2s_agent_config agt_cfg;
  i2s_config master_cfg[], slave_cfg[];
  //i2s_report_server rp_sev;
  i2s_report_catcher rp_cth;
  bit test_pass = 0;
  
  en_dis_switch en_override = DISABLE;
  
  //prototype
  extern function new(string name = "i2s_base_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  //extern virtual function void end_of_elaboration_phase(uvm_phase phase); 
  extern virtual function void set_master_config(int i);
  extern virtual function void set_slave_config(int i);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void extract_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);

  
  //printing topology 
  virtual function void end_of_elaboration();
    super.end_of_elaboration();
    uvm_top.print_topology();
  endfunction

endclass : i2s_base_test

  //////////////////////////////////////////////////////// 
  // Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : void  
  // Description        : constrctor
  //////////////////////////////////////////////////////// 

  function i2s_base_test :: new(string name = "i2s_base_test",uvm_component parent=null);
    super.new(name,parent);
     //rp_sev= new();
     //uvm_report_server::set_server(rp_sev);
    `uvm_info(get_type_name(),"I2S_BASE_TEST NEW",UVM_LOW)
  endfunction : new


  //////////////////////////////////////////////////////// 
	// Method name        : build_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : create and build object 
  ////////////////////////////////////////////////////////
  
  function void i2s_base_test :: build_phase(uvm_phase phase);
    super.build_phase(phase);
     
    rp_cth = i2s_report_catcher::type_id::create("rp_cth");
    uvm_report_cb::add(null,rp_cth);
    //overriding 
    //required any specific agent or write in loop
   /* if(en_override == ENABLE) begin
      uvm_factory factory = uvm_factory::get();
      set_type_override_by_type(i2s_master_driver::get_type(), i2s_master_driver_child::get_type());
      set_type_override_by_type(i2s_slave_driver::get_type(), i2s_slave_driver_child::get_type());
      set_type_override_by_type(i2s_slave_monitor::get_type(), i2s_slave_monitor_child::get_type());
      set_type_override_by_type(i2s_master_monitor::get_type(), i2s_master_monitor_child::get_type());
      set_type_override_by_type(i2s_scoreboard::get_type(), i2s_scoreboard_child::get_type());
    end*/
    
    //create env_cfg and set
    env_cfg = i2s_env_config::type_id::create("env_cfg",this);
    uvm_config_db #(i2s_env_config) :: set(this,"*","i2s_env_config",env_cfg);
    //create and set agent_config
    agt_cfg = i2s_agent_config::type_id::create("agt_cfg",this);
    uvm_config_db #(i2s_agent_config) :: set(this,"*","i2s_agent_config",agt_cfg);
    
    //checking condition for master_agent enable
    if(env_cfg.en_master_agent == ENABLE) begin
        //allocate memory
        master_cfg = new[agt_cfg.no_of_master_agent];
    end
    
    //checking condition for slave_agent enable
    if(env_cfg.en_slave_agent == ENABLE) begin
      //allocate memory
      slave_cfg = new[agt_cfg.no_of_slave_agent];
    end
    
    //create an env.
    env = i2s_env::type_id::create("env", this);
    
    //checking condition for master_agent enable
    if(env_cfg.en_master_agent == ENABLE) begin
      //create array of master_config
      for(int i=0; i<agt_cfg.no_of_master_agent; i++) begin
        master_cfg[i] = i2s_config::type_id::create($sformatf("master_cfg[i]",i));
        //get interfcae for master_cfg
        if(!uvm_config_db #(virtual i2s_interface)::get(this,"","vif",master_cfg[i].vif))
          `uvm_fatal(get_type_name(),"not getting interface in test") 
          
          //set any specifiey config
          set_master_config(i);
        
        //set array of master_cfg
         uvm_config_db #(i2s_config) :: set(null,"*",$sformatf("i2s_master_config[%0d]",i),master_cfg[i]);
        `uvm_info(get_type_name(),$sformatf("set master_config in test: %0d",i),UVM_LOW)
      end
    end
    
    if(env_cfg.en_slave_agent == ENABLE) begin
      //create array of master_config
      for(int i=0; i<agt_cfg.no_of_slave_agent; i++) begin
        slave_cfg[i] = i2s_config::type_id::create($sformatf("slave_cfg[i]",i));
        //get interface for slave_cfg
        if(!uvm_config_db #(virtual i2s_interface)::get(this,"","vif",slave_cfg[i].vif))
          `uvm_fatal(get_type_name(),"not getting interface in test")
          
          //set any specifiey config
          set_slave_config(i);
        
        //set array of slave_config
        uvm_config_db #(i2s_config) :: set(null,"*",$sformatf("i2s_slave_config[%0d]",i),master_cfg[i]);
        `uvm_info(get_type_name(),$sformatf("set slave_config in test: %0d",i),UVM_LOW)
      end
    end
    `uvm_info(get_type_name(),"I2S_BASE_TEST BULID_PHASE",UVM_LOW)
    
  endfunction : build_phase
      
  //////////////////////////////////////////////////////// 
  // Method name        : set_master_config
  // Parameter Passed   : int i
  // Returned parameter : void  
  // Description        : setting config variables array
  //////////////////////////////////////////////////////// 

  function void i2s_base_test :: set_master_config(int i);
    //assert(master_cfg[i].randomize)
      //`uvm_info(get_type_name(),"i2s_master_config Randomization done",UVM_LOW)
    //`uvm_info(get_type_name(),$sformatf("set_config_class in base_test: \n%0s",master_cfg[i].sprint()),UVM_HIGH)
    master_cfg[i].print();
  endfunction:set_master_config
  
  //////////////////////////////////////////////////////// 
  // Method name        : set_slave_config
  // Parameter Passed   : int i
  // Returned parameter : void  
  // Description        : setting config variables array
  //////////////////////////////////////////////////////// 
  
  function void i2s_base_test :: set_slave_config(int i);
    //slave_cfg[i].mode_sel = RX;
  endfunction:set_slave_config

    
    task i2s_base_test :: run_phase(uvm_phase phase);
      //add uvm_report callback as add method
      //uvm_report_cb::add(env.i2s_scb, rp_cth);
      `uvm_info(get_type_name(),"i2s_base_test run_phase",UVM_LOW)
    endtask:run_phase		
    
    
    
    function void i2s_base_test :: extract_phase(uvm_phase phase);
      if(env.i2s_scb.pass_pkt==1)
        test_pass = 1;
      else if(env.i2s_scb.fail_pkt==1)
        test_pass = 0;
    endfunction
    
    function void i2s_base_test :: report_phase(uvm_phase phase);
     /* if(test_pass==1)
        //`uvm_info(get_type_name(),"\t PASS_TEST \t",UVM_HIGH)
      else
        `uvm_info(get_type_name(),"\t FAIL_TEST \t",UVM_HIGH)*/
    endfunction
