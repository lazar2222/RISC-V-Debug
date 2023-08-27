force -freeze sim:/testbench/top/dmi_interface/address $1 0
force -freeze sim:/testbench/top/dmi_interface/read 1 0
run 100
noforce sim:/testbench/top/dmi_interface/address
noforce sim:/testbench/top/dmi_interface/read
examine -delta -1 sim:/testbench/top/dmi_interface/data
