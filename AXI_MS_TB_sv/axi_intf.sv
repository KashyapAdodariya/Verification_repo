
interface axi_intf #(parameter int AWIDTH = 32, parameter int WIDTH = 32) (input bit ACLK, bit ARESETn,bit mclk);
  
  //--- OUTPUT (as per MASTER) ---
  logic [3:0]AWID;
  logic [AWIDTH-1:0]AWADDR;
  logic [7:0]AWLEN;
  logic [2:0]AWSIZE;
  logic [1:0]AWBURST;
  logic AWVALID;
  
  logic [3:0]WID;
  logic [WIDTH-1:0]WDATA;
  logic [(WIDTH/8)-1:0]WSTRB;
  logic WLAST;
  logic WVALID;
  
  logic BREADY;
  
  logic [3:0]ARID;
  logic [AWIDTH-1:0]ARADDR;
  logic [7:0]ARLEN;
  logic [2:0]ARSIZE;
  logic [1:0]ARBURST;
  logic ARVALID;
  
  logic RREADY;
  
  //--- INPUT (as per MASTER)---
  
  logic AWREADY;
  
  logic WREADY;
 
  logic [3:0]BID;
  logic [1:0]BRESP;
  logic BVALID;
  
  logic ARREADY;
  
  logic [3:0]RID;
  logic [WIDTH-1:0]RDATA;
  logic [1:0]RRESP;
  logic RLAST;
  logic RVALID;
  
  logic [31:0] mem [256];
  
  //slave clocking block
  clocking slave_cb @(posedge ACLK or negedge ARESETn);
    default input #1 output #1;
    output AWREADY,WREADY,BID,BRESP,BVALID,ARREADY,RID,RDATA,RRESP,RLAST,RVALID,mem;
    input AWID,AWADDR,AWLEN,AWBURST,AWSIZE,AWVALID,WID,WDATA,WSTRB,WLAST,WVALID,BREADY,ARID,mclk,
           ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID,RREADY;
  endclocking : slave_cb
  
  //monitor clockin block
  clocking monitor_cb @(posedge ACLK or negedge ARESETn);
    default input #1;
    input AWREADY,WREADY,BID,BRESP,BVALID,ARREADY,RID,RDATA,RRESP,RLAST,RVALID,AWID,AWADDR,AWLEN,AWBURST,
          AWSIZE,AWVALID,WID,WDATA,WSTRB,WLAST,WVALID,BREADY,ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID,RREADY;
  endclocking : monitor_cb
  
  //master clocking block
  clocking master_cb @(posedge ACLK or negedge ARESETn);
    default input #1 output #1;
    input AWREADY,WREADY,BID,BRESP,BVALID,ARREADY,RID,RDATA,RRESP,RLAST,RVALID;
    output AWID,AWADDR,AWLEN,AWBURST,AWSIZE,AWVALID,WID,WDATA,WSTRB,WLAST,WVALID,BREADY,ARID,
           ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID,RREADY;
  endclocking : master_cb
  
  //slave modport
  modport slave_mp (clocking slave_cb);
  
  //monitor modport
  modport monitor_mp (clocking monitor_cb);
    
  //master modport
  modport master_mp (clocking master_cb);
  
endinterface : axi_intf
