

class transaction_item extends uvm_sequence_item;
  
  logic [3:0]temp;
  
  `uvm_object_utils(transaction_item)
  
  function new(string name = "transaction_item");
    super.new(name);
  endfunction: new
  
endclass: transaction_item



class transaction_item_1 extends uvm_sequence_item;
  
  bit [3:0]temp;
  
  `uvm_object_utils(transaction_item_1)
  
  function new(string name = "transaction_item_1");
    super.new(name);
  endfunction: new
  
endclass: transaction_item_1