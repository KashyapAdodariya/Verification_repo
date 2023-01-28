//`uvm_analysis_imp_decl(_port_a)//for getting packet from monitor
`uvm_analysis_imp_decl(_port_b)//for getting packet from slave driver
`uvm_analysis_imp_decl(_port_c)//for getting packet from master driver

class ei_spi_scoreboard_c extends uvm_scoreboard;
  bit [7:0] sc_mem [2**(`ADDR_WIDTH*8)-1:0];
  int error_count ;
  int total_pkt_compared ,pkt_match , pkt_mismatch, R_R_pkt_mismatch, R_R_pkt_match, W_W_pkt_mismatch, W_W_pkt_match, R_A_COM_mismatch, R_A_COM_match;
  ei_spi_sequence_item_c mon,s_drv,m_drv, trans;
  ei_spi_sequence_item_c mon_qu[$];
  ei_spi_sequence_item_c s_drv_qu[$];
  ei_spi_sequence_item_c m_drv_qu[$];
  //---------------------------------------
  //port to recive packets from monitor
  //---------------------------------------
  uvm_tlm_analysis_fifo#(ei_spi_sequence_item_c) analy_fifo;
  //uvm_analysis_imp_port_a#(ei_spi_sequence_item_c, ei_spi_scoreboard_c) analy_fifo;
  uvm_analysis_imp_port_b#(ei_spi_sequence_item_c, ei_spi_scoreboard_c) s_drv2scb_export;
  uvm_analysis_imp_port_c#(ei_spi_sequence_item_c, ei_spi_scoreboard_c) m_drv2scb_export;

  `uvm_component_utils(ei_spi_scoreboard_c)


  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  //---------------------------------------
  // build_phase - create port and initialize local memory
  //---------------------------------------

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    foreach(sc_mem[i]) sc_mem[i] = i;


    analy_fifo = new("analy_fifo", this);
    s_drv2scb_export	 = new("s_drv2scb_export", this);			//building s_drv2scb analysis port in scb
    m_drv2scb_export	 = new("m_drv2scb_export", this);			//building m_drv2scb analysis port in scb
  endfunction: build_phase

  //---------------------------------------
  // write task - recives the pkt from monitor and pushes into queue
  //---------------------------------------

  //virtual function void write_port_a(ei_spi_sequence_item_c pkt);
  // `uvm_info(get_type_name(),$sformatf("From Scoreboard packet received from Monitor(port a):-\n %s", pkt.sprint()),UVM_MEDIUM)

  //endfunction 


  virtual function void write_port_b(ei_spi_sequence_item_c pkt);
    `uvm_info(get_type_name(),$sformatf("From Scoreboard packet received from Slave driver(port b):-\n %s", pkt.sprint()),UVM_MEDIUM)
    s_drv_qu.push_back(pkt);
  endfunction 

  virtual function void write_port_c(ei_spi_sequence_item_c pkt);
    `uvm_info(get_type_name(),$sformatf("From Scoreboard packet received from master driver(port c):-\n %s", pkt.sprint()),UVM_MEDIUM)
    m_drv_qu.push_back(pkt);
  endfunction 

  //---------------------------------------
  // run_phase - compare's the read data with the expected data(stored in local memory)
  // local memory will be updated on the write operation.
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
       
    `uvm_info(get_type_name(), "\t--------Scoreboard Running--------", UVM_MEDIUM)
    forever begin
      analy_fifo.get(trans);
      mon_qu.push_back(trans);
      wait(mon_qu.size() > 0 ) begin
        total_pkt_compared++;
        //         `uvm_info(get_type_name(), "\t------------------------STATUS-------------------", UVM_MEDIUM)
        mon = mon_qu.pop_front();
        // 		total_pkt++;
        foreach(mon.data[i]) begin
          sc_mem[mon.address+i] = mon.data[i];
        end

        if(mon.instruction[7]) begin		//Write operation
          wait(s_drv_qu.size() > 0 )
          s_drv = s_drv_qu.pop_front();

          if(s_drv.compare(mon)) begin
            `uvm_warning("MYWARN1", "This is a warning")
            `uvm_warning("MYWARN1", "This is a warning")
            `uvm_warning("MYWARN1", "This is a warning")
            `uvm_info(get_type_name(), "---------------------------------------", UVM_MEDIUM)
            `uvm_info(get_type_name(), "----  W_W :    COMPARISION PASS           ----", UVM_MEDIUM)
            `uvm_info(get_type_name(), "---------------------------------------", UVM_MEDIUM)
            pkt_match++;
            W_W_pkt_match++;
          end
          else begin
            `uvm_warning("MYWARN1", "This is a warning")
            `uvm_warning("MYWARN1", "This is a warning")
            `uvm_warning("MYWARN1", "This is a warning")
            `uvm_warning("MYWARN1", "This is a warning")
            `uvm_info(get_type_name(), "---------------------------------------", UVM_MEDIUM)
            `uvm_error(get_type_name(), "----  W_W :    COMPARISION FAIL           ----")
            `uvm_info(get_type_name(), "---------------------------------------", UVM_MEDIUM)
            pkt_mismatch++;
            W_W_pkt_mismatch++;
          end
        end
        else begin
          wait(m_drv_qu.size() > 0 );
          error_count = 0; 
          foreach(mon.data[i]) begin
            if (mon.data[i] != sc_mem[mon.address+i])
              error_count++;                                       //increamenting error_count variable if data mismatched
          end 

          m_drv = m_drv_qu.pop_front();

          if(m_drv.compare(mon)) begin
            `uvm_info(get_type_name(), "---------------------------------------", UVM_MEDIUM)
            `uvm_info(get_type_name(), "----  R_R :    COMPARISION PASS           ----", UVM_MEDIUM)
            `uvm_info(get_type_name(), "---------------------------------------", UVM_MEDIUM)
            pkt_match++;
            R_R_pkt_match++;
          end
          else begin
            `uvm_info(get_type_name(), "---------------------------------------", UVM_MEDIUM)
            `uvm_error(get_type_name(), "----  R_R :    COMPARISION FAIL           ----")
            `uvm_info(get_type_name(), "---------------------------------------", UVM_MEDIUM)
            pkt_mismatch++;
            R_R_pkt_mismatch++;
          end

          if(error_count > 0) begin 
            `uvm_error(get_type_name(), $sformatf("------------------------------------------------"))
            `uvm_error(get_type_name(), $sformatf("-------- ROUND ABOUT COMPARISION FAILED --------"))
            `uvm_error(get_type_name(), $sformatf("-------------------------------------------------"))
            R_A_COM_mismatch++;
          end
          else begin
            `uvm_info(get_type_name(), "---------------------------------------", UVM_MEDIUM)
            `uvm_info(get_type_name(), "---- ROUND ABOUT COMPARISION PASSED ----", UVM_MEDIUM)
            `uvm_info(get_type_name(), "---------------------------------------", UVM_MEDIUM)
            R_A_COM_match++;
          end

        end
      end
    end
  endtask : run_phase


  //  ---------------------------------------
  // Report phase
  //---------------------------------------   
  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);

    svr = uvm_report_server::get_server();

    `uvm_info(get_type_name(), $sformatf("*************************************************************************************************"),UVM_MEDIUM)
    // `uvm_info(get_type_name(), $sformatf("Total packet generated = %0d",ei_spi_wr_dly_rd_test::repeat_operation),UVM_MEDIUM)
    `uvm_info(get_type_name(), $sformatf("Total packet Compared = %0d | Matched : %0d | MisMatched : 	%0d",total_pkt_compared,pkt_match,pkt_mismatch),UVM_MEDIUM)
    `uvm_info(get_type_name(), $sformatf("\t-Total sucessefull Packets W_W comparision : %0d  ",W_W_pkt_match),UVM_MEDIUM)
    `uvm_info(get_type_name(), $sformatf("\t-Total Unsucessefull Packets W_W comparision : %0d  ",W_W_pkt_mismatch),UVM_MEDIUM)
    `uvm_info(get_type_name(), $sformatf("\t-Total sucessefull Packets R_R comparision : %0d  ",R_R_pkt_match),UVM_MEDIUM)
    `uvm_info(get_type_name(), $sformatf("\t-Total Unsucessefull Packets R_R comparision : %0d  ",R_R_pkt_mismatch),UVM_MEDIUM)
    `uvm_info(get_type_name(), $sformatf("\t-Total sucessefull Packets Round about comparison : %0d ",R_A_COM_match),UVM_MEDIUM)
    `uvm_info(get_type_name(), $sformatf("\t-Total Unsucessefull Packets Round about comparison : %0d ",R_A_COM_mismatch),UVM_MEDIUM)

    if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
       `uvm_warning("MYWARN1", "This is a warning")
      `uvm_warning("MYWARN1", "This is a warning")
      `uvm_info(get_type_name(), "**************************************************************", UVM_NONE)
      `uvm_info(get_type_name(), "***************       ERROR : TEST CASE FAIL       ***********", UVM_NONE)
      `uvm_info(get_type_name(), "**************************************************************", UVM_NONE)
    end
    else begin
      `uvm_warning("MYWARN1", "This is a warning")
      `uvm_warning("MYWARN1", "This is a warning")
      `uvm_info(get_type_name(), "**************************************************************", UVM_NONE)
      `uvm_info(get_type_name(), "*****************       TEST CASE PASS        ****************", UVM_NONE)
      `uvm_info(get_type_name(), "**************************************************************", UVM_NONE)
    end
  endfunction

endclass 

