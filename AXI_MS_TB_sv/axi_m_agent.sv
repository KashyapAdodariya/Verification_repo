

//define axi_agent class
class axi_m_agent;

  //instantiate generator driver and monitor in agent class
    axi_m_gen gen=new();
	axi_m_dri dri=new();
    //monitor mon=new();
    scoreboard s1=new();
	axi_m_mon mon=new();
  axi_slave_driver dri_s= new();

  //declare run_phase of agent class
  task run();
		$display("axi_agent::run");

    //start run_phase of driver generator and monitor in parallel
		fork
			gen.run();
			dri.run();
          dri_s.run();
            mon.run();
            s1.run();
        join

  endtask //end of run phase

endclass //end of agent class
