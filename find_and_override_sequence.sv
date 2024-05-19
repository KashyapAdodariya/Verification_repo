// Code your testbench here
// or browse Examples

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_transaction extends uvm_sequence_item;
  `uvm_object_utils(my_transaction)
  function new(string name="my_transaction");
    super.new(name);
  endfunction
endclass

class my_sequence extends uvm_sequence #(my_transaction);
  `uvm_object_utils(my_sequence)
  function new(string name="my_sequence");
    super.new(name);
  endfunction
endclass

// Function to get the type of sequence given a string
function uvm_object_wrapper get_sequence_type(string sequence_type_name,path="");
    uvm_object_wrapper sequence_type;
  if (!uvm_factory::get().find_override_by_name(sequence_type_name, path)) begin
        `uvm_error("GET_SEQUENCE_TYPE", $sformatf("Sequence type %s not found in the factory", sequence_type_name));
        return null;
    end
    return sequence_type;
endfunction

// Usage example:
module top;
    initial begin
        string sequence_name = "my_sequence";
      uvm_object_wrapper sequence_type = get_sequence_type(sequence_name);
        if (sequence_type != null) begin
            $display("Sequence type %s found in the factory", sequence_name);
        end
    end
endmodule