#!/bin/bash
#  Run dstat and collect output into csv files.
#  Collect system profile, summarizing system state

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
HDD=()
SSD=()
pcidev=$(lspci | egrep 'SATA|SAS' | grep LSI | awk '{print $1}')
drives=($(ls -l /dev/disk/by-path | egrep $pcidev | awk '{print substr($11, 7)}' | sort))

# Loop through array and check each drive to see if it is an SSD or HDD then populate
# HDD and SSD appropriately.  We do this so we can monitor the right drives.

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

# Command intervals
sinterval=1
minterval=10
linterval=30
llinterval=3600
count=380

dstat_disk_flags="-D total,$hdd -N bond0,bond1"
dstat_proc_flags="--time -p -c --disk --mem --top-cpu --top-bio --top-latency "
dstat_sys_flags="--time --load --proc --cpu --sys --vm --disk  --net -N bond0,bond1"

#dstat_disk="dstat $dstat_disk_flags $linterval $count"
dstat_disk="dstat $dstat_disk_flags --output $OUTPUTFILE_disk $linterval $count"
dstat_process="dstat $dstat_proc_flags --output $OUTPUTFILE_proc $linterval $count"
dstat_sys="dstat $dstat_sys_flags --output $OUTPUTFILE_sys $linterval $count"

#-- Main 
bg_cmd ${dstat_process}
bg_cmd ${dstat_disk}
bg_cmd ${dstat_sys}

