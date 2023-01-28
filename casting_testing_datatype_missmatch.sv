
class test_1;
  real a[3];
  function new(string s = "class test_1 started");
    $display(s);
  endfunction: new
  function void get_array();
    foreach(this.a[i]) begin
      a[i] = $urandom_range(0,5);
      $display("a[%0d]: %0.3f",i,this.a[i]);
    end
  endfunction: get_array
endclass: test_1

class test_2;
  real b[3];
  test_1 t1;
  function new(string s = "class test_2 started");
    $display(s);
    t1 = new;
  endfunction: new
  function void get_array();
    foreach(this.b[i]) begin
      b[i] = $urandom_range(0,10);
      $display("b[%0d]: %0d",i,this.b[i]);
    end
  endfunction: get_array
  function void assign_array();
    foreach(this.b[i]) begin
      t1.a[i] = b[i];
      $display("assign values t1.a[%0d]: %0.3f",i,t1.a[i]);
    end
  endfunction: assign_array
endclass: test_2

class test_3;
  int c[5];
  test_2 t2;
  function new(string s = "class test_3 started");
    $display(s);
    t2 = new;
  endfunction: new
  function void get_array();
    foreach(c[i]) begin
      c[i] = $urandom_range(11,100);
      $display("c[%0d]: %0.3f",i,c[i]);
    end
  endfunction: get_array 
  function void index_map;
    //$display("t2.b: %0p",t2.b);
    void'(t2.randomize());
    t2.get_array();
    foreach(t2.b[i]) begin
      t2.b[i] = c[i];
      $display("new t2.b[%0d]: %0d",i,t2.b[i]);
      //$display(t2.b[i]);
    end
  endfunction: index_map
  function void compare();
    foreach(t2.b[i]) begin
      if(t2.b[i]==c[i]) $display("matched");
      else $display("mismatch");
    end
  endfunction: compare
  function void direct_assign();
    t2.b[0] = 101.1010125456;
    $display("b[0]: %0f",t2.b[0]);
  endfunction
endclass: test_3

module test;
  //test_1 t1 = new;
  //test_2 t2 = new;
  test_3 t3 = new;
  initial begin
    //t1.get_array();
    //t2.get_array();
    //void'(t3.randomize());
    t3.get_array();
    t3.direct_assign();
    //t2.assign_array();
    t3.index_map();
    t3.compare();
    t3.direct_assign();
    $display("t2.b: %0p",t3.t2.b);
  end
endmodule: test