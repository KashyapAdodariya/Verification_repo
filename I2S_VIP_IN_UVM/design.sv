
/*=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:
  * File Name          : i2s_pkg.sv
  * Title              :                                                                                                                         
  * Created Date       : Friday 06 August 2021 01:24:12 PM
  * Last Modified Date : Saturday 28 August 2021 08:30:28 AM
  * purpose            :  
  * Author             : Kashyap Adodariya  
  * Organization       : EITRA
  * Modifier           : Kashyap Adodariya  
  * Assumptions        :   
  * Limitation         :   
  * Know Errors        :   
=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:*/  

/*-------------------------------------------------------------------------------
  Copyright (c) 2000-2021 eInfochips. - All rights reserved

  This software is authored by eInfochips and is eInfochips intellectual
  property, including the copyrights in all countries in the world. This 
  software is provided under a license to use only with all other rights,
  including ownership rights, being retained by eInfochips. 

  This file may not be distributed, copied, or reproduced in any manner,
  electronic or otherwise, without the express written consent of eInfochips.
-------------------------------------------------------------------------------*/

// Revision: 3
//-------------------------------------------------------------------------------


package i2s_pkg;
`define size 16
`timescale 1ns/1ps
`define FREQ 48.0000
`define toggle ((1000/`FREQ)/2)

	import uvm_pkg::*;

typedef enum {ENABLE, DISABLE} en_dis_switch;
//trasaction mode
typedef enum {TX,RX,CONTROLLER} transaction_mode_e;
//---for select word length---//
typedef enum {WLEN8=8,WLEN16=16,WLEN18=18,WLEN20=20,WLEN24=24} word_length_e;
//---for select channle mode---//
typedef enum {MONO_RIGHT,MONO_LEFT,STEREO} channel_mode_e;

	  `include "uvm_macros.svh"
`include "i2s_driver_callback.sv"
    `include "i2s_seq_item.sv"
    `include "i2s_config.sv"
    `include "i2s_env_config.sv"
    `include "i2s_agent_config.sv"
    `include "i2s_sequence.sv"
    `include "i2s_sub.sv"
    `include "i2s_master_sequencer.sv"
    `include "i2s_slave_sequencer.sv"
    `include "i2s_master_driver.sv"
    `include "i2s_slave_driver.sv"
    `include "i2s_master_monitor.sv"
    `include "i2s_slave_monitor.sv"
//`include "i2s_report_server.sv"
`include "i2s_report_catcher.sv"
    `include "i2s_scoreboard.sv"
	  `include "i2s_agent.sv"
    `include "i2s_agent_top.sv"
  	`include "i2s_env.sv"
    `include "i2s_base_test.sv"
    `include "stereo_mode_test.sv"

endpackage

//+UVM_TESTNAME=stereo_mode_test +UVM_VERBOSITY=UVM_LOW +UVM_TIMEOUT=500000 +UVM_CONFIG_DB_TRACE +UVM_MAX_QUIT_COUNT=10 +UVM_PHASE_TRACE +UVM_OBJECTION_TRACE  