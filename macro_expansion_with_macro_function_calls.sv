`define INST_EXPAND(macro) \
	```macro``(5) \
	```macro``(1) 

`define gen_str(num) \
if(``num==1)a = ``num; \
else b = ``num;


module test;
  int a,b;
  initial begin 
    `INST_EXPAND(gen_str)
    $display("a = %0d\t b = %0d",a,b);
  end
  
endmodule
	