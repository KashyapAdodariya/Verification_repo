class i2s_master_agent;
  //for select active and passive agent
  typedef enum {ACTIVE,PASSIVE} status;
  //transection class pass
  i2s_transaction tr;
  //mailbox for generater to driver
  mailbox gen2driv_mbox;
  //mailbox for master driver to scoreboard
  mailbox m_driv2scr_mbox;
  mailbox s_driv2scr_mbox;
  //mailbox for master monitor to scoreboard
  mailbox m_mon2scr_mbox;
  //mailbox for slave monitor to scoreboard 
  mailbox s_mon2scr_mbox;
  mailbox mon2cross_scr_mbox;
  //generater handle
  i2s_master_gen gen;
  //driver handle
  i2s_master_driver driv;
  //monitor handle
  i2s_monitor m_mon;
  //virtual interface handle
  virtual i2s_intf vif;
  //master config class handle
  i2s_config master_cfg;
  //slave config class handle
  i2s_config slave_cfg;
  //active-passive selection
  status agent_status = ACTIVE;
  i2s_scoreboard scr;
  
  function new(virtual i2s_intf vif,mailbox m_driv2scr_mbox,s_driv2scr_mbox,m_mon2scr_mbox,s_mon2scr_mbox,mon2cross_scr_mbox,i2s_config master_cfg,slave_cfg,i2s_transaction tr);
    this.vif = vif;
    this.master_cfg=master_cfg;
    this.slave_cfg = slave_cfg;
    this.mon2cross_scr_mbox=mon2cross_scr_mbox;
    this.m_driv2scr_mbox =m_driv2scr_mbox;
    this.s_driv2scr_mbox =s_driv2scr_mbox;
    this.m_mon2scr_mbox=m_mon2scr_mbox;
    this.s_mon2scr_mbox=s_mon2scr_mbox;
    gen2driv_mbox=new;
    //tr = new(master_cfg);
    this.tr=tr;
  endfunction

  task run();
    if(agent_status == ACTIVE) begin
      if(master_cfg.mode_sel == TX) begin
        gen=new(gen2driv_mbox, master_cfg,tr);
      end
      driv=new(vif,gen2driv_mbox,m_driv2scr_mbox,master_cfg); 
    end    	
    m_mon=new(vif,master_cfg,slave_cfg,m_mon2scr_mbox,s_mon2scr_mbox);
    scr = new(m_driv2scr_mbox,s_driv2scr_mbox,m_mon2scr_mbox,s_mon2scr_mbox,mon2cross_scr_mbox,master_cfg,slave_cfg);
    
    fork
      if(agent_status == ACTIVE) begin
        fork
          if(master_cfg.mode_sel == TX) gen.run();
          driv.run();
        join
      end
      if(master_cfg.mode_sel == TX) 
        m_mon.run();
      if(master_cfg.mode_sel == TX) scr.run();
    join
    
  endtask:run
  
endclass:i2s_master_agent