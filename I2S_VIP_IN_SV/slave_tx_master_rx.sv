program automatic test_tb(i2s_intf intf);
  i2s_config master_cfg,slave_cfg;
  i2s_env env;
  i2s_transaction tr=new(slave_cfg);
  
  initial begin
    master_cfg=new();
    slave_cfg = new();

    env = new(intf,master_cfg,slave_cfg,tr);
    slave_cfg.chnl_mode=STEREO;
    slave_cfg.repeat_gen=2;
    slave_cfg.complement=NORMAL;
    master_cfg.word_len=WLEN16;
    slave_cfg.mode_sel=TX;
    master_cfg.mode_sel=RX;
     master_cfg.print("MASTER_CONFIGURATION");
    slave_cfg.print("SLAVE_CONFIGURATION");

    `info("==================================RUNNING TEST:SLAVE TX(STEREO) MASTER RX==================================",LOW);

    fork
      env.run();
    join_any
    disable fork;
  end
endprogram :test_tb