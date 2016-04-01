#!/bin/bash
# Delete a group of created volumes


echo "`date` = "
echo "`date` = ====================================================="
echo "`date` =                   Removing Volumes "
echo "`date` = ====================================================="
echo "`date` = "
echo "`date` = Deleting Volumes"
echo "`date` = "

# wait for input
echo "`date` = Press <RETURN> to continue"
read 

for vol in {1..20}
   do
     echo "`date`; echo " = " ;cinder delete XtremIO_Vol${vol}"
     echo "`date` = "
     cinder delete XtremIO_Vol${vol} & >/dev/null
   done

sleep 1
echo "`date` = "
echo "`date` = "
echo "`date` = Completed Volume Deletion"
sleep 1
echo "`date` = cinder list"
cinder list
echo "`date` = "
echo "`date` = $(cinder list | grep Xtr | wc -l) Volumes" 
echo "`date` = "