#!/bin/bash
###======================================================================================###
#   Create empty Cinder volumes
#   Created by:  Karl Vietmeier
#                karlv@storagenet.org
#  
#   Create an arbitrary number of empty Cinder volumes to test XtermIO Cinder driver
###======================================================================================###

startvols=$(cinder list | grep Xtr | wc -l|xargs)

echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = There are Currently $startvols Volumes Created in the Project"
echo "`date` = =========================================================="
echo "`date` = "
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Creating Volumes"
echo "`date` = =========================================================="
echo "`date` = "

# Wait for input
echo "`date` = Press <RETURN> to continue"
read 

# Create the volumes
for vol in $(seq -f "%03g" 1 20)
   do
     echo "`date` = cinder create 10 --display-name XtremIO_Vol${vol} --volume-type XtremIO"
     cinder create 10 --display-name XtremIO_Vol${vol} --volume-type XtremIO &> /dev/null
   done
sleep 1

echo "`date` = "
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Completed Volume Creation"
echo "`date` = =========================================================="
sleep 1
echo "`date` = cinder list"
cinder list

endvols=$(cinder list | grep Xtr | wc -l|xargs)

echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = $endvols Volumes Created" 
echo "`date` = =========================================================="
echo "`date` = "
sleep 5