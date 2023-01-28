// Code your design here
// Register Info:

// 

module simpleDUT(
  input        clk,
  input        resetb,
  input        req,
  input        wr1rd0,
  input  [7:0] addr,
  input  [7:0] data,
  
  output       ack,
  output [7:0] rd_data
);

  reg [7:0] rd_dataQ;
  reg [7:0] mem[16];
  reg [7:0] rega1Q;
  reg [7:0] rega2Q;
  reg [7:0] regb1Q;
  reg [7:0] regb2Q;
  reg [7:0] regbQ;
  reg       ackQ;
  
  assign rd_data = rd_dataQ;
  assign ack     = ackQ;
  
  always_ff@(posedge clk or resetb) begin
    if(!resetb) begin
      foreach(mem[i]) begin
        mem[i] <= 0;
      end
    end
    else begin
      if(req && ackQ && wr1rd0 && (addr >= 8'h04)) begin
        mem[addr-4] <= data;
      end
    end
  end
  
  always_ff@(posedge clk or resetb) begin : ack_ff
    if(!resetb) begin
      ackQ <= 0;
    end
    else begin
      if(req) begin
        ackQ <= ackQ ? 0 : $urandom;
      end
      else begin
        ackQ <= 0;
      end
    end
  end : ack_ff
  
  always_ff@(posedge clk or resetb) begin : rega1_ff
    if(!resetb) begin
      rega1Q <= 8'h10;
    end
    else begin
      if(req && ackQ && wr1rd0 && (addr == 8'h00)) begin
        rega1Q <= data;
      end
    end
  end : rega1_ff
  
  always_ff@(posedge clk or resetb) begin : rega2_ff
    if(!resetb) begin
      rega2Q <= 8'h10;
    end
    else begin
      if(req && ackQ && wr1rd0 && (addr == 8'h01)) begin
        rega2Q <= data;
      end
    end
  end : rega2_ff
  
  always_ff@(posedge clk or resetb) begin : regb1_ff
    if(!resetb) begin
      regb1Q <= {4'b0101, 4'h0};
    end
    else begin
      if(req && ackQ && wr1rd0 && (addr == 8'h02)) begin
        regb1Q[5:0] <= data[5:0];
      end
    end
  end : regb1_ff
  
  always_ff@(posedge clk or resetb) begin : regb2_ff
    if(!resetb) begin
      regb2Q <= {4'b0101, 4'h0};
    end
    else begin
      if(req && ackQ && wr1rd0 && (addr == 8'h03)) begin
        regb2Q[5:0] <= data[5:0];
      end
    end
  end : regb2_ff
  
  always_comb begin
    case(addr) inside
      8'h00: rd_dataQ = rega1Q;
      8'h01: rd_dataQ = rega2Q;
      8'h02: rd_dataQ = regb1Q;
      8'h03: rd_dataQ = regb2Q;
      [8'h04:8'hFF]: rd_dataQ = mem[addr-4];
    endcase
  end
  
endmodule : simpleDUT