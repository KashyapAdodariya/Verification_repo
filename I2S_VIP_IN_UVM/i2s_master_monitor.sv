

`define vif vif.monitor_mp
class i2s_master_monitor extends uvm_monitor;
  `uvm_component_utils(i2s_master_monitor)

  // Virtual Interface
    virtual i2s_interface vif;
  // analysis port, to send the transaction to scoreboard
  uvm_analysis_port #(i2s_seq_item) monitor_port;
  //other instance and veriable
  i2s_config m_cfg;
  int word_length;
  int diff; 
  i2s_seq_item trans;

  //prototype
  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern task moni();
  extern task mon_mono_right(input i2s_config m_cfg);
  extern task mon_mono_left(input i2s_config m_cfg);
  extern task mon_stereo(input i2s_config m_cfg);

endclass: i2s_master_monitor

  //////////////////////////////////////////////////////// 
  // Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : void  
  // Description        : constrctor and create tlm port
  //////////////////////////////////////////////////////// 

  function i2s_master_monitor :: new (string name, uvm_component parent);
    super.new(name, parent);
    trans = new();
    monitor_port = new("monitor_port", this);
    `uvm_info(get_type_name(),"I2S_MASTER_MONITOR NEW",UVM_LOW)
  endfunction : new

  //////////////////////////////////////////////////////// 
	// Method name        : build_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : create and build object 
  //////////////////////////////////////////////////////// 

  function void i2s_master_monitor :: build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual i2s_interface)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    if(!uvm_config_db #(i2s_config)::get(this,"","m_cfg_1d",m_cfg))
      `uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
      //if(!uvm_config_db #(i2s_config)::get(this,"","s_cfg_1d",s_cfg))
      //`uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
      `uvm_info(get_type_name(),"I2S_MASTER_MONITOR BUILD_PHASE",UVM_LOW)
  endfunction: build_phase

  ///////////////////////////////////////////////////////////////// 
	// Method name        : run_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : call required task and run in run phase
  //                      convert the signal level activity to transaction level. 
  ////////////////////////////////////////////////////////////////// 

  task i2s_master_monitor :: run_phase(uvm_phase phase);
    forever begin
      moni();
      monitor_port.write(trans);
      `uvm_info(get_type_name(),"I2S_MASTER_MONITOR RUN_PHASE",UVM_LOW)
    end
  endtask : run_phase

  //////////////////////////////////////////////////////// 
	// Method name        : moni
  // Parameter Passed   : null
  // Returned parameter : void  
  // Description        : call other task based on  set config
  ////////////////////////////////////////////////////////

  task i2s_master_monitor :: moni();
    
    if(m_cfg.mode_sel == TX)begin 
      word_length= m_cfg.s_word_len;
    end

    if(m_cfg.mode_sel == TX) begin
    // forever begin
        trans=new();
        if(m_cfg.chnl_mode == MONO_RIGHT)begin 
          `uvm_info("i2s_master_monitor", "Mono right", UVM_LOW)
          mon_mono_right(m_cfg);
        end
        else if(m_cfg.chnl_mode == MONO_LEFT)begin
          `uvm_info("i2s_master_monitor", "Mono left mode", UVM_LOW)
          mon_mono_left(m_cfg);					// calling mono left task
        end
        else if(m_cfg.chnl_mode == STEREO)begin
          `uvm_info("i2s_master_monitor", "Stereo mode", UVM_LOW)
          mon_stereo(m_cfg);					// calling stereo task
        end
        else begin
          `uvm_error(get_type_name(),"------------Please select valid channel mode in config class----------");
        end
      //end
    end
  endtask:moni

    //////////////////////////////////////////////////////// 
    // Method name        : mon_mono_right
    // Parameter Passed   : input i2s_config m_cfg
    // Returned parameter : void  
    // Description        : 
    ////////////////////////////////////////////////////////

  task i2s_master_monitor :: mon_mono_right(input i2s_config m_cfg);
    
      wait(`vif.WS == 1);
    
    if(m_cfg.mode_sel == TX) begin
      if(m_cfg.s_word_len >m_cfg.word_len)
        word_length=m_cfg.word_len;
    end
    
    for(int i=(word_length)-1;i>=0;i--)begin
        @(`edge_clk `vif.SCK);
        @(negedge `vif.SCK);
        trans.data[i] = `vif.sd_out;
    end

    if(m_cfg.mode_sel == TX) begin
      if(m_cfg.word_len > m_cfg.s_word_len) begin
          diff = m_cfg.word_len - m_cfg.s_word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
  endtask

  //////////////////////////////////////////////////////// 
	// Method name        : mon_mono_left
  // Parameter Passed   : input i2s_config m_cfg
  // Returned parameter : void  
  // Description        : 
  ////////////////////////////////////////////////////////

  task i2s_master_monitor :: mon_mono_left(input i2s_config m_cfg);   

    wait(`vif.WS == 0);
    if(m_cfg.mode_sel == TX) begin
      if(m_cfg.s_word_len >m_cfg.word_len)     
          word_length=m_cfg.word_len;
    end    
    for(int i=(word_length)-1;i>=0;i--)begin
        @(`edge_clk `vif.SCK);
        @(negedge `vif.SCK);
        trans.data[i] = `vif.sd_out;
    end
    if(m_cfg.mode_sel == TX) begin
      if(m_cfg.word_len > m_cfg.s_word_len) begin
          diff = m_cfg.word_len - m_cfg.s_word_len;
        for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        @(negedge `vif.SCK);
        end
    end
  endtask

  //////////////////////////////////////////////////////// 
	// Method name        : mon_stereo
  // Parameter Passed   : input i2s_config m_cfg
  // Returned parameter : void  
  // Description        : 
  ////////////////////////////////////////////////////////

  task i2s_master_monitor :: mon_stereo(input i2s_config m_cfg);

    if(m_cfg.mode_sel == TX) begin						
      if(m_cfg.s_word_len >m_cfg.word_len)begin
            word_length=m_cfg.word_len;
      end
    end

      fork  
        begin:th1
          wait(`vif.WS==1);          
          for(int i=(word_length)-1;i>0;i--)begin
            @(`edge_clk `vif.SCK);
            @(negedge `vif.SCK);
            trans.data[i] = `vif.sd_out;
          end 
          @(`edge_clk `vif.SCK);
          trans.data[0] = `vif.sd_out;          
          if(m_cfg.mode_sel == TX) begin
            if(m_cfg.word_len > m_cfg.s_word_len) begin
              diff = m_cfg.word_len - m_cfg.s_word_len;
              for(int k=0; k<diff; k++) begin
                @(`edge_clk `vif.SCK);                
              end
                @(negedge `vif.SCK);
            end
          end
        end :th1
        begin:th2
          wait(`vif.WS==0);
          for(int i=0;i<word_length;i++)begin
            @(`edge_clk `vif.SCK);
            @(negedge `vif.SCK);
            trans.data[(2*`size-1)-i] = `vif.sd_out;  
          end
        end :th2
      join
      //disable fork;    
  endtask:mon_stereo

