class i2s_env;
  typedef enum {ON,OFF} status;
  virtual i2s_intf vif;
  i2s_master_agent m_agent;
  i2s_slave_agent s_agent;
  i2s_scoreboard_c scr;
  i2s_config master_cfg,slave_cfg;
  i2s_transaction tr;
  //need mailbox here only due to scr comman for both agent
  mailbox m_driv2scr_mbox;
  mailbox s_driv2scr_mbox;
  mailbox m_mon2scr_mbox;
  mailbox s_mon2scr_mbox;
  mailbox m_mon2cross_scr_mbox;
  mailbox s_mon2cross_scr_mbox;
  status env_scr = OFF;
  
  function new(virtual i2s_intf vif,i2s_config master_cfg,slave_cfg,i2s_transaction tr);
    this.vif = vif; 
    this.tr=tr;
    this.master_cfg=master_cfg;
    this.slave_cfg = slave_cfg;
	m_driv2scr_mbox=new;
	s_driv2scr_mbox=new;
	m_mon2scr_mbox=new;
	s_mon2scr_mbox=new;
    m_mon2cross_scr_mbox=new;
    s_mon2cross_scr_mbox=new;
    m_agent=new(vif,m_driv2scr_mbox,s_driv2scr_mbox,m_mon2scr_mbox,s_mon2scr_mbox,m_mon2cross_scr_mbox,master_cfg, slave_cfg,tr);
    s_agent=new(vif,m_driv2scr_mbox,s_driv2scr_mbox,m_mon2scr_mbox,s_mon2scr_mbox,s_mon2cross_scr_mbox,master_cfg,slave_cfg,tr);
    scr = new(m_mon2scr_mbox,s_mon2scr_mbox,m_mon2cross_scr_mbox,s_mon2cross_scr_mbox);
  endfunction

  task run();
    fork
      m_agent.run();
      s_agent.run();
      if(env_scr == OFF)  scr.run();      
    join
  endtask
  
endclass