`define MON_IF axi_vif

class axi_m_mon;
  
  //creating virtual interface handle
  virtual axi_intf axi_vif;
  
  transaction m_pkt ;
  int x[$];
  int z = 0 ;
  int y = 0 ;
  
  task run;
    axi_vif=axi_m_config::vif;
    $display("---------monitor running--------------");
    
    fork
      begin
        forever begin
          wait(`MON_IF.ARVALID) begin
            @(posedge `MON_IF.ACLK) ;
            x[z]=axi_vif.ARLEN;
            z++;
            @(posedge `MON_IF.ACLK) ;
            @(posedge `MON_IF.ACLK) ;
          end
        end
      end
        
      begin
        forever begin
          if(y < x.size+1) begin
          m_pkt=new;
          //wait(`MON_IF.RVALID);
          for(int i=0; i<x[y]+1; i++) begin
            $display(x);
            $display("inside monitor forloop");
            //@(`MON_IF.RVALID);
            wait(`MON_IF.RVALID)
            begin
            //@(posedge `MON_IF.RVALID); 
              $display("RVALID is high");
              wait(m_pkt.TDATA[i-1]!=`MON_IF.RDATA);
              m_pkt.TDATA=new[m_pkt.TDATA.size+1](m_pkt.TDATA);
              m_pkt.TDATA[i]   =   `MON_IF.RDATA;
              $display("mon ----- mon %h",m_pkt.TDATA[i]);
              $display("RDATA MON -------------------%h",`MON_IF.RDATA);
              $display("----------- y = %d---------",y);  
              @(posedge `MON_IF.ACLK); 
            end
          end
          axi_m_config::mon2score_mbox.put(m_pkt);
          y++;
            if(y > x.size) begin break; end
          $display("mon ----- mon put %p",m_pkt.TDATA);
          $display("===monitor put packet into mailbox===");
          end
          //axi_m_config::mon2score_mbox.put(m_pkt);
        end
      end // fork bein end
    join
  endtask
endclass