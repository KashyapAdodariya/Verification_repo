//
// Deep Copy of CLass Objects //
//
// Default copy constructor is called when we initialize an object with another object of same type -- Shallow Copy

// For DEEP COPY we overload the copy constructor to perform deep copy //

class Data;
  int length;
  
  function new( int len);
    length = len;
  endfunction
  
endclass:Data

class Packet;
  int id;
  bit [7:0] addr;
  Data d_h;
  
  function new(int id, bit[7:0] addr, int length);
    // construct Data object //
    d_h = new(length);
    this.id = id;
    this.addr = addr;
  endfunction
  
  function void copy(Packet pk);
    id = pk.id;
    addr = pk.addr;
    d_h.length = pk.d_h.length;
  endfunction
  
endclass:Packet

module test;
  
  Packet p1_h;
  Packet p2_h;
  
  initial begin
    
    p1_h = new(0, 8'hab, 5);
    
    
    $display("p1 id : %0d, data : %h, length : %0d" , p1_h.id, p1_h.addr, p1_h.d_h.length);
    
    p2_h = new(0, 8'h00, 0);
    
    // call the copy constructor //
    p2_h.copy(p1_h);
    
    $display("p2 id : %0d, data : %h, length : %0d" , p2_h.id, p2_h.addr, p2_h.d_h.length);
    
    // change content of p2_h //
    p2_h.id = 2;
    p2_h.addr = 8'hcd;
    p2_h.d_h.length = 100;

    // Now we can change the length in p2_h without affecting p1_h //
    // which wasn't the case in shallow copy //
    $display("p2 id : %0d, data : %h, length : %0d" , p2_h.id, p2_h.addr, p2_h.d_h.length);
    $display("p1 id : %0d, data : %h, length : %0d" , p1_h.id, p1_h.addr, p1_h.d_h.length);
    
  end
  
endmodule