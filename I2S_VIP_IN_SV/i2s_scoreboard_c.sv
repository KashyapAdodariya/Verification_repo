

/* Revision: 2
-------------------------------------------------------------------------------*/

class i2s_scoreboard_c;
  
  i2s_transaction s_pkt;
  i2s_transaction m_pkt;
  
  //MAILBOX MASTER MONITOR TO SCOREBOARD
  mailbox m_mon2scr_mbox; 
  mailbox m_mon2cross_scr_mbox;
  mailbox s_mon2cross_scr_mbox;
  
  //MAILBOX SLAVE MONITOR TO SCOREBOARD
  mailbox s_mon2scr_mbox;
  
  function new(mailbox m_mon2scr_mbox,s_mon2scr_mbox,m_mon2cross_scr_mbox,s_mon2cross_scr_mbox);
    this.m_mon2cross_scr_mbox=m_mon2cross_scr_mbox;
    this.s_mon2cross_scr_mbox=s_mon2cross_scr_mbox; 
    this.s_mon2scr_mbox = s_mon2scr_mbox;
    this.m_mon2scr_mbox = m_mon2scr_mbox;    
    
  endfunction
  
  /*---------------------------SCOREBOARD Tasks------------------------------*/
  extern task run();
  
endclass

  task i2s_scoreboard_c::run();
      
    `info("\t\t\tSCOREBOARD RUNING\t\t\t",LOW);
    forever begin
      int temp_a,temp_b,temp_c,temp_d;
      m_mon2cross_scr_mbox.get(temp_a);
      
      temp_c = temp_a;
      s_mon2cross_scr_mbox.get(temp_b);
      temp_d = temp_b;
      
      if(temp_c==temp_d) begin
        `info("------Cross Monitor data PASS  ------",LOW);
      end
      else begin
        `error("------Cross Monitor data FAIL  ------",LOW);
        $stop;
      end
      
      
    end
  endtask