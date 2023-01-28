class my_report_server extends uvm_default_report_server;
  
//   function new();
//     super.new();
//     $display("\n\ncheck new for my_report_server\n\n");
//   endfunction: new
  
 //uvm_report_message a;
   virtual function string compose_report_message( uvm_report_message report_message,
                                                   string report_object_name = "" );
     
     uvm_severity severity = report_message.get_severity();
       string       name     = report_message.get_report_object().get_full_name();
      

//       return $sformatf( "%-8s | %16s | %2d | %0t | %-21s | %-7s | %s",
//                         severity.name(), filename, line, $time, name, id, message );
     
//      return $sformatf( "%-8s ",
//                         severity.name() );
     
     if((severity.name() == "UVM_ERROR") || (severity.name() == "UVM_INFO"))begin
       string       id       = report_message.get_id();
       string       message  = report_message.get_message();
       string       filename = report_message.get_filename();
       int          line     = report_message.get_line();
       return $sformatf( "%-8s | %16s | %2d | %0t | %-21s | %-7s | %s",
                        severity.name(), filename, line, $time, name, id, message );
     end
     else
       return super.compose_report_message(report_message,report_object_name);
    endfunction: compose_report_message
  
endclass: my_report_server