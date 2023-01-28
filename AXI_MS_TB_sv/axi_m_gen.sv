class axi_m_gen;
  transaction tx,txQ[$];
	task run();
      $display("--- axi_gen :: Started Run task ---");
      case (axi_m_config::testname)
			
          
"2_WRITE_BACK_TO_BACK" : begin
  for(int i=0;i<2;i++) begin
                             tx=new;
                             tx.randomize with {rw == WRITE;};
                             txQ.push_back(tx);
                             $display("write : %d",tx);
						     axi_m_config::gen2bfm_mbox.put(tx);
					       end
			             //end

//"2_READ_BACK_TO_BACK" : begin
  for(int i=0;i<2;i++) begin
				            tx=new;
                            $display(txQ);
                            tx.randomize with {rw==READ; 
                                               ATADDR == txQ[i].ATADDR;
                                               ATLEN == txQ[i].ATLEN;
                                               ATSIZE == txQ[i].ATSIZE;
                                               ATBURST == txQ[i].ATBURST;};
						    axi_m_config::gen2bfm_mbox.put(tx);
					      end
  
  //2-write + 2-read + 2-write
    for(int i=0;i<2;i++) begin
                             tx=new;
                             tx.randomize with {rw == WRITE;};
                             txQ.push_back(tx);
                             $display("write : %d",tx);
						     axi_m_config::gen2bfm_mbox.put(tx);
					       end

  
  						txQ.delete();
	  		            end
            "WRITE_TX" : begin
				           tx=new();
                           tx.randomize with {rw==WRITE;};
                           txQ.push_back(tx);
					       axi_m_config::gen2bfm_mbox.put(tx);
			             end
          
"READ_WRITE_READ_WRITE_TX" : begin
  							int i=0;
			  	           tx=new();
                           tx.randomize with {rw==READ; 
                                              ATADDR == txQ[i].ATADDR;
                                              ATLEN == txQ[i].ATLEN;
                                              ATSIZE == txQ[i].ATSIZE;
                                              ATBURST == txQ[i].ATBURST;};
					       axi_m_config::gen2bfm_mbox.put(tx);
                           i++;
  
  				           tx=new();
  						   tx.randomize with {rw==WRITE;};
                           txQ.push_back(tx);
					       axi_m_config::gen2bfm_mbox.put(tx);
    					
  						   tx=new();
                           tx.randomize with {rw==READ; 
                                              ATADDR == txQ[i].ATADDR;
                                              ATLEN == txQ[i].ATLEN;
                                              ATSIZE == txQ[i].ATSIZE;
                                              ATBURST == txQ[i].ATBURST;};
					       axi_m_config::gen2bfm_mbox.put(tx);

  				           tx=new();
                           tx.randomize with {rw==WRITE;};
                           txQ.push_back(tx);
					       axi_m_config::gen2bfm_mbox.put(tx);
                           i++;
			             end
          
      "RANDOM_TEST" :  begin
        				  int i=0;
                           tx=new();
                           tx.randomize with {if(rw==READ)  ATADDR == txQ[i].ATADDR;
                                              ATLEN == txQ[i].ATLEN;
                                              ATSIZE == txQ[i].ATSIZE;
                                              ATBURST == txQ[i].ATBURST;};
					       axi_m_config::gen2bfm_mbox.put(tx);
      				   end

		  
    
          default : $display("enter valid testname");
endcase	     
	endtask
endclass