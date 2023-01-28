

class i2s_transaction #(parameter word_size = `size);
//---config handle---//  
  i2s_config cfg;
//---right and left data---//  
  rand  bit [(2*word_size)-1:0] data;
  
////////////////////////////---New constructor---///////////////////////////////////
  function new(i2s_config master_cfg);
    cfg=master_cfg;
  endfunction:new

//////////////////////////////---Methods---////////////////////////////////////////
  extern function void print(string str = "Transaction Class");
  extern function void post_randomize();
  extern function i2s_transaction copy(i2s_transaction tr,i2s_config cfg);
 // extern function bit compare(i2s_transaction tr);
  
endclass:i2s_transaction

////////////////////////////////////////////////////////////////////////////////////
// Method name        : print()
// Parameter Passed   : String str = "Transaction Class"bydefault value 
// Returned parameter : None
// Assumption         : first half ([word_size-1:word_size/2])bits for left and
//                      ([word_size/2:0])bits for right channel
// Description        : Display property of i2s_transaction Class
////////////////////////////////////////////////////////////////////////////////////

  function void i2s_transaction::print(string str = "Transaction Class");
    string print_trans;
    print_trans=$psprintf(
     "\t\t%0s\t\t\n",str,
     "data   =%h\n",this.data,
     "===========================================================================================");
    `info(print_trans,LOW);
  endfunction:print
  

        
//////////////////////////////////////////////////////////////////////////////////////
// Method name        : post_randomize()
// Parameter Passed   : None 
// Returned parameter : None
// Description        : Based on data transfer mode post process on data
//////////////////////////////////////////////////////////////////////////////////////
  
  function void i2s_transaction::post_randomize();
//---for NORMAL---//    
    if(cfg.complement==NORMAL)begin:normal
      `info("------Normal Data Transfer------",LOW);
    end:normal
//---for ONES_COMPL---//    
    else if(cfg.complement==ONES_COMPL)begin:ones
      `info("------ONES Complement Data Transfer-------",LOW);
       data=~data;
    end:ones
//---for TWOS_COMPL---//    
    else begin:twos
      `info("------TWOS Complement Data Transfer-------",LOW);
       data=~data+1;
    end:twos      
  endfunction:post_randomize
  
  

/////////////////////////////////////////////////////////////////////////////////////
// Method name        : copy()
// Parameter Passed   : class handle
// Returned parameter : i2s_transaction class handle
// Description        : for copying property of i2s_transaction Class
/////////////////////////////////////////////////////////////////////////////////////
  
  function i2s_transaction i2s_transaction::copy(i2s_transaction tr,i2s_config cfg);
    if(tr==null)begin
      `warning("----Try copy into Null packet----",MID);
      tr=new(cfg);
    end
    tr.data=this.data;
    return tr;
  endfunction:copy
  /*
  //////////////////////////////////////////////////////////////////////////////////////
// Method name        : compare()
// Parameter Passed   : i2s_transaction class handle 
// Returned parameter : bit datatype variable
// Description        : for compare property of two i2s_transaction Class handle
//////////////////////////////////////////////////////////////////////////////////////
  
  function bit i2s_transaction::compare(i2s_transaction tr);
    bit comp_res=1;
//---for null object---//    
    if(tr==null)begin
      `warning("-----Null packet try to compare with class packet-----",MID);
      comp_res=0;
    end
    
    else begin
      if(cfg.chnl_mode==MONO_LEFT && cfg.chnl_mode==STEREO)begin
        if(tr.data[(2*word_size)-1:word_size] != this.data[(2*word_size)-1:word_size])begin
          `info("-----left_data channel data is not match-----",LOW);
        comp_res=0;
        end
      end
      
      if(cfg.chnl_mode==MONO_RIGHT && cfg.chnl_mode==STEREO)begin
        if(tr.data[word_size-1:0] != this.data[word_size-1:0])begin
          `info("------right_data channel data is not match-------",LOW);
         comp_res=0;
        end
      end
    end
    
    return comp_res;
  endfunction:compare
  */
        
