#!/bin/bash
###======================================================================================###
#   Create volumes and copy glance image to the volume
#   Created by:  Karl Vietmeier
#                karlv@storagenet.org
#  
#   Create an arbitrary number of empty Cinder volumes to test XtermIO Cinder driver
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
echo "`date` =  Creating $num_vols Volumes and copying Glance Image"
echo "`date` = =========================================================="
echo "`date` = "
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Creating Volumes and Copying Image"
echo "`date` = =========================================================="
echo "`date` = "

# Wait for input
echo "`date` = Press <RETURN> to continue"
read 

# Create the volumes
for vol in $(seq -f "%02g" 1 5)
	do
		echo "`date` = cinder create $vol_size --display-name ${vol_name}${vol} --image-id $image_id --volume-type $vol_type"
		cinder create $vol_size --display-name ${vol_name}${vol} --image-id $image_id --volume-type $vol_type &> /dev/null
   done

sleep 10

echo "`date` = "
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Completed Volume Creation and Image Copy"
echo "`date` = =========================================================="
sleep 1
echo "`date` = cinder list"
cinder list

endvols=$(cinder list | grep BootVol | wc -l|xargs)

echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = $endvols Nova Bootable Volumes Created" 
echo "`date` = =========================================================="
echo "`date` = "
sleep 5


