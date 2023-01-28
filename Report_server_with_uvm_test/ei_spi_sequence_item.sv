class ei_spi_sequence_item_c extends uvm_sequence_item;

  rand bit 	[`ADDR_WIDTH*8-1:0] address;
  rand bit 	[7:0] 			    instruction;
  rand logic[`DATA_WIDTH*8-1:0] data [$];

  `uvm_object_utils_begin(ei_spi_sequence_item_c)
  `uvm_field_int(address, UVM_ALL_ON)
  `uvm_field_int(instruction, UVM_ALL_ON)
  `uvm_field_queue_int(data,UVM_ALL_ON)
  `uvm_object_utils_end

  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "mem_seq_item");
    super.new(name);
  endfunction

  
  //---------------------------------------
  //Constraint
  //---------------------------------------
  constraint data_length { instruction[6:4] inside {[1:4]};}			// data length should be 1,2,3 or 4 bytes

  constraint data_size { soft data.size == instruction[6:4];}

  constraint reserve_bit {instruction[3:0] == 0;};

  constraint r_dis_data {(instruction[7] == 0) -> data.size == 0;}		// if read bit is generated then there would be no data


endclass 