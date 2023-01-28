

// Revision: 3
//-------------------------------------------------------------------------------

`define vif vif.monitor_mp

class i2s_slave_monitor extends uvm_monitor;
  `uvm_component_utils(i2s_slave_monitor)
  // Virtual Interface  
  virtual i2s_interface vif;

  uvm_analysis_port #(i2s_seq_item) monitor_port;
  
  i2s_config s_cfg;
  int word_length;
  int diff;
  i2s_seq_item trans;
  int repeat_gen=i2s_seq_item::no_item;
    
  extern function new(string name, uvm_component parent);
  extern function void build_phase(uvm_phase phase);    
  extern task run_phase(uvm_phase phase);
  extern task mon_mono_right(input i2s_config s_cfg);
  extern task mon_mono_left(input i2s_config s_cfg);
  extern task mon_stereo(input i2s_config s_cfg);
  extern task collect_data(); 
  
endclass:i2s_slave_monitor

  //////////////////////////////////////////////////////// 
  // Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : void  
  // Description        : constrctor and create tlm port
  //////////////////////////////////////////////////////// 

  function i2s_slave_monitor:: new(string name, uvm_component parent);
    super.new(name, parent);
    trans = new();
    monitor_port = new("monitor_port", this);
    `uvm_info(get_type_name(),"SLAVE_MONITOR NEW",UVM_LOW)
  endfunction : new

  //////////////////////////////////////////////////////// 
	// Method name        : build_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : create and build object 
  //////////////////////////////////////////////////////// 

  function void i2s_slave_monitor:: build_phase(uvm_phase phase);
    super.build_phase(phase);   
    if(!uvm_config_db#(virtual i2s_interface)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    if(!uvm_config_db #(i2s_config)::get(this,"","s_cfg_1d",s_cfg))
      `uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
      `uvm_info(get_type_name(),"SLAVE_MONITOR BUILD_PHASE",UVM_LOW)
  endfunction: build_phase    
      
  ///////////////////////////////////////////////////////////////// 
	// Method name        : run_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : call required task and run in run phase
  //                      convert the signal level activity to transaction level. 
  ////////////////////////////////////////////////////////////////// 

  task i2s_slave_monitor:: run_phase (uvm_phase phase);
    super.run_phase(phase);
    forever
      begin
      collect_data;   
      end
    `uvm_info(get_type_name(),"SLAVE_MONITOR_RUN",UVM_LOW)
  endtask

  //////////////////////////////////////////////////////// 
	// Method name        : collect_data
  // Parameter Passed   : null
  // Returned parameter : void  
  // Description        : call other task based on  set config
  ////////////////////////////////////////////////////////

  task i2s_slave_monitor:: collect_data;
    
      trans = i2s_seq_item::type_id::create("trans");

      if(s_cfg.mode_sel == TX)begin 
            word_length= s_cfg.s_word_len;
          end
          
    else if (s_cfg.mode_sel == TX)begin
            word_length=s_cfg.word_len;
          end
          
          if(s_cfg.mode_sel == TX) begin
            repeat (repeat_gen) begin
              trans=new("trans");
              if(s_cfg.chnl_mode == MONO_RIGHT)begin       // calling mono right 
                mon_mono_right(s_cfg);
              end
              else if(s_cfg.chnl_mode == MONO_LEFT)begin
                mon_mono_left(s_cfg);					// calling mono left task
              end
              else if(s_cfg.chnl_mode == STEREO)begin
                mon_stereo(s_cfg);					// calling stereo task
              end
              else begin
                `uvm_error("Incorrect config set","------------Please select valid channel mode in config class----------");
              end
            end
          end
      
    else if(s_cfg.mode_sel == TX) begin
        repeat (repeat_gen) begin												
          trans=new("s_cfg");
          if(s_cfg.chnl_mode == MONO_RIGHT)begin       // calling mono right task
            mon_mono_right(s_cfg);
          end
          else if(s_cfg.chnl_mode == MONO_LEFT)begin
            mon_mono_left(s_cfg);					// calling mono left task
          end
          else if(s_cfg.chnl_mode == STEREO)begin
            mon_stereo(s_cfg);					// calling stereo task
          end
          else begin
            `uvm_error("Incorrect config set","------------Please select valid channel mode in config class----------");
          end
        end
      end
    endtask:collect_data

  //////////////////////////////////////////////////////// 
	// Method name        : mon_mono_right
  // Parameter Passed   : input i2s_config m_cfg
  // Returned parameter : void  
  // Description        : 
  ////////////////////////////////////////////////////////

    task i2s_slave_monitor:: mon_mono_right(input i2s_config s_cfg);
      wait(`vif.WS == 1);
      
      if(s_cfg.mode_sel == TX) begin
        if(s_cfg.s_word_len >s_cfg.word_len)
          word_length=s_cfg.word_len;
      end
      
      if(s_cfg.mode_sel == TX) begin
        if(s_cfg.word_len > s_cfg.s_word_len)
          word_length=s_cfg.s_word_len;
      end
      
      for(int i=(word_length)-1;i>=0;i--)begin
          @(`edge_clk `vif.SCK);
          @(negedge `vif.SCK);
          trans.data[i] = `vif.sd_out;
      end
    
      if(s_cfg.mode_sel == TX) begin
        if(s_cfg.word_len > s_cfg.s_word_len) begin
            diff = s_cfg.word_len - s_cfg.s_word_len;
            for(int k=0; k<diff; k++) begin
              @(`edge_clk `vif.SCK);
            end
          end
        end
        
      if(s_cfg.mode_sel == TX) begin
        if(s_cfg.s_word_len > s_cfg.word_len) begin
            diff = s_cfg.s_word_len - s_cfg.word_len;
            for(int k=0; k<diff; k++) begin
              @(`edge_clk `vif.SCK);
            end
          end
        end
        
        trans.print();
      if(s_cfg.mode_sel == TX)begin 
        //used write port
        monitor_port.write(trans);
      end
      
      else if (s_cfg.mode_sel == TX)begin
        //used write port
        monitor_port.write(trans);
        end
        @(`edge_clk `vif.SCK);
      
    endtask:mon_mono_right

  //////////////////////////////////////////////////////// 
	// Method name        : mon_mono_left
  // Parameter Passed   : input i2s_config m_cfg
  // Returned parameter : void  
  // Description        : 
  ////////////////////////////////////////////////////////

    task i2s_slave_monitor:: mon_mono_left(input i2s_config s_cfg);
      wait(`vif.WS == 0);
      if(s_cfg.mode_sel == TX) begin
        if(s_cfg.s_word_len >s_cfg.word_len)     
          word_length=s_cfg.word_len;
      end
      
      
      if(s_cfg.mode_sel == TX) begin
        if(s_cfg.word_len > s_cfg.s_word_len)
          word_length=s_cfg.s_word_len;
      end
        
      
      for(int i=(word_length)-1;i>=0;i--)begin
        @(`edge_clk `vif.SCK);
        @(negedge `vif.SCK);
        trans.data[i] = `vif.sd_out;
      end
    
      if(s_cfg.mode_sel == TX) begin
        if(s_cfg.word_len > s_cfg.s_word_len) begin
          diff = s_cfg.word_len - s_cfg.s_word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        @(`edge_clk `vif.SCK);
        end
      end
      
      if(s_cfg.mode_sel == TX) begin
        if(s_cfg.s_word_len > s_cfg.word_len) begin
            diff = s_cfg.s_word_len - s_cfg.word_len;
          for(int k=0; k<diff; k++) begin
              @(`edge_clk `vif.SCK);
            end
          @(`edge_clk `vif.SCK);
          end
      end
      
      trans.print();
      if(s_cfg.mode_sel == TX)begin 
        monitor_port.write(trans);
      end
      
      if (s_cfg.mode_sel == TX)begin
          //used write port
          monitor_port.write(trans);
      end
          @(`edge_clk `vif.SCK); 
    endtask:mon_mono_left

  //////////////////////////////////////////////////////// 
	// Method name        : mon_stereo
  // Parameter Passed   : input i2s_config m_cfg
  // Returned parameter : void  
  // Description        : 
  ////////////////////////////////////////////////////////

    task i2s_slave_monitor:: mon_stereo(input i2s_config s_cfg);
      if(s_cfg.mode_sel == TX) begin						
        if(s_cfg.s_word_len >s_cfg.word_len)begin
              word_length=s_cfg.word_len;
        end
      end
      if(s_cfg.mode_sel == TX) begin
        if(s_cfg.word_len > s_cfg.s_word_len)
              word_length=s_cfg.s_word_len;
      end
      
        fork  
          begin:th1
            wait(`vif.WS==1);
            for(int i=(word_length)-1;i>=0;i--)begin
              @(`edge_clk `vif.SCK);
              @(negedge `vif.SCK);
              trans.data[i] = `vif.sd_out;
            end 
            if(s_cfg.mode_sel == TX) begin
              if(s_cfg.word_len > s_cfg.s_word_len) begin
                diff = s_cfg.word_len - s_cfg.s_word_len;
                for(int k=0; k<diff; k++) begin
                  @(`edge_clk `vif.SCK);
                end
                  @(negedge `vif.SCK);
              end
            end
            if(s_cfg.mode_sel == TX) begin
              if(s_cfg.s_word_len > s_cfg.word_len) begin
                diff = s_cfg.s_word_len - s_cfg.word_len;
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
        trans.print();
      if(s_cfg.mode_sel == TX)begin 
          //used write port
          monitor_port.write(trans);
      end 
      else if (s_cfg.mode_sel == TX)begin
          //used write port
          monitor_port.write(trans);
        end 
    endtask:mon_stereo
      