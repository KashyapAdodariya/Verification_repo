class i2s_driver extends uvm_driver#(i2s_sequence_item);
  `uvm_component_utils(i2s_driver)

  //declear veriavle

  virtual i2s_interface m_vif;
  i2s_config cfg;
  i2s_sequence_item seq;
  
  extern function new(string name ="i2s_driver",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass

function i2s_driver::new(string name ="i2s_driver",uvm_component parent);
	super.new(name,parent);
  $display("i2s_driver run");
endfunction

function void i2s_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
	// get the config object using uvm_config_db 
  if(!uvm_config_db #(i2s_config)::get(this,"","i2s_config",cfg))
		`uvm_fatal("CONFIG","cannot get() cfg from uvm_config_db. Have you set() it?")
	$display("i2s_driver build_phase");
endfunction

function void i2s_driver::connect_phase(uvm_phase phase);
	m_vif=cfg.vif;
  $display("i2s_driver connect_phase");
endfunction

task i2s_driver::run_phase(uvm_phase phase);
  `uvm_info(get_type_name(),"This is i2s DRIVER run_phase",UVM_LOW)
	forever begin
		seq_item_port.get_next_item(seq);
		$display("i2s_driver run_phase");
      $display("////////////////////////////////////////////////////");
      seq.print();
            $display("////////////////////////////////////////////////////");

    seq_item_port.item_done();
	end
endtask
      
      
      
    