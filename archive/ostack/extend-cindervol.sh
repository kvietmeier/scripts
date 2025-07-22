#!/bin/bash
###======================================================================================###
#   Extend empty Cinder volumes
#   Created by:  Karl Vietmeier
#                karl.vietmeier@wwt.com
#  
#   Extend an arbitrary number of empty Cinder volumes to test XtermIO Cinder driver
###======================================================================================###

#startvols=$(cinder list | grep Xtr | wc -l|xargs)
startvols=$(cinder list | awk '$12 == "false" && $10 == "XtremIO" {print $2}'| wc -l|xargs)
num_vols=200
vol_type="XtremIO"
start_vol_size=10
ext_vol_size=100
vol_name=XtremIO_Vol-

echo "`date` = =========================================================="
echo "`date` = $startvols Volumes in the Project are Currently ${start_vol_size}G"
echo "`date` = =========================================================="
echo "`date` = "
echo "`date` = "
cinder list --sort name:desc
echo "`date` = "
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Extending the Volumes"
echo "`date` = =========================================================="
echo "`date` = "

# Wait for input
echo "`date` = Press <RETURN> to continue"
read 

# Extend the volumes
for volid in $(cinder list | awk '$12 == "false" && $10 == "XtremIO" {print $2}')
   do
     echo "`date` = cinder extend ${volid} ${ext_vol_size}" 
     cinder extend ${volid} ${ext_vol_size}
   done

sleep 1

echo "`date` = "
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Completed Volume Extension"
echo "`date` = =========================================================="
sleep 1
echo "`date` = "
echo "`date` = cinder list --sort name:desc"
echo "`date` = "
cinder list --sort name:desc

endvols=$(cinder list | awk '$8 == "100" && $10 == "XtremIO" {print $2}'| wc -l|xargs)

echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = $endvols Volumes Extended" 
echo "`date` = =========================================================="
echo "`date` = "
sleep 5
