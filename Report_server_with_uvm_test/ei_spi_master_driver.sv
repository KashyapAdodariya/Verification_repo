class ei_spi_mst_driver_c extends  uvm_driver #(ei_spi_sequence_item_c);


  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual ei_spi_interface_i m_vif;

  //--------------------------------------- 
  // Declare variable
  //--------------------------------------- 
  int repeat_SCLK_toggle;								// This variable will be randomized [20-40(range)] and  SCLK will toggle n times(randomize value) and then SCLK will be stable
  int check_slave_no = 100;								// Value of slave number will be stored in check_slave_no
  int delay_SS_ERR;										// This variable will be randomized [20-40(range)] and  SS_ will be valid n times(randomize value) and then SS_ will will be high	
  event error_detect;


  ei_spi_config_c cnfg;

  `uvm_component_utils(ei_spi_mst_driver_c)

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(ei_spi_sequence_item_c) m_drv2scb_port;

  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new


  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ei_spi_interface_i)::get(this, "", "m_vif", m_vif))
      `uvm_fatal("NO_vif",{"virtual interface must be set for: ",get_full_name(),".m_vif"});
    m_drv2scb_port = new("analysis_port",this);		//building m_drv2scb analysis port

    if(!uvm_config_db#(ei_spi_config_c):: get(this,"*","ei_spi_config_c",cnfg))
      `uvm_fatal("NO_cnfg",{"config handle must be set for: ",get_full_name(),".cnfg"});
    
    `uvm_info(get_type_name(), $sformatf("Master driver running : CPOL = %0d", cnfg.CPOL),UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Master driver running : CPHA = %0d", cnfg.CPHA),UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Master driver running : LSBFE = %0d", cnfg.LSBFE),UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Master driver running : SS_ERR1 = %0d", cnfg.SS_ERR1),UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Master driver running : SS_ERR = %0d", cnfg.SS_ERR),UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Master driver running : SCLK_ERR = %0d", cnfg.SCLK_ERR),UVM_LOW)

  endfunction: build_phase


  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Master driver running"),UVM_HIGH)
    //     m_vif.mp_master_driver.MOSI = 1'b0;
    //     @ (posedge m_vif.CLK);
    m_vif.mp_master_driver.SCLK = cnfg.CPOL;
    foreach(m_vif.mp_master_driver.SS_[i]) m_vif.mp_master_driver.SS_[i] = 1;	
    #20;	//initially SCLK will be high for 20s
    forever 
      begin
        seq_item_port.get_next_item(req);					//sending request to sequencer to send sequence
        
        wait(m_vif.RESETn == 1);										// Wait untill reset is deasserted

        // If any of the process in m1 fork gets completed, then the fork will disable
        m1: fork
          //-----------------------------------Process -1---------------------------------------           
          begin
            generate_sclk();
          end
          //-------------------------------------------------------------------------------------            


          //-----------------------------------Process -2---------------------------------------
          begin
            @(edge m_vif.mp_master_driver.SCLK);
            wait(m_vif.RESETn == 0);
            `uvm_info(get_type_name(), $sformatf("RESET detected, Reseting the MASTER"),UVM_LOW)
            m_vif.mp_master_driver.SS_ = 3'b111;
            disable m1;
          end   
          //-------------------------------------------------------------------------------------            


          //-----------------------------------Process -3---------------------------------------            
          begin
            if(check_slave_no != cnfg.slave) 
              begin
                foreach(m_vif.mp_master_driver.SS_[i]) m_vif.mp_master_driver.SS_[i] = 1;					//not any slave selected
                m_vif.mp_master_driver.SS_[cnfg.slave] = 0;									//assigning SS_ low for particular slave selected

              end
            if (cnfg.SS_ERR1)
              foreach(m_vif.mp_master_driver.SS_[i]) m_vif.mp_master_driver.SS_[i] = 1;
            address_transmit(req);
            instruction_transmit(req);
            if (req.instruction[7])
              data_transmit(req);
            else
              data_receive(req);
          end
          //-------------------------------------------------------------------------------------                    

          //-----------------------------------Process -4---------------------------------------            
          begin
            @ (error_detect);												//waiting for event error_detect to be triggered, if error is detected then it will come out of fork join_any and terminate the fork
            #1;					
          end
          //-------------------------------------------------------------------------------------                    

        join_any
        disable fork;
          m_vif.mp_master_driver.SCLK = cnfg.CPOL;										// Setting default value of SCLK as per the value of CPOL
          seq_item_port.item_done();
          end

          endtask : run_phase


          //-----------------------------------------------------------------------------
          // 	Method name         : generate_sclk()
          //    Parameters passed   : none
          //    Returned parameters : none
          // 	Description         : generate SCLK. with diffrent scenario.
          //                        : SCLK_ERR -> stop SCLK in between transaction.(errorneous cond.)
          //                        : SS_ERR   -> pull SS_ in between transaction.(errorneous cond.)
          //                        : SS_ERR1  -> generate SCLK during SS_ high transaction.(errorneous cond.)    
          //-----------------------------------------------------------------------------    

          task generate_sclk();
            if (cnfg.SCLK_ERR == 0 )
              begin

                fork       
                  //-----------------------------------Process -1---------------------------------------
                  begin
                    if(cnfg.SS_ERR1 == 0)
                      begin
                        wait ($countbits(m_vif.mp_master_driver.SS_, '0) != 1);						//checking for no of 0's in m_vif.mp_master_driver.SS_
                        m_vif.mp_master_driver.SCLK = cnfg.CPOL;
                        if ($countbits(m_vif.mp_master_driver.SS_, '0) == 0)

                          `uvm_info(get_type_name(), $sformatf("Any slave not Selected"),UVM_LOW)

                          else
                            `uvm_info(get_type_name(), $sformatf("Invalid!!! Multiple slave Selected"),UVM_LOW)
                            end
                            end
                            //-------------------------------------------------------------------------------------            


                            //-----------------------------------Process -2---------------------------------------                    
                            begin
                              if(cnfg.SS_ERR1 == 0)
                                begin
                                  m_vif.mp_master_driver.SCLK = cnfg.CPOL;
                                  wait ($countbits(m_vif.mp_master_driver.SS_, '0) == 1);
                                  m_vif.mp_master_driver.SCLK = cnfg.CPOL ^ cnfg.CPHA;
                                  while ($countbits(m_vif.mp_master_driver.SS_, '0) == 1) 
                                    begin
                                      #2
                                      if($countbits(m_vif.mp_master_driver.SS_, '0) == 1)
                                        m_vif.mp_master_driver.SCLK = ~m_vif.mp_master_driver.SCLK;								//generating SCLK
                                      else
                                        m_vif.mp_master_driver.SCLK = cnfg.CPOL;					//settting the value of SCLK as per CPOL 
                                    end
                                end
                            end
                        //-------------------------------------------------------------------------------------            

                        //-----------------------------------Process -3---------------------------------------                        
                        begin
                          if(cnfg.SS_ERR1) 
                            begin
                              m_vif.mp_master_driver.SCLK = cnfg.CPOL;
                              forever begin
                                #2;
                                m_vif.mp_master_driver.SCLK = ~m_vif.mp_master_driver.SCLK;									//generating SCLK
                              end
                            end
                        end
                        //-------------------------------------------------------------------------------------                    

                        //-----------------------------------Process -4---------------------------------------                                
                        begin											// Process to generate SS_ error
                          if(cnfg.SS_ERR)
                            begin
                              delay_SS_ERR = $urandom_range(35,60);
                              #delay_SS_ERR;
                              foreach(m_vif.mp_master_driver.SS_[i]) m_vif.mp_master_driver.SS_[i] = 1;
                              delay_SS_ERR = $urandom_range(30,60);
                              #delay_SS_ERR;
                              //                     check_slave_no = 100;
                              cnfg.SS_ERR = 0;
                            end
                        end
                        //-------------------------------------------------------------------------------------        

                        join
                      end

                    else 
                      begin
                        fork
                          //-----------------------------------Process -1---------------------------------------                    
                          begin
                            wait ($countbits(m_vif.mp_master_driver.SS_, '0) != 1);
                            m_vif.mp_master_driver.SCLK = cnfg.CPOL;								//settting the value of SCLK as per CPOL 
                            if ($countbits(m_vif.mp_master_driver.SS_, '0) == 0)
                              `uvm_info(get_type_name(), $sformatf("Any slave not Selected"),UVM_LOW)


                              else
                                `uvm_info(get_type_name(), $sformatf("Invalid!!! Multiple slave Selected"),UVM_LOW)
                                end
                                //-------------------------------------------------------------------------------------    

                                //-----------------------------------Process -2---------------------------------------           
                                begin
                                  m_vif.mp_master_driver.SCLK = cnfg.CPOL;
                                  wait ($countbits(m_vif.mp_master_driver.SS_, '0) == 1);
                                  m_vif.mp_master_driver.SCLK = cnfg.CPOL ^ cnfg.CPHA;
                                  repeat_SCLK_toggle = $urandom_range(20,40);
                                  repeat(repeat_SCLK_toggle) begin
                                    if($countbits(m_vif.mp_master_driver.SS_, '0) == 1) 
                                      begin
                                        #2
                                        if($countbits(m_vif.mp_master_driver.SS_, '0) == 1)
                                          m_vif.mp_master_driver.SCLK = ~m_vif.mp_master_driver.SCLK;
                                        else
                                          m_vif.mp_master_driver.SCLK = cnfg.CPOL;							//settting the value of SCLK as per CPOL 
                                      end
                                  end
                                  m_vif.mp_master_driver.SCLK = cnfg.CPOL;								//settting the value of SCLK as per CPOL 
                                  #10;
                                  -> error_detect;															//triggering event error_detect
                                  while ($countbits(m_vif.mp_master_driver.SS_, '0) == 1)
                                    begin
                                      #2
                                      if($countbits(m_vif.mp_master_driver.SS_, '0) == 1)
                                        m_vif.mp_master_driver.SCLK = ~m_vif.mp_master_driver.SCLK;
                                      else
                                        m_vif.mp_master_driver.SCLK = cnfg.CPOL;
                                    end
                                end
                            //-------------------------------------------------------------------------------------    

                            join
                          end
                          endtask : generate_sclk


                          //-----------------------------------------------------------------------------
                          // Method name : address_transmit()
                          // Description :Used to transmit address from master to slave
                          //-----------------------------------------------------------------------------

                          task address_transmit(ei_spi_sequence_item_c req);
                            //                               `uvm_info(get_type_name(), $sformatf("Address transmitting"),UVM_MEDIUM)

                            if(cnfg.LSBFE == 1) begin
                              for( int i = 0; i <= `ADDR_WIDTH*8-1; i++ )
                                begin
                                  m_vif.mp_master_driver.MOSI = req.address[i];
                                  `uvm_info(get_type_name(),$sformatf("at master transmitt addr [%0d] %0b",i,req.address[i]),UVM_HIGH)
                                  #0 transmit_edge();
                                end
                            end

                            else begin
                              for( int i = `ADDR_WIDTH*8-1; i >= 0; i-- )
                                begin
                                  m_vif.mp_master_driver.MOSI = req.address[i];
                                  `uvm_info(get_type_name(),$sformatf("at master transmitt addr [%0d] %0b",i,req.address[i]),UVM_HIGH)
                                  #0 transmit_edge();
                                end
                            end
                            `uvm_info(get_type_name(), $sformatf("Address transmitted sucessfully from master"),UVM_HIGH)

                            //
                          endtask : address_transmit

                          //-----------------------------------------------------------------------------
                          // Method name : instruction_transmit()
                          // Description :Used to transmit instruction from master to slave
                          //-----------------------------------------------------------------------------

                          task instruction_transmit(ei_spi_sequence_item_c req);
                            //                               `uvm_info(get_type_name(), $sformatf("Instruction transmitting"),UVM_MEDIUM)

                            if(cnfg.LSBFE)
                              begin
                                for( int i = 0; i <= 7; i++ )
                                  begin
                                    m_vif.mp_master_driver.MOSI = req.instruction[i];
                                    `uvm_info(get_type_name(),$sformatf("AT master instr[%0d] : %0b",i,req.instruction[i]),UVM_HIGH)
                                    transmit_edge();
                                  end
                              end
                            else 
                              begin
                                for( int i = 7; i >= 0; i-- )
                                  begin
                                    m_vif.mp_master_driver.MOSI = req.instruction[i];
                                    `uvm_info(get_type_name(),$sformatf("AT master instr[%0d] : %0b",i,req.instruction[i]),UVM_HIGH)
                                    transmit_edge();
                                  end
                              end
                            //                               `uvm_info(get_type_name(), $sformatf("Instruction transmitted sucessfully"),UVM_MEDIUM)


                          endtask : instruction_transmit

                          //-----------------------------------------------------------------------------
                          // Method name : data_transmit()
                          // Description :Used to transmit data from master to slave
                          //-----------------------------------------------------------------------------

                          task data_transmit(ei_spi_sequence_item_c req);
                            //                               `uvm_info(get_type_name(), $sformatf("Data transmitting"),UVM_MEDIUM)

                            for( int j = 0; j < req.data.size(); j++ ) 
                              begin
                                if(cnfg.LSBFE) 
                                  begin
                                    for( int i = 0; i <= `DATA_WIDTH*8-1; i++ )
                                      begin
                                        m_vif.mp_master_driver.MOSI = req.data[j][i];
                                        `uvm_info(get_type_name(),$sformatf("AT master transmitt data[%0d] : %0b",i,req.data[j][i]),UVM_HIGH)
                                        transmit_edge();
                                      end
                                  end

                                else 
                                  begin
                                    for( int i = `DATA_WIDTH*8-1; i >= 0; i-- ) 
                                      begin
                                        m_vif.mp_master_driver.MOSI = req.data[j][i];
                                        `uvm_info(get_type_name(),$sformatf("AT master transmitt data[%0d] : %0b",i,req.data[j][i]),UVM_HIGH)
                                        transmit_edge();
                                      end
                                  end
                              end
                            `uvm_info(get_type_name(),$sformatf("------------Write packet transmitted from master :------:\n %s", req.sprint()),UVM_HIGH)

                          endtask : data_transmit

                          //-----------------------------------------------------------------------------
                          // Method name : data_receive()
                          // Description :Used to receive data from slave to master 
                          //-----------------------------------------------------------------------------

                          task data_receive(ei_spi_sequence_item_c req);
                            //                               `uvm_info(get_type_name(), $sformatf("Data Receiving from master"),UVM_MEDIUM)

                            for( int j = 0; j < req.instruction[6:4]; j++ )
                              begin
                                if(cnfg.LSBFE)
                                  begin
                                    for( int i = 0; i <= `DATA_WIDTH*8-1; i++ ) 
                                      begin
                                        sample_edge();
                                        req.data[j][i] = m_vif.mp_master_driver.MISO;
                                        `uvm_info(get_type_name(),$sformatf("AT master receive data[%0d] : %0b",i,req.data[j][i]),UVM_HIGH)
                                      end
                                  end
                                else
                                  begin
                                    for( int i = `DATA_WIDTH*8-1; i >= 0; i-- )
                                      begin
                                        sample_edge();
                                        req.data[j][i] = m_vif.mp_master_driver.MISO;
                                        `uvm_info(get_type_name(),$sformatf("AT master receive data[%0d] : %0b",i,req.data[j][i]),UVM_HIGH)
                                      end
                                  end
                              end
                            `uvm_info(get_type_name(),$sformatf("------------------------------READ packet received by master from slave :\n %s--------------------", req.sprint()),UVM_MEDIUM)

                            m_drv2scb_port.write(req);		//broadcasting data from master driver
                            transmit_edge();					//we are transmitting first bit of every transaction of master without waiting for any edge (cpol&cpoh=0), so this transmit_edge() helps the master to transmitt data on next edge(SO here master will sample its last bit of data on posedge(cpol&cpoh=0) and we are waiting for the next transmit_edge i.e(negedge) ,So that master will send its first bit of next trans on the negedge)

                          endtask : data_receive

                          //-----------------------------------------------------------------------------
                          // Method name : transmit_edge()
                          // Description : According to CPOL and CPHA conifiguring the edge of SCLK to 
                          //				 transmit data
                          //-----------------------------------------------------------------------------

                          task transmit_edge;
                            if(cnfg.CPOL ^ cnfg.CPHA)
                              begin
                                @(posedge m_vif.mp_master_driver.SCLK);
                              end
                            else 
                              begin
                                @(negedge m_vif.mp_master_driver.SCLK);
                              end
                          endtask : transmit_edge

                          //-----------------------------------------------------------------------------
                          // Method name : sample_edge()
                          // Description :According to CPOL and CPHA conifiguring the edge of SCLK to 
                          //              sample data
                          //-----------------------------------------------------------------------------

                          task sample_edge;
                            if(cnfg.CPOL ^ cnfg.CPHA)
                              begin
                                @(negedge m_vif.mp_master_driver.SCLK);
                              end
                            else 
                              begin
                                @(posedge m_vif.mp_master_driver.SCLK);
                              end
                          endtask : sample_edge
                          endclass : ei_spi_mst_driver_c
