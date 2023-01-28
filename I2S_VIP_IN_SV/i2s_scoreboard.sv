	


/* Revision: 2
-------------------------------------------------------------------------------*/


/*-----------------------------I2S Scoreboard------------------------------*/
class i2s_scoreboard;
  
  //int mvar;
  //Config handle
  i2s_config master_cfg,slave_cfg;
  
  //Transaction class instance
  i2s_transaction d_pkt;
  i2s_transaction m_pkt;
  
  //MAILBOX MASTER DRIVER TO SCOREBOARD
  mailbox m_driv2scr_mbox;
  
  //MAILBOX SLAVE DRIVER TO SCOREBOARD
  mailbox mon2cross_scr_mbox;
  mailbox s_driv2scr_mbox;
  
  //MAILBOX MASTER MONITOR TO SCOREBOARD
  mailbox m_mon2scr_mbox;
  
  //MAILBOX SLAVE MONITOR TO SCOREBOARD
  mailbox s_mon2scr_mbox;
  
  int count;
  
  //CONNECTING MAILBOX
  function new(mailbox m_driv2scr_mbox,s_driv2scr_mbox,m_mon2scr_mbox,s_mon2scr_mbox,mon2cross_scr_mbox,i2s_config master_cfg,slave_cfg);
    
    this.master_cfg = master_cfg;
    this.slave_cfg = slave_cfg;
    this.mon2cross_scr_mbox=mon2cross_scr_mbox;
    this.m_driv2scr_mbox = m_driv2scr_mbox;
    this.s_mon2scr_mbox = s_mon2scr_mbox;
    this.s_driv2scr_mbox = s_driv2scr_mbox;
    this.m_mon2scr_mbox = m_mon2scr_mbox;    
    
  endfunction
  
  /*---------------------------SCOREBOARD Tasks------------------------------*/
  extern task run();
  extern task run_master_tx();
  extern task run_slave_tx();
  
endclass
    
    
  ////////////////////////////////////////////////////////////////////////////////
  // Method name         : run task
  // Parameters passed   : none
  // Returned parameters : none
  // Description         : slave rx and master tx mode based on channel mode 
  ////////////////////////////////////////////////////////////////////////////////
   

  task i2s_scoreboard::run();
    `info("\t\t\tSCOREBOARD RUNING\t\t\t",LOW);
    forever begin

      if(master_cfg.mode_sel == TX) begin  
        
        run_master_tx();
      end
      else if(slave_cfg.mode_sel == TX) begin  
        run_slave_tx();
      end
     end
  endtask
      
        
    task i2s_scoreboard::run_master_tx();    
      int mvar;
         int flag = 1;
         bit [(`size*2)-1: 0] temp_array;
         int diff;
       
         m_driv2scr_mbox.get(d_pkt);   
         if(d_pkt==null) begin 
           `error("------Object is null not received packet from monitor side  ------",HIGH);
         end
       
         m_mon2scr_mbox.get(m_pkt);
         if(m_pkt==null) begin 
           `error("------Object is null not received packet from driver side  ------",HIGH);
         end
       
           
        if (master_cfg.word_len == slave_cfg.word_len) begin
           
           if(master_cfg.chnl_mode == MONO_RIGHT) begin
             for(int i=(2*`size)-1; i >= 0  ; i--) begin
               if(i < master_cfg.word_len) begin
               temp_array[i] = d_pkt.data[i];
               end
               else begin 
                 temp_array[i] = 0;
               end
             end
             

             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Right channel data pass------",LOW);
             end
             
             else begin
               `fatal("------Mono mode Right channel data fail------",LOW);
               flag=0;
               $finish();
             end
             
           end
           
           else if(master_cfg.chnl_mode == MONO_LEFT) begin
            
             for(int i=(2*`size)-1; i >= master_cfg.word_len  ; i--) begin
               temp_array[i - master_cfg.word_len] = d_pkt.data[i];
             end
             
             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Left channel data pass------",LOW);
             end
             
             else begin 
               `fatal("------Mono mode Left channel data fail------",LOW);
               flag=0;
               $finish();
             end
           end
           
           else if(master_cfg.chnl_mode == STEREO) begin
            
             if(m_pkt.data == d_pkt.data) begin
               `info("------Stereo mode right and left channel data pass------",LOW);
             end
             
             else begin
               `fatal("------Stereo mode right and left channel data fail-------",LOW);
               flag=0;
               $finish();
             end
             
           end
           count++;
           
           if(count== master_cfg.repeat_gen && flag==0) begin
             `info("------TESTCASE FAIL------",LOW);
             mvar = flag;
             mon2cross_scr_mbox.put(mvar);
           end
           else if(count == master_cfg.repeat_gen && flag==1) begin
             `info("------TESTCASE PASS------",LOW);
             mvar = flag;
             mon2cross_scr_mbox.put(mvar);
             $finish();
           end
     
         end
        
        
         else if(master_cfg.word_len > slave_cfg.word_len) begin
     
           if(master_cfg.chnl_mode == MONO_RIGHT) begin
             diff = master_cfg.word_len - slave_cfg.word_len;
             for(int i=1; i <=diff ; i++) begin
               temp_array[diff - i] = d_pkt.data[(2*`size)/2-i];
             end

             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Right channel data pass------",LOW);
             end
             
             else begin
               `fatal("------Mono mode Right channel data fail------",LOW);
               flag=0;
               $finish();
             end
           end
           
           else if(master_cfg.chnl_mode == MONO_LEFT) begin
             
             diff = master_cfg.word_len - slave_cfg.word_len;
             for(int i=1; i <=diff ; i++) begin
               temp_array[diff - i] = d_pkt.data[(2*`size)-i];
             end
             
             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Left channel data pass------",LOW);
             end
             
             else begin 
               `fatal("------Mono mode Left channel data fail------",LOW);
               flag=0;
               $finish();
             end
           end
           
           else if(master_cfg.chnl_mode == STEREO) begin
             
             
             diff = master_cfg.word_len - slave_cfg.word_len;
             for(int i=1; i <=diff ; i++) begin
               temp_array[diff - i] = d_pkt.data[(2*`size)/2-i];
             end
             for(int i=1; i <=diff ; i++) begin
               temp_array[(2*`size) - i] = d_pkt.data[(2*`size)-i];
             end
             

             if(m_pkt.data == temp_array ) begin
               `info("------Stereo mode right and left channel data pass------",LOW);
             end
             
             else begin
               `fatal("------Stereo mode right and left channel data fail------",LOW);
               flag=0;
               $finish();
             end
             
           end
           count++;
         
           if(count== master_cfg.repeat_gen && flag==0) begin
             `info("------TESTCASE FAIL------",LOW);
             mvar = flag;
             mon2cross_scr_mbox.put(mvar);
           end
           else if(count == master_cfg.repeat_gen && flag==1) begin
             `info("------TESTCASE PASS------",LOW);
             mvar = flag;
             mon2cross_scr_mbox.put(mvar);
             $finish();
           end
         end
       
       
         else if(master_cfg.word_len < slave_cfg.word_len) begin
     
           if(master_cfg.chnl_mode == MONO_RIGHT) begin
             diff = slave_cfg.word_len - master_cfg.word_len ;
         
             for(int i=slave_cfg.word_len - diff; i >= 0 ; i--) begin
               temp_array[i] = d_pkt.data[i];
             end
             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Right channel data pass------",LOW);
             end
             
             else begin
               `fatal("------Mono mode Right channel data fail------",LOW);
               flag=0;
               $finish();
             end
           end
           
           else if(master_cfg.chnl_mode == MONO_LEFT) begin
             diff = slave_cfg.word_len - master_cfg.word_len ;
         
             for(int i=(2*`size)-1; i >= master_cfg.word_len  ; i--) begin
               temp_array[i - master_cfg.word_len] = d_pkt.data[i];
             end
             
             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Left channel data pass------",LOW);
             end
             
             else begin 
               `fatal("------Mono mode Left channel data fail------",LOW);
               flag=0;
               $finish();
             end
           end
           
           else if(master_cfg.chnl_mode == STEREO) begin
             
             if(m_pkt.data == d_pkt.data) begin
               `info("-----Stereo mode right and left channel data pass------",LOW);
             end
             
             else begin
               `fatal("------Stereo mode right and left channel data fail------",LOW);

               flag=0;
             end
             
           end
           count++;
           
           if(count== master_cfg.repeat_gen && flag==0) begin
             `info("------TESTCASE FAIL------",LOW);
              mvar = flag;
             mon2cross_scr_mbox.put(mvar);
           end
           else if(count == master_cfg.repeat_gen && flag==1) begin
             `info("------TESTCASE PASS------",LOW);
              mvar = flag;
             mon2cross_scr_mbox.put(mvar);
             $finish();
           end
         end
         
  endtask
      
      
  task i2s_scoreboard::run_slave_tx();  
    int mvar;
         int flag = 1;
         bit [(`size*2)-1: 0] temp_array;
         int diff;
       
         s_driv2scr_mbox.get(d_pkt);   
         if(d_pkt==null) begin 
           `error("------Object is null not received packet from monitor side  ------",HIGH);
         end
       
         s_mon2scr_mbox.get(m_pkt);
         if(m_pkt==null) begin 
           `error("------Object is null not received packet from driver side  ------",HIGH);
         end
       
           
        if (master_cfg.word_len == slave_cfg.word_len) begin
           
           if(master_cfg.chnl_mode == MONO_RIGHT) begin
             for(int i=(2*`size)-1; i >= 0  ; i--) begin
               if(i < master_cfg.word_len) begin
               temp_array[i] = d_pkt.data[i];
               end
               else begin 
                 temp_array[i] = 0;
               end
             end
             

             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Right channel data pass------",LOW);
             end
             
             else begin
               
               `fatal("------Mono mode Right channel data fail------",LOW);
               flag=0;
               $finish();
             end
             
           end
           
           else if(slave_cfg.chnl_mode == MONO_LEFT) begin
            
             for(int i=(2*`size)-1; i >= master_cfg.word_len  ; i--) begin
               temp_array[i - master_cfg.word_len] = d_pkt.data[i];
             end
             
             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Left channel data pass------",LOW);
             end
             
             else begin 
               `fatal("------Mono mode Left channel data fail------",LOW);
               flag=0;
               $finish();
             end
           end
           
          else if(slave_cfg.chnl_mode == STEREO) begin
            
             if(m_pkt.data == d_pkt.data) begin
               `info("------Stereo mode right and left channel data pass------",LOW);
             end
             
             else begin
               `fatal("------Stereo mode right and left channel data fail-------",LOW);
               flag=0;
               $finish();
             end
             
           end
           count++;
           
         
           if(count== slave_cfg.repeat_gen && flag==0) begin
             `info("------TESTCASE FAIL------",LOW);
              mvar = flag;
             mon2cross_scr_mbox.put(mvar);
           end
           else if(count == slave_cfg.repeat_gen && flag==1) begin
             `info("------TESTCASE PASS------",LOW);
              mvar = flag;
              mon2cross_scr_mbox.put(mvar);
              $finish();
           end
     
         end
        
        
         else if(master_cfg.word_len > slave_cfg.word_len) begin
     
           if(slave_cfg.chnl_mode == MONO_RIGHT) begin
             diff = master_cfg.word_len - slave_cfg.word_len;
             for(int i=1; i <=diff ; i++) begin
               temp_array[diff - i] = d_pkt.data[(2*`size)/2-i];
             end

             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Right channel data pass------",LOW);
             end
             
             else begin
               `fatal("------Mono mode Right channel data fail------",LOW);
               flag=0;
               $finish();
             end
           end
           
           else if(slave_cfg.chnl_mode == MONO_LEFT) begin
             
             diff = master_cfg.word_len - slave_cfg.word_len;
             for(int i=1; i <=diff ; i++) begin
               temp_array[diff - i] = d_pkt.data[(2*`size)-i];
             end
             
  
             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Left channel data pass------",LOW);
             end
             
             else begin 
               `fatal("------Mono mode Left channel data fail------",LOW);
               flag=0;
               $finish();
             end
           end
           
           else if(slave_cfg.chnl_mode == STEREO) begin

             if(m_pkt.data == d_pkt.data ) begin
               `info("------Stereo mode right and left channel data pass------",LOW);
             end
             
             else begin
               `fatal("------Stereo mode right and left channel data fail------",LOW);
               flag=0;
               $finish();
             end
             
           end
           count++;
         
           if(count== slave_cfg.repeat_gen && flag==0) begin
             `info("------TESTCASE FAIL------",LOW);
              mvar = flag;
             mon2cross_scr_mbox.put(mvar);
           end
           else if(count == slave_cfg.repeat_gen && flag==1) begin
             `info("------TESTCASE PASS------",LOW);
              mvar = flag;
             mon2cross_scr_mbox.put(mvar);
             $finish();
           end
         end
       
       
         else if(master_cfg.word_len < slave_cfg.word_len) begin
     
           if(master_cfg.chnl_mode == MONO_RIGHT) begin
             diff = slave_cfg.word_len - master_cfg.word_len ;
         
             for(int i=slave_cfg.word_len - diff; i >= 0 ; i--) begin
               temp_array[i] = d_pkt.data[i];
             end
             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Right channel data pass------",LOW);
             end
             
             else begin
               `fatal("------Mono mode Right channel data fail------",LOW);
               flag=0;
               $finish();
             end
           end
           
           else if(slave_cfg.chnl_mode == MONO_LEFT) begin
             diff = slave_cfg.word_len - master_cfg.word_len ;
         
             for(int i=slave_cfg.word_len - diff; i >= 0 ; i--) begin
               temp_array[i] = d_pkt.data[(2*`size)-i];
             end

             if(m_pkt.data == temp_array) begin
               `info("------Mono mode Left channel data pass------",LOW);
             end
             
             else begin 
               `fatal("------Mono mode Left channel data fail------",LOW);
               flag=0;
               $finish();
             end
           end
           
           else if(slave_cfg.chnl_mode == STEREO) begin
             
             diff = slave_cfg.word_len - master_cfg.word_len;
             for(int i=1; i <=diff ; i++) begin
               temp_array[diff - i] = d_pkt.data[(2*`size)/2-i];
             end
             for(int i=1; i <=diff ; i++) begin
               temp_array[(2*`size) - i] = d_pkt.data[(2*`size)-i];
             end
             
             if(m_pkt.data == temp_array) begin
               `info("-----Stereo mode right and left channel data pass------",LOW);
             end
             
             else begin
               `fatal("------Stereo mode right and left channel data fail------",LOW);

               flag=0;
               $finish();
             end
             
           end
           count++;
           
           if(count== slave_cfg.repeat_gen && flag==0) begin
             `info("------TESTCASE FAIL------",LOW);
              mvar = flag;
             mon2cross_scr_mbox.put(mvar);
           end
           else if(count == slave_cfg.repeat_gen && flag==1) begin
             `info("------TESTCASE PASS------",LOW);
              mvar = flag;
             mon2cross_scr_mbox.put(mvar);
             $finish();
           end
         end
         
  endtask