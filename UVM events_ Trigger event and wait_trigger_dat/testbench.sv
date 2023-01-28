`include "uvm_macros.svh"
import uvm_pkg::*;

class transaction extends uvm_object;
  rand bit [7:0] addr;
  rand bit [7:0] data;
  
  function new(string name = "transaction");
    super.new(name);
  endfunction
  
  `uvm_object_utils_begin(transaction)
    `uvm_field_int(addr, UVM_PRINT);
    `uvm_field_int(data, UVM_PRINT);
  `uvm_object_utils_end
endclass

module event_example();
  uvm_event e1;
  
  task process_A();
    transaction tr_A = new();
    #10;
    $display("@%0t: Before triggering event e1", $time);
    assert(tr_A.randomize);
    tr_A.print();
    e1.trigger(tr_A);
    $display("@%0t: After triggering event e1", $time);
  endtask
  
  task process_B();
    uvm_object event_data;
    transaction tr_B;
    
    $display("@%0t: waiting for the event e1", $time);
    e1.wait_trigger_data(event_data);
    $cast(tr_B, event_data);
    $display("@%0t: event e1 is triggered and data received = \n%s", $time, tr_B.sprint());
  endtask

  initial begin
    e1 = new();
    fork
      process_A();
      process_B();
    join
  end
endmodule
