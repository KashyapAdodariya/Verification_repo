class ei_spi_coverage_c extends uvm_subscriber#(ei_spi_sequence_item_c);


  //--------------------------------------- 
  // Declare variable
  //--------------------------------------- 
  int CPOL;
  int CPHA;
  int LSBFE;
  bit TRX_DONE;
  int slave;
  bit SS_ERR1;
  bit SS_ERR;
  bit SCLK_ERR;
//   real cov;			

  `uvm_component_utils(ei_spi_coverage_c)

  uvm_analysis_imp#(ei_spi_sequence_item_c, ei_spi_coverage_c) coverage_export;

  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
    spi_cg = new();
  endfunction : new

  ei_spi_sequence_item_c trx;

  //--------------------------------------- 
  // Cover group
  //--------------------------------------- 
  covergroup spi_cg() ;

    //     -----------------------------------------COVERPOINT-1-------------------------------------------
    data_len_cp: coverpoint trx.instruction[6:4]
    {
      bins data_len_bin[] = {[1:4]};
    }

    //-----------------------------------------COVERPOINT-2-------------------------------------------
    address_len_cp: coverpoint `ADDR_WIDTH
    {
      bins address_len_bin[] = {1,2,4};
    } 

    //-----------------------------------------COVERPOINT-3-------------------------------------------
    wr_rd_cp: coverpoint trx.instruction[7];

    //-----------------------------------------COVERPOINT-4-------------------------------------------    
    lsbfe_cp: coverpoint LSBFE;

    //-----------------------------------------COVERPOINT-5-------------------------------------------    
    CPOL_cp: coverpoint CPOL;

    //-----------------------------------------COVERPOINT-6-------------------------------------------    
    CPHA_cp: coverpoint CPHA;

    //-----------------------------------------CROSS COVERAGE-------------------------------------------
    cross_cp:cross CPOL, CPHA;

    //     -----------------------------

  endgroup

  //---------------------------------------
  // build_phase - create port and initialize local memory
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    coverage_export = new("coverage_export", this);

    void'(uvm_config_db#(int):: get(this,"*","CPOL",CPOL));
    void'(uvm_config_db#(int):: get(this,"*","CPHA",CPHA));
    void'(uvm_config_db#(int):: get(this,"*","LSBFE",LSBFE));
    //     scb 	 = spi_cg::type_id::create("scb", this);
  endfunction: build_phase


  //---------------------------------------
  // write task 
  //---------------------------------------
  virtual function void write(ei_spi_sequence_item_c pkt);
    trx = pkt;
    //     $display($time,,"\t------------- Packet received from COVERAGE Class---------------");
    //     `uvm_info(get_type_name(),$sformatf(" Printing trans, \n %s", pkt.sprint()),UVM_LOW)
    spi_cg.sample();
    //     pkt.print();
  endfunction 


//   //---------------------------------------
//   // extract Phase 
//   //---------------------------------------
//   function void extract_phase(uvm_phase phase);
//     super.extract_phase(phase);
// //     cov =  spi_cg.get_coverage();
//   endfunction

//   //---------------------------------------
//   // Report Phase 
//   //---------------------------------------
//   function void report_phase(uvm_phase phase);
//     super.report_phase(phase);
// //     `uvm_info(get_type_name(),$sformatf("Coverage is :  %f",cov),UVM_LOW)
//   endfunction


endclass : ei_spi_coverage_c