// Code your testbench here
// or browse Examples
`include "uvm_macros.svh"
module top();
  
  // User report server
   class my_report_server extends uvm_report_server;
      `uvm_object_utils(my_report_server)

     function new(string name="my_report_server");
       super.new();
       $display( "Constructing report serevr %0s",name);
     endfunction : new

  // Return type is string    
   virtual function string compose_message( uvm_severity severity,string name,string id,string message,string filename,int line );

    // DEBUG MESSAGE
    //$display("New Format: \n %0s",super.compose_message(severity,name,id,message,filename,line));
     $display("NEW FORMAT:\t %0s %0s %0s %0s",severity, name, id, message);
     //This display comes.
     //$display("This is from uvm_report_sever extended class");
   endfunction 
   endclass

   class test extends uvm_test;
     // ... Some stuff here...
     // Declare handle here.
     `uvm_component_utils(test);
     
     my_report_server srv_h;
     int i;
     
     function new(string name,uvm_component parent);
       super.new(name,parent);
       endfunction

     function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      srv_h = new();
      uvm_report_server::set_server(srv_h);
     endfunction
     
     task run_phase(uvm_phase phase);
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
     endtask

   endclass
     
    initial
      begin
        run_test("test");
      end
     
endmodule