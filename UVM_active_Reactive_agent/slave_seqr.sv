class slave_seqr_h extends uvm_sequencer#(sequence_item_h);
  `uvm_component_utils(slave_seqr_h)
  //slave_seq_h slv_seq;
  slave_mem_h slave_mem;
 // uvm_analysis_export #(sequence_item_h) m_request_export; 
  uvm_tlm_analysis_fifo #(sequence_item_h) m_request_fifo;
  
  function new(string name = "slave_seqr_h", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(),"slave_seqr_h new call",UVM_LOW)
    m_request_fifo = new("m_request_fifo", this); 
    //m_request_export = new("m_request_export", this);
  endfunction: new
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //m_request_export.connect(m_request_fifo.analysis_export);
  endfunction: connect_phase
  
endclass:slave_seqr_h

