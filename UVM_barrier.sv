
//used Processes get released Once after all the process reaching synchronization point
//uvm_barrier allows a set of processes to be blocked until the desired number of processes get to the

`include "uvm_macros.svh"
import uvm_pkg::*;

module uvm_barrier_ex;
  uvm_barrier ba;
  
  initial begin
    ba = new("ba",2);
   
    //or
    
    //ba = new("ba");
    //ba.set_threshold(3);
    
     
    task reset_process();
      #32;
      ba.reset(1);
    endtask
    
    //or
    
    //ba.set_threshold(3);
    //ba.set_auto_reset(0);
    
    task cancel_process();
    #20;
    	$display($time," Number of process waiting before cancel
                     is %0d",ba.get_num_waiters());
    	ba.cancel();
    	$display($time," Number of process waiting after cancel
                     is %0d",ba.get_num_waiters());
    endtask
    
    fork
      begin       //process-1
        $display($time," Inside the process-a");
        #5;
        $display($time," process-a completed");
        $display($time," process-a Waiting for barrier");
        ba.wait_for();
        $display($time," process-a after wait_for");        
      end
      
      begin       //process-2
        $display($time," Inside the process-b");
        #6;
        $display($time," process-b completed");
        $display($time," process-b Waiting for barrier");        
        ba.wait_for();
        $display($time," process-b after wait_for");
      end
      
      begin       //process-3
        $display($time," Inside the process-c");
        #7;
        $display($time," process-c completed");
        $display($time," process-c Waiting for barrier");       
        ba.wait_for();
        $display($time," process-c after wait_for");
      end
      
      begin       //process-4
        $display($time," Inside the process-d");
        #8;
        $display($time," process-d completed");
        $display($time," process-d Waiting for barrier");       
        ba.wait_for();
        $display($time," process-d after wait_for");
      end
      begin
        reset_process();
      end
      begin
        cancel_process();
      end
    join
  end
endmodule