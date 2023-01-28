//declear class for save required veriables
class axi_slave_trans;
	parameter int size_bus = 32;
	bit [3:0]id;
	bit [3:0]len;
	bit [2:0]size;
	bit [1:0]bursttype;
	bit [size_bus-1:0]address;
	bit [size_bus-1:0]data;
	bit [(size_bus/8)-1:0]wstrb;
  bit [3:0]wid;
    //bit resetn;
endclass:axi_slave_trans

//declear class for slave driver
class axi_slave_driver;
	//declear virtual interface
	virtual axi_intf vif;
	//for store write and read trasaction based on awid field
	axi_slave_trans trans_wrt[*];
	axi_slave_trans trans_red[*];
    //axi_slave_trans t=new;
	//asso. array for memory. used only per byte store
	byte unsigned mem[*];
	//used in alen transection counter	
    int flag,flag1;
    int temp;
    
    //task for reset  
	extern task reset();
	
  //run task
  task run();

    // assign config::vif to local vif
    vif = axi_m_config::vif;
    //forever loop start
    forever begin:forever1
    	//waiting for posedge of ACLK
    	@(posedge vif.ACLK);
     
		  //starting parallel process for reset and (write+read) process    
		  fork:outside_fork
		    begin:reset1
		      //reset task call
		      reset();
		    end:reset1
		    begin
			//inside_fork used for start parallal process for write and read
		    fork:inside_fork
		      //write_channel data store in mem
		      begin:write_channel
                
                //wait(vif.slave_mp.slave_cb.AWVALID)begin
                forever begin:in_for
                  wait(vif.slave_mp.slave_cb.AWVALID);
                fork
                  begin:fork1
                    
		        trans_wrt[vif.slave_mp.slave_cb.AWID] = new();
		        //write_channel(trans_wrt[vif.slave_mp.slave_cb.AWID]);
				//chack AWVALID was assreted or not
		      	if(vif.slave_mp.slave_cb.AWVALID==1) begin:if1
		      		//asserted AWREADY as a one
					vif.slave_mp.slave_cb.AWREADY <= 1;
					//Push address,busrttype,burstlen,burstsize based on awid field
					//create a new object in trans_wrt on AWID index 
					//trans_wrt[vif.slave_mp.slave_cb.AWID] = new();
					//store length
					trans_wrt[vif.slave_mp.slave_cb.AWID].len = vif.slave_mp.slave_cb.AWLEN;
					//store burst size
					trans_wrt[vif.slave_mp.slave_cb.AWID].size = vif.slave_mp.slave_cb.AWSIZE;
					//store bursttype
					trans_wrt[vif.slave_mp.slave_cb.AWID].bursttype = vif.slave_mp.slave_cb.AWBURST;
					//store write address
					trans_wrt[vif.slave_mp.slave_cb.AWID].address = vif.slave_mp.slave_cb.AWADDR;
					//store AWID 
					trans_wrt[vif.slave_mp.slave_cb.AWID].id = vif.slave_mp.slave_cb.AWID;
                  trans_wrt[vif.slave_mp.slave_cb.AWID].wid=vif.slave_mp.slave_cb.WID;
                 // ##1 vif.slave_mp.slave_cb.AWREADY <=0;
				end:if1
				//deseart AWREADY
		        else begin vif.slave_mp.slave_cb.AWREADY <= 0; end
                    
                    $display("\n\n\n %0h %oh\n\n\n",trans_wrt[vif.slave_mp.slave_cb.AWID].id,trans_wrt[vif.slave_mp.slave_cb.AWID].wid);
                    
                  end:fork1
                  begin:fork2
		        
				//for write data phase
				//wait for wvalid
				@(vif.slave_mp.slave_cb.WVALID) begin:if2
		            //assert wread  
		        	vif.slave_mp.slave_cb.WREADY <= 1;
		        	//by using AWID put data into transection class object
                  trans_wrt[vif.slave_mp.slave_cb.WID].data = vif.slave_mp.slave_cb.WDATA;
		            //store wstrob
					trans_wrt[vif.slave_mp.slave_cb.WID].wstrb = vif.slave_mp.slave_cb.WSTRB;
					
					//for fix burst type
					if(trans_wrt[vif.slave_mp.slave_cb.WID].bursttype==0) begin:if3
						//according to wstrob signal select below case and increment address for memory	                    
						case(trans_wrt[vif.slave_mp.slave_cb.WID].wstrb)
							//only 8bit transfer no need to incerment address
							4'b0001: this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[7:0];
							4'b0010: this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[15:8];
							4'b0100: this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[23:16];
							4'b1000: this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[31:24];
							//only 16bit store in memory need to incre. address 2 times
							4'b0011: begin 
										 this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[7:0];
										 this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address+1] = vif.slave_mp.slave_cb.WDATA[15:8];
									 end
							4'b1100: begin 
										this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[7:0];
										this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address+1] = vif.slave_mp.slave_cb.WDATA[15:8];
							   		 end
							////32-bit store in memory. need to incre. address 4 times
							4'b1111: begin 
                              			this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[7:0];
										this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address+1] = vif.slave_mp.slave_cb.WDATA[15:8];
										this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address+2] = vif.slave_mp.slave_cb.WDATA[23:16];
										this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address+3] = vif.slave_mp.slave_cb.WDATA[31:24];
									 end
							default: $error("not valid wstrb");
						endcase
					end:if3
					
					//for incr burst type
					if(trans_wrt[vif.slave_mp.slave_cb.WID].bursttype == 1) begin:if4
						//increment length till len+1 used flag to denote
						while(flag!=(trans_wrt[vif.slave_mp.slave_cb.WID].len+1)) 
					  	    begin
								//first data will send to address according to strobe condition
								case(trans_wrt[vif.slave_mp.slave_cb.WID].wstrb)
									4'b0001: this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[7:0];
									4'b0010: this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[15:8];
									4'b0100: this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[23:16];
									4'b1000: this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[31:24];
									4'b0011: begin 
												this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[7:0];
												this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address+1] = vif.slave_mp.slave_cb.WDATA[15:8];
									   		end
									4'b1100: begin 
												this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[7:0];
										  		this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address+1] = vif.slave_mp.slave_cb.WDATA[15:8];
										     end
									4'b1111: begin 
												this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address] = vif.slave_mp.slave_cb.WDATA[7:0];
												this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address+1] = vif.slave_mp.slave_cb.WDATA[15:8];
												this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address+2] = vif.slave_mp.slave_cb.WDATA[23:16];
												this.mem[trans_wrt[vif.slave_mp.slave_cb.WID].address+3] = vif.slave_mp.slave_cb.WDATA[31:24];
											 end
								default: $error("not valid wstrb");
								endcase
                                                         
							   //for next tx address will be inremented
								trans_wrt[vif.slave_mp.slave_cb.WID].address= trans_wrt[vif.slave_mp.slave_cb.WID].address+(2**(trans_wrt[vif.slave_mp.slave_cb.WID].size));
							   //flag will increment for each data if flag equal to the len+1 then loop will terminated
							   flag++;
                              
                              $display("\n\n\n\nflag: %0d mem: %p\n\n\n\n",flag,mem);
                              
                              if(vif.slave_mp.slave_cb.WLAST==1) begin:last
                                  //BID=AWID same both
                                  vif.slave_mp.slave_cb.BID <= vif.slave_mp.slave_cb.WID;
                                  //send okey responce
                                  vif.slave_mp.slave_cb.BRESP <= 2'b00;
                                  //bvalid asserted
                                  vif.slave_mp.slave_cb.BVALID <= 1;
                                  //at negedge of clk bvalid deserted
                                  @(negedge vif.ACLK);
                                  vif.slave_mp.slave_cb.BVALID <= 1'b0;
							 end:last
							   //wait till next posedge of clk 
		                       @(posedge vif.ACLK); 
							end
							//flush the flag for next transection
						    flag=0;
						end:if4
		              
		             //logic for wlast signal
		            //wait (vif.slave_mp.slave_cb.WLAST); 
					/*if(vif.slave_mp.slave_cb.WLAST==1) begin:last
							//BID=AWID same both
						  	vif.slave_mp.slave_cb.BID <= vif.slave_mp.slave_cb.ARID;
							//send okey responce
							vif.slave_mp.slave_cb.BRESP <= 2'b00;
							//bvalid asserted
							vif.slave_mp.slave_cb.BVALID <= 1;
							//at negedge of clk bvalid deserted
		                  	@(negedge vif.ACLK);
							vif.slave_mp.slave_cb.BVALID <= 1'b0;
					end:last*/
                  
					else vif.slave_mp.slave_cb.WREADY <= 0;
			end:if2
            
            end:fork2
            join
                end:in_for
                
		 end:write_channel
/*--------------------------------------------------------------------------------------------------------------------------------------*/
		 //start read channel logic     
		 begin:read_channel
	     	//read_channel task call	  
	     	//wait for ARVALID asserted       
           forever begin:for3
		    wait(vif.slave_mp.slave_cb.ARVALID); 
			if(vif.slave_mp.slave_cb.ARVALID==1) begin:if5
				//asset arready
				vif.slave_mp.slave_cb.ARREADY <= 1;
				//asset rvalid
				vif.slave_mp.slave_cb.RVALID <= 1;
				//push all required data into trans_red
				trans_red[vif.slave_mp.slave_cb.ARID] = new();
				trans_red[vif.slave_mp.slave_cb.ARID].len = vif.slave_mp.slave_cb.ARLEN;
				trans_red[vif.slave_mp.slave_cb.ARID].size = vif.slave_mp.slave_cb.ARSIZE;
				trans_red[vif.slave_mp.slave_cb.ARID].bursttype = vif.slave_mp.slave_cb.ARBURST;
				trans_red[vif.slave_mp.slave_cb.ARID].address = vif.slave_mp.slave_cb.ARADDR;
				trans_red[vif.slave_mp.slave_cb.ARID].id = vif.slave_mp.slave_cb.ARID;
			end:if5
		        //else begin vif.slave_mp.slave_cb.ARREADY <= 0; end
				//for read data phase
				//wait(vif.slave_mp.slave_cb.RREADY); begin:if6
				//start fix type
		        //wait(vif.slave_mp.slave_cb.ARVALID);
			begin:if6	      
				//for fix burst type    
		    	if(trans_red[vif.slave_mp.slave_cb.ARID].bursttype==0) begin:if7
		    		//send id 
					vif.slave_mp.slave_cb.RID <= trans_red[vif.slave_mp.slave_cb.ARID].id;
					//sent rdata
					vif.slave_mp.slave_cb.RDATA <= this.mem[trans_red[vif.slave_mp.slave_cb.ARID].address];
				end:if7
				//for incr burst type
				if(trans_red[vif.slave_mp.slave_cb.ARID].bursttype == 1) begin:if8
					//send RID same as ARID
					vif.slave_mp.slave_cb.RID <=trans_red[vif.slave_mp.slave_cb.ARID].id;
					//for burst type send data upto len+1	                
		            while(flag1!=(trans_red[vif.slave_mp.slave_cb.ARID].len+1)) 
						begin:wh
							//send rresp as okey, rvalid as 1 and rlast as 0 for every transection
						   	vif.slave_mp.slave_cb.RRESP <= 2'b00;
						   	vif.slave_mp.slave_cb.RVALID <= 1;
						   	vif.slave_mp.slave_cb.RLAST <= 0;
		            	   	//if(mem.exist[trans_red[vif.slave_mp.slave_cb.ARID].address]) begin:exists1	not working
		                     if(this.mem[trans_red[vif.slave_mp.slave_cb.ARID].address]!=0) begin:exists1
		                     	//for size=0 send 7bit
					      	   if(trans_red[vif.slave_mp.slave_cb.ARID].size==0)
							   		begin
		                       		     vif.slave_mp.slave_cb.RDATA[7:0] <=this.mem[trans_red[vif.slave_mp.slave_cb.ARID].address];         
									end
								//for size=1 send 16bit
								else if(trans_red[vif.slave_mp.slave_cb.ARID].size==1)
									begin
		                        	    vif.slave_mp.slave_cb.RDATA[7:0]<=this.mem[trans_red[vif.slave_mp.slave_cb.ARID].address]; 
		                                vif.slave_mp.slave_cb.RDATA[15:8]<=this.mem[trans_red[vif.slave_mp.slave_cb.ARID].address+1];
									end
								////for siz more then 2 send 32bit
								else 
									begin
		                           	    vif.slave_mp.slave_cb.RDATA[7:0]<=this.mem[trans_red[vif.slave_mp.slave_cb.ARID].address];
		                               	vif.slave_mp.slave_cb.RDATA[15:8]<=this.mem[trans_red[vif.slave_mp.slave_cb.ARID].address+1];
		                               	vif.slave_mp.slave_cb.RDATA[23:16]<=this.mem[trans_red[vif.slave_mp.slave_cb.ARID].address+2];
		                               	vif.slave_mp.slave_cb.RDATA[31:24]<=this.mem[trans_red[vif.slave_mp.slave_cb.ARID].address+3]; 
								    end
								    //logic for incr address
							   trans_red[vif.slave_mp.slave_cb.ARID].address= trans_red[vif.slave_mp.slave_cb.ARID].address+(2**(trans_red[vif.slave_mp.slave_cb.ARID].size));
							   //flag will increment for each data if flag equal to the len+1 then loop will terminated
							   flag1++;
		                       @(posedge vif.ACLK);
							 end:exists1
							   //else vif.slave_mp.slave_cb.RDATA <= 0;			//if data not found
							   
		                     if(flag1==(trans_red[vif.slave_mp.slave_cb.ARID].len+1))
						  		begin
							  		vif.slave_mp.slave_cb.RLAST<=1;
						  		end 
						  		
		                     @(negedge vif.ACLK);
						  		vif.slave_mp.slave_cb.RVALID <= 0;
						  		//vif.slave_mp.slave_cb.RDATA <= 0;
						  		//vif.slave_mp.slave_cb.RID <= 0;
		             end:wh
		              
				  //flush the flag for new transection
				  flag1=0;
				  vif.slave_mp.slave_cb.RLAST<=0;
				end:if8
			end:if6
				//by default rlast==0
		        //vif.slave_mp.slave_cb.RLAST<=0;
           end:for3
		  end:read_channel
           
		      

	  join:inside_fork
	  end
    join:outside_fork
    disable fork;
   end:forever1
  endtask:run
endclass:axi_slave_driver
 
//declear task for rrest
task axi_slave_driver :: reset();
  wait(!(vif.ARESETn));
    vif.slave_mp.slave_cb.WREADY <= 0;
    vif.slave_mp.slave_cb.BVALID <= 0;
    vif.slave_mp.slave_cb.BID <= 0;
    vif.slave_mp.slave_cb.BRESP <= 0;
    $display("RESET: IS ON AT SLAVE");
  //wait(vif.slave_mp.slave_cb.ARESET);
    //$display("RESET: IS OFF AT SLAVE");
endtask:reset