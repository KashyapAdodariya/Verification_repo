module test1;
  bit [7:0]x;
  bit clk=0;
  initial forever #1 clk=~clk;
  always @(posedge clk) begin
    x=10;
    x=20;
    #10;
    $display($time,"Test-1\t Check Value: x = %0d",x);
  end
  //initial #40 $finish();
endmodule

module test2;
  bit [7:0] x;
  bit clk;
  initial forever #1 clk=~clk;
  always @(posedge clk) begin
    x<=10;
    x<=20;
    #10;
    $display($time,"Test-2\t Check Value: x = %0d",x);
  end
   
  //initial #20 $finish();
endmodule

module test3;
  bit [7:0] x;
  bit [7:0] y;
  bit clk;
  initial forever #1 clk=~clk;
  always @(posedge clk) begin
    x=10;
    x=20;
    y<=x;
    #10;
    $display($time,"Test-3\t Check Value: x = %0d, y = %0d",x,y);
  end
   
  //initial #20 $finish();
endmodule

module test4;
  bit [7:0] x;
  bit [7:0] y;
  bit clk;
  initial forever #1 clk=~clk;
  always @(posedge clk) begin
    x=10;
    x=20;
    y = x;
    #10;
    $display($time,"Test-4\t Check Value: x = %0d, y = %0d",x,y);
  end
   
  //initial #20 $finish();
endmodule

module test5;
  bit [7:0] x;
  bit [7:0] y;
  bit clk;
  initial forever #1 clk=~clk;
  always @(posedge clk) begin
    x=10;
    y=x;
    x=20;
    #10;
    $display($time,"Test-5\t Check Value: x = %0d, y = %0d",x,y);
  end
   
  //initial #20 $finish();
endmodule

module test6;
  bit [7:0] x;
  bit [7:0] y;
  bit clk;
  initial forever #1 clk=~clk;
  always @(posedge clk) begin
    x=10;
    y<=x;
    x=20;
    #10;
    $display($time,"Test-6\t Check Value: x = %0d, y = %0d",x,y);
  end
   
  //initial #20 $finish();
endmodule

module test7;
  bit [7:0] x;
  bit [7:0] y;
  bit clk;
  initial forever #1 clk=~clk;
  always @(posedge clk) begin
    y<=x;
    x=10;
    x=20;
    #10;
    $display($time,"Test-7\t Check Value: x = %0d, y = %0d",x,y);
  end
   
  //initial #20 $finish();
endmodule

module test8;
  bit [7:0] x;
  bit [7:0] y;
  bit clk;
  initial forever #1 clk=~clk;
  always @(posedge clk) begin
    x<=10;
    x<=20;
    y<=x;
    #10;
    $display($time,"Test-8\t Check Value: x = %0d, y = %0d",x,y);
  end
   
 // initial #20 $finish();
endmodule

module test9;
  bit [7:0] x;
  bit [7:0] y;
  bit clk;
  initial forever #1 clk=~clk;
  always @(posedge clk) begin
    x<=10;
    y<=x;
    x<=20;
    #10;
    $display($time,"Test-9\t Check Value: x = %0d, y = %0d",x,y);
  end
   
  initial #20 $finish();
endmodule

