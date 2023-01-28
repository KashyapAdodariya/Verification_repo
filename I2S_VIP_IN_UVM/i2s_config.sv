

// Revision: 3
//-------------------------------------------------------------------------------


class i2s_config extends uvm_object;
  
  `uvm_object_utils(i2s_config)

  //for monitor and other component connect_phase
  virtual i2s_interface vif;
  
  //set active and passive mode for each config
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  //---for SCK signal---//
  shortreal high_low=((`toggle/2))/2; 
  
  //---word length for master and slave ---//  
  word_length_e word_len=`size;
  word_length_e s_word_len = `size;
 
  //seting veriable for clock
  parameter DUTY = 50.000;		
  shortreal period=high_low*4*word_len;	
  shortreal on_duty_cycle = (period*DUTY)/100;	
  shortreal off_duty_cycle = period - on_duty_cycle;

  //---used in gen class for generate repeat_gen times packet---//
  int repeat_gen=i2s_seq_item::no_item;
  //---variable select tx or rx in master and slave---//
  rand transaction_mode_e mode_sel=TX;
  //---varible for schannel mode---//
  rand channel_mode_e chnl_mode=STEREO;

  //prototype
  extern function new(string name = "i2s_config");
  extern function string con2str();
  extern function void do_print(uvm_printer printer);
 
endclass:i2s_config


	//////////////////////////////////////////////////////// 
	// Method name        : con2str()
  // Parameter Passed   : null
  // Returned parameter : null  
  // Description        : convert data into string
  ////////////////////////////////////////////////////////  
 
  function string i2s_config :: con2str();
      string print_config;
      print_config = $psprintf(
        "\t\t%0s\t\t\n",
        "Transection Mode = %0s\n",this.mode_sel,
        "Duty Cycle       = %0d\n",this.DUTY,
        "Word_len         = %0s\n",this.word_len.name(),
        "Mode_sel         = %0s\n",this.mode_sel.name(),
        "Channel_mode     = %0s\n",this.chnl_mode.name(),
          "=========================================================================================");
  endfunction:con2str

    
  //////////////////////////////////////////////////////// 
	// Method name        : do_print
  // Parameter Passed   : uvm_printer printer
  // Returned parameter : void  
  // Description        : help in printing
  //////////////////////////////////////////////////////// 

  function void i2s_config :: do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_string("Transection Mode", this.mode_sel.name());
    //printer.print_string("Duty Cycle", this.complement.name());
    printer.print_string("Master_Word_len", this.word_len.name());
    printer.print_string("Slave_Word_len", this.s_word_len.name());
    printer.print_string("Channel_mode", this.chnl_mode.name());
  endfunction:do_print
   
  //////////////////////////////////////////////////////// 
	// Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : null  
  // Description        : constrctor
  //////////////////////////////////////////////////////// 
  
  function i2s_config :: new(string name = "i2s_config");
    super.new(name);
    //$display("i2s_config run");
    `uvm_info(get_type_name(),"I2S_CONFIG NEW",UVM_LOW)
  endfunction:new

