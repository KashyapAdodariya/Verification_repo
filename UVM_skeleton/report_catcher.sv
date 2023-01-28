class report_catcher_h extends uvm_report_catcher;
  `uvm_object_utils(report_catcher_h)
  
  int error_injection_count = 0;
  int fail_count = 0;
  int pass_count = 0;
  
  function new(string name = "report_catcher_h");
    super.new(name);
    `uvm_info(get_type_name(),"report_catcher new call",UVM_LOW)
  endfunction
  
  function action_e catch();
    if((get_severity()==UVM_ERROR) & (get_id() == "ERROR INJECTION MSG")) begin
      set_severity(UVM_INFO);
      set_id("MSG_DEMOTED");
      set_message("ERROR INJECTION MSG DEMOTED WITH UVM_INFO");
      error_injection_count++;
    end
    if(get_message() == "\n\tTESTCASE FAIL\t\n" && get_severity()==UVM_INFO) begin
      set_severity(UVM_INFO);
      fail_count++;
    end
    if(get_message() == "\n\tTESTCASE PASS\t\n" && get_severity()==UVM_INFO) begin
      set_severity(UVM_INFO);
      pass_count++;
    end
    return THROW;
  endfunction: catch
  
endclass