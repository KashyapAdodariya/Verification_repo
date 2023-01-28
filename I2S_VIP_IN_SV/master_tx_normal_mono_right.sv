program automatic test_tb(i2s_intf intf);
  i2s_config master_cfg,slave_cfg;
  i2s_env env;
  i2s_transaction tr=new(master_cfg);
  initial begin
    master_cfg=new();
    slave_cfg = new();

    env = new(intf,master_cfg,slave_cfg,tr);
    master_cfg.chnl_mode=MONO_RIGHT;
    master_cfg.repeat_gen=2;
    master_cfg.complement=NORMAL;
    master_cfg.word_len=WLEN16;
    slave_cfg.mode_sel=RX;
    master_cfg.mode_sel=TX;
     master_cfg.print("MASTER_CONFIGURATION");
    slave_cfg.print("SLAVE_CONFIGURATION");

    `info("==================================RUNNING TEST:TEST FOR MONO_RIGHT MODE  NORAML DATA TRANSFER==================================",LOW);

    fork
      env.run();
    join_any
    disable fork;
  end
endprogram :test_tb