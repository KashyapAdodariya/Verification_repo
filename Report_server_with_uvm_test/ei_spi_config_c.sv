

class ei_spi_config_c extends uvm_object; 

  `uvm_object_utils(ei_spi_config_c)

  rand bit LSBFE; 						    //Variable to set the LSBFE rand bit (LSB First)
  rand bit CPOL; 								// Variable to set the polarity of the clock
  rand bit CPHA; 								// Variable to set the phase of the clock
  rand bit SCLK_ERR; 							// Variable to generate error of SCLK (SCLK stable in between transaction)
  rand bit SS_ERR; 							// Variable to generate error of SS_ (deassert SS_ in between transaction)
   bit SS_ERR1; 
  int slave; 						

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name = "ei_spi_config_c"); 
    super.new(name); 
  endfunction: new

  //constraint CPOL_CPHA_LSBFE {CPOL==0; CPHA==0; LSBFE==0; SCLK_ERR==0; SS_ERR==0; }
  
endclass

//-----------------------CPOL_LO_CPHA_LO_-------------------
class CPOL_LO_CPHA_LO_LSBFE_LO extends ei_spi_config_c; 
  `uvm_object_utils(CPOL_LO_CPHA_LO_LSBFE_LO)
  
    function new (string name = "CPOL_LO_CPHA_LO_LSBFE_LO"); 
    super.new(name); 
  endfunction: new
  
  constraint CPOL_CPHA_LSBFE {CPOL==0; CPHA==0; LSBFE==0; SCLK_ERR==1; SS_ERR==1; }
endclass

class CPOL_LO_CPHA_LO_LSBFE_HI extends ei_spi_config_c; 
    `uvm_object_utils(CPOL_LO_CPHA_LO_LSBFE_HI)
    function new (string name = "CPOL_LO_CPHA_LO_LSBFE_HI"); 
    super.new(name); 
  endfunction: new
  constraint CPOL_CPHA_LSBFE {CPOL==0; CPHA==0; LSBFE==1; SCLK_ERR==0; SS_ERR==0; }
endclass

//-----------------------CPOL_LO_CPHA_HI-------------------
class CPOL_LO_CPHA_HI_LSBFE_LO extends ei_spi_config_c; 
  `uvm_object_utils(CPOL_LO_CPHA_HI_LSBFE_LO)
    function new (string name = "CPOL_LO_CPHA_HI_LSBFE_LO"); 
    super.new(name); 
  endfunction: new
  constraint CPOL_CPHA_LSBFE {CPOL==0; CPHA==1; LSBFE==0; SCLK_ERR==0; SS_ERR==0; }
endclass

class CPOL_LO_CPHA_HI_LSBFE_HI extends ei_spi_config_c; 
  `uvm_object_utils(CPOL_LO_CPHA_HI_LSBFE_HI)
  function new (string name = "CPOL_LO_CPHA_HI_LSBFE_HI"); 
    super.new(name); 
  endfunction: new
  constraint CPOL_CPHA_LSBFE {CPOL==0; CPHA==1; LSBFE==1; SCLK_ERR==0; SS_ERR==0; }
endclass

//-----------------------CPOL_HI_CPHA_LO-------------------
class CPOL_HI_CPHA_LO_LSBFE_LO extends ei_spi_config_c; 
  `uvm_object_utils(CPOL_HI_CPHA_LO_LSBFE_LO)
    function new (string name = "CPOL_HI_CPHA_LO_LSBFE_LO"); 
    super.new(name); 
  endfunction: new
  constraint CPOL_CPHA_LSBFE {CPOL==1; CPHA==0; LSBFE==0; SCLK_ERR==0; SS_ERR==0; }
endclass

class CPOL_HI_CPHA_LO_LSBFE_HI extends ei_spi_config_c; 
  `uvm_object_utils(CPOL_HI_CPHA_LO_LSBFE_HI)
  function new (string name = "CPOL_HI_CPHA_LO_LSBFE_HI"); 
    super.new(name); 
  endfunction: new
  constraint CPOL_CPHA_LSBFE {CPOL==1; CPHA==0; LSBFE==1; SCLK_ERR==0; SS_ERR==0; }
endclass

//-----------------------CPOL_HI_CPHA_HI-------------------
class CPOL_HI_CPHA_HI_LSBFE_LO extends ei_spi_config_c; 
  `uvm_object_utils(CPOL_HI_CPHA_HI_LSBFE_LO)
    function new (string name = "CPOL_HI_CPHA_HI_LSBFE_LO"); 
    super.new(name); 
  endfunction: new
  constraint CPOL_CPHA_LSBFE {CPOL==1; CPHA==1; LSBFE==0; SCLK_ERR==0; SS_ERR==0; }
endclass

class CPOL_HI_CPHA_HI_LSBFE_HI extends ei_spi_config_c; 
  `uvm_object_utils(CPOL_HI_CPHA_HI_LSBFE_HI)
  function new (string name = "CPOL_HI_CPHA_HI_LSBFE_HI"); 
    super.new(name); 
  endfunction: new
  constraint CPOL_CPHA_LSBFE {CPOL==1; CPHA==1; LSBFE==1; SCLK_ERR==0; SS_ERR==0; }
endclass

//-----------------------SCLK_ERR-------------------
class SCLK_ERR_TEST extends ei_spi_config_c; 
  `uvm_object_utils(SCLK_ERR_TEST)
    function new (string name = "SCLK_ERR_TEST"); 
    super.new(name); 
  endfunction: new
  constraint CPOL_CPHA_LSBFE {CPOL==0; CPHA==0; LSBFE==0; SCLK_ERR==1; SS_ERR==0; }
endclass

//-----------------------SS_ERR-------------------
class SS_ERR_TEST extends ei_spi_config_c; 
  `uvm_object_utils(SS_ERR_TEST)
  function new (string name = "SS_ERR_TEST"); 
    super.new(name); 
  endfunction: new
  constraint CPOL_CPHA_LSBFE {CPOL==0; CPHA==0; LSBFE==0; SCLK_ERR==0; SS_ERR==1; }
endclass
