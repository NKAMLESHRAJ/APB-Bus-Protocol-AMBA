create_clock -period 10.000 -name sysclk [get_ports pclk]
set_input_delay -clock sysclk 2.000 [all_inputs]
set_input_delay -clock sysclk -min 1.000 [all_inputs]
set_output_delay -clock sysclk 0.002 [all_outputs]
set_output_delay -clock sysclk -min 0.001 [all_outputs]

