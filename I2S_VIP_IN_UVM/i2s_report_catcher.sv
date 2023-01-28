class i2s_report_catcher extends uvm_report_catcher;
  `uvm_object_utils(i2s_report_catcher)
  int error_count=0;
  int fail_count = 0;
  int pass_count = 0;
  
  function new(string name = "i2s_report_catcher");
    super.new(name);
  endfunction:new	
  
  function action_e catch();
    if(get_severity()==UVM_ERROR && get_message() == "error injection generated massage") begin
      set_severity(UVM_INFO);
      error_count++;
    end
    if(get_message() == "\tTESTCASE FAIL\t" && get_severity()==UVM_INFO) begin
      set_severity(UVM_ERROR);
      fail_count++;
    end
    if(get_message() == "\tTESTCASE PASS\t" && get_severity()==UVM_INFO) begin
      set_severity(UVM_ERROR);
      pass_count++;
    end
    return THROW;
  endfunction:catch
  
endclass:i2s_report_catcher