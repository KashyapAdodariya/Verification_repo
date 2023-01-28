// Non-Parameterized Class //
class Stack_DS;
  int array_stack[$];
  int tos; // top of stack
  
  function new();
    tos = 0;
  endfunction
  
  function void push(input int i);
    array_stack.push_front(i);
  endfunction
  
  function int pop();
    return array_stack.pop_front();
  endfunction
  
  function void print();
    $display("stack content: %p", array_stack);
    $display("elements in stack: %d", array_stack.size() );
  endfunction
  
endclass:Stack_DS

// stack class with default type parameter //
// parameterized class //
class Stack_DS_param #(type T = int);
  // Use the parameter to generalize the type of data in stack //
  T array_stack[$];
  int tos; // top of stack
  
  function new();
    tos = 0;
  endfunction
  
  function void push(input T i);
    array_stack.push_front(i);
  endfunction
  
  function int pop();
    return array_stack.pop_front();
  endfunction
  
  function void print();
    $display("stack content: %p", array_stack);
    $display("elements in stack: %d", array_stack.size() );
  endfunction
  
endclass:Stack_DS_param


module test;
  
  Stack_DS stack_h;
  int data;
  
  initial begin
    stack_h = new();
    
    stack_h.push(10);
    stack_h.push(20);
    stack_h.push(15);
    // print content of stack //
    stack_h.print();
    
    data = stack_h.pop();
    // stack after pop //
    stack_h.print();
  end
  // With Parameterized Class //
  // we can set the type based on our need :-)
  // increased flexibility and reusability //
  Stack_DS_param #(string) stack_p_h;
  initial begin
    stack_p_h = new();
    
    stack_p_h.push("Hi");
    stack_p_h.push("Hello");
    stack_p_h.push("World");
    
    stack_p_h.print();
    
    stack_p_h.pop();
    stack_p_h.print();
    
  end
endmodule