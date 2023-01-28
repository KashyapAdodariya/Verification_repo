

// Revision: 3
//-------------------------------------------------------------------------------

//------------------------SEQUENCE i2s----------------------------------- 


class write_sequence extends uvm_sequence#(i2s_seq_item);
  
  `uvm_object_utils(write_sequence)

  //prototype
  extern function new(string name = "write_sequence");
  extern virtual task body();

endclass:write_sequence

  //////////////////////////////////////////////////////// 
  // Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : void  
  // Description        : constrctor
  ////////////////////////////////////////////////////////

  function write_sequence :: new(string name = "write_sequence");
    super.new(name);
  endfunction

  //////////////////////////////////////////////////////// 
  // Method name        : body
  // Parameter Passed   : void
  // Returned parameter : void  
  // Description        : randomization and send pkt 
  ////////////////////////////////////////////////////////
  task write_sequence :: body();
    req.seq_repeat = 0;
    repeat(req.no_item) begin
      //`uvm_do(req)
      req = i2s_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize()) begin
      req.trans_count++; 
      req.seq_repeat++;
      //`uvm_info("i2s_sequence_body", $sformatf("Randomization Done for transection count: %0d", req.trans_count++),UVM_LOW)
      `uvm_info("i2s_sequence_body", $sformatf("Printing transaction:\n%0s",req.sprint()),UVM_LOW)
      end
      else
        `uvm_error("i2s_sequence_body",$sformatf("Randomization Fail on Transection count: %0d",req.trans_count++));
      finish_item(req);
    end
  endtask




