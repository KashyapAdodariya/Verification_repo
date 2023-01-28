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
    this.data = 8'h00;
    this.address = 8'h00;
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
  
  task modify(Transaction T);
    // create the transcation object in memory //
    T = new();
    T.address = 8'hab;
    T.data = 8'hcd;
  endtask
  
  task modify_ref(ref Transaction T);
    // create the transcation object in memory //
    T = new();
    T.address = 8'hab;
    T.data = 8'hcd;
  endtask
  
  initial
    begin
      // handle //
      Transaction tx_h;
      // send to task to modify data members //
      modify(tx_h);
      // ERROR: referening to null object in memory //
      // as the handle is not passed using reference any modifications will not be seen to original handle//
      // in this case the handel is created in the modify task, so outside the task handle tx_h is not even allocated
      
      // tx_h.display_info(); 
      
      // Pass by reference to a task to modify data members //
      // this will work correctly. //
      // as we pass handel by reference so the allocated memory and data member modifications are in reference to the handel tx_h //
      modify_ref(tx_h);
      tx_h.display_info();

    end
endmodule