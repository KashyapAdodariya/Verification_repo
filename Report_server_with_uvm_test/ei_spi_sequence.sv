class BASE_SEQ extends uvm_sequence#(ei_spi_sequence_item_c);
  `uvm_object_utils(BASE_SEQ)
  static int total_pkt_generated;
  function new(string name = "BASE_SEQ");
    super.new(name);
  endfunction
  task body();
    $display("Inside Base sequence");
  endtask
endclass

//=========================================================================
// Sanity Test - "write" followed by "read" (sequence's inside sequences)
//=========================================================================
class ei_spi_sanity_test extends BASE_SEQ;
bit [1:0]i = 1;
  `uvm_object_utils(ei_spi_sanity_test)

  parameter number_of_slave = `NO_OF_SLAVE;
  bit [(`ADDR_WIDTH*8)-1:0] random_addr;					//variable to generate random address 
  byte repeat_operation;
  byte total_pkt_generated;
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "ei_spi_sanity_test");
    super.new(name);
  endfunction

  task pre_body();
    // raise objection if started as a root sequence
    if(starting_phase != null)
      starting_phase.raise_objection(this);
  endtask
  //--------------------------------------- 
  //Body taks
  //---------------------------------------

  virtual task body();
    grab(m_sequencer);
    //`uvm_info(get_type_name(),"======================== Sequence Running =============================================",UVM_LOW);
    `uvm_info(get_type_name(),$sformatf("=====================  SEQ_1.%0d : Started =======================================",i),UVM_LOW);
   // `uvm_info(get_type_name(),"===================== SEQ_1 : Started =======================================",UVM_LOW);
    //repeat_operation = $urandom_range(7,15);
    repeat_operation = 1;
    repeat(repeat_operation)
      begin
        random_addr = $random;
                repeat(1) 
                  begin
                    //write operation
                    `uvm_do_with(req,{req.instruction[6:4] == 3'b001; req.instruction[7] == 1'b1; req.address == random_addr;})
                  end
                total_pkt_generated++;
        repeat(1)
          begin
            //read operation
            `uvm_do_with(req,{req.instruction[6:4] == 3'b001; req.instruction[7] == 1'b0; req.address == random_addr;})
          end
        total_pkt_generated++;
      end
   // `uvm_info(get_type_name(),"===================== SEQ_1 : ENDED =======================================",UVM_LOW);
    `uvm_info(get_type_name(),$sformatf("===================== SEQ_1.%0d : ENDED =======================================",i),UVM_LOW);
    i++;
    ungrab(m_sequencer);
  endtask
  task post_body();
    // drop objection if started as a root sequence
    if(starting_phase != null)
      starting_phase.drop_objection(this);
  endtask

endclass


class ei_spi_wr_dly_rd_test extends BASE_SEQ;
bit [1:0]i = 1;

  `uvm_object_utils(ei_spi_wr_dly_rd_test)

  parameter number_of_slave = `NO_OF_SLAVE;
  bit [(`ADDR_WIDTH*8)-1:0] random_addr;					//variable to generate random address 
  static int repeat_operation;
  int DELAY_BETW_2_TRX = 100;								//delay between transaction in ns
  byte total_pkt_generated;



  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "ei_spi_sanity_test");
    super.new(name);
  endfunction

  //--------------------------------------- 
  //Body taks
  //---------------------------------------
  virtual task body();
   // grab(m_sequencer);
    //`uvm_info(get_type_name(),"======================== Sequence Running=============================================",UVM_LOW);
    `uvm_info(get_type_name(),$sformatf("=====================  SEQ_3.%0d : Started =======================================",i),UVM_LOW);
    
    repeat_operation =  1; //$urandom_range(3,5);
    repeat(repeat_operation)
      begin
        random_addr = $random;
        repeat(5) 
          begin
            `uvm_do_with(req,{req.instruction[6:4] == 3'b010; req.instruction[7] == 1'b1; req.address == 5;})
          end
        //         total_pkt_generated++;
        //         #DELAY_BETW_2_TRX;

                repeat(5)
                  begin
                    `uvm_do_with(req,{req.instruction[6:4] == 3'b010; req.instruction[7] == 1'b0; req.address == 5;})
                  end
//                 total_pkt_generated++;
//                 #DELAY_BETW_2_TRX;									//Delay between 2 transaction

      end
    
   // `uvm_info(get_type_name(),"===================== SEQ_3 :  ENDED =======================================",UVM_LOW);
    `uvm_info(get_type_name(),$sformatf("===================== SEQ_3.%0d : ENDED =======================================",i),UVM_LOW);
   // ungrab(m_sequencer);
    i++;
    
    //`uvm_info(get_type_name(), $sformatf("Total packet generated = %0d",total_pkt_generated),UVM_LOW)
  endtask
endclass
// =========================================================================





//=========================================================================
// 10 back to back write - 10 b2b read (sequence's inside sequences)
//=========================================================================
class ei_spi_10_b2b_wr_10_b2b_rd_test extends BASE_SEQ;
  bit [1:0]i = 1;
  `uvm_object_utils(ei_spi_10_b2b_wr_10_b2b_rd_test)

  bit [(`ADDR_WIDTH*8)-1:0] random_addr;					//variable to generate random address 
  bit [(`ADDR_WIDTH*8)-1:0] addr_rd;						//variable to get address form queue
  int addr_queue[$];										//declare queue to store address

  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "ei_spi_10_b2b_wr_10_b2b_rd_test");
    super.new(name);
  endfunction

  //--------------------------------------- 
  //Body taks
  //-------------------------------------
  virtual task body();
    grab(m_sequencer);
   // `uvm_info(get_type_name(),"======================== Sequence Running=============================================",UVM_LOW);
    `uvm_info(get_type_name(),$sformatf("=====================  SEQ_2.%0d : Started =======================================",i),UVM_LOW);
    repeat(10) 
      begin
        random_addr = $random;								//generate random address
        addr_queue.push_front(random_addr);					//push address into address queue
        `uvm_do_with(req,{req.instruction[6:4] == 3'b010; req.instruction[7] == 1'b1; req.address == random_addr;})
      end
    repeat(10)
      begin
        addr_rd = addr_queue.pop_back();					//pop address from address queue
        `uvm_do_with(req,{req.instruction[6:4] == 3'b010;req.instruction[7] == 1'b0; req.address == addr_rd;})
      end
     //`uvm_info(get_type_name(),$sformatf("From Scoreboard packet received from Slave driver(port b):-\n %s", pkt.sprint()),UVM_MEDIUM)
    `uvm_info(get_type_name(),$sformatf("===================== SEQ_2.%0d : ENDED =======================================",i),UVM_LOW);
    ungrab(m_sequencer);
    i++;
  endtask
endclass : ei_spi_10_b2b_wr_10_b2b_rd_test
// =========================================================================

