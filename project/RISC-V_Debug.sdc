create_clock -period "50.000000 MHz" -name clk [get_ports CLOCK_50]

create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay  -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay  -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck             3 [get_ports altera_reserved_tdo]

derive_pll_clocks

create_generated_clock -source [get_ports CLOCK_50] -name clk_dram [get_ports {DRAM_CLK}]
create_generated_clock -source [get_ports CLOCK_50] -name clk_vga  [get_ports {VGA_CLK}]

derive_clock_uncertainty

set_input_delay -max -clock clk_dram 5.96 [get_ports DRAM_DQ*]
set_input_delay -min -clock clk_dram 2.97 [get_ports DRAM_DQ*]

set_output_delay -max -clock clk_dram 1.63  [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -min -clock clk_dram -0.95 [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -max -clock clk_dram 1.65  [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]
set_output_delay -min -clock clk_dram -0.9  [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]

set_output_delay -max -clock clk_vga 0.33  [get_ports {VGA_R* VGA_G* VGA_B* VGA_BLANK_N VGA_SYNC_N VGA_HS VGA_VS}]
set_output_delay -min -clock clk_vga -1.64 [get_ports {VGA_R* VGA_G* VGA_B* VGA_BLANK_N VGA_SYNC_N VGA_HS VGA_VS}]

set_false_path -from [get_ports {KEY*}] -to *
set_false_path -from [get_ports {SW*} ] -to *
set_false_path -from * -to [get_ports {LED*}]
set_false_path -from * -to [get_ports {HEX*}]