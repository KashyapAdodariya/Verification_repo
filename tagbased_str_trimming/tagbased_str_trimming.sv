module StringToVariables;
  int address;
  int data;
  int hsize;

  initial begin
    string input_str = "address=2345;;hsize=1\n";
    string idstr,valuestr;
    int st = 0;
    int ed = 0;
    int strlength = input_str.len();
    int address = 0,hsize = 0;
    
    while(ed != strlength) begin
      if(input_str[ed] != ";" || input_str[ed] != "\n") begin
        while(input_str[ed] != "=" && input_str[ed] != ";" && input_str[ed] != "\n") begin
          idstr = {idstr,input_str[ed]};
          ed++;
          $display("idstr chk in 19 %0s",idstr);
        end
        if(input_str[ed] == "=")begin
          ed++;
          while(input_str[ed] != ";" && input_str[ed] != "\n") begin
            valuestr = {valuestr,input_str[ed]};
            ed++;
            $display("valuestr chk in 26 %0s",valuestr);
          end
        end
        else $display("Not fine value argument");
        if(input_str[ed] == ";" || input_str[ed] == "\n") begin
          if(idstr=="address") address = valuestr.atohex();
          if(idstr=="data") data = valuestr.atohex();
          if(idstr=="hsize") hsize = valuestr.atohex();
          $display("check value = %0h -> %0h -> %0h",address,data,hsize);
        end
        ed++;
        idstr = "";
        valuestr = "";
      end
      else begin
        $display("next variable");
      end
      //if(ed==strlength) break;
    end
  
  end
endmodule
