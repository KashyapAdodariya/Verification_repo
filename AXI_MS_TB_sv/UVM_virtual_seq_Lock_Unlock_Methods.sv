// Code your testbench here
// or browse Examples
class instruction extends uvm_sequence_item;
  typedef enum {PUSH_A,PUSH_B,ADD,SUB,MUL,DIV,POP_C} inst_t;
  rand inst_t inst;

  `uvm_object_utils_begin(instruction)
    `uvm_field_enum(inst_t,inst, UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name = "instruction");
    super.new(name);
  endfunction

endclass

class instruction_sequencer extends uvm_sequencer #(instruction);

  function new (string name, uvm_component parent);
    super.new(name, parent);
    `uvm_update_sequence_lib_and_item(instruction)
  endfunction

  `uvm_sequencer_utils(instruction_sequencer)

endclass


class seq_a extends uvm_sequence #(instruction);

  instruction req;

  function new(string name="seq_a");
    super.new(name);
  endfunction

  `uvm_sequence_utils(seq_a, instruction_sequencer)

  virtual task body();
    repeat(4) begin
         `uvm_do_with(req, { inst == PUSH_A; });
      end
  endtask

endclass

class seq_b extends uvm_sequence #(instruction);

  instruction req;

  function new(string name="seq_b");
    super.new(name);
  endfunction

  `uvm_sequence_utils(seq_b, instruction_sequencer)

  virtual task body();
    //lock();
    grab();
    repeat(4) begin
         `uvm_do_with(req, { inst == PUSH_B; });
      end
    //unlock();
    ungrab();
  endtask

endclass

class seq_c extends uvm_sequence #(instruction);

  instruction req;

  function new(string name="seq_c");
    super.new(name);
  endfunction

  `uvm_sequence_utils(seq_c, instruction_sequencer)

  virtual task body();
    repeat(4) begin
         `uvm_do_with(req, { inst == POP_C; });
      end
  endtask

endclass

class parallel_sequence extends uvm_sequence #(instruction);

  seq_a s_a;
  seq_b s_b;
  seq_b s_b2;
  seq_c s_c;
    instruction_sequencer m_sqr;

  function new(string name="parallel_sequence");
    super.new(name);
    s_a = seq_a :: type_id :: create("s_a");
    s_b = seq_b :: type_id :: create("s_b");
    //s_b2 = seq_b :: type_id :: create("s_b2");
    s_c = seq_c :: type_id :: create("s_c");
  endfunction

  `uvm_sequence_utils(parallel_sequence, instruction_sequencer)

  virtual task body();
      fork
        s_a.start(m_sqr);
        s_b.start(m_sqr);
        s_c.start(m_sqr);
      join
  endtask

endclass

class instruction_driver extends uvm_driver #(instruction);

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(instruction_driver)

  // Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase (uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      $display("%0t: Driving Instruction  ",$time,req.inst.name());
      #10;
      // rsp.set_id_info(req);   These two steps are required only if 
      // seq_item_port.put(esp); responce needs to be sent back to sequence
      seq_item_port.item_done();
    end
  endtask

endclass


class test extends uvm_test;
  instruction_sequencer sequencer;
  instruction_driver driver;
  parallel_sequence par_seq;
  
  `uvm_component_utils(test)
  
  function new (string name = "", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer = instruction_sequencer::type_id::create("sequencer", this);
    driver   = instruction_driver::type_id::create("driver", this);
  endfunction: build_phase
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction: connect_phase
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    par_seq = parallel_sequence::type_id::create("par_seq");
    par_seq.m_sqr = sequencer;
    phase.raise_objection(this);
    par_seq.start(sequencer);
    phase.drop_objection(this);
  endtask: run_phase
  
endclass: test

module tb();
  initial 
    begin
      run_test("test");
    end
endmodule: tb

