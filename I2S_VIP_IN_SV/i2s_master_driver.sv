

// Revision: 2
//-------------------------------------------------------------------------------

`define vif intf.master_drv_mp

class i2s_master_driver;

  i2s_config master_cfg;
  mailbox gen2driv_mbox;
  mailbox m_driv2scr_mbox;
  virtual i2s_intf intf;
  i2s_transaction tx1,txQ[$],tx;

  function new(virtual i2s_intf intf, mailbox gen_mbox, mailbox driv_mbox, i2s_config master_cfg);
    this.gen2driv_mbox = gen_mbox;
    this.m_driv2scr_mbox = driv_mbox;
    this.intf = intf;
    this.master_cfg = master_cfg; 
  endfunction:new
  
  extern task run();
endclass:i2s_master_driver

  //////////////////////////////////////////////////////// 
  // Method name        : task run()  
  // Parameter Passed   : none  
  // Returned parameter : none
  // Description        : driver all required signals 
  ////////////////////////////////////////////////////////  
  

task i2s_master_driver :: run();
  `info("\t\t\tMASTER DRIVER RUNING\t\t\t",LOW);

    begin:main
      fork
        /*forever begin
        	  begin:reset
     		 wait(`vif.reset==0);
     		 //vif.SCK <= 0;
     		 `vif.WS <= 0;
     		 `vif.sd_out <= 0;
     		 `info("\n RESET ON \n",LOW);
     		 wait(`vif.reset == 1);
     		 `info("\n RESET OFF \n",LOW);
    		end:reset
        end
        */
        //clock thread
        begin:th1
          forever begin
            `vif.SCK <= 0;
            #(master_cfg.high_low);
            `vif.SCK <= 1;
            #(master_cfg.high_low);
          end
        end:th1
  
        begin:th2
          @(`edge_clk `vif.SCK);
          forever begin
            `vif.WS <= 1'b0;
            #(master_cfg.on_duty_cycle);
            `vif.WS <= 1'b1;
            #(master_cfg.off_duty_cycle);
          end
        end:th2
  
        begin:th3
          forever begin
            begin 
              
              gen2driv_mbox.get(tx1);
              if(tx1==null) begin
                `error("Transection class NULL in master driver gen2driv_mbox",HIGH);
                $stop;
              end
              txQ.push_back(tx1);
              m_driv2scr_mbox.put(tx1);
              
              if(master_cfg.mode_sel == TX) begin:TX_mode
                tx = txQ.pop_front();
                
                wait(`vif.WS == 0); begin:wait_ws0
                  if((master_cfg.chnl_mode == MONO_LEFT || master_cfg.chnl_mode == STEREO) && `vif.reset==1) begin
                    for(int j=($size(tx.data)-1); j>=$size(tx.data)/2; j--) begin
                      	if(`vif.reset==1) begin
                          @(`edge_clk `vif.SCK);
                          `vif.master_drv_cb.sd_out <= tx.data[j];
                      	end
                      	else begin
                          @(`edge_clk `vif.SCK);
                          `vif.master_drv_cb.sd_out <= 0;
                        end
                      end
                    end
                  
                  else if(master_cfg.chnl_mode == MONO_RIGHT && `vif.reset==1) begin
                    for(int k=($size(tx.data)/2)-1; k>=0; k--) begin         
                      if(`vif.reset == 1) begin
                        @(`edge_clk `vif.SCK);
                        `vif.master_drv_cb.sd_out <= tx.data[k];
                      end
                      else begin
                        `info("\n RESET ON \n",LOW);
                        @(`edge_clk `vif.SCK);
                        `vif.master_drv_cb.sd_out <= 0;
                      end
                    end 
                  end
                end:wait_ws0
  
                wait(`vif.WS == 1); begin:wait_ws1
                  if((master_cfg.chnl_mode == MONO_RIGHT || master_cfg.chnl_mode == STEREO) && `vif.reset==1) begin
                    for(int k=($size(tx.data)/2)-1; k>=0; k--) begin      
                      if(`vif.reset==1) begin
                        @(`edge_clk `vif.SCK);
                        `vif.master_drv_cb.sd_out <= tx.data[k];
                      end
                      else begin
                        `info("\n RESET ON \n",LOW);
                        @(`edge_clk `vif.SCK);
                        `vif.master_drv_cb.sd_out <= 0;
                      end
                    end
                  end
                  else if (master_cfg.chnl_mode == MONO_LEFT && `vif.reset==1) begin
                    for(int j=($size(tx.data)-1); j>=$size(tx.data)/2; j--) begin
                      if(`vif.reset==1) begin 
                        @(`edge_clk `vif.SCK);
                        `vif.master_drv_cb.sd_out <= tx.data[j];
                      end
                      else begin
                        `info("\n RESET ON \n",LOW);
                        @(`edge_clk `vif.SCK);
                        `vif.master_drv_cb.sd_out <= 0;
                      end
                    end
                  end
                end:wait_ws1
  
              end:TX_mode
  
              else if(master_cfg.mode_sel == RX) begin:RX_mode
                @(`edge_clk `vif.SCK);
                 repeat(master_cfg.repeat_gen) begin
                   `vif.WS <= 1'b0;
                   #(master_cfg.on_duty_cycle);
                   `vif.WS <= 1'b1;
                    #(master_cfg.off_duty_cycle);
                 end
              end:RX_mode
  
              else begin
                `error("MASTER_DRIVER: Not select any mode. Plz Select mode in config class",HIGH);
                $stop;
              end
  
            end
          end
        end:th3
      join_any
      disable fork;
    end:main
    
  //join_any
  
  endtask:run