//
// SystemVerilog Object Oriented Programming Features 
//


// PART-1: Classes in SystemVerilog


class Transaction;
  // data members //
  logic [15:0] address;
  logic [7:0]  data;
  
  bit ready;
  bit valid;
  
  // constructor //
  function new();
    $display("--- Constructor Called ---");
    this.ready = 1'b1;
    this.valid = 1'b0;
    this.address = $urandom_range(10,100);
    this.data = $urandom_range(10,100);
  endfunction
  
  // class method (member function) //
  function void display_info();
    $display("-------- DEBUG INFO --------");
    $display(" address assigned: %0h", address);
    $display(" data generated: %0h", data);
    $display(" Valid = %b, Ready = %0b", valid, ready);
    $display("-------- END DEBUG --------");  
    
  endfunction:display_info
  
endclass:Transaction



module test;
  
initial
  begin
    // declare the class object
    Transaction bus_tran;
    for(int i = 0; i < 2; i=i+1)
      begin
        // construct class object
        // Object is created in the memory and pointer to the address of the menory is assigned to the object handle i.e. bus_tran
        
        bus_tran = new(); // constructor new() is called
        bus_tran.display_info();
      end
  end
  
  // INTERVIEW QUESTION: What difference will it make if we place
  // bus_tran = new(); before the for loop ?
  
endmodule:test