//
// Shallow Copy of CLass Objects //
//

// It is also possible to make copy of one one object
// Below exalmple shows shallow copy 
// and how it works and the motivation to do deep copy

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
  
  task Set(int id, bit[7:0] addr, int length);
    // construct Data object //
    d_h = new(length);
    this.id = id;
    this.addr = addr;
    
  endtask
  
endclass:Packet

module test;
  
  Packet p1_h;
  Packet p2_h;
  
  initial begin
    
    p1_h = new;
    
    p1_h.Set(10, 8'hab, 5);
    
    $display("p1 id : %0d, data : %h, length : %0d" , p1_h.id, p1_h.addr, p1_h.d_h.length);
    
    p2_h = new p1_h;
    $display("p2 id : %0d, data : %h, length : %0d" , p2_h.id, p2_h.addr, p2_h.d_h.length);
    
    // change content of p2_h //
    p2_h.id = 2;
    p2_h.addr = 8'hcd;
    p2_h.d_h.length = 100;
    
    // NOTICE Except for length changes in p2 does not reflect changes in p1 //
    // This is Shallow Copy of Class Objects
    // where the content is copied to a new location
    // expect for the Data object, where only the value fo the pointer d_h is copied
    // and not the object itself!
    // -- Deep Copy is required for this !!!
    // topic of next post :-)
    $display("p2 id : %0d, data : %h, length : %0d" , p2_h.id, p2_h.addr, p2_h.d_h.length);
    $display("p1 id : %0d, data : %h, length : %0d" , p1_h.id, p1_h.addr, p1_h.d_h.length);
    
  end
  
endmodule