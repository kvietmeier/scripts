#!/bin/bash
##======================================================================================###
#   Create Nova Instances
#   Created by:  Karl Vietmeier
#  
#   Create Nova instances based on existing volumes of type "XtremIO"
###======================================================================================###

### Vars
count=1
instances=$(nova list | grep ACTIVE | wc -l|xargs)
startvols=$(cinder list | grep Xtr | wc -l|xargs)
netid=$(neutron net-list | awk '$4 ~ /XtremIO/ {print $2}')
flavorid=$(nova flavor-list | awk '$4 ~ /XtremIO/ {print $2}')


### Main
echo "`date` = =========================================================="
echo "`date` = There are Currently $instances Instances Active in the Project"
echo "`date` = =========================================================="
echo "`date` = "
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Creating Nova Instances"
echo "`date` = =========================================================="
echo "`date` = "

# Wait for input
echo "`date` = Press <RETURN> to continue"
read 


#for vol in $(cinder list | awk '$4 == "available" && $10 == "XtremIO" {print $2}')
for vol in $(cinder list | awk '$10 == "XtremIO" {print $2}')
  do
    #echo "`date` = Creating Instance"
    echo "nova boot --flavor $flavorid --block-device source=volume,id=$vol,dest=volume,shutdown=remove,bootindex=0 --nic net-id=$netid Instance${count} &> /dev/null"
    #echo "nova boot --flavor $flavorid --block-device source=volume,id=$vol"
    #nova boot --flavor m1.XtremIO --block-device source=volume,id=$vol,dest=volume,shutdown=remove,bootindex=0 --nic net-id=$netid Instance${count}
    count=$((count+1))
  done

echo ""
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Completed Instance Creation"
echo "`date` = =========================================================="

end_count=$((count-1))
new_nova=$(nova list | grep ACTIVE | wc -l|xargs)
endvols=$(cinder list | grep Xtr | wc -l|xargs)

echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = $end_count Instances Created" 
echo "`date` = =========================================================="
echo "`date` = "
sleep 15

nova list
