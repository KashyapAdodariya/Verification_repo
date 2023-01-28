

/* Revision: 2
-------------------------------------------------------------------------------*/

`define vif intf.slave_drv_mp

///-----------------------------I2S Slave Driver------------------------------/
class i2s_slave_driver;
  
  //INTERFACE DEFINE  
  virtual i2s_intf intf;
  
  i2s_transaction pkt,pkt1,pktQ[$]; 
  
  //Config handle
  i2s_config slave_cfg;
  
  //MAILBOX GENERATOR TO DRIVER
  mailbox gen2driv_mbox;
  
  //MAILBOX DRIVER TO SCB
  mailbox s_driv2scr_mbox;
  
  int count;
  
  //CONNECTING MAILBOX
  function new(virtual i2s_intf intf, mailbox gen_mbox, mailbox driv_mbox, i2s_config slave_cfg);
    this.gen2driv_mbox = gen_mbox;
    this.s_driv2scr_mbox = driv_mbox;
    this.intf = intf;
    this.slave_cfg = slave_cfg;
  endfunction:new
  
  ///---------------------------Declare Run Task------------------------------/
  extern task run();
    
endclass:i2s_slave_driver
    
  /////////////////////////////////////////////////////////////////
  // Method name        : task run_rx();
  // Parameter Passed   : none  
  // Returned parameter : none
  // Description        : drive WS in rx mode. run only in posedge
  /////////////////////////////////////////////////////////////////
    
    
  task i2s_slave_driver::run;
    `info("\t\t\tSLAVE DRIVER RUNING\t\t\t",LOW);
    forever begin
      //Get the packet from mailbox
      gen2driv_mbox.get(pkt1);
      if(pkt1==null) begin
        `error("Null packet detect in slave driver",HIGH);
        $stop;
      end
      //put packet into queue
      pktQ.push_back(pkt1);  
      //put packet into driver to scr mailbox
      s_driv2scr_mbox.put(pkt1);
      
      if(slave_cfg.mode_sel == TX) begin
        pkt = pktQ.pop_front();          
        wait(`vif.WS == 0);
        
        if(slave_cfg.chnl_mode == MONO_LEFT || slave_cfg.chnl_mode == STEREO && `vif.reset==1) begin
          for(int i=$size(pkt.data)-1; i >= $size(pkt.data)/2; i--) begin
            if(`vif.reset==1) begin
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= pkt.data[i];
            end
            else begin
              `info("\n RESET ON \n",LOW);
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= 0;
            end
          end
        end
          
        else if(slave_cfg.chnl_mode == MONO_RIGHT) begin
          for(int i=($size(pkt.data)/2)-1; i >= 0; i--) begin
            if(`vif.reset==1) begin
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= pkt.data[i];
            end
            else begin
              `info("\n RESET ON \n",LOW);
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= 0;
            end
          end
        end
                    
        wait(`vif.WS == 1); 
        
        if(slave_cfg.chnl_mode == MONO_RIGHT || slave_cfg.chnl_mode == STEREO) begin
          for(int i=($size(pkt.data)/2)-1; i >= 0; i--) begin
           if(`vif.reset==1) begin
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= pkt.data[i];
            end
            else begin
              `info("\n RESET ON \n",LOW);
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= 0;
            end
          end
        end 
          
        else if(slave_cfg.chnl_mode == MONO_LEFT) begin
          for(int i=$size(pkt.data)-1; i >= $size(pkt.data)/2; i--) begin
            if(`vif.reset==1) begin
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= pkt.data[i];
            end
            else begin
              `info("\n RESET ON \n",LOW);
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= 0;
            end
          end           
        end
        
      end
    end
  endtask