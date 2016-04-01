#!/bin/bash
# Create Nova instances based on existing volumes of type "XtremIO"


echo "Currently no Volumes"
cinder list
# echo "date - Copy glance image to volume"
echo "Creating 500 Volume - `date`"

# wait for input
for vol in {001..500}
   do
     echo "cinder create 10 --display-name XtremIO_Vol${vol} --volume-type XtremIO"
     echo "...."
     cinder create 10 --display-name XtremIO_Vol${vol} --volume-type XtremIO &> /dev/null
   done

sleep 10
echo "Completed Volume Creation"
sleep 10
cinder list
sleep 5
cinder list | grep Xtr | wc -l 