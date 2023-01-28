class seq_item extends uvm_sequence_item;
    rand int temp;

    function new(string name = "seq_item");
        super.new(name);
    endfunction: new

    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(temp, UVM_DEFAULT)
    `uvm_object_utils_end

    constraint temp_c {temp inside {[1:20]};}
endclass: seq_item

class sequencer extends uvm_sequencer#(seq_item);
    `uvm_component_utils(sequencer)

    function new(string name = "seq_item", uvm_component parent = null);
        super.new(name, parent);
        //`uvm_update_sequence_lib_and_item(seq_item)
    endfunction: new

endclass: sequencer

class driver extends uvm_driver #(seq_item);
    `uvm_component_utils(driver)
  
    function new (string name = "driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new
  
    task run_phase (uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        //`uvm_info(get_type_name(), $sformatf("Temp: %0d",req.temp),UVM_LOW)
        #1;
        seq_item_port.item_done();
      end
    endtask: run_phase

  endclass: driver

  class agent extends uvm_agent;
    `uvm_component_utils(agent)
    sequencer sqr;
    driver    drv;
      
    function new (string name = "agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction: new
    
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      sqr = sequencer::type_id::create("sqr", this);
      drv = driver::type_id::create("drv", this);
    endfunction: build_phase
  
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction: connect_phase

  endclass: agent

  
class base_seq extends uvm_sequence#(seq_item);
    `uvm_object_utils(base_seq)
    seq_item req;
    function new(string name = "base_seq");
        super.new(name);
    endfunction: new
endclass: base_seq 

class child_seq extends base_seq;
    `uvm_object_utils(child_seq)
    seq_item pkt;
    rand int count = 0;
    static int seq_no = 0;
    //if need add more veriable and sequence
    function new(string name = "child_seq");
        super.new(name);
    endfunction: new
  
    virtual task body();
      //if any operation then write here
      if(seq_no!=-1) begin
        if(seq_no==2) lock();
        else if(seq_no==1) grab();
      	else seq_no++;
      end
      for(int i=0; i<count; i++) begin
        `uvm_do(pkt)
        `uvm_info(get_type_name(), $sformatf("SEQ count: %0d",i), UVM_LOW)
      end
      if(seq_no!=-1) begin
        if(seq_no==2) unlock();
        else if(seq_no==1) ungrab();
      end
    endtask: body
          constraint count_c {soft count inside {[1:2]};}
endclass: child_seq

class concurrent_seq extends base_seq;
    `uvm_object_utils(concurrent_seq)
    child_seq seq1, seq2, seq3;
    //if need add more veriable and sequence
    function new(string name = "concurrent_seq");
        super.new(name);
    endfunction: new
    virtual task body();
        super.body();
        seq1 = child_seq::type_id::create("seq1");
        seq2 = child_seq::type_id::create("seq2");
        seq3 = child_seq::type_id::create("seq3");
        fork 
            begin: thread_1
                //pre-operation write here
                `uvm_do(seq1)
              `uvm_info(get_type_name(), $sformatf("FOR SEQ1"), UVM_LOW)
                //post-operation write here
            end: thread_1
            begin: thread_2
              //grab(m_sequencer);
              //`uvm_info(get_type_name(), "LOCK START", UVM_LOW);
              `uvm_do_with(seq2, {count==3;})
              `uvm_info(get_type_name(), $sformatf("FOR SEQ2"), UVM_LOW)
              //ungrab(m_sequencer);
              //`uvm_info(get_type_name(), "LOCK END", UVM_LOW);
            end: thread_2
            begin: thread_3
              `uvm_do_with(seq3, {count inside {[5:10]};})
              `uvm_info(get_type_name(), $sformatf("FOR SEQ3"), UVM_LOW)  
            end: thread_3
        join
    endtask: body
endclass: concurrent_seq

class test extends uvm_test;
    agent agt;
    `uvm_component_utils(test)
  
    function new (string name = "test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new
  
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      agt = agent::type_id::create("agt", this);
    endfunction : build_phase
  
    task run_phase(uvm_phase phase);
      concurrent_seq c_seq;
      c_seq = concurrent_seq::type_id::create("c_seq");
      phase.raise_objection(this);
      agt.sqr.set_arbitration(UVM_SEQ_ARB_RANDOM);
      c_seq.start(agt.sqr);
      phase.drop_objection(this);
    endtask : run_phase
  endclass : test
  
  module top();
    initial begin
      run_test("test");
    end
  endmodule : top