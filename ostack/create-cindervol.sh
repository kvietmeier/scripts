#!/bin/bash
###======================================================================================###
#   Create empty Cinder volumes
#   Created by:  Karl Vietmeier
#                karl.vietmeier@wwt.com
#  
#   Create an arbitrary number of empty Cinder volumes to test XtermIO Cinder driver
###======================================================================================###

startvols=$(cinder list | grep Xtr | wc -l|xargs)
num_vols=200
vol_type="XtremIO"
vol_size=10
vol_name=XtremIO_Vol-

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
for vol in $(seq -f "%03g" 1 200)
   do
     echo "`date` = cinder create 10 --display-name ${vol_name}${vol} --volume-type $vol_type"
     cinder create 10 --display-name ${vol_name}${vol} --volume-type $vol_type &> /dev/null
   done
sleep 1

echo "`date` = "
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Completed Volume Creation"
echo "`date` = =========================================================="
sleep 1
echo "`date` = cinder list --sort name:desc"
cinder list --sort name:desc

endvols=$(cinder list | grep Xtr | wc -l|xargs)

echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = $endvols Volumes Created" 
echo "`date` = =========================================================="
echo "`date` = "
sleep 5