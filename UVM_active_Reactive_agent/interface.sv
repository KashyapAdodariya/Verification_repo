interface intf_h(input logic clock);
  logic [7:0]addr;
  logic [31:0]wdata;
  logic [31:0]rdata;
  logic r_w;
endinterface: intf_h