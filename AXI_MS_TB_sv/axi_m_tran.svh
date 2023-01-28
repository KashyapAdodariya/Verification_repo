//================= transaction class constraints =================

//--- FIRST DEFINE CONSTRAINT FOR SIZE OF DIFFERENT WRITE DATA CHANNEL ENTITY ---

constraint transaction::data_size_c{
    TDATA.size==ATLEN+1;
    ATADDR inside {[0:255]};
};

//--- THEN CONSTRAINT FOR AW/ARSIZE SIGNAL WHICH ON BASES OF WIDTH OF DATA BUS WHICH IS PARAMATERIZE ---
                      
constraint transaction::atsize_c{
  if (WIDTH/8==1)   ATSIZE==0; 
  else if(WIDTH/8==2)   ATSIZE inside {[0:1]}; 
  else if(WIDTH/8==4)   ATSIZE inside {[2:2]};
  else if(WIDTH/8==8)   ATSIZE inside {[0:3]};
  else if(WIDTH/8==16)  ATSIZE inside {[0:4]}; 
  else if(WIDTH/8==32)  ATSIZE inside {[0:5]};  
  else if(WIDTH/8==64)  ATSIZE inside {[0:6]}; 
  else if(WIDTH/8==128) ATSIZE inside {[0:7]};   
};

// --- DEFINE SIZE OF WSTRB LENGTH ---
constraint transaction::wstrb_size_c{
  WSTRB.size()==ATLEN+1;
}

// --- WRITE CONSTRAINT FOR WSTRB --
constraint transaction::wstrb_value_c{
  if(ATBURST==FIXED || ATBURST==INCR) {
    if(ATSIZE==0) 
      foreach(WSTRB[i]) WSTRB[i]==4'b0001;
    else if(ATSIZE==1) 
      foreach(WSTRB[i]) WSTRB[i]==4'b0011;
    else if(ATSIZE==2) 
     foreach(WSTRB[i]) WSTRB[i]==4'b1111;
  } 
  
   /* else  if(ATBURST==INCR) {
    if(ATSIZE==0) 
      foreach(WSTRB[i]) WSTRB[i]==4'b0001<<(i%4);
    
    else if(ATSIZE==1) 
      foreach(WSTRB[i]) if(i%2==1) WSTRB[i]==4'b1100; else WSTRB[i]==4'b0011;
    
    else if(ATSIZE==2) 
      foreach(WSTRB[i]) WSTRB[i]==4'b1111;
    }*/
   
 
}
  

  

 
//--- DEFINE CONSTRAINT FOT ATBURST SIGNAL ---

constraint transaction::atburst_c{
  ATBURST inside {1};}
    

//================= transaction class functions ====================

//--- print function will print all values of transaction class ---
function void transaction::print_f();
  string s1;
  if(rw==0)
    begin
      s1 = "read class";
    end
  else
    begin
      s1 = "write class";
    end
  $display("//////////////////////////////////////////////////////////////////////////////////////");
  $display("                               %0s                                    ",s1);
  $display("//////////////////////////////////////////////////////////////////////////////////////");
  
  $display("ATADDR = %h,\nATID=%h,\nATLEN=%h,\nATSIZE=%h,\nATBURST=%0s,\nATLOCK=%s,\nATCACHE=%h,\nATPROT=%h\n",ATADDR,ATID,ATLEN,ATSIZE,ATBURST.name(),ATLOCK.name(),ATCACHE,ATPROT);

  foreach(TDATA[i])
    begin
      $display("TDATA[%0d]=%0h",i,TDATA[i]);
    end

  foreach(WSTRB[i])
    begin
      $display("WSTRB[%0d]=%0h",i,WSTRB[i]);
    end

endfunction

// --- copy function copy data of class into input packet of argunment ---
function void transaction::copy_f(ref trn_item_t tr);
  string s1;
  tr = new();
  if(rw==1)
    begin
      s1 = "read class";
    end
  else
    begin
      s1 = "write class";
    end
  $display("\n--- copy operation start in %s class... ---",s1);
 // tr = new();
  tr.ATADDR = this.ATADDR;
  tr.ATID = this.ATID;
  tr.ATLEN=this.ATLEN;
  tr.ATSIZE=this.ATSIZE;
  tr.ATBURST=this.ATBURST;
  tr.ATLOCK=this.ATLOCK;
  tr.ATCACHE=this.ATCACHE;
  tr.ATPROT=this.ATPROT;
  tr.TDATA=this.TDATA;
  $display("--- copy operation completed in %s class... ---\n",s1);
endfunction

//--- compare function compare data of class with input packet of argunment ---

function bit transaction::compare_f(trn_item_t tr);
  string s1;
  bit out = 1;
  
  if(rw==1)
    begin
      s1 = "read class";
    end
  else
    begin
      s1 = "write class";
    end
  
  $display("\n--- compare operation start in %s class... ---",s1);
  if(tr == null)
    begin
      $error("--- NULL PACKET TRY TO COMPARE WITH CLASS !!! ---");
      //error_count::error_cnt++;
      //error_count::call_finish();
    end
  else
    begin
      if(tr.ATADDR != this.ATADDR)
        begin
          out = 0;
          $display("ATADDR NOT MATCH");
        end
      if(tr.ATID != this.ATID)
        begin
          out = 0;
          $display("ATID NOT MATCH");
        end
      if(tr.ATLEN != this.ATLEN)
        begin
          out = 0;
          $display("ATLEN NOT MATCH");
        end
      if(tr.ATSIZE != this.ATSIZE)
        begin
          out = 0;
          $display("ATSIZE NOT MATCH");
        end
      if(tr.ATBURST != this.ATBURST)
        begin
          out = 0;
          $display("ATBURST NOT MATCH");
        end
      if(tr.ATLOCK != this.ATLOCK)
        begin
          out = 0;
          $display("ADLOCK NOT MATCH");
        end
      if(tr.ATCACHE != this.ATCACHE)
        begin
          out = 0;
          $display("ADCACHE NOT MATCH");
        end
      if(tr.ATPROT != this.ATPROT)
        begin
          out = 0;
          $display("ADPROT NOT MATCH");
        end
      foreach(tr.TDATA[i])
        begin
          if(tr.TDATA[i] != this.TDATA[i])
            begin
              out = 0;
              $display("TDATA[%0d] NOT MATCH",i);
            end
        end
      $display("\n--- compare operation completed in %s class... ---",s1);
      return out;
    end
endfunction
