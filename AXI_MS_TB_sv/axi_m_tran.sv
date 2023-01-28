

class transaction#(parameter int width=32); 
  
  //--- declare typedef for class instance to use it as a argunment of different function ---
  typedef transaction#(width) trn_item_t;

  //--- DECLARE PARAMETER WIDTH TO CREATE PARAMETERIZE DATABUS LENGTH ---
  parameter WIDTH = width;

  //--- DECLARE ALL VARIABLE WHICH ARE COMMON IN BOTH READ WRITE CHANNEL ---
  typedef enum bit[1:0] {FIXED,INCR,WRAP} BURST_e;
  typedef enum bit[1:0]{NORMAL,LOCKED,EXCL}  LOCK_e;
  typedef enum bit { READ ,WRITE} tx_e;
  rand bit [31:0] ATADDR;
  randc bit [3:0] ATID;
  rand bit [3:0] ATLEN;
  rand bit [2:0] ATSIZE;
  rand BURST_e ATBURST;
  rand LOCK_e ATLOCK;
  rand tx_e rw;
  rand bit [3:0] ATCACHE;
  rand bit [2:0] ATPROT;
  rand bit [WIDTH-1:0] TDATA[];
  rand bit [(WIDTH/8)-1:0] WSTRB[];
  int UID;
  static int count;

  //--- new constructor ---
  function new();
    count++;
    UID=count;
  endfunction
  
 //--- DECLARE ALL METHODS AND CONSTRAINTS AS EXTERN ---
  
  extern constraint data_size_c;
  extern constraint atsize_c;
  extern constraint atburst_c;
  extern constraint wstrb_size_c;//D
  extern constraint wstrb_value_c;//D
  extern function void print_f();
  extern function void copy_f(ref trn_item_t tr);
  extern function bit compare_f(trn_item_t tr);

endclass //--- END OF TRANSACTION CLASS ---

