//
// Static variables in classes
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


// static variable is not an dynamic instance
// static variable is only created once and is SHARED across all 
// instances of the class objects
//
// Example: we can use to keep track of packts created
class Packet extends Transaction;
  
  // derived class members
  logic [7:0]  data;
  bit ready;
  // static property //
  static int PacketId = 0;
  
  // constructor is crucial here as the parent class has to be constructed first //
  function new();
    // first call Parent (Base) class using super.new()
    // MUST be the FIRST statement before any other statements//
    super.new();
    $display("--- Derived Constructor Called ---");
    this.data = $urandom_range(10,100);
    this.ready = 1'b1;
    // increment the packet id //
    PacketId = PacketId + 1;
  endfunction
  
  function void display_info();
    $display("-------- DEBUG INFO --------");
    $display(" data generated: %0h", data);
    $display(" Ready = %0b", ready);
    $display(" Packet ID Count = %0d", PacketId);
    $display("-------- END DEBUG --------");  
    
  endfunction:display_info
  
endclass:Packet


module test_inh;
  Transaction tk;
  Packet pk_1;
  Packet pk_2;
  Packet pk_3;
  
  initial begin
    pk_1 = new();
    pk_1.display_info(); // Packet ID Count = 1
    
    pk_2 = new();
    pk_2.display_info(); // Packet ID Count = 2
    
    pk_3 = new();
    pk_3.display_info(); // Packet ID Count = 3
  end
endmodule