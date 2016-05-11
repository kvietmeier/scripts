#!/bin/bash
##======================================================================================###
#   Delete a group of created volumes
#   Created by:  Karl Vietmeier
#                karlv@storagenet.org
#  
#   Delete the Cinder volumes to test XtermIO Cinder driver
###======================================================================================###


startvols=$(cinder list | awk '$4 == "available" {print $2}' | wc -l|xargs)
num_vols=200
vol_type="XtremIO"
vol_size=10
vol_name=XtremIO_Vol-


echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Removing $startvols Volumes "
echo "`date` = =========================================================="
echo "`date` = "
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Deleting Volumes"
echo "`date` = =========================================================="
echo "`date` = "

# Wait for input
echo "`date` = Press <RETURN> to continue"
read 

# Delete the volumes - only those in available state
for volid in $(cinder list | awk '$4 == "available" {print $2}')
   do
     echo "`date` "=" cinder delete $volid"
     cinder delete $volid & >/dev/null
   done

endvols=$(cinder list | awk '$4 == "deleting" {print $2}' | wc -l|xargs)

sleep 1
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Completed Volume Deletion"
echo "`date` = =========================================================="
echo "`date` = "
echo "`date` = cinder list"
echo "`date` = "

while [ $endvols -gt 0 ]
    do
        endvols=$(cinder list | awk '$4 == "deleting" {print $2}' | wc -l|xargs)
        echo "`date` = $endvols are left"
    done

echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = $endvols Volumes Remain" 
echo "`date` = =========================================================="
echo "`date` = "
cinder list
echo "`date` = "
