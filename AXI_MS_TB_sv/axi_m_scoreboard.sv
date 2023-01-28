class scoreboard;

  transaction m_pkt=new;
  transaction d_pkt=new;
  
  
  //task to receive data from bfm & monitor and compare
  task run;
    forever begin
    //static mailbox
    $display("------------scoreboard running------------");
    axi_m_config::mon2score_mbox.get(m_pkt);
    $display("===packet received from monitor===");
    axi_m_config::bfm2score_mbox.get(d_pkt);
    $display("===packet received from bfm===");      
    //comparing rdata coming from slave dut with bfm rdata
  
      
    //loop to compare each beat data as per length
    foreach(d_pkt.TDATA[i] )begin
     //   $display("scb4");
   //   $display(d_pkt.TDATA);
    //  $display(m_pkt.TDATA);
      
      if(d_pkt.WSTRB[i][0]==1) begin   
        if(d_pkt.TDATA[i][7:0]!=m_pkt.TDATA[i][7:0]) begin
          $display("--- score --- dridata = %h --- mondata = %h",d_pkt.TDATA[i],m_pkt.TDATA[i]);
          $display("beat %0d : 0 to 7 bit is not matched",i); 
        end        
      else begin
        $display("RDATA is matched with DUT output");
        $display("--- score WIN --- dridata = %h --- mondata = %h",d_pkt.TDATA[i],m_pkt.TDATA[i]);
      end
    end
      
      
      if(d_pkt.WSTRB[i][1]==1) begin  
        if(d_pkt.TDATA[i][15:8]!=m_pkt.TDATA[i][15:8]) begin
          $display("beat %0d : 8 to 15 bit is not matched",i); 
        end
      else $display("RDATA is matched with DUT output");
    end
      
      
      if(d_pkt.WSTRB[i][2]==1) begin  
        if(d_pkt.TDATA[i][23:16]!=m_pkt.TDATA[i][23:16]) begin
          $display("beat %0d : 16 to 23 bit is not matched",i); 
        end
      else $display("RDATA is matched with DUT output");
    end
      
      
      if(d_pkt.WSTRB[i][3]==1) begin  
        if(d_pkt.TDATA[i][31:24]!=m_pkt.TDATA[i][31:24]) begin
          $display("beat %0d : 31 to 24 bit is not matched",i); 
        end
      else $display("RDATA is matched with DUT output");
    end
            
    end
   
    end
  endtask
endclass
  