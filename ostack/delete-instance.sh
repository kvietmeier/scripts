#!/bin/bash
##======================================================================================###
#   Delete Nova Instances
#   Created by:  Karl Vietmeier
#                karl.vietmeier@wwt.com
#  
#   Delete Nova instances 
###======================================================================================###

count=1
instances=$(nova list | grep ACTIVE | wc -l|xargs)



echo "`date` = =========================================================="
echo "`date` = There are Currently $instances Instances Active in the Project"
echo "`date` = =========================================================="
echo "`date` = "
echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Deleting Instances"
echo "`date` = =========================================================="
echo "`date` = "

# Wait for input
echo "`date` = Press <RETURN> to continue"
read 

for instance in $(nova list | awk '$6 == "ACTIVE" {print $2}')
  do
    #echo "`date` = Deleting Instance $instance"
    echo "`date` = nova delete $instance"
    nova delete $instance
    count=$((count+1))
  done


count=$((count-1))

echo "`date` = "
echo "`date` = =========================================================="
echo "`date` = Completed Deleting $count Instances"
echo "`date` = =========================================================="
echo "`date` = "
sleep 10
nova list