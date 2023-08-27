force -freeze sim:/testbench/top/dmi_interface/address $1 0
force -freeze sim:/testbench/top/dmi_interface/data $2 0
force -freeze sim:/testbench/top/dmi_interface/write 1 0
run 100
noforce sim:/testbench/top/dmi_interface/address
noforce sim:/testbench/top/dmi_interface/data
noforce sim:/testbench/top/dmi_interface/write
