#!/bin/bash
# Create Nova instances based on existing volumes of type "XtremIO"

for vol in {1..20}
   do
     echo "Delete Volume XtremIO_Vol${vol}"
     echo "cinder delete XtremIO_Vol${vol}"
     echo "---"
     cinder delete XtremIO_Vol${vol} 
   done

sleep 1
echo "Finished Deleting Volumes"
cinder list