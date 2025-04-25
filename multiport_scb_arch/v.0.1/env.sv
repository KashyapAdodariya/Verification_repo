


class env extends uvm_env;
  
  monitor mon[3];
  scb_wrapper scb_wrap;
  
  `uvm_component_utils(env)
  
  function new(string name = "env", uvm_component parent);
    super.new(name, parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `print("ENV: BUILD_PHASE CALLED")
    for(int i=0;i<3;i++) begin
      mon[i] = monitor::type_id::create($sformatf("mon[%0d]",i), this);
      mon[i].a = 'hF - i;
    end
    scb_wrap = scb_wrapper::type_id::create("scb_warp", this);
  endfunction: build_phase
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `print("ENV: RUN_PHASE CALLED")
  endtask: run_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `print("ENV: CONNECT_PHASE CALLED")
    for(int i=0; i<3; i++) begin
      mon[i].analysis_port.connect(scb_wrap.subscr[i].analysis_export);
    end
  endfunction: connect_phase
  
endclass: env