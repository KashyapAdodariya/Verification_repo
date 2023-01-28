/*class my_report_server extends uvm_report_server;
  `uvm_object_utils(my_report_server)
  
  function new(string name="my_report_server");
    super.new(name);
    $display( "Customize report serevr %0s",name);
  endfunction : new

  // Return type is string    
   function string compose_message( uvm_severity severity,
                                           string name,
                                           string id,
                                           string message,
                                           string filename,
                                           int line );
     
    //$display("New Format: \n %0s",super.compose_message(severity,name,id,message,filename,line));
     
     //Avoid filename and line number
      $display("NEW FORMAT:\t %0s %0s %0s %0s",severity, name, id, message);     
     //This display comes after every message.
     //$display("This is from uvm_report_sever extended class");
   endfunction 
  
endclass: my_report_server*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class demoter extends uvm_report_catcher;
  
  function new(string name = "demoter");
    super.new(name);
  endfunction
    
  function action_e catch();
    //demote error to fatal
    if((get_severity == UVM_FATAL) & (get_id == "Message_id_2"))
      begin
        set_severity(UVM_ERROR);
        set_id("Message_id_2 DEMOTER");
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module test_reporting; 
  initial begin
    run_test("test_1");
  end
endmodule: test_reporting

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class print_reporting extends uvm_component;
  `uvm_component_utils(print_reporting)
  
  function new(string name = "print_reporting", uvm_component parent);
    super.new(name, parent);
  endfunction: new
  
  function void print();
    `uvm_info("Message_id_1", "message_1 (uvm_low)", UVM_LOW)
    `uvm_info("Message_id_1", "message_2 (uvm_high)", UVM_HIGH)
    `uvm_info("Message_id_2", "message_3 (uvm_full)", UVM_FULL)
    `uvm_info("Message_id_2", "message_4 (uvm_debug)", UVM_DEBUG)
    `uvm_info("Message_id_0", "message_0 (uvm_none)", UVM_NONE)
    `uvm_warning("Message_id_1", "WARNING_message_1")
    `uvm_warning("Message_id_2", "WARNING_message_2")
    `uvm_error("Message_id_1", "ERROR_message_1")
    `uvm_error("Message_id_2", "ERROR_message_2")
    `uvm_fatal("Message_id_1", "FATAL_message_1")
    `uvm_fatal("Message_id_2", "FATAL_message_2")
  endfunction: print
  
endclass: print_reporting

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class test_1 extends uvm_test;
  `uvm_component_utils(test_1)
  
  int base_log;  
  int error_log; 
  int id_log;
  int error_id_log;
  //my_report_server rp_sv;
  demoter dmt;
  print_reporting pr;
  
  function new(string name="test_1", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //rp_sv = new("my_report_server");
    dmt = new();
    uvm_report_cb::add(null,dmt);
    //uvm_report_server::set_server(rp_sv);
    pr = print_reporting::type_id::create("pr", this);
  endfunction: build_phase
  
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    //file open
    base_log = $fopen("base_log", "w");
    error_log = $fopen("error_log", "w");
    id_log = $fopen("id_log", "w");
    error_id_log = $fopen("error_id_log", "w");
    
    //check file hendler assertion
    assert(base_log);
    assert(error_log);
    assert(id_log);
    assert(error_id_log);
    
    `ifdef CMD_OFF_VLEVEL
      pr.set_report_verbosity_level(UVM_HIGH);
    `elsif CMD_OFF_IDVLEVEL
      pr.set_report_id_verbosity("Message_id_1", UVM_LOW);
    `elsif CMD_OFF_SIDVLEVEL
      pr.set_report_severity_id_verbosity(UVM_INFO, "Message_id_2", UVM_FULL);
    `endif
    
    //with path
    pr.set_report_severity_action(UVM_INFO, UVM_DISPLAY | UVM_LOG);
    pr.set_report_severity_action(UVM_WARNING, UVM_DISPLAY | UVM_LOG);
    pr.set_report_severity_action(UVM_ERROR, UVM_DISPLAY | UVM_LOG);
    pr.set_report_severity_action(UVM_FATAL, UVM_DISPLAY | UVM_LOG);
    
    pr.set_report_default_file(base_log);
    pr.set_report_severity_file(UVM_ERROR, error_log);
    pr.set_report_id_file("Message_id_1", id_log);
    pr.set_report_severity_id_file( UVM_ERROR, "Message_id_1", error_id_log );
    
  endfunction: start_of_simulation_phase
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    pr.print();
  endtask:run_phase
  
  function void final_phase( uvm_phase phase );
    $fclose(base_log);
    $fclose(error_log);
    $fclose(id_log);
    $fclose(error_id_log);
  endfunction: final_phase
  
endclass: test_1

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
