



//-------------------------Enum declaration--------------------------//

//---for select transaction mode---//
typedef enum {TX,RX,CONTROLLER} transaction_mode_e;
//---for select word length---//
typedef enum {WLEN8=8,WLEN16=16,WLEN18=18,WLEN20=20,WLEN24=24} word_length_e;
//---for select channle mode---//
typedef enum {MONO_RIGHT,MONO_LEFT,STEREO} channel_mode_e;
//---for select data transfer---//
typedef enum {NORMAL,ONES_COMPL,TWOS_COMPL} comp_e;

  	
//-----------------------------Config class-------------------------//
class i2s_config #(parameter word_size = `size);
  
//---for SCK signal---//
  shortreal high_low=((`toggle/2))/2; 
  
//---word length for master and slave ---//  
  word_length_e word_len=`size;
 
  parameter DUTY = 50.000;		
  shortreal period=high_low*4*word_len;	
  shortreal on_duty_cycle = (period*DUTY)/100;	
  shortreal off_duty_cycle = period - on_duty_cycle;

  
//---used in gen class for generate repeat_gen times packet---//
  rand int repeat_gen=3;
 
//---variable select tx or rx in master and slave---//
  rand transaction_mode_e mode_sel=TX;
  
//---varible for schannel mode---//
  rand channel_mode_e chnl_mode=STEREO;
  
  
//---for  data transfer----//
  rand comp_e complement=NORMAL; 
  
//----constraint------//  
  constraint repeat_gen_c{
    repeat_gen inside {[1:10]};
  }
  
  extern function void print(string str = "MASTER_CONFIG");
 // extern function i2s_config copy(i2s_config obj);
endclass:i2s_config
    

////////////////////////////////////////////////////////////////////////////////////
// Method name        : print()
// Parameter Passed   : String
// Returned parameter : None
// Description        : Display property of config class 
////////////////////////////////////////////////////////////////////////////////////
    
  function void i2s_config :: print(string str = "MASTER_CONFIG");
  string print_config;
  print_config = $psprintf(
    "\t\t%0s\t\t\n",str,
    "Duty Cycle     = %0d\n",this.DUTY,
    "repeat_gen     = %0d\n",this.repeat_gen,
    "word_len       = %0s\n",this.word_len.name(),
    "mode_sel       = %0s\n",this.mode_sel.name(),
    "channel_mode   = %0s\n",this.chnl_mode.name(),
    "complement     = %0s\n",this.complement.name(),
    "=========================================================================================");
  `info(print_config,LOW);
  endfunction:print

    /*
    
////////////////////////////////////////////////////////////////////////////////////
// Method name        : copy()
// Parameter Passed   : i2s_config class handle
// Returned parameter : i2s_config class handle
// Description        : copying property of class
////////////////////////////////////////////////////////////////////////////////////    
    

function i2s_config i2s_config::copy(i2s_config obj);
//---for null object---//  
  if(obj == null) begin
    `warning("-----i2s_config class copy into NULL object-----",MID);
    obj = new();
  end
  obj.repeat_gen = this.repeat_gen;     
  obj.word_len   = this.word_len;     
  obj.mode_sel   = this.mode_sel;      
  obj.chnl_mode  = this.chnl_mode;        
  obj.complement = this.complement; 
  return obj;
endfunction:copy
*/


 