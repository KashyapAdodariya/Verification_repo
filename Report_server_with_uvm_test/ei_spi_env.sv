`include "ei_spi_agent.sv"
// `include "ei_spi_slv_agent.sv"
`include "ei_spi_scoreboard.sv"
`include "ei_spi_coverage.sv"

class ei_spi_env_c extends uvm_env;

  //---------------------------------------
  // agent and scoreboard instance
  //---------------------------------------
  ei_spi_agent_c 		mst_agent;							
  ei_spi_agent_c 		slv_agent; 
  //   ei_spi_slv_agent_c 	slv_agent; 
  ei_spi_scoreboard_c 	scb;	
  ei_spi_coverage_c 	cvg;


  `uvm_component_utils(ei_spi_env_c)

  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new


  //---------------------------------------
  // build_phase - crate the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mst_agent = ei_spi_agent_c::type_id::create("mst_agent", this);
    slv_agent = ei_spi_agent_c::type_id::create("slv_agent", this);
    //     slv_agent = ei_spi_slv_agent_c::type_id::create("slv_agent", this);
    scb  	  = ei_spi_scoreboard_c::type_id::create("scb", this);
    cvg 	  = ei_spi_coverage_c::type_id::create("cvg", this);


    `uvm_info(get_type_name(), $sformatf("Master agent object created"),UVM_HIGH)
    `uvm_info(get_type_name(), $sformatf("Slave agent object created"),UVM_HIGH)
    `uvm_info(get_type_name(), $sformatf("scoreboard object created"),UVM_HIGH)

  endfunction : build_phase


  //---------------------------------------
  // connect_phase - connecting monitor and scoreboard port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    mst_agent.mon.item_collected_port.connect(scb.analy_fifo.analysis_export);
    `uvm_info(get_type_name(), $sformatf("Mon - SCB Connected"),UVM_HIGH)

    slv_agent.slv_drv.s_drv2scb_port.connect(scb.s_drv2scb_export);
    `uvm_info(get_type_name(), $sformatf("Slave Driver - SCB Connected"),UVM_HIGH)

    mst_agent.mst_drv.m_drv2scb_port.connect(scb.m_drv2scb_export);
    `uvm_info(get_type_name(), $sformatf("Master Driver - SCB Connected"),UVM_HIGH)

    mst_agent.mon.item_collected_port.connect(cvg.coverage_export);//connecting coverage analysis port

  endfunction : connect_phase

endclass : ei_spi_env_c

































