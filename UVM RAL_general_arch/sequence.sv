class base_seq extends uvm_sequence#(seq_item);
  `uvm_object_utils(base_seq)

  seq_item seq;

  function new(string name = "base_seq");
    super.new(name);
  endfunction: new

  task body();
    `uvm_info(get_type_name(),"base seq body task",UVM_LOW)
    `uvm_do(seq);
  endtask: body

endclass: base_seq


class ral_seq extends base_seq;
  `uvm_object_utils(ral_seq)

  seq_item seq;
  reg_block reg_blk;
  uvm_status_e   status;
  uvm_reg_data_t read_data;

  function new(string name = "ral_seq");
    super.new(name);
  endfunction: new

  task body();
    `uvm_info(get_type_name(),"ral_seq body task",UVM_LOW)
    reg_blk = reg_block::type_id::create("reg_blk");

    if(!(uvm_config_db#(reg_block)::get(uvm_root::get()," ","reg_blk",reg_blk)))
      `uvm_fatal(get_type_name(),"Not getting reg_block")    

      reg_blk.tm_cont_reg.write(status,32'h1234_1234);
    reg_blk.tm_cont_reg.read(status, read_data);
    reg_blk.sts_reg.write(status, 32'h5678_5678);
    reg_blk.sts_reg.read(status, read_data);

  endtask: body

endclass: ral_seq

class ral1_seq extends base_seq;
  `uvm_object_utils(ral1_seq)

  seq_item seq;
  reg_block reg_blk;
  uvm_status_e   status;
  uvm_reg_data_t read_data;

  function new(string name = "ral1_seq");
    super.new(name);
  endfunction: new

  task body();
    `uvm_info(get_type_name(),"ral_seq body task",UVM_LOW)
    reg_blk = reg_block::type_id::create("reg_blk");

    if(!(uvm_config_db#(reg_block)::get(uvm_root::get()," ","reg_blk",reg_blk)))
      `uvm_fatal(get_type_name(),"Not getting reg_block")    

      reg_blk.tm_cont_reg.write(status,32'h1234_1234);
    reg_blk.tm_cont_reg.read(status, read_data);
    reg_blk.sts_reg.write(status, 32'h5678_5678);
    reg_blk.sts_reg.read(status, read_data);

  endtask: body

  //   task write_by_config(input uvm_status_e status, input bit [31:0] data = ral_cfg.pack_reg);

  //   endtask: write_by_config

  //   task read_by_config();

  //   endtask: read_by_config

endclass: ral1_seq
/////////////////////////////////////////////////////////////////////////////////////////////////////////

class reset_reg_seq extends base_seq;
  `uvm_object_utils(reset_reg_seq)

  seq_item seq;
  reg_block reg_blk;
  uvm_status_e   status;
  uvm_reg_data_t read_data;
  uvm_reg_hw_reset_seq reset_seq;

  function new(string name = "reset_reg_seq");
    super.new(name);
  endfunction: new

  task body();
    `uvm_info(get_type_name(),"ral_seq body task",UVM_LOW)
    reg_blk = reg_block::type_id::create("reg_blk");
    reset_seq = uvm_reg_hw_reset_seq::type_id::create("reset_seq");

    if(!(uvm_config_db#(reg_block)::get(uvm_root::get()," ","reg_blk",reg_blk)))
      `uvm_fatal(get_type_name(),"Not getting reg_block")        
    if(!$cast(reset_seq.model,reg_blk))
      `uvm_fatal(get_type_name(),"Castting fail for reset_seq")


  endtask: body

endclass: reset_reg_seq