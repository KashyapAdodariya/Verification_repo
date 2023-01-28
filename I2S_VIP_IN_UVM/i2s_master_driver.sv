
// Revision: 3
//-------------------------------------------------------------------------------

`define edge_clk posedge
`define vif vif.master_drv_mp

class i2s_master_driver extends uvm_driver #(i2s_seq_item);
  `uvm_component_utils(i2s_master_driver)
  //for callbacks
  `uvm_register_cb(i2s_master_driver,i2s_driver_callback)

  // Virtual Interface
  virtual i2s_interface vif;
  
  //declear veriables and tlm ports
  i2s_config cfg;
  uvm_blocking_put_port#(i2s_seq_item) driv2scb;
  i2s_seq_item tx;
  
  //prototype
  extern function new(string name ="i2s_master_driver", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern virtual task send_dut(i2s_seq_item tx);
  extern virtual task run_phase(uvm_phase phase);

endclass : i2s_master_driver

  //////////////////////////////////////////////////////// 
  // Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : void  
  // Description        : constrctor
  //////////////////////////////////////////////////////// 

  function i2s_master_driver :: new (string name ="i2s_master_driver", uvm_component parent);
    super.new(name, parent);
    driv2scb=new("driv2scb",this);
    `uvm_info(get_type_name(),"DRIVER_NEW",UVM_LOW)
  endfunction : new

  //////////////////////////////////////////////////////// 
	// Method name        : build_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : create and build object 
  ////////////////////////////////////////////////////////

  function void i2s_master_driver :: build_phase(uvm_phase phase);
    super.build_phase(phase);    
    if(!uvm_config_db#(virtual i2s_interface)::get(this,"", "vif", vif))
      `uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
      if(!uvm_config_db #(i2s_config)::get(this,"","m_cfg_1d",cfg))
    `uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
    `uvm_info(get_type_name(),"I2S_MASTER_DRIVER_BUILD",UVM_LOW)
  endfunction: build_phase

  //////////////////////////////////////////////////////// 
	// Method name        : run_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : create and build object 
  ////////////////////////////////////////////////////////

  task i2s_master_driver :: run_phase(uvm_phase phase);
    `uvm_info(get_type_name(),"I2S_MASTER_DRIVER RUN PHASE",UVM_LOW)
    forever begin
      //callbacks
      `uvm_do_callbacks(i2s_master_driver,i2s_driver_callback,pre_run());
      
      seq_item_port.get_next_item(tx);
      send_dut(tx);
      seq_item_port.item_done();
      //callbacks
      `uvm_do_callbacks(i2s_master_driver,i2s_driver_callback,post_run());
    end
  endtask : run_phase
  
  ////////////////////////////////////////////////////////////// 
	// Method name        : send_dut
  // Parameter Passed   : i2s_seq_item tx
  // Returned parameter : void  
  // Description        : prepare data for sending in interface  
  ///////////////////////////////////////////////////////////////

  task i2s_master_driver :: send_dut(i2s_seq_item tx);
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
            #1;
            //#(cfg.high_low);
            `vif.SCK <= 1;
            #1;
            //#(cfg.high_low);
          end
        end:th1

        begin:th2
          @(`edge_clk `vif.SCK);
          forever begin
            `vif.WS <= 1'b0;
            #(2*cfg.word_len);
            //#(cfg.on_duty_cycle);
            `vif.WS <= 1'b1;
            #(2*cfg.word_len);
            //#(cfg.off_duty_cycle);
          end
        end:th2

        begin:th3
          //forever begin
            begin 
              driv2scb.put(tx);             
              if(cfg.mode_sel == TX) begin:TX_mode
                wait(`vif.WS == 0); begin:wait_ws0
                  if((cfg.chnl_mode == MONO_LEFT || cfg.chnl_mode == STEREO)) begin
                    for(int j=($size(tx.data)-1); j>=$size(tx.data)/2; j--) begin
                          @(`edge_clk `vif.SCK);
                          `vif.master_drv_cb.sd_out <= tx.data[j];
                      end
                    end
                  
                  else if(cfg.chnl_mode == MONO_RIGHT) begin
                    for(int k=($size(tx.data)/2)-1; k>=0; k--) begin
                        @(`edge_clk `vif.SCK);
                        `vif.master_drv_cb.sd_out <= tx.data[k];
                    end 
                  end
                end:wait_ws0

                wait(`vif.WS == 1); begin:wait_ws1
                  if((cfg.chnl_mode == MONO_RIGHT || cfg.chnl_mode == STEREO)) begin
                    for(int k=($size(tx.data)/2)-1; k>=0; k--) begin 
                        @(`edge_clk `vif.SCK);
                        `vif.master_drv_cb.sd_out <= tx.data[k];
                    end
                  end
                  else if (cfg.chnl_mode == MONO_LEFT) begin
                    for(int j=($size(tx.data)-1); j>=$size(tx.data)/2; j--) begin
                        @(`edge_clk `vif.SCK);
                        `vif.master_drv_cb.sd_out <= tx.data[j];
                    end
                  end
                end:wait_ws1

              end:TX_mode

              else if(cfg.mode_sel == RX) begin:RX_mode
                @(`edge_clk `vif.SCK);
                //forever begin
                  `vif.WS <= 1'b0;
                  #(cfg.on_duty_cycle);
                  `vif.WS <= 1'b1;
                    #(cfg.off_duty_cycle);
                // end
              end:RX_mode

              else begin
                `uvm_error(get_type_name(),"MASTER_DRIVER: Not select any mode. Plz Select mode in config class");
              end

            end
        // end
        end:th3
      join_any
      disable fork;
    end:main
  endtask:send_dut

