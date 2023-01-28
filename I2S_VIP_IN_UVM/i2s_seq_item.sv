

// Revision: 3
//-------------------------------------------------------------------------------

//---for select data transfer---//
typedef enum {NORMAL,ONES_COMPL,TWOS_COMPL} comp_e;

class i2s_seq_item #(parameter word_size = `size) extends uvm_sequence_item;
  
  rand bit [(2*word_size)-1:0] data;
  rand comp_e complement;
  static int trans_count = 0;
  static int seq_repeat = 0;
  static int no_item=8;
  
  `uvm_object_utils(i2s_seq_item)
  //Utility and Field macros

  extern function new(string name = "i2s_sequence_item");
  extern function void do_print(uvm_printer printer);
  extern function void post_randomize();
    
  /*`uvm_object_utils_begin(i2s_seq_item)
    `uvm_field_int(data,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(trans_count,UVM_DEFAULT | NO_COMPARE)
    `uvm_field_int(seq_repeat,UVM_DEFAULT | NO_COMPARE)
  `uvm_object_utils_end*/
    
    constraint data_c {data%2 == 0;}
    //constraint data_c1 {data inside {[0:100]};}

endclass:i2s_seq_item

  //////////////////////////////////////////////////////// 
  // Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : void  
  // Description        : constrctor
  ////////////////////////////////////////////////////////
  
  function i2s_seq_item :: new(string name = "i2s_sequence_item");
    super.new(name);
  endfunction:new

  //////////////////////////////////////////////////////// 
  // Method name        : do_print
  // Parameter Passed   : uvm_printer printer
  // Returned parameter : void
  // Description        : print
  ////////////////////////////////////////////////////////  
  
  function void i2s_seq_item :: do_print(uvm_printer printer);
    printer.print_field("DATA", this.data,word_size,UVM_HEX);
    printer.print_string("Complement Type", this.complement.name());
    printer.print_field_int("Transection_Count: ", trans_count,$size(trans_count),UVM_DEC);
    printer.print_field_int("seq_Count: ", seq_repeat,$size(seq_repeat),UVM_DEC);

  endfunction:do_print


  /////////////////////////////////////////////////////////////////////////
  // Method name        : post_randomize()
  // Parameter Passed   : None 
  // Returned parameter : None
  // Description        : Based on data transfer mode post process on data
  /////////////////////////////////////////////////////////////////////////

  function void i2s_seq_item :: post_randomize();
    //---for NORMAL---//    
    if(complement==NORMAL)begin:normal
      `uvm_info("post_rand","------Normal Data Transfer------",UVM_LOW);
    end:normal
    //---for ONES_COMPL---//    
    else if(complement==ONES_COMPL)begin:ones
      `uvm_info("post_rand","------ONES Complement Data Transfer-------",UVM_LOW);
       data=~data;
    end:ones
    //---for TWOS_COMPL---//    
    else begin:twos
      `uvm_info("post_rand","------TWOS Complement Data Transfer-------",UVM_LOW);
       data=~data+1;
    end:twos      
  endfunction:post_randomize
    
