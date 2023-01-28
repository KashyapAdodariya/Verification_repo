//`ifdef test_one
`include "report_server.sv"
`include "ei_spi_config_c.sv"
`include "ei_spi_env.sv"


//------------------------- BASE TEST --------------------------
class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  virtual function void start_of_simulation_phase (uvm_phase phase);
    
    
     my_report_server my_server = new;
   
      super.start_of_simulation_phase( phase );
    
   // set_report_severity_action(UVM_ERROR | UVM_LOG, UVM_DISPLAY);
    //if(uvm_severity == UVM_ERROR)
      uvm_report_server::set_server( my_server );
    uvm_top.print_topology();				//print the whole testbench topology
  endfunction


  ei_spi_env_c env;
  ei_spi_config_c cnfg;
  ei_spi_agent_c agent;
  ei_spi_sanity_test sequence_h;

  //---------added-----------
  virtual ei_spi_interface_i m_vif;

  function new(string name = "base_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new
  
  
  


  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    
        
    //--------------------added---------------------------
    if(!uvm_config_db#(virtual ei_spi_interface_i)::get(this, "", "m_vif", m_vif))
      `uvm_fatal("NO_vif",{"virtual interface must be set for: ",get_full_name(),".m_vif"});
    //----------------------------------------------------

    env = ei_spi_env_c::type_id::create("env", this);
    agent = ei_spi_agent_c::type_id::create("agent",this);
    sequence_h = ei_spi_sanity_test::type_id::create("sequence_h");
    // seq = ei_spi_sanity_test::type_id::create("seq");

    CONFIGURE_VALUES();		
    

    cnfg = ei_spi_config_c::type_id::create("cnfg", this);
    if(!cnfg.randomize())
      `uvm_fatal(get_type_name(), "******************** Randomization Failed ****************************")

      uvm_config_db #(ei_spi_config_c) :: set (this,"*","ei_spi_config_c",cnfg);

    // starting a sequence with default_sequence----------------------------------------------------
    //uvm_config_db#(uvm_object_wrapper)::set(this, "env.agent.sequencer.run_phase", "default_sequence", ei_spi_sanity_test::type_id::get());



    //      uvm_config_db#(uvm_object_wrapper)::set(this,"my_env_h.my_wr_agent_h.my_wr_sequencer_h.reset_phase","default_sequence",my_reset_sequence::type_id::get());
    uvm_config_db#(uvm_sequence_base)::dump();

  endfunction : build_phase


  virtual function void display_arb_cfg();
    UVM_SEQ_ARB_TYPE  arb_properties;
    arb_properties = env.mst_agent.seq.get_arbitration();
    `uvm_info("TEST", $sformatf("==================== Current arbitration of sequencer  :- %s =========================", arb_properties.name()), UVM_LOW)
  endfunction


  virtual function void CONFIGURE_VALUES();
  endfunction

  /// Pre-reset Phase Task LOW

  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    m_vif.RESETn = 0;				//reset applied(active low s/g)
    `uvm_info(get_type_name(), $sformatf("	Reset Applied :- RESETn : %0d ",m_vif.RESETn),UVM_LOW)
    #140;
    m_vif.RESETn = 1;				//deassert the reset
    `uvm_info(get_type_name(), $sformatf(" Reset Deasserted :- RESETn : %0d ",m_vif.RESETn),UVM_LOW)
    //     reset_seq.start(env.mst_agent.seq);
    phase.drop_objection(this);
  endtask: reset_phase 

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //  seq.start(env.mst_agent.seq);
    phase.drop_objection(this);
  endtask : run_phase


endclass : base_test


//---------------1. SPI_CPOL_LO_CPHA_LO_LSBFE_LO------------------
class SPI_CPOL_LO_CPHA_LO_LSBFE_LO extends base_test;
  `uvm_component_utils(SPI_CPOL_LO_CPHA_LO_LSBFE_LO)

  //sanity_plus_10_b_2_b_W_R seq; // sanity and 10_B2B cases are running
  //sanity_plus_10_b_2_b_W_R_P seq1;
  ei_spi_sanity_test seq_1;
  ei_spi_10_b2b_wr_10_b2b_rd_test seq_2;
  ei_spi_wr_dly_rd_test seq_3;

  function new(string name = "SPI_CPOL_LO_CPHA_LO_LSBFE_LO",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //--------------------added---------------------------
    seq_1 = ei_spi_sanity_test::type_id::create("seq_1",this);
    seq_2 = ei_spi_10_b2b_wr_10_b2b_rd_test::type_id::create("seq_2",this);
    seq_3 = ei_spi_wr_dly_rd_test::type_id::create("seq_3",this);

    //CONFIGURE_VALUES task is used to override base configuration with CPOL_LO_CPHA_LO_LSBFE_LO 
  endfunction : build_phase
  virtual function void CONFIGURE_VALUES();
    set_type_override_by_type(ei_spi_config_c::get_type(), CPOL_LO_CPHA_LO_LSBFE_LO::get_type());
  endfunction : CONFIGURE_VALUES

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
  // env.mst_agent.seq.set_arbitration(UVM_SEQ_ARB_FIFO);
    //     env.mst_agent.seq.set_arbitration(UVM_SEQ_ARB_RANDOM);
    //env.mst_agent.seq.set_arbitration(UVM_SEQ_ARB_STRICT_FIFO); //132
     //env.mst_agent.seq.set_arbitration(UVM_SEQ_ARB_STRICT_RANDOM); //
    //      env.mst_agent.seq.set_arbitration(UVM_SEQ_ARB_WEIGHTED);
   // display_arb_cfg();
    //==========================================================================================
    /*     							- UVM_SEQ_ARB_FIFO

                    - Without Priority - 

                    - With Priority  -
*/    
    //==========================================================================================



    //without priority
    fork
      seq_1.start(env.mst_agent.seq);
       seq_2.start(env.mst_agent.seq);           //Default Arbitaration UVM_SEQ_ARB_FIFO
      seq_3.start(env.mst_agent.seq);
    join 

    //with priority
//           fork
//        		 repeat(3)    seq_1.start(env.mst_agent.seq, .this_priority(200))	;//rd
//         	repeat(3)   seq_2.start(env.mst_agent.seq, .this_priority(100) ); //No eeffect of priority         
//         	repeat(3)    seq_3.start(env.mst_agent.seq, .this_priority(500) ); //wr-5 times
//           join 

    phase.drop_objection(this);

    // seq1.start(env.mst_agent.seq); // starting the sequence

  endtask : run_phase


endclass 










































//---------------2. SPI_CPOL_LO_CPHA_LO_LSBFE_HI------------------
class SPI_CPOL_LO_CPHA_LO_LSBFE_HI extends base_test;

  ei_spi_wr_dly_rd_test seq;

  `uvm_component_utils(SPI_CPOL_LO_CPHA_LO_LSBFE_HI)
  //   CPOL_LO_CPHA_LO_LSBFE_HI cnfg_two;
  function new(string name = "SPI_CPOL_LO_CPHA_LO_LSBFE_HI",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //--------------------added---------------------------
    seq = ei_spi_wr_dly_rd_test::type_id::create("seq");
  endfunction : build_phase 

  virtual function void CONFIGURE_VALUES();
    set_type_override_by_type(ei_spi_config_c::get_type(), CPOL_LO_CPHA_LO_LSBFE_HI::get_type());		//parent,child
    //     factory.print();
    $display("************************Inside child function**********************************");
  endfunction : CONFIGURE_VALUES

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.mst_agent.seq);
    phase.drop_objection(this);
  endtask : run_phase

endclass 

//---------------3. SPI_CPOL_LO_CPHA_HI_LSBFE_LO --------------------------------
class SPI_CPOL_LO_CPHA_HI_LSBFE_LO extends base_test;
  `uvm_component_utils(SPI_CPOL_LO_CPHA_HI_LSBFE_LO)

  function new(string name = "SPI_CPOL_LO_CPHA_HI_LSBFE_LO",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  function void CONFIGURE_VALUES();
    set_type_override_by_type(ei_spi_config_c::get_type(), CPOL_LO_CPHA_HI_LSBFE_LO::get_type());		//parent,child
  endfunction : CONFIGURE_VALUES

endclass 







//default sequence scenario
//---------------4. SPI_CPOL_LO_CPHA_HI_LSBFE_HI --------------------------------
class SPI_CPOL_LO_CPHA_HI_LSBFE_HI extends base_test;
  `uvm_component_utils(SPI_CPOL_LO_CPHA_HI_LSBFE_HI)
  ei_spi_sanity_test seq; 
  function new(string name = "SPI_CPOL_LO_CPHA_HI_LSBFE_HI",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //--------------------added---------------------------
    seq = ei_spi_sanity_test::type_id::create("seq");
  endfunction : build_phase 


  virtual function void CONFIGURE_VALUES();
    set_type_override_by_type(ei_spi_config_c::get_type(), CPOL_LO_CPHA_HI_LSBFE_HI::get_type());		//parent,child
  endfunction : CONFIGURE_VALUES

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.mst_agent.seq);
    phase.drop_objection(this);
  endtask : run_phase


endclass 




















//---------------5. SPI_CPOL_HI_CPHA_LO_LSBFE_LO --------------------------------
class SPI_CPOL_HI_CPHA_LO_LSBFE_LO extends base_test;

  `uvm_component_utils(SPI_CPOL_HI_CPHA_LO_LSBFE_LO)

  function new(string name = "SPI_CPOL_HI_CPHA_LO_LSBFE_LO",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void CONFIGURE_VALUES();
    set_type_override_by_type(ei_spi_config_c::get_type(), CPOL_HI_CPHA_LO_LSBFE_LO::get_type());		//parent,child
  endfunction : CONFIGURE_VALUES

endclass 

//---------------6. SPI_CPOL_HI_CPHA_LO_LSBFE_HI --------------------------------
class SPI_CPOL_HI_CPHA_LO_LSBFE_HI extends base_test;

  `uvm_component_utils(SPI_CPOL_HI_CPHA_LO_LSBFE_HI)

  function new(string name = "SPI_CPOL_HI_CPHA_LO_LSBFE_HI",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void CONFIGURE_VALUES();
    set_type_override_by_type(ei_spi_config_c::get_type(), CPOL_HI_CPHA_LO_LSBFE_HI::get_type());		//parent,child
  endfunction : CONFIGURE_VALUES

endclass : SPI_CPOL_HI_CPHA_LO_LSBFE_HI

//---------------7. SPI_CPOL_HI_CPHA_HI_LSBFE_LO --------------------------------
class SPI_CPOL_HI_CPHA_HI_LSBFE_LO extends base_test;

  `uvm_component_utils(SPI_CPOL_HI_CPHA_HI_LSBFE_LO)

  function new(string name = "SPI_CPOL_HI_CPHA_HI_LSBFE_LO",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void CONFIGURE_VALUES();
    set_type_override_by_type(ei_spi_config_c::get_type(), CPOL_HI_CPHA_HI_LSBFE_LO::get_type());		//parent,child
  endfunction : CONFIGURE_VALUES

endclass 

//---------------8. SPI_CPOL_HI_CPHA_HI_LSBFE_HI --------------------------------
class SPI_CPOL_HI_CPHA_HI_LSBFE_HI extends base_test;

  `uvm_component_utils(SPI_CPOL_HI_CPHA_HI_LSBFE_HI)

  function new(string name = "SPI_CPOL_HI_CPHA_HI_LSBFE_HI",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void CONFIGURE_VALUES();
    set_type_override_by_type(ei_spi_config_c::get_type(), CPOL_HI_CPHA_HI_LSBFE_HI::get_type());		//parent,child
  endfunction : CONFIGURE_VALUES

endclass 

//---------------9. SPI_SCLK_ERR --------------------------------
class SPI_SCLK_ERR extends base_test;

  `uvm_component_utils(SPI_SCLK_ERR)

  function new(string name = "SPI_SCLK_ERR",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void CONFIGURE_VALUES();
    set_type_override_by_type(ei_spi_config_c::get_type(), SCLK_ERR_TEST::get_type());		//parent,child
  endfunction : CONFIGURE_VALUES

endclass

//---------------10. SPI_SS_ERR --------------------------------
class SPI_SS_ERR extends base_test;

  `uvm_component_utils(SPI_SS_ERR)

  function new(string name = "SPI_SS_ERR",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void CONFIGURE_VALUES();
    set_type_override_by_type(ei_spi_config_c::get_type(), SS_ERR_TEST::get_type());		//parent,child
  endfunction : CONFIGURE_VALUES

endclass


