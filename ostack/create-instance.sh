#!/bin/bash
# Create Nova instances based on existing volumes of type "XtremIO"

count=1
#for vol in $(cinder list | awk '$4 == "available" && $10 == "XtremIO" {print $2}')
for vol in $(cinder list | awk '$10 == "XtremIO" {print $2}')
      do
        echo "Creating Instances"
        echo "nova boot --flavor m1.XtremIO --block-device source=volume,id=$vol,dest=volume,shutdown=remove,bootindex=0 --nic net-id=f9c5a3ef-f600-40a0-9965-a39ff8f6be11 Instance${count} &> /dev/null"
        #nova boot --flavor m1.XtremIO --block-device source=volume,id=$vol,dest=volume,shutdown=remove,bootindex=0 --nic net-id=f9c5a3ef-f600-40a0-9965-a39ff8f6be11 Instance${count} &> /dev/null
        count=$((count+1))
      done

sleep 5
echo "Completed Creating Instances"
nova list
