class ral_env_h extends uvm_env;
  `uvm_component_utils(ral_env_h)
  
  //adeptor and reg_modle
  ral_adapter_h adapter;
  reg_block_h reg_blk;
  uvm_reg_predictor#(sequence_item_h) ral_predictor;
  
  function new(string name = "ral_env_h", uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(),"ral_env new call",UVM_LOW)
  endfunction: new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"ral_env build_phase call",UVM_LOW)
    adapter = ral_adapter_h::type_id::create("adapter");
    reg_blk = reg_block_h::type_id::create("reg_blk");
    ral_predictor = uvm_reg_predictor#(sequence_item_h)::type_id::create("ral_predictor",this);
    reg_blk.build();
    reg_blk.reset();
    reg_blk.lock_model();
    `uvm_info(get_type_name(),"Printing reg_block inside ral_env_h",UVM_LOW)
    reg_blk.print();
    uvm_config_db#(reg_block_h)::set(null,"*","reg_blk",reg_blk);
    `uvm_info(get_type_name(),"Setting reg_block inside ral_env_h",UVM_LOW)
  endfunction: build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(),"ral_env connect_phase call",UVM_LOW)
    //not required to connect sequencer and predictor here
    //reg_blk.default_map.set_sequencer(.sequencer(seqr_h))
    reg_blk.default_map.set_base_addr('h0000);
  endfunction: connect_phase
  
endclass: ral_env_h