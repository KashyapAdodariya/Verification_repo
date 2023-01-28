class i2s_sequencer extends uvm_sequencer #(i2s_sequence_item);


// Factory registration using `uvm_component_utils
	`uvm_component_utils(i2s_sequencer)

//------------------------------------------
// METHODS
//------------------------------------------

// Standard UVM Methods:
	extern function new(string name = "i2s_sequencer",uvm_component parent);

endclass
//-----------------  constructor new method  -------------------//
function i2s_sequencer::new(string name="i2s_sequencer",uvm_component parent);

	super.new(name,parent);
  $display("sequencer run");

endfunction 