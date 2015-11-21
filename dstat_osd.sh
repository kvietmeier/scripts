#!/bin/bash
###======================================= dstat_osd.sh =====================================================### 
###  Basic Usage: Run dstat and collect output into csv files.
###  Collect system profile while monitoring disk usage during benchmark runs or performancde troubleshooting
###  Created By:   Karl Vietmeier
###                Technical Leader, Cloud Engineering Cisco System
###
###  To Do:
###        Prompt for output directory
###        Prompt for duration
###==========================================================================================================### 

#-- Functions
# Run cmd in background
bg_cmd()
  {
    cmd="$@"
    ${cmd} &>/dev/null &
    disown
  }

#-- End Functions

#-- Variables/Setup
# Empty Arrays
HDD=()
SSD=()
# Collect the disk devices to run dstat against
pcidev=$(lspci | egrep 'SATA|SAS' | grep LSI | awk '{print $1}')
drives=($(ls -l /dev/disk/by-path | egrep $pcidev | grep -v part | awk '{print substr($11, 7)}' | sort))

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

hdd=$(IFS=,; echo "${HDD[*]}")
CURRENT_TIME=$(date +%m%d:%H%M)
OUTPUTDIR="/root/output/"
OUTPUTFILE_proc=${OUTPUTDIR}dstat_process.${CURRENT_TIME}.csv
OUTPUTFILE_disk=${OUTPUTDIR}dstat_disk.${CURRENT_TIME}.csv
OUTPUTFILE_sys=${OUTPUTDIR}dstat_sys.${CURRENT_TIME}.csv

# Command delays
sdelay=1
mdelay=10
ldelay=30
lldelay=3600
count=50000

dstat_disk_flags="-D total,$hdd -N bond0,bond1"
dstat_proc_flags="--time -p -c --disk --mem --top-cpu --top-bio --top-latency "
dstat_sys_flags="--time --load --proc --cpu --sys --vm --disk  --net -N bond0,bond1"

#dstat_disk="dstat $dstat_disk_flags $ldelay $count"
dstat_disk="dstat $dstat_disk_flags --output $OUTPUTFILE_disk $mdelay $count"
dstat_process="dstat $dstat_proc_flags --output $OUTPUTFILE_proc $mdelay $count"
dstat_sys="dstat $dstat_sys_flags --output $OUTPUTFILE_sys $mdelay $count"

#-- Main 
bg_cmd ${dstat_process}
bg_cmd ${dstat_disk}
bg_cmd ${dstat_sys}

