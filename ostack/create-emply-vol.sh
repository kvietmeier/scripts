#!/bin/bash
# Create Nova instances based on existing volumes of type "XtremIO"

for vol in {006..200}
   do
     echo "cinder create 10 --display-name XtremIO_Vol${vol} --volume-type XtremIO"
     echo "...."
     cinder create 10 --display-name XtremIO_Vol${vol} --volume-type XtremIO &> /dev/null
   done

sleep 10
echo "Completed Volumes"
cinder list