//uvm_sequence#(ei_spi_sequence_item_c);
/*
//********************Task - 1***********************
1.	Figure out the total configurations of the project assigned.
Create base configuration and create child configuration.
Create base test and Child test.

2.	Create one to one mapping of test to configuration.
Override with the created configuration for each test

3.	Utilize and implement each phases in your project assign and implement following feature in suitable phases
- print the whole testbench topology
- apply a reset
- generate stimulus
- print the pass fail result
- generate the statistics on standard output file

//***************************************************


//-----------updated--------------
source : https://www.corelis.com/education/tutorials/spi-tutorial/
Mode CPOL  CPHA Clk Polarity  Clk Phase Used to Sample and/or Shift the Data
0     0     0     low     sampled on rising edge and shifted out on the falling edge
1     0     1     low     sampled on falling edge and shifted out on the rising edge
2     1     0     high    sampled on falling edge and shifted out on the rising edge
3     1     1     high    sampled on rising edge and shifted out on the falling edge

SS_ :
000 0 invalid
001 1 invalid
010 2 invalid
011 3 slave 2 selected
100 4 invalid
101 5 slave 1 selected
110 6 slave 0 selected
111 7 not any slave selected


*/