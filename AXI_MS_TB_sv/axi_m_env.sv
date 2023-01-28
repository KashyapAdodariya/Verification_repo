

//--- generate environment class ---
class axi_m_env ;

  //--- instantiate agent as well as scoreboard here ---
	axi_m_agent agt=new();
	//axi_m_sb scb=new();
    
  //--- declare run_phase of env class --- 
  task run();
		$display("axi_env::run");

    //--- start run_phase of agent as well as scoreboard block ---
    fork
      agt.run();
      //scb.run();
    join

  endtask // end of run phase

endclass //end of environment class
