class bit_toggle_cg_wrapper;
  covergroup bit_toggle_cg(input int bit_idx) with function sample(bit x, int aidx);
    bit_transition: coverpoint x iff (bit_idx == aidx) {
      bins zeroone = (0 => 1);
      bins onezero = (1 => 0);
    }
  endgroup

  function new(string name="bit_toggle_cg_wrapper", int aidx=0);
    bit_toggle_cg = new(aidx);
    bit_toggle_cg.set_inst_name($sformatf(name));
  endfunction

  function void sample(bit x, int aidx);
    bit_toggle_cg.sample(x, aidx);
  endfunction
endclass


class bitwise_coverage#(int WIDTH = 8);
  
  bit[WIDTH-1:0] x;
  
  bit_toggle_cg_wrapper bit_toggle_cg_w[WIDTH];
  function void sample_bit_toggle(bit[WIDTH-1:0] x);
    for(int i=0;i<WIDTH;i++) begin
      bit_toggle_cg_w[i].sample(x, i);
    end
  endfunction
  
  covergroup walking_1_cg with function sample(bit[WIDTH-1:0] x, int position);
    walking_1: coverpoint position iff (x[position]==1 && $onehot(x) ) {
      bins b[] = {[0:WIDTH-1]};
    }
  endgroup
  
  /**
   * Samples the walking-1 of a value
   * @param x - the value to be covered
   */
  function void sample_walking_1(bit[WIDTH-1:0] x);
    for(int i=0;i<WIDTH;i++)begin
      walking_1_cg.sample(x, i);
    end
  endfunction
  
   // Power-of-two couvergroup
  covergroup power_of_2_cg with function sample(bit[WIDTH-1:0] x, int position);
    power_of_two: coverpoint position iff (x[position]==1 && ((x&(~((1<<(position+1))-1)))==0)) {
      bins b[] = {[0:WIDTH-1]};
    }
  endgroup
  
  /**
   * Samples the power-of-two ranges of a value
   * @param x - the value to be covered
   */
  function void sample_power_of_2(bit[WIDTH-1:0] x);
    for(int i=0;i<WIDTH;i++) begin
      power_of_2_cg.sample(x, i);
    end
  endfunction

  // ----------------------------------
  // Alignment covergroup
  covergroup alignment_cg(input int align) with function sample(bit[WIDTH-1:0] x);
    alignment: coverpoint (x%align) {
      bins b[] = {[0:align-1]};
    }
  endgroup
  
  /**
   * Samples the alignment of a value
   * @param x - the value for which the alignment should be covered
   */
  function void sample_alignment(bit[WIDTH-1:0] x);
    alignment_cg.sample(x);
  endfunction

  // ----------------------------------
  // Duty cycle covergroup
  covergroup duty_cycle_cg with function sample(int duty_cycle);
    duty_cycle_p: coverpoint (duty_cycle) {
      bins b[10] = {[0:99]};
    }
  endgroup
  
  /**
   * Samples the duty cycle of a value
   * @param x - the value to be covered
   */
  function void sample_duty_cycle(bit[15:0] x);
    int unsigned count = $countones(x), duty_cycle=0;
    duty_cycle = ((count * 100 )/16);
    duty_cycle_cg.sample(duty_cycle);
  endfunction

  // ----------------------------------
  // Odd parity covergroup
  covergroup odd_parity_cg(input int bitwidth) with function sample(int aparity);
    parity: coverpoint (aparity) {
      bins b[] = {[1:bitwidth]} with (item % 2 == 1);
    }
  endgroup
  
  /**
   * Samples the odd parity of a value
   * @param x - the value to be covered by odd parity
   */
  function void sample_odd_parity(bit[WIDTH-1:0] x);
    int unsigned count = $countones(x);
    odd_parity_cg.sample(count);
  endfunction

  // ----------------------------------
  // Even parity covergroup
  covergroup even_parity_cg(input int bitwidth) with function sample(int aparity);
    parity: coverpoint (aparity) {
      bins b[] = {[1:bitwidth]} with (item % 2 == 0);
    }
  endgroup
  
  /**
   * Samples the even parity of a value
   * @param x - the value to be covered by even parity
   */
  function void sample_even_parity(bit[WIDTH-1:0] x);
    int unsigned count = $countones(x);
    even_parity_cg.sample(count);
  endfunction

  // ----------------------------------
  // Consecutive bits covergroup
  covergroup consecutive_bits_cg(input int limit) with function sample(int nof_1_bits, int nof_groups);
    nof_consecutive_bits: coverpoint (nof_1_bits) {
      bins b[] = {[0:limit]};
    }
    nof_bit_groups: coverpoint (nof_groups) {
      bins b[] = {[0:WIDTH/2+WIDTH%2]};
    }
  endgroup
  
  /**
   * Samples number of consecutive bits in a stream, over a WIDTH-bits window
   * @param x - the value you want to sample; depending on implementation it could also be a list of bits
   */
  function void sample_consecutive_bits(bit[WIDTH-1:0] x);
    int unsigned count = 0, nof_groups = 0;
    int unsigned counta[$];
    if (x == 0 || x == {WIDTH{1'b1}}) begin
      consecutive_bits_cg.sample((x == 0)?0:WIDTH, (x == 0)?0:1);
      return;
    end
    for(int i=0; i<WIDTH; i++) begin
      count += x[i];
      if ((x[i] == 0 || (i == (WIDTH-1))) && count != 0) begin
        nof_groups += 1;
        counta.push_back(count);
        count = 0;
      end
    end
    foreach(counta[i])
      consecutive_bits_cg.sample(counta[i], counta.size());
  endfunction

  // ----------------------------------
  // Masking covergroup
  covergroup masking_cg with function sample(bit[WIDTH-1:0] x, int position, bit amasking_result);
    mask: coverpoint position iff (x == 0 || x == {WIDTH{1'b1}} || ($onehot(x) && x[position-1] == 1) ) {
      bins zero = {0};
      bins w1[] = {[1:WIDTH]};
      bins all1 = {WIDTH + 1};
    }
    masking_result : coverpoint amasking_result {
      bins no_match = {0};
      bins match = {1};
    }
    mask_vs_result : cross mask, masking_result {
      ignore_bins all_pass = binsof(mask) intersect {0} && binsof(masking_result) intersect {0};
    }
  endgroup
  
  /**
   * Samples the mask and the masking result
   * @param x - the value of the mask to be covered
   * @param masking_result - the masking result
   */
  function void sample_mask(bit[WIDTH-1:0] x, bit masking_result);
    if (x == 0) begin
      masking_cg.sample(0, 0, masking_result);
      return;
    end
    if (x == {WIDTH{1'b1}}) begin
      masking_cg.sample({WIDTH{1'b1}}, WIDTH + 1, masking_result);
      return;
    end
    for(int i=0;i<WIDTH;i++)begin
      masking_cg.sample(x, (i+1), masking_result);
    end
  endfunction

  function new(string name="bitwise_coverage_template", bit [WIDTH-1:0] data);
    this.x = data;
    foreach(bit_toggle_cg_w[i])  bit_toggle_cg_w[i] = new($sformatf("%s.bit_toggle_cg_%1d", name, i));
    walking_1_cg = new();
    walking_1_cg.set_inst_name($sformatf("%s.walking_1_cg", name));
    power_of_2_cg = new();
    power_of_2_cg.set_inst_name($sformatf("%s.power_of_2_cg", name));
    alignment_cg = new(4);
    alignment_cg.set_inst_name($sformatf("%s.alignment_cg", name));
    duty_cycle_cg = new();
    duty_cycle_cg.set_inst_name($sformatf("%s.duty_cycle_cg", name));
    odd_parity_cg = new(8);
    odd_parity_cg.set_inst_name($sformatf("%s.odd_parity_cg", name));
    even_parity_cg = new(8);
    even_parity_cg.set_inst_name($sformatf("%s.even_parity_cg", name));
    consecutive_bits_cg = new(8);
    consecutive_bits_cg.set_inst_name($sformatf("%s.consecutive_bits_cg", name));
    masking_cg = new();
    masking_cg.set_inst_name($sformatf("%s.masking_cg", name));
  endfunction: new
 
endclass: bitwise_coverage



module test;
  bit clk;
  bit [7:0] data = 0;
  int i=0;
  bitwise_coverage bitwise_coverage_c;
  
  always #1 clk = ~clk;
  
  initial begin
    bitwise_coverage_c = new(.data(data));
  end
  
//   always @(posedge clk ) begin
//     //data = $urandom;
//     data = i++;
//     $display("data = %0h at clk = %0h ---> time: %0t",data,clk,$time);
//   end
//   initial begin
//     data = 'b01;
//     bitwise_coverage_c.sample_walking_1(data);
//     data = 'b10;
//     bitwise_coverage_c.sample_walking_1(data);
//     data = 'b100;
//     bitwise_coverage_c.sample_walking_1(data);
//     data = 'b1000;
//     bitwise_coverage_c.sample_walking_1(data);
//     data = 'b10000;
//     bitwise_coverage_c.sample_walking_1(data);
//     data = 'b100000;
//     bitwise_coverage_c.sample_walking_1(data);
//     data = 'b1000000;
//     bitwise_coverage_c.sample_walking_1(data);
//     data = 'b10000000;
//     bitwise_coverage_c.sample_walking_1(data);
//   end
  
  initial begin
    repeat(4) begin
      @(posedge clk);
      data++;
    end
    repeat(20000) begin
      //@(posedge clk);
      data = $urandom;
    end
  end
  
  
  always @(/*posedge clk or negedge clk*/*) begin
    // bitwise_coverage_c.bit_toggle_cg_w.sample_bit_toggle(data);
    bitwise_coverage_c.sample_walking_1(data);
    bitwise_coverage_c.sample_power_of_2(data);
    bitwise_coverage_c.sample_alignment(data);
    bitwise_coverage_c.sample_duty_cycle(data);
    bitwise_coverage_c.sample_odd_parity(data);
    bitwise_coverage_c.sample_even_parity(data);
    bitwise_coverage_c.sample_consecutive_bits(data);
    bitwise_coverage_c.sample_mask(data,0);
  end
  
  initial #2000000 $finish;
  
  final begin
    $display ("\nCoverage.walking_1_cg = %0.4f",  bitwise_coverage_c.walking_1_cg.get_inst_coverage());
    $display ("\nCoverage.power_of_2_cg = %0.4f",  bitwise_coverage_c.power_of_2_cg.get_inst_coverage());
    $display ("\nCoverage.alignment_cg = %0.4f",  bitwise_coverage_c.alignment_cg.get_inst_coverage());
    $display ("\nCoverage.duty_cycle_cg = %0.4f",  bitwise_coverage_c.duty_cycle_cg.get_inst_coverage());
    $display ("\nCoverage.odd_parity_cg = %0.4f",  bitwise_coverage_c.odd_parity_cg.get_inst_coverage());
    $display ("\nCoverage.even_parity_cg = %0.4f",  bitwise_coverage_c.even_parity_cg.get_inst_coverage());
    $display ("\nCoverage.consecutive_bits_cg = %0.4f",  bitwise_coverage_c.consecutive_bits_cg.get_inst_coverage());
    $display ("\nCoverage.masking_cg = %0.4f",  bitwise_coverage_c.masking_cg.get_inst_coverage());
  end
  
endmodule: test



// class bitwise_coverage_template#(int WIDTH = 8) extends uvm_component;
//   `uvm_component_utils(bitwise_coverage_template)

//   /**
//    * Bit-toggling covergroup wrapper class
//    */
//   class bit_toggle_cg_wrapper;
//     covergroup bit_toggle_cg(input int bit_idx) with function sample(bit x, int aidx);
//       bit_transition: coverpoint x iff (bit_idx == aidx) {
//         bins zeroone = (0 => 1);
//         bins onezero = (1 => 0);
//       }
//     endgroup

//     function new(string name="bit_toggle_cg_wrapper", int aidx=0);
//       bit_toggle_cg = new(aidx);
//       bit_toggle_cg.set_inst_name(name);
//     endfunction

//     function void sample(bit x, int aidx);
//       bit_toggle_cg.sample(x, aidx);
//     endfunction
//   endclass
  
//   // the array of coverage groups, one covergroup per bit
//   bit_toggle_cg_wrapper bit_toggle_cg_w[WIDTH];
  
//   /**
//    * Samples the bit toggling of a value
//    * @param x - the value to be covered
//    */
//   function void sample_bit_toggle(bit[WIDTH-1:0] x);
//     for(int i=0;i<WIDTH;i++) begin
//       bit_toggle_cg_w[i].sample(x, i);
//     end
//   endfunction

//   // ----------------------------------
//   // Walking-1 covergroup
//   covergroup walking_1_cg with function sample(bit[WIDTH-1:0] x, int position);
//     walking_1: coverpoint position iff (x[position]==1 && $onehot(x) ) {
//       bins b[] = {[0:WIDTH-1]};
//     }
//   endgroup
  
//   /**
//    * Samples the walking-1 of a value
//    * @param x - the value to be covered
//    */
//   function void sample_walking_1(bit[WIDTH-1:0] x);
//     for(int i=0;i<WIDTH;i++)begin
//       walking_1_cg.sample(x, i);
//     end
//   endfunction

//   // ----------------------------------
//   // Power-of-two couvergroup
//   covergroup power_of_2_cg with function sample(bit[WIDTH-1:0] x, int position);
//     power_of_two: coverpoint position iff (x[position]==1 && ((x&(~((1<<(position+1))-1)))==0)) {
//       bins b[] = {[0:WIDTH-1]};
//     }
//   endgroup
  
//   /**
//    * Samples the power-of-two ranges of a value
//    * @param x - the value to be covered
//    */
//   function void sample_power_of_2(bit[WIDTH-1:0] x);
//     for(int i=0;i<WIDTH;i++) begin
//       power_of_2_cg.sample(x, i);
//     end
//   endfunction

//   // ----------------------------------
//   // Alignment covergroup
//   covergroup alignment_cg(input int align) with function sample(bit[WIDTH-1:0] x);
//     alignment: coverpoint (x%align) {
//       bins b[] = {[0:align-1]};
//     }
//   endgroup
  
//   /**
//    * Samples the alignment of a value
//    * @param x - the value for which the alignment should be covered
//    */
//   function void sample_alignment(bit[WIDTH-1:0] x);
//     alignment_cg.sample(x);
//   endfunction

//   // ----------------------------------
//   // Duty cycle covergroup
//   covergroup duty_cycle_cg with function sample(int duty_cycle);
//     duty_cycle: coverpoint (duty_cycle) {
//       bins b[10] = {[0:99]};
//     }
//   endgroup
  
//   /**
//    * Samples the duty cycle of a value
//    * @param x - the value to be covered
//    */
//   function void sample_duty_cycle(bit[15:0] x);
//     int unsigned count = $countones(x), duty_cycle=50;
//     duty_cycle = ((count * 100 )/16);
//     duty_cycle_cg.sample(duty_cycle);
//   endfunction

//   // ----------------------------------
//   // Odd parity covergroup
//   covergroup odd_parity_cg(input int bitwidth) with function sample(int aparity);
//     parity: coverpoint (aparity) {
//       bins b[] = {[1:bitwidth]} with (item % 2 == 1);
//     }
//   endgroup
  
//   /**
//    * Samples the odd parity of a value
//    * @param x - the value to be covered by odd parity
//    */
//   function void sample_odd_parity(bit[WIDTH-1:0] x);
//     int unsigned count = $countones(x);
//     odd_parity_cg.sample(count);
//   endfunction

//   // ----------------------------------
//   // Even parity covergroup
//   covergroup even_parity_cg(input int bitwidth) with function sample(int aparity);
//     parity: coverpoint (aparity) {
//       bins b[] = {[1:bitwidth]} with (item % 2 == 0);
//     }
//   endgroup
  
//   /**
//    * Samples the even parity of a value
//    * @param x - the value to be covered by even parity
//    */
//   function void sample_even_parity(bit[WIDTH-1:0] x);
//     int unsigned count = $countones(x);
//     even_parity_cg.sample(count);
//   endfunction

//   // ----------------------------------
//   // Consecutive bits covergroup
//   covergroup consecutive_bits_cg(input int limit) with function sample(int nof_1_bits, int nof_groups);
//     nof_consecutive_bits: coverpoint (nof_1_bits) {
//       bins b[] = {[0:limit]};
//     }
//     nof_bit_groups: coverpoint (nof_groups) {
//       bins b[] = {[0:WIDTH/2+WIDTH%2]};
//     }
//   endgroup
  
//   /**
//    * Samples number of consecutive bits in a stream, over a WIDTH-bits window
//    * @param x - the value you want to sample; depending on implementation it could also be a list of bits
//    */
//   function void sample_consecutive_bits(bit[WIDTH-1:0] x);
//     int unsigned count = 0, nof_groups = 0;
//     int unsigned counta[$];
//     if (x == 0 || x == {WIDTH{1'b1}}) begin
//       consecutive_bits_cg.sample((x == 0)?0:WIDTH, (x == 0)?0:1);
//       return;
//     end
//     for(int i=0; i<WIDTH; i++) begin
//       count += x[i];
//       if ((x[i] == 0 || (i == (WIDTH-1))) && count != 0) begin
//         nof_groups += 1;
//         counta.push_back(count);
//         count = 0;
//       end
//     end
//     foreach(counta[i])
//       consecutive_bits_cg.sample(counta[i], counta.size());
//   endfunction

//   // ----------------------------------
//   // Masking covergroup
//   covergroup masking_cg with function sample(bit[WIDTH-1:0] x, int position, bit amasking_result);
//     mask: coverpoint position iff (x == 0 || x == {WIDTH{1'b1}} || ($onehot(x) && x[position-1] == 1) ) {
//       bins zero = {0};
//       bins w1[] = {[1:WIDTH]};
//       bins all1 = {WIDTH + 1};
//     }
//     masking_result : coverpoint amasking_result {
//       bins no_match = {0};
//       bins match = {1};
//     }
//     mask_vs_result : cross mask, masking_result {
//       ignore_bins all_pass = binsof(mask) intersect {0} && binsof(masking_result) intersect {0};
//     }
//   endgroup
  
//   /**
//    * Samples the mask and the masking result
//    * @param x - the value of the mask to be covered
//    * @param masking_result - the masking result
//    */
//   function void sample_mask(bit[WIDTH-1:0] x, bit masking_result);
//     if (x == 0) begin
//       masking_cg.sample(0, 0, masking_result);
//       return;
//     end
//     if (x == {WIDTH{1'b1}}) begin
//       masking_cg.sample({WIDTH{1'b1}}, WIDTH + 1, masking_result);
//       return;
//     end
//     for(int i=0;i<WIDTH;i++)begin
//       masking_cg.sample(x, (i+1), masking_result);
//     end
//   endfunction

//   /**
//    * Class constructor where the covergroup-s are initialized
//    * @param name - name of the class
//    * @param parent - parent component of the class
//    */
//   function new(string name="bitwise_coverage_template", uvm_component parent=null);
//     super.new(name, parent);
//     foreach(bit_toggle_cg_w[i])
//       bit_toggle_cg_w[i] = new($sformatf("%s.bit_toggle_cg_%1d", get_full_name(), i), i);
//     walking_1_cg = new();
//     walking_1_cg.set_inst_name($sformatf("%s.walking_1_cg", get_full_name()));
//     power_of_2_cg = new();
//     power_of_2_cg.set_inst_name($sformatf("%s.power_of_2_cg", get_full_name()));
//     alignment_cg = new(4);
//     alignment_cg.set_inst_name($sformatf("%s.alignment_cg", get_full_name()));
//     duty_cycle_cg = new();
//     duty_cycle_cg.set_inst_name($sformatf("%s.duty_cycle_cg", get_full_name()));
//     odd_parity_cg = new(8);
//     odd_parity_cg.set_inst_name($sformatf("%s.odd_parity_cg", get_full_name()));
//     even_parity_cg = new(8);
//     even_parity_cg.set_inst_name($sformatf("%s.even_parity_cg", get_full_name()));
//     consecutive_bits_cg = new(8);
//     consecutive_bits_cg.set_inst_name($sformatf("%s.consecutive_bits_cg", get_full_name()));
//     masking_cg = new();
//     masking_cg.set_inst_name($sformatf("%s.masking_cg", get_full_name()));
//   endfunction
// endclass