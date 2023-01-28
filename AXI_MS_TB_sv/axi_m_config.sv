
class axi_m_config;
  
  //---for testcases---//
  static string testname = "2_WRITE_BACK_TO_BACK";
  
  //---mailbox handle for generator and driver(bfm)---//
  static mailbox gen2bfm_mbox=new();

  //---mailbox handle for driver and scoreboard ---//
  static mailbox bfm2score_mbox=new();
  
  //---mailbox handle for monitor and score board---//
  static mailbox mon2score_mbox=new();
  
  //---virtul interface handle---//
  static virtual axi_intf vif;
  
  //---for count no of read and write transaction---//
  static int no_wx_tx;
  static int no_rx_tx;
  
  //---for verbosity---// 
  static bit[1:0] verb = 0;
endclass
  
