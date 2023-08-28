do wave.do
run 2900
do dmi_write.do 10 00000001
run 1600
do dmi_read.do 10 
do dmi_write.do 10 80000001
do dmi_write.do 10 00000001
run 1000
do dmi_write.do 10 40000001
do dmi_write.do 10 00000001
run 1700
do dmi_write.do 10 20000001
do dmi_write.do 10 00000001
run 1700
do dmi_write.do 10 10000001
run 1000
do dmi_write.do 10 10000003
do dmi_write.do 10 10000001
run 900
do dmi_write.do 10 00000001
run 900
do dmi_write.do 10 00000003
do dmi_write.do 10 00000001
run 1100
do dmi_write.do 10 10000001
do dmi_write.do 10 00000001
run 800
do dmi_write.do 10 00000009
run 700
do dmi_write.do 10 00000005
run 400
do dmi_write.do 10 00000005
run 300
do dmi_write.do 10 00000009
run 200
do dmi_write.do 10 00000009
run 400
do dmi_write.do 10 0000000d
run 700
do dmi_write.do 10 0000000d
do dmi_write.do 10 00000009
run 900
do dmi_write.do 10 00000003
do dmi_write.do 10 00000001
run 900
do dmi_write.do 10 40000001
run 1900
do dmi_write.do 10 80000001
run 1200
do dmi_write.do 10 40000001
run 1000
do dmi_write.do 10 20000001
run 1200
do dmi_write.do 10 00000001
run 1100
do dmi_write.do 10 40000001
do dmi_write.do 10 40000005
run 1100
do dmi_write.do 10 20000005
do dmi_write.do 10 00000001
run 2800
do dmi_write.do 10 80000001
run 1700
force -freeze sim:/testbench/top/rv_core/csr_interface/DPC_reg 32'h00000010 0
run 500
do dmi_write.do 10 40000001
run 2300
noforce sim:/testbench/top/rv_core/csr_interface/DPC_reg
