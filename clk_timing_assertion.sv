module M;
  bit clk; 
  realtime t1, clk_period=4.0;
  initial forever #2 clk=!clk; 

  property p2;
   realtime current_time;
   @(posedge clk)
    ('1,current_time=$realtime) |=> (clk_period==$realtime-current_time);
  endproperty
 
    function automatic bit check_period(realtime now_time); 
      if ($realtime-now_time != clk_period) begin 
        t1=$realtime-now_time;  
        return 0;
      end 
      else return 1'b1;   
    endfunction : check_period
    
   property p3;
     realtime current_time;
     bit pass;
     @(posedge clk)
     ('1,current_time=$realtime,$display($time,"\tc_time: %0d",current_time)) |=> (1, pass=check_period(current_time),$display($time,"\tpass: %0d",pass));
  endproperty
  
  property p4;
     realtime current_time;
     bit pass;
     @(posedge clk)
     ('1,current_time=$realtime,$display($time,"c_time: %0d",current_time)) |=> (1, pass=check_period(current_time),$display($time,"\tpass: %0d",pass));
  endproperty
  
    
  ap3: assert property(p3) else $display("ERRORRRRRR");  
      
      initial begin
        #100ns;
        $finish();
      end
 endmodule 
    
   /*



module assertion_ex_1;
  int delay_2,delay_1;

  bit clk,start_event,end_event;
  bit test_expr;
  
  property check_wdata();
    int expexcted_value = 7;
    realtime one_t,neg_t;

    // @(posedge clk) (($rose(clk), one_t = $realtime), $display(" one_t = %d",one_t)) |-> ($fell(clk), neg_t = $realtime) ##0 ((neg_t-one_t==expexcted_value), $display("neg_t = %d expexcted_value = %d",neg_t,expexcted_value));
    // @(specified edge clk) (count = 0,1_t = $realtime) ##1 (count = n)[->1] |-> $realtime - 1_t == expected_val

    @(posedge clk) ((1,one_t=$realtime),$display("one_t=%d",one_t)) |-> ($fell(clk), neg_t=$realtime) ##0 ((neg_t-one_t==expexcted_value), $display("neg_t = %d expexcted_value = %d",neg_t,expexcted_value));
    

  endproperty 
  prop1 : assert property (check_wdata()); //else $fatal("Fail arration");


    //     initial 
    //       forever #5 clk =~ clk;

    always #5 clk = ~clk;

    initial 
      begin 

        clk = 0;

        test_expr = 0;
        start_event = 0;
        end_event = 0;

        //         fork

        //           begin
        // //             repeat (24) begin
        // //               delay_1 = $urandom_range (1,4);
        // //               // delay1 = $urandom_range (1,3);
        // //               #delay_1;
        // //              // expected_val  = 5;
        // //             end
        //           end

        // //           begin
        // //             repeat (24) begin
        // //               delay_2 = $urandom_range (1,15);
        // //               // delay1 = $urandom_range (1,3);
        // //               #delay_2;

        // //               #7;
        // //               start_event = ~start_event;
        // //               #20;
        // //               test_expr = ~test_expr;
        // //             end
        // //           end

        //         join 
        #50;

        $finish();
      end


    initial begin
      $dumpfile("dump.vcd");
      $dumpvars(1);
    end

    endmodule
    
    */