class virtual_seqr_h extends uvm_sequencer;
  
  sequencer_h    seqr;
  //if have more seqr write here instances of rest of seqr.
  
  `uvm_component_utils(virtual_seqr_h)
  
  function new(string name = "virtual_seqr_h", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  //try without testcase
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     //seqr = sequencer_h::type_id::create("seqr",this);
//   endfunction 
  
endclass: virtual_seqr_h