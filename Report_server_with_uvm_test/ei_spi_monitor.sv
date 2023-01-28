// "ei_spi_coverage.sv"


class ei_spi_monitor_c extends uvm_monitor;


    ei_spi_config_c cnfg;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual ei_spi_interface_i m_vif;


  //--------------------------------------- 
  // Declare variable
  //--------------------------------------- 
  parameter addr_length = `ADDR_WIDTH;						// Copying value of addr width to local variable

  bit [addr_length*8-1 :0] addr;							// Array to store store address
  bit [7:0]				   instr;							// Array to store 8 bits of instruction
  bit [`DATA_WIDTH*8-1:0] 			   data  [$];						// 2D array to store data

  int slave_no;												// Stores value of slave number when slave is reciving data from master
  int slave_select;
  int err1_flag; 											// if 0: Error is not generated,  1: Error is generated
  int count	= 0 ;											// If 0: Transaction is not completed, 1: Transaction is completed

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(ei_spi_sequence_item_c) item_collected_port;

  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  ei_spi_sequence_item_c trx1;

  `uvm_component_utils(ei_spi_monitor_c)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
//     trx1 = new();
    trx1 = ei_spi_sequence_item_c::type_id::create ("trx1 from monitor");	//creating object of sequence_item_c 
    item_collected_port = new("item_collected_port", this);					//mon2scb port
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ei_spi_interface_i)::get(this, "", "m_vif", m_vif))
      `uvm_fatal("NO_m_vif",{"virtual interface must be set for: ",get_full_name(),".m_vif"});

    if(!uvm_config_db#(ei_spi_config_c):: get(this,"*","ei_spi_config_c",cnfg))
    `uvm_fatal("NO_cnfg",{"config handle must be set for: ",get_full_name(),".cnfg"});
    
  endfunction: build_phase

  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Monitor running"),UVM_HIGH)

    fork 
      begin
        send_receive_data();						// This task monitors MOSI and MISO line 
      end

      begin
        check_error();								// This task detect error and terminates all the process if error is detected
      end
    join
  endtask : run_phase


  //---------------------------------------------------------------------------------------
  // 	Method name         : send_receive_data()
  // 	Description         : This task is to send/receive address ,instruction & data  
  //---------------------------------------------------------------------------------------

  task send_receive_data;
    begin
      forever 
        begin
          wait(m_vif.RESETn == 1);  
          wait ($countbits(m_vif.mp_monitor.SS_, '0) == 1);

          l1 : fork

            //......................................................................................
            // PROCESS -1     Description: This process monitors MISO and MOSI line and recives
            // 			  				 address instruction and data.
            //......................................................................................

            begin	: process_one								
              #0
              wait ($countbits(m_vif.mp_monitor.SS_, '0) == 1);
              receive_address();
              receive_instruction();
              if(instr[7])
                receive_data_slave();								//task of slave to receive data when rd/wr= 1(write operation)
              else
                data_receive_master();								//task of master to receive data when rd/wr= 0(read operation)
            end : process_one
            //....................................................................................


            //......................................................................................
            // PROCESS -2     Description: This process waits for error flag to be asserted, As the 
            // 			  				 flag sets high it will disable the fork and terminate.
            //......................................................................................

            begin	: process_two									// Process to terminate the transaction
              wait(err1_flag == 1);  
              err1_flag = 0;
              disable l1;
            end		: process_two
            //....................................................................................


            //......................................................................................
            // PROCESS -3     Description: This process waits for error flag to be asserted, As the 
            // 			  				 flag sets high it will disable the fork and terminate.
            //......................................................................................

            begin
              @(edge m_vif.mp_monitor.SCLK);
              wait(m_vif.RESETn == 0);
              disable l1;
            end
            //....................................................................................

          join_any
          count = 1;								// One transaction is completed so count sets high
        end
    end    
  endtask : send_receive_data

  //---------------------------------------------------------------------------------------
  // 	Method name         : check_error()
  // 	Description         : This task is to detect error 
  //---------------------------------------------------------------------------------------

  task check_error;
    begin
      forever 									
        begin													
          wait(m_vif.RESETn == 1);            
          wait ($countbits(m_vif.mp_monitor.SS_, '0) == 1);		// Wait till any slave is selected
          wait(err1_flag == 0);
          fork

            //......................................................................................
            // PROCESS -1     Description: This process wait for an edge of SLCK, as the edge is detected
            // 			  				   then the process gets completed and terminates other processes.
            //......................................................................................

            begin
              @(edge m_vif.mp_monitor.SCLK);
            end
            //......................................................................................


            //......................................................................................
            // PROCESS -2     Description: This process checks toggling of clock, if the SLCK remains
            //							   stable for more then half time period, then error flag will 
            //							   set high.
            //......................................................................................

            begin                
              if(count == 1)									// If transaction is completed then SLCK toggle check will be by passed	
                begin   
                  @(posedge m_vif.mp_monitor.SCLK);  
                end

              else												// SCLK toggle check	
                begin   
                  #((`CLK_delay*2)+1);
                  `uvm_error(get_type_name(), "*******ERROR FROM MONITOR********(SCLK is not toggling)")
                  //                   $display("******************ERROR From Monitor****************At time: %0t (SCLK is not toggling)",$time);
                  err1_flag=1;                 
                end
            end
            //......................................................................................


            //......................................................................................
            // PROCESS -3     Description: If SS_ bit is high in between transaction then this process
            //							   will set error flag high 
            //......................................................................................

            begin
              wait(count==0 );
              wait($countbits(m_vif.mp_monitor.SS_, '0) != 1);				// Wait till the SS_ is high
                  `uvm_error(get_type_name(),"********ERROR From Monitor**********(SS is high in between transaction)")
              err1_flag = 1;
            end
            //......................................................................................            


            //......................................................................................
            // PROCESS -4     Description: If RESETn is assrted then it will disable the fork and
            //							   terminate all the processes
            //......................................................................................

            begin
              @(edge m_vif.mp_monitor.SCLK);
              wait(m_vif.RESETn == 0);
            end
            //......................................................................................            

          join_any
          disable fork;
            end      
            end
            endtask : check_error



            //-----------------------------------------------------------------------------
            // 	Method name         : receive_address()
            // 	Description         : This task is used by slave to receive address coming 
            //						  from master on MOSI line
            //-----------------------------------------------------------------------------

            task  receive_address;
              #0
              if(cnfg.LSBFE == 1)
                begin
                  for( int i = 0; i <= `ADDR_WIDTH*8-1; i++ )  			// At every sample edge, samples value from MOSI
                    begin
                      #0 sample_edge();
                      count = 0;
                      addr[i] = m_vif.mp_monitor.MOSI;								// Stores the values of address in addr variable
                    end
                end
              else 
                begin
                  for( int i = `ADDR_WIDTH*8-1; i >= 0; i-- ) 
                    begin
                      #0 sample_edge();
                      count = 0;
                      addr[i] = m_vif.mp_monitor.MOSI;
                    end
                end
              trx1.address = addr;										// Copying temporary variable (addr) into transaction property (address)
            endtask : receive_address

            //-----------------------------------------------------------------------------
            // 	Method name         : receive_instruction()
            // 	Description         : This task is used by slave to receive instruction coming from master on MOSI line
            //-----------------------------------------------------------------------------

            task  receive_instruction;
              if(cnfg.LSBFE) 
                begin
                  for( int i = 0; i <= 7; i++ )
                    begin
                      sample_edge();
                      instr[i] = m_vif.mp_monitor.MOSI;								// Stores the value of instructions in instr[] array
                    end
                end
              else 
                begin
                  for( int i = 7; i >= 0; i-- ) 
                    begin
                      sample_edge();
                      instr[i] = m_vif.mp_monitor.MOSI;
                    end
                end
              trx1.instruction = instr;									//copying temporary variable (instr) into transaction property (instruction)
            endtask : receive_instruction



            //-----------------------------------------------------------------------------
            // 	Method name         : receive_data_slave()
            // 	Description         : This task is used by slave to receive data coming 
            //						  from master on MOSI line
            //-----------------------------------------------------------------------------

            task  receive_data_slave;
              for( int j = 0; j < instr[6:4]; j++ ) 					// Checking the value of data length in instruction byte
                begin
                  if(cnfg.LSBFE)
                    begin
                      for( int i = 0; i <= `DATA_WIDTH*8-1; i++ ) 
                        begin
                          sample_edge();
                          data[j][i] = m_vif.mp_monitor.MOSI;						// Storing data in temporary array
                        end
                    end

                  else begin
                    for( int i = `DATA_WIDTH*8-1; i >= 0; i-- )
                      begin
                        sample_edge();
                        data[j][i] = m_vif.mp_monitor.MOSI;							// Storing data in temporary array
                      end
                  end
                end

              trx1.data = data ;										//copying data into transaction property (instruction)

              foreach(m_vif.mp_monitor.SS_[i])
                begin
                  if(!m_vif.mp_monitor.SS_[i])
                    begin
                      slave_no = i;										// Selecting the slave
                    end
                end

              //               ei_spi_cov.spi_cg.sample();								// Sampling the coverage
              item_collected_port.write(trx1);
              `uvm_info(get_type_name(), $sformatf("Monitor : Transaction packet captured during WRITE operation:-\n %0p",trx1.sprint),UVM_MEDIUM)
//               trx1.print();

              if(cnfg.CPHA)
                sample_edge();											// Waiting for a sample edge after the trx is completed.

              addr = 0;
              instr = 0;
              count = 1;												//if count =1 ,indicates the transaction is complete
              data.delete();

              @(edge m_vif.mp_monitor.SCLK);											// New transaction starts after one edge
            endtask : receive_data_slave


            //-----------------------------------------------------------------------------
            // 	Method name         : receive_data_slave()
            // 	Description         : This task is used by master to receive data coming 
            // 						  from slave on MISO line
            //-----------------------------------------------------------------------------

            task  data_receive_master();
              for( int j = 0; j < instr[6:4]; j++ )
                begin
                  if(cnfg.LSBFE)
                    begin
                      for( int i = 0; i <= `DATA_WIDTH*8-1; i++ ) 
                        begin
                          sample_edge();
                          data[j][i] = m_vif.mp_monitor.MISO;
                        end
                    end

                  else
                    begin
                      for( int i = `DATA_WIDTH*8-1; i >= 0; i-- )
                        begin
                          sample_edge();
                          data[j][i] = m_vif.mp_monitor.MISO;
                        end
                    end
                end
              trx1.data = data;												//copying data into transaction property (instruction)

              foreach(m_vif.mp_monitor.SS_[i])
                begin
                  if(!m_vif.mp_monitor.SS_[i]) 
                    begin
                      slave_select = i;										// Selecting the slave
                    end
                end

              //               ei_spi_cov.spi_cg.sample();									// Sampling the coverage
              item_collected_port.write(trx1);

                `uvm_info(get_type_name(), $sformatf("Monitor : Transaction packet captured during READ operation:-\n %0p",trx1.sprint),UVM_MEDIUM)
//               trx1.print();

              transmit_edge();												// Waiting for one transmit edge before starting new trx
              addr = 0;
              instr = 0;
              data.delete();

            endtask : data_receive_master


            //     -----------------------------------------------------------------------------
            //   	Method name         : transmit_edge()
            //   	Description         : This task is used to create edge to transmit the data
            //   ----------------------------------------------------------------------------- 

            task transmit_edge;
              if(cnfg.CPOL ^ cnfg.CPHA)									// Xor operation of cnfg.CPOL and cnfg.CPHA bit		 
                begin
                  @(posedge m_vif.mp_monitor.SCLK);	
                end
              else 
                begin 
                  @(negedge m_vif.mp_monitor.SCLK);					
                end
            endtask : transmit_edge

            //-----------------------------------------------------------------------------
            // 	Method name         : sample_edge()
            // 	Description         : This task is used to create edge to sample the data  
            //----------------------------------------------------------------------------- 

            task sample_edge;
              if(cnfg.CPOL ^ cnfg.CPHA)									// Xor operation of cnfg.CPOL and cnfg.CPHA bit
                begin
                  @(negedge m_vif.mp_monitor.SCLK);					
                end
              else 
                begin 
                  @(posedge m_vif.mp_monitor.SCLK);
                end
            endtask : sample_edge


            endclass : ei_spi_monitor_c
