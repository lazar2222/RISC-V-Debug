create_clock -period "50.000000 MHz" -name clk [get_ports clock_50]

create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay  -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay  -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck             3 [get_ports altera_reserved_tdo]

derive_pll_clocks

derive_clock_uncertainty

set_false_path -from [get_ports {key*}] -to *
set_false_path -from [get_ports {sw*} ] -to *
set_false_path -from * -to [get_ports {led*}]
set_false_path -from * -to [get_ports {hex*}]

set_false_path -from [get_ports {tck}] -to *
set_false_path -from [get_ports {tms} ] -to *
set_false_path -from [get_ports {tdi}] -to *
set_false_path -from * -to [get_ports {tdo}]

set_false_path -from [get_ports {n_trst} ] -to *
set_false_path -from [get_ports {n_rst} ] -to *
set_false_path -from * -to [get_ports {vt_ref}]