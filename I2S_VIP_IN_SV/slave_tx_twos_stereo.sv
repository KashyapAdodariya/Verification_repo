program automatic test_tb(i2s_intf intf);  
  i2s_config#(`size) master_cfg=new,slave_cfg=new;
  i2s_transaction tr=new(master_cfg);
  i2s_env env;
  initial begin
   
    env = new(intf,master_cfg,slave_cfg,tr);

    slave_cfg.chnl_mode=STEREO;
    master_cfg.repeat_gen=2;
    slave_cfg.complement=TWOS_COMPL;
    slave_cfg.word_len=`size;
    slave_cfg.mode_sel=RX;
    master_cfg.mode_sel=TX;

    
    master_cfg.print("MASTER_CONFIGURATION");
    slave_cfg.print("SLAVE_CONFIGURATION");


      `info("[---------------RUNNING TEST: SLAVE_TX_STEREO_TWOS_DATA_TRANSFER-------------------]",LOW);
   fork
      env.run();
    join_any
   disable fork;
    
  end
endprogram:test_tb



