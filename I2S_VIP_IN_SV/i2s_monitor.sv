

/* Revision: 2
-------------------------------------------------------------------------------*/
`define vif vif.monitor_mp
class i2s_monitor;
  int diff;
  int word_length;
  i2s_config master_cfg,slave_cfg;
  i2s_transaction mst_trans;
  virtual i2s_intf vif;

//declaring 2 mailbox one for master one for slave
  mailbox m_mon2scr_mbox;       
  mailbox s_mon2scr_mbox;
  
//copying all the handles  
  
  function new(virtual i2s_intf vif,i2s_config master_cfg,slave_cfg,mailbox m_mon2scr_mbox,s_mon2scr_mbox);
    this.vif=vif;
 
    this.m_mon2scr_mbox=m_mon2scr_mbox;
    this.s_mon2scr_mbox=s_mon2scr_mbox;
    this.master_cfg=master_cfg;
    this.slave_cfg = slave_cfg;
  endfunction
  
  
  
  task run();
    
    
        if(master_cfg.mode_sel == TX)begin 
          word_length= slave_cfg.word_len;
        end
        
        else if (slave_cfg.mode_sel == TX)begin
          word_length=master_cfg.word_len;
        end
        
        if(master_cfg.mode_sel == TX) begin
          repeat (master_cfg.repeat_gen) begin
            mst_trans=new(master_cfg);
            if(master_cfg.chnl_mode == MONO_RIGHT)begin       // calling mono right 
              mon_mono_right(master_cfg,slave_cfg);
            end
            else if(master_cfg.chnl_mode == MONO_LEFT)begin
              mon_mono_left(master_cfg,slave_cfg);					// calling mono left task
            end
            else if(master_cfg.chnl_mode == STEREO)begin
              mon_stereo(master_cfg,slave_cfg);					// calling stereo task
            end
            else begin
              $display("------------Please select valid channel mode in config class----------");
            end
          end
        end
    
    else if(slave_cfg.mode_sel == TX) begin
      repeat (slave_cfg.repeat_gen) begin												
        mst_trans=new(slave_cfg);
        if(slave_cfg.chnl_mode == MONO_RIGHT)begin       // calling mono right task
          mon_mono_right(master_cfg,slave_cfg);
        end
        else if(slave_cfg.chnl_mode == MONO_LEFT)begin
          mon_mono_left(master_cfg,slave_cfg);					// calling mono left task
        end
        else if(slave_cfg.chnl_mode == STEREO)begin
          mon_stereo(master_cfg,slave_cfg);					// calling stereo task
        end
        else begin
          $display("------------Please select valid channel mode in config class----------");
        end
      end
    end
  endtask:run
  
  
  task mon_mono_right(input i2s_config master_cfg,slave_cfg);
    
      wait(`vif.WS == 1);
    
    if(master_cfg.mode_sel == TX) begin
      if(slave_cfg.word_len >master_cfg.word_len)
        word_length=master_cfg.word_len;
    end
    
    if(slave_cfg.mode_sel == TX) begin
      if(master_cfg.word_len > slave_cfg.word_len)
        word_length=slave_cfg.word_len;
    end
    
    for(int i=(word_length)-1;i>=0;i--)begin
        @(`edge_clk `vif.SCK);
        @(negedge `vif.SCK);
        mst_trans.data[i] = `vif.sd_out;
    end
  
    if(master_cfg.mode_sel == TX) begin
      if(master_cfg.word_len > slave_cfg.word_len) begin
          diff = master_cfg.word_len - slave_cfg.word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
      
    if(slave_cfg.mode_sel == TX) begin
      if(slave_cfg.word_len > master_cfg.word_len) begin
          diff = slave_cfg.word_len - master_cfg.word_len;
          for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        end
      end
      
      mst_trans.print("monitor data");
    if(master_cfg.mode_sel == TX)begin 
         m_mon2scr_mbox.put(mst_trans);
      end
     
    else if (slave_cfg.mode_sel == TX)begin
        s_mon2scr_mbox.put(mst_trans);
      end
      @(`edge_clk `vif.SCK);

  endtask
  
  
  task mon_mono_left(input i2s_config master_cfg,slave_cfg);   
    
 
    wait(`vif.WS == 0);
    if(master_cfg.mode_sel == TX) begin
      if(slave_cfg.word_len >master_cfg.word_len)     
          word_length=master_cfg.word_len;
    end
     
     
    if(slave_cfg.mode_sel == TX) begin
      if(master_cfg.word_len > slave_cfg.word_len)
          word_length=slave_cfg.word_len;
    end
      
     
    for(int i=(word_length)-1;i>=0;i--)begin
        @(`edge_clk `vif.SCK);
        @(negedge `vif.SCK);
        mst_trans.data[i] = `vif.sd_out;
    end
  
    if(master_cfg.mode_sel == TX) begin
      if(master_cfg.word_len > slave_cfg.word_len) begin
          diff = master_cfg.word_len - slave_cfg.word_len;
        for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
        @(`edge_clk `vif.SCK);
        end
    end
     
    if(slave_cfg.mode_sel == TX) begin
      if(slave_cfg.word_len > master_cfg.word_len) begin
          diff = slave_cfg.word_len - master_cfg.word_len;
        for(int k=0; k<diff; k++) begin
            @(`edge_clk `vif.SCK);
          end
         @(`edge_clk `vif.SCK);
        end
    end
    
    mst_trans.print("monitor data");
    if(master_cfg.mode_sel == TX)begin 
         m_mon2scr_mbox.put(mst_trans);
      
      end
     
     if (slave_cfg.mode_sel == TX)begin
        s_mon2scr_mbox.put(mst_trans);
      end
        @(`edge_clk `vif.SCK);
  endtask
  
  
  
  task mon_stereo(input i2s_config master_cfg,slave_cfg);

    
    if(master_cfg.mode_sel == TX) begin						
      if(slave_cfg.word_len >master_cfg.word_len)begin
            word_length=master_cfg.word_len;
      end
    end
        
    if(slave_cfg.mode_sel == TX) begin
      if(master_cfg.word_len > slave_cfg.word_len)
            word_length=slave_cfg.word_len;
    end
      
    
      fork  
        begin:th1
          wait(`vif.WS==1);
          
          for(int i=(word_length)-1;i>=0;i--)begin
            @(`edge_clk `vif.SCK);
            @(negedge `vif.SCK);
            mst_trans.data[i] = `vif.sd_out;
          end 
          
          if(master_cfg.mode_sel == TX) begin
            if(master_cfg.word_len > slave_cfg.word_len) begin
              diff = master_cfg.word_len - slave_cfg.word_len;
              for(int k=0; k<diff; k++) begin
                @(`edge_clk `vif.SCK);
              end
                @(negedge `vif.SCK);
            end
          end
          
          if(slave_cfg.mode_sel == TX) begin
            if(slave_cfg.word_len > master_cfg.word_len) begin
              diff = slave_cfg.word_len - master_cfg.word_len;
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
            mst_trans.data[(2*`size-1)-i] = `vif.sd_out;
          end
        
        end :th2

  
      join    
      mst_trans.print("monitor data");
     if(master_cfg.mode_sel == TX)begin 
         m_mon2scr_mbox.put(mst_trans);
      end
     
    else if (slave_cfg.mode_sel == TX)begin
        s_mon2scr_mbox.put(mst_trans);
      end
    
  endtask:mon_stereo
  
endclass:i2s_monitor




/*
checker my_check(logic WS);

property w_s;
@(posedge `vif.SCK) `vif.WS |-> ##(monitor_cfg.config_ration) ~`vif.WS;
endproperty

assert property(my_check);


endchecker


*/




