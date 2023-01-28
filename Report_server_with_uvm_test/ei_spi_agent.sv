//***************************AGENT**************************
`include "ei_spi_sequence_item.sv"
`include "ei_spi_sequencer.sv"
`include "ei_spi_sequence.sv"
`include "ei_spi_master_driver.sv"
`include "ei_spi_monitor.sv"
`include "ei_spi_slave_driver.sv"

class ei_spi_agent_c extends uvm_agent;

  //---------------------------------------
  // component instances
  //---------------------------------------
  ei_spi_sequencer_c     	seq;						// Creating instance of master generator
  ei_spi_mst_driver_c    	mst_drv;					// Creating instance of master driver
  ei_spi_monitor_c		 	mon;						// Creating instance of monitor
  ei_spi_slv_driver_c 		slv_drv;					// Creating instance of slave driver

  string agent_name;
  `uvm_component_utils(ei_spi_agent_c)


  //---------------------------------------
  // constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    agent_name = name;
  endfunction : new


  //---------------------------------------
  // build_phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(get_is_active()==UVM_ACTIVE && agent_name == "mst_agent")
      begin
        mst_drv = ei_spi_mst_driver_c::type_id::create("mst_drv", this);
        mon = ei_spi_monitor_c::type_id::create("mon", this);
        seq = ei_spi_sequencer_c::type_id::create("seq", this);
      end
    if(agent_name == "slv_agent")
      begin
        slv_drv = ei_spi_slv_driver_c::type_id::create("slv_drv", this);
      end

    `uvm_info(get_type_name(), $sformatf("Master driver object created"),UVM_HIGH)
    `uvm_info(get_type_name(), $sformatf("Monitor object created"),UVM_HIGH)
    `uvm_info(get_type_name(), $sformatf("Sequencer object created"),UVM_HIGH)

  endfunction : build_phase



  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    if(get_is_active()==UVM_ACTIVE && agent_name == "mst_agent") begin
      mst_drv.seq_item_port.connect(seq.seq_item_export);
      `uvm_info(get_type_name(), $sformatf("Master drv - Sequencer Connected"),UVM_HIGH)
    end
  endfunction : connect_phase


endclass : ei_spi_agent_c