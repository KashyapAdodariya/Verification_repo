class ral_env extends uvm_env;
  `uvm_component_utils(ral_env)
  
  //adeptor and reg_modle
  ral_adapter adapter;
  reg_block reg_blk;
  uvm_reg_predictor#(seq_item) ral_predictor;
  
  function new(string name = "ral_env", uvm_component parent);
    super.new(name,parent);
  endfunction: new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    adapter = ral_adapter::type_id::create("adapter");
    reg_blk = reg_block::type_id::create("reg_blk");
    //if(reg_blk.en_predictor_type inside {EXPLICIT, PASSIVE}) begin
    ral_predictor = uvm_reg_predictor#(seq_item)::type_id::create("ral_predictor",this);
    //end
    reg_blk.build();
    reg_blk.reset();
    reg_blk.lock_model();
    `uvm_info(get_type_name(),"Printing reg_block inside ral_env",UVM_LOW)
    reg_blk.print();
    uvm_config_db#(reg_block)::set(null,"*","reg_blk",reg_blk);
    `uvm_info(get_type_name(),"Setting reg_block inside ral_env",UVM_LOW)
  endfunction: build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //not required to connect sequencer and predictor here
    //reg_blk.default_map.set_sequencer(.sequencer(seqr_h))
    reg_blk.default_map.set_base_addr('h0000);
  endfunction: connect_phase
  
endclass: ral_env