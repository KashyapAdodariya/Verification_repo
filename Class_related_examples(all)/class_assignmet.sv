//
//  Class Assignment =
//

/*
	When we assign an object to another handel (which has not been created in memory). Bith the handles will point to same object in the memory and no new object will be created during the assignment
    
    Which implies, changing data variables using oe handle will also be
    seen by the other handle!!
*/

class Transaction;
  // data members //
  logic [15:0] address;
  logic [7:0] data;
  bit valid;
  
  // constructor //
  function new();
    $display("--- Base Constructor Called ---");
    this.valid = 1'b0;
    this.data = 8'haa;
    this.address = $urandom_range(10,100);
  endfunction
  
  // class method (member function) //
  function void display_info();
    $display("-------- DEBUG INFO --------");
    $display(" address assigned: %0h", address);
    $display(" data: %0h", data);
    $display(" Valid = %b", valid);
    $display("-------- END DEBUG --------");  
    
  endfunction:display_info
  
endclass:Transaction


module test_inh;
  initial
    begin
      // object memory is created and t1_h points to it
      Transaction t1_h = new();
      Transaction t2_h; // create a handle
      // perform object assignment
      // still only one object in memory is present
      // both handles will point to the same object in memory
      t2_h = t1_h;
      
      t2_h.display_info(); //o/p: t2_h.data = 8'haa
      // lets change data using t1_h
      t1_h.data = 8'h11;
      
      // we will see the change made using t1_h on t2_h
      t2_h.display_info(); // o/p: t2_h.data = 8'h11

    end
endmodule