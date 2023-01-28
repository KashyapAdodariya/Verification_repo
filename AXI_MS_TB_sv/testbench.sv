`include "axi_header.svh"

//--- define top module of axi master vip ---
module top;
  
  //--- declare clock and reset signals ---
  reg ACLK,ARESETn,mclk;

  //--- initialise clock and signal to zero
	initial begin
    $display("--- start of stimulation ---");
		ACLK=1;
        mclk =1;
		ARESETn=0;
    //--- generate clock ---
      fork
		forever #5 ACLK=~ACLK;
        forever #10 mclk=~mclk;
      join
	end

  //--- call finish ---
	initial begin
		#3000;
    $display("--- end of stimulation ---");
		$finish;
	end

  //--- instantiate interface program block and dut---
  axi_intf pif(ACLK,ARESETn,mclk);
  axi_m_tb tb();
  //slave s0(pif.slave_mp);

  //--- pass physical handle of interface to virtual handle of same in configfile
  initial begin
    axi_m_config::vif=pif;
  end

  //--- declare dumpfile for waveform
  initial begin
    $dumpfile("axi_master.vcd");
    $dumpvars;
  end
 
  //initial begin
    //pif.AWREADY <= 1;
    //pif.WREADY <= 1;
    //pif.ARREADY <= 1;
  //end
    

endmodule //end of top module


