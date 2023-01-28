

// Revision: 3
//-------------------------------------------------------------------------------


class i2s_sub extends uvm_subscriber#(i2s_seq_item);
  `uvm_component_utils(i2s_sub)
  i2s_seq_item seq;
  
  covergroup i2s_cg;
    full_data: coverpoint seq.data{
      bins data_f = {[15:$]};
    }
  endgroup:i2s_cg
  
  function new(string name = "i2s_sub", uvm_component parent);
    super.new(name, parent);
    i2s_cg = new;
    `uvm_info(get_type_name(),"subscriber run",UVM_LOW)
  endfunction:new
  
  virtual function void write(i2s_seq_item seq);
    this.seq = seq;
    i2s_cg.sample();
  endfunction:write
  
endclass:i2s_sub
  
  
