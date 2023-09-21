restart -f
run 1600
do dmi_write.do 10 00000001
do dmi_write.do 38 $1
do dmi_write.do 39 $2
run 500
do dmi_read.do  3c
run 500
do dmi_write.do 3c $3
run 500
echo $1
echo $2
pause