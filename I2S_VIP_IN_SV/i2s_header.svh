`define size 16
`include "i2s_message_logger.sv"
`include "i2s_config.sv"
`include "i2s_transaction.sv"
`include "i2s_interface.sv"
`include "i2s_generator.sv"
`include "i2s_master_driver.sv"
`include "i2s_monitor.sv"
`include "i2s_scoreboard.sv"
`include "i2s_master_agent.sv"
`include "i2s_slave_driver.sv"
`include "i2s_slave_agent.sv"
`include "i2s_scoreboard_c.sv"
`include "i2s_env.sv"

`ifdef test1
`include "alteranate_data_stream_mono_left_mode.sv"
`elsif test2
`include "alteranate_data_stream_mono_right_mode.sv"
`elsif  test3
`include "alteranate_data_stream_stereo_mode.sv"
`elsif  test4
`include "change_word_len.sv"
`elsif  test5
`include "slave_tx_twos_stereo.sv"
`elsif test6
`include "mono_left_mode.sv"
`elsif test7
`include "mono_right_mode.sv"
`elsif test8
`include "stereo_mode.sv"
`elsif test9
`include "slave_tx_master_rx.sv"
`elsif test10
`include "master_tx_normal_mono_left.sv"
`elsif test11
`include "master_tx_normal_mono_right.sv"
`elsif test12
`include "master_tx_normal_stereo.sv"
`elsif  test13
`include "master_tx_twos_mono_left.sv"
`elsif test14
`include "master_tx_twos_mono_right.sv"
`elsif  test15
`include "master_tx_twos_stereo.sv"
`elsif  test16
`include "controller_mode.sv"
`elsif test17
`include "slave_tx_normal_stereo.sv"
/*
`elsif  test20
`include "master_tx_wlen_greaterthen_slave_mono_right.sv"
`elsif  test21
`include "master_tx_wlen_greaterthen_slave_stereo.sv"
`elsif  test22
`include "mono_left_mode.sv"
`elsif  test23
`include "mono_right_mode.sv"
`elsif  test24
`include "rx_word_len_gr_tx_word_len.sv"
`elsif test25
`include "slave_tx_normal_mono_left.sv"
`elsif  test26
`include "slave_tx_normal_mono_right.sv"
`elsif  test27
`include "slave_tx_normal_stereo.sv"
`elsif  test28
`include "slave_tx_twos_mono_left.sv"
`elsif test29
`include "slave_tx_twos_mono_right.sv"
*/
`endif




