

// Revision: 3
//-------------------------------------------------------------------------------


//------------------------SLAVE-DRIVER i2s------------------------------- 

`define edge_clk posedge
`define vif vif.slave_drv_mp
class i2s_slave_driver extends uvm_driver #(i2s_seq_item);

   
  // Virtual Interface
   
  virtual i2s_interface vif;
  
  //uvm_analysis_port#(i2c_seq_item) item_actual_port;
  uvm_blocking_put_port#(i2s_seq_item) driv2scb;
  // i2c_seq_item actual_collected;
  i2s_config cfg;
  i2s_seq_item pkt;
  `uvm_component_utils(i2s_slave_driver)
    
   
  // Constructor
   
  function new (string name, uvm_component parent);
    super.new(name, parent);
    driv2scb=new("driv2scb",this);
    `uvm_info(get_type_name(),"SLAVE_DRIVER NEW",UVM_LOW)
  endfunction : new
  
   
  // build phase
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    $display("$time=%t,Starting driver's build_phase",$time);
    
    if(!uvm_config_db#(virtual i2s_interface)::get(this,"", "vif", vif))
      `uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db.")
      if(!uvm_config_db #(i2s_config)::get(this,"","s_cfg_1d",cfg))
		`uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db.")
        `uvm_info(get_type_name(),"SLAVE_DRIVER BUILD_PHASE",UVM_LOW)
  endfunction: build_phase
  

    
  // run phase
    
   virtual task run_phase(uvm_phase phase);
    
    
    forever begin
      seq_item_port.get_next_item(req);
      send_dut(pkt);
      seq_item_port.item_done();
    end
    `uvm_info(get_type_name(),"SLAVE_DRIVER RUN_PHASE",UVM_LOW)
  endtask : run_phase
  
  
    task send_dut(i2s_seq_item pkt);
   
    begin 
      driv2scb.put(pkt); 
      
      if(cfg.mode_sel == TX) begin         
        wait(`vif.WS == 0);
        
        if(cfg.chnl_mode == MONO_LEFT || cfg.chnl_mode == STEREO && `vif.reset==1) begin
          for(int i=$size(pkt.data)-1; i >= $size(pkt.data)/2; i--) begin
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= pkt.data[i];
          end
        end
          
        else if(cfg.chnl_mode == MONO_RIGHT) begin
          for(int i=($size(pkt.data)/2)-1; i >= 0; i--) begin
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= pkt.data[i];
          end
        end
   
                    
        wait(`vif.WS == 1); 
        
        if(cfg.chnl_mode == MONO_RIGHT || cfg.chnl_mode == STEREO) begin
          for(int i=($size(pkt.data)/2)-1; i >= 0; i--) begin
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= pkt.data[i];
          end
         end 
          
        else if(cfg.chnl_mode == MONO_LEFT) begin
          for(int i=$size(pkt.data)-1; i >= $size(pkt.data)/2; i--) begin
              @(`edge_clk `vif.SCK);
              `vif.slave_drv_cb.sd_out <= pkt.data[i];
          end
        end           
        
      end
    end
  endtask

endclass : i2s_slave_driver
