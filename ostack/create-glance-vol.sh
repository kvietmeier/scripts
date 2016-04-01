#!/bin/bash
# Create volumes and copy glance image to the volume

# in each script
# echo "date - Copy glance image to volume"
# wait for keyboard
for vol in {001..005}
	do
		echo "cinder create 10 --display-name XtermIO_Vol${vol} --image-id 811fed1f-7d13-4da2-900e-f33e5ceff682 --volume-type XtremIO"
		echo "...."
		cinder create 10 --display-name XtermIO_Vol${vol} --image-id 811fed1f-7d13-4da2-900e-f33e5ceff682 --volume-type XtremIO &> /dev/null
   done

sleep 10
# echo "date - Completed Copy glance image to volume"
# wait for keyboard
echo "Volume Status"
cinder list