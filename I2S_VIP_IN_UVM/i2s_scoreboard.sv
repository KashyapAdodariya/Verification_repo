

// Revision: 3
//-------------------------------------------------------------------------------

class i2s_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(i2s_scoreboard)
  //uvm_tlm_analysis_fifo #(i2s_seq_item) master_fifo;
  uvm_tlm_analysis_fifo #(i2s_seq_item) slave_fifo;
  uvm_blocking_put_imp #(i2s_seq_item,i2s_scoreboard) slave_drv;
  uvm_blocking_put_imp #(i2s_seq_item,i2s_scoreboard) master_drv;
  
  //i2s_config m_cfg;
  i2s_seq_item m_data,s_data;
  i2s_seq_item pkt,trans[$];
  
  //declear veriable and insatance
  int n;
  int no_of_tx_pkt;
  int no_of_rx_pkt;
  int no_of_success_pkt;
  int no_of_failure_pkt;
  bit pass_pkt;
  bit fail_pkt;
  
  //prototype
  extern function new(string name = "i2s_scoreboard",uvm_component parent);
  extern task run_phase(uvm_phase phase);
  extern task put(i2s_seq_item pkt_s);
  extern function void check_data();
  extern function void report_phase(uvm_phase phase);  
  extern function void build_phase(uvm_phase phase);
 
endclass 

  //////////////////////////////////////////////////////// 
	// Method name        : build_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : create and build object 
  //////////////////////////////////////////////////////// 

  function void i2s_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);  
    `uvm_info(get_type_name(),"I2S_SCB BUILD_PHASE",UVM_LOW)
  endfunction    

  //////////////////////////////////////////////////////// 
  // Method name        : new
  // Parameter Passed   : name as sting
  // Returned parameter : void  
  // Description        : constract tlm port
  ////////////////////////////////////////////////////////

  function i2s_scoreboard::new(string name = "i2s_scoreboard" ,uvm_component parent);
    super.new(name,parent);
      slave_fifo=new("slave_fifo",this);
      master_drv=new("master_drv",this);
    `uvm_info(get_type_name(),"I2S_SCB NEW",UVM_LOW)
  endfunction
     
  //////////////////////////////////////////////////////// 
  // Method name        : put
  // Parameter Passed   : i2s_seq_item pkt_s
  // Returned parameter : void  
  // Description        : 
  ////////////////////////////////////////////////////////
  task i2s_scoreboard:: put(i2s_seq_item pkt_s);
    trans.push_back(pkt_s);
    no_of_tx_pkt++;
  endtask
    
  //////////////////////////////////////////////////////// 
  // Method name        : run_phase
  // Parameter Passed   : uvm_phase phase
  // Returned parameter : void  
  // Description        : running 
  ////////////////////////////////////////////////////////

  task i2s_scoreboard::run_phase(uvm_phase phase);
    
    forever begin
      pass_pkt = 0;
      fail_pkt = 0;
      
      slave_fifo.get(pkt);
      no_of_rx_pkt++;
      `uvm_info("SCOREBOARD","\t\t\tCHECKING\t\t\t",UVM_HIGH)
      //trans[n].print();
      pkt.print();
      if(pkt.data == trans[n].data) begin
        no_of_success_pkt++;
        pass_pkt = 1;
        `uvm_info("SCOREBOARD","\t\t\tTESTCASE PASS\t\t\t",UVM_HIGH)
      end
      else begin
        no_of_failure_pkt++;
        fail_pkt = 0;
        `uvm_info("SCOREBOARD","\t\t\tTESTCASE FAIL\t\t\t",UVM_HIGH)
      end
      n++;
      end
    `uvm_info(get_type_name(),"I2S_SCB RUN_PHASE",UVM_LOW)
  endtask : run_phase
        


  function void i2s_scoreboard:: report_phase(uvm_phase phase);  
    $display("\n\n      \tSCORE BOARD RESULT FOR PACKET     ");
    $display("      TOTAL NO OF DATA VERIFIED WITH SUCCESS: %0d     ",no_of_success_pkt  );
    $display("      TOTAL NO OF DATA VERIFIED WITH FAILURE: %0d     \n\n",no_of_failure_pkt);
  endfunction
      
        







  /*class i2s_scoreboard extends uvm_scoreboard;

    uvm_tlm_analysis_fifo #(i2s_seq_item)item_collected;
    uvm_blocking_put_imp #(i2s_seq_item,i2s_scoreboard) item_drive_collect;
    
    i2s_seq_item pkt,trans[$];
    int num_of_passed;
    int num_of_failed;
    `uvm_component_utils(i2s_scoreboard)

    // new - constructor

    function new (string name, uvm_component parent);
      super.new(name, parent);
      item_collected = new("item_collected",this);
      item_drive_collect=new("item_drive_collect",this);
    endfunction : new

    // build_phase - 

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
    endfunction: build_phase
    
    virtual task put(i2s_seq_item pkt_s);
      $display("scoreboard is running");
      trans.push_back(pkt_s);
    endtask
    

    // run_phase

    virtual task run_phase(uvm_phase phase);
        $display("scoreboard comparision");
      
    forever begin
      item_collected.get(pkt);
      foreach(trans[i]) begin
        if(pkt.data == trans[i].data) begin
        num_of_passed++;
          $display("TESTCASE pass");
      end
      else begin
        num_of_failed++;
          $display("TESTCASE failed");
      end
      end
    end
    endtask : run_phase
        

  endclass : i2s_scoreboard

  */
