//typedef bit [31:0]data_que[$];
typedef enum {ZERO_INIT,ONE_INIT,RANDOM_INIT} mem_init_h;

class slave_mem_h extends uvm_component;
  `uvm_component_utils(slave_mem_h)
  
  mem_init_h mem_init = ZERO_INIT;
  
  function new(string name = "slave_mem_h", uvm_component parent = null);
    super.new(name,parent);
    `uvm_info(get_type_name(),"slave_mem_h new call",UVM_LOW)
  endfunction: new
  
  bit [31:0]mem[*];
  
  function void write(bit [7:0]addr, bit [31:0]data);
    `uvm_info(get_type_name(),"slave_mem_h write call",UVM_LOW)
    mem[addr] = data;
    $display("memory display: addr: %0h\n data: %0h\n",addr,mem[addr]);
  endfunction: write
  
  function bit[31:0] read(bit [7:0]addr);
    `uvm_info(get_type_name(),"slave_mem_h read call",UVM_LOW)
    return mem[addr];
  endfunction: read
  
  
//   function void init();
//     case(mem_init)
//       ZERO_INIT: begin
//         for(int i=0;i<mem.size();i++) mem[i] = 0;
//       end
//       ONE_INIT: begin
//         for(int i=0;i<mem.size();i++) mem[i] = 1;
//       end
//       RANDOM_INIT: begin
//         for(int i=0;i<mem.size();i++) mem[i] = $urandom;
//       end
//     endcase
//   endfunction: init;
  
endclass: slave_mem_h