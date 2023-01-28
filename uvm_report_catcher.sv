// Code your testbench here
// or browse Examples
class demoter extends uvm_report_catcher;
  
  function new(string name = "demoter");
    super.new(name);
  endfunction
  
  /*function action_e catch();
    //demote error to warning
    if((get_severity == UVM_ERROR) & (get_id == "DRV_ERROR"))
      begin
        set_severity(UVM_WARNING);
        set_id("DRV_ERROR_DEMOTED");
        set_message("Configuration error demoted::");
      end
    // to supress all INFO messages
    if(get_severity == UVM_INFO)
      begin
        set_action(UVM_NO_ACTION);
      end
    return THROW;
  endfunction*/
  
  function action_e catch();
    //demote error to warning
    if((get_severity == UVM_FATAL) & (get_id == "DRIVER"))
      begin
        set_severity(UVM_ERROR);
        set_id("DRV_DEMOTED");
        set_message("Configuration FATAL demoted to ERROR::");
      end
   //To avoid all info and warnings messages 
    if(get_severity == UVM_INFO & (get_severity == UVM_WARNING))
      begin
        set_action(UVM_NO_ACTION);
      end
    return THROW;
  endfunction
  
endclass

class driver extends uvm_driver;
  int data=43;
  int addr=32;
  //demoter dem=new;
  
  `uvm_component_utils_begin(driver)
  `uvm_field_int(data,UVM_ALL_ON)
  `uvm_field_int(addr,UVM_ALL_ON)
  `uvm_component_utils_end
  
  function new(string name = "", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build();
    super.build();
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    uvm_report_warning("WARNING", " a warning");
    uvm_report_info("DRV"," id1 (uvm_none)", UVM_NONE);
    uvm_report_info("DRV"," id2 (uvm_low)", UVM_LOW);
    uvm_report_info("DRV"," id3 (uvm_medium)", UVM_MEDIUM);
    uvm_report_info("DRV"," id6 (uvm_low)", UVM_LOW);
    uvm_report_error("ERROR", " error message 1"); 
    uvm_report_error("ERROR", " error message 2");
    uvm_report_error("ERROR", " error message 3");
    uvm_report_fatal("DRIVER", " FATAL message 1");
    uvm_report_fatal("FATAL", " FATAL message 2");
  endtask
  
endclass

module top;
  demoter dem;
  driver dri;
  initial begin
    dem=new();
    dri=new("dri",null);
    uvm_report_cb::add(null,dem);
    run_test();
  end
endmodule