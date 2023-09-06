restart -f
run 1600
do dmi_write.do 10 00000001
run 400
do dmi_write.do 10 80000001
do dmi_write.do 10 00000001
do dmi_write.do 20 00102083
do dmi_write.do 4 53729
do dmi_write.do 17 $1
run 900
echo $1
pause