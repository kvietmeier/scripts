#!/bin/bash
# Delete a group of created volumes

startvols=$(cinder list | grep Xtr | wc -l|xargs)

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

# wait for input
echo "`date` = Press <RETURN> to continue"
read 

for vol in $(seq -f "%03g" 1 20)
   do
     echo "`date` "=" cinder delete XtremIO_Vol${vol}"
     cinder delete XtremIO_Vol${vol} & >/dev/null
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