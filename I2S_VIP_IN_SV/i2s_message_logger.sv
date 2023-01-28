

//---for max no of error---//
`define max_error 10

//---for vaebosity level---//
parameter LOW=0,
          MID=1,
          HIGH=2;
          
`define verbo_lev LOW

//---macros for each msg_type---//
`define info i2s_msg_logger::info
`define display i2s_msg_logger::display
`define warning i2s_msg_logger::warning
`define error i2s_msg_logger::error
`define fatal i2s_msg_logger::fatal

//---------------------------------Message logger class---------------------------//
class i2s_msg_logger;
  
//---static variable for count error and warning---//  
  static shortint error_count;
  static shortint warning_count;
  
//---static function for info---//  
  static function void info (string msg,bit [1:0]lev);
  if(lev>=`verbo_lev)begin
    $info("%s",msg);
  end
  endfunction
  
//---static function for display---// 
  static function void display (string msg,int arg,bit [1:0]lev);
  if(lev>=`verbo_lev)begin
    $display("time[%0t]\t%s:%0d",$time,msg,arg);
  end
  endfunction
  
//---static function for disply and count warning ---//  
  static function void warning (string msg,bit [1:0]lev);
  if(lev>=`verbo_lev)begin
    $warning("%s",msg);
     warning_count++;
  end
  endfunction
  
//---static function for display and count error ---//  
  static function void error (string msg,bit [1:0]lev);
  if(lev>=`verbo_lev)begin
    $error("%s",msg);
    if(error_count==`max_error)begin
      `info("-----Maximum count of error reaches -----",MID);
      error_display();
      $finish();
    end
    else begin
    error_count++;
    end
  end
  endfunction
  
//---static function for fatal error ---//  
  static function void fatal (string msg,bit [1:0]lev);
  if(lev>=`verbo_lev)begin
    $fatal("%s",msg);
    error_display();
    $finish();  
  end
  endfunction
  
//----for display total no of error and warning---//  
  static function void error_display();
    `display("-----Error Reporting-----",error_count,MID);
    `display("----Warning Reporting----",warning_count,MID);
  endfunction

endclass


