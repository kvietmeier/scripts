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

# Configure Output
CURRENT_TIME=$(date +%m%d:%H%M)
OUTPUTDIR=${HOME}/dstat/

# Check if the directory for output exists
if [ ! -d $OUTPUTDIR ] ; then
  mkdir $OUTPUTDIR 2> /dev/null
fi

OUTPUTFILE_proc=${OUTPUTDIR}dstat_process.${CURRENT_TIME}.csv
OUTPUTFILE_io=${OUTPUTDIR}dstat_io.${CURRENT_TIME}.csv
OUTPUTFILE_sys=${OUTPUTDIR}dstat_sys.${CURRENT_TIME}.csv


# Command intervals
sinterval=1
minterval=10
linterval=30
llinterval=3600
count=600

# dstat parameters
dstat_io_flags="-D total,$hdd -N bond0,bond1"
dstat_proc_flags="--time -p -c --disk --mem --top-cpu --top-bio --top-latency "
dstat_sys_flags="--time --load --proc --cpu --sys --vm --disk  --net -N eth0,eth1,eth2,eth3,eth4,eth5,eth6,eth7,bond0,bond1"

dstat_io="dstat $dstat_io_flags --output $OUTPUTFILE_io $sinterval $count"
dstat_process="dstat $dstat_proc_flags --output $OUTPUTFILE_proc $sinterval $count"
dstat_sys="dstat $dstat_sys_flags --output $OUTPUTFILE_sys $sinterval $count"

#-- Main 
bg_cmd ${dstat_process}
bg_cmd ${dstat_disk}
bg_cmd ${dstat_sys}

