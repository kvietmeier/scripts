#!/bin/bash
# Create Nova instances based on existing volumes of type "XtremIO"


echo "`date` = "
echo "`date` = ====================================================="
echo "`date` = There are Currently no Volumes Created in the Project"
echo "`date` = ====================================================="
echo "`date` = "
cinder list
echo "`date` = "
echo "`date` = Creating 500 Volumes"
echo "`date` = "

# wait for input
echo "`date` = Press <RETURN> to continue"
read 

for vol in {001..20}
   do
     echo "`date` = cinder create 10 --display-name XtremIO_Vol${vol} --volume-type XtremIO"
     #echo "...."
     #cinder create 10 --display-name XtremIO_Vol${vol} --volume-type XtremIO &> /dev/null
   done
sleep 1
echo "`date` = "
echo "`date` = "
echo "`date` = Completed Volume Creation"
sleep 1
echo "`date` = cinder list"
cinder list
echo "`date` = "
echo "`date` = $(cinder list | grep Xtr | wc -l) Volumes Created" 
echo "`date` = "
sleep 5