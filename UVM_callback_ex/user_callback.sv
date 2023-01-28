//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------

//------------------------------------------------
//	Class - user_callback_1
//------------------------------------------------

class user_callback_1 extends driver_callback;
  
  `uvm_object_utils(user_callback_1)
  
  function new(string name = "user_callback_1");
    super.new(name);
  endfunction
  
  task pre_drive;
    `uvm_info("USER_CALLBACK-1","Inside pre_drive method",UVM_LOW);
  endtask
  
  task post_drive;
    `uvm_info("USER_CALLBACK-1","Inside post_drive method",UVM_LOW);
  endtask
endclass

//------------------------------------------------
//	Class - user_callback_2
//------------------------------------------------

class user_callback_2 extends driver_callback;
  
  `uvm_object_utils(user_callback_2)
  
  function new(string name = "user_callback_2");
    super.new(name);
  endfunction
  
  task pre_drive;
    `uvm_info("USER_CALLBACK-2","Inside pre_drive method",UVM_LOW);
  endtask
  
  task post_drive;
    `uvm_info("USER_CALLBACK-2","Inside post_drive method",UVM_LOW);
  endtask
endclass