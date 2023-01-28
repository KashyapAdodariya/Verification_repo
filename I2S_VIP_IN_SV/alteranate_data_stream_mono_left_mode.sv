class alternate_data_stream_test_mono_left extends i2s_transaction ;
  constraint data_c {data =={`size{2'b01}};}
  function new(i2s_config cfg);
      super.new(cfg);
    endfunction 


endclass:alternate_data_stream_test_mono_left 

program automatic test_tb(i2s_intf intf);  
  i2s_config#(`size) master_cfg=new,slave_cfg=new;
  i2s_transaction tr=new(master_cfg);
  i2s_env env;
  initial begin
    alternate_data_stream_test_mono_left seq_h=new(master_cfg);
    tr=seq_h;
    env = new(intf,master_cfg,slave_cfg,tr);

    master_cfg.chnl_mode=MONO_LEFT;
    master_cfg.repeat_gen=2;
    master_cfg.complement=NORMAL;
    slave_cfg.word_len=WLEN8;
    slave_cfg.mode_sel=RX;
    master_cfg.mode_sel=TX;  
    master_cfg.print("MASTER_CONFIGURATION");
    slave_cfg.print("SLAVE_CONFIGURATION");

     `info("[---------------RUNNING TEST:ALTERNATE DATA STREAM ON MONO LEFT MODE-------------------]",LOW);
     fork
      env.run();
    join_any
    disable fork;
  end
endprogram:test_tb
