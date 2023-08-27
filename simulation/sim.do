do wave.do
run 1600
do dmi_write.do 10 00000001
run 400
do dmi_write.do 10 80000001
do dmi_write.do 10 00000001
run 700
do dmi_write.do 20 00f00093
do dmi_write.do 17 01000000
run 600
do dmi_write.do 17 00221001
run 700
do dmi_write.do 4 00221001
run 500
do dmi_write.do 17 002f1001
run 900
do dmi_write.do 10 40000001
run 1800