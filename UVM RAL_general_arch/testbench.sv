//`include "uvm_macros.svh"
`include "interface.sv"
`include "base_test.sv"
//import uvm_pkg::*;
`define DUT_EN
module tb_top;
  bit clk;
  bit reset_n;
  always #1 clk = ~clk;
  
  initial begin
    reset_n = 0;
    #5; 
    reset_n = 1;
  end
  
  intf vif(clk,reset_n);
 
  `ifdef DUT_EN
  design_sfr DUT(vif.clk, vif.reset_n, vif.i_wr_en, vif.i_rd_en, vif.i_waddr, vif.i_raddr, vif.i_wdata, vif.i_wstrobe, vif.o_rdata, vif.o_wready, vif.o_rvalid);
  `endif
  initial begin
    uvm_config_db#(virtual intf)::set(uvm_root::get(),"*","vif",vif);
    $dumpfile("dump.vcd");
    $dumpvars(0); //(0, tb_top);    
  end
  
  initial begin
    run_test();
  end
  
endmodule: tb_top