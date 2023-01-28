class axi_m_dri; 
  virtual axi_intf vif;
  transaction pkt = new,pktQ[$];
  int looping_var;//looping_var
  task run();

     
    //--- assigning virtual interface to config class interface ---
    vif=axi_m_config::vif;

    //--- asserting all zero initially ---
    vif.master_mp.master_cb.AWLEN<=0;
    vif.master_mp.master_cb.AWBURST<=0;
    vif.master_mp.master_cb.AWSIZE<=0;
    vif.master_mp.master_cb.AWVALID<=0;
    vif.master_mp.master_cb.WID<=0;
    vif.master_mp.master_cb.WDATA<=0;
    vif.master_mp.master_cb.WSTRB<=0;
    vif.master_mp.master_cb.WLAST<=0;
    vif.master_mp.master_cb.AWID<=0;
    vif.master_mp.master_cb.AWADDR<=0;
    vif.master_mp.master_cb.WVALID<=0;
    vif.master_mp.master_cb.BREADY<=0;
    vif.master_mp.master_cb.ARID<=0;
    vif.master_mp.master_cb.ARADDR<=0;
    vif.master_mp.master_cb.ARSIZE<=0;
    vif.master_mp.master_cb.ARBURST<=0;
    vif.master_mp.master_cb.ARVALID<=0;
    vif.master_mp.master_cb.RREADY<=0;
    if(axi_m_config::verb>1)begin
      $display("-------------axi master driver run-------------");
    end
   
    
    //--- fork for to simaltaniously start mailbox and driving signals ---
    fork
      //--- getting data from mailbox ---
      begin
        forever begin
          axi_m_config::gen2bfm_mbox.get(pkt);
          axi_m_config::bfm2score_mbox.put(pkt);
          pktQ.push_back(pkt);
          //if(axi_m_config::verb>1)begin
            pkt.print_f();
          //end
        end//forever for mailbox
        
      end//fork for mailbox 
      
      //--- fork begin for driving signals ---
      begin
        /*--------------------------
          Ready signals to be drived
          write resp: BREADY,
          read data : RREADY;
          --------------------------
        */
        vif.master_mp.master_cb.BREADY<=1;
        vif.master_mp.master_cb.RREADY<=1;
        
        //--- for each queue member(packets) ---
        foreach(pktQ[j]) begin
          
          if(axi_m_config::verb>1)begin
            $display("loop no = %0d pkt=%0d",j,pktQ[j]);
          end
          
          /*-----------------------------------------------------------
          ADDR channel logic 3 cases through this ifelse coverd 
          1)if we have read/write togather current and next pkt then process them togather
          2)if we have read/write togather current and previous then, 
            do nothing because processed earlier
          3)only single transaction
          -------------------------------------------------------------
          */
          
          //--- case 1 of 3 ---
          if(pktQ[j+1] != null && pktQ[j].UID==pktQ[j+1].UID) begin
            if(axi_m_config::verb>1)begin
              $display("case : Read/Write togather.");
            end
            
            //--- simaltaniously call read/write task for driving intf ---
            fork
              begin
                drive_intf_addr(pktQ[j]);
              end
              begin
                drive_intf_addr(pktQ[j]);
              end
            join
            
            //--- simaltaniously driving data and valid=0 of addr ---
            fork
              begin
                @(posedge vif.ACLK);
                vif.master_mp.master_cb.AWVALID<=0;
                vif.master_mp.master_cb.ARVALID<=0;
              end//fork
              begin
                if(pktQ[j].rw==1) begin
                  drive_intf_data(pktQ[j]);
                end//if(pktQ[i].rw==1)
                else begin
                  drive_intf_data(pktQ[j+1]);
                end//else block of if(pktQ[i].rw==1)
              end//fork
            join //fork add_chnl logic
            
          end //if of case 1 of 3
          
          //--- case of case 2 of 3 ---
          else if (j!=0 && pktQ[j-1].UID==pktQ[j].UID) begin
              if(axi_m_config::verb>1)begin
                $display("looped for write/read.");
              end
          end
          
          //--- case of case 3 of 3 ---
          else begin
            
            drive_intf_addr(pktQ[j]);
            
            //--- simaltaniously driving data and valid=0 of addr ---
            fork
              begin
                @(posedge vif.ACLK);
                //vif.master_mp.master_cb.AWVALID<=0;
                //vif.master_mp.master_cb.ARVALID<=0;
              end//fork
              begin
                drive_intf_data(pktQ[j]);  
              end//fork
            join
            
          end//if of case 3 of 3
          
        end//for each queue member(packets)
        
      end//fork of assertions
      
    join//fork for mailbox and assertions
    
  endtask
  
  //----------------------------TASK-----------------------------------
  //--- Task that will assert the data signals to the interface after calling ---
  task drive_intf_data(transaction pkt);
    /*-------------------------------------------
      output signals to be drived
      write data: WID,WDATA,WSTRB,WLAST,WVALID,
      -------------------------------------------
    */
    if(pkt.rw==1)begin//rw=1 is WRITE
      vif.master_mp.master_cb.WID<=pkt.ATID;//ID
      foreach(pkt.TDATA[i])begin
        vif.WDATA<=pkt.TDATA[i];//data
        vif.WSTRB<=pkt.WSTRB[i];//strob
        if(pkt.ATLEN==i) begin
          vif.WLAST<=1;
        end
        vif.WVALID<=1;
        
        //--- wait for next posedge for next data ---
        //wait(vif.WREADY) @(posedge vif.ACLK);
        
        //-------------------------------------------------------
        //-------------------------------------------------------
        //vif.WVALID <= 1'bz;//done for chacking hase to be removed
        //-------------------------------------------------------
        //-------------------------------------------------------
        
        @(posedge vif.ACLK);
      end//foreach end
      vif.WVALID<=0;
      vif.WLAST<=0;
      if(axi_m_config::verb>1)begin
        $display("write data channel for UID = %0d WRITE DATA transaction done.",pkt.UID);
      end
      
    end//if end
    else if (pkt.rw==0)begin//rw=1 is READ
      wait(vif.master_mp.master_cb.RLAST);
      @(posedge vif.ACLK);
    end
  endtask
  
  //----------------------------TASK-----------------------------------
  //--- Task that will assert the addr signals to the interface after calling ---
  task drive_intf_addr(transaction pkt);
    
  /*---------------------------------------------------
    output signals to be drived
    write addr: AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID,
    read addr : ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID
    ---------------------------------------------------
  */
    if (pkt.rw==0) begin//which is READ
      //--- read addr channel ---
      vif.master_mp.master_cb.ARID<=pkt.ATID;
      vif.master_mp.master_cb.ARADDR<=pkt.ATADDR;
      vif.master_mp.master_cb.ARLEN<=pkt.ATLEN;
      vif.master_mp.master_cb.ARSIZE<=pkt.ATSIZE;
      vif.master_mp.master_cb.ARBURST<=pkt.ATBURST;
      vif.master_mp.master_cb.ARVALID<=1;
      
      //--- valid=1 at posedge ---
      forever begin
        @(posedge vif.ACLK);
        if(vif.master_mp.master_cb.ARREADY==1) begin
          break;
        end
      end
      //wait(vif.master_mp.master_cb.ARREADY);
      //@(posedge vif.ACLK);
      
      vif.master_mp.master_cb.ARVALID<=0;
      if(axi_m_config::verb>1)begin
        $display("address channel for UID = %0d READ transaction done.",pkt.UID);
      end
    end
    else if (pkt.rw==1) begin//which is WRITE
      //--- write addr channel ---
      vif.master_mp.master_cb.AWID<=pkt.ATID;
      vif.master_mp.master_cb.AWADDR<=pkt.ATADDR;
      vif.master_mp.master_cb.AWLEN<=pkt.ATLEN;
      vif.master_mp.master_cb.AWSIZE<=pkt.ATSIZE;
      vif.master_mp.master_cb.AWBURST<=pkt.ATBURST;
      vif.master_mp.master_cb.AWVALID<=1;
      
      //--- valid=1 at posedge ---
      forever begin
        @(posedge vif.ACLK);
        if(vif.master_mp.master_cb.AWREADY==1) begin
          break;
        end
      end
      //wait(vif.master_mp.master_cb.AWREADY);
      //@(posedge vif.ACLK);
      vif.master_mp.master_cb.AWVALID<=0;
      
      if(axi_m_config::verb>1)begin
        $display("address channel for UID = %0d WRITE transaction done.",pkt.UID);
      end
    end
  endtask
endclass : axi_m_dri