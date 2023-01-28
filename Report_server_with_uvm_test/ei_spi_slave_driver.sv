class ei_spi_slv_driver_c extends uvm_driver #(ei_spi_sequence_item_c);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual ei_spi_interface_i s_vif;

  //--------------------------------------- 
  // Declare variable
  //--------------------------------------- 
  parameter addr_length = `ADDR_WIDTH;

  bit [7:0] 			   instr;					// Array to store 8 bits of instruction
  bit [`DATA_WIDTH*8-1:0]  data [$];				// queue to store data
  bit [addr_length*8-1 :0] addr;					// Variable Array to store address
//   bit [7:0] mem [2**(addr_length*8)-1:0];			// Variable memory according address width
  bit [`DATA_WIDTH*8-1:0] mem [2**(addr_length*8)-1:0];

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(ei_spi_sequence_item_c) s_drv2scb_port;

  int err_flag;										// if 0: Error is not generated,  1: Error is generated
  int transaction_complete = 0;									// If 0: Transaction is not completed, 1: Transaction is completed

    ei_spi_config_c cnfg;

  ei_spi_sequence_item_c trx1 = new();				// Creating object of transaction class 


  `uvm_component_utils(ei_spi_slv_driver_c)

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
    if(!uvm_config_db#(virtual ei_spi_interface_i)::get(this, "", "s_vif", s_vif))
      `uvm_fatal("NO_vif",{"virtual interface must be set for: ",get_full_name(),".s_vif"});
    s_drv2scb_port = new("analysis_port",this);		//building s_drv2scb analysis port

    
//         uvm_config_db#(ei_spi_config_c):: get(this,"*","ei_spi_config_c",cnfg);
       if(!uvm_config_db#(ei_spi_config_c):: get(this,"*","ei_spi_config_c",cnfg))
    `uvm_fatal("NO_cnfg",{"config handle must be set for: ",get_full_name(),".cnfg"});

  endfunction: build_phase


  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Slave driver running"),UVM_HIGH)

    s_vif.mp_slave_driver.MISO = 1'bz;								// Setting MISO as high impedence initially

    foreach(mem[i])									// Setting default values in memory
      begin
        mem[i] = i;
      end     

    fork 
      begin
        send_recive_data();
      end
      begin
        error_detect();
      end
    join
  endtask : run_phase


  //----------------------------------------------------------
  //----------------------------------------------------------



  //---------------------------------------------------------------------------------------
  // 	Method name         : send_recive_data()
  // 	Description         : sending and reciving : address, instruction and data
  //---------------------------------------------------------------------------------------

  task send_recive_data;
    begin
      forever 
        begin
          #0
          wait(s_vif.RESETn == 1);
          wait(!s_vif.mp_slave_driver.SS_[cnfg.slave]);
          //           err_flag = 0;

          l1:  fork

            //......................................................................................
            // PROCESS -1     Description: This process  recives address instruction and data
            // 			  				   from MOSI pin.
            //......................................................................................

            begin								
              wait (!s_vif.mp_slave_driver.SS_[cnfg.slave]);
              s_vif.mp_slave_driver.MISO = 1'bz;
              receive_address();
              receive_instruction();
              if(instr[7])
                receive_data();								// task of slave to receive data when rd/wr= 1(write operation)
              else
                transmmit_data();							// task of master to receive data when rd/wr= 0(read operation)
            end
            //....................................................................................


            //......................................................................................
            // PROCESS -2     Description: This process waits for error flag to be asserted, As the 
            // 			  				 flag sets high it will disable the fork and terminate.
            //......................................................................................

            begin									// Process to terminate the transaction
              wait(err_flag == 1);
              disable l1;
            end
            //....................................................................................           


            //......................................................................................
            // PROCESS -3     Description: This process waits for error flag to be asserted, As the 
            // 			  				 flag sets high it will disable the fork and terminate.
            //......................................................................................

            begin
              @(edge s_vif.mp_slave_driver.SCLK);
              wait(s_vif.RESETn == 0);
              `uvm_info(get_type_name(), $sformatf("RESET detected, Reseting the SLAVE"),UVM_LOW)
              disable l1;
            end
            //....................................................................................            

          join_any
          transaction_complete = 1;								// One transaction is completed so count sets high
        end
    end
  endtask : send_recive_data


  //---------------------------------------------------------------------------------------
  // 	Method name         : error_detect()
  // 	Description         : detecting error when SCL is stable or SS_ is deasserted
  //--------------------------------------------------------------------------------------- 

  task error_detect;
    begin
      forever 									
        begin										// Error detection process
          wait(s_vif.RESETn == 1);         			// Wait till slave is selected
          wait(!s_vif.mp_slave_driver.SS_[cnfg.slave]);  				// Wait till the SS_ is equal to the selected slave number
          wait(err_flag == 0);

          fork

            //......................................................................................
            // PROCESS -1     Description: This process wait for an edge of SLCK, as the edge is detected
            // 			  				   then the process gets completed and terminates other processes.
            //...................................................................................... 

            begin
              @(edge s_vif.mp_slave_driver.SCLK);
            end
            //......................................................................................            


            //......................................................................................
            // PROCESS -2     Description: This process checks toggling of clock, if the SLCK remains
            //							   stable for more then half time period, then error flag will 
            //							   set high.
            //......................................................................................

            begin                
              if(transaction_complete == 1)									// If transaction is completed then SLCK toggle check will be by passed	
                begin   
                  @(posedge s_vif.mp_slave_driver.SCLK);  
                end
              else												// SCLK toggle check	
                begin   
                  #((`CLK_delay*2)+1);
                  `uvm_error(get_type_name(), "*******ERROR FROM SLAVE********(SCLK is not toggling)")
                  //                   $display("******************ERROR FROM SLAVE****************At time: %0t (SCLK is not toggling)",$time);
                  err_flag=1;                 
                end
            end
            //....................................................................................            


            //......................................................................................
            // PROCESS -3     Description: If SS_ bit is high in between transaction then this process
            //							   will set error flag high 
            //......................................................................................

            begin
              wait(transaction_complete==0 && s_vif.mp_slave_driver.SS_[cnfg.slave]);				// Wait till the SS_ is high
             `uvm_error(get_type_name(), "*******ERROR FROM SLAVE********(SS is high in between transaction)")
              err_flag = 1;
            end
            //....................................................................................


            //......................................................................................
            // PROCESS -4     Description: If RESETn is assrted then it will disable the fork and
            //							   terminate all the processes
            //......................................................................................

            begin
              @(edge s_vif.mp_slave_driver.SCLK);
              wait(s_vif.RESETn == 0);
            end
            //....................................................................................            

          join_any
          disable fork;
            end      
            end
            endtask : error_detect


            //---------------------------------------------------------------------------------------
            // 	Method name         : receive_address()
            // 	Description         : This task is to recive 8/16/32 bit of address
            //---------------------------------------------------------------------------------------

            task receive_address;
              err_flag = 0;
              if(cnfg.LSBFE == 1)  								// If cnfg.LSBFE bit is 1 then LSB comes first
                begin
                  for( int i = 0; i <= `ADDR_WIDTH*8-1; i++ )  	// no. of iteration depends on address width
                    begin
                      #0 sample_edge();
                      transaction_complete = 0;
                      addr[i] = s_vif.mp_slave_driver.MOSI;
                      `uvm_info(get_type_name(),$sformatf("at slave addr [%0h] %0b",i,addr[i]),UVM_FULL)
                    end
                end

              else 												// If cnfg.LSBFE bit is 0 then MSB comes first
                begin
                  for( int i = `ADDR_WIDTH*8-1; i >= 0; i-- ) 
                    begin
                      #0 sample_edge();
                      transaction_complete = 0;
                      addr[i] = s_vif.mp_slave_driver.MOSI;
                     `uvm_info(get_type_name(),$sformatf("at slave addr [%0h] %0b",i,addr[i]),UVM_FULL)
                    end
                end
              `uvm_info(get_type_name(), $sformatf("--------At Slave Address received : 'h%h--------", addr),UVM_HIGH)
              trx1.address = addr;								// Storing address in variable of transaction class
            endtask : receive_address 


            //---------------------------------------------------------------------------------------
            // 	Method name         : receive_instruction()
            // 	Description         : Recives 8-bit of instruction
            //---------------------------------------------------------------------------------------

            task receive_instruction;
              if(cnfg.LSBFE) 
                begin
                  for( int i = 0; i <= 7; i++ ) 
                    begin
                      sample_edge();
                      instr[i] = s_vif.mp_slave_driver.MOSI;						// Reciving instruction in temp array
                      `uvm_info(get_type_name(),$sformatf("AT Slave instr[%0d] : %0b",i,instr[i]),UVM_HIGH)
                    end
                end
              else 
                begin
                  for( int i = 7; i >= 0; i-- ) 
                    begin
                      sample_edge();
                      instr[i] = s_vif.mp_slave_driver.MOSI;
                      `uvm_info(get_type_name(),$sformatf("AT Slave instr[%0d] : %0b",i,instr[i]),UVM_HIGH)
                    end
                end

              `uvm_info(get_type_name(), $sformatf("-----------Instruction received from Slave: 'h%h----------", instr),UVM_HIGH)
              trx1.instruction = instr;							// Storing instruction in variable of transaction class
            endtask : receive_instruction


            //---------------------------------------------------------------------------------------
            // 	Method name         : receive_data()
            // 	Description         : Reciving 1/2/3/4 byte of data according to data len
            //---------------------------------------------------------------------------------------

            task receive_data;
              for( int j = 0; j < instr[6:4]; j++ ) 				// Checking the value of data length in instruction byte
                begin
                  if(cnfg.LSBFE) 
                    begin
                      for( int i = 0; i <= `DATA_WIDTH*8-1; i++ ) 
                        begin
                          sample_edge();
                          data[j][i] = s_vif.mp_slave_driver.MOSI;					// Storing data in temporary array
                          `uvm_info(get_type_name(),$sformatf("AT Slave receive data[%0d]:  %0b",i, data[j][i]),UVM_HIGH)
                        end
                    end
                  else 
                    begin
                      for( int i = `DATA_WIDTH*8-1; i >= 0; i-- ) 
                        begin
                          sample_edge();
                          data[j][i] = s_vif.mp_slave_driver.MOSI;					// Storing data in temporary array
                          `uvm_info(get_type_name(),$sformatf("AT Slave receive data[%0d]:  %0b", i,data[j][i]),UVM_HIGH)
                        end
                    end
                end
              `uvm_info(get_type_name(), $sformatf("---------------------AT Slave Data received : %0p-------------------------", data),UVM_HIGH)

              foreach(data[i]) 
                begin
                  mem[addr+i] = data[i];							// Loading the recieved data into memory
                end
              transaction_complete = 1;											// Count =1 ,indicates the transaction is complete

              if(cnfg.CPHA)
                sample_edge();										// Waiting for a sample edge after the trx is completed.

              trx1.data = data;										// Storing recived data in variable of transaction class
              s_drv2scb_port.write(trx1);				// Now pass trx packet to other components via the analysis port write() method

//               `uvm_info(get_type_name(), $sformatf("Received Packet"),UVM_LOW)
//               trx1.print();
              `uvm_info(get_type_name(),$sformatf(" At SLAVE Packet received :- \n %0p",trx1.sprint),UVM_MEDIUM)
              addr = 0;
              instr = 0;
              data.delete(); 
              //----------------------changed--------------------
//               @(edge s_vif.mp_slave_driver.SCLK);										// New transaction starts after one edge
            endtask : receive_data


            //---------------------------------------------------------------------------------------
            // 	Method name         : transmmit_data()
            // 	Description         : Transmitting 1/2/3/4 byte of data according to data len
            //---------------------------------------------------------------------------------------

            task transmmit_data;
              data.delete(); 
              for( int i = 0; i < instr[6:4]; i++) 
                begin
                  data[i] = mem[addr+i];							// Loding data from memory to temporary array
                end

              `uvm_info(get_type_name(),$sformatf("at slave send data : %0p ",data),UVM_FULL)

              for( int j = 0; j < data.size(); j++ ) 
                begin
                  if(cnfg.LSBFE) 
                    begin
                      for( int i = 0; i <= `DATA_WIDTH*8-1; i++ ) 
                        begin
                          transmit_edge();
                          s_vif.mp_slave_driver.MISO = data[j][i];					// Sending data from temporary array to MISO bit by bit
                          `uvm_info(get_type_name(),$sformatf("AT slave transmitt data[%0h] : %0b",i,data[j][i]),UVM_FULL)
                        end
                    end
                  else 
                    begin
                      for( int i = `DATA_WIDTH*8-1; i >= 0; i-- ) 
                        begin
                          transmit_edge();
                          s_vif.mp_slave_driver.MISO = data[j][i];					// Sending data from temporary array to MISO bit by bit
                          `uvm_info(get_type_name(),$sformatf("AT slave transmitt data[%0h] : %0b",i,data[j][i]),UVM_FULL)
                        end
                    end
                end
              transaction_complete = 1;
//               `uvm_info(get_type_name(), $sformatf("Read data send from Slave to master : %0p",trx1.data),UVM_HIGH)
//               trx1.print();
              transmit_edge();										// Waiting for a sample edge after the trx is completed.

              s_vif.mp_slave_driver.MISO = 1'bz;										// Settind MISO high impedence after transmitting data
              addr = 0;
              instr = 0;
              data.delete();
            endtask : transmmit_data


            //---------------------------------------------------------------------------------------
            // 	Method name         : transmit_edge()
            // 	Description         : According to cnfg.CPOL and cnfg.CPHA conifiguring the edge of SCLK to transmit data
            //---------------------------------------------------------------------------------------

            task transmit_edge;
              begin
                if(cnfg.CPOL ^ cnfg.CPHA) 		// Xor operation of cnfg.CPOL and cnfg.CPHA 
                  begin
                    @(posedge s_vif.mp_slave_driver.SCLK);
                  end
                else 
                  begin 
                    @(negedge s_vif.mp_slave_driver.SCLK);	
                  end
              end
            endtask : transmit_edge


            //---------------------------------------------------------------------------------------
            // 	Method name         : sample_edge()
            // 	Description         : According to cnfg.CPOL and cnfg.CPHA conifiguring the edge of SCLK to sample data
            //---------------------------------------------------------------------------------------

            task sample_edge;
              begin
                if(cnfg.CPOL ^ cnfg.CPHA)  		// Xor operation of cnfg.CPOL and cnfg.CPHA  
                  begin
                    @(negedge s_vif.mp_slave_driver.SCLK);
                  end
                else 
                  begin 
                    @(posedge s_vif.mp_slave_driver.SCLK);
                  end
              end
            endtask : sample_edge

            endclass : ei_spi_slv_driver_c

            //----------------------------------------------------------
            //----------------------------------------------------------





