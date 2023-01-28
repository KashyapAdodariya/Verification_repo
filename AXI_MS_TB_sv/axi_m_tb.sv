
//--- define testbench program ---
program axi_m_tb();

  //--- instantiate environment class ---
	axi_m_env env=new();

	initial begin

    //--- start run phase of environment class ---
		env.run();

  end //end of run phase

  final begin
  end
endprogram //end of testbench program
