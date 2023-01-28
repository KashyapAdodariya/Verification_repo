	  //fork..join using fork...join_none

module test;
  initial begin
    fork
      begin
        #5;
        $display($time,"\ttest_display_1");
      end
      begin
        #6;
        $display($time,"\ttest_display_2");
      end
      begin
        #7;
        $display($time,"\ttest_display_3");
      end
    join_none
    wait fork;
      $display($time, "\ttest_display_4");
  end
endmodule: test

      //fork...join_any using fork...join_none
      
module top;
   event any;
   initial begin
      fork
        begin #10 $display($time, "\ttop_display_1"); ->any; end
        begin #20 $display($time, "\ttop_display_2"); ->any; end
      join_none
      @any;
     $display($time, "\ttop_display_3");
   end
endmodule

      //fork...join_none using fork...join_any
      
module top1;
   initial begin
      fork
        #10 $display($time, "\ttop1_display_1");
        #20 $display($time, "\ttop1_display_2");
	 	begin end
      join_any
     $display($time, "\ttop1_display_3");
   end
endmodule: top1
