`define test_one

`define NO_OF_SLAVE 1
`define ADDR_WIDTH 1									//address width in byte.(No of locations in memory)
`define DATA_WIDTH 1									//data width in byte.(width of memory)
`define CLK_delay 1										// Set delay of base clock
`define assertion_disable 0								//disable all the assertions

//including interfcae and testcase files
`include "ei_spi_interface.sv"
`include "ei_spi_test.sv"



module ei_spi_top;

  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------

  bit CLK ;												// Base clock with delay of 1 ns

  //---------------------------------------
  //clock generation
  //---------------------------------------
  always #`CLK_delay  CLK = ~CLK;	

  
  ei_spi_interface_i m_pif(.CLK(CLK));
  ei_spi_interface_i s_pif(.CLK(CLK));

  //---------------------------------------
  //bind interface signals
  //---------------------------------------
  assign s_pif.SS_  = m_pif.SS_;
  assign s_pif.SCLK = m_pif.SCLK;
  assign s_pif.MOSI = m_pif.MOSI;
  assign m_pif.MISO = s_pif.MISO;
  
  //------------------------added--------------------
  assign s_pif.RESETn = m_pif.RESETn;

//   initial begin
//     RESETn = 0;
//     $display($time,,"RESETn : %0d" , RESETn);
//     #50;
//     RESETn = 1;
//     $display($time,,"RESETn : %0d" , RESETn);
//   end
  
  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  initial begin 

    uvm_config_db#(virtual ei_spi_interface_i)::set(uvm_root::get(),"*","m_vif",m_pif);
    uvm_config_db#(virtual ei_spi_interface_i)::set(uvm_root::get(),"*","s_vif",s_pif);
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end

  initial begin 
    if(`assertion_disable)
      $assertoff();
  end
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin 
    run_test();
  end

endmodule : ei_spi_top