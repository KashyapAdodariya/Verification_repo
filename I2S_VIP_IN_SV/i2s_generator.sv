

class i2s_master_gen;
//---transaction class handle---//  
  i2s_transaction tx;
//---config class handle---//  
  i2s_config cfg;
//---mailbox between generator and driver---//   
  mailbox gen2driv_mbox;

////////////////////////////---New constructor---///////////////////////////////////
  
  function new(mailbox gen2driv_mbox,i2s_config cfg,i2s_transaction tx);
    this.cfg=cfg;
    this.tx=tx;
    this.gen2driv_mbox=gen2driv_mbox;
  endfunction
  
//////////////////////////////////////////////////////////////////////////////////////
// Method name        : run()
// Parameter Passed   : None 
// Returned parameter : None
// Description        : For generate packets and drive to the driver(master,slave)
////////////////////////////////////////////////////////////////////////////////////// 
  
  task run();
      `info("\t\t\tGENERATOR RUNING\t\t\t",LOW);
//---repeat loop for repeat_gen times---//      
    for(int i=1;i<=cfg.repeat_gen;i++) begin:rept
       tx=new(cfg);
        assert(tx.randomize)begin:sucs_1
          `display("------Randomization successed ------packet",i,LOW);
          gen2driv_mbox.put(tx);
          tx.print("---------GENERATOR DATA-------");
        end:sucs_1      
       else begin:sucs_0
         `fatal("------Fatal Error::Randomization Failed------",HIGH);
        end:sucs_0
      end:rept
  //end:str
  endtask:run
endclass:i2s_master_gen
