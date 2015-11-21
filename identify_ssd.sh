#!/bin/bash
###=========================  identify_ssd.sh  =========================###
#  Programatically identify which devices on an LSI controller are SSD and
#  which are HDD
#
#  Created By:  Karl Vietmeier
###=====================================================================###

# Create empty arrays 
HHD=()
SSD=()

# Find the PCI Bus number for the LSI Controller
pcidev=$(lspci | egrep 'SATA|SAS' | grep LSI | awk '{print $1}')

# Dump the drives into an array for later processing
drives=($(ls -l /dev/disk/by-path | egrep $pcidev | awk '{print substr($11, 7)}' | sort))
echo ""
echo "[==============================]"
echo " Found ${#drives[*]} Drives, checking type"
echo "[==============================]"
echo ""

# Loop through array and check each drive to see if it is an SSD or HDD then populate 
# HDD and SSD apprpriately

for drive in "${drives[@]}"
do
     type=$(cat /sys/block/${drive}/queue/rotational)
     if [ $type == 1 ]
        then 
            HDD[${#HDD[*]}]=$drive
     elif [ $type == 0 ]
        then 
            SSD[${#SSD[*]}]=$drive
     fi
     #echo "$drive = $type"
done

# Are they populated correctly?

echo "These are Spinning Disks"
echo ${HDD[@]} 
echo "These are Solid State"
echo ${SSD[@]}
