#!/bin/bash
###======================================================================================###
#   Delete Glance volumes 
#   Created by:  Karl Vietmeier
#                karlv@storagenet.org
#  
#   Clean Up script
###======================================================================================###

## Vars
startvols=$(cinder list | grep Xtr | wc -l|xargs)

num_vols=20
image_id=811fed1f-7d13-4da2-900e-f33e5ceff682
vol_type="XtremIO"
vol_size=10
vol_name=XtremIO_BootVol-

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

# Delete the volumes
for vol in $(seq -f "%02g" 1 5)
   do
     echo "`date` "=" cinder delete ${vol_name}${vol}"
     cinder delete ${vol_name}${vol} & >/dev/null
   done

sleep 1
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Completed Volume Deletion"
echo "`date` = =========================================================="
echo "`date` = "
echo "`date` = cinder list"
sleep 20
cinder list

endvols=$(cinder list | grep Xtr | wc -l|xargs)

echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = $endvols Volumes Remain" 
echo "`date` = =========================================================="
echo "`date` = "


