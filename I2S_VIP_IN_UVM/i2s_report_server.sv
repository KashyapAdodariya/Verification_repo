class i2s_report_server extends uvm_report_server;
  `uvm_object_utils(i2s_report_server)

  function new(string name="i2s_report_server");
     super.new();
     `uvm_info(get_type_name(),"I2S_MY_REPORT_SERVER NEW",UVM_LOW)
   endfunction : new
  
   virtual function string compose_message( uvm_severity severity,
                                           string name,
                                           string id,
                                           string message,
                                           string filename,
                                           int line );
     
     //`uvm_info(get_type_name(),$sformatf("From: \n %0s",super.compose_message(severity,name,id,message,filename,line)),UVM_LOW)
     //uvm_severity_type severity_type = uvm_severity_type'( severity );
      //return $psprintf( "%-8s | %16s | %2d | %0t | %-21s | %-7s | %s",
      //       severity_type.name(), filename, line, $time, name, id, message );
   endfunction 
  
endclass