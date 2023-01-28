//
// Polymorphism: IDEA
// virtual functions resolves to the most-derived version of the function that exists
// between the base and derived class. This capability is known as polymorphism
//
/*
* In Object Oriented Programming we can have same function within parent and derived class
* and can safetly pass the base class hanndel to parennt class handel with desired behavior
* this is achieved by making the funnctionn definitionn "virtual" in the parennt class,
* so we can correctly overwrite in the base class
*
*
*
* Below Example shows the usage of this idea
*/

class Transaction;
  // data members //
  logic [15:0] address;
  bit valid;
  
  // constructor //
  function new();
    this.valid = 1'b0;
    this.address = $urandom_range(10,100);
  endfunction
  
  // class method (member function) //
  function void display_info();
    $display("-------- BASE INFO --------");
    $display(" address assigned: %0h", address);
    $display(" Valid = %b", valid);
    $display("-------- END DEBUG --------");  
  endfunction:display_info
  
  // Notice the "virtual" inn front of the funnction //
  virtual function void display_poly();
    $display("-------- BASE INFO --------");
    $display(" address assigned: %0h", address);
    $display(" Valid = %b", valid);
    $display("-------- END DEBUG --------");  
  endfunction:display_poly
  
endclass:Transaction

class Packet extends Transaction;
  
  // derived class members
  logic [7:0]  data;
  bit ready;
  
  // constructor is crucial here as the parent class has to be constructed first //
  function new();
    // first call Parent (Base) class using super.new()
    // MUST be the FIRST statement before any other statements//
    super.new();
    this.data = $urandom_range(10,100);
    this.ready = 1'b1;
  endfunction
  
  function void display_info();
    $display("-------- DERIVED INFO --------");
    $display(" data generated: %0h", data);
    $display(" Ready = %0b", ready);
    $display("-------- END DEBUG --------");
  endfunction:display_info
  
  function void display_poly();
    $display("-------- DERIVED INFO --------");
    $display(" data generated: %0h", data);
    $display(" Ready = %0b", ready);
    $display("-------- END DEBUG --------");
  endfunction:display_poly
  
endclass:Packet


module test_inh;
  
  // some function that take argument as Transaction type object //
  // this calls the class display_info function //
  function void print(Transaction T);
    T.display_info();
  endfunction
  
  function void print_2(Transaction T);
    T.display_poly();
  endfunction
  
  Transaction tk;
  Packet pk;
  
  initial begin
    tk = new();
    pk = new();

    // class print function on tk //
    // this works as expected //
    print(tk);
    
    // call prinnt fucntion on pk //
    // this will result inn callinng base class display_info() 
    // insted of packet class funnction WHY ??
    print(pk);
    
    $display("------------WITH POLYMORPHISM ---------------");
    $display("------ WE GET CORRECT DERIVED CLASS ----------");
    // POLYMORPHISM //
    // NOW lets call the display_poly() function inn the print funnctionn above
    // Notice the keyword 'virtual' in front of display_poly() for both the classes 
    // notice now we get the child class i.e. Packet info correctly. :-)
    print_2(pk);
    
  end
endmodule