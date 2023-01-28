// --------------------------------
// Name  Type      Size  Value     
// --------------------------------
// req   seq_item  -     @894      
//   a   integral  32    'h524858a0
// --------------------------------
// UVM_INFO sequence.sv(29) @ 0: uvm_test_top.env_o.v_seqr@@v_seq.Bseq [core_B_seq] core_B_seq: Inside Body
// --------------------------------
// Name  Type      Size  Value     
// --------------------------------
// req   seq_item  -     @910      
//   a   integral  32    'h85902ecc
// --------------------------------
// UVM_INFO testbench.sv(33) @ 0: uvm_test_top [base_test] 
// UVM_INFO testbench.sv(34) @ 0: uvm_test_top [base_test] v_seq.Aseq.a = 81
// UVM_INFO testbench.sv(35) @ 0: uvm_test_top [base_test] v_seq.Bseq.a = 47


//without uvm_do

// --------------------------------
// Name  Type      Size  Value     
// --------------------------------
// req   seq_item  -     @906      
//   a   integral  32    'hba78e456
// --------------------------------
// UVM_INFO sequence.sv(29) @ 0: uvm_test_top.env_o.agt_B.seqr_B@@Bseq [core_B_seq] core_B_seq: Inside Body
// --------------------------------
// Name  Type      Size  Value     
// --------------------------------
// req   seq_item  -     @922      
//   a   integral  32    'h85902ecc
// --------------------------------
// UVM_INFO testbench.sv(35) @ 0: uvm_test_top [base_test] 
// UVM_INFO testbench.sv(36) @ 0: uvm_test_top [base_test] v_seq.Aseq.a = 87
// UVM_INFO testbench.sv(37) @ 0: uvm_test_top [base_test] v_seq.Bseq.a = 19


//using seq_item_context

// --------------------------------
// Name  Type      Size  Value     
// --------------------------------
// req   seq_item  -     @906      
//   a   integral  32    'hba78e456
// --------------------------------
// UVM_INFO sequence.sv(29) @ 0: uvm_test_top.env_o.agt_B.seqr_B@@v_seq.Bseq [core_B_seq] core_B_seq: Inside Body
// --------------------------------
// Name  Type      Size  Value     
// --------------------------------
// req   seq_item  -     @922      
//   a   integral  32    'h85902ecc
// --------------------------------
// UVM_INFO testbench.sv(35) @ 0: uvm_test_top [base_test] 
// UVM_INFO testbench.sv(36) @ 0: uvm_test_top [base_test] v_seq.Aseq.a = 81
// UVM_INFO testbench.sv(37) @ 0: uvm_test_top [base_test] v_seq.Bseq.a = 47
