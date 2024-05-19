typedef struct {
    string name;
    int data_count;
    string id;
  	string data[$]; // Assuming maximum number of data entries
  	int hash_addr_data[int];
} dataStruct;

module csv_process;

  dataStruct dataColl[$];
  string demostr = "tb_top.hdl_path,3,102:3,103:4,105:6,tb.out_hdl";
  int st_idx=0, end_idx=0;
  int data_cnt = 0;
  //string splitstr;
  
  function string split_using_delimiter_fn(int offset, string str, string del, int en, output int cnt);
    //string temp = "";
    for (int i = offset; i < str.len(); i=i+1) begin
      //if(en==1) $display("%0s ",str.getc(i));
      if (str.getc(i) == del || str.getc(i)=="\n" || i==(str.len-1)) begin
       		cnt = i;
        //if(en) $display("inside return loop : substr=%0s\t offset:%0d\t i:%0d",str.substr(offset,i-1),offset,i);
        if(offset==i) return str.getc(i);
        else return str.substr(offset,i-1);
     	end
      //else temp = {temp, str.getc(i)};
    end
  endfunction
  
  initial begin    
    for(int i=0;i<1;i++) begin
      string data_cnt = "";
      string addr_value = "";
      string addr = "";
      string value = "";
      dataColl[i].name = split_using_delimiter_fn(st_idx,demostr,",",0,end_idx);
      data_cnt = split_using_delimiter_fn(end_idx+1,demostr,",",0,end_idx);
      dataColl[i].data_count = data_cnt.atoi();
      //dataColl[i].data_count = split_using_delimiter_fn(end_idx+1,demostr,",",0,end_idx);
      //data_cnt = dataColl[i].data_count.atoi();
      for(int ij=0;ij<dataColl[i].data_count; ij++) begin
        int sub_end_idx=0;
        addr_value = split_using_delimiter_fn(end_idx+1,demostr,",",0,end_idx);
        addr = split_using_delimiter_fn(0,addr_value,":",0,sub_end_idx);
        value = split_using_delimiter_fn(sub_end_idx+1,addr_value,":",0,sub_end_idx);
        //$display("\naddr:%0s\t value=%0s",addr,value);
        dataColl[i].hash_addr_data[addr.atoi()] = value.atoi();
      end
      dataColl[i].id = split_using_delimiter_fn(end_idx+1,demostr,",",1,end_idx);
      $display("field-> name:%0s, data_cnt=%0d\t id:%0s\t addr_ass:%0p",dataColl[i].name,dataColl[i].data_count,dataColl[i].id,dataColl[i].hash_addr_data);
    end
    
    //make sequence
    for(int i=0;i<dataColl.size();i++) begin      
      foreach(dataColl[force_idx]) begin
      	//all input force with 'hx
        //uvm_hdl_force(dataColl[force_idx].name,'hx);		//all input force with 'hx
      end
      //uvm_hdl_force(dataColl[i].name,'h1);			//required input value force, avoid to force cheking idx
      foreach(dataColl[i].hash_addr_data[addr]) begin
        ahb_seq_execution(addr,dataColl[i].hash_addr_data[addr]);
      end
      self_check('h1,dataColl[i].id);
    end
    
  end
  
  task ahb_seq_execution(int addr, int data);
    $display("ahb_sequence_execution started: addr=%0h, data=%0h",addr,data);
  endtask 
  
  function void self_check(int exp_data, string read_data_path);
    int act_data;
    //uvm_hdl_read(read_data_path,act_data);
    //if(act_data!=exp_data) `uvm_error("data mis-match happend")
    $display("exp_data=%0h\t read_data_path=%0s",exp_data,read_data_path);
  endfunction
  
endmodule