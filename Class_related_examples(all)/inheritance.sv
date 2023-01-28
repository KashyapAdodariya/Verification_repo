//
// Inheritance
//

class Transaction;
  // data members //
  logic [15:0] address;
  bit valid;
  
  // constructor //
  function new();
    $display("--- Base Constructor Called ---");
    this.valid = 1'b0;
    this.address = $urandom_range(10,100);
  endfunction
  
  // class method (member function) //
  function void display_info();
    $display("-------- DEBUG INFO --------");
    $display(" address assigned: %0h", address);
    $display(" Valid = %b", valid);
    $display("-------- END DEBUG --------");  
    
  endfunction:display_info
  
endclass:Transaction

class Packet extends Transaction;
  
  // derived class members
  logic [7:0]  data;
  bit ready;
  
  // constructor is crucial here as the parent class has to be constructed first //
  function new();
    // first call Parent (Base) class using super.new()
    // MUST be the FIRST statement before any other statements//
    super.new();
    $display("--- Derived Constructor Called ---");
    this.data = $urandom_range(10,100);
    this.ready = 1'b1;
  endfunction
  
  function void display_info();
    $display("-------- DEBUG INFO --------");
    $display(" data generated: %0h", data);
    $display(" Ready = %0b", ready);
    $display("-------- END DEBUG --------");  
    
  endfunction:display_info
  
endclass:Packet


module test_inh;
  Transaction tk;
  Packet pk;
  
  initial begin
    tk = new();
    pk = new();
    
    pk.display_info();
  end
endmodule