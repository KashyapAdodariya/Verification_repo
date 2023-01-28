

// Revision: 1
//-------------------------------------------------------------------------------

package i2s_pkg;
 
`define size 16
`timescale 1ns/1ps
`define FREQ 48.0000
`define toggle ((1000/`FREQ)/2)

  import uvm_pkg::*;
  `include "uvm_macros.svh"

`include "i2s_config.sv"
`include "i2s_sequence_item.sv"
//`include "i2s_config.sv"
`include "i2s_env_config.sv"
`include "i2s_sequence.sv"
`include "i2s_sequencer.sv"
`include "i2s_scoreboard.sv"
`include "i2s_driver.sv"
`include "i2s_monitor.sv"
`include "i2s_agent.sv"
`include "i2s_agent_top.sv"
`include "i2s_env.sv"
`include "i2s_test.sv"
  

endpackage:i2s_pkg

