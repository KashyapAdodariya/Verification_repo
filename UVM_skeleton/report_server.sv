class report_server_h extends uvm_report_server;
  `uvm_object_utils(report_server_h)

  function new(string name="report_server_h");
    super.new(name);
    `uvm_info(get_type_name(),"report_server new call",UVM_LOW)
   endfunction : new
  
   virtual function string compose_message( uvm_severity severity,
                                           string name,
                                           string id,
                                           string message,
                                           string filename,
                                           int line );
     
//      `uvm_info(get_type_name(),$sformatf("From: \n %0s",super.compose_message(severity,name,id,message,filename,line)),UVM_LOW)
//      uvm_severity_type severity_type = uvm_severity_type'( severity );
//       return $psprintf( "%-8s | %16s | %2d | %0t | %-21s | %-7s | %s",
//             severity_type.name(), filename, line, $time, name, id, message );
     $display("NEW FORMAT:\t %0s %0s %0s %0s",severity, name, id, message);
   endfunction 
  
endclass