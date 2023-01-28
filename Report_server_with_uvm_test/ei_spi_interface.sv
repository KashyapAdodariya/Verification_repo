// interface ei_spi_interface_i (input bit CLK,bit RESETn);
interface ei_spi_interface_i (input bit CLK);
  bit RESETn ;
  logic	[`NO_OF_SLAVE-1:0]SS_;
  bit	 SCLK;
  bit	 MOSI;
  logic  MISO;					//MISO can be even in high impedance state
  
    
  //defining modports  for drivers
  modport mp_master_driver( input MISO , output SCLK, MOSI, SS_ );
  modport mp_slave_driver ( input SCLK, MOSI, SS_ ,output MISO);
  modport mp_monitor	  (input SCLK, MOSI, MISO, SS_);
      
    
//   //*************************ASSERTIONS****************************
  
//   //----------------------------ASSERTION-1--------------------------------
//   // MISO should be Z when SS is HIGH.
  property ss_high_prop;
    @(posedge CLK) disable iff(!RESETn) ($countbits(SS_, '0) == 1) ##0 ($countbits(SS_, '0) != 1) |-> MISO ==1'bz [*0:$] ##1 ($countbits(SS_, '0) == 1);
  endproperty

  ss_high_assert: assert property (ss_high_prop)
    else $display($time,,"---->>>> MISO not tri-state while ss_high. assertion failed!!!");
      
//   //----------------------------ASSERTION-2-------------------------------
  // Clock should  stable when SS is high
  property clk_tog_prop;
    @(posedge CLK) disable iff(!RESETn) ($countbits(SS_, '0) == 1) ##0 ($countbits(SS_, '0) != 1) |=> ($stable(SCLK)) [*0:$] ##1 ($countbits(SS_, '0) == 1);
  endproperty

  clk_tog_assert: assert property (clk_tog_prop)
    else $display($time,,"---->>>> clk_tog while ss_high. assertion failed!!!");
       
endinterface : ei_spi_interface_i